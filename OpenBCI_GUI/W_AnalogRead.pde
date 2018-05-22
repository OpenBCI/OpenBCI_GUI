
////////////////////////////////////////////////////
//
//  W_AnalogRead is used to visiualze analog voltage values
//
//  Created: AJ Keller
//
//
///////////////////////////////////////////////////,

class W_AnalogRead extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...

  int numAnalogReadBars;
  float xF, yF, wF, hF;
  float ts_padding;
  float ts_x, ts_y, ts_h, ts_w; //values for actual time series chart (rectangle encompassing all analogReadBars)
  float plotBottomWell;
  float playbackWidgetHeight;
  int analogReadBarHeight;

  AnalogReadBar[] analogReadBars;

  int[] xLimOptions = {1, 3, 5, 7}; // number of seconds (x axis of graph)
  int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV

  boolean allowSpillover = false;

  TextBox[] chanValuesMontage;
  boolean showMontageValues;

  private boolean visible = true;
  private boolean updating = true;

 // these variables added to first tab to allow global access
 // int AnalogReadStartingVertScaleIndex = 5;
 // int AnalogReadStartingHorizontalScaleIndex = 2;

  private boolean hasScrollbar = false;

  Button analogModeButton;

  W_AnalogRead(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function

    addDropdown("VertScale_AR", "Vert Scale", Arrays.asList("Auto", "50", "100", "200", "400", "1000", "10000"), AnalogReadStartingVertScaleIndex);
    addDropdown("Duration_AR", "Window", Arrays.asList("1 sec", "3 sec", "5 sec", "7 sec"), AnalogReadStartingHorizontalScaleIndex);
    // addDropdown("Spillover", "Spillover", Arrays.asList("False", "True"), 0);

    //set number of anaolg reads
    if (cyton.isWifi()) {
      numAnalogReadBars = 2;
    } else {
      numAnalogReadBars = 3;
    }

    xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
    yF = float(y);
    wF = float(w);
    hF = float(h);

    plotBottomWell = 45.0; //this appears to be an arbitrary vertical space adds GPlot leaves at bottom, I derived it through trial and error
    ts_padding = 10.0;
    ts_x = xF + ts_padding;
    ts_y = yF + (ts_padding);
    ts_w = wF - ts_padding*2;
    ts_h = hF - playbackWidgetHeight - plotBottomWell - (ts_padding*2);
    analogReadBarHeight = int(ts_h/numAnalogReadBars);

    analogReadBars = new AnalogReadBar[numAnalogReadBars];

    //create our channel bars and populate our analogReadBars array!
    for(int i = 0; i < numAnalogReadBars; i++){
      println("init analog read bar " + i);
      int analogReadBarY = int(ts_y) + i*(analogReadBarHeight); //iterate through bar locations
      AnalogReadBar tempBar = new AnalogReadBar(_parent, i+5, int(ts_x), analogReadBarY, int(ts_w), analogReadBarHeight); //int _channelNumber, int _x, int _y, int _w, int _h
      analogReadBars[i] = tempBar;
      analogReadBars[i].adjustVertScale(yLimOptions[AnalogReadStartingVertScaleIndex]);
      analogReadBars[i].adjustTimeAxis(xLimOptions[AnalogReadStartingHorizontalScaleIndex]);
    }

    analogModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "Turn Analog Read On", 12);
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
    if(visible && updating){
      super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

      //put your code here...
      //update channel bars ... this means feeding new EEG data into plots
      for(int i = 0; i < numAnalogReadBars; i++){
        analogReadBars[i].update();
      }
    }
  }

  void draw(){
    if(visible){
      super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

      //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
      pushStyle();
      //draw channel bars
      analogModeButton.draw();
      if (cyton.getBoardMode() != BOARD_MODE_ANALOG) {
        analogModeButton.setString("Turn Analog Read On");
      } else {
        analogModeButton.setString("Turn Analog Read Off");
        for(int i = 0; i < numAnalogReadBars; i++){
          analogReadBars[i].draw();
        }
      }
      popStyle();
    }
  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
    yF = float(y);
    wF = float(w);
    hF = float(h);

    ts_x = xF + ts_padding;
    ts_y = yF + (ts_padding);
    ts_w = wF - ts_padding*2;
    ts_h = hF - playbackWidgetHeight - plotBottomWell - (ts_padding*2);
    analogReadBarHeight = int(ts_h/numAnalogReadBars);

    for(int i = 0; i < numAnalogReadBars; i++){
      int analogReadBarY = int(ts_y) + i*(analogReadBarHeight); //iterate through bar locations
      analogReadBars[i].screenResized(int(ts_x), analogReadBarY, int(ts_w), analogReadBarHeight); //bar x, bar y, bar w, bar h
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
          if (cyton.isWifi()) {
            output("Starting to read analog inputs on pin marked A5 (D11) and A6 (D12)");
          } else {
            output("Starting to read analog inputs on pin marked A5 (D11), A6 (D12) and A7 (D13)");
          }
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
        }
      }
    }
    analogModeButton.setIsActive(false);
  }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void VertScale_AR(int n) {
  if (n==0) { //autoscale
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustVertScale(0);
    }
  } else if(n==1) { //50uV
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustVertScale(50);
    }
  } else if(n==2) { //100uV
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustVertScale(100);
    }
  } else if(n==3) { //200uV
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustVertScale(200);
    }
  } else if(n==4) { //400uV
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustVertScale(400);
    }
  } else if(n==5) { //1000uV
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustVertScale(1000);
    }
  } else if(n==6) { //10000uV
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustVertScale(10000);
    }
  }
  closeAllDropdowns();
}

