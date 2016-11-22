
int navHeight = 22;
float[] smoothFac = new float[]{0.0, 0.5, 0.75, 0.9, 0.95, 0.98}; //used by FFT & Headplot
int smoothFac_ind = 2;    //initial index into the smoothFac array = 0.75 to start .. used by FFT & Head Plots
color bgColor = color(1, 18, 41);

FFT_Widget fft_widget;
OpenBionics_Widget ob_widget;

void setupGUIWidgets() {
  timeSeries_widget = new W_TimeSeries(this, 4);
  headPlot_widget = new HeadPlot_Widget(this);
  fft_widget = new FFT_Widget(this);
  ob_widget = new OpenBionics_Widget(this);
  Container motor_container = new Container(0.6 * width, 0.07 * height, 0.4 * width, 0.45 * height, 0);
  Container accel_container = new Container(0.6 * width, 0.07 * height, 0.4 * width, 0.45 * height, 0);

  emg_widget = new EMG_Widget(nchan, openBCI.get_fs_Hz(), motor_container, this);

}

void updateGUIWidgets() {
  timeSeries_widget.update();
  headPlot_widget.update();
  fft_widget.update();
  ob_widget.update();

  // wm.update();
}

void drawGUIWidgets() {
  if(drawTimeSeries){
    timeSeries_widget.draw();
    headPlot_widget.draw();
    fft_widget.draw();
    ob_widget.draw();
  }

  // wm.draw();
}

void GUIWidgets_screenResized(int _winX, int _winY) {
  timeSeries_widget.screenResized(this, _winX, _winY);
  headPlot_widget.screenResized(this, _winX, _winY);
  fft_widget.screenResized(this, _winX, _winY);
  ob_widget.screenResized(this,_winX,_winY);
  emg_widget.screenResized(this, _winX, _winY);

  // wm.screenResized();
}

void GUIWidgets_mousePressed() {
  timeSeries_widget.mousePressed();
  headPlot_widget.mousePressed();
  fft_widget.mousePressed();
  emg_widget.mousePressed();
  ob_widget.mousePressed();

  // wm.mousePressed();
}

void GUIWidgets_mouseReleased() {
  timeSeries_widget.mouseReleased();
  headPlot_widget.mouseReleased();
  fft_widget.mouseReleased();
  emg_widget.mouseReleased();
  ob_widget.mouseReleased();

  // wm.mouseReleased();
}

//========================================================================================
//========================================================================================
//========================================================================================

WidgetManager wm;
boolean wmVisible = true;

class WidgetManager{

  //List of all Widgets
  W_template w_template;
  W_template w_template2;
  W_template w_template3;
  // W_fft w_fft;
  // W_timeSeries w_timeSeries;

  //this holds all of the widgets ... when creating/adding new widgets, we will add them to this ArrayList (below)
  ArrayList<Widget> widgets;

  //Variables for
  int currentContainerLayout; //this is the Layout structure for the main body of the GUI ... refer to [PUT_LINK_HERE] for layouts/numbers image
  ArrayList<Layout> layouts = new ArrayList<Layout>();  //this holds all of the different layouts ...

  WidgetManager(PApplet _this){
    widgets = new ArrayList<Widget>();

    currentContainerLayout = 4; //default layout ... tall container left and 2 shorter containers stacked on the right
    setupWidgets(_this);
    setupLayouts();

  }

  void setupWidgets(PApplet _this){
    w_template = new W_template(_this, 3);
    w_template2 = new W_template(_this, 9);
    w_template3 = new W_template(_this, 4);
    // w_fft = new W_fft(_this, 9);
    // w_timeSeries = new W_timeSeries(_this, 4);

    widgets.add(w_template);
    widgets.add(w_template2);
    widgets.add(w_template3);
    // widgets.add(w_fft);
    // widgets.add(w_timeSeries);
  }

  void update(){
    if(wmVisible){
      for(int i = 0; i < widgets.size(); i++){
        widgets.get(i).update();
      }
    }
  }

  void draw(){
    if(wmVisible){
      for(int i = 0; i < widgets.size(); i++){
        widgets.get(i).draw();
      }
    }
  }

  void screenResized(){
    for(int i = 0; i < widgets.size(); i++){
      widgets.get(i).screenResized();
    }
  }

  void mousePressed(){
    for(int i = 0; i < widgets.size(); i++){
      widgets.get(i).mousePressed();
    }
  }

  void mouseReleased(){
    for(int i = 0; i < widgets.size(); i++){
      widgets.get(i).mouseReleased();
    }
  }

  void setupLayouts(){
    //refer to [PUT_LINK_HERE] for layouts/numbers image
    layouts.add(new Layout(new int[]{5}));
    layouts.add(new Layout(new int[]{4,6}));
    layouts.add(new Layout(new int[]{2,8}));
    layouts.add(new Layout(new int[]{1,3,7,9}));
    layouts.add(new Layout(new int[]{4,3,9}));
    layouts.add(new Layout(new int[]{1,7,6}));
    layouts.add(new Layout(new int[]{1,3,8}));
    layouts.add(new Layout(new int[]{2,7,9}));
  }

  void printLayouts(){
    for(int i = 0; i < layouts.size(); i++){
      println(layouts.get(i));
      for(int j = 0; j < layouts.get(i).myContainers.length; j++){
        // println(layouts.get(i).myContainers[j]);
        print(layouts.get(i).myContainers[j].x + ", ");
        print(layouts.get(i).myContainers[j].y + ", ");
        print(layouts.get(i).myContainers[j].w + ", ");
        println(layouts.get(i).myContainers[j].h);
      }
      println();
    }
  }

  void setNewContainerLayout(int _newLayout){
    //find the "layout" that matchies the incoming "New Layout"
    for(int i = 0; i < layouts.size(); i++){
      if(_newLayout == i){

        //use layouts[i] to construct the new Widget Layout of the GUI

        //if (layouts[i].size() > numActiveWidgets)
          //fill the new vacant containers w/ non-active widgets (pick in order of the list of all widgets)
          //make those new widgets active as well
        //else if(layouts.size() < numActiveWidgets)
          //deactivate additional widgets
        //else
          //the new layout has the same number of active widgets ... just need to remap

        //map new containers to new active widgets ... (these numbers should match now, based on above logic)
        //map x/y/w/h values of new Layout containers onto corresponding active widgets

      }
    }
  }
};

//the Layout class is an orgnanizational tool ... a layout consists of a combination of containers ... refer to Container.pde
class Layout{

  Container[] myContainers;

  Layout(int[] _myContainers){ //when creating a new layout, you pass in the integer #s of the containers you want as part of the layout ... so if I pass in the array {5}, my layout is 1 container that takes up the whole GUI body
    //constructor stuff
    myContainers = new Container[_myContainers.length]; //make the myContainers array equal to the size of the incoming array of ints
    for(int i = 0; i < _myContainers.length; i++){
      myContainers[i] = container[_myContainers[i]];
    }
  }

  Container getContainer(int _numContainer){
    if(_numContainer < myContainers.length){
      return myContainers[_numContainer];
    } else{
      println("tried to return a non-existant container...");
      return myContainers[myContainers.length-1];
    }
  }

}
