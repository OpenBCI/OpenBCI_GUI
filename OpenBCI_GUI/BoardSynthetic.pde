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

/* This class does nothing, it serves as a signal that the board we are using
 * is null, but does not crash if we use it.
 */
class BoardNull extends BoardSynthetic {

    @Override
    public void update() {} // empty

    @Override
    public void startStreaming() {
        println("WARNING: calling 'startStreaming' on a NULL board!");
    }

    @Override
    public void stopStreaming() {
        println("WARNING: calling 'stopStreaming' on a NULL board!");
    }
};
