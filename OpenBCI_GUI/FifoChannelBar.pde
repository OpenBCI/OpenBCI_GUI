//Reusable class to display data over time with built-in FIFO buffer
//Works with data that is calculated by the GUI each frame, then fed to this class.
class FifoChannelBar {
    private int x, y, w, h;
    private int xOffset;
    
    private GPlot plot;
    private float barXAxisLabelPadding = 22;
    private float barYAxisLabelPadding = 30;
    private boolean showXAxis = true;

    private int layerCount = 1;
    private CircularFIFODataBuffer fifoBuffer;
    private CircularFIFODataBuffer fifoTimeBuffer;
    private float lastTimerValue;
    private int samplingRate;
    private int totalBufferSeconds;
    private int totalBufferPoints;
    private int windowSeconds;
    private int windowPointsCount;
    private float timeBetweenPoints;
    private boolean isOpenness = false;

    private TextBox valueTextBox;

    private GPlotAutoscaler gplotAutoscaler = new GPlotAutoscaler();

    FifoChannelBar(PApplet _parentApplet, String yAxisLabel, int xLimit, float yLimit, int _x, int _y, int _w, int _h, color lineColor, int _layerCount, int _samplingRate, int _totalBufferSeconds) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        totalBufferSeconds = _totalBufferSeconds;
        totalBufferPoints = totalBufferSeconds * _samplingRate;
        windowSeconds = xLimit;
        samplingRate = _samplingRate;
        windowPointsCount = windowSeconds * samplingRate;
        timeBetweenPoints = windowSeconds / windowPointsCount;
        layerCount = _layerCount;

        if (yAxisLabel.equals("Openness")) {
            isOpenness = true;
        }

