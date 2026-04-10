public enum NetworkSerialShowPlusSigns { YES, NO };

class NetworkStreamOutSerial extends NetworkStreamOut {
    
    private processing.serial.Serial serialConnection;
    private String portName;
    private int baudRate;
    private PApplet pApplet;

    private boolean debugSerialOutput = false;

    NetworkStreamOutSerial(NetworkDataType dataType, String portName, int baudRate, PApplet _this) {
        super(dataType);
        protocol = NetworkProtocol.SERIAL;
        this.streamNumber = 0;
        this.dataType = dataType;
        this.portName = portName;
        this.baudRate = baudRate;
        this.pApplet = _this;

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
        try {
            serialConnection = new processing.serial.Serial(pApplet, portName, baudRate);
            serialConnection.clear();
            println("Networking: Successfully opened SERIAL/COM port " + portName + " at baud rate of " + baudRate);
        } catch (Exception e) {
            println("Networking: could not open SERIAL/COM port:  " + portName);
            println("Error: " + e);
        }
    }

    @Override
    protected void closeNetwork() {
        try {
            serialConnection.clear();
            serialConnection.stop();
            println("Networking: Successfully closed SERIAL/COM port: " + portName);
        } catch (Exception e) {
            println("Networking: Failed to close SERIAL/COM port: " + portName);
        }
    }

    @Override
    protected StringList getAttributes() {
        StringList attributes = new StringList();
        attributes.append(dataType.getString());
        attributes.append(portName);
        attributes.append(str(baudRate));
        return attributes;
    }

    @Override
    protected void sendTimeSeriesFilteredData() {
        output2dArraySerial(dataAccumulator.getTimeSeriesFilteredBuffer(), NetworkSerialShowPlusSigns.YES);
    }

    @Override
    protected void sendTimeSeriesRawData() {
        output2dArraySerial(dataAccumulator.getTimeSeriesRawBuffer(), NetworkSerialShowPlusSigns.YES);
    }

    @Override
    protected void sendFocusData() {
        final int metricValue = dataAccumulator.getFocusValueExceedsThreshold();
        StringBuilder output = new StringBuilder();
        output.append(metricValue);
        output.append("\n");
        outputUsingProtocol(output.toString());
    }

    @Override
    protected void sendFFTData() {
        //This output is disabled as there is no reasonable usage for FFT over serial
        return;
    }

    @Override
    protected void sendBandPowersAllChannels() {
        final float[][] bandPowerData = dataAccumulator.getAllBandPowerData();
        StringBuilder output = new StringBuilder();
        // Send out band powers for each channel sequentially
        for (int channel = 0; channel < numExgChannels; channel++) {
            output.append("[" + (channel + 1) + ",");
            for (int band = 0; band < NUM_BAND_POWERS; band++) {
                float value = bandPowerData[channel][band];
                String valueFormatted = threeDecimalPlaces.format(value);
                output.append(valueFormatted);
                if (band < NUM_BAND_POWERS - 1) {
                    output.append(",");
                }
            }
            output.append("]");
            outputUsingProtocol(output.toString());
        }
    }

    @Override
    protected void sendNormalizedBandPowerData() {
        final float[] normalizedBandPowerData = dataAccumulator.getNormalizedBandPowerData();
        StringBuilder output = new StringBuilder();
        for (int i = 0; i < NUM_BAND_POWERS; i++) {
            float power_band = normalizedBandPowerData[i];
            String power_band_3dec = threeDecimalPlaces.format(power_band);
            output.append(power_band_3dec);
            if (i < NUM_BAND_POWERS - 1) {
                output.append(","); 
            }
        }
        output.append("]");
        outputUsingProtocol(output.toString());
    }

    @Override
    protected void sendEMGData() {
        final float[] emgValues = dataAccumulator.getEmgNormalizedValues();
        StringBuilder output = new StringBuilder();
        for (int i = 0; i < numExgChannels; i++) {
            float emg_normalized = emgValues[i];
            String emg_normalized_3dec = threeDecimalPlaces.format(emg_normalized);
            output.append(emg_normalized_3dec);
            if (i != numExgChannels - 1) {
                output.append(",");
            } else {
                output.append("\n");
            }
        }
        outputUsingProtocol(output.toString());
    }

