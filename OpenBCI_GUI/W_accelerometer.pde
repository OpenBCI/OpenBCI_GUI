
////////////////////////////////////////////////////
//
//  W_accelerometer is used to visualize accelerometer data
//
//  Created: Joel Murphy
//  Modified: Colin Fausnaught, September 2016
//  Modified: Wangshu Sun, November 2016
//  Modified: Richard Waltman, November 2018
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
  int accelBuffSize = 500; //points registered in accelerometer buff
  int[] xLimOptions = {1, 3, 5, 10, 20}; // number of seconds (x axis of graph)
  int accelInitialHorizScaleIndex = 3;
  AccelerometerBar[] accelerometerBar;

  // bottom xyz graph
  int accelGraphWidth;
  int accelGraphHeight;
  int accelGraphX;
  int accelGraphY;
  int numAccelerometerBars = 1;
  int accPadding = 30;

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
  private boolean visible = true;
  private boolean updating = true;
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
    X = new int[accelBuffSize];
    Y = new int[accelBuffSize];
    Z = new int[accelBuffSize];

    // for synthesizing values
    Xrising = true;
    Yrising = false;
    Zrising = true;

    // initialize data
    for (int i=0; i<X.length; i++) {  // initialize the accelerometer data
      X[i] = accelGraphY + accelGraphHeight/4; // X at 1/4
      Y[i] = accelGraphY + accelGraphHeight/2;  // Y at 1/2
      Z[i] = accelGraphY + (accelGraphHeight/4)*3;  // Z at 3/4
    }

    accelerometerBar = new AccelerometerBar[numAccelerometerBars];

    //create our channel bar and populate our accelerometerBar array!
    println("init accelerometer bar");
    int analogReadBarY = int(accelGraphY) + (accelGraphHeight); //iterate through bar locations
    AccelerometerBar tempBar = new AccelerometerBar(_parent, accelGraphX, accelGraphY, accelGraphWidth, accelGraphHeight); //int _channelNumber, int _x, int _y, int _w, int _h
    accelerometerBar[0] = tempBar;
    //accelerometerBar[0].adjustVertScale(yLimOptions[arInitialVertScaleIndex]);
    accelerometerBar[0].adjustTimeAxis(xLimOptions[accelInitialHorizScaleIndex]);


    String defaultAccelModeButtonString;
    if (eegDataSource == DATASOURCE_GANGLION) {
      defaultAccelModeButtonString = "Turn Accel. Off";
    } else {
      defaultAccelModeButtonString = "Turn Accel. On";
    }
    accelModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, defaultAccelModeButtonString, 12);
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

  public boolean isVisible() {
    return visible;
  }
  public boolean isUpdating() {
    return updating;
  }

  public void setVisible(boolean _visible) {
    visible = _visible;
  }
  public void setUpdating(boolean _updating) {
    updating = _updating;
  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
    //put your code here...
    if (isRunning) {
      updatePlotPoints();
      //feed new data to into plot
      accelerometerBar[0].update();

    }
  }

  void updatePlotPoints() {
    if (eegDataSource == DATASOURCE_SYNTHETIC) {
      synthesizeaccelData();
      currentXvalue = map(X[X.length-1], accelGraphY, accelGraphY+accelGraphHeight, yMaxMin, -yMaxMin);
      currentYvalue = map(Y[Y.length-1], accelGraphY, accelGraphY+accelGraphHeight, yMaxMin, -yMaxMin);
      currentZvalue = map(Z[Z.length-1], accelGraphY, accelGraphY+accelGraphHeight, yMaxMin, -yMaxMin);
      shiftWave();
    } else if (eegDataSource == DATASOURCE_CYTON) {
      currentXvalue = hub.validAccelValues[0] * cyton.get_scale_fac_accel_G_per_count();
      currentYvalue = hub.validAccelValues[1] * cyton.get_scale_fac_accel_G_per_count();
      currentZvalue = hub.validAccelValues[2] * cyton.get_scale_fac_accel_G_per_count();
      X[X.length-1] =
        int(map(currentXvalue, -yMaxMin, yMaxMin, float(accelGraphY+accelGraphHeight), float(accelGraphY)));
      X[X.length-1] = constrain(X[X.length-1], accelGraphY, accelGraphY+accelGraphHeight);
      Y[Y.length-1] =
        int(map(currentYvalue, -yMaxMin, yMaxMin, float(accelGraphY+accelGraphHeight), float(accelGraphY)));
      Y[Y.length-1] = constrain(Y[Y.length-1], accelGraphY, accelGraphY+accelGraphHeight);
      Z[Z.length-1] =
        int(map(currentZvalue, -yMaxMin, yMaxMin, float(accelGraphY+accelGraphHeight), float(accelGraphY)));
      Z[Z.length-1] = constrain(Z[Z.length-1], accelGraphY, accelGraphY+accelGraphHeight);

      shiftWave();
    } else if (eegDataSource == DATASOURCE_GANGLION) {
      currentXvalue = hub.validAccelValues[0] * ganglion.get_scale_fac_accel_G_per_count();
      currentYvalue = hub.validAccelValues[1] * ganglion.get_scale_fac_accel_G_per_count();
      currentZvalue = hub.validAccelValues[2] * ganglion.get_scale_fac_accel_G_per_count();
      X[X.length-1] =
        int(map(currentXvalue, -yMaxMin, yMaxMin, float(accelGraphY+accelGraphHeight), float(accelGraphY)));
      X[X.length-1] = constrain(X[X.length-1], accelGraphY, accelGraphY+accelGraphHeight);
      Y[Y.length-1] =
        int(map(currentYvalue, -yMaxMin, yMaxMin, float(accelGraphY+accelGraphHeight), float(accelGraphY)));
      Y[Y.length-1] = constrain(Y[Y.length-1], accelGraphY, accelGraphY+accelGraphHeight);
      Z[Z.length-1] =
        int(map(currentZvalue, -yMaxMin, yMaxMin, float(accelGraphY+accelGraphHeight), float(accelGraphY)));
      Z[Z.length-1] = constrain(Z[Z.length-1], accelGraphY, accelGraphY+accelGraphHeight);

      shiftWave();
    } else {  // playback data
      currentXvalue = accelerometerBuff[0][accelerometerBuff[0].length-1];
      currentYvalue = accelerometerBuff[1][accelerometerBuff[1].length-1];
      currentZvalue = accelerometerBuff[2][accelerometerBuff[2].length-1];
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

    fill(50);
    textFont(p5, 12);
    textAlign(CENTER,CENTER);
    int yAxisTextPadding = int(accPadding*.75);
    text("+"+(int)yMaxMin+"g", accelGraphX + yAxisTextPadding, accelGraphY);
    text("0g", accelGraphX + yAxisTextPadding, accelGraphY + accelGraphHeight/2);
    text("-"+(int)yMaxMin+"g", accelGraphX + yAxisTextPadding, accelGraphY + accelGraphHeight);

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
      drawAccValues();
      draw3DGraph();
      //drawAccWave();
      if (cyton.getBoardMode() != BOARD_MODE_DEFAULT) {
        accelModeButton.setString("Turn Accel. On");
        accelModeButton.draw();
      }
    } else if (eegDataSource == DATASOURCE_GANGLION) {
      if (ganglion.isBLE()) accelModeButton.draw();
      if (accelerometerModeOn) {
        drawAccValues();
        draw3DGraph();
        //drawAccWave();
      }
    } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  // SYNTHETIC
      drawAccValues();
      draw3DGraph();
      //drawAccWave();
      accelerometerBar[0].draw();
    }
    else {  // PLAYBACK
      drawAccValues();
      draw3DGraph();
      //drawAccWave2();
      accelerometerBar[0].draw();
    }

    popStyle();
  }

  void setGraphDimensions(){
    //println("accel w "+w);
    //println("accel h "+h);
    //println("accel x "+x);
    //println("accel y "+y);
    accelGraphWidth = w - accPadding*2;
    accelGraphHeight = int((float(h) - float(accPadding*3))/2.0);
    accelGraphX = x + accPadding/3;
    accelGraphY = y + h - accelGraphHeight - accPadding;

    // PolarWindowWidth = 155;
    // PolarWindowHeight = 155;
    PolarWindowWidth = accelGraphHeight;
    PolarWindowHeight = accelGraphHeight;
    PolarWindowX = x + w - accPadding - PolarWindowWidth/2;
    PolarWindowY = y + accPadding + PolarWindowHeight/2;
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
      X[i] = accelGraphY + accelGraphHeight/4; // X at 1/4
      Y[i] = accelGraphY + accelGraphHeight/2;  // Y at 1/2
      Z[i] = accelGraphY + (accelGraphHeight/4)*3;  // Z at 3/4
    }

    accelerometerBar[0].screenResized(accelGraphX, accelGraphY, accelGraphWidth-accPadding*2, accelGraphHeight); //bar x, bar y, bar w, bar h

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
          accelModeButton.setString("Turn Accel. On");
          accelerometerModeOn = false;
        } else{
          ganglion.accelStart();
          accelModeButton.setString("Turn Accel. Off");
          accelerometerModeOn = true;
        }
        //accelerometerModeOn = !accelerometerModeOn;
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
    text("X = " + nf(currentXvalue, 1, 3) + " g", x+accPadding , y + (h/12)*1.5);
    fill(Ycolor);
    text("Y = " + nf(currentYvalue, 1, 3) + " g", x+accPadding, y + (h/12)*3);
    fill(Zcolor);
    text("Z = " + nf(currentZvalue, 1, 3) + " g", x+accPadding, y + (h/12)*4.5);
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
      // int xi = int(map(i, 0, X.length-1, 0, accelGraphWidth-1));
      // vertex(accelGraphX+xi, X[i]);                    //draw a line connecting the data points
      int xi = int(map(i, 0, X.length-1, 0, accelGraphWidth-1));
      // int yi = int(map(X[i], yMaxMin, -yMaxMin, 0.0, accelGraphHeight-1));
      // int yi = 2;
      vertex(accelGraphX+xi, X[i]);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < Y.length; i++) {
      int xi = int(map(i, 0, X.length-1, 0, accelGraphWidth-1));//scale/map the data points
      vertex(accelGraphX+xi, Y[i]);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < Z.length; i++) {
      int xi = int(map(i, 0, X.length-1, 0, accelGraphWidth-1));
      vertex(accelGraphX+xi, Z[i]);
    }
    endShape();
  }

  void drawAccWave2() { //used to draw playback data
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int x = int(map(accelerometerBuff[0][i], -yMaxMin, yMaxMin, float(accelGraphY+accelGraphHeight), float(accelGraphY)));  // ss
      x = constrain(x, accelGraphY, accelGraphY+accelGraphHeight);
      int xi = int(map(i, 0, accelerometerBuff[0].length-1, 0, accelGraphWidth-1)); //this makes playback accel data scale properly
      vertex(accelGraphX+xi, x);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < accelerometerBuff[1].length; i++) {
      int y = int(map(accelerometerBuff[1][i], -yMaxMin, yMaxMin, float(accelGraphY+accelGraphHeight), float(accelGraphY)));  // ss
      y = constrain(y, accelGraphY, accelGraphY+accelGraphHeight);
      int xi = int(map(i, 0, accelerometerBuff[1].length-1, 0, accelGraphWidth-1));
      vertex(accelGraphX+xi, y);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < accelerometerBuff[2].length; i++) {
      int z = int(map(accelerometerBuff[2][i], -yMaxMin, yMaxMin, float(accelGraphY+accelGraphHeight), float(accelGraphY)));  // ss
      z = constrain(z, accelGraphY, accelGraphY+accelGraphHeight);
      int xi = int(map(i, 0, accelerometerBuff[2].length-1, 0, accelGraphWidth-1));
      vertex(accelGraphX+xi, z);
    }
    endShape();
  }

  void synthesizeaccelData() {
    if (Xrising) {  // MAKE A SAW WAVE FOR TESTING
      X[X.length-1]--;   // place the new raw datapoint at the end of the array
      if (X[X.length-1] <= accelGraphY) {
        Xrising = false;
      }
    } else {
      X[X.length-1]++;   // place the new raw datapoint at the end of the array
      if (X[X.length-1] >= accelGraphY+accelGraphHeight) {
        Xrising = true;
      }
    }

    if (Yrising) {  // MAKE A SAW WAVE FOR TESTING
      Y[Y.length-1]--;   // place the new raw datapoint at the end of the array
      if (Y[Y.length-1] <= accelGraphY) {
        Yrising = false;
      }
    } else {
      Y[Y.length-1]++;   // place the new raw datapoint at the end of the array
      if (Y[Y.length-1] >= accelGraphY+accelGraphHeight) {
        Yrising = true;
      }
    }

    if (Zrising) {  // MAKE A SAW WAVE FOR TESTING
      Z[Z.length-1]--;   // place the new raw datapoint at the end of the array
      if (Z[Z.length-1] <= accelGraphY) {
        Zrising = false;
      }
    } else {
      Z[Z.length-1]++;   // place the new raw datapoint at the end of the array
      if (Z[Z.length-1] >= accelGraphY+accelGraphHeight) {
        Zrising = true;
      }
    }
  }

};



