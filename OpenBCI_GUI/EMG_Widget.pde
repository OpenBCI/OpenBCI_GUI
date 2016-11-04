/////////////////////////////////////////////////////////////////////////////////
//
//  Emg_Widget is used to visiualze EMG data by channel, and to trip events
//
//  Created: Colin Fausnaught, August 2016 (with a lot of reworked code from Tao)
//
//  Custom widget to visiualze EMG data. Features dragable thresholds, serial
//  out communication, channel configuration, digital and analog events.
//
//  KNOWN ISSUES: Cannot resize with window dragging events
//
//  TODO: Add dynamic threshold functionality
////////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

Button configButton;
Serial serialOutEMG;
ControlP5 cp5Serial;
String serialNameEMG;
String baudEMG;



//------------------------------------------------------------------------
//                            Classes
//------------------------------------------------------------------------

class EMG_Widget extends Container {

  private float fs_Hz; //sample rate
  private int nchan;
  private int lastChan = 0;
  PApplet parent;
  String oldCommand = "";
  int parentContainer = 3;
  PFont f = createFont("Arial Bold", 24); //for "FFT Plot" Widget Title

  Motor_Widget[] motorWidgets;
  TripSlider[] tripSliders;
  TripSlider[] untripSliders;


  public Config_Widget configWidget;

  class Motor_Widget {
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
    float untripThreshold = 0.5;
    //if writing to a serial port
    int output = 0;                   //value between 0-255 that is the relative position of the current uV average between the rolling lower and upper uV thresholds
    float output_normalized = 0;      //converted to between 0-1
    float output_adjusted = 0;        //adjusted depending on range that is expected on the other end, ie 0-255?
    boolean analogBool = true;        //Analog events?
    boolean digitalBool = true;       //Digital events?
  }

  //Constructor
  EMG_Widget(int NCHAN, float sample_rate_Hz, Container c, PApplet p) {



    super(c, "WHOLE");
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    h = (int)container[parentContainer].h;
    w = (int)container[parentContainer].w;

    parent = p;
    cp5Serial = new ControlP5(p);


    this.nchan = NCHAN;
    this.fs_Hz = sample_rate_Hz;
    // println("EMG_Widget: constructor: NCHAN " + NCHAN);
    tripSliders = new TripSlider[NCHAN];
    untripSliders = new TripSlider[NCHAN];
    motorWidgets = new Motor_Widget[NCHAN];

    for (int i = 0; i < NCHAN; i++) {
      motorWidgets[i] = new Motor_Widget();
      motorWidgets[i].ourChan = i;
    }

    initSliders(w, h);

    configButton = new Button(int(x), int(y), 20, 20, "O", fontInfo.buttonLabel_size);  
    configWidget = new Config_Widget(NCHAN, sample_rate_Hz, c, motorWidgets);
  }


