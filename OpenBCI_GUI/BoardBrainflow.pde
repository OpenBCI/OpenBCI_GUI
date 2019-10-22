import brainflow.*;
import org.apache.commons.lang3.SystemUtils;

abstract class BoardBrainFlow implements Board {
    private DataPacket_ADS1299 dataPacket;
    private BoardShim board_shim = null;

    private int packetNumberChannel = 0;
    private int[] eegChannels = {};
    private int[] accelChannels = {};

    private boolean streaming = false;
    private BrainFlowInputParams params;
    private int samplingRate = 0;

    private int[] lastAccelValues = {};

    /* Abstract Functions.
     * Implement these in your board.
     */
    abstract public BoardIds getBoardType();
    abstract protected BrainFlowInputParams getParams();

    public int getBoardTypeInt() {
        return getBoardType().get_code();
    } 

    protected BoardBrainFlow() {
        params = getParams();

        try {
            packetNumberChannel = BoardShim.get_package_num_channel(getBoardTypeInt());
            eegChannels = BoardShim.get_eeg_channels(getBoardTypeInt());
            accelChannels = BoardShim.get_accel_channels(getBoardTypeInt());
            samplingRate = BoardShim.get_sampling_rate(getBoardTypeInt());
            lastAccelValues = new int[accelChannels.length];
        } catch (BrainFlowError e) {
            println("WARNING: failed to get board info from BoardShim");
            e.printStackTrace();
        }
    }

    @Override
    public void initialize() {
        try {
            updateToNChan(getNumChannels());

            board_shim = new BoardShim (getBoardTypeInt(), params);
            board_shim.prepare_session();

        } catch (Exception e) {
            board_shim = null;
            outputError("ERROR: " + e + " when initializing Brainflow board. Data will not stream.");
            e.printStackTrace();
        }

        dataPacket = new DataPacket_ADS1299(getNumChannels(), accelChannels.length);
    }

    @Override
    public void uninitialize() {
        if(board_shim != null) {
            try {
                board_shim.release_session();
            } catch (BrainFlowError e) {
                println("WARNING: could not release brainflow board.");
                e.printStackTrace();
            }
        }
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

            for (int i=0; i<accelChannels.length; i++)
            {
                dataPacket.auxValues[i] = (int)Math.round(data[accelChannels[i]][count]);
                lastAccelValues[i] = (int)Math.round(data[accelChannels[i]][count]);
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

    @Override
    public int getSampleRate() {
        return samplingRate;
    }

    @Override
    public int getNumChannels() {
        return eegChannels.length;
    }

    @Override
    public int[] getLastAccelValues() {
        return lastAccelValues;
    }
};
