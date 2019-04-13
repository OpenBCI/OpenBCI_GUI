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
    boolean showHardwareSettings = false;

    Button hardwareSettingsButton;

    ChannelBar[] channelBars;
    PlaybackScrollbar scrollbar;

    int[] xLimOptions = {1, 3, 5, 10, 20}; // number of seconds (x axis of graph)
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

    private boolean hasScrollbar = true; //used to turn playback scrollbar widget on/off
    boolean updateNumberOfChannelBars = false; //used if user selects new playback file using playback widget

    W_timeSeries(PApplet _parent){
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
        tsVertScaleSave = 3;
        tsHorizScaleSave = 2;
        //checkForSuccessTS = 0;

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function

        addDropdown("VertScale_TS", "Vert Scale", Arrays.asList(tsVertScaleArray), tsVertScaleSave);
        addDropdown("Duration", "Window", Arrays.asList(tsHorizScaleArray), tsHorizScaleSave);
        // addDropdown("Spillover", "Spillover", Arrays.asList("False", "True"), 0);

        //Instantiate scrollbar if using playback mode and scrollbar feature in use
        if(eegDataSource == DATASOURCE_PLAYBACKFILE && hasScrollbar){
            playbackWidgetHeight = 50.0;
            pb_x = ts_x - ts_padding/2;
            pb_y = ts_y + ts_h + playbackWidgetHeight + (ts_padding * 3);
            pb_w = wF - ts_padding*4;
            pb_h = playbackWidgetHeight/2;
            //Make a new scrollbar
            scrollbar = new PlaybackScrollbar(int(pb_x), int(pb_y), int(pb_w), int(pb_h), indices);
        } else{
            playbackWidgetHeight = 0.0;
        }

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

            if(eegDataSource == DATASOURCE_PLAYBACKFILE && hasScrollbar){
                //scrub playback file
                scrollbar.update();
            }

            //update the number of channel bars if user has selected a new file using playback widget
            if (updateNumberOfChannelBars) {
                updateNumChannelBars(ourApplet);
            }
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
                fill(0,0,0,20);
                stroke(31,69,110);
                rect(xF, ts_y + ts_h + playbackWidgetHeight + 5, wF, playbackWidgetHeight);
                scrollbar.draw();
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
        } else if (eegDataSource == DATASOURCE_PLAYBACKFILE && hasScrollbar) {
            ///////////////////////////////////////////////////
            ///////////////////////////////////////////////////
            //Resize the playback slider if using playback mode
            pb_x = ts_x - ts_padding/2;
            pb_y = ts_y + ts_h + playbackWidgetHeight + (ts_padding*3);
            pb_w = wF - ts_padding*8;
            pb_h = playbackWidgetHeight/2;
            scrollbar.screenResized(pb_x, pb_y, pb_w, pb_h);
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
                println("HardwareSetingsButton: Toggle...");
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

    //Called when a user selects a new playback file from playback widget
    void updateNumChannelBars(PApplet _parent) {
        //println("NEW NCHAN = " + nchan);
        numChannelBars = nchan;

        //Clear the array that holds the channel bars
        channelBars = null;

        //Create new channel bars
        channelBarHeight = int(ts_h/numChannelBars);

        channelBars = new ChannelBar[numChannelBars];

        //Create our channel bars and populate our channelBars array!
        for(int i = 0; i < numChannelBars; i++){
            int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
            ChannelBar tempBar = new ChannelBar(_parent, i+1, int(ts_x), channelBarY, int(ts_w), channelBarHeight); //int _channelNumber, int _x, int _y, int _w, int _h
            channelBars[i] = tempBar;
        }

        /*
        //this resizes all of the chanel bars
        channelBarHeight = int(ts_h/numChannelBars);

        for(int i = 0; i < numChannelBars; i++){
            int channelBarY = int(ts_y) + i*(channelBarHeight); //iterate through bar locations
            channelBars[i].screenResized(int(ts_x), channelBarY, int(ts_w), channelBarHeight); //bar x, bar y, bar w, bar h
        }
        */

        updateNumberOfChannelBars = false;
    }
};

