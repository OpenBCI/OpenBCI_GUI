
//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------
import ddf.minim.analysis.*; //for FFT

DataProcessing dataProcessing;
String curTimestamp;
boolean hasRepeated = false;
HashMap<Integer,String> index_of_times;

// indexes
final int DELTA = 0; // 1-4 Hz
final int THETA = 1; // 4-8 Hz
final int ALPHA = 2; // 8-13 Hz
final int BETA = 3; // 13-30 Hz
final int GAMMA = 4; // 30-55 Hz

float playback_speed_fac = 1.0f;  //make 1.0 for real-time.  larger for faster playback

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//called from systemUpdate when mode=10 and isRunning = true
void process_input_file() throws Exception {
    index_of_times = new HashMap<Integer, String>();
    indices = 0;
    float scaler = BoardCytonConstants.scale_fac_uVolts_per_count;
    if (currentBoard instanceof BoardBrainFlow) {
        scaler = 1;
    }
    try {
        while (!hasRepeated) {
            currentTableRowIndex = getPlaybackDataFromTable(playbackData_table, currentTableRowIndex, scaler, scaler, dataPacketBuff[lastReadDataPacketInd]);
            if (curTimestamp != null) {
                index_of_times.put(indices, curTimestamp.substring(1)); //remove white space from timestamp
            } else {
                index_of_times.put(indices, "notFound");
            }
            indices++;
        }
        println("number of indexes "+indices);
        println("Finished filling hashmap");
        has_processed = true;
    }
    catch (Exception e) {
        e.printStackTrace();
        throw new Exception();
    }
}

/*************************/
int getDataIfAvailable(int pointCounter) {
    float scaler = BoardCytonConstants.scale_fac_uVolts_per_count;
    if (currentBoard instanceof BoardBrainFlow) {
        scaler = 1;
    }

    // todo[brainflow] - this code here is just a copypaste get rid of it
    if (eegDataSource == DATASOURCE_CYTON) {
        //get data from serial port as it streams in
        //next, gather any new data into the "little buffer"
        try {
            while ( (curDataPacketInd != lastReadDataPacketInd) && (pointCounter < nPointsPerUpdate) && (timestamps.length != 0)) {
                lastReadDataPacketInd = (lastReadDataPacketInd+1) % dataPacketBuff.length;  //increment to read the next packet
                for (int Ichan=0; Ichan < nchan; Ichan++) {   //loop over each cahnnel
                    //scale the data into engineering units ("microvolts") and save to the "little buffer"
                    yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan] * scaler;
                }
                for (int auxChan=0; auxChan < 3; auxChan++) auxBuff[auxChan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].auxValues[auxChan];
                //println(timestamps.length);
                long timestamp = (long) (timestamps[(pointCounter) % (timestamps.length+1)] * 1000);
                //println(timestamp + " | " + pointCounter % (timestamps.length + 1) + " of " + timestamps.length);
                saveDataToFile(scaler, lastReadDataPacketInd, timestamp,  currentBoard.getLastValidAccelValues());
                pointCounter++; //increment counter for "little buffer"
            }
        } catch (Exception e) {
            //e.printStackTrace();
        }
    } else if (eegDataSource == DATASOURCE_GANGLION) {
        //get data from ble as it streams in
        //next, gather any new data into the "little buffer"
        while ( (curDataPacketInd != lastReadDataPacketInd) && (pointCounter < nPointsPerUpdate)) {
            lastReadDataPacketInd = (lastReadDataPacketInd + 1) % dataPacketBuff.length;  //increment to read the next packet
            for (int Ichan=0; Ichan < nchan; Ichan++) {   //loop over each cahnnel
                //scale the data into engineering units ("microvolts") and save to the "little buffer"
                yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan] * scaler;
            }
            pointCounter++; //increment counter for "little buffer"
        }

    } else if (eegDataSource == DATASOURCE_NOVAXR) {
        while ( (curDataPacketInd != lastReadDataPacketInd) && (pointCounter < nPointsPerUpdate)) {
            lastReadDataPacketInd = (lastReadDataPacketInd+1) % dataPacketBuff.length;  //increment to read the next packet
            
            for (int Ichan=0; Ichan < nchan; Ichan++) {   //loop over each cahnnel
                //scale the data into engineering units ("microvolts") and save to the "little buffer"
                yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan];
            }
            for (int auxChan=0; auxChan < 3; auxChan++) auxBuff[auxChan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].auxValues[auxChan];
            pointCounter++; //increment counter for "little buffer"
        }

    } else if (eegDataSource == DATASOURCE_SYNTHETIC) {

        while ( (curDataPacketInd != lastReadDataPacketInd) && (pointCounter < nPointsPerUpdate)) {
            lastReadDataPacketInd = (lastReadDataPacketInd+1) % dataPacketBuff.length;  //increment to read the next packet
            
            for (int Ichan=0; Ichan < nchan; Ichan++) {   //loop over each cahnnel
                //scale the data into engineering units ("microvolts") and save to the "little buffer"
                yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan] * scaler;
            }
            for (int auxChan=0; auxChan < 3; auxChan++) auxBuff[auxChan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].auxValues[auxChan];
            pointCounter++; //increment counter for "little buffer"
        }

    } else {
        // make or load data to simulate real time

        //has enough time passed?
        int current_millis = millis();
        if (current_millis >= nextPlayback_millis) {
            //prepare for next time
            int increment_millis = int(round(float(nPointsPerUpdate)*1000.f/getSampleRateSafe())/playback_speed_fac);
            if (nextPlayback_millis < 0) nextPlayback_millis = current_millis;
            nextPlayback_millis += increment_millis;

            // generate or read the data
            lastReadDataPacketInd = 0;
            for (int i = 0; i < nPointsPerUpdate; i++) {
                dataPacketBuff[lastReadDataPacketInd].sampleIndex++;
                switch (eegDataSource) {
                case DATASOURCE_PLAYBACKFILE:
                    currentTableRowIndex=getPlaybackDataFromTable(playbackData_table, currentTableRowIndex, scaler, scaler, dataPacketBuff[lastReadDataPacketInd]);
                    break;
                default:
                    //no action
                }
                //gather the data into the "little buffer"
                for (int Ichan=0; Ichan < nchan; Ichan++) {
                    //scale the data into engineering units..."microvolts"
                    yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan]* scaler;
                }

                pointCounter++;
            } //close the loop over data points
        } // close "has enough time passed"
    }
    return pointCounter;
}

