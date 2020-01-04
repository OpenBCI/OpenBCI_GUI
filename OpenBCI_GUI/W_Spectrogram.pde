
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

    int paddingLeft = 60;
    int paddingRight = 8;   
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
        {1.5, 1, .5, 0}
    };
    float[] horizAxisLabel;

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
        vertAxisLabel = vertAxisLabels[settings.spectMaxFrqSave];
        horizAxisLabel = horizAxisLabels[settings.spectSampleRateSave];

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("SpectrogramMaxFreq", "Max Freq", Arrays.asList(settings.spectMaxFrqArray), settings.spectMaxFrqSave);
        addDropdown("SpectrogramSampleRate", "Samples", Arrays.asList(settings.spectSampleRateArray), settings.spectSampleRateSave);
        //addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
        //addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

        //widgetTemplateButton = new Button (x + w/2, y + navHeight, 200, navHeight, "SelectSoundFile", 12);
        //widgetTemplateButton.setFont(p4, 14);
        //widgetTemplateButton.setURL("https://openbci.github.io/Documentation/docs/06Software/01-OpenBCISoftware/GUIWidgets#custom-widget");
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        //put your code here...
        //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
        if (topNav.configSelector.isVisible || topNav.layoutSelector.isVisible) {
            /*
            widgetTemplateButton.setIsActive(false);
            widgetTemplateButton.setIgnoreHover(true);
            */
        } else {
            //widgetTemplateButton.setIgnoreHover(false);
        }

        //Update channel checkboxes and active channels
        spectChanSelectTop.update(x, y, w);
        spectChanSelectBot.update(x, y + navH, w);
        //Let the top channel select open the bottom one also so we can open both with 1 button
        if (chanSelectWasOpen != spectChanSelectTop.isVisible()) {
            spectChanSelectBot.setIsVisible(spectChanSelectTop.isVisible());
            chanSelectWasOpen = spectChanSelectTop.isVisible();
            flexSpectrogramSizeAndPosition();
        }
        /*
        //Flex the Gplot graph when channel select dropdown is open/closed
        if (bpChanSelect.isVisible() != prevChanSelectIsVisible) {
            flexGPlotSizeAndPosition();
            prevChanSelectIsVisible = bpChanSelect.isVisible();
        }
        */

        /*
        if (this.isActive) {
            // perform a forward FFT on the samples in jingle's mix buffer
            // note that if jingle were a MONO file, this would be the same as using jingle.left or jingle.right
            fftLin_L.forward(jingle.left);
            fftLin_R.forward(jingle.right);
            // increment the x position
            xPos = xPos + 1;
            // wrap around at the screen width
            if (xPos >= w) {
                xPos = 0;
            }
        }

        final int INTERVAL = 10;
        
        void setup()
        {
        size(400, 400);
        smooth();
        background(255);
        }
        
        void draw()
        {
        // Scroll one column of pixels per frame
        loadPixels();
        for (int r = 0; r < height; r++)
        {
            arrayCopy(pixels, width * r, pixels, width * r + 1, width - 1);
        }
        updatePixels();
        // Add a line from time to time
        if (frameCount % INTERVAL == 0)
        {
            stroke(color(random(0, 50), random(50, 200), random(100, 255)));
            strokeWeight(random(2, 10));
            line(random(INTERVAL, width), 0, random(INTERVAL, width), height);
        }
        }



        */
        if (isRunning) {
            //Make sure we are always draw new pixels on the right
            xPos = dataImg.width - 1;
        }
        
        //println("+++++++XPOS  == " + xPos + " || RightEdge == " + (w));

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

        //widgetTemplateButton.draw();
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
                        //******** I think there is a problem here because there is some extra space at the top of the image
                        //arrayCopy(dataImg.pixels, dataImg.width * r + 1, dataImg.pixels, r * dataImg.width, dataImg.width);
                    }
                }

                lastShift += scrollSpeed;
            }
            //for (int i = 0; i < fftLin_L.specSize() - 80; i++) {
            for (int i = 0; i < dataImg.height/2; i++) {
                //LEFT SPECTROGRAM ON TOP
                float hueValue = hueLimit - map((fftAvgs(spectChanSelectTop.activeChan, i)*32), 0, 256, 0, hueLimit);
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
                // colorMode is HSB, the range for hue is 256, for saturation is 100, brightness is 100.
                colorMode(HSB, 256, 100, 100);
                // color for stroke is specified as hue, saturation, brightness.
                stroke(int(hueValue), 100, 80);
                int y_offset = 1;
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
        image(dataImg, 0, -1);
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
        //widgetTemplateButton.setPos(x + w/2 - widgetTemplateButton.but_dx/2, y - navHeight);
        spectChanSelectTop.screenResized(pApplet);
        spectChanSelectBot.screenResized(pApplet);  
        graphX = x + paddingLeft;
        graphY = y + paddingTop;
        graphW = w - paddingRight - paddingLeft;
        graphH = h - paddingBottom - paddingTop;
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        //put your code here...
        //If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
        if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
            /*
            if(widgetTemplateButton.isMouseHere()){
                widgetTemplateButton.setIsActive(true);
            }
            */
        }
        spectChanSelectTop.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked
        spectChanSelectBot.mousePressed(this.dropdownIsActive);
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        /*
        //put your code here...
        if(widgetTemplateButton.isActive && widgetTemplateButton.isMouseHere()){
            selectInput("Select a sound file for playback:", "loadSoundFromFile");
        }

        widgetTemplateButton.setIsActive(false);
        */

    }

    void drawAxes(float scaledW, float scaledH) {
        
        pushStyle();
            fill(255);
            textSize(14);
            text("Time (minutes)", x + w/2 - textWidth("Time (minutes)")/3, y + h - 9);
            noFill();
            stroke(255);
            strokeWeight(2);
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
            for (int i = 0; i <= numHorizAxisDivs; i++) {
                float offset = scaledW * dataImageW * (float(i) / numHorizAxisDivs);
                line(horizAxisX + offset, horizAxisY, horizAxisX + offset, horizAxisY + tickMarkSize);
                text(horizAxisLabel[i], horizAxisX + offset - (textWidth(Integer.toString(vertAxisLabel[i])) / 3), horizAxisY + 30);
            }
        popStyle();
        
        pushStyle();
            pushMatrix();
                rotate(radians(-90));
                translate(-h/2 - textWidth("Frequency (Hz)")/3 + 10, 20);
                fill(255);
                textSize(14);
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

    }

    void drawCenterLine() {
        //draw a thick line down the middle to separate the two plots
        pushStyle();
        stroke(255);
        strokeWeight(3);
        line(graphX, midLineY, graphX + graphW, midLineY);
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

    /*
    void start() {

        this.isActive = true;

        // loop the file
        jingle.loop();
        
        // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
        // note that this needs to be a power of two 
        // and that it means the size of the spectrum will be 1024. 
        // see the online tutorial for more info.
        fftLin_L = new FFT(jingle.bufferSize(), jingle.sampleRate());
        fftLin_R = fftLin_L;
        // calculate the averages by grouping frequency bands linearly. use 30 averages.
        fftLin_L.linAverages(30);
        fftLin_R.linAverages(30);

        img.resize(w, h);
    }

    void stop() {
        this.isActive = false;
        // always close Minim audio classes when you are done with them
        jingle.close();
        // always stop Minim before exiting
        minim.stop();
        //super.stop();
    }
    */
};

/*
void loadSoundFromFile(File selection) {
    if (w_spectrogram.isActive) w_spectrogram.stop();
    w_spectrogram.jingle = minim.loadFile(selection.getAbsolutePath(), 512);
    w_spectrogram.start();
}
*/


//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
//triggered when there is an event in the Spectrogram Widget MaxFreq. Dropdown
void SpectrogramMaxFreq(int n) {
    /* request the selected item based on index n */
    MaxFreq(n);
    w_fft.cp5_widget.getController("MaxFreq").getCaptionLabel().setText(settings.fftMaxFrqArray[n]);
    w_spectrogram.vertAxisLabel = w_spectrogram.vertAxisLabels[n];
    closeAllDropdowns();
    w_spectrogram.dataImageH = w_spectrogram.vertAxisLabel[0] * 2;
    //overwrite the existing image because the sample rate is about to change
    w_spectrogram.dataImg = createImage(w_spectrogram.dataImageW, w_spectrogram.dataImageH, RGB);
}

void SpectrogramSampleRate(int n) {
    /* request the selected item based on index n */
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
        w_spectrogram.setScrollSpeed(5);
    }
    closeAllDropdowns();
}
