
////////////////////////////////////////////////////
//
// This class creates an FFT Plot separate from the old Gui_Manager
//
// Conor Russomanno, July 2016
//
// Requires the plotting library from grafica ... replacing the old gwoptics (which is now no longer supported)
//
///////////////////////////////////////////////////

class W_template extends Widget {

  //to see the variables

  W_template(PApplet _parent, int _parentContainer){
    super(_parent, _parentContainer);

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    addDropdown("Dropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
    addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
    addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);
    setupDropdowns();

  }

  void update(){
    super.update(); //calls the parent update() method of Widget

    //put your code here

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget
    //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    //put your code here

  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget

    //put your code here

  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget

    //put your code here

  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget

    //put your code here

  }

};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void Dropdown1(int n){
  println("Item " + (n+1) + " selected from Dropdown 1");
  if(n==0){
    //do this
  } else if(n==1){
    //do this instead
  }
}

void Dropdown2(int n){
  println("Item " + (n+1) + " selected from Dropdown 2");
}

void Dropdown3(int n){
  println("Item " + (n+1) + " selected from Dropdown 3");
}
