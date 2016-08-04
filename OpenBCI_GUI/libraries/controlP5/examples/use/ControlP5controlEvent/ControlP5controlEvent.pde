/**
 * ControlP5 ControlEvent.
 * every control event is automatically forwarded to the function controlEvent(ControlEvent)
 * inside a sketch if such function is available. For further details about the API of 
 * the ControlEvent class, please refer to the documentation.
 *
 *
 * find a list of public methods available for ControlEvent
 * at the bottom of this sketch's source code
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlP5
 *
 */

import controlP5.*;

ControlP5 cp5;

public int myColorRect1 = 200;

public int myColorRect2 = 100;


void setup() {
  size(400, 400);
  noStroke();
  
  cp5 = new ControlP5(this);
  cp5.addNumberbox("n1")
     .setValue(myColorRect1)
     .setPosition(20, 20)
     .setSize(100, 20)
     .setMin(0)
     .setMax(255)
     .setId(1);
     
  cp5.addNumberbox("n2")
     .setValue(myColorRect2)
     .setPosition(20, 60)
     .setSize(100, 20)
     .setMin(0)
     .setMax(255)
     .setId(2);
     
  cp5.addTextfield("n3")
     .setPosition(20, 100)
     .setSize(100, 20)
     .setId(3);
     
}

void draw() {
  background(ControlP5.MAROON);
  fill(ControlP5.RED, myColorRect1);
  rect(140, 20, 240, 170);
  fill(ControlP5.FUCHSIA, myColorRect2);
  rect(140, 210, 240, 170);
}


void controlEvent(ControlEvent theEvent) {
  println("got a control event from controller with id "+theEvent.getController().getId());
  
  if (theEvent.isFrom(cp5.getController("n1"))) {
    println("this event was triggered by Controller n1");
  }
  
  switch(theEvent.getController().getId()) {
    case(1):
    myColorRect1 = (int)(theEvent.getController().getValue());
    break;
    case(2):
    myColorRect2 = (int)(theEvent.getController().getValue());
    break;
    case(3):
    println(theEvent.getController().getStringValue());
    break;
  }
}


/*
a list of all methods available for the ControlEvent Controller
use ControlP5.printPublicMethodsFor(ControlEvent.class);
to print the following list into the console.

You can find further details about class ControlEvent in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.ControlEvent : ControlGroup getGroup() 
controlP5.ControlEvent : Controller getController() 
controlP5.ControlEvent : String getLabel() 
controlP5.ControlEvent : String getName() 
controlP5.ControlEvent : String getStringValue() 
controlP5.ControlEvent : String toString() 
controlP5.ControlEvent : Tab getTab() 
controlP5.ControlEvent : boolean isAssignableFrom(Class) 
controlP5.ControlEvent : boolean isController() 
controlP5.ControlEvent : boolean isFrom(ControllerInterface) 
controlP5.ControlEvent : boolean isFrom(String) 
controlP5.ControlEvent : boolean isGroup() 
controlP5.ControlEvent : boolean isTab() 
controlP5.ControlEvent : float getArrayValue(int) 
controlP5.ControlEvent : float getValue() 
controlP5.ControlEvent : float[] getArrayValue() 
controlP5.ControlEvent : int getId() 
controlP5.ControlEvent : int getType() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:22:35

*/


