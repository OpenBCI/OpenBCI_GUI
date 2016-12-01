


HeadPlot_Widget headPlot_widget;
ControlP5 cp5_HeadPlot;
List ten20List = Arrays.asList("10-20", "5-10");
List headsetList = Arrays.asList("None", "Mark II", "Mark III (N)", "Mark III (SN)", "Mark IV");
List numChanList = Arrays.asList("4 chan", "8 chan", "16 chan");
List polarityList = Arrays.asList("+/-", " + ");
List smoothingHeadPlotList = Arrays.asList("0.0", "0.5", "0.75", "0.9", "0.95", "0.98");
List filterHeadplotList = Arrays.asList("Unfilt.", "Filtered");

class HeadPlot_Widget {

  int x, y, w, h;
  int parentContainer = 3;

  PFont f = createFont("Arial Bold", 24); //for "FFT Plot" Widget Title
  PFont f2 = createFont("Arial", 18); //for dropdown name titles (above dropdown widgets)

  HeadPlot headPlot;

  //constructor 1
  HeadPlot_Widget(PApplet _parent) {
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    cp5_HeadPlot = new ControlP5(_parent);

    //headPlot = new HeadPlot(float(x)/win_x, float(y)/win_y, float(w)/win_x, float(h)/win_y, win_x, win_y, nchan);
    headPlot = new HeadPlot(x, y, w, h, win_x, win_y);

    //FROM old Gui_Manager
    headPlot.setIntensityData_byRef(dataProcessing.data_std_uV, is_railed);
    headPlot.setPolarityData_byRef(dataProcessing.polarity);
    setSmoothFac(smoothFac[smoothFac_ind]);

    //setup dropdown menus
    setupDropdownMenus(_parent);
  }

