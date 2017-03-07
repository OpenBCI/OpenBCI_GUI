
/**
* ControlP5 Mouseover
*
*
* this example demonstrates the use of the mouseover methods 
* isMouseOver(), getMouseOverList()
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/


import controlP5.*;

ControlP5 cp5;

public int slider1 = 64;
public int slider2 = 128;


void setup() {
  size(700, 400);
  smooth(8);
  cp5 = new ControlP5(this);

  cp5.addSlider("slider1", 0, 255, 20, 100, 128, 20);
  cp5.addSlider("slider2", 0, 255, 20, 150, 128, 20);

  ScrollableList l = cp5.addScrollableList("myList", 250, 260, 200, 80);
  for (int i=0;i<80;i++) {
    l.addItem("item "+i, i);
  }
  
  cp5.addButton("b1", 0, 20, 350, 80, 20);
  cp5.addButton("b2", 0, 101, 350, 80, 20);

}

color hover = color(0, 230, 150);

void draw() {
  background(ControlP5.BLACK);
  // check if the mouse is inside of any of the controllers 
  // displayed in the main window
  if(cp5.isMouseOver()) {
    fill(hover);
  } else {
    fill(128);
  }
  
  ellipse(45,50,50,50);
  
  // check if the mouse is hovering controller slider1 and set the color accordingly
  fill(cp5.isMouseOver(cp5.getController("slider1")) ? hover:color(slider1));
  rect(250, 100, 200, 20);
  
  
  fill(cp5.isMouseOver(cp5.getController("slider2")) ? hover:color(slider2));
  rect(250, 150, 200, 20);
  
  fill(cp5.isMouseOver(cp5.getController("b1")) ? hover:color(128));
  ellipse(30, 330, 20, 20);
  
  fill(cp5.isMouseOver(cp5.getController("b2")) ? hover:color(128));
  ellipse(110, 330, 20, 20);
  
  fill(cp5.isMouseOver(cp5.getController("myList")) ? hover:color(128));
  ellipse(260, 230, 20, 20);
  
}


void mousePressed() {
  // print the current mouseoverlist on mouse pressed
  print("The Current mouseoverlist:\t");
  println(cp5.getWindow().getMouseOverList());
}


/*
a list of all methods available for the ControlP5 Controller
use ControlP5.printPublicMethodsFor(ControlP5.class);
to print the full list into the console.

You can find further details about class ControlP5 in the javadoc.

Format:
ClassName : returnType methodName(parameter type)

controlP5.ControlP5 : List getMouseOverList() 
controlP5.ControlP5 : boolean isMouseOver() 
controlP5.ControlP5 : boolean isMouseOver(ControllerInterface) 

*/


