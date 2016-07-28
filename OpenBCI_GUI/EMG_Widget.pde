
Button configButton;
Serial serialOutEMG;
ControlP5 cp5Serial;
String serialNameEMG;
String baudEMG;



class EMG_Widget extends Container{

  private float fs_Hz; //sample rate
  private int nchan;
  private int lastChan = 0;
  PApplet parent;
  
  
  Motor_Widget[] motorWidgets;
  TripSlider[] tripSliders;
  TripSlider[] untripSliders;
  
  
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
  EMG_Widget(int NCHAN, float sample_rate_Hz, Container container, PApplet p){
    
    super(container, "WHOLE");
    parent = p;
    cp5Serial = new ControlP5(parent);
    
    this.nchan = NCHAN;
    this.fs_Hz = sample_rate_Hz;
    
    
    //make that array yo
    tripSliders = new TripSlider[NCHAN];
    untripSliders = new TripSlider[NCHAN];
    motorWidgets = new Motor_Widget[NCHAN];
    
    for (int i = 0; i < NCHAN; i++){
      motorWidgets[i] = new Motor_Widget();
      motorWidgets[i].ourChan = i;
      
      
    }
    
    initSliders(h,w);
    
    //tripSliders[0] = new TripSlider(50,160,0,30,5,tripSliders);
    //tripSliders[1] = new TripSlider(100,160,0,30,5,tripSliders);
    
    configButton = new Button(int(x) - 60,int(y),20,20,"O",fontInfo.buttonLabel_size);
    configWidget = new Config_Widget(NCHAN, sample_rate_Hz, container, motorWidgets);
  }
  
