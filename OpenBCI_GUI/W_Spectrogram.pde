
//////////////////////////////////////////////////////
//                                                  //
//                  W_Spectrogram.pde               //
//                                                  //
//                                                  //
//    Created by: Richard Waltman, September 2019   //
//                                                  //
//////////////////////////////////////////////////////

class W_Spectrogram extends Widget {

    //to see all core variables/methods of the Widget class, refer to Widget.pde
    public ChannelSelect spectChanSelectTop;
    public ChannelSelect spectChanSelectBot;
    private boolean chanSelectWasOpen = false;

    int xPos = 0;
    int hueLimit = 160;

    Button widgetTemplateButton;
    PImage dataImg;
    int dataImageW = 1800;
    int dataImageH = 200;
    int prevW = 0;
    int prevH = 0;
    float scaledWidth;
    float scaledHeight;
    int graphX = 0;
    int graphY = 0;
    int graphW = 0;
    int graphH = 0;
    int midLineY = 0;

    int lastShift = 0;
    private int scrollSpeed = 100; // == 10Hz
    boolean wasRunning = false;

    int paddingLeft = 54;
    int paddingRight = 26;   
    int paddingTop = 8;
    int paddingBottom = 50;
    int numHorizAxisDivs = 3;
    int numVertAxisDivs = 8;
    int[][] vertAxisLabels = {
        {20, 15, 10, 5, 0, 5, 10, 15, 20},
        {40, 30, 20, 10, 0, 10, 20, 30, 40},
        {60, 45, 30, 15, 0, 15, 30, 45, 60},
        {100, 75, 50, 25, 0, 25,  50, 75, 100},
        {120, 90, 60, 30, 0, 30, 60, 90, 120},
        {250, 188, 125, 63, 0, 63, 125, 188, 250}
    };
    int[] vertAxisLabel;
    float[][] horizAxisLabels = {
        {30, 25, 20, 15, 10, 5, 0},
        {6, 5, 4, 3, 2, 1, 0},
        {3, 2, 1, 0},
        {1.5, 1, .5, 0},
        {1, .5, 0}
    };
    float[] horizAxisLabel;
    StringList horizAxisLabelStrings;

    float[] topFFTAvg;
    float[] botFFTAvg;

    W_Spectrogram(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //Add channel select dropdown to this widget
        spectChanSelectTop = new ChannelSelect(pApplet, x, y, w, navH, "Spectrogram_Channels_Top");
        spectChanSelectBot = new ChannelSelect(pApplet, x, y + navH, w, navH, "Spectrogram_Channels_Bot");
        activateDefaultChannels();
        spectChanSelectBot.hideChannelText();

        xPos = w - 1; //draw on the right, and shift pixels to the left
        prevW = w;
        prevH = h;
        graphX = x + paddingLeft;
        graphY = y + paddingTop;
        graphW = w - paddingRight - paddingLeft;
        graphH = h - paddingBottom - paddingTop;

        dataImg = createImage(dataImageW, dataImageH, RGB);

        settings.spectMaxFrqSave = 1;
        settings.spectSampleRateSave = 2;
        settings.spectLogLinSave = 0;
        vertAxisLabel = vertAxisLabels[settings.spectMaxFrqSave];
        horizAxisLabel = horizAxisLabels[settings.spectSampleRateSave];
        horizAxisLabelStrings = new StringList();

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("SpectrogramMaxFreq", "Max Freq", Arrays.asList(settings.spectMaxFrqArray), settings.spectMaxFrqSave);
        addDropdown("SpectrogramSampleRate", "Samples", Arrays.asList(settings.spectSampleRateArray), settings.spectSampleRateSave);
        addDropdown("SpectrogramLogLin", "Log/Lin", Arrays.asList(settings.fftLogLinArray), settings.spectLogLinSave);

        widgetTemplateButton = new Button (x + int(spectChanSelectBot.tri_xpos) + 10, y + navHeight + 2, 142, navHeight - 4, "Save Spectrogram", 10);
        widgetTemplateButton.setFont(p4, 14);
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        //put your code here...
        //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
        if (topNav.configSelector.isVisible || topNav.layoutSelector.isVisible) {
            widgetTemplateButton.setIsActive(false);
            widgetTemplateButton.setIgnoreHover(true);
        } else {
            widgetTemplateButton.setIgnoreHover(false);
        }

        //Update channel checkboxes and active channels
        spectChanSelectTop.update(x, y, w);
        spectChanSelectBot.update(x, y + navH, w);
        //Let the top channel select open the bottom one also so we can open both with 1 button
        if (chanSelectWasOpen != spectChanSelectTop.isVisible()) {
            spectChanSelectBot.setIsVisible(spectChanSelectTop.isVisible());
            chanSelectWasOpen = spectChanSelectTop.isVisible();
            //Allow spectrogram to flex size and position depending on if the channel select is open
            flexSpectrogramSizeAndPosition();
        }
        
        
        
        if (isRunning && eegDataSource != DATASOURCE_PLAYBACKFILE) {
            //Make sure we are always draw new pixels on the right
            xPos = dataImg.width - 1;
            //Fetch/calculate the time strings for the horizontal axis ticks
            fetchTimeStrings(numHorizAxisDivs);
        } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
            xPos = dataImg.width - 1;
            //Fetch playback data timestamp even when system is not running
            fetchTimeStrings(numHorizAxisDivs);
        }
        
