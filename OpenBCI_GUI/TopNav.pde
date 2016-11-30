///////////////////////////////////////////////////////////////////////////////////////
//
//  Created by Conor Russomanno, 11/3/16
//  Extracting old code Gui_Manager.pde, adding new features for GUI v2 launch
//
///////////////////////////////////////////////////////////////////////////////////////

int navBarHeight = 32;
TopNav topNav;

class TopNav {

  // PlotFontInfo fontInfo;

  Button stopButton;
  public final static String stopButton_pressToStop_txt = "Stop Data Stream";
  public final static String stopButton_pressToStart_txt = "Start Data Stream";

  Button filtBPButton;
  Button filtNotchButton;
  Button intensityFactorButton;

  Button questionMark;
  Button layout;

  LayoutSelector layoutSelector;

  //constructor
  TopNav(){

    stopButton = new Button(3, 35, 170, 26, stopButton_pressToStart_txt, fontInfo.buttonLabel_size);
    stopButton.setFont(h2, 16);
    stopButton.setColorNotPressed(color(184, 220, 105));
    stopButton.setHelpText("Press this button to Stop/Start the data stream. Or press <SPACEBAR>");

    filtNotchButton = new Button(7 + stopButton.but_dx, 35, 70, 26, "Notch\n" + dataProcessing.getShortNotchDescription(), fontInfo.buttonLabel_size);
    filtBPButton = new Button(11 + stopButton.but_dx + 70, 35, 70, 26, "BP Filt\n" + dataProcessing.getShortFilterDescription(), fontInfo.buttonLabel_size);
    intensityFactorButton = new Button(15 + stopButton.but_dx + 70 + 70, 35, 70, 26, "Vert Scale\n" + round(vertScale_uV) + "uV", fontInfo.buttonLabel_size);

    questionMark = new Button(width - 3 - 26, 3, 26, 26, "?", fontInfo.buttonLabel_size);
    questionMark.setFont(h2, 16);
    questionMark.setHelpText("Here you will find links to helpful online tutorials and getting started guides. Also, check out how to create custom widgets for the GUI!");
    layout = new Button(width - 3 - 70, 35, 70, 26, "Layout", fontInfo.buttonLabel_size);
    layout.setFont(h2, 16);

    layoutSelector = new LayoutSelector();

  }

  void update(){

  }

  void draw(){
    pushStyle();
    noStroke();
    fill(229);
    rect(0, 0, width, topNav_h);
    stroke(31,69,110);
    fill(255);
    rect(-1, 0, width+2, navBarHeight);
    popStyle();

    stopButton.draw();

    filtBPButton.draw();
    filtNotchButton.draw();
    intensityFactorButton.draw();

    questionMark.draw();
    layout.draw();

    image(logo, width/2 - (128/2) - 2, 6, 128, 22);

    layoutSelector.draw();

  }

  void screenHasBeenResized(int _x, int _y){
    questionMark.but_x = width - 3 - 26;
    layout.but_x = width - 3 - 70;

    layoutSelector.screenResized();     //pass screenResized along to layoutSelector
  }

  void mousePressed(){
    if (stopButton.isMouseHere()) {
      stopButton.setIsActive(true);
      stopButtonWasPressed();
    }
    if (filtBPButton.isMouseHere()) {
      filtBPButton.setIsActive(true);
      incrementFilterConfiguration();
    }
    if (topNav.filtNotchButton.isMouseHere()) {
      filtNotchButton.setIsActive(true);
      incrementNotchConfiguration();
    }
    if (intensityFactorButton.isMouseHere()) {
      intensityFactorButton.setIsActive(true);
      incrementVertScaleFactor();
    }
    if (questionMark.isMouseHere()) {
      questionMark.setIsActive(true);
      //toggle help/tutorial dropdown menu
    }
    if (layout.isMouseHere()) {
      layout.setIsActive(true);
      //toggle layout window to enable the selection of your container layout...
    }

    layoutSelector.mousePressed();     //pass mousePressed along to layoutSelector
  }

  void mouseReleased(){

    if (layout.isMouseHere() && layout.isActive()) {
      layoutSelector.toggleVisibility();
      layout.setIsActive(true);
      wm.printLayouts();
    }

    stopButton.setIsActive(false);

    filtBPButton.setIsActive(false);
    filtNotchButton.setIsActive(false);
    intensityFactorButton.setIsActive(false);

    questionMark.setIsActive(false);
    layout.setIsActive(false);

    layoutSelector.mouseReleased();    //pass mouseReleased along to layoutSelector
  }

}







//=============== OLD STUFF FROM Gui_Manger.pde ===============//

float default_vertScale_uV=200.0; //this defines the Y-scale on the montage plots...this is the vertical space between traces
float[] vertScaleFactor = {1.0f, 2.0f, 5.0f, 50.0f, 0.25f, 0.5f};
int vertScaleFactor_ind = 0;
float vertScale_uV=default_vertScale_uV;

void incrementFilterConfiguration() {
  dataProcessing.incrementFilterConfiguration();

  //update the button strings
  topNav.filtBPButton.but_txt = "BP Filt\n" + dataProcessing.getShortFilterDescription();
  // topNav.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
}

void incrementNotchConfiguration() {
  dataProcessing.incrementNotchConfiguration();

  //update the button strings
  topNav.filtNotchButton.but_txt = "Notch\n" + dataProcessing.getShortNotchDescription();
  // topNav.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
}

void setDefaultVertScale(float val_uV) {
  default_vertScale_uV = val_uV;
  updateVertScale();
}

