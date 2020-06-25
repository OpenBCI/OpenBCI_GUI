import brainflow.*;

class BoardBrainFlowStreaming extends BoardBrainFlow implements AccelerometerCapableBoard {

    private int masterBoardId;
    private String ipAddress;
    private int ipPort;

    public BoardBrainFlowStreaming(int masterBoardId, String ipAddress, int ipPort) {
        super();
        this.masterBoardId = masterBoardId;
        this.ipAddress = ipAddress;
        this.ipPort = ipPort;
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.ip_address = ipAddress;
        params.ip_port = ipPort;
        params.other_info = Integer.toString(masterBoardId, 10);
        return params;
    }

    // for streaming board need to use master board id in function like  get_eeg_channels
    @Override
    public BoardIds getBoardId() {
        return BoardIds.from_code(masterBoardId);
    }

    @Override
    public boolean initializeInternal() {
        try {
            // here we need to provide board id of streaming board
            boardShim = new BoardShim (BoardIds.STREAMING_BOARD.get_code(), getParams());
            try {
                BoardShim.enable_dev_board_logger();
                BoardShim.set_log_file("brainflow_log.txt");
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
            boardShim.prepare_session();
            return true; 

        } catch (Exception e) {
            boardShim = null;
            outputError("ERROR: " + e + " when initializing Brainflow board. Data will not stream.");
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public void setEXGChannelActive(int channelIndex, boolean active) {
        // do nothing here
    }

    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return true;
    }

    @Override
    protected void addChannelNamesInternal(String[] channelNames) {
        // do nothing here
    }

    @Override
    public boolean isAccelerometerActive() {
        if (getAccelerometerChannels().length != 0) {
            return true;
        }
        return false;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        // nothing
    }

    @Override
    public boolean canDeactivateAccelerometer() {
        return false;
    }

    @Override
    public int[] getAccelerometerChannels() {
        try {
            return BoardShim.get_accel_channels(masterBoardId);
        } catch (BrainFlowError e) {
            // nothing
        }

        return new int[0];
    }

};
