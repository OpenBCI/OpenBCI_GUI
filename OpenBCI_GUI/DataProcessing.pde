
//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------
import ddf.minim.analysis.*; //for FFT

DataProcessing dataProcessing;
String curTimestamp;
boolean hasRepeated = false;
HashMap<String,float[][]> processed_file;
HashMap<Integer,String> index_of_times;
HashMap<String,Integer> index_of_times_rev;



//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//called from systemUpdate when mode=10 and isRunning = true
void process_input_file() throws Exception {
  processed_file = new HashMap<String, float[][]>();
  index_of_times = new HashMap<Integer, String>();
  index_of_times_rev = new HashMap<String, Integer>();
  float localLittleBuff[][] = new float[nchan][nPointsPerUpdate];

  try {
    while (!hasRepeated) {
      currentTableRowIndex=getPlaybackDataFromTable(playbackData_table, currentTableRowIndex, openBCI.get_scale_fac_uVolts_per_count(), openBCI.get_scale_fac_accel_G_per_count(), dataPacketBuff[lastReadDataPacketInd]);

      for (int Ichan=0; Ichan < nchan; Ichan++) {
        //scale the data into engineering units..."microvolts"
        localLittleBuff[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan]* openBCI.get_scale_fac_uVolts_per_count();
      }
      processed_file.put(curTimestamp, localLittleBuff);
      index_of_times.put(indices,curTimestamp);
      index_of_times_rev.put(curTimestamp,indices);
      indices++;
    }
  }
  catch (Exception e) {
    throw new Exception();
  }

  println("Finished filling hashmap");
  has_processed = true;
}


