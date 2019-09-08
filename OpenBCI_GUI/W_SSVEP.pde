////////////////////////////////////////////////////
//
//    W_SSVEP
//
//    This is an SSVEP Widget that will display frequencies for you to look at, and then observe
//    spikes in brain waves matching that frequency.
//
//    Created by: Leanne Pichay, July 2019
//
////////////////////////////////////////////////////

class W_SSVEP extends Widget {

    //frequency variables offered
    int[] freqs = new int[4];
    boolean[] ssvepOn = {true, true, true, true};

    //coords for each SSVEP — FORMAT {x0, y0, x1, y1}
    float[][] ssvepCoords = {
                             {0,0,0,0},
                             {0,0,0,0},
                             {0,0,0,0},
                             {0,0,0,0}
                                        };

    //Limiting dimension variable
    int s;

    //toggle showAbout
    boolean showAbout;

    //determine if height of widget > width
    boolean heightLarger;

    //Widget CP5s
    ControlP5 cp5_ssvep; //For all CP5 elements within the SSVEP widget
    int dropdownWidth_freq = 115;
    String[] dropdownNames = {"Frequency_1", "Frequency_2", "Frequency_3", "Frequency_4"};
    List<String> dropdownOptions = new ArrayList<String>();
    boolean freqDropdownsShouldBeClosed = false;

    public ChannelSelect ssvepChanSelect;

    //---------NETWORKING VARS
    float[] ssvepData = new float[4];
    public int  numActiveChannels;

    boolean configIsVisible = false;
    boolean layoutIsVisible = false;

    String ssvepHelpText = "For best results, set the GUI framerate to 60fps.\n\n"
                            + "The SSVEP Widget(BETA) provides visual stimulation at specific frequencies."
                            + "In response to looking at one of the SSVEPs, you will see an increase in brain activity at that frequency in the FFT plot. "
                            + "Make sure to select the electrodes that align with the back of your head, where the visual stimulus will be recognized.\n\n"
                            + "You can stop/start each SSVEP by clicking on it.\n\n"
                            + "This widget is currently in beta mode and requires more input and testing from the OpenBCI Community.";
    int ssvepHelpTextFontSize = 16;
    Button infoButton;

    W_SSVEP(PApplet _parent) {

        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)
        
        addDropdown("NumberSSVEP", "# SSVEPs", Arrays.asList("1", "2", "3", "4"), 0);
        // showAbout = true;
        cp5_ssvep = new ControlP5(pApplet);
        ssvepChanSelect = new ChannelSelect(pApplet, x, y, w, navH, "SSVEP_Channels");

        for (int i = 0; i < 9; i++) {
            dropdownOptions.add(String.valueOf(i+7) + " Hz");
        }
        
        //init cp5 dropdowns in reverse so ssvep dropdwns 1 & 2 draw over 3 & 4
        for (int i = dropdownNames.length - 1; i >= 0; i--) {
            createDropdown(dropdownNames[i], dropdownOptions);
        }

        if (h > w) {
            heightLarger = true;
            s = h;
        } else {
            heightLarger = false;
            s = w;
        }

        //Activate default channels
        numActiveChannels = 2;
        int firstChan;
        int secondChan;
        if (nchan == 4) {
            firstChan = 2;
            secondChan = 3;
        } else {
            firstChan = 6;
            secondChan = 7;
        }
        ssvepChanSelect.checkList.activate(firstChan);
        ssvepChanSelect.checkList.activate(secondChan);
        ssvepChanSelect.activeChan.add(firstChan);
        ssvepChanSelect.activeChan.add(secondChan);

        cp5_ssvep.setAutoDraw(false);
        showAbout = false;        //set Default start value for showing about section as fault

