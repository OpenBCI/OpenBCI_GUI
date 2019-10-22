import brainflow.*;

class BoardSynthetic extends BoardBrainFlow {

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.other_info = str(random(43345));
        return params;
    }

    @Override
    public BoardIds getBoardType() {
        return BoardIds.SYNTHETIC_BOARD;
    }
};
