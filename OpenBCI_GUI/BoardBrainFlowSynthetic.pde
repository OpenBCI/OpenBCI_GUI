import brainflow.*;

class BoardBrainFlowSynthetic extends BoardBrainFlow implements AccelerometerCapableBoard{

    public BoardBrainFlowSynthetic() {
        super();
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        return params;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.SYNTHETIC_BOARD;
    }

    @Override
    public void setChannelActive(int channelIndex, boolean active) {
        // Dummy string
        configBoard("SYNTHETIC PLACEHOLDER");
    }

    @Override
    public boolean isAccelerometerActive() {
        return true;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        outputWarn("Accelerometer is always active for BrainflowSyntheticBoard");
    }

    @Override
    public int[] getAccelerometerChannels() {
        try {
            return BoardShim.get_accel_channels(getBoardIdInt());
        } catch (BrainFlowError e) {
            println("Error when getting accel channels.");
            e.printStackTrace();
            return new int[0];
        }
    }
};
