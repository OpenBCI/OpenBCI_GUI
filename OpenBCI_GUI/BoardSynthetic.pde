
/* Generates synthetic data
 */
class BoardSynthetic extends Board {
    private final float ADS1299_Vref = 4.5f;  //reference voltage for ADC in ADS1299.  set by its hardware
    private final float ADS1299_gain = 24.0;  //assumed gain setting for ADS1299.  set by its Arduino code
    private final float scale_fac_uVolts_per_count = ADS1299_Vref / ((float)(pow(2, 23)-1)) / ADS1299_gain  * 1000000.f; //ADS1299 datasheet Table 7, confirmed through experiment
    private final float sine_freq_Hz = 10.0f;

    private DataPacket_ADS1299 dataPacket;
    private boolean streaming = false;
    private float[] sine_phase_rad;
    private int lastSynthTime;
    private float[] lastAccelValues;

    // Synthetic accel data timer. Track frame count for synthetic data.
    private int accelSynthTime;

    public BoardSynthetic() {        
        dataPacket = new DataPacket_ADS1299(getNumChannels(), NUM_ACCEL_DIMS);
        sine_phase_rad = new float[getNumChannels()];
        lastAccelValues = new float[NUM_ACCEL_DIMS];
    }

    @Override
    public boolean initialize() {
        return true;
    }

    @Override
    public void uninitialize() {
        // empty
    }

    @Override
    public void update() {
        if (!streaming) {
            return; // early out
        }
        
        int samplingIntervalMS = (int)((1.f/getSampleRate()) * 1000);

        while (millis() - lastSynthTime > samplingIntervalMS)
        {
            synthesizeData();
            synthesizeAccelData();

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
        accelSynthTime = 0;
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

    @Override
    public int getSampleRate() {
        return 250;
    }
    
    @Override
    public int getNumChannels() {
        return nchan;
    }

    @Override
    public float[] getLastAccelValues() {
        return lastAccelValues;
    }

    @Override
    public boolean isAccelerometerActive() {
        return true;
    }

    @Override
    public boolean isAccelerometerAvailable() {
        return true;
    }

    @Override
    public void setChannelActive(int channelIndex, boolean active) {
        // empty
    }

    void synthesizeData() {
        float val_uV;
        for (int Ichan=0; Ichan < nchan; Ichan++) {
            if (isChannelActive(Ichan)) {
                val_uV = randomGaussian()*sqrt(getSampleRate()/2.0f); // ensures that it has amplitude of one unit per sqrt(Hz) of signal bandwidth
                if (Ichan==0) val_uV*= 10f;  //scale one channel higher

                if (Ichan==1) {
                    //add sine wave at 10 Hz at 10 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * sine_freq_Hz / getSampleRate();
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 10.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);
                } else if (Ichan==2) {
                    //50 Hz interference at 50 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * 50.0f / getSampleRate();  //60 Hz
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 50.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);    //20 uVrms
                } else if (Ichan==3) {
                    //60 Hz interference at 50 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * 60.0f / getSampleRate();  //50 Hz
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 50.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //20 uVrms
                }
            } else {
                val_uV = 0.0f;
            }
            dataPacket.values[Ichan] = (int) (0.5f+ val_uV / scale_fac_uVolts_per_count); //convert to counts, the 0.5 is to ensure rounding
        }
    }

    void synthesizeAccelData() {
        for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
            // simple sin wave tied to current time.
            // offset each axis by its index * 2
            // multiply by accelXyzLimit to fill the height of the plot
            lastAccelValues[i] = sin(accelSynthTime/100.f + i*2.f) * accelXyzLimit;
        }
        accelSynthTime ++;
    }//end void synthesizeAccelData
};
