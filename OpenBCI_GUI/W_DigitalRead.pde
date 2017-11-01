
////////////////////////////////////////////////////
//
//    W_PulseSensor.pde
//
//    Created: Joel Murphy, Spring 2017
//
///////////////////////////////////////////////////,

class W_DigitalRead extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...

  // testing stuff

  Button digitalModeButton;

  W_DigitalRead(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    digitalModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "Turn Digital Read On", 12);
    digitalModeButton.setCornerRoundess((int)(navHeight-6));
    digitalModeButton.setFont(p6,10);
    digitalModeButton.setColorNotPressed(color(57,128,204));
    digitalModeButton.textColorNotActive = color(255);
    digitalModeButton.hasStroke(false);
    if (cyton.isWifi()) {
      digitalModeButton.setHelpText("Click this button to activate digital reading on the Cyton D11, D12, and D17");
    } else {
      digitalModeButton.setHelpText("Click this button to activate digital reading on the Cyton D11, D12, D13, D17 and D18");
    }

  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)


    //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    pushStyle();

    digitalModeButton.draw();

    popStyle();
  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    println("Digital Read Widget -- Screen Resized.");

    digitalModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    if (digitalModeButton.isMouseHere()) {
      digitalModeButton.setIsActive(true);
    }
  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(digitalModeButton.isActive && digitalModeButton.isMouseHere()){
      // println("digitalModeButton...");
      if(cyton.isPortOpen()) {

        if (cyton.getBoardMode() != BOARD_MODE_DIGITAL) {
          cyton.setBoardMode(BOARD_MODE_DIGITAL);
          output("Starting to read digital inputs on pin marked D11");
          digitalModeButton.setString("Turn Digital Read Off");
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
          digitalModeButton.setString("Turn Digital Read On");
        }
      }
    }
    digitalModeButton.setIsActive(false);
  }

  //add custom functions here

};
