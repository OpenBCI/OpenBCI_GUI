
//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------
import ddf.minim.analysis.*; //for FFT

import brainflow.DataFilter;
import brainflow.FilterTypes;

String curTimestamp;
HashMap<Integer,String> index_of_times;

float playback_speed_fac = 1.0f;  //make 1.0 for real-time.  larger for faster playback

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------


void processNewData() {

    List<double[]> currentData = currentBoard.getData(getCurrentBoardBufferSize());
    int[] exgChannels = currentBoard.getEXGChannels();
    int channelCount = currentBoard.getNumEXGChannels();

    if (currentData.size() == 0 || currentData.get(0).length == 0) {
        return;
    }

    //update the data buffers
    for (int channel=0; channel < channelCount; channel++) {
        for(int i = 0; i < getCurrentBoardBufferSize(); i++) {
            dataProcessingRawBuffer[channel][i] = (float)currentData.get(i)[exgChannels[channel]];
        }

        dataProcessingFilteredBuffer[channel] = dataProcessingRawBuffer[channel].clone();
    }

    //apply additional processing for the time-domain montage plot (ie, filtering)
    dataProcessing.process(dataProcessingFilteredBuffer, fftBuff);

    //look to see if the latest data is railed so that we can notify the user on the GUI
    for (int channel=0; channel < globalChannelCount; channel++) is_railed[channel].update(dataProcessingRawBuffer[channel], channel);

    //compute the electrode impedance. Do it in a very simple way [rms to amplitude, then uVolt to Volt, then Volt/Amp to Ohm]
    for (int channel=0; channel < globalChannelCount; channel++) {
        // Calculate the impedance
        float impedance = (sqrt(2.0)*dataProcessing.data_std_uV[channel]*1.0e-6) / BoardCytonConstants.leadOffDrive_amps;
        // Subtract the 2.2kOhm resistor
        impedance -= BoardCytonConstants.series_resistor_ohms;
        // Verify the impedance is not less than 0
        if (impedance < 0) {
            // Incase impedance some how dipped below 2.2kOhm
            impedance = 0;
        }
        // Store to the global variable
        data_elec_imp_ohm[channel] = impedance;
    }
}

void initializeFFTObjects(ddf.minim.analysis.FFT[] fftBuff, float[][] dataProcessingRawBuffer, int fftPointCount, float fs_Hz) {
    float[] fooData;
    for (int channel=0; channel < globalChannelCount; channel++) {
        //make the FFT objects...Following "SoundSpectrum" example that came with the Minim library
        fftBuff[channel].window(ddf.minim.analysis.FFT.HAMMING);

        //do the FFT on the initial data
        if (globalFFTSettings.getDataIsFiltered()) {
            fooData = dataProcessingFilteredBuffer[channel];  //use the filtered data for the FFT
        } else {
            fooData = dataProcessingRawBuffer[channel];  //use the raw data for the FFT
        }
        fooData = Arrays.copyOfRange(fooData, fooData.length-fftPointCount, fooData.length);
        fftBuff[channel].forward(fooData); //compute FFT on this channel of data
    }
}

//------------------------------------------------------------------------
//                          CLASSES
//------------------------------------------------------------------------

class DataProcessing {
    private float fs_Hz;  //sample rate
    float data_std_uV[];
    float polarity[];
    final int[] processing_band_low_Hz = {
        1, 4, 8, 13, 30
    }; //lower bound for each frequency band of interest (2D classifier only)
    final int[] processing_band_high_Hz = {
        4, 8, 13, 30, 55
    };  //upper bound for each frequency band of interest
    float avgPowerInBins[][];
    float headWidePower[];

    public EmgSettings emgSettings;
    public NetworkingSettings networkingSettings;
    public NetworkingDataAccumulator networkingDataAccumulator;

    private final int DOWNSAMPLING_FACTOR = getDownsamplingFactor();
    private int downsamplingCounter = DOWNSAMPLING_FACTOR; // Start at DOWNSAMPLING_FACTOR to accept the first sample

