
////////////////////////////////////////////////////
//
// W_accelerometer is used to visualize accelerometer data
//
// Created: Joel Murphy
// Modified: Colin Fausnaught, September 2016
// Modified: Wangshu Sun, November 2016
// Modified: Richard Waltman, November 2018
//
//
////////////////////////////////////////////////////

//Use the same colors for X,Y,Z throughout Accelerometer widget
final color ACCEL_X_COLOR = color(224, 56, 45);
final color ACCEL_Y_COLOR = color(49, 113, 89);
final color ACCEL_Z_COLOR = color(54, 87, 158);

float[][] accelArray; //holds X,Y,Z values for up to 20s
float accelXyzLimit = 4.0; //hard limit on all accel values

class W_accelerometer extends Widget {
  //To see all core variables/methods of the Widget class, refer to Widget.pde
  color graphStroke = color(210);
  color graphBG = color(245);
  color textColor = color(0);
  color strokeColor = color(138, 146, 153);
  color eggshell = color(255, 253, 248);

  //Graphing variables
  int[] xLimOptions = {0, 1, 3, 5, 10, 20}; //number of seconds (x axis of graph)
  int[] yLimOptions = {0, 1, 2, 4};
  int accelInitialHorizScaleIndex = accHorizScaleSave; //default to 10 second view
  int accelHorizLimit = 20;
  //Number of points, used to make buffers
  int accelBuffSize;
  AccelerometerBar accelerometerBar;

  //Bottom xyz graph
  int accelGraphWidth;
  int accelGraphHeight;
  int accelGraphX;
  int accelGraphY;
  int accPadding = 30;

  //Circular 3d xyz graph
  float PolarWindowX;
  float PolarWindowY;
  int PolarWindowWidth;
  int PolarWindowHeight;
  float PolarCorner;

  float yMaxMin;

  float[] currentAccelVals;

  //For synthesizing values
  boolean[] accelRising;
  //boolean Xrising = false;
  //boolean Yrising = true;
  //boolean Zrising = true;
  float accelSynthRate = 0.23/sqrt(6);
  boolean OBCI_inited= true;
  private boolean visible = true;
  private boolean updating = true;
  boolean accelInitHasOccured = false;
  boolean accelerometerModeOn = true;
  Button accelModeButton;

