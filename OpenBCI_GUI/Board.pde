import org.apache.commons.lang3.tuple.Pair;

abstract class Board implements DataSource {

    private FixedStack<double[]> accumulatedData = new FixedStack<double[]>();
    private double[][] dataThisFrame;
    private PacketLossTracker packetLossTracker;

    // accessible by all boards, can be returned as valid empty data
    protected double[][] emptyData;

    @Override
    public boolean initialize() {
        boolean res = initializeInternal();

        double[] fillData = new double[getTotalChannelCount()];
        accumulatedData.setSize(getCurrentBoardBufferSize());
        accumulatedData.fill(fillData);

        emptyData = new double[getTotalChannelCount()][0];

        packetLossTracker = setupPacketLossTracker();

        return res;
    }

    @Override
    public void uninitialize() {
        uninitializeInternal();
    }

    @Override
    public void startStreaming() {
        packetLossTracker.onStreamStart();
    }

    @Override
    public void stopStreaming() {
        
        // empty
    }

    @Override
    public void update() {
        updateInternal();

        dataThisFrame = getNewDataInternal();

        for (int i = 0; i < dataThisFrame[0].length; i++) {
            double[] newEntry = new double[getTotalChannelCount()];
            for (int j = 0; j < getTotalChannelCount(); j++) {
                newEntry[j] = dataThisFrame[j][i];
            }

            accumulatedData.push(newEntry);
        }

        if( packetLossTracker != null) {
            //TODO: make all API including getNewDataInternal() return List<double[]> 
            // and we can just pass dataThisFrame here.
            packetLossTracker.addSamples(getData(dataThisFrame[0].length));
        }
    }

    @Override
    public int getNumEXGChannels() {
        return getEXGChannels().length;
    }

    // returns all the data this board has received in this frame
    @Override
    public double[][] getFrameData() {
        return dataThisFrame;
    }

    @Override
    public List<double[]> getData(int maxSamples) {
        int endIndex = accumulatedData.size();
        int startIndex = max(0, endIndex - maxSamples);

        return accumulatedData.subList(startIndex, endIndex);
    }

    public String[] getChannelNames() {
        String[] names = new String[getTotalChannelCount()];
        Arrays.fill(names, "Other");

        names[getTimestampChannel()] = "Timestamp";
        names[getSampleIndexChannel()] = "Sample Index";

        int[] exgChannels = getEXGChannels();
        for (int i=0; i<exgChannels.length; i++) {
            names[exgChannels[i]] = "EXG Channel " + i;
        }

        addChannelNamesInternal(names);
        return names;
    }

    public PacketLossTracker getPacketLossTracker() {
        return packetLossTracker;
    }

    public abstract boolean isConnected();

    public abstract Pair <Boolean, String> sendCommand(String command);

    // ***************************************
    // protected methods implemented by board

    // implemented by each board class and used internally here to accumulate the FixedStack
    // and provide with public interfaces getFrameData() and getData(int)
    protected abstract double[][] getNewDataInternal();

    protected abstract boolean initializeInternal();

    protected abstract void uninitializeInternal();

    protected abstract void updateInternal();

    protected abstract void addChannelNamesInternal(String[] channelNames);

    protected abstract PacketLossTracker setupPacketLossTracker();
};