//triggered when there is an event in the LogLin Dropdown
void Duration_AR(int n) {
  // println("adjust duration to: ");
  if(n==0){ //set time series x axis to 1 secconds
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustTimeAxis(1);
    }
  } else if(n==1){ //set time series x axis to 3 secconds
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustTimeAxis(3);
    }
  } else if(n==2){ //set to 5 seconds
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustTimeAxis(5);
    }
  } else if(n==3){ //set to 7 seconds (max due to arry size ... 2000 total packets saved)
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
      w_analogRead.analogReadBars[i].adjustTimeAxis(7);
    }
  }
  closeAllDropdowns();
}

//========================================================================================================================
//                      Analog Voltage BAR CLASS -- Implemented by Analog Read Widget Class
//========================================================================================================================
//this class contains the plot and buttons for a single channel of the Time Series widget
//one of these will be created for each channel (4, 8, or 16)
class AnalogReadBar{

  int analogInputPin;
  int auxValuesPosition;
  String analogInputString;
  int x, y, w, h;
  boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware

  GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
  GPointsArray analogReadPoints;
  int nPoints;
  int numSeconds;
  float timeBetweenPoints;

  color channelColor; //color of plot trace

  boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
  int autoScaleYLim = 0;

  TextBox analogValue;
  TextBox analogPin;
  TextBox digitalPin;

  boolean drawAnalogValue;
  int lastProcessedDataPacketInd = 0;

  int[] analogReadData;

  AnalogReadBar(PApplet _parent, int _analogInputPin, int _x, int _y, int _w, int _h){ // channel number, x/y location, height, width

    analogInputPin = _analogInputPin;
    int digitalPinNum = 0;
    if (analogInputPin == 7) {
      auxValuesPosition = 2;
      digitalPinNum = 13;
    } else if (analogInputPin == 6) {
      auxValuesPosition = 1;
      digitalPinNum = 12;
    } else {
      analogInputPin = 5;
      auxValuesPosition = 0;
      digitalPinNum = 11;
    }

    analogInputString = str(analogInputPin);
    isOn = true;

    x = _x;
    y = _y;
    w = _w;
    h = _h;

    numSeconds = 5;
    plot = new GPlot(_parent);
    plot.setPos(x + 36 + 4, y);
    plot.setDim(w - 36 - 4, h);
    plot.setMar(0f, 0f, 0f, 0f);
    plot.setLineColor((int)channelColors[(auxValuesPosition)%8]);
    plot.setXLim(-3.2,-2.9);
    plot.setYLim(-200,200);
    plot.setPointSize(2);
    plot.setPointColor(0);
    if (cyton.isWifi()) {
      if(auxValuesPosition == 1){
        plot.getXAxis().setAxisLabelText("Time (s)");
      }
    } else {
      if(auxValuesPosition == 2){
        plot.getXAxis().setAxisLabelText("Time (s)");
      }
    }

    nPoints = nPointsBasedOnDataSource();

    analogReadData = new int[nPoints];

    analogReadPoints = new GPointsArray(nPoints);
    timeBetweenPoints = (float)numSeconds / (float)nPoints;

    for (int i = 0; i < nPoints; i++) {
      float time = -(float)numSeconds + (float)i*timeBetweenPoints;
      float analog_value = 0.0; //0.0 for all points to start
      GPoint tempPoint = new GPoint(time, analog_value);
      analogReadPoints.set(i, tempPoint);
    }

    plot.setPoints(analogReadPoints); //set the plot with 0.0 for all analogReadPoints to start

    analogValue = new TextBox("t", x + 36 + 4 + (w - 36 - 4) - 2, y + h);
    analogValue.textColor = color(bgColor);
    analogValue.alignH = RIGHT;
    // analogValue.alignV = TOP;
    analogValue.drawBackground = true;
    analogValue.backgroundColor = color(255,255,255,125);

    analogPin = new TextBox("A" + analogInputString, x+3, y + h);
    analogPin.textColor = color(bgColor);
    analogPin.alignH = CENTER;
    digitalPin = new TextBox("(D" + digitalPinNum + ")", x+3, y + h + 12);
    digitalPin.textColor = color(bgColor);
    digitalPin.alignH = CENTER;

    drawAnalogValue = true;

  }