//========================================================================================================================
//                      Accelerometer Graph Class -- Implemented by Accelerometer Widget Class
//========================================================================================================================
//this class contains the plot for the 2d graph of accelerometer data
class AccelerometerBar{

  int analogInputPin;
  int auxValuesPosition;
  String analogInputString;
  int x, y, w, h;
  boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware

  GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
  GPointsArray accelPointsX;
  GPointsArray accelPointsY;
  GPointsArray accelPointsZ;
  int nPoints;
  int numSeconds;
  float timeBetweenPoints;

  color channelColor; //color of plot trace

  boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
  int autoScaleYLim = 0;
  int lastProcessedDataPacketInd = 0;

  int[] accelData;

  AccelerometerBar(PApplet _parent, int _x, int _y, int _w, int _h){ // channel number, x/y location, height, width

    isOn = true;

    x = _x;
    y = _y;
    w = _w;
    h = _h;

    nPoints = 500;
    accelData = new int[nPoints];
    accelPointsX = new GPointsArray(nPoints);
    accelPointsY = new GPointsArray(nPoints);
    accelPointsZ = new GPointsArray(nPoints);
    timeBetweenPoints = (float)numSeconds / (float)nPoints;

    for (int i = 0; i < nPoints; i++) {
      float time = -(float)numSeconds + (float)i*timeBetweenPoints;
      float accelValueX = 1.0;
      float accelValueY = 0.0;
      float accelValueZ = -1.0;
      GPoint tempPointX = new GPoint(time, accelValueX);
      GPoint tempPointY = new GPoint(time, accelValueY);
      GPoint tempPointZ = new GPoint(time, accelValueZ);
      accelPointsX.add(i, tempPointX);
      accelPointsY.add(i, tempPointY);
      accelPointsZ.add(i, tempPointZ);
    }

    numSeconds = 10;
    plot = new GPlot(_parent);
    plot.setPos(x + 36 + 4, y);
    plot.setDim(w - 36 - 4, h);
    plot.setMar(0f, 0f, 0f, 0f);
    plot.setLineColor((int)channelColors[(auxValuesPosition)%8]);
    plot.setXLim(-10,0);
    plot.setYLim(-4.0,4.0);
    plot.setPointSize(2);
    plot.setPointColor(0);
    plot.getXAxis().setAxisLabelText("Time (s)");

    //set the plot points for X, Y, and Z axes
    plot.setPoints(accelPointsX);
    plot.setLineColor(color(224, 56, 45));
    plot.addLayer("layer 1", accelPointsY);
    plot.getLayer("layer 1").setLineColor(color(49, 113, 89));
    plot.addLayer("layer 2", accelPointsZ);
    plot.getLayer("layer 2").setLineColor(color(54, 87, 158));

  }

