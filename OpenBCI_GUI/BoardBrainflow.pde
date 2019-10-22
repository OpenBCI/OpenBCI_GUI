import brainflow.*;
import org.apache.commons.lang3.SystemUtils;

abstract class BoardBrainFlow implements Board {
    private DataPacket_ADS1299 dataPacket;
    private BoardShim board_shim = null;

    private int packetNumberChannel = 0;
    private int[] eegChannels = {};
    private int[] auxChannels = {};

    private boolean streaming = false;

    /* Abstract Functions.
     * Implement these in your board.
     */
    abstract public BoardIds getBoardType();
    abstract protected BrainFlowInputParams getParams();

    public int getBoardTypeInt() {
        return getBoardType().get_code();
    } 

    protected BoardBrainFlow() {} // empty

    @Override
    public void initialize() {
        try {
            BrainFlowInputParams params = getParams();

            packetNumberChannel = BoardShim.get_package_num_channel(getBoardTypeInt());
            eegChannels = BoardShim.get_eeg_channels(getBoardTypeInt());
            auxChannels = BoardShim.get_other_channels(getBoardTypeInt());

            updateToNChan(eegChannels.length);

            board_shim = new BoardShim (getBoardTypeInt(), params);
            board_shim.prepare_session();
            
        } catch (Exception e) {
            board_shim = null;
            outputError("ERROR: " + e + " when initializing Brainflow board. Data will not stream.");
            e.printStackTrace();
        }

        dataPacket = new DataPacket_ADS1299(eegChannels.length, auxChannels.length);
    }

    @Override
    public void uninitialize() {
        // empty for now
    }

    @Override
    public void update() {
        if (!streaming || board_shim == null) {
            return; // early out
        }

        int data_count = 0;
        double[][] data;
        try {
            data_count = board_shim.get_board_data_count();
            data = board_shim.get_board_data();
        }
        catch (BrainFlowError e) {
            println ("ERROR: Exception trying to get board data");
            e.printStackTrace();
            return; // early out
        }

        for (int count = 0; count < data_count; count++)
        {
            dataPacket.sampleIndex = (int)Math.round(data[packetNumberChannel][count]);

            for (int i=0; i < eegChannels.length; i++)
            {
                dataPacket.values[i] = (int)Math.round(data[eegChannels[i]][count]);
            }

            for (int i=0; i<auxChannels.length; i++)
            {
                dataPacket.auxValues[i] = (int)Math.round(data[auxChannels[i]][count]);
            }
            
            // This is also used to let the rest of the code that it may be time to do something
            curDataPacketInd = (curDataPacketInd+1) % dataPacketBuff.length;
            dataPacket.copyTo(dataPacketBuff[curDataPacketInd]);
        }
    }

    @Override
    public void startStreaming() {
        println("Brainflow start streaming");
        if(streaming) {
            println("Already streaming, do nothing");
            return;
        }
        try {
            board_shim.start_stream (3600);
            streaming = true;
        }
        catch (BrainFlowError e) {
            println("ERROR: Exception when starting stream");
            e.printStackTrace();
            streaming = false;
        }
    }

    @Override
    public void stopStreaming() {
        println("Brainflow stop streaming");
        if(!streaming) {
            println("Already stopped streaming, do nothing");
            return;
        }
        streaming = false;
        try {
            board_shim.stop_stream ();
        }
        catch (BrainFlowError e) {
            println("ERROR: Exception when stoppping stream");
            e.printStackTrace();
        }
    }
};