    @Override
    protected void sendAccelerometerData() {
        output2dArraySerial(dataAccumulator.getAccelBuffer(), NetworkSerialShowPlusSigns.YES);
    }

    @Override
    protected void sendAnalogData() {
        output2dArraySerial(dataAccumulator.getAnalogBuffer(), NetworkSerialShowPlusSigns.NO);
    }

    @Override
    protected void sendDigitalData() {
        output2dArraySerial(dataAccumulator.getDigitalBuffer(), NetworkSerialShowPlusSigns.NO);
    }

    @Override
    protected void sendPulseData() {
        StringBuilder output = new StringBuilder();
        output.append(dataAccumulator.getPulseSensorBPM());
        output.append(",");
        output.append(dataAccumulator.getPulseSensorIBI());
        outputUsingProtocol(output.toString());
    }

    @Override
    protected void sendEMGJoystickData() {
        final float[] emgJoystickXY = dataAccumulator.getEMGJoystickXY();
        // Data Format: +0.900,-0.042\n
        // 7 chars per axis, including \n char
        StringBuilder output = new StringBuilder();
        for (int i = 0; i < emgJoystickXY.length; i++) {
            float data = emgJoystickXY[i];
            String dataFormatted = threeDecimalPlaces.format(data);
            if (data >= 0)
                output.append("+");
                output.append(dataFormatted);
            if (i != emgJoystickXY.length - 1) {
                output.append(",");
            } else {
                output.append("\n");
            }
        }
        outputUsingProtocol(output.toString());
    }

    @Override
    protected void sendMarkerData() {
        final float[] markerData = dataAccumulator.getMarkerBuffer();
        for (int i = 0; i < markerData.length; i++) {
            StringBuilder output = new StringBuilder();
            float markerValue = markerData[i];    
            output.append(threeDecimalPlaces.format(markerValue));
            output.append("\n");
            outputUsingProtocol(output.toString());
        }
    }

    private void outputUsingProtocol(String data) {
        try {
            if (debugSerialOutput) {
                println("SerialMessage: " + data);
            }
            serialConnection.write(data);
        } catch (Exception e) {
            println(e.getMessage());
        }
    }

    private void output2dArraySerial(float[][] dataBuffer, NetworkSerialShowPlusSigns showPlusSign) {
        StringBuilder output = new StringBuilder();
        for (int i = 0; i < dataBuffer.length; i++) {
            output.append("[");
            for (int j = 0; j < dataBuffer[i].length; j++) {
                float data = dataBuffer[i][j];
                //Formatting in this way is resilient to internationalization
                String dataFormatted = threeDecimalPlaces.format(data);
                if (showPlusSign == NetworkSerialShowPlusSigns.YES && data >= 0) {
                    output.append("+");
                }
                output.append(dataFormatted);
                if (j != dataBuffer[i].length - 1) {
                    output.append(",");
                }
            }
            String channelArrayEnding = i != dataBuffer.length - 1 ? "]," : "]";
            output.append(channelArrayEnding);
        }
        output.append("\n");
        outputUsingProtocol(output.toString());
    }

    private void output2dArraySerial(int[][] dataBuffer, NetworkSerialShowPlusSigns showPlusSign) {
        StringBuilder output = new StringBuilder();
        for (int i = 0; i < dataBuffer.length; i++) {
            output.append("[");
            for (int j = 0; j < dataBuffer[i].length; j++) {
                int data = dataBuffer[i][j];
                String dataFormatted = String.format("%d", data);
                if (showPlusSign == NetworkSerialShowPlusSigns.YES && data >= 0) {
                    output.append("+");
                }
                output.append(dataFormatted);
                if (j != dataBuffer[i].length - 1) {
                    output.append(",");
                }
            }
            String channelArrayEnding = i != dataBuffer.length - 1 ? "]," : "]";
            output.append(channelArrayEnding);
        }
        output.append("\n");
        outputUsingProtocol(output.toString());
    }
}