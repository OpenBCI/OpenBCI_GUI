class DataSourcePlaybackCyton extends DataSourcePlayback implements AccelerometerCapableBoard, AnalogCapableBoard, DigitalCapableBoard, FileBoard  {
   
    DataSourcePlaybackCyton(String filePath) {
        super(filePath);
    }

    @Override
    public int getAccelSampleRate() {
        return getSampleRate();
    }

    @Override
    public int getAnalogSampleRate() {
        return getSampleRate();
    }

    @Override
    public int getDigitalSampleRate() {
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
    public boolean isAnalogActive() {
        return underlyingBoard instanceof AnalogCapableBoard;
    }

    @Override
    public void setAnalogActive(boolean active) {
        // nothing
    }

    @Override
    public boolean canDeactivateAnalog() {
        return false;
    }

    @Override
    public int[] getAnalogChannels() {
        if (underlyingBoard instanceof AnalogCapableBoard) {
            return ((AnalogCapableBoard)underlyingBoard).getAnalogChannels();
        }

        return new int[0];
    }

    @Override
    public boolean isDigitalActive() {
        return underlyingBoard instanceof DigitalCapableBoard;
    }

    @Override
    public void setDigitalActive(boolean active) {
        // nothing
    }

    @Override
    public boolean canDeactivateDigital() {
        return false;
    }

    @Override
    public int[] getDigitalChannels() {
        if (underlyingBoard instanceof DigitalCapableBoard) {
            return ((DigitalCapableBoard)underlyingBoard).getDigitalChannels();
        }

        return new int[0];
    }

    @Override
    public List<double[]> getDataWithAnalog(int maxSamples) {
        return getData(maxSamples);
    }

    @Override
    public List<double[]> getDataWithDigital(int maxSamples) {
        return getData(maxSamples);
    }

    @Override
    public List<double[]> getDataWithAccel(int maxSamples) {
        return getData(maxSamples);
    }

}
