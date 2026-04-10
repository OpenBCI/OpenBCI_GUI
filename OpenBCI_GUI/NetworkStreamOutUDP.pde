class NetworkStreamOutUDP extends NetworkStreamOut {

    private UDP udp;
    private String dataTypeKey;

    NetworkStreamOutUDP(NetworkDataType dataType, String ip, int port, int _streamNumber) {
        super(dataType);
        protocol = NetworkProtocol.UDP;
        this.streamNumber = _streamNumber;
        this.ip = ip;
        this.port = port;
        dataTypeKey = dataType.getUDPKey();

        // Force decimal formatting for all Locales
        Locale currentLocale = Locale.getDefault();
        DecimalFormatSymbols otherSymbols = new DecimalFormatSymbols(currentLocale);
        otherSymbols.setDecimalSeparator('.');
        otherSymbols.setGroupingSeparator(',');
        threeDecimalPlaces = new DecimalFormat("0.000", otherSymbols);
        fourLeadingPlaces = new DecimalFormat("####", otherSymbols);
    }

    @Override
    protected void openNetwork() {
        super.openNetwork();
        udp = new UDP(this);
        udp.setBuffer(20000);
        udp.listen(false);
        udp.log(false);
    }

    @Override
    protected void closeNetwork() {
        udp.close();
    }

    @Override
    protected StringList getAttributes() {
        StringList attributes = new StringList();
        attributes.append(dataType.getString());
        attributes.append(this.ip);
        attributes.append(str(this.port));
        return attributes;
    }

    @Override
    protected void sendTimeSeriesFilteredData() {
        output2dArrayUDP(dataAccumulator.getTimeSeriesFilteredBuffer());
    }

    @Override
    protected void sendTimeSeriesRawData() {
        output2dArrayUDP(dataAccumulator.getTimeSeriesRawBuffer());
    }

    @Override
    protected void sendFocusData() {
        final int metricValue = dataAccumulator.getFocusValueExceedsThreshold();
        StringBuilder output = new StringBuilder();
        output.append("{\"type\":\"");
        output.append(dataTypeKey);
        output.append("\",\"data\":");
        output.append(str(metricValue));
        output.append("}\r\n");
        outputUsingProtocol(output.toString());
    }

    @Override
    protected void sendFFTData() {
        final ddf.minim.analysis.FFT[] fftBuff = dataAccumulator.getFFTBuffer();
        StringBuilder output = new StringBuilder();
        output.append("{\"type\":\"");
        output.append(dataTypeKey);
        output.append("\",\"data\":[[");
        for (int i = 0; i < numExgChannels; i++) {
            for (int j = 0; j < NUM_FFT_BINS_TO_SEND; j++) {
                output.append(str(fftBuff[i].getBand(j)));
                if (j != NUM_FFT_BINS_TO_SEND - 1) {
                    output.append(",");
                }
            }
            if (i != numExgChannels - 1) {
                output.append("],[");
            } else {
                output.append("]]}\r\n");
            }
        }
        outputUsingProtocol(output.toString());
    }

    @Override
    protected void sendBandPowersAllChannels() {
        output2dArrayUDP(dataAccumulator.getAllBandPowerData());
    }

    @Override
    protected void sendNormalizedBandPowerData() {
        final float[] normalizedBandPowerData = dataAccumulator.getNormalizedBandPowerData();
        output1dArrayUDP(normalizedBandPowerData);
    }
    
    @Override
    protected void sendEMGData() {
        final float[] emgValues = dataAccumulator.getEmgNormalizedValues();
        output1dArrayUDP(emgValues);
    }

    @Override
    protected void sendAccelerometerData() {
        output2dArrayUDP(dataAccumulator.getAccelBuffer());
    }

    @Override
    protected void sendAnalogData() {
        output2dArrayUDP(dataAccumulator.getAnalogBuffer());
    }

    @Override
    protected void sendDigitalData() {
        output2dArrayUDP(dataAccumulator.getDigitalBuffer());
    }

    @Override
    protected void sendPulseData() {
        final int numDataPoints = 2;
        final int bpm = dataAccumulator.getPulseSensorBPM();
        final int ibi = dataAccumulator.getPulseSensorIBI();
        StringBuilder output = new StringBuilder();
        output.append("{\"type\":\"");
        output.append(dataTypeKey);
        output.append("\",\"data\":[");
        output.append(str(bpm));
        output.append(",");
        output.append(str(ibi));
        output.append("]}\r\n");
        outputUsingProtocol(output.toString());
    }

    @Override
    protected void sendEMGJoystickData() {
        final float[] emgJoystickXY = dataAccumulator.getEMGJoystickXY();
        output1dArrayUDP(emgJoystickXY);
    }

    @Override
    protected void sendMarkerData() {
        final float[] markerData = dataAccumulator.getMarkerBuffer();
        output1dArrayUDP(markerData);
    }

    private void outputUsingProtocol(String data) {
        try {
            udp.send(data, ip, port);
        } catch (Exception e) {
            println(e.getMessage());
        }
    }

    private void output2dArrayUDP(float[][] dataBuffer) {
        StringBuilder output = new StringBuilder();
        output.append("{\"type\":\"");
        output.append(dataTypeKey);
        output.append("\",\"data\":[");
        for (int i = 0; i < dataBuffer.length; i++) {
            output.append("[");
            for (int j = 0; j < dataBuffer[i].length; j++) {
                float data = dataBuffer[i][j];
                //Formatting in this way is resilient to internationalization
                String dataFormatted = threeDecimalPlaces.format(data);
                output.append(dataFormatted);
                if (j != dataBuffer[i].length - 1) {
                    output.append(",");
                }
            }
            String channelArrayEnding = i != dataBuffer.length - 1 ? "]," : "]";
            output.append(channelArrayEnding);
        }
        output.append("]}\r\n");
        outputUsingProtocol(output.toString());
    }

    private void output2dArrayUDP(int[][] dataBuffer) {
        StringBuilder output = new StringBuilder();
        output.append("{\"type\":\"");
        output.append(dataTypeKey);
        output.append("\",\"data\":[");
        for (int i = 0; i < dataBuffer.length; i++) {
            output.append("[");
            for (int j = 0; j < dataBuffer[i].length; j++) {
                int data = dataBuffer[i][j];
                String dataFormatted = String.format("%d", data);
                output.append(dataFormatted);
                if (j != dataBuffer[i].length - 1) {
                    output.append(",");
                }
            }
            String channelArrayEnding = i != dataBuffer.length - 1 ? "]," : "]";
            output.append(channelArrayEnding);
        }
        output.append("]}\r\n");
        outputUsingProtocol(output.toString());
    }

    private void output1dArrayUDP(float[] dataBuffer) {
        StringBuilder output = new StringBuilder();
        output.append("{\"type\":\"");
        output.append(dataTypeKey);
        output.append("\",\"data\":[");
        for (int i = 0; i < dataBuffer.length; i++) {
            float data = dataBuffer[i];
            //Formatting in this way is resilient to internationalization
            String dataFormatted = threeDecimalPlaces.format(data);
            output.append(dataFormatted);
            if (i != dataBuffer.length - 1) {
                output.append(",");
            }
        }
        output.append("]}\r\n");
        outputUsingProtocol(output.toString());
    }
}