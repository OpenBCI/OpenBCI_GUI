
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

    // returns all the data this board has, all the data types
    // maxSamples limits the amount of samples returned
    public double[][] getData(int maxSamples);

    // number of data samples the board is holding
    // (getData cannot return more than this number of samples)
    public int getDataCount();

    public void setChannelActive(int channelIndex, boolean active);

    public void sendCommand(String command);

    public void setSampleRate(int sampleRate);
};