//These functions are activated when an item from the corresponding dropdown is selected
void VertScale_TS(int n) {
    tsVertScaleSave = n;
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
        w_timeSeries.channelBars[i].adjustVertScale(w_timeSeries.yLimOptions[n]);
    }
    //closeAllDropdowns();
}

//triggered when there is an event in the Duration Dropdown
void Duration(int n) {
    tsHorizScaleSave = n;
    // println("adjust duration to: " + xLimOptions[n]);
    //set time series x axis to the duration selected from dropdown
    int newDuration = w_timeSeries.xLimOptions[tsHorizScaleSave];
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
        w_timeSeries.channelBars[i].adjustTimeAxis(newDuration);
    }
    //If selected by user, sync the duration of Time Series, Accelerometer, and Analog Read(Cyton Only)
    if (accHorizScaleSave == 0) {
        //set accelerometer x axis to the duration selected from dropdown
        w_accelerometer.accelerometerBar.adjustTimeAxis(newDuration);
    }
    if (cyton.getBoardMode() == BOARD_MODE_ANALOG) {
        if (arHorizScaleSave == 0){
            //set analog read x axis to the duration selected from dropdown
            for(int i = 0; i < w_analogRead.numAnalogReadBars; i++){
                w_analogRead.analogReadBars[i].adjustTimeAxis(newDuration);
            }
        }
    }
    //closeAllDropdowns();
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
        onOffButton.setColorNotPressed(channelColors[(channelNumber-1)%8]); //Set channel button background colors
        onOffButton.textColorNotActive = color(255); //Set channel button text to white
        onOffButton.hasStroke(false);

        if(eegDataSource == DATASOURCE_CYTON){
            impButton_diameter = 22;
            impCheckButton = new Button (x + 36, y + int(h/2) - int(impButton_diameter/2), impButton_diameter, impButton_diameter, "\u2126", fontInfo.buttonLabel_size);
            impCheckButton.setFont(h2, 16);
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
                w_timeSeries.hsc.toggleImpedanceCheck(channelNumber);  // 'n' indicates the N inputs and '1' indicates test impedance
                if(drawImpValue){
                    drawImpValue = false;
                    impCheckButton.setColorNotPressed(color(255)); //White background
                    impCheckButton.textColorNotActive = color(0); //Black text
                } else {
                    drawImpValue = true;
                    impCheckButton.setColorNotPressed(color(50)); //Dark background
                    impCheckButton.textColorNotActive = color (255); //White text
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
    int indexStartPosition = 0;
    int indexPosition = indexStartPosition;
    Button skipToStartButton;
    int skipToStart_diameter;
    Boolean indicatorAtStart; //true means the indicator is at index 0
    int clearBufferThreshold = 5;
    float ps_Padding = 50.0; //used to make room for skip to start button

    PlaybackScrollbar (float xp, float yp, int sw, int sh, int is) {
        swidth = sw;
        sheight = sh;
        //float widthtoheight = sw - sh;
        //ratio = (float)sw / widthtoheight;
        xpos = xp + ps_Padding; //lots of padding to make room for button
        ypos = yp-sheight/2;
        spos = xpos;
        newspos = spos;
        sposMin = xpos;
        sposMax = xpos + swidth - sheight/2;
        num_indices = is;
        indicatorAtStart = true;

        //Let's make a button to return to the start of playback!!
        skipToStart_diameter = 30;
        skipToStartButton = new Button (int(xp) + int(skipToStart_diameter*.5), int(yp) + int(sh/2) - skipToStart_diameter, skipToStart_diameter, skipToStart_diameter, "");
        skipToStartButton.setColorNotPressed(color(235)); //Set channel button background colors
        skipToStartButton.hasStroke(false);
        PImage bgImage = loadImage("skipToStart-30x26.png");
        skipToStartButton.setBackgroundImage(bgImage);
    }

    /////////////// Update loop for PlaybackScrollbar
    void update() {
        num_indices = indices;

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
        //if the slider is being used, update new position based on user mouseX
        if (locked) {
            newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
            try {
                clearAllTimeSeriesGPlots();
                clearAllAccelGPlots();
                playbackScrubbing(); //perform scrubbing
            } catch (Exception e) {
                println("PlaybackScrollbar: Error: " + e);
            }
        }

        //if the slider is not being used, let playback control it when (isRunning)
        if (!locked && isRunning){
            //process the file
            if (systemMode == SYSTEMMODE_POSTINIT && !has_processed && !isOldData) {
                lastReadDataPacketInd = 0;
                pointCounter = 0;
                try {
                    process_input_file();
                    ///println("TimeSeriesFileProcessed");
                } catch(Exception e) {
                    isOldData = true;
                    output("###Error processing timestamps, are you using old data?");
                }
            }
            //Set the new position of playback indicator using mapped value
            newspos = updatePos();

            //Print current position to bottom of GUI
            output("Time: " + getCurrentTimeStamp()
            + " --- " + int(float(currentTableRowIndex)/getSampleRateSafe())
            + " seconds" );
        }
        if (abs(newspos - spos) > 1) { //if the slider has been moved
            spos = spos + (newspos-spos); //update position
        }
        if (getIndex() == 0) { //if the current index is 0, the indicator is at start
            indicatorAtStart = true;
        } else {
            indicatorAtStart = false;
        }

        if(mousePressed && skipToStartButton.isMouseHere() && !indicatorAtStart){
            //println("Playback Scrollbar: Skip to start button pressed"); //This does not print!!
            skipToStartButton.setIsActive(true);
            skipToStartButtonAction(); //skip to start
            indicatorAtStart = true;
        } else if (!mousePressed && !skipToStartButton.isMouseHere()) {
            skipToStartButton.setIsActive(false); //set button to not active
        }

    } //end update loop for PlaybackScrollbar

    float constrain(float val, float minv, float maxv) {
        return min(max(val, minv), maxv);
    } //end update loop

    //checks if mouse is over the playback scrollbar
    boolean overEvent() {
        if (mouseX > xpos && mouseX < xpos+swidth &&
            mouseY > ypos && mouseY < ypos+sheight) {
            cursor(HAND); //changes cursor icon to a hand
            return true;
        } else {
            cursor(ARROW);
            return false;
        }
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

        popStyle();
    }

    void screenResized(float _x, float _y, float _w, float _h){
        swidth = int(_w);
        sheight = int(_h);
        xpos = _x + ps_Padding; //add lots of padding for use
        ypos = _y - sheight/2;
        sposMin = xpos;
        sposMax = xpos + swidth - sheight/2;
        //update the position of the playback indicator us
        newspos = updatePos();

        skipToStartButton.setPos(
            int(_x) + int(skipToStart_diameter*.5),
            int(_y) - int(skipToStart_diameter*.5)
            );

    }

    //Fetch index using playback indicator position
    int getIndex(){
        //Divide the width (Max - Min) by the number of indices
        //Store this value for scrollbar step size as a float
        float scrollbarStepSize = (sposMax-sposMin) / num_indices;
        //println("sep val : " + scrollbarStepSize);
        int index_Position = int(getPos());
        int indexCounter;

        //Set index position by finding the playback indicator
        for (indexCounter = 0; indexCounter < num_indices + 1; indexCounter++) {
            if (spos == sposMin) { //Indicator is at the beginning
                indexPosition = 0;
                indicatorAtStart = true;
            }
            //If not at the beginning or the end, use step size from above
            if (index_Position > scrollbarStepSize * indexCounter && index_Position <= scrollbarStepSize * (indexCounter + 1)) {
                indexPosition = indexCounter;
                indicatorAtStart = false;
                //println(">= val: " + (scrollbarStepSize * indexCounter) + " || <= val: " + (scrollbarStepSize * (indexCounter +1)) );
            }
            if (spos == sposMax) { //Indicator is at the end
                indexPosition = num_indices;
                indicatorAtStart = false;
            }
        }

        return indexPosition;
    }

    //Get current position of the playback indicator
    float getPos() {
        //Return the slider position and account for button space
        return spos - ps_Padding;
    }

    //Update the position of the playback indicator during playback
    float updatePos() {
        //Fetch the counter and the max time in Seconds
        int secondCounter = int(float(currentTableRowIndex)/getSampleRateSafe());
        int secondCounterMax = int(float(playbackData_table.getRowCount())/getSampleRateSafe());
        //Map the values to playbackslider min and max
        float m = map(secondCounter, 0, secondCounterMax, sposMin, sposMax);
        //println("mapval_"+m);
        //Returns mapped value to set the new position of playback indicator
        return m;
    }

    ////////////////////////////////////////////////////////////////////////
    //                        PlaybackScrubbing                           //
    // Gets called when the playback slider position is moved by the user //
    // This function should scrub the file using the slider position      //
    void playbackScrubbing() {
        num_indices = indices;
        //println("INDEXES: "+num_indices);
        if(has_processed){
            //This updates Time Series playback position and the value at the top of the GUI in title bar
            currentTableRowIndex = getIndex();
            String[] newTimeStamp = split(index_of_times.get(currentTableRowIndex), '.');
            //If system is stopped, success print detailed position to bottom of GUI
            if (!isRunning) {
                outputSuccess("New Position{ " + getPos() + "/" + sposMax
                + " Index: " + currentTableRowIndex
                + " } --- Time: " + newTimeStamp[0]
                + " --- " + getElapsedTimeInSeconds(currentTableRowIndex)
                + " seconds" );
            }
        }
    }

    //Find times to display for playback position
    String getCurrentTimeStamp() {
        //update the value for the number of indices
        num_indices = indices;
        //return current playback time
        String[] timeStamp = split(curTimestamp, '.');
        return timeStamp[0];
    }

    //This function scrubs to the beginning of the playback file
    //Useful to 'reset' the scrollbar before loading a new playback file
    void skipToStartButtonAction() {
        if (!indicatorAtStart) { //if indicator is not at start
            newspos = sposMin; //move slider to min position
            indexPosition = 0; //set index position to 0
            currentTableRowIndex = 0; //set playback position to 0
            indicatorAtStart = true;

            clearAllTimeSeriesGPlots();
            clearAllAccelGPlots();

            if (!isRunning) { //if the system is not running
                //Success print detailed position to bottom of GUI
                outputSuccess("New Position{ " + getPos() + "/" + sposMax
                + " Index: " + getIndex()
                + " } --- Time: " +  getCurrentTimeStamp()
                + " --- " + getElapsedTimeInSeconds(currentTableRowIndex)
                + " seconds" );
            }
        }
    }// end skipToStartButtonAction
};//end PlaybackScrollbar class

//Used in the above PlaybackScrollbar class
//Also used in OpenBCI_GUI in the app's title bar
int getElapsedTimeInSeconds(int tableRowIndex) {
    String startTime = index_of_times.get(0);
    String currentTime = index_of_times.get(tableRowIndex);
    DateFormat df = new SimpleDateFormat("hh:mm:ss");
    long time1 = 0;
    long time2 = 0;
    try {
        time1 = df.parse(startTime).getTime();
        time2 = df.parse(currentTime).getTime();
    } catch (Exception e) {
    }
    int delta = int((time2 - time1)*0.001);
    return delta;
}

void clearAllTimeSeriesGPlots() {
    dataBuffY_uV = new float[nchan][dataBuffX.length];
    dataBuffY_filtY_uV = new float[nchan][dataBuffX.length];
    for(int i = 0; i < w_timeSeries.numChannelBars; i++){
        for(int j = 0; j < dataBuffY_filtY_uV[i].length; j++) {
            dataBuffY_uV[i][j] = 0.0;
            dataBuffY_filtY_uV[i][j] = 0.0;
        }
        w_timeSeries.channelBars[i].update();
    }
}
