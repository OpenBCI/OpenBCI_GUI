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

import org.apache.commons.lang3.math.NumberUtils;

interface TimeSeriesAxisEnum {
    public int getIndex();
    public int getValue();
    public String getString();
}

public enum TimeSeriesXLim implements TimeSeriesAxisEnum
{
    ONE (0, 1, "1 sec"),
    THREE (1, 3, "3 sec"),
    FIVE (2, 5, "5 sec"),
    TEN (3, 10, "10 sec"),
    TWENTY (4, 20, "20 sec");

    private int index;
    private int value;
    private String label;

    TimeSeriesXLim(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    @Override
    public int getValue() {
        return value;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }
}

public enum TimeSeriesYLim implements TimeSeriesAxisEnum
{
    AUTO (0, 0, "Auto"),
    UV_50 (1, 50, "50 uV"),
    UV_100 (2, 100, "100 uV"),
    UV_200 (3, 200, "200 uV"),
    UV_400 (4, 400, "400 uV"),
    UV_1000 (5, 1000, "1000 uV"),
    UV_10000 (6, 10000, "10000 uV");

    private int index;
    private int value;
    private String label;

    TimeSeriesYLim(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    @Override
    public int getValue() {
        return value;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }
}

class W_timeSeries extends Widget {
    //to see all core variables/methods of the Widget class, refer to Widget.pde
    //put your custom variables here...
    private int numChannelBars;
    private float xF, yF, wF, hF;
    private float ts_padding;
    private float ts_x, ts_y, ts_h, ts_w; //values for actual time series chart -- rectangle encompassing all channelBars
    private float pb_x, pb_y, pb_h, pb_w; //values for playback sub-widget
    private float plotBottomWell;
    private float playbackWidgetHeight;
    private int channelBarHeight;
    public final int interChannelBarSpace = 2;

    private ControlP5 tscp5;
    private Button hwSettingsButton;

    private ChannelSelect tsChanSelect;
    private ChannelBar[] channelBars;
    private PlaybackScrollbar scrollbar;
    private TimeDisplay timeDisplay;

    TimeSeriesXLim xLimit = TimeSeriesXLim.FIVE;
    TimeSeriesYLim yLimit = TimeSeriesYLim.UV_200;

    private PImage expand_default;
    private PImage expand_hover;
    private PImage expand_active;
    private PImage contract_default;
    private PImage contract_hover;
    private PImage contract_active;

    private ADS1299SettingsController adsSettingsController;

    private boolean allowSpillover = false;
    private TextBox[] impValuesMontage;
    private boolean visible = true;
    private boolean hasScrollbar = true; //used to turn playback scrollbar widget on/off

