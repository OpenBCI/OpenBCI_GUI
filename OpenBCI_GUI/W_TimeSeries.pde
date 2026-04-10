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

class W_TimeSeries extends WidgetWithSettings {
    private int numChannelBars;
    private float xF, yF, wF, hF;
    private float ts_padding;
    private float ts_x, ts_y, ts_h, ts_w; //values for actual time series chart -- rectangle encompassing all channelBars
    private float pb_x, pb_y, pb_h, pb_w; //values for playback sub-widget
    private float plotBottomWell;
    private float playbackWidgetHeight;
    private int channelBarHeight;
    public final int INTER_CHANNEL_BAR_SPACE = 2;
    private final int PADDING_5 = 5;

    private ControlP5 tscp5;
    private Button hwSettingsButton;

    private ExGChannelSelect tsChanSelect;
    private ChannelBar[] channelBars;
    private PlaybackScrollbar scrollbar;
    private TimeDisplay timeDisplay;

    private PImage expand_default;
    private PImage expand_hover;
    private PImage expand_active;
    private PImage contract_default;
    private PImage contract_hover;
    private PImage contract_active;

    private ADS1299SettingsController adsSettingsController;

    private boolean allowSpillover = false;
    private boolean hasScrollbar = true; //used to turn playback scrollbar widget on/off

    List<controlP5.Controller> cp5ElementsToCheck;

