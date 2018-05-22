
////////////////////////////////////////////////////
//
//    W_PulseSensor.pde
//
//    Created: Joel Murphy, Spring 2017
//
///////////////////////////////////////////////////,

class W_PulseSensor extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...


  color graphStroke = #d2d2d2;
  color graphBG = #f5f5f5;
  color textColor = #000000;

// Pulse Sensor Visualizer Stuff
  int count = 0;
  int heart = 0;
  int PulseBuffSize = dataPacketBuff.length; // Originally 400
  int BPMbuffSize = 100;

  int PulseWindowWidth;
  int PulseWindowHeight;
  int PulseWindowX;
  int PulseWindowY;
  int BPMwindowWidth;
  int BPMwindowHeight;
  int BPMwindowX;
  int BPMwindowY;
  int BPMposX;
  int BPMposY;
  int IBIposX;
  int IBIposY;
  int padding = 15;
  color eggshell;
  color pulseWave;
  int[] PulseWaveY;      // HOLDS HEARTBEAT WAVEFORM DATA
  int[] BPMwaveY;        // HOLDS BPM WAVEFORM DATA
  boolean rising;

  // Synthetic Wave Generator Stuff
  float theta;  // Start angle at 0
  float amplitude;  // Height of wave
  int syntheticMultiplier;
  long thisTime;
  long thatTime;
  int refreshRate;

  // Pulse Sensor Beat Finder Stuff
  // ASSUMES 250Hz SAMPLE RATE
  int[] rate;                    // array to hold last ten IBI values
  int sampleCounter;          // used to determine pulse timing
  int lastBeatTime;           // used to find IBI
  int P =512;                      // used to find peak in pulse wave, seeded
  int T = 512;                     // used to find trough in pulse wave, seeded
  int thresh = 530;                // used to find instant moment of heart beat, seeded
  int amp = 0;                   // used to hold amplitude of pulse waveform, seeded
  boolean firstBeat = true;        // used to seed rate array so we startup with reasonable BPM
  boolean secondBeat = false;      // used to seed rate array so we startup with reasonable BPM
  int BPM;                   // int that holds raw Analog in 0. updated every 2mS
  int Signal;                // holds the incoming raw data
  int IBI = 600;             // int that holds the time interval between beats! Must be seeded!
  boolean Pulse = false;     // "True" when User's live heartbeat is detected. "False" when not a "live beat".
  boolean QS = false;        // becomes true when Arduoino finds a beat.
  int lastProcessedDataPacketInd = 0;
  boolean analogReadOn = false;

  // testing stuff

  Button analogModeButton;



  W_PulseSensor(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)



    // Pulse Sensor Stuff
    eggshell = color(255, 253, 248);
    pulseWave = color(224, 56, 45);

    PulseWaveY = new int[PulseBuffSize];
    BPMwaveY = new int[BPMbuffSize];
    rate = new int[10];
    setPulseWidgetVariables();
    initializePulseFinderVariables();

    analogModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "Turn Analog Read On", 12);
    analogModeButton.setCornerRoundess((int)(navHeight-6));
    analogModeButton.setFont(p6,10);
    analogModeButton.setColorNotPressed(color(57,128,204));
    analogModeButton.textColorNotActive = color(255);
    analogModeButton.hasStroke(false);
    analogModeButton.setHelpText("Click this button to activate analog reading on the Cyton");

  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    if (curDataPacketInd < 0) return;

    if (eegDataSource == DATASOURCE_CYTON) {  // LIVE FROM CYTON

    } else if (eegDataSource == DATASOURCE_GANGLION) {  // LIVE FROM GANGLION

    } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  // SYNTHETIC

    }
    else {  // PLAYBACK

    }

    int numSamplesToProcess = curDataPacketInd - lastProcessedDataPacketInd;
    if (numSamplesToProcess < 0) {
      numSamplesToProcess += dataPacketBuff.length; //<>// //<>//
    }
    // Shift internal ring buffer numSamplesToProcess
    if (numSamplesToProcess > 0) {
      for(int i=0; i < PulseWaveY.length - numSamplesToProcess; i++){
        PulseWaveY[i] = PulseWaveY[i+numSamplesToProcess]; //<>// //<>//
      }
    }

    // for each new sample
    int samplesProcessed = 0;
    while (samplesProcessed < numSamplesToProcess) {
      lastProcessedDataPacketInd++;

      // Watch for wrap around
      if (lastProcessedDataPacketInd > dataPacketBuff.length - 1) {
        lastProcessedDataPacketInd = 0;
      }

      int signal = dataPacketBuff[lastProcessedDataPacketInd].auxValues[0];

      processSignal(signal);
      PulseWaveY[PulseWaveY.length - numSamplesToProcess + samplesProcessed] = signal; //<>// //<>//

      samplesProcessed++;
    }

    if(QS){
      QS = false;
      for(int i=0; i<BPMwaveY.length-1; i++){
        BPMwaveY[i] = BPMwaveY[i+1];
      }
      BPMwaveY[BPMwaveY.length-1] = BPM;
    }

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)


    //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    pushStyle();


    fill(graphBG);
    stroke(graphStroke);
    rect(PulseWindowX,PulseWindowY,PulseWindowWidth,PulseWindowHeight);
    rect(BPMwindowX,BPMwindowY,BPMwindowWidth,BPMwindowHeight);

    fill(50);
    textFont(p4, 16);
    textAlign(LEFT,CENTER);
    text("BPM "+BPM, BPMposX, BPMposY);
    text("IBI "+IBI+"mS", IBIposX, IBIposY);

    if (analogReadOn) {
      drawWaves();
    }

    analogModeButton.draw();

    popStyle();
  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    println("Pulse Sensor Widget -- Screen Resized.");

    setPulseWidgetVariables();
    analogModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    if (analogModeButton.isMouseHere()) {
      analogModeButton.setIsActive(true);
    }
  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(analogModeButton.isActive && analogModeButton.isMouseHere()){
      // println("analogModeButton...");
      if(cyton.isPortOpen()) {
        if (analogReadOn) {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
          analogModeButton.setString("Turn Analog Read On");
        } else {
          cyton.setBoardMode(BOARD_MODE_ANALOG);
          output("Starting to read analog inputs on pin marked D11");
          analogModeButton.setString("Turn Analog Read Off");
        }
        analogReadOn = !analogReadOn;
      }
    }
    analogModeButton.setIsActive(false);
  }

  //add custom functions here
  void setPulseWidgetVariables(){
    PulseWindowWidth = ((w/4)*3) - padding;
    PulseWindowHeight = h - padding *2;
    PulseWindowX = x + padding;
    PulseWindowY = y + h - PulseWindowHeight - padding;

    BPMwindowWidth = w/4 - (padding + padding/2);
    BPMwindowHeight = PulseWindowHeight; // - padding;
    BPMwindowX = PulseWindowX + PulseWindowWidth + padding/2;
    BPMwindowY = PulseWindowY; // + padding;

    BPMposX = BPMwindowX + padding/2;
    BPMposY = y - padding; // BPMwindowHeight + int(float(padding)*2.5);
    IBIposX = PulseWindowX + PulseWindowWidth/2; // + padding/2
    IBIposY = y - padding;

    // float py;
    // float by;
    // for(int i=0; i<PulseWaveY.length; i++){
    //   py = map(float(PulseWaveY[i]),
    //     0.0,1023.0,
    //     float(PulseWindowY + PulseWindowHeight),float(PulseWindowY)
    //   );
    //   PulseWaveY[i] = int(py);
    // }
    // for(int i=0; i<BPMwaveY.length; i++){
    //   BPMwaveY[i] = BPMwindowY + BPMwindowHeight-1;
    // }
  }

  void initializePulseFinderVariables(){
    sampleCounter = 0;
    lastBeatTime = 0;
    P = 512;
    T = 512;
    thresh = 530;
    amp = 0;
    firstBeat = true;
    secondBeat = false;
    BPM = 0;
    Signal = 512;
    IBI = 600;
    Pulse = false;
    QS = false;

    theta = 0.0;
    amplitude = 300;
    syntheticMultiplier = 1;

    thatTime = millis();

    // float py = map(float(Signal),
    //   0.0,1023.0,
    //   float(PulseWindowY + PulseWindowHeight),float(PulseWindowY)
    // );
    for(int i=0; i<PulseWaveY.length; i++){
      PulseWaveY[i] = Signal;

      // PulseWaveY[i] = PulseWindowY + PulseWindowHeight/2;
    }
    for(int i=0; i<BPMwaveY.length; i++){
      BPMwaveY[i] = BPM;
    }

  }

  void drawWaves(){
    int xi, yi;
    noFill();
    strokeWeight(1);
    stroke(pulseWave);
    beginShape();                                  // using beginShape() renders fast
    for(int i=0; i<PulseWaveY.length; i++){
      xi = int(map(i,0, PulseWaveY.length-1,0, PulseWindowWidth-1));
      xi += PulseWindowX;
      yi = int(map(PulseWaveY[i],0.0,1023.0,
        float(PulseWindowY + PulseWindowHeight),float(PulseWindowY)));
      vertex(xi, yi);
    }
    endShape();

    strokeWeight(2);
    stroke(pulseWave);
    beginShape();                                  // using beginShape() renders fast
    for(int i=0; i<BPMwaveY.length; i++){
      xi = int(map(i,0, BPMwaveY.length-1,0, BPMwindowWidth-1));
      xi += BPMwindowX;
      yi = int(map(BPMwaveY[i], 0.0,200.0,
        float(BPMwindowY + BPMwindowHeight), float(BPMwindowY)));
      vertex(xi, yi);
    }
    endShape();

  }

  // THIS IS THE BEAT FINDING FUNCTION
  // BASED ON CODE FROM World Famous Electronics, MAKERS OF PULSE SENSOR
  // https://github.com/WorldFamousElectronics/PulseSensor_Amped_Arduino
  void processSignal(int sample){                         // triggered when Timer2 counts to 124
    // cli();                                      // disable interrupts while we do this
    // Signal = analogRead(pulsePin);              // read the Pulse Sensor
    sampleCounter += (4 * syntheticMultiplier);                         // keep track of the time in mS with this variable
    int N = sampleCounter - lastBeatTime;       // monitor the time since the last beat to avoid noise

      //  find the peak and trough of the pulse wave
    if(sample < thresh && N > (IBI/5)*3){       // avoid dichrotic noise by waiting 3/5 of last IBI
      if (sample < T){                        // T is the trough
        T = sample;                         // keep track of lowest point in pulse wave
      }
    }

    if(sample > thresh && sample > P){          // thresh condition helps avoid noise
      P = sample;                             // P is the peak
    }                                        // keep track of highest point in pulse wave

    //  NOW IT'S TIME TO LOOK FOR THE HEART BEAT
    // signal surges up in value every time there is a pulse
    if (N > 250){                                   // avoid high frequency noise
      if ( (sample > thresh) && (Pulse == false) && (N > (IBI/5)*3) ){
        Pulse = true;                               // set the Pulse flag when we think there is a pulse
        IBI = sampleCounter - lastBeatTime;         // measure time between beats in mS
        lastBeatTime = sampleCounter;               // keep track of time for next pulse

        if(secondBeat){                        // if this is the second beat, if secondBeat == TRUE
          secondBeat = false;                  // clear secondBeat flag
          for(int i=0; i<=9; i++){             // seed the running total to get a realisitic BPM at startup
            rate[i] = IBI;
          }
        }

        if(firstBeat){                         // if it's the first time we found a beat, if firstBeat == TRUE
          firstBeat = false;                   // clear firstBeat flag
          secondBeat = true;                   // set the second beat flag
          // sei();                               // enable interrupts again
          return;                              // IBI value is unreliable so discard it
        }


        // keep a running total of the last 10 IBI values
        int runningTotal = 0;                  // clear the runningTotal variable

        for(int i=0; i<=8; i++){                // shift data in the rate array
          rate[i] = rate[i+1];                  // and drop the oldest IBI value
          runningTotal += rate[i];              // add up the 9 oldest IBI values
        }

        rate[9] = IBI;                          // add the latest IBI to the rate array
        runningTotal += rate[9];                // add the latest IBI to runningTotal
        runningTotal /= 10;                     // average the last 10 IBI values
        BPM = 60000/runningTotal;               // how many beats can fit into a minute? that's BPM!
        BPM = constrain(BPM,0,200);
        QS = true;                              // set Quantified Self flag
        // QS FLAG IS NOT CLEARED INSIDE THIS FUNCTION
      }
    }

    if (sample < thresh && Pulse == true){   // when the values are going down, the beat is over
      // digitalWrite(blinkPin,LOW);            // turn off pin 13 LED
      Pulse = false;                         // reset the Pulse flag so we can do it again
      amp = P - T;                           // get amplitude of the pulse wave
      thresh = amp/2 + T;                    // set thresh at 50% of the amplitude
      P = thresh;                            // reset these for next time
      T = thresh;
    }

    if (N > 2500){                           // if 2.5 seconds go by without a beat
      thresh = 530;                          // set thresh default
      P = 512;                               // set P default
      T = 512;                               // set T default
      lastBeatTime = sampleCounter;          // bring the lastBeatTime up to date
      firstBeat = true;                      // set these to avoid noise
      secondBeat = false;                    // when we get the heartbeat back
    }

    // sei();                                   // enable interrupts when youre done!
  }// end processSignal


};