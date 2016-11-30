
int navHeight = 22;
float[] smoothFac = new float[]{0.0, 0.5, 0.75, 0.9, 0.95, 0.98}; //used by FFT & Headplot
int smoothFac_ind = 2;    //initial index into the smoothFac array = 0.75 to start .. used by FFT & Head Plots
color bgColor = color(1, 18, 41);

FFT_Widget fft_widget;
OpenBionics_Widget ob_widget;

W_TimeSeries timeSeries_widget;
boolean drawTimeSeries = false;

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
  W_template w_template4;
  // W_fft w_fft;
  // W_timeSeries w_timeSeries;

  //this holds all of the widgets ... when creating/adding new widgets, we will add them to this ArrayList (below)
  ArrayList<Widget> widgets;

  //Variables for
  int currentContainerLayout; //this is the Layout structure for the main body of the GUI ... refer to [PUT_LINK_HERE] for layouts/numbers image
  ArrayList<Layout> layouts = new ArrayList<Layout>();  //this holds all of the different layouts ...

  WidgetManager(PApplet _this){
    widgets = new ArrayList<Widget>();

    setupLayouts();
    setupWidgets(_this);

    currentContainerLayout = 4; //default layout ... tall container left and 2 shorter containers stacked on the right
    setNewContainerLayout(currentContainerLayout); //sets and fills layout with widgets in order of widget index, to reorganize widget index, reorder the creation in setupWidgets()

  }

  void setupWidgets(PApplet _this){
    w_template = new W_template(_this);
    w_template.setTitle("Widget 1");

    w_template2 = new W_template(_this);
    w_template2.setTitle("Widget 2");

    w_template3 = new W_template(_this);
    w_template3.setTitle("Widget 3");

    w_template4 = new W_template(_this);
    w_template4.setTitle("Widget 4");
    // w_fft = new W_fft(_this, 9);
    // w_timeSeries = new W_timeSeries(_this, 4);

    widgets.add(w_template);
    widgets.add(w_template2);
    widgets.add(w_template3);
    widgets.add(w_template4);
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
        if(widgets.get(i).isActive){
          widgets.get(i).draw();
        }
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
    //note that the order you create/add these layouts matters... if you reorganize these, the LayoutSelector will be out of order
    layouts.add(new Layout(new int[]{5})); //layout 1
    layouts.add(new Layout(new int[]{1,3,7,9})); //layout 2
    layouts.add(new Layout(new int[]{4,6})); //layout 3
    layouts.add(new Layout(new int[]{2,8})); //etc.
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

    //find out how many active widgets we need...
    int numActiveWidgetsNeeded = layouts.get(_newLayout).myContainers.length;
    //calculate the number of current active widgets & keep track of which widgets are active
    int numActiveWidgets = 0;
    // ArrayList<int> activeWidgets = new ArrayList<int>();
    for(int i = 0; i < widgets.size(); i++){
      if(widgets.get(i).isActive){
        numActiveWidgets++; //increment numActiveWidgets
        // activeWidgets.add(i); //keep track of the active widget
      }
    }

    if(numActiveWidgets > numActiveWidgetsNeeded){ //if there are more active widgets than needed
      //shut some down
      int numToShutDown = numActiveWidgets - numActiveWidgetsNeeded;
      int counter = 0;
      println("Powering " + numToShutDown + " widgets down, and remapping.");
      for(int i = widgets.size()-1; i >= 0; i--){
        if(widgets.get(i).isActive && counter < numToShutDown){
          println("Deactivating widget [" + i + "]");
          widgets.get(i).isActive = false;
          counter++;
        }
      }

      //and map active widgets
      counter = 0;
      for(int i = 0; i < widgets.size(); i++){
        if(widgets.get(i).isActive){
          widgets.get(i).setContainer(layouts.get(_newLayout).containerInts[counter]);
          counter++;
        }
      }

    } else if(numActiveWidgetsNeeded > numActiveWidgets){ //if there are less active widgets than needed
      //power some up
      int numToPowerUp = numActiveWidgetsNeeded - numActiveWidgets;
      int counter = 0;
      println("Powering " + numToPowerUp + " widgets up, and remapping.");
      for(int i = 0; i < widgets.size(); i++){
        if(!widgets.get(i).isActive && counter < numToPowerUp){
          println("Activating widget [" + i + "]");
          widgets.get(i).isActive = true;
          counter++;
        }
      }

      //and map active widgets
      counter = 0;
      for(int i = 0; i < widgets.size(); i++){
        if(widgets.get(i).isActive){
          widgets.get(i).setContainer(layouts.get(_newLayout).containerInts[counter]);
          counter++;
        }
      }

    } else{ //if there are the same mount
      //simply remap active widgets
      println("Remapping widgets.");
      int counter = 0;
      for(int i = 0; i < widgets.size(); i++){
        if(widgets.get(i).isActive){
          widgets.get(i).setContainer(layouts.get(_newLayout).containerInts[counter]);
          counter++;
        }
      }

    }

    //for however many containers there are in the new layout

    // for(int i = 0; i < layouts.get(_newLayout).myContainers.length; i++){
    //   //map the xywh coordinates of widget i to container i
    //   println("yep " + i);
    //   widgets.get(i).setContainer(layouts.get(_newLayout).containerInts[i]);
    // }

    // for(int i = 0; i < layouts.size(); i++){
    //   if(_newLayout == i){
    //
    //     //use layouts[i] to construct the new Widget Layout of the GUI
    //
    //     //if (layouts[i].size() > numActiveWidgets)
    //       //fill the new vacant containers w/ non-active widgets (pick in order of the list of all widgets)
    //       //make those new widgets active as well
    //     //else if(layouts.size() < numActiveWidgets)
    //       //deactivate additional widgets
    //     //else
    //       //the new layout has the same number of active widgets ... just need to remap
    //
    //     //map new containers to new active widgets ... (these numbers should match now, based on above logic)
    //     //map x/y/w/h values of new Layout containers onto corresponding active widgets
    //
    //   }
    // }
  }
};

//the Layout class is an orgnanizational tool ... a layout consists of a combination of containers ... refer to Container.pde
class Layout{

  Container[] myContainers;
  int[] containerInts;

  Layout(int[] _myContainers){ //when creating a new layout, you pass in the integer #s of the containers you want as part of the layout ... so if I pass in the array {5}, my layout is 1 container that takes up the whole GUI body
    //constructor stuff
    myContainers = new Container[_myContainers.length]; //make the myContainers array equal to the size of the incoming array of ints
    containerInts = new int[_myContainers.length];
    for(int i = 0; i < _myContainers.length; i++){
      myContainers[i] = container[_myContainers[i]];
      containerInts[i] = _myContainers[i];
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
