
interface Board {

    public boolean initialize();

    public void uninitialize();

    public void update();

    public void startStreaming();

    public void stopStreaming();

    public boolean isConnected();

    public int getSampleRate();
    
    public int getNumEXGChannels();

    // returns a list of all the channels that contain EXG data.
    // the numbers in this list can be used to index the array
    // returned by getData() to cherrypick EXG data out of it.
    public int[] getEXGChannels();

    // returns all the data this board has received in this frame
    public double[][] getDataThisFrame();

    public void setChannelActive(int channelIndex, boolean active);

    public void sendCommand(String command);

    public void setSampleRate(int sampleRate);
};