  W_accelerometer(PApplet _parent) {
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //Default dropdown settings
    accVertScaleSave = 2;
    accHorizScaleSave = 0;

    //Make dropdowns
    addDropdown("accelVertScale", "Vert Scale", Arrays.asList(accVertScaleArray), accVertScaleSave);
    addDropdown("accelDuration", "Window", Arrays.asList(accHorizScaleArray), accHorizScaleSave);

    setGraphDimensions();
    yMaxMin = adjustYMaxMinBasedOnSource();

    //XYZ buffer for bottom graph
    accelBuffSize = nPointsBasedOnDataSource();   //accelBuffSize = 20 seconds * 25 Hz
    accelArray = new float[NUM_ACCEL_DIMS][accelBuffSize];
    accelRising = new boolean[NUM_ACCEL_DIMS];
    initAccelData();
    currentAccelVals = new float[NUM_ACCEL_DIMS];

    //create our channel bar and populate our accelerometerBar array!
    println("init accelerometer bar");
    int analogReadBarY = int(accelGraphY) + (accelGraphHeight); //iterate through bar locations
    AccelerometerBar tempBar = new AccelerometerBar(_parent, accelGraphX, accelGraphY, accelGraphWidth, accelGraphHeight); //int _channelNumber, int _x, int _y, int _w, int _h
    accelerometerBar = tempBar;
    //accelerometerBar.adjustVertScale(yLimOptions[arInitialVertScaleIndex]);
    //sync horiz axis to Time Series by default
    accelerometerBar.adjustTimeAxis(w_timeSeries.xLimOptions[tsHorizScaleSave]);

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

  void initAccelData() {
    //initialize data
    for (int i = 0; i < accelArray[0].length; i++) {  //initialize the accelerometer data
      accelArray[0][i] = accelXyzLimit/2;
      accelArray[1][i] = 0;
      accelArray[2][i] = -accelXyzLimit/2;
    }
    accelRising[0] = false;
    accelRising[1] = true;
    accelRising[2] = true;
  }

  float adjustYMaxMinBasedOnSource() {
    float _yMaxMin;
    if (eegDataSource == DATASOURCE_CYTON) {
      _yMaxMin = 4.0;
    }else if (eegDataSource == DATASOURCE_GANGLION || nchan == 4) {
      _yMaxMin = 2.0;
      accelXyzLimit = 2.0;
    }else{
      _yMaxMin = 4.0;
    }
    return _yMaxMin;
  }

  int nPointsBasedOnDataSource() {
    return accelHorizLimit * (int)getSampleRateSafe();
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

  void update() {
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    if (isRunning && accelerometerModeOn) {
      //update the current Accelerometer values
      updateAccelPoints();
      //update the line graph and corresponding gplot points
      accelerometerBar.update();
    }
  }

  void updateAccelPoints() {
    for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
      if (eegDataSource == DATASOURCE_SYNTHETIC) {
        synthesizeAccelData();
      } else if (eegDataSource == DATASOURCE_CYTON) {
        currentAccelVals[i] = hub.validAccelValues[i] * cyton.get_scale_fac_accel_G_per_count();
      } else if (eegDataSource == DATASOURCE_GANGLION) {
        currentAccelVals[i] = hub.validAccelValues[i] * ganglion.get_scale_fac_accel_G_per_count();
      } else {  //playback data
        currentAccelVals[i] = accelerometerBuff[i][accelerometerBuff[i].length-1];
      }
    }
  }

  void draw() {
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

    fill(graphBG);  //pulse window background
    stroke(graphStroke);
    ellipse(PolarWindowX,PolarWindowY,PolarWindowWidth,PolarWindowHeight);

    stroke(180);
    line(PolarWindowX-PolarWindowWidth/2, PolarWindowY, PolarWindowX+PolarWindowWidth/2, PolarWindowY);
    line(PolarWindowX, PolarWindowY-PolarWindowHeight/2, PolarWindowX, PolarWindowY+PolarWindowHeight/2);
    line(PolarWindowX-PolarCorner, PolarWindowY+PolarCorner, PolarWindowX+PolarCorner, PolarWindowY-PolarCorner);

    fill(50);
    textFont(p3, 16);

    if (eegDataSource == DATASOURCE_CYTON) {  //LIVE CYTON
      drawAccValues();
      draw3DGraph();
      if (cyton.getBoardMode() != BOARD_MODE_DEFAULT) {
        accelModeButton.setString("Turn Accel. On");
        accelModeButton.draw();
      } else {
        accelerometerBar.draw();
      }
    } else if (eegDataSource == DATASOURCE_GANGLION) {  //LIVE GANGLION
      if (accelerometerModeOn) {
        drawAccValues();
        draw3DGraph();
        accelerometerBar.draw();
      }
      if (ganglion.isBLE()) accelModeButton.draw();
    } else {  //SYNTHETIC and PLAYBACK
      drawAccValues();
      draw3DGraph();
      accelerometerBar.draw();
    }

    popStyle();
  }

  void setGraphDimensions() {
    //println("accel w "+w);
    //println("accel h "+h);
    //println("accel x "+x);
    //println("accel y "+y);
    accelGraphWidth = w - accPadding*2;
    accelGraphHeight = int((float(h) - float(accPadding*3))/2.0);
    accelGraphX = x + accPadding/3;
    accelGraphY = y + h - accelGraphHeight - int(accPadding*2) + accPadding/6;

    //PolarWindowWidth = 155;
    //PolarWindowHeight = 155;
    PolarWindowWidth = accelGraphHeight;
    PolarWindowHeight = accelGraphHeight;
    PolarWindowX = x + w - accPadding - PolarWindowWidth/2;
    PolarWindowY = y + accPadding + PolarWindowHeight/2 - 10;
    PolarCorner = (sqrt(2)*PolarWindowWidth/2)/2;
  }

  void screenResized() {
    int prevX = x;
    int prevY = y;
    int prevW = w;
    int prevH = h;
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)
    setGraphDimensions();
    //resize the accelerometer line graph
    accelerometerBar.screenResized(accelGraphX, accelGraphY, accelGraphWidth-accPadding*2, accelGraphHeight); //bar x, bar y, bar w, bar h
    //update the position of the accel mode button
    accelModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
  }

