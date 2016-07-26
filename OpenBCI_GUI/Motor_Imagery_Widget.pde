
Button configButton;

class Motor_Imagery_Widget extends Container{

  private float fs_Hz; //sample rate
  private int nchan;
  private int lastChan = 0;
  
  
  Motor_Widget[] motorWidgets;
  
  public Config_Widget configWidget;
  
  class Motor_Widget{
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
  
    boolean analogBool = true;
    boolean digitalBool = true;
  }
  
  //Constructor
  Motor_Imagery_Widget(int NCHAN, float sample_rate_Hz, Container container){
  
    super(container, "WHOLE");
    
    this.nchan = NCHAN;
    this.fs_Hz = sample_rate_Hz;
    
    //make that array yo
    motorWidgets = new Motor_Widget[NCHAN];
    for (int i = 0; i < NCHAN; i++){
      motorWidgets[i] = new Motor_Widget();
      motorWidgets[i].ourChan = i;
    }
    
    configButton = new Button(int(x) - 60,int(y),20,20,"O",fontInfo.buttonLabel_size);
    configWidget = new Config_Widget(NCHAN, sample_rate_Hz, container, motorWidgets);
  }
  
  public void process(float[][] data_newest_uV, //holds raw EEG data that is new since the last call
        float[][] data_long_uV, //holds a longer piece of buffered EEG data, of same length as will be plotted on the screen
        float[][] data_forDisplay_uV, //this data has been filtered and is ready for plotting on the screen
        FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

    //for example, you could loop over each EEG channel to do some sort of time-domain processing 
    //using the sample values that have already been filtered, as will be plotted on the display
    float EEG_value_uV;
    
    //looping over channels and analyzing input data
    for (Motor_Widget cfc : motorWidgets) {
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
        configButton.draw();
        if(!configButton.wasPressed){
          //if(configButton.isMouseHere()) println("wwww");
          //float rx = 0.6 * width, ry = 0.07 * height, rw = 0.4 * width, rh = 0.45 * height;
          float rx = x, ry = y, rw = w, rh = h;
          
          float scaleFactor = 3.0;
          float scaleFactorJaw = 1.5;
          int rowNum = 4;
          int colNum = motorWidgets.length / rowNum;
          float rowOffset = rh / rowNum;
          float colOffset = rw / colNum;
          int index = 0;
    
          //new 
          for (int i = 0; i < rowNum; i++) {
            for (int j = 0; j < colNum; j++) {
              
              pushMatrix();
              translate(rx + j * colOffset, ry + i * rowOffset);
              //draw visulizer
            //if(this.motorWidgets[index].analogBool){
              noFill();
              stroke(0,255,0);
              strokeWeight(2);
              //circle for outer threshold
              ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * motorWidgets[i * colNum + j].upperThreshold, scaleFactor * motorWidgets[i * colNum + j].upperThreshold);
              //circle for inner threshold
              stroke(0,255,255);
              ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * motorWidgets[i * colNum + j].lowerThreshold, scaleFactor * motorWidgets[i * colNum + j].lowerThreshold);
              //realtime
              fill(255,0,0, 125);
              noStroke();
              ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * motorWidgets[i * colNum + j].myAverage, scaleFactor * motorWidgets[i * colNum + j].myAverage);
            //}
            
             
            
            //draw background bar for mapped uV value indication
            
            //if(this.motorWidgets[index].digitalBool){
              fill(0,255,255,125);
              rect(5*colOffset/8, 2 * rowOffset / 8, (3*colOffset/32), (4*rowOffset/8));
              //draw real time bar of actually mapped value
              rect(5*colOffset/8, 6 *rowOffset / 8, (3*colOffset/32), map(motorWidgets[i * colNum + j].output_normalized, 0, 1, 0, (-1) * (4*rowOffset/8)));
            //}
            
             //draw the thresholds
            fill(255,0,0);
            rect(5*colOffset/8, (2 * rowOffset / 8) , (3*colOffset/32), 2);
            fill(0,0,50);
            //rect(13*(width/16), 3*(height/8) +  map(output_normalized, 0, 1, 0, (-1) * (height/4)) * untripThreshold, (width/64), 5);
    
              popMatrix();
              
              index++;
            }
          }
    
