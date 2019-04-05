
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
    float arPadding;
    float ar_x, ar_y, ar_h, ar_w; //values for actual time series chart (rectangle encompassing all analogReadBars)
    float plotBottomWell;
    float playbackWidgetHeight;
    int analogReadBarHeight;

    AnalogReadBar[] analogReadBars;

    int[] xLimOptions = {0, 1, 3, 5, 10, 20}; // number of seconds (x axis of graph)
    int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV

    boolean allowSpillover = false;

    TextBox[] chanValuesMontage;
    boolean showMontageValues;

    private boolean visible = true;
    private boolean updating = true;
    boolean analogReadOn = false;

    int arInitialVertScaleIndex = 5;
    int arInitialHorizScaleIndex = 0;

    private boolean hasScrollbar = false;

    Button analogModeButton;

    W_AnalogRead(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //Analog Read settings
        arVertScaleSave = 5; //updates in VertScale_AR()
        arHorizScaleSave = 0; //updates in Duration_AR()

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("VertScale_AR", "Vert Scale", Arrays.asList(arVertScaleArray), arInitialVertScaleIndex);
        addDropdown("Duration_AR", "Window", Arrays.asList(arHorizScaleArray), arInitialHorizScaleIndex);
        // addDropdown("Spillover", "Spillover", Arrays.asList("False", "True"), 0);

        //set number of analog reads
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
        arPadding = 10.0;
        ar_x = xF + arPadding;
        ar_y = yF + (arPadding);
        ar_w = wF - arPadding*2;
        ar_h = hF - playbackWidgetHeight - plotBottomWell - (arPadding*2);
        analogReadBarHeight = int(ar_h/numAnalogReadBars);

        analogReadBars = new AnalogReadBar[numAnalogReadBars];

        //create our channel bars and populate our analogReadBars array!
        for(int i = 0; i < numAnalogReadBars; i++) {
            println("init analog read bar " + i);
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            AnalogReadBar tempBar = new AnalogReadBar(_parent, i+5, int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //int _channelNumber, int _x, int _y, int _w, int _h
            analogReadBars[i] = tempBar;
            analogReadBars[i].adjustVertScale(yLimOptions[arInitialVertScaleIndex]);
            //sync horiz axis to Time Series by default
            analogReadBars[i].adjustTimeAxis(w_timeSeries.xLimOptions[tsHorizScaleSave]);
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

    void update() {
        if(visible && updating) {
            super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

            //put your code here...
            //update channel bars ... this means feeding new EEG data into plots
            for(int i = 0; i < numAnalogReadBars; i++) {
                analogReadBars[i].update();
            }
        }
    }

    void draw() {
        if(visible) {
            super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

            //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
            pushStyle();
            //draw channel bars
            analogModeButton.draw();
            if (cyton.getBoardMode() != BoardMode.ANALOG) {
                analogModeButton.setString("Turn Analog Read On");
            } else {
                analogModeButton.setString("Turn Analog Read Off");
                for(int i = 0; i < numAnalogReadBars; i++) {
                    analogReadBars[i].draw();
                }
            }
            popStyle();
        }
    }

    void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //put your code here...
        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        ar_x = xF + arPadding;
        ar_y = yF + (arPadding);
        ar_w = wF - arPadding*2;
        ar_h = hF - playbackWidgetHeight - plotBottomWell - (arPadding*2);
        analogReadBarHeight = int(ar_h/numAnalogReadBars);

        for(int i = 0; i < numAnalogReadBars; i++) {
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            analogReadBars[i].screenResized(int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //bar x, bar y, bar w, bar h
        }

        analogModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        if (analogModeButton.isMouseHere()) {
            analogModeButton.setIsActive(true);
        }
    }

    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        //put your code here...
        if(analogModeButton.isActive && analogModeButton.isMouseHere()) {
            // println("analogModeButton...");
            if(cyton.isPortOpen()) {
                if (cyton.getBoardMode() != BoardMode.ANALOG) {
                    cyton.setBoardMode(BoardMode.ANALOG);
                    if (cyton.isWifi()) {
                        output("Starting to read analog inputs on pin marked A5 (D11) and A6 (D12)");
                    } else {
                        output("Starting to read analog inputs on pin marked A5 (D11), A6 (D12) and A7 (D13)");
                    }
                    w_accelerometer.accelerometerModeOn = false;
                    w_digitalRead.digitalReadOn = false;
                    w_markermode.markerModeOn = false;
                    w_pulsesensor.analogReadOn = true;
                } else {
                    cyton.setBoardMode(BoardMode.DEFAULT);
                    output("Starting to read accelerometer");
                    w_accelerometer.accelerometerModeOn = true;
                }
                analogReadOn = !analogReadOn;
            }
        }
        analogModeButton.setIsActive(false);
    }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void VertScale_AR(int n) {
    arVertScaleSave = n;
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++) {
            w_analogRead.analogReadBars[i].adjustVertScale(w_analogRead.yLimOptions[n]);
    }
    //closeAllDropdowns();
}

//triggered when there is an event in the LogLin Dropdown
void Duration_AR(int n) {
    // println("adjust duration to: " + w_analogRead.analogReadBars[i].adjustTimeAxis(n));
    //set analog read x axis to the duration selected from dropdown
    arHorizScaleSave = n;

    //Sync the duration of Time Series, Accelerometer, and Analog Read(Cyton Only)
    for(int i = 0; i < w_analogRead.numAnalogReadBars; i++) {
        if (n == 0) {
            w_analogRead.analogReadBars[i].adjustTimeAxis(w_timeSeries.xLimOptions[tsHorizScaleSave]);
        } else {
            w_analogRead.analogReadBars[i].adjustTimeAxis(w_analogRead.xLimOptions[n]);
        }
    }
    //closeAllDropdowns();
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
    int arBuffSize;

    color channelColor; //color of plot trace

    boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
    int autoScaleYLim = 0;

    TextBox analogValue;
    TextBox analogPin;
    TextBox digitalPin;

    boolean drawAnalogValue;
    int lastProcessedDataPacketInd = 0;

    int[] analogReadData;

    AnalogReadBar(PApplet _parent, int _analogInputPin, int _x, int _y, int _w, int _h) { // channel number, x/y location, height, width

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

        numSeconds = 20;
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
            if(auxValuesPosition == 1) {
                plot.getXAxis().setAxisLabelText("Time (s)");
            }
        } else {
            if(auxValuesPosition == 2) {
                plot.getXAxis().setAxisLabelText("Time (s)");
            }
        }

        nPoints = nPointsBasedOnDataSource(); //max duration 20s
        arBuffSize = nPoints;
        analogReadData = new int[nPoints];

        analogReadPoints = new GPointsArray(nPoints);
        timeBetweenPoints = (float)numSeconds / (float)nPoints;

        for (int i = 0; i < arBuffSize; i++) {
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

    void update() {

        //update the voltage value text string
        String fmt; float val;

        //update the voltage values
        val = hub.validAccelValues[auxValuesPosition];
        analogValue.string = String.format(getFmt(val),val);

        // update data in plot
        updatePlotPoints();
        if(isAutoscale) {
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

    void updatePlotPoints() {
        // update data in plot
        int numSamplesToProcess = curDataPacketInd - lastProcessedDataPacketInd;
        if (numSamplesToProcess < 0) {
            numSamplesToProcess += dataPacketBuff.length;
        }

        // Shift internal ring buffer numSamplesToProcess
        if (numSamplesToProcess > 0) {
            for(int i = 0; i < analogReadData.length - numSamplesToProcess; i++) {
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

            analogReadData[analogReadData.length - numSamplesToProcess + samplesProcessed] = voltage; //<>//

            samplesProcessed++;
        }

        int arBuffDiff = arBuffSize - nPoints;
        if (numSamplesToProcess > 0) {
            for (int i = arBuffDiff; i < arBuffSize; i++) {
                float timey = -(float)numSeconds + (float)(i-arBuffDiff)*timeBetweenPoints;
                float voltage = analogReadData[i];

                GPoint tempPoint = new GPoint(timey, voltage);
                analogReadPoints.set(i-arBuffDiff, tempPoint);

            }
            plot.setPoints(analogReadPoints); //reset the plot with updated analogReadPoints
        }
    }

    void draw() {
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
            if(auxValuesPosition == 1) { //only draw the x axis label on the bottom channel bar
                plot.drawXAxis();
                plot.getXAxis().draw();
            }
        } else {
            if(auxValuesPosition == 2) { //only draw the x axis label on the bottom channel bar
                plot.drawXAxis();
                plot.getXAxis().draw();
            }
        }

        plot.endDraw();

        if(drawAnalogValue) {
            analogValue.draw();
            analogPin.draw();
            digitalPin.draw();
        }

        popStyle();
    }

    int nPointsBasedOnDataSource() {
        return numSeconds * (int)getSampleRateSafe();
    }

    void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        nPoints = nPointsBasedOnDataSource();

        analogReadPoints = new GPointsArray(nPoints);
        if(_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
        }else{
            plot.getXAxis().setNTicks(10);
        }
        if (w_analogRead != null) {
            if(w_analogRead.isUpdating()) {
                updatePlotPoints();
            }
        }
        // println("New X axis = " + _newTimeSize);
        //closeAllDropdowns();
    }

    void adjustVertScale(int _vertScaleValue) {
        if(_vertScaleValue == 0) {
            isAutoscale = true;
        } else {
            isAutoscale = false;
            plot.setYLim(-_vertScaleValue, _vertScaleValue);
        }
        //closeAllDropdowns();
    }

    void autoScale() {
        autoScaleYLim = 0;
        for(int i = 0; i < nPoints; i++) {
            if(int(abs(analogReadPoints.getY(i))) > autoScaleYLim) {
                autoScaleYLim = int(abs(analogReadPoints.getY(i)));
            }
        }
        plot.setYLim(-autoScaleYLim, autoScaleYLim);
    }

    void screenResized(int _x, int _y, int _w, int _h) {
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
