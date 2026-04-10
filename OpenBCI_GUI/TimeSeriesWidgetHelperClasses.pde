
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
    ControlP5 cbCp5;
    Button onOffButton;
    int onOff_diameter;
    int yScaleButton_h;
    int yScaleButton_w;
    Button yScaleButton_pos;
    Button yScaleButton_neg;
    int yAxisLabel_h;
    private TextBox yAxisMax;
    private TextBox yAxisMin;
    
    int yAxisUpperLim;
    int yAxisLowerLim;
    int uiSpaceWidth;
    int padding_4 = 4;
    int minimumChannelHeight;
    int plotBottomWellH = 35;

    GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Se ries trace
    GPointsArray channelPoints;
    int nPoints;
    int numSeconds;
    float timeBetweenPoints;
    private GPlotAutoscaler gplotAutoscaler;

    color channelColor; //color of plot trace
    
    TextBox voltageValue;
    TextBox impValue;

    boolean drawVoltageValue;

    ChannelBar(PApplet _parentApplet, int _channelIndex, int _x, int _y, int _w, int _h, PImage expand_default, PImage expand_hover, PImage expand_active, PImage contract_default, PImage contract_hover, PImage contract_active) {
        
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

        onOff_diameter = h > 26 ? 26 : h - 2;
        createOnOffButton("onOffButton"+channelIndex, channelString, x + 6, y + int(h/2) - int(onOff_diameter/2), onOff_diameter, onOff_diameter);

        //Create GPlot for this Channel
        uiSpaceWidth = 36 + padding_4;
        yAxisUpperLim = 200;
        yAxisLowerLim = -200;
        numSeconds = 5;
        plot = new GPlot(_parentApplet);
        plot.setPos(x + uiSpaceWidth, y);
        plot.setDim(w - uiSpaceWidth, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[channelIndex%8]);
        plot.setXLim(-5,0);
        plot.setYLim(yAxisLowerLim, yAxisUpperLim);
        plot.setPointSize(2);
        plot.setPointColor(0);
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getXAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getXAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        if (channelIndex == globalChannelCount-1) {
            plot.getXAxis().setAxisLabelText("Time (s)");
            plot.getXAxis().getAxisLabel().setOffset(plotBottomWellH/2 + 5f);
        }
        gplotAutoscaler = new GPlotAutoscaler();

        //Fill the GPlot with initial data
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

        //Create a UI to custom scale the Y axis for this channel
        yScaleButton_w = 18;
        yScaleButton_h = 18;
        yAxisLabel_h = 12;
        int padding = 2;
        yAxisMax = new TextBox("+"+yAxisUpperLim+"uV", x + uiSpaceWidth + padding, y + int(padding*1.5), OPENBCI_DARKBLUE, color(255,255,255,175), LEFT, TOP);
        yAxisMin = new TextBox(yAxisLowerLim+"uV", x + uiSpaceWidth + padding, y + h - yAxisLabel_h - padding_4, OPENBCI_DARKBLUE, color(255,255,255,175), LEFT, TOP);
        customYLim(yAxisMax, yAxisUpperLim);
        customYLim(yAxisMin, yAxisLowerLim);
        yScaleButton_neg = createYScaleButton(channelIndex, false, "decreaseYscale", "-T", x + uiSpaceWidth + padding, y + w/2 - yScaleButton_h/2, yScaleButton_w, yScaleButton_h, contract_default, contract_hover, contract_active); 
        yScaleButton_pos = createYScaleButton(channelIndex, true, "increaseYscale", "+T", x + uiSpaceWidth + padding*2 + yScaleButton_w, y + w/2 - yScaleButton_h/2, yScaleButton_w, yScaleButton_h, expand_default, expand_hover, expand_active);
        
        //Create textBoxes to display the current values
        impValue = new TextBox("", x + uiSpaceWidth + (int)plot.getDim()[0], y + padding, OPENBCI_DARKBLUE, color(255,255,255,175), RIGHT, TOP);
        voltageValue = new TextBox("", x + uiSpaceWidth + (int)plot.getDim()[0] - padding, y + h, OPENBCI_DARKBLUE, color(255,255,255,175), RIGHT, BOTTOM);
        drawVoltageValue = true;

        //Establish a minimumChannelHeight
        minimumChannelHeight = padding_4 + yAxisLabel_h*2;
    }

    void update(boolean hardwareSettingsAreOpen, TimeSeriesLabelMode _labelMode) {

        //Reusable variables
        String fmt; float val;

        //Update the voltage value TextBox
        val = dataProcessing.data_std_uV[channelIndex];
        voltageValue.string = String.format(getFmt(val),val) + " uVrms";
        if (is_railed != null) {
            voltageValue.setText(is_railed[channelIndex].notificationString + voltageValue.string);
            voltageValue.setTextColor(OPENBCI_DARKBLUE);
            color bgColor = color(255,255,255,175); // Default white background for voltage TextBox
            if (is_railed[channelIndex].is_railed) {
                bgColor = SIGNAL_CHECK_RED_LOWALPHA;
            } else if (is_railed[channelIndex].is_railed_warn) {
                bgColor =  SIGNAL_CHECK_YELLOW_LOWALPHA;
            }
            voltageValue.setBackgroundColor(bgColor);
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

        if (currentBoard.isEXGChannelActive(channelIndex)) {
            onOffButton.setColorBackground(channelColors[channelIndex%8]); // power down == false, set color to vibrant
        }
        else {
            onOffButton.setColorBackground(50); // power down == true, set to grey
        }
        
        //Hide yAxisButtons when hardware settings are open, using autoscale, and labels are turn on
        boolean b = !hardwareSettingsAreOpen 
            && h > minimumChannelHeight
            && !gplotAutoscaler.getEnabled()
            && _labelMode == TimeSeriesLabelMode.ON;
        yScaleButton_pos.setVisible(b);
        yScaleButton_neg.setVisible(b);
        yScaleButton_pos.setUpdate(b);
        yScaleButton_neg.setUpdate(b);
        b = !hardwareSettingsAreOpen
            && h > minimumChannelHeight
            && _labelMode == TimeSeriesLabelMode.ON;
        yAxisMin.setVisible(b);
        yAxisMax.setVisible(b);
        voltageValue.setVisible(_labelMode != TimeSeriesLabelMode.OFF);
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
        float[][] buffer = downsampledFilteredBuffer.getBuffer();
        final int bufferSize = buffer[channelIndex].length;
        final int startIndex = bufferSize - nPoints;
        for (int i = startIndex; i < bufferSize; i++) {
            int adjustedIndex = i - startIndex;
            float time = -(float)numSeconds + (float)(adjustedIndex)*timeBetweenPoints;
            float filt_uV_value = buffer[channelIndex][i];
            channelPoints.set(adjustedIndex, time, filt_uV_value, "");
        }
        plot.setPoints(channelPoints);

        gplotAutoscaler.update(plot, channelPoints);

        if (gplotAutoscaler.getEnabled()) {
            float[] minMax = gplotAutoscaler.getMinMax();
            customYLim(yAxisMin, (int)minMax[0]);
            customYLim(yAxisMax, (int)minMax[1]);
        }
    }

    public void draw(boolean hardwareSettingsAreOpen) {        

        plot.beginDraw();
        plot.drawBox();
        plot.drawGridLines(GPlot.VERTICAL);
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
        stroke(OPENBCI_BLUE_ALPHA50);
        noFill();
        rect(x,y,w,h);
        popStyle();

        //draw channelBar separator line in the middle of INTER_CHANNEL_BAR_SPACE
        if (!isBottomChannel()) {
            pushStyle();
            stroke(OPENBCI_DARKBLUE);
            strokeWeight(1);
            int separator_y = y + h + int(widgetManager.getTimeSeriesWidget().INTER_CHANNEL_BAR_SPACE / 2);
            line(x, separator_y, x + w, separator_y);
            popStyle();
        }

        //draw impedance values in time series also for each channel
        drawVoltageValue = true;
        if (currentBoard instanceof ImpedanceSettingsBoard) {
            if (((ImpedanceSettingsBoard)currentBoard).isCheckingImpedance(channelIndex)) {
                impValue.draw();
                drawVoltageValue = false;
            }
        }
        
        if (drawVoltageValue) {
            voltageValue.draw();
        }

        try {
            cbCp5.draw();
        } catch (NullPointerException e) {
            e.printStackTrace();
            println("CP5 ERROR ON CHANNEL " + channelIndex);
        }

        yAxisMin.draw();
        yAxisMax.draw();
    }

    private int nPointsBasedOnDataSource() {
        return (numSeconds * currentBoard.getSampleRate()) / getDownsamplingFactor();
    }

    public void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        nPoints = nPointsBasedOnDataSource();
        channelPoints = new GPointsArray(nPoints);
        timeBetweenPoints = (float)numSeconds / (float)nPoints;
        if (_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
        }else{
            plot.getXAxis().setNTicks(10);
        }
        
        updatePlotPoints();
    }

    public void adjustVertScale(int _vertScaleValue) {
        boolean enableAutoscale = _vertScaleValue == 0;
        gplotAutoscaler.setEnabled(enableAutoscale);
        if (enableAutoscale) {
            return;
        }
        yAxisLowerLim = -_vertScaleValue;
        yAxisUpperLim = _vertScaleValue;
        plot.setYLim(yAxisLowerLim, yAxisUpperLim);
        //Update button text
        customYLim(yAxisMin, yAxisLowerLim);
        customYLim(yAxisMax, yAxisUpperLim);
    }

    //Update yAxis text and responsively size Textfield
    private void customYLim(TextBox tb, int limit) {
        StringBuilder s = new StringBuilder(limit > 0 ? "+" : "");
        s.append(limit);
        s.append("uV");
        tb.setText(s.toString());
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

        yAxisMax.setPosition(x + uiSpaceWidth + padding, y + int(padding*1.5) - 2);
        yAxisMin.setPosition(x + uiSpaceWidth + padding, y + h - yAxisLabel_h - padding - 1);
        
        final int yAxisLabelWidth = yAxisMax.getWidth();
        int yScaleButtonX = x + uiSpaceWidth + padding_4;
        int yScaleButtonY = y + h/2 - yScaleButton_h/2;
        boolean enoughSpaceBetweenAxisLabels = h > yScaleButton_h + yAxisLabel_h*2 + 2;
        yScaleButtonX += enoughSpaceBetweenAxisLabels ? 0 : yAxisLabelWidth;
        yScaleButton_neg.setPosition(yScaleButtonX, yScaleButtonY);
        yScaleButtonX += yScaleButton_w + padding;
        yScaleButton_pos.setPosition(yScaleButtonX, yScaleButtonY);

        onOff_diameter = h > 26 ? 26 : h - 2;
        onOffButton.setSize(onOff_diameter, onOff_diameter);
        onOffButton.setPosition(x + 6, y + int(h/2) - int(onOff_diameter/2));
    }

    public void updateCP5(PApplet _parentApplet) {
        cbCp5.setGraphics(_parentApplet, 0, 0);
    }

    private boolean isBottomChannel() {
        int numActiveChannels = widgetManager.getTimeSeriesWidget().tsChanSelect.getActiveChannels().size();
        boolean isLastChannel = channelIndex ==  widgetManager.getTimeSeriesWidget().tsChanSelect.getActiveChannels().get(numActiveChannels - 1);
        return isLastChannel;
    }

    public void mousePressed() {
    }

    public void mouseReleased() {
    }

    private void createOnOffButton(String name, String text, int _x, int _y, int _w, int _h) {
        onOffButton = createButton(cbCp5, name, text, _x, _y, _w, _h, 0, h2, 16, channelColors[channelIndex%8], WHITE, BUTTON_HOVER, BUTTON_PRESSED, (Integer) null, -2);
        onOffButton.setCircularButton(true);
        onOffButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                boolean newState = !currentBoard.isEXGChannelActive(channelIndex);
                println("[" + channelString + "] onOff released - " + (newState ? "On" : "Off"));
                currentBoard.setEXGChannelActive(channelIndex, newState);
                if (currentBoard instanceof ADS1299SettingsBoard) {
                    W_TimeSeries timeSeriesWidget = widgetManager.getTimeSeriesWidget();
                    timeSeriesWidget.adsSettingsController.updateChanSettingsDropdowns(channelIndex, currentBoard.isEXGChannelActive(channelIndex));
                    boolean hasUnappliedChanges = currentBoard.isEXGChannelActive(channelIndex) != newState;
                    timeSeriesWidget.adsSettingsController.setHasUnappliedSettings(channelIndex, hasUnappliedChanges);
                }
            }
        });
        onOffButton.setDescription("Click to toggle channel " + channelString + ".");
    }

    private Button createYScaleButton(int chan, boolean shouldIncrease, String bName, String bText, int _x, int _y, int _w, int _h, PImage _default, PImage _hover, PImage _active) {
        _default.resize(_w, _h);
        _hover.resize(_w, _h);
        _active.resize(_w, _h);
        final Button myButton = cbCp5.addButton(bName)
                .setPosition(_x, _y)
                .setSize(_w, _h)
                .setColorLabel(color(255))
                .setColorForeground(OPENBCI_BLUE)
                .setColorBackground(color(144, 100))
                .setImages(_default, _hover, _active)
                ;
        myButton.onClick(new yScaleButtonCallbackListener(chan, shouldIncrease));
        return myButton;
    }

    private class yScaleButtonCallbackListener implements CallbackListener {
        private int channel;
        private boolean increase;
        private final int hardLimit = 10;
        private int yLimOption = TimeSeriesYLim.UV_200.getValue();
        //private int delta = 0; //value to change limits by

        yScaleButtonCallbackListener(int theChannel, boolean isIncrease)  {
            channel = theChannel;
            increase = isIncrease;
        }
        public void controlEvent(CallbackEvent theEvent) {
            verbosePrint("A button was pressed for channel " + (channel+1) + ". Should we increase (or decrease?): " + increase);

            int inc = increase ? 1 : -1;
            int factor = yAxisUpperLim > 25 || (yAxisUpperLim == 25 && increase) ? 25 : 5;
            int n = (int)(log10(abs(yAxisLowerLim))) * factor * inc;
            yAxisLowerLim -= n;
            n = (int)(log10(yAxisUpperLim)) * factor * inc;
            yAxisUpperLim += n;
            
            yAxisLowerLim = yAxisLowerLim <= -hardLimit ? yAxisLowerLim : -hardLimit;
            yAxisUpperLim = yAxisUpperLim >= hardLimit ? yAxisUpperLim : hardLimit;
            plot.setYLim(yAxisLowerLim, yAxisUpperLim);
            //Update button text
            customYLim(yAxisMin, yAxisLowerLim);
            customYLim(yAxisMax, yAxisUpperLim);
        }
    }
};