  void initSliders(float rh, float rw){
    
            //rect(5*colOffset/8, (2 * rowOffset / 8) , (3*colOffset/32), 2);
    int rowNum = 4;
    int colNum = motorWidgets.length / rowNum;
    int index = 0;
    float rowOffset = rh / rowNum;
    float colOffset = rw / colNum;
    
    if(nchan == 8){
      for (int i = 0; i < rowNum; i++) {
              for (int j = 0; j < colNum; j++) {      
  
                if(i > 2){
                  tripSliders[index] = new TripSlider(int(752 + (j * 205)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,true, motorWidgets[index]);
                  untripSliders[index] = new TripSlider(int(752 + (j * 205)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,false, motorWidgets[index]);
                }
                else{
                  tripSliders[index] = new TripSlider(int(752 + (j * 205)), int(117 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,true, motorWidgets[index]);
                  untripSliders[index] = new TripSlider(int(752 + (j * 205)), int(117 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,false, motorWidgets[index]);
                }
                
                tripSliders[index].setStretchPercentage(motorWidgets[index].tripThreshold);
                untripSliders[index].setStretchPercentage(motorWidgets[index].untripThreshold);
                index++;
                println(index);
                
  
              }
      }
    }
    else if(nchan == 16){
      for (int i = 0; i < rowNum; i++) {
              for (int j = 0; j < colNum; j++) {    
                
                if( j < 2){
                  tripSliders[index] = new TripSlider(int(683 + (j * 103)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,true, motorWidgets[index]);
                  untripSliders[index] = new TripSlider(int(683 + (j * 103)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,false, motorWidgets[index]);
                }
                else{
                  tripSliders[index] = new TripSlider(int(683 + (j * 103) - 1), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,true, motorWidgets[index]);
                  untripSliders[index] = new TripSlider(int(683 + (j * 103) - 1), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,false, motorWidgets[index]);
                }
                
                tripSliders[index].setStretchPercentage(motorWidgets[index].tripThreshold);
                untripSliders[index].setStretchPercentage(motorWidgets[index].untripThreshold);
                index++;
                println(index);
                
  
              }
      }
    }
    
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
      
      
      
      //=============== TRIPPIN ==================
      switch(cfc.ourChan){
      
        case 0:
          eventChan0(cfc);
          break;
        case 1:
          eventChan1(cfc);
          break;
        case 2:
          eventChan2(cfc);
          break;
        case 3:
          eventChan3(cfc);
          break;
        case 4:
          eventChan4(cfc);
          break;
        case 5:
          eventChan5(cfc);
          break;
        case 6:
          eventChan6(cfc);
          break;
        case 7:
          eventChan7(cfc);
          break;
        case 8:
          eventChan8(cfc);
          break;
        case 9:
          eventChan9(cfc);
          break;
        case 10:
          eventChan10(cfc);
          break;
        case 11:
          eventChan11(cfc);
          break;
        case 12:
          eventChan12(cfc);
          break;
        case 13:
          eventChan13(cfc);
          break;
        case 14:
          eventChan14(cfc);
          break;
        case 15:
          eventChan15(cfc);
          break;
        default:
          break;
      
      }
      
      
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
                      
        cp5Serial.setVisible(true);  

        pushStyle();
        configButton.draw();
        if(!configButton.wasPressed){
          //if(configButton.isMouseHere()) println("wwww");
          //float rx = 0.6 * width, ry = 0.07 * height, rw = 0.4 * width, rh = 0.45 * height;        
          cp5Serial.get(MenuList.class, "serialListConfig").setVisible(false); 
          cp5Serial.get(MenuList.class, "baudList").setVisible(false);   
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
              rect(5*colOffset/8, 2 * rowOffset / 8 - 7, (3*colOffset/32), int((4*rowOffset/8) + 7));
              
              //println("WOAH THIS: " + (4*rowOffset/8));
              //draw real time bar of actually mapped value
              rect(5*colOffset/8, 6 *rowOffset / 8 , (3*colOffset/32), map(motorWidgets[i * colNum + j].output_normalized, 0, 1, 0, (-1) * int((4*rowOffset/8) )));
            //}
            
             //draw the thresholds
            //fill(255,0,0);
            //rect(5*colOffset/8, (2 * rowOffset / 8) , (3*colOffset/32), 2);
            //fill(0,0,50);
            //rect(13*(width/16), 3*(height/8) +  map(output_normalized, 0, 1, 0, (-1) * (height/4)) * untripThreshold, (width/64), 5);
    
              popMatrix();
              tripSliders[index].update();
              tripSliders[index].display();
              untripSliders[index].update();
              untripSliders[index].display();
              index++;
            }
          }
    

          popStyle();
        }
       else{
         configWidget.draw();
       }
       
      }
      else{
        cp5Serial.setVisible(false);  
       }

    //drawTriggerFeedback();
  } //end of draw

  
	
  public void drawTriggerFeedback(){

  }
  
  void mousePressed(){
    if(mouseX >= x - 35 && mouseX <= x+w && mouseY >= y && mouseY <= y+h && configButton.wasPressed){
       
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
      
      if(motorWidget.configWidget.connectToSerial.isMouseHere()){
        motorWidget.configWidget.connectToSerial.wasPressed = true;
        motorWidget.configWidget.connectToSerial.setIsActive(true);
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
      if(!motorWidget.configWidget.dynamicThreshold.wasPressed && !configButton.wasPressed){
        tripSliders[i].releaseEvent();
        untripSliders[i].releaseEvent();
      }
      
      if(i != lastChan){
        motorWidget.configWidget.chans[i].setIsActive(false);
        motorWidget.configWidget.chans[i].wasPressed = false;
      }
    }
    
    if(motorWidget.configWidget.connectToSerial.isMouseHere()){
      motorWidget.configWidget.connectToSerial.wasPressed = false;
      motorWidget.configWidget.connectToSerial.setIsActive(false);
      
      try{
        serialOutEMG = new Serial(parent,serialNameEMG,Integer.parseInt(baudEMG));
        motorWidget.configWidget.print_onscreen("Connected!");
      }
      catch (Exception e){
        motorWidget.configWidget.print_onscreen("Could not connect!");
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
    public Button connectToSerial;
    
    MenuList serialListLocal;
    MenuList baudList;
    String last_message = "";
    
    
    String[] serialPortsLocal = new String[Serial.list().length];
    
    
    public Config_Widget(int NCHAN, float sample_rate_Hz, Container container, Motor_Widget[] parent){
      super(container, "WHOLE");
      
      this.nchan = NCHAN;
      this.fs_Hz = sample_rate_Hz;
      this.parent = parent;
      
      
      chans = new Button[NCHAN];
      digital = new Button(int(x + 55),int(y + 60),10,10,"",fontInfo.buttonLabel_size);
      analog = new Button(int(x - 15),int(y + 60),10,10,"",fontInfo.buttonLabel_size);
      valueThreshold = new Button(int(x+235), int(y+60), 10,10,"",fontInfo.buttonLabel_size);
      dynamicThreshold = new Button(int(x+150), int(y+60), 10,10,"",fontInfo.buttonLabel_size);
      connectToSerial = new Button(int(x+235), int(y+297),100,25,"Connect", 18);
      
      digital.setIsActive(true);
      digital.wasPressed = true;
      analog.setIsActive(true);
      analog.wasPressed = true;
      valueThreshold.setIsActive(true);
      valueThreshold.wasPressed = true;
      
      
      serialListLocal = new MenuList(cp5Serial, "serialListConfig", 236, 120, f2);
      serialListLocal.setPosition(x - 10 , y + 160);
      serialPortsLocal = Serial.list();
      for (int i = 0; i < serialPortsLocal.length; i++) {
        String tempPort = serialPortsLocal[(serialPortsLocal.length-1) - i]; //list backwards... because usually our port is at the bottom
        if(!tempPort.equals(openBCI_portName)) serialListLocal.addItem(makeItem(tempPort));
      }
      
      
      baudList = new MenuList(cp5Serial, "baudList", 100, 120, f2);
      baudList.setPosition(x+235, y + 160);
     
      baudList.addItem(makeItem("230400"));
      baudList.addItem(makeItem("115200"));
      baudList.addItem(makeItem("57600"));
      baudList.addItem(makeItem("38400"));
      baudList.addItem(makeItem("28800"));
      baudList.addItem(makeItem("19200"));
      baudList.addItem(makeItem("14400"));
      baudList.addItem(makeItem("9600"));
      baudList.addItem(makeItem("7200"));
      baudList.addItem(makeItem("4800"));
      baudList.addItem(makeItem("3600"));
      baudList.addItem(makeItem("2400"));
      baudList.addItem(makeItem("1800"));
      baudList.addItem(makeItem("1200"));
      baudList.addItem(makeItem("600"));
      baudList.addItem(makeItem("300"));
      
      
      Map bob = ((MenuList)baudList).getItem(0);
      baudEMG = (String)bob.get("headline");
      baudList.activeItem = 0;
      
      Map bobSer = ((MenuList)serialListLocal).getItem(0);
      serialNameEMG = (String)bobSer.get("headline");
      serialListLocal.activeItem = 0;
      
      cp5Serial.get(MenuList.class, "serialListConfig").setVisible(false); 
      cp5Serial.get(MenuList.class, "baudList").setVisible(false);   
      
      
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
      //Config Window Rectangle
      fill(211,211,211);
      rect(rx - 35,ry,rw,rh);
      
      //Serial Config Rectangle
      fill(190,190,190);
      rect(rx - 30,ry+90,rw- 10,rh-95);
      
      
      //Channel Configs
      fill(255,255,255);
      //rect(rx - 30,ry+5,(rw - 10) / nchan,30,20,20,0,0);
      for(int i = 0; i < nchan; i++){
        chans[i].draw();
      }
      drawAnalogSelection();
      drawThresholdSelection();
      drawMenuLists();
      
      print_lastmessage();
    
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
      textSize(13);
      text("Dynamic",x+167, y+68);
      text("Trip Value     %" + (double)Math.round((parent[lastChan].tripThreshold * 100) * 10d) / 10d,x+250, y+63);
      text("Untrip Value %"+ (double)Math.round((parent[lastChan].untripThreshold * 100) * 10d) / 10d,x+250, y+78);
    }
    
    void drawMenuLists(){
      fill(50);
      textFont(f1);
      textAlign(CENTER);
      textSize(18);
      text("Serial Out Configuration",x+160, y+120);
      
      textSize(14);
      textAlign(LEFT);
      text("Serial Port", x-10, y + 150);
      text("BAUD Rate", x+235, y+150);
      cp5Serial.get(MenuList.class, "serialListConfig").setVisible(true); //make sure the serialList menulist is visible
      cp5Serial.get(MenuList.class, "baudList").setVisible(true); //make sure the baudList menulist is visible
      
      connectToSerial.draw();
    }
    
    public void print_onscreen(String localstring){
        textAlign(LEFT);
        fill(0);
        rect(x - 10, y + 290, (w-175), 40);
        fill(255);
        text(localstring, x, y + 290 + 15, ( w - 180), 40 -15);
        this.last_message = localstring;
        
     
      }
      
    void print_lastmessage(){
        textAlign(LEFT);
        fill(0);
        rect(x - 10, y + 290, (w-175), 40);
        fill(255);
        text(this.last_message, x, y + 290 + 15, ( w - 180), 40 -15);
      }
  
  }
  
  
  
  //TRIP SLIDERS
  class TripSlider {
    
    int lx, ly;
    int boxx, boxy;
    int stretch;
    int wid;
    int len;
    boolean over;
    boolean press;
    boolean locked = false;
    boolean otherslocked = false;
    boolean trip;
    boolean drawHand;
    TripSlider[] others;
    color current_color = color(255,255,255);
    Motor_Widget parent;
    
    TripSlider(int ix, int iy, int il, int iwid, int ilen, TripSlider[] o, boolean wastrip, Motor_Widget p) {
      lx = ix;
      ly = iy;
      stretch = il;
      wid = iwid;
      len = ilen;
      boxx = lx - wid/2;
      boxy = ly-stretch - len/2;
      others = o;
      trip = wastrip; 
      parent = p;
    }
    
    void update() {
      boxx = lx - wid/2;
      boxy = ly - stretch;
      
      for (int i=0; i<others.length; i++) {
        if (others[i].locked == true) {
          otherslocked = true;
          break;
        } else {
          otherslocked = false;
        }  
      }
      
      if (otherslocked == false) {
        overEvent();
        pressEvent();
      }
      
      if (press) {
        if(trip) stretch = lock(ly -mouseY, int(parent.untripThreshold * (50 - len)), 50 - len);
        else stretch = lock(ly -mouseY, 0, int(parent.tripThreshold * (50- len)));
        //println("wut :" + float(ly - mouseY) / 48);
        
        if((ly - mouseY) > 50-len && trip) parent.tripThreshold = 1;
        else if((ly - mouseY) > 50 -len && !trip) parent.untripThreshold = 1;
        else if((ly - mouseY) < 0 && trip) parent.tripThreshold = 0;
        else if((ly - mouseY) < 0 && !trip) parent.untripThreshold = 0;
        else if(trip) parent.tripThreshold = float(ly - mouseY) / (50 - len);
        else if(!trip) parent.untripThreshold = float(ly - mouseY) / (50 - len);
      }
    }
    
    void overEvent() {
      if (overRect(boxx, boxy, wid, len)) {
        over = true;
      } else {
        over = false;
      }
    }
    
    void pressEvent() {
      if (over && mousePressed || locked) {
        press = true;
        locked = true;
      } else {
        press = false;
      }
    }
    
    void releaseEvent() {
      locked = false;
    }
    
    void setColor(){
      if(over) {
        current_color = color(127,134,143); 
        if(!drawHand){
          cursor(HAND);
          drawHand = true;
        }
      }
      else {
        if(trip) current_color = color(0,255,0);
        else current_color = color(255,0,0);
        if(drawHand){
          cursor(ARROW);
          drawHand = false;
        }
      }
    }
    
    void setStretchPercentage(float val){
      //println("ly: " + (ly - 60 - 100*val));
      
      stretch = lock(int((50 - len) * val), 0, 50 - len);
    }
    
    
    void display() {
      //line(lx, ly, lx, ly-stretch);
      fill(255);
      strokeWeight(0);
      stroke(255);
      setColor();
      fill(current_color);
      rect(boxx, boxy, wid, len);
      
      //if (over || press) {
      //  line(boxx, boxy, boxx+wid, boxy+len);
      //  line(boxx, boxy+wid, boxx+len, boxy);
      //}
  
    }
    boolean overRect(int lx, int ly, int lwidth, int lheight) {
      if (mouseX >= lx && mouseX <= lx+lwidth && 
          mouseY >= ly && mouseY <= ly+lheight) {
        return true;
      } else {
        return false;
      }
    }
  
    int lock(int val, int minv, int maxv) { 
      return  min(max(val, minv), maxv); 
    } 
}

  
  //===================== EVENTS =========================
  
  void eventChan0(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 1");
      cfc.switchCounter++;
      if(serialOutEMG != null) serialOutEMG.write("5");
      cfc.switchTripped = false;
    }
    
  
  }
  
  void eventChan1(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 2");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan2(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 3");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan3(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 4");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan4(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 5");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan5(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 6");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan6(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 7");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan7(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 8");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan8(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 9");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan9(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 10");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan10(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 11");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan11(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 12");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan12(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 13");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan13(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 14");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan14(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 15");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  void eventChan15(Motor_Widget cfc){
  
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
    
    int timeToWait = 1250;
    int timeToWaitThresh = 750;
    
    if(output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh){
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
    }
    if(switchTripped && output_normalized <= untripThreshold){
      println("Untripped 16");
      cfc.switchCounter++;
      cfc.switchTripped = false;
    }
    
  
  
  }
  
  
  
  
}