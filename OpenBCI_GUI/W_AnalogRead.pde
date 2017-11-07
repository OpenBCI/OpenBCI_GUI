
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
  int AnalogGraphWindowWidth;
  int AnalogGraphWindowHeight;
  int AccelWindowX;
  int AccelWindowY;

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
      A5[i] = AccelWindowY + AnalogGraphWindowHeight/4; // A5 at 1/4
      A6[i] = AccelWindowY + AnalogGraphWindowHeight/2;  // A6 at 1/2
      A7[i] = AccelWindowY + (AnalogGraphWindowHeight/4)*3;  // A7 at 3/4
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
        currentA5Value = map(A5[A5.length-1], AccelWindowY, AccelWindowY+AnalogGraphWindowHeight, yMaxMin, -yMaxMin);
        currentA6Value = map(A6[A6.length-1], AccelWindowY, AccelWindowY+AnalogGraphWindowHeight, yMaxMin, -yMaxMin);
        currentA7Value = map(A7[A7.length-1], AccelWindowY, AccelWindowY+AnalogGraphWindowHeight, yMaxMin, -yMaxMin);
        shiftWave();
      } else if (eegDataSource == DATASOURCE_CYTON) {
        currentA5Value = hub.validAccelValues[0];
        currentA6Value = hub.validAccelValues[1];
        currentA7Value = hub.validAccelValues[2];
        A5[A5.length-1] =
          int(map(currentA5Value, -yMaxMin, yMaxMin, float(AccelWindowY+AnalogGraphWindowHeight), float(AccelWindowY)));
        A5[A5.length-1] = constrain(A5[A5.length-1], AccelWindowY, AccelWindowY+AnalogGraphWindowHeight);
        A6[A6.length-1] =
          int(map(currentA6Value, -yMaxMin, yMaxMin, float(AccelWindowY+AnalogGraphWindowHeight), float(AccelWindowY)));
        A6[A6.length-1] = constrain(A6[A6.length-1], AccelWindowY, AccelWindowY+AnalogGraphWindowHeight);
        A7[A7.length-1] =
          int(map(currentA7Value, -yMaxMin, yMaxMin, float(AccelWindowY+AnalogGraphWindowHeight), float(AccelWindowY)));
        A7[A7.length-1] = constrain(A7[A7.length-1], AccelWindowY, AccelWindowY+AnalogGraphWindowHeight);

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
      rect(AccelWindowX, AccelWindowY, AnalogGraphWindowWidth, AnalogGraphWindowHeight);
      line(AccelWindowX, AccelWindowY + AnalogGraphWindowHeight/2, AccelWindowX+AnalogGraphWindowWidth, AccelWindowY + AnalogGraphWindowHeight/2); //midline

      fill(50);
      textFont(p5, 12);
      textAlign(CENTER,CENTER);
      text("4096", AccelWindowX+AnalogGraphWindowWidth + 12, AccelWindowY);
      text("0", AccelWindowX+AnalogGraphWindowWidth + 12, AccelWindowY + AnalogGraphWindowHeight);


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
        // draw3DGraph();
        drawAccWave();
        if (cyton.getBoardMode() != BOARD_MODE_ANALOG) {
          analogModeButton.setString("Turn Analog Read Off");
        } else {
          analogModeButton.setString("Turn Analog Read On");
        }
      } else {  // PLAYBACK
        drawAccValues();
        // draw3DGraph();
        drawAccWave2();
      }
    }

    popStyle();
  }

  void setGraphDimensions(){
    AnalogGraphWindowWidth = w - padding*2;
    if (cyton.isWifi()) {
      AnalogGraphWindowHeight = int((float(h) - float(padding*3))/3.0);
    } else {
      AnalogGraphWindowHeight = int((float(h) - float(padding*3))/4.0);
    }
    AccelWindowX = x + padding;
    AccelWindowY = y + h - AnalogGraphWindowHeight - padding;
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
      A5[i] = AccelWindowY + AnalogGraphWindowHeight/4; // A5 at 1/4
      A6[i] = AccelWindowY + AnalogGraphWindowHeight/2;  // A6 at 1/2
      A7[i] = AccelWindowY + (AnalogGraphWindowHeight/4)*3;  // A7 at 3/4
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
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
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
      // int xi = int(map(i, 0, A5.length-1, 0, AnalogGraphWindowWidth-1));
      // vertex(AccelWindowX+xi, A5[i]);                    //draw a line connecting the data points
      int xi = int(map(i, 0, A5.length-1, 0, AnalogGraphWindowWidth-1));
      // int yi = int(map(A5[i], yMaxMin, -yMaxMin, 0.0, AnalogGraphWindowHeight-1));
      // int yi = 2;
      vertex(AccelWindowX+xi, A5[i]);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < A6.length; i++) {
      int xi = int(map(i, 0, A5.length-1, 0, AnalogGraphWindowWidth-1));
      vertex(AccelWindowX+xi, A6[i]);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < A7.length; i++) {
      int xi = int(map(i, 0, A5.length-1, 0, AnalogGraphWindowWidth-1));
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
      int x = int(map(accelerometerBuff[0][i], -yMaxMin, yMaxMin, float(AccelWindowY+AnalogGraphWindowHeight), float(AccelWindowY)));  // ss
      x = constrain(x, AccelWindowY, AccelWindowY+AnalogGraphWindowHeight);
      vertex(AccelWindowX+i, x);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int y = int(map(accelerometerBuff[1][i], -yMaxMin, yMaxMin, float(AccelWindowY+AnalogGraphWindowHeight), float(AccelWindowY)));  // ss
      y = constrain(y, AccelWindowY, AccelWindowY+AnalogGraphWindowHeight);
      vertex(AccelWindowX+i, y);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int z = int(map(accelerometerBuff[2][i], -yMaxMin, yMaxMin, float(AccelWindowY+AnalogGraphWindowHeight), float(AccelWindowY)));  // ss
      z = constrain(z, AccelWindowY, AccelWindowY+AnalogGraphWindowHeight);
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
      if (A5[A5.length-1] >= AccelWindowY+AnalogGraphWindowHeight) {
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
      if (A6[A6.length-1] >= AccelWindowY+AnalogGraphWindowHeight) {
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
      if (A7[A7.length-1] >= AccelWindowY+AnalogGraphWindowHeight) {
        Zrising = true;
      }
    }
  }

};

