////////////////////////////////////////////////////
//
// This class creates a Time Series Plot separate from the old Gui_Manager
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
    float pb_x, pb_y, pb_h, pb_w; //values for playback sub-widget
    float plotBottomWell;
    float playbackWidgetHeight;
    int channelBarHeight;

    Button hardwareSettingsButton;

    ChannelBar[] channelBars;
    PlaybackScrollbar scrollbar;
    TimeDisplay timeDisplay;

    int[] xLimOptions = {1, 3, 5, 10, 20}; // number of seconds (x axis of graph)
    int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV

    int xLim = xLimOptions[1];  //start at 5s
    int xMax = xLimOptions[0];  //start w/ autoscale

    boolean allowSpillover = false;

    private ADS1299SettingsController adsSettingsController;

    TextBox[] impValuesMontage;

    private boolean visible = true;
    private boolean updating = true;

    private boolean hasScrollbar = true; //used to turn playback scrollbar widget on/off

    W_timeSeries(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

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
        numChannelBars = nchan; //set number of channel bars = to current nchan of system (4, 8, or 16)

        //Time Series settings
        settings.tsVertScaleSave = 3;
        settings.tsHorizScaleSave = 2;

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function

        addDropdown("VertScale_TS", "Vert Scale", Arrays.asList(settings.tsVertScaleArray), settings.tsVertScaleSave);
        addDropdown("Duration", "Window", Arrays.asList(settings.tsHorizScaleArray), settings.tsHorizScaleSave);
        // addDropdown("Spillover", "Spillover", Arrays.asList("False", "True"), 0);

        //Instantiate scrollbar if using playback mode and scrollbar feature in use
        if(eegDataSource == DATASOURCE_PLAYBACKFILE && hasScrollbar) {
            playbackWidgetHeight = 50.0;
            pb_x = ts_x - ts_padding/2;
            pb_y = ts_y + ts_h + playbackWidgetHeight + (ts_padding * 3);
            pb_w = ts_w - ts_padding*4;
            pb_h = playbackWidgetHeight/2;
            //Make a new scrollbar
            scrollbar = new PlaybackScrollbar(int(pb_x), int(pb_y), int(pb_w), int(pb_h));
        } else {
            int td_h = 18;
            timeDisplay = new TimeDisplay(int(ts_x), int(ts_y + hF - td_h), int(ts_w), td_h);
            playbackWidgetHeight = 0.0;
        }

        channelBarHeight = int(ts_h/numChannelBars);

        channelBars = new ChannelBar[numChannelBars];

        //create our channel bars and populate our channelBars array!
        for(int i = 0; i < numChannelBars; i++) {
            int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
            ChannelBar tempBar = new ChannelBar(_parent, i, int(ts_x), channelBarY, int(ts_w), channelBarHeight); //int _channelIndex, int _x, int _y, int _w, int _h
            channelBars[i] = tempBar;
        }

        if(currentBoard instanceof ADS1299SettingsBoard) {
            hardwareSettingsButton = new Button((int)(x + 3), (int)(y + navHeight + 3), 120, navHeight - 6, "Hardware Settings", 12);
            hardwareSettingsButton.setCornerRoundess((int)(navHeight-6));
            hardwareSettingsButton.setFont(p5,12);
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

        if (currentBoard instanceof ADS1299SettingsBoard) {
            adsSettingsController = new ADS1299SettingsController((int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], h_hsc - 4, channelBarHeight);
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

    void update() {
        if(visible && updating) {
            super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

            if(currentBoard instanceof ADS1299SettingsBoard) {
                adsSettingsController.update(); //update channel controller
                //ignore top left button interaction when widgetSelector dropdown is active
                ignoreButtonCheck(hardwareSettingsButton);
            }

            if(eegDataSource == DATASOURCE_PLAYBACKFILE && hasScrollbar) {
                //scrub playback file
                scrollbar.update();
            } else {
                timeDisplay.update();
            }

            //update channel bars ... this means feeding new EEG data into plots
            for(int i = 0; i < numChannelBars; i++) {
                channelBars[i].update();
            }
        }
    }

    void draw() {
        if(visible) {
            super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

            //remember to refer to x,y,w,h which are the positioning variables of the Widget class
            pushStyle();
            //draw channel bars
            for(int i = 0; i < numChannelBars; i++) {
                channelBars[i].draw();
            }

            //Display playback scrollbar or timeDisplay, depending on data source
            if (eegDataSource == DATASOURCE_PLAYBACKFILE && hasScrollbar) { //you will only ever see the playback widget in Playback Mode ... otherwise not visible
                fill(0,0,0,20);
                stroke(31,69,110);
                rect(xF, ts_y + ts_h + playbackWidgetHeight + 5, wF, playbackWidgetHeight);
                scrollbar.draw();
            } else {
                timeDisplay.draw();
            }

            if(currentBoard instanceof ADS1299SettingsBoard) {
                hardwareSettingsButton.draw();
                adsSettingsController.draw();
            }

            popStyle();
        }
    }

    void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        ts_x = xF + ts_padding;
        ts_y = yF + (ts_padding);
        ts_w = wF - ts_padding*2;
        ts_h = hF - playbackWidgetHeight - plotBottomWell - (ts_padding*2);
        channelBarHeight = int(ts_h/numChannelBars);

        for(int i = 0; i < numChannelBars; i++) {
            int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
            channelBars[i].screenResized(int(ts_x), channelBarY, int(ts_w), channelBarHeight); //bar x, bar y, bar w, bar h
        }


        if (currentBoard instanceof ADS1299SettingsBoard) {
            hardwareSettingsButton.setPos((int)(x0 + 3), (int)(y0 + navHeight + 3));
            adsSettingsController.screenResized((int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], (int)ts_h - 4, channelBarHeight);
        }
        
        ////Resize the playback slider if using playback mode, or resize timeDisplay div at the bottom of timeSeries
        if (eegDataSource == DATASOURCE_PLAYBACKFILE && hasScrollbar) {
            pb_x = ts_x - ts_padding/2;
            pb_y = ts_y + ts_h + playbackWidgetHeight + (ts_padding*3);
            pb_w = ts_w - ts_padding*4;
            pb_h = playbackWidgetHeight/2;
            scrollbar.screenResized(pb_x, pb_y, pb_w, pb_h);
        } else {
            int td_h = 18;
            timeDisplay.screenResized(int(ts_x), int(ts_y + hF - td_h), int(ts_w), td_h);
        }
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        if (!this.dropdownIsActive) {
            if(currentBoard instanceof ADS1299SettingsBoard) {
                if (hardwareSettingsButton.isMouseHere()) {
                    hardwareSettingsButton.setIsActive(true);
                }
            }
        }

        if(adsSettingsController != null && adsSettingsController.isVisible) {
            if (!this.dropdownIsActive) {
                adsSettingsController.mousePressed();
            }
        } else {
            for(int i = 0; i < channelBars.length; i++) {
                channelBars[i].mousePressed();
            }
        }

    }
    
    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        // TODO[brainflow] get rid of this insane if-statement logic
        if(currentBoard instanceof ADS1299SettingsBoard) {
            if(hardwareSettingsButton.isActive && hardwareSettingsButton.isMouseHere()) {
                println("HardwareSetingsButton: Toggle...");
                setAdsSettingsVisible(!adsSettingsController.isVisible);
            }
            hardwareSettingsButton.setIsActive(false);
        }

        if(adsSettingsController != null && adsSettingsController.isVisible) {
            adsSettingsController.mouseReleased();
        } else {
            for(int i = 0; i < channelBars.length; i++) {
                channelBars[i].mouseReleased();
            }
        }
    }

    private void setAdsSettingsVisible(boolean visible) {
        if(visible) {
            if (isRunning) {
                PopupMessage msg = new PopupMessage("Info", "Streaming needs to be stopped before accessing hardware settings");
                return;
            }

            hardwareSettingsButton.setString("Time Series");
        }
        else {
            hardwareSettingsButton.setString("Hardware Settings");
        }

        if (adsSettingsController != null) {
            adsSettingsController.isVisible = visible;
        }
    }

    public void closeADSSettings() {
        setAdsSettingsVisible(false);
    }
};