  void setupDropdownMenus(PApplet _parent) {
    //ControlP5 Stuff
    int dropdownPos;
    int dropdownWidth = 60;
    cp5_colors = new CColor();
    cp5_colors.setActive(color(150, 170, 200)); //when clicked
    cp5_colors.setForeground(color(125)); //when hovering
    cp5_colors.setBackground(color(255)); //color of buttons
    cp5_colors.setCaptionLabel(color(1, 18, 41)); //color of text
    cp5_colors.setValueLabel(color(0, 0, 255));

    cp5_HeadPlot.setColor(cp5_colors);
    cp5_HeadPlot.setAutoDraw(false);
    //-------------------------------------------------------------
    //MAX FREQUENCY (ie X Axis) DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 3; //work down from 4 since we're starting on the right side now...
    cp5_HeadPlot.addScrollableList("Ten20")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(ten20List)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_HeadPlot.getController("Ten20")
      .getCaptionLabel()
      .setText("10-20")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
    //VERTICAL SCALE (ie Y Axis) DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 2;
    cp5_HeadPlot.addScrollableList("Headset")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(headsetList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_HeadPlot.getController("Headset")
      .getCaptionLabel()
      .setText("None")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
    //Logarithmic vs. Linear DROPDOWN
    //-------------------------------------------------------------
    //dropdownPos = 3;
    //cp5_HeadPlot.addScrollableList("NumChan")
    //  //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
    //  .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
    //  .setOpen(false)
    //  .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
    //  .setScrollSensitivity(0.0)
    //  .setBarHeight(navHeight - 4)
    //  .setItemHeight(navHeight - 4)
    //  .addItems(numChanList)
    //  // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    //  ;

    //cp5_HeadPlot.getController("NumChan")
    //  .getCaptionLabel()
    //  .setText("8 chan")
    //  //.setFont(controlFonts[0])
    //  .setSize(12)
    //  .getStyle()
    //  //.setPaddingTop(4)
    //  ;
    //-------------------------------------------------------------
    // SMOOTHING DROPDOWN (ie FFT bin size)
    //-------------------------------------------------------------
    dropdownPos = 1;
    cp5_HeadPlot.addScrollableList("Polarity")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(polarityList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;


    cp5_HeadPlot.getController("Polarity")
      .getCaptionLabel()
      .setText("+/-")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
    // UNFILTERED VS FILT DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 0;
    cp5_HeadPlot.addScrollableList("SmoothingHeadPlot")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(smoothingHeadPlotList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    String initSmooth = smoothFac[smoothFac_ind] + "";
    cp5_HeadPlot.getController("SmoothingHeadPlot")
      .getCaptionLabel()
      .setText(initSmooth)
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
    // UNFILTERED VS FILT DROPDOWN
    //-------------------------------------------------------------
    //dropdownPos = 0;
    //cp5_HeadPlot.addScrollableList("UnfiltFiltHeadPlot")
    //  //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
    //  .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
    //  .setOpen(false)
    //  .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
    //  .setScrollSensitivity(0.0)
    //  .setBarHeight(navHeight - 4)
    //  .setItemHeight(navHeight - 4)
    //  .addItems(filterHeadplotList)
    //  // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    //  ;

    //cp5_HeadPlot.getController("UnfiltFiltHeadPlot")
    //  .getCaptionLabel()
    //  .setText("Filtered")
    //  //.setFont(controlFonts[0])
    //  .setSize(12)
    //  .getStyle()
    //  //.setPaddingTop(4)
    //  ;
    //-------------------------------------------------------------
  }

  void update() {

    //update position/size of FFT Plot
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    headPlot.update();
  }

  void draw() {

    if(!drawEMG){
      pushStyle();
      noStroke();

      fill(255);
      rect(x, y, w, h); //widget background
      //fill(150,150,150);
      //rect(x, y, w, navHeight); //top bar
      //fill(200, 200, 200);
      //rect(x, y+navHeight, w, navHeight); //top bar
      //fill(bgColor);
      //textSize(18);
      //text("Head Plot", x+w/2, y+navHeight/2);
      ////fill(255,0,0,150);
      ////rect(x,y,w,h);

      fill(150, 150, 150);
      rect(x, y, w, navHeight); //top bar
      fill(200, 200, 200);
      rect(x, y+navHeight, w, navHeight); //button bar
      fill(255);
      rect(x+2, y+2, navHeight-4, navHeight-4);
      fill(bgColor, 100);
      //rect(x+3,y+3, (navHeight-7)/2, navHeight-10);
      rect(x+4, y+4, (navHeight-10)/2, (navHeight-10)/2);
      rect(x+4, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10)/2);
      rect(x+((navHeight-10)/2)+5, y+4, (navHeight-10)/2, (navHeight-10)/2);
      rect(x+((navHeight-10)/2)+5, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10 )/2);
      //text("FFT Plot", x+w/2, y+navHeight/2)
      fill(bgColor);
      textAlign(LEFT, CENTER);
      textFont(f);
      textSize(18);
      text("Head Montage", x+navHeight+2, y+navHeight/2 - 2); //left
      //textAlign(CENTER,CENTER); text("FFT Plot", w/2, y+navHeight/2 - 2); //center
      //fill(255,0,0,150);
      //rect(x,y,w,h);

      headPlot.draw(); //draw the actual headplot

      //draw dropdown titles
      int dropdownPos = 3; //used to loop through drop down titles ... should use for loop with titles in String array, but... laziness has ensued. -Conor
      int dropdownWidth = 60;
      textFont(f2);
      textSize(12);
      textAlign(CENTER, BOTTOM);
      fill(bgColor);
      text("Layout", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      dropdownPos = 2;
      text("Headset", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      //dropdownPos = 3;
      //text("# Chan.", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      dropdownPos = 1;
      text("Polarity", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      dropdownPos = 0;
      text("Smoothing", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      // dropdownPos = 0;
      // text("Filters?", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));

      cp5_HeadPlot.draw(); //draw all dropdown menus

      popStyle();
    }
  }

  void screenResized(PApplet _parent, int _winX, int _winY) {
    //when screen is resized...
    //update Head Plot widget position/size
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    //update position of headplot
    headPlot.setPositionSize(x, y, w, h, width, height);

    cp5_HeadPlot.setGraphics(_parent, 0, 0); //remaps the cp5 controller to the new PApplet window size

    //update dropdown menu positions
    int dropdownPos;
    int dropdownWidth = 60;
    dropdownPos = 3; //work down from 4 since we're starting on the right side now...
    cp5_HeadPlot.getController("Ten20")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 2; //work down from 4 since we're starting on the right side now...
    cp5_HeadPlot.getController("Headset")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    //dropdownPos = 2;
    //cp5_HeadPlot.getController("NumChan")
    //  //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
    //  .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
    //  //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
    //  ;
    dropdownPos = 1;
    cp5_HeadPlot.getController("Polarity")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 0;
    cp5_HeadPlot.getController("SmoothingHeadPlot")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    //dropdownPos = 0;
    //cp5_HeadPlot.getController("UnfiltFiltHeadPlot")
    //  //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
    //  .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
    //  //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
    //  ;
  }

  public void setSmoothFac(float fac) {
    headPlot.smooth_fac = fac;
  }

  void mousePressed() {
    //called by GUI_Widgets.pde
    if(mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h){
      //println("headPlot.mousePressed()");
    }
  }
  void mouseReleased() {
    //called by GUI_Widgets.pde
    if (mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) {
      println("headPlot.mouseReleased()");
    }
  }
  void keyPressed() {
    //called by GUI_Widgets.pde
  }
  void keyReleased() {
    //called by GUI_Widgets.pde
  }
};
