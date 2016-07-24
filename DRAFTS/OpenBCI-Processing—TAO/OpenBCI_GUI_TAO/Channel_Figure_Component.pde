//------------------------Added by TaoLin, for ChannelFigureComponent(visualizer)-------------------------------------------

boolean drawEMG = false; //if true... toggles on EEG_Processing_User.draw and toggles off the headplot in Gui_Manager

class Channel_Figure_Component extends Container {
  private float fs_Hz;  //sample rate
  private int nchan;  
  
  //new
  ChannelFigureComponent[] CFCArray; //ChannelFigureComponentArray
  class ChannelFigureComponent {
    //variables
    boolean isTriggered = false;
    float upperThreshold = 25;        //default uV upper threshold value ... this will automatically change over time
    float lowerThreshold = 0;         //default uV lower threshold value ... this will automatically change over time
    int averagePeriod = 250;          //number of data packets to average over (250 = 1 sec)
    int thresholdPeriod = 1250;       //number of packets
    int ourChan = 0;                  //channel being monitored ... "3 - 1" means channel 3 (with a 0 index)
    float myAverage = 0.0;            //this will change over time ... used for calculations below
    float acceptableLimitUV = 200;    //uV values above this limit are excluded, as a result of them almost certainly being noise...
    //prez related
    boolean switchTripped = false;
    int switchCounter = 0;
    float timeOfLastTrip = 0;
    float tripThreshold = 0.75;
    float untripThreshold = 0.6;    
    //if writing to a serial port
    int output = 0;                   //value between 0-255 that is the relative position of the current uV average between the rolling lower and upper uV thresholds
    float output_normalized = 0;      //converted to between 0-1
    float output_adjusted = 0;        //adjusted depending on range that is expected on the other end, ie 0-255?
  }

 
  //class constructor
  Channel_Figure_Component(int NCHAN, float sample_rate_Hz, Container container) {
    super(container, "WHOLE");
    nchan = NCHAN;
    fs_Hz = sample_rate_Hz;
    
    //new
    CFCArray = new ChannelFigureComponent[NCHAN];
    for (int i = 0; i < NCHAN; i++) {
      CFCArray[i] = new ChannelFigureComponent();
      CFCArray[i].ourChan = i;
    }
  }
  
  //here is the processing routine called by the OpenBCI main program...update this with whatever you'd like to do
  public void process(float[][] data_newest_uV, //holds raw EEG data that is new since the last call
        float[][] data_long_uV, //holds a longer piece of buffered EEG data, of same length as will be plotted on the screen
        float[][] data_forDisplay_uV, //this data has been filtered and is ready for plotting on the screen
        FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

    //for example, you could loop over each EEG channel to do some sort of time-domain processing 
    //using the sample values that have already been filtered, as will be plotted on the display
    float EEG_value_uV;
    
    //looping over channels and analyzing input data
    for (ChannelFigureComponent cfc : CFCArray) {
      cfc.myAverage = 0.0;
      for(int i = data_forDisplay_uV[cfc.ourChan].length - cfc.averagePeriod; i < data_forDisplay_uV[cfc.ourChan].length; i++){
         if(abs(data_forDisplay_uV[cfc.ourChan][i]) <= cfc.acceptableLimitUV){ //prevent BIG spikes from effecting the average
           cfc.myAverage += abs(data_forDisplay_uV[cfc.ourChan][i]);  //add value to average ... we will soon divide by # of packets
         } else {
           cfc.myAverage += cfc.acceptableLimitUV; //if it's greater than the limit, just add the limit
         }
      }
      cfc.myAverage = cfc.myAverage / float(cfc.averagePeriod); //finishing the average     
      
      if(cfc.myAverage >= cfc.upperThreshold && cfc.myAverage <= cfc.acceptableLimitUV){ // 
         cfc.upperThreshold = cfc.myAverage; 
      }
      if(cfc.myAverage <= cfc.lowerThreshold){
         cfc.lowerThreshold = cfc.myAverage; 
      }
      if(cfc.upperThreshold >= (cfc.myAverage + 35)){
        cfc.upperThreshold *= .97;
      }
      if(cfc.lowerThreshold <= cfc.myAverage){
        cfc.lowerThreshold += (10 - cfc.lowerThreshold)/(frameRate * 5); //have lower threshold creep upwards to keep range tight
      }
      //output_L = (int)map(myAverage_L, lowerThreshold_L, upperThreshold_L, 0, 255);
      cfc.output_normalized = map(cfc.myAverage, cfc.lowerThreshold, cfc.upperThreshold, 0, 1);
      cfc.output_adjusted = ((-0.1/(cfc.output_normalized*255.0)) + 255.0);
    }
  

   
   //-----------------what is this part used for---------------------------------------
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
    //---------------------------------------------------------------------------------
    
  }

  public void draw(){
    super.draw();
    if(drawEMG){
      pushStyle();
        //float rx = 0.6 * width, ry = 0.07 * height, rw = 0.4 * width, rh = 0.45 * height;
        float rx = CON_X, ry = CON_Y, rw = CON_W, rh = CON_H;
        
        float scaleFactor = 3.0;
        float scaleFactorJaw = 1.5;
        int rowNum = 4;
        int colNum = CFCArray.length / rowNum;
        float rowOffset = rh / rowNum;
        float colOffset = rw / colNum;

        //new 
        for (int i = 0; i < rowNum; i++) {
          for (int j = 0; j < colNum; j++) {
            
            pushMatrix();
            translate(rx + j * colOffset, ry + i * rowOffset);
            //draw visulizer
            noFill();
            stroke(0,255,0);
            strokeWeight(2);
            //circle for outer threshold
            ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * CFCArray[i * colNum + j].upperThreshold, scaleFactor * CFCArray[i * colNum + j].upperThreshold);
            //circle for inner threshold
            stroke(0,255,255);
            ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * CFCArray[i * colNum + j].lowerThreshold, scaleFactor * CFCArray[i * colNum + j].lowerThreshold);
            //realtime
            fill(255,0,0, 125);
            noStroke();
            ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * CFCArray[i * colNum + j].myAverage, scaleFactor * CFCArray[i * colNum + j].myAverage);
            //draw background bar for mapped uV value indication
            fill(0,255,255,125);
            rect(5*colOffset/8, 2 * rowOffset / 8, (3*colOffset/32), (4*rowOffset/8));
            //draw real time bar of actually mapped value
            rect(5*colOffset/8, 6 *rowOffset / 8, (3*colOffset/32), map(CFCArray[i * colNum + j].output_normalized, 0, 1, 0, (-1) * (4*rowOffset/8)));
            popMatrix();
          }
        }
        

      popStyle();
    }
    //drawTriggerFeedback();
  } //end of draw
  
  public void drawTriggerFeedback(){

  }
}