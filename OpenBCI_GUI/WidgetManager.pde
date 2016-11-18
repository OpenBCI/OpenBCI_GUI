
int navHeight = 22;
float[] smoothFac = new float[]{0.0, 0.5, 0.75, 0.9, 0.95, 0.98}; //used by FFT & Headplot
int smoothFac_ind = 2;    //initial index into the smoothFac array = 0.75 to start .. used by FFT & Head Plots
color bgColor = color(1, 18, 41);

FFT_Widget fft_widget;
OpenBionics_Widget ob_widget;

void setupGUIWidgets() {
  // timeSeries_widget = new W_TimeSeries(this, 4);
  // headPlot_widget = new HeadPlot_Widget(this);
  // fft_widget = new FFT_Widget(this);
  // ob_widget = new OpenBionics_Widget(this);
  // Container motor_container = new Container(0.6 * width, 0.07 * height, 0.4 * width, 0.45 * height, 0);
  // Container accel_container = new Container(0.6 * width, 0.07 * height, 0.4 * width, 0.45 * height, 0);
  //
  // emg_widget = new EMG_Widget(nchan, openBCI.get_fs_Hz(), motor_container, this);

  wm = new WidgetManager(this);
}

void updateGUIWidgets() {
  // timeSeries_widget.update();
  // headPlot_widget.update();
  // fft_widget.update();
  // ob_widget.update();

  wm.update();
}

void drawGUIWidgets() {
  // if(drawTimeSeries){
  //   timeSeries_widget.draw();
  //   headPlot_widget.draw();
  //   fft_widget.draw();
  //   ob_widget.draw();
  // }

  wm.draw();
}

void GUIWidgets_screenResized(int _winX, int _winY) {
  // timeSeries_widget.screenResized(this, _winX, _winY);
  // headPlot_widget.screenResized(this, _winX, _winY);
  // fft_widget.screenResized(this, _winX, _winY);
  // ob_widget.screenResized(this,_winX,_winY);
  // emg_widget.screenResized(this, _winX, _winY);

  wm.screenResized();
}

void GUIWidgets_mousePressed() {
  // timeSeries_widget.mousePressed();
  // headPlot_widget.mousePressed();
  // fft_widget.mousePressed();
  // emg_widget.mousePressed();
  // ob_widget.mousePressed();

  wm.mousePressed();
}

void GUIWidgets_mouseReleased() {
  // timeSeries_widget.mouseReleased();
  // headPlot_widget.mouseReleased();
  // fft_widget.mouseReleased();
  // emg_widget.mouseReleased();
  // ob_widget.mouseReleased();

  wm.mouseReleased();
}

//========================================================================================
//========================================================================================
//========================================================================================

WidgetManager wm;

class WidgetManager{

  int containerConfiguration;

  //List of all Widgets
  W_template w_template;
  W_template w_template2;
  W_template w_template3;
  // W_fft w_fft;
  // W_timeSeries w_timeSeries;

  //Let's test this:
  ArrayList<Widget> widgets;

  WidgetManager(PApplet _this){
    widgets = new ArrayList<Widget>();
    setupWidgets(_this);

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
    for(int i = 0; i < widgets.size(); i++){
      widgets.get(i).update();
    }
  }

  void draw(){
    for(int i = 0; i < widgets.size(); i++){
      widgets.get(i).draw();
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

  void setContainerLayout(int _containerConfiguration){
    //
  }
};
