//////////////////////////////////////////////////////
//                                                  //
//                  W_Spectrogram.pde               //
//                                                  //
//                                                  //
//   Created by: Richard Waltman, September 2019    //
//   Refactored by: Richard Waltman, April 2025     //
//                                                  //
//////////////////////////////////////////////////////

class W_Spectrogram extends WidgetWithSettings {
    private ExGChannelSelect spectChanSelectTop;
    private ExGChannelSelect spectChanSelectBot;
    private boolean chanSelectWasOpen = false;
    private List<controlP5.Controller> cp5ElementsToCheck;

    private int xPos = 0;
    private int hueLimit = 160;

    private PImage dataImg;
    private int dataImageW = 1800;
    private int dataImageH = 200;
    private int prevW = 0;
    private int prevH = 0;
    private float scaledWidth;
    private float scaledHeight;
    private int graphX = 0;
    private int graphY = 0;
    private int graphW = 0;
    private int graphH = 0;
    private int midLineY = 0;

    private int lastShift = 0;
    private int scrollSpeed = 25; // == 40Hz
    private boolean wasRunning = false;

    private int paddingLeft = 54;
    private int paddingRight = 26;   
    private int paddingTop = 8;
    private int paddingBottom = 50;
    private StringList horizontalAxisLabelStrings;

    private float[] topFFTAvg;
    private float[] botFFTAvg;

    W_Spectrogram() {
        super();
        widgetTitle = "Spectrogram";

        xPos = w - 1; //draw on the right, and shift pixels to the left
        prevW = w;
        prevH = h;
        graphX = x + paddingLeft;
        graphY = y + paddingTop;
        graphW = w - paddingRight - paddingLeft;
        graphH = h - paddingBottom - paddingTop;
        
        //Fetch/calculate the time strings for the horizontal axis ticks
        horizontalAxisLabelStrings = fetchTimeStrings();

        //Resize the height of the data image using default 
        SpectrogramMaxFrequency maxFrequency = widgetSettings.get(SpectrogramMaxFrequency.class);
        dataImageH = maxFrequency.getAxisLabels()[0] * 2;
        //Create image using correct dimensions! Fixes bug where image size and labels do not align on session start.
        dataImg = createImage(dataImageW, dataImageH, RGB);
    }

    @Override
    protected void initWidgetSettings() {
        super.initWidgetSettings();
        widgetSettings.set(SpectrogramMaxFrequency.class, SpectrogramMaxFrequency.MAX_60)
                    .set(SpectrogramWindowSize.class, SpectrogramWindowSize.ONE_MINUTE)
                    .set(GraphLogLin.class, GraphLogLin.LIN);

        initDropdown(SpectrogramMaxFrequency.class, "spectrogramMaxFrequencyDropdown", "Max Hz");
        initDropdown(SpectrogramWindowSize.class, "spectrogramWindowDropdown", "Window");
        initDropdown(GraphLogLin.class, "spectrogramLogLinDropdown", "Log/Lin");

        spectChanSelectTop = new DualExGChannelSelect(ourApplet, x, y, w, navH, true);
        spectChanSelectBot = new DualExGChannelSelect(ourApplet, x, y + navH, w, navH, false);
        activateDefaultChannels();
        updateChannelSettings();
        
        cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.addAll(spectChanSelectTop.getCp5ElementsForOverlapCheck());
        cp5ElementsToCheck.addAll(spectChanSelectBot.getCp5ElementsForOverlapCheck());
    }

    @Override
    protected void applySettings() {
        updateDropdownLabel(SpectrogramMaxFrequency.class, "spectrogramMaxFrequencyDropdown");
        updateDropdownLabel(SpectrogramWindowSize.class, "spectrogramWindowDropdown");
        updateDropdownLabel(GraphLogLin.class, "spectrogramLogLinDropdown");
        applyMaxFrequency();
        applyWindowSize();
        applyChannelSettings();
    }

    private void applyChannelSettings() {
        // Apply saved channel selections if available
        if (hasNamedChannels("top")) {
            applyNamedChannels("top", spectChanSelectTop);
        }
        
        if (hasNamedChannels("bottom")) {
            applyNamedChannels("bottom", spectChanSelectBot);
        }
    }

