////////////////////////////////////////////////////
//
// This class creates an Time Series Plot separate from the old Gui_Manager
// It extends the Widget class
//
// Conor Russomanno, November 2016
//
// Requires the plotting library from grafica ... replacing the old gwoptics (which is now no longer supported)
//
///////////////////////////////////////////////////


class W_timeSeries extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...

  int numChannelBars;
  float xF, yF, wF, hF;
  float ts_padding;
  float ts_x, ts_y, ts_h, ts_w; //values for actual time series chart (rectangle encompassing all channelBars)
  float plotBottomWell;
  float playbackWidgetHeight;
  int channelBarHeight;
  boolean showHardwareSettings = false;

  Button hardwareSettingsButton;

  ChannelBar[] channelBars;

  int[] xLimOptions = {1, 3, 5, 7}; // number of seconds (x axis of graph)
  int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV

  int xLim = xLimOptions[1];  //start at 5s
  int xMax = xLimOptions[0];  //start w/ autoscale

  boolean allowSpillover = false;

  HardwareSettingsController hsc;


  TextBox[] chanValuesMontage;
  TextBox[] impValuesMontage;
  boolean showMontageValues;

  private boolean visible = true;
  private boolean updating = true;

  private boolean hasScrollbar = false;

  W_timeSeries(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function

    addDropdown("VertScale_TS", "Vert Scale", Arrays.asList("Auto", "50 uV", "100 uV", "200 uV", "400 uV", "1000 uV", "10000 uV"), tsVertScaleSave);
    addDropdown("Duration", "Window", Arrays.asList("1 sec", "3 sec", "5 sec", "7 sec"), tsHorizScaleSave);
    // addDropdown("Spillover", "Spillover", Arrays.asList("False", "True"), 0);

    numChannelBars = nchan; //set number of channel bars = to current nchan of system (4, 8, or 16)

    xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
    yF = float(y);
    wF = float(w);
    hF = float(h);

    if(eegDataSource == DATASOURCE_PLAYBACKFILE && hasScrollbar){ //you will only ever see the playback widget in Playback Mode ... otherwise not visible
      playbackWidgetHeight = 50.0;
    } else{
      playbackWidgetHeight = 0.0;
    }

    plotBottomWell = 45.0; //this appears to be an arbitrary vertical space adds GPlot leaves at bottom, I derived it through trial and error
    ts_padding = 10.0;
    ts_x = xF + ts_padding;
    ts_y = yF + (ts_padding);
    ts_w = wF - ts_padding*2;
    ts_h = hF - playbackWidgetHeight - plotBottomWell - (ts_padding*2);
    channelBarHeight = int(ts_h/numChannelBars);

    channelBars = new ChannelBar[numChannelBars];

    //create our channel bars and populate our channelBars array!
    for(int i = 0; i < numChannelBars; i++){
      int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
      ChannelBar tempBar = new ChannelBar(_parent, i+1, int(ts_x), channelBarY, int(ts_w), channelBarHeight); //int _channelNumber, int _x, int _y, int _w, int _h
      channelBars[i] = tempBar;
    }

    if(eegDataSource == DATASOURCE_CYTON){
      hardwareSettingsButton = new Button((int)(x + 3), (int)(y + navHeight + 3), 120, navHeight - 6, "Hardware Settings", 12);
      hardwareSettingsButton.setCornerRoundess((int)(navHeight-6));
      hardwareSettingsButton.setFont(p6,10);
      // hardwareSettingsButton.setStrokeColor((int)(color(150)));
      // hardwareSettingsButton.setColorNotPressed(openbciBlue);
      hardwareSettingsButton.setColorNotPressed(color(57,128,204));
      hardwareSettingsButton.textColorNotActive = color(255);
      // hardwareSettingsButton.setStrokeColor((int)(color(138, 182, 229, 100)));
      hardwareSettingsButton.hasStroke(false);
      // hardwareSettingsButton.setColorNotPressed((int)(color(138, 182, 229)));
      hardwareSettingsButton.setHelpText("The buttons in this panel allow you to adjust the hardware settings of the OpenBCI Board.");
    }

    int x_hsc = int(ts_x);
    int y_hsc = int(ts_y);
    int w_hsc = int(ts_w); //width of montage controls (on left of montage)
    int h_hsc = int(ts_h); //height of montage controls (on left of montage)
    hsc = new HardwareSettingsController((int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], h_hsc - 4, channelBarHeight);
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
      hsc.update(); //update channel controller

      //update channel bars ... this means feeding new EEG data into plots
      for(int i = 0; i < numChannelBars; i++){
        channelBars[i].update();
      }
    }
  }

  void draw(){
    if(visible){
      super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

      //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class

      pushStyle();
      //draw channel bars
      for(int i = 0; i < numChannelBars; i++){
        channelBars[i].draw();
      }

      if(eegDataSource == DATASOURCE_CYTON){
        hardwareSettingsButton.draw();
      }

      //temporary placeholder for playback controller widget
      if(eegDataSource == DATASOURCE_PLAYBACKFILE && hasScrollbar){ //you will only ever see the playback widget in Playback Mode ... otherwise not visible
        pushStyle();
        fill(0,0,0,20);
        stroke(31,69,110);
        rect(xF, ts_y + ts_h + playbackWidgetHeight + 5, wF, playbackWidgetHeight);
        popStyle();
      } else{
        //dont draw anything at the bottom
      }

      //draw channel controller
      hsc.draw();

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
    channelBarHeight = int(ts_h/numChannelBars);

    for(int i = 0; i < numChannelBars; i++){
      int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
      channelBars[i].screenResized(int(ts_x), channelBarY, int(ts_w), channelBarHeight); //bar x, bar y, bar w, bar h
    }

    hsc.screenResized((int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], (int)ts_h - 4, channelBarHeight);

    if(eegDataSource == DATASOURCE_CYTON){
      hardwareSettingsButton.setPos((int)(x0 + 3), (int)(y0 + navHeight + 3));
    }
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)


    if(eegDataSource == DATASOURCE_CYTON){
      //put your code here...
      if (hardwareSettingsButton.isMouseHere()) {
        hardwareSettingsButton.setIsActive(true);
      }
    }

    if(hsc.isVisible){
      hsc.mousePressed();
    } else {
      for(int i = 0; i < channelBars.length; i++){
        channelBars[i].mousePressed();
      }
    }


  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    if(eegDataSource == DATASOURCE_CYTON){
      //put your code here...
      if(hardwareSettingsButton.isActive && hardwareSettingsButton.isMouseHere()){
        println("toggle...");
        if(showHardwareSettings){
          showHardwareSettings = false;
          hsc.isVisible = false;
          hardwareSettingsButton.setString("Hardware Settings");
        } else{
          showHardwareSettings = true;
          hsc.isVisible = true;
          hardwareSettingsButton.setString("Time Series");
        }
      }
      hardwareSettingsButton.setIsActive(false);
    }

    if(hsc.isVisible){
      hsc.mouseReleased();
    } else {
      for(int i = 0; i < channelBars.length; i++){
        channelBars[i].mouseReleased();
      }
    }
  }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void VertScale_TS(int n) {
  tsVertScaleSave = n;
  if (n==0) { //autoscale
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustVertScale(0);
    }
  } else if(n==1) { //50uV
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustVertScale(50);
    }
  } else if(n==2) { //100uV
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustVertScale(100);
    }
  } else if(n==3) { //200uV
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustVertScale(200);
    }
  } else if(n==4) { //400uV
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustVertScale(400);
    }
  } else if(n==5) { //1000uV
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustVertScale(1000);
    }
  } else if(n==6) { //10000uV
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustVertScale(10000);
    }
  }
}

