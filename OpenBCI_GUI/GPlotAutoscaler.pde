class GPlotAutoscaler {
    private boolean isEnabled = false;
    private boolean useAverage = false;
    private float spacing = 0f; //Provides a buffer between the data and the plot's edges
    private float minimum = Float.MAX_VALUE;
    private float maximum = Float.MIN_VALUE;
    private int previousMillis = 0;
    private int currentMillis = 0;
    private int timerThresholdMillis = 1000;

    public GPlotAutoscaler() {
    }

    public GPlotAutoscaler(boolean _isEnabled) {
        isEnabled = _isEnabled;
    }

    public GPlotAutoscaler(float _spacing) {
        spacing = _spacing;
    }

    public GPlotAutoscaler(boolean _isEnabled, float _spacing) {
        isEnabled = _isEnabled;
        spacing = _spacing;
    }

    //Used for single layer plots e.g. EEG, EMG, Focus, etc.
    public void update(GPlot plot, GPointsArray pointsArray) {
        if (!isTimeToAutoscale()) {
            return;
        }
        
        resetMinMax();
        for (int i = 0; i < pointsArray.getNPoints(); i++) {
            updateMinMax(pointsArray.getY(i));
        }
        setYLimits(plot);
        previousMillis = currentMillis;
    }

    //Used for multilayer plots e.g. Cyton and Ganglion Accelerometer with X, Y, Z axes in the same plot
    public void update(GPlot plot, GPointsArray[] pointsArrays) {
        if (!isTimeToAutoscale()) {
            return;
        }
        
        resetMinMax();
        updateMinMaxMultilayer(pointsArrays);
        setYLimits(plot);
        previousMillis = currentMillis;
    }

    //Used for single layer plots where minMax values are updated when the points are added to the plot
    public void update(GPlot plot) {
        if (!isTimeToAutoscale()) {
            return;
        }

        setYLimits(plot);
        previousMillis = currentMillis;
    }

    public void updatePrecise(GPlot plot) {
        if (!isTimeToAutoscale()) {
            return;
        }

        setYLimitsPrecise(plot);
        previousMillis = currentMillis;
    }

    public void updatePrecise(GPlot plot, GPointsArray pointsArray) {
        if (!isTimeToAutoscale()) {
            return;
        }
        
        resetMinMax();
        for (int i = 0; i < pointsArray.getNPoints(); i++) {
            updateMinMax(pointsArray.getY(i));
        }
        setYLimitsPrecise(plot);
        previousMillis = currentMillis;
    }

    public void updatePrecise(GPlot plot, GPointsArray[] pointsArrays) {
        if (!isTimeToAutoscale()) {
            return;
        }
        
        resetMinMax();
        updateMinMaxMultilayer(pointsArrays);
        setYLimitsPrecise(plot);
        previousMillis = currentMillis;
    }

    private void setYLimits(GPlot plot) {
        if (minimum == Float.MAX_VALUE || maximum == -Float.MAX_VALUE) {
            return;
        }
        double lowerLimit = Math.floor(minimum) - spacing;
        double upperLimit = Math.ceil(maximum) + spacing;
        //This is a very expensive method. Here is the bottleneck.
        try {
            plot.setYLim((float)lowerLimit, (float)upperLimit);
        } catch (NumberFormatException e) {
            System.out.println("Error in GPlotAutoscaler.update(GPlot plot): " + e);
            println("Lower limit: " + lowerLimit + " Upper limit: " + upperLimit);
        }
    }

    private void setYLimitsPrecise(GPlot plot) {
        if (minimum == Float.MAX_VALUE || maximum == -Float.MAX_VALUE) {
            return;
        }
        double lowerLimit = minimum - spacing;
        double upperLimit = maximum + spacing;
        //This is a very expensive method. Here is the bottleneck.
        try {
            plot.setYLim((float)lowerLimit, (float)upperLimit);
        } catch (NumberFormatException e) {
            System.out.println("Error in GPlotAutoscaler.update(GPlot plot): " + e);
            println("Lower limit: " + lowerLimit + " Upper limit: " + upperLimit);
        }
    }

    private void updateMinMaxMultilayer(GPointsArray[] pointsArrays) {
        if (pointsArrays == null) {
            println("Error in GPlotAutoscaler.minMaxMultilayer(GPointsArray[] pointsArrays): pointsArrays is null");
            return;
        }
        
        float[] vals = new float[pointsArrays.length];
        for (int i = 0; i < pointsArrays[0].getNPoints(); i++) {
            for (int j = 0; j < pointsArrays.length; j++) {
                vals[j] = pointsArrays[j].getY(i);
            }
            minimum = min(minimum, min(vals));
            maximum = max(maximum, max(vals));
        }
    }

    private boolean isTimeToAutoscale() {
        return isEnabled && currentBoard.isStreaming() && timerHasElapsed();
    }

    private boolean timerHasElapsed() {
        currentMillis = millis();
        return currentMillis > previousMillis + timerThresholdMillis;
    }

    public void setEnabled(boolean value) {
        isEnabled = value;
    }

    public boolean getEnabled() {
        return isEnabled;
    }

    public float[] getMinMax() {
        float[] minMax = {minimum, maximum};
        return minMax;
    }

    public void setSpacing(float value) {
        spacing = value;
    }

    public void updateMinMax(float value) {
        maximum = Math.max(value, maximum);
        minimum = Math.min(value, minimum);
    }

    public void resetMinMax() {
        maximum = Float.MIN_VALUE;
        minimum = Float.MAX_VALUE;
    }
}