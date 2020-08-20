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

    private int numChannelBars;
    private float xF, yF, wF, hF;
    private float ts_padding;
    private float ts_x, ts_y, ts_h, ts_w; //values for actual time series chart (rectangle encompassing all channelBars)
    private float pb_x, pb_y, pb_h, pb_w; //values for playback sub-widget
    private float plotBottomWell;
    private float playbackWidgetHeight;
    private int channelBarHeight;

    private Button_obci hardwareSettingsButton;
    private Button_obci hardwareSettingsLoadButton;
    private Button_obci hardwareSettingsStoreButton;

    private ChannelSelect tsChanSelect;
    private ChannelBar[] channelBars;
    private PlaybackScrollbar scrollbar;
    private TimeDisplay timeDisplay;

    private int[] xLimOptions = {1, 3, 5, 10, 20}; // number of seconds (x axis of graph)
    private int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV

    private int xLim = xLimOptions[1];  //start at 5s
    private int xMax = xLimOptions[0];  //start w/ autoscale

    private ADS1299SettingsController adsSettingsController;

    private boolean allowSpillover = false;
    private TextBox[] impValuesMontage;
    private boolean visible = true;
    private boolean hasScrollbar = true; //used to turn playback scrollbar widget on/off

    W_timeSeries(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        tsChanSelect = new ChannelSelect(_parent, x, y, w, navH, "TS_Channels");

        //activate all channels in channelSelect by default
        activateAllChannels();

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
        if((currentBoard instanceof FileBoard) && hasScrollbar) {
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
            hardwareSettingsButton = new Button_obci((int)(x + 80), (int)(y + navHeight + 3), 120, navHeight - 6, "Hardware Settings", 12);
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

            hardwareSettingsLoadButton = new Button_obci(hardwareSettingsButton.but_x + hardwareSettingsButton.but_dx + 4, (int)(y + navHeight + 3), 80, navHeight - 6, "Load Settings", 12);
            hardwareSettingsLoadButton.setCornerRoundess((int)(navHeight-6));
            hardwareSettingsLoadButton.setFont(p5,12);
            hardwareSettingsLoadButton.setColorNotPressed(color(57,128,204));
            hardwareSettingsLoadButton.textColorNotActive = color(255);
            hardwareSettingsLoadButton.hasStroke(false);
            hardwareSettingsLoadButton.setHelpText("Select settings file to load.");
        
            hardwareSettingsStoreButton = new Button_obci(hardwareSettingsLoadButton.but_x + hardwareSettingsLoadButton.but_dx + 4, (int)(y + navHeight + 3), 83, navHeight - 6, "Save Settings", 12);
            hardwareSettingsStoreButton.setCornerRoundess((int)(navHeight-6));
            hardwareSettingsStoreButton.setFont(p5,12);
            hardwareSettingsStoreButton.setColorNotPressed(color(57,128,204));
            hardwareSettingsStoreButton.textColorNotActive = color(255);
            hardwareSettingsStoreButton.hasStroke(false);
            hardwareSettingsStoreButton.setHelpText("Save current settings to file.");
        }

        int x_hsc = int(ts_x);
        int y_hsc = int(ts_y);
        int w_hsc = int(ts_w); //width of montage controls (on left of montage)
        int h_hsc = int(ts_h); //height of montage controls (on left of montage)

        if (currentBoard instanceof ADS1299SettingsBoard) {
            adsSettingsController = new ADS1299SettingsController(tsChanSelect.activeChan, (int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], h_hsc - 4, channelBarHeight);
        }
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean _visible) {
        visible = _visible;
    }

    void update() {
        if(visible) {
            super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

            // offset based on whether channel select is open or not.
            int chanSelectOffset = 0;
            if (tsChanSelect.isVisible()) {
                chanSelectOffset = navHeight;
            }

            //Update channel checkboxes and active channels
            tsChanSelect.update(x, y, w);
            numChannelBars = tsChanSelect.activeChan.size();
            channelBarHeight = int((ts_h - chanSelectOffset)/numChannelBars);

            for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
                int activeChan = tsChanSelect.activeChan.get(i);
                int channelBarY = int(ts_y + chanSelectOffset) + i*(channelBarHeight); //iterate through bar locations
                channelBars[activeChan].resize(int(ts_x), channelBarY, int(ts_w), channelBarHeight); //bar x, bar y, bar w, bar h
            }

            if (currentBoard instanceof ADS1299SettingsBoard) {
                hardwareSettingsButton.setPos((int)(x0 + 80), (int)(y0 + navHeight + 3));
                hardwareSettingsLoadButton.setPos(hardwareSettingsButton.but_x + hardwareSettingsButton.but_dx + 4, (int)(y0 + navHeight + 3));
                hardwareSettingsStoreButton.setPos(hardwareSettingsLoadButton.but_x + hardwareSettingsLoadButton.but_dx + 4, (int)(y0 + navHeight + 3));
                adsSettingsController.resize((int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], (int)ts_h - 4, channelBarHeight);
                adsSettingsController.update(); //update channel controller
                //ignore top left button interaction when widgetSelector dropdown is active
                ignoreButtonCheck(hardwareSettingsButton);
                ignoreButtonCheck(hardwareSettingsLoadButton);
                ignoreButtonCheck(hardwareSettingsStoreButton);
            }

            if((currentBoard instanceof FileBoard) && hasScrollbar) {
                //scrub playback file
                scrollbar.update();
            } else {
                timeDisplay.update();
            }

            //update channel bars ... this means feeding new EEG data into plots
            for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
                int activeChan = tsChanSelect.activeChan.get(i);
                channelBars[activeChan].update();
            }
        }
    }

    void draw() {
        if(visible) {
            super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

            //remember to refer to x,y,w,h which are the positioning variables of the Widget class
            pushStyle();
            //draw channel bars
            for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
                int activeChan = tsChanSelect.activeChan.get(i);
                channelBars[activeChan].draw();
            }

            //Display playback scrollbar or timeDisplay, depending on data source
            if((currentBoard instanceof FileBoard) && hasScrollbar) { //you will only ever see the playback widget in Playback Mode ... otherwise not visible
                fill(0,0,0,20);
                stroke(31,69,110);
                rect(xF, ts_y + ts_h + playbackWidgetHeight + 5, wF, playbackWidgetHeight);
                scrollbar.draw();
            } else {
                timeDisplay.draw();
            }

            if(currentBoard instanceof ADS1299SettingsBoard) {
                hardwareSettingsButton.draw();
                hardwareSettingsLoadButton.draw();
                hardwareSettingsStoreButton.draw();
                adsSettingsController.draw();
            }

            popStyle();
            
            tsChanSelect.draw();
        }
    }

    void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        tsChanSelect.screenResized(pApplet);

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        ts_x = xF + ts_padding;
        ts_y = yF + (ts_padding);
        ts_w = wF - ts_padding*2;
        ts_h = hF - playbackWidgetHeight - plotBottomWell - (ts_padding*2);
        
        ////Resize the playback slider if using playback mode, or resize timeDisplay div at the bottom of timeSeries
        if((currentBoard instanceof FileBoard) && hasScrollbar) {
            pb_x = ts_x - ts_padding/2;
            pb_y = ts_y + ts_h + playbackWidgetHeight + (ts_padding*3);
            pb_w = ts_w - ts_padding*4;
            pb_h = playbackWidgetHeight/2;
            scrollbar.screenResized(pb_x, pb_y, pb_w, pb_h);
        } else {
            int td_h = 18;
            timeDisplay.screenResized(int(ts_x), int(ts_y + hF - td_h), int(ts_w), td_h);
        }

        // offset based on whether channel select is open or not.
        int chanSelectOffset = 0;
        if (tsChanSelect.isVisible()) {
            chanSelectOffset = navHeight;
        }
        for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
            int activeChan = tsChanSelect.activeChan.get(i);
            int channelBarY = int(ts_y + chanSelectOffset) + i*(channelBarHeight); //iterate through bar locations
            channelBars[activeChan].resize(int(ts_x), channelBarY, int(ts_w), channelBarHeight); //bar x, bar y, bar w, bar h
        }

        if (currentBoard instanceof ADS1299SettingsBoard) {
            hardwareSettingsButton.setPos((int)(x0 + 80), (int)(y0 + navHeight + 3));
            adsSettingsController.resize((int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], (int)ts_h - 4, channelBarHeight);
        }
        
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        tsChanSelect.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked

        if (!this.dropdownIsActive) {
            if(currentBoard instanceof ADS1299SettingsBoard) {
                if (hardwareSettingsButton.isMouseHere()) {
                    hardwareSettingsButton.setIsActive(true);
                }
                if (hardwareSettingsLoadButton.isMouseHere()) {
                    hardwareSettingsLoadButton.setIsActive(true);
                }
                if (hardwareSettingsStoreButton.isMouseHere()) {
                    hardwareSettingsStoreButton.setIsActive(true);
                }
            }
        }

        if(adsSettingsController != null && adsSettingsController.isVisible) {
            if (!this.dropdownIsActive) {
                adsSettingsController.mousePressed();
            }
        }

        for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
            int activeChan = tsChanSelect.activeChan.get(i);
            channelBars[activeChan].mousePressed();
        }
    }
    
    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        if(currentBoard instanceof ADS1299SettingsBoard) {
            if(hardwareSettingsButton.isActive && hardwareSettingsButton.isMouseHere()) {
                println("HardwareSetingsButton: Toggle...");
                setAdsSettingsVisible(!adsSettingsController.isVisible);
            }
            if(hardwareSettingsLoadButton.isActive && hardwareSettingsLoadButton.isMouseHere()) {
                if (isRunning) {
                    PopupMessage msg = new PopupMessage("Info", "Streaming needs to be stopped before loading hardware settings.");
                } else {
                    selectInput("Select settings file to load", "loadSettingsFileSelected");
                }
            }
            if(hardwareSettingsStoreButton.isActive && hardwareSettingsStoreButton.isMouseHere()) {
                selectOutput("Save settings to file", "storeSettingsFileSelected");
            }
            hardwareSettingsButton.setIsActive(false);
            hardwareSettingsLoadButton.setIsActive(false);
            hardwareSettingsStoreButton.setIsActive(false);
        }

        if(adsSettingsController != null && adsSettingsController.isVisible) {
            adsSettingsController.mouseReleased();
        } 
        
        for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
            int activeChan = tsChanSelect.activeChan.get(i);
            channelBars[activeChan].mouseReleased();
        }
    }

    private void setAdsSettingsVisible(boolean visible) {
        if(!(currentBoard instanceof ADS1299SettingsBoard)) {
            return;
        }

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

    private void activateAllChannels() {
        tsChanSelect.activeChan.clear();
        //Activate all channel checkboxes by default for this widget
        for (int i = 0; i < nchan; i++) {
            tsChanSelect.checkList.activate(i);
            tsChanSelect.activeChan.add(i);
        }
    }
};