        //State change check
        if (isRunning && !wasRunning) {
            onStartRunning();
        } else if (!isRunning && wasRunning) {
            onStopRunning();
        }
    }

    void onStartRunning() {
        wasRunning = true;
        lastShift = millis();
    }

    void onStopRunning() {
        wasRunning = false;
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        
        //Scale the dataImage to fit in inside the widget
        float scaleW = float(graphW) / dataImageW;
        float scaleH = float(graphH) / dataImageH;

        widgetTemplateButton.draw();
        pushStyle();
        fill(0);
        rect(x, y, w, h); //draw a black background for the widget
        popStyle();

        //draw the spectrogram if the widget is open, and update pixels if isRunning
        if (isRunning) {
            pushStyle();
            dataImg.loadPixels();

            //Shift all pixels to the left! (every scrollspeed ms)
            if(millis() - lastShift > scrollSpeed) {
                for (int r = 0; r < dataImg.height; r++) {
                    if (r != 0) {
                        arrayCopy(dataImg.pixels, dataImg.width * r, dataImg.pixels, dataImg.width * r - 1, dataImg.width);
                    } else {
                        //When there would be an ArrayOutOfBoundsException, account for it!
                        arrayCopy(dataImg.pixels, dataImg.width * (r + 1), dataImg.pixels, r * dataImg.width, dataImg.width);
                    }
                }

                lastShift += scrollSpeed;
            }
            //for (int i = 0; i < fftLin_L.specSize() - 80; i++) {
            for (int i = 0; i <= dataImg.height/2; i++) {
                //LEFT SPECTROGRAM ON TOP
                float hueValue = hueLimit - map((fftAvgs(spectChanSelectTop.activeChan, i)*32), 0, 256, 0, hueLimit);
                if (settings.spectLogLinSave == 0) {
                    hueValue = map(log10(hueValue), 0, 2, 0, hueLimit);
                }
                // colorMode is HSB, the range for hue is 256, for saturation is 100, brightness is 100.
                colorMode(HSB, 256, 100, 100);
                // color for stroke is specified as hue, saturation, brightness.
                stroke(int(hueValue), 100, 80);
                // plot a point using the specified stroke
                //point(xPos, i);
                int loc = xPos + ((dataImg.height/2 - i) * dataImg.width);
                if (loc >= dataImg.width * dataImg.height) loc = dataImg.width * dataImg.height - 1;
                try {
                    dataImg.pixels[loc] = color(int(hueValue), 100, 80);
                } catch (Exception e) {
                    println("Major drawing error Spectrogram Left image!");
                }

                //RIGHT SPECTROGRAM ON BOTTOM
                hueValue = hueLimit - map((fftAvgs(spectChanSelectBot.activeChan, i)*32), 0, 256, 0, hueLimit);
                if (settings.spectLogLinSave == 0) {
                    hueValue = map(log10(hueValue), 0, 2, 0, hueLimit);
                }
                // colorMode is HSB, the range for hue is 256, for saturation is 100, brightness is 100.
                colorMode(HSB, 256, 100, 100);
                // color for stroke is specified as hue, saturation, brightness.
                stroke(int(hueValue), 100, 80);
                int y_offset = -1;
                // Pixel = X + ((Y + Height/2) * Width)
                loc = xPos + ((i + dataImg.height/2 + y_offset) * dataImg.width);
                if (loc >= dataImg.width * dataImg.height) loc = dataImg.width * dataImg.height - 1;
                try {
                    dataImg.pixels[loc] = color(int(hueValue), 100, 80);
                } catch (Exception e) {
                    println("Major drawing error Spectrogram Right image!");
                }
            }
            dataImg.updatePixels();
            popStyle();
        }
        
        pushMatrix();
        translate(graphX, graphY);
        scale(scaleW, scaleH);
        image(dataImg, 0, 0);
        popMatrix();

        spectChanSelectTop.draw();
        spectChanSelectBot.draw();
        //if (spectChanSelectTop.isVisible()) spectChanSelectBot.forceDrawChecklist(dropdownIsActive);
        drawAxes(scaleW, scaleH);
        drawCenterLine();
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)
        
        //cp5.setGraphics(pApplet, 0, 0);
        //put your code here...
        widgetTemplateButton.setPos(x + int(textWidth("Channels")) + 7 + 5, y - navHeight + 2);
        spectChanSelectTop.screenResized(pApplet);
        spectChanSelectBot.screenResized(pApplet);  
        graphX = x + paddingLeft;
        graphY = y + paddingTop;
        graphW = w - paddingRight - paddingLeft;
        graphH = h - paddingBottom - paddingTop;
        //Allow spectrogram to flex size and position depending on if the channel select is open
        if (spectChanSelectTop.isVisible()) {
            graphY += navH * 2;
            graphH -= navH * 2;
        }
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        //put your code here...
        //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
        if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
            if(widgetTemplateButton.isMouseHere()){
                widgetTemplateButton.setIsActive(true);
            }
        }
        spectChanSelectTop.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked
        spectChanSelectBot.mousePressed(this.dropdownIsActive);
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
        
        //put your code here...
        if(widgetTemplateButton.isActive && widgetTemplateButton.isMouseHere()){
            //selectInput("Select a sound file for playback:", "loadSoundFromFile");
            String s = settings.guiDataPath + System.currentTimeMillis() + ".jpg";
            dataImg.save(s);
            outputSuccess("Spectrogram Image saved to: " + s);
        }

        widgetTemplateButton.setIsActive(false);

    }

    void drawAxes(float scaledW, float scaledH) {
        
        pushStyle();
            fill(255);
            textSize(14);
            //draw horizontal axis label
            text("Time", x + w/2 - textWidth("Time")/3, y + h - 9);
            noFill();
            stroke(255);
            strokeWeight(2);
            //draw rectangle around the spectrogram
            rect(graphX, graphY, scaledW * dataImageW, scaledH * dataImageH);
        popStyle();

        pushStyle();
            //draw horizontal axis ticks from left to right
            int tickMarkSize = 7; //in pixels
            float horizAxisX = graphX;
            float horizAxisY = graphY + scaledH * dataImageH;
            stroke(255);
            fill(255);
            strokeWeight(2);
            textSize(10);
            for (int i = 0; i <= numHorizAxisDivs; i++) {
                float offset = scaledW * dataImageW * (float(i) / numHorizAxisDivs);
                line(horizAxisX + offset, horizAxisY, horizAxisX + offset, horizAxisY + tickMarkSize);
                text(horizAxisLabelStrings.get(i), horizAxisX + offset - (int)textWidth(horizAxisLabelStrings.get(i))/2, horizAxisY + tickMarkSize * 3);
            }
        popStyle();
        
        pushStyle();
            pushMatrix();
                rotate(radians(-90));
                translate(-h/2 - textWidth("Frequency (Hz)")/3, 20);
                fill(255);
                textSize(14);
                //draw y axis label
                text("Frequency (Hz)", -y, x);
            popMatrix();
        popStyle();

        pushStyle();
            //draw vertical axis ticks from top to bottom
            float vertAxisX = graphX;
            float vertAxisY = graphY;
            stroke(255);
            fill(255);
            strokeWeight(2);
            for (int i = 0; i <= numVertAxisDivs; i++) {
                float offset = scaledH * dataImageH * (float(i) / numVertAxisDivs);
                //if (i <= numVertAxisDivs/2) offset -= 2;
                line(vertAxisX, vertAxisY + offset, vertAxisX - tickMarkSize, vertAxisY + offset);
                if (vertAxisLabel[i] == 0) midLineY = int(vertAxisY + offset);
                offset += paddingTop - 2;
                text(vertAxisLabel[i], vertAxisX - tickMarkSize*2 - textWidth(Integer.toString(vertAxisLabel[i])), vertAxisY + offset);
            }
        popStyle();

        drawColorScaleReference();
    }

    void drawCenterLine() {
        //draw a thick line down the middle to separate the two plots
        pushStyle();
        stroke(255);
        strokeWeight(3);
        line(graphX, midLineY, graphX + graphW, midLineY);
        popStyle();
    }

    void drawColorScaleReference() {
        int colorScaleHeight = 128;
        pushStyle();
            //draw color scale reference to the right of the spectrogram
            for (int i = 0; i < colorScaleHeight; i++) {
                float hueValue = hueLimit - map(i * 2, 0, 256, 0, hueLimit);
                if (settings.spectLogLinSave == 0) {
                    hueValue = map(log(hueValue) / log(10), 0, 2, 0, hueLimit);
                }
                //println(hueValue);
                // colorMode is HSB, the range for hue is 256, for saturation is 100, brightness is 100.
                colorMode(HSB, 256, 100, 100);
                // color for stroke is specified as hue, saturation, brightness.
                stroke(int(hueValue), 100, 80);
                strokeWeight(10);
                point(x + w - paddingRight/2 + 1, y + paddingTop + midLineY - colorScaleHeight/3 - 14 - i);
            }
        popStyle();
    }

    void activateDefaultChannels() {
        int[] topChansToActivate;
        int[] botChansToActivate; 
        if (nchan == 4) {
            topChansToActivate = new int[]{0, 2};
            botChansToActivate = new int[]{1, 3};
        } else if (nchan == 8) {
            topChansToActivate = new int[]{0, 2, 4, 6};
            botChansToActivate = new int[]{1, 3, 5, 7};
        } else {
            topChansToActivate = new int[]{0, 2, 4, 6, 8 ,10, 12, 14};
            botChansToActivate = new int[]{1, 3, 5, 7, 9, 11, 13, 15};
        }

        for (int i = 0; i < topChansToActivate.length; i++) {
            spectChanSelectTop.checkList.activate(topChansToActivate[i]);
            spectChanSelectTop.activeChan.add(topChansToActivate[i]);
            spectChanSelectBot.checkList.activate(botChansToActivate[i]);
            spectChanSelectBot.activeChan.add(botChansToActivate[i]);
        }
    }

    void flexSpectrogramSizeAndPosition() {
        if (spectChanSelectTop.isVisible()) {
            graphY += navH * 2;
            graphH -= navH * 2;
        } else {
            graphY -= navH * 2;
            graphH += navH * 2;
        }
    }

    void setScrollSpeed(int i) {
        scrollSpeed = i;
    }

    float fftAvgs(List<Integer> _activeChan, int freqBand) {
        float sum = 0f;
        for (int i = 0; i < _activeChan.size(); i++) {
            sum += fftBuff[_activeChan.get(i)].getBand(freqBand);
        }
        return sum / _activeChan.size();
    }

    void fetchTimeStrings(int numAxisTicks) {
        horizAxisLabelStrings.clear();
        LocalTime time;
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
        if (eegDataSource != DATASOURCE_PLAYBACKFILE) {
            time = LocalTime.now();
        } else {
            try {
                if (getCurrentTimeStamp().equals("TimeNotFound")) {
                    time = LocalTime.now();
                } else {
                    long t = new Long(getCurrentTimeStamp());
                    Date d =  new Date(t);
                    String timeFromPlayback = new SimpleDateFormat("HH:mm:ss").format(d);
                    time = LocalTime.parse(timeFromPlayback);
                }
            } catch (NullPointerException e) {
                println("Spectrogram: Timestamp error...");
                e.printStackTrace();
                time = LocalTime.now();
            } catch (NumberFormatException e) {
                println("Spectrogram: Timestamp error...");
                e.printStackTrace();
                time = LocalTime.now();
            }
        }
        
        
        for (int i = 0; i <= numAxisTicks; i++) {
            long l = (long)(horizAxisLabel[i] * 60f);
            LocalTime t = time.plus(l, ChronoUnit.SECONDS);
            horizAxisLabelStrings.append(t.format(formatter));
        }
    }

    //Identical to the method in TimeSeries, but allows spectrogram to get the data directly from the playback data in the background
    //Find times to display for playback position
    String getCurrentTimeStamp() {
        //return current playback time
        if (index_of_times != null) { //Check if the hashmap is null to prevent exception
            if (index_of_times.get(0) != null) {
                if (currentTableRowIndex > playbackData_table.getRowCount()) {
                    return index_of_times.get(playbackData_table.getRowCount());
                } else {
                    return index_of_times.get(currentTableRowIndex);
                }
            } else {
                //This is a sanity check for null exception, and this would print on screen
                return "TimeNotFound";
            }
        } else {
            //Same here
            return "TimeNotFound";
        }
    }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
