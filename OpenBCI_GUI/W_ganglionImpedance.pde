
////////////////////////////////////////////////////
//
//    W_template.pde (ie "Widget Template")
//
//    This is a Template Widget, intended to be used as a starting point for OpenBCI Community members that want to develop their own custom widgets!
//    Good luck! If you embark on this journey, please let us know. Your contributions are valuable to everyone!
//
//    Created by: Conor Russomanno, November 2016
//
///////////////////////////////////////////////////,

class W_ganglionImpedance extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...

  W_ganglionImpedance(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    addDropdown("Dropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
    addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
    addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    pushStyle();
    // textFont(h1,24);
    // fill(bgColor);
    // textAlign(CENTER,CENTER);
    // text(widgetTitle, x + w/2, y + h/2);
    fill(0);
    for(int i = 0; i < ganglion.impedanceArray.length; i++){
      String toPrint;
      if(i == 0){
        toPrint = "Reference Impedance = " + ganglion.impedanceArray[i]/1000.0 + " k\u2126";
      } else {
        toPrint = "Channel[" + i + "] Impedance = " + ganglion.impedanceArray[i]/1000.0 + " k\u2126";
      }
      text(toPrint, x + 10, y + 60 + 20*(i));
    }

    for(int i = 0; i < ganglion.impedanceArray.length; i++){
      String toPrint;
      float target = convertRawGanglionImpedanceToTarget(ganglion.impedanceArray[i]/1000.0);
      if(i == 0){
        toPrint = "Reference Impedance = " + target + " k\u2126";
      } else {
        toPrint = "Channel[" + i + "] Impedance = " + target + " k\u2126";
      }
      text(toPrint, x + 10, y + 220 + 20*(i));
    }


    popStyle();

  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...

  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...

  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...

  }

  //add custom classes functions here
  void customFunction(){
    //this is a fake function... replace it with something relevant to this widget
  }

};

public float convertRawGanglionImpedanceToTarget(float _actual){

  //the following impedance adjustment calculations were derived using empirical values from resistors between 1,2,3,4,REF-->D_G
  float _target;

  //V1 -- more accurate for lower impedances (< 22kOhcm) -> y = 0.0034x^3 - 0.1443x^2 + 3.1324x - 10.59
  if(_actual <= 22){
    // _target = (0.0004)*(pow(_actual,3)) - (0.0262)*(pow(_actual,2)) + (1.8349)*(_actual) - 6.6006;
    _target = (0.0034)*(pow(_actual,3)) - (0.1443)*(pow(_actual,2)) + (3.1324)*(_actual) - 10.59;
  }
  //V2 -- more accurate for higher impedances (> 22kOhm) -> y = 0.000009x^4 - 0.001x^3 + 0.0409x^2 + 0.6445x - 1
  else {
    _target = (0.000009)*(pow(_actual,4)) - (0.001)*pow(_actual,3) + (0.0409)*(pow(_actual,2)) + (0.6445)*(pow(_actual,1)) - 1;
  }

  return _target;

}

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
// void Dropdown1(int n){
//   println("Item " + (n+1) + " selected from Dropdown 1");
//   if(n==0){
//     //do this
//   } else if(n==1){
//     //do this instead
//   }
//
//   closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
// }
//
// void Dropdown2(int n){
//   println("Item " + (n+1) + " selected from Dropdown 2");
//   closeAllDropdowns();
// }
//
// void Dropdown3(int n){
//   println("Item " + (n+1) + " selected from Dropdown 3");
//   closeAllDropdowns();
// }
