import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

public abstract class NetworkStreamOut extends Thread {
    protected NetworkProtocol protocol;
    protected int streamNumber;
    protected NetworkDataType dataType;
    protected String ip;
    protected int port;
    protected int numExgChannels;
    protected DecimalFormat threeDecimalPlaces;
    protected DecimalFormat fourLeadingPlaces;
    protected final int NUM_BAND_POWERS = 5; // DELTA, THETA, ALPHA, BETA, GAMMA
    protected final int NUM_FFT_BINS_TO_SEND = 125;

    protected Boolean isStreaming;
    private int startIndex;
    private double[][] previousFrameData;

    private int samplesSent = 0;
    private int sampleRateClock = 0;
    private int sampleRateClockInterval = 10000;
    private boolean debugSamplingRate = false;
    private boolean debugAuxSamplingRate = false;
    
    protected NetworkingDataAccumulator dataAccumulator = dataProcessing.networkingDataAccumulator;

    NetworkStreamOut(NetworkDataType dataType) {
        this.dataType = dataType;
        this.isStreaming = false;
        numExgChannels = currentBoard.getNumEXGChannels();
    }

    public void run() {
        openNetwork();
        this.isStreaming = true;
        while(this.isStreaming) {
            if (currentBoard.isStreaming()) {
                if (checkDataIsReadyFlag()) {
                    sendData();
                    resetDataIsReadyFlag();
                } else {
                    try {
                        Thread.sleep(1);
                    } catch (InterruptedException e) {
                        println(e.getMessage());
                    }
                }
            } else {
                try {
                    Thread.sleep(1);
                } catch (InterruptedException e) {
                    println(e.getMessage());
                }
            }
        }
    }

    public void quit() {
        this.isStreaming = false;
        closeNetwork();
        interrupt();
    }

    protected void openNetwork() {
        println("Networking: " + getAttributes());
    }

    protected boolean checkDataIsReadyFlag() {
        switch (dataType) {
            case TIME_SERIES_RAW:
                return dataAccumulator.newTimeSeriesDataToSend.get();
            case TIME_SERIES_FILTERED:
                return dataAccumulator.newTimeSeriesDataToSendFiltered.get();
            case ACCEL_AUX:
                if (currentBoard instanceof AccelerometerCapableBoard) {
                    AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                    if (accelBoard.isAccelerometerActive()) {
                        return dataAccumulator.newAccelDataToSend.get();
                    }
                }
                if (currentBoard instanceof AnalogCapableBoard) {
                    AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                    if (analogBoard.isAnalogActive()) {
                        return dataAccumulator.newAnalogDataToSend.get();
                    }
                }
                if (currentBoard instanceof DigitalCapableBoard) {
                    DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                    if (digitalBoard.isDigitalActive()) {
                        return dataAccumulator.newDigitalDataToSend.get();
                    }
                }
            case MARKER:
                return dataAccumulator.newMarkerDataToSend.get();
            default:
                return dataAccumulator.networkingFrameLocks[this.streamNumber].get();
        }
    }

    protected void resetDataIsReadyFlag() {
        switch (dataType) {
            case TIME_SERIES_RAW:
                dataAccumulator.newTimeSeriesDataToSend.set(false);
                break;
            case TIME_SERIES_FILTERED:
                dataAccumulator.newTimeSeriesDataToSendFiltered.set(false);
                break;
            case ACCEL_AUX:
                if (currentBoard instanceof AccelerometerCapableBoard) {
                    AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                    if (accelBoard.isAccelerometerActive()) {
                        dataAccumulator.newAccelDataToSend.set(false);
                    }
                } else if (currentBoard instanceof AnalogCapableBoard) {
                    AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                    if (analogBoard.isAnalogActive()) {
                        dataAccumulator.newAnalogDataToSend.set(false);
                    }
                } else if (currentBoard instanceof DigitalCapableBoard) {
                    DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                    if (digitalBoard.isDigitalActive()) {
                        dataAccumulator.newDigitalDataToSend.set(false);
                    }
                }
                break;
            case MARKER:
                dataAccumulator.newMarkerDataToSend.set(false);
                break;
            default:
                dataAccumulator.networkingFrameLocks[streamNumber].set(false);
                break;
        }        
    }

    protected void sendData() {
        switch (dataType) {
            case TIME_SERIES_RAW:
                sendTimeSeriesRawData();
                break;
            case TIME_SERIES_FILTERED:
                sendTimeSeriesFilteredData();
                break;
            case FOCUS:
                sendFocusData();
                break;
            case FFT:
                sendFFTData();
                break;
            case EMG:
                sendEMGData();
                break;
            case AVG_BAND_POWERS:
                sendNormalizedBandPowerData();
                break;
            case BAND_POWERS:
                sendBandPowersAllChannels();
                break;
            case ACCEL_AUX:
                if (currentBoard instanceof AccelerometerCapableBoard) {
                    AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                    if (accelBoard.isAccelerometerActive()) {
                        sendAccelerometerData();
                    }
                }
                if (currentBoard instanceof AnalogCapableBoard) {
                    AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                    if (analogBoard.isAnalogActive()) {
                        sendAnalogData();
                    }
                }
                if (currentBoard instanceof DigitalCapableBoard) {
                    DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                    if (digitalBoard.isDigitalActive()) {
                        sendDigitalData();
                    }
                }
                break;
            case PULSE:
                sendPulseData();
                break;
            case EMG_JOYSTICK:
                sendEMGJoystickData();
                break;
            case MARKER:
                sendMarkerData();
                break;
        }

        if (debugSamplingRate) {
            if (dataType == NetworkDataType.TIME_SERIES_RAW 
                    || dataType == NetworkDataType.TIME_SERIES_FILTERED 
                    || dataType == NetworkDataType.MARKER) {
                debugTimeSeriesDataSamplingRate();
            }
        }
    }

    private void debugTimeSeriesDataSamplingRate() {
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
    }

    protected abstract void closeNetwork();
    protected abstract StringList getAttributes();
    protected abstract void sendTimeSeriesFilteredData();
    protected abstract void sendTimeSeriesRawData();
    protected abstract void sendFocusData();
    protected abstract void sendFFTData();
    protected abstract void sendBandPowersAllChannels();
    protected abstract void sendNormalizedBandPowerData();
    protected abstract void sendEMGData();
    protected abstract void sendAccelerometerData();
    protected abstract void sendAnalogData();
    protected abstract void sendDigitalData();
    protected abstract void sendPulseData();
    protected abstract void sendEMGJoystickData();
    protected abstract void sendMarkerData();
}