  void update(){

    //update the voltage value text string
    String fmt; float val;

    //update the voltage values
    val = hub.validAccelValues[auxValuesPosition];
    analogValue.string = String.format(getFmt(val),val);

    // update data in plot
    updatePlotPoints();
    if(isAutoscale){
      autoScale();
    }
  }

  private String getFmt(float val) {
    String fmt;
      if (val > 100.0f) {
        fmt = "%.0f";
      } else if (val > 10.0f) {
        fmt = "%.1f";
      } else {
        fmt = "%.2f";
      }
      return fmt;
  }

  void updatePlotPoints(){
    // update data in plot
    int numSamplesToProcess = curDataPacketInd - lastProcessedDataPacketInd;
    if (numSamplesToProcess < 0) {
      numSamplesToProcess += dataPacketBuff.length;
    }

    // Shift internal ring buffer numSamplesToProcess
    if (numSamplesToProcess > 0) {
      for(int i = 0; i < analogReadData.length - numSamplesToProcess; i++){
        analogReadData[i] = analogReadData[i + numSamplesToProcess];
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

      int voltage = dataPacketBuff[lastProcessedDataPacketInd].auxValues[auxValuesPosition];

      analogReadData[analogReadData.length - numSamplesToProcess + samplesProcessed] = voltage; //<>// //<>// //<>//

      samplesProcessed++;
    }

    if (numSamplesToProcess > 0) {
      for (int i = 0; i < nPoints; i++) {
        float timey = -(float)numSeconds + (float)i*timeBetweenPoints;
        float voltage = analogReadData[i];

        GPoint tempPoint = new GPoint(timey, voltage);
        analogReadPoints.set(i, tempPoint);

      }
      plot.setPoints(analogReadPoints); //reset the plot with updated analogReadPoints
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
    // plot.drawPoints();
    // plot.drawYAxis();
    if (cyton.isWifi()) {
      if(auxValuesPosition == 1){ //only draw the x axis label on the bottom channel bar
        plot.drawXAxis();
        plot.getXAxis().draw();
      }
    } else {
      if(auxValuesPosition == 2){ //only draw the x axis label on the bottom channel bar
        plot.drawXAxis();
        plot.getXAxis().draw();
      }
    }

    plot.endDraw();

    if(drawAnalogValue){
      analogValue.draw();
      analogPin.draw();
      digitalPin.draw();
    }

    popStyle();
  }

  int nPointsBasedOnDataSource(){
    return numSeconds * (int)getSampleRateSafe();
  }

  void adjustTimeAxis(int _newTimeSize){
    numSeconds = _newTimeSize;
    plot.setXLim(-_newTimeSize,0);

    nPoints = nPointsBasedOnDataSource();

    analogReadPoints = new GPointsArray(nPoints);
    if(_newTimeSize > 1){
      plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
    }else{
      plot.getXAxis().setNTicks(10);
    }
    if (w_analogRead != null) {
      if(w_analogRead.isUpdating()){
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
      if(int(abs(analogReadPoints.getY(i))) > autoScaleYLim){
        autoScaleYLim = int(abs(analogReadPoints.getY(i)));
      }
    }
    plot.setYLim(-autoScaleYLim, autoScaleYLim);
  }

  void screenResized(int _x, int _y, int _w, int _h){
    x = _x;
    y = _y;
    w = _w;
    h = _h;

    //reposition & resize the plot
    plot.setPos(x + 36 + 4, y);
    plot.setDim(w - 36 - 4, h);

    analogValue.x = x + 36 + 4 + (w - 36 - 4) - 2;
    analogValue.y = y + h;

    analogPin.x = x + 14;
    analogPin.y = y + int(h/2.0);
    digitalPin.x = analogPin.x;
    digitalPin.y = analogPin.y + 12;
  }
};