//========================================================================================================================
//                                          END OF -- CHANNEL BAR CLASS
//========================================================================================================================


//========================== PLAYBACKSLIDER ==========================
class PlaybackScrollbar {
    private final float ps_Padding = 40.0; //used to make room for skip to start button
    private int x, y, w, h;
    private int swidth, sheight;    // width and height of bar
    private float xpos, ypos;       // x and y position of bar
    private float spos;    // x position of slider
    private float sposMin, sposMax; // max and min values of slider
    private boolean over;           // is the mouse over the slider?
    private boolean locked;
    private ControlP5 pbsb_cp5;
    private Button skipToStartButton;
    private int skipToStart_diameter;
    private String currentAbsoluteTimeToDisplay = "";
    private String currentTimeInSecondsToDisplay = "";
    private FileBoard fileBoard;
    
    private final DateFormat currentTimeFormatShort = new SimpleDateFormat("mm:ss");
    private final DateFormat currentTimeFormatLong = new SimpleDateFormat("HH:mm:ss");
    private final DateFormat timeStampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    PlaybackScrollbar (int _x, int _y, int _w, int _h, float xp, float yp, int sw, int sh) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        swidth = sw;
        sheight = sh;
        xpos = xp + ps_Padding; //lots of padding to make room for button
        ypos = yp-sheight/2;
        spos = xpos;
        sposMin = xpos;
        sposMax = xpos + swidth - sheight/2;

