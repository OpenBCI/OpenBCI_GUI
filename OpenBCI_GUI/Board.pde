
abstract class Board {

    private FixedStack<double[]> accumulatedData = new FixedStack<double[]>();
    private double[][] dataThisFrame;

    // accessible by all boards, can be returned as valid empty data
    protected double[][] emptyData;

// ***************************************
// public interface
    public int getBufferSize() {
        return dataBuff_len_sec * getSampleRate();
    }

    public boolean initialize() {
        boolean res = initializeInternal();

        double[] fillData = new double[getTotalChannelCount()];
        accumulatedData.setSize(getBufferSize());
        accumulatedData.fill(fillData);

        emptyData = new double[getTotalChannelCount()][0];

        return res;
    }

    public void uninitialize() {
        uninitializeInternal();
    }

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
    }

    public int getNumEXGChannels() {
        return getEXGChannels().length;
    }

    // returns all the data this board has received in this frame
    public double[][] getFrameData() {
        return dataThisFrame;
    }

    public List<double[]> getData(int maxSamples) {
        int endIndex = accumulatedData.size();
        int startIndex = max(0, endIndex - maxSamples);

        return accumulatedData.subList(startIndex, endIndex);
    }    

    public abstract void startStreaming();

    public abstract void stopStreaming();

    public abstract boolean isConnected();

    public abstract int getSampleRate();

    public abstract void setChannelActive(int channelIndex, boolean active);

    public abstract void sendCommand(String command);

    public abstract void setSampleRate(int sampleRate);

    public abstract int[] getEXGChannels();

// ***************************************
// protected methods implemented by board

    // implemented by each board class and used internally here to accumulate the FixedStack
    // and provide with public interfaces getFrameData() and getData(int)
    protected abstract double[][] getNewDataInternal();

    protected abstract boolean initializeInternal();

    protected abstract void uninitializeInternal();

    protected abstract void updateInternal();

    protected abstract int getTotalChannelCount();

};
