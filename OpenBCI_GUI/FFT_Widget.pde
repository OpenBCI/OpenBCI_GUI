
////////////////////////////////////////////////////
//
// This class creates an FFT Plot separate from the old Gui_Manager
//
// Conor Russomanno, July 2016
//
// Requires the plotting library from grafica ... replacing the old gwoptics (which is now no longer supported)
//
///////////////////////////////////////////////////


import grafica.*;
import java.util.Random;

//fft constants
int Nfft = 256; //set resolution of the FFT.  Use N=256 for normal, N=512 for MU waves
FFT[] fftBuff = new FFT[nchan];    //from the minim library
boolean isFFTFiltered = true; //yes by default ... this is used in dataProcessing.pde to determine which uV array feeds the FFT calculation

ControlP5 cp5_FFT;
List maxFreqList = Arrays.asList("20 Hz", "40 Hz", "60 Hz", "120 Hz");
List logLinList = Arrays.asList("Log", "Linear");
List vertScaleList = Arrays.asList("10 uV", "50 uV", "100 uV", "1000 uV");
List smoothList = Arrays.asList("0.0", "0.5", "0.75", "0.9", "0.95", "0.98");
List filterList = Arrays.asList("Filtered", "Unfilt.");

CColor cp5_colors;

class FFT_Widget {

  int x, y, w, h; 
  int[] positioning = {0, 0, 0, 0}; // {x0, y0, w, h} retreived from corresponding container
  GPlot fft_plot; //create an fft plot for each active channel
  GPointsArray[] fft_points;  //create an array of points for each channel of data (4, 8, or 16)

  PFont f = createFont("Arial Bold", 24); //for "FFT Plot" Widget Title
  PFont f2 = createFont("Arial", 18); //for dropdown name titles (above dropdown widgets)

  int parentContainer = 9; //which container is it mapped to by default?

  int[] lineColor = {
    (int)color(129, 129, 129), 
    (int)color(124, 75, 141), 
    (int)color(54, 87, 158), 
    (int)color(49, 113, 89), 
    (int)color(221, 178, 13), 
    (int)color(253, 94, 52), 
    (int)color(224, 56, 45), 
    (int)color(162, 82, 49), 
    (int)color(129, 129, 129), 
    (int)color(124, 75, 141), 
    (int)color(54, 87, 158), 
    (int)color(49, 113, 89), 
    (int)color(221, 178, 13), 
    (int)color(253, 94, 52), 
    (int)color(224, 56, 45), 
    (int)color(162, 82, 49)
  };

  int[] xLimOptions = {20, 40, 60, 120};
  int[] yLimOptions = {10, 50, 100, 1000};

  int xLim = xLimOptions[2];  //maximum value of x axis ... in this case 20 Hz, 40 Hz, 60 Hz, 120 Hz
  int xMax = xLimOptions[3];
  int FFT_indexLim = int(1.0*xMax*(Nfft/get_fs_Hz_safe()));   // maxim value of FFT index
  int yLim = 100;  //maximum value of y axis ... 100 uV


  //constructor 1
  FFT_Widget(PApplet parent) {
    cp5_FFT = new ControlP5(parent);

    println("1");
    fft_points = new GPointsArray[nchan];
    println(fft_points.length);
    println("2");
    //fftBuff = new FFT[nchan];
    println(fftBuff.length);
    println("3");

    println(FFT_indexLim);
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    initializeFFTPlot(parent);
    setupDropdownMenus(parent);
  }

