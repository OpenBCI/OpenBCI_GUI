
////////////////////////////////////////////////////
//
//    W_SSVEP
//
//    This is an SSVEP Widget that will display frequencies for you to look at, and then observe
//    spikes in brain waves matching that frequency.
//
//    Created by: Leanne Pichay, July 2019
//
///////////////////////////////////////////////////,
int ssvepDisplay;

class W_SSVEP extends Widget {

    //frequency variables offered
    int freq1, freq2, freq3, freq4;

    //Limiting dimension variable
    int s;

    //toggle showAbout
    boolean showAbout;

    //determine if height of widget > width
    boolean heightLarger;

    //Widget CP5s
    ControlP5 cp5_ssvepDropdowns;
    String[] dropdownNames;
    List<String> dropdownOptions;

    boolean configIsVisible = false;
    boolean layoutIsVisible = false;

    W_SSVEP(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        addDropdown("NumberSSVEP", "# SSVEPs", Arrays.asList("1", "2","3","4"), 0);

        freq1 = 8;
        freq2 = 8;
        freq3 = 8;
        freq4 = 8;

        // showAbout = true;
        cp5_ssvepDropdowns = new ControlP5(pApplet);

        dropdownNames = new String[] {"Frequency 1", "Frequency 2", "Frequency 3", "Frequency 4"};
        dropdownOptions = new ArrayList<String>();

        for (int i = 0; i < 9; i++) {
          dropdownOptions.add(String.valueOf(i+7) + " Hz");
        }

        for (int i = 0; i < dropdownNames.length; i++) {
          createDropdown(dropdownNames[i], dropdownOptions);
        }

        cp5_ssvepDropdowns.setAutoDraw(false);

        if (h > w) {
          heightLarger = true;
          s = h;
        } else {
          heightLarger = false;
          s = w;
        }

    }

    void update() {
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        if ((topNav.configSelector.isVisible != configIsVisible) || (topNav.layoutSelector.isVisible != layoutIsVisible)) {
            //lock/unlock the controllers within networking widget when using TopNav Objects
            if (topNav.configSelector.isVisible || topNav.layoutSelector.isVisible) {
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1").lock();
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").lock();
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").lock();
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 4").lock();

            } else {
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1").unlock();
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").unlock();
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").unlock();
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 4").unlock();
            }

            //lock/unlock dropdowns when Widget Selector is in use
            if (cp5_widget.get(ScrollableList.class, "WidgetSelector").isOpen()) {
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1").lock();
            } else {
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1").unlock();
            }

            //lock/unlock lower Freq4 dropdown when Freq2 dropdown is in use in 4 SSVEP use case
            if (cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").isOpen()) {
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 4").lock();
                print("!!!!!!!!");

            } else {
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 4").setVisible(true).unlock();
            }

            //lock/unlock lower Freq3 dropdown when Freq1 dropdown is in use in 4 SSVEP use case
            if (cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1").isOpen() && ssvepDisplay == 3) {
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").lock();
            } else {
                cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").unlock();
            }

            //manage dropdowns in 3 SSVEP use case
            if (heightLarger && ssvepDisplay == 2) {
               // lock freq2 if freq1 is in use
               if(cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1").isOpen()){
                  cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").lock();
               }
               else{
                 cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").unlock();
               }

               // lock freq3 if freq2 is in use
               if(cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").isOpen()){
                  cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").lock();
               }
               else{
                 cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").unlock();
               }
            }

            configIsVisible = topNav.configSelector.isVisible;
            layoutIsVisible = topNav.layoutSelector.isVisible;
        }

        if (ssvepDisplay == 0) {  // 1 SSVEP
            freq1 = updateFreq(1);
        } else if (ssvepDisplay == 1) {
            freq1 = updateFreq(1);
            freq2 = updateFreq(2);
        } else if (ssvepDisplay == 2) {
            freq1 = updateFreq(1);
            freq2 = updateFreq(2);
            freq3 = updateFreq(3);
        } else if (ssvepDisplay == 3) {
            freq1 = updateFreq(1);
            freq2 = updateFreq(2);
            freq3 = updateFreq(3);
            freq4 = updateFreq(4);
        }

        setDropdownPositions();
    }

