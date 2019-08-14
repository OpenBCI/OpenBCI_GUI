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
    String[] dropdownNames = {"Frequency 1", "Frequency 2", "Frequency 3", "Frequency 4"};
    List<String> dropdownOptions = new ArrayList<String>();

    public ChannelSelect ssvepChanSelect;

    //---------NETWORKING VARS
    float[] ssvepData = new float[4];
    public int  numActiveChannels;

    boolean configIsVisible = false;
    boolean layoutIsVisible = false;

    String ssvepHelpText = "The SSVEP Widget allows for visual stimulation at specific frequencies.\n\n"
                            + "In response to looking at one of the SSVEPs, you will see an increase in brain activity at that frequency in the FFT plot. "
                            + "Make sure to select the electrodes that align with the back of your head, where the visual stimulus will be recognized.\n\n"
                            + "You can stop/start each SSVEP by clicking on it.\n\n"
                            + "For best results, set the GUI framerate to 60fps.\n\n";
    int ssvepHelpTextFontSize = 16;

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

        //Activate channel checkboxes 7 and 8 by default
        numActiveChannels = 2;
        ssvepChanSelect.checkList.activate(6);
        ssvepChanSelect.checkList.activate(7);
        ssvepChanSelect.activeChan.add(6);
        ssvepChanSelect.activeChan.add(7);

        cp5_ssvep.setAutoDraw(false);
        showAbout = false;        //set Default start value for showing about section as fault
    }

    void update() {
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        if ((topNav.configSelector.isVisible != configIsVisible) || (topNav.layoutSelector.isVisible != layoutIsVisible)) {
            //lock/unlock the controllers within networking widget when using TopNav Objects
            if (topNav.configSelector.isVisible || topNav.layoutSelector.isVisible) {
                cp5_ssvep.get(ScrollableList.class, "Frequency 1").lock();
                cp5_ssvep.get(ScrollableList.class, "Frequency 2").lock();
                cp5_ssvep.get(ScrollableList.class, "Frequency 3").lock();
                cp5_ssvep.get(ScrollableList.class, "Frequency 4").lock();

            } else {
                cp5_ssvep.get(ScrollableList.class, "Frequency 1").unlock();
                cp5_ssvep.get(ScrollableList.class, "Frequency 2").unlock();
                cp5_ssvep.get(ScrollableList.class, "Frequency 3").unlock();
                cp5_ssvep.get(ScrollableList.class, "Frequency 4").unlock();
            }

            //lock/unlock dropdowns when Widget Selector is in use
            if (cp5_widget.get(ScrollableList.class, "WidgetSelector").isOpen()) {
                cp5_ssvep.get(ScrollableList.class, "Frequency 1").lock();
            } else {
                cp5_ssvep.get(ScrollableList.class, "Frequency 1").unlock();
            }

            //lock/unlock lower Freq4 dropdown when Freq2 dropdown is in use in 4 SSVEP use case
            if (cp5_ssvep.get(ScrollableList.class, "Frequency 2").isOpen()) {
                cp5_ssvep.getController("Frequency 2").bringToFront();
                cp5_ssvep.get(ScrollableList.class, "Frequency 4").lock();
            } else {
                cp5_ssvep.get(ScrollableList.class, "Frequency 4").setVisible(true).unlock();
            }

            //lock/unlock lower Freq3 dropdown when Freq1 dropdown is in use in 4 SSVEP use case
            if (cp5_ssvep.get(ScrollableList.class, "Frequency 1").isOpen() && settings.numSSVEPs == 3) {
                cp5_ssvep.getController("Frequency 1").bringToFront();
                cp5_ssvep.get(ScrollableList.class, "Frequency 3").lock();

            } else {
                cp5_ssvep.get(ScrollableList.class, "Frequency 3").unlock();
            }

            //manage dropdowns in 3 SSVEP use case
            if (heightLarger && settings.numSSVEPs == 2) {
               // lock freq2 if freq1 is in use
               if (cp5_ssvep.get(ScrollableList.class, "Frequency 1").isOpen()){
                   cp5_ssvep.get(ScrollableList.class, "Frequency 2").bringToFront();
                   cp5_ssvep.get(ScrollableList.class, "Frequency 2").lock();
               } else {
                   cp5_ssvep.get(ScrollableList.class, "Frequency 2").unlock();
               }

               // lock freq3 if freq2 is in use
               if (cp5_ssvep.get(ScrollableList.class, "Frequency 2").isOpen()){
                   cp5_ssvep.get(ScrollableList.class, "Frequency 3").lock();
                   cp5_ssvep.getController("Frequency 2").bringToFront();
               } else {
                   cp5_ssvep.get(ScrollableList.class, "Frequency 3").unlock();
               }
            }

            configIsVisible = topNav.configSelector.isVisible;
            layoutIsVisible = topNav.layoutSelector.isVisible;

        }

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

        setDropdownPositions();

        //Update channel checkboxes and active channels
        ssvepChanSelect.update(x, y, w);

        numActiveChannels = ssvepChanSelect.activeChan.size();
        if (isRunning) {
            ssvepData = processData();
            //println(ssvepData);
        }
    }

    void draw() {
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        fill(0);
        rect(x, y, w, h);
        pushStyle();

        popStyle();
        ssvepChanSelect.draw();
        pushStyle();

        //left side
        if (settings.numSSVEPs == 0) {  // 1 SSVEP
            //(String colour, int freq, float wFactor, float hFactor, float hOffset, float size)
            drawSSVEP("blue", freqs[0], 0.5, 0.5, 0.0, s/4);
        } else if (settings.numSSVEPs == 1) { // 2 SSVEPs
            if (heightLarger) {
                drawSSVEP("blue", freqs[0], 0.5, 0.20, 0.0, s/5);
                drawSSVEP("red", freqs[1], 0.5, 0.70, 0.0, s/5);
            } else {
                drawSSVEP("blue", freqs[0], 0.20, 0.5, 0.0, s/5);
                drawSSVEP("red", freqs[1], 0.70, 0.5, 0.0, s/5);
            }
        } else if (settings.numSSVEPs == 2) { // 3 SSVEPs
            if (heightLarger) {
                //If ssveps are arranged vertically, Add 0.1 to heightFactor with height offset of 30
                drawSSVEP("blue", freqs[0], 0.5, 0.1, 30.0, s/5);
                drawSSVEP("red", freqs[1], 0.5, 1.0/3 + 0.1, 30.0, s/5);
                drawSSVEP("green", freqs[2], 0.5, 2.0/3 + 0.1, 30.0, s/5);
            } else {
                drawSSVEP("blue", freqs[0], 0.125, 0.5, 0.0, s/5);
                drawSSVEP("red", freqs[1], 0.5, 0.5, 0.0, s/5);
                drawSSVEP("green", freqs[2], 0.875, 0.5, 0.0, s/5);
            }
        } else if (settings.numSSVEPs == 3) { // 4 SSVEPs
            float sz = s/6;
            drawSSVEP("blue", freqs[0], 0.25, 0.25, 0.0, s/6);
            drawSSVEP("red", freqs[1], 0.75, 0.25, 0.0, s/6);
            drawSSVEP("green", freqs[2], 0.25, 0.75, 0.0, s/6);
            drawSSVEP("yellow", freqs[3], 0.75, 0.75, 0.0, s/6);
        }

        //Draw all cp5 elements within the SSVEP widget
        //Only draws elements that are visible
        cp5_ssvep.draw();

        // show about details
        if (showAbout) {
            stroke(220);
            fill(20);
            rect(x + 20, y + 20, w - 40, h- 40);
            textAlign(LEFT, TOP);
            textSize(ssvepHelpTextFontSize);
            fill(250);
            text(ssvepHelpText, x + 30, y + 30, w - 60, h -60);
        }

        stroke(0);
        noFill();
        ellipse(x + w - 80, y - navH/2 , 18, 18);
        fill(0);
        textAlign(CENTER, CENTER);
        if (showAbout) {
            text("x", x + w - 80, y - navH/2 - 2);
        }
        else {
            text("?", x + w - 80, y - navH/2 - 2);
        }

    }

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

        ssvepChanSelect.screenResized(pApplet);
    }
    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        if (!this.dropdownIsActive) {
            if (dist(mouseX, mouseY, x + w - 80, y - navH/2) <= 9){
                showAbout = !showAbout;
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
    }

    void createDropdown(String name, List<String> _items) {
        cp5_ssvep.addScrollableList(name)
            .setOpen(false)
            .setColorBackground(color(0)) // text field bg color
            .setColorValueLabel(color(130))       // text color
            .setColorCaptionLabel(color(130))
            .setColorForeground(color(60))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
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
            ;

        cp5_ssvep.getController(name)
            .getValueLabel()
            .toUpperCase(false)
            .setFont(h4)
            .setSize(12)
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

    void resetDropdowns() {
        cp5_ssvep.get(ScrollableList.class, "Frequency 1").setVisible(false);
        cp5_ssvep.get(ScrollableList.class, "Frequency 2").setVisible(false);
        cp5_ssvep.get(ScrollableList.class, "Frequency 3").setVisible(false);
        cp5_ssvep.get(ScrollableList.class, "Frequency 4").setVisible(false);
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

        if (settings.numSSVEPs == 0) {
            //(int dropdownNo, float wFactor, float wOffset, float hFactor, float hOffset)
            setDropdown(1, 0.5, - s/8, 0, 30.0);
        } else if (settings.numSSVEPs == 1) {
            if (heightLarger) {
                setDropdown(1, 0, 10.0, 0.25, -s/8);
                setDropdown(2, 0, 10.0, 0.75, -s/8);
            } else {
                setDropdown(1, 0.25, -s/8, 0, 30.0);
                setDropdown(2, 0.75, -s/8, 0, 30.0);
            }
        } else if (settings.numSSVEPs == 2) {
            if (heightLarger) {
                setDropdown(1, 0, 10.0, 0.0, 30.0);
                setDropdown(2, 0, 10.0, 1.0/3, 30.0);
                setDropdown(3, 0, 10.0, 2.0/3, 30.0);
            } else {
                //Freq1 Dropdown
                setDropdown(1, 0.125, -s/8, 0, 30.0);
                setDropdown(2, 0.5, -s/8, 0.0, 30.0);
                setDropdown(3, 0.825, -s/8, 0.0, 30.0);
            }
        } else if (settings.numSSVEPs == 3) {
            setDropdown(4, 1.0, (-1.0/6) - 100.0, 0.5, -15);
            setDropdown(3, 0.0, 10.0, 0.5, -15);
            setDropdown(1, 0.0, 10.0, 0.0, 30.0);
            setDropdown(2, 1.0, (-1.0/6) - 100.0, 0.0, 30.0);
        }
   }

    //------- set the Position of an individual dropdown
    void setDropdown(int dropdownNo, float wFactor, float wOffset, float hFactor, float hOffset){
        cp5_ssvep.getController("Frequency "+dropdownNo).setPosition(x + (w * wFactor) + wOffset, y + (h * hFactor) + hOffset);
        cp5_ssvep.get(ScrollableList.class, "Frequency "+dropdownNo).setVisible(true);
    }

    int updateFreq(int controllerNum) {
        String label = cp5_ssvep.get(ScrollableList.class, "Frequency "+controllerNum).getLabel();
        if (!label.equals("Frequency "+controllerNum)) {
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
                //println("PEAK DATA: " + backgroundData[i]);

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

                finalData[i] = peakData[i]/backgroundData[i];
            } else {
                finalData[i] = 0;
            }
        }
        //println(finalData);
        return finalData;
    } //end of processData

} //end of ssvep class

void NumberSSVEP(int n) {
    settings.numSSVEPs = n;
    closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}
