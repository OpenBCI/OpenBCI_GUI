
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

class W_networking extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...
  Button widgetTemplateButton;
  int protocolMode = 0;

  W_networking(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    addDropdown("Protocol", "Drop 1", Arrays.asList("OSC", "UDC", "LSL", "Serial"), protocolMode);
    // addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
    // addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

    widgetTemplateButton = new Button (x + w/2, y + h/2, 200, navHeight, "Design Your Own Widget!", 12);
    widgetTemplateButton.setFont(p4, 14);
    widgetTemplateButton.setURL("http://docs.openbci.com/OpenBCI%20Software/");

  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    pushStyle();

    if(protocolMode == 0){
      fill(255,0,0);
    } else if (protocolMode == 1){
      fill(0,255,0);
    } else if (protocolMode == 2){
      fill(0,0,255);
    } else if (protocolMode == 3){
      fill(0,255,255);
    }

    rect(x, y, w, h);

    widgetTemplateButton.draw();

    popStyle();

  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    widgetTemplateButton.setPos(x + w/2 - widgetTemplateButton.but_dx/2, y + h/2 - widgetTemplateButton.but_dy/2);


  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...
    if(widgetTemplateButton.isMouseHere()){
      widgetTemplateButton.setIsActive(true);
    }

  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(widgetTemplateButton.isActive && widgetTemplateButton.isMouseHere()){
      widgetTemplateButton.goToURL();
    }
    widgetTemplateButton.setIsActive(false);

  }

  //add custom functions here
  void customFunction(){
    //this is a fake function... replace it with something relevant to this widget

  }

};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void Protocol(int n){
  println("Item " + (n+1) + " selected from Dropdown 1");
  // if(n==0){
  //   protcolMode = 0;
  // } else if(n==1){
  //   protcolMode = 1;
  // } else if(n==2){
  //   protcolMode = 2;
  // } else if(n==3){
  //   protcolMode = 3;
  // }
  w_networking.protocolMode = n;

  closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}
