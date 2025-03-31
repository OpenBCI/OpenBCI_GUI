import brainflow.*;

import org.apache.commons.lang3.tuple.Pair;

public enum BrainFlowPlaybackBoards
{
    CYTON("Cyton", BoardIds.CYTON_BOARD),
    CYTONDAISY("CytonDaisy", BoardIds.CYTON_DAISY_BOARD),
    GANGLION("Ganglion", BoardIds.GANGLION_BOARD),
    SYNTHETIC("Synthetic", BoardIds.SYNTHETIC_BOARD);

    private String name;
    private BoardIds boardId;
 
    BrainFlowPlaybackBoards(String _name, BoardIds _boardId) {
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

class BoardBrainFlowPlayback extends BoardBrainFlow implements AccelerometerCapableBoard {

    private int[] accelChannelsCache = null;
    private BoardIds masterBoardId;
    private String filePath;

    public BoardBrainFlowPlayback(BoardIds masterBoardId, String filePath) {
        super();
        this.masterBoardId = masterBoardId;
        this.filePath = filePath;
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.file = filePath;
        params.master_board = masterBoardId.get_code();
        return params;
    }

    // for playback board need to use master board id in function like get_eeg_channels
    @Override
    public BoardIds getBoardId() {
        return masterBoardId;
    }

    @Override
    public boolean initializeInternal() {
        try {
            // here we need to provide board id of playback board
            boardShim = new BoardShim (BoardIds.PLAYBACK_FILE_BOARD.get_code(), getParams());
            try {
                BoardShim.enable_dev_board_logger();
                BoardShim.set_log_file(directoryManager.getConsoleDataPath() + "Brainflow_" +
                    directoryManager.getFileNameDateTime() + ".txt");
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
            boardShim.prepare_session();
            boardShim.config_board("loopback_true");
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
        outputWarn("EXG is always active for Playback board");
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
    protected PacketLossTracker setupPacketLossTracker() {
        if (masterBoardId == BoardIds.CYTON_DAISY_BOARD) {
                return new PacketLossTrackerCytonSerialDaisy(getSampleIndexChannel(), getTimestampChannel());
        }
        final int minSampleIndex = 0;
        final int maxSampleIndex = 255;
        return new PacketLossTracker(getSampleIndexChannel(), getTimestampChannel(),
                                    minSampleIndex, maxSampleIndex);
    }

    @Override
    public boolean isAccelerometerActive() {
        return true;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        outputWarn("Accelerometer is always active for Playback board");
    }

    @Override
    public boolean canDeactivateAccelerometer() {
        return false;
    }

    @Override
    public int[] getAccelerometerChannels() {
        if (accelChannelsCache == null) {
            try {
                accelChannelsCache = BoardShim.get_accel_channels(getBoardIdInt());
            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }

        return accelChannelsCache;
    }

    @Override
    public List<double[]> getDataWithAccel(int maxSamples) {
        return getData(maxSamples);
    }

    @Override
    public int getAccelSampleRate() {
        return getSampleRate();
    }

};
