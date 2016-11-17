
////////////////////////////////////////////////////
//
// This class creates an FFT Plot separate from the old Gui_Manager
// It extends the Widget class
//
// Conor Russomanno, November 2016
//
// Requires the plotting library from grafica ... replacing the old gwoptics (which is now no longer supported)
//
///////////////////////////////////////////////////

W_FFT widget_FFT;

class W_FFT extends Widget {


  W_FFT(PApplet _parent){
    super(_parent);

    parentContainer = 9;

    // String[] dropdownItems = {"20 Hz", "40 Hz", "60 Hz", "120 Hz"};
    addDropdown("MaxFreq", "Max Freq", new String[]{"20 Hz", "40 Hz", "60 Hz", "120 Hz"}, 2);
    addDropdown("VertScale", "Vert Scale", new String[]{"10 uV", "50 uV", "100 uV", "1000 uV"}, 1);
    addDropdown("LogLin", "Log/Lin", new String[]{"10 uV", "50 uV", "100 uV", "1000 uV"}, 0);
    addDropdown("Smoothing", "Smooth Fac", new String[]{"10 uV", "50 uV", "100 uV", "1000 uV"}, 0);
    addDropdown("UnfiltFilt", "Filters?", new String[]{"Filtered", "Unfilt."}, 0);


  }

  void update(){

  }
  void draw(){

  }
  void mousePressed(){

  }
  void mouseReleased(){

  }

};
