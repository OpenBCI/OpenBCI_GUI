/**
 * ControlP5 properties sets.
 *
 * saves/loads controller values into/from properties-file.
 * this example shows how to make property sets of controllers that can be loaded and
 * saved individually. By default property files come in a serialized format 
 * with a .ser extension.
 *
 *
 * default properties load/save key combinations are 
 * alt+shift+l to load properties
 * alt+shift+s to save properties
 *
 *
 * find a list of public methods available for the ControllerPropererties Controller 
 * at the bottom of this sketch's source code
 *
 * by andreas schlegel, 2011
 * www.sojamo.de/libraries/controlp5
 * 
 */

import controlP5.*;

ControlP5 cp5;

public int slider1 = 32;
public int slider2 = 64;
public int slider3 = 128;
public int slider4 = 255;


void setup() {
  size(400, 600);
  cp5 = new ControlP5(this);
  
  // add a vertical slider
  cp5.addSlider("slider1", 0, 255, 20, 100, 128, 20);
  cp5.addSlider("slider2", 0, 255, 20, 150, 128, 20);
  cp5.addSlider("slider3", 0, 255, 20, 200, 128, 20);
  cp5.addSlider("slider4", 0, 255, 20, 250, 128, 20);

  cp5.addButton("b1", 0, 20, 350, 80, 12).setCaptionLabel("save setA");
  cp5.addButton("b2", 0, 101, 350, 80, 12).setCaptionLabel("load setA").setColorBackground(color(0, 100, 50));

  cp5.addButton("b3", 0, 200, 350, 80, 12).setCaptionLabel("save default");
  cp5.addButton("b4", 0, 281, 350, 80, 12).setCaptionLabel("load default").setColorBackground(color(0, 100, 50));

  
  // add a new properties set 'setA'
  cp5.getProperties().addSet("setA");

  // move controller 'slider' from the default set to setA
  // the 3 parameters read like this: move controller(1) from set(2) to set(3) 
  cp5.getProperties().move(cp5.getController("slider1"), "default", "setA");
  // use copy instead of move to register 'slider' with both sets (default and setA)

  // prints the current list of properties registered and the set(s) they belong to 
  cp5.getProperties().print();
  
  /* by default properties are saved in JSON format, if you want to change to the old default (java's serialized format), un-comment line below*/
  // cp5.getProperties().setFormat(ControlP5.SERIALIZED);
}

void draw() {
  background(0);

  fill(slider1);
  rect(250, 100, 100, 20);

  fill(slider2);
  rect(250, 150, 100, 20);

  fill(slider3);
  rect(250, 200, 100, 20);

  fill(slider4);
  rect(250, 250, 100, 20);
}

void b1(float v) {
  cp5.saveProperties("setA", "setA");
}

void b2(float v) {
  cp5.loadProperties(("setA"));
}

void b3(float v) {
  cp5.saveProperties("default", "default");
}

void b4(float v) {
  cp5.loadProperties(("default.json"));
}





/*
 a list of all methods available for the ControllerProperties class
 use ControlP5.printPublicMethodsFor(ControllerProperties.class);
 to print the following list into the console.
 
 You can find further details about class ControllerProperties in the javadoc.
 
 Format:
 ClassName : returnType methodName(parameter type)
 
controlP5.ControllerProperties : ControllerProperties remove(ControllerInterface) 
controlP5.ControllerProperties : ControllerProperties remove(ControllerInterface, String) 
controlP5.ControllerProperties : ControllerProperties remove(ControllerInterface, String, String) 
controlP5.ControllerProperties : ControllerProperty getProperty(ControllerInterface, String) 
controlP5.ControllerProperties : ControllerProperty getProperty(ControllerInterface, String, String) 
controlP5.ControllerProperties : ControllerProperty register(ControllerInterface, String) 
controlP5.ControllerProperties : ControllerProperty register(ControllerInterface, String, String) 
controlP5.ControllerProperties : HashSet addSet(String) 
controlP5.ControllerProperties : HashSet getPropertySet(ControllerInterface) 
controlP5.ControllerProperties : List get(ControllerInterface) 
controlP5.ControllerProperties : Map get() 
controlP5.ControllerProperties : String toString() 
controlP5.ControllerProperties : boolean load() 
controlP5.ControllerProperties : boolean load(String) 
controlP5.ControllerProperties : void delete(ControllerProperty) 
controlP5.ControllerProperties : void move(ControllerInterface, String, String) 
controlP5.ControllerProperties : void move(ControllerProperty, String, String) 
controlP5.ControllerProperties : void only(ControllerProperty, String) 
controlP5.ControllerProperties : void print() 
controlP5.ControllerProperties : void setFormat(Format) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 
*/
