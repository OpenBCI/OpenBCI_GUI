
class W_NovaAux extends Widget {

    //to see all core variables/methods of the Widget class, refer to Widget.pde
    //put your custom variables here...

    private int numAnalogReadBars;
    float xF, yF, wF, hF;
    float arPadding;
    // values for actual time series chart (rectangle encompassing all analogReadBars)
    float ar_x, ar_y, ar_h, ar_w;
    float plotBottomWell;
    float playbackWidgetHeight;
    int analogReadBarHeight;

    AuxReadBar[] analogReadBars;

    int[] xLimOptions = {0, 1, 3, 5, 10, 20}; // number of seconds (x axis of graph)
    int[] yLimOptions = {0, 50, 100, 200, 400, 1000, 10000}; // 0 = Autoscale ... everything else is uV

    private boolean allowSpillover = false;
    private boolean visible = true;
    private boolean updating = true;

    //Initial dropdown settings
    private int arInitialVertScaleIndex = 5;
    private int arInitialHorizScaleIndex = 0;

    //Button analogModeButton;

    W_NovaAux(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //Analog Read settings
        settings.arVertScaleSave = 5; //updates in VertScale_AR()
        settings.arHorizScaleSave = 0; //updates in Duration_AR()

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("VertScale_NovaAux", "Vert Scale", Arrays.asList(settings.arVertScaleArray), arInitialVertScaleIndex);
        addDropdown("Duration_NovaAux", "Window", Arrays.asList(settings.arHorizScaleArray), arInitialHorizScaleIndex);
        // addDropdown("Spillover", "Spillover", Arrays.asList("False", "True"), 0);

        //set number of analog reads
        numAnalogReadBars = 2;

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

        analogReadBars = new AuxReadBar[numAnalogReadBars];

        //create our channel bars and populate our analogReadBars array!
        for(int i = 0; i < numAnalogReadBars; i++) {
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            AuxReadBar tempBar = new AuxReadBar(_parent, i+1, int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //int _channelNumber, int _x, int _y, int _w, int _h
            analogReadBars[i] = tempBar;
            analogReadBars[i].adjustVertScale(yLimOptions[arInitialVertScaleIndex]);
            //sync horiz axis to Time Series by default
            analogReadBars[i].adjustTimeAxis(w_timeSeries.xLimOptions[settings.tsHorizScaleSave]);
        }

        /*
        analogModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 128, navHeight - 6, "ANALOG TOGGLE", 12);
        analogModeButton.setCornerRoundess((int)(navHeight-6));
        analogModeButton.setFont(p5,12);
        analogModeButton.setColorNotPressed(color(57,128,204));
        analogModeButton.textColorNotActive = color(255);
        analogModeButton.hasStroke(false);
        if (selectedProtocol == BoardProtocol.WIFI) {
            analogModeButton.setHelpText("Click this button to activate/deactivate analog read on Cyton pins A5(D11) and A6(D12).");
        } else {
            analogModeButton.setHelpText("Click this button to activate/deactivate analog read on Cyton pins A5(D11), A6(D12) and A7(D13).");
        }
        */
    }

    public boolean isVisible() {
        return visible;
    }
    public boolean isUpdating() {
        return updating;
    }

    public int getNumAnalogReads() {
        return numAnalogReadBars;
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

            //update channel bars ... this means feeding new EEG data into plots
            for(int i = 0; i < numAnalogReadBars; i++) {
                analogReadBars[i].update();
            }

            //ignore top left button interaction when widgetSelector dropdown is active
            //ignoreButtonCheck(analogModeButton);
        }
    }