//triggered when there is an event in the Spectrogram Widget MaxFreq. Dropdown
void SpectrogramMaxFreq(int n) {
    settings.spectMaxFrqSave = n;
    //Link the choices made in the FFT widget and the Spectrogram Widget for this parameter
    MaxFreq(n);
    w_fft.cp5_widget.getController("MaxFreq").getCaptionLabel().setText(settings.fftMaxFrqArray[n]);
    closeAllDropdowns();
    //reset the vertical axis labelss
    w_spectrogram.vertAxisLabel = w_spectrogram.vertAxisLabels[n];
    //Resize the height of the data image
    w_spectrogram.dataImageH = w_spectrogram.vertAxisLabel[0] * 2;
    //overwrite the existing image because the sample rate is about to change
    w_spectrogram.dataImg = createImage(w_spectrogram.dataImageW, w_spectrogram.dataImageH, RGB);
}

void SpectrogramSampleRate(int n) {
    settings.spectSampleRateSave = n;
    //overwrite the existing image because the sample rate is about to change
    w_spectrogram.dataImg = createImage(w_spectrogram.dataImageW, w_spectrogram.dataImageH, RGB);
    w_spectrogram.horizAxisLabel = w_spectrogram.horizAxisLabels[n];
    if (n == 0) {
        w_spectrogram.numHorizAxisDivs = 6;
        w_spectrogram.setScrollSpeed(1000);
    } else if (n == 1) {
        w_spectrogram.numHorizAxisDivs = 6;
        w_spectrogram.setScrollSpeed(200);
    } else if (n == 2) {
        w_spectrogram.numHorizAxisDivs = 3;
        w_spectrogram.setScrollSpeed(100);
    } else if (n == 3) {
        w_spectrogram.numHorizAxisDivs = 3;
        w_spectrogram.setScrollSpeed(50);
    } else if (n == 4) {
        w_spectrogram.numHorizAxisDivs = 2;
        w_spectrogram.setScrollSpeed(25);
    }
    w_spectrogram.horizAxisLabelStrings.clear();
    w_spectrogram.fetchTimeStrings(w_spectrogram.numHorizAxisDivs);
    closeAllDropdowns();
}

void SpectrogramLogLin(int n) {
    settings.spectLogLinSave = n;
    closeAllDropdowns();
}