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
int ssvepDisplay;

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

    //----------CHANNEL SELECT INFRASTRUCTURE
    ControlP5 cp5_ssvepCheckboxes;   //ControlP5 for which channels to use
    CheckBox checkList;
    //draw checkboxes vars
    int offset;                      //offset on nav bar of checks
    int checkHeight = y0 + navH;

    //checkbox dropdown vars
    boolean channelSelectPressed;
    boolean channelSelectHover;

    //---------NETWORKING VARS
    float[] ssvepData = new float[4];
    //data from checkboxes vars
    int numActiveChannels;
    List<Integer> activeChannels = new ArrayList<Integer>();

    boolean configIsVisible = false;
    boolean layoutIsVisible = false;

    W_SSVEP(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        addDropdown("NumberSSVEP", "# SSVEPs", Arrays.asList("1", "2", "3", "4"), 0);
        // showAbout = true;
        cp5_ssvep = new ControlP5(pApplet);

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

        int checkSize = navH - 4;
        offset = (navH - checkSize)/2;

        channelSelectHover = false;
        channelSelectPressed = false;

        checkList = cp5_ssvep.addCheckBox("channelList")
                              .setPosition(x + 5, y + offset)
                              .setSize(checkSize, checkSize)
                              .setItemsPerRow(nchan)
                              .setSpacingColumn(13)
                              .setSpacingRow(2)
                              .setColorLabel(color(0)) //Set the color of the text label
                              .setColorForeground(color(120)) //checkbox color when mouse is hovering over it
                              .setColorBackground(color(150)) //checkbox background color
                              .setColorActive(color(57, 128, 204)) //checkbox color when active
                              ;


        for (int i = 0; i < nchan; i++) {
          int chNum = i+1;
          cp5_ssvep.get(CheckBox.class, "channelList")
                        .addItem(String.valueOf(chNum), chNum)
                        ;

          checkList.getItem(chNum - 1).setVisible(false);           //set invisible after adding items, so make sure they won't stay invisible
        }

        checkList.activate(6);
        checkList.activate(7);

        numActiveChannels = 2;
        activeChannels.add(6);
        activeChannels.add(7);

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
            if (cp5_ssvep.get(ScrollableList.class, "Frequency 1").isOpen() && ssvepDisplay == 3) {
                cp5_ssvep.getController("Frequency 1").bringToFront();
                cp5_ssvep.get(ScrollableList.class, "Frequency 3").lock();

            } else {
                cp5_ssvep.get(ScrollableList.class, "Frequency 3").unlock();
            }

            //manage dropdowns in 3 SSVEP use case
            if (heightLarger && ssvepDisplay == 2) {
               // lock freq2 if freq1 is in use
               if(cp5_ssvep.get(ScrollableList.class, "Frequency 1").isOpen()){
                   cp5_ssvep.get(ScrollableList.class, "Frequency 2").bringToFront();

                  cp5_ssvep.get(ScrollableList.class, "Frequency 2").lock();

               }
               else{
                 cp5_ssvep.get(ScrollableList.class, "Frequency 2").unlock();
               }

               // lock freq3 if freq2 is in use
               if(cp5_ssvep.get(ScrollableList.class, "Frequency 2").isOpen()){
                  cp5_ssvep.get(ScrollableList.class, "Frequency 3").lock();
                  cp5_ssvep.getController("Frequency 2").bringToFront();
               }
               else{
                 cp5_ssvep.get(ScrollableList.class, "Frequency 3").unlock();
               }
            }

            configIsVisible = topNav.configSelector.isVisible;
            layoutIsVisible = topNav.layoutSelector.isVisible;

        }

        if (ssvepDisplay == 0) {  // 1 SSVEP
            freqs[0] = updateFreq(1);
        } else if (ssvepDisplay == 1) {
            freqs[0] = updateFreq(1);
            freqs[1] = updateFreq(2);
        } else if (ssvepDisplay == 2) {
            freqs[0] = updateFreq(1);
            freqs[1] = updateFreq(2);
            freqs[2] = updateFreq(3);
        } else if (ssvepDisplay == 3) {
            freqs[0] = updateFreq(1);
            freqs[1] = updateFreq(2);
            freqs[2] = updateFreq(3);
            freqs[3] = updateFreq(4);
        }

        if (mouseX > (x + 57) && mouseX < (x + 67) && mouseY < (y - navH*0.25) && mouseY > (y - navH*0.65)) {
            channelSelectHover = true;
            // println(1);
        } else {
            channelSelectHover = false;
            // println(2);
        }

        setDropdownPositions();

        //Update the number of active checks
        int count = 0;
        activeChannels.clear();
        for (int i = 0; i < nchan; i++) {
            if(checkList.getState(i)){
                count++;
                activeChannels.add(i);
            }
        }
        numActiveChannels = count;
        if (isRunning) {
            ssvepData = processData();
            println(ssvepData);
        }
    }

    void draw() {
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        fill(0);
        rect(x,y, w, h);
        pushStyle();

        //channel select button
        if (!channelSelectPressed) {
            if(!channelSelectHover){
                fill(0);
            } else {
                fill(130);
            }
            triangle(x + 57.0, y - navH*0.65, x + 62.0, y - navH*0.25, x + 67.0, y - navH*0.65);
        } else {
            if(!channelSelectHover){
                fill(0);
            } else {
                fill(130);
            }
            triangle(x + 57.0, y - navH*0.25, x + 62.0, y - navH*0.65, x + 67.0, y - navH*0.25);
            fill(180);
            rect(x,y,w,navH);
        }

        textSize(12);
        fill(0);
        text("Channels", x + 2, y - 6);
        pushStyle();

        //left side
        if (ssvepDisplay == 0) {  // 1 SSVEP
            drawSSVEP("blue", freqs[0], 0.5, 0.5, s/4);
        } else if (ssvepDisplay == 1) { // 2 SSVEPs
            if (heightLarger) {
                drawSSVEP("blue", freqs[0], 0.5, 0.25, s/4);
                drawSSVEP("red", freqs[1], 0.5, 0.75, s/4);
            } else {
              drawSSVEP("blue", freqs[0], 0.25, 0.5, s/4);
              drawSSVEP("red", freqs[1], 0.75, 0.5, s/4);
            }
        } else if (ssvepDisplay == 2) {
            if (heightLarger) {
              drawSSVEP("blue", freqs[0], 0.5, 0.125, s/4);
              drawSSVEP("red", freqs[1], 0.5, 0.5, s/4);
              drawSSVEP("green", freqs[2], 0.5, 0.875, s/4);
            } else {
              drawSSVEP("blue", freqs[0], 0.125, 0.5, s/4);
              drawSSVEP("red", freqs[1], 0.5, 0.5, s/4);
              drawSSVEP("green", freqs[2], 0.875, 0.5, s/4);
            }
        } else if (ssvepDisplay == 3) {
            float sz = s/6;
            drawSSVEP("blue", freqs[0], 0.25, 0.25, s/6);
            drawSSVEP("red", freqs[1], 0.75, 0.25, s/6);
            drawSSVEP("green", freqs[2], 0.25, 0.75, s/6);
            drawSSVEP("yellow", freqs[3], 0.75, 0.75, s/6);
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
            textSize(11.5);
            fill(250);
            String s = "The SSVEP Widget, allows for visual stimulation at specific frequencies. This means that in response to looking at one of the SSVEPs set at a given frequency, you will see an increase in brain activity at that frequency in the FFT plot. For best results, set the frame rate to 60fps.\n\nAdditionally, select the electrodes that align with the back of your head, where the visual stimulus will be recognized. Refer to OpenBCI GUI Widget Guide for more details.\n\nTo pause a single SSVEP, click on it.";
            text(s, x + 30, y + 30, w - 60, h -60);
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

        //Re-Setting the position of the checkBoxes here ensures it draws within the SSVEP widget
        cp5_ssvep.get(CheckBox.class, "channelList").setPosition(x + 5, y + offset);
    }
    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        if(!this.dropdownIsActive) {
            if (dist(mouseX, mouseY, x + w - 80, y - navH/2) <= 9){
                showAbout = !showAbout;
            }

            for(int i = 0; i <= ssvepDisplay; i++){
                if(mouseX > ssvepCoords[i][0] && mouseY > ssvepCoords[i][1] && mouseX < ssvepCoords[i][2] && mouseY < ssvepCoords[i][3]){
                    ssvepOn[i] = !ssvepOn[i];
                }
            }

            if (mouseX > (x + 57) && mouseX < (x + 67) && mouseY < (y - navH*0.25) && mouseY > (y - navH*0.65)) {
                channelSelectPressed = !channelSelectPressed;
                // println(1);
                if(channelSelectPressed){
                    for (int i = 0; i < nchan; i++) {
                        checkList.getItem(i).setVisible(true);
                    }
                } else {
                    for (int i = 0; i < nchan; i++) {
                        checkList.getItem(i).setVisible(false);
                    }
                }
            }


        }
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
      if (ssvepDisplay != 3){
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

   void drawSSVEP(String colour, int freq, float wFactor, float hFactor, float size){
     boolean whiteBG = false;
     if(colour.equals("blue")){
       whiteBG = true;
     }

     int r = 0;
     int g = 0;
     int b = 0;

     int ind = 0;

     if(colour.equals("blue")){
       b = 255;
     }
     else if(colour.equals("red")){
       r = 255;
       ind = 1;
     }
     else if(colour.equals("green")){
       g = 255;
       ind = 2;
     }
     else if(colour.equals("yellow")){
       r = 255;
       g = 255;
       ind = 3;
     }

     if (freq == 0 || !ssvepOn[ind] || millis()%(2*(500/freq)) >= (500/freq)) {
       fill(r,g,b);
       rect(x + (w * wFactor) - (size/2), y + (h*hFactor) - (size/2), size, size);
       pushStyle();
         noFill();
         if(whiteBG){
           stroke(255);
         }
         else{
           stroke(0);
         }
         rect(x + (w * wFactor) - (size/4), y + (h*hFactor) - (size/4), size/2, size/2);
       popStyle();

     } else {
       fill(0);
       rect(x + (w * wFactor) - (size/2), y + (h*hFactor) - (size/2), size, size);
       pushStyle();
         noFill();
         stroke(r,g,b);
         rect(x + (w * wFactor) - (size/10), y + (h*hFactor) - (size/10), size/5, size/5);
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

     if (ssvepDisplay == 0) {
         setDropdown(1, 0.5, - s/8, 0, 30.0);
     } else if (ssvepDisplay == 1) {
       if (heightLarger) {
         setDropdown(1, 0, 10.0, 0.25, -s/8);
         setDropdown(2, 0, 10.0, 0.75, -s/8);
       } else {
         setDropdown(1, 0.25, -s/8, 0, 30.0);
         setDropdown(2, 0.75, -s/8, 0, 30.0);
       }
     } else if (ssvepDisplay == 2) {
         if (heightLarger) {
            setDropdown(1, 0, 10.0, 0.0, 10.0);
            setDropdown(2, 0, 10.0, 1.0/3, 0.0);
            setDropdown(3, 0, 10.0, 2.0/3, 0.0);
         } else {
           //Freq1 Dropdown
           setDropdown(1, 0.125, -s/8, 0, 30.0);
           setDropdown(2, 0.5, -s/8, 0.0, 30.0);
           setDropdown(3, 0.825, -s/8, 0.0, 30.0);
        }
     } else if (ssvepDisplay == 3) {
       setDropdown(4, 1.0, (-1.0/6) - 100.0, 0.5, -15);
       setDropdown(3, 0.0, 10.0, 0.5, -15);
       setDropdown(1, 0.0, 10.0, 0.0, 30.0);
       setDropdown(2, 1.0, (-1.0/6) - 100.0, 0.0, 30.0);
     }
   }

   //------- set the Position of an individual dropdown
   void setDropdown(int dropdownNo, float wFactor, float wOffset, float hFactor, float hOffset){
     cp5_ssvep.getController("Frequency "+dropdownNo)
                       .setPosition(x + (w * wFactor) + wOffset, y + (h * hFactor) + hOffset);

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

   float[] processData(){
      int activeSSVEPs = ssvepDisplay + 1;
      float[] finalData = new float[4];

      for (int i = 0; i < activeSSVEPs; i++) {
          if(freqs[i] > 0) {
              float sum = 0;

              for (int j = 0; j < activeChannels.size(); j++){
                  int chan = activeChannels.get(j);
                  sum+= fftBuff[j].getFreq(freqs[i]);
              }

              float avg = sum/numActiveChannels;
              finalData[i] = avg;
          } else {
              finalData[i] = 0;
          }

      }
      return finalData;
   }

}

void NumberSSVEP(int n) {
    verbosePrint("NumberSSVEP: Item " + n + " selected from dropdown");
    ssvepDisplay = n;
    closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}