void saveDataToFile(float scaler, int curDataPacketInd, long timestamp, float[] _auxBuff) {
    //If data is available, save to playback file...
    float auxScaler = scaler;
    int stopByte = 0xC0;
    switch (outputDataSource) {
        case OUTPUT_SOURCE_ODF:
            if (eegDataSource == DATASOURCE_GANGLION) {
                //auxScaler = ganglion.get_scale_fac_accel_G_per_count();
                auxScaler = 1;
            } else {
                if (eegDataSource == DATASOURCE_CYTON) {
                    if (currentBoard.isDigitalActive() || currentBoard.isAnalogActive()) {
                        stopByte = 0xC1;
                    }
                }
            }
            fileoutput_odf.writeRawData_dataPacket(
                            dataPacketBuff[curDataPacketInd],
                            scaler,
                            _auxBuff,
                            auxScaler,
                            stopByte,
                            timestamp
                        );
            break;
        case OUTPUT_SOURCE_BDF:
            // curBDFDataPacketInd = curDataPacketInd;
            // thread("writeRawData_dataPacket_bdf");
            fileoutput_bdf.writeRawData_dataPacket(dataPacketBuff[curDataPacketInd]);
            break;
        case OUTPUT_SOURCE_NONE:
        default:
            // Do nothing...
            break;
    }
}

RunningMean avgBitRate = new RunningMean(10);  //10 point running average...at 5 points per second, this should be 2 second running average

void processNewData() {
    //compute instantaneous byte rate
    float inst_byteRate_perSec = (int)(1000.f * ((float)(openBCI_byteCount - prevBytes)) / ((float)(millis() - prevMillis)));

    prevMillis=millis();           //store for next time
    prevBytes = openBCI_byteCount; //store for next time

    //compute smoothed byte rate
    avgBitRate.addValue(inst_byteRate_perSec);
    byteRate_perSec = (int)avgBitRate.calcMean();

    //update the data buffers
    for (int Ichan=0; Ichan < nchan; Ichan++) {
        //append the new data to the larger data buffer...because we want the plotting routines
        //to show more than just the most recent chunk of data.  This will be our "raw" data.
        appendAndShift(dataBuffY_uV[Ichan], yLittleBuff_uV[Ichan]);

        //make a copy of the data that we'll apply processing to.  This will be what is displayed on the full montage
        dataBuffY_filtY_uV[Ichan] = dataBuffY_uV[Ichan].clone();
    }

    //if you want to, re-reference the montage to make it be a mean-head reference
    if (false) rereferenceTheMontage(dataBuffY_filtY_uV);

    //apply additional processing for the time-domain montage plot (ie, filtering)
    dataProcessing.process(yLittleBuff_uV, dataBuffY_uV, dataBuffY_filtY_uV, fftBuff);

    dataProcessing_user.process(yLittleBuff_uV, dataBuffY_uV, dataBuffY_filtY_uV, fftBuff);
    dataProcessing.newDataToSend = true;

    //look to see if the latest data is railed so that we can notify the user on the GUI
    for (int Ichan=0; Ichan < nchan; Ichan++) is_railed[Ichan].update(dataPacketBuff[lastReadDataPacketInd].values[Ichan]);

    //compute the electrode impedance. Do it in a very simple way [rms to amplitude, then uVolt to Volt, then Volt/Amp to Ohm]
    for (int Ichan=0; Ichan < nchan; Ichan++) {
        // Calculate the impedance
        float impedance = (sqrt(2.0)*dataProcessing.data_std_uV[Ichan]*1.0e-6) / BoardCytonConstants.leadOffDrive_amps;
        // Subtract the 2.2kOhm resistor
        impedance -= BoardCytonConstants.series_resistor_ohms;
        // Verify the impedance is not less than 0
        if (impedance < 0) {
            // Incase impedance some how dipped below 2.2kOhm
            impedance = 0;
        }
        // Store to the global variable
        data_elec_imp_ohm[Ichan] = impedance;
    }
}

//helper function in handling the EEG data
void appendAndShift(float[] data, float[] newData) {
    int nshift = newData.length;
    int end = data.length-nshift;
    for (int i=0; i < end; i++) {
        data[i]=data[i+nshift];  //shift data points down by 1
    }
    for (int i=0; i<nshift; i++) {
        data[end+i] = newData[i];  //append new data
    }
}

