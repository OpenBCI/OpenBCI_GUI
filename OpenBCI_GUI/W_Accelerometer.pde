
////////////////////////////////////////////////////
//
// W_Accelerometer is used to visualize accelerometer data
//
// Created: Joel Murphy
// Modified: Colin Fausnaught, September 2016
// Modified: Wangshu Sun, November 2016
// Modified: Richard Waltman, November 2018
//
//
////////////////////////////////////////////////////

//Use the same colors for X,Y,Z throughout Accelerometer widget
final color ACCEL_X_COLOR = color(224, 56, 45);
final color ACCEL_Y_COLOR = color(49, 113, 89);
final color ACCEL_Z_COLOR = color(54, 87, 158);


class W_Accelerometer extends Widget {
    //To see all core variables/methods of the Widget class, refer to Widget.pde
    color graphStroke = color(210);
    color graphBG = color(245);
    color textColor = color(0);
    color strokeColor = color(138, 146, 153);
    color eggshell = color(255, 253, 248);

    //Graphing variables
    int[] xLimOptions = {0, 1, 3, 5, 10, 20}; //number of seconds (x axis of graph)
    int[] yLimOptions = {0, 1, 2, 4};
    float accelXyzLimit = 4.0; //hard limit on all accel values
    int accelHorizLimit = 20;
    float[] lastAccelVals;
    AccelerometerBar accelerometerBar;

    //Bottom xyz graph
    int accelGraphWidth;
    int accelGraphHeight;
    int accelGraphX;
    int accelGraphY;
    int accPadding = 30;

    //Circular 3d xyz graph
    float polarWindowX;
    float polarWindowY;
    int polarWindowWidth;
    int polarWindowHeight;
    float polarCorner;

    float yMaxMin;

    private boolean visible = true;
    private boolean updating = true;
    boolean accelInitHasOccured = false;
    private Button_obci accelModeButton;

    private AccelerometerCapableBoard accelBoard;

    W_Accelerometer(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)
        
        accelBoard = (AccelerometerCapableBoard)currentBoard;

        //Default dropdown settings
        settings.accVertScaleSave = 0;
        settings.accHorizScaleSave = 0;

        //Make dropdowns
        addDropdown("accelVertScale", "Vert Scale", Arrays.asList(settings.accVertScaleArray), settings.accVertScaleSave);
        addDropdown("accelDuration", "Window", Arrays.asList(settings.accHorizScaleArray), settings.accHorizScaleSave);

        setGraphDimensions();
        yMaxMin = adjustYMaxMinBasedOnSource();

        //XYZ buffer for bottom graph
        lastAccelVals = new float[NUM_ACCEL_DIMS];

        //create our channel bar and populate our accelerometerBar array!
        accelerometerBar = new AccelerometerBar(_parent, accelXyzLimit, accelGraphX, accelGraphY, accelGraphWidth, accelGraphHeight);
        accelerometerBar.adjustTimeAxis(w_timeSeries.xLimOptions[settings.tsHorizScaleSave]); //sync horiz axis to Time Series by default

        accelModeButton = new Button_obci((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "", 12);
        accelModeButton.setCornerRoundess((int)(navHeight-6));
        accelModeButton.setFont(p5,12);
        accelModeButton.setColorNotPressed(color(57,128,204));
        accelModeButton.textColorNotActive = color(255);
        accelModeButton.hasStroke(false);
        accelModeButton.setHelpText("Click to activate/deactivate the accelerometer!");
    }

    float adjustYMaxMinBasedOnSource() {
        float _yMaxMin;
        if (eegDataSource == DATASOURCE_CYTON) {
            _yMaxMin = 4.0;
        }else if (eegDataSource == DATASOURCE_GANGLION || nchan == 4) {
            _yMaxMin = 2.0;
            accelXyzLimit = 2.0;
        }else{
            _yMaxMin = 4.0;
        }
        return _yMaxMin;
    }

    int nPointsBasedOnDataSource() {
        return accelHorizLimit * currentBoard.getSampleRate();
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
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        if (visible && updating && accelBoard.isAccelerometerActive()) {
            //update the line graph and corresponding gplot points
            accelerometerBar.update();

            //update the current Accelerometer values
            lastAccelVals = accelerometerBar.getLastAccelVals();
        }
    }

    public float getLastAccelVal(int val) {
        return lastAccelVals[val];
    }