    void draw() {
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        fill(0);
        rect(x,y, w, h);
        pushStyle();

        //left side
        if (ssvepDisplay == 0) {  // 1 SSVEP
            drawSSVEP("blue", freq1, 0.5, 0.5, s/4);
        } else if (ssvepDisplay == 1) { // 2 SSVEPs
            if (heightLarger) {
                drawSSVEP("blue", freq1, 0.5, 0.25, s/4);
                drawSSVEP("red", freq2, 0.5, 0.75, s/4);
            } else {
              drawSSVEP("blue", freq1, 0.25, 0.5, s/4);
              drawSSVEP("red", freq2, 0.75, 0.5, s/4);
            }
        } else if (ssvepDisplay == 2) {
            if (heightLarger) {
              drawSSVEP("blue", freq1, 0.5, 0.125, s/4);
              drawSSVEP("red", freq2, 0.5, 0.5, s/4);
              drawSSVEP("green", freq3, 0.5, 0.875, s/4);
            } else {
              drawSSVEP("blue", freq1, 0.125, 0.5, s/4);
              drawSSVEP("red", freq2, 0.5, 0.5, s/4);
              drawSSVEP("green", freq3, 0.875, 0.5, s/4);
            }
        } else if (ssvepDisplay == 3) {
            drawSSVEP("blue", freq1, 0.25, 0,25, s/6);
            drawSSVEP("red", freq2, 0.75, 0.25, s/6);
            drawSSVEP("green", freq3, 0.25, 0.75, s/6);
            drawSSVEP("yellow", freq4, 0.75, 0.75, s/6);
        }

        cp5_ssvepDropdowns.draw();

        //show about details
        // if (showAbout) {
        //     stroke(70,70,70);
        //     fill(100,100,100);
        //
        //     rect(x + 20, y + 20, w - 40, h- 40);
        //     textAlign(LEFT, TOP);
        //     textSize(10);
        //     fill(255,255,255);
        //     String s = "The SSVEP Widget is designed to display set frequencies ";
        //     text(s, x + 40, y + 40, w - 80, h -80);
        // }
    }

    void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //Resets the CP5 origin when the app is resized
        cp5_ssvepDropdowns.setGraphics(pApplet, 0, 0);