  void mousePressed() {
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    if (eegDataSource == DATASOURCE_GANGLION) {
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

  void mouseReleased() {
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    if (eegDataSource == DATASOURCE_GANGLION) {
      if (accelModeButton.isActive && accelModeButton.isMouseHere()) {
        if (ganglion.isAccelModeActive()) {
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
      if (accelModeButton.isActive && accelModeButton.isMouseHere()) {
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
    fill(ACCEL_X_COLOR);
    text("X = " + nf(currentAccelVals[0], 1, 3) + " g", x+accPadding , y + (h/12)*1.5 - 5);
    fill(ACCEL_Y_COLOR);
    text("Y = " + nf(currentAccelVals[1], 1, 3) + " g", x+accPadding, y + (h/12)*3 - 5);
    fill(ACCEL_Z_COLOR);
    text("Z = " + nf(currentAccelVals[2], 1, 3) + " g", x+accPadding, y + (h/12)*4.5 - 5);
  }

  //Draw the current accelerometer values as a 3D graph
  void draw3DGraph() {
    noFill();
    strokeWeight(3);
    stroke(ACCEL_X_COLOR);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map(currentAccelVals[0], -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY);
    stroke(ACCEL_Y_COLOR);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map((sqrt(2)*currentAccelVals[1]/2), -yMaxMin, yMaxMin, -PolarWindowWidth/2, PolarWindowWidth/2), PolarWindowY+map((sqrt(2)*currentAccelVals[1]/2), -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
    stroke(ACCEL_Z_COLOR);
    line(PolarWindowX, PolarWindowY, PolarWindowX, PolarWindowY+map(currentAccelVals[2], -yMaxMin, yMaxMin, PolarWindowWidth/2, -PolarWindowWidth/2));
    strokeWeight(1);
  }

  //Used during Synthetic data mode
  void synthesizeAccelData() {
    float[] lastAccelVal = new float[NUM_ACCEL_DIMS];

    for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
      lastAccelVal[i] = accelArray[i][accelArray[i].length-1];
      if (accelRising[i]) {  //MAKE A SAW WAVE FOR TESTING
        currentAccelVals[i] = lastAccelVal[i] + accelSynthRate;//place the new raw datapoint at the end of the array
        if (currentAccelVals[i] >= accelXyzLimit) accelRising[i] = false;
      } else {
        currentAccelVals[i] = lastAccelVal[i] - accelSynthRate;//place the new raw datapoint at the end of the array
        if (currentAccelVals[i] <= -accelXyzLimit) accelRising[i] = true;
      }
    }
  }//end void synthesizeAccelData
};//end W_accelerometer class

//These functions are activated when an item from the corresponding dropdown is selected
void accelVertScale(int n) {
  accVertScaleSave = n;
  w_accelerometer.accelerometerBar.adjustVertScale(w_accelerometer.yLimOptions[n]);
  closeAllDropdowns();
}

//triggered when there is an event in the Duration Dropdown
void accelDuration(int n) {
  accHorizScaleSave = n;

  //Sync the duration of Time Series, Accelerometer, and Analog Read(Cyton Only)
  if (n == 0) {
    w_accelerometer.accelerometerBar.adjustTimeAxis(w_timeSeries.xLimOptions[tsHorizScaleSave]);
  } else {
    //set accelerometer x axis to the duration selected from dropdown
    w_accelerometer.accelerometerBar.adjustTimeAxis(w_accelerometer.xLimOptions[n]);
  }
  closeAllDropdowns();
}

//========================================================================================================================
//                     Accelerometer Graph Class -- Implemented by Accelerometer Widget Class
//========================================================================================================================
//this class contains the plot for the 2d graph of accelerometer data
class AccelerometerBar{

  int x, y, w, h;
  boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware
  int accBarPadding = 30;
  int xOffset;

  GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
  GPointsArray accelPointsX;
  GPointsArray accelPointsY;
  GPointsArray accelPointsZ;
  int nPoints;
  int numSeconds = 20; //default to 20 seconds
  float timeBetweenPoints;
  float[] accelTimeArray;
  int numSamplesToProcess;

  color channelColor; //color of plot trace

  boolean isAutoscale; //when isAutoscale equals true, the y-axis will automatically update to scale to the largest visible amplitude
  int autoScaleYLim = 0;
  int lastProcessedDataPacketInd = 0;

  AccelerometerBar(PApplet _parent, int _x, int _y, int _w, int _h) { //channel number, x/y location, height, width

    isOn = true;

    x = _x;
    y = _y;
    w = _w;
    h = _h;
    if (eegDataSource == DATASOURCE_CYTON) {
      xOffset = 22;
    } else {
      xOffset = 0;
    }

    plot = new GPlot(_parent);
    plot.setPos(x + 36 + 4 + xOffset, y); //match Accelerometer plot position with Time Series
    plot.setDim(w - 36 - 4 - xOffset, h);
    plot.setMar(0f, 0f, 0f, 0f);
    plot.setLineColor((int)channelColors[(NUM_ACCEL_DIMS)%8]);
    plot.setXLim(-numSeconds,0); //set the horizontal scale
    plot.setYLim(-accelXyzLimit,accelXyzLimit); //change this to adjust vertical scale
    //plot.setPointSize(2);
    plot.setPointColor(0);
    plot.getXAxis().setAxisLabelText("Time (s)");
    plot.getYAxis().setAxisLabelText("Acceleration (g)");
    plot.getXAxis().getAxisLabel().setOffset(float(accBarPadding));
    plot.getYAxis().getAxisLabel().setOffset(float(accBarPadding));

    nPoints = nPointsBasedOnDataSource();
    timeBetweenPoints = (float)numSeconds / (float)nPoints;
    accelTimeArray = new float[nPoints];
    for (int i = 0; i < accelTimeArray.length; i++) {
      accelTimeArray[i] = -(float)numSeconds + (float)i * timeBetweenPoints;
    }
    //make a GPoint array using float arrays x[] and y[] instead of plain index points
    accelPointsX = new GPointsArray(accelTimeArray, accelArray[0]);
    accelPointsY = new GPointsArray(accelTimeArray, accelArray[1]);
    accelPointsZ = new GPointsArray(accelTimeArray, accelArray[2]);

    //int accelBuffDiff = accelArrayX.length - nPoints;
    for (int i = 0; i < nPoints; i++) {
      //float time = -(float)numSeconds + (float)(i-accelBuffDiff)*timeBetweenPoints;
      GPoint tempPointX = new GPoint(accelTimeArray[i], accelArray[0][i]);
      GPoint tempPointY = new GPoint(accelTimeArray[i], accelArray[1][i]);
      GPoint tempPointZ = new GPoint(accelTimeArray[i], accelArray[2][i]);
      //println(accelTimeArray[i]);
      accelPointsX.set(i, tempPointX);
      accelPointsY.set(i, tempPointY);
      accelPointsZ.set(i, tempPointZ);
    }

    //set the plot points for X, Y, and Z axes
    plot.addLayer("layer 1", accelPointsX);
    plot.getLayer("layer 1").setLineColor(ACCEL_X_COLOR);
    plot.addLayer("layer 2", accelPointsY);
    plot.getLayer("layer 2").setLineColor(ACCEL_Y_COLOR);
    plot.addLayer("layer 3", accelPointsZ);
    plot.getLayer("layer 3").setLineColor(ACCEL_Z_COLOR);
  }

  //Used to update the accelerometerBar class
  void update() {
    updateGPlotPoints();
    if (isAutoscale) {
      autoScale();
    }
  }

  void draw() {
    pushStyle();
    plot.beginDraw();
    plot.drawBox(); //we won't draw this eventually ...
    plot.drawGridLines(0);
    plot.drawLines(); //Draw a Line graph!
    //plot.drawPoints(); //Used to draw Points instead of Lines
    plot.drawYAxis();
    plot.drawXAxis();
    plot.getXAxis().draw();
    plot.endDraw();
    popStyle();
  }

  int nPointsBasedOnDataSource() {
    return numSeconds * (int)getSampleRateSafe();
  }

  void adjustTimeAxis(int _newTimeSize) {
    numSeconds = _newTimeSize;
    plot.setXLim(-_newTimeSize,0);

    nPoints = nPointsBasedOnDataSource();
    timeBetweenPoints = (float)numSeconds / (float)nPoints;
    //println("Accelerometer Points:  " + nPoints + "||   Interval: " + timeBetweenPoints);

    //Calculate the array for GPlot X axis (Time)
    accelTimeArray = new float[nPoints];
    for (int i = 0; i < accelTimeArray.length; i++) {
      accelTimeArray[i] = -(float)numSeconds + (float)i * timeBetweenPoints;
    }
    //printArray(accelTimeArray);

    //Overwrite the existing GPointsArrays with a blank one of size == nPoints
    accelPointsX = new GPointsArray(nPoints);
    accelPointsY = new GPointsArray(nPoints);
    accelPointsZ = new GPointsArray(nPoints);

    //Set the number of axis divisions...
    if (_newTimeSize > 1) {
      plot.getXAxis().setNTicks(_newTimeSize);
    }else{
      plot.getXAxis().setNTicks(10);
    }

    //If user changes time window, and the accelerometer widget exists...
    if (w_accelerometer != null) {
      //...Redraw/update all of the points in the GPlot from the buffer
      setGPlotPoints(w_accelerometer.accelBuffSize);
    }
  }

  //Used to update the Points within the graph
  void updateGPlotPoints() {
    int accelBuffSize = w_accelerometer.accelBuffSize;

    //Update data in plot
    numSamplesToProcess = curDataPacketInd - lastProcessedDataPacketInd;
    if (numSamplesToProcess < 0) {
      numSamplesToProcess += dataPacketBuff.length;
    }

    //Shift internal ring buffer numSamplesToProcess
    if (numSamplesToProcess > 0) {
      for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
        for (int j = 0; j < accelArray[0].length - numSamplesToProcess; j++) {
          accelArray[i][j] = accelArray[i][j + numSamplesToProcess] ;
        }
      }
    }

    //for each new sample
    int samplesProcessed = 0;
    while (samplesProcessed < numSamplesToProcess) {
      lastProcessedDataPacketInd++;

      //Watch for wrap around
      if (lastProcessedDataPacketInd > dataPacketBuff.length - 1) {
        lastProcessedDataPacketInd = 0;
      }

      int curArrayInd = accelBuffSize - numSamplesToProcess + samplesProcessed;
      for (int i = 0; i < NUM_ACCEL_DIMS; i++) {
        accelArray[i][curArrayInd] = w_accelerometer.currentAccelVals[i];
      }

      samplesProcessed++;
    }

    //set all of the Gplot points
    setGPlotPoints(accelBuffSize);
  }

  void setGPlotPoints(int accelBuffSize) {
    //println("UPDATING ACCEL GRAPH");
    int accelBuffDiff = accelBuffSize - nPoints;
    if (numSamplesToProcess > 0) {
      for (int i = accelBuffDiff; i < accelBuffSize; i++) { //same method used in W_TimeSeries
        //float time = -(float)numSeconds + (float)(i-(accelBuffDiff))*timeBetweenPoints;
        GPoint tempPointX = new GPoint(accelTimeArray[i-accelBuffDiff], accelArray[0][i]);
        GPoint tempPointY = new GPoint(accelTimeArray[i-accelBuffDiff], accelArray[1][i]);
        GPoint tempPointZ = new GPoint(accelTimeArray[i-accelBuffDiff], accelArray[2][i]);
        accelPointsX.set(i-accelBuffDiff, tempPointX);
        accelPointsY.set(i-accelBuffDiff, tempPointY);
        accelPointsZ.set(i-accelBuffDiff, tempPointZ);
      }
      //set points in three layers on the same plot, just like old graph
      plot.setPoints(accelPointsX, "layer 1");
      plot.setPoints(accelPointsY, "layer 2");
      plot.setPoints(accelPointsZ, "layer 3");
    }
  }

  void adjustVertScale(int _vertScaleValue) {
    if (_vertScaleValue == 0) {
      isAutoscale = true;
    } else {
      isAutoscale = false;
      plot.setYLim(-_vertScaleValue, _vertScaleValue);
    }
  }

  void autoScale() {
    autoScaleYLim = 0;
    for (int i = 0; i < nPoints; i++) {
      if (int(abs(accelPointsX.getY(i))) > autoScaleYLim) {
        autoScaleYLim = int(abs(accelPointsX.getY(i)));
      }
    }
    plot.setYLim(-autoScaleYLim, autoScaleYLim);
  }

  void screenResized(int _x, int _y, int _w, int _h) {
    x = _x;
    y = _y;
    w = _w+100;
    h = _h;

    //reposition & resize the plot
    plot.setPos(x + 36 + 4 + xOffset, y);
    plot.setDim(w - 36 - 4 - xOffset, h);

  }
};
