
//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

DataProcessing_User dataProcessing_user;
boolean drawEMG = false; //if true... toggles on EEG_Processing_User.draw and toggles off the headplot in Gui_Manager

//------------------------------------------------------------------------
//                            Classes
//------------------------------------------------------------------------

class DataProcessing_User {
  private float fs_Hz;  //sample rate
  private int nchan;  
  
  boolean switchesActive = false;

  //Left Eye Variables
  boolean isTriggered_L = false;
  float upperThreshold_L = 25;  //default uV upper threshold value ... this will automatically change over time
  float lowerThreshold_L = 0;  //default uV lower threshold value ... this will automatically change over time
  int averagePeriod_L = 125;  //number of data packets to average over (250 = 1 sec)
  int thresholdPeriod_L = 1250;  //number of packets
  int ourChan_L = 1 - 1;  //channel being monitored ... "3 - 1" means channel 3 (with a 0 index)
  float myAverage_L = 0.0;   //this will change over time ... used for calculations below
  float acceptableLimitUV_L = 200;  //uV values above this limit are excluded, as a result of them almost certainly being noise...
  int uncounted_L = 0;
  //prez related
  boolean switchTripped_L = false;
  int switchCounter_L = 0;
  float timeOfLastTrip_L = 0;
  float tripThreshold_L = 0.75;
  float untripThreshold_L = 0.6;

  //Right Eye Variables
  boolean isTriggered_R = false;
  float upperThreshold_R= 25;  //default uV upper threshold value ... this will automatically change over time
  float lowerThreshold_R = 0;  //default uV lower threshold value ... this will automatically change over time
  int averagePeriod_R = 125;  //number of data packets to average over (250 = 1 sec)
  int thresholdPeriod_R = 1250;  //number of packets
  int ourChan_R = 2 - 1;  //channel being monitored ... "3 - 1" means channel 3 (with a 0 index)
  float myAverage_R = 0.0;   //this will change over time ... used for calculations below
  float acceptableLimitUV_R = 200;  //uV values above this limit are excluded, as a result of them almost certainly being noise... 
  int uncounted_R = 0;
  //prez related
  boolean switchTripped_R = false;
  int switchCounter_R = 0;
  float timeOfLastTrip_R = 0;
  float tripThreshold_R = 0.75;
  float untripThreshold_R = 0.60;

  //add your own variables here
  boolean isTriggered = false;  //boolean to keep track of when the trigger condition is met
  float upperThreshold = 25;  //default uV upper threshold value ... this will automatically change over time
  float lowerThreshold = 0;  //default uV lower threshold value ... this will automatically change over time
  int averagePeriod = 125;  //number of data packets to average over (250 = 1 sec)
  int thresholdPeriod = 1250;  //number of packets
  int ourChan = 3 - 1;  //channel being monitored ... "3 - 1" means channel 3 (with a 0 index)
  float myAverage = 0.0;   //this will change over time ... used for calculations below
  float acceptableLimitUV = 150;  //uV values above this limit are excluded, as a result of them almost certainly being noise...
  boolean switchTripped = false;
  int switchCounter = 0;
  float timeOfLastTrip = 0;
  float tripThreshold = 0.50;
  float untripThreshold = 0.30;

  //if writing to a serial port
  int output = 0; //value between 0-255 that is the relative position of the current uV average between the rolling lower and upper uV thresholds
  float output_normalized = 0;  //converted to between 0-1
  float output_adjusted = 0;  //adjusted depending on range that is expected on the other end, ie 0-255?

  //if writing to a serial port
  int output_L = 0; //value between 0-255 that is the relative position of the current uV average between the rolling lower and upper uV thresholds
  float output_normalized_L = 0;  //converted to between 0-1
  float output_adjusted_L = 0;  //adjusted depending on range that is expected on the other end, ie 0-255?

  //if writing to a serial port
  int output_R = 0; //value between 0-255 that is the relative position of the current uV average between the rolling lower and upper uV thresholds
  float output_normalized_R = 0;  //converted to between 0-1
  float output_adjusted_R = 0;  //adjusted depending on range that is expected on the other end, ie 0-255?

  //class constructor
  DataProcessing_User(int NCHAN, float sample_rate_Hz) {
    nchan = NCHAN;
    fs_Hz = sample_rate_Hz;
  }

  //add some functions here...if you'd like