//triggered when there is an event in the LogLin Dropdown
void Duration(int n) {
  tsHorizScaleSave = n;
  // println("adjust duration to: ");
  if(n==0){ //set time series x axis to 1 secconds
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustTimeAxis(1);
    }
  } else if(n==1){ //set time series x axis to 3 secconds
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustTimeAxis(3);
    }
  } else if(n==2){ //set to 5 seconds
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustTimeAxis(5);
    }
  } else if(n==3){ //set to 7 seconds (max due to arry size ... 2000 total packets saved)
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
      w_timeSeries.channelBars[i].adjustTimeAxis(7);
    }
  }
  closeAllDropdowns();
}

//triggered when there is an event in the LogLin Dropdown
void Spillover(int n) {
  if (n==0) {
    w_timeSeries.allowSpillover = false;
  } else {
    w_timeSeries.allowSpillover = true;
  }
  closeAllDropdowns();
}













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
  Button onOffButton;
  int onOff_diameter, impButton_diameter;
  Button impCheckButton;

  GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
  GPointsArray channelPoints;
  int nPoints;
  int numSeconds;
  float timeBetweenPoints;

  color channelColor; //color of plot trace

  boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
  int autoScaleYLim = 0;

  TextBox voltageValue;
  TextBox impValue;

  boolean drawVoltageValue;
  boolean drawImpValue;

  ChannelBar(PApplet _parent, int _channelNumber, int _x, int _y, int _w, int _h){ // channel number, x/y location, height, width

    channelNumber = _channelNumber;
    channelString = str(channelNumber);
    isOn = true;

    x = _x;
    y = _y;
    w = _w;
    h = _h;

    if(h > 26){
      onOff_diameter = 26;
    } else{
      onOff_diameter = h - 2;
    }

    onOffButton = new Button (x + 6, y + int(h/2) - int(onOff_diameter/2), onOff_diameter, onOff_diameter, channelString, fontInfo.buttonLabel_size);
    onOffButton.setFont(h2, 16);
    onOffButton.setCircleButton(true);
    onOffButton.setColorNotPressed(channelColors[(channelNumber-1)%8]);
    onOffButton.hasStroke(false);

    if(eegDataSource == DATASOURCE_CYTON){
      impButton_diameter = 22;
      impCheckButton = new Button (x + 36, y + int(h/2) - int(impButton_diameter/2), impButton_diameter, impButton_diameter, "\u2126", fontInfo.buttonLabel_size);
      impCheckButton.setFont(h2, 16);
      impCheckButton.setCircleButton(true);
      impCheckButton.setColorNotPressed(color(255));
      impCheckButton.hasStroke(false);
    } else {
      impButton_diameter = 0;
    }
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

    voltageValue = new TextBox("", x + 36 + 4 + impButton_diameter + (w - 36 - 4 - impButton_diameter) - 2, y + h);
    voltageValue.textColor = color(bgColor);
    voltageValue.alignH = RIGHT;
    // voltageValue.alignV = TOP;
    voltageValue.drawBackground = true;
    voltageValue.backgroundColor = color(255,255,255,125);

    impValue = new TextBox("", x + 36 + 4 + impButton_diameter + 2, y + h);
    impValue.textColor = color(bgColor);
    impValue.alignH = LEFT;
    // impValue.alignV = TOP;
    impValue.drawBackground = true;
    impValue.backgroundColor = color(255,255,255,125);

    drawVoltageValue = true;
    drawImpValue = false;

  }

  void update(){

    //update the voltage value text string
    String fmt; float val;

    //update the voltage values
    val = dataProcessing.data_std_uV[channelNumber-1];
    voltageValue.string = String.format(getFmt(val),val) + " uVrms";
    if (is_railed != null) {
      if (is_railed[channelNumber-1].is_railed == true) {
        voltageValue.string = "RAILED";
      } else if (is_railed[channelNumber-1].is_railed_warn == true) {
        voltageValue.string = "NEAR RAILED - " + String.format(getFmt(val),val) + " uVrms";
      }
    }

    //update the impedance values
    val = data_elec_imp_ohm[channelNumber-1]/1000;
    impValue.string = String.format(getFmt(val),val) + " kOhm";
    if (is_railed != null) {
      if (is_railed[channelNumber-1].is_railed == true) {
        impValue.string = "RAILED";
      }
    }

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

    //draw channel holder background
    stroke(31,69,110, 50);
    fill(255);
    rect(x,y,w,h);

    //draw onOff Button
    onOffButton.draw();
    //draw impedance check Button
    if(eegDataSource == DATASOURCE_CYTON){
      impCheckButton.draw();
    }

    //draw plot
    stroke(31,69,110, 50);
    fill(color(125,30,12,30));

    rect(x + 36 + 4 + impButton_diameter, y, w - 36 - 4 - impButton_diameter, h);

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

    if(drawImpValue){
      impValue.draw();
    }
    if(drawVoltageValue){
      voltageValue.draw();
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

    if(h > 26){
      onOff_diameter = 26;
      onOffButton.but_dx = onOff_diameter;
      onOffButton.but_dy = onOff_diameter;
    } else{
      // println("h = " + h);
      onOff_diameter = h - 2;
      onOffButton.but_dx = onOff_diameter;
      onOffButton.but_dy = onOff_diameter;
    }

    onOffButton.but_x = x + 6;
    onOffButton.but_y = y + int(h/2) - int(onOff_diameter/2);

    if(eegDataSource == DATASOURCE_CYTON){
      impCheckButton.but_x = x + 36;
      impCheckButton.but_y = y + int(h/2) - int(impButton_diameter/2);
    }

    //reposition & resize the plot
    plot.setPos(x + 36 + 4 + impButton_diameter, y);
    plot.setDim(w - 36 - 4 - impButton_diameter, h);

    voltageValue.x = x + 36 + 4 + impButton_diameter + (w - 36 - 4 - impButton_diameter) - 2;
    voltageValue.y = y + h;
    impValue.x = x + 36 + 4 + impButton_diameter + 2;
    impValue.y = y + h;

  }

  void mousePressed(){
    if(onOffButton.isMouseHere()){
      println("[" + channelNumber + "] onOff pressed");
      onOffButton.setIsActive(true);
    }

    if(eegDataSource == DATASOURCE_CYTON){
      if(impCheckButton.isMouseHere()){
        println("[" + channelNumber + "] imp pressed");
        impCheckButton.setIsActive(true);
      }
    }

  }

  void mouseReleased(){
    if(onOffButton.isMouseHere()){
      println("[" + channelNumber + "] onOff released");
      if(isOn){  // if channel is active
        isOn = false; // deactivate it
        deactivateChannel(channelNumber - 1); //got to - 1 to make 0 indexed
        onOffButton.setColorNotPressed(color(50));
      }
      else { // if channel is not active
        isOn = true;
        activateChannel(channelNumber - 1);       // activate it
        onOffButton.setColorNotPressed(channelColors[(channelNumber-1)%8]);
      }
    }

    onOffButton.setIsActive(false);

    if(eegDataSource == DATASOURCE_CYTON){
      if(impCheckButton.isMouseHere() && impCheckButton.isActive()){
        println("[" + channelNumber + "] imp released");
        w_timeSeries.hsc.toggleImpedanceCheck(channelNumber-1);  // 'n' indicates the N inputs and '1' indicates test impedance
        if(drawImpValue){
          drawImpValue = false;
          impCheckButton.setColorNotPressed(color(255));
        } else {
          drawImpValue = true;
          impCheckButton.setColorNotPressed(color(50));
        }
      }
      impCheckButton.setIsActive(false);
    }
  }
};