//========================================================================================================================
//                      CHANNEL BAR CLASS -- Implemented by Time Series Widget Class
//========================================================================================================================
//this class contains the plot and buttons for a single channel of the Time Series widget
//one of these will be created for each channel (4, 8, or 16)
class ChannelBar{

  int channelNumber; //duh
  String channelString;
  int x, y, w, h;
  boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware

  GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
  GPointsArray channelPoints;
  int nPoints;
  int numSeconds;
  float timeBetweenPoints;

  color channelColor; //color of plot trace

  boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
  int autoScaleYLim = 0;

  TextBox analogValue;

  boolean drawAnalogValue;

  ChannelBar(PApplet _parent, int _channelNumber, int _x, int _y, int _w, int _h){ // channel number, x/y location, height, width

    channelNumber = _channelNumber;
    channelString = str(channelNumber);
    isOn = true;

    x = _x;
    y = _y;
    w = _w;
    h = _h;

    numSeconds = 5;
    plot = new GPlot(_parent);
    plot.setPos(x + 36 + 4 + impButton_diameter, y);
    plot.setDim(w - 36 - 4 - impButton_diameter, h);
    plot.setMar(0f, 0f, 0f, 0f);
    plot.setLineColor((int)channelColors[(channelNumber-1)%8]);
    plot.setXLim(-5,0);
    plot.setYLim(-200,200);
    plot.setPointSize(2);
    plot.setPointColor(0);
    if(channelNumber == nchan){
      plot.getXAxis().setAxisLabelText("Time (s)");
    }
    // plot.setBgColor(color(31,69,110));

    nPoints = nPointsBasedOnDataSource();

    channelPoints = new GPointsArray(nPoints);
    timeBetweenPoints = (float)numSeconds / (float)nPoints;

    for (int i = 0; i < nPoints; i++) {
      float time = -(float)numSeconds + (float)i*timeBetweenPoints;
      // float time = (-float(numSeconds))*(float(i)/float(nPoints));
      // float filt_uV_value = dataBuffY_filtY_uV[channelNumber-1][dataBuffY_filtY_uV.length-nPoints];
      float filt_uV_value = 0.0; //0.0 for all points to start
      GPoint tempPoint = new GPoint(time, filt_uV_value);
      channelPoints.set(i, tempPoint);
    }

    plot.setPoints(channelPoints); //set the plot with 0.0 for all channelPoints to start

    analogValue = new TextBox("", x + 36 + 4 + impButton_diameter + (w - 36 - 4 - impButton_diameter) - 2, y + h);
    analogValue.textColor = color(bgColor);
    analogValue.alignH = RIGHT;
    // analogValue.alignV = TOP;
    analogValue.drawBackground = true;
    analogValue.backgroundColor = color(255,255,255,125);

    drawAnalogValue = true;

  }