  //here is the processing routine called by the OpenBCI main program...update this with whatever you'd like to do
  public void process(float[][] data_newest_uV, //holds raw bio data that is new since the last call
    float[][] data_long_uV, //holds a longer piece of buffered EEG data, of same length as will be plotted on the screen
    float[][] data_forDisplay_uV, //this data has been filtered and is ready for plotting on the screen
    FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

    //for example, you could loop over each EEG channel to do some sort of time-domain processing 
    //using the sample values that have already been filtered, as will be plotted on the display
    float EEG_value_uV;

    //chan 3
    myAverage = 0.0;
    for (int i = data_forDisplay_uV[ourChan].length - averagePeriod; i < data_forDisplay_uV[ourChan].length; i++) {
      if (abs(data_forDisplay_uV[ourChan][i]) <= acceptableLimitUV) { //prevent BIG spikes from effecting the average
        myAverage += abs(data_forDisplay_uV[ourChan][i]);  //add value to average ... we will soon divide by # of packets
      }
    }
    myAverage = myAverage / float(averagePeriod); //finishing the average

    //Left Eye -- Chan 1
    myAverage_L = 0.0;
    for (int i = data_forDisplay_uV[ourChan_L].length - averagePeriod_L; i < data_forDisplay_uV[ourChan_L].length; i++) {
      if (abs(data_forDisplay_uV[ourChan_L][i]) <= acceptableLimitUV_L) { //prevent BIG spikes from effecting the average
        myAverage_L += abs(data_forDisplay_uV[ourChan_L][i]);  //add value to average ... we will soon divide by # of packets
      } else {
        myAverage_L += acceptableLimitUV_L; //if it's greater than the limit, just add the limit
      }
    }
    myAverage_L = myAverage_L / float(averagePeriod_L); //finishing the average
    uncounted_L = 0;
    //println("myAverage_L = " + myAverage_L);

    //Right Eye -- Chan 2
    myAverage_R = 0.0;
    for (int i = data_forDisplay_uV[ourChan_R].length - averagePeriod_R; i < data_forDisplay_uV[ourChan_R].length; i++) {
      if (abs(data_forDisplay_uV[ourChan_R][i]) <= acceptableLimitUV_R) { //prevent BIG spikes from effecting the average
        myAverage_R += abs(data_forDisplay_uV[ourChan_R][i]);  //add value to average ... we will soon divide by # of packets
      } else {
        myAverage_R += acceptableLimitUV_R;
      }
    }

    myAverage_R = myAverage_R / float(averagePeriod_R); //finishing the average
    uncounted_R = 0;
    //println("uncounted_R" + uncounted_R);
    //println("averagePeriod_R = " + averagePeriod_R);
    //println("myAverage_R = " + myAverage_R); 
    //println("------------------");

    //--------------------- some conditionals -- CHAN 3 -------------------------

    if (myAverage >= upperThreshold && myAverage <= acceptableLimitUV) { // 
      upperThreshold = myAverage;
    }

    if (myAverage <= lowerThreshold) {
      lowerThreshold = myAverage;
    }

    if (upperThreshold >= myAverage) {
      upperThreshold -= (upperThreshold - 25)/(frameRate * 5); //have upper threshold creep downwards to keep range tight
    }

    if (lowerThreshold <= myAverage) {
      lowerThreshold += (25 - lowerThreshold)/(frameRate * 5); //have lower threshold creep upwards to keep range tight
    }

    output = (int)map(myAverage, lowerThreshold, upperThreshold, 0, 255);
    output_normalized = map(myAverage, lowerThreshold, upperThreshold, 0, 1);
    output_adjusted = ((-0.1/(output_normalized*255.0)) + 255.0);

    //trip the output to a value between 0-255
    if (output < 0) output = 0;
    if (output > 255) output = 255;

    //attempt to write to serial_output. If this serial port does not exist, do nothing.
    try {
      //println("inMoov_output: | " + output + " |");
      serial_output.write(output);
    }
    catch(RuntimeException e) {
      if (isVerbose) println("serial not present");
    }

    //------------------ LEFT EYE & RIGHT EYE ------------------------- //

    //LEFT
    if (myAverage_L >= upperThreshold_L && myAverage_L <= acceptableLimitUV_L) { // 
      upperThreshold_L = myAverage_L;
    }
    if (myAverage_L <= lowerThreshold_L) {
      lowerThreshold_L = myAverage_L;
    }
    if (upperThreshold_L >= (myAverage_L + 35)) {
      //upperThreshold_L -= (upperThreshold_L)/(frameRate * 5); //have upper threshold creep downwards to keep range tight
      upperThreshold_L *= .97;
    }
    if (lowerThreshold_L <= myAverage_L) {
      lowerThreshold_L += (10 - lowerThreshold_L)/(frameRate * 5); //have lower threshold creep upwards to keep range tight
    }
    //output_L = (int)map(myAverage_L, lowerThreshold_L, upperThreshold_L, 0, 255);
    output_normalized_L = map(myAverage_L, lowerThreshold_L, upperThreshold_L, 0, 1);
    //output_adjusted_L = ((-0.1/(output_normalized_L*255.0)) + 255.0);

    //RIGHT
    if (myAverage_R >= upperThreshold_R && myAverage_R <= acceptableLimitUV_R) { // 
      upperThreshold_R = myAverage_R;
    }
    if (myAverage_R <= lowerThreshold_R) {
      lowerThreshold_R = myAverage_R;
    }
    if (upperThreshold_R >= myAverage_R + 35) {
      //upperThreshold_R -= (upperThreshold_R - 25)/(frameRate * 5); //have upper threshold creep downwards to keep range tight
      upperThreshold_R *= .97;
    }
    if (lowerThreshold_R <= myAverage_R) {
      lowerThreshold_R += (10 - lowerThreshold_R)/(frameRate * 5); //have lower threshold creep upwards to keep range tight
    }
    //output_L = (int)map(myAverage_L, lowerThreshold_L, upperThreshold_L, 0, 255);
    output_normalized_R = map(myAverage_R, lowerThreshold_R, upperThreshold_R, 0, 1);
    //output_adjusted_L = ((-0.1/(output_normalized_L*255.0)) + 255.0);

    //======================= TRIPPING SWITCHES ==========================//
    if (switchesActive) {
      // =========================== RIGHT ================================ //
      if (output_normalized_L >= tripThreshold_L && switchTripped_L == false && (millis() - timeOfLastTrip_L) >= 2000 && switchTripped_R == false) {
        println("switchTripped_L = true");
        switchTripped_L = true;
        timeOfLastTrip_L = millis();
        switchCounter_L = 1;
      }

      if (output_normalized_R >= tripThreshold_R && switchTripped_R == false && (millis() - timeOfLastTrip_R) >= 2000 && switchTripped_L == false) {
        println("switchTripped_R = true");
        switchTripped_R = true;
        timeOfLastTrip_R = millis();
        switchCounter_R = 1;
      }
      if ((millis() - timeOfLastTrip_R) >= 750 && (millis() - timeOfLastTrip_R) <= 1250) {
        println("sweet zone R");
        if (switchTripped_L) {
          switchTripped_L = false;
          myPresentation.slideBack();
        }
      }
      //=========================== LEFT ================================
      if ((millis() - timeOfLastTrip_L) >= 750 && (millis() - timeOfLastTrip_L) <= 1250) {
        println("sweet zone L");
        if (switchTripped_R) {
          switchTripped_R = false;
          myPresentation.slideForward();
        }
      }
      if (millis() - timeOfLastTrip_L >= 250) {
        switchTripped_L = false;
        switchCounter_L = 0;
      }
      if (millis() - timeOfLastTrip_R >= 250) {
        switchTripped_R = false;
        switchCounter_R = 0;
      }
      //============================= JAW ===================================
      if (output_normalized >= tripThreshold && switchTripped == false && millis() - timeOfLastTrip >= 750) {
        switchTripped = true; 
        switchCounter++;
        timeOfLastTrip = millis();
      }
      if (switchTripped == true && output_normalized <= untripThreshold) {
        switchTripped = false;
      }
    }

    if (millis() - timeOfLastTrip >= 1250) {
      if (switchCounter == 1) {
        //do nothing 
        println("Reset Switch...");
      } else if (switchCounter == 2) {
        //do nothing 
        //lock slides
        myPresentation.lockSlides = !myPresentation.lockSlides;
        println("Lock Slides");
      } else if (switchCounter == 3) {
        //next slide
        drawPresentation = !drawPresentation;
        println("Next Slide!");
      } else if (switchCounter == 4) {
        //previous slide
        println("Previous Slide!!!");
        myPresentation.slideBack();
      } else if (switchCounter == 5) {
        //previous slide
        drawPresentation = !drawPresentation;
        println("Turning on presentation!!!");
      } else if (switchCounter == 6) {
        //previous slide
        //      robotHand = !robotHand;
        println("Turn Robot Hand ON/OFF!!!");
      }
      switchCounter = 0; //reset switch counter
    }

    ////--RIGHT
    //if (output_normalized_R >= tripThreshold_R && switchTripped_R == false && millis() - timeOfLastTrip_R >= 750) {
    //  switchTripped_R = true; 
    //  switchCounter_R++;
    //  timeOfLastTrip_R = millis();
    //}
    //if (switchTripped_R == true && output_normalized_R <= untripThreshold_R) {
    //  switchTripped_R = false;
    //} 
    //if (millis() - timeOfLastTrip_R >= 1250) {
    //  if (switchCounter_R == 1) {
    //    if (output_normalized_L >= tripThreshold_L && switchTripped_L == false && millis() - timeOfLastTrip_L >= 750) {
    //      switchTripped_L = true; 
    //      switchCounter_L++;
    //      timeOfLastTrip_L = millis();
    //      myPresentation.slideBack();
    //    }
    //    println("Reset Switch...");
    //  } else if (switchCounter_R == 2) {
    //    //do nothing 
    //    println("Reset Switch...");
    //  } else if (switchCounter_R == 3) {
    //    //next slide
    //    myPresentation.slideForward();
    //    println("Next Slide!");
    //  } else if (switchCounter_R == 4) {
    //    //previous slide
    //    println("Previous Slide!!!");
    //    myPresentation.slideBack();
    //  } else if (switchCounter_R == 5) {
    //    //previous slide
    //    drawPresentation = !drawPresentation;
    //    println("Turning on presentation!!!");
    //  } else if (switchCounter_R == 6) {
    //    //previous slide
    //  //      robotHand = !robotHand;
    //    println("Turn Robot Hand ON/OFF!!!");
    //  }
    //  switchCounter_R = 0; //reset switch counter
    //}
    //==================================================================

    //if switchCounter_L was triggered between 800 & 1200 ms ago
    //and switchCounter_R is triggered
    //go forward 1 slide


    //if switchCounter_R was triggered between 800 & 1200 ms ago
    //and switchCounter_L is triggered
    //go back 1 slide

    //OR, you could loop over each EEG channel and do some sort of frequency-domain processing from the FFT data
    float FFT_freq_Hz, FFT_value_uV;
    for (int Ichan=0; Ichan < nchan; Ichan++) {
      //loop over each new sample
      for (int Ibin=0; Ibin < fftBuff[Ichan].specSize(); Ibin++) {
        FFT_freq_Hz = fftData[Ichan].indexToFreq(Ibin);
        FFT_value_uV = fftData[Ichan].getBand(Ibin);

        //add your processing here...

        //println("EEG_Processing_User: Ichan = " + Ichan + ", Freq = " + FFT_freq_Hz + "Hz, FFT Value = " + FFT_value_uV + "uV/bin");
      }
    }
  }

  public void draw() {
    if (drawEMG) {
      pushStyle();

      //circle for outer threshold
      noFill();
      stroke(0, 255, 0);
      strokeWeight(2);
      float scaleFactor = 1.0;
      float scaleFactorJaw = 1.5;

      //LEFT -- draw visualizer
      pushMatrix();
      translate((-width)/8.0, 0);
      ellipse(3*(width/4), height/4, scaleFactor * upperThreshold_L, scaleFactor * upperThreshold_L);
      //circle for inner threshold
      stroke(0, 255, 255);
      ellipse(3*(width/4), height/4, scaleFactor * lowerThreshold_L, scaleFactor * lowerThreshold_L);
      //realtime 
      fill(255, 0, 0, 125);
      noStroke();
      ellipse(3*(width/4), height/4, scaleFactor * myAverage_L, scaleFactor * myAverage_L);
      //draw background bar for mapped uV value indication
      fill(0, 255, 255, 125);
      rect(13*(width/16), height/8, (width/64), (height/4));
      //draw real time bar of actually mapped value
      fill(0, 255, 255);
      rect(13*(width/16), 3*(height/8), (width/64), map(output_normalized_L, 0, 1, 0, (-1) * (height/4)));
      popMatrix();

      noFill();
      stroke(0, 255, 0);
      strokeWeight(2);

      //RIGHT -- draw visualizer
      pushMatrix();
      translate(width/8, 0);
      ellipse(3*(width/4), height/4, scaleFactor * upperThreshold_R, scaleFactor * upperThreshold_R);
      //circle for inner threshold
      stroke(0, 255, 255);
      ellipse(3*(width/4), height/4, scaleFactor * lowerThreshold_R, scaleFactor * lowerThreshold_R);
      //realtime 
      fill(255, 0, 0, 125);
      noStroke();
      ellipse(3*(width/4), height/4, scaleFactor * myAverage_R, scaleFactor * myAverage_R);
      //draw background bar for mapped uV value indication
      fill(0, 255, 255, 125);
      rect(13*(width/16), height/8, (width/64), (height/4));
      //draw real time bar of actually mapped value
      fill(0, 255, 255);
      rect(13*(width/16), 3*(height/8), (width/64), map(output_normalized_R, 0, 1, 0, (-1) * (height/4)));
      popMatrix();

      //circle for outer threshold
      noFill();
      stroke(0, 255, 0);
      strokeWeight(2);
      ellipse(3*(width/4), height/4, scaleFactorJaw * upperThreshold, scaleFactorJaw * upperThreshold);
      //circle for inner threshold
      stroke(0, 255, 255);
      ellipse(3*(width/4), height/4, scaleFactorJaw * lowerThreshold, scaleFactorJaw * lowerThreshold);
      //realtime 
      fill(255, 0, 0, 125);
      noStroke();
      ellipse(3*(width/4), height/4, scaleFactorJaw * myAverage, scaleFactorJaw * myAverage);
      //draw background bar for mapped uV value indication
      fill(0, 255, 255, 125);
      rect(13*(width/16), height/8, (width/64), (height/4));
      //draw real time bar of actually mapped value
      fill(0, 255, 255);
      rect(13*(width/16), 3*(height/8), (width/64), map(output_normalized, 0, 1, 0, (-1) * (height/4)));

      popStyle();
    }
    drawTriggerFeedback();
  } //end of draw

  public void drawTriggerFeedback() {
    //Is the board streaming data?
    //if so ... draw left eye trigger feedback
    if (isRunning) {
      //LEFT
      if (dataProcessing_user.switchCounter_L == 1) {
        //draw red circle
        fill(255, 0, 0);
        ellipse(width/2-40, height - 40, 20, 20);
        noFill();
        ellipse(width/2+40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_L == 2) {
        //draw green circle
        fill(0, 255, 0);
        ellipse(width/2-40, height - 40, 20, 20);
        noFill();
        ellipse(width/2+40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_L == 3) {
        //draw blue circle
        fill(0, 0, 255);
        ellipse(width/2-40, height - 40, 20, 20);
        noFill();
        ellipse(width/2+40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_L == 4) {
        //draw blue circle
        fill(0, 255, 255);
        ellipse(width/2-40, height - 40, 20, 20);
        noFill();
        ellipse(width/2+40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_L == 5) {
        //draw blue circle
        fill(255, 255, 0);
        ellipse(width/2-40, height - 40, 20, 20);
        noFill();
        ellipse(width/2+40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_L == 6) {
        //draw blue circle
        fill(255, 0, 255);
        ellipse(width/2-40, height - 40, 20, 20);
        noFill();
        ellipse(width/2+40, height - 40, 20, 20);
      }

      //RIGHT
      if (dataProcessing_user.switchCounter_R == 1) {
        //draw red circle
        fill(255, 0, 0);
        ellipse(width/2+40, height - 40, 20, 20);
        noFill();
        ellipse(width/2-40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_R == 2) {
        //draw green circle
        fill(0, 255, 0);
        ellipse(width/2+40, height - 40, 20, 20);
        noFill();
        ellipse(width/2-40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_R == 3) {
        //draw blue circle
        fill(0, 0, 255);
        ellipse(width/2+40, height - 40, 20, 20);
        noFill();
        ellipse(width/2-40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_R == 4) {
        //draw blue circle
        fill(0, 255, 255);
        ellipse(width/2+40, height - 40, 20, 20);
        noFill();
        ellipse(width/2-40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_R == 5) {
        //draw blue circle
        fill(255, 255, 0);
        ellipse(width/2+40, height - 40, 20, 20);
        noFill();
        ellipse(width/2-40, height - 40, 20, 20);
      } else if (dataProcessing_user.switchCounter_R == 6) {
        //draw blue circle
        fill(255, 0, 255);
        ellipse(width/2+40, height - 40, 20, 20);
        noFill();
        ellipse(width/2-40, height - 40, 20, 20);
      }

      if (switchCounter == 1) {
        //draw red circle
        fill(255, 0, 0);
        ellipse(width/2, height - 40, 20, 20);
      } else if (switchCounter == 2) {
        //draw green circle
        fill(0, 255, 0);
        ellipse(width/2, height - 40, 20, 20);
      } else if (switchCounter == 3) {
        //draw blue circle
        fill(0, 0, 255);
        ellipse(width/2, height - 40, 20, 20);
      }
    }
  }
};