//========================================================================================================================
//                                          END OF -- CHANNEL BAR CLASS
//========================================================================================================================

//============= PLAYBACKSLIDER =============
class PlaybackScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  int num_indices;

  PlaybackScrollbar (float xp, float yp, int sw, int sh, int is) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight/2;
    num_indices = is;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos);
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      cursor(HAND);
      return true;
    } else {
      cursor(ARROW);
      return false;
    }
  }

  int get_index(){

    float seperate_val = sposMax / num_indices;

    int index;

    for(index = 0; index < num_indices + 1; index++){
      if(getPos() >= seperate_val * index && getPos() <= seperate_val * (index +1) ) return index;
      else if(index == num_indices && getPos() >= seperate_val * index) return num_indices;
    }

    return -1;
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight/2, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
};

//WORK WITH COLIN ON IMPLEMENTING THIS ABOVE
/*
if(has_processed){
  if(scrollbar == null) scrollbar = new PlaybackScrollbar(10,height/20 * 19, width/2 - 10, 16, indices);
  else {
    float val_uV = 0.0f;
    boolean foundIndex =true;
    int startIndex = 0;

    scrollbar.update();
    scrollbar.display();
    //println(index_of_times.get(scrollbar.get_index()));
    SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss.SSS");
    ArrayList<Date> keys_to_plot = new ArrayList();

    try{
      Date timeIndex = format.parse(index_of_times.get(scrollbar.get_index()));
      Date fiveBefore = new Date(timeIndex.getTime());
      fiveBefore.setTime(fiveBefore.getTime() - 5000);
      Date fiveBeforeCopy = new Date(fiveBefore.getTime());

      //START HERE TOMORROW

      int i = 0;
      int timeToBreak = 0;
      while(true){
        //println("in while i:" + i);
        if(index_of_times.get(i).contains(format.format(fiveBeforeCopy).toString())){
          println("found");
          startIndex = i;
          break;
        }
        if(i == index_of_times.size() -1){
          i = 0;
          fiveBeforeCopy.setTime(fiveBefore.getTime() + 1);
          timeToBreak++;
        }
        if(timeToBreak > 3){
          break;
        }
        i++;

      }
      println("after first while");

      while(fiveBefore.before(timeIndex)){
       //println("in while :" + fiveBefore);
        if(index_of_times.get(startIndex).contains(format.format(fiveBefore).toString())){
          keys_to_plot.add(fiveBefore);
          startIndex++;
        }
        //println(fiveBefore);
        fiveBefore.setTime(fiveBefore.getTime() + 1);
      }
      println("keys_to_plot size: " + keys_to_plot.size());
    }
    catch(Exception e){}

    float[][] data = new float[keys_to_plot.size()][nchan];
    int i = 0;

    for(Date elm : keys_to_plot){

      for(int Ichan=0; Ichan < nchan; Ichan++){
        val_uV = processed_file.get(elm)[Ichan][startIndex];


        data[Ichan][i] = (int) (0.5f+ val_uV / cyton.get_scale_fac_uVolts_per_count()); //convert to counts, the 0.5 is to ensure roundi
      }
      i++;
    }

    //println(keys_to_plot.size());
    if(keys_to_plot.size() > 100){
    for(int Ichan=0; Ichan<nchan; Ichan++){
      update(data[Ichan],data_elec_imp_ohm);
    }
    }
    //for(int index = 0; index <= scrollbar.get_index(); index++){
    //  //yLittleBuff_uV = processed_file.get(index_of_times.get(index));

    //}

    cc.update();
    cc.draw();
  }
}
*/
