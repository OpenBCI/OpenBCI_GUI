/* Playback OpenBCI Data Format (CSV) Files */
class BoardPlayback implements Board, AccelerometerCapableBoard {
    private final float ADS1299_Vref = 4.5f;  //reference voltage for ADC in ADS1299.  set by its hardware
    private final float ADS1299_gain = 24.0;  //assumed gain setting for ADS1299.  set by its Arduino code
    private final float scale_fac_uVolts_per_count = ADS1299_Vref / ((float)(pow(2, 23)-1)) / ADS1299_gain  * 1000000.f; //ADS1299 datasheet Table 7, confirmed through experiment
    private final float sine_freq_Hz = 10.0f;

    private DataPacket_ADS1299 dataPacket;
    private boolean streaming = false;
    private boolean isInitialized = false;
    private int lastSynthTime;
    private float[] lastAccelValues;

    public BoardPlayback() {        
        dataPacket = new DataPacket_ADS1299(getNumChannels(), NUM_ACCEL_DIMS);
        lastAccelValues = new float[NUM_ACCEL_DIMS];
    }

    @Override
    public boolean initialize() {
        isInitialized = true;
        return true;
    }

    @Override
    public void uninitialize() {
        isInitialized = false;
    }

    @Override
    public void update() {
        if (!streaming) {
            return; // early out
        }
        
        int samplingIntervalMS = (int)((1.f/getSampleRate()) * 1000);

        while (millis() - lastSynthTime > samplingIntervalMS)
        {

        // generate or read the data
            lastReadDataPacketInd = 0;
            for (int i = 0; i < nPointsPerUpdate; i++) {
                dataPacketBuff[lastReadDataPacketInd].sampleIndex++;
                switch (eegDataSource) {
                case DATASOURCE_PLAYBACKFILE:
                    currentTableRowIndex=getPlaybackDataFromTable(playbackData_table, currentTableRowIndex, 1, 1, dataPacketBuff[lastReadDataPacketInd]);
                    break;
                default:
                    //no action
                }
                //gather the data into the "little buffer"
                for (int Ichan=0; Ichan < nchan; Ichan++) {
                    //scale the data into engineering units..."microvolts"
                    yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan];
                }
            }
            // TODO[brainflow] this is common to all boards. refactor it?
            // This is also used to let the rest of the code that it may be time to do something
            curDataPacketInd = (curDataPacketInd+1) % dataPacketBuff.length;
            dataPacket.copyTo(dataPacketBuff[curDataPacketInd]);

            lastSynthTime += samplingIntervalMS;

        }
    }

    @Override
    public void startStreaming() {
        if(streaming) {
            println("Already streaming, do nothing");
            return;
        }
        lastSynthTime = millis();
        streaming = true;
    }

    @Override
    public void stopStreaming() {
        if(!streaming) {
            println("Already stopped streaming, do nothing");
            return;
        }
        streaming = false;
    }

    public boolean isConnected() {
        return isInitialized;
    }

    @Override
    public int getSampleRate() {
        return 250;
    }
    
    @Override
    public int getNumChannels() {
        return nchan;
    }

    @Override
    public float[] getLastValidAccelValues() {
        return lastAccelValues;
    }

    @Override
    public boolean isAccelerometerActive() {
        return true;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        outputWarn("Can't turn off accelerometer in synthetic board.");
    }

    @Override
    public void setChannelActive(int channelIndex, boolean active) {
        // empty
    }

    @Override
    public void sendCommand(String command) {
        outputWarn("Sending commands is not implemented for Sythetic board. Command: " + command);
    }
    
    @Override
    public void setSampleRate(int sampleRate) {
        outputWarn("Changing the sampling rate is not implemented for Sythetic board. Sampling rate will stay at " + getSampleRate());
    }

};
