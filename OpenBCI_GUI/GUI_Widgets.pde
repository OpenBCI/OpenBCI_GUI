
int navHeight = 25;

void setupGUIWidgets() {
  fft_widget = new FFT_Widget(this);
  headPlot_widget = new HeadPlot_Widget();
  
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

void GUIWidgets_mousePressed(){
  
}

void GUIWidgets_mouseReleased(){
  
}

void GUIWidgets_keyPressed(){
  
}

void GUIWidgets_keyReleased(){
  
}