    String getButtonString() {
        if (accelBoard.isAccelerometerActive()) {
            return "Turn Accel. Off";
        }
        else {
            return "Turn Accel. On";
        }
    }

    void draw() {
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        pushStyle();

        fill(50);
        textFont(p4, 14);
        textAlign(CENTER,CENTER);
        text("z", polarWindowX, (polarWindowY-polarWindowHeight/2)-12);
        text("x", (polarWindowX+polarWindowWidth/2)+8, polarWindowY-5);
        text("y", (polarWindowX+polarCorner)+10, (polarWindowY-polarCorner)-10);

        fill(graphBG);  //pulse window background
        stroke(graphStroke);
        ellipse(polarWindowX,polarWindowY,polarWindowWidth,polarWindowHeight);

        stroke(180);
        line(polarWindowX-polarWindowWidth/2, polarWindowY, polarWindowX+polarWindowWidth/2, polarWindowY);
        line(polarWindowX, polarWindowY-polarWindowHeight/2, polarWindowX, polarWindowY+polarWindowHeight/2);
        line(polarWindowX-polarCorner, polarWindowY+polarCorner, polarWindowX+polarCorner, polarWindowY-polarCorner);

        fill(50);
        textFont(p3, 16);
        accelModeButton.setString(getButtonString());

        if (eegDataSource == DATASOURCE_CYTON || eegDataSource == DATASOURCE_GANGLION) {
            accelModeButton.draw();
        }

        if (accelBoard.isAccelerometerActive()) {
            drawAccValues();
            draw3DGraph();
            accelerometerBar.draw();
        }
        popStyle();
    }

    void setGraphDimensions() {
        accelGraphWidth = w - accPadding*2;
        accelGraphHeight = int((float(h) - float(accPadding*3))/2.0);
        accelGraphX = x + accPadding/3;
        accelGraphY = y + h - accelGraphHeight - int(accPadding*2) + accPadding/6;

        polarWindowWidth = accelGraphHeight;
        polarWindowHeight = accelGraphHeight;
        polarWindowX = x + w - accPadding - polarWindowWidth/2;
        polarWindowY = y + accPadding + polarWindowHeight/2 - 10;
        polarCorner = (sqrt(2)*polarWindowWidth/2)/2;
    }

    void screenResized() {
        int prevX = x;
        int prevY = y;
        int prevW = w;
        int prevH = h;
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)
        setGraphDimensions();
        //resize the accelerometer line graph
        accelerometerBar.screenResized(accelGraphX, accelGraphY, accelGraphWidth-accPadding*2, accelGraphHeight); //bar x, bar y, bar w, bar h
        //update the position of the accel mode button
        accelModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        if (eegDataSource == DATASOURCE_CYTON || eegDataSource == DATASOURCE_GANGLION) {
            if (accelModeButton.isMouseHere()) {
                accelModeButton.setIsActive(true);
            }
        }
    }

    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        if (eegDataSource == DATASOURCE_CYTON || eegDataSource == DATASOURCE_GANGLION) {
            //TODO[brainflow]
            if (accelModeButton.isActive && accelModeButton.isMouseHere()) {
                if (!accelBoard.isAccelerometerActive()) {
                    accelBoard.setAccelerometerActive(true);
                    output("Starting to read accelerometer");
                } else {                    
                    accelBoard.setAccelerometerActive(false);
                }
            }
            accelModeButton.setIsActive(false);
        }
    }

    //Draw the current accelerometer values as text
    void drawAccValues() {
        float displayX = (float)lastAccelVals[0];
        float displayY = (float)lastAccelVals[1];
        float displayZ = (float)lastAccelVals[2];
        textAlign(LEFT,CENTER);
        textFont(h1,20);
        fill(ACCEL_X_COLOR);
        text("X = " + nf(displayX, 1, 3) + " g", x+accPadding , y + (h/12)*1.5 - 5);
        fill(ACCEL_Y_COLOR);
        text("Y = " + nf(displayY, 1, 3) + " g", x+accPadding, y + (h/12)*3 - 5);
        fill(ACCEL_Z_COLOR);
        text("Z = " + nf(displayZ, 1, 3) + " g", x+accPadding, y + (h/12)*4.5 - 5);
    }

    //Draw the current accelerometer values as a 3D graph
    void draw3DGraph() {
        float displayX = (float)lastAccelVals[0];
        float displayY = (float)lastAccelVals[1];
        float displayZ = (float)lastAccelVals[2];

        noFill();
        strokeWeight(3);
        stroke(ACCEL_X_COLOR);
        line(polarWindowX, polarWindowY, polarWindowX+map(displayX, -yMaxMin, yMaxMin, -polarWindowWidth/2, polarWindowWidth/2), polarWindowY);
        stroke(ACCEL_Y_COLOR);
        line(polarWindowX, polarWindowY, polarWindowX+map((sqrt(2)*displayY/2), -yMaxMin, yMaxMin, -polarWindowWidth/2, polarWindowWidth/2), polarWindowY+map((sqrt(2)*displayY/2), -yMaxMin, yMaxMin, polarWindowWidth/2, -polarWindowWidth/2));
        stroke(ACCEL_Z_COLOR);
        line(polarWindowX, polarWindowY, polarWindowX, polarWindowY+map(displayZ, -yMaxMin, yMaxMin, polarWindowWidth/2, -polarWindowWidth/2));
        strokeWeight(1);
    }

};//end W_Accelerometer class

