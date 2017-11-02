
////////////////////////////////////////////////////
//
//  W_MarkerMode is used to put the board into marker mode
//  by Gerrie van Zyl
//  Basd on W_Analogread by AJ Keller
//
//
///////////////////////////////////////////////////,

class W_MarkerMode extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...

  // color boxBG;
  color graphStroke = #d2d2d2;
  color graphBG = #f5f5f5;
  color textColor = #000000;

  color strokeColor;

  // Accelerometer Stuff
  int MarkerBuffSize = 500; //points registered in accelerometer buff

  int padding = 30;

  // bottom xyz graph
  int MarkerWindowWidth;
  int MarkerWindowHeight;
  int MarkerWindowX;
  int MarkerWindowY;


  color eggshell;
  color Xcolor;

  float yMaxMin;

  float currentXvalue;

  int[] X;

  int lastMarker=0;

  float dummyX;

  // for the synthetic markers
  float synthTime;
  int synthCount;

  boolean OBCI_inited= true;

  Button markerModeButton;

  W_MarkerMode(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    // boxBG = bgColor;
    strokeColor = color(138, 146, 153);

    // Marker Sensor Stuff
    eggshell = color(255, 253, 248);
    Xcolor = color(224, 56, 45);


    setGraphDimensions();

    // this is set to 255+20 we will add 20 to all markers so even marker of value=1 can be seen
    yMaxMin = 265;

    // XYZ buffer for bottom graph
    X = new int[MarkerBuffSize];

    // for synthesizing values
    synthTime = 0.0;
    
    // initialize data
    for (int i=0; i<X.length; i++) {  // initialize the marker data
      X[i] = 0; 
    }

    markerModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "Turn MarkerMode On", 12);
    markerModeButton.setCornerRoundess((int)(navHeight-6));
    markerModeButton.setFont(p6,10);
    markerModeButton.setColorNotPressed(color(57,128,204));
    markerModeButton.textColorNotActive = color(255);
    markerModeButton.hasStroke(false);
    markerModeButton.setHelpText("Click this button to activate/deactivate the MarkerMode of your Cyton board!");
  }

  public void initPlayground(Cyton _OBCI) {
    OBCI_inited = true;
  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...
    if (eegDataSource == DATASOURCE_SYNTHETIC) {
      synthesizeMarkerData();
      currentXvalue = map(X[X.length-1], MarkerWindowY, MarkerWindowY+MarkerWindowHeight, yMaxMin, 0);
      shiftWave();
    } else if (eegDataSource == DATASOURCE_CYTON) {
      if (isRunning && cyton.getBoardMode() == BOARD_MODE_MARKER) {

// todo        currentXvalue = dataPacket.auxValues[0];
        currentXvalue = 1;
        if (currentXvalue > 1.0)
          lastMarker = int(currentXvalue);
        if (currentXvalue > 0.0)
          currentXvalue += 10;
           
        X[X.length-1] =
          int(map(logScaleMarker(currentXvalue), 0, yMaxMin, float(MarkerWindowY+MarkerWindowHeight), float(MarkerWindowY)));
        X[X.length-1] = constrain(X[X.length-1], MarkerWindowY, MarkerWindowY+MarkerWindowHeight);

        shiftWave();
      }
    } else {  // playback data
      currentXvalue = accelerometerBuff[0][accelerometerBuff[0].length-1];
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

      fill(graphBG);
      stroke(graphStroke);
      rect(MarkerWindowX, MarkerWindowY, MarkerWindowWidth, MarkerWindowHeight);
      line(MarkerWindowX, MarkerWindowY + MarkerWindowHeight/2, MarkerWindowX+MarkerWindowWidth, MarkerWindowY + MarkerWindowHeight/2); //midline

      fill(50);
      textFont(p5, 12);
      textAlign(CENTER,CENTER);
      text((int)yMaxMin-20, MarkerWindowX+MarkerWindowWidth + 12, MarkerWindowY);
      text("0", MarkerWindowX+MarkerWindowWidth + 12, MarkerWindowY + MarkerWindowHeight);


      fill(graphBG);  // pulse window background
      stroke(graphStroke);

      stroke(180);

      fill(50);
      textFont(p3, 16);

      if (eegDataSource == DATASOURCE_CYTON) {  // LIVE
        // fill(Xcolor);
        // text("X " + nf(currentXvalue, 1, 3), x+10, y+40);
        // fill(Ycolor);
        // text("Y " + nf(currentYvalue, 1, 3), x+10, y+80);
        // fill(Zcolor);
        // text("Z " + nf(currentZvalue, 1, 3), x+10, y+120);
        markerModeButton.draw();
        drawMarkerValues();
        drawMarkerWave();
      } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  // SYNTHETIC
        // fill(Xcolor);
        // text("X "+nf(currentXvalue, 1, 3), x+10, y+40);
        // fill(Ycolor);
        // text("Y "+nf(currentYvalue, 1, 3), x+10, y+80);
        // fill(Zcolor);
        // text("Z "+nf(currentZvalue, 1, 3), x+10, y+120);
        drawMarkerValues();
        drawMarkerWave();
      }
      else {  // PLAYBACK
        drawMarkerValues();
        drawMarkerWave2();
      }
    }

    // pushStyle();
    // textFont(h1,24);
    // fill(bgColor);
    // textAlign(CENTER,CENTER);
    // text(widgetTitle, x + w/2, y + h/2);
    // popStyle();
    popStyle();
  }

  void setGraphDimensions(){
    MarkerWindowWidth = w - padding*2;
    MarkerWindowHeight = int((float(h) - float(padding*3)));
    MarkerWindowX = x + padding;
    MarkerWindowY = y + h - MarkerWindowHeight - padding;

  }

  void screenResized(){
    int prevX = x;
    int prevY = y;
    int prevW = w;
    int prevH = h;

    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    int dy = y - prevY;
    println("dy = " + dy);

    //put your code here...
    // MarkerWindowWidth = int(w) - 10;
    // MarkerWindowX = int(x)+5;
    // MarkerWindowY = int(y)-10+int(h)/2;
    //
    // PolarWindowX = x+MarkerWindowWidth-90;
    // PolarWindowY = y+83;
    // PolarCorner = (sqrt(2)*PolarWindowWidth/2)/2;
    println("Acc Widget -- Screen Resized.");

    setGraphDimensions();

    //empty arrays to start redrawing from scratch
    for (int i=0; i<X.length; i++) {  // initialize the accelerometer data
      X[i] = MarkerWindowY + MarkerWindowHeight/4; // X at 1/4
    }

    markerModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    if (markerModeButton.isMouseHere()) {
      markerModeButton.setIsActive(true);
    }
  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(markerModeButton.isActive && markerModeButton.isMouseHere()){
      // println("digitalModeButton...");
      if(cyton.isPortOpen()) {
        if (cyton.getBoardMode() != BOARD_MODE_MARKER) {
          cyton.setBoardMode(BOARD_MODE_MARKER);
          output("Starting to read markers");
          markerModeButton.setString("Turn Marker Off");
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
          markerModeButton.setString("Turn Marker On");
        }
      }
    }
    markerModeButton.setIsActive(false);
  }

  //add custom classes functions here
  void drawMarkerValues() {
    textAlign(LEFT,CENTER);
    textFont(h1,20);
    fill(Xcolor);
    text("Last Marker = " + lastMarker, x+padding , y + (h/12)*1.5);
  }

  void shiftWave() {
    for (int i = 0; i < X.length-1; i++) {      // move the pulse waveform by
      X[i] = X[i+1];
    }
  }

  void drawMarkerWave() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < X.length; i++) {
      // int xi = int(map(i, 0, X.length-1, 0, MarkerWindowWidth-1));
      // vertex(MarkerWindowX+xi, X[i]);                    //draw a line connecting the data points
      int xi = int(map(i, 0, X.length-1, 0, MarkerWindowWidth-1));
      // int yi = int(map(X[i], yMaxMin, -yMaxMin, 0.0, MarkerWindowHeight-1));
      // int yi = 2;
      vertex(MarkerWindowX+xi, X[i]);                    //draw a line connecting the data points
    }
    endShape();
  }

  void drawMarkerWave2() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int x = int(map(accelerometerBuff[0][i], -yMaxMin, yMaxMin, float(MarkerWindowY+MarkerWindowHeight), float(MarkerWindowY)));  // ss
      x = constrain(x, MarkerWindowY, MarkerWindowY+MarkerWindowHeight);
      vertex(MarkerWindowX+i, x);                    //draw a line connecting the data points
    }
    endShape();
  }

  void synthesizeMarkerData() {
    synthTime += 0.02;
    
    if (synthCount++ > 10){      
      currentXvalue =  (sin(synthTime) +1.0)*127.;
      lastMarker = int(currentXvalue);
      synthCount = 0;
    } else {
      currentXvalue = 0.0;
    }


    X[X.length-1] = int(map(logScaleMarker(currentXvalue), 0, yMaxMin, float(MarkerWindowY+MarkerWindowHeight), float(MarkerWindowY)));
        X[X.length-1] = constrain(X[X.length-1], MarkerWindowY, MarkerWindowY+MarkerWindowHeight);
  }


  int logScaleMarker( float value ) {
    // this returns log value between 0 and yMaxMin for a value between 0. and 265.
    return int(log(int(value)+1.0)*yMaxMin/log(265.0));
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