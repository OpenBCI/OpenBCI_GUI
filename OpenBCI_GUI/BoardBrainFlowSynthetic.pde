import brainflow.*;

class BoardBrainFlowSynthetic extends BoardBrainFlow
implements AccelerometerCapableBoard, PPGCapableBoard, EDACapableBoard {

    private int[] accelChannelsCache = null;
    private int[] edaChannelsCache = null;
    private int[] ppgChannelsCache = null;

    public BoardBrainFlowSynthetic() {
        super();
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
    public void setEXGChannelActive(int channelIndex, boolean active) {
        // Dummy string
        sendCommand("SYNTHETIC PLACEHOLDER");
    }

    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return true;
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
    public boolean isPPGActive() {
        return true;
    }

    @Override
    public void setPPGActive(boolean active) {
        outputWarn("PPG is always active for BrainflowSyntheticBoard");
    }

    @Override
    public int[] getPPGChannels() {
        if(ppgChannelsCache == null) {
            try {
                ppgChannelsCache = BoardShim.get_ppg_channels(getBoardIdInt());

            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }

        return ppgChannelsCache;
    }

    @Override
    public boolean isEDAActive() {
        return true;
    }

    @Override
    public void setEDAActive(boolean active) {
        outputWarn("EDA is always active for BrainflowSyntheticBoard");
    }

    @Override
    public int[] getEDAChannels() {
        if (edaChannelsCache == null) {
            try {
                edaChannelsCache = BoardShim.get_eda_channels(getBoardIdInt());

            } catch (BrainFlowError e) {
                e.printStackTrace();
            }
        }

        return edaChannelsCache;
    }
    
    @Override
    protected void addChannelNamesInternal(String[] channelNames) {
        for (int i=0; i<getEDAChannels().length; i++) {
            channelNames[getEDAChannels()[i]] = "EDA Channel " + i;
        }
        for (int i=0; i<getPPGChannels().length; i++) {
            channelNames[getPPGChannels()[i]] = "PPG Channel " + i;
        }
        for (int i=0; i<getAccelerometerChannels().length; i++) {
            channelNames[getAccelerometerChannels()[i]] = "Accel Channel " + i;
        }
    }
};
