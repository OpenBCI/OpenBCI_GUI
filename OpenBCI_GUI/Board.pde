
abstract class Board {

    public abstract boolean initialize();

    public abstract void uninitialize();

    public abstract void update();

    public abstract void startStreaming();

    public abstract void stopStreaming();

    public abstract boolean isConnected();

    public abstract int getSampleRate();
    
    public abstract int getNumChannels();

    public abstract void setChannelActive(int channelIndex, boolean active);

    public abstract void sendCommand(String command);

    public abstract void setSampleRate(int sampleRate);
};
