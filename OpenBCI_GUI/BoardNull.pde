
/* This class does nothing, it serves as a signal that the board we are using
 * is null, but does not crash if we use it.
 */
class BoardNull implements Board {

    @Override
    public void initialize() {
        // empty
    }

    @Override
    public void uninitialize() {
        // empty
    }

    @Override
    public void update() {
        // empty
    }

    @Override
    public void startStreaming() {
        println("WARNING: calling 'startStreaming' on a NULL board!");
    }

    @Override
    public void stopStreaming() {
        println("WARNING: calling 'stopStreaming' on a NULL board!");
    }
};
