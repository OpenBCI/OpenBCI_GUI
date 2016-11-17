
////////////////////////////////////////////////////
//
// This class creates an FFT Plot separate from the old Gui_Manager
//
// Conor Russomanno, July 2016
//
// Requires the plotting library from grafica ... replacing the old gwoptics (which is now no longer supported)
//
///////////////////////////////////////////////////

W_Template widget_FFT;

class W_Template extends Widget {


  W_FFT(PApplet _parent){
    super(_parent);

    parentContainer = 9;

    // String[] dropdownItems = {"20 Hz", "40 Hz", "60 Hz", "120 Hz"};
    addDropdown("Dropdown1", "Dropdown 1", new String[]{"A", "B"}, 0);
    addDropdown("Dropdown2", "Dropdown 2", new String[]{"C", "D", "E"}, 1);
    addDropdown("Dropdown3", "Dropdown 3", new String[]{"F", "G", "H", "I"}, 3);

  }

  void update(){

  }

  void draw(){

  }

  void mousePressed(){

  }

  void mouseReleased(){

  }

  void Dropdown1(int n){
    println("Option " + (n+1) " selected..")
  }

  void Dropdown2(int n){
    println("Option " + (n+1) " selected..")
  }

  void Dropdown3(int n){
    println("Option " + (n+1) " selected..")
  }

};
