import brainflow.*;
import org.apache.commons.lang3.ArrayUtils;

class BoardBrainFlowSynthetic extends BoardBrainFlow {

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        return params;
    }

    @Override
    public BoardIds getBoardType() {
        return BoardIds.SYNTHETIC_BOARD;
    }
};