  void update(){

    //update the voltage value text string
    String fmt; float val;

    //update the voltage values
    val = dataProcessing.data_std_uV[channelNumber-1];
    analogValue.string = String.format(getFmt(val),val) + " V";

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
      numSamplesToProcess += dataPacketBuff.length; //<>//
    }
    // Shift internal ring buffer numSamplesToProcess
    if (numSamplesToProcess > 0) {
      for(int i=0; i < PulseWaveY.length - numSamplesToProcess; i++){
        PulseWaveY[i] = PulseWaveY[i+numSamplesToProcess]; //<>//
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

      int signal = dataPacketBuff[lastProcessedDataPacketInd].auxValues[0];

      processSignal(signal);
      PulseWaveY[PulseWaveY.length - numSamplesToProcess + samplesProcessed] = signal; //<>//

      samplesProcessed++;
    }
    if(dataBuffY_filtY_uV[channelNumber-1].length > nPoints){
      for (int i = dataBuffY_filtY_uV[channelNumber-1].length - nPoints; i < dataBuffY_filtY_uV[channelNumber-1].length; i++) {
        float time = -(float)numSeconds + (float)(i-(dataBuffY_filtY_uV[channelNumber-1].length-nPoints))*timeBetweenPoints;
        float filt_uV_value = dataBuffY_filtY_uV[channelNumber-1][i];
        // float filt_uV_value = 0.0;
        GPoint tempPoint = new GPoint(time, filt_uV_value);
        channelPoints.set(i-(dataBuffY_filtY_uV[channelNumber-1].length-nPoints), tempPoint);
      }
      plot.setPoints(channelPoints); //reset the plot with updated channelPoints
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
    if(channelNumber == nchan){ //only draw the x axis label on the bottom channel bar
      plot.drawXAxis();
      plot.getXAxis().draw();
    }
    plot.endDraw();

    if(drawAnalogValue){
      analogValue.draw();
    }

    popStyle();
  }

  void setDrawImp(boolean _trueFalse){
    drawImpValue = _trueFalse;
  }

  int nPointsBasedOnDataSource(){
    return numSeconds * (int)getSampleRateSafe();
  }

  void adjustTimeAxis(int _newTimeSize){
    numSeconds = _newTimeSize;
    plot.setXLim(-_newTimeSize,0);

    nPoints = nPointsBasedOnDataSource();

    channelPoints = new GPointsArray(nPoints);
    if(_newTimeSize > 1){
      plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
    }else{
      plot.getXAxis().setNTicks(10);
    }
    if(w_timeSeries.isUpdating()){
      updatePlotPoints();
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
      if(int(abs(channelPoints.getY(i))) > autoScaleYLim){
        autoScaleYLim = int(abs(channelPoints.getY(i)));
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

  }
};
