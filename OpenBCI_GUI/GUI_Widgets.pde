
int navHeight = 22;

void setupGUIWidgets() {
  fft_widget = new FFT_Widget(this);
  headPlot_widget = new HeadPlot_Widget(this);
  
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

void GUIWidgets_screenResized(int _winX, int _winY){
  headPlot_widget.screenResized(this, _winX, _winY);
  fft_widget.screenResized(this, _winX, _winY);
}

void GUIWidgets_mousePressed(){
  
}

void GUIWidgets_mouseReleased(){
  
}

void GUIWidgets_keyPressed(){
  
}

void GUIWidgets_keyReleased(){
  
}