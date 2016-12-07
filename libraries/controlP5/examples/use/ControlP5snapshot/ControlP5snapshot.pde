/**
 * ControlP5 snapshot
 *
 * this example shows how to use the snapshot methods for ControllerProperties.
 * Snapshots allow you to save controller states in memory, recall, save and remove them.
 *
 * How to load, save and remove snapshots? see keyPressed()
 *
 * find a list of public methods available for the ControllerProperties Controller
 * at the bottom of this sketch.
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */





import controlP5.*;
ControlP5 cp5;

public float n = 50;
public float s = 10;
public float k = 100;

void setup() {
  size(400, 400);
  smooth();
  cp5 = new ControlP5(this);

  cp5.addNumberbox("n")
  .setPosition(10, 10)
  .setSize(42, 16)
  .setMultiplier(0.1)
  .setRange(10,60)
  .setValue(20)
  ;

  cp5.addSlider("s")
  .setPosition(10, 100)
  .setSize(100, 20)
  .setScrollSensitivity(0.01)
  .setRange(60,140)
  .setValue(100)
  ;
  

  cp5.addKnob("k")
  .setPosition(200, 100)
  .setRadius(50)
  .setScrollSensitivity(0.001)
  .setMin(60)
  .setMax(140)
  .setDisplayStyle(Controller.ARC)
  ;

  cp5.addRange("r")
  .setPosition(10,200)
  .setSize(100,20)
  .setRange(0, 200)
  .setRangeValues(50,100)
  ;
} 


void draw() {
  background(0);
}


void keyPressed() {
  switch(key) {
    case('1'):
    cp5.getProperties().setSnapshot("hello1");
    break;
    case('2'):
    cp5.getProperties().setSnapshot("hello2");
    break;
    case('3'):
    cp5.getProperties().setSnapshot("hello3");
    break;

    case('a'):
    cp5.getProperties().getSnapshot("hello1");
    break;
    case('s'):
    cp5.getProperties().getSnapshot("hello2");
    break;
    case('d'):
    cp5.getProperties().getSnapshot("hello3");
    break;
    
    case('z'):
    cp5.getProperties().removeSnapshot("hello1");
    break;
    case('x'):
    cp5.getProperties().removeSnapshot("hello2");
    break;
    case('c'):
    cp5.getProperties().removeSnapshot("hello3");
    break;
    
    case('i'):
    cp5.getProperties().saveSnapshot("hello1");
    break;
    case('o'):
    cp5.getProperties().load("hello1.ser");
    break;
  }

  println(cp5.getProperties().getSnapshotIndices());
}



/*
a list of all methods available for the ControllerProperties Controller
use ControlP5.printPublicMethodsFor(ControllerProperties.class);
to print the following list into the console.

You can find further details about class ControllerProperties in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.ControllerProperties : ArrayList getSnapshotIndices() 
controlP5.ControllerProperties : ControllerProperties addSet(String) 
controlP5.ControllerProperties : ControllerProperties delete(ControllerProperty) 
controlP5.ControllerProperties : ControllerProperties getSnapshot(String) 
controlP5.ControllerProperties : ControllerProperties move(ControllerInterface, String, String) 
controlP5.ControllerProperties : ControllerProperties move(ControllerProperty, String, String) 
controlP5.ControllerProperties : ControllerProperties only(ControllerProperty, String) 
controlP5.ControllerProperties : ControllerProperties print() 
controlP5.ControllerProperties : ControllerProperties register(ControllerInterface, String) 
controlP5.ControllerProperties : ControllerProperties remove(ControllerInterface) 
controlP5.ControllerProperties : ControllerProperties remove(ControllerInterface, String) 
controlP5.ControllerProperties : ControllerProperties remove(ControllerInterface, String, String) 
controlP5.ControllerProperties : ControllerProperties removeSnapshot(String) 
controlP5.ControllerProperties : ControllerProperties saveSnapshot(String) 
controlP5.ControllerProperties : ControllerProperties saveSnapshotAs(String, String) 
controlP5.ControllerProperties : ControllerProperties setSnapshot(String) 
controlP5.ControllerProperties : ControllerProperties updateSnapshot(String) 
controlP5.ControllerProperties : ControllerProperty getProperty(ControllerInterface, String) 
controlP5.ControllerProperties : ControllerProperty getProperty(ControllerInterface, String, String) 
controlP5.ControllerProperties : ControllerProperty register(ControllerInterface, String, String) 
controlP5.ControllerProperties : HashSet getPropertySet(ControllerInterface) 
controlP5.ControllerProperties : List get(ControllerInterface) 
controlP5.ControllerProperties : Map get() 
controlP5.ControllerProperties : String toString() 
controlP5.ControllerProperties : boolean load() 
controlP5.ControllerProperties : boolean load(String) 
controlP5.ControllerProperties : boolean save() 
controlP5.ControllerProperties : boolean saveAs(String) 
controlP5.ControllerProperties : void setFormat(Format) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 


*/



