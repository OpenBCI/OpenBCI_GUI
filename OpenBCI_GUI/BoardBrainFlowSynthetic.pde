import brainflow.*;

class BoardBrainFlowSynthetic extends BoardBrainFlow {

    public BoardBrainFlowSynthetic() {
        super(BoardIds.SYNTHETIC_BOARD);
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        return params;
    }

    @Override
    public void setChannelActive(int channelIndex, boolean active) {
        // Dummy string
        configBoard("SYNTHETIC PLACEHOLDER");
    }
};
