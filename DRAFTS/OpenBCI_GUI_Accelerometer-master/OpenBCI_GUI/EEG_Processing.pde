//import ddf.minim.analysis.*; //for FFT

boolean drawUser = false; //if true... toggles on EEG_Processing_User.draw and toggles off the headplot in Gui_Manager

class EEG_Processing_User {
  private float fs_Hz;  //sample rate
  private int nchan;  
  
  //add your own variables here
  boolean isTriggered = false;  //boolean to keep track of when the trigger condition is met
  float upperThreshold = 25;  //default uV upper threshold value ... this will automatically change over time
  float lowerThreshold = 0;  //default uV lower threshold value ... this will automatically change over time
  int averagePeriod = 250;  //number of data packets to average over (250 = 1 sec)
  int thresholdPeriod = 1250;  //number of packets
  int ourChan = 3 - 1;  //channel being monitored ... "3 - 1" means channel 3 (with a 0 index)
  float myAverage = 0.0;   //this will change over time ... used for calculations below
  float acceptableLimitUV = 255;  //uV values above this limit are excluded, as a result of them almost certainly being noise...
  
  //if writing to a serial port
  int output = 0; //value between 0-255 that is the relative position of the current uV average between the rolling lower and upper uV thresholds
  float output_normalized = 0;  //converted to between 0-1
  float output_adjusted = 0;  //adjusted depending on range that is expected on the other end, ie 0-255?
 
  //class constructor
  EEG_Processing_User(int NCHAN, float sample_rate_Hz) {
    nchan = NCHAN;
    fs_Hz = sample_rate_Hz;
  }
  
  //add some functions here...if you'd like
  
  //here is the processing routine called by the OpenBCI main program...update this with whatever you'd like to do
  public void process(float[][] data_newest_uV, //holds raw EEG data that is new since the last call
        float[][] data_long_uV, //holds a longer piece of buffered EEG data, of same length as will be plotted on the screen
        float[][] data_forDisplay_uV, //this data has been filtered and is ready for plotting on the screen
        FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

    //for example, you could loop over each EEG channel to do some sort of time-domain processing 
    //using the sample values that have already been filtered, as will be plotted on the display
    float EEG_value_uV;
    
    for(int i = data_forDisplay_uV[ourChan].length - averagePeriod; i < data_forDisplay_uV[ourChan].length; i++){
       if(data_forDisplay_uV[ourChan][i] <= acceptableLimitUV){ //prevent BIG spikes from effecting the average
         myAverage += abs(data_forDisplay_uV[ourChan][i]);  //add value to average ... we will soon divide by # of packets
       }
    }

    myAverage = myAverage / float(averagePeriod); //finishing the average
    
    //--------------------- some conditionals -------------------------
    
    if(myAverage >= upperThreshold && myAverage <= acceptableLimitUV){ // 
       upperThreshold = myAverage; 
    }
    
    if(myAverage <= lowerThreshold){
       lowerThreshold = myAverage; 
    }
    
    if(upperThreshold >= myAverage){
      upperThreshold -= (upperThreshold - 25)/(frameRate * 5); //have upper threshold creep downwards to keep range tight
    }
    
    if(lowerThreshold <= myAverage){
      lowerThreshold += (25 - lowerThreshold)/(frameRate * 5); //have lower threshold creep upwards to keep range tight
    }
    
    output = (int)map(myAverage, lowerThreshold, upperThreshold, 0, 255);
    output_normalized = map(myAverage, lowerThreshold, upperThreshold, 0, 1);
    output_adjusted = ((-0.1/(output_normalized*255.0)) + 255.0);
    
    //trip the output to a value between 0-255
    if(output < 0) output = 0;
    if(output > 255) output = 255;
    
    //attempt to write to serial_output. If this serial port does not exist, do nothing.
    try {
      //println("inMoov_output: | " + output + " |");
      serial_output.write(output);
    }
    catch(RuntimeException e){
      if(isVerbose) println("serial not present");
    }
        
    //OR, you could loop over each EEG channel and do some sort of frequency-domain processing from the FFT data
    float FFT_freq_Hz, FFT_value_uV;
    for (int Ichan=0;Ichan < nchan; Ichan++) {
      //loop over each new sample
      for (int Ibin=0; Ibin < fftBuff[Ichan].specSize(); Ibin++){
        FFT_freq_Hz = fftData[Ichan].indexToFreq(Ibin);
        FFT_value_uV = fftData[Ichan].getBand(Ibin);
        
        //add your processing here...
        
        
        
        //println("EEG_Processing_User: Ichan = " + Ichan + ", Freq = " + FFT_freq_Hz + "Hz, FFT Value = " + FFT_value_uV + "uV/bin");
      }
    }  
  }