    W_timeSeries(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        tscp5 = new ControlP5(_parent);
        tscp5.setGraphics(_parent, 0,0);
        tscp5.setAutoDraw(false);

        tsChanSelect = new ChannelSelect(pApplet, x, y, w, navH, "TS_Channels");

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

        //This is a newer protocol for setting up dropdowns.
        addDropdown("VertScale_TS", "Vert Scale", getEnumStrings(yLimit.values()), yLimit.getIndex());
        addDropdown("Duration", "Window", getEnumStrings(xLimit.values()), xLimit.getIndex());

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

        expand_default = loadImage("expand_default.png");
        expand_hover = loadImage("expand_hover.png");
        expand_active = loadImage("expand_active.png");
        contract_default = loadImage("contract_default.png");
        contract_hover = loadImage("contract_hover.png");
        contract_active = loadImage("contract_active.png");

        channelBarHeight = int(ts_h/numChannelBars);
        channelBars = new ChannelBar[numChannelBars];
        //create our channel bars and populate our channelBars array!
        for(int i = 0; i < numChannelBars; i++) {
            int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
            ChannelBar tempBar = new ChannelBar(_parent, i, int(ts_x), channelBarY, int(ts_w), channelBarHeight, expand_default, expand_hover, expand_active, contract_default, contract_hover, contract_active);
            channelBars[i] = tempBar;
        }

        int x_hsc = int(channelBars[0].plot.getPos()[0] + 2);
        int y_hsc = int(channelBars[0].plot.getPos()[1]);
        int w_hsc = int(channelBars[0].plot.getOuterDim()[0]);
        int h_hsc = channelBarHeight * numChannelBars + navH;

        if (currentBoard instanceof ADS1299SettingsBoard) {
            hwSettingsButton = createHSCButton(hwSettingsButton, "HardwareSettings", "Hardware Settings", (int)(x0 + 80), (int)(y + navHeight + 3), 120, navHeight - 6);
            adsSettingsController = new ADS1299SettingsController(_parent, tsChanSelect.activeChan, x_hsc, y_hsc, w_hsc, h_hsc, channelBarHeight);
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

            // offset based on whether channel select or hardware settings are open or not
            int chanSelectOffset = tsChanSelect.isVisible() ? navHeight : 0;
            if (currentBoard instanceof ADS1299SettingsBoard) {
                chanSelectOffset += adsSettingsController.getIsVisible() ? navHeight : 0;
            }

            //Responsively size the channelBarHeight
            channelBarHeight = int((ts_h - chanSelectOffset) / tsChanSelect.activeChan.size());

            //Update channel checkboxes
            tsChanSelect.update(x, y, w);

            //Update and resize all active channels
            for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
                int activeChan = tsChanSelect.activeChan.get(i);
                int channelBarY = int(ts_y + chanSelectOffset) + i*(channelBarHeight); //iterate through bar locations
                //To make room for channel bar separator, subtract space between channel bars from height
                int cb_h = channelBarHeight - interChannelBarSpace;
                channelBars[activeChan].resize(int(ts_x), channelBarY, int(ts_w), cb_h);
                channelBars[activeChan].update();
            }
            
            //Responsively size and update the HardwareSettingsController
            if (currentBoard instanceof ADS1299SettingsBoard) {
                int cb_h = channelBarHeight + interChannelBarSpace - 2;
                int h_hsc = channelBarHeight * numChannelBars + navH;        
                adsSettingsController.resize((int)channelBars[0].plot.getPos()[0], (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], h_hsc, cb_h);
                adsSettingsController.update(); //update channel controller
                //ignore top left button interaction when widgetSelector dropdown is active
                ignoreButtonCheck(hwSettingsButton);
            }
            
            //Update Playback scrollbar and/or display time
            if((currentBoard instanceof FileBoard) && hasScrollbar) {
                //scrub playback file
                scrollbar.update();
            } else {
                timeDisplay.update();
            }
        }
    }