void setVertScaleFactor_ind(int ind) {
  vertScaleFactor_ind = max(0,ind);
  if (ind >= vertScaleFactor.length) vertScaleFactor_ind = 0;
  updateVertScale();
}
void incrementVertScaleFactor() {
  setVertScaleFactor_ind(vertScaleFactor_ind+1);  //wrap-around is handled inside the function
}
void updateVertScale() {
  vertScale_uV = default_vertScale_uV*vertScaleFactor[vertScaleFactor_ind];
  //println("GUI_Manager: updateVertScale: vertScale_uV = " + vertScale_uV);

  //update how the plots are scaled
  if (gui.montageTrace != null) gui.montageTrace.setYScale_uV(vertScale_uV);  //the Y-axis on the montage plot is fixed...the data is simply scaled prior to plotting
  if (gui.gFFT != null) gui.gFFT.setYAxisMax(vertScale_uV);
  headPlot_widget.headPlot.setMaxIntensity_uV(vertScale_uV);
  topNav.intensityFactorButton.setString("Vert Scale\n" + round(vertScale_uV) + "uV");

}

class LayoutSelector{

  int x, y, w, h, margin, b_w, b_h;
  boolean isVisible;

  ArrayList<Button> layoutOptions; //

  LayoutSelector(){
    w = 180;
    x = width - w;
    y = navBarHeight * 2;
    margin = 6;
    b_w = (w - 5*margin)/4;
    b_h = b_w;
    h = margin*3 + b_h*2;


    isVisible = false;

    layoutOptions = new ArrayList<Button>();
    addLayoutOptionButton();
  }

  void update(){
    if(isVisible){ //only update if visible

    }
  }

  void draw(){
    if(isVisible){ //only draw if visible
      pushStyle();

      // println("it's happening");
      stroke(31,69,110);
      fill(229); //bg
      rect(x, y, w, h);

      for(int i = 0; i < layoutOptions.size(); i++){
        layoutOptions.get(i).draw();
      }

      popStyle();
    }
  }

  void isMouseHere(){

  }

  void mousePressed(){
    //only allow button interactivity if isVisible==true
    if(isVisible){
      for(int i = 0; i < layoutOptions.size(); i++){
        if(layoutOptions.get(i).isMouseHere()){
          layoutOptions.get(i).setIsActive(true);
        }
      }
    }
  }

  void mouseReleased(){
    //only allow button interactivity if isVisible==true
    if(isVisible){
      for(int i = 0; i < layoutOptions.size(); i++){
        if(layoutOptions.get(i).isMouseHere() && layoutOptions.get(i).isActive()){
          int layoutSelected = i+1;
          println("Layout [" + layoutSelected + "] selected.");
          output("Layout [" + layoutSelected + "] selected.");
          layoutOptions.get(i).setIsActive(false);
          toggleVisibility(); //shut layoutSelector if something is selected
        }
      }
    }
  }

  void screenResized(){
    //update position of outer box and buttons
    int oldX = x;
    x = width - w;
    int dx = oldX - x;
    for(int i = 0; i < layoutOptions.size(); i++){
      layoutOptions.get(i).setX(layoutOptions.get(i).but_x - dx);
    }

  }

  void toggleVisibility(){
    isVisible = !isVisible;
    if(isVisible){
      //the very convoluted way of locking all controllers of a single controlP5 instance...
      for(int i = 0; i < cp5_HeadPlot.getAll().size(); i++){
        cp5_HeadPlot.getController(cp5_HeadPlot.getAll().get(i).getAddress()).lock();
      }
    }else{
      //the very convoluted way of unlocking all controllers of a single controlP5 instance...
      for(int i = 0; i < cp5_HeadPlot.getAll().size(); i++){
        cp5_HeadPlot.getController(cp5_HeadPlot.getAll().get(i).getAddress()).unlock();
      }
    }
  }

  void addLayoutOptionButton(){

    //FIRST ROW

    //setup button 1 -- full screen
    Button tempLayoutButton = new Button(x + margin, y + margin, b_w, b_h, "N/A");
    PImage tempBackgroundImage = loadImage("layout_buttons/layout_1.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 2 -- 2x2
    tempLayoutButton = new Button(x + 2*margin + b_w*1, y + margin, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_2.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 3 -- 2x1
    tempLayoutButton = new Button(x + 3*margin + b_w*2, y + margin, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_3.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 4 -- 1x2
    tempLayoutButton = new Button(x + 4*margin + b_w*3, y + margin, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_4.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //SECOND ROW

    //setup button 5
    tempLayoutButton = new Button(x + margin, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_5.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 6
    tempLayoutButton = new Button(x + 2*margin + b_w*1, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_6.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 7
    tempLayoutButton = new Button(x + 3*margin + b_w*2, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_7.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 8
    tempLayoutButton = new Button(x + 4*margin + b_w*3, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_8.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //THIRD ROW -- commented until more widgets are added
    
    // h = margin*4 + b_h*3;
    // //setup button 9
    // tempLayoutButton = new Button(x + margin, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
    // tempBackgroundImage = loadImage("layout_buttons/layout_9.png");
    // tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    // layoutOptions.add(tempLayoutButton);
    //
    // //setup button 10
    // tempLayoutButton = new Button(x + 2*margin + b_w*1, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
    // tempBackgroundImage = loadImage("layout_buttons/layout_10.png");
    // tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    // layoutOptions.add(tempLayoutButton);
    //
    // //setup button 11
    // tempLayoutButton = new Button(x + 3*margin + b_w*2, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
    // tempBackgroundImage = loadImage("layout_buttons/layout_11.png");
    // tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    // layoutOptions.add(tempLayoutButton);
    //
    // //setup button 12
    // tempLayoutButton = new Button(x + 4*margin + b_w*3, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
    // tempBackgroundImage = loadImage("layout_buttons/layout_12.png");
    // tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    // layoutOptions.add(tempLayoutButton);

  }

  void updateLayoutOptionButtons(){

  }

}