    @Override
    protected void updateChannelSettings() {
        // Save current channel selections before saving settings
        saveChannelSettings();
    }

    private void saveChannelSettings() {
        saveNamedChannels("top", spectChanSelectTop.getActiveChannels());
        saveNamedChannels("bottom", spectChanSelectBot.getActiveChannels());
    }

    @Override
    public void update(){
        super.update();

        //Update channel checkboxes, active channels, and position
        updateUIState();
        
        checkBoardStreamingState();
    }

    private void onStartRunning() {
        wasRunning = true;
        lastShift = millis();
    }

    private void onStopRunning() {
        wasRunning = false;
    }

    @Override
    public void draw() {
        super.draw();
        
        float scaleW = float(graphW) / dataImageW;
        float scaleH = float(graphH) / dataImageH;
        
        // Update spectrogram data if streaming
        if (currentBoard.isStreaming()) {
            updateSpectrogramData();
        }
        
        // Display the spectrogram image
        displaySpectrogramImage(scaleW, scaleH);
        
        // Draw UI elements
        spectChanSelectTop.draw();
        spectChanSelectBot.draw();
        drawAxes(scaleW, scaleH);
        drawCenterLine();
    }

    private void displaySpectrogramImage(float scaleW, float scaleH) {
        pushMatrix();
        translate(graphX, graphY);
        scale(scaleW, scaleH);
        image(dataImg, 0, 0);
        popMatrix();
    }

    private void updateSpectrogramData() {
        pushStyle();
        dataImg.loadPixels();
        
        // Shift pixels to the left if needed
        shiftPixelsLeft();
        
        // Calculate and draw new data points
        drawSpectrogramPoints();
        
        dataImg.updatePixels();
        popStyle();
    }

    private void shiftPixelsLeft() {
        if (millis() - lastShift > scrollSpeed) {
            for (int r = 0; r < dataImg.height; r++) {
                if (r != 0) {
                    arrayCopy(dataImg.pixels, dataImg.width * r, dataImg.pixels, dataImg.width * r - 1, dataImg.width);
                } else {
                    arrayCopy(dataImg.pixels, dataImg.width * (r + 1), dataImg.pixels, r * dataImg.width, dataImg.width);
                }
            }
            lastShift += scrollSpeed;
        }
    }

    private void drawSpectrogramPoints() {
        GraphLogLin logLin = widgetSettings.get(GraphLogLin.class);
        
        for (int i = 0; i <= dataImg.height/2; i++) {
            // Draw top spectrogram (left channels)
            drawSpectrogramPoint(spectChanSelectTop.getActiveChannels(), i, dataImg.height/2 - i, logLin);
            
            // Draw bottom spectrogram (right channels)
            int y_offset = -1;
            drawSpectrogramPoint(spectChanSelectBot.getActiveChannels(), i, i + dataImg.height/2 + y_offset, logLin);
        }
    }

    private void drawSpectrogramPoint(List<Integer> channels, int freqBand, int yPosition, GraphLogLin logLin) {
        float hueValue = hueLimit - map((fftAvgs(channels, freqBand)*32), 0, 256, 0, hueLimit);
        
        if (logLin == GraphLogLin.LOG) {
            hueValue = map(log10(hueValue), 0, 2, 0, hueLimit);
        }
        
        colorMode(HSB, 256, 100, 100);
        stroke(int(hueValue), 100, 80);
        
        int loc = xPos + (yPosition * dataImg.width);
        if (loc >= dataImg.width * dataImg.height) {
            loc = dataImg.width * dataImg.height - 1;
        }
        
        try {
            dataImg.pixels[loc] = color(int(hueValue), 100, 80);
        } catch (Exception e) {
            println("Major drawing error in Spectrogram at position: " + yPosition);
        }
    }