//These functions are activated when an item from the corresponding dropdown is selected
void accelVertScale(int n) {
    settings.accVertScaleSave = n;
    w_accelerometer.accelerometerBar.adjustVertScale(w_accelerometer.yLimOptions[n]);
    closeAllDropdowns();
}

//triggered when there is an event in the Duration Dropdown
void accelDuration(int n) {
    settings.accHorizScaleSave = n;

    //Sync the duration of Time Series, Accelerometer, and Analog Read(Cyton Only)
    if (n == 0) {
        w_accelerometer.accelerometerBar.adjustTimeAxis(w_timeSeries.xLimOptions[settings.tsHorizScaleSave]);
    } else {
        //set accelerometer x axis to the duration selected from dropdown
        w_accelerometer.accelerometerBar.adjustTimeAxis(w_accelerometer.xLimOptions[n]);
    }
    closeAllDropdowns();
}

//========================================================================================================================
//                     Accelerometer Graph Class -- Implemented by Accelerometer Widget Class
//========================================================================================================================
class AccelerometerBar {
    //this class contains the plot for the 2d graph of accelerometer data
    int x, y, w, h;
    boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware
    int accBarPadding = 30;
    int xOffset;

    GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
    GPointsArray accelPointsX;
    GPointsArray accelPointsY;
    GPointsArray accelPointsZ;

    int nPoints;
    int numSeconds = 20; //default to 20 seconds
    float timeBetweenPoints;
    float[] accelTimeArray;
    int numSamplesToProcess;
    float minX, minY, minZ;
    float maxX, maxY, maxZ;
    float minVal;
    float maxVal;
    final float autoScaleSpacing = 0.1;

    color channelColor; //color of plot trace

    boolean isAutoscale; //when isAutoscale equals true, the y-axis will automatically update to scale to the largest visible amplitude
    int lastProcessedDataPacketInd = 0;
    
    private AccelerometerCapableBoard accelBoard;

    AccelerometerBar(PApplet _parent, float accelXyzLimit, int _x, int _y, int _w, int _h) { //channel number, x/y location, height, width
        
        // This widget is only instantiated when the board is accel capable, so we don't need to check
        accelBoard = (AccelerometerCapableBoard)currentBoard;
        isOn = true;

        x = _x;
        y = _y;
        w = _w;
        h = _h;
        if (eegDataSource == DATASOURCE_CYTON) {
            xOffset = 22;
        } else {
            xOffset = 0;
        }

        plot = new GPlot(_parent);
        plot.setPos(x + 36 + 4 + xOffset, y); //match Accelerometer plot position with Time Series
        plot.setDim(w - 36 - 4 - xOffset, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[(NUM_ACCEL_DIMS)%8]);
        plot.setXLim(-numSeconds,0); //set the horizontal scale
        plot.setYLim(-accelXyzLimit, accelXyzLimit); //change this to adjust vertical scale
        //plot.setPointSize(2);
        plot.setPointColor(0);
        plot.getXAxis().setAxisLabelText("Time (s)");
        plot.getYAxis().setAxisLabelText("Acceleration (g)");
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().getAxisLabel().setOffset(float(accBarPadding));
        plot.getYAxis().getAxisLabel().setOffset(float(accBarPadding));

        initArrays();

        //set the plot points for X, Y, and Z axes
        plot.addLayer("layer 1", accelPointsX);
        plot.getLayer("layer 1").setLineColor(ACCEL_X_COLOR);
        plot.addLayer("layer 2", accelPointsY);
        plot.getLayer("layer 2").setLineColor(ACCEL_Y_COLOR);
        plot.addLayer("layer 3", accelPointsZ);
        plot.getLayer("layer 3").setLineColor(ACCEL_Z_COLOR);
    }

