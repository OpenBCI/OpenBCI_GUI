///////////////////////////////////////////////////////////////////////////////////////
//
//  Created by Conor Russomanno, 11/3/16
//  To replace gMontage of old Gui_Manager.pde
//    - Updating the Time Series (formally known as EEG Montage) ... Using Grafica as opposed to gwoptics for plotting data
//    - Adding Playback Controller
//    - Simplifying Impedance Checking
//    - Adding some new visualization features (variable duration, autoscale, spillover?, Vert Scale)
//
///////////////////////////////////////////////////////////////////////////////////////

PlaybackScrollbar scrollBar;

//Channel Colors -- Defaulted to matching the OpenBCI electrode ribbon cable
color[] channelColors = {
  color(129, 129, 129),
  color(124, 75, 141),
  color(54, 87, 158),
  color(49, 113, 89),
  color(221, 178, 13),
  color(253, 94, 52),
  color(224, 56, 45),
  color(162, 82, 49)
};

ControlP5 cp5_TimeSeries;

List durationList = Arrays.asList("1 sec", "3 sec", "5 sec", "7 sec");
List vertScaleList_TS = Arrays.asList("Auto", "50 uV", "100 uV", "200 uV", "400 uV", "1000 uV", "10000 uV");
List spillOverList = Arrays.asList("False", "True");

class TimeSeries {

  int numChannelBars;
  float x, y, w, h;
  float ts_padding;
  float ts_x, ts_y, ts_h, ts_w; //values for actual time series chart (rectangle encompassing all channelBars)
  float plotBottomWell;
  float topNavHeight, playbackWidgetHeight;
  int channelBarHeight;
  int parentContainer;
  boolean showHardwareSettings = false;

  Button hardwareSettingsButton;

  PFont f = createFont("Arial Bold", 24); //for "FFT Plot" Widget Title
  PFont f2 = createFont("Arial", 18); //for dropdown name titles (above dropdown widgets)

  ChannelBar[] channelBars;

  int[] xLimOptions = {3, 5, 8}; // number of seconds (x axis of graph)
  int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV

  int xLim = xLimOptions[1];  //start at 5s
  int xMax = xLimOptions[0];  //start w/ autoscale

  boolean allowSpillover = false;

  HardwareSettingsController hsc;
  TextBox[] chanValuesMontage;
  TextBox[] impValuesMontage;
  boolean showMontageValues;

  TimeSeries(PApplet _parent, int _parentContainer){

    cp5_TimeSeries = new ControlP5(_parent);

    numChannelBars = nchan; //set number of channel bars = to current nchan of system (4, 8, or 16)

    parentContainer = _parentContainer;

    x = float(int(container[parentContainer].x)); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
    y = float(int(container[parentContainer].y));
    w = float(int(container[parentContainer].w));
    h = float(int(container[parentContainer].h));

    topNavHeight = navHeight * 2.0; //22*2 = 44
    if(eegDataSource == DATASOURCE_PLAYBACKFILE){ //you will only ever see the playback widget in Playback Mode ... otherwise not visible
      playbackWidgetHeight = 50.0;
    } else{
      playbackWidgetHeight = 0.0;
    }

    plotBottomWell = 45.0; //this appears to be an arbitrary vertical space adds GPlot leaves at bottom, I derived it through trial and error
    ts_padding = 10.0;
    ts_x = x + ts_padding;
    ts_y = y + topNavHeight + (ts_padding);
    ts_w = w - ts_padding*2;
    ts_h = h - topNavHeight - playbackWidgetHeight - plotBottomWell - (ts_padding*2);
    channelBarHeight = int(ts_h/numChannelBars);
    // ts_x = x + ts_padding;
    // ts_y = y + topNavHeight + ts_padding;
    // ts_w = w - ts_padding*2;
    // ts_h = h - topNavHeight - playbackWidgetHeight - ts_padding*2;
    // channelBarHeight = int(ts_h/numChannelBars);

    channelBars = new ChannelBar[numChannelBars];

    //create our channel bars and populate our channelBars array!
    for(int i = 0; i < numChannelBars; i++){
      int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
      ChannelBar tempBar = new ChannelBar(_parent, i+1, int(ts_x), channelBarY, int(ts_w), channelBarHeight); //int _channelNumber, int _x, int _y, int _w, int _h
      channelBars[i] = tempBar;
    }

    hardwareSettingsButton = new Button((int)(x + 3), (int)(y + navHeight + 3), 120, navHeight - 6, "Hardware Settings", 12);
    hardwareSettingsButton.setCornerRoundess((int)(navHeight-6));
    hardwareSettingsButton.setFont(p2,10);
    hardwareSettingsButton.setStrokeColor((int)(color(150)));
    // hardwareSettingsButton.setStrokeColor((int)(color(138, 182, 229, 100)));
    // hardwareSettingsButton.hasStroke(false);
    // hardwareSettingsButton.setColorNotPressed((int)(color(138, 182, 229)));
    hardwareSettingsButton.setHelpText("The buttons in this panel allow you to adjust the hardware settings of the OpenBCI Board.");

    setupDropdownMenus(_parent); //setup our dropdown menus for the Time Series

    int x_hsc = int(ts_x);
    int y_hsc = int(ts_y);
    int w_hsc = int(ts_w); //width of montage controls (on left of montage)
    int h_hsc = int(ts_h); //height of montage controls (on left of montage)
    hsc = new HardwareSettingsController((int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], h_hsc - 4, channelBarHeight);

  }

