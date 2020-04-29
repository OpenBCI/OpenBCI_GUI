
/* This class does nothing, it serves as a signal that the board we are using
 * is null, but does not crash if we use it.
 */
class BoardNull extends Board {

    @Override
    public boolean initializeInternal() {
        return true;
    }

    @Override
    public void uninitializeInternal() {
        // empty
    }

    @Override
    public void updateInternal() {
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

    public boolean isConnected() {
        return false;
    }

    @Override
    public int getSampleRate() {
        return 0;
    }

    @Override
    public int[] getEXGChannels() {
        return new int[0];
    }

    @Override
    public int getTimestampChannel() {
        return 0;
    }
    
    @Override
    public int getSampleNumberChannel() {
        return 0;
    }

    @Override
    public void setEXGChannelActive(int channelIndex, boolean active) {
        // empty
    }
    
    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return false;
    }

    @Override
    public void sendCommand(String command) {
        // empty
    }

    @Override
    public void setSampleRate(int sampleRate) {
        // empty
    }

    protected double[][] getNewDataInternal() {
        return new double[1][0];
    }

    @Override
    public int getTotalChannelCount() {
        return 0;
    }

    protected void addChannelNamesInternal(String[] channelNames) {
        // nothing
    }
};