    @Override
    public void screenResized(){
        super.screenResized();

        spectChanSelectTop.screenResized(ourApplet);
        spectChanSelectBot.screenResized(ourApplet);  
        graphX = x + paddingLeft;
        graphY = y + paddingTop;
        graphW = w - paddingRight - paddingLeft;
        graphH = h - paddingBottom - paddingTop;
    }

    @Override
    public void mousePressed(){
        super.mousePressed();

        spectChanSelectTop.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked
        spectChanSelectBot.mousePressed(this.dropdownIsActive);
    }

    @Override
    public void mouseReleased(){
        super.mouseReleased();
    }

    private void drawAxes(float scaledW, float scaledH) {
        drawSpectrogramBorder(scaledW, scaledH);
        drawHorizontalAxisAndLabels(scaledW, scaledH);
        drawVerticalAxisAndLabels(scaledW, scaledH);
        drawYAxisLabel();
        drawColorScaleReference();
    }

    private void drawSpectrogramBorder(float scaledW, float scaledH) {
        pushStyle();
        fill(255);
        textSize(14);
        text("Time", x + w/2 - textWidth("Time")/3, y + h - 9);
        noFill();
        stroke(255);
        strokeWeight(2);
        rect(graphX, graphY, scaledW * dataImageW, scaledH * dataImageH);
        popStyle();
    }

    private void drawHorizontalAxisAndLabels(float scaledW, float scaledH) {
        pushStyle();
        int tickMarkSize = 7;
        float horizontalAxisX = graphX;
        float horizontalAxisY = graphY + scaledH * dataImageH;
        stroke(255);
        fill(255);
        strokeWeight(2);
        textSize(11);
        
        SpectrogramWindowSize windowSize = widgetSettings.get(SpectrogramWindowSize.class);
        int horizontalAxisDivCount = windowSize.getAxisLabels().length;
        
        for (int i = 0; i < horizontalAxisDivCount; i++) {
            float offset = scaledW * dataImageW * (float(i) / horizontalAxisDivCount);
            line(horizontalAxisX + offset, horizontalAxisY, horizontalAxisX + offset, horizontalAxisY + tickMarkSize);
            
            if (horizontalAxisLabelStrings.get(i) != null) {
                text(horizontalAxisLabelStrings.get(i), 
                    horizontalAxisX + offset - (int)textWidth(horizontalAxisLabelStrings.get(i))/2, 
                    horizontalAxisY + tickMarkSize * 3);
            }
        }
        popStyle();
    }

    private void drawYAxisLabel() {
        pushStyle();
        pushMatrix();
        rotate(radians(-90));
        textSize(14);
        int yAxisLabelOffset = spectChanSelectTop.isVisible() ? (int)textWidth("Frequency (Hz)") / 4 : 0;
        translate(-h/2 - textWidth("Frequency (Hz)")/4, 20);
        fill(255);
        
        if (!spectChanSelectTop.isVisible()) {
            text("Frequency (Hz)", -y - yAxisLabelOffset, x);
        }
        
        popMatrix();
        popStyle();
    }

    private void drawVerticalAxisAndLabels(float scaledW, float scaledH) {
        pushStyle();
        float verticalAxisX = graphX;
        float verticalAxisY = graphY;
        int tickMarkSize = 7;
        stroke(255);
        fill(255);
        textSize(12);
        strokeWeight(2);
        
        SpectrogramMaxFrequency maxFrequency = widgetSettings.get(SpectrogramMaxFrequency.class);
        int verticalAxisDivCount = maxFrequency.getAxisLabels().length - 1;
        
        for (int i = 0; i < verticalAxisDivCount; i++) {
            float offset = scaledH * dataImageH * (float(i) / verticalAxisDivCount);
            line(verticalAxisX, verticalAxisY + offset, verticalAxisX - tickMarkSize, verticalAxisY + offset);
            
            if (maxFrequency.getAxisLabels()[i] == 0) {
                midLineY = int(verticalAxisY + offset);
            }
            
            offset += paddingTop/2;
            text(maxFrequency.getAxisLabels()[i], 
                verticalAxisX - tickMarkSize*2 - textWidth(Integer.toString(maxFrequency.getAxisLabels()[i])), 
                verticalAxisY + offset);
        }
        popStyle();
    }

