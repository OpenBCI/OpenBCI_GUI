public class NetworkingDataAccumulator {

    // These LinkedLists are used to accumulate data from the board in the main thread.
    private LinkedList<double[]> timeSeriesQueue;
    private LinkedList<float[]> filteredTimeSeriesQueue;
    private LinkedList<Double> markerQueue;
    private LinkedList<double[]> accelerometerQueue;
    private LinkedList<double[]> digitalQueue;
    private LinkedList<double[]> analogQueue;
    
    // These buffers are used to store data that is consumed and sent by networking threads.
    private float[][] timeSeriesBuffer;
    private float[][] filteredTimeSeriesBuffer;
    private float[] markerBuffer;
    private float[][] accelerometerBuffer;
    private int[][] digitalBuffer;
    private float[][] analogBuffer;
    
    // These are used as flags to indicate when there is new data to send. Read by networking threads.
    public AtomicBoolean[] networkingFrameLocks = new AtomicBoolean[NETWORKING_STREAMS_COUNT];
    public AtomicBoolean newTimeSeriesDataToSend = new AtomicBoolean(false);
    public AtomicBoolean newTimeSeriesDataToSendFiltered = new AtomicBoolean(false);
    public AtomicBoolean newMarkerDataToSend = new AtomicBoolean(false);
    public AtomicBoolean newAccelDataToSend = new AtomicBoolean(false);
    public AtomicBoolean newDigitalDataToSend = new AtomicBoolean(false);
    public AtomicBoolean newAnalogDataToSend = new AtomicBoolean(false);

    private long startTime;

    public NetworkingDataAccumulator() {
        Arrays.fill(networkingFrameLocks, new AtomicBoolean(false));

        initNetworkingDataBuffers();
    }

    // Call this function in DataProcessing.pde to update the buffers
    public void update() {
        if (!currentBoard.isStreaming()) {
            return;
        }

        accumulateNewData();
        prepareDataToSend();
    }

    private void initNetworkingDataBuffers() {

        timeSeriesBuffer = new float[currentBoard.getNumEXGChannels()][nPointsPerUpdate];
        timeSeriesQueue = new LinkedList<double[]>();

        filteredTimeSeriesBuffer = new float[currentBoard.getNumEXGChannels()][nPointsPerUpdate];
        filteredTimeSeriesQueue = new LinkedList<float[]>();

        markerBuffer = new float[nPointsPerUpdate];
        markerQueue = new LinkedList<Double>();

        if (currentBoard instanceof AccelerometerCapableBoard) {
            AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard)currentBoard;
            accelerometerBuffer = new float[accelBoard.getAccelerometerChannels().length][nPointsPerUpdate];
            accelerometerQueue = new LinkedList<double[]>();
        }

        if (currentBoard instanceof DigitalCapableBoard) {
            DigitalCapableBoard digitalBoard = (DigitalCapableBoard)currentBoard;
            digitalBuffer = new int[digitalBoard.getDigitalChannels().length][nPointsPerUpdate];
            digitalQueue = new LinkedList<double[]>();
        }

        if (currentBoard instanceof AnalogCapableBoard) {
            AnalogCapableBoard analogBoard = (AnalogCapableBoard)currentBoard;
            analogBuffer = new float[analogBoard.getAnalogChannels().length][nPointsPerUpdate];
            analogQueue = new LinkedList<double[]>();
        }
    }

    public void compareAndSetNetworkingFrameLocks() {
        for (int i = 0; i < networkingFrameLocks.length; i++) {
            networkingFrameLocks[i].compareAndSet(false, true);
        }
    }

    private void accumulateNewData() {
        double[][] newData = currentBoard.getFrameData();
        int[] exgChannels = currentBoard.getEXGChannels();
        int markerChannel = currentBoard.getMarkerChannel();

        if (newData[exgChannels[0]].length == 0) {
            return;
        }

        int start = dataProcessingFilteredBuffer[0].length - newData[exgChannels[0]].length;

        for (int iSample = 0; iSample < newData[exgChannels[0]].length; iSample++) {

            double[] sample = new double[exgChannels.length];
            float[] sample_filtered = new float[exgChannels.length];

            for (int iChan = 0; iChan < exgChannels.length; iChan++) {
                sample[iChan] = newData[exgChannels[iChan]][iSample];
                sample_filtered[iChan] = dataProcessingFilteredBuffer[iChan][start + iSample];
            }
            timeSeriesQueue.add(sample);
            filteredTimeSeriesQueue.add(sample_filtered);
            markerQueue.add(newData[markerChannel][iSample]);

            if (currentBoard instanceof AccelerometerCapableBoard) {
                AccelerometerCapableBoard accelBoard = (AccelerometerCapableBoard) currentBoard;
                int[] accelChannels = accelBoard.getAccelerometerChannels();
                double[] accelSample = new double[accelChannels.length];
                for (int iChan = 0; iChan < accelChannels.length; iChan++) {
                    accelSample[iChan] = newData[accelChannels[iChan]][iSample];
                }
                accelerometerQueue.add(accelSample);
            }

            if (currentBoard instanceof DigitalCapableBoard) {
                DigitalCapableBoard digitalBoard = (DigitalCapableBoard) currentBoard;
                if (digitalBoard.isDigitalActive()) {
                    int[] digitalChannels = digitalBoard.getDigitalChannels();
                    double[] digitalSample = new double[digitalChannels.length];
                    for (int iChan = 0; iChan < digitalChannels.length; iChan++) {
                        digitalSample[iChan] = newData[digitalChannels[iChan]][iSample];
                    }
                    digitalQueue.add(digitalSample);
                }
            }

            if (currentBoard instanceof AnalogCapableBoard) {
                AnalogCapableBoard analogBoard = (AnalogCapableBoard) currentBoard;
                if (analogBoard.isAnalogActive()) {
                    int[] analogChannels = analogBoard.getAnalogChannels();
                    double[] analogSample = new double[analogChannels.length];
                    for (int iChan = 0; iChan < analogChannels.length; iChan++) {
                        analogSample[iChan] = newData[analogChannels[iChan]][iSample];
                    }
                    analogQueue.add(analogSample);
                }
            }
        }
    }

                
    private void prepareDataToSend() {

        boolean timeSeriesDataIsReady = timeSeriesQueue.size() >= nPointsPerUpdate;
        if (timeSeriesDataIsReady) {
            if (!newTimeSeriesDataToSend.get()) {
                popDoubleQueueTo2DFloatBuffer(timeSeriesQueue, timeSeriesBuffer, nPointsPerUpdate);
                newTimeSeriesDataToSend.set(true);
            } else {
                popDoubleArrayQueueToMaintainSize(timeSeriesQueue, nPointsPerUpdate);
            }
        }

        boolean timeSeriesDataIsReadyFiltered = filteredTimeSeriesQueue.size() >= nPointsPerUpdate;
        if (timeSeriesDataIsReadyFiltered) {
            if (!newTimeSeriesDataToSendFiltered.get()) {
                popFloatQueueTo2DFloatBuffer(filteredTimeSeriesQueue, filteredTimeSeriesBuffer, nPointsPerUpdate);
                newTimeSeriesDataToSendFiltered.set(true);
            } else {
                popFloatArrayQueueToMaintainSize(filteredTimeSeriesQueue, nPointsPerUpdate);
            }
        }

        boolean markerDataIsReady = markerQueue.size() >= nPointsPerUpdate;
        if (markerDataIsReady) {
            if (!newMarkerDataToSend.get()) {
                popDoubleQueueTo1DFloatBuffer(markerQueue, markerBuffer, nPointsPerUpdate);
                newMarkerDataToSend.set(true);
            } else {
                popDoubleQueueToMaintainSize(markerQueue, nPointsPerUpdate);
            }
        }

        if (currentBoard instanceof AccelerometerCapableBoard) {
            boolean accelDataIsReady = accelerometerQueue.size() >= nPointsPerUpdate;
            if (accelDataIsReady) {
                if (!newAccelDataToSend.get()) {
                    popDoubleQueueTo2DFloatBuffer(accelerometerQueue, accelerometerBuffer, nPointsPerUpdate);
                    newAccelDataToSend.set(true);
                } else {
                    popDoubleArrayQueueToMaintainSize(accelerometerQueue, nPointsPerUpdate);
                }
            }
        }

        if (currentBoard instanceof BoardCyton) {
            boolean digitalDataIsReady = digitalQueue.size() >= nPointsPerUpdate;
            if (digitalDataIsReady) {
                if (!newDigitalDataToSend.get()) {
                    popDoubleQueueTo2DIntBuffer(digitalQueue, digitalBuffer, nPointsPerUpdate);
                    newDigitalDataToSend.set(true);
                } else {
                    popDoubleArrayQueueToMaintainSize(digitalQueue, nPointsPerUpdate);
                }
            }

            boolean analogDataIsReady = analogQueue.size() >= nPointsPerUpdate;
            if (analogDataIsReady) {
                if (!newAnalogDataToSend.get()) {
                    popDoubleQueueTo2DFloatBuffer(analogQueue, analogBuffer, nPointsPerUpdate);
                    newAnalogDataToSend.set(true);
                } else {
                    popDoubleArrayQueueToMaintainSize(analogQueue, nPointsPerUpdate);
                }
            }
        }
    }

    private void popDoubleQueueTo2DFloatBuffer(LinkedList<double[]> queue, float[][] buffer, int pointsPerUpdate) {
        for (int iSample = 0; iSample < pointsPerUpdate; iSample++) {
            double[] sample = queue.pop();

            for (int iChan = 0; iChan < sample.length; iChan++) {
                buffer[iChan][iSample] = (float) sample[iChan];
            }
        }
    }

    private void popFloatQueueTo2DFloatBuffer(LinkedList<float[]> queue, float[][] buffer, int pointsPerUpdate) {
        for (int iSample = 0; iSample < pointsPerUpdate; iSample++) {
            float[] sample = queue.pop();

            for (int iChan = 0; iChan < sample.length; iChan++) {
                buffer[iChan][iSample] = (float) sample[iChan];
            }
        }
    }

    private void popDoubleQueueTo2DIntBuffer(LinkedList<double[]> queue, int[][] buffer, int pointsPerUpdate) {
        for (int iSample = 0; iSample < pointsPerUpdate; iSample++) {
            double[] sample = queue.pop();

            for (int iChan = 0; iChan < sample.length; iChan++) {
                buffer[iChan][iSample] = (int) sample[iChan];
            }
        }
    }

    private void popDoubleQueueTo1DFloatBuffer(LinkedList<Double> queue, float[] buffer, int pointsPerUpdate) {
        for (int iSample = 0; iSample < pointsPerUpdate; iSample++) {
            buffer[iSample] = queue.pop().floatValue();
        }
    }

    private void popDoubleArrayQueueToMaintainSize(LinkedList<double[]> queue, int pointsPerUpdate) {
        for (int iSample = 0; iSample < pointsPerUpdate; iSample++) {
            queue.pop();
        }
    }

    private void popFloatArrayQueueToMaintainSize(LinkedList<float[]> queue, int pointsPerUpdate) {
        for (int iSample = 0; iSample < pointsPerUpdate; iSample++) {
            queue.pop();
        }
    }

    private void popDoubleQueueToMaintainSize(LinkedList<Double> queue, int pointsPerUpdate) {
        for (int iSample = 0; iSample < pointsPerUpdate; iSample++) {
            queue.pop();
        }
    }

    public float[][] getTimeSeriesRawBuffer() {
        return timeSeriesBuffer;
    }

    public float[][] getTimeSeriesFilteredBuffer() {
        return filteredTimeSeriesBuffer;
    }

    public float[] getMarkerBuffer() {
        return markerBuffer;
    }

    public float[][] getAccelBuffer() {
        return accelerometerBuffer;
    }

    public int[][] getDigitalBuffer() {
        return digitalBuffer;
    }

    public float[][] getAnalogBuffer() {
        return analogBuffer;
    }

    public ddf.minim.analysis.FFT[] getFFTBuffer() {
        return fftBuff;
    }

    public float[][] getAllBandPowerData() {
        return dataProcessing.avgPowerInBins;
    }

    public float[] getNormalizedBandPowerData() {
        return ((W_BandPower) widgetManager.getWidget("W_BandPower")).getNormalizedBPSelectedChannels();
    }

    public float[] getEmgNormalizedValues() {
        return dataProcessing.emgSettings.values.getNormalizedValues();
    }

    public int getPulseSensorBPM() {
        return ((W_PulseSensor) widgetManager.getWidget("W_PulseSensor")).getBPM();
    }

    public int getPulseSensorIBI() {
        return ((W_PulseSensor) widgetManager.getWidget("W_PulseSensor")).getIBI();
    }

    public int getFocusValueExceedsThreshold() {
        return ((W_Focus) widgetManager.getWidget("W_Focus")).getMetricExceedsThreshold();
    }

    public float[] getEMGJoystickXY() {
        return ((W_EmgJoystick) widgetManager.getWidget("W_EmgJoystick")).getJoystickXY();
    }
}