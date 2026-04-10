class NetworkStreamOutOSC extends NetworkStreamOut {

    private OscP5 osc;
    private NetAddress oscNetAddress;
    private OscMessage msg;
    private String baseOscAddress;
    private String dataTypeKey;

    NetworkStreamOutOSC(NetworkDataType dataType, String ip, int port, String baseAddress, int _streamNumber) {
        super(dataType);
        protocol = NetworkProtocol.OSC;
        this.streamNumber = _streamNumber;
        this.ip = ip;
        this.port = port;
        this.baseOscAddress = baseAddress;
        dataTypeKey = dataType.getOSCKey();
    }

    @Override
    protected void openNetwork() {
        super.openNetwork();
        osc = new OscP5(this, port + 1000);
        oscNetAddress = new NetAddress(ip, port);
        msg = new OscMessage(baseOscAddress);
    }

    @Override
    protected void closeNetwork() {
        try {
            osc.stop();
        } catch (Exception e) {
            println(e.getMessage());
        }
    }

    @Override
    protected StringList getAttributes() {
        StringList attributes = new StringList();
        attributes.append(dataType.getString());
        attributes.append(this.ip);
        attributes.append(str(this.port));
        attributes.append(this.baseOscAddress);
        return attributes;
    }

    @Override
    protected void sendTimeSeriesFilteredData() {
        output2dArrayOSC(dataAccumulator.getTimeSeriesFilteredBuffer());
    }

    @Override
    protected void sendTimeSeriesRawData() {
        output2dArrayOSC(dataAccumulator.getTimeSeriesRawBuffer());
    }

    @Override
    protected void sendFocusData() {
        final int metricValue = dataAccumulator.getFocusValueExceedsThreshold();
        msg.clearArguments();
        msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey);
        msg.add(metricValue);
        outputUsingProtocol();
    }

    @Override
    protected void sendFFTData() {
        final ddf.minim.analysis.FFT[] fftBuff = dataAccumulator.getFFTBuffer();
        for (int i = 0; i < numExgChannels; i++) {
            for (int j = 0; j < 125; j++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/ch" + i + "/bin" + j);
                msg.add(fftBuff[i].getBand(j));
            }
            outputUsingProtocol();
        }
    }

    @Override
    protected void sendBandPowersAllChannels() {
        output2dArrayOSC(dataAccumulator.getAllBandPowerData());
    }

    @Override
    protected void sendNormalizedBandPowerData() {
        final float[] normalizedBandPowerData = dataAccumulator.getNormalizedBandPowerData();
        msg.clearArguments();
        for (int i = 0; i < NUM_BAND_POWERS; i++) {
            msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/" + i);
            msg.add(normalizedBandPowerData[i]);
            outputUsingProtocol();
        }
    }

    @Override
    protected void sendEMGData() {
        final float[] emgValues = dataAccumulator.getEmgNormalizedValues();
        for (int i = 0; i < numExgChannels; i++) {
            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/" + i);
            msg.add(emgValues[i]);
            outputUsingProtocol();
        }
    }

    @Override
    protected void sendAccelerometerData() {
        final float[][] accelBuffer = dataAccumulator.getAccelBuffer();
        for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
            for (int j = 0; j < accelBuffer[i].length; j++) {
                msg.clearArguments();
                if (i == 0) {
                    msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/x");
                } else if (i == 1) {
                    msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/y");
                } else if (i == 2) {
                    msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/z");
                }
                msg.add(accelBuffer[i][j]);
                outputUsingProtocol();
            }
        }
    }

    @Override
    protected void sendAnalogData() {
        output2dArrayOSC(dataAccumulator.getAnalogBuffer());
    }

    @Override
    protected void sendDigitalData() {
        output2dArrayOSC(dataAccumulator.getDigitalBuffer());
    }

    @Override
    protected void sendPulseData() {
        final int bpm = dataAccumulator.getPulseSensorBPM();
        final int ibi = dataAccumulator.getPulseSensorIBI();
        
        msg.clearArguments();
        msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/bpm");
        msg.add(bpm);
        outputUsingProtocol();

        msg.clearArguments();
        msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/ibi");
        msg.add(ibi);
        outputUsingProtocol();
    }

    @Override
    protected void sendEMGJoystickData() {
        final float[] emgJoystickXY = dataAccumulator.getEMGJoystickXY();
        for (int i = 0; i < emgJoystickXY.length; i++) {
            msg.clearArguments();
            if (i == 0) {
                msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/x");
            } else if (i == 1) {
                msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/y");
            }
            msg.add(emgJoystickXY[i]);
            outputUsingProtocol();
        }
    }

    @Override
    protected void sendMarkerData() {
        final float[] markerData = dataAccumulator.getMarkerBuffer();
        for (int i = 0; i < markerData.length; i++) {
            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey);
            msg.add(markerData[i]);
            outputUsingProtocol();
        }
    }

    private void outputUsingProtocol() {
        try {
            osc.send(msg, oscNetAddress);
        } catch (Exception e) {
            println(e.getMessage());
        }
    }

    private void output2dArrayOSC(float[][] dataBuffer) {
        for (int i = 0; i < dataBuffer.length; i++) {
            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/ch" + i);
            for (int j = 0; j < dataBuffer[i].length; j++) {
                msg.add(dataBuffer[i][j]);
            }
            outputUsingProtocol();
        }
    }

    private void output2dArrayOSC(int[][] dataBuffer) {
        for (int i = 0; i < dataBuffer.length; i++) {
            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/" + dataTypeKey + "/ch" + i);
            for (int j = 0; j < dataBuffer[i].length; j++) {
                msg.add(dataBuffer[i][j]);
            }
            outputUsingProtocol();
        }
    }
}