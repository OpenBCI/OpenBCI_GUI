import brainflow.*;
import org.apache.commons.lang3.SystemUtils;

abstract class BoardBrainFlow implements Board {
    private DataPacket_ADS1299 dataPacket;
    private BoardIds boardType = BoardIds.SYNTHETIC_BOARD;
    private BoardShim boardShim = null;

    private int samplingRate = 0;
    private int packetNumberChannel = 0;
    private int[] dataChannels = {};
    private int[] accelChannels = {};

    private boolean streaming = false;
    private int[] lastAccelValues = {};

    /* Abstract Functions.
     * Implement these in your board.
     */
    abstract protected BrainFlowInputParams getParams();

    protected BoardBrainFlow(BoardIds boardId) {
        boardType = boardId;
        try {
            samplingRate = BoardShim.get_sampling_rate(getBoardTypeInt());
            packetNumberChannel = BoardShim.get_package_num_channel(getBoardTypeInt());
            dataChannels = BoardShim.get_eeg_channels(getBoardTypeInt());
            accelChannels = BoardShim.get_accel_channels(getBoardTypeInt());
            lastAccelValues = new int[accelChannels.length];
        } catch (BrainFlowError e) {
            println("WARNING: failed to get board info from BoardShim");
            e.printStackTrace();
        }

        dataPacket = new DataPacket_ADS1299(getNumChannels(), accelChannels.length);
    }

    @Override
    public void initialize() {
        try {
            updateToNChan(getNumChannels());

            boardShim = new BoardShim (getBoardTypeInt(), getParams());
            boardShim.prepare_session();

        } catch (Exception e) {
            boardShim = null;
            outputError("ERROR: " + e + " when initializing Brainflow board. Data will not stream.");
            e.printStackTrace();
        }
    }

    @Override
    public void uninitialize() {
        if(boardShim != null) {
            try {
                boardShim.release_session();
            } catch (BrainFlowError e) {
                println("WARNING: could not release brainflow board.");
                e.printStackTrace();
            }
        }
    }

    @Override
    public void update() {
        if (!streaming || boardShim == null) {
            return; // early out
        }

        int data_count = 0;
        double[][] data;
        try {
            data_count = boardShim.get_board_data_count();
            data = boardShim.get_board_data();
        }
        catch (BrainFlowError e) {
            println ("ERROR: Exception trying to get board data");
            e.printStackTrace();
            return; // early out
        }

        for (int count = 0; count < data_count; count++)
        {
            dataPacket.sampleIndex = (int)Math.round(data[packetNumberChannel][count]);

            for (int i=0; i < dataChannels.length; i++)
            {
                dataPacket.values[i] = (int)Math.round(data[dataChannels[i]][count]);
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
            boardShim.start_stream (3600);
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
            boardShim.stop_stream ();
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
        return dataChannels.length;
    }

    @Override
    public int[] getLastAccelValues() {
        return lastAccelValues;
    }
    
    public BoardIds getBoardType() {
        return boardType;
    }

    public int getBoardTypeInt() {
        return getBoardType().get_code();
    }

    protected void configBoard(String configStr) {
        try {
            println("Sending config string to board: " + configStr);
            boardShim.config_board(configStr);
        }
        catch (BrainFlowError e) {
            println("ERROR: Exception sending config string to board: " + configStr);
            e.printStackTrace();
        }
    }
};
