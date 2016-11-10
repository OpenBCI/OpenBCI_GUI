/////////////////////////////////////////////////////////////////////////////////
//
//  Accelerometer_Widget is used to visiualze accelerometer data
//
//  Created: Joel Murphy
//  Modified: Colin Fausnaught, September 2016
//  Modified: Wangshu Sun, November 2016 
//
//  Use '/' to toggle between accelerometer and pulse sensor.
////////////////////////////////////////////////////////////////////////////////

class Accelerometer_Widget{

  int x, y, w, h;
  int parentContainer = 9;  // bottomright
  
  color boxBG;
  color strokeColor;

  PFont f4 = createFont("fonts/Raleway-SemiBold.otf", 64); 

  float topMargin, bottomMargin;
  float expandLimit = width/2.5;
  boolean isOpen;
  boolean collapsing;

  // Accelerometer Stuff
  
  // bottom xyz graph
  int AccelWindowWidth;
  int AccelWindowHeight; 
  int AccelWindowX;
  int AccelWindowY;
  
  // circular 3d xyz graph
  float PolarWindowX;
  float PolarWindowY;
  int PolarWindowWidth;
  int PolarWindowHeight;
  float PolarCorner;
  
  color eggshell;
  color Xcolor;
  color Ycolor;
  color Zcolor;
  
  float currentXvalue;
  float currentYvalue;
  float currentZvalue;
  
  int[] X;
  int[] Y;      // 
  int[] Z;
  
  float dummyX;
  float dummyY;
  float dummyZ;
  boolean Xrising;
  boolean Yrising;
  boolean Zrising;
  boolean OBCI_inited= true;

  Accelerometer_Widget() {
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    boxBG = bgColor;
    strokeColor = color(138, 146, 153);

    // Accel Sensor Stuff
    eggshell = color(255, 253, 248);
    Xcolor = color(255, 36, 36);
    Ycolor = color(36, 255, 36);
    Zcolor = color(36, 100, 255);

    AccelWindowWidth = 500;
    AccelWindowHeight = 183;
    AccelWindowX = int(x)+5;
    AccelWindowY = int(y)-10+int(h)/2;
    
    PolarWindowWidth = 155;
    PolarWindowHeight = 155;
    PolarWindowX = x+AccelWindowWidth-100;
    PolarWindowY = y+83;
    PolarCorner = (sqrt(2)*PolarWindowWidth/2)/2;
  
    // XYZ buffer for bottom graph
    X = new int[AccelWindowWidth];
    Y = new int[AccelWindowWidth];
    Z = new int[AccelWindowWidth];
    
    // for synthesizing values
    Xrising = true; 
    Yrising = false; 
    Zrising = true;
    
    // initialize data
    for (int i=0; i<X.length; i++) {  // initialize the accelerometer data
      X[i] = AccelWindowY + AccelWindowHeight/4; // X at 1/4
      Y[i] = AccelWindowY + AccelWindowHeight/2;  // Y at 1/2
      Z[i] = AccelWindowY + (AccelWindowHeight/4)*3;  // Z at 3/4
    }
  }

  public void initPlayground(OpenBCI_ADS1299 _OBCI) {
    OBCI_inited = true;
  }

