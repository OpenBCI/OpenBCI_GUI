import brainflow.*;

import org.apache.commons.lang3.tuple.Pair;

public enum BrainFlowStreaming_Boards
{
    CYTON("Cyton", BoardIds.CYTON_BOARD),
    CYTONDAISY("CytonDaisy", BoardIds.CYTON_DAISY_BOARD),
    GANGLION("Ganglion", BoardIds.GANGLION_BOARD),
    SYNTHETIC("Synthetic", BoardIds.SYNTHETIC_BOARD);

    private String name;
    private BoardIds boardId;
 
    BrainFlowStreaming_Boards(String _name, BoardIds _boardId) {
        this.name = _name;
        this.boardId = _boardId;
    }
 
    public String getName() {
        return name;
    }

    public BoardIds getBoardId() {
        return boardId;
    }
}

class BoardBrainFlowStreaming extends BoardBrainFlow implements AccelerometerCapableBoard {

    private BoardIds masterBoardId;
    private String ipAddress;
    private int ipPort;

    public BoardBrainFlowStreaming(BoardIds masterBoardId, String ipAddress, int ipPort) {
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
        params.other_info = Integer.toString(masterBoardId.get_code(), 10);
        return params;
    }

    // for streaming board need to use master board id in function like  get_eeg_channels
    @Override
    public BoardIds getBoardId() {
        return masterBoardId;
    }

    @Override
    public boolean initializeInternal() {
        try {
            // here we need to provide board id of streaming board
            boardShim = new BoardShim (BoardIds.STREAMING_BOARD.get_code(), getParams());
            try {
                BoardShim.enable_dev_board_logger();
                BoardShim.set_log_file(directoryManager.getConsoleDataPath() + "Brainflow_" +
                    directoryManager.getFileNameDateTime() + ".txt");
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
            return BoardShim.get_accel_channels(masterBoardId.get_code());
        } catch (BrainFlowError e) {
            // nothing
        }

        return new int[0];
    }

    @Override
    protected PacketLossTracker setupPacketLossTracker() {
        if (masterBoardId == BoardIds.CYTON_DAISY_BOARD) {
                return new PacketLossTrackerCytonSerialDaisy(getSampleIndexChannel(), getTimestampChannel());
        }
        final int minSampleIndex = 0;
        final int maxSampleIndex = 255;
        return new PacketLossTracker(getSampleIndexChannel(), getTimestampChannel(),
                                    minSampleIndex, maxSampleIndex);
    }

};
