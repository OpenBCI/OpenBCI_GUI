
interface Board {

    public boolean initialize();

    public void uninitialize();

    public void update();

    public void startStreaming();

    public void stopStreaming();

    public int getSampleRate();
    
    public int getNumChannels();

    public float[] getLastAccelValues();

    public void setChannelActive(int channelIndex, boolean active);
};