    void initArrays() {
        nPoints = nPointsBasedOnDataSource();
        timeBetweenPoints = (float)numSeconds / (float)nPoints;

        accelTimeArray = new float[nPoints];
        for (int i = 0; i < accelTimeArray.length; i++) {
            accelTimeArray[i] = -(float)numSeconds + (float)i * timeBetweenPoints;
        }

        float[] accelArrayX = new float[nPoints];
        float[] accelArrayY = new float[nPoints];
        float[] accelArrayZ = new float[nPoints];

        //make a GPoint array using float arrays x[] and y[] instead of plain index points
        accelPointsX = new GPointsArray(accelTimeArray, accelArrayX);
        accelPointsY = new GPointsArray(accelTimeArray, accelArrayY);
        accelPointsZ = new GPointsArray(accelTimeArray, accelArrayZ);
    }

    //Used to update the accelerometerBar class
    void update() {
        updateGPlotPoints();

        if (isAutoscale) {
            autoScale();
        }
    }

    void draw() {
        pushStyle();
        plot.beginDraw();
        plot.drawBox(); //we won't draw this eventually ...
        plot.drawGridLines(2);
        plot.drawLines(); //Draw a Line graph!
        //plot.drawPoints(); //Used to draw Points instead of Lines
        plot.drawYAxis();
        plot.drawXAxis();
        plot.getXAxis().draw();
        plot.endDraw();
        popStyle();
    }

    int nPointsBasedOnDataSource() {
        return numSeconds * currentBoard.getSampleRate();
    }

    void adjustTimeAxis(int _newTimeSize) {
        numSeconds = _newTimeSize;
        plot.setXLim(-_newTimeSize,0);

        initArrays();

        //Set the number of axis divisions...
        if (_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);
        }else{
            plot.getXAxis().setNTicks(10);
        }
    }

    //Used to update the Points within the graph
    void updateGPlotPoints() {
        List<double[]> allData = currentBoard.getData(nPoints);
        int[] accelChannels = accelBoard.getAccelerometerChannels();

        for (int i=0; i < nPoints; i++) {
            accelPointsX.set(i, accelTimeArray[i], (float)allData.get(i)[accelChannels[0]], "");
            accelPointsY.set(i, accelTimeArray[i], (float)allData.get(i)[accelChannels[1]], "");
            accelPointsZ.set(i, accelTimeArray[i], (float)allData.get(i)[accelChannels[2]], "");
        }

        plot.setPoints(accelPointsX, "layer 1");
        plot.setPoints(accelPointsY, "layer 2");
        plot.setPoints(accelPointsZ, "layer 3");
    }

    float[] getLastAccelVals() {
        float[] result = new float[NUM_ACCEL_DIMS];
        result[0] = accelPointsX.getY(nPoints-1);   
        result[1] = accelPointsY.getY(nPoints-1);   
        result[2] = accelPointsZ.getY(nPoints-1);   

        return result;
    }

    void adjustVertScale(int _vertScaleValue) {
        if (_vertScaleValue == 0) {
            isAutoscale = true;
        } else {
            isAutoscale = false;
            plot.setYLim(-_vertScaleValue, _vertScaleValue);
        }
    }

    void autoScale() {
        float[] minMaxVals = minMax(accelPointsX, accelPointsY, accelPointsZ);
        plot.setYLim(minMaxVals[0] - autoScaleSpacing, minMaxVals[1] + autoScaleSpacing);
    }

    float[] minMax(GPointsArray arrX, GPointsArray arrY, GPointsArray arrZ) {
        float[] minMaxVals = {0.f, 0.f};
        for (int i = 0; i < arrX.getNPoints(); i++) { //go through the XYZ GPpointArrays for on-screen values
            float[] vals = {arrX.getY(i), arrY.getY(i), arrZ.getY(i)};
            minMaxVals[0] = min(minMaxVals[0], min(vals)); //make room to see
            minMaxVals[1] = max(minMaxVals[1], max(vals));
        }
        return minMaxVals;
    }

    void screenResized(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w+100;
        h = _h;
        //reposition & resize the plot
        plot.setPos(x + 36 + 4 + xOffset, y);
        plot.setDim(w - 36 - 4 - xOffset, h);

    }
}; //end of class
