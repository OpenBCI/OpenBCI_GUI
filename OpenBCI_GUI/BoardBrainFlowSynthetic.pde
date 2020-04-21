import brainflow.*;

class BoardBrainFlowSynthetic extends BoardBrainFlow
implements AccelerometerCapableBoard, PPGCapableBoard, EDACapableBoard {

    private int[] edaChannels = {};
    private int[] ppgChannels = {};


    public BoardBrainFlowSynthetic() {
        super();
        try {
            edaChannels = BoardShim.get_eda_channels(BoardIds.SYNTHETIC_BOARD.get_code ());
            ppgChannels = BoardShim.get_ppg_channels(BoardIds.SYNTHETIC_BOARD.get_code ());
        } catch (BrainFlowError e) {
            e.printStackTrace();
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
    public void setChannelActive(int channelIndex, boolean active) {
        // Dummy string
        configBoard("SYNTHETIC PLACEHOLDER");
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
    public float[] getLastValidAccelValues() {
        return lastValidAccelValues;
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
    public double[][] getPPGValues() {
        double[][] res = new double[ppgChannels.length][];
        for (int i = 0; i < ppgChannels.length; i++) {
            res[i] = new double[rawData[0].length];
            for (int j = 0; j < rawData[0].length; j++) {
                res[i][j] = rawData[ppgChannels[i]][j];
            }
        }
        return res;
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
    public double[][] getEDAValues() {
        double[][] res = new double[edaChannels.length][];
        for (int i = 0; i < edaChannels.length; i++) {
            res[i] = new double[rawData[0].length];
            for (int j = 0; j < rawData[0].length; j++) {
                res[i][j] = rawData[edaChannels[i]][j];
            }
        }
        return res;
    }
};