  public void update() {
    if (isRunning) {
      if (synthesizeData) {    
        synthesizeAccelerometerData();
        currentXvalue = map(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, 4.0, -4.0);
        currentYvalue = map(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, 4.0, -4.0);
        currentZvalue = map(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, 4.0, -4.0);
        shiftWave();
      } else if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
        currentXvalue = openBCI.validAuxValues[0]*openBCI.get_scale_fac_accel_G_per_count();
        currentYvalue = openBCI.validAuxValues[1]*openBCI.get_scale_fac_accel_G_per_count();
        currentZvalue = openBCI.validAuxValues[2]*openBCI.get_scale_fac_accel_G_per_count();
        X[X.length-1] = 
          int(map(currentXvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        X[X.length-1] = constrain(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Y[Y.length-1] = 
          int(map(currentYvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Y[Y.length-1] = constrain(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Z[Z.length-1] = 
          int(map(currentZvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Z[Z.length-1] = constrain(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);

        shiftWave();
      } else {  // playback data
        currentXvalue = X_buff[X_buff.length-1];
        currentYvalue = Y_buff[Y_buff.length-1];
        currentZvalue = Z_buff[Z_buff.length-1];
      }
    }
  }

  public void draw() {
    // verbosePrint("yeaaa");
    if(drawAccel){
        fill(boxBG);
        stroke(strokeColor);
        rect(x, y, w, h);
        textFont(f4, 24);
        textAlign(LEFT, TOP);
        fill(eggshell);
        text("Acellerometer Gs", x + 10, y + 10);
        
        fill(50);
        textFont(f4, 16);
        text("z", PolarWindowX-12, (PolarWindowY-PolarWindowHeight/2));
        text("x", (PolarWindowX-PolarWindowWidth/2)+2, PolarWindowY-15);
        text("y", (PolarWindowX-PolarCorner)-5, (PolarWindowY+PolarCorner)-20);
        
        fill(eggshell);  // pulse window background
        stroke(eggshell);
        rect(AccelWindowX, AccelWindowY, AccelWindowWidth, AccelWindowHeight);
        
        fill(eggshell);  // pulse window background
        stroke(eggshell); 
        ellipse(PolarWindowX,PolarWindowY,PolarWindowWidth,PolarWindowHeight);
        
        stroke(180);
        line(PolarWindowX-PolarWindowWidth/2, PolarWindowY, PolarWindowX+PolarWindowWidth/2, PolarWindowY);
        line(PolarWindowX, PolarWindowY-PolarWindowHeight/2, PolarWindowX, PolarWindowY+PolarWindowHeight/2);
        line(PolarWindowX-PolarCorner, PolarWindowY+PolarCorner, PolarWindowX+PolarCorner, PolarWindowY-PolarCorner);
        
        fill(50);
        textFont(f4, 30);
        
        if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {  // LIVE
          fill(Xcolor);
          text("X " + nf(currentXvalue, 1, 3), x+10, y+40);
          fill(Ycolor);
          text("Y " + nf(currentYvalue, 1, 3), x+10, y+80);
          fill(Zcolor);
          text("Z " + nf(currentZvalue, 1, 3), x+10, y+120);
          draw3DGraph();
          drawAccWave();
        }
        else if (synthesizeData) {  // SYNTHETIC
          fill(Xcolor);
          text("X "+nf(currentXvalue, 1, 3), x+10, y+40);
          fill(Ycolor);
          text("Y "+nf(currentYvalue, 1, 3), x+10, y+80);
          fill(Zcolor);
          text("Z "+nf(currentZvalue, 1, 3), x+10, y+120);
          draw3DGraph();
          drawAccWave();
        }
        else {  // PLAYBACK
          drawAccValues();
          draw3DGraph();
          drawAccWave2();
        }

    }
  }

  void screenResized(PApplet _parent, int _winX, int _winY) {
    //when screen is resized...
    //update position/size of FFT widget
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    PolarWindowX = x+AccelWindowWidth-100;
    PolarWindowY = y+83;
    PolarCorner = (sqrt(2)*PolarWindowWidth/2)/2;

    AccelWindowX = int(x)+5;
    AccelWindowY = int(y)-10+int(h)/2;
  }

  void drawAccValues() {
    fill(Xcolor);
    text("X " + nf(currentXvalue, 1, 3), x+10, y+40);
    fill(Ycolor);
    text("Y " + nf(currentYvalue, 1, 3), x+10, y+80);
    fill(Zcolor);
    text("Z " + nf(currentZvalue, 1, 3), x+10, y+120);
  }

  void shiftWave() {
    for (int i = 0; i < X.length-1; i++) {      // move the pulse waveform by
      X[i] = X[i+1]; 
      Y[i] = Y[i+1];
      Z[i] = Z[i+1];
    }
  }

  void draw3DGraph() {
    noFill();
    strokeWeight(3);
    stroke(Xcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map(currentXvalue, -4.0, 4.0, -77, 77), PolarWindowY);
    stroke(Ycolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map((sqrt(2)*currentYvalue/2), -4.0, 4.0, -77, 77), PolarWindowY-map((sqrt(2)*currentYvalue/2), -4.0, 4.0, -77, 77));
    stroke(Zcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX, PolarWindowY+map(currentZvalue, -4.0, 4.0, -77, 77));
  }

  void drawAccWave() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < X.length; i++) {    
      vertex(AccelWindowX+i, X[i]);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < Y.length; i++) {    
      vertex(AccelWindowX+i, Y[i]);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < Z.length; i++) {    
      vertex(AccelWindowX+i, Z[i]);
    }
    endShape();
  }

  void drawAccWave2() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < X_buff.length; i++) {    
      int x = int(map(X_buff[i], -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));  // ss
      x = constrain(x, AccelWindowY, AccelWindowY+AccelWindowHeight);
      vertex(AccelWindowX+i, x);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < Y_buff.length; i++) {    
      int y = int(map(Y_buff[i], -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));  // ss
      y = constrain(y, AccelWindowY, AccelWindowY+AccelWindowHeight);
      vertex(AccelWindowX+i, y);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < Z_buff.length; i++) {    
      int z = int(map(Z_buff[i], -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));  // ss
      z = constrain(z, AccelWindowY, AccelWindowY+AccelWindowHeight);
      vertex(AccelWindowX+i, z);
    }
    endShape();
  }

  void synthesizeAccelerometerData() {
    if (Xrising) {  // MAKE A SAW WAVE FOR TESTING
      X[X.length-1]--;   // place the new raw datapoint at the end of the array
      if (X[X.length-1] == AccelWindowY) { 
        Xrising = false;
      }
    } else {
      X[X.length-1]++;   // place the new raw datapoint at the end of the array
      if (X[X.length-1] == AccelWindowY+AccelWindowHeight) { 
        Xrising = true;
      }
    }

    if (Yrising) {  // MAKE A SAW WAVE FOR TESTING
      Y[Y.length-1]--;   // place the new raw datapoint at the end of the array
      if (Y[Y.length-1] == AccelWindowY) { 
        Yrising = false;
      }
    } else {
      Y[Y.length-1]++;   // place the new raw datapoint at the end of the array
      if (Y[Y.length-1] == AccelWindowY+AccelWindowHeight) { 
        Yrising = true;
      }
    }

    if (Zrising) {  // MAKE A SAW WAVE FOR TESTING
      Z[Z.length-1]--;   // place the new raw datapoint at the end of the array
      if (Z[Z.length-1] == AccelWindowY) { 
        Zrising = false;
      }
    } else {
      Z[Z.length-1]++;   // place the new raw datapoint at the end of the array
      if (Z[Z.length-1] == AccelWindowY+AccelWindowHeight) { 
        Zrising = true;
      }
    }
  }



  public void mousePressed() {
    verbosePrint("Playground >> mousePressed()");
  }

  public void mouseReleased() {
    verbosePrint("Playground >> mouseReleased()");
  }
  
}
  