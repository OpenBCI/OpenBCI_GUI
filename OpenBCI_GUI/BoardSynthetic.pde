import java.util.stream.IntStream;

/* Generates synthetic data
 */
class BoardSynthetic extends Board implements AccelerometerCapableBoard {
    private final float sine_freq_Hz = 10.0f;

    private boolean streaming = false;
    private boolean isInitialized = false;
    private float[] sine_phase_rad;
    private int lastSynthTime;
    private int samplingIntervalMS;
    private boolean[] exgChannelActive;

    private int sampleNumberChannel;
    private int[] exgChannels;
    private int[] accelChannels;
    private int timestampChannel;
    private int totalChannels;


    // Synthetic accel data timer. Track frame count for synthetic data.
    private int accelSynthTime;

    public BoardSynthetic() {    
        totalChannels = 0;
        sampleNumberChannel = totalChannels++;
        exgChannels = range(totalChannels, totalChannels + nchan);
        totalChannels += nchan;
        accelChannels = range(totalChannels, totalChannels + NUM_ACCEL_DIMS);
        totalChannels += NUM_ACCEL_DIMS;
        timestampChannel = totalChannels++;    
    }

    @Override
    public boolean initializeInternal() {

        exgChannelActive = new boolean[exgChannels.length];
        Arrays.fill(exgChannelActive, true);
        
        sine_phase_rad = new float[getNumEXGChannels()];

        samplingIntervalMS = (int)((1.f/getSampleRate()) * 1000);

        accelSynthTime = 0;
        
        isInitialized = true;
        return true;
    }

    @Override
    public void uninitializeInternal() {
        isInitialized = false;
    }

    @Override
    public void updateInternal() {
        //empty
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
    public int[] getEXGChannels() {
        return exgChannels;
    }

    @Override
    public int getTimestampChannel() {
        return timestampChannel;
    }
    
    @Override
    public int getSampleNumberChannel() {
        return sampleNumberChannel;
    }

    @Override
    public int[] getAccelerometerChannels() {
        return accelChannels;
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
    public void setEXGChannelActive(int channelIndex, boolean active) {
        exgChannelActive[channelIndex] = active;
    }

    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return exgChannelActive[channelIndex];
    }

    @Override
    public void sendCommand(String command) {
        outputWarn("Sending commands is not implemented for Sythetic board. Command: " + command);
    }
    
    @Override
    public void setSampleRate(int sampleRate) {
        outputWarn("Changing the sampling rate is not implemented for Sythetic board. Sampling rate will stay at " + getSampleRate());
    }

    @Override
    protected double[][] getNewDataInternal() {
        if(!streaming) {
            return emptyData;
        }

        int timeElapsed = millis() - lastSynthTime;
        int totalSamples = timeElapsed / samplingIntervalMS;

        double[][] newData = new double[totalChannels][totalSamples];

        for (int i=0; i<totalSamples; i++)
        {
            synthesizeEXGData(newData, i);
            synthesizeAccelData(newData, i);
            
            lastSynthTime += samplingIntervalMS;
        }

        return newData;
    }

    //Synthesize Time Series Data to Test GUI Functionality
    private void synthesizeEXGData(double[][] buffer, int sampleIndex) {
        float val_uV;
        for (int i = 0; i<getNumEXGChannels(); i++) {
            int Ichan = exgChannels[i];
            if (isEXGChannelActive(i)) {
                val_uV = randomGaussian()*sqrt(getSampleRate()/2.0f); // ensures that it has amplitude of one unit per sqrt(Hz) of signal bandwidth
                if (Ichan==0) {
                    val_uV*= 10f;  //scale one channel higher
                } else if (Ichan==1) {
                    //add sine wave at 10 Hz at 10 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * sine_freq_Hz / getSampleRate();
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 10.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);
                } else if (Ichan==2) {
                    //15 Hz interference at 20 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * 15.0f / getSampleRate();  //15 Hz
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 20.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);    //20 uVrms
                } else if (Ichan==3) {
                    //20 Hz interference at 30 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * 20.0f / getSampleRate();  //20 Hz
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 30.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //30 uVrms
                } else if (Ichan==4) {
                    //25 Hz interference at 40 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * 25.0f / getSampleRate();  //25 Hz
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 40.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //40 uVrms
                } else if (Ichan==5) {
                    //30 Hz interference at 50 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * 30.0f / getSampleRate();  //30 Hz
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 50.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //50 uVrms
                } else if (Ichan==6) {
                    //50 Hz interference at 60 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * 50.0f / getSampleRate();  //50 Hz
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 60.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //60 uVrms
                } else if (Ichan==7) {
                    //60 Hz interference at 120 uVrms
                    sine_phase_rad[Ichan] += 2.0f*PI * 60.0f / getSampleRate();  //60 Hz
                    if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                    val_uV += 120.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //120 uVrms
                }
            } else {
                val_uV = 0.0f;
            }

            buffer[Ichan][sampleIndex] = (double)(0.5 + val_uV); //convert to counts, the 0.5 is to ensure rounding
        }
    }

    private void synthesizeAccelData(double[][] buffer, int sampleIndex) {
        for (int i = 0; i < accelChannels.length; i++) {
            // simple sin wave tied to current time.
            // offset each axis by its index * 2
            // multiply by accelXyzLimit to fill the height of the plot
            buffer[accelChannels[i]][sampleIndex] = (double)sin(accelSynthTime/100.0 + i*2.0) * w_accelerometer.accelXyzLimit;
        }
        accelSynthTime ++;
    }//end void synthesizeAccelData

    @Override
    protected int getTotalChannelCount() {
        return totalChannels;
    }
    
    @Override
    protected void addChannelNamesInternal(String[] channelNames) {
        for (int i=0; i<accelChannels.length; i++) {
            channelNames[accelChannels[i]] = "Accel Channel " + i;
        }
    }
};
