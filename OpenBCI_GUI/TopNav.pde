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
  }

  void screenHasBeenResized(int _x, int _y){
    questionMark.but_x = width - 3 - 26;
    layout.but_x = width - 3 - 70;
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
  }

  void mouseReleased(){

    if (layout.isMouseHere()) {
      layout.setIsActive(true);
      wm.printLayouts();
    }

    stopButton.setIsActive(false);

    filtBPButton.setIsActive(false);
    filtNotchButton.setIsActive(false);
    intensityFactorButton.setIsActive(false);

    questionMark.setIsActive(false);
    layout.setIsActive(false);
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