//help append and shift a single data
void appendAndShift(float[] data, float newData) {
    int nshift = 1;
    int end = data.length-nshift;
    for (int i=0; i < end; i++) {
        data[i]=data[i+nshift];  //shift data points down by 1
    }
    data[end] = newData;  //append new data
}

final float sine_freq_Hz = 10.0f;
float[] sine_phase_rad = new float[nchan];

void synthesizeData(int nchan, float fs_Hz, float scale_fac_uVolts_per_count, DataPacket_ADS1299 curDataPacket) {
    float val_uV;
    for (int Ichan=0; Ichan < nchan; Ichan++) {
        if (isChannelActive(Ichan)) {
            val_uV = randomGaussian()*sqrt(fs_Hz/2.0f); // ensures that it has amplitude of one unit per sqrt(Hz) of signal bandwidth
            if (Ichan==0) val_uV*= 10f;  //scale one channel higher

            if (Ichan==1) {
                //add sine wave at 10 Hz at 10 uVrms
                sine_phase_rad[Ichan] += 2.0f*PI * sine_freq_Hz / fs_Hz;
                if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                val_uV += 10.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);
            } else if (Ichan==2) {
                //15 Hz interference at 20 uVrms
                sine_phase_rad[Ichan] += 2.0f*PI * 15.0f / fs_Hz;  //15 Hz
                if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                val_uV += 20.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);    //20 uVrms
            } else if (Ichan==3) {
                //20 Hz interference at 30 uVrms
                sine_phase_rad[Ichan] += 2.0f*PI * 20.0f / fs_Hz;  //20 Hz
                if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                val_uV += 30.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //30 uVrms
            } else if (Ichan==4) {
                //25 Hz interference at 40 uVrms
                sine_phase_rad[Ichan] += 2.0f*PI * 25.0f / fs_Hz;  //25 Hz
                if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                val_uV += 40.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //40 uVrms
            } else if (Ichan==5) {
                //30 Hz interference at 50 uVrms
                sine_phase_rad[Ichan] += 2.0f*PI * 30.0f / fs_Hz;  //30 Hz
                if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                val_uV += 50.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //50 uVrms
            } else if (Ichan==6) {
                //50 Hz interference at 80 uVrms
                sine_phase_rad[Ichan] += 2.0f*PI * 50.0f / fs_Hz;  //50 Hz
                if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                val_uV += 120.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //80 uVrms
            } else if (Ichan==7) {
                //60 Hz interference at 100 uVrms
                sine_phase_rad[Ichan] += 2.0f*PI * 60.0f / fs_Hz;  //60 Hz
                if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
                val_uV += 20.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //20 uVrms
            }
        } else {
            val_uV = 0.0f;
        }
        curDataPacket.values[Ichan] = (int) (0.5f+ val_uV / scale_fac_uVolts_per_count); //convert to counts, the 0.5 is to ensure rounding
    }
}

//some data initialization routines
void prepareData(float[] dataBuffX, float[][] dataBuffY_uV, float fs_Hz) {
    //initialize the x and y data
    int xoffset = dataBuffX.length - 1;
    for (int i=0; i < dataBuffX.length; i++) {
        dataBuffX[i] = ((float)(i-xoffset)) / fs_Hz; //x data goes from minus time up to zero
        for (int Ichan = 0; Ichan < nchan; Ichan++) {
            dataBuffY_uV[Ichan][i] = 0f;  //make the y data all zeros
        }
    }
}

void initializeFFTObjects(FFT[] fftBuff, float[][] dataBuffY_uV, int Nfft, float fs_Hz) {

    float[] fooData;
    for (int Ichan=0; Ichan < nchan; Ichan++) {
        //make the FFT objects...Following "SoundSpectrum" example that came with the Minim library
        fftBuff[Ichan].window(FFT.HAMMING);

        //do the FFT on the initial data
        if (isFFTFiltered == true) {
            fooData = dataBuffY_filtY_uV[Ichan];  //use the filtered data for the FFT
        } else {
            fooData = dataBuffY_uV[Ichan];  //use the raw data for the FFT
        }
        fooData = Arrays.copyOfRange(fooData, fooData.length-Nfft, fooData.length);
        fftBuff[Ichan].forward(fooData); //compute FFT on this channel of data
    }
}