        infoButton = new Button(x + w - 80, y - navH + 2, 18, 18, "?", 14);
        infoButton.setCornerRoundess((int)(navHeight-6));
        infoButton.setFont(p5,12);
        infoButton.setColorNotPressed(color(57,128,204));
        infoButton.setFontColorNotActive(color(255));
        infoButton.setHelpText("Click this button to view details on the SSVEP Widget.");
        infoButton.hasStroke(false);
    }

    void update() {
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        //Lock/unlock the controllers within networking widget when using TopNav Objects
        //Also locks dropdown 2 when #SSVEPs dropdown is open
        lockUnlockControllersAsNeeded();

        if (settings.numSSVEPs == 0) {  // 1 SSVEP
            freqs[0] = updateFreq(1);
        } else if (settings.numSSVEPs == 1) {
            freqs[0] = updateFreq(1);
            freqs[1] = updateFreq(2);
        } else if (settings.numSSVEPs == 2) {
            freqs[0] = updateFreq(1);
            freqs[1] = updateFreq(2);
            freqs[2] = updateFreq(3);
        } else if (settings.numSSVEPs == 3) {
            freqs[0] = updateFreq(1);
            freqs[1] = updateFreq(2);
            freqs[2] = updateFreq(3);
            freqs[3] = updateFreq(4);
        }

        //put the frequency dropdowns in the right place
        setDropdownPositions();
        if (freqDropdownsShouldBeClosed) {
            freqDropdownsShouldBeClosed = false;
        } else {
            //and open or close dropdowns based on user interaction on hover
            openCloseDropdowns();
        }

        //Update channel checkboxes and active channels
        ssvepChanSelect.update(x, y, w);

        //save the number of active channels to be analyzed (e.g. ch7+ch8 = 2 active channels)
        numActiveChannels = ssvepChanSelect.activeChan.size();
        
        //if the system is running, process SSVEP data
        if (isRunning) {
            ssvepData = processData();
            //println(ssvepData);
        }

        
    } //end of update loop

    void draw() {
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        pushStyle();
        //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        fill(0);
        rect(x, y, w, h);
        popStyle();

        pushStyle();
        ssvepChanSelect.draw();
        infoButton.draw();
        popStyle();

        //left side
        if (settings.numSSVEPs == 0) {  // 1 SSVEP
            //(String colour, int freq, float wFactor, float hFactor, float hOffset, float size)
            drawSSVEP("blue", freqs[0], 0.5, 0.5, 0, s/4);
        } else if (settings.numSSVEPs == 1) { // 2 SSVEPs
            if (heightLarger) {
                drawSSVEP("blue", freqs[0], 0.5, 0.20, 0, s/5);
                drawSSVEP("red", freqs[1], 0.5, 0.70, 0, s/5);
            } else {
                drawSSVEP("blue", freqs[0], 0.20, 0.5, 0, s/5);
                drawSSVEP("red", freqs[1], 0.70, 0.5, 0, s/5);
            }
        } else if (settings.numSSVEPs == 2) { // 3 SSVEPs
            if (heightLarger) {
                //If ssveps are arranged vertically, Add 0.1 to heightFactor with height offset of 30
                drawSSVEP("blue", freqs[0], 0.5, 0.1, 30.0, s/5);
                drawSSVEP("red", freqs[1], 0.5, 1.0/3 + 0.1, 30.0, s/5);
                drawSSVEP("green", freqs[2], 0.5, 2.0/3 + 0.1, 30.0, s/5);
            } else {
                drawSSVEP("blue", freqs[0], 0.125, 0.5, 0, s/5);
                drawSSVEP("red", freqs[1], 0.5, 0.5, 0, s/5);
                drawSSVEP("green", freqs[2], 0.875, 0.5, 0, s/5);
            }
        } else if (settings.numSSVEPs == 3) { // 4 SSVEPs
            float sz = s/6;
            drawSSVEP("blue", freqs[0], 0.25, 0.25, 0, s/6);
            drawSSVEP("red", freqs[1], 0.75, 0.25, 0, s/6);
            drawSSVEP("green", freqs[2], 0.25, 0.75, 0, s/6);
            drawSSVEP("yellow", freqs[3], 0.75, 0.75, 0, s/6);
        }

        //draw backgrounds to dropdown scrollableLists ... unfortunately ControlP5 doesn't have this by default, so we have to hack it to make it look nice...
        pushStyle();
        fill(100);
        for (int i = 1; i <= settings.numSSVEPs + 1; i++) {
            String c = "Frequency_" + i;
            rect(cp5_ssvep.getController(c).getPosition()[0] - 1, cp5_ssvep.getController(c).getPosition()[1] - 1, dropdownWidth_freq + 2, cp5_ssvep.getController(c).getHeight()+2);
        }

        //Draw all cp5 elements within the SSVEP widget
        //Only draws elements that are visible
        //Drawing here draws on top of scrollableList background rectangles that were just drawn
        cp5_ssvep.draw();

        //If widget help button was clicked, show about details
        if (showAbout) {
            stroke(220);
            fill(20);
            rect(x + 20, y + 20, w - 40, h- 40);
            textAlign(LEFT, TOP);
            textFont(p3, ssvepHelpTextFontSize);
            fill(250);
            text(ssvepHelpText, x + 30, y + 30, w - 60, h -60);
        }

        popStyle();

    } //end of draw loop

    void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //Resets the CP5 origin when the app is resized
        cp5_ssvep.setGraphics(pApplet, 0, 0);

        if (h > w) {
            heightLarger = true;
            s = w;
        } else {
            heightLarger = false;
            s = h;
        }

        infoButton.setPos(x + w - 100, y - navH + 2);
        
        setFreqDropdownSizes();

        ssvepChanSelect.screenResized(pApplet);
    }
    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        if (!this.dropdownIsActive) {

            if (infoButton.isMouseHere()) {
                infoButton.setIsActive(true);
            }


            for(int i = 0; i <= settings.numSSVEPs; i++){
                if (mouseX > ssvepCoords[i][0] && mouseY > ssvepCoords[i][1] && mouseX < ssvepCoords[i][2] && mouseY < ssvepCoords[i][3]){
                    ssvepOn[i] = !ssvepOn[i];
                }
            }
        }
        ssvepChanSelect.mousePressed(this.dropdownIsActive);
    }

    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        if (infoButton.isActive && infoButton.isMouseHere()) {
            showAbout = !showAbout;
        }
        infoButton.setIsActive(false);
    }

    void createDropdown(String name, List<String> _items) {
        int _dropdownHeight = (dropdownOptions.size() + 1) * (navH - 2);
        cp5_ssvep.addScrollableList(name)
            .setOpen(false)
            .setColorBackground(color(0)) // text field bg color
            .setColorValueLabel(color(130))       // text color
            .setColorCaptionLabel(color(130))
            .setColorForeground(color(60))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
            .setSize(dropdownWidth_freq, _dropdownHeight)
            .addItems(_items)
            .setVisible(false)
            .setBarHeight(20)
            .setItemHeight(20)
            ;

        cp5_ssvep.getController(name)
            .getCaptionLabel()
            .toUpperCase(false)
            .setFont(h4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;

        cp5_ssvep.getController(name)
            .getValueLabel()
            .toUpperCase(false)
            .setFont(h4)
            .setSize(12)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
    }

    void createStartButton(int wFactor, int hFactor, int ssvepNo) {
        int d;
        if (settings.numSSVEPs != 3) {
            d = h/4;
        } else {
            d = h/6;
        }
    }

    void setFreqDropdownSizes() {
        //int dropdownsItemsToShow = int((h0 * widgetDropdownScaling) / (navH - 4));
        int _dropdownHeight = (dropdownOptions.size() + 1) * (navH - 2);
        for(int i = 0; i <= settings.numSSVEPs; i++){
            cp5_ssvep.getController(dropdownNames[i])
                    .setSize(dropdownWidth_freq, _dropdownHeight);
                    ;
        }
    }

    void drawSSVEP(String colour, int freq, float wFactor, float hFactor, float hOffset, float size) {
        boolean whiteBG = false;
        if (colour.equals("blue")){
            whiteBG = true;
        }

        int r = 0;
        int g = 0;
        int b = 0;

        int ind = 0;

        if (colour.equals("blue")){
            b = 255;
        } else if (colour.equals("red")) {
            r = 255;
            ind = 1;
        } else if (colour.equals("green")) {
            g = 255;
            ind = 2;
        } else if (colour.equals("yellow")) {
            r = 255;
            g = 255;
            ind = 3;
        }

       if (freq == 0 || !ssvepOn[ind] || millis()%(2*(500/freq)) >= (500/freq)) {
            fill(r,g,b);
            rect(x + (w * wFactor) - (size/2), y + (h*hFactor) + hOffset - (size/2), size, size);
            pushStyle();
            noFill();
            if (whiteBG) {
               stroke(255);
            } else {
               stroke(0);
            }
            rect(x + (w * wFactor) - (size/4), y + (h*hFactor) + hOffset - (size/4), size/2, size/2);
            popStyle();
        } else {
            fill(0);
            rect(x + (w * wFactor) - (size/2), y + (h*hFactor) + hOffset - (size/2), size, size);
            pushStyle();
            noFill();
            stroke(r,g,b);
            rect(x + (w * wFactor) - (size/10), y + (h*hFactor) + hOffset - (size/10), size/5, size/5);
            popStyle();
        }

        //---------- Store Coords
        ssvepCoords[ind][0] = x + w * wFactor - size/2;
        ssvepCoords[ind][1] = y + h * hFactor - size/2;
        ssvepCoords[ind][2] = x + w * wFactor + size/2;
        ssvepCoords[ind][3] = y + h * hFactor + size/2;

    }

   //------set position of all dropdowns
   void setDropdownPositions() {
        resetDropdowns();

        int _wOffset = -dropdownWidth_freq/2;

        if (settings.numSSVEPs == 0) {
            //(int dropdownNo, float wFactor, float wOffset, float hFactor, float hOffset)
            setDropdown(1, 0.5, - s/8, 0, 30.0);
        } else if (settings.numSSVEPs == 1) {
            if (heightLarger) {
                setDropdown(1, 0, 10.0, 0.25, -s/8);
                setDropdown(2, 0, 10.0, 0.75, -s/8);
            } else {
                setDropdown(1, 0.2, _wOffset, 0, 30.0);
                setDropdown(2, 0.7, _wOffset, 0, 30.0);
            }
        } else if (settings.numSSVEPs == 2) {
            if (heightLarger) {
                setDropdown(1, 0, 10.0, 0, 30.0);
                setDropdown(2, 0, 10.0, 1.0/3, 30.0);
                setDropdown(3, 0, 10.0, 2.0/3, 30.0);
            } else {
                //Freq1 Dropdown
                setDropdown(1, 0.125, _wOffset, 0, 30.0);
                setDropdown(2, 0.5, _wOffset, 0, 30.0);
                setDropdown(3, 0.875, _wOffset, 0, 30.0);
            }
        } else if (settings.numSSVEPs == 3) {
            setDropdown(1, 0, 10.0, 0, navH + 4);
            setDropdown(2, 1.0, (-1.0/6) - 130f, 0, navH + 4);
            setDropdown(3, 0, 10.0, 0.55, 0);
            setDropdown(4, 1.0, (-1.0/6) - 130f, 0.55, 0);
        }
   }

    //------- set the Position of an individual dropdown
    void setDropdown(int dropdownNo, float wFactor, float wOffset, float hFactor, float hOffset){
        cp5_ssvep.getController("Frequency_"+dropdownNo).setPosition(x + (w * wFactor) + wOffset, y + (h * hFactor) + hOffset);
        cp5_ssvep.get(ScrollableList.class, "Frequency_"+dropdownNo).setVisible(true);
    }

    void resetDropdowns() {
        cp5_ssvep.get(ScrollableList.class, "Frequency_1").setVisible(false);
        cp5_ssvep.get(ScrollableList.class, "Frequency_2").setVisible(false);
        cp5_ssvep.get(ScrollableList.class, "Frequency_3").setVisible(false);
        cp5_ssvep.get(ScrollableList.class, "Frequency_4").setVisible(false);
    }

    void openCloseDropdowns() {
        for(int i = 1; i <= settings.numSSVEPs + 1; i++){
            if (cp5_ssvep.get(ScrollableList.class, "Frequency_"+i).isOpen()) {
                if (!cp5_ssvep.get(ScrollableList.class, "Frequency_"+i).isMouseOver()) {
                    cp5_ssvep.get(ScrollableList.class, "Frequency_"+i).close();
                }
            } else {
                if (cp5_ssvep.get(ScrollableList.class, "Frequency_"+i).isMouseOver()) {
                    cp5_ssvep.get(ScrollableList.class, "Frequency_"+i).open();
                }
            }
        }
    }

    void closeAllDropdowns() {
        freqDropdownsShouldBeClosed = true;
        this.cp5_ssvep.get(ScrollableList.class, "Frequency_1").close();
        this.cp5_ssvep.get(ScrollableList.class, "Frequency_2").close();
        this.cp5_ssvep.get(ScrollableList.class, "Frequency_3").close();
        this.cp5_ssvep.get(ScrollableList.class, "Frequency_4").close();
    }

    void lockUnlockControllersAsNeeded() {
        //If neither widget selection or #SSVEPs dropdown is active...
        if (!dropdownIsActive) {
            //Unlock all Frequency dropdowns and proceed to check for other cases
            cp5_ssvep.get(ScrollableList.class, "Frequency_1").unlock();
            cp5_ssvep.get(ScrollableList.class, "Frequency_2").unlock();
            cp5_ssvep.get(ScrollableList.class, "Frequency_3").unlock();
            cp5_ssvep.get(ScrollableList.class, "Frequency_4").unlock();
            //Check for state change in topNav objects
            if ((topNav.configSelector.isVisible != configIsVisible) || (topNav.layoutSelector.isVisible != layoutIsVisible)) {
                //Lock/unlock the controllers within networking widget when using TopNav Objects
                if (topNav.configSelector.isVisible || topNav.layoutSelector.isVisible) {
                    cp5_ssvep.get(ScrollableList.class, "Frequency_1").lock();
                    cp5_ssvep.get(ScrollableList.class, "Frequency_2").lock();
                    cp5_ssvep.get(ScrollableList.class, "Frequency_3").lock();
                    cp5_ssvep.get(ScrollableList.class, "Frequency_4").lock();

                } else {
                    cp5_ssvep.get(ScrollableList.class, "Frequency_1").unlock();
                    cp5_ssvep.get(ScrollableList.class, "Frequency_2").unlock();
                    cp5_ssvep.get(ScrollableList.class, "Frequency_3").unlock();
                    cp5_ssvep.get(ScrollableList.class, "Frequency_4").unlock();
                }

                //lock/unlock dropdowns when Widget Selector is in use
                if (cp5_widget.get(ScrollableList.class, "WidgetSelector").isOpen()) {
                    cp5_ssvep.get(ScrollableList.class, "Frequency_1").lock();
                } else {
                    cp5_ssvep.get(ScrollableList.class, "Frequency_1").unlock();
                }

                //lock/unlock lower Freq4 dropdown when Freq2 dropdown is in use in 4 SSVEP use case
                if (cp5_ssvep.get(ScrollableList.class, "Frequency_2").isOpen()) {
                    cp5_ssvep.getController("Frequency_2").bringToFront();
                    cp5_ssvep.get(ScrollableList.class, "Frequency_4").lock();
                } else {
                    cp5_ssvep.get(ScrollableList.class, "Frequency_4").setVisible(true).unlock();
                }

                //lock/unlock lower Freq3 dropdown when Freq1 dropdown is in use in 4 SSVEP use case
                if (cp5_ssvep.get(ScrollableList.class, "Frequency_1").isOpen() && settings.numSSVEPs == 3) {
                    cp5_ssvep.getController("Frequency_1").bringToFront();
                    cp5_ssvep.get(ScrollableList.class, "Frequency_3").lock();

                } else {
                    cp5_ssvep.get(ScrollableList.class, "Frequency_3").unlock();
                }

                //manage dropdowns in 3 SSVEP use case
                if (heightLarger && settings.numSSVEPs == 2) {
                    // lock freq2 if freq1 is in use
                    if (cp5_ssvep.get(ScrollableList.class, "Frequency_1").isOpen()){
                        cp5_ssvep.get(ScrollableList.class, "Frequency_2").bringToFront();
                        cp5_ssvep.get(ScrollableList.class, "Frequency_2").lock();
                    } else {
                        cp5_ssvep.get(ScrollableList.class, "Frequency_2").unlock();
                    }

                    // lock freq3 if freq2 is in use
                    if (cp5_ssvep.get(ScrollableList.class, "Frequency_2").isOpen()){
                        cp5_ssvep.get(ScrollableList.class, "Frequency_3").lock();
                        cp5_ssvep.getController("Frequency_2").bringToFront();
                    } else {
                        cp5_ssvep.get(ScrollableList.class, "Frequency_3").unlock();
                    }
                }

                configIsVisible = topNav.configSelector.isVisible;
                layoutIsVisible = topNav.layoutSelector.isVisible;
            } //end topNav state change check
        } else {
            //If using the widget selector or #SSVEPs dropdowns, lock frequency dropdowns
            cp5_ssvep.get(ScrollableList.class, "Frequency_1").lock();
            cp5_ssvep.get(ScrollableList.class, "Frequency_2").lock();
            cp5_ssvep.get(ScrollableList.class, "Frequency_3").lock();
            cp5_ssvep.get(ScrollableList.class, "Frequency_4").lock();
        }
    }

    int updateFreq(int controllerNum) {
        String label = cp5_ssvep.get(ScrollableList.class, "Frequency_"+controllerNum).getLabel();
        if (!label.equals("Frequency_"+controllerNum)) {
            String[] s = split(label, " ");
            return Integer.valueOf(s[0]);
        }
        return -1;
    }

    float[] processData() {
        int activeSSVEPs = settings.numSSVEPs + 1;
        //println("NUM SSVEPs = " + activeSSVEPs);

        float[] peakData = new float[4];     //uV at the selected SSVEP freqencies
        float[] backgroundData = new float[4];   //uV at all other frequencies
        float[] finalData = new float[4];    //ratio between peak and background

        for (int i = 0; i < activeSSVEPs; i++) {
            if (freqs[i] > 0) {
                //calculate peak uV
                float sum = 0;
                for (int j = 0; j < ssvepChanSelect.activeChan.size(); j++) {
                    int chan = ssvepChanSelect.activeChan.get(j);
                    sum += fftBuff[chan].getFreq(freqs[i]);
                }
                float avg = sum/numActiveChannels;
                peakData[i] = avg;
                //println("PEAK DATA: " + peakData[i]);

                //calculate background uV in all channels but the given channel
                sum = 0;
                for (int f = 7; f <= 15; f++) {         //where f represents any of the frequencies selectable
                    if (f <  freqs[i] || f > freqs[i]) {
                        int freqSum = 0;
                        for (int j = 0; j < ssvepChanSelect.activeChan.size(); j++) {
                            int chan = ssvepChanSelect.activeChan.get(j);
                            freqSum += fftBuff[chan].getFreq(f);
                        }
                        sum += freqSum/8;
                    }
                }
                backgroundData[i] = sum;
                //println("BACKGROUND DATA: " + backgroundData[i]);
                if (backgroundData[i] != 0) {
                    finalData[i] = peakData[i]/backgroundData[i];
                } else {
                    finalData[i] = peakData[i];
                }
            } else {
                finalData[i] = 0;
            }
        }
        //println(finalData);
        return finalData;
    } //end of processData

    /*
    
    ///Here is another algorithm from older code that finds peak frequencies...

    void findPeakFrequency(FFT[] fftData, int Ichan) {

        //loop over each EEG channel and find the frequency with the peak amplitude
        float FFT_freq_Hz, FFT_value_uV;
        //for (int Ichan=0;Ichan < nchan; Ichan++) {

        //clear the data structure that will hold the peak for this channel
        detectedPeak[Ichan].clear();

        //loop over each frequency bin to find the one with the strongest peak
        int nBins =  fftData[Ichan].specSize();
        for (int Ibin=0; Ibin < nBins; Ibin++) {
        FFT_freq_Hz = fftData[Ichan].indexToFreq(Ibin); //here is the frequency of htis bin

            //is this bin within the frequency band of interest?
        if ((FFT_freq_Hz >= min_allowed_peak_freq_Hz) && (FFT_freq_Hz <= max_allowed_peak_freq_Hz)) {
            //we are within the frequency band of interest

            //get the RMS voltage (per bin)
            FFT_value_uV = fftData[Ichan].getBand(Ibin) / ((float)nBins); 
            //FFT_value_uV = fftData[Ichan].getBand(Ibin);

            //decide if this is the maximum, compared to previous bins for this channel
            if (FFT_value_uV > detectedPeak[Ichan].rms_uV_perBin) {
            //this is bigger, so hold onto this value as the new "maximum"
            detectedPeak[Ichan].bin  = Ibin;
            detectedPeak[Ichan].freq_Hz = FFT_freq_Hz;
            detectedPeak[Ichan].rms_uV_perBin = FFT_value_uV;
            }
        } //close if within frequency band
        } //close loop over bins

        //loop over the bins again (within the sense band) to get the average background power, excluding the bins on either side of the peak
        float sum_pow=0;
        int count=0;
        for (int Ibin=0; Ibin < nBins; Ibin++) {
        FFT_freq_Hz = fftData[Ichan].indexToFreq(Ibin);
        if ((FFT_freq_Hz >= min_allowed_peak_freq_Hz) && (FFT_freq_Hz <= max_allowed_peak_freq_Hz)) {
            if ((Ibin < detectedPeak[Ichan].bin - 1) || (Ibin > detectedPeak[Ichan].bin + 1)) {
            FFT_value_uV = fftData[Ichan].getBand(Ibin) / ((float)nBins);  //get the RMS per bin
            sum_pow+=pow(FFT_value_uV, 2.0);
            count++;
            }
        }
        }
        //compute mean
        detectedPeak[Ichan].background_rms_uV_perBin = sqrt(sum_pow / count);

        //decide if peak is big enough to be detected
        detectedPeak[Ichan].SNR_dB = 20.0*(float)java.lang.Math.log10(detectedPeak[Ichan].rms_uV_perBin / detectedPeak[Ichan].background_rms_uV_perBin);

        //kludge
        //if ((detectedPeak[Ichan].freq_Hz >= processing_band_low_Hz[0]) && (detectedPeak[Ichan].freq_Hz <= processing_band_high_Hz[0])) {
        //  if (detectedPeak[Ichan].SNR_dB >= detection_thresh_dB-2.0) {
        //    detectedPeak[Ichan].threshold_dB = detection_thresh_dB;
        //    detectedPeak[Ichan].isDetected = true;
        //  }
        //} else {
        //  if (detectedPeak[Ichan].SNR_dB >= detection_thresh_dB) {
        //    detectedPeak[Ichan].threshold_dB = detection_thresh_dB;
        //    detectedPeak[Ichan].isDetected = true;
        //  }
        //}

        //} // end loop over channels
    } //end method findPeakFrequency
    */

} //end of ssvep class

//Corresponds to the number of SSVEPs dropdown menu at the top right of the SSVEP widget
void NumberSSVEP(int n) {
    settings.numSSVEPs = n;
    closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}

///The following functions correspond to the ScrollableLists of the same name in the SSVEP widget
void Frequency_1(int n) {
    w_ssvep.closeAllDropdowns();
}

void Frequency_2(int n) {
    w_ssvep.closeAllDropdowns();
}

void Frequency_3(int n) {
    w_ssvep.closeAllDropdowns();
}

void Frequency_4(int n) {
    w_ssvep.closeAllDropdowns();
}

