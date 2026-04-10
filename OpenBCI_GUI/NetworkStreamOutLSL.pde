class NetworkStreamOutLSL extends NetworkStreamOut {

    private LSL.StreamOutlet outlet_data;
    private String streamType;
    private String streamName;
    private int numLslDataPoints;
    
    NetworkStreamOutLSL(NetworkDataType dataType, String streamName, String streamType, int numLslDataPoints, int _streamNumber) {
        super(dataType);
        protocol = NetworkProtocol.LSL;
        this.streamNumber = _streamNumber;
        this.streamName = streamName;
        this.streamType = streamType;
        this.numLslDataPoints = numLslDataPoints;
        //openNetwork();
    }

    @Override
    protected void openNetwork() {
        super.openNetwork();
        String streamId = "openbcigui";
        LSL.StreamInfo infoData = new LSL.StreamInfo(this.streamName, 
                this.streamType,
                this.numLslDataPoints,
                currentBoard.getSampleRate(),
                LSL.ChannelFormat.float32,
                streamId);
        outlet_data = new LSL.StreamOutlet(infoData);
    }

    @Override
    protected void closeNetwork() {
        outlet_data.close();
    }

    @Override
    protected StringList getAttributes() {
        StringList attributes = new StringList();
        attributes.append(dataType.getString());
        attributes.append(this.streamName);
        attributes.append(this.streamType);
        attributes.append(str(this.numLslDataPoints));
        return attributes;
    }

    @Override
    protected void sendTimeSeriesFilteredData() {
        output2dArrayLSL(dataAccumulator.getTimeSeriesFilteredBuffer());
    }

    @Override
    protected void sendTimeSeriesRawData() {
        output2dArrayLSL(dataAccumulator.getTimeSeriesRawBuffer());
    }

    @Override
    protected void sendFocusData() {
        final int metricValue = dataAccumulator.getFocusValueExceedsThreshold();
        final float[] output = new float[] { (float) metricValue };
        outlet_data.push_sample(output);
    }

    @Override
    protected void sendFFTData() {
        final ddf.minim.analysis.FFT[] fftBuff = dataAccumulator.getFFTBuffer();
        final float[] dataToSend = new float[numExgChannels * NUM_FFT_BINS_TO_SEND];
        for (int i = 0; i < numExgChannels; i++) {
            for (int j = 0; j < NUM_FFT_BINS_TO_SEND; j++) {
                dataToSend[j + NUM_FFT_BINS_TO_SEND * i] = fftBuff[i].getBand(j);
            }
        }
        outlet_data.push_chunk(dataToSend);
    }

    @Override
    protected void sendBandPowersAllChannels() {
        final float[][] bandPowerData = dataAccumulator.getAllBandPowerData();
        // Send out band powers for each channel sequentially via push_sample
        // Prepend channel number to each array
        // push_chunk will send out all channels at once...but doesn't seem to gaurantee all X channels of data will be pulled at once, despite extensive testing
        // Example sample: [Channel Number, DELTA, THETA, ALPHA, BETA, GAMMA]
        float[] dataToSend = new float[NUM_BAND_POWERS + 1];
        for (int channel = 0; channel < numExgChannels; channel++) {
            for (int band = 0; band < NUM_BAND_POWERS + 1; band++) {
                if (band == 0) {
                    dataToSend[band] = (float) channel;
                } else {
                    dataToSend[band] = bandPowerData[channel][band - 1];
                }
            }
            outlet_data.push_sample(dataToSend);
        }
    }

    @Override
    protected void sendNormalizedBandPowerData() {
        outlet_data.push_sample(dataAccumulator.getNormalizedBandPowerData());
    }

    @Override
    protected void sendEMGData() {
        outlet_data.push_sample(dataAccumulator.getEmgNormalizedValues());
    }

    @Override
    protected void sendAccelerometerData() {
        output2dArrayLSL(dataAccumulator.getAccelBuffer());
    }

    @Override
    protected void sendAnalogData() {
        output2dArrayLSL(dataAccumulator.getAnalogBuffer());
    }

    @Override
    protected void sendDigitalData() {
        output2dArrayLSL(dataAccumulator.getDigitalBuffer());
    }

    @Override
    protected void sendPulseData() {
        float[] dataToSend = new float[2];
        dataToSend[0] = dataAccumulator.getPulseSensorBPM();
        dataToSend[1] = dataAccumulator.getPulseSensorIBI();
        outlet_data.push_sample(dataToSend);
    }

    @Override
    protected void sendEMGJoystickData() {
        final float[] emgJoystickXY = dataAccumulator.getEMGJoystickXY();
        float[] dataToSend = new float[emgJoystickXY.length];
        for (int i = 0; i < emgJoystickXY.length; i++) {
            dataToSend[i] = emgJoystickXY[i];
        }
        outlet_data.push_sample(dataToSend);
    }

    @Override
    protected void sendMarkerData() {
        outlet_data.push_chunk(dataAccumulator.getMarkerBuffer());
    }

    private void output2dArrayLSL(float[][] dataBuffer) {
        float[] flattenedDataArray = new float[dataBuffer.length * dataBuffer[0].length];
        for (int sample = 0; sample < dataBuffer[0].length; sample++) {
            for (int channel = 0; channel < dataBuffer.length; channel++) {
                flattenedDataArray[channel + sample * dataBuffer.length] = dataBuffer[channel][sample];
            }
        }
        outlet_data.push_chunk(flattenedDataArray);
    }

    private void output2dArrayLSL(int[][] dataBuffer) {
        float[] flattenedDataArray = new float[dataBuffer.length * dataBuffer[0].length];
        for (int sample = 0; sample < dataBuffer[0].length; sample++) {
            for (int channel = 0; channel < dataBuffer.length; channel++) {
                flattenedDataArray[channel + sample * dataBuffer.length] = dataBuffer[channel][sample];
            }
        }
        outlet_data.push_chunk(flattenedDataArray);
    }
}