int getPlaybackDataFromTable(Table datatable, int currentTableRowIndex, float scale_fac_uVolts_per_count, float scale_fac_accel_G_per_count, DataPacket_ADS1299 curDataPacket) {
    float val_uV = 0.0f;
    float[] acc_G = new float[n_aux_ifEnabled];
    boolean acc_newData = false;

    //check to see if we can load a value from the table
    if (currentTableRowIndex >= datatable.getRowCount()) {
        //end of file
        println("OpenBCI_GUI: getPlaybackDataFromTable: End of playback data file.  Starting over...");
        hasRepeated = true;
        currentTableRowIndex = 0;
    } else {
        //get the row
        TableRow row = datatable.getRow(currentTableRowIndex);
        currentTableRowIndex++; //increment to the next row

        //get each value
        for (int Ichan=0; Ichan < nchan; Ichan++) {
            if (isChannelActive(Ichan) && (Ichan < datatable.getColumnCount())) {
                val_uV = row.getFloat(Ichan);
            } else {
                //use zeros for the missing channels
                val_uV = 0.0f;
            }

            //put into data structure
            curDataPacket.values[Ichan] = (int) (0.5f+ val_uV / scale_fac_uVolts_per_count); //convert to counts, the 0.5 is to ensure rounding
        }

        // get accelerometer data
        try{
            for (int Iacc=0; Iacc < n_aux_ifEnabled; Iacc++) {

                if (Iacc < datatable.getColumnCount()) {
                    acc_G[Iacc] = row.getFloat(Iacc + nchan);
                    if (Float.isNaN(acc_G[Iacc])) {
                        acc_G[Iacc] = 0.0f;
                    }
                } else {
                    //use zeros for bad data :)
                    acc_G[Iacc] = 0.0f;
                }

                //put into data structure
                curDataPacket.auxValues[Iacc] = (int) (0.5f+ acc_G[Iacc] / scale_fac_accel_G_per_count); //convert to counts, the 0.5 is to ensure rounding

                // Wangshu Dec.6 2016
                // as long as xyz are not zero at the same time, it should be fine...otherwise it will ignore it.
                if (acc_G[Iacc] > 0.000001) {
                    acc_newData = true;
                }
            }
        } catch (ArrayIndexOutOfBoundsException e){
        // println("Data does not exist... possibly an old file.");
        }
        if (acc_newData) {
            for (int Iacc=0; Iacc < n_aux_ifEnabled; Iacc++) {
                appendAndShift(accelerometerBuff[Iacc], acc_G[Iacc]);
            }
        }
        // if available, get time stamp for use in playback
        if (row.getColumnCount() >= nchan + NUM_ACCEL_DIMS + 2) {
            try{
                if (!isOldData) curTimestamp = row.getString(row.getColumnCount() - 1);
            } catch (ArrayIndexOutOfBoundsException e) {
                println("Data does not exist... possibly an old file.");
            }
        } else {
            curTimestamp = "-1";
        }
    } //end else
    return currentTableRowIndex;
}

//------------------------------------------------------------------------
//                          CLASSES
//------------------------------------------------------------------------

class DataProcessing {
    private float fs_Hz;  //sample rate
    private int nchan;
    final int N_FILT_CONFIGS = 5;
    FilterConstants[] filtCoeff_bp = new FilterConstants[N_FILT_CONFIGS];
    final int N_NOTCH_CONFIGS = 3;
    FilterConstants[] filtCoeff_notch = new FilterConstants[N_NOTCH_CONFIGS];
    private int currentFilt_ind = 3;
    private int currentNotch_ind = 0;  // set to 0 to default to 60Hz, set to 1 to default to 50Hz
    float data_std_uV[];
    float polarity[];
    boolean newDataToSend;
    final int[] processing_band_low_Hz = {
        1, 4, 8, 13, 30
    }; //lower bound for each frequency band of interest (2D classifier only)
    final int[] processing_band_high_Hz = {
        4, 8, 13, 30, 55
    };  //upper bound for each frequency band of interest
    float avgPowerInBins[][];
    float headWidePower[];

    DataProcessing(int NCHAN, float sample_rate_Hz) {
        nchan = NCHAN;
        fs_Hz = sample_rate_Hz;
        data_std_uV = new float[nchan];
        polarity = new float[nchan];
        newDataToSend = false;
        avgPowerInBins = new float[nchan][processing_band_low_Hz.length];
        headWidePower = new float[processing_band_low_Hz.length];

        defineFilters();  //define the filters anyway just so that the code doesn't bomb
    }

