
interface Board {

    public boolean initialize();

    public void uninitialize();

    public void update();

    public void startStreaming();

    public void stopStreaming();

    public boolean isConnected();

    public int getSampleRate();
    
    public int getNumChannels();

    public void setChannelActive(int channelIndex, boolean active);

    public void sendCommand(String command);

    public void setSampleRate(int sampleRate);
};