  void update(){

    //update the voltage value text string
    //String fmt; float val;

    //update the voltage values
    //val = hub.validAccelValues[auxValuesPosition];
    //analogValue.string = String.format(getFmt(val),val);

    // update data in plot
    //updatePlotPoints();
    if(isAutoscale){
      autoScale();
    }
  }

  void updatePlotPoints(){
    // update data in plot
    int numSamplesToProcess = curDataPacketInd - lastProcessedDataPacketInd;
    if (numSamplesToProcess < 0) {
      numSamplesToProcess += dataPacketBuff.length;
    }

    // Shift internal ring buffer numSamplesToProcess
    if (numSamplesToProcess > 0) {
      for(int i = 0; i < accelData.length - numSamplesToProcess; i++){
        accelData[i] = accelData[i + numSamplesToProcess];
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

      //int  = dataPacketBuff[lastProcessedDataPacketInd].auxValues[auxValuesPosition];

      //accelData[accelData.length - numSamplesToProcess + samplesProcessed] = voltage; //<>//

      samplesProcessed++;
    }

    if (numSamplesToProcess > 0) {
      for (int i = 0; i < nPoints; i++) {
        float time = -(float)numSeconds + (float)i*timeBetweenPoints;
        float accPointX = w_accelerometer.X[i];
        float accPointY = w_accelerometer.Y[i];
        float accPointZ = w_accelerometer.Z[i];
        GPoint tempPointX = new GPoint(time, accPointX + 1);
        GPoint tempPointY = new GPoint(time, accPointY);
        GPoint tempPointZ = new GPoint(time, accPointZ - 1);
        accelPointsX.set(i, tempPointX);
        accelPointsY.set(i, tempPointY);
        accelPointsZ.set(i, tempPointZ);

      }
      plot.setPoints(accelPointsX); //set the plot with 0.0 for all accelPoints to start
      plot.setLineColor(color(224, 56, 45));
      plot.addLayer("layer 1", accelPointsY);
      plot.getLayer("layer 1").setLineColor(color(49, 113, 89));
      plot.addLayer("layer 2", accelPointsZ);
      plot.getLayer("layer 2").setLineColor(color(54, 87, 158));
    }

  }

  void draw(){
    pushStyle();

    //draw plot
    stroke(31,69,110, 50);
    fill(color(125,30,12,30));

    rect(x + 36 + 4, y, w - 36 - 4, h);

    plot.beginDraw();
    plot.drawBox(); // we won't draw this eventually ...
    plot.drawGridLines(0);
    plot.drawLines();
    //plot.drawPoints();
    //plot.drawYAxis();
    plot.drawXAxis();
    plot.getXAxis().draw();

    plot.endDraw();
    popStyle();
  }

  int nPointsBasedOnDataSource(){
    return numSeconds * 25;
  }

  void adjustTimeAxis(int _newTimeSize){
    numSeconds = _newTimeSize;
    plot.setXLim(-_newTimeSize,0);

    nPoints = nPointsBasedOnDataSource();

    accelPointsX = new GPointsArray(nPoints);
    accelPointsY = new GPointsArray(nPoints);
    accelPointsZ = new GPointsArray(nPoints);
    if(_newTimeSize > 1){
      plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
    }else{
      plot.getXAxis().setNTicks(10);
    }
    if (w_accelerometer != null) {
      if(w_accelerometer.isUpdating()){
        updatePlotPoints();
      }
    }
    // println("New X axis = " + _newTimeSize);
  }

  void adjustVertScale(int _vertScaleValue){
    if(_vertScaleValue == 0){
      isAutoscale = true;
    } else {
      isAutoscale = false;
      plot.setYLim(-_vertScaleValue, _vertScaleValue);
    }
  }

  void autoScale(){
    autoScaleYLim = 0;
    for(int i = 0; i < nPoints; i++){
      if(int(abs(accelPointsX.getY(i))) > autoScaleYLim){
        autoScaleYLim = int(abs(accelPointsX.getY(i)));
      }
    }
    plot.setYLim(-autoScaleYLim, autoScaleYLim);
  }

  void screenResized(int _x, int _y, int _w, int _h){
    x = _x;
    y = _y;
    w = _w+100;
    h = _h;

    //reposition & resize the plot
    plot.setPos(x + 36 + 4, y);
    plot.setDim(w - 36 - 4, h);

  }
};
