
int navHeight = 22;
float[] smoothFac = new float[]{0.0, 0.5, 0.75, 0.9, 0.95, 0.98}; //used by FFT & Headplot
int smoothFac_ind = 2;    //initial index into the smoothFac array = 0.75 to start .. used by FFT & Head Plots
color bgColor = color(1, 18, 41);

FFT_Widget fft_widget;

void setupGUIWidgets() {
  headPlot_widget = new HeadPlot_Widget(this);
  fft_widget = new FFT_Widget(this);
  Container motor_container = new Container(0.6 * width, 0.07 * height, 0.4 * width, 0.45 * height, 0);

  motorWidget = new Motor_Imagery_Widget(nchan, openBCI.get_fs_Hz(), motor_container);

}

void updateGUIWidgets() {
  headPlot_widget.update();
  fft_widget.update();
}

void drawGUIWidgets() {
  //if () {
  headPlot_widget.draw();
  fft_widget.draw();

  //}
}

void GUIWidgets_screenResized(int _winX, int _winY) {
  headPlot_widget.screenResized(this, _winX, _winY);
  fft_widget.screenResized(this, _winX, _winY);
}

void GUIWidgets_mousePressed() {
  motorWidget.mousePressed();
}

void GUIWidgets_mouseReleased() {
  
  motorWidget.mouseReleased();
  headPlot_widget.mousePressed();
  fft_widget.mousePressed();
  
}



//void GUIWidgets_keyPressed() {
//  headPlot_widget.keyPressed();
//  fft_widget.keyPressed();
//}

//void GUIWidgets_keyReleased() {
//  headPlot_widget.keyReleased();
//  fft_widget.keyReleased();
//}