  //Draw function added to render EMG feedback visualizer
  public void draw(){
    pushStyle();

      //circle for outer threshold
      noFill();
      stroke(0,255,0);
      strokeWeight(2);
      float scaleFactor = 1.25;
      ellipse(3*(width/4), height/4, scaleFactor * upperThreshold, scaleFactor * upperThreshold);

      //circle for inner threshold
      stroke(0,255,255);
      ellipse(3*(width/4), height/4, scaleFactor * lowerThreshold, scaleFactor * lowerThreshold);
  
      //realtime 
      fill(255,0,0, 125);
      noStroke();
      ellipse(3*(width/4), height/4, scaleFactor * myAverage, scaleFactor * myAverage);
      
      //draw background bar for mapped uV value indication
      fill(0,255,255,125);
      rect(7*(width/8), height/8, (width/32), (height/4));
      
      //draw real time bar of actually mapped value
      fill(0,255,255);
      rect(7*(width/8), 3*(height/8), (width/32), map(output_normalized, 0, 1, 0, (-1) * (height/4)));

    popStyle();
  }

}

class EEG_Processing {
  private float fs_Hz;  //sample rate
  private int nchan;
  final int N_FILT_CONFIGS = 5;
  FilterConstants[] filtCoeff_bp = new FilterConstants[N_FILT_CONFIGS];
  final int N_NOTCH_CONFIGS = 3;
  FilterConstants[] filtCoeff_notch = new FilterConstants[N_NOTCH_CONFIGS];
  private int currentFilt_ind = 0;
  private int currentNotch_ind = 0;  // set to 0 to default to 60Hz, set to 1 to default to 50Hz
  float data_std_uV[];
  float polarity[];


  EEG_Processing(int NCHAN, float sample_rate_Hz) {
    nchan = NCHAN;
    fs_Hz = sample_rate_Hz;
    data_std_uV = new float[nchan];
    polarity = new float[nchan];
    

    //check to make sure the sample rate is acceptable and then define the filters
    if (abs(fs_Hz-250.0f) < 1.0) {
      defineFilters();
    } 
    else {
      println("EEG_Processing: *** ERROR *** Filters can currently only work at 250 Hz");
      defineFilters();  //define the filters anyway just so that the code doesn't bomb
    }
  }

  public float getSampleRateHz() { 
    return fs_Hz;
  };

  //define filters...assumes sample rate of 250 Hz !!!!!
  private void defineFilters() {
    int n_filt;
    double[] b, a, b2, a2;
    String filt_txt, filt_txt2;
    String short_txt, short_txt2; 

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
          b2 = new double[] { 0.96508099, -1.19328255,  2.29902305, -1.19328255,  0.96508099 };
          a2 = new double[] { 1.0       , -1.21449348,  2.29780334, -1.17207163,  0.93138168 }; 
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
    for (int Ifilt=0;Ifilt<n_filt;Ifilt++) {
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
    for (int Ichan=0;Ichan < nchan; Ichan++) {  

      //filter the data in the time domain
      filterIIR(filtCoeff_notch[currentNotch_ind].b, filtCoeff_notch[currentNotch_ind].a, data_forDisplay_uV[Ichan]); //notch
      filterIIR(filtCoeff_bp[currentFilt_ind].b, filtCoeff_bp[currentFilt_ind].a, data_forDisplay_uV[Ichan]); //bandpass

      //compute the standard deviation of the filtered signal...this is for the head plot
      float[] fooData_filt = dataBuffY_filtY_uV[Ichan];  //use the filtered data
      fooData_filt = Arrays.copyOfRange(fooData_filt, fooData_filt.length-((int)fs_Hz), fooData_filt.length);   //just grab the most recent second of data
      data_std_uV[Ichan]=std(fooData_filt); //compute the standard deviation for the whole array "fooData_filt"
     
    } //close loop over channels
    
    //find strongest channel
    int refChanInd = findMax(data_std_uV);
    //println("EEG_Processing: strongest chan (one referenced) = " + (refChanInd+1));
    float[] refData_uV = dataBuffY_filtY_uV[refChanInd];  //use the filtered data
    refData_uV = Arrays.copyOfRange(refData_uV, refData_uV.length-((int)fs_Hz), refData_uV.length);   //just grab the most recent second of data
      
    
    //compute polarity of each channel
    for (int Ichan=0; Ichan < nchan; Ichan++) {
      float[] fooData_filt = dataBuffY_filtY_uV[Ichan];  //use the filtered data
      fooData_filt = Arrays.copyOfRange(fooData_filt, fooData_filt.length-((int)fs_Hz), fooData_filt.length);   //just grab the most recent second of data
      float dotProd = calcDotProduct(fooData_filt,refData_uV);
      if (dotProd >= 0.0f) {
        polarity[Ichan]=1.0;
      } else {
        polarity[Ichan]=-1.0;
      }
      
    }    
  }
}