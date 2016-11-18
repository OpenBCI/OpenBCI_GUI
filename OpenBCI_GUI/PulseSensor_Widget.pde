/////////////////////////////////////////////////////////////////////////////////
//
//  PulseSensor_Widget is used to visiualze heartbeat data using a pulse sensor
//
//  Created: Colin Fausnaught, September 2016
//           Source Code by Joel Murphy
//
//  Use '/' to toggle between accelerometer and pulse sensor.
////////////////////////////////////////////////////////////////////////////////

class PulseSensor_Widget{

  //button for opening and closing
  int x, y, w, h;
  int parentContainer = 3;
  color boxBG;
  color strokeColor;

// Pulse Sensor Stuff
  int count = 0;
  int heart = 0;
  int PulseBuffSize = 500;

  int PulseWindowWidth;
  int PulseWindowHeight;
  int PulseWindowX;
  int PulseWindowY;
  color eggshell;
  int[] PulseWaveY;      // HOLDS HEARTBEAT WAVEFORM DATA
  boolean rising;
  //boolean OBCI_inited= false;

  //OpenBCI_ADS1299 OBCI;

  PulseSensor_Widget(PApplet parent) {
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    boxBG = bgColor;
    strokeColor = color(138, 146, 153);

    // Pulse Sensor Stuff
    eggshell = color(255, 253, 248);

    PulseWindowWidth = 500;
    PulseWindowHeight = 183;
    PulseWindowX = int(x)+5;
    PulseWindowY = int(y)-10+int(h)/2;
    PulseWaveY = new int[PulseBuffSize];
    rising = true;
    for (int i=0; i<PulseWaveY.length; i++){
      PulseWaveY[i] = PulseWindowY + PulseWindowHeight/2; // initialize the pulse window data line to V/2
   }

  }

  public void update() {
    if (isRunning) {
      if(synthesizeData){
        count++;
      }

      if(frameCount%60 == 0){ heart = 15; }  // fake the beat for now
      if(openBCI.freshAuxValues){ heart = 4; }
      heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
      heart = max(heart,0);       // don't let the heart variable go into negative numbers

      float upperClip = 800.0;  // used to keep the pulse waveform within the pulse wave window
      float lowerClip = 200.0;
      if(synthesizeData){
        if(rising){  // MAKE A SAW WAVE FOR TESTING
         PulseWaveY[PulseWaveY.length-1]--;   // place the new raw datapoint at the end of the array
         if(PulseWaveY[PulseWaveY.length-1] == PulseWindowY){ rising = false; }
        }else{
         PulseWaveY[PulseWaveY.length-1]++;   // place the new raw datapoint at the end of the array
         if(PulseWaveY[PulseWaveY.length-1] == PulseWindowY+PulseWindowHeight){ rising = true; }
        }
      }else{
        float sensorValue = float(openBCI.rawReceivedDataPacket.auxValues[0]);
        PulseWaveY[PulseWaveY.length-1] =
        int(map(sensorValue,lowerClip,upperClip,float(PulseWindowY+PulseWindowHeight),float(PulseWindowY)));
        PulseWaveY[PulseWaveY.length-1] = constrain(PulseWaveY[PulseWaveY.length-1],PulseWindowY,PulseWindowY+PulseWindowHeight);
      }

      for (int i = 0; i < PulseWaveY.length-1; i++) {      // move the pulse waveform by
       PulseWaveY[i] = PulseWaveY[i+1];
      }
    }
  }

  public void draw() {
    if(drawPulse){
    // verbosePrint("yeaaa");
      fill(boxBG);
      stroke(strokeColor);
      rect(x, y, w, h);

      textFont(f4,24);
      textAlign(LEFT, TOP);
      fill(eggshell);
      text("Pulse Sensor Amped", x + 10, y + 10);
      textFont(f4,32);
      if(synthesizeData){
        text("BPM " + count, x+10, y+50);
        text("IBI 760", x+10, y+100);
        //text("Width "+ w, x+10, y+50);
        //text("Height "+ h, x+10, y+70);
      }else{
        text("BPM " + openBCI.validAuxValues[1], x+10, y+40);
        text("IBI " + openBCI.validAuxValues[2], x+10, y+100);
      }

      // heart shape
      fill(250,0,0);
      stroke(250,0,0);

      strokeWeight(1);
      if (heart > 0){             // if a beat happened recently,
      strokeWeight(8);          // make the heart pulse
      }

      translate(-35,0);
      smooth();   // draw the heart with two bezier curves
      bezier(x+w-60,y+40, x+w+20,y-30, x+w+40,y+130, x+w-60,y+140);
      bezier(x+w-60,y+40, x+w-150,y-30, x+w-160,y+130, x+w-60,y+140);
      translate(35,0);

      strokeWeight(1);          // reset the strokeWeight for next time
      fill(eggshell);  // pulse window background
      stroke(eggshell);
      rect(PulseWindowX,PulseWindowY,PulseWindowWidth,PulseWindowHeight);

      stroke(255,0,0);                               // red is a good color for the pulse waveform
      noFill();
      beginShape();                                  // using beginShape() renders fast
      for (int x = 0; x < PulseWaveY.length; x++) {
        int xi = int(map(x, 0, PulseWaveY.length-1, 0, PulseWindowWidth-1));
        vertex(PulseWindowX+xi, PulseWaveY[x]);                    //draw a line connecting the data points
      }
      endShape();

    }
  }

  void screenResized(PApplet _parent, int _winX, int _winY) {
    //when screen is resized...
    //update position/size of Pulse Widget
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;


    PulseWindowX = int(x)+5;
    PulseWindowY = int(y)-10+int(h)/2;
    PulseWindowWidth = int(w)-10;
    PulseWindowHeight = 183;
  }

  //boolean isMouseHere() {
  //  if (mouseX >= x && mouseX <= width && mouseY >= y && mouseY <= height - bottomMargin) {
  //    return true;
  //  } else {
  //    return false;
  //  }
  //}

  //boolean isMouseInButton() {
  //  //verbosePrint("Playground: isMouseInButton: attempting");
  //  if (mouseX >= collapser.but_x && mouseX <= collapser.but_x+collapser.but_dx && mouseY >= collapser.but_y && mouseY <= collapser.but_y + collapser.but_dy) {
  //    return true;
  //  } else {
  //    return false;
  //  }
  //}

  public void mousePressed() {
    verbosePrint("PulseSensor >> mousePressed()");
  }

  public void mouseReleased() {
    verbosePrint("PulseSensor >> mouseReleased()");
  }

}