    private void drawCenterLine() {
        //draw a thick line down the middle to separate the two plots
        pushStyle();
        stroke(255);
        strokeWeight(3);
        line(graphX, midLineY, graphX + graphW, midLineY);
        popStyle();
    }

    private void drawColorScaleReference() {
        int colorScaleHeight = 128;
        //Dynamically scale the Log/Lin amplitude-to-color reference line. If it won't fit, don't draw it.
        if (graphH < colorScaleHeight) {
            colorScaleHeight = int(h * 1/2);
            if (colorScaleHeight > graphH) {
                return;
            }
        }
        GraphLogLin logLin = widgetSettings.get(GraphLogLin.class);
        pushStyle();
            //draw color scale reference to the right of the spectrogram
            for (int i = 0; i < colorScaleHeight; i++) {
                float hueValue = hueLimit - map(i * 2, 0, colorScaleHeight*2, 0, hueLimit);
                if (logLin == GraphLogLin.LOG) {
                    hueValue = map(log(hueValue) / log(10), 0, 2, 0, hueLimit);
                }
                //println(hueValue);
                // colorMode is HSB, the range for hue is 256, for saturation is 100, brightness is 100.
                colorMode(HSB, 256, 100, 100);
                // color for stroke is specified as hue, saturation, brightness.
                stroke(ceil(hueValue), 100, 80);
                strokeWeight(10);
                point(x + w - paddingRight/2 + 1, midLineY + colorScaleHeight/2 - i);
            }
        popStyle();
    }

    private void activateDefaultChannels() {
        int[] topChansToActivate;
        int[] botChansToActivate; 

        if (globalChannelCount == 4) {
            topChansToActivate = new int[]{0, 2};
            botChansToActivate = new int[]{1, 3};
        } else if (globalChannelCount == 8) {
            topChansToActivate = new int[]{0, 2, 4, 6};
            botChansToActivate = new int[]{1, 3, 5, 7};
        } else {
            topChansToActivate = new int[]{0, 2, 4, 6, 8 ,10, 12, 14};
            botChansToActivate = new int[]{1, 3, 5, 7, 9, 11, 13, 15};
        }

        for (int i = 0; i < topChansToActivate.length; i++) {
            spectChanSelectTop.setToggleState(topChansToActivate[i], true);
            
        }

        for (int i = 0; i < botChansToActivate.length; i++) {
            spectChanSelectBot.setToggleState(botChansToActivate[i], true);
        }
    }

    private void flexSpectrogramSizeAndPosition() {
        int flexHeight = spectChanSelectTop.getHeight() + spectChanSelectBot.getHeight();
        if (spectChanSelectTop.isVisible()) {
            graphY = y + paddingTop + flexHeight;
            graphH = h - paddingBottom - paddingTop - flexHeight;
        } else {
            graphY = y + paddingTop;
            graphH = h - paddingBottom - paddingTop;
        }
    }

    public void setScrollSpeed(int i) {
        scrollSpeed = i;
    }

    private float fftAvgs(List<Integer> _activeChan, int freqBand) {
        float sum = 0f;
        for (int i = 0; i < _activeChan.size(); i++) {
            sum += fftBuff[_activeChan.get(i)].getBand(freqBand);
        }
        return sum / _activeChan.size();
    }

    private StringList fetchTimeStrings() {
        StringList output = new StringList();
        LocalDateTime time;
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
        if (getCurrentTimeStamp() == 0) {
            time = LocalDateTime.now();
        } else {
            time = LocalDateTime.ofInstant(Instant.ofEpochMilli(getCurrentTimeStamp()), 
                                            TimeZone.getDefault().toZoneId()); 
        }
        SpectrogramWindowSize windowSize = widgetSettings.get(SpectrogramWindowSize.class);
        for (int i = 0; i < windowSize.getAxisLabels().length; i++) {
            long l = (long)(windowSize.getAxisLabels()[i] * 60f);
            LocalDateTime t = time.minus(l, ChronoUnit.SECONDS);
            output.append(t.format(formatter));
        }
        return output;
    }