//These functions are activated when an item from the corresponding dropdown is selected
void VertScale_TS(int n) {
    settings.tsVertScaleSave = n;
    for(int i = 0; i < w_timeSeries.numChannelBars; i++) {
        w_timeSeries.channelBars[i].adjustVertScale(w_timeSeries.yLimOptions[n]);
    }
    closeAllDropdowns();
}

//triggered when there is an event in the Duration Dropdown
void Duration(int n) {
    settings.tsHorizScaleSave = n;
    // println("adjust duration to: " + xLimOptions[n]);
    //set time series x axis to the duration selected from dropdown
    int newDuration = w_timeSeries.xLimOptions[n];
    for(int i = 0; i < w_timeSeries.numChannelBars; i++) {
        w_timeSeries.channelBars[i].adjustTimeAxis(newDuration);
    }
    //If selected by user, sync the duration of Time Series, Accelerometer, and Analog Read(Cyton Only)
    if (settings.accHorizScaleSave == 0) {
        //set accelerometer x axis to the duration selected from dropdown
        w_accelerometer.accelerometerBar.adjustTimeAxis(newDuration);
    }
    if (currentBoard instanceof AnalogCapableBoard) {
        if (settings.arHorizScaleSave == 0) {
            //set analog read x axis to the duration selected from dropdown
            for(int i = 0; i < w_analogRead.numAnalogReadBars; i++) {
                w_analogRead.analogReadBars[i].adjustTimeAxis(newDuration);
            }
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

    int channelIndex; //duh
    String channelString;
    int x, y, w, h;
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

    ChannelBar(PApplet _parent, int _channelIndex, int _x, int _y, int _w, int _h) { // channel number, x/y location, height, width

        channelIndex = _channelIndex;
        channelString = str(channelIndex + 1);

        x = _x;
        y = _y;
        w = _w;
        h = _h;

        if(h > 26) {
            onOff_diameter = 26;
        } else{
            onOff_diameter = h - 2;
        }

        onOffButton = new Button (x + 6, y + int(h/2) - int(onOff_diameter/2), onOff_diameter, onOff_diameter, channelString, fontInfo.buttonLabel_size);
        onOffButton.setHelpText("Click to toggle channel " + channelString + ".");
        onOffButton.setFont(h2, 16);
        onOffButton.setCircleButton(true);
        onOffButton.setColorNotPressed(channelColors[channelIndex%8]); //Set channel button background colors
        onOffButton.textColorNotActive = color(255); //Set channel button text to white
        onOffButton.hasStroke(false);

        if(currentBoard instanceof ImpedanceSettingsBoard) {
            impButton_diameter = 22;
            impCheckButton = new Button (x + 36, y + int(h/2) - int(impButton_diameter/2), impButton_diameter, impButton_diameter, "\u2126", fontInfo.buttonLabel_size);
            impCheckButton.setHelpText("Click to toggle impedance check for channel " + channelString + ".");
            impCheckButton.setFont(h3, 16); //override the default font and fontsize
            impCheckButton.setCircleButton(true);
            impCheckButton.setColorNotPressed(color(255)); //White background
            impCheckButton.textColorNotActive = color(0); //Black text
            impCheckButton.textColorActive = color(255); //White text when clicked
            impCheckButton.hasStroke(false);
        } else {
            impButton_diameter = 0;
        }
        numSeconds = 5;
        plot = new GPlot(_parent);
        plot.setPos(x + 36 + 4 + impButton_diameter, y);
        plot.setDim(w - 36 - 4 - impButton_diameter, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[channelIndex%8]);
        plot.setXLim(-5,0);
        plot.setYLim(-200,200);
        plot.setPointSize(2);
        plot.setPointColor(0);
        plot.setAllFontProperties("Arial", 0, 14);
        if(channelIndex == nchan-1) {
            plot.getXAxis().setAxisLabelText("Time (s)");
        }
        // plot.setBgColor(color(31,69,110));

        nPoints = nPointsBasedOnDataSource();

        channelPoints = new GPointsArray(nPoints);
        timeBetweenPoints = (float)numSeconds / (float)nPoints;

        for (int i = 0; i < nPoints; i++) {
            float time = -(float)numSeconds + (float)i*timeBetweenPoints;
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
    }

    void update() {

        //update the voltage value text string
        String fmt; float val;

        //update the voltage values
        val = dataProcessing.data_std_uV[channelIndex];
        voltageValue.string = String.format(getFmt(val),val) + " uVrms";
        if (is_railed != null) {
            if (is_railed[channelIndex].is_railed == true) {
                voltageValue.string = "RAILED";
            } else if (is_railed[channelIndex].is_railed_warn == true) {
                voltageValue.string = "NEAR RAILED - " + String.format(getFmt(val),val) + " uVrms";
            }
        }

        //update the impedance values
        val = data_elec_imp_ohm[channelIndex]/1000;
        impValue.string = String.format(getFmt(val),val) + " kOhm";
        if (is_railed != null) {
            if (is_railed[channelIndex].is_railed == true) {
                impValue.string = "RAILED";
            }
        }

        // update data in plot
        updatePlotPoints();
        if(isAutoscale) {
            autoScale();
        }

        if(currentBoard.isEXGChannelActive(channelIndex)) {
            onOffButton.setColorNotPressed(channelColors[channelIndex%8]); // power down == false, set color to vibrant
        }
        else {
            onOffButton.setColorNotPressed(50); // power down == false, set color to vibrant
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

    void updatePlotPoints() {
        // update data in plot
        if(dataBuffY_filtY_uV[channelIndex].length > nPoints) {
            for (int i = dataBuffY_filtY_uV[channelIndex].length - nPoints; i < dataBuffY_filtY_uV[channelIndex].length; i++) {
                float time = -(float)numSeconds + (float)(i-(dataBuffY_filtY_uV[channelIndex].length-nPoints))*timeBetweenPoints;
                float filt_uV_value = dataBuffY_filtY_uV[channelIndex][i];

                // update channel point in place
                channelPoints.set(i-(dataBuffY_filtY_uV[channelIndex].length-nPoints), time, filt_uV_value, "");
            }
            plot.setPoints(channelPoints); //reset the plot with updated channelPoints
        }
    }

    void draw() {        
        pushStyle();

        //draw channel holder background
        stroke(31,69,110, 50);
        fill(255);
        rect(x,y,w,h);

        //draw onOff Button
        onOffButton.draw();

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
        if(channelIndex == nchan-1) { //only draw the x axis label on the bottom channel bar
            plot.drawXAxis();
            plot.getXAxis().draw();
        }
        plot.endDraw();

        //draw impedance check Button
        if(currentBoard instanceof ImpedanceSettingsBoard) {
            impCheckButton.draw();

            if(((ImpedanceSettingsBoard)currentBoard).isCheckingImpedance(channelIndex)) {
                impValue.draw();
            }
        }
        
        if(drawVoltageValue) {
            voltageValue.draw();
        }

        popStyle();
    }

    int nPointsBasedOnDataSource() {
        return numSeconds * currentBoard.getSampleRate();
    }

    void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        nPoints = nPointsBasedOnDataSource();
        channelPoints = new GPointsArray(nPoints);
        if(_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
        }else{
            plot.getXAxis().setNTicks(10);
        }
        if(w_timeSeries.isUpdating()) {
            updatePlotPoints();
        }
        // println("New X axis = " + _newTimeSize);
    }

    void adjustVertScale(int _vertScaleValue) {
        if(_vertScaleValue == 0) {
            isAutoscale = true;
        } else {
            isAutoscale = false;
            plot.setYLim(-_vertScaleValue, _vertScaleValue);
        }
    }

    void autoScale() {
        autoScaleYLim = 0;
        for(int i = 0; i < nPoints; i++) {
            if(int(abs(channelPoints.getY(i))) > autoScaleYLim) {
                autoScaleYLim = int(abs(channelPoints.getY(i)));
            }
        }
        plot.setYLim(-autoScaleYLim, autoScaleYLim);
    }

    void screenResized(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        if(h > 26) {
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

        if(currentBoard instanceof ImpedanceSettingsBoard) {
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

    void mousePressed() {
        if(onOffButton.isMouseHere()) {
            println("[" + channelString + "] onOff pressed");
            onOffButton.setIsActive(true);
        }

        if(currentBoard instanceof ImpedanceSettingsBoard) {
            if(impCheckButton.isMouseHere()) {
                println("[" + channelString + "] imp pressed");
                impCheckButton.setIsActive(true);
            }
        }

    }

    void mouseReleased() {
        if(onOffButton.isMouseHere()) {
            println("[" + channelString + "] onOff released");
            currentBoard.setEXGChannelActive(channelIndex, !currentBoard.isEXGChannelActive(channelIndex));
        }

        onOffButton.setIsActive(false);

        if(currentBoard instanceof ImpedanceSettingsBoard) {
            if(impCheckButton.isMouseHere() && impCheckButton.isActive()) {
                println("[" + channelString + "] imp released");

                // flip impedance check
                ImpedanceSettingsBoard impBoard = (ImpedanceSettingsBoard)currentBoard;
                impBoard.setCheckingImpedance(channelIndex, !impBoard.isCheckingImpedance(channelIndex));

                if(impBoard.isCheckingImpedance(channelIndex)) {
                    impCheckButton.setColorNotPressed(color(50)); //Dark background
                    impCheckButton.textColorNotActive = color (255); //White text
                } else {
                    impCheckButton.setColorNotPressed(color(255)); //White background
                    impCheckButton.textColorNotActive = color(0); //Black text
                }
            }
            impCheckButton.setIsActive(false);
        }
    }
};

//========================================================================================================================
//                                          END OF -- CHANNEL BAR CLASS
//========================================================================================================================




//========================== PLAYBACKSLIDER ==========================
class PlaybackScrollbar {
    private final float ps_Padding = 50.0; //used to make room for skip to start button
    private int swidth, sheight;    // width and height of bar
    private float xpos, ypos;       // x and y position of bar
    private float spos;    // x position of slider
    private float sposMin, sposMax; // max and min values of slider
    private boolean over;           // is the mouse over the slider?
    private boolean locked;
    private Button skipToStartButton;
    private int skipToStart_diameter;
    private String currentAbsoluteTimeToDisplay = "";
    private String currentTimeInSecondsToDisplay = "";
    private DataSourcePlayback playbackDataSource;
    
    private final DateFormat currentTimeFormatShort = new SimpleDateFormat("mm:ss");
    private final DateFormat currentTimeFormatLong = new SimpleDateFormat("HH:mm:ss");
    private final DateFormat timeStampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    PlaybackScrollbar (float xp, float yp, int sw, int sh) {
        swidth = sw;
        sheight = sh;
        //float widthtoheight = sw - sh;
        //ratio = (float)sw / widthtoheight;
        xpos = xp + ps_Padding; //lots of padding to make room for button
        ypos = yp-sheight/2;
        spos = xpos;
        sposMin = xpos;
        sposMax = xpos + swidth - sheight/2;

        //Let's make a button to return to the start of playback!!
        skipToStart_diameter = 30;
        skipToStartButton = new Button (int(xp) + int(skipToStart_diameter*.5), int(yp) + int(sh/2) - skipToStart_diameter, skipToStart_diameter, skipToStart_diameter, "");
        skipToStartButton.setColorNotPressed(color(235)); //Set channel button background colors
        skipToStartButton.hasStroke(false);
        PImage bgImage = loadImage("skipToStart-30x26.png");
        skipToStartButton.setBackgroundImage(bgImage);

        playbackDataSource = (DataSourcePlayback)currentBoard;
    }

    /////////////// Update loop for PlaybackScrollbar
    void update() {
        checkMouseOver(); // check if mouse is over

        if (mousePressed && over) {
            locked = true;
        }
        if (!mousePressed) {
            locked = false;
        }
        //if the slider is being used, update new position based on user mouseX
        if (locked) {
            spos = constrain(mouseX-sheight/2, sposMin, sposMax);
            scrubToPosition();
        }
        else {
            updateCursor();
        }

        if (mousePressed && skipToStartButton.isMouseHere()) {
            //println("Playback Scrollbar: Skip to start button pressed"); //This does not print!!
            skipToStartButton.setIsActive(true);
            skipToStartButtonAction(); //skip to start
        } else if (!mousePressed && !skipToStartButton.isMouseHere()) {
            skipToStartButton.setIsActive(false); //set button to not active
        }

        // update timestamp
        currentAbsoluteTimeToDisplay = getAbsoluteTimeToDisplay();

        //update elapsed time to display
        currentTimeInSecondsToDisplay = getCurrentTimeToDisplaySeconds();

    } //end update loop for PlaybackScrollbar

    void updateCursor() {
        float currentSample = float(playbackDataSource.getCurrentSample());
        float totalSamples = float(playbackDataSource.getTotalSamples());
        float currentPlaybackPos = currentSample / totalSamples;

        spos =  lerp(sposMin, sposMax, currentPlaybackPos);
    }

    void scrubToPosition() {
        int totalSamples = playbackDataSource.getTotalSamples();
        int newSamplePos = floor(totalSamples * getCursorPercentage());

        playbackDataSource.goToIndex(newSamplePos);
    }

    float getCursorPercentage() {
        return (spos - sposMin) / (sposMax - sposMin);
    }

    String getAbsoluteTimeToDisplay() {
        List<double[]> currentData = currentBoard.getData(1);
        int timeStampChan = currentBoard.getTimestampChannel();
        long timestampMS = (long)(currentData.get(0)[timeStampChan] * 1000.0);
        if(timestampMS == 0) {
            return "";
        }
        
        return timeStampFormat.format(new Date(timestampMS));
    }

    String getCurrentTimeToDisplaySeconds() {
        double totalMillis = playbackDataSource.getTotalTimeSeconds() * 1000.0;
        double currentMillis = playbackDataSource.getCurrentTimeSeconds() * 1000.0;

        String totalTimeStr = formatCurrentTime(totalMillis);
        String currentTimeStr = formatCurrentTime(currentMillis);

        return currentTimeStr + " / " + totalTimeStr;
    }

    String formatCurrentTime(double millis) {
        DateFormat formatter = currentTimeFormatShort;
        if (millis >= 3600000.0) { // bigger than 60 minutes
            formatter = currentTimeFormatLong;
        }

        return formatter.format(new Date((long)millis));
    }

    //checks if mouse is over the playback scrollbar
    private void checkMouseOver() {
        if (mouseX > xpos && mouseX < xpos+swidth &&
            mouseY > ypos && mouseY < ypos+sheight) {
            if(!over) {
                onMouseEnter();
            }
        }
        else {
            if (over) {
                onMouseExit();
            }
        }
    }

    // called when the mouse enters the playback scrollbar
    private void onMouseEnter() {
        over = true;
        cursor(HAND); //changes cursor icon to a hand
    }

    private void onMouseExit() {
        over = false;
        cursor(ARROW);
    }

    void draw() {
        pushStyle();

        //draw button to skip to the beginning of recording
        skipToStartButton.draw();

        //draw the playback slider inside the playback sub-widget
        noStroke();
        fill(204);
        rect(xpos, ypos, swidth, sheight);

        //select color for playback indicator
        if (over || locked) {
            fill(0, 0, 0);
        } else {
            fill(102, 102, 102);
        }
        //draws playback position indicator
        rect(spos, ypos, sheight/2, sheight);

        //draw current timestamp and X of Y Seconds above scrollbar
        int fontSize = 17;
        textFont(p2, fontSize);
        fill(0);
        float tw = textWidth(currentAbsoluteTimeToDisplay);
        text(currentAbsoluteTimeToDisplay, xpos + swidth - tw, ypos - fontSize - 4);
        text(currentTimeInSecondsToDisplay, xpos, ypos - fontSize - 4);

        popStyle();
    }

    void screenResized(float _x, float _y, float _w, float _h) {
        swidth = int(_w);
        sheight = int(_h);
        xpos = _x + ps_Padding; //add lots of padding for use
        ypos = _y - sheight/2;
        sposMin = xpos;
        sposMax = xpos + swidth - sheight/2;
        //update the position of the playback indicator us
        //newspos = updatePos();

        skipToStartButton.setPos(
            int(_x) + int(skipToStart_diameter*.5),
            int(_y) - int(skipToStart_diameter*.5)
            );
    }

    //This function scrubs to the beginning of the playback file
    //Useful to 'reset' the scrollbar before loading a new playback file
    void skipToStartButtonAction() {       
        playbackDataSource.goToIndex(0);
    }
    
};//end PlaybackScrollbar class

//========================== TimeDisplay ==========================
class TimeDisplay {
    int swidth, sheight;    // width and height of bar
    float xpos, ypos;       // x and y position of bar
    String currentAbsoluteTimeToDisplay = "";
    String currentTimeInSecondsToDisplay = "";
    Boolean updatePosition = false;
    LocalTime time;
    long startTime;
    boolean prevIsRunning = false;

    TimeDisplay (float xp, float yp, int sw, int sh) {
        swidth = sw;
        sheight = sh;
        xpos = xp; //lots of padding to make room for button
        ypos = yp;
        currentAbsoluteTimeToDisplay = fetchCurrentTimeString();
    }

    /////////////// Update loop for TimeDisplay when data stream is running
    void update() {
        if (isRunning) {
            //Fetch Local time
            try {
                currentAbsoluteTimeToDisplay = fetchCurrentTimeString();
            } catch (NullPointerException e) {
                println("TimeDisplay: Timestamp error...");
                e.printStackTrace();
            }
            //Reset second counter when data stream starts and stops
            if (prevIsRunning == false) {
                startTime = System.currentTimeMillis();
                prevIsRunning = true;
            }
            //Calculate elapsed time using current millis
            int secondsElapsed = int((System.currentTimeMillis() - startTime) / 1000F);
            currentTimeInSecondsToDisplay = secondsElapsed + " s";
        } else {
            prevIsRunning = false;
        }
    } //end update loop for TimeDisplay

    void draw() {
        pushStyle();
        //draw current timestamp at the bottom of the Widget container
        if (!currentAbsoluteTimeToDisplay.equals(null)) {
            int fontSize = 17;
            textFont(p2, fontSize);
            fill(0);
            float tw = textWidth(currentAbsoluteTimeToDisplay);
            text(currentAbsoluteTimeToDisplay, xpos + swidth - tw, ypos);
            text(currentTimeInSecondsToDisplay, xpos + 10, ypos);
        }
        popStyle();
    }

    void screenResized(float _x, float _y, float _w, float _h) {
        swidth = int(_w);
        sheight = int(_h);
        xpos = _x;
        ypos = _y;
    }

    String fetchCurrentTimeString() {
        time = LocalTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
        return time.format(formatter);
    }
};//end TimeDisplay class

//Used in the above PlaybackScrollbar class
//Also used in OpenBCI_GUI in the app's title bar
int getElapsedTimeInSeconds(int tableRowIndex) {
    int elapsedTime = int(float(tableRowIndex)/currentBoard.getSampleRate());
    return elapsedTime;
}