  void update(){

    //update channel controller
    hsc.update();

    //update the text strings

    //update channel bars ... this means feeding new EEG data into plots
    for(int i = 0; i < numChannelBars; i++){
      channelBars[i].update();
    }

  }

  void draw(){

    pushStyle();
    noStroke();

    fill(255, 255, 255);
    rect(x, y, w, h); //widget background

    //top bar & nav bar
    fill(150, 150, 150);
    rect(x, y, w, navHeight); //top bar
    fill(200, 200, 200);
    rect(x, y+navHeight, w, navHeight); //button bar
    fill(255);
    rect(x+2, y+2, navHeight-4, navHeight-4);
    fill(bgColor, 100);
    //rect(x+3,y+3, (navHeight-7)/2, navHeight-10);
    rect(x+4, y+4, (navHeight-10)/2, (navHeight-10)/2);
    rect(x+4, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10)/2);
    rect(x+((navHeight-10)/2)+5, y+4, (navHeight-10)/2, (navHeight-10)/2);
    rect(x+((navHeight-10)/2)+5, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10 )/2);
    //text("FFT Plot", x+w/2, y+navHeight/2)
    fill(bgColor);
    textAlign(LEFT, CENTER);
    textFont(f);
    textSize(18);
    text("Time Series (uV/s)", x+navHeight+2, y+navHeight/2 - 2); //left
    //text("EEG Data (" + dataProcessing.getFilterDescription() + ")", x+navHeight+2, y+navHeight/2 - 3); //left

    //draw channel bars
    for(int i = 0; i < numChannelBars; i++){
      channelBars[i].draw();
    }

    //draw dropdown titles
    int dropdownPos = 2; //used to loop through drop down titles ... should use for loop with titles in String array, but... laziness has ensued. -Conor
    int dropdownWidth = 60;
    textFont(f2);
    textSize(12);
    textAlign(CENTER, BOTTOM);
    fill(bgColor);
    text("Duration", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    dropdownPos = 1;
    text("Vert Scale", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    dropdownPos = 0;
    text("Spillover", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));

    //draw dropdown menus
    cp5_TimeSeries.draw();

    popStyle();

    hardwareSettingsButton.draw();

    //temporary placeholder for playback controller widget
    if(eegDataSource == DATASOURCE_PLAYBACKFILE){ //you will only ever see the playback widget in Playback Mode ... otherwise not visible
      pushStyle();
      fill(0,0,0,20);
      stroke(31,69,110);
      rect(x, ts_y + ts_h + playbackWidgetHeight + 5, w, playbackWidgetHeight);
    } else{
      //dont draw anything at the bottom
    }

    //draw channel controller
    hsc.draw();
  }

  void screenResized(PApplet _parent, int _winX, int _winY) {
    //when screen is resized...
    //update position/size of FFT widget
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    ts_x = x + ts_padding;
    ts_y = y + topNavHeight + (ts_padding);
    ts_w = w - ts_padding*2;
    ts_h = h - topNavHeight - playbackWidgetHeight - plotBottomWell - (ts_padding*2);
    channelBarHeight = int(ts_h/numChannelBars);

    for(int i = 0; i < numChannelBars; i++){
      int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
      channelBars[i].screenResized(int(ts_x), channelBarY, int(ts_w), channelBarHeight); //bar x, bar y, bar w, bar h
    }

    hsc.screenResized((int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], (int)ts_h - 4, channelBarHeight);

    //update dropdown menu positions
    cp5_TimeSeries.setGraphics(_parent, 0, 0); //remaps the cp5 controller to the new PApplet window size
    int dropdownPos;
    int dropdownWidth = 60;
    dropdownPos = 2; //work down from 4 since we're starting on the right side now...
    cp5_TimeSeries.getController("Duration")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 1;
    cp5_TimeSeries.getController("VertScale_TS")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 0;
    cp5_TimeSeries.getController("Spillover")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;


  }

  void mousePressed(){
    if (hardwareSettingsButton.isMouseHere()) {
      hardwareSettingsButton.setIsActive(true);
    }
  }

  void mouseReleased(){
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

  void setupDropdownMenus(PApplet _parent) {
    //ControlP5 Stuff
    int dropdownPos;
    int dropdownWidth = 60;
    cp5_colors = new CColor();
    cp5_colors.setActive(color(150, 170, 200)); //when clicked
    cp5_colors.setForeground(color(125)); //when hovering
    cp5_colors.setBackground(color(255)); //color of buttons
    cp5_colors.setCaptionLabel(color(1, 18, 41)); //color of text
    cp5_colors.setValueLabel(color(0, 0, 255));

    cp5_TimeSeries.setColor(cp5_colors);
    cp5_TimeSeries.setAutoDraw(false);


    //-------------------------------------------------------------
    // MAX XAXIS DURATION ... 5 sec by default ... DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 2; //work down from 4 since we're starting on the right side now...
    cp5_TimeSeries.addScrollableList("Duration")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(durationList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_TimeSeries.getController("Duration")
      .getCaptionLabel()
      .setText("5 sec")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;

    //-------------------------------------------------------------
    // VERTICAL SCALE - uV (ie Y Axis) DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 1;
    cp5_TimeSeries.addScrollableList("VertScale_TS")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(vertScaleList_TS)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_TimeSeries.getController("VertScale_TS")
      .getCaptionLabel()
      .setText("Auto")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
    // Allow Channel Bars to spill into other Channel Bars? DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 0;
    cp5_TimeSeries.addScrollableList("Spillover")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(spillOverList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_TimeSeries.getController("Spillover")
      .getCaptionLabel()
      .setText("False")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;

  }

};

//triggered when there is an event in the LogLin Dropdown
void VertScale_TS(int n) {
  if (n==0) { //autoscale
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustVertScale(0);
    }
  } else if(n==1) { //50uV
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustVertScale(50);
    }
  } else if(n==2) { //100uV
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustVertScale(100);
    }
  } else if(n==3) { //200uV
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustVertScale(200);
    }
  } else if(n==4) { //400uV
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustVertScale(400);
    }
  } else if(n==5) { //1000uV
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustVertScale(1000);
    }
  } else if(n==6) { //10000uV
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustVertScale(10000);
    }
  }
}

