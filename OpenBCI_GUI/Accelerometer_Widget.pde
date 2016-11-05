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

  Button collapser;

  Accelerometer_Widget(int _topMargin) {
    super(_topMargin);

    topMargin = _topMargin;
    bottomMargin = helpWidget.h;

    x = width;
    y = topMargin;
    w = 0;
    h = (height - (topMargin+bottomMargin))/2;

    isOpen = false;
    collapsing = true;

    boxBG = bgColor;
    strokeColor = color(138, 146, 153);
    collapser = new Button(0, 0, 20, 60, "<", 14);

    // Accel Sensor Stuff
    eggshell = color(255, 253, 248);
    Xcolor = color(255, 36, 36);
    Ycolor = color(36, 255, 36);
    Zcolor = color(36, 100, 255);
    
    PolarWindowWidth = 155;
    PolarWindowHeight = 155;
    
    AccelWindowWidth = 440;
    AccelWindowHeight = 183;
    AccelWindowX = int(x)+5;
    AccelWindowY = int(y)-10+int(h)/2;
    
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
    if(drawAccel){
      if (OBCI_inited) {
  
        pushStyle();
        fill(boxBG);
        stroke(strokeColor);
        rect(width - w, topMargin, w, h);
        textFont(f2, 24);
        textAlign(LEFT, TOP);
        fill(eggshell);
        text("Acellerometer Gs", x + 10, y + 10);
  
  
        PolarWindowX = x+340;
        PolarWindowY = y+83;
        PolarCorner = (sqrt(2)*PolarWindowWidth/2)/2;
  
        fill(eggshell);  // pulse window background
        stroke(eggshell);
        rect(AccelWindowX, AccelWindowY, AccelWindowWidth, AccelWindowHeight);
        //rect(PolarWindowX-PolarWindowWidth/2, PolarWindowY-PolarWindowHeight/2, PolarWindowWidth, PolarWindowHeight);
        ellipse(PolarWindowX,PolarWindowY,PolarWindowWidth,PolarWindowHeight);
        stroke(180);
        line(PolarWindowX-PolarWindowWidth/2, PolarWindowY, PolarWindowX+PolarWindowWidth/2, PolarWindowY);
        line(PolarWindowX, PolarWindowY-PolarWindowHeight/2, PolarWindowX, PolarWindowY+PolarWindowHeight/2);
        line(PolarWindowX-PolarCorner, PolarWindowY+PolarCorner, PolarWindowX+PolarCorner, PolarWindowY-PolarCorner);
        fill(50);
        textFont(f2, 16);
        text("z", PolarWindowX-12, (PolarWindowY-PolarWindowHeight/2));
        text("x", (PolarWindowX-PolarWindowWidth/2)+2, PolarWindowY-15);
        text("y", (PolarWindowX-PolarCorner)-5, (PolarWindowY+PolarCorner)-20);
        textFont(f2, 30);
        if (synthesizeData) {
          synthesizeAccelerometerData();
          dummyX = map(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, 4.0, -4.0);
          dummyY = map(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, 4.0, -4.0);
          dummyZ = map(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, 4.0, -4.0);
          fill(Xcolor);
          text("X "+nf(dummyX, 1, 3), x+10, y+40);
          fill(Ycolor);
          text("Y "+nf(dummyY, 1, 3), x+10, y+80);
          fill(Zcolor);
          text("Z "+nf(dummyZ, 1, 3), x+10, y+120);
        } else {
          currentXvalue = openBCI.validAuxValues[0]*openBCI.get_scale_fac_accel_G_per_count();
          currentYvalue = openBCI.validAuxValues[1]*openBCI.get_scale_fac_accel_G_per_count();
          currentZvalue = openBCI.validAuxValues[2]*openBCI.get_scale_fac_accel_G_per_count();
          fill(Xcolor);
          text("X " + nf(currentXvalue, 1, 3), x+10, y+40);
          fill(Ycolor);
          text("Y " + nf(currentYvalue, 1, 3), x+10, y+80);
          fill(Zcolor);
          text("Z " + nf(currentZvalue, 1, 3), x+10, y+120);
          X[X.length-1] = 
            int(map(currentXvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
          X[X.length-1] = constrain(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
          Y[Y.length-1] = 
            int(map(currentYvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
          Y[Y.length-1] = constrain(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
          Z[Z.length-1] = 
            int(map(currentZvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
          Z[Z.length-1] = constrain(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        }
  
        for (int i = 0; i < X.length-1; i++) {      // move the pulse waveform by
          X[i] = X[i+1]; 
          Y[i] = Y[i+1];
          Z[i] = Z[i+1];
        }
  
  
  
        noFill();
        beginShape();                                  // using beginShape() renders fast
        stroke(Xcolor);
        for (int i = 0; i < X.length; i++) {    
          vertex(AccelWindowX+i, X[i]);                    //draw a line connecting the data points
        }
        endShape();
        strokeWeight(3);
        if (synthesizeData) { 
          line(PolarWindowX, PolarWindowY, PolarWindowX+map(dummyX, -4.0, 4.0, -77, 77), PolarWindowY);
        } else {
          line(PolarWindowX, PolarWindowY, PolarWindowX+map(currentXvalue, -4.0, 4.0, -77, 77), PolarWindowY);
        }
        strokeWeight(1);
        beginShape();
        stroke(Ycolor);
        for (int i = 0; i < Y.length; i++) {    
          vertex(AccelWindowX+i, Y[i]);
        }
        endShape();
        strokeWeight(3);
        if (synthesizeData) { 
          line(PolarWindowX, PolarWindowY, PolarWindowX+map((sqrt(2)*dummyY/2), -4.0, 4.0, -77, 77), PolarWindowY-map((sqrt(2)*dummyY/2), -4.0, 4.0, -77, 77));
        } else {
          line(PolarWindowX, PolarWindowY, PolarWindowX+map((sqrt(2)*currentYvalue/2), -4.0, 4.0, -77, 77), PolarWindowY-map((sqrt(2)*currentYvalue/2), -4.0, 4.0, -77, 77));
        }
        strokeWeight(1);
        beginShape();
        stroke(Zcolor);
        for (int i = 0; i < Z.length; i++) {    
          vertex(AccelWindowX+i, Z[i]);
        }
        endShape();
        strokeWeight(3);
        if (synthesizeData) { 
          line(PolarWindowX, PolarWindowY, PolarWindowX, PolarWindowY+map(dummyZ, -4.0, 4.0, -77, 77));
        } else {
          line(PolarWindowX, PolarWindowY, PolarWindowX, PolarWindowY+map(currentZvalue, -4.0, 4.0, -77, 77));
        }
        strokeWeight(1);
  
  
  
  
        fill(255, 0, 0);
        collapser.draw(int(x - collapser.but_dx), int(topMargin + (h-collapser.but_dy)/2));
        popStyle();
      }
    }
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

  boolean isMouseHere() {
    if (mouseX >= x && mouseX <= width && mouseY >= y && mouseY <= height - bottomMargin) {
      return true;
    } else {
      return false;
    }
  }

  boolean isMouseInButton() {
    verbosePrint("Playground: isMouseInButton: attempting");
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
      AccelWindowX = int(x)+5;
    }
  }

  public void collapse() {
    if (w >= 0) {
      w = w - 50;
      x = width - w;
      AccelWindowX = int(x)+5;
    }
  }
}
  
  