        if (h > w) {
          heightLarger = true;
          s = h;
        } else {
          heightLarger = false;
          s = w;
        }
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
    }

    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    }

    void createDropdown(String name, List<String> _items) {
      cp5_ssvepDropdowns.addScrollableList(name)
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

      cp5_ssvepDropdowns.getController(name)
            .getCaptionLabel()
            .toUpperCase(false)
            .setFont(h4)
            .setSize(14)
            ;

      cp5_ssvepDropdowns.getController(name)
            .getValueLabel()
            .toUpperCase(false)
            .setFont(h4)
            .setSize(12)
            ;
   }

   void resetDropdowns() {
     cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1").setVisible(false);
     cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").setVisible(false);
     cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").setVisible(false);
     cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 4").setVisible(false);
   }

   void drawSSVEP(String colour, int freq, float wFactor, float hFactor, float size){
     boolean whiteBG = false;
     if(colour.equals("blue")){
       whiteBG = true;
     }

     if (millis()%(2*(500/freq1)) >= (500/freq1)) {
       int r = 0;
       int g = 0;
       int b = 0;

       if(colour.equals("blue")){
         b = 255;
       }
       else if(colour.equals("red")){
         r = 255;
       }
       else if(colour.equals("green")){
         g = 255;
       }
       else if(colour.equals("yellow")){
         b = 255;
         g = 255;
       }

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
         stroke(0,0,255);
         rect(x + (w * wFactor) - (size/10), y + (h*hFactor) - (size/10), size/5, size/5);
       popStyle();
     }
   }

   void setDropdownPositions() {
     resetDropdowns();

     setDropdown4();
     setDropdown3();
     setDropdown2();
     setDropdown1();
   }

   void setDropdown1() {
     if (ssvepDisplay == 0) {
       cp5_ssvepDropdowns.getController("Frequency 1")
                         .setPosition(x + w/2 - h/8, y + 30);

       cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1") // set visual settings for dropdown
                               .setVisible(true)
                               ;
     } else if (ssvepDisplay == 1) {
       if (heightLarger) {
        //freq1 dropdown
         cp5_ssvepDropdowns.getController("Frequency 1")
                           .setPosition(x + 10, y + h/4 - s/8)
                           ;

         cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1") // set visual settings for dropdown
                           .setVisible(true)
                           ;
       } else {
         //Freq1 Dropdown
         cp5_ssvepDropdowns.getController("Frequency 1")
                           .setPosition(x + w/4 - s/8, y + 30)
                           ;

         cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1") // set visual settings for dropdown
                           .setVisible(true)
                           ;
       }
     } else if (ssvepDisplay == 2) {
         if (heightLarger) {
           //Freq1 Dropdown
           cp5_ssvepDropdowns.getController("Frequency 1")
                             .setPosition(x + 10, y + 10)
                             ;

           cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1")
                             .setVisible(true)
                             ;
         } else {
           //Freq1 Dropdown
           cp5_ssvepDropdowns.getController("Frequency 1")
                             .setPosition(x + w/8 - s/8, y + 30);

           cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1")
                             .setVisible(true)
                             ;

        }
     } else if (ssvepDisplay == 3) {
       cp5_ssvepDropdowns.getController("Frequency 1")
                           .setPosition(x + 10, y + 10);

       cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 1")
                           .setVisible(true)
                           ;
     }
   }

   void setDropdown2() {
     if (ssvepDisplay == 1) {
       if (heightLarger) {
        //freq2 dropdown
         cp5_ssvepDropdowns.getController("Frequency 2")
                           .setPosition(x + 10, y + (3*h/4) - s/8);

         cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").setVisible(true);   // set visual settings for dropdown
       } else {
         //Freq2 Dropdown
         cp5_ssvepDropdowns.getController("Frequency 2")
                           .setPosition(x + (3*w/4) - s/8, y + 30);

         cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2")
                            .setVisible(true);   // set visual settings for dropdown
       }
     } else if (ssvepDisplay == 2) {
       if (heightLarger) {
         //Freq2 Dropdown
         cp5_ssvepDropdowns.getController("Frequency 2")
                           .setPosition(x + 10, y + h/3);

         cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").setVisible(true);   // set visual settings for dropdown
       } else {
         //Freq2 Dropdown
         cp5_ssvepDropdowns.getController("Frequency 2")
                           .setPosition(x + w/2 - s/8, y + 30);

         cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").setVisible(true);   // set visual settings for dropdown
       }
     } else if (ssvepDisplay == 3) {
       //Freq2 Dropdown
       cp5_ssvepDropdowns.getController("Frequency 2")
                         .setPosition(x + w - h/6 - 70, y + 10);

       cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 2").setVisible(true);   // set visual settings for dropdown
     }
   }

   void setDropdown3() {
     if (ssvepDisplay == 2) {
       if (heightLarger) {
         //Freq3 Dropdown
         cp5_ssvepDropdowns.getController("Frequency 3")
                           .setPosition(x + 10, y + (2*h/3));

         cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").setVisible(true);   // set visual settings for dropdown
       } else {
         //Freq3 Dropdown
         cp5_ssvepDropdowns.getController("Frequency 3")
                           .setPosition(x + (7*w/8) - s/8, y + 30);

         cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").setVisible(true);   // set visual settings for dropdown
       }
     } else if (ssvepDisplay == 3) {
      //Freq3 Dropdown
      cp5_ssvepDropdowns.getController("Frequency 3")
                        .setPosition(x + 10, y + h/2);

      cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 3").setVisible(true);   // set visual settings for dropdown
     }
   }

   void setDropdown4() {
     if (ssvepDisplay == 3) {
      cp5_ssvepDropdowns.getController("Frequency 4")
                        .setPosition(x + w - h/6 - 70, y + h/2);

      cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency 4").setVisible(true);   // set visual settings for dropdown
     }
   }

   int updateFreq(int controllerNum) {
     String s = cp5_ssvepDropdowns.get(ScrollableList.class, "Frequency "+controllerNum).getLabel();
     if (!s.equals("Frequency "+controllerNum)) {
       s = s.substring(0,s.indexOf(" "));
       return Integer.valueOf(s);
     }
     return -1;
   }

}

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void NumberSSVEP(int n) {
    println("Item " + (n+1) + " selected from Dropdown 1");
    if (n==0) {
        ssvepDisplay = 0;
    } else if (n==1) {
        ssvepDisplay = 1;
    } else if (n==2) {
        ssvepDisplay = 2;
    } else if (n==3) {
        ssvepDisplay = 3;
    }

    closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}