    W_TimeSeries() {
        super();
        widgetTitle = "Time Series";

        tscp5 = new ControlP5(ourApplet);
        tscp5.setGraphics(ourApplet, 0, 0);
        tscp5.setAutoDraw(false);

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        plotBottomWell = 35.0; //this appears to be an arbitrary vertical space adds GPlot leaves at bottom, I derived it through trial and error
        ts_padding = 10.0;
        ts_x = xF + ts_padding;
        ts_y = yF + ts_padding;
        ts_w = wF - ts_padding*2;
        ts_h = hF - playbackWidgetHeight - plotBottomWell - (ts_padding*2);
        numChannelBars = globalChannelCount; //set number of channel bars = to current globalChannelCount of system (4, 8, or 16)

        //Instantiate scrollbar if using playback mode and scrollbar feature in use
        if ((currentBoard instanceof FileBoard) && hasScrollbar) {
            playbackWidgetHeight = 30.0;
            int _x = floor(xF) - 1;
            int _y = int(ts_y + ts_h + playbackWidgetHeight + 5);
            int _w = int(wF) + 1;
            int _h = int(playbackWidgetHeight);
            pb_x = ts_x - ts_padding/2;
            pb_y = _y + playbackWidgetHeight/2;
            pb_w = ts_w - ts_padding*4;
            pb_h = playbackWidgetHeight/2;
            //Make a new scrollbar
            scrollbar = new PlaybackScrollbar(_x, _y, _w, _h, int(pb_x), int(pb_y), int(pb_w), int(pb_h));
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
        for (int i = 0; i < numChannelBars; i++) {
            int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
            ChannelBar tempBar = new ChannelBar(ourApplet, i, int(ts_x), channelBarY, int(ts_w), channelBarHeight, expand_default, expand_hover, expand_active, contract_default, contract_hover, contract_active);
            channelBars[i] = tempBar;
        }
        applyVerticalScaleToChannelBars();

        int x_hsc = int(channelBars[0].plot.getPos()[0] + 2);
        int y_hsc = int(channelBars[0].plot.getPos()[1]);
        int w_hsc = int(channelBars[0].plot.getOuterDim()[0]);
        int h_hsc = channelBarHeight * numChannelBars;

        if (currentBoard instanceof ADS1299SettingsBoard) {
            hwSettingsButton = createHSCButton("HardwareSettings", "Hardware Settings", (int)(x0 + 80), (int)(y0 + NAV_HEIGHT + 1), 120, NAV_HEIGHT - 3);
            cp5ElementsToCheck.add((controlP5.Controller)hwSettingsButton);
            adsSettingsController = new ADS1299SettingsController(ourApplet, tsChanSelect.getActiveChannels(), x_hsc, y_hsc, w_hsc, h_hsc, channelBarHeight);
        }
    }

    @Override
    protected void initWidgetSettings() {
        super.initWidgetSettings();
        // Store default values for widget settings
        widgetSettings.set(TimeSeriesYLim.class, TimeSeriesYLim.AUTO)
                    .set(TimeSeriesXLim.class, TimeSeriesXLim.FIVE)
                    .set(TimeSeriesLabelMode.class, TimeSeriesLabelMode.MINIMAL);
        
        // Initialize the dropdowns with these settings
        initDropdown(TimeSeriesYLim.class, "timeSeriesVerticalScaleDropdown", "Vert Scale");
        initDropdown(TimeSeriesXLim.class, "timeSeriesHorizontalScaleDropdown", "Window");
        initDropdown(TimeSeriesLabelMode.class, "timeSeriesLabelModeDropdown", "Labels");

        // Initialize the channel select feature for this widget
        tsChanSelect = new ExGChannelSelect(ourApplet, x, y, w, navH);
        
        // Activate all channels in channelSelect by default for this widget
        tsChanSelect.activateAllButtons();
        
        // Check and lock channel select if a dropdown that overlaps it is open
        cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.addAll(tsChanSelect.getCp5ElementsForOverlapCheck());
        
        // Save the active channels to the widget settings
        saveActiveChannels(tsChanSelect.getActiveChannels());
        
        // Save the current settings to the widget settings
        widgetSettings.saveDefaults();
    }

    @Override
    protected void applySettings() {
        // Update dropdown labels to match current settings
        updateDropdownLabel(TimeSeriesYLim.class, "timeSeriesVerticalScaleDropdown");
        updateDropdownLabel(TimeSeriesXLim.class, "timeSeriesHorizontalScaleDropdown");
        updateDropdownLabel(TimeSeriesLabelMode.class, "timeSeriesLabelModeDropdown");
        applyVerticalScaleToChannelBars();
        applyHorizontalScaleToChannelBars();
        applyActiveChannels(tsChanSelect);
    }

    @Override
    protected void updateChannelSettings() {
        // Just save the current active channels when saving settings
        if (tsChanSelect != null) {
            saveActiveChannels(tsChanSelect.getActiveChannels());
        }
    }

    void update() {
        super.update();

        // offset based on whether channel select or hardware settings are open or not
        int chanSelectOffset = tsChanSelect.isVisible() ? tsChanSelect.getHeight() : 0;
        int developerCommandsUIHeight = 0;
        if (currentBoard instanceof ADS1299SettingsBoard) {
            chanSelectOffset += adsSettingsController.getIsVisible() ? adsSettingsController.getHeaderHeight() : 0;
            developerCommandsUIHeight = adsSettingsController.getIsVisible() ? adsSettingsController.getCommandBarHeight() - (PADDING_5 * 2) : 0;
        }

        //Responsively size the channelBarHeight
        channelBarHeight = int((ts_h - chanSelectOffset - developerCommandsUIHeight) / tsChanSelect.getActiveChannels().size());

        //Update channel checkboxes
        tsChanSelect.update(x, y, w);

        //Update and resize all active channels
        for (int i = 0; i < tsChanSelect.getActiveChannels().size(); i++) {
            int activeChannel = tsChanSelect.getActiveChannels().get(i);
            int channelBarY = int(ts_y + chanSelectOffset) + i*(channelBarHeight); //iterate through bar locations
            //To make room for channel bar separator, subtract space between channel bars from height
            int cb_h = channelBarHeight - INTER_CHANNEL_BAR_SPACE;
            channelBars[activeChannel].resize(int(ts_x), channelBarY, int(ts_w), cb_h);
            channelBars[activeChannel].update(getAdsSettingsVisible(), widgetSettings.get(TimeSeriesLabelMode.class));
        }
        
        //Responsively size and update the HardwareSettingsController
        if (currentBoard instanceof ADS1299SettingsBoard) {
            int cb_h = channelBarHeight + INTER_CHANNEL_BAR_SPACE - 2;
            int h_hsc = channelBarHeight * tsChanSelect.getActiveChannels().size();        
            adsSettingsController.resize((int)channelBars[0].plot.getPos()[0], (int)channelBars[0].plot.getPos()[1], (int)channelBars[0].plot.getOuterDim()[0], h_hsc, cb_h);
            adsSettingsController.update(); //update channel controller
        }
        
        //Update Playback scrollbar and/or display time
        if ((currentBoard instanceof FileBoard) && hasScrollbar) {
            //scrub playback file
            scrollbar.update();
        } else {
            timeDisplay.update();
        }

        lockElementsOnOverlapCheck(cp5ElementsToCheck);
    }

    void draw() {
        super.draw();

        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        //draw channel bars
        for (int i = 0; i < tsChanSelect.getActiveChannels().size(); i++) {
            int activeChannel = tsChanSelect.getActiveChannels().get(i);
            channelBars[activeChannel].draw(getAdsSettingsVisible());
        }

        //Display playback scrollbar, timeDisplay, or ADSSettingsController depending on data source
        if ((currentBoard instanceof FileBoard) && hasScrollbar) { //you will only ever see the playback widget in Playback Mode ... otherwise not visible
            scrollbar.draw();
        } else if (currentBoard instanceof ADS1299SettingsBoard) {
            //Hide time display when ADSSettingsController is open for compatible boards
            if (!getAdsSettingsVisible()) {
                timeDisplay.draw();
            }
            adsSettingsController.draw();
        } else {
            timeDisplay.draw();
        }

        tscp5.draw();
        
        tsChanSelect.draw();
    }

    void screenResized() {
        super.screenResized();

        //Very important to allow users to interact with objects after app resize
        tscp5.setGraphics(ourApplet, 0,0);
        
        tsChanSelect.screenResized(ourApplet);

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        ts_x = xF + ts_padding;
        ts_y = yF + (ts_padding);
        ts_w = wF - ts_padding*2;
        ts_h = hF - playbackWidgetHeight - plotBottomWell - (ts_padding*2);
        
        ////Resize the playback slider if using playback mode, or resize timeDisplay div at the bottom of timeSeries
        if ((currentBoard instanceof FileBoard) && hasScrollbar) {
            int _x = floor(xF) - 1;
            int _y = y + h - int(playbackWidgetHeight);
            int _w = int(wF) + 1;
            int _h = int(playbackWidgetHeight);
            pb_x = ts_x - ts_padding/2;
            pb_y = _y + playbackWidgetHeight/2;
            pb_w = ts_w - ts_padding*4;
            pb_h = playbackWidgetHeight/2;
            scrollbar.screenResized(_x, _y, _w, _h, pb_x, pb_y, pb_w, pb_h);
        } else {
            int td_h = 18;
            timeDisplay.screenResized(int(ts_x), int(ts_y + hF - td_h), int(ts_w), td_h);
        }

        // offset based on whether channel select is open or not.
        int chanSelectOffset = 0;
        if (tsChanSelect.isVisible()) {
            chanSelectOffset = tsChanSelect.getHeight();
        }
        
        for (ChannelBar cb : channelBars) {
            cb.updateCP5(ourApplet);
        }
        
        for (int i = 0; i < tsChanSelect.getActiveChannels().size(); i++) {
            int activeChannel = tsChanSelect.getActiveChannels().get(i);
            int channelBarY = int(ts_y + chanSelectOffset) + i*(channelBarHeight); //iterate through bar locations
            channelBars[activeChannel].resize(int(ts_x), channelBarY, int(ts_w), channelBarHeight); //bar x, bar y, bar w, bar h
        }
        
        if (currentBoard instanceof ADS1299SettingsBoard) {
            hwSettingsButton.setPosition(x0 + 80, (int)(y0 + NAV_HEIGHT + 1));
        }
        
    }

    void mousePressed() {
        super.mousePressed();
        tsChanSelect.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked

        for (int i = 0; i < tsChanSelect.getActiveChannels().size(); i++) {
            int activeChannel = tsChanSelect.getActiveChannels().get(i);
            channelBars[activeChannel].mousePressed();
        }
    }
    
    void mouseReleased() {
        super.mouseReleased();

        for (int i = 0; i < tsChanSelect.getActiveChannels().size(); i++) {
            int activeChannel = tsChanSelect.getActiveChannels().get(i);
            channelBars[activeChannel].mouseReleased();
        }
    }

    public void setAdsSettingsVisible(boolean visible) {
        if (!(currentBoard instanceof ADS1299SettingsBoard)) {
            return;
        }

        String buttonText = "Time Series";
        
        if (visible && currentBoard.isStreaming()) { 
            if (guiSettings.getShowStopStreamHardwareSettingsPopup()) {
                if (!stopStreamHardwareSettingsPopupIsVisible) {
                    println("HardwareSettings: Opened popup to stop streaming and show hardware settings");
                    PopupMessage msg = new PopupMessageHardwareSettings();
                }
                return;
            } else {
                topNav.dataStreamTogglePressed();
            }
        }

        boolean inSync = adsSettingsController.setIsVisible(visible);
        
        if (!visible && adsSettingsController != null && inSync) {
            buttonText = "Hardware Settings";         
        }
        hwSettingsButton.setCaptionLabel(buttonText);

        println("HardwareSettings Toggle: " + adsSettingsController.getIsVisible());
    }

    private boolean getAdsSettingsVisible() {
        return adsSettingsController != null && adsSettingsController.getIsVisible();
    }

    public void closeADSSettings() {
        setAdsSettingsVisible(false);
    }

    private Button createHSCButton(String name, String text, int _x, int _y, int _w, int _h) {
        final Button myButton = createButton(tscp5, name, text, _x, _y, _w, _h);
        myButton.setBorderColor(OBJECT_BORDER_GREY);
        myButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {    
                setAdsSettingsVisible(!adsSettingsController.getIsVisible());
            }
        });
        return myButton;
    }

    private void applyVerticalScaleToChannelBars() {
        int verticalScaleValue = widgetSettings.get(TimeSeriesYLim.class).getValue();
        for (int i = 0; i < numChannelBars; i++) {
            channelBars[i].adjustVertScale(verticalScaleValue);
        }
    }

    private void applyHorizontalScaleToChannelBars() {
        int horizontalScaleValue = widgetSettings.get(TimeSeriesXLim.class).getValue();
        for (int i = 0; i < numChannelBars; i++) {
            channelBars[i].adjustTimeAxis(horizontalScaleValue);
        }
    }

    public void setVerticalScale(int n) {
        widgetSettings.setByIndex(TimeSeriesYLim.class, n);
        applyVerticalScaleToChannelBars();
    }

    public void setHorizontalScale(int n) {
        widgetSettings.setByIndex(TimeSeriesXLim.class, n);
        applyHorizontalScaleToChannelBars();
    }

    public void setLabelMode(int n) {
        widgetSettings.setByIndex(TimeSeriesLabelMode.class, n);
    }
};

//These functions are activated when an item from the corresponding dropdown is selected
void timeSeriesVerticalScaleDropdown(int n) {
    widgetManager.getTimeSeriesWidget().setVerticalScale(n);
}

void timeSeriesHorizontalScaleDropdown(int n) {
    widgetManager.getTimeSeriesWidget().setHorizontalScale(n);
}

void timeSeriesLabelModeDropdown(int n) {
    widgetManager.getTimeSeriesWidget().setLabelMode(n);
}