    void draw() {
        if (visible) {
            super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

            //remember to refer to x,y,w,h which are the positioning variables of the Widget class
            pushStyle();
            //draw channel bars
            for (int i = 0; i < tsChanSelect.activeChan.size(); i++) {
                int activeChan = tsChanSelect.activeChan.get(i);
                channelBars[activeChan].draw(getAdsSettingsVisible());
            }
            popStyle();

            //Display playback scrollbar or timeDisplay, depending on data source
            if ((currentBoard instanceof FileBoard) && hasScrollbar) { //you will only ever see the playback widget in Playback Mode ... otherwise not visible
                fill(0,0,0,20);
                stroke(31,69,110);
                rect(xF, ts_y + ts_h + playbackWidgetHeight + 5, wF, playbackWidgetHeight);
                scrollbar.draw();
            } else {
                timeDisplay.draw();
            }

            if (currentBoard instanceof ADS1299SettingsBoard) {
                adsSettingsController.draw();
            }

            tscp5.draw();
            
            tsChanSelect.draw();

            popStyle();
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
        
        for (ChannelBar cb : channelBars) {
            cb.updateCP5(ourApplet);
        }
        
        for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
            int activeChan = tsChanSelect.activeChan.get(i);
            int channelBarY = int(ts_y + chanSelectOffset) + i*(channelBarHeight); //iterate through bar locations
            channelBars[activeChan].resize(int(ts_x), channelBarY, int(ts_w), channelBarHeight); //bar x, bar y, bar w, bar h
        }
        
        if (currentBoard instanceof ADS1299SettingsBoard) {
            hwSettingsButton.setPosition(x0 + 80, (int)(y0 + navHeight + 3));
            int h_hsc = channelBarHeight * numChannelBars + navH;
            adsSettingsController.resize((int)channelBars[0].plot.getPos()[0] + 2, (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], h_hsc, channelBarHeight);
        }
        
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        tsChanSelect.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked

        for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
            int activeChan = tsChanSelect.activeChan.get(i);
            channelBars[activeChan].mousePressed();
        }
    }
    
    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        for(int i = 0; i < tsChanSelect.activeChan.size(); i++) {
            int activeChan = tsChanSelect.activeChan.get(i);
            channelBars[activeChan].mouseReleased();
        }
    }

    private void setAdsSettingsVisible(boolean visible) {
        if(!(currentBoard instanceof ADS1299SettingsBoard)) {
            return;
        }

        String buttonText = "Time Series";

        if (visible && isRunning) {
            PopupMessage msg = new PopupMessage("Info", "Streaming needs to be stopped before accessing Hardware Settings");
            return;
        }

        boolean inSync = adsSettingsController.setIsVisible(visible);
        
        if (!visible && adsSettingsController != null && inSync) {
            buttonText = "Hardware Settings";         
        }
        hwSettingsButton.setCaptionLabel(buttonText);
    }

    private boolean getAdsSettingsVisible() {
        return adsSettingsController != null && adsSettingsController.getIsVisible();
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

    private Button createHSCButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h) {
        myButton = tscp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(color(177, 184, 193))
            .setColorBackground(colorNotPressed)
            .setColorActive(color(150,170,200))
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial",12,true))
            .toUpperCase(false)
            .setSize(12)
            .setText(text)
            ;
        myButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {    
                println("HardwareSettings Toggle: " + !adsSettingsController.getIsVisible());
                setAdsSettingsVisible(!adsSettingsController.getIsVisible());
            }
        });
        return myButton;
    }

    public List<String> getEnumStrings(TimeSeriesAxisEnum[] enumValues) {
        List<String> enumStrings = new ArrayList<String>();
        for (TimeSeriesAxisEnum val : enumValues) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }

    public TimeSeriesYLim getTSVertScale() {
        return yLimit;
    }

    public TimeSeriesXLim getTSHorizScale() {
        return xLimit;
    }

    public void setTSVertScale(int n) {
        yLimit = yLimit.values()[n];
        for (int i = 0; i < numChannelBars; i++) {
            channelBars[i].adjustVertScale(yLimit.getValue());
        }
    }

    public void setTSHorizScale(int n) {
        xLimit = xLimit.values()[n];
        for (int i = 0; i < numChannelBars; i++) {
            channelBars[i].adjustTimeAxis(xLimit.getValue());
        }
    }
};

//These functions are activated when an item from the corresponding dropdown is selected
void VertScale_TS(int n) {
    w_timeSeries.setTSVertScale(n);
}

