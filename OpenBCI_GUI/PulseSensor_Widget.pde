/////////////////////////////////////////////////////////////////////////////////
//
//  PulseSensor_Widget is used to visiualze heartbeat data using a pulse sensor
//
//  Created: Colin Fausnaught, September 2016
//           Source Code by Joel Murphy
//
//  Use '/' to toggle between accelerometer and pulse sensor.
////////////////////////////////////////////////////////////////////////////////

class PulseSensor_Widget extends Playground{

  //button for opening and closing
  float x, y, w, h;
  color boxBG;
  color strokeColor;
  
  float topMargin, bottomMargin;
  float expandLimit = width/2.5;
  boolean isOpen;
  boolean collapsing;
  
// Pulse Sensor Stuff
  int count = 0;
  int heart = 0;
  int PulseWindowWidth;
  int PulseWindowHeight; 
  int PulseWindowX;
  int PulseWindowY;
  color eggshell;
  int[] PulseWaveY;      // HOLDS HEARTBEAT WAVEFORM DATA
  boolean rising;
  boolean OBCI_inited= false;
  
  OpenBCI_ADS1299 OBCI;
  
  Button collapser;

  PulseSensor_Widget(int _topMargin) {
    super(_topMargin);
    topMargin = _topMargin;
    bottomMargin = helpWidget.h;

    isOpen = false;
    collapsing = true;

    boxBG = bgColor;
    strokeColor = color(138, 146, 153);
    collapser = new Button(0, 0, 20, 60, "<", 14);

    x = width;
    y = topMargin;
    w = 0;
    h = (height - (topMargin+bottomMargin))/2;
    
// Pulse Sensor Stuff
    eggshell = color(255, 253, 248);
    PulseWindowWidth = 440;
    PulseWindowHeight = 183;
    PulseWindowX = int(x)+5;
    PulseWindowY = int(y)-10+int(h)/2;
    PulseWaveY = new int[PulseWindowWidth];
    rising = true;
    for (int i=0; i<PulseWaveY.length; i++){
      PulseWaveY[i] = PulseWindowY + PulseWindowHeight/2; // initialize the pulse window data line to V/2
   }
    
  }
  
  public void initPlayground(OpenBCI_ADS1299 _OBCI){
    OBCI = _OBCI;
    OBCI_inited = true;
  }

  public void update() {
    // verbosePrint("uh huh");
    if (collapsing) {
      collapse();
    } else {
      expand();
    }

    if (x > width) {
      x = width;
    }
  }

  public void draw() {
    // verbosePrint("yeaaa");
  if(OBCI_inited){
    if(drawPulse){
      pushStyle();
      fill(boxBG);
      stroke(strokeColor);
      rect(width - w, topMargin, w, h);
      textFont(f2,24);
      textAlign(LEFT, TOP);
      fill(eggshell);
      text("Pulse Sensor Amped", x + 10, y + 10);
      textFont(f2,50);
      if(synthesizeData){
        text("BPM " + count, x+10, y+40);
        text("IBI 760", x+10, y+100);
        count++;
        //text("Width "+ w, x+10, y+50);
        //text("Height "+ h, x+10, y+70);
      }else{
        text("BPM " + OBCI.validAuxValues[1], x+10, y+40);
        text("IBI " + OBCI.validAuxValues[2], x+10, y+100);
      }
      fill(250,0,0);
      stroke(250,0,0);
      if(frameCount%60 == 0){ heart = 15; }  // fake the beat for now
      if(OBCI.freshAuxValues){ heart = 4; }
      heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
      heart = max(heart,0);       // don't let the heart variable go into negative numbers
      strokeWeight(1);
      if (heart > 0){             // if a beat happened recently, 
      strokeWeight(8);          // make the heart pulse
      }
      smooth();   // draw the heart with two bezier curves
      bezier(x+expandLimit-60,y+40, x+expandLimit+20,y-30, x+expandLimit+40,y+130, x+expandLimit-60,y+140);
      bezier(x+expandLimit-60,y+40, x+expandLimit-150,y-30, x+expandLimit-160,y+130, x+expandLimit-60,y+140);
      strokeWeight(1);          // reset the strokeWeight for next time
      
      fill(eggshell);  // pulse window background
      stroke(eggshell);
      rect(PulseWindowX,PulseWindowY,PulseWindowWidth,PulseWindowHeight);
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
        float sensorValue = float(OBCI.rawReceivedDataPacket.auxValues[0]);
        PulseWaveY[PulseWaveY.length-1] = 
        int(map(sensorValue,lowerClip,upperClip,float(PulseWindowY+PulseWindowHeight),float(PulseWindowY)));
        PulseWaveY[PulseWaveY.length-1] = constrain(PulseWaveY[PulseWaveY.length-1],PulseWindowY,PulseWindowY+PulseWindowHeight);
      }
      
      for (int i = 0; i < PulseWaveY.length-1; i++) {      // move the pulse waveform by
       PulseWaveY[i] = PulseWaveY[i+1];  
      }
      
      stroke(255,0,0);                               // red is a good color for the pulse waveform
      noFill();
      beginShape();                                  // using beginShape() renders fast
      for (int x = 0; x < PulseWaveY.length; x++) {    
       vertex(PulseWindowX+x, PulseWaveY[x]);                    //draw a line connecting the data points
      }
      endShape();
      
      
      fill(255, 0, 0);
      collapser.draw(int(x - collapser.but_dx), int(topMargin + (h-collapser.but_dy)/2));
      popStyle();
      }
    }
  }

  boolean isMouseHere() {
    if (mouseX >= x && mouseX <= width && mouseY >= y && mouseY <= height - bottomMargin) {
      return true;
    } else {
      return false;
    }
  }

  boolean isMouseInButton() {
    //verbosePrint("Playground: isMouseInButton: attempting");
    if (mouseX >= collapser.but_x && mouseX <= collapser.but_x+collapser.but_dx && mouseY >= collapser.but_y && mouseY <= collapser.but_y + collapser.but_dy) {
      return true;
    } else {
      return false;
    }
  }

  public void toggleWindow() {
    if (isOpen) {//if open
      verbosePrint("close");
      collapsing = true;//collapsing = true;
      isOpen = false;
      collapser.but_txt = "<";
    } else {//if closed
      verbosePrint("open");
      collapsing = false;//expanding = true;
      isOpen = true;
      collapser.but_txt = ">";
    }
  }

  public void mousePressed() {
    verbosePrint("Playground >> mousePressed()");
  }

  public void mouseReleased() {
    verbosePrint("Playground >> mouseReleased()");
  }

  public void expand() {
    if (w <= expandLimit) {
      w = w + 50;
      x = width - w;
      PulseWindowX = int(x)+5;
    }
  }

  public void collapse() {
    if (w >= 0) {
      w = w - 50;
      x = width - w;
      PulseWindowX = int(x)+5;
    }
  }
}