        plot = new GPlot(_parentApplet);
        plot.setPos(x + 36 + 4 + xOffset, y);
        plot.setDim(w - 36 - 4 - xOffset, h);
        plot.setMar(0f, 0f, 0f, 0f);
        plot.setLineColor((int)channelColors[(NUM_ACCEL_DIMS)%8]);
        plot.setXLim(-windowSeconds,0); //horizontal scale
        plot.setYLim(0, yLimit); //vertical scale
        plot.setPointColor(0);
        plot.getXAxis().setAxisLabelText("Time (s)");
        plot.getYAxis().setAxisLabelText(yAxisLabel);
        plot.setAllFontProperties("Arial", 0, 14);
        plot.getXAxis().getAxisLabel().setOffset(barXAxisLabelPadding);
        plot.getYAxis().getAxisLabel().setOffset(barYAxisLabelPadding);
        plot.getXAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getXAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getXAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);
        plot.getYAxis().setFontColor(OPENBCI_DARKBLUE);
        plot.getYAxis().setLineColor(OPENBCI_DARKBLUE);
        plot.getYAxis().getAxisLabel().setFontColor(OPENBCI_DARKBLUE);

        adjustTimeAxis(windowSeconds);

        initArrays();

        initLayers();

        valueTextBox = new TextBox("t", x + 36 + 4 + (w - 36 - 4) - 2, y + h);
        valueTextBox.textColor = OPENBCI_DARKBLUE;
        valueTextBox.alignH = RIGHT;
        valueTextBox.drawBackground = true;
        valueTextBox.backgroundColor = color(255,255,255,125);
        valueTextBox.string = "0";
        valueTextBox.setVisible(false);
    }

    FifoChannelBar(PApplet _parentApplet, String yAxisLabel, int xLimit, int _x, int _y, int _w, int _h, color lineColor, int layerCount, int _totalBufferSeconds) {
        this(_parentApplet, yAxisLabel, xLimit, 1, _x, _y, _w, _h, lineColor, layerCount, 200, _totalBufferSeconds);
    }

    FifoChannelBar(PApplet _parentApplet, String yAxisLabel, int xLimit, float yLimit, int _x, int _y, int _w, int _h, color lineColor, int _totalBufferSeconds) {
        this(_parentApplet, yAxisLabel, xLimit, yLimit, _x, _y, _w, _h, lineColor, 1, 200, _totalBufferSeconds);
    }

    private void initArrays() {
        fifoBuffer = new CircularFIFODataBuffer(layerCount, totalBufferPoints);
        fifoTimeBuffer = new CircularFIFODataBuffer(layerCount, totalBufferPoints);
    }

    public void initLayers() {
        for (int i = 0; i < layerCount; i++) {
            plot.addLayer("layer" + (i + 1), new GPointsArray(windowPointsCount - 1));
            plot.getLayer("layer" + (i + 1)).setLineColor((int)channelColors[(i + 4) % 8]);
        }
    }

    public void update(double value) {
        update((float)value);
    }

    public void update(int value) {
        update((float)value);
    }

    public void update(float value) {
        resetTimer();
        addLastToFifo(0, value, lastTimerValue);
        GPointsArray[] pointsArrays = updateGPlot();
        gplotAutoscaler.update(plot, pointsArrays);
    }

    public void updateUsingPrecision(float value) {
        resetTimer();
        addLastToFifo(0, value, lastTimerValue);
        GPointsArray[] pointsArrays = updateGPlot();
        gplotAutoscaler.updatePrecise(plot, pointsArrays);
    }

    public void update(float[] values) {
        resetTimer();
        for (int i = 0; i < values.length; i++) {
            addLastToFifo(i, values[i], lastTimerValue);
        }
        GPointsArray[] pointsArrays = updateGPlot();
        gplotAutoscaler.update(plot, pointsArrays);
    }

    public void updateFifo(float[] values) {
        resetTimer();
        for (int i = 0; i < values.length; i++) {
            addLastToFifo(i, values[i], lastTimerValue);
        }
    }

    private void addLastToFifo(int layer, float value, float time) {
        fifoBuffer.add(layer, value);
        fifoTimeBuffer.add(layer, time);
    }

    public void clear() {
        initArrays();
        resetTimer();
        GPointsArray[] pointsArrays = updateGPlot();
        gplotAutoscaler.update(plot, pointsArrays);
    }

    public void resetTimer() {
        lastTimerValue = (float)millis() / 1000f;
    }

    public void draw() {
        plot.beginDraw();
        plot.drawBox();
        plot.drawGridLines(GPlot.BOTH);
        plot.drawLines(); //Draw a Line graph!
        plot.drawYAxis();
        if (showXAxis) {
            plot.drawXAxis();
            plot.getXAxis().draw();
        }
        plot.endDraw();

        valueTextBox.draw();
    }

    public void screenResized(int _x, int _y, int _w, int _h) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        //reposition & resize the plot
        plot.setPos(x + 36 + 4 + xOffset, y);
        plot.setDim(w - 36 - 4 - xOffset, h);
        valueTextBox.x = x + 36 + 4 + (w - 36 - 4) - 2;
        valueTextBox.y = y + h;
    }

    //Used to update the Points within the graph using the FIFO buffer in this class
    private GPointsArray[] updateGPlot() {
        float[][] timeData = fifoTimeBuffer.getBuffer(windowPointsCount);
        float[][] data = fifoBuffer.getBuffer(windowPointsCount);

        int stopId = 0;
        for (stopId = windowPointsCount - 1; stopId > 0; stopId--) {
            if (lastTimerValue - timeData[0][stopId] > windowSeconds) {
                break;
            }
        }

        GPointsArray[] pointsArrays = new GPointsArray[data.length];
        for (int layer = 0; layer < data.length; layer++) {
            pointsArrays[layer] = updateGPlotPoints(layer, data[layer], timeData[layer]);
        }
        return pointsArrays;
    }

    private GPointsArray updateGPlotPoints(int layer, float[] data, float[] timeData) {
        int stopId = 0;
        for (stopId = windowPointsCount - 1; stopId > 0; stopId--) {
            if (lastTimerValue - timeData[stopId] > windowSeconds) {
                break;
            }
        }
        
        int size = windowPointsCount - 1 - stopId;
        
        GPointsArray pointsArray = new GPointsArray(size);
        for (int i = 0; i < size; i++) {
            int dataIndex = i + stopId;
            float _x = timeData[dataIndex] - lastTimerValue;
            float _y = data[dataIndex];
            pointsArray.set(i, _x, _y, "");
        }
        plot.setPoints(pointsArray, "layer" + (layer + 1));
        return pointsArray;
    }

    //Update GPlot with external data and bypass the FIFO buffer in this class
    public void updateGPlotPointsExternal(float[][] data) {
        gplotAutoscaler.resetMinMax();
        GPointsArray[] pointsArrays = new GPointsArray[data.length];
        for (int layer = 0; layer < data.length; layer++) {
            pointsArrays[layer] = new GPointsArray(data[layer].length);
            for (int i = 0; i < data[layer].length; i++) {
                float _x = -(float)windowSeconds + (float)(i * timeBetweenPoints);
                float _y = data[layer][i];
                GPoint tempPoint = new GPoint(_x, _y);
                pointsArrays[layer].set(i, tempPoint);
            }
            plot.setPoints(pointsArrays[layer], "layer" + (layer + 1));
        }
        gplotAutoscaler.update(plot, pointsArrays);
    }
    

    public void adjustTimeAxis(int _newTimeSize) {
        windowSeconds = _newTimeSize;
        windowPointsCount = windowSeconds * samplingRate;
        timeBetweenPoints = (float)windowSeconds / (float)windowPointsCount;
        plot.setXLim(-_newTimeSize,0);
        //Set the number of axis divisions based on the new time size
        if (_newTimeSize > 1) {
            plot.getXAxis().setNTicks(_newTimeSize);
        }else{
            plot.getXAxis().setNTicks(10);
        }
    }

    public void adjustYAxis(float min, float max) {
        plot.setYLim(min, max);
    }

    public void setEnabled(boolean value) {
        gplotAutoscaler.setEnabled(value);
    }

    public void setAutoscaleSpacing(float spacing) {
        gplotAutoscaler.setSpacing(spacing);
    }

    public void setPlotPositionAndOuterDimensions(boolean channelSelectIsVisible) {
        int _y = channelSelectIsVisible ? y + 22 : y;
        int _h = channelSelectIsVisible ? h - 22 : h;
        //reposition & resize the plot
        plot.setPos(x + 36 + 4 + xOffset, _y);
        plot.setDim(w - 36 - 4 - xOffset, _h);
    }

    public void setYAxisLabel(String label) {
        plot.getYAxis().setAxisLabelText(label);
    }

    public void setXAxisLabel(String label) {
        plot.getXAxis().setAxisLabelText(label);
    }

    public void setNumYAxisTicks(int numTicks) {
        plot.getYAxis().setNTicks(numTicks);
    }

    public void setShowXAxis(boolean show) {
        showXAxis = show;
    }

    public void setShowValueTextBox(boolean show) {
        valueTextBox.setVisible(show);
    }

    public void setValueTextBoxString(String value) {
        valueTextBox.string = value;
    }

    public void setSamplingRate(int _samplingRate) {
        samplingRate = _samplingRate;
        totalBufferPoints = totalBufferSeconds * samplingRate;
        windowPointsCount = windowSeconds * samplingRate;
        timeBetweenPoints = (float)windowSeconds / (float)windowPointsCount;
    }
};