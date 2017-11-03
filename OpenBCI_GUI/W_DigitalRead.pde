
////////////////////////////////////////////////////
//
//  W_DigitalRead is used to visiualze accelerometer data
//
//  Created: AJ Keller
//
//
///////////////////////////////////////////////////,

class W_DigitalRead extends Widget {

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

  float currentD11Value;
  float currentD12Value;
  float currentD17Value;

  int[] D11;
  int[] D12;
  int[] D17;

  float dummyX;
  float dummyY;
  float dummyZ;
  boolean Xrising;
  boolean Yrising;
  boolean Zrising;
  boolean OBCI_inited= true;

  Button digitalModeButton;

  W_DigitalRead(PApplet _parent){
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
    D11 = new int[AccelBuffSize];
    D12 = new int[AccelBuffSize];
    D17 = new int[AccelBuffSize];

    // for synthesizing values
    Xrising = true;
    Yrising = false;
    Zrising = true;

    // initialize data
    for (int i=0; i<D11.length; i++) {  // initialize the accelerometer data
      D11[i] = AccelWindowY + AccelWindowHeight/4; // D11 at 1/4
      D12[i] = AccelWindowY + AccelWindowHeight/2;  // D12 at 1/2
      D17[i] = AccelWindowY + (AccelWindowHeight/4)*3;  // D17 at 3/4
    }

    digitalModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "Turn Digital Read On", 12);
    digitalModeButton.setCornerRoundess((int)(navHeight-6));
    digitalModeButton.setFont(p6,10);
    digitalModeButton.setColorNotPressed(color(57,128,204));
    digitalModeButton.textColorNotActive = color(255);
    digitalModeButton.hasStroke(false);
    if (cyton.isWifi()) {
      digitalModeButton.setHelpText("Click this button to activate digital reading on the Cyton D11, D12, and D17");
    } else {
      digitalModeButton.setHelpText("Click this button to activate digital reading on the Cyton D11, D12, D13, D17 and D18");
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
    if (isRunning && cyton.getBoardMode() == BOARD_MODE_DIGITAL) {
      if (eegDataSource == DATASOURCE_SYNTHETIC) {
        synthesizeAccelerometerData();
        currentD11Value = map(D11[D11.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, yMaxMin, -yMaxMin);
        currentD12Value = map(D12[D12.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, yMaxMin, -yMaxMin);
        currentD17Value = map(D17[D17.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, yMaxMin, -yMaxMin);
        shiftWave();
      } else if (eegDataSource == DATASOURCE_CYTON) {
        currentD11Value = ((hub.validAccelValues[0] & 0xFF00) >> 8);
        currentD12Value = (hub.validAccelValues[0] & 0xFF);
        currentD17Value = (hub.validAccelValues[1]);
        D11[D11.length-1] =
          int(map(currentD11Value, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        D11[D11.length-1] = constrain(D11[D11.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        D12[D12.length-1] =
          int(map(currentD12Value, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        D12[D12.length-1] = constrain(D12[D12.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        D17[D17.length-1] =
          int(map(currentD17Value, -yMaxMin, yMaxMin, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        D17[D17.length-1] = constrain(D17[D17.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);

        shiftWave();
      } else {  // playback data
        currentD11Value = accelerometerBuff[0][accelerometerBuff[0].length-1];
        currentD12Value = accelerometerBuff[1][accelerometerBuff[1].length-1];
        currentD17Value = accelerometerBuff[2][accelerometerBuff[2].length-1];
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

      // fill(50);
      // textFont(p4, 14);
      // textAlign(CENTER,CENTER);
      // text("D11", PolarWindowX, (PolarWindowY-PolarWindowHeight/2)-12);
      // text("D12", (PolarWindowX+PolarWindowWidth/2)+8, PolarWindowY-5);
      // if (cyton.isSerial()) {
      //   text("D17", (PolarWindowX+PolarCorner)+10, (PolarWindowY-PolarCorner)-10);
      // }

      fill(graphBG);
      stroke(graphStroke);
      rect(AccelWindowX, AccelWindowY, AccelWindowWidth, AccelWindowHeight);
      line(AccelWindowX, AccelWindowY + AccelWindowHeight/2, AccelWindowX+AccelWindowWidth, AccelWindowY + AccelWindowHeight/2); //midline

      fill(50);
      textFont(p5, 12);
      textAlign(CENTER,CENTER);
      text("1", AccelWindowX+AccelWindowWidth + 12, AccelWindowY);
      text("0", AccelWindowX+AccelWindowWidth + 12, AccelWindowY + AccelWindowHeight);


      // fill(graphBG);  // pulse window background
      // stroke(graphStroke);
      // ellipse(PolarWindowX,PolarWindowY,PolarWindowWidth,PolarWindowHeight);
      //
      // stroke(180);
      // line(PolarWindowX-PolarWindowWidth/2, PolarWindowY, PolarWindowX+PolarWindowWidth/2, PolarWindowY);
      // line(PolarWindowX, PolarWindowY-PolarWindowHeight/2, PolarWindowX, PolarWindowY+PolarWindowHeight/2);
      // line(PolarWindowX-PolarCorner, PolarWindowY+PolarCorner, PolarWindowX+PolarCorner, PolarWindowY-PolarCorner);

      fill(50);
      textFont(p3, 16);

      if (eegDataSource == DATASOURCE_CYTON) {  // LIVE
        digitalModeButton.draw();
        drawAccValues();
        // draw3DGraph();
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
    for (int i=0; i<D11.length; i++) {  // initialize the accelerometer data
      D11[i] = AccelWindowY + AccelWindowHeight/4; // D11 at 1/4
      D12[i] = AccelWindowY + AccelWindowHeight/2;  // D12 at 1/2
      D17[i] = AccelWindowY + (AccelWindowHeight/4)*3;  // D17 at 3/4
    }

    digitalModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    if (digitalModeButton.isMouseHere()) {
      digitalModeButton.setIsActive(true);
    }
  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(digitalModeButton.isActive && digitalModeButton.isMouseHere()){
      // println("digitalModeButton...");
      if(cyton.isPortOpen()) {
        if (cyton.getBoardMode() != BOARD_MODE_DIGITAL) {
          cyton.setBoardMode(BOARD_MODE_DIGITAL);
          output("Starting to read digital inputs on pin marked D11");
          digitalModeButton.setString("Turn Digital Read Off");
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
          digitalModeButton.setString("Turn Digital Read On");
        }
      }
    }
    digitalModeButton.setIsActive(false);
  }

  //add custom classes functions here
  void drawAccValues() {
    textAlign(LEFT,CENTER);
    textFont(h1,20);
    fill(Xcolor);
    text("D11 = " + nf(currentD11Value, 1, 0), x+padding , y + (h/12)*1.5);
    fill(Ycolor);
    text("D12 = " + nf(currentD12Value, 1, 0), x+padding, y + (h/12)*3);
    fill(Zcolor);
    text("D17 = " + nf(currentD17Value, 1, 0), x+padding, y + (h/12)*4.5);
  }

  void shiftWave() {
    for (int i = 0; i < D11.length-1; i++) {      // move the pulse waveform by
      D11[i] = D11[i+1];
      D12[i] = D12[i+1];
      D17[i] = D17[i+1];
    }
  }

  void draw3DGraph() {
    noFill();
    strokeWeight(3);
    stroke(Xcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map(currentD11Value, -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY);
    stroke(Ycolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map((sqrt(2)*currentD12Value/2), -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY+map((sqrt(2)*currentD12Value/2), -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
    stroke(Zcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX, PolarWindowY+map(currentD17Value, -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
  }

  void drawAccWave() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < D11.length; i++) {
      // int xi = int(map(i, 0, D11.length-1, 0, AccelWindowWidth-1));
      // vertex(AccelWindowX+xi, D11[i]);                    //draw a line connecting the data points
      int xi = int(map(i, 0, D11.length-1, 0, AccelWindowWidth-1));
      // int yi = int(map(D11[i], yMaxMin, -yMaxMin, 0.0, AccelWindowHeight-1));
      // int yi = 2;
      vertex(AccelWindowX+xi, D11[i]);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < D12.length; i++) {
      int xi = int(map(i, 0, D11.length-1, 0, AccelWindowWidth-1));
      vertex(AccelWindowX+xi, D12[i]);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < D17.length; i++) {
      int xi = int(map(i, 0, D11.length-1, 0, AccelWindowWidth-1));
      vertex(AccelWindowX+xi, D17[i]);
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
      D11[D11.length-1]--;   // place the new raw datapoint at the end of the array
      if (D11[D11.length-1] <= AccelWindowY) {
        Xrising = false;
      }
    } else {
      D11[D11.length-1]++;   // place the new raw datapoint at the end of the array
      if (D11[D11.length-1] >= AccelWindowY+AccelWindowHeight) {
        Xrising = true;
      }
    }

    if (Yrising) {  // MAKE A SAW WAVE FOR TESTING
      D12[D12.length-1]--;   // place the new raw datapoint at the end of the array
      if (D12[D12.length-1] <= AccelWindowY) {
        Yrising = false;
      }
    } else {
      D12[D12.length-1]++;   // place the new raw datapoint at the end of the array
      if (D12[D12.length-1] >= AccelWindowY+AccelWindowHeight) {
        Yrising = true;
      }
    }

    if (Zrising) {  // MAKE A SAW WAVE FOR TESTING
      D17[D17.length-1]--;   // place the new raw datapoint at the end of the array
      if (D17[D17.length-1] <= AccelWindowY) {
        Zrising = false;
      }
    } else {
      D17[D17.length-1]++;   // place the new raw datapoint at the end of the array
      if (D17[D17.length-1] >= AccelWindowY+AccelWindowHeight) {
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
