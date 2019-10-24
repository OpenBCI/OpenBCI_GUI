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
};