  void initializeFFTPlot(PApplet _parent) {
    //setup GPlot for FFT
    fft_plot =  new GPlot(_parent, x, y+navHeight, w, h-navHeight); //based on container dimensions
    fft_plot.getXAxis().setAxisLabelText("Frequency (Hz)");
    fft_plot.getYAxis().setAxisLabelText("Amplitude (uV)");
    //fft_plot.setMar(50,50,50,50); //{ bot=60, left=70, top=40, right=30 } by default
    fft_plot.setMar(60, 70, 40, 30); //{ bot=60, left=70, top=40, right=30 } by default
    fft_plot.setLogScale("y");

    fft_plot.setYLim(0.1, yLim);
    int _nTicks = int(yLim/10 - 1); //number of axis subdivisions
    fft_plot.getYAxis().setNTicks(_nTicks);  //sets the number of axis divisions...
    fft_plot.setXLim(0.1, xLim);
    fft_plot.getYAxis().setDrawTickLabels(true);
    fft_plot.setPointSize(2);
    fft_plot.setPointColor(0);

    //setup points of fft point arrays
    for (int i = 0; i < fft_points.length; i++) {
      fft_points[i] = new GPointsArray(FFT_indexLim);
    }

    //fill fft point arrays
    for (int i = 0; i < fft_points.length; i++) {
      for (int j = 0; j < FFT_indexLim; j++) {
        //GPoint temp = new GPoint(i, 15*noise(0.1*i));
        //println(i + " " + j);
        GPoint temp = new GPoint(j, 0);
        fft_points[i].set(j, temp);
      }
    }

    //map fft point arrays to fft plots
    fft_plot.setPoints(fft_points[0]);
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

    cp5_FFT.setColor(cp5_colors);
    cp5_FFT.setAutoDraw(false);
    //-------------------------------------------------------------
    //MAX FREQUENCY (ie X Axis) DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 4; //work down from 4 since we're starting on the right side now...
    cp5_FFT.addScrollableList("MaxFreq")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(maxFreqList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_FFT.getController("MaxFreq")
      .getCaptionLabel()
      .setText("60 Hz")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
    //VERTICAL SCALE (ie Y Axis) DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 3;
    cp5_FFT.addScrollableList("VertScale")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(vertScaleList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_FFT.getController("VertScale")
      .getCaptionLabel()
      .setText("100 uV")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
    //Logarithmic vs. Linear DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 2;
    cp5_FFT.addScrollableList("LogLin")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(logLinList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_FFT.getController("LogLin")
      .getCaptionLabel()
      .setText("Log")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
    // SMOOTHING DROPDOWN (ie FFT bin size)
    //-------------------------------------------------------------
    dropdownPos = 1;
    cp5_FFT.addScrollableList("Smoothing")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(smoothList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    String initSmooth = smoothFac[smoothFac_ind] + "";
    cp5_FFT.getController("Smoothing")
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
    dropdownPos = 0;
    cp5_FFT.addScrollableList("UnfiltFilt")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(filterList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_FFT.getController("UnfiltFilt")
      .getCaptionLabel()
      .setText("Filtered")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
  }

  void update() {
    //update the points of the FFT channel arrays
    //update fft point arrays
    for (int i = 0; i < fft_points.length; i++) {
      for (int j = 0; j < FFT_indexLim + 2; j++) {  //loop through frequency domain data, and store into points array
        //GPoint powerAtBin = new GPoint(j, 15*random(0.1*j));

        GPoint powerAtBin = new GPoint((1.0*get_fs_Hz_safe()/Nfft)*j, fftBuff[i].getBand(j));
        fft_points[i].set(j, powerAtBin);
        //println("=========================================");
        //println(j);
        //println(fftBuff[i].getBand(j) + " :: " + fft_points[i].getX(j) + " :: " + fft_points[i].getY(j));
        //println("=========================================");
      }
    }

    //remap fft point arrays to fft plots
    fft_plot.setPoints(fft_points[0]);
  }

  void draw() {

    pushStyle();

    //draw FFT Graph w/ all plots
    noStroke();
    fft_plot.beginDraw();
    fft_plot.drawBackground();
    fft_plot.drawBox();
    fft_plot.drawXAxis();
    fft_plot.drawYAxis();
    //fft_plot.drawTopAxis();
    //fft_plot.drawRightAxis();
    //fft_plot.drawTitle();
    fft_plot.drawGridLines(2);
    //here is where we will update points & loop...
    for (int i = 0; i < fft_points.length; i++) {
      fft_plot.setLineColor(lineColor[i]);
      fft_plot.setPoints(fft_points[i]);
      fft_plot.drawLines();
      //fft_plot.drawPoints(); //draw points
    }
    fft_plot.endDraw();

    //draw nav bars and button bars
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
    text("FFT Plot", x+navHeight+2, y+navHeight/2 - 2); //title of widget -- left
    //textAlign(CENTER,CENTER); text("FFT Plot", w/2, y+navHeight/2 - 2); //title of widget -- left
    //fill(255,0,0,150);
    //rect(x,y,w,h);

    //draw dropdown titles
    int dropdownPos = 4; //used to loop through drop down titles ... should use for loop with titles in String array, but... laziness has ensued. -Conor
    int dropdownWidth = 60;
    textFont(f2);
    textSize(12);
    textAlign(CENTER, BOTTOM);
    fill(bgColor);
    text("Max Freq", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    dropdownPos = 3;
    text("Max uV", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    dropdownPos = 2;
    text("Log/Lin", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    dropdownPos = 1;
    text("Smoothing", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    dropdownPos = 0;
    text("Filters?", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));

    //draw dropdown menus
    cp5_FFT.draw();

    popStyle();
  }

  void screenResized(PApplet _parent, int _winX, int _winY) {
    //when screen is resized...
    //update position/size of FFT widget
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    //update position/size of FFT plot
    fft_plot.setPos(x, y+navHeight);//update position
    fft_plot.setOuterDim(w, h-navHeight);//update dimensions

    //update dropdown menu positions
    cp5_FFT.setGraphics(_parent, 0, 0); //remaps the cp5 controller to the new PApplet window size
    int dropdownPos;
    int dropdownWidth = 60;
    dropdownPos = 4; //work down from 4 since we're starting on the right side now...
    cp5_FFT.getController("MaxFreq")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 3;
    cp5_FFT.getController("VertScale")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 2;
    cp5_FFT.getController("LogLin")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 1;
    cp5_FFT.getController("Smoothing")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 0;
    cp5_FFT.getController("UnfiltFilt")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
  }

  void mousePressed() {
    //called by GUI_Widgets.pde
    if (mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) {
      println("fft_widget.mousePressed()");
    }
  }
  void mouseReleased() {
    //called by GUI_Widgets.pde
    if (mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) {
      //println("fft_widget.mouseReleased()");
    }
  }
  //void keyPressed() {
  //  //called by GUI_Widgets.pde
  //}
  //void keyReleased() {
  //  //called by GUI_Widgets.pde
  //}
}

//triggered when there is an event in the MaxFreq. Dropdown
void MaxFreq(int n) {
  /* request the selected item based on index n */
  println(n, cp5_FFT.get(ScrollableList.class, "MaxFreq").getItem(n));

  /* here an item is stored as a Map  with the following key-value pairs:
   * name, the given name of the item
   * text, the given text of the item by default the same as name
   * value, the given value of the item, can be changed by using .getItem(n).put("value", "abc"); a value here is of type Object therefore can be anything
   * color, the given color of the item, how to change, see below
   * view, a customizable view, is of type CDrawable 
   */

  //for (int i =0; i < maxFreqList.size(); i++) {
  //  if (i != n) {
  //    cp5_FFT.get(ScrollableList.class, "MaxFreq").getItem(i).put("color", cp5_colors);
  //  }
  //}

  //CColor c = new CColor();
  ////c.setBackground(color(1, 18, 41));
  //c.setBackground(color(0, 255, 0));
  //c.setCaptionLabel(color(255, 255, 255));
  //cp5_FFT.get(ScrollableList.class, "MaxFreq").getItem(n).put("color", c);

  fft_widget.fft_plot.setXLim(0.1, fft_widget.xLimOptions[n]); //update the xLim of the FFT_Plot
}

//triggered when there is an event in the VertScale Dropdown
void VertScale(int n) {

  fft_widget.fft_plot.setYLim(0.1, fft_widget.yLimOptions[n]); //update the yLim of the FFT_Plot
}

//triggered when there is an event in the LogLin Dropdown
void LogLin(int n) {
  if (n==0) {
    fft_widget.fft_plot.setLogScale("y");
  } else {
    fft_widget.fft_plot.setLogScale("");
  }
}

//triggered when there is an event in the LogLin Dropdown
void Smoothing(int n) {
  smoothFac_ind = n;
}

//triggered when there is an event in the LogLin Dropdown
void UnfiltFilt(int n) {
  if (n==0) {
    //have FFT use filtered data -- default
    isFFTFiltered = true;
  } else {
    //have FFT use unfiltered data
    isFFTFiltered = false;
  }
}