        pbsb_cp5 = new ControlP5(ourApplet);
        pbsb_cp5.setGraphics(ourApplet, 0,0);
        pbsb_cp5.setAutoDraw(false);

        //Let's make a button to return to the start of playback!!
        skipToStart_diameter = 25;
        createSkipToStartButton("skipToStartButton", "", int(xp) + int(skipToStart_diameter*.5), int(yp) + int(sh/2) - skipToStart_diameter, skipToStart_diameter, skipToStart_diameter);

        fileBoard = (FileBoard)currentBoard;
    }

    private void createSkipToStartButton(String name, String text, int _x, int _y, int _w, int _h) {
        skipToStartButton = createButton(pbsb_cp5, name, text, _x, _y, _w, _h, 0, p5, 12, GREY_235, OPENBCI_DARKBLUE, BUTTON_HOVER, BUTTON_PRESSED, (Integer)null, 0);
        PImage defaultImage = loadImage("skipToStart_default-30x26.png");
        skipToStartButton.setImage(defaultImage);
        skipToStartButton.setForceDrawBackground(true);
        skipToStartButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               skipToStartButtonAction();
            }
        });
        skipToStartButton.setDescription("Click to go back to the beginning of the file.");
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
        dataProcessing.updateEntireDownsampledBuffer();
        dataProcessing.clearCalculatedMetricWidgets();
    }

    float getCursorPercentage() {
        return (spos - sposMin) / (sposMax - sposMin);
    }

    String getAbsoluteTimeToDisplay() {
        List<double[]> currentData = currentBoard.getData(1);
        if (currentData.get(0).length == 0) {
            return "";
        }
        int timeStampChan = currentBoard.getTimestampChannel();
        long timestampMS = (long)(currentData.get(0)[timeStampChan] * 1000.0);
        if (timestampMS == 0) {
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
            if (!over) {
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

        fill(GREY_235);
        stroke(OPENBCI_BLUE);
        rect(x, y, w, h);

        //draw the playback slider inside the playback sub-widget
        noStroke();
        fill(GREY_200);
        rect(xpos, ypos, swidth, sheight);

        //select color for playback indicator
        if (over || locked) {
            fill(OPENBCI_DARKBLUE);
        } else {
            fill(102, 102, 102);
        }
        //draws playback position indicator
        rect(spos, ypos, sheight/2, sheight);

        //draw current timestamp and X of Y Seconds above scrollbar
        textFont(p2, 18);
        fill(OPENBCI_DARKBLUE);
        textAlign(LEFT, TOP);
        float textHeight = textAscent() - textDescent();
        float textY = y - textHeight - 10;
        float tw = textWidth(currentAbsoluteTimeToDisplay);
        text(currentAbsoluteTimeToDisplay, xpos + swidth - tw, textY);
        text(currentTimeInSecondsToDisplay, xpos, textY);

        popStyle();

        pbsb_cp5.draw();
    }

    void screenResized(int _x, int _y, int _w, int _h, float _pbx, float _pby, float _pbw, float _pbh) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        swidth = int(_pbw);
        sheight = int(_pbh);
        xpos = _pbx + ps_Padding; //add lots of padding for use
        ypos = _pby - sheight/2;
        sposMin = xpos;
        sposMax = xpos + swidth - sheight/2;
        //update the position of the playback indicator us
        //newspos = updatePos();

        pbsb_cp5.setGraphics(ourApplet, 0, 0);

        skipToStartButton.setPosition(
            int(_pbx) + int(skipToStart_diameter*.5),
            int(_pby) - int(skipToStart_diameter*.5)
            );
    }

    //This function scrubs to the beginning of the playback file
    //Useful to 'reset' the scrollbar before loading a new playback file
    void skipToStartButtonAction() {       
        fileBoard.goToIndex(0);
        dataProcessing.updateEntireDownsampledBuffer();
        dataProcessing.clearCalculatedMetricWidgets();
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
        if (currentBoard.isStreaming()) {
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
            fill(OPENBCI_DARKBLUE);
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
