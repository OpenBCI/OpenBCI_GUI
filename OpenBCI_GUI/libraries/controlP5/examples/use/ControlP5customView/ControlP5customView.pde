/**
* ControlP5 Custom View
*
*
* find a list of public methods available for the ControllerDisplay Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/


import controlP5.*;


ControlP5 cp5;


void setup() {
  size(400, 400);
  smooth();
  cp5 = new ControlP5(this);
  cp5.addButton("hello")
     .setPosition(50, 100)
     .setSize(150,150)
     .setView(new CircularButton())
     ;
     
  cp5.addButton("world")
     .setPosition(250, 100)
     .setSize(50,50)
     .setView(new CircularButton())
     ;
}


void draw() {
  background(ControlP5.BLACK);
}

public void hello(int theValue) {
  println("Hello pressed");
}

public void world(int theValue) {
  println("World pressed");
}

/**
 * to define a custom View for a controller use the ContollerView<T> interface
 * T here must be replace by the name of the Controller class your custom View will be 
 * applied to. In our example T is replace by Button since we are aplpying the View 
 * to the Button instance create in setup. The ControllerView interface requires
 * you to implement the display(PApplet, T) method. Same here, T must be replaced by
 * the Controller class you are designing the custom view for, for us this is the 
 * Button class. 
 */
 
class CircularButton implements ControllerView<Button> {

  public void display(PGraphics theApplet, Button theButton) {
    theApplet.pushMatrix();
    if (theButton.isInside()) {
      if (theButton.isPressed()) { // button is pressed
        theApplet.fill(ControlP5.LIME);
      }  else { // mouse hovers the button
        theApplet.fill(ControlP5.YELLOW);
      }
    } else { // the mouse is located outside the button area
      theApplet.fill(ControlP5.GREEN);
    }
    
    theApplet.ellipse(0, 0, theButton.getWidth(), theButton.getHeight());
    
    // center the caption label 
    int x = theButton.getWidth()/2 - theButton.getCaptionLabel().getWidth()/2;
    int y = theButton.getHeight()/2 - theButton.getCaptionLabel().getHeight()/2;
    
    translate(x, y);
    theButton.getCaptionLabel().draw(theApplet);
    
    theApplet.popMatrix();
  }
}


/*
a list of all methods available for the ControllerView Controller
use ControlP5.printPublicMethodsFor(ControllerView.class);
to print the following list into the console.

You can find further details about class ControllerView in the javadoc.

Format:
ClassName : returnType methodName(parameter type)

controlP5.ControllerView : void display(PApplet, T)

*/

