
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
////////////////////////////////////////////////////


final color accelXcolor = color(224, 56, 45);
final color accelYcolor = color(49, 113, 89);
final color accelZcolor = color(54, 87, 158);

float[] accelArrayX;
float[] accelArrayY;
float[] accelArrayZ;
float accelXyzLimit = 4.0;

class W_accelerometer extends Widget {
  //to see all core variables/methods of the Widget class, refer to Widget.pde
  color graphStroke = color(210);
  color graphBG = color(245);
  color textColor = color(0);
  color strokeColor = color(138, 146, 153);
  color eggshell = color(255, 253, 248);

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

  float yMaxMin;

  float currentXvalue;
  float currentYvalue;
  float currentZvalue;

  //for synthesizing values
  boolean Xrising = false;
  boolean Yrising = true;
  boolean Zrising = true;
  float accelSynthRate = 0.23/sqrt(6);
  boolean OBCI_inited= true;
  private boolean visible = true;
  private boolean updating = true;
  boolean accelerometerModeOn = true;
  Button accelModeButton;

  W_accelerometer(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    setGraphDimensions();
    yMaxMin = adjustYMaxMinBasedOnSource();

    // XYZ buffer for bottom graph
    accelArrayX = new float[accelBuffSize];
    accelArrayY = new float[accelBuffSize];
    accelArrayZ = new float[accelBuffSize];

    // initialize data
    for(int i = 0; i < accelArrayX.length; i++) {  // initialize the accelerometer data
      accelArrayX[i] = accelXyzLimit;
      accelArrayY[i] = 0;
      accelArrayZ[i] = -accelXyzLimit;
    }

    //create our channel bar and populate our accelerometerBar array!
    accelerometerBar = new AccelerometerBar[numAccelerometerBars];
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
    accelModeButton.setHelpText("Click to activate/deactivate the accelerometer!");
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
      accelXyzLimit = 2.0;
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
    if (isRunning) {
      //update the current Accelerometer plot points
      updatePlotPoints();
      //update the line graph plot points
      accelerometerBar[0].update();
    }
  }

