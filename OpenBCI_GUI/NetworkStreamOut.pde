class NetworkStreamOut extends Thread {
    private String protocol;
    private int streamNumber;
    private String dataType;
    private String ip;
    private int port;
    private String baseOscAddress;
    private String streamType;
    private String streamName;
    private int numLslDataPoints;
    private int numExgChannels;
    private DecimalFormat threeDecimalPlaces;
    private DecimalFormat fourLeadingPlaces;

    public Boolean isStreaming;
    private int start;
    private double[][] previousFrameData;

    private int samplesSent = 0;
    private int sampleRateClock = 0;
    private int sampleRateClockInterval = 10000;

    // OSC Objects
    private OscP5 osc;
    private NetAddress oscNetAddress;
    private OscMessage msg;
    // UDP Objects
    private UDP udp;
    // LSL objects
    private LSL.StreamInfo info_data;
    private LSL.StreamOutlet outlet_data;

    // Serial objects %%%%%
    private processing.serial.Serial serial_networking;
    private String portName;
    private int baudRate;
    private String serialMessage = "";

    private PApplet pApplet;

    // OSC Stream
    NetworkStreamOut(String dataType, String ip, int port, String baseAddress, int _streamNumber) {
        this.protocol = "OSC";
        this.streamNumber = _streamNumber;
        this.dataType = dataType;
        this.ip = ip;
        this.port = port;
        this.baseOscAddress = baseAddress;
        this.isStreaming = false;
        updateNumChan();
        try {
            closeNetwork();
        } catch (Exception e) {
            outputError("Error closing network while creating OSC Stream: " + e);
        }
    }

    // UDP Stream
    NetworkStreamOut(String dataType, String ip, int port, int _streamNumber) {
        this.protocol = "UDP";
        this.streamNumber = _streamNumber;
        this.dataType = dataType;
        this.ip = ip;
        this.port = port;
        this.isStreaming = false;
        updateNumChan();

        // Force decimal formatting for all Locales
        Locale currentLocale = Locale.getDefault();
        DecimalFormatSymbols otherSymbols = new DecimalFormatSymbols(currentLocale);
        otherSymbols.setDecimalSeparator('.');
        otherSymbols.setGroupingSeparator(',');
        threeDecimalPlaces = new DecimalFormat("0.000", otherSymbols);
        fourLeadingPlaces = new DecimalFormat("####", otherSymbols);

        try {
            closeNetwork();
        } catch (Exception e) {
            outputError("Error closing network while creating UDP Stream: " + e);
        }
    }

    // LSL Stream
    NetworkStreamOut(String dataType, String streamName, String streamType, int numLslDataPoints, int _streamNumber) {
        this.protocol = "LSL";
        this.streamNumber = _streamNumber;
        this.dataType = dataType;
        this.streamName = streamName;
        this.streamType = streamType;
        this.numLslDataPoints = numLslDataPoints;
        this.isStreaming = false;
        updateNumChan();
        try {
            closeNetwork();
        } catch (Exception e) {
            outputError("Error closing network while creating LSL Stream: " + e);
        }
    }

    // Serial Stream
    NetworkStreamOut(String dataType, String portName, int baudRate, PApplet _this) {
        this.protocol = "Serial";
        this.streamNumber = 0;
        this.dataType = dataType;
        this.portName = portName;
        this.baudRate = baudRate;
        this.isStreaming = false;
        this.pApplet = _this;
        updateNumChan();

        // Force decimal formatting for all Locales
        Locale currentLocale = Locale.getDefault();
        DecimalFormatSymbols otherSymbols = new DecimalFormatSymbols(currentLocale);
        otherSymbols.setDecimalSeparator('.');
        otherSymbols.setGroupingSeparator(',');
        threeDecimalPlaces = new DecimalFormat("0.000", otherSymbols);
        fourLeadingPlaces = new DecimalFormat("####", otherSymbols);

        try {
            closeNetwork();
        } catch (Exception e) {
            outputError("Error closing network while creating Serial Stream: " + e);
        }
    }

    public void start() {
        this.isStreaming = true;
        if (!this.protocol.equals("LSL")) {
            super.start();
        } else {
            openNetwork();
        }
    }

    public void run() {
        if (!this.protocol.equals("LSL")) {
            openNetwork();
            while (this.isStreaming) {
                if (!currentBoard.isStreaming()) {
                    try {
                        Thread.sleep(1);
                    } catch (InterruptedException e) {
                        println(e.getMessage());
                    }
                } else {
                    if (checkForData()) {
                        sendData();
                    } else {
                        try {
                            Thread.sleep(1);
                        } catch (InterruptedException e) {
                            println(e.getMessage());
                        }
                    }
                }
            }
        } else if (this.protocol.equals("LSL")) {
            if (!currentBoard.isStreaming()) {
                try {
                    Thread.sleep(1);
                } catch (InterruptedException e) {
                    println(e.getMessage());
                }
            } else {
                // This method has been updated to reduce duplicate packets - RW 3/15/23
                if (checkForData()) {
                    sendData();
                }
            }
        }
    }

    private void updateNumChan() {
        numExgChannels = currentBoard.getNumEXGChannels();
        // Bug #638: ArrayOutOfBoundsException was thrown if
        // nPointsPerUpdate was larger than 10, as start was
        // set to dataProcessingFilteredBuffer[0].length - 10.
        start = dataProcessingFilteredBuffer[0].length - nPointsPerUpdate;
    }

    // This method has been updated to reduce duplicate packets - RW 3/15/23
    private synchronized Boolean checkForData() {
        if (this.dataType.equals("TimeSeriesRaw")) {
            return w_networking.newTimeSeriesDataToSend.compareAndSet(true, false);
        }

        if (this.dataType.equals("TimeSeriesFilt")) {
            return w_networking.newTimeSeriesDataToSendFiltered.compareAndSet(true, false);
        }

        if (this.dataType.equals("Marker")) {
            return w_networking.newMarkerDataToSend.compareAndSet(true, false);
        }

        if (this.dataType.equals("Accel/Aux")) {
            if (currentBoard instanceof AccelerometerCapableBoard) {
                AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                if (accelBoard.isAccelerometerActive()) {
                    return w_networking.newAccelDataToSend.compareAndSet(true, false);
                }
            }
            if (currentBoard instanceof AnalogCapableBoard) {
                AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                if (analogBoard.isAnalogActive()) {
                    return w_networking.newAnalogDataToSend.compareAndSet(true, false);
                }
            }
            if (currentBoard instanceof DigitalCapableBoard) {
                DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                if (digitalBoard.isDigitalActive()) {
                    return w_networking.newDigitalDataToSend.compareAndSet(true, false);
                }
            }
        }

        if (w_networking.networkingFrameLocks[this.streamNumber].compareAndSet(true, false)) {
            return true;
        } else {
            return false;
        }
    }

    private void sendData() {
        if (this.dataType.equals("TimeSeriesFilt") || this.dataType.equals("TimeSeriesRaw")) {
            sendTimeSeriesData();
        } else if (this.dataType.equals("Focus")) {
            sendFocusData();
        } else if (this.dataType.equals("FFT")) {
            sendFFTData();
        } else if (this.dataType.equals("EMG")) {
            sendEMGData();
        } else if (this.dataType.equals("AvgBandPower")) {
            sendNormalizedPowerBandData();
        } else if (this.dataType.equals("BandPower")) {
            sendPowerBandData();
        } else if (this.dataType.equals("Accel/Aux")) {
            if (currentBoard instanceof AccelerometerCapableBoard) {
                AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                if (accelBoard.isAccelerometerActive()) {
                    sendAccelerometerData();
                }
            }
            if (currentBoard instanceof AnalogCapableBoard) {
                AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                if (analogBoard.isAnalogActive()) {
                    sendAnalogReadData();
                }
            }
            if (currentBoard instanceof DigitalCapableBoard) {
                DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                if (digitalBoard.isDigitalActive()) {
                    sendDigitalReadData();
                }
            }
        } else if (this.dataType.equals("Pulse")) {
            sendPulseData();
        } else if (this.dataType.equals("EMGJoystick")) {
            sendEMGJoystickData();
        } else if (this.dataType.equals("Marker")) {
            sendMarkerData();
        }
    }

    private void sendTimeSeriesData() {

        float[][] newDataFromBuffer = new float[currentBoard.getNumEXGChannels()][nPointsPerUpdate];
        String udpDataTypeName = "timeSeriesRaw";
        String oscDataTypeName = "time-series-raw";

        if (this.dataType.equals("TimeSeriesRaw")) {
            // Unfiltered
            for (int i = 0; i < newDataFromBuffer.length; i++) {
                newDataFromBuffer[i] = w_networking.dataBufferToSend[i];
            }
        } else {
            // Filtered
            udpDataTypeName = "timeSeriesFilt";
            oscDataTypeName = "time-series-filtered";
            for (int i = 0; i < newDataFromBuffer.length; i++) {
                newDataFromBuffer[i] = w_networking.dataBufferToSend_Filtered[i];
            }
        }

        /*
        // This code is used to check the sample rate of the data stream
        if (sampleRateClock == 0) sampleRateClock = millis(); 
        samplesSent = samplesSent + nPointsPerUpdate;
        if (millis() > sampleRateClock + sampleRateClockInterval) { 
            float timeDelta = float(millis() - sampleRateClock) / 1000;
            float sampleRateCheck = samplesSent / timeDelta;
            println("\nNumber of samples collected = " + samplesSent);
            println("Time Interval (Desired) = " + (sampleRateClockInterval / 1000));
            println("Time Interval (Actual) = " + timeDelta);
            println("Sample Rate (Desired) = " + currentBoard.getSampleRate());
            println("Sample Rate (Actual) = " + sampleRateCheck);
            sampleRateClock = 0;
            samplesSent = 0;
        }
        */

        if (this.protocol.equals("UDP")) {

            StringBuilder output = new StringBuilder();
            output.append("{\"type\":\"");
            output.append(udpDataTypeName);
            output.append("\",\"data\":[");

            for (int i = 0; i < newDataFromBuffer.length; i++) {
                output.append("[");
                for (int j = 0; j < newDataFromBuffer[i].length; j++) {
                    output.append(str(newDataFromBuffer[i][j]));
                    if (j != newDataFromBuffer[i].length - 1) {
                        output.append(",");
                    }
                }
                String channelArrayEnding = i != newDataFromBuffer.length - 1 ? "]," : "]";
                output.append(channelArrayEnding);
            }

            // End of entire packet
            output.append("]}\r\n");

            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("OSC")) {

            for (int i = 0; i < newDataFromBuffer.length; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/" + oscDataTypeName + "/ch" + i);
                for (int j = 0; j < newDataFromBuffer[i].length; j++) {
                    msg.add(newDataFromBuffer[i][j]);
                }
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }

        } else if (this.protocol.equals("LSL")) {
            int numChannels = newDataFromBuffer.length;
            int numSamples = newDataFromBuffer[0].length;
            float[] dataToSend = new float[numChannels * numSamples];
            for (int sample = 0; sample < numSamples; sample++) {
                for (int channel = 0; channel < numChannels; channel++) {
                    dataToSend[channel + sample * numChannels] = newDataFromBuffer[channel][sample];
                }
            }
            // From LSLLink Library: The time stamps of other samples are automatically
            // derived based on the sampling rate of the stream.
            outlet_data.push_chunk(dataToSend);

        } else if (this.protocol.equals("Serial")) {

            // Time Series over serial port should be disabled as there is no reasonable usage for this
            StringBuilder serialMessage = new StringBuilder();
            for (int i = 0; i < newDataFromBuffer.length; i++) {
                serialMessage.append("[");
                for (int j = 0; j < newDataFromBuffer[i].length; j++) {
                    float chan_uV = newDataFromBuffer[i][j];
                    
                    serialMessage.append(threeDecimalPlaces.format(chan_uV));
                    if (i < numExgChannels - 1) {
                        // add a comma to serialMessage to separate chan values, as long as it isn't last value...
                        serialMessage.append(","); 
                    }
                }
                serialMessage.append("]"); // close the message w/ "]"
                try {
                    // Write message to serial
                    this.serial_networking.write(serialMessage.toString());
                    // println(serialMesage.toString());
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }

        }
    }

    // Send out 1 or 0 as an integer over all networking data types for "Focus" data
    private void sendFocusData() {
        final int IS_METRIC = w_focus.getMetricExceedsThreshold();
        if (this.protocol.equals("OSC")) {
            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/focus");
            msg.add(IS_METRIC);
            try {
                this.osc.send(msg, this.oscNetAddress);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("UDP")) {
            StringBuilder sb = new StringBuilder("{\"type\":\"focus\",\"data\":");
            sb.append(str(IS_METRIC));
            sb.append("}\r\n");
            try {
                this.udp.send(sb.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            float[] output = new float[] { (float) IS_METRIC };
            outlet_data.push_sample(output);
            // Serial
        } else if (this.protocol.equals("Serial")) {
            StringBuilder sb = new StringBuilder();
            sb.append(IS_METRIC);
            sb.append("\n");
            try {
                // println("SerialMessage: " + serialMessage);
                this.serial_networking.write(sb.toString());
            } catch (Exception e) {
                println("Networking Serial: Focus Error");
                println(e.getMessage());
            }
        }
    }

    private void sendFFTData() {
        // UNFILTERED & FILTERED ... influenced globally by the FFT filters dropdown
        // EEG/FFT readings above 125Hz don't typically travel through the skull
        // So for now, only send out 0-125Hz with 1 bin per Hz
        // Bin 10 == 10Hz frequency range
        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < numExgChannels; i++) {
                for (int j = 0; j < 125; j++) {
                    msg.clearArguments();
                    msg.setAddrPattern(baseOscAddress + "/fft/ch" + i + "/bin" + j);
                    msg.add(fftBuff[i].getBand(j));
                }
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            String outputter = "{\"type\":\"fft\",\"data\":[[";
            for (int i = 0; i < numExgChannels; i++) {
                for (int j = 0; j < 125; j++) {
                    outputter += str(fftBuff[i].getBand(j));
                    if (j != 125 - 1) {
                        outputter += ",";
                    }
                }
                if (i != numExgChannels - 1) {
                    outputter += "],[";
                } else {
                    outputter += "]]}\r\n";
                }
            }
            try {
                this.udp.send(outputter, this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            float[] dataToSend = new float[numExgChannels * 125];
            for (int i = 0; i < numExgChannels; i++) {
                for (int j = 0; j < 125; j++) {
                    dataToSend[j + 125 * i] = fftBuff[i].getBand(j);
                }
            }
            // From LSLLink Library: The time stamps of other samples are automatically
            // derived based on the sampling rate of the stream.
            outlet_data.push_chunk(dataToSend);
        } else if (this.protocol.equals("Serial")) {
            ///////////////////////////////// THIS OUTPUT IS DISABLED
            // Send FFT Data over Serial ...
            /*
                * for (int i=0;i<numExgChannels;i++) { serialMessage = "[" + (i+1) + ","; //clear
                * message for (int j=0;j<125;j++) { float fft_band = fftBuff[i].getBand(j);
                * String fft_band_3dec = threeDecimalPlaces.format(fft_band); serialMessage +=
                * fft_band_3dec; if (j < 125-1) { serialMessage += ","; //add a comma to
                * serialMessage to separate chan values, as long as it isn't last value... } }
                * serialMessage += "]"; try { // println(serialMessage);
                * this.serial_networking.write(serialMessage); } catch (Exception e) {
                * println(e.getMessage()); } }
                */
        }
    }

    private void sendPowerBandData() {
        // UNFILTERED & FILTERED ... influenced globally by the FFT filters dropdown
        // just like the FFT data
        final int NUM_BAND_POWERS = 5; // DELTA, THETA, ALPHA, BETA, GAMMA

        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < numExgChannels; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/band-power/" + i);
                for (int j = 0; j < NUM_BAND_POWERS; j++) {
                    msg.add(dataProcessing.avgPowerInBins[i][j]); // [CHAN][BAND]
                }
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            // DELTA, THETA, ALPHA, BETA, GAMMA
            String outputter = "{\"type\":\"bandPower\",\"data\":[[";
            for (int i = 0; i < numExgChannels; i++) {
                for (int j = 0; j < NUM_BAND_POWERS; j++) {
                    outputter += str(dataProcessing.avgPowerInBins[i][j]); // [CHAN][BAND]
                    if (j != NUM_BAND_POWERS - 1) {
                        outputter += ",";
                    }
                }
                if (i != numExgChannels - 1) {
                    outputter += "],[";
                } else {
                    outputter += "]]}\r\n";
                }
            }
            try {
                this.udp.send(outputter, this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("LSL")) {

            // DELTA, THETA, ALPHA, BETA, GAMMA
            int numChannels = numExgChannels;
            float[] dataToSend = new float[numChannels * NUM_BAND_POWERS];
            for (int band = 0; band < NUM_BAND_POWERS; band++) {
                for (int channel = 0; channel < numChannels; channel++) {
                    dataToSend[channel + band * numChannels] = dataProcessing.avgPowerInBins[channel][band];
                }
            }
            double unixTime = System.currentTimeMillis() / 1000d;
            //println(unixTime);
            outlet_data.push_chunk(dataToSend, unixTime, true);

        } else if (this.protocol.equals("Serial")) {
            for (int i = 0; i < numExgChannels; i++) {
                serialMessage = "[" + (i + 1) + ","; // clear message
                for (int j = 0; j < NUM_BAND_POWERS; j++) {
                    float power_band = dataProcessing.avgPowerInBins[i][j];
                    String power_band_3dec = threeDecimalPlaces.format(power_band);
                    serialMessage += power_band_3dec;
                    if (j < NUM_BAND_POWERS - 1) {
                        serialMessage += ","; // add a comma to serialMessage to separate chan values, as long as it
                                                // isn't last value...
                    }
                }
                serialMessage += "]";
                try {
                    // println(serialMessage);
                    this.serial_networking.write(serialMessage);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        }
    }

    private void sendNormalizedPowerBandData() {
        // UNFILTERED & FILTERED ... influenced globally by the FFT filters dropdown ...
        // just like the FFT data
        // Band Power order: DELTA, THETA, ALPHA, BETA, GAMMA
        final int NUM_BAND_POWERS = 5; 

        if (this.protocol.equals("OSC")) {

            msg.clearArguments();
            for (int i = 0; i < NUM_BAND_POWERS; i++) {
                msg.setAddrPattern(baseOscAddress + "/average-band-power/" + i);
                msg.add(w_bandPower.getNormalizedBPSelectedChannels()[i]); // [CHAN][BAND]
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
            
        } else if (this.protocol.equals("UDP")) {

            StringBuilder outputter = new StringBuilder("{\"type\":\"averageBandPower\",\"data\":[");
            for (int i = 0; i < NUM_BAND_POWERS; i++) {
                outputter.append(str(w_bandPower.getNormalizedBPSelectedChannels()[i]));
                if (i != NUM_BAND_POWERS - 1) {
                    outputter.append(",");
                } else {
                    outputter.append("]}\r\n");
                }
            }
            // println(outputter.toString());
            try {
                this.udp.send(outputter.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("LSL")) {

            float[] avgPowerLSL = w_bandPower.getNormalizedBPSelectedChannels();
            outlet_data.push_sample(avgPowerLSL);

        } else if (this.protocol.equals("Serial")) {

            serialMessage = "[";
            for (int i = 0; i < NUM_BAND_POWERS; i++) {
                float power_band = w_bandPower.getNormalizedBPSelectedChannels()[i];
                String power_band_3dec = threeDecimalPlaces.format(power_band);
                serialMessage += power_band_3dec;
                if (i < NUM_BAND_POWERS - 1) {
                    // add a comma to serialMessage to separate chan values, as long as it isn't last value...
                    serialMessage += ","; 
                }
            }
            serialMessage += "]";
            try {
                // println(serialMessage);
                this.serial_networking.write(serialMessage);
            } catch (Exception e) {
                println(e.getMessage());
            }

        }
    }

    private void sendEMGData() {
        EmgSettingsValues emgSettingsValues = dataProcessing.emgSettings.values;
        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < numExgChannels; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/emg/" + i);
                msg.add(emgSettingsValues.getOutputNormalized(i));
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            String outputter = "{\"type\":\"emg\",\"data\":[";
            for (int i = 0; i < numExgChannels; i++) {
                outputter += str(emgSettingsValues.getOutputNormalized(i));
                if (i != numExgChannels - 1) {
                    outputter += ",";
                } else {
                    outputter += "]}\r\n";
                }
            }
            try {
                this.udp.send(outputter, this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            float[] dataToSend = new float[numExgChannels];
            for (int i = 0; i < numExgChannels; i++) {
                dataToSend[i] = emgSettingsValues.getOutputNormalized(i);
            }
            outlet_data.push_sample(dataToSend);
        } else if (this.protocol.equals("Serial")) {
            serialMessage = "";
            for (int i = 0; i < numExgChannels; i++) {
                float emg_normalized = emgSettingsValues.getOutputNormalized(i);
                String emg_normalized_3dec = threeDecimalPlaces.format(emg_normalized);
                serialMessage += emg_normalized_3dec;
                if (i != numExgChannels - 1) {
                    serialMessage += ",";
                } else {
                    serialMessage += "\n";
                }
            }
            try {
                println(serialMessage);
                this.serial_networking.write(serialMessage);
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendAccelerometerData() {

        if (this.protocol.equals("OSC")) {

            for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                for (int j = 0; j < w_networking.accelDataBufferToSend[i].length; j++) {
                    msg.clearArguments();
                    if (i == 0) {
                        msg.setAddrPattern(baseOscAddress + "/accelerometer/x");
                    } else if (i == 1) {
                        msg.setAddrPattern(baseOscAddress + "/accelerometer/y");
                    } else if (i == 2) {
                        msg.setAddrPattern(baseOscAddress + "/accelerometer/z");
                    }
                    msg.add(w_networking.accelDataBufferToSend[i][j]);
                    try {
                        this.osc.send(msg, this.oscNetAddress);
                    } catch (Exception e) {
                        println(e.getMessage());
                    }
                }
            }

        } else if (this.protocol.equals("UDP")) {

            StringBuilder output = new StringBuilder();
            output.append("{\"type\":\"accelerometer\",\"data\":[");

            for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                output.append("[");
                for (int j = 0; j < w_networking.accelDataBufferToSend[i].length; j++) {
                    float accelData = w_networking.accelDataBufferToSend[i][j];
                    // Formatting in this way is resilient to internationalization
                    String accelData_3dec = threeDecimalPlaces.format(accelData);
                    output.append(accelData_3dec);
                    if (j != w_networking.accelDataBufferToSend[i].length - 1) {
                        output.append(",");
                    }
                }
                String channelArrayEnding = i != NUM_ACCEL_DIMS - 1 ? "]," : "]";
                output.append(channelArrayEnding);
            }
            
            output.append("]}\r\n");

            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("LSL")) {

            int numChannels = NUM_ACCEL_DIMS;
            int numSamples = w_networking.accelDataBufferToSend[0].length;
            float[] dataToSend = new float[numChannels * numSamples];
            for (int sample = 0; sample < numSamples; sample++) {
                for (int channel = 0; channel < numChannels; channel++) {
                    dataToSend[channel + sample * numChannels] = w_networking.accelDataBufferToSend[channel][sample];
                }
            }
            outlet_data.push_chunk(dataToSend);

        } else if (this.protocol.equals("Serial")) {

            StringBuilder serialMessage = new StringBuilder();
            for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
                serialMessage.append("[");
                for (int j = 0; j < w_networking.accelDataBufferToSend[i].length; j++) {
                    float accelData = w_networking.accelDataBufferToSend[i][j];
                    // Formatting in this way is resilient to internationalization
                    String accelData_3dec = threeDecimalPlaces.format(accelData);
                    if (accelData >= 0) {
                        serialMessage.append("+");
                    }
                    serialMessage.append(accelData_3dec);
                    if (j != w_networking.accelDataBufferToSend[i].length - 1) {
                        serialMessage.append(",");
                    }
                }
                serialMessage.append("]");
            }
            try {
                // println(serialMessage);
                this.serial_networking.write(serialMessage.toString());
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendAnalogReadData() {

        final int NUM_ANALOG_READS = ((AnalogCapableBoard)currentBoard).getAnalogChannels().length;

        if (this.protocol.equals("OSC")) {

            for (int i = 0; i < NUM_ANALOG_READS; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/analog/" + i);
                for (int j = 0; j < w_networking.analogDataBufferToSend[i].length; j++) {
                    msg.add(w_networking.analogDataBufferToSend[i][j]);
                }
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }

        } else if (this.protocol.equals("UDP")) {

            StringBuilder output = new StringBuilder();
            output.append("{\"type\":\"analog\",\"data\":[");

            for (int i = 0; i < NUM_ANALOG_READS; i++) {
                output.append("[");
                for (int j = 0; j < w_networking.analogDataBufferToSend[i].length; j++) {
                    float analogData = w_networking.analogDataBufferToSend[i][j];
                    // Formatting in this way is resilient to internationalization
                    String analogData_3dec = threeDecimalPlaces.format(analogData);
                    output.append(analogData_3dec);
                    if (j != w_networking.analogDataBufferToSend[i].length - 1) {
                        output.append(",");
                    }
                }
                String channelArrayEnding = i != NUM_ANALOG_READS - 1 ? "]," : "]";
                output.append(channelArrayEnding);
            }

            output.append("]}\r\n");

            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("LSL")) {

            int numChannels = NUM_ANALOG_READS;
            int numSamples = w_networking.analogDataBufferToSend[0].length;
            float[] dataToSend = new float[numChannels * numSamples];
            for (int sample = 0; sample < numSamples; sample++) {
                for (int channel = 0; channel < numChannels; channel++) {
                    dataToSend[channel + sample * numChannels] = w_networking.analogDataBufferToSend[channel][sample];
                }
            }
            outlet_data.push_chunk(dataToSend);

        } else if (this.protocol.equals("Serial")) {

            StringBuilder serialMessage = new StringBuilder();

            for (int i = 0; i < NUM_ANALOG_READS; i++) {
                serialMessage.append("[");
                for (int j = 0; j < w_networking.analogDataBufferToSend[i].length; j++) {
                    float analogData = w_networking.analogDataBufferToSend[i][j];
                    // Formatting in this way is resilient to internationalization
                    String analogData_3dec = threeDecimalPlaces.format(analogData);
                    serialMessage.append(analogData_3dec);
                    if (j != w_networking.analogDataBufferToSend[i].length - 1) {
                        serialMessage.append(",");
                    }
                }
                String channelArrayEnding = i != NUM_ANALOG_READS - 1 ? "]," : "]";
                serialMessage.append(channelArrayEnding);
            }
            serialMessage.append("\n");
            try {
                // println(serialMessage);
                this.serial_networking.write(serialMessage.toString());
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendDigitalReadData() {

        final int NUM_DIGITAL_READS = w_digitalRead.getNumDigitalReads();

        if (this.protocol.equals("OSC")) {

            for (int i = 0; i < NUM_DIGITAL_READS; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/digital/" + i);
                //msg.add(w_digitalRead.digitalReadDots[i].getDigitalReadVal());
                for (int j = 0; j < w_networking.digitalDataBufferToSend[i].length; j++) {
                    msg.add(w_networking.digitalDataBufferToSend[i][j]);
                }
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }

        } else if (this.protocol.equals("UDP")) {
            
            StringBuilder output = new StringBuilder();
            output.append("{\"type\":\"digital\",\"data\":[");

            for (int i = 0; i < NUM_DIGITAL_READS; i++) {
                output.append("[");
                for (int j = 0; j < w_networking.digitalDataBufferToSend[i].length; j++) {
                    int digitalData = w_networking.digitalDataBufferToSend[i][j];
                    String digitalDataFormatted = String.format("%d", digitalData);
                    output.append(digitalDataFormatted);
                    if (j != w_networking.digitalDataBufferToSend[i].length - 1) {
                        output.append(",");
                    }
                }
                String channelArrayEnding = i != NUM_DIGITAL_READS - 1 ? "]," : "]";
                output.append(channelArrayEnding);
            }

            output.append("]}\r\n");

            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("LSL")) {

            int numChannels = NUM_DIGITAL_READS;
            int numSamples = w_networking.digitalDataBufferToSend[0].length;
            float[] dataToSend = new float[numChannels * numSamples];
            for (int sample = 0; sample < numSamples; sample++) {
                for (int channel = 0; channel < numChannels; channel++) {
                    dataToSend[channel + sample * numChannels] = w_networking.digitalDataBufferToSend[channel][sample];
                }
            }
            outlet_data.push_chunk(dataToSend);

        } else if (this.protocol.equals("Serial")) {

            StringBuilder serialMessage = new StringBuilder();

            for (int i = 0; i < NUM_DIGITAL_READS; i++) {
                serialMessage.append("[");
                for (int j = 0; j < w_networking.digitalDataBufferToSend[i].length; j++) {
                    int digitalData = w_networking.digitalDataBufferToSend[i][j];
                    String digitalDataFormatted = String.format("%d", digitalData);
                    serialMessage.append(digitalDataFormatted);
                    if (j != w_networking.digitalDataBufferToSend[i].length - 1) {
                        serialMessage.append(",");
                    }
                }
                String channelArrayEnding = i != NUM_DIGITAL_READS - 1 ? "]," : "]";
                serialMessage.append(channelArrayEnding.toString());
            }

            serialMessage.append("\n");

            try {
                // println(serialMessage);
                this.serial_networking.write(serialMessage.toString());
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendPulseData() {
        // Get data from Board that
        int numDataPoints = 2;

        if (this.protocol.equals("OSC")) {

            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/pulse/bpm");
            msg.add(w_pulsesensor.getBPM());
            try {
                this.osc.send(msg, this.oscNetAddress);
            } catch (Exception e) {
                println(e.getMessage());
            }

            msg.clearArguments();
            msg.setAddrPattern(baseOscAddress + "/pulse/ibi");
            msg.add(w_pulsesensor.getIBI());
            try {
                this.osc.send(msg, this.oscNetAddress);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("UDP")) {

            StringBuilder output = new StringBuilder("{\"type\":\"pulse\",\"data\":[");
            output.append(str(w_pulsesensor.getBPM()));
            output.append(",");
            output.append(str(w_pulsesensor.getIBI()));
            output.append("]}\r\n");
            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("LSL")) {

            float[] dataToSend = new float[2];
            dataToSend[0] = w_pulsesensor.getBPM();
            dataToSend[1] = w_pulsesensor.getIBI();
            // From LSLLink Library: The time stamps of other samples are automatically
            // derived based on the sampling rate of the stream.
            outlet_data.push_sample(dataToSend);

        } else if (this.protocol.equals("Serial")) {

            serialMessage = ""; // clear message
            serialMessage += w_pulsesensor.getBPM() + ",";
            serialMessage += w_pulsesensor.getIBI();
            try {
                this.serial_networking.write(serialMessage);
            } catch (Exception e) {
                println(e.getMessage());
            }

        }
    }// End sendPulseData

    private void sendEMGJoystickData() {

        final float[] emgJoystickXY = w_emgJoystick.getJoystickXY();

        if (this.protocol.equals("OSC")) {
            for (int i = 0; i < emgJoystickXY.length; i++) {
                msg.clearArguments();
                if (i == 0) {
                    msg.setAddrPattern(baseOscAddress + "/emg-joystick/x");
                } else if (i == 1) {
                    msg.setAddrPattern(baseOscAddress + "/emg-joystick/y");
                }
                msg.add(emgJoystickXY[i]);
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        } else if (this.protocol.equals("UDP")) {
            StringBuilder output = new StringBuilder("{\"type\":\"emgJoystick\",\"data\":[");
            for (int i = 0; i < emgJoystickXY.length; i++) {
                // Formatting in this way is resilient to internationalization
                String dataFormatted = threeDecimalPlaces.format(emgJoystickXY[i]);
                output.append(dataFormatted);
                if (i != emgJoystickXY.length - 1) {
                    output.append(",");
                } else {
                    output.append("]}\r\n");
                }
            }
            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("LSL")) {
            float[] dataToSend = new float[emgJoystickXY.length];
            for (int i = 0; i < emgJoystickXY.length; i++) {
                dataToSend[i] = emgJoystickXY[i];
            }
            outlet_data.push_sample(dataToSend);
        } else if (this.protocol.equals("Serial")) {
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
            try {
                // println(serialMessage);
                this.serial_networking.write(output.toString());
            } catch (Exception e) {
                println(e.getMessage());
            }
        }
    }

    private void sendMarkerData() {

        float[] newDataFromBuffer = new float[nPointsPerUpdate];

        for (int i = 0; i < newDataFromBuffer.length; i++) {
            newDataFromBuffer[i] = w_networking.markerDataBufferToSend[i];
        }

        /*
        // Check sampling rate for every networking protocol for this data type
        if (sampleRateClock == 0) sampleRateClock = millis(); 
        samplesSent = samplesSent + nPointsPerUpdate;
        if (millis() > sampleRateClock + sampleRateClockInterval) { 
            float timeDelta = float(millis() - sampleRateClock) / 1000;
            float sampleRateCheck = samplesSent / timeDelta;
            println("\nNumber of samples collected = " + samplesSent);
            println("Time Interval (Desired) = " + (sampleRateClockInterval / 1000));
            println("Time Interval (Actual) = " + timeDelta);
            println("Sample Rate (Desired) = " + currentBoard.getSampleRate());
            println("Sample Rate (Actual) = " + sampleRateCheck);
            sampleRateClock = 0;
            samplesSent = 0;
        }
        */

        if (this.protocol.equals("UDP")) {

            StringBuilder output = new StringBuilder();
            output.append("{\"type\":\"");
            output.append("marker");
            output.append("\",\"data\":[");

            for (int i = 0; i < newDataFromBuffer.length; i++) {
                output.append(str(newDataFromBuffer[i]));
                if (i != newDataFromBuffer.length - 1) {
                    output.append(",");
                }
            }

            // End of entire packet
            output.append("]}\r\n");

            try {
                this.udp.send(output.toString(), this.ip, this.port);
            } catch (Exception e) {
                println(e.getMessage());
            }

        } else if (this.protocol.equals("OSC")) {

            for (int i = 0; i < newDataFromBuffer.length; i++) {
                msg.clearArguments();
                msg.setAddrPattern(baseOscAddress + "/marker");
                msg.add(newDataFromBuffer[i]);
                try {
                    this.osc.send(msg, this.oscNetAddress);
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }

        } else if (this.protocol.equals("LSL")) {
            // In this case, the newDataFromBuffer array is already formatted in an acceptable way.
            // From LSLLink Library: The time stamps of other samples are automatically
            // derived based on the sampling rate of the stream.
            outlet_data.push_chunk(newDataFromBuffer);

        } else if (this.protocol.equals("Serial")) {

            // Time Series over serial port should be disabled as there is no reasonable usage for this
            for (int i = 0; i < newDataFromBuffer.length; i++) {
                StringBuilder serialMessage = new StringBuilder();
                float markerValue = newDataFromBuffer[i];    
                serialMessage.append(threeDecimalPlaces.format(markerValue));
                serialMessage.append("\n");
                try {
                    // Write message to serial
                    this.serial_networking.write(serialMessage.toString());
                    //println(serialMessage.toString());
                } catch (Exception e) {
                    println(e.getMessage());
                }
            }
        }
    }

    //// Add new stream function here (ex. sendWidgetData) in the same format as
    //// above

    public void quit() {
        this.isStreaming = false;
        closeNetwork();
        interrupt();
    }

    private void closeNetwork() {
        if (this.protocol.equals("OSC")) {
            try {
                this.osc.stop();
            } catch (Exception e) {
                println(e.getMessage());
            }
        } else if (this.protocol.equals("UDP")) {
            this.udp.close();
        } else if (this.protocol.equals("LSL")) {
            outlet_data.close();
        } else if (this.protocol.equals("Serial")) {
            // Close Serial Port %%%%%
            try {
                serial_networking.clear();
                serial_networking.stop();
                println("Successfully closed SERIAL/COM port " + this.portName);
            } catch (Exception e) {
                println("Failed to close SERIAL/COM port " + this.portName);
            }
        }
    }

    private void openNetwork() {
        println("Networking: " + getAttributes());
        if (this.protocol.equals("OSC")) {
            // Possibly enter a nice custom exception here
            // try {
            this.osc = new OscP5(this, this.port + 1000);
            this.oscNetAddress = new NetAddress(this.ip, this.port);
            this.msg = new OscMessage(this.baseOscAddress);
            // } catch (Exception e) {
            // }
        } else if (this.protocol.equals("UDP")) {
            this.udp = new UDP(this);
            this.udp.setBuffer(20000);
            this.udp.listen(false);
            this.udp.log(false);
            output("UDP successfully connected");
        } else if (this.protocol.equals("LSL")) {
            String stream_id = "openbcigui";
            info_data = new LSL.StreamInfo(this.streamName, this.streamType, this.numLslDataPoints,
                    currentBoard.getSampleRate(), LSL.ChannelFormat.float32, stream_id);
            outlet_data = new LSL.StreamOutlet(info_data);
        } else if (this.protocol.equals("Serial")) {
            // Open Serial Port! %%%%%
            try {
                serial_networking = new processing.serial.Serial(this.pApplet, this.portName, this.baudRate);
                serial_networking.clear();
                verbosePrint("Successfully opened SERIAL/COM: " + this.portName);
                output("Successfully opened SERIAL/COM (" + this.baudRate + "): " + this.portName);
            } catch (Exception e) {
                verbosePrint("W_Networking.pde: could not open SERIAL PORT: " + this.portName);
                println("Error: " + e);
            }
        }
    }

    // Used only to print attributes to the screen
    private StringList getAttributes() {
        StringList attributes = new StringList();
        if (this.protocol.equals("OSC")) {
            attributes.append(this.dataType);
            attributes.append(this.ip);
            attributes.append(str(this.port));
            attributes.append(this.baseOscAddress);
        } else if (this.protocol.equals("UDP")) {
            attributes.append(this.dataType);
            attributes.append(this.ip);
            attributes.append(str(this.port));
        } else if (this.protocol.equals("LSL")) {
            attributes.append(this.dataType);
            attributes.append(this.streamName);
            attributes.append(this.streamType);
            attributes.append(str(this.numLslDataPoints));
        } else if (this.protocol.equals("Serial")) {
            attributes.append(this.dataType);
            attributes.append(this.portName);
            attributes.append(str(this.baudRate));
        }
        return attributes;
    }

}