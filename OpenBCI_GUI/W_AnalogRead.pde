
////////////////////////////////////////////////////
//
//  W_AnalogRead is used to visiualze accelerometer data
//
//  Created: AJ Keller
//
//
///////////////////////////////////////////////////,

class W_AnalogRead extends Widget {

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

  float currentA5Value;
  float currentA6Value;
  float currentA7Value;

  int[] A5;
  int[] A6;
  int[] A7;

  float dummyX;
  float dummyY;
  float dummyZ;
  boolean Xrising;
  boolean Yrising;
  boolean Zrising;
  boolean OBCI_inited = true;

  Button analogModeButton;

  W_AnalogRead(PApplet _parent){
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
    A5 = new int[AccelBuffSize];
    A6 = new int[AccelBuffSize];
    A7 = new int[AccelBuffSize];

    // for synthesizing values
    Xrising = true;
    Yrising = false;
    Zrising = true;

    // initialize data
    for (int i=0; i<A5.length; i++) {  // initialize the accelerometer data
      A5[i] = AccelWindowY + AccelWindowHeight/4; // A5 at 1/4
      A6[i] = AccelWindowY + AccelWindowHeight/2;  // A6 at 1/2
      A7[i] = AccelWindowY + (AccelWindowHeight/4)*3;  // A7 at 3/4
    }

    analogModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "Turn Accel. On", 12);
    analogModeButton.setCornerRoundess((int)(navHeight-6));
    analogModeButton.setFont(p6,10);
    // analogModeButton.setStrokeColor((int)(color(150)));
    // analogModeButton.setColorNotPressed(openbciBlue);
    analogModeButton.setColorNotPressed(color(57,128,204));
    analogModeButton.textColorNotActive = color(255);
    // analogModeButton.setStrokeColor((int)(color(138, 182, 229, 100)));
    analogModeButton.hasStroke(false);
    // analogModeButton.setColorNotPressed((int)(color(138, 182, 229)));
    if (cyton.isWifi()) {
      analogModeButton.setHelpText("Click this button to activate/deactivate the analog read of your Cyton board from A5(D11) and A6(D12)");
    } else {
      analogModeButton.setHelpText("Click this button to activate/deactivate the analog read of your Cyton board from A5(D11), A6(D12) and A7(D13)");
    }
  }

  public void initPlayground(Cyton _OBCI) {
    OBCI_inited = true;
  }

  float adjustYMaxMinBasedOnSource(){
    return 0.0;
  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...
    if (isRunning && cyton.getBoardMode() == BOARD_MODE_ANALOG) {
      if (eegDataSource == DATASOURCE_SYNTHETIC) {
        synthesizeAccelerometerData();
        currentA5Value = map(A5[A5.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, yMaxMin, -yMaxMin);
        currentA6Value = map(A6[A6.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, yMaxMin, -yMaxMin);
        currentA7Value = map(A7[A7.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, yMaxMin, -yMaxMin);
        shiftWave();
      } else if (eegDataSource == DATASOURCE_CYTON) {
        currentA5Value = hub.validAccelValues[0];
        currentA6Value = hub.validAccelValues[1];
        currentA7Value = hub.validAccelValues[2];
        A5[A5.length-1] =
          int(map(currentA5Value, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        A5[A5.length-1] = constrain(A5[A5.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        A6[A6.length-1] =
          int(map(currentA6Value, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        A6[A6.length-1] = constrain(A6[A6.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        A7[A7.length-1] =
          int(map(currentA7Value, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        A7[A7.length-1] = constrain(A7[A7.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);

        shiftWave();
      } else {  // playback data
        currentA5Value = accelerometerBuff[0][accelerometerBuff[0].length-1];
        currentA6Value = accelerometerBuff[1][accelerometerBuff[1].length-1];
        currentA7Value = accelerometerBuff[2][accelerometerBuff[2].length-1];
      }
    }
  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    pushStyle();
    //put your code here...
    //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    if (true) {
      // fill(graphBG);
      // stroke(strokeColor);
      // rect(x, y, w, h);
      // textFont(f4, 24);
      // textAlign(LEFT, TOP);
      // fill(textColor);
      // text("Acellerometer Gs", x + 10, y + 10);

      fill(50);
      textFont(p4, 14);
      textAlign(CENTER,CENTER);
      text("A5", PolarWindowX, (PolarWindowY-PolarWindowHeight/2)-12);
      text("A6", (PolarWindowX+PolarWindowWidth/2)+8, PolarWindowY-5);
      if (cyton.isSerial()) {
        text("A7", (PolarWindowX+PolarCorner)+10, (PolarWindowY-PolarCorner)-10);
      }

      fill(graphBG);
      stroke(graphStroke);
      rect(AccelWindowX, AccelWindowY, AccelWindowWidth, AccelWindowHeight);
      line(AccelWindowX, AccelWindowY + AccelWindowHeight/2, AccelWindowX+AccelWindowWidth, AccelWindowY + AccelWindowHeight/2); //midline

      fill(50);
      textFont(p5, 12);
      textAlign(CENTER,CENTER);
      text("4096", AccelWindowX+AccelWindowWidth + 12, AccelWindowY);
      text("0", AccelWindowX+AccelWindowWidth + 12, AccelWindowY + AccelWindowHeight);


      // fill(graphBG);  // pulse window background
      // stroke(graphStroke);
      // ellipse(PolarWindowX,PolarWindowY,PolarWindowWidth,PolarWindowHeight);
      //
      // stroke(180);
      // line(PolarWindowX-PolarWindowWidth/2, PolarWindowY, PolarWindowX+PolarWindowWidth/2, PolarWindowY);
      // line(PolarWindowX, PolarWindowY-PolarWindowHeight/2, PolarWindowX, PolarWindowY+PolarWindowHeight/2);
      // line(PolarWindowX-PolarCorner, PolarWindowY+PolarCorner, PolarWindowX+PolarCorner, PolarWindowY-PolarCorner);
      //
      // fill(50);
      // textFont(p3, 16);

      if (eegDataSource == DATASOURCE_CYTON) {  // LIVE
        analogModeButton.draw();
        drawAccValues();
        draw3DGraph();
        drawAccWave();
      } else {  // PLAYBACK
        drawAccValues();
        draw3DGraph();
        drawAccWave2();
      }
    }

    popStyle();
  }

  void setGraphDimensions(){
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
    for (int i=0; i<A5.length; i++) {  // initialize the accelerometer data
      A5[i] = AccelWindowY + AccelWindowHeight/4; // A5 at 1/4
      A6[i] = AccelWindowY + AccelWindowHeight/2;  // A6 at 1/2
      A7[i] = AccelWindowY + (AccelWindowHeight/4)*3;  // A7 at 3/4
    }

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
        if (cyton.getBoardMode() != BOARD_MODE_ANALOG) {
          cyton.setBoardMode(BOARD_MODE_ANALOG);
          output("Starting to read analog inputs on pin marked D11");
          analogModeButton.setString("Turn Digital Read Off");
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
          analogModeButton.setString("Turn Digital Read On");
        }
      }
    }
    analogModeButton.setIsActive(false);
  }

  //add custom classes functions here
  void drawAccValues() {
    textAlign(LEFT,CENTER);
    textFont(h1,20);
    fill(Xcolor);
    text("A5 = " + nf(currentA5Value, 1, 0), x+padding , y + (h/12)*1.5);
    fill(Ycolor);
    text("A6 = " + nf(currentA6Value, 1, 0), x+padding, y + (h/12)*3);
    fill(Zcolor);
    text("A7 = " + nf(currentA7Value, 1, 0), x+padding, y + (h/12)*4.5);
  }

  void shiftWave() {
    for (int i = 0; i < A5.length-1; i++) {      // move the pulse waveform by
      A5[i] = A5[i+1];
      A6[i] = A6[i+1];
      A7[i] = A7[i+1];
    }
  }

  void draw3DGraph() {
    noFill();
    strokeWeight(3);
    stroke(Xcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map(currentA5Value, -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY);
    stroke(Ycolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map((sqrt(2)*currentA6Value/2), -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY+map((sqrt(2)*currentA6Value/2), -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
    stroke(Zcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX, PolarWindowY+map(currentA7Value, -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
  }

  void drawAccWave() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < A5.length; i++) {
      // int xi = int(map(i, 0, A5.length-1, 0, AccelWindowWidth-1));
      // vertex(AccelWindowX+xi, A5[i]);                    //draw a line connecting the data points
      int xi = int(map(i, 0, A5.length-1, 0, AccelWindowWidth-1));
      // int yi = int(map(A5[i], yMaxMin, -yMaxMin, 0.0, AccelWindowHeight-1));
      // int yi = 2;
      vertex(AccelWindowX+xi, A5[i]);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < A6.length; i++) {
      int xi = int(map(i, 0, A5.length-1, 0, AccelWindowWidth-1));
      vertex(AccelWindowX+xi, A6[i]);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < A7.length; i++) {
      int xi = int(map(i, 0, A5.length-1, 0, AccelWindowWidth-1));
      vertex(AccelWindowX+xi, A7[i]);
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
      A5[A5.length-1]--;   // place the new raw datapoint at the end of the array
      if (A5[A5.length-1] <= AccelWindowY) {
        Xrising = false;
      }
    } else {
      A5[A5.length-1]++;   // place the new raw datapoint at the end of the array
      if (A5[A5.length-1] >= AccelWindowY+AccelWindowHeight) {
        Xrising = true;
      }
    }

    if (Yrising) {  // MAKE A SAW WAVE FOR TESTING
      A6[A6.length-1]--;   // place the new raw datapoint at the end of the array
      if (A6[A6.length-1] <= AccelWindowY) {
        Yrising = false;
      }
    } else {
      A6[A6.length-1]++;   // place the new raw datapoint at the end of the array
      if (A6[A6.length-1] >= AccelWindowY+AccelWindowHeight) {
        Yrising = true;
      }
    }

    if (Zrising) {  // MAKE A SAW WAVE FOR TESTING
      A7[A7.length-1]--;   // place the new raw datapoint at the end of the array
      if (A7[A7.length-1] <= AccelWindowY) {
        Zrising = false;
      }
    } else {
      A7[A7.length-1]++;   // place the new raw datapoint at the end of the array
      if (A7[A7.length-1] >= AccelWindowY+AccelWindowHeight) {
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
