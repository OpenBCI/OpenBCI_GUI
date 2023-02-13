class DataSourcePlaybackSynthetic extends DataSourcePlayback implements AccelerometerCapableBoard, FileBoard  {
   
    DataSourcePlaybackSynthetic(String filePath) {
        super(filePath);
    }

    protected boolean instantiateUnderlyingBoard() {
        try {
            underlyingBoard = new BoardBrainFlowSynthetic(nchan);
        } catch (Exception e) {
            println(e.getMessage());
            e.printStackTrace();
            return false;
        }

        return underlyingBoard != null;
    }

    @Override
    public int getAccelSampleRate() {
        return getSampleRate();
    }

    @Override
    public boolean isAccelerometerActive() { 
        return underlyingBoard instanceof AccelerometerCapableBoard;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        // nothing
    }

    @Override
    public boolean canDeactivateAccelerometer() {
        return false;
    }

    @Override
    public int[] getAccelerometerChannels() {
        if (underlyingBoard instanceof AccelerometerCapableBoard) {
            return ((AccelerometerCapableBoard)underlyingBoard).getAccelerometerChannels();
        }

        return new int[0];
    }

    @Override
    public List<double[]> getDataWithAccel(int maxSamples) {
        return getData(maxSamples);
    }

}