void loadSettingsFileSelected(File selection) {
    if (selection == null) {
        output("Settings file not selected.");
    } else {
        if (currentBoard instanceof ADS1299SettingsBoard) {
            if (((ADS1299SettingsBoard)currentBoard).getADS1299Settings().loadSettingsValues(selection.getAbsolutePath())) {
                output("Settings loaded.");
            } else {
                output("Failed to load settings.");
            }
        }
    }
}

void storeSettingsFileSelected(File selection) {
    if (selection == null) {
        output("Settings file not selected.");
    } else {
        if (currentBoard instanceof ADS1299SettingsBoard) {
            if (((ADS1299SettingsBoard)currentBoard).getADS1299Settings().saveToFile(selection.getAbsolutePath())) {
                output("Settings saved.");
            } else {
                output("Failed to save settings.");
            }
        }
    }
}

//These functions are activated when an item from the corresponding dropdown is selected
void VertScale_TS(int n) {
    settings.tsVertScaleSave = n;
    for(int i = 0; i < w_timeSeries.numChannelBars; i++) {
        w_timeSeries.channelBars[i].adjustVertScale(w_timeSeries.yLimOptions[n]);
    }
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
}

//triggered when there is an event in the LogLin Dropdown
void Spillover(int n) {
    if (n==0) {
        w_timeSeries.allowSpillover = false;
    } else {
        w_timeSeries.allowSpillover = true;
    }
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
    Button_obci onOffButton;
    int onOff_diameter, impButton_diameter;
    Button_obci impCheckButton;
    ControlP5 cbCp5;
    int yScaleButton_w, yScaleButton_h;
    Button yScaleButton_pos;
    Button yScaleButton_neg;
    int yLim;
    int uiSpaceWidth;

    GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    GPointsArray channelPoints;
    int nPoints;
    int numSeconds;
    float timeBetweenPoints;

    color channelColor; //color of plot trace

    boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
    int autoScaleYLim = 0;

    TextBox voltageValue;
    //TextBox impValue;
    TextBox yAxisLabel_pos;
    TextBox yAxisLabel_neg;

    boolean drawVoltageValue;

    ChannelBar(PApplet _parent, int _channelIndex, int _x, int _y, int _w, int _h) { // channel number, x/y location, height, width
        
        cbCp5 = new ControlP5(ourApplet);
        cbCp5.setGraphics(ourApplet, x, y);
        cbCp5.setAutoDraw(false); //Setting this saves code as cp5 elements will only be drawn/visible when [cp5].draw() is called

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

        //// Old buttons
        onOffButton = new Button_obci (x + 6, y + int(h/2) - int(onOff_diameter/2), onOff_diameter, onOff_diameter, channelString, fontInfo.buttonLabel_size);
        onOffButton.setHelpText("Click to toggle channel " + channelString + ".");
        onOffButton.setFont(h2, 16);
        onOffButton.setCircleButton(true);
        onOffButton.setColorNotPressed(channelColors[channelIndex%8]); //Set channel button background colors
        onOffButton.textColorNotActive = color(255); //Set channel button text to white
        onOffButton.hasStroke(false);

        if(currentBoard instanceof ImpedanceSettingsBoard) {
            impButton_diameter = 22;
            impCheckButton = new Button_obci (x + 36, y + int(h/2) - int(impButton_diameter/2), impButton_diameter, impButton_diameter, "\u2126", fontInfo.buttonLabel_size);
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
        ////End Old buttons

        // New Buttons :)
        yScaleButton_w = 36 + impButton_diameter - 8;
        yScaleButton_h = 12;
        yScaleButton_pos = createButton(yScaleButton_pos, channelIndex, true, "increaseYscale", "+", x + w/2 - yScaleButton_w/2, y + 4, yScaleButton_w, yScaleButton_h);
        yScaleButton_neg = createButton(yScaleButton_neg, channelIndex, false, "decreaseYscale", "-", x + w/2 - yScaleButton_w/2, y + h - yScaleButton_h - 4, yScaleButton_w, yScaleButton_h); 
        
        uiSpaceWidth = 36 + 4 + impButton_diameter;
        yLim = 200;
        numSeconds = 5;
        plot = new GPlot(_parent);
        plot.setPos(x + uiSpaceWidth, y);
        plot.setDim(w - 36 - 4 - impButton_diameter, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[channelIndex%8]);
        plot.setXLim(-5,0);
        plot.setYLim(-yLim, yLim);
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

        
        voltageValue = new TextBox("", x + uiSpaceWidth + (int)plot.getDim()[0] - 2, y + h);
        voltageValue.textColor = color(bgColor);
        voltageValue.alignH = RIGHT;
        voltageValue.alignV = BOTTOM;
        voltageValue.drawBackground = true;
        voltageValue.backgroundColor = color(255,255,255,125);
        
        /*
        voltageValue = new Textlabel(cbCp5, "", x + uiSpaceWidth + (int)plot.getDim()[0] - 100, y + h - 14);
        voltageValue.setColor(color(bgColor));
        voltageValue.setColorBackground(color(255,255,255,125));
        voltageValue.setFont(p5);
        */
        /*
        impValue = new TextBox("", x + uiSpaceWidth + 2, y + h);
        impValue.textColor = color(bgColor);
        impValue.alignH = LEFT;
        // impValue.alignV = TOP;
        impValue.drawBackground = true;
        impValue.backgroundColor = color(255,255,255,125);
        */

        yAxisLabel_pos = new TextBox("+"+yLim, x + uiSpaceWidth + 2, y + 2);
        yAxisLabel_pos.textColor = color(bgColor);
        yAxisLabel_pos.alignH = LEFT;
        yAxisLabel_pos.alignV = TOP;
        yAxisLabel_pos.drawBackground = true;
        yAxisLabel_pos.backgroundColor = color(255,255,255,255);

        yAxisLabel_neg = new TextBox("+"+yLim, x + uiSpaceWidth + 2, y + h);
        yAxisLabel_neg.textColor = color(bgColor);
        yAxisLabel_neg.alignH = LEFT;
        yAxisLabel_neg.alignV = BOTTOM;
        yAxisLabel_neg.drawBackground = true;
        yAxisLabel_neg.backgroundColor = color(255,255,255,255);

        drawVoltageValue = true;
    }

    void update() {

        //Reusable variables
        String fmt; float val;

        //update the voltage values
        val = dataProcessing.data_std_uV[channelIndex];
        fmt = String.format(getFmt(val),val) + " uVrms";
        if (is_railed != null) {
            if (is_railed[channelIndex].is_railed == true) {
                fmt = "RAILED - " + fmt;
            } else if (is_railed[channelIndex].is_railed_warn == true) {
                fmt = "NEAR RAILED - " + fmt;
            }
        }
        //voltageValue.setText(fmt);
        voltageValue.string = fmt;

        //update the impedance values
        val = data_elec_imp_ohm[channelIndex]/1000;
        fmt = String.format(getFmt(val),val) + " kOhm";
        if (is_railed != null && is_railed[channelIndex].is_railed == true) {
            fmt = "RAILED - " + fmt;
        }
        //impValue.setText(fmt);

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

    private void updatePlotPoints() {
        // update data in plot
        if(dataProcessingFilteredBuffer[channelIndex].length > nPoints) {
            for (int i = dataProcessingFilteredBuffer[channelIndex].length - nPoints; i < dataProcessingFilteredBuffer[channelIndex].length; i++) {
                float time = -(float)numSeconds + (float)(i-(dataProcessingFilteredBuffer[channelIndex].length-nPoints))*timeBetweenPoints;
                float filt_uV_value = dataProcessingFilteredBuffer[channelIndex][i];

                // update channel point in place
                channelPoints.set(i-(dataProcessingFilteredBuffer[channelIndex].length-nPoints), time, filt_uV_value, "");
            }
            plot.setPoints(channelPoints); //reset the plot with updated channelPoints
        }
    }

    public void draw() {        
        pushStyle();

        //draw channel holder background
        stroke(31,69,110, 50);
        fill(255);
        rect(x,y,w,h);

        //draw onOff Button_obci
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
        //plot.drawYAxis();
        if(channelIndex == nchan-1) { //only draw the x axis label on the bottom channel bar
            plot.drawXAxis();
            plot.getXAxis().draw();
        }
        plot.endDraw();

        //draw impedance check Button_obci
        if(currentBoard instanceof ImpedanceSettingsBoard) {
            impCheckButton.draw();

            if(((ImpedanceSettingsBoard)currentBoard).isCheckingImpedance(channelIndex)) {
                //impValue.draw();
            }
        }
        
        if(drawVoltageValue) {
            voltageValue.draw();
        }

        yAxisLabel_pos.string = "+" + yLim;
        yAxisLabel_pos.draw();
        yAxisLabel_neg.string = "-" + yLim;
        yAxisLabel_neg.draw();

        popStyle();
    }

    private int nPointsBasedOnDataSource() {
        return numSeconds * currentBoard.getSampleRate();
    }

    public void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        nPoints = nPointsBasedOnDataSource();
        channelPoints = new GPointsArray(nPoints);
        if(_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
        }else{
            plot.getXAxis().setNTicks(10);
        }
        
        updatePlotPoints();
    }

    public void adjustVertScale(int _vertScaleValue) {
        if(_vertScaleValue == 0) {
            isAutoscale = true;
        } else {
            isAutoscale = false;
            plot.setYLim(-_vertScaleValue, _vertScaleValue);
            yLim = _vertScaleValue;
        }
    }

    private void autoScale() {
        autoScaleYLim = 0;
        for(int i = 0; i < nPoints; i++) {
            if(int(abs(channelPoints.getY(i))) > autoScaleYLim) {
                autoScaleYLim = int(abs(channelPoints.getY(i)));
            }
        }
        plot.setYLim(-autoScaleYLim, autoScaleYLim);
    }

    public void resize(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        //cbCp5.setGraphics(ourApplet, x, y);
        //reposition & resize the plot
        int plotW = w - 36 - 4 - impButton_diameter;
        plot.setPos(x + uiSpaceWidth, y);
        plot.setDim(plotW, h);
        
        //voltageValue.setPosition(x + uiSpaceWidth + plotW - textWidth(voltageValue.getStringValue()), y + h - 16);
        
        voltageValue.x = x + uiSpaceWidth + (w - 36 - 4 - impButton_diameter) - 2;
        voltageValue.y = y + h;
        /*
        impValue.x = x + uiSpaceWidth + 2;
        impValue.y = y + h;
        */
        yAxisLabel_pos.x = x + uiSpaceWidth + 2;
        yAxisLabel_pos.y = y + 2;
        yAxisLabel_neg.x = x + uiSpaceWidth + 2;
        yAxisLabel_neg.y = y + h;

        yScaleButton_pos.setPosition(x + (36 + impButton_diameter + 4)/2 - yScaleButton_w/2, y + 4);
        yScaleButton_neg.setPosition(x + (36 + impButton_diameter + 4)/2 - yScaleButton_w/2, y + h - yScaleButton_h - 4);

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
    }

    public void mousePressed() {
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

    public void mouseReleased() {
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

    private Button createButton (Button myButton, int chan, boolean shouldIncrease, String bName, String bText, int _x, int _y, int _w, int _h) {
        myButton = cbCp5.addButton(bName)
                .setPosition(_x, _y)
                .setSize(_w, _h)
                .setColorLabel(color(255))
                .setColorForeground(color(31, 69, 110))
                .setColorBackground(color(144, 100));
        myButton.getCaptionLabel()
                .setFont(createFont("Arial",14,true))
                .toUpperCase(false)
                .setSize(14)
                .setText(bText);
        myButton.onClick(new MyCallbackListener (chan, shouldIncrease ));
        return myButton;
    }

    private class MyCallbackListener implements CallbackListener {
        private int channel;
        private boolean increase;
        MyCallbackListener(int theChannel, boolean isIncrease)  {
            channel = theChannel;
            increase = isIncrease;
        }
        public void controlEvent(CallbackEvent theEvent) {
            verbosePrint("A button was pressed for channel " + (channel+1) + ". Should we increase (or decrease?): " + increase);
            yLim += increase ? 50 : -50;
            adjustVertScale(yLim);
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
    private Button_obci skipToStartButton;
    private int skipToStart_diameter;
    private String currentAbsoluteTimeToDisplay = "";
    private String currentTimeInSecondsToDisplay = "";
    private FileBoard fileBoard;
    
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
        skipToStartButton = new Button_obci (int(xp) + int(skipToStart_diameter*.5), int(yp) + int(sh/2) - skipToStart_diameter, skipToStart_diameter, skipToStart_diameter, "");
        skipToStartButton.setColorNotPressed(color(235)); //Set channel button background colors
        skipToStartButton.hasStroke(false);
        PImage bgImage = loadImage("skipToStart-30x26.png");
        skipToStartButton.setBackgroundImage(bgImage);

        fileBoard = (FileBoard)currentBoard;
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
        float currentSample = float(fileBoard.getCurrentSample());
        float totalSamples = float(fileBoard.getTotalSamples());
        float currentPlaybackPos = currentSample / totalSamples;

        spos =  lerp(sposMin, sposMax, currentPlaybackPos);
    }

    void scrubToPosition() {
        int totalSamples = fileBoard.getTotalSamples();
        int newSamplePos = floor(totalSamples * getCursorPercentage());

        fileBoard.goToIndex(newSamplePos);
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
        double totalMillis = fileBoard.getTotalTimeSeconds() * 1000.0;
        double currentMillis = fileBoard.getCurrentTimeSeconds() * 1000.0;

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
        fileBoard.goToIndex(0);
    }
    
};//end PlaybackScrollbar class

//========================== TimeDisplay ==========================
class TimeDisplay {
    int swidth, sheight;    // width and height of bar
    float xpos, ypos;       // x and y position of bar
    String currentAbsoluteTimeToDisplay = "";
    Boolean updatePosition = false;
    LocalDateTime time;

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
            text(streamTimeElapsed.toString(), xpos + 10, ypos);
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
        time = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
        return time.format(formatter);
    }
};//end TimeDisplay class