    DataProcessing(float sample_rate_Hz) {
        fs_Hz = sample_rate_Hz;
        data_std_uV = new float[globalChannelCount];
        polarity = new float[globalChannelCount];
        avgPowerInBins = new float[globalChannelCount][processing_band_low_Hz.length];
        headWidePower = new float[processing_band_low_Hz.length];
        emgSettings = new EmgSettings();
        networkingSettings = new NetworkingSettings();
        networkingDataAccumulator = new NetworkingDataAccumulator();
    }
    
    //Process data on a channel-by-channel basis
    private synchronized void processChannel(int channel, float[][] data_forDisplay_uV, float[] prevFFTdata) {            
        int fftPointCount = getNumFFTPoints();
        double foo;

        // Filter the data in the time domain
        // TODO: Use double arrays here and convert to float only to plot data.
        // ^^^ This might not feasible or meaningful performance improvement. I looked into it a while ago and it seems we need floats for the FFT library also. -RW 2022)
        try {
            double[] tempArray = floatToDoubleArray(data_forDisplay_uV[channel]);
            
            //Apply BandStop filter if the filter should be active on this channel
            if (filterSettings.values.bandStopFilterActive[channel].isActive()) {
                DataFilter.perform_bandstop(
                    tempArray,
                    currentBoard.getSampleRate(),
                    filterSettings.values.bandStopStartFreq[channel],
                    filterSettings.values.bandStopStopFreq[channel],
                    filterSettings.values.bandStopFilterOrder[channel].getValue(),
                    filterSettings.values.bandStopFilterType[channel].getValue(),
                    1.0);
            }

            //Apply BandPass filter if the filter should be active on this channel
            if (filterSettings.values.bandPassFilterActive[channel].isActive()) {
                DataFilter.perform_bandpass(
                    tempArray,
                    currentBoard.getSampleRate(),
                    filterSettings.values.bandPassStartFreq[channel],
                    filterSettings.values.bandPassStopFreq[channel],
                    filterSettings.values.bandPassFilterOrder[channel].getValue(),
                    filterSettings.values.bandPassFilterType[channel].getValue(),
                    1.0);
            }

            //Apply Environmental Noise filter on all channels. Do it like this since there are no codes for NONE or FIFTY_AND_SIXTY in BrainFlow
            switch (filterSettings.values.globalEnvFilter) {
                case FIFTY_AND_SIXTY:
                    DataFilter.perform_bandstop(
                        tempArray,
                        currentBoard.getSampleRate(),
                        48d,
                        52d,
                        4,
                        BrainFlowFilterType.BUTTERWORTH.getValue(),
                        1d);
                    DataFilter.perform_bandstop(
                        tempArray,
                        currentBoard.getSampleRate(),
                        58d,
                        62d,
                        4,
                        BrainFlowFilterType.BUTTERWORTH.getValue(),
                        1d);
                    break;
                case FIFTY:
                    DataFilter.perform_bandstop(
                        tempArray,
                        currentBoard.getSampleRate(),
                        48d,
                        52d,
                        4,
                        BrainFlowFilterType.BUTTERWORTH.getValue(),
                        1d);
                    break;
                case SIXTY:
                    DataFilter.perform_bandstop(
                        tempArray,
                        currentBoard.getSampleRate(),
                        58d,
                        62d,
                        4,
                        BrainFlowFilterType.BUTTERWORTH.getValue(),
                        1d);
                    break;
                default:
                    break;
            }

            doubleToFloatArray(tempArray, data_forDisplay_uV[channel]);
        } catch (BrainFlowError e) {
            e.printStackTrace();
        }

        //compute the standard deviation of the filtered signal...this is for the head plot
        float[] fooData_filt = dataProcessingFilteredBuffer[channel];  //use the filtered data
        fooData_filt = Arrays.copyOfRange(fooData_filt, fooData_filt.length-((int)fs_Hz), fooData_filt.length);   //just grab the most recent second of data
        data_std_uV[channel] = std(fooData_filt); //compute the standard deviation for the whole array "fooData_filt"

        //copy the previous FFT data...enables us to apply some smoothing to the FFT data
        for (int I=0; I < fftBuff[channel].specSize(); I++) {
            prevFFTdata[I] = fftBuff[channel].getBand(I); //copy the old spectrum values
        }

        //prepare the data for the new FFT
        float[] fooData;
        if (globalFFTSettings.getDataIsFiltered()) {
            fooData = dataProcessingFilteredBuffer[channel];  //use the filtered data for the FFT
        } else {
            fooData = dataProcessingRawBuffer[channel];  //use the raw data for the FFT
        }
        fooData = Arrays.copyOfRange(fooData, fooData.length-fftPointCount, fooData.length);   //trim to grab just the most recent block of data
        float meanData = mean(fooData);  //compute the mean
        for (int I=0; I < fooData.length; I++) fooData[I] -= meanData; //remove the mean (for a better looking FFT

        //compute the FFT
        fftBuff[channel].forward(fooData); //compute FFT on this channel of data

        // FFT ref: https://www.mathworks.com/help/matlab/ref/fft.html
        // first calculate double-sided FFT amplitude spectrum
        for (int I=0; I <= fftPointCount/2; I++) {
            fftBuff[channel].setBand(I, (float)(fftBuff[channel].getBand(I) / fftPointCount));
        }
        // then convert into single-sided FFT spectrum: DC & Nyquist (i=0 & i=N/2) remain the same, others multiply by two.
        for (int I=1; I < fftPointCount/2; I++) {
            fftBuff[channel].setBand(I, (float)(fftBuff[channel].getBand(I) * 2));
        }

        //average the FFT with previous FFT data so that it makes it smoother in time
        double min_val = 0.01d;
        float smoothingFactor = globalFFTSettings.getSmoothingFactor().getValue();
        for (int I=0; I < fftBuff[channel].specSize(); I++) {   //loop over each fft bin
            if (prevFFTdata[I] < min_val) prevFFTdata[I] = (float)min_val; //make sure we're not too small for the log calls
            foo = fftBuff[channel].getBand(I);
            if (foo < min_val) foo = min_val; //make sure this value isn't too small

            if (true) {
                //smooth in dB power space
                foo =   (1.0d - smoothingFactor) * java.lang.Math.log(java.lang.Math.pow(foo, 2));
                foo += smoothingFactor * java.lang.Math.log(java.lang.Math.pow((double)prevFFTdata[I], 2));
                foo = java.lang.Math.sqrt(java.lang.Math.exp(foo)); //average in dB space
            } else {
                //LEGACY CODE -- NOT USED
                //smooth (average) in linear power space
                foo =   (1.0d - smoothingFactor) * java.lang.Math.pow(foo, 2);
                foo+= smoothingFactor * java.lang.Math.pow((double)prevFFTdata[I], 2);
                // take sqrt to be back into uV_rtHz
                foo = java.lang.Math.sqrt(foo);
            }
            fftBuff[channel].setBand(I, (float)foo); //put the smoothed data back into the fftBuff data holder for use by everyone else
            // fftBuff[channel].setBand(I, 1.0f);  // test
        } //end loop over FFT bins

        // calculate single-sided psd by single-sided FFT amplitude spectrum
        // PSD ref: https://www.mathworks.com/help/dsp/ug/estimate-the-power-spectral-density-in-matlab.html
        // when i = 1 ~ (N/2-1), psd = (N / fs) * mag(i)^2 / 4
        // when i = 0 or i = N/2, psd = (N / fs) * mag(i)^2

        for (int i = 0; i < processing_band_low_Hz.length; i++) {
            float sum = 0;
            // int binNum = 0;
            for (int Ibin = 0; Ibin <= fftPointCount/2; Ibin ++) { // loop over FFT bins
                float FFT_freq_Hz = fftBuff[channel].indexToFreq(Ibin);   // center frequency of this bin
                float psdx = 0;
                // if the frequency matches a band
                if (FFT_freq_Hz >= processing_band_low_Hz[i] && FFT_freq_Hz < processing_band_high_Hz[i]) {
                    if (Ibin != 0 && Ibin != fftPointCount/2) {
                        psdx = fftBuff[channel].getBand(Ibin) * fftBuff[channel].getBand(Ibin) * fftPointCount/currentBoard.getSampleRate() / 4;
                    }
                    else {
                        psdx = fftBuff[channel].getBand(Ibin) * fftBuff[channel].getBand(Ibin) * fftPointCount/currentBoard.getSampleRate();
                    }
                    sum += psdx;
                    // binNum ++;
                }
            }
            avgPowerInBins[channel][i] = sum;   // total power in a band
            // println(i, binNum, sum);
        }
    }