    void draw() {
        if(visible) {
            super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

            //remember to refer to x,y,w,h which are the positioning variables of the Widget class
            pushStyle();
            //draw channel bars 
            for(int i = 0; i < numAnalogReadBars; i++) {
                analogReadBars[i].draw();
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

        ar_x = xF + arPadding;
        ar_y = yF + (arPadding);
        ar_w = wF - arPadding*2;
        ar_h = hF - playbackWidgetHeight - plotBottomWell - (arPadding*2);
        analogReadBarHeight = int(ar_h/numAnalogReadBars);

        for(int i = 0; i < numAnalogReadBars; i++) {
            int analogReadBarY = int(ar_y) + i*(analogReadBarHeight); //iterate through bar locations
            analogReadBars[i].screenResized(int(ar_x), analogReadBarY, int(ar_w), analogReadBarHeight); //bar x, bar y, bar w, bar h
        }

        // analogModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        /*
        if (analogModeButton.isMouseHere()) {
            analogModeButton.setIsActive(true);
        }
        */
    }

    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        /*
        if(analogModeButton.isActive && analogModeButton.isMouseHere()) {
            // println("analogModeButton...");
            if (!analogBoard.isAnalogActive()) {
                analogBoard.setAnalogActive(true);
                if (selectedProtocol == BoardProtocol.WIFI) {
                    output("Starting to read analog inputs on pin marked A5 (D11) and A6 (D12)");
                } else {
                    output("Starting to read analog inputs on pin marked A5 (D11), A6 (D12) and A7 (D13)");
                }
            } else {
                analogBoard.setAnalogActive(false);
                output("Starting to read accelerometer");
            }
        }
        analogModeButton.setIsActive(false);
        */
    }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void VertScale_NovaAux(int n) {
    //settings.arVertScaleSave = n;
    for(int i = 0; i < w_novaAux.numAnalogReadBars; i++) {
            w_novaAux.analogReadBars[i].adjustVertScale(w_novaAux.yLimOptions[n]);
    }
    //closeAllDropdowns();
}

//triggered when there is an event in the LogLin Dropdown
void Duration_NovaAux(int n) {
    // println("adjust duration to: " + w_analogRead.analogReadBars[i].adjustTimeAxis(n));
    //set analog read x axis to the duration selected from dropdown
    //settings.arHorizScaleSave = n;

    //Sync the duration of Time Series, Accelerometer, and Analog Read(Cyton Only)
    for(int i = 0; i < w_novaAux.numAnalogReadBars; i++) {
        if (n == 0) {
            w_novaAux.analogReadBars[i].adjustTimeAxis(w_novaAux.xLimOptions[settings.tsHorizScaleSave]);
        } else {
            w_novaAux.analogReadBars[i].adjustTimeAxis(w_novaAux.xLimOptions[n]);
        }
    }
    //closeAllDropdowns();
}

//========================================================================================================================
//                      Analog Voltage BAR CLASS -- Implemented by Analog Read Widget Class
//========================================================================================================================
//this class contains the plot and buttons for a single channel of the Time Series widget
//one of these will be created for each channel (4, 8, or 16)
class AuxReadBar{

    int auxValuesPosition;
    String analogInputString;
    int x, y, w, h;
    boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware

    GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    GPointsArray auxReadPoints;
    int nPoints;
    int numSeconds;
    float timeBetweenPoints;
    int bufferSize;

    color channelColor; //color of plot trace

    boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
    int autoScaleYLim = 0;

    TextBox analogValue;
    TextBox analogPin;

    boolean drawAnalogValue;
    int lastProcessedDataPacketInd = 0;

    double[] auxReadData;
    private EDACapableBoard edaBoard;
    private PPGCapableBoard ppgBoard;

    AuxReadBar(PApplet _parent, int auxChanNum, int _x, int _y, int _w, int _h) { // channel number, x/y location, height, width

        auxValuesPosition = auxChanNum;

        analogInputString = str(auxValuesPosition);
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
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().setAxisLabelText("Time (s)");

        nPoints = nPointsBasedOnDataSource(); //max duration 20s
        bufferSize = nPoints;
        auxReadData = new double[nPoints];

        auxReadPoints = new GPointsArray(nPoints);
        timeBetweenPoints = (float)numSeconds / (float)nPoints;

        for (int i = 0; i < bufferSize; i++) {
            float time = -(float)numSeconds + (float)i*timeBetweenPoints;
            float analog_value = 0.0; //0.0 for all points to start
            GPoint tempPoint = new GPoint(time, analog_value);
            auxReadPoints.set(i, tempPoint);
        }

        plot.setPoints(auxReadPoints); //set the plot with 0.0 for all auxReadPoints to start

        analogValue = new TextBox("t", x + 36 + 4 + (w - 36 - 4) - 2, y + h);
        analogValue.textColor = color(bgColor);
        analogValue.alignH = RIGHT;
        // analogValue.alignV = TOP;
        analogValue.drawBackground = true;
        analogValue.backgroundColor = color(255,255,255,125);

        analogPin = new TextBox("Aux" + analogInputString, x+3, y + h);
        analogPin.textColor = color(bgColor);
        analogPin.alignH = CENTER;

        drawAnalogValue = true;
        if (auxValuesPosition == 1) {
            edaBoard = (EDACapableBoard) currentBoard;
        } else if (auxValuesPosition == 2) {
            ppgBoard = (PPGCapableBoard) currentBoard;
        }
    }

    void update() {

        //update the voltage value text string
        float val = 0f;

        //update the voltage values
        //val = hub.validAccelValues[auxValuesPosition];
        analogValue.string = String.format(getFmt(val),val);
        try {
            //println(Arrays.deepToString(edaBoard.getEDAValues()));
            //double[] edaData = edaBoard.getEDAValues()[0];
            //println(edaData);
        } catch (Exception e) {
            //oops
        }
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
            for(int i = 0; i < auxReadData.length - numSamplesToProcess; i++) {
                auxReadData[i] = auxReadData[i + numSamplesToProcess];
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

            //int voltage = dataPacketBuff[lastProcessedDataPacketInd].auxValues[auxValuesPosition];
            double voltage = 0D;
            try {
                if (auxValuesPosition == 1) {
                    voltage = edaBoard.getEDAValues()[0][lastProcessedDataPacketInd];
                } else {
                    voltage = ppgBoard.getPPGValues()[0][lastProcessedDataPacketInd];
                }
            } catch (Exception e) {
                //e.printStackTrace();
            }
            auxReadData[auxReadData.length - numSamplesToProcess + samplesProcessed] = voltage; //<>//

            samplesProcessed++;
        }

        int buffDiff = bufferSize - nPoints;
        if (numSamplesToProcess > 0) {
            for (int i = buffDiff; i < bufferSize; i++) {
                float timey = -(float)numSeconds + (float)(i-buffDiff)*timeBetweenPoints;
                float voltage = (float)auxReadData[i];

                GPoint tempPoint = new GPoint(timey, voltage);
                auxReadPoints.set(i-buffDiff, tempPoint);

            }
            plot.setPoints(auxReadPoints); //reset the plot with updated auxReadPoints
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
        
        if(auxValuesPosition == 2) { //only draw the x axis label on the bottom channel bar
            plot.drawXAxis();
            plot.getXAxis().draw();
        }

        plot.endDraw();

        if(drawAnalogValue) {
            analogValue.draw();
            analogPin.draw();
        }

        popStyle();
    }

    int nPointsBasedOnDataSource() {
        return numSeconds * getSampleRateSafe();
    }

    void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        nPoints = nPointsBasedOnDataSource();

        auxReadPoints = new GPointsArray(nPoints);
        if (_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);  //sets the number of axis divisions...
        }
        else {
            plot.getXAxis().setNTicks(10);
        }
        if (w_analogRead != null) {
            if(w_analogRead.isUpdating()) {
                updatePlotPoints();
            }
        }
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
        if (auxReadPoints.getNPoints() > 0) {
            for(int i = 0; i < nPoints; i++) {
                if(int(abs(auxReadPoints.getY(i))) > autoScaleYLim) {
                    autoScaleYLim = int(abs(auxReadPoints.getY(i)));
                }
            }
        }
        plot.setYLim(-autoScaleYLim, autoScaleYLim);
    }

    void screenResized(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        plot.setPos(x + 36 + 4, y);
        plot.setDim(w - 36 - 4, h);

        analogValue.x = x + 36 + 4 + (w - 36 - 4) - 2;
        analogValue.y = y + h;

        analogPin.x = x + 14;
        analogPin.y = y + int(h/2.0) + 7;
    }
};