//triggered when there is an event in the Duration Dropdown
void Duration(int n) {
    w_timeSeries.setTSHorizScale(n);

    int newDuration = w_timeSeries.getTSHorizScale().getValue();
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

//========================================================================================================================
//                      CHANNEL BAR CLASS -- Implemented by Time Series Widget Class
//========================================================================================================================
//this class contains the plot and buttons for a single channel of the Time Series widget
//one of these will be created for each channel (4, 8, or 16)
class ChannelBar {

    int channelIndex; //duh
    String channelString;
    int x, y, w, h;
    int defaultH;
    Button_obci onOffButton;
    int onOff_diameter, impButton_diameter;
    Button_obci impCheckButton;
    ControlP5 cbCp5;
    int yScaleButton_h;
    int yScaleButton_w;
    Button yScaleButton_pos;
    Button yScaleButton_neg;
    int yAxisLabel_h;
    private Textfield yAxisMax;
    private Textfield yAxisMin;
    
    int yAxisUpperLim;
    int yAxisLowerLim;
    int uiSpaceWidth;
    int padding_4 = 4;
    int minimumChannelHeight;
    int plotBottomWellH = 45;

    GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    GPointsArray channelPoints;
    int nPoints;
    int numSeconds;
    float timeBetweenPoints;

    color channelColor; //color of plot trace

    boolean isAutoscale = false; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
    float autoscaleMin;
    float autoscaleMax;
    int previousMillis = 0;
    
    TextBox voltageValue;
    TextBox impValue;

    boolean drawVoltageValue;

    ChannelBar(PApplet _parent, int _channelIndex, int _x, int _y, int _w, int _h, PImage expand_default, PImage expand_hover, PImage expand_active, PImage contract_default, PImage contract_hover, PImage contract_active) {
        
        cbCp5 = new ControlP5(ourApplet);
        cbCp5.setGraphics(ourApplet, x, y);
        cbCp5.setAutoDraw(false); //Setting this saves code as cp5 elements will only be drawn/visible when [cp5].draw() is called

        channelIndex = _channelIndex;
        channelString = str(channelIndex + 1);

        x = _x;
        y = _y;
        w = _w;
        h = _h;
        defaultH = h;

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

        uiSpaceWidth = 36 + padding_4 + impButton_diameter;
        yAxisUpperLim = 200;
        yAxisLowerLim = -200;
        numSeconds = 5;
        plot = new GPlot(_parent);
        plot.setPos(x + uiSpaceWidth, y);
        plot.setDim(w - uiSpaceWidth, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[channelIndex%8]);
        plot.setXLim(-5,0);
        plot.setYLim(yAxisLowerLim, yAxisUpperLim);
        plot.setPointSize(2);
        plot.setPointColor(0);
        plot.setAllFontProperties("Arial", 0, 14);
        if(channelIndex == nchan-1) {
            plot.getXAxis().setAxisLabelText("Time (s)");
            plot.getXAxis().getAxisLabel().setOffset(plotBottomWellH/2 + 5f);
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

        // New Buttons
        yScaleButton_w = 18;
        yScaleButton_h = 18;
        yAxisLabel_h = 12;
        int padding = 2;
        yAxisMax = createTextfield(yAxisMax, yAxisUpperLim, "yAxisMax", "+"+yAxisUpperLim+"uV", x + uiSpaceWidth + padding, y + int(padding*1.5), yAxisMax.autoWidth + padding_4*2, yAxisLabel_h);
        yAxisMin = createTextfield(yAxisMin, yAxisLowerLim, "yAxisMin", yAxisLowerLim+"uV", x + uiSpaceWidth + padding, y + h - yAxisLabel_h - padding_4, yAxisMin.autoWidth + padding_4*2, yAxisLabel_h);

        yScaleButton_neg = createButton(yScaleButton_neg, channelIndex, false, "decreaseYscale", "-T", x + uiSpaceWidth + padding, y + w/2 - yScaleButton_h/2, yScaleButton_w, yScaleButton_h, contract_default, contract_hover, contract_active); 
        yScaleButton_pos = createButton(yScaleButton_pos, channelIndex, true, "increaseYscale", "+T", x + uiSpaceWidth + padding*2 + yScaleButton_w, y + w/2 - yScaleButton_h/2, yScaleButton_w, yScaleButton_h, expand_default, expand_hover, expand_active);
        
        impValue = new TextBox("", x + uiSpaceWidth + (int)plot.getDim()[0], y + padding, color(bgColor), color(255,255,255,175), RIGHT, TOP);
        voltageValue = new TextBox("", x + uiSpaceWidth + (int)plot.getDim()[0] - padding, y + h, color(bgColor), color(255,255,255,175), RIGHT, BOTTOM);

        drawVoltageValue = true;
        minimumChannelHeight = padding_4 + yAxisLabel_h*2;
    }

    void update() {

        //Reusable variables
        String fmt; float val;

        //update the voltage values
        val = dataProcessing.data_std_uV[channelIndex];
        voltageValue.string = String.format(getFmt(val),val) + " uVrms";
        if (is_railed != null) {
            voltageValue.setText(is_railed[channelIndex].notificationString + voltageValue.string);
            voltageValue.setTextColor(is_railed[channelIndex].getColor());
        }

        //update the impedance values
        val = data_elec_imp_ohm[channelIndex]/1000;
        fmt = String.format(getFmt(val),val) + " kOhm";
        if (is_railed != null && is_railed[channelIndex].is_railed == true) {
            fmt = "RAILED - " + fmt;
        }
        impValue.setText(fmt);

        // update data in plot
        updatePlotPoints();

        if(currentBoard.isEXGChannelActive(channelIndex)) {
            onOffButton.setColorNotPressed(channelColors[channelIndex%8]); // power down == false, set color to vibrant
        }
        else {
            onOffButton.setColorNotPressed(50); // power down == true, set to grey
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

        autoscaleMax = 0;
        autoscaleMin = 0;

        // update data in plot
        if (dataProcessingFilteredBuffer[channelIndex].length >= nPoints) {
            for (int i = dataProcessingFilteredBuffer[channelIndex].length - nPoints; i < dataProcessingFilteredBuffer[channelIndex].length; i++) {
                float time = -(float)numSeconds + (float)(i-(dataProcessingFilteredBuffer[channelIndex].length-nPoints))*timeBetweenPoints;
                float filt_uV_value = dataProcessingFilteredBuffer[channelIndex][i];

                // update channel point in place
                channelPoints.set(i-(dataProcessingFilteredBuffer[channelIndex].length-nPoints), time, filt_uV_value, "");
                autoscaleMax = Math.max(filt_uV_value, autoscaleMax);
                autoscaleMin = Math.min(filt_uV_value, autoscaleMin);
            }
            applyAutoscale();
            plot.setPoints(channelPoints); //reset the plot with updated channelPoints
        }
    }

    public void draw(boolean hardwareSettingsAreOpen) {        
        pushStyle();

        //draw onOff Button_obci
        onOffButton.draw();

        plot.beginDraw();
        plot.drawBox();
        plot.drawGridLines(0);
        try {
            plot.drawLines();
        } catch (NullPointerException e) {
            e.printStackTrace();
            println("PLOT ERROR ON CHANNEL " + channelIndex);
            
        }
        //Draw the x axis label on the bottom channel bar, hide if hardware settings are open
        if (isBottomChannel() && !hardwareSettingsAreOpen) {
            plot.drawXAxis();
            plot.getXAxis().draw();
        }
        plot.endDraw();

        //draw channel holder background
        pushStyle();
        stroke(31,69,110, 50);
        //stroke(255,0,0,255);
        noFill();
        rect(x,y,w,h);

        //draw channelBar separator line in the middle of interChannelBarSpace
        if (!isBottomChannel()) {
            pushStyle();
            stroke(bgColor);
            strokeWeight(1);
            int separator_y = y + h + int(w_timeSeries.interChannelBarSpace/2);
            line(x, separator_y, x + w, separator_y);
        }

        //draw impedance check Button_obci
        drawVoltageValue = true;
        if (currentBoard instanceof ImpedanceSettingsBoard) {
            impCheckButton.draw();
            if(((ImpedanceSettingsBoard)currentBoard).isCheckingImpedance(channelIndex)) {
                impValue.draw();
                drawVoltageValue = false;
            }
        }
        
        if (drawVoltageValue) {
            voltageValue.draw();
        }
        
        //Hide yAxisButtons when hardware settings are open, labels would start to overlap, or using autoscale
        boolean b = !hardwareSettingsAreOpen && (h > yScaleButton_h + yAxisLabel_h*2 + 2) && !isAutoscale;
        yScaleButton_pos.setVisible(b);
        yScaleButton_neg.setVisible(b);
        b = !hardwareSettingsAreOpen && h > minimumChannelHeight;
        yAxisMin.setVisible(b);
        yAxisMax.setVisible(b);

        popStyle();
        try {
            cbCp5.draw();
        } catch (NullPointerException e) {
            e.printStackTrace();
            println("CP5 ERROR ON CHANNEL " + channelIndex);
        }
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

    //Happens when user selects vert scale dropdown
    public void adjustVertScale(int _vertScaleValue) {
        //Early out if autoscale
        if (_vertScaleValue == 0) {
            isAutoscale = true;
            yAxisMin.lock();
            yAxisMax.lock();
            return;
        }
        yAxisMin.unlock();
        yAxisMax.unlock();
        isAutoscale = false;
        yAxisLowerLim = -_vertScaleValue;
        yAxisUpperLim = _vertScaleValue;
        plot.setYLim(yAxisLowerLim, yAxisUpperLim);
        //Update button text
        customYLim(yAxisMin, yAxisLowerLim);
        customYLim(yAxisMax, yAxisUpperLim);
    }

    public void applyAutoscale() {
        if (isAutoscale && isRunning) {
            if (millis() > previousMillis + 1000) {
            //if (true) {
                previousMillis = millis();
                float limit = Math.max(abs(autoscaleMin), autoscaleMax);
                limit = Math.max(limit, 5);
                //float limit = 50f;
                plot.setYLim(-limit, limit);
                customYLim(yAxisMin, (int)-limit);
                customYLim(yAxisMax, (int)limit);
                //println("CH " + channelIndex + "__DOING AUTOSCALE - " + previousMillis);
            }
        }
    }

    //Update yAxis text and responsively size Textfield
    private void customYLim(Textfield tf, int limit) {
        String s = limit > 0 ? "+" : "";
        s += limit+"uV";
        tf.setText(s);
        //Responsively scale button size based on number of digits
        int _width =  s.length() * 6;
        tf.setSize(_width, yAxisLabel_h);
    }

    public void resize(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        //reposition & resize the plot
        int plotW = w - uiSpaceWidth;
        plot.setPos(x + uiSpaceWidth, y);
        plot.setDim(plotW, h);

        int padding = 2;
        voltageValue.setPosition(x + uiSpaceWidth + (w - uiSpaceWidth) - padding, y + h);
        impValue.setPosition(x + uiSpaceWidth + (int)plot.getDim()[0], y + padding);

        yScaleButton_neg.setPosition(x + uiSpaceWidth + padding, y + h/2 - yScaleButton_h/2);
        yScaleButton_pos.setPosition(x + uiSpaceWidth + padding*2 + yScaleButton_w, y + h/2 - yScaleButton_h/2);

        yAxisMax.setPosition(x + uiSpaceWidth + padding, y + int(padding*1.5));
        yAxisMin.setPosition(x + uiSpaceWidth + padding, y + h - yAxisLabel_h - padding);

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

    public void updateCP5(PApplet _parent) {
        cbCp5.setGraphics(_parent, 0, 0);
    }

    private boolean isBottomChannel() {
        return channelIndex == nchan - 1;
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
            w_timeSeries.adsSettingsController.updateChanSettingsDropdowns(channelIndex, currentBoard.isEXGChannelActive(channelIndex), channelColors[channelIndex%8]);
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

    private Button createButton (Button myButton, int chan, boolean shouldIncrease, String bName, String bText, int _x, int _y, int _w, int _h, PImage _default, PImage _hover, PImage _active) {
        _default.resize(_w, _h);
        _hover.resize(_w, _h);
        _active.resize(_w, _h);
        myButton = cbCp5.addButton(bName)
                .setPosition(_x, _y)
                .setSize(_w, _h)
                .setColorLabel(color(255))
                .setColorForeground(color(31, 69, 110))
                .setColorBackground(color(144, 100))
                .setImages(_default, _hover, _active)
                ;
        myButton.getCaptionLabel()
                .setFont(createFont("Arial",12,true))
                .toUpperCase(false)
                .setSize(12)
                .setText("")
                ;
        myButton.onClick(new ButtonCallbackListener(chan, shouldIncrease));
        return myButton;
    }

    private Textfield createTextfield(Textfield myTextfield, int intValue, String name, String text, int _x, int _y, int _w, int _h) {
        myTextfield = cbCp5.addTextfield(name)
            .setPosition(_x, _y)
            .setCaptionLabel("")
            .setSize(_w, _h)
            .setFont(createFont("Arial",10,true))
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(color(0, 0, 0))  // text color
            .setColorForeground(color(210))  // border color when not selected - grey
            .setColorActive(isSelected_color)  // border color when selected - green
            .setColorCursor(color(26, 26, 26))
            .setText(text) //set the text
            .align(5, 10, 20, 40)
            //.onDoublePress(new TFCallbackListener (channelIndex, text, multiplier))
            .setAutoClear(false)
            ;
        myTextfield.addCallback(new TFCallbackListener(channelIndex, myTextfield));
        customYLim(myTextfield, intValue);
        return myTextfield;
    }

    private class ButtonCallbackListener implements CallbackListener {
        private int channel;
        private boolean increase;
        private final int hardLimit = 25;
        private int yLimOption = TimeSeriesYLim.UV_200.getValue();
        //private int delta = 0; //value to change limits by

        ButtonCallbackListener(int theChannel, boolean isIncrease)  {
            channel = theChannel;
            increase = isIncrease;
        }
        public void controlEvent(CallbackEvent theEvent) {
            verbosePrint("A button was pressed for channel " + (channel+1) + ". Should we increase (or decrease?): " + increase);

            int inc = increase ? 1 : -1;
            int n = (int)(log10(abs(yAxisLowerLim))) * 25 * inc;
            yAxisLowerLim -= n;
            n = (int)(log10(yAxisUpperLim)) * 25 * inc;
            yAxisUpperLim += n;
            
            yAxisLowerLim = yAxisLowerLim <= -hardLimit ? yAxisLowerLim : -hardLimit;
            yAxisUpperLim = yAxisUpperLim >= hardLimit ? yAxisUpperLim : hardLimit;
            plot.setYLim(yAxisLowerLim, yAxisUpperLim);
            //Update button text
            customYLim(yAxisMin, yAxisLowerLim);
            customYLim(yAxisMax, yAxisUpperLim);
        }
    }

    private class TFCallbackListener implements CallbackListener {
        private int channel;
        private Textfield tf;
        private String rcvString;
        private int rcvAsInt;
    
        TFCallbackListener(int i, Textfield _tf)  {
            channel = i;
            tf = _tf;
        }
        public void controlEvent(CallbackEvent theEvent) {
            
            //Pressing ENTER in the Textfield triggers a "Broadcast"
            if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) { 
                
                //Try to clean up typing accidents from user input in Textfield
                rcvString = theEvent.getController().getStringValue().replaceAll("[A-Za-z!@#$%^&()=/*_]","");
                rcvAsInt = NumberUtils.toInt(rcvString);
                if (rcvAsInt == 0) {
                    rcvAsInt = Math.round(NumberUtils.toFloat(rcvString));
                }
                verbosePrint("Textfield: channel===" + channel + "|| string===" + rcvString + "|| asInteger===" + rcvAsInt);
                
                if (tf == yAxisMin) {
                    yAxisLowerLim = rcvAsInt;
                } else {
                    yAxisUpperLim = rcvAsInt;
                }
                
                customYLim(tf, rcvAsInt);
                plot.setYLim(yAxisLowerLim, yAxisUpperLim);
            }

            //Clicking in the Textfield, which you must do before typing, reformats the text to be an integer
            if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
                int i = (tf == yAxisMin) ? yAxisLowerLim : yAxisUpperLim;
                tf.setText(Integer.toString(i));
            }
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