    //Identical to the method in TimeSeries, but allows spectrogram to get the data directly from the playback data in the background
    //Find times to display for playback position
    private long getCurrentTimeStamp() {
        //return current playback time
        List<double[]> currentData = currentBoard.getData(1);
        if (currentData.size() == 0 || currentData.get(0).length == 0) {
            return 0;
        }
        int timeStampChan = currentBoard.getTimestampChannel();
        long timestampMS = (long)(currentData.get(0)[timeStampChan] * 1000.0);
        return timestampMS;
    }

    public void clear() {
        // Set all pixels to black (or any other background color you want to clear with)
        for (int i = 0; i < dataImg.pixels.length; i++) {
            dataImg.pixels[i] = color(0);  // Black background
        }
    }

    public void setLogLin(int n) {
        widgetSettings.setByIndex(GraphLogLin.class, n);
    }

    public void setMaxFrequency(int n) {
        widgetSettings.setByIndex(SpectrogramMaxFrequency.class, n);
        applyMaxFrequency();
    }

    public void setWindowSize(int n) {
        widgetSettings.setByIndex(SpectrogramWindowSize.class, n);
        applyWindowSize();
    }

    private void applyMaxFrequency() {
        SpectrogramMaxFrequency maxFrequency = widgetSettings.get(SpectrogramMaxFrequency.class);
        // Resize the height of the data image
        dataImageH = maxFrequency.getAxisLabels()[0] * 2;
        // Overwrite the existing image
        dataImg = createImage(dataImageW, dataImageH, RGB);
    }

    private void applyWindowSize() {
        SpectrogramWindowSize windowSize = widgetSettings.get(SpectrogramWindowSize.class);
        setScrollSpeed(windowSize.getScrollSpeed());
        horizontalAxisLabelStrings.clear();
        horizontalAxisLabelStrings = fetchTimeStrings();
        dataImg = createImage(dataImageW, dataImageH, RGB);
    }

    private void resetSpectrogramImage() {
        // Create a new image with the current settings
        dataImg = createImage(dataImageW, dataImageH, RGB);
    }

    private void updateTimeAxisLabels() {
        horizontalAxisLabelStrings.clear();
        horizontalAxisLabelStrings = fetchTimeStrings();
    }

    private void checkBoardStreamingState() {
        if (currentBoard.isStreaming()) {
            // Update position for new data points
            xPos = dataImg.width - 1;
            // Update time axis labels
            updateTimeAxisLabels();
        }
        
        // State change detection
        if (currentBoard.isStreaming() && !wasRunning) {
            onStartRunning();
        } else if (!currentBoard.isStreaming() && wasRunning) {
            onStopRunning();
        }
    }

    private void updateUIState() {
        spectChanSelectTop.update(x, y, w);
        int chanSelectBotYOffset = navH;
        spectChanSelectBot.update(x, y + chanSelectBotYOffset, w);
        
        // Synchronize visibility between top and bottom channel selectors
        synchronizeChannelSelectors();
        
        // Update flexible layout based on channel selector visibility
        flexSpectrogramSizeAndPosition();
        
        // Handle UI element overlap checking
        if (spectChanSelectTop.isVisible()) {
            lockElementsOnOverlapCheck(cp5ElementsToCheck);
        }
    }

    private void synchronizeChannelSelectors() {
        if (chanSelectWasOpen != spectChanSelectTop.isVisible()) {
            spectChanSelectBot.setIsVisible(spectChanSelectTop.isVisible());
            chanSelectWasOpen = spectChanSelectTop.isVisible();
        }
    }
};

public void spectrogramMaxFrequencyDropdown(int n) {
    ((W_Spectrogram) widgetManager.getWidget("W_Spectrogram")).setMaxFrequency(n);
}

public void spectrogramWindowDropdown(int n) {
    ((W_Spectrogram) widgetManager.getWidget("W_Spectrogram")).setWindowSize(n);
}

public void spectrogramLogLinDropdown(int n) {
    ((W_Spectrogram) widgetManager.getWidget("W_Spectrogram")).setLogLin(n);
}
