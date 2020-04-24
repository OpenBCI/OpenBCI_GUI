import java.util.stream.IntStream;

/* Generates synthetic data
 */
class BoardSynthetic implements Board, AccelerometerCapableBoard {
    private final float sine_freq_Hz = 10.0f;

    private boolean streaming = false;
    private boolean isInitialized = false;
    private float[] sine_phase_rad;
    private int lastSynthTime;
    private int samplingIntervalMS;
    private int[] exgChannels;
    private int[] accelChanels;
    private int totalChannels;
    private double[][] dataThisFrame;

    private double[][] emptyData;

    // Synthetic accel data timer. Track frame count for synthetic data.
    private int accelSynthTime;

    public BoardSynthetic() {        
    }

    @Override
    public boolean initialize() {
        exgChannels = range(0, nchan);
        accelChanels = range(nchan, nchan + NUM_ACCEL_DIMS);
        
        sine_phase_rad = new float[getNumEXGChannels()];

        totalChannels = exgChannels.length + accelChanels.length;

        samplingIntervalMS = (int)((1.f/getSampleRate()) * 1000);

        emptyData = new double[totalChannels][0];

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
            dataThisFrame = emptyData;
            return; // early out
        }

        synthesizeData();
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

    public boolean isConnected() {
        return isInitialized;
    }

    @Override
    public int getSampleRate() {
        return 250;
    }
    
    @Override
    public int getNumEXGChannels() {
        return getEXGChannels().length;
    }

    @Override
    public int[] getEXGChannels() {
        return exgChannels;
    }

    @Override
    public double[][] getDataThisFrame() {
        return dataThisFrame;
    }

    @Override
    public int[] getAccelerometerChannels() {
        return accelChanels;
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

    void synthesizeData() {
        int timeElapsed = millis() - lastSynthTime;
        int totalSamples = timeElapsed / samplingIntervalMS;

        dataThisFrame = new double[totalChannels][totalSamples];

        for (int i=0; i<totalSamples; i++)
        {
            synthesizeEXGData(i);
            synthesizeAccelData(i);
            
            lastSynthTime += samplingIntervalMS;
        }
    }

    //Synthesize Time Series Data to Test GUI Functionality
    void synthesizeEXGData(int sampleIndex) {
        float val_uV;
        for (int Ichan : getEXGChannels()) {
            if (isChannelActive(Ichan)) {
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

            dataThisFrame[Ichan][sampleIndex] = (double)(0.5 + val_uV); //convert to counts, the 0.5 is to ensure rounding
        }
    }

    void synthesizeAccelData(int sampleIndex) {
        for (int i = 0; i < accelChanels.length; i++) {
            // simple sin wave tied to current time.
            // offset each axis by its index * 2
            // multiply by accelXyzLimit to fill the height of the plot
            dataThisFrame[accelChanels[i]][sampleIndex] = (double)sin(accelSynthTime/100.0 + i*2.0) * w_accelerometer.accelXyzLimit;
        }
        accelSynthTime ++;
    }//end void synthesizeAccelData
};
