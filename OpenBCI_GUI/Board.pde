
interface Board {

    public boolean initialize();

    public void uninitialize();

    public void update();

    public void startStreaming();

    public void stopStreaming();

    public boolean isConnected();

    public int getSampleRate();
    
    public int getNumEXGChannels();

    public int[] getEXGChannels();

    public double[][] getData(int maxSamples);

    public double[][] getData(); // gets all data

    public void setChannelActive(int channelIndex, boolean active);

    public void sendCommand(String command);

    public void setSampleRate(int sampleRate);
};