  void updatePlotPoints() {
    if (eegDataSource == DATASOURCE_SYNTHETIC) {
      synthesizeAccelData();
      currentXvalue = accelArrayX[accelArrayX.length-1];
      currentYvalue = accelArrayY[accelArrayY.length-1];
      currentZvalue = accelArrayZ[accelArrayZ.length-1];
      shiftWave();
    } else if (eegDataSource == DATASOURCE_CYTON) {
      currentXvalue = hub.validAccelValues[0] * cyton.get_scale_fac_accel_G_per_count();
      currentYvalue = hub.validAccelValues[1] * cyton.get_scale_fac_accel_G_per_count();
      currentZvalue = hub.validAccelValues[2] * cyton.get_scale_fac_accel_G_per_count();
      accelArrayX[accelArrayX.length-1] = currentXvalue;
      accelArrayY[accelArrayY.length-1] = currentYvalue;
      accelArrayZ[accelArrayZ.length-1] = currentZvalue;
      shiftWave();
    } else if (eegDataSource == DATASOURCE_GANGLION) {
      currentXvalue = hub.validAccelValues[0] * ganglion.get_scale_fac_accel_G_per_count();
      currentYvalue = hub.validAccelValues[1] * ganglion.get_scale_fac_accel_G_per_count();
      currentZvalue = hub.validAccelValues[2] * ganglion.get_scale_fac_accel_G_per_count();
      accelArrayX[accelArrayX.length-1] = currentXvalue;
      accelArrayY[accelArrayY.length-1] = currentYvalue;
      accelArrayZ[accelArrayZ.length-1] = currentZvalue;
      shiftWave();
    } else {  // playback data
      currentXvalue = accelerometerBuff[0][accelerometerBuff[0].length-1];
      currentYvalue = accelerometerBuff[1][accelerometerBuff[1].length-1];
      currentZvalue = accelerometerBuff[2][accelerometerBuff[2].length-1];
      accelArrayX[accelArrayX.length-1] = currentXvalue;
      accelArrayY[accelArrayY.length-1] = currentYvalue;
      accelArrayZ[accelArrayZ.length-1] = currentZvalue;
      shiftWave();
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
      accelerometerBar[0].draw();
      if (cyton.getBoardMode() != BOARD_MODE_DEFAULT) {
        accelModeButton.setString("Turn Accel. On");
        accelModeButton.draw();
      }
    } else if (eegDataSource == DATASOURCE_GANGLION) {
      if (accelerometerModeOn) {
        drawAccValues();
        draw3DGraph();
        accelerometerBar[0].draw();
      }
      if (ganglion.isBLE()) accelModeButton.draw();
    } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  // SYNTHETIC
      drawAccValues();
      draw3DGraph();
      accelerometerBar[0].draw();
    }
    else {  // PLAYBACK
      drawAccValues();
      draw3DGraph();
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
    setGraphDimensions();
    //resize the accelerometer line graph
    accelerometerBar[0].screenResized(accelGraphX, accelGraphY, accelGraphWidth-accPadding*2, accelGraphHeight); //bar x, bar y, bar w, bar h
    //update the position of the accel mode button
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

  //Draw the current accelerometer values as text
  void drawAccValues() {
    textAlign(LEFT,CENTER);
    textFont(h1,20);
    fill(accelXcolor);
    text("X = " + nf(currentXvalue, 1, 3) + " g", x+accPadding , y + (h/12)*1.5);
    fill(accelYcolor);
    text("Y = " + nf(currentYvalue, 1, 3) + " g", x+accPadding, y + (h/12)*3);
    fill(accelZcolor);
    text("Z = " + nf(currentZvalue, 1, 3) + " g", x+accPadding, y + (h/12)*4.5);
  }

  //Draw the current accelerometer values as a 3D graph
  void draw3DGraph() {
    noFill();
    strokeWeight(3);
    stroke(accelXcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map(currentXvalue, -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY);
    stroke(accelYcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map((sqrt(2)*currentYvalue/2), -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY+map((sqrt(2)*currentYvalue/2), -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
    stroke(accelZcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX, PolarWindowY+map(currentZvalue, -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
    strokeWeight(1);
  }

  //Shift the data in the accelerometer arrays
  void shiftWave() {
    for (int i = 0; i < accelArrayX.length-1; i++) {      // move the pulse waveform by
      accelArrayX[i] = accelArrayX[i+1];
      accelArrayY[i] = accelArrayY[i+1];
      accelArrayZ[i] = accelArrayZ[i+1];
    }
  }

  //Used during Synthetic data mode
  void synthesizeAccelData() {
    int endOfArray = accelArrayX.length-1;
    if (Xrising) {  // MAKE A SAW WAVE FOR TESTING
      accelArrayX[endOfArray] = accelArrayX[endOfArray] + accelSynthRate;// place the new raw datapoint at the end of the array
      if (accelArrayX[endOfArray] >= accelXyzLimit) {
        Xrising = false;
      }
    } else {
      accelArrayX[endOfArray] = accelArrayX[endOfArray] - accelSynthRate;// place the new raw datapoint at the end of the array
      if (accelArrayX[endOfArray] <= -accelXyzLimit) {
        Xrising = true;
      }
    }

    if (Yrising) {  // MAKE A SAW WAVE FOR TESTING
      accelArrayY[endOfArray] = accelArrayY[endOfArray] + accelSynthRate;// place the new raw datapoint at the end of the array
      if (accelArrayY[endOfArray] >= accelXyzLimit) {
        Yrising = false;
      }
    } else {
      accelArrayY[endOfArray] = accelArrayY[endOfArray] - accelSynthRate;// place the new raw datapoint at the end of the array
      if (accelArrayY[endOfArray] <= -accelXyzLimit) {
        Yrising = true;
      }
    }

    if (Zrising) {  // MAKE A SAW WAVE FOR TESTING
      accelArrayZ[endOfArray] = accelArrayZ[endOfArray] + accelSynthRate;// place the new raw datapoint at the end of the array
      if (accelArrayZ[endOfArray] >= accelXyzLimit) {
        Zrising = false;
      }
    } else {
      accelArrayZ[endOfArray] = accelArrayZ[endOfArray] - accelSynthRate; // place the new raw datapoint at the end of the array
      if (accelArrayZ[endOfArray] <= -accelXyzLimit) {
        Zrising = true;
      }
    }
  }//end void synthesizeAccelData
}//end W_accelerometer class

//========================================================================================================================
//                      Accelerometer Graph Class -- Implemented by Accelerometer Widget Class
//========================================================================================================================
//this class contains the plot for the 2d graph of accelerometer data
class AccelerometerBar{

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

  int[][] accelData;

  AccelerometerBar(PApplet _parent, int _x, int _y, int _w, int _h){ // channel number, x/y location, height, width

    isOn = true;

    x = _x;
    y = _y;
    w = _w;
    h = _h;

    numSeconds = 10;
    plot = new GPlot(_parent);
    plot.setPos(x + 36 + 4, y);
    plot.setDim(w - 36 - 4, h);
    plot.setMar(0f, 0f, 0f, 0f);
    plot.setLineColor((int)channelColors[(NUM_ACCEL_DIMS)%8]);
    plot.setXLim(-10,0);
    plot.setYLim(-accelXyzLimit,accelXyzLimit);
    plot.setPointSize(2);
    plot.setPointColor(0);
    plot.getXAxis().setAxisLabelText("Time (s)");

    nPoints = 500;
    accelData = new int[NUM_ACCEL_DIMS][nPoints];
    accelPointsX = new GPointsArray(nPoints);
    accelPointsY = new GPointsArray(nPoints);
    accelPointsZ = new GPointsArray(nPoints);
    timeBetweenPoints = (float)numSeconds / (float)nPoints;

    for (int i = 0; i < nPoints; i++) {
      float time = -(float)numSeconds + (float)i*timeBetweenPoints;
      GPoint tempPointX = new GPoint(time, accelArrayX[i]);
      GPoint tempPointY = new GPoint(time, accelArrayY[i]);
      GPoint tempPointZ = new GPoint(time, accelArrayZ[i]);
      accelPointsX.add(i, tempPointX);
      accelPointsY.add(i, tempPointY);
      accelPointsZ.add(i, tempPointZ);
    }

    //set the plot points for X, Y, and Z axes
    plot.addLayer("layer 1", accelPointsX);
    plot.getLayer("layer 1").setLineColor(accelXcolor);
    plot.addLayer("layer 2", accelPointsY);
    plot.getLayer("layer 2").setLineColor(accelYcolor);
    plot.addLayer("layer 3", accelPointsZ);
    plot.getLayer("layer 3").setLineColor(accelZcolor);

  }

  //Used to update the accelerometerBar class
  void update(){
    updatePlotPoints();
    if(isAutoscale){
      //autoScale();
    }
  }

  //Used to update the Points within the graph
  void updatePlotPoints(){
    for (int i = 0; i < accelArrayX.length; i++) {
      float time = -(float)numSeconds + (float)i*timeBetweenPoints;
      GPoint tempPointX = new GPoint(time, accelArrayX[i]);
      GPoint tempPointY = new GPoint(time, accelArrayY[i]);
      GPoint tempPointZ = new GPoint(time, accelArrayZ[i]);
      accelPointsX.set(i, tempPointX);
      accelPointsY.set(i, tempPointY);
      accelPointsZ.set(i, tempPointZ);
    }
    plot.setPoints(accelPointsX, "layer 1");
    plot.setPoints(accelPointsY, "layer 2");
    plot.setPoints(accelPointsZ, "layer 3");
  }

  void draw(){
    pushStyle();
    plot.beginDraw();
    plot.drawBox(); // we won't draw this eventually ...
    plot.drawGridLines(0);
    plot.drawLines(); //Draw a Line graph!
    //plot.drawPoints(); //Used to draw Points instead of Lines
    plot.drawYAxis();
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