          popStyle();
        }
       else{
         configWidget.draw();
       }
      }
    //drawTriggerFeedback();
  } //end of draw

  
	
  public void drawTriggerFeedback(){

  }
  
  void mousePressed(){
    if(mouseX >= x - 35 && mouseX <= x+w && mouseY >= y && mouseY <= y+h){
         
      for(int i = 0; i < nchan; i++){
        if(motorWidget.configWidget.chans[i].isMouseHere()) {
          motorWidget.configWidget.chans[i].setIsActive(true);
          motorWidget.configWidget.chans[i].wasPressed = true;
          lastChan = i;
          
          if(!motorWidgets[lastChan].digitalBool){
            motorWidget.configWidget.digital.setIsActive(false);
          }
          else if(motorWidgets[lastChan].digitalBool){
            motorWidget.configWidget.digital.setIsActive(true);
          }
        
          if(!motorWidgets[lastChan].analogBool){
            motorWidget.configWidget.analog.setIsActive(false);
          }
          else if(motorWidgets[lastChan].analogBool){
            motorWidget.configWidget.analog.setIsActive(true);
          }
        
          break;          
        }
        
      }
      
      if(motorWidget.configWidget.digital.isMouseHere()){
        if(motorWidget.configWidget.digital.wasPressed){
          motorWidgets[lastChan].digitalBool = false;
          motorWidget.configWidget.digital.wasPressed = false;
          motorWidget.configWidget.digital.setIsActive(false);
        }
        else if(!motorWidget.configWidget.digital.wasPressed){
          motorWidgets[lastChan].digitalBool = true;
          motorWidget.configWidget.digital.wasPressed = true;
          motorWidget.configWidget.digital.setIsActive(true);
        }
      }
      
      if(motorWidget.configWidget.analog.isMouseHere()){
        if(motorWidget.configWidget.analog.wasPressed){
          motorWidgets[lastChan].analogBool = false;
          motorWidget.configWidget.analog.wasPressed = false;
          motorWidget.configWidget.analog.setIsActive(false);
        }
        else if(!motorWidget.configWidget.analog.wasPressed){
          motorWidgets[lastChan].analogBool = true;
          motorWidget.configWidget.analog.wasPressed = true;
          motorWidget.configWidget.analog.setIsActive(true);
        }
      }
      
      
      //digital = new Button(int(x + 55),int(y + 60),10,10,"",fontInfo.buttonLabel_size);
      //analog = new Button(int(x - 15),int(y + 60),10,10,"",fontInfo.buttonLabel_size);
      
      
    }
    else if(mouseX >= (x-60) && mouseX <= (x-40) && mouseY >= y && mouseY <= y+20){
      
      if(configButton.isMouseHere()){
        configButton.setIsActive(true);
        
        if(configButton.wasPressed){
          configButton.wasPressed = false;
          configButton.setString("O");
        }
        else{
          configButton.wasPressed = true;
          configButton.setString("X");
        }
      }
    }
  
  }

  
  void mouseReleased(){
    //if(mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h){
      //println("Motor imagery Mouse Pressed");
    for(int i = 0; i < nchan; i++){
      if(i != lastChan){
        motorWidget.configWidget.chans[i].setIsActive(false);
        motorWidget.configWidget.chans[i].wasPressed = false;
      }
    }

    //}
    
    configButton.setIsActive(false);
  }
  
  class Config_Widget extends Container{
    private float fs_Hz;
    private int nchan;
    private Motor_Widget[] parent;
    public Button[] chans;
    public Button analog;
    public Button digital;
    public Button valueThreshold;
    public Button dynamicThreshold;
    
    
    
    public Config_Widget(int NCHAN, float sample_rate_Hz, Container container, Motor_Widget[] parent){
      super(container, "WHOLE");
      
      this.nchan = NCHAN;
      this.fs_Hz = sample_rate_Hz;
      this.parent = parent;
      
      
      chans = new Button[NCHAN];
      digital = new Button(int(x + 55),int(y + 60),10,10,"",fontInfo.buttonLabel_size);
      analog = new Button(int(x - 15),int(y + 60),10,10,"",fontInfo.buttonLabel_size);
      valueThreshold = new Button(int(x+240), int(y+60), 10,10,"",fontInfo.buttonLabel_size);
      dynamicThreshold = new Button(int(x+155), int(y+60), 10,10,"",fontInfo.buttonLabel_size);
      digital.setIsActive(true);
      digital.wasPressed = true;
      analog.setIsActive(true);
      analog.wasPressed = true;
      valueThreshold.setIsActive(true);
      valueThreshold.wasPressed = true;
      
      for (int i = 0; i < NCHAN; i++){
        if(NCHAN == 8) chans[i] = new Button(int(x - 30 + (i * (w-10)/nchan )), int(y + 10), int((w-10)/nchan), 30,"CHAN " + (i+1),fontInfo.buttonLabel_size);
        else chans[i] = new Button(int(x - 30 + (i * (w-10)/nchan )), int(y + 5), int((w-10)/nchan), 30,"" + (i+1),fontInfo.buttonLabel_size);
      }
      chans[0].setIsActive(true);
      chans[0].wasPressed = true;
    
    }
  
    public void draw(){
      pushStyle();
      
      float rx = x, ry = y, rw = w, rh =h;
      
      fill(211,211,211);
      
      rect(rx - 35,ry,rw,rh);
      
      fill(255,255,255);
      
      //rect(rx - 30,ry+5,(rw - 10) / nchan,30,20,20,0,0);
      for(int i = 0; i < nchan; i++){
        chans[i].draw();
      }
      drawAnalogSelection();
      drawThresholdSelection();
    
    }
    
    void drawAnalogSelection(){
      fill(233,233,233);
      rect(x-30,y+50,165,30);
      analog.draw();
      digital.draw();
      fill(50);
      text("Analog",x+20, y+63);
      text("Digital",x+90, y+63);
    }
    
    void drawThresholdSelection(){
      fill(233,233,233);
      rect(x+140,y+50,230,30);
      valueThreshold.draw();
      dynamicThreshold.draw();
      
      fill(50);
      textAlign(LEFT);
      text("Dynamic",x+175, y+68);
      text("Trip Value %" + parent[lastChan].tripThreshold * 10,x+255, y+63);
      text("Untrip Value %"+ (parent[lastChan].untripThreshold * 10),x+255, y+78);
    }
  
  }
  
  
  
  
}