/*************************/
int getDataIfAvailable(int pointCounter) {

  if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
    //get data from serial port as it streams in
    //next, gather any new data into the "little buffer"
    while ( (curDataPacketInd != lastReadDataPacketInd) && (pointCounter < nPointsPerUpdate)) {
      lastReadDataPacketInd = (lastReadDataPacketInd+1) % dataPacketBuff.length;  //increment to read the next packet
      for (int Ichan=0; Ichan < nchan; Ichan++) {   //loop over each cahnnel
        //scale the data into engineering units ("microvolts") and save to the "little buffer"
        yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan] * openBCI.get_scale_fac_uVolts_per_count();
      }
      for (int auxChan=0; auxChan < 3; auxChan++) auxBuff[auxChan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].auxValues[auxChan];
      pointCounter++; //increment counter for "little buffer"
    }
  } else if (eegDataSource == DATASOURCE_GANGLION) {
    //get data from ble as it streams in
    //next, gather any new data into the "little buffer"
    while ( (curDataPacketInd != lastReadDataPacketInd) && (pointCounter < nPointsPerUpdate)) {
      lastReadDataPacketInd = (lastReadDataPacketInd + 1) % dataPacketBuff.length;  //increment to read the next packet
      for (int Ichan=0; Ichan < nchan; Ichan++) {   //loop over each cahnnel
        //scale the data into engineering units ("microvolts") and save to the "little buffer"
        yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan] * ganglion.get_scale_fac_uVolts_per_count();
      }
      pointCounter++; //increment counter for "little buffer"
    }

  } else {
    // make or load data to simulate real time

    //has enough time passed?
    int current_millis = millis();
    if (current_millis >= nextPlayback_millis) {
      //prepare for next time
      int increment_millis = int(round(float(nPointsPerUpdate)*1000.f/get_fs_Hz_safe())/playback_speed_fac);
      if (nextPlayback_millis < 0) nextPlayback_millis = current_millis;
      nextPlayback_millis += increment_millis;

      // generate or read the data
      lastReadDataPacketInd = 0;
      for (int i = 0; i < nPointsPerUpdate; i++) {
        // println();
        dataPacketBuff[lastReadDataPacketInd].sampleIndex++;
        switch (eegDataSource) {
        case DATASOURCE_SYNTHETIC: //use synthetic data (for GUI debugging)
          synthesizeData(nchan, get_fs_Hz_safe(), openBCI.get_scale_fac_uVolts_per_count(), dataPacketBuff[lastReadDataPacketInd]);
          break;
        case DATASOURCE_PLAYBACKFILE:
          currentTableRowIndex=getPlaybackDataFromTable(playbackData_table, currentTableRowIndex, openBCI.get_scale_fac_uVolts_per_count(), openBCI.get_scale_fac_accel_G_per_count(), dataPacketBuff[lastReadDataPacketInd]);
          break;
        default:
          //no action
        }
        //gather the data into the "little buffer"
        for (int Ichan=0; Ichan < nchan; Ichan++) {
          //scale the data into engineering units..."microvolts"
          yLittleBuff_uV[Ichan][pointCounter] = dataPacketBuff[lastReadDataPacketInd].values[Ichan]* openBCI.get_scale_fac_uVolts_per_count();
        }

        pointCounter++;
      } //close the loop over data points
      //if (eegDataSource==DATASOURCE_PLAYBACKFILE) println("OpenBCI_GUI: getDataIfAvailable: currentTableRowIndex = " + currentTableRowIndex);
      //println("OpenBCI_GUI: getDataIfAvailable: pointCounter = " + pointCounter);
    } // close "has enough time passed"
    else{
    }
  }
  return pointCounter;
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

  ////prepare to update the data buffers
  //float foo_val;

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

  //apply user processing
  // ...yLittleBuff_uV[Ichan] is the most recent raw data since the last call to this processing routine
  // ...dataBuffY_filtY_uV[Ichan] is the full set of filtered data as shown in the time-domain plot in the GUI
  // ...fftBuff[Ichan] is the FFT data structure holding the frequency spectrum as shown in the freq-domain plot in the GUI
  // w_emg.process(yLittleBuff_uV, dataBuffY_uV, dataBuffY_filtY_uV, fftBuff); //%%%
  // w_openbionics.process();

  dataProcessing_user.process(yLittleBuff_uV, dataBuffY_uV, dataBuffY_filtY_uV, fftBuff);
  dataProcessing.newDataToSend = true;

  //look to see if the latest data is railed so that we can notify the user on the GUI
  for (int Ichan=0; Ichan < nchan; Ichan++) is_railed[Ichan].update(dataPacketBuff[lastReadDataPacketInd].values[Ichan]);

  //compute the electrode impedance. Do it in a very simple way [rms to amplitude, then uVolt to Volt, then Volt/Amp to Ohm]
  for (int Ichan=0; Ichan < nchan; Ichan++) {
    // Calculate the impedance
    float impedance = (sqrt(2.0)*dataProcessing.data_std_uV[Ichan]*1.0e-6) / openBCI.get_leadOffDrive_amps();
    // Subtract the 2.2kOhm resistor
    impedance -= openBCI.get_series_resistor();
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
      //val_uV = random(1)*sqrt(fs_Hz/2.0f); // ensures that it has amplitude of one unit per sqrt(Hz) of signal bandwidth
      if (Ichan==0) val_uV*= 10f;  //scale one channel higher

      if (Ichan==1) {
        //add sine wave at 10 Hz at 10 uVrms
        sine_phase_rad[Ichan] += 2.0f*PI * sine_freq_Hz / fs_Hz;
        if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
        val_uV += 10.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);
      } else if (Ichan==2) {
        //50 Hz interference at 50 uVrms
        sine_phase_rad[Ichan] += 2.0f*PI * 50.0f / fs_Hz;  //60 Hz
        if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
        val_uV += 50.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);    //20 uVrms
      } else if (Ichan==3) {
        //60 Hz interference at 50 uVrms
        sine_phase_rad[Ichan] += 2.0f*PI * 60.0f / fs_Hz;  //50 Hz
        if (sine_phase_rad[Ichan] > 2.0f*PI) sine_phase_rad[Ichan] -= 2.0f*PI;
        val_uV += 50.0f * sqrt(2.0)*sin(sine_phase_rad[Ichan]);  //20 uVrms
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


void initializeFFTObjects(FFT[] fftBuff, float[][] dataBuffY_uV, int N, float fs_Hz) {

  float[] fooData;
  for (int Ichan=0; Ichan < nchan; Ichan++) {
    //make the FFT objects...Following "SoundSpectrum" example that came with the Minim library
    //fftBuff[Ichan] = new FFT(Nfft, fs_Hz);  //I can't have this here...it must be in setup
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
    println("OpenBCI_GUI: getPlaybackDataFromTable: hit the end of the playback data file.  starting over...");
    hasRepeated = true;
    //if (isRunning) stopRunning();
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
        } else {
          //use zeros for bad data :)
          acc_G[Iacc] = 0.0f;
        }

        //put into data structure
        curDataPacket.auxValues[Iacc] = (int) (0.5f+ acc_G[Iacc] / scale_fac_accel_G_per_count); //convert to counts, the 0.5 is to ensure rounding

        // Wangshu Dec.6 2016
        // as long as xyz are not zero at the same time, it should be fine...otherwise it will ignore it.
        if (acc_G[Iacc]!= 0) {
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

    // get time stamp
    if (!isOldData) curTimestamp = row.getString(nchan+3);

    //int localnchan = nchan;

    if(!isRunning){
      try{
        if(!isOldData) row.getString(nchan+4);
        else row.getString(nchan+3);

        nchan = 16;
      }
      catch (ArrayIndexOutOfBoundsException e){ println("8 Channel");}
    }

  }
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
  private String[] binNames;
  final int[] processing_band_low_Hz = {
    1, 4, 8, 13, 30
  }; //lower bound for each frequency band of interest (2D classifier only)
  final int[] processing_band_high_Hz = {
    4, 8, 13, 30, 55
  };  //upper bound for each frequency band of interest
  float avgPowerInBins[][];
  float headWidePower[];
  int numBins;

  // indexs
  final int DELTA = 0; // 1-4 Hz
  final int THETA = 1; // 4-8 Hz
  final int ALPHA = 2; // 8-13 Hz
  final int BETA = 3; // 13-30 Hz
  final int GAMMA = 4; // 30-55 Hz

  DataProcessing(int NCHAN, float sample_rate_Hz) {
    nchan = NCHAN;
    fs_Hz = sample_rate_Hz;
    data_std_uV = new float[nchan];
    polarity = new float[nchan];
    newDataToSend = false;
    avgPowerInBins = new float[nchan][processing_band_low_Hz.length];
    headWidePower = new float[processing_band_low_Hz.length];

    //check to make sure the sample rate is acceptable and then define the filters
    if (abs(fs_Hz-250.0f) < 1.0) {
      defineFilters(0);
    } else if (abs(fs_Hz-200.0f) < 1.0) {
      defineFilters(1);
    } else {
      println("EEG_Processing: *** ERROR *** Filters can currently only work at 250 Hz or 200 Hz");
      defineFilters(0);  //define the filters anyway just so that the code doesn't bomb
    }
  }

  public float getSampleRateHz() {
    return fs_Hz;
  };

  //define filters...assumes sample rate of 250 Hz !!!!!
  private void defineFilters(int _mode) {
    int mode = _mode; // 0 means classic OpenBCI board, 1 means ganglion
    int n_filt;
    double[] b, a, b2, a2;
    String filt_txt, filt_txt2;
    String short_txt, short_txt2;

    switch(mode) {
      // classic OpenBCI board, sampling rate 250 Hz
    case 0:
      //loop over all of the pre-defined filter types
      n_filt = filtCoeff_notch.length;
      for (int Ifilt=0; Ifilt < n_filt; Ifilt++) {
        switch (Ifilt) {
        case 0:
          //60 Hz notch filter, assumed fs = 250 Hz.  2nd Order Butterworth: b, a = signal.butter(2,[59.0 61.0]/(fs_Hz / 2.0), 'bandstop')
          b2 = new double[] { 9.650809863447347e-001, -2.424683201757643e-001, 1.945391494128786e+000, -2.424683201757643e-001, 9.650809863447347e-001 };
          a2 = new double[] { 1.000000000000000e+000, -2.467782611297853e-001, 1.944171784691352e+000, -2.381583792217435e-001, 9.313816821269039e-001  };
          filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "Notch 60Hz", "60Hz");
          break;
        case 1:
          //50 Hz notch filter, assumed fs = 250 Hz.  2nd Order Butterworth: b, a = signal.butter(2,[49.0 51.0]/(fs_Hz / 2.0), 'bandstop')
          b2 = new double[] { 0.96508099, -1.19328255, 2.29902305, -1.19328255, 0.96508099 };
          a2 = new double[] { 1.0, -1.21449348, 2.29780334, -1.17207163, 0.93138168 };
          filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "Notch 50Hz", "50Hz");
          break;
        case 2:
          //no notch filter
          b2 = new double[] { 1.0 };
          a2 = new double[] { 1.0 };
          filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "No Notch", "None");
          break;
        }
      } // end loop over notch filters

      n_filt = filtCoeff_bp.length;
      for (int Ifilt=0; Ifilt<n_filt; Ifilt++) {
        //define bandpass filter
        switch (Ifilt) {
        case 0:
          //butter(2,[1 50]/(250/2));  %bandpass filter
          b = new double[] {
            2.001387256580675e-001, 0.0f, -4.002774513161350e-001, 0.0f, 2.001387256580675e-001
          };
          a = new double[] {
            1.0f, -2.355934631131582e+000, 1.941257088655214e+000, -7.847063755334187e-001, 1.999076052968340e-001
          };
          filt_txt = "Bandpass 1-50Hz";
          short_txt = "1-50 Hz";
          break;
        case 1:
          //butter(2,[7 13]/(250/2));
          b = new double[] {
            5.129268366104263e-003, 0.0f, -1.025853673220853e-002, 0.0f, 5.129268366104263e-003
          };
          a = new double[] {
            1.0f, -3.678895469764040e+000, 5.179700413522124e+000, -3.305801890016702e+000, 8.079495914209149e-001
          };
          filt_txt = "Bandpass 7-13Hz";
          short_txt = "7-13 Hz";
          break;
        case 2:
          //[b,a]=butter(2,[15 50]/(250/2)); %matlab command
          b = new double[] {
            1.173510367246093e-001, 0.0f, -2.347020734492186e-001, 0.0f, 1.173510367246093e-001
          };
          a = new double[] {
            1.0f, -2.137430180172061e+000, 2.038578008108517e+000, -1.070144399200925e+000, 2.946365275879138e-001
          };
          filt_txt = "Bandpass 15-50Hz";
          short_txt = "15-50 Hz";
          break;
        case 3:
          //[b,a]=butter(2,[5 50]/(250/2)); %matlab command
          b = new double[] {
            1.750876436721012e-001, 0.0f, -3.501752873442023e-001, 0.0f, 1.750876436721012e-001
          };
          a = new double[] {
            1.0f, -2.299055356038497e+000, 1.967497759984450e+000, -8.748055564494800e-001, 2.196539839136946e-001
          };
          filt_txt = "Bandpass 5-50Hz";
          short_txt = "5-50 Hz";
          break;
        default:
          //no filtering
          b = new double[] {
            1.0
          };
          a = new double[] {
            1.0
          };
          filt_txt = "No BP Filter";
          short_txt = "No Filter";
        }  //end switch block

        //create the bandpass filter
        filtCoeff_bp[Ifilt] =  new FilterConstants(b, a, filt_txt, short_txt);
      } //end loop over band pass filters

      break;

      // Ganglion board, sampling rate 200 Hz
    case 1:
      //loop over all of the pre-defined filter types
      n_filt = filtCoeff_notch.length;
      for (int Ifilt=0; Ifilt < n_filt; Ifilt++) {
        switch (Ifilt) {
        case 0:
          //60 Hz notch filter, assumed fs = 200 Hz.  2nd Order Butterworth: b, a = signal.butter(2,[59.0 61.0]/(fs_Hz / 2.0), 'bandstop')
          b2 = new double[] { 0.956543225556876, 1.18293615779028, 2.27881429174347, 1.18293615779028, 0.956543225556876 };
          a2 = new double[] { 1, 1.20922304075909, 2.27692490805579, 1.15664927482146, 0.914975834801432 };
          filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "Notch 60Hz", "60Hz");
          break;
        case 1:
          //50 Hz notch filter, assumed fs = 200 Hz.  2nd Order Butterworth: b, a = signal.butter(2,[49.0 51.0]/(fs_Hz / 2.0), 'bandstop')
          b2 = new double[] { 0.956543225556877, -2.34285519884863e-16, 1.91308645111375, -2.34285519884863e-16, 0.956543225556877};
          a2 = new double[] { 1, -1.02695629777827e-15, 1.91119706742607, -1.01654795692241e-15, 0.914975834801435};
          filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "Notch 50Hz", "50Hz");
          break;
        case 2:
          //no notch filter
          b2 = new double[] { 1.0 };
          a2 = new double[] { 1.0 };
          filtCoeff_notch[Ifilt] =  new FilterConstants(b2, a2, "No Notch", "None");
          break;
        }
      } // end loop over notch filters

      n_filt = filtCoeff_bp.length;
      for (int Ifilt=0; Ifilt<n_filt; Ifilt++) {
        //define bandpass filter
        switch (Ifilt) {
        case 0:
          //butter(2,[1 50]/(200/2));  %bandpass filter
          b = new double[] {
            0.283751216219318, 0, -0.567502432438636, 0, 0.283751216219318
          };
          a = new double[] {
            1, -1.97380379923172, 1.17181238127012, -0.368664525962831, 0.171812381270120
          };
          filt_txt = "Bandpass 1-50Hz";
          short_txt = "1-50 Hz";
          break;
        case 1:
          //butter(2,[7 13]/(200/2));
          b = new double[] {
            0.00782020803349883, 0, -0.0156404160669977, 0, 0.00782020803349883
          };
          a = new double[] {
            1, -3.56776916484310, 4.92946172209398, -3.12070317627516, 0.766006600943266
          };
          filt_txt = "Bandpass 7-13Hz";
          short_txt = "7-13 Hz";
          break;
        case 2:
          //[b,a]=butter(2,[15 50]/(200/2)); %matlab command
          b = new double[] {
            0.167483800127017, 0, -0.334967600254034, 0, 0.167483800127017
          };
          a = new double[] {
            1, -1.56695061045088, 1.22696619781982, -0.619519163981230, 0.226966197819818
          };
          filt_txt = "Bandpass 15-50Hz";
          short_txt = "15-50 Hz";
          break;
        case 3:
          //[b,a]=butter(2,[5 50]/(200/2)); %matlab command
          b = new double[] {
            0.248341078962540, 0, -0.496682157925080, 0, 0.248341078962540
          };
          a = new double[] {
            1, -1.86549482213123, 1.17757811892770, -0.460665534278457, 0.177578118927698
          };
          filt_txt = "Bandpass 5-50Hz";
          short_txt = "5-50 Hz";
          break;
        default:
          //no filtering
          b = new double[] {
            1.0
          };
          a = new double[] {
            1.0
          };
          filt_txt = "No BP Filter";
          short_txt = "No Filter";
        }  //end switch block

        //create the bandpass filter
        filtCoeff_bp[Ifilt] =  new FilterConstants(b, a, filt_txt, short_txt);
      } //end loop over band pass filters

      break;
    }
  } //end defineFilters method

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
  }

  public void incrementNotchConfiguration() {
    //increment the index
    currentNotch_ind++;
    if (currentNotch_ind >= N_NOTCH_CONFIGS) currentNotch_ind = 0;
  }

  public void process(float[][] data_newest_uV, //holds raw EEG data that is new since the last call
    float[][] data_long_uV, //holds a longer piece of buffered EEG data, of same length as will be plotted on the screen
    float[][] data_forDisplay_uV, //put data here that should be plotted on the screen
    FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

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
      for (int I=0; I < fftBuff[Ichan].specSize(); I++) {  //loop over each FFT bin
        fftBuff[Ichan].setBand(I, (float)(fftBuff[Ichan].getBand(I) / fftBuff[Ichan].specSize()));
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
      } //end loop over FFT bins
      for (int i = 0; i < processing_band_low_Hz.length; i++) {
        float sum = 0;
        for (int j = processing_band_low_Hz[i]; j < processing_band_high_Hz[i]; j++) {
          sum += fftBuff[Ichan].getBand(j);
        }
        avgPowerInBins[Ichan][i] = sum;
      }
    } //end the loop over channels.
    for (int i = 0; i < processing_band_low_Hz.length; i++) {
      float sum = 0;

      for (int j = 0; j < nchan; j++) {
        sum += avgPowerInBins[j][i];
      }
      headWidePower[i] = sum/nchan;
    }

    //delta in channel ... averPowerInBins[1][DELTA];
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

    println("Brain Wide DELTA = " + headWidePower[DELTA]);
    println("Brain Wide THETA = " + headWidePower[THETA]);
    println("Brain Wide ALPHA = " + headWidePower[ALPHA]);
    println("Brain Wide BETA  = " + headWidePower[BETA]);
    println("Brain Wide GAMMA = " + headWidePower[GAMMA]);

  }
}
