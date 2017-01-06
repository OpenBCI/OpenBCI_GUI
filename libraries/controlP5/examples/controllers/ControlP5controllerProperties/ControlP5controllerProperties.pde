/**
 * ControlP5 Properties 
 *
 *
 * saves controller values to a properties-file
 * loads controller values from a properties-file
 *
 * Properties will only save values not the Controller itself.
 * 
 * Also take a look at the use/ControlP5snapshot example to 
 * save controller values to memory.
 *
 * Use ControllerProperties to load and save serialized controller properties 
 * to a properties file. 
 * The controllers implementing save/load properties so far are 
 * Slider, Knob, Numberbox, Toggle, Checkbox, RadioButton, Textlabel, 
 * Matrix, Range, Textarea, ListBox, Dropdown, ColorPicker. 
 * Properties are currently saved in the java serialization format.
 *
 * saveProperties(String theFilename) and loadProperties(String theFilename) 
 * by default properties will be saved to your sketch folder as controlP5.ser
 * if that file already exists it will be overwritten. for custom property files
 * see the comments inside keyPressed() below.
 *
 * find a list of public methods available for the ControllerProperties class 
 * at the bottom of this sketch's source code
 *
 * default properties load/save key combinations are 
 * alt+shift+l to load properties
 * alt+shift+s to save properties
 *
 * by andreas schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */

import controlP5.*;

ControlP5 cp5;
public int myColor = color(0, 0, 0);

public int sliderValue = 100;
public int sliderTicks1 = 100;
public int sliderTicks2 = 30;


void setup() {
  size(700, 400);
  noStroke();
  
  cp5 = new ControlP5(this);
  
  cp5.addSlider("slider")
     .setBroadcast(false)
     .setRange(0, 200)
     .setPosition(20, 100)
     .setSize(10, 100)
     .setBroadcast(true)
     .setValue(100)
     ;
  
  cp5.addSlider("sliderTicks1")
     .setRange(0, 255)
     .setPosition(100, 100)
     .setSize(10, 100)
     .setNumberOfTickMarks(5)
     ;

  cp5.addSlider("sliderValue")
     .setRange(0, 255)
     .setValue(128)
     .setPosition(200, 180)
     .setSize(100, 10)
     ;
     
  cp5.addSlider("sliderTicks2")
     .setRange(0, 255)
     .setValue(128)
     .setPosition(200, 220)
     .setSize(100, 10)
     .setNumberOfTickMarks(7)
     .setSliderMode(Slider.FLEXIBLE)
     ;
     
}

void draw() {
  background(sliderTicks1);

  fill(sliderValue);
  rect(0, 0, width, 100);

  fill(myColor);
  rect(0, 300, width, 70);

  fill(sliderTicks2);
  rect(0, 370, width, 30);
}

public void slider(float theColor) {
  myColor = color(theColor);
  println("a slider event. setting background to "+theColor);
}

void keyPressed() {
  // default properties load/save key combinations are 
  // alt+shift+l to load properties
  // alt+shift+s to save properties
  if (key=='1') {
    cp5.saveProperties(("hello.properties"));
  } 
  else if (key=='2') {
    cp5.loadProperties(("hello.properties"));
  }
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
controlP5.ControllerProperties : void setFormat(PropertiesStorageFormat) 
controlP5.ControllerProperties : void setFormat(String) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:03

*/


