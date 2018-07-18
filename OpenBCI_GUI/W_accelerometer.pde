
////////////////////////////////////////////////////
//
//  W_accelerometer is used to visiualze accelerometer data
//
//  Created: Joel Murphy
//  Modified: Colin Fausnaught, September 2016
//  Modified: Wangshu Sun, November 2016
//
//
///////////////////////////////////////////////////,

class W_accelerometer extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...

  // color boxBG;
  color graphStroke = #d2d2d2;
  color graphBG = #f5f5f5;
  color textColor = #000000;

  color strokeColor;

  // Accelerometer Stuff
  int AccelBuffSize = 500; //points registered in accelerometer buff

  int padding = 30;

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

  float yMaxMin;

  float currentXvalue;
  float currentYvalue;
  float currentZvalue;

  int[] X;
  int[] Y;
  int[] Z;

  float dummyX;
  float dummyY;
  float dummyZ;
  boolean Xrising;
  boolean Yrising;
  boolean Zrising;
  boolean OBCI_inited= true;
  boolean accelerometerModeOn = true;

  Button accelModeButton;

  W_accelerometer(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    // boxBG = bgColor;
    strokeColor = color(138, 146, 153);

    // Accel Sensor Stuff
    eggshell = color(255, 253, 248);
    Xcolor = color(224, 56, 45);
    Ycolor = color(49, 113, 89);
    Zcolor = color(54, 87, 158);

    setGraphDimensions();

    yMaxMin = adjustYMaxMinBasedOnSource();

    // XYZ buffer for bottom graph
    X = new int[AccelBuffSize];
    Y = new int[AccelBuffSize];
    Z = new int[AccelBuffSize];

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

    accelModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "Turn Accel. On", 12);
    accelModeButton.setCornerRoundess((int)(navHeight-6));
    accelModeButton.setFont(p6,10);
    accelModeButton.setColorNotPressed(color(57,128,204));
    accelModeButton.textColorNotActive = color(255);
    accelModeButton.hasStroke(false);
    accelModeButton.setHelpText("Click this button to activate/deactivate the accelerometer!");
  }

  public void initPlayground(Cyton _OBCI) {
    OBCI_inited = true;
  }

  float adjustYMaxMinBasedOnSource(){
    float _yMaxMin;
    if(eegDataSource == DATASOURCE_CYTON){
      _yMaxMin = 4.0;
    }else if(eegDataSource == DATASOURCE_GANGLION || nchan == 4){
      _yMaxMin = 2.0;
    }else{
      _yMaxMin = 4.0;
    }

    return _yMaxMin;
  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...
    if (isRunning) {
      if (eegDataSource == DATASOURCE_SYNTHETIC) {
        synthesizeAccelerometerData();
        currentXvalue = map(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, yMaxMin, -yMaxMin);
        currentYvalue = map(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, yMaxMin, -yMaxMin);
        currentZvalue = map(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, yMaxMin, -yMaxMin);
        shiftWave();
      } else if (eegDataSource == DATASOURCE_CYTON) {
        currentXvalue = hub.validAccelValues[0] * cyton.get_scale_fac_accel_G_per_count();
        currentYvalue = hub.validAccelValues[1] * cyton.get_scale_fac_accel_G_per_count();
        currentZvalue = hub.validAccelValues[2] * cyton.get_scale_fac_accel_G_per_count();
        X[X.length-1] =
          int(map(currentXvalue, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        X[X.length-1] = constrain(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Y[Y.length-1] =
          int(map(currentYvalue, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Y[Y.length-1] = constrain(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Z[Z.length-1] =
          int(map(currentZvalue, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Z[Z.length-1] = constrain(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);

        shiftWave();
      } else if (eegDataSource == DATASOURCE_GANGLION) {
        currentXvalue = hub.validAccelValues[0] * ganglion.get_scale_fac_accel_G_per_count();
        currentYvalue = hub.validAccelValues[1] * ganglion.get_scale_fac_accel_G_per_count();
        currentZvalue = hub.validAccelValues[2] * ganglion.get_scale_fac_accel_G_per_count();
        X[X.length-1] =
          int(map(currentXvalue, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        X[X.length-1] = constrain(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Y[Y.length-1] =
          int(map(currentYvalue, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Y[Y.length-1] = constrain(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Z[Z.length-1] =
          int(map(currentZvalue, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Z[Z.length-1] = constrain(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);

        shiftWave();
      } else {  // playback data
        currentXvalue = accelerometerBuff[0][accelerometerBuff[0].length-1];
        currentYvalue = accelerometerBuff[1][accelerometerBuff[1].length-1];
        currentZvalue = accelerometerBuff[2][accelerometerBuff[2].length-1];
        // X[X.length-1] =
        //   int(map(currentXvalue, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        // X[X.length-1] = constrain(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        // Y[Y.length-1] =
        //   int(map(currentYvalue, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        // Y[Y.length-1] = constrain(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        // Z[Z.length-1] =
        //   int(map(currentZvalue, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        // Z[Z.length-1] = constrain(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        //
        // shiftWave();
      }
    }
  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    pushStyle();
    //put your code here...
    //remember to refer to x,y,w,h which are the positioning variables of the Widget class

    fill(50);
    textFont(p4, 14);
    textAlign(CENTER,CENTER);
    text("z", PolarWindowX, (PolarWindowY-PolarWindowHeight/2)-12);
    text("x", (PolarWindowX+PolarWindowWidth/2)+8, PolarWindowY-5);
    text("y", (PolarWindowX+PolarCorner)+10, (PolarWindowY-PolarCorner)-10);

    fill(graphBG);
    stroke(graphStroke);
    rect(AccelWindowX, AccelWindowY, AccelWindowWidth, AccelWindowHeight);
    line(AccelWindowX, AccelWindowY + AccelWindowHeight/2, AccelWindowX+AccelWindowWidth, AccelWindowY + AccelWindowHeight/2); //midline

    fill(50);
    textFont(p5, 12);
    textAlign(CENTER,CENTER);
    text("+"+(int)yMaxMin+"g", AccelWindowX+AccelWindowWidth + 12, AccelWindowY);
    text("0g", AccelWindowX+AccelWindowWidth + 12, AccelWindowY + AccelWindowHeight/2);
    text("-"+(int)yMaxMin+"g", AccelWindowX+AccelWindowWidth + 12, AccelWindowY + AccelWindowHeight);


    fill(graphBG);  // pulse window background
    stroke(graphStroke);
    ellipse(PolarWindowX,PolarWindowY,PolarWindowWidth,PolarWindowHeight);

    stroke(180);
    line(PolarWindowX-PolarWindowWidth/2, PolarWindowY, PolarWindowX+PolarWindowWidth/2, PolarWindowY);
    line(PolarWindowX, PolarWindowY-PolarWindowHeight/2, PolarWindowX, PolarWindowY+PolarWindowHeight/2);
    line(PolarWindowX-PolarCorner, PolarWindowY+PolarCorner, PolarWindowX+PolarCorner, PolarWindowY-PolarCorner);

    fill(50);
    textFont(p3, 16);

    if (eegDataSource == DATASOURCE_CYTON) {  // LIVE
      // fill(Xcolor);
      // text("X " + nf(currentXvalue, 1, 3), x+10, y+40);
      // fill(Ycolor);
      // text("Y " + nf(currentYvalue, 1, 3), x+10, y+80);
      // fill(Zcolor);
      // text("Z " + nf(currentZvalue, 1, 3), x+10, y+120);
      drawAccValues();
      draw3DGraph();
      drawAccWave();
      if (cyton.getBoardMode() != BOARD_MODE_DEFAULT) {
        accelModeButton.setString("Turn Accel On");
        accelModeButton.draw();
      }
    } else if (eegDataSource == DATASOURCE_GANGLION) {
      if (ganglion.isBLE()) accelModeButton.draw();
      if (accelerometerModeOn) {
        drawAccValues();
        draw3DGraph();
        drawAccWave();
      }
    } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  // SYNTHETIC
      drawAccValues();
      draw3DGraph();
      drawAccWave();
    }
    else {  // PLAYBACK
      drawAccValues();
      draw3DGraph();
      drawAccWave2();
    }

    popStyle();
  }

  void setGraphDimensions(){
    println("accel w "+w);
    println("accel h "+h);
    println("accel x "+x);
    println("accel y "+y);
    AccelWindowWidth = w - padding*2;
    AccelWindowHeight = int((float(h) - float(padding*3))/2.0);
    AccelWindowX = x + padding;
    AccelWindowY = y + h - AccelWindowHeight - padding;

    // PolarWindowWidth = 155;
    // PolarWindowHeight = 155;
    PolarWindowWidth = AccelWindowHeight;
    PolarWindowHeight = AccelWindowHeight;
    PolarWindowX = x + w - padding - PolarWindowWidth/2;
    PolarWindowY = y + padding + PolarWindowHeight/2;
    PolarCorner = (sqrt(2)*PolarWindowWidth/2)/2;
  }

  void screenResized(){
    int prevX = x;
    int prevY = y;
    int prevW = w;
    int prevH = h;

    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    int dy = y - prevY;
    setGraphDimensions();

    //empty arrays to start redrawing from scratch
    for (int i=0; i<X.length; i++) {  // initialize the accelerometer data
      X[i] = AccelWindowY + AccelWindowHeight/4; // X at 1/4
      Y[i] = AccelWindowY + AccelWindowHeight/2;  // Y at 1/2
      Z[i] = AccelWindowY + (AccelWindowHeight/4)*3;  // Z at 3/4
    }

    accelModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...
    if(eegDataSource == DATASOURCE_GANGLION){
      //put your code here...
      if (ganglion.isBLE()) {
        if (accelModeButton.isMouseHere()) {
          accelModeButton.setIsActive(true);
        }
      }
    } else if (eegDataSource == DATASOURCE_CYTON) {
      if (accelModeButton.isMouseHere()) {
        accelModeButton.setIsActive(true);
      }
    }
  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(eegDataSource == DATASOURCE_GANGLION){
      //put your code here...
      if(accelModeButton.isActive && accelModeButton.isMouseHere()){
        if(ganglion.isAccelModeActive()){
          ganglion.accelStop();

          accelModeButton.setString("Turn Accel On");
          accelerometerModeOn = false;
        } else{
          ganglion.accelStart();
          accelModeButton.setString("Turn Accel Off");
          accelerometerModeOn = true;
          w_analogRead.analogReadOn = false;
          w_pulsesensor.analogReadOn = false;
          w_digitalRead.digitalReadOn = false;
          w_markermode.markerModeOn = false;
        }
        accelerometerModeOn = !accelerometerModeOn;
      }
      accelModeButton.setIsActive(false);
    } else if (eegDataSource == DATASOURCE_CYTON) {
      if(accelModeButton.isActive && accelModeButton.isMouseHere()){
        cyton.setBoardMode(BOARD_MODE_DEFAULT);
        output("Starting to read accelerometer");
        accelerometerModeOn = true;
        w_analogRead.analogReadOn = false;
        w_pulsesensor.analogReadOn = false;
        w_digitalRead.digitalReadOn = false;
        w_markermode.markerModeOn = false;
      }
      accelModeButton.setIsActive(false);
    }

  }

  //add custom classes functions here
  void drawAccValues() {
    textAlign(LEFT,CENTER);
    textFont(h1,20);
    fill(Xcolor);
    text("X = " + nf(currentXvalue, 1, 3) + " g", x+padding , y + (h/12)*1.5);
    fill(Ycolor);
    text("Y = " + nf(currentYvalue, 1, 3) + " g", x+padding, y + (h/12)*3);
    fill(Zcolor);
    text("Z = " + nf(currentZvalue, 1, 3) + " g", x+padding, y + (h/12)*4.5);
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
    line(PolarWindowX, PolarWindowY, PolarWindowX+map(currentXvalue, -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY);
    stroke(Ycolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map((sqrt(2)*currentYvalue/2), -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY+map((sqrt(2)*currentYvalue/2), -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
    stroke(Zcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX, PolarWindowY+map(currentZvalue, -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
  }

  void drawAccWave() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < X.length; i++) {
      // int xi = int(map(i, 0, X.length-1, 0, AccelWindowWidth-1));
      // vertex(AccelWindowX+xi, X[i]);                    //draw a line connecting the data points
      int xi = int(map(i, 0, X.length-1, 0, AccelWindowWidth-1));
      // int yi = int(map(X[i], yMaxMin, -yMaxMin, 0.0, AccelWindowHeight-1));
      // int yi = 2;
      vertex(AccelWindowX+xi, X[i]);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < Y.length; i++) {
      int xi = int(map(i, 0, X.length-1, 0, AccelWindowWidth-1));
      vertex(AccelWindowX+xi, Y[i]);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < Z.length; i++) {
      int xi = int(map(i, 0, X.length-1, 0, AccelWindowWidth-1));
      vertex(AccelWindowX+xi, Z[i]);
    }
    endShape();
  }

  void drawAccWave2() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int x = int(map(accelerometerBuff[0][i], -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));  // ss
      x = constrain(x, AccelWindowY, AccelWindowY+AccelWindowHeight);
      vertex(AccelWindowX+i, x);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int y = int(map(accelerometerBuff[1][i], -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));  // ss
      y = constrain(y, AccelWindowY, AccelWindowY+AccelWindowHeight);
      vertex(AccelWindowX+i, y);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int z = int(map(accelerometerBuff[2][i], -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));  // ss
      z = constrain(z, AccelWindowY, AccelWindowY+AccelWindowHeight);
      vertex(AccelWindowX+i, z);
    }
    endShape();
  }

  void synthesizeAccelerometerData() {
    if (Xrising) {  // MAKE A SAW WAVE FOR TESTING
      X[X.length-1]--;   // place the new raw datapoint at the end of the array
      if (X[X.length-1] <= AccelWindowY) {
        Xrising = false;
      }
    } else {
      X[X.length-1]++;   // place the new raw datapoint at the end of the array
      if (X[X.length-1] >= AccelWindowY+AccelWindowHeight) {
        Xrising = true;
      }
    }

    if (Yrising) {  // MAKE A SAW WAVE FOR TESTING
      Y[Y.length-1]--;   // place the new raw datapoint at the end of the array
      if (Y[Y.length-1] <= AccelWindowY) {
        Yrising = false;
      }
    } else {
      Y[Y.length-1]++;   // place the new raw datapoint at the end of the array
      if (Y[Y.length-1] >= AccelWindowY+AccelWindowHeight) {
        Yrising = true;
      }
    }

    if (Zrising) {  // MAKE A SAW WAVE FOR TESTING
      Z[Z.length-1]--;   // place the new raw datapoint at the end of the array
      if (Z[Z.length-1] <= AccelWindowY) {
        Zrising = false;
      }
    } else {
      Z[Z.length-1]++;   // place the new raw datapoint at the end of the array
      if (Z[Z.length-1] >= AccelWindowY+AccelWindowHeight) {
        Zrising = true;
      }
    }
  }

};

// //These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
// void Thisdrop(int n){
//   println("Item " + (n+1) + " selected from Dropdown 1");
//   if(n==0){
//     //do this
//   } else if(n==1){
//     //do this instead
//   }
//
//   closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
// }
//
// void Dropdown2(int n){
//   println("Item " + (n+1) + " selected from Dropdown 2");
//   closeAllDropdowns();
// }
//
// void Dropdown3(int n){
//   println("Item " + (n+1) + " selected from Dropdown 3");
//   closeAllDropdowns();
// }