  //Initalizes the threshold sliders
  void initSliders(float rw, float rh) {
    //Stole some logic from the rectangle drawing in draw()
    int rowNum = 4;
    int colNum = motorWidgets.length / rowNum;
    int index = 0;

    float rowOffset = rh / rowNum;
    float colOffset = rw / colNum;

    if (nchan == 4) {
      for (int i = 0; i < rowNum; i++) {
        for (int j = 0; j < colNum; j++) {

          if (i > 2) {
            tripSliders[index] = new TripSlider(int(752 + (j * 205)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders, true, motorWidgets[index]);
            untripSliders[index] = new TripSlider(int(752 + (j * 205)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders, false, motorWidgets[index]);
          } else {
            tripSliders[index] = new TripSlider(int(752 + (j * 205)), int(117 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders, true, motorWidgets[index]);
            untripSliders[index] = new TripSlider(int(752 + (j * 205)), int(117 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders, false, motorWidgets[index]);
          }

          tripSliders[index].setStretchPercentage(motorWidgets[index].tripThreshold);
          untripSliders[index].setStretchPercentage(motorWidgets[index].untripThreshold);
          index++;
        }
      }
    } else if (nchan == 8) {
      for (int i = 0; i < rowNum; i++) {
        for (int j = 0; j < colNum; j++) {      
          //TripSlider(int ix, int iy, int il, int iwid, int ilen, TripSlider[] o, boolean wastrip, Motor_Widget p) {
          //rect(5*colOffset/8, 2 * rowOffset / 8 , (3*colOffset/32), int((4*rowOffset/8)));
          //        ^X              ^Y                ^WIDTH              ^HEIGHT

          //TripSlider(int ix, int iy, int il, int iwid, int ilen, TripSlider[] o, boolean wastrip, Motor_Widget p) {

          //lx = ix;
          //ly = iy;
          //stretch = il;
          //wid = iwid;
          //len = ilen;
          //boxx = lx - wid/2;
          //boxy = ly-stretch - len/2;


          //            if(i > 2){
          //              //tripSliders[index] = new TripSlider(int(752 + (j * 205)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,true, motorWidgets[index]);
          //              //untripSliders[index] = new TripSlider(int(752 + (j * 205)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,false, motorWidgets[index]);

          //              //done here
          //              //tripSliders[index] = new TripSlider(int(5*colOffset/8), int(2 * rowOffset / 8) , 0, int(3*colOffset/32), 2, tripSliders,true, motorWidgets[index]);
          //              tripSliders[index] = new TripSlider(int(5*colOffset/8), int(2 * rowOffset / 8) , 0, int(3*colOffset/32), 2, tripSliders,true, motorWidgets[index]);

          //              untripSliders[index] = new TripSlider(int(752 + (j * 205)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, untripSliders,false, motorWidgets[index]);

          //            }
          //  else{

          //(5*colOffset/8, 2 * rowOffset / 8 , (3*colOffset/32), 2_

          tripSliders[index] = new TripSlider(int(5*colOffset/8), int(2 * rowOffset / 8), 0, int((3*colOffset/32)), 2, tripSliders, true, motorWidgets[index]);
          untripSliders[index] = new TripSlider(int(5*colOffset/8), int(2 * rowOffset / 8), 0, int(3*colOffset/32), 2, tripSliders, false, motorWidgets[index]);
          //  }


          tripSliders[index].setStretchPercentage(motorWidgets[index].tripThreshold);
          untripSliders[index].setStretchPercentage(motorWidgets[index].untripThreshold);
          index++;
        }
      }
    } else if (nchan == 16) {
      for (int i = 0; i < rowNum; i++) {
        for (int j = 0; j < colNum; j++) {    

          if ( j < 2) {
            //tripSliders[index] = new TripSlider(int(683 + (j * 103)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,true, motorWidgets[index]);
            //untripSliders[index] = new TripSlider(int(683 + (j * 103)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,false, motorWidgets[index]);

            tripSliders[index] = new TripSlider(int(683 + (j * 103)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders, true, motorWidgets[index]);
            untripSliders[index] = new TripSlider(int(683 + (j * 103)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders, false, motorWidgets[index]);
          } else {
            tripSliders[index] = new TripSlider(int(683 + (j * 103) - 1), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders, true, motorWidgets[index]);
            untripSliders[index] = new TripSlider(int(683 + (j * 103) - 1), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders, false, motorWidgets[index]);
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
    //float EEG_value_uV;

    //looping over channels and analyzing input data
    for (Motor_Widget cfc : motorWidgets) {
      cfc.myAverage = 0.0;
      for (int i = data_forDisplay_uV[cfc.ourChan].length - cfc.averagePeriod; i < data_forDisplay_uV[cfc.ourChan].length; i++) {
        if (abs(data_forDisplay_uV[cfc.ourChan][i]) <= cfc.acceptableLimitUV) { //prevent BIG spikes from effecting the average
          cfc.myAverage += abs(data_forDisplay_uV[cfc.ourChan][i]);  //add value to average ... we will soon divide by # of packets
        } else {
          cfc.myAverage += cfc.acceptableLimitUV; //if it's greater than the limit, just add the limit
        }
      }
      cfc.myAverage = cfc.myAverage / float(cfc.averagePeriod); //finishing the average

      if (cfc.myAverage >= cfc.upperThreshold && cfc.myAverage <= cfc.acceptableLimitUV) { //
        cfc.upperThreshold = cfc.myAverage;
      }
      if (cfc.myAverage <= cfc.lowerThreshold) {
        cfc.lowerThreshold = cfc.myAverage;
      }
      if (cfc.upperThreshold >= (cfc.myAverage + 35)) {
        cfc.upperThreshold *= .97;
      }
      if (cfc.lowerThreshold <= cfc.myAverage) {
        cfc.lowerThreshold += (10 - cfc.lowerThreshold)/(frameRate * 5); //have lower threshold creep upwards to keep range tight
      }
      //output_L = (int)map(myAverage_L, lowerThreshold_L, upperThreshold_L, 0, 255);
      cfc.output_normalized = map(cfc.myAverage, cfc.lowerThreshold, cfc.upperThreshold, 0, 1);
      cfc.output_adjusted = ((-0.1/(cfc.output_normalized*255.0)) + 255.0);



      //=============== TRIPPIN ==================
      //= Just calls all the trip events         =
      //==========================================

      switch(cfc.ourChan) {

      case 0:
        if (configWidget.digital.wasPressed) digitalEventChan0(cfc);
        if (configWidget.analog.wasPressed) analogEventChan0(cfc);
        break;
      case 1:
        if (configWidget.digital.wasPressed) digitalEventChan1(cfc);
        if (configWidget.analog.wasPressed) analogEventChan1(cfc);
        break;
      case 2:
        if (configWidget.digital.wasPressed) digitalEventChan2(cfc);
        if (configWidget.analog.wasPressed) analogEventChan2(cfc);
        break;
      case 3:
        if (configWidget.digital.wasPressed) digitalEventChan3(cfc);
        if (configWidget.analog.wasPressed) analogEventChan3(cfc);
        break;
      case 4:
        if (configWidget.digital.wasPressed) digitalEventChan4(cfc);
        if (configWidget.analog.wasPressed) analogEventChan4(cfc);
        break;
      case 5:
        if (configWidget.digital.wasPressed) digitalEventChan5(cfc);
        if (configWidget.analog.wasPressed) analogEventChan5(cfc);
        break;
      case 6:
        if (configWidget.digital.wasPressed) digitalEventChan6(cfc);
        if (configWidget.analog.wasPressed) analogEventChan6(cfc);
        break;
      case 7:
        if (configWidget.digital.wasPressed) digitalEventChan7(cfc);
        if (configWidget.analog.wasPressed) analogEventChan7(cfc);
        break;
      case 8:
        if (configWidget.digital.wasPressed) digitalEventChan8(cfc);
        if (configWidget.analog.wasPressed) analogEventChan8(cfc);
        break;
      case 9:
        if (configWidget.digital.wasPressed) digitalEventChan9(cfc);
        if (configWidget.analog.wasPressed) analogEventChan9(cfc);
        break;
      case 10:
        if (configWidget.digital.wasPressed) digitalEventChan10(cfc);
        if (configWidget.analog.wasPressed) analogEventChan10(cfc);
        break;
      case 11:
        if (configWidget.digital.wasPressed) digitalEventChan11(cfc);
        if (configWidget.analog.wasPressed) analogEventChan11(cfc);
        break;
      case 12:
        if (configWidget.digital.wasPressed) digitalEventChan12(cfc);
        if (configWidget.analog.wasPressed) analogEventChan12(cfc);
        break;
      case 13:
        if (configWidget.digital.wasPressed) digitalEventChan13(cfc);
        if (configWidget.analog.wasPressed) analogEventChan13(cfc);
        break;
      case 14:
        if (configWidget.digital.wasPressed) digitalEventChan14(cfc);
        if (configWidget.analog.wasPressed) analogEventChan14(cfc);
        break;
      case 15:
        if (configWidget.digital.wasPressed) digitalEventChan15(cfc);
        if (configWidget.analog.wasPressed) analogEventChan15(cfc);
        break;
      default:
        break;
      }
    }

    //=================== OpenBionics switch example ==============================

    //if (millis() - motorWidgets[1].timeOfLastTrip >= 2000 && serialOutEMG != null) {
    //  switch(motorWidgets[1].switchCounter){
    //    case 1:
    //      switch(motorWidgets[0].switchCounter){
    //        case 1:
    //          //RED CIRCLE FOR JAW, RED FOR BROW
    //          //hand.write(oldCommand);
    //          break;
    //        case 2:
    //          //GREEN CIRCLE FOR JAW, RED FOR BROW
    //          serialOutEMG.write(oldCommand);
    //          delay(100);
    //          oldCommand = "1234";
    //          serialOutEMG.write(oldCommand);
    //          break;
    //        case 3:
    //          //BLUE CIRCLE FOR JAW, RED FOR BROW
    //          serialOutEMG.write(oldCommand);
    //          delay(100);
    //          oldCommand = "01";
    //          serialOutEMG.write(oldCommand);
    //          break;
    //        case 4:
    //          //VIOLET CIRCLE FOR JAW, RED FOR BROW
    //          serialOutEMG.write("0");
    //          break;
    //      }
    //      break;
    //    case 2:
    //      //println("Two Brow Raises");
    //      switch(motorWidgets[0].switchCounter){
    //        case 1:
    //          //RED CIRCLE FOR JAW, GREEN FOR BROW
    //          break;
    //        case 2:
    //          //GREEN CIRCLE FOR JAW, GREEN FOR BROW
    //          serialOutEMG.write(oldCommand);
    //          delay(100);
    //          oldCommand = "23";
    //          serialOutEMG.write(oldCommand);
    //          break;
    //        case 3:
    //          //BLUE CIRCLE FOR JAW, GREEN FOR BROW
    //          serialOutEMG.write(oldCommand);
    //          delay(100);
    //          oldCommand = "012";
    //          serialOutEMG.write(oldCommand);
    //          break;
    //        case 4:
    //          //VIOLET CIRCLE FOR JAW, GREEN FOR BROW
    //          serialOutEMG.write("1");
    //          break;
    //      }
    //      break;
    //    case 3:
    //      //println("Three Brow Raises");
    //      switch(motorWidgets[0].switchCounter){
    //        case 1:
    //          //RED CIRCLE FOR JAW, BLUE FOR BROW
    //          break;
    //        case 2:
    //          //GREEN CIRCLE FOR JAW, BLUE FOR BROW
    //          serialOutEMG.write(oldCommand);
    //          delay(100);
    //          oldCommand = "234";
    //          serialOutEMG.write(oldCommand);
    //          break;
    //        case 3:
    //          //BLUE CIRCLE FOR JAW, BLUE FOR BROW
    //          serialOutEMG.write(oldCommand);
    //          delay(100);
    //          oldCommand = "0123";
    //          serialOutEMG.write(oldCommand);
    //          break;
    //        case 4:
    //          //VIOLET CIRCLE FOR JAW, BLUE FOR BROW
    //          serialOutEMG.write("2");
    //          break;
    //      }
    //      break;
    //    case 4:
    //      //println("Four Brow Raises");
    //      switch(motorWidgets[0].switchCounter){
    //        case 1:
    //          //RED CIRCLE FOR JAW, VIOLET FOR BROW
    //          break;
    //        case 2:
    //          //GREEN CIRCLE FOR JAW, VIOLET FOR BROW
    //          serialOutEMG.write(oldCommand);
    //          delay(100);
    //          oldCommand = "0134";
    //          serialOutEMG.write(oldCommand);
    //          break;
    //        case 3:
    //          //BLUE CIRCLE FOR JAW, VIOLET FOR BROW
    //          serialOutEMG.write(oldCommand);
    //          delay(100);
    //          oldCommand = "01234";
    //          serialOutEMG.write(oldCommand);
    //          break;
    //        case 4:
    //          //VIOLET CIRCLE FOR JAW, VIOLET FOR BROW
    //          serialOutEMG.write("3");
    //          break;
    //      }
    //      break;
    //    case 5:
    //      //println("Five Brow Raises");
    //      switch(motorWidgets[0].switchCounter){
    //        case 1:
    //          //RED CIRCLE FOR JAW, YELLOW FOR BROW
    //          break;
    //        case 2:
    //          //GREEN CIRCLE FOR JAW, YELLOW FOR BROW
    //          break;
    //        case 3:
    //          //BLUE CIRCLE FOR JAW, YELLOW FOR BROW
    //          break;
    //        case 4:
    //          //VIOLET CIRCLE FOR JAW, YELLOW FOR BROW
    //          serialOutEMG.write("4");
    //          break;
    //      }
    //      break;
    //    //case 6:
    //    //  println("Six Brow Raises");
    //    //  break;
    //  }
    //  motorWidgets[1].switchCounter = 0;
    //}



    //----------------- Leftover from Tou Code, what does this do? ----------------------------
    //OR, you could loop over each EEG channel and do some sort of frequency-domain processing from the FFT data
    float FFT_freq_Hz, FFT_value_uV;
    for (int Ichan=0; Ichan < nchan; Ichan++) {
      //loop over each new sample
      for (int Ibin=0; Ibin < fftBuff[Ichan].specSize(); Ibin++) {
        FFT_freq_Hz = fftData[Ichan].indexToFreq(Ibin);
        FFT_value_uV = fftData[Ichan].getBand(Ibin);

        //add your processing here...
      }
    }
    //---------------------------------------------------------------------------------
  }
  void update() {

    //update position/size of FFT Plot
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;
  }

  void screenResized(PApplet _parent, int _winX, int _winY) {
    //when screen is resized...
    //update Head Plot widget position/size
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;
  }


  public void draw() {
    super.draw();
    if (drawEMG) {

      cp5Serial.setVisible(true);

      pushStyle();
      noStroke();
      fill(125);
      rect(x, y, w, h);

      fill(150, 150, 150);
      rect(x, y, w, navHeight); //top bar
      fill(200, 200, 200);
      rect(x, y+navHeight, w, navHeight); //button bar
      fill(255);
      rect(x+2, y+2, navHeight-4, navHeight-4);
      fill(bgColor, 100);
      //rect(x+3,y+3, (navHeight-7)/2, navHeight-10);
      rect(x+4, y+4, (navHeight-10)/2, (navHeight-10)/2);
      rect(x+4, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10)/2);
      rect(x+((navHeight-10)/2)+5, y+4, (navHeight-10)/2, (navHeight-10)/2);
      rect(x+((navHeight-10)/2)+5, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10 )/2);
      //text("FFT Plot", x+w/2, y+navHeight/2)
      fill(bgColor);
      textAlign(LEFT, CENTER);
      textFont(f);
      textSize(18);
      text("EMG Widget", x+navHeight+2, y+navHeight/2 - 2);


      //draw dropdown titles
      int dropdownPos = 4; //used to loop through drop down titles ... should use for loop with titles in String array, but... laziness has ensued. -Conor
      int dropdownWidth = 60;
      textFont(f2);
      textSize(12);
      textAlign(CENTER, BOTTOM);
      fill(bgColor);
      text("Layout", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      dropdownPos = 3;
      text("Headset", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      //dropdownPos = 3;
      //text("# Chan.", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      dropdownPos = 2;
      text("Polarity", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      dropdownPos = 1;
      text("Smoothing", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      dropdownPos = 0;
      text("Filters?", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));



      configButton.draw();
      if (!configButton.wasPressed) {   
        cp5Serial.get(MenuList.class, "serialListConfig").setVisible(false); 
        cp5Serial.get(MenuList.class, "baudList").setVisible(false);   
        float rx = x, ry = y + 2* navHeight, rw = w, rh = h - 2*navHeight;


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
            noFill();
            stroke(0, 255, 0);
            strokeWeight(2);
            //circle for outer threshold
            ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * motorWidgets[i * colNum + j].upperThreshold, scaleFactor * motorWidgets[i * colNum + j].upperThreshold);
            //circle for inner threshold
            stroke(0, 255, 255);
            ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * motorWidgets[i * colNum + j].lowerThreshold, scaleFactor * motorWidgets[i * colNum + j].lowerThreshold);
            //realtime
            fill(255, 0, 0, 125);
            noStroke();
            ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * motorWidgets[i * colNum + j].myAverage, scaleFactor * motorWidgets[i * colNum + j].myAverage);

            //draw background bar for mapped uV value indication

            fill(0, 255, 255, 125);
            rect(5*colOffset/8, 2 * rowOffset / 8, (3*colOffset/32), int((4*rowOffset/8)));

            //draw real time bar of actually mapped value
            rect(5*colOffset/8, 6 *rowOffset / 8, (3*colOffset/32), map(motorWidgets[i * colNum + j].output_normalized, 0, 1, 0, (-1) * int((4*rowOffset/8) )));





            //TripSlider(int ix, int iy, int il, int iwid, int ilen, TripSlider[] o, boolean wastrip, Motor_Widget p) {

            //lx = ix;
            //ly = iy;
            //stretch = il;
            //wid = iwid;
            //len = ilen;
            //boxx = lx - wid/2;
            //boxy = ly-stretch - len/2;


            //tripSliders[index] = new TripSlider(int(752 + (j * 205)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,true, motorWidgets[index]);
            //untripSliders[index] = new TripSlider(int(752 + (j * 205)), int(118 + (i * 86)), 0, int(3*colOffset/32), 2, tripSliders,false, motorWidgets[index]);


            //draw thresholds
            tripSliders[index].update(rx + j * colOffset, ry + i * rowOffset);
            tripSliders[index].display(5*colOffset/8, 2 * rowOffset / 8, (3*colOffset/32), 2);
            //tripSliders[index].display(5*colOffset/8, 2 * rowOffset / 8 , (3*colOffset/32), 2);
            //println("Col thing For Sliders: " + (5*colOffset/8));
            untripSliders[index].update(rx + j * colOffset, ry + i * rowOffset);
            untripSliders[index].display(5*colOffset/8, 2 * rowOffset / 8, (3*colOffset/32), 2);


            //tripSliders[index].setStretchPercentage(motorWidgets[index].tripThreshold);
            //untripSliders[index].setStretchPercentage(motorWidgets[index].untripThreshold);
            index++;

            popMatrix();
          }
        }


        popStyle();
      } else {
        configWidget.draw();
      }
    } else {
      cp5Serial.setVisible(false);
    }

    if (serialOutEMG != null) drawTriggerFeedback();
  } //end of draw



  //Feedback for triggers/switches.
  //Currently only used for the OpenBionics implementation, but left
  //in to give an idea of how it can be used.
  public void drawTriggerFeedback() {
    //Is the board streaming data?
    //if so ... draw feedback
    if (isRunning) {

      switch (motorWidgets[0].switchCounter) {
      case 1:
        fill(255, 0, 0);
        ellipse(width/2, height - 40, 20, 20);
        break;
      case 2:
        fill(0, 255, 0);
        ellipse(width/2, height - 40, 20, 20);
        break;
      case 3:
        fill(0, 0, 255);
        ellipse(width/2, height - 40, 20, 20);
        break;
      case 4:
        fill(128, 0, 128);
        ellipse(width/2, height - 40, 20, 20);
        break;
      }

      //switch (motorWidgets[1].switchCounter){
      //  case 1:
      //    fill(255,0,0);
      //    ellipse(width/2, height - 70 , 20, 20);
      //    break;
      //  case 2:
      //    fill(0,255,0);
      //    ellipse(width/2, height - 70 , 20, 20);
      //    break;
      //  case 3:
      //    fill(0,0,255);
      //    ellipse(width/2, height - 70 , 20, 20);
      //    break;
      //  case 4:
      //    fill(128,0,128);
      //    ellipse(width/2, height - 70 , 20, 20);
      //    break;
      //  case 5:
      //    fill(255,255,0);
      //    ellipse(width/2, height - 70 , 20, 20);
      //    break;
      //}
    }
  }

  //Mouse pressed event
  void mousePressed() {
    if (mouseX >= x - 35 && mouseX <= x+w && mouseY >= y && mouseY <= y+h && configButton.wasPressed) {

      //Handler for channel selection. No two channels can be
      //selected at the same time. All values are then set
      //to whatever value the channel specifies they should
      //have (particularly analog and digital buttons)

      for (int i = 0; i < nchan; i++) {
        if (emg_widget.configWidget.chans[i].isMouseHere()) {
          emg_widget.configWidget.chans[i].setIsActive(true);
          emg_widget.configWidget.chans[i].wasPressed = true;
          lastChan = i;

          if (!motorWidgets[lastChan].digitalBool) {
            emg_widget.configWidget.digital.setIsActive(false);
          } else if (motorWidgets[lastChan].digitalBool) {
            emg_widget.configWidget.digital.setIsActive(true);
          }

          if (!motorWidgets[lastChan].analogBool) {
            emg_widget.configWidget.analog.setIsActive(false);
          } else if (motorWidgets[lastChan].analogBool) {
            emg_widget.configWidget.analog.setIsActive(true);
          }

          break;
        }
      }

      //Digital button event
      if (emg_widget.configWidget.digital.isMouseHere()) {
        if (emg_widget.configWidget.digital.wasPressed) {
          motorWidgets[lastChan].digitalBool = false;
          emg_widget.configWidget.digital.wasPressed = false;
          emg_widget.configWidget.digital.setIsActive(false);
        } else if (!emg_widget.configWidget.digital.wasPressed) {
          motorWidgets[lastChan].digitalBool = true;
          emg_widget.configWidget.digital.wasPressed = true;
          emg_widget.configWidget.digital.setIsActive(true);
        }
      }

      //Analog button event
      if (emg_widget.configWidget.analog.isMouseHere()) {
        if (emg_widget.configWidget.analog.wasPressed) {
          motorWidgets[lastChan].analogBool = false;
          emg_widget.configWidget.analog.wasPressed = false;
          emg_widget.configWidget.analog.setIsActive(false);
        } else if (!emg_widget.configWidget.analog.wasPressed) {
          motorWidgets[lastChan].analogBool = true;
          emg_widget.configWidget.analog.wasPressed = true;
          emg_widget.configWidget.analog.setIsActive(true);
        }
      }

      //Connect button event
      if (emg_widget.configWidget.connectToSerial.isMouseHere()) {
        emg_widget.configWidget.connectToSerial.wasPressed = true;
        emg_widget.configWidget.connectToSerial.setIsActive(true);
      }
    } else if (mouseX >= (x) && mouseX <= (x-20) && mouseY >= y && mouseY <= y+20) {


      //Open configuration menu
      if (configButton.isMouseHere()) {
        configButton.setIsActive(true);

        if (configButton.wasPressed) {
          configButton.wasPressed = false;
          configButton.setString("O");
        } else {
          configButton.wasPressed = true;
          configButton.setString("X");
        }
      }
    }
  }

  //Mouse Released Event
  void mouseReleased() {
    // println("EMG_Widget: mouseReleased: nchan " + nchan);
    for (int i = 0; i < nchan; i++) {
      if (!emg_widget.configWidget.dynamicThreshold.wasPressed && !configButton.wasPressed) {
        tripSliders[i].releaseEvent();
        untripSliders[i].releaseEvent();
      }

      if (i != lastChan) {
        emg_widget.configWidget.chans[i].setIsActive(false);
        emg_widget.configWidget.chans[i].wasPressed = false;
      }
    }

    if (emg_widget.configWidget.connectToSerial.isMouseHere()) {
      emg_widget.configWidget.connectToSerial.wasPressed = false;
      emg_widget.configWidget.connectToSerial.setIsActive(false);

      try {
        serialOutEMG = new Serial(parent, serialNameEMG, Integer.parseInt(baudEMG));
        emg_widget.configWidget.print_onscreen("Connected!");
      }
      catch (Exception e) {
        emg_widget.configWidget.print_onscreen("Could not connect!");
      }
    }

    configButton.setIsActive(false);
  }


  //=============== Config_Widget ================
  //=  The configuration menu. Customize in any  =
  //=  way that could help you out!              =
  //=                                            =
  //=  TODO: Add dynamic threshold functionality =
  //==============================================

  class Config_Widget extends Container {
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


    //Constructor
    public Config_Widget(int NCHAN, float sample_rate_Hz, Container container, Motor_Widget[] parent) {
      super(container, "WHOLE");

      // println("EMG_Widget: Config_Widget: nchan " + NCHAN);

      this.nchan = NCHAN;
      this.fs_Hz = sample_rate_Hz;
      this.parent = parent;


      chans = new Button[NCHAN];
      digital = new Button(int(x + 55), int(y + 60), 10, 10, "", fontInfo.buttonLabel_size);
      analog = new Button(int(x - 15), int(y + 60), 10, 10, "", fontInfo.buttonLabel_size);
      valueThreshold = new Button(int(x+235), int(y+60), 10, 10, "", fontInfo.buttonLabel_size);
      dynamicThreshold = new Button(int(x+150), int(y+60), 10, 10, "", fontInfo.buttonLabel_size);  //CURRENTLY DOES NOTHING! Working on implementation
      connectToSerial = new Button(int(x+235), int(y+297), 100, 25, "Connect", 18);

      digital.setIsActive(true);
      digital.wasPressed = true;
      analog.setIsActive(true);
      analog.wasPressed = true;
      valueThreshold.setIsActive(true);
      valueThreshold.wasPressed = true;

      //Available serial outputs
      serialListLocal = new MenuList(cp5Serial, "serialListConfig", 236, 120, f2);
      serialListLocal.setPosition(x - 10, y + 160);
      serialPortsLocal = Serial.list();
      for (int i = 0; i < serialPortsLocal.length; i++) {
        String tempPort = serialPortsLocal[(serialPortsLocal.length-1) - i]; //list backwards... because usually our port is at the bottom
        if (!tempPort.equals(openBCI_portName)) serialListLocal.addItem(makeItem(tempPort));
      }

      //List of BAUD values
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


      //Set first items to active
      Map bob = ((MenuList)baudList).getItem(0);
      baudEMG = (String)bob.get("headline");
      baudList.activeItem = 0;

      Map bobSer = ((MenuList)serialListLocal).getItem(0);
      serialNameEMG = (String)bobSer.get("headline");
      serialListLocal.activeItem = 0;

      //Hide the list until open button clicked
      cp5Serial.get(MenuList.class, "serialListConfig").setVisible(false);
      cp5Serial.get(MenuList.class, "baudList").setVisible(false);

      //Buttons for different channels (Just displays number if 16 channel)
      for (int i = 0; i < NCHAN; i++) {
        if (NCHAN == 8) chans[i] = new Button(int(x - 30 + (i * (w-10)/nchan )), int(y + 10), int((w-10)/nchan), 30, "CHAN " + (i+1), fontInfo.buttonLabel_size);
        else chans[i] = new Button(int(x - 30 + (i * (w-10)/nchan )), int(y + 5), int((w-10)/nchan), 30, "" + (i+1), fontInfo.buttonLabel_size);
      }

      //Set fist channel as active
      chans[0].setIsActive(true);
      chans[0].wasPressed = true;
    }

    public void draw() {
      pushStyle();

      float rx = x, ry = y, rw = w, rh =h;
      //Config Window Rectangle
      fill(211, 211, 211);
      rect(rx - 35, ry, rw, rh);

      //Serial Config Rectangle
      fill(190, 190, 190);
      rect(rx - 30, ry+90, rw- 10, rh-95);


      //Channel Configs
      fill(255, 255, 255);
      for (int i = 0; i < nchan; i++) {
        chans[i].draw();
      }
      drawAnalogSelection();
      drawThresholdSelection();
      drawMenuLists();

      print_lastmessage();
    }

    void drawAnalogSelection() {
      fill(233, 233, 233);
      rect(x-30, y+50, 165, 30);
      analog.draw();
      digital.draw();
      fill(50);
      text("Analog", x+20, y+63);
      text("Digital", x+90, y+63);
    }

    void drawThresholdSelection() {
      fill(233, 233, 233);
      rect(x+140, y+50, 230, 30);
      valueThreshold.draw();
      dynamicThreshold.draw();

      fill(50);
      textAlign(LEFT);
      textSize(13);
      text("Dynamic", x+167, y+68);
      text("Trip Value     %" + (double)Math.round((parent[lastChan].tripThreshold * 100) * 10d) / 10d, x+250, y+63);
      text("Untrip Value %"+ (double)Math.round((parent[lastChan].untripThreshold * 100) * 10d) / 10d, x+250, y+78);
    }

    void drawMenuLists() {
      fill(50);
      textFont(f1);
      textAlign(CENTER);
      textSize(18);
      text("Serial Out Configuration", x+160, y+120);

      textSize(14);
      textAlign(LEFT);
      text("Serial Port", x-10, y + 150);
      text("BAUD Rate", x+235, y+150);
      cp5Serial.get(MenuList.class, "serialListConfig").setVisible(true); //make sure the serialList menulist is visible
      cp5Serial.get(MenuList.class, "baudList").setVisible(true); //make sure the baudList menulist is visible

      connectToSerial.draw();
    }

    public void print_onscreen(String localstring) {
      textAlign(LEFT);
      fill(0);
      rect(x - 10, y + 290, (w-175), 40);
      fill(255);
      text(localstring, x, y + 290 + 15, ( w - 180), 40 -15);
      this.last_message = localstring;
    }

    void print_lastmessage() {
      textAlign(LEFT);
      fill(0);
      rect(x - 10, y + 290, (w-175), 40);
      fill(255);
      text(this.last_message, x, y + 290 + 15, ( w - 180), 40 -15);
    }
  }



  //============= TripSlider =============
  //=  Class for moving thresholds. Can  =
  //=  be dragged up and down, but lower =
  //=  thresholds cannot go above upper  =
  //=  thresholds (and visa versa).      =
  //======================================
  class TripSlider {
    //Fields
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
    color current_color = color(255, 255, 255);
    Motor_Widget parent;

    //Constructor
    TripSlider(int ix, int iy, int il, int iwid, int ilen, TripSlider[] o, boolean wastrip, Motor_Widget p) {
      lx = ix;
      ly = iy;
      stretch = il;
      wid = iwid;
      len = ilen;
      boxx = lx - wid/2;
      //boxx = lx;
      boxy = ly-stretch - len/2;
      //boxy = ly;
      others = o;
      trip = wastrip;  //Boolean to distinguish between trip and untrip thresholds
      parent = p;
    }

    //Called whenever thresholds are dragged
    void update(float tx, float ty) {
      boxx = lx;
      boxy = (wid + (ly/2)) - int(((wid + (ly/2)) - ly) * (float(stretch) / float(wid)));
      //boxy = ly + (ly - int( ly * (float(stretch) / float(wid)))) ;

      for (int i=0; i<others.length; i++) {
        if (others[i].locked == true) {
          otherslocked = true;
          break;
        } else {
          otherslocked = false;
        }
      }

      if (otherslocked == false) {
        overEvent(tx, ty);
        pressEvent();
      }

      if (press) {
        //Some of this may need to be refactored in order to support window resizing
        println("ty: " + ty + " ly: " + ly + " mouseY: " + mouseY + " boxy: " + boxy + " stretch: " + stretch + " width: " + wid);
        if (trip) stretch = lock(int(mouseY - (ty + ly)), int(parent.untripThreshold * (wid)), wid);
        else stretch = lock(int(map(((ty + ly) - mouseY), (-1) * (ty + ly) + wid - (ly/2), 0, 0, wid)), 0, int(parent.tripThreshold * (wid)));

        if ((ly - mouseY) > wid && trip) parent.tripThreshold = 1;
        else if ((ly - mouseY) > wid && !trip) parent.untripThreshold = 1;
        else if ((ly - mouseY) < 0 && trip) parent.tripThreshold = 0;
        else if ((ly - mouseY) < 0 && !trip) parent.untripThreshold = 0;
        else if (trip) parent.tripThreshold = float(ly - mouseY) / (wid);
        else if (!trip) parent.untripThreshold = float(ly - mouseY) / (wid);
      }
    }

    //Checks if mouse is here
    void overEvent(float tx, float ty) {
      if (overRect(int(boxx + tx), int(boxy + ty), wid, len)) {
        over = true;
      } else {
        over = false;
      }
    }

    //Checks if mouse is pressed
    void pressEvent() {
      if (over && mousePressed || locked) {
        press = true;
        locked = true;
      } else {
        press = false;
      }
    }

    //Mouse was released
    void releaseEvent() {
      locked = false;
    }

    //Color selector and cursor setter
    void setColor() {
      if (over) {
        current_color = color(127, 134, 143);
        if (!drawHand) {
          cursor(HAND);
          drawHand = true;
        }
      } else {
        if (trip) current_color = color(0, 255, 0);
        else current_color = color(255, 0, 0);
        if (drawHand) {
          cursor(ARROW);
          drawHand = false;
        }
      }
    }

    //Helper function to make setting default threshold values easier.
    //Expects a float as input (0.25 is 25%)
    void setStretchPercentage(float val) {
      stretch = lock(int((wid) * val), 0, wid);
    }

    //Displays the thresholds
    void display(float tx, float ty, float tw, float tl) {
      lx = int(tx);
      ly = int(ty);
      wid = int(tw);
      len = int(tl);

      fill(255);
      strokeWeight(0);
      stroke(255);
      setColor();
      fill(current_color);
      rect(boxx, boxy, wid, len);

      //rect(lx, ly, wid, len);
    }

    //Check if the mouse is here
    boolean overRect(int lx, int ly, int twidth, int theight) {
      if (mouseX >= lx && mouseX <= lx+twidth && 
        mouseY >= ly && mouseY <= ly+theight) {

        return true;
      } else {
        return false;
      }
    }

    //Locks the threshold in place
    int lock(int val, int minv, int maxv) {
      return  min(max(val, minv), maxv);
    }
  }



  //===================== DIGITAL EVENTS =============================
  //=  Digital Events work by tripping certain thresholds, and then  =
  //=  untripping said thresholds. In order to use digital events    =
  //=  you will need to observe the switchCounter field in any       =
  //=  given channel. Check out the OpenBionics Switch Example       =
  //=  in the process() function above to get an idea of how to do   =
  //=  this. It is important that your observation of switchCounter  =
  //=  is done in the process() function AFTER the Digital Events    =
  //=  are evoked.                                                   =
  //=                                                                =
  //=  This system supports both digital and analog events           =
  //=  simultaneously and seperated.                                 =
  //==================================================================

  //Channel 1 Event
  void digitalEventChan0(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (motorWidgets[0].switchCounter > 4) motorWidgets[0].switchCounter = 0;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 2 Event
  void digitalEventChan1(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 3 Event
  void digitalEventChan2(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 4 Event
  void digitalEventChan3(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 5 Event
  void digitalEventChan4(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 6 Event
  void digitalEventChan5(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 7 Event
  void digitalEventChan6(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 8 Event
  void digitalEventChan7(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 9 Event
  void digitalEventChan8(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 10 Event
  void digitalEventChan9(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 11 Event
  void digitalEventChan10(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 12 Event
  void digitalEventChan11(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 13 Event
  void digitalEventChan12(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 14 Event
  void digitalEventChan13(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 15 Event
  void digitalEventChan14(Motor_Widget cfc) {
    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }

  //Channel 16 Event
  void digitalEventChan15(Motor_Widget cfc) {

    //Local instances of Motor_Widget fields
    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;

    //Custom waiting threshold
    int timeToWaitThresh = 750;

    if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
      //Tripped
      cfc.switchTripped = true;
      cfc.timeOfLastTrip = millis();
      cfc.switchCounter++;
    }
    if (switchTripped && output_normalized <= untripThreshold) {
      //Untripped
      cfc.switchTripped = false;
    }
  }


  //===================== ANALOG EVENTS ===========================
  //=  Analog events are a big more complicated than digital      =
  //=  events. In order to use analog events you must map the     =
  //=  output_normalized value to whatver minimum and maximum     =
  //=  you'd like and then write that to the serialOutEMG.        =
  //=                                                             =
  //=  Check out analogEventChan0() for the OpenBionics analog    =
  //=  event example to get an idea of how to use analog events.  =
  //===============================================================

  //Channel 1 Event
  void analogEventChan0(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;


    //================= OpenBionics Analog Movement Example =======================
    if (serialOutEMG != null) {
      //println("Output normalized: " + int(map(output_normalized, 0, 1, 0, 100)));
      if (int(map(output_normalized, 0, 1, 0, 100)) > 10) {
        serialOutEMG.write("G0P" + int(map(output_normalized, 0, 1, 0, 100)));
        delay(10);
      } else serialOutEMG.write("G0P0");
    }
  }

  //Channel 2 Event
  void analogEventChan1(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 3 Event
  void analogEventChan2(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 4 Event
  void analogEventChan3(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 5 Event
  void analogEventChan4(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 6 Event
  void analogEventChan5(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 7 Event
  void analogEventChan6(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 8 Event
  void analogEventChan7(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 9 Event
  void analogEventChan8(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 10 Event
  void analogEventChan9(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 11 Event
  void analogEventChan10(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 12 Event
  void analogEventChan11(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 13 Event
  void analogEventChan12(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 14 Event
  void analogEventChan13(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 15 Event
  void analogEventChan14(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }

  //Channel 16 Event
  void analogEventChan15(Motor_Widget cfc) {

    float output_normalized = cfc.output_normalized;
    float tripThreshold = cfc.tripThreshold;
    float untripThreshold = cfc.untripThreshold;
    boolean switchTripped = cfc.switchTripped;
    float timeOfLastTrip = cfc.timeOfLastTrip;
  }
}