    public void process(float[][] data_forDisplay_uV, ddf.minim.analysis.FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

        float prevFFTdata[] = new float[fftBuff[0].specSize()];

        for (int channel=0; channel < globalChannelCount; channel++) { 
            processChannel(channel, data_forDisplay_uV, prevFFTdata);
        } //end the loop over channels.

        for (int i = 0; i < processing_band_low_Hz.length; i++) {
            float sum = 0;

            for (int j = 0; j < globalChannelCount; j++) {
                sum += avgPowerInBins[j][i];
            }
            headWidePower[i] = sum/globalChannelCount;   // averaging power over all channels
        }

        /////////////////////////////////////////////////////////////
        // Compute widget values independent of widgets being open //
        //                       -RW #1094                         //
        /////////////////////////////////////////////////////////////
        emgSettings.values.process(dataProcessingFilteredBuffer);
        ((W_Focus) widgetManager.getWidget("W_Focus")).updateFocusWidgetData();
        ((W_BandPower) widgetManager.getWidget("W_BandPower")).updateBandPowerWidgetData();
        ((W_EmgJoystick) widgetManager.getWidget("W_EmgJoystick")).updateEmgJoystickWidgetData();
        if (currentBoard instanceof BoardCyton) {
            if (widgetManager.getWidgetExists("W_PulseSensor")) {
                ((W_PulseSensor) widgetManager.getWidget("W_PulseSensor")).updatePulseSensorWidgetData();
            }
        }

        networkingDataAccumulator.update();

        addFilteredDataToDownsampledBuffer();
    }

    private void addFilteredDataToDownsampledBuffer() {
        int[] exgChannels = currentBoard.getEXGChannels();
        float[][] filteredData = dataProcessingFilteredBuffer;
        double[][] frameData = currentBoard.getFrameData();

        if (frameData[exgChannels[0]].length == 0) {
            return;
        }

        if (!currentBoard.isStreaming()) {
            return;
        }
        
        int start = filteredData[0].length - frameData[exgChannels[0]].length;

        for (int iSample = start; iSample < filteredData[exgChannels[0]].length; iSample++) {
            if (downsamplingCounter == DOWNSAMPLING_FACTOR) {
                downsamplingCounter = 0;
                for (int iChannel = 0; iChannel < exgChannels.length; iChannel++) {
                    downsampledFilteredBuffer.add(iChannel, filteredData[iChannel][iSample]);
                }
            }
            downsamplingCounter++;
        }
    }

    //Called when using the Playback Scrollbar to update the data while in Playback Mode
    public void updateEntireDownsampledBuffer() {
        int[] exgChannels = currentBoard.getEXGChannels();
        float[][] filteredData = dataProcessingFilteredBuffer;
        downsampledFilteredBuffer.initArrays();
        

        for (int iSample = 0; iSample < filteredData[0].length; iSample++) {
            if (downsamplingCounter == DOWNSAMPLING_FACTOR) {
                downsamplingCounter = 0;
                for (int iChannel = 0; iChannel < exgChannels.length; iChannel++) {
                    downsampledFilteredBuffer.add(iChannel, filteredData[iChannel][iSample]);
                }
            }
            downsamplingCounter++;
        }
    }

    private void clearCalculatedMetricWidgets() {
        println("Clearing calculated metric widgets");
        ((W_Spectrogram) widgetManager.getWidget("W_Spectrogram")).clear();
        ((W_Focus) widgetManager.getWidget("W_Focus")).clear();
    }
}