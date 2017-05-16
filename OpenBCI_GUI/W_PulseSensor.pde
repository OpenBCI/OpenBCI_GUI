
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

// Pulse Sensor Stuff
  int count = 0;
  int heart = 0;
  int PulseBuffSize = 400;
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

  W_PulseSensor(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)



    // Pulse Sensor Stuff
    eggshell = color(255, 253, 248);
    pulseWave = color(224, 56, 45);

    PulseWaveY = new int[PulseBuffSize];
    BPMwaveY = new int[BPMbuffSize];

    setPulseWidgetVariables();

  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...

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
    text("BPM", BPMposX, BPMposY);
    text("IBI", IBIposX, IBIposY);



    if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {  // LIVE

    } else if (eegDataSource == DATASOURCE_GANGLION) {

    } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  // SYNTHETIC


    }
    else {  // PLAYBACK

    }
    drawWaves();

    popStyle();

  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    println("Pulse Sensor Widget -- Screen Resized.");

    setPulseWidgetVariables();

  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...


  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...


  }

  //add custom functions here
  void setPulseWidgetVariables(){



    PulseWindowWidth = ((w/4)*3) - padding;
    PulseWindowHeight = h - padding *2;
    PulseWindowX = x + padding;
    PulseWindowY = y + h - PulseWindowHeight - padding;

    BPMwindowWidth = w/4 - (padding + padding/2);
    BPMwindowHeight = PulseWindowHeight - padding*2;
    BPMwindowX = PulseWindowX + PulseWindowWidth + padding/2;
    BPMwindowY = PulseWindowY + padding;

    BPMposX = BPMwindowX + padding/2;
    BPMposY = y + padding;
    IBIposX = BPMwindowX + padding/2;
    IBIposY = y + BPMwindowHeight + int(float(padding)*2.5);

    for(int i=0; i<PulseWaveY.length; i++){
      PulseWaveY[i] = PulseWindowY + PulseWindowHeight/2;
    }
    for(int i=0; i<BPMwaveY.length; i++){
      BPMwaveY[i] = BPMwindowY + BPMwindowHeight-1;
    }

  }

  void drawWaves(){
    noFill();
    strokeWeight(1);
    stroke(pulseWave);
    beginShape();                                  // using beginShape() renders fast
    for(int i=0; i<PulseWaveY.length; i++){
      int xi = int(map(i,0, PulseWaveY.length-1,0, PulseWindowWidth-1));
      vertex(PulseWindowX+xi, PulseWaveY[i]);
    }
    endShape();

    strokeWeight(2);
    stroke(pulseWave);
    beginShape();                                  // using beginShape() renders fast
    for(int i=0; i<BPMwaveY.length; i++){
      int xi = int(map(i,0, BPMwaveY.length-1,0, BPMwindowWidth-1));
      vertex(BPMwindowX+xi, BPMwaveY[i]);
    }
    endShape();

  }

};
