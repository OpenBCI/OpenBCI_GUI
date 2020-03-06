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
    public float[] getLastValidAccelValues() {
        return lastValidAccelValues;
    }
};