    //define filters depending on the sampling rate
    private void defineFilters() {
        int n_filt;
        double[] b, a, b2, a2;
        String filt_txt, filt_txt2;
        String short_txt, short_txt2;

        //------------ loop over all of the pre-defined filter types -----------
        //------------ notch filters ------------
        n_filt = filtCoeff_notch.length;
        for (int Ifilt=0; Ifilt < n_filt; Ifilt++) {
            switch (Ifilt) {
                case 0:
                    //60 Hz notch filter, 2nd Order Butterworth: [b, a] = butter(2,[59.0 61.0]/(fs_Hz / 2.0), 'stop') %matlab command
                    switch(int(fs_Hz)) {
                        case 125:
                            b2 = new double[] { 0.931378858122982, 3.70081291785747, 5.53903191270520, 3.70081291785747, 0.931378858122982 };
                            a2 = new double[] { 1, 3.83246204081167, 5.53431749515949, 3.56916379490328, 0.867472133791669 };
                            break;
                        case 200:
                            b2 = new double[] { 0.956543225556877, 1.18293615779028, 2.27881429174348, 1.18293615779028, 0.956543225556877 };
                            a2 = new double[] { 1, 1.20922304075909, 2.27692490805580, 1.15664927482146, 0.914975834801436 };
                            break;
                        case 250:
                            b2 = new double[] { 0.965080986344733, -0.242468320175764, 1.94539149412878, -0.242468320175764, 0.965080986344733 };
                            a2 = new double[] { 1, -0.246778261129785, 1.94417178469135, -0.238158379221743, 0.931381682126902 };
                            break;
                        case 500:
                            b2 = new double[] { 0.982385438526095, -2.86473884662109, 4.05324051877773, -2.86473884662109, 0.982385438526095};
                            a2 = new double[] { 1, -2.89019558531207, 4.05293022193077, -2.83928210793009, 0.965081173899134 };
                            break;
                        case 1000:
                            b2 = new double[] { 0.991153595101611, -3.68627799048791, 5.40978944177152, -3.68627799048791, 0.991153595101611 };
                            a2 = new double[] { 1, -3.70265590760266, 5.40971118136100, -3.66990007337352, 0.982385450614122 };
                            break;
                        case 1600:
                            b2 = new double[] { 0.994461788958027, -3.86796874670208, 5.75004904085114, -3.86796874670208, 0.994461788958027 };
                            a2 = new double[] { 1, -3.87870938463296, 5.75001836883538, -3.85722810877252, 0.988954249933128 };
                            break;
                        default:
                            println("EEG_Processing: *** ERROR *** Filters can only work at 125Hz, 200Hz, 250 Hz, 1000Hz or 1600Hz");
                            b2 = new double[] { 1.0 };
                            a2 = new double[] { 1.0 };
                    }
                    filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "Notch 60Hz", "60Hz");
                    break;
                case 1:
                    //50 Hz notch filter, 2nd Order Butterworth: [b, a] = butter(2,[49.0 51.0]/(fs_Hz / 2.0), 'stop')
                    switch(int(fs_Hz)) {
                        case 125:
                            b2 = new double[] { 0.931378858122983, 3.01781693143160, 4.30731047590091, 3.01781693143160, 0.931378858122983 };
                            a2 = new double[] { 1, 3.12516981877757, 4.30259605835520, 2.91046404408562, 0.867472133791670 };
                            break;
                        case 200:
                            b2 = new double[] { 0.956543225556877, -2.34285519884863e-16, 1.91308645111375, -2.34285519884863e-16, 0.956543225556877 };
                            a2 = new double[] { 1, -1.41553435639707e-15, 1.91119706742607, -1.36696209906972e-15, 0.914975834801435 };
                            break;
                        case 250:
                            b2 = new double[] { 0.965080986344734, -1.19328255433335, 2.29902305135123, -1.19328255433335, 0.965080986344734 };
                            a2 = new double[] { 1, -1.21449347931898, 2.29780334191380, -1.17207162934771, 0.931381682126901 };
                            break;
                        case 500:
                            b2 = new double[] { 0.982385438526090, -3.17931708468811, 4.53709552901242, -3.17931708468811, 0.982385438526090 };
                            a2 = new double[] { 1, -3.20756923909868, 4.53678523216547, -3.15106493027754, 0.965081173899133 };
                            break;
                        case 1000:
                            b2 = new double[] { 0.991153595101607, -3.77064677042206, 5.56847615976560, -3.77064677042206, 0.991153595101607 };
                            a2 = new double[] { 1, -3.78739953308251, 5.56839789935513, -3.75389400776205, 0.982385450614127 };
                            break;
                        case 1600:
                            b2 = new double[] { 0.994461788958316, -3.90144402068168, 5.81543195046478, -3.90144402068168, 0.994461788958316 };
                            a2 = new double[] { 1, -3.91227761329151, 5.81540127844733, -3.89061042807090, 0.988954249933127 };
                            break;
                        default:
                            println("EEG_Processing: *** ERROR *** Filters can only work at 125Hz, 200Hz, 250 Hz, 1000Hz or 1600Hz");
                            b2 = new double[] { 1.0 };
                            a2 = new double[] { 1.0 };
                    }
                    filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "Notch 50Hz", "50Hz");
                    break;
                case 2:
                    //no notch filter
                    b2 = new double[] { 1.0 };
                    a2 = new double[] { 1.0 };
                    filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "No Notch", "None");
                    break;
                }
            }// end loop over notch filters

            //------------ bandpass filters ------------
            n_filt = filtCoeff_bp.length;
            for (int Ifilt=0; Ifilt<n_filt; Ifilt++) {
                //define bandpass filter
                switch (Ifilt) {
                case 0:
                    //1-50 Hz band pass filter, 2nd Order Butterworth: [b, a] = butter(2,[1.0 50.0]/(fs_Hz / 2.0))
                    switch(int(fs_Hz)) {
                        case 125:
                            b = new double[] { 0.615877232553135, 0, -1.23175446510627, 0, 0.615877232553135 };
                            a = new double[] { 1, -0.789307541613509, -0.853263915766877, 0.263710995896442, 0.385190413112446 };
                            break;
                        case 200:
                            b = new double[] { 0.283751216219319, 0, -0.567502432438638, 0, 0.283751216219319 };
                            a = new double[] { 1, -1.97380379923172, 1.17181238127012, -0.368664525962831, 0.171812381270120 };
                            break;
                        case 250:
                            b = new double[] { 0.200138725658073, 0, -0.400277451316145, 0, 0.200138725658073 };
                            a = new double[] { 1, -2.35593463113158, 1.94125708865521, -0.784706375533419, 0.199907605296834 };
                            break;
                        case 500:
                            b = new double[] { 0.0652016551604422, 0, -0.130403310320884, 0, 0.0652016551604422 };
                            a = new double[] { 1, -3.14636562553919, 3.71754597063790, -1.99118301927812, 0.420045500522989 };
                            break;
                        case 1000:
                            b = new double[] { 0.0193615659240911, 0, -0.0387231318481823, 0, 0.0193615659240911 };
                            a = new double[] { 1, -3.56607203834158, 4.77991824545949, -2.86091191298975, 0.647068888346475 };
                            break;
                        case 1600:
                            b = new double[] { 0.00812885687466408, 0, -0.0162577137493282, 0, 0.00812885687466408 };
                            a = new double[] { 1, -3.72780746887970, 5.21756471024747, -3.25152171857009, 0.761764999239264 };
                            break;
                        default:
                            println("EEG_Processing: *** ERROR *** Filters can only work at 125Hz, 200Hz, 250 Hz, 1000Hz or 1600Hz");
                            b = new double[] { 1.0 };
                            a = new double[] { 1.0 };
                    }
                    filt_txt = "Bandpass 1-50Hz";
                    short_txt = "1-50 Hz";
                    break;
                case 1:
                    //7-13 Hz band pass filter, 2nd Order Butterworth: [b, a] = butter(2,[7.0 13.0]/(fs_Hz / 2.0))
                    switch(int(fs_Hz)) {
                        case 125:
                            b = new double[] { 0.0186503962278349, 0, -0.0373007924556699, 0, 0.0186503962278349 };
                            a = new double[] { 1, -3.17162467236842, 4.11670870329067, -2.55619949640702, 0.652837763407545 };
                            break;
                        case 200:
                            b = new double[] { 0.00782020803349772, 0, -0.0156404160669954, 0, 0.00782020803349772 };
                            a = new double[] { 1, -3.56776916484310, 4.92946172209398, -3.12070317627516, 0.766006600943265 };
                            break;
                        case 250:
                            b = new double[] { 0.00512926836610803, 0, -0.0102585367322161, 0, 0.00512926836610803 };
                            a = new double[] { 1, -3.67889546976404, 5.17970041352212, -3.30580189001670, 0.807949591420914 };
                            break;
                        case 500:
                            b = new double[] { 0.00134871194834618, 0, -0.00269742389669237, 0, 0.00134871194834618 };
                            a = new double[] { 1, -3.86550956895320, 5.63152598761351, -3.66467991638185, 0.898858994155253 };
                            break;
                        case 1000:
                            b = new double[] { 0.000346041337684191, 0, -0.000692082675368382, 0, 0.000346041337684191 };
                            a = new double[] { 1, -3.93960949694447, 5.82749974685320, -3.83595939375067, 0.948081706106736 };
                            break;
                        case 1600:
                            b = new double[] { 0.000136510722194708, 0, -0.000273021444389417, 0, 0.000136510722194708 };
                            a = new double[] { 1, -3.96389829181139, 5.89507193593518, -3.89839913574117, 0.967227428151860 };
                            break;
                        default:
                            println("EEG_Processing: *** ERROR *** Filters can only work at 125Hz, 200Hz, 250 Hz, 1000Hz or 1600Hz");
                            b = new double[] { 1.0 };
                            a = new double[] { 1.0 };
                    }
                    filt_txt = "Bandpass 7-13Hz";
                    short_txt = "7-13 Hz";
                    break;
                case 2:
                    //15-50 Hz band pass filter, 2nd Order Butterworth: [b, a] = butter(2,[15.0 50.0]/(fs_Hz / 2.0))
                    switch(int(fs_Hz)) {
                        case 125:
                            b = new double[] { 0.350346377855414, 0, -0.700692755710828, 0, 0.350346377855414 };
                            a = new double[] { 1, 0.175228265043619, -0.211846955102387, 0.0137230352398757, 0.180232073898346 };
                            break;
                        case 200:
                            b = new double[] { 0.167483800127017, 0, -0.334967600254034, 0, 0.167483800127017 };
                            a = new double[] { 1, -1.56695061045088, 1.22696619781982, -0.619519163981229, 0.226966197819818 };
                            break;
                        case 250:
                            b = new double[] { 0.117351036724609, 0, -0.234702073449219, 0, 0.117351036724609 };
                            a = new double[] { 1, -2.13743018017206, 2.03857800810852, -1.07014439920093, 0.294636527587914 };
                            break;
                        case 500:
                            b = new double[] { 0.0365748358439273, 0, -0.0731496716878546, 0, 0.0365748358439273 };
                            a = new double[] { 1, -3.18880661866679, 3.98037203788323, -2.31835989524663, 0.537194624801103 };
                            break;
                        case 1000:
                            b = new double[] { 0.0104324133710872, 0, -0.0208648267421744, 0, 0.0104324133710872 };
                            a = new double[] { 1, -3.63626742713985, 5.01393973667604, -3.10964559897057, 0.732726030371817 };
                            break;
                        case 1600:
                            b = new double[] { 0.00429884732196394, 0, -0.00859769464392787, 0, 0.00429884732196394 };
                            a = new double[] { 1, -3.78412985599134, 5.39377521548486, -3.43287342581222, 0.823349595537562 };
                            break;
                        default:
                            println("EEG_Processing: *** ERROR *** Filters can only work at 125Hz, 200Hz, 250 Hz, 1000Hz or 1600Hz");
                            b = new double[] { 1.0 };
                            a = new double[] { 1.0 };
                    }
                    filt_txt = "Bandpass 15-50Hz";
                    short_txt = "15-50 Hz";
                    break;
                case 3:
                    //5-50 Hz band pass filter, 2nd Order Butterworth: [b, a] = butter(2,[5.0 50.0]/(fs_Hz / 2.0))
                    switch(int(fs_Hz)) {
                        case 125:
                            b = new double[] { 0.529967227069348, 0, -1.05993445413870, 0, 0.529967227069348 };
                            a = new double[] { 1, -0.517003774490767, -0.734318454224823, 0.103843398397761, 0.294636527587914 };
                            break;
                        case 200:
                            b = new double[] { 0.248341078962541, 0, -0.496682157925081, 0, 0.248341078962541 };
                            a = new double[] { 1, -1.86549482213123, 1.17757811892770, -0.460665534278457, 0.177578118927698 };
                            break;
                        case 250:
                            b = new double[] { 0.175087643672101, 0, -0.350175287344202, 0, 0.175087643672101 };
                            a = new double[] { 1, -2.29905535603850, 1.96749775998445, -0.874805556449481, 0.219653983913695 };
                            break;
                        case 500:
                            b = new double[] { 0.0564484622607352, 0, -0.112896924521470, 0, 0.0564484622607352 };
                            a = new double[] { 1, -3.15946330211917, 3.79268442285094, -2.08257331718360, 0.450445430056042 };
                            break;
                        case 1000:
                            b = new double[] { 0.0165819316692804, 0, -0.0331638633385608, 0, 0.0165819316692804 };
                            a = new double[] { 1, -3.58623980811691, 4.84628980428803, -2.93042721682014, 0.670457905953175 };
                            break;
                        case 1600:
                            b = new double[] { 0.00692579317243661, 0, -0.0138515863448732, 0, 0.00692579317243661 };
                            a = new double[] { 1, -3.74392328264678, 5.26758817627966, -3.30252568902969, 0.778873972655117 };
                            break;
                        default:
                            println("EEG_Processing: *** ERROR *** Filters can only work at 125Hz, 200Hz, 250 Hz, 1000Hz or 1600Hz");
                            b = new double[] { 1.0 };
                            a = new double[] { 1.0 };
                    }
                    filt_txt = "Bandpass 5-50Hz";
                    short_txt = "5-50 Hz";
                    break;
                default:
                    //no filtering
                    b = new double[] { 1.0 };
                    a = new double[] { 1.0 };
                    filt_txt = "No BP Filter";
                    short_txt = "No Filter";
                }  //end switch block

                //create the bandpass filter
                filtCoeff_bp[Ifilt] =  new FilterConstants(b, a, filt_txt, short_txt);
        } //end loop over band pass filters
    }
    //end defineFilters method

    public String getFilterDescription() {
        return filtCoeff_bp[currentFilt_ind].name + ", " + filtCoeff_notch[currentNotch_ind].name;
    }
    public String getShortFilterDescription() {
        return filtCoeff_bp[currentFilt_ind].short_name;
    }
    public String getShortNotchDescription() {
        return filtCoeff_notch[currentNotch_ind].short_name;
    }

    public void incrementFilterConfiguration() {
        //increment the index
        currentFilt_ind++;
        if (currentFilt_ind >= N_FILT_CONFIGS) currentFilt_ind = 0;
        settings.dataProcessingBandpassSave = currentFilt_ind;//store the value to save bandpass setting
    }

    public void incrementNotchConfiguration() {
        //increment the index
        currentNotch_ind++;
        if (currentNotch_ind >= N_NOTCH_CONFIGS) currentNotch_ind = 0;
        settings.dataProcessingNotchSave = currentNotch_ind;
    }

    public void process(float[][] data_newest_uV, //holds raw EEG data that is new since the last call
        float[][] data_long_uV, //holds a longer piece of buffered EEG data, of same length as will be plotted on the screen
        float[][] data_forDisplay_uV, //put data here that should be plotted on the screen
        FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data
        int Nfft = getNfftSafe();
        //loop over each EEG channel
        for (int Ichan=0; Ichan < nchan; Ichan++) {

            //filter the data in the time domain
            filterIIR(filtCoeff_notch[currentNotch_ind].b, filtCoeff_notch[currentNotch_ind].a, data_forDisplay_uV[Ichan]); //notch
            filterIIR(filtCoeff_bp[currentFilt_ind].b, filtCoeff_bp[currentFilt_ind].a, data_forDisplay_uV[Ichan]); //bandpass

            //compute the standard deviation of the filtered signal...this is for the head plot
            float[] fooData_filt = dataBuffY_filtY_uV[Ichan];  //use the filtered data
            fooData_filt = Arrays.copyOfRange(fooData_filt, fooData_filt.length-((int)fs_Hz), fooData_filt.length);   //just grab the most recent second of data
            data_std_uV[Ichan]=std(fooData_filt); //compute the standard deviation for the whole array "fooData_filt"
        } //close loop over channels


        // calculate FFT after filter

        //println("PPP" + fftBuff[0].specSize());
        float prevFFTdata[] = new float[fftBuff[0].specSize()];
        double foo;

        //update the FFT (frequency spectrum)
        // println("nchan = " + nchan);
        for (int Ichan=0; Ichan < nchan; Ichan++) {

            //copy the previous FFT data...enables us to apply some smoothing to the FFT data
            for (int I=0; I < fftBuff[Ichan].specSize(); I++) {
                prevFFTdata[I] = fftBuff[Ichan].getBand(I); //copy the old spectrum values
            }

            //prepare the data for the new FFT
            float[] fooData;
            if (isFFTFiltered == true) {
                fooData = dataBuffY_filtY_uV[Ichan];  //use the filtered data for the FFT
            } else {
                fooData = dataBuffY_uV[Ichan];  //use the raw data for the FFT
            }
            fooData = Arrays.copyOfRange(fooData, fooData.length-Nfft, fooData.length);   //trim to grab just the most recent block of data
            float meanData = mean(fooData);  //compute the mean
            for (int I=0; I < fooData.length; I++) fooData[I] -= meanData; //remove the mean (for a better looking FFT

            //compute the FFT
            fftBuff[Ichan].forward(fooData); //compute FFT on this channel of data

            //convert to uV_per_bin...still need to confirm the accuracy of this code.
            //Do we need to account for the power lost in the windowing function?   CHIP  2014-10-24

            // FFT ref: https://www.mathworks.com/help/matlab/ref/fft.html
            // first calculate double-sided FFT amplitude spectrum
            for (int I=0; I <= Nfft/2; I++) {
                fftBuff[Ichan].setBand(I, (float)(fftBuff[Ichan].getBand(I) / Nfft));
            }
            // then convert into single-sided FFT spectrum: DC & Nyquist (i=0 & i=N/2) remain the same, others multiply by two.
            for (int I=1; I < Nfft/2; I++) {
                fftBuff[Ichan].setBand(I, (float)(fftBuff[Ichan].getBand(I) * 2));
            }

            //average the FFT with previous FFT data so that it makes it smoother in time
            double min_val = 0.01d;
            for (int I=0; I < fftBuff[Ichan].specSize(); I++) {   //loop over each fft bin
                if (prevFFTdata[I] < min_val) prevFFTdata[I] = (float)min_val; //make sure we're not too small for the log calls
                foo = fftBuff[Ichan].getBand(I);
                if (foo < min_val) foo = min_val; //make sure this value isn't too small

                if (true) {
                    //smooth in dB power space
                    foo =   (1.0d-smoothFac[smoothFac_ind]) * java.lang.Math.log(java.lang.Math.pow(foo, 2));
                    foo += smoothFac[smoothFac_ind] * java.lang.Math.log(java.lang.Math.pow((double)prevFFTdata[I], 2));
                    foo = java.lang.Math.sqrt(java.lang.Math.exp(foo)); //average in dB space
                } else {
                    //smooth (average) in linear power space
                    foo =   (1.0d-smoothFac[smoothFac_ind]) * java.lang.Math.pow(foo, 2);
                    foo+= smoothFac[smoothFac_ind] * java.lang.Math.pow((double)prevFFTdata[I], 2);
                    // take sqrt to be back into uV_rtHz
                    foo = java.lang.Math.sqrt(foo);
                }
                fftBuff[Ichan].setBand(I, (float)foo); //put the smoothed data back into the fftBuff data holder for use by everyone else
                // fftBuff[Ichan].setBand(I, 1.0f);  // test
            } //end loop over FFT bins

            // calculate single-sided psd by single-sided FFT amplitude spectrum
            // PSD ref: https://www.mathworks.com/help/dsp/ug/estimate-the-power-spectral-density-in-matlab.html
            // when i = 1 ~ (N/2-1), psd = (N / fs) * mag(i)^2 / 4
            // when i = 0 or i = N/2, psd = (N / fs) * mag(i)^2

            for (int i = 0; i < processing_band_low_Hz.length; i++) {
                float sum = 0;
                // int binNum = 0;
                for (int Ibin = 0; Ibin <= Nfft/2; Ibin ++) { // loop over FFT bins
                    float FFT_freq_Hz = fftBuff[Ichan].indexToFreq(Ibin);   // center frequency of this bin
                    float psdx = 0;
                    // if the frequency matches a band
                    if (FFT_freq_Hz >= processing_band_low_Hz[i] && FFT_freq_Hz < processing_band_high_Hz[i]) {
                        if (Ibin != 0 && Ibin != Nfft/2) {
                            psdx = fftBuff[Ichan].getBand(Ibin) * fftBuff[Ichan].getBand(Ibin) * Nfft/getSampleRateSafe() / 4;
                        }
                        else {
                            psdx = fftBuff[Ichan].getBand(Ibin) * fftBuff[Ichan].getBand(Ibin) * Nfft/getSampleRateSafe();
                        }
                        sum += psdx;
                        // binNum ++;
                    }
                }
                avgPowerInBins[Ichan][i] = sum;   // total power in a band
                // println(i, binNum, sum);
            }
        } //end the loop over channels.
        for (int i = 0; i < processing_band_low_Hz.length; i++) {
            float sum = 0;

            for (int j = 0; j < nchan; j++) {
                sum += avgPowerInBins[j][i];
            }
            headWidePower[i] = sum/nchan;   // averaging power over all channels
        }

        //delta in channel 2 ... avgPowerInBins[1][DELTA];
        //headwide beta ... headWidePower[BETA];

        //find strongest channel
        int refChanInd = findMax(data_std_uV);
        //println("EEG_Processing: strongest chan (one referenced) = " + (refChanInd+1));
        float[] refData_uV = dataBuffY_filtY_uV[refChanInd];  //use the filtered data
        refData_uV = Arrays.copyOfRange(refData_uV, refData_uV.length-((int)fs_Hz), refData_uV.length);   //just grab the most recent second of data


        //compute polarity of each channel
        for (int Ichan=0; Ichan < nchan; Ichan++) {
            float[] fooData_filt = dataBuffY_filtY_uV[Ichan];  //use the filtered data
            fooData_filt = Arrays.copyOfRange(fooData_filt, fooData_filt.length-((int)fs_Hz), fooData_filt.length);   //just grab the most recent second of data
            float dotProd = calcDotProduct(fooData_filt, refData_uV);
            if (dotProd >= 0.0f) {
                polarity[Ichan]=1.0;
            } else {
                polarity[Ichan]=-1.0;
            }
        }
    }
}