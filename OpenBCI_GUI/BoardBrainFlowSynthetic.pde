import brainflow.*;

import org.apache.commons.lang3.tuple.Pair;

class BoardBrainFlowSynthetic extends BoardBrainFlow implements AccelerometerCapableBoard {

    private int[] accelChannelsCache = null;
    private int numChannels = 0;
    private volatile boolean[] activeChannels = null;

    public BoardBrainFlowSynthetic(int numChannels) {
        super();
        this.numChannels = numChannels;
        activeChannels = new boolean[numChannels];
        for (int i = 0; i < numChannels; i++) {
            activeChannels[i] = true;
        }
    }

    // implement mandatory abstract functions
    @Override
    protected BrainFlowInputParams getParams() {
        BrainFlowInputParams params = new BrainFlowInputParams();
        return params;
    }

    @Override
    public BoardIds getBoardId() {
        return BoardIds.SYNTHETIC_BOARD;
    }

    @Override
    public int[] getEXGChannels() {
        int[] channels = super.getEXGChannels();
        int[] res = new int[numChannels];
        for (int i = 0; i < numChannels; i++)
        {
            res[i] = channels[i];
        }
        return res;
    }

    @Override
    public void setEXGChannelActive(int channelIndex, boolean active) {
        activeChannels[channelIndex] = active;
    }

    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return activeChannels[channelIndex];
    }

    @Override
    protected double[][] getNewDataInternal() {
        double[][] data = super.getNewDataInternal();
        int[] exgChannels = getEXGChannels();
        for (int i = 0; i < numChannels; i++) {
            if (!activeChannels[i]) {
                for (int j = 0; j < data[exgChannels[i]].length; j++) {
                    data[exgChannels[i]][j] = 0.0;
                }
            }
        }
        return data;
    }

    @Override
    public boolean isAccelerometerActive() {
        return true;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        outputWarn("Accelerometer is always active for BrainflowSyntheticBoard");
    }

    @Override
    public boolean canDeactivateAccelerometer() {
        return false;
    }

    @Override
    public int[] getAccelerometerChannels() {
        if (accelChannelsCache == null) {
            try {
                accelChannelsCache = BoardShim.get_accel_channels(getBoardIdInt());

            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }

        return accelChannelsCache;
    }

    
    @Override
    protected void addChannelNamesInternal(String[] channelNames) {
        for (int i = 0; i < getAccelerometerChannels().length; i++) {
            channelNames[getAccelerometerChannels()[i]] = "Accel Channel " + i;
        }
        channelNames[getMarkerChannel()] = "Marker Channel";
    }

    @Override
    protected PacketLossTracker setupPacketLossTracker() {
        final int minSampleIndex = 0;
        final int maxSampleIndex = 255;
        return new PacketLossTracker(getSampleIndexChannel(), getTimestampChannel(),
                                    minSampleIndex, maxSampleIndex);
    }

    @Override
    public List<double[]> getDataWithAccel(int maxSamples) {
        return getData(maxSamples);
    }

    @Override
    public int getAccelSampleRate() {
        return getSampleRate();
    }
};