//triggered when there is an event in the LogLin Dropdown
void Duration(int n) {
  // println("adjust duration to: ");
  if(n==0){ //set time series x axis to 2 secconds
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustTimeAxis(1);
    }
  } else if(n==1){ //set time series x axis to 2 secconds
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustTimeAxis(3);
    }
  } else if(n==2){ //set to 5 seconds
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustTimeAxis(5);
    }
  } else if(n==3){ //set to 8 seconds (max due to arry size ... 2000 total packets saved)
    for(int i = 0; i < timeSeries_widget.numChannelBars; i++){
      timeSeries_widget.channelBars[i].adjustTimeAxis(7);
    }
  }

}

//triggered when there is an event in the LogLin Dropdown
void Spillover(int n) {
  if (n==0) {
    timeSeries_widget.allowSpillover = false;
  } else {
    timeSeries_widget.allowSpillover = true;
  }
}

//========================================================================================================================
//                      CHANNEL BAR CLASS
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

  boolean isAutoscale = true; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
  int autoScaleYLim = 0;

  ChannelBar(PApplet _parent, int _channelNumber, int _x, int _y, int _w, int _h){ // channel number, x/y location, height, width

    channelNumber = _channelNumber;
    channelString = str(channelNumber);
    isOn = true;

    x = _x;
    y = _y;
    w = _w;
    h = _h;

    onOff_diameter = 26;
    onOffButton = new Button (x + 6, y + int(h/2) - int(onOff_diameter/2), onOff_diameter, onOff_diameter, channelString, fontInfo.buttonLabel_size);
    onOffButton.setFont(h2, 16);
    onOffButton.setCircleButton(true);
    onOffButton.setColorNotPressed(channelColors[(channelNumber-1)%8]);
    onOffButton.hasStroke(false);

    impButton_diameter = 22;
    impCheckButton = new Button (x + 36, y + int(h/2) - int(impButton_diameter/2), impButton_diameter, impButton_diameter, "\u2126", fontInfo.buttonLabel_size);
    impCheckButton.setFont(h2, 16);
    impCheckButton.setCircleButton(true);
    impCheckButton.setColorNotPressed(color(255));
    impCheckButton.hasStroke(false);

    numSeconds = 5;
    plot = new GPlot(_parent);
    plot.setPos(x + 36 + 4 + impButton_diameter, y);
    plot.setDim(w - 36 - 4 - impButton_diameter, h);
    plot.setMar(0f, 0f, 0f, 0f);
    plot.setLineColor((int)channelColors[(channelNumber-1)%8]);
    plot.setXLim(-5,0);
    plot.setYLim(-30,30);
    plot.setPointSize(2);
    plot.setPointColor(0);

    if(channelNumber == nchan){
      plot.getXAxis().setAxisLabelText("Time (s)");
    }
    // plot.setBgColor(color(31,69,110));


    nPoints = numSeconds * (int)openBCI.fs_Hz;
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
  }

  void update(){
    // update data in plot
    updatePlotPoints();
    if(isAutoscale){
      autoScale();
    }
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
    impCheckButton.draw();

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

    popStyle();
  }

  void adjustTimeAxis(int _newTimeSize){
    numSeconds = _newTimeSize;
    plot.setXLim(-_newTimeSize,0);
    nPoints = numSeconds * (int)openBCI.fs_Hz;
    channelPoints = new GPointsArray(nPoints);
    if(_newTimeSize > 1){
      plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
    }else{
      plot.getXAxis().setNTicks(10);
    }
    updatePlotPoints();
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
    onOffButton.but_x = x + 6;
    onOffButton.but_y = y + int(h/2) - int(onOff_diameter/2);
    impCheckButton.but_x = x + 36;
    impCheckButton.but_y = y + int(h/2) - int(impButton_diameter/2);

    //reposition & resize the plot
    plot.setPos(x + 36 + 4 + impButton_diameter, y);
    plot.setDim(w - 36 - 4 - impButton_diameter, h);

  }

  void mouseReleased(){

  }
};
//========================================================================================================================
//                  END OF -- CHANNEL BAR CLASS
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


        data[Ichan][i] = (int) (0.5f+ val_uV / openBCI.get_scale_fac_uVolts_per_count()); //convert to counts, the 0.5 is to ensure roundi
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
