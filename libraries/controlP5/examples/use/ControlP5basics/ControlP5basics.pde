/**
 * ControlP5 Basics
 *
 * The following example demonstrates the basic use of controlP5.<br />
 * After initializing controlP5 you can add controllers to controlP5.
 * Here we use three numberboxes, one slider and one textfield.
 * The numberbox with name numberboxC will trigger function numberboxC()
 * in the example below. Whenever controlP5 detects a function in your 
 * sketch that corresponds to the name of a controller, it will forward
 * an event to that function. Any event triggered by a controller 
 * will be forwarded to function controlEvent in your sketch.
 * related examples ControlP5numberbox, ControlP5slider, ControlP5textfield
 * 
 * by Andreas Schlegel, 2011
 * www.sojamo.de/libraries/controlp5
 *
 */


import controlP5.*;

ControlP5 cp5;
public int myColorRect = 200;
public int myColorBackground = 100;

void setup() {
  size(400, 400);
  noStroke();
  
  cp5 = new ControlP5(this);

  // create a slider
  // parameters:
  // name, minValue, maxValue, defaultValue, x, y, width, height
  cp5.addSlider("sliderA", 100, 200, 100, 100, 260, 100, 14);


  // create 3 numberboxes and assign an id for each
  cp5.addNumberbox("numberboxA", myColorRect, 100, 140, 100, 14).setId(1);
  cp5.addNumberbox("numberboxB", myColorBackground, 100, 180, 100, 14).setId(2);
  cp5.addNumberbox("numberboxC", 0, 100, 220, 100, 14).setId(3);


  // create a texfield
  cp5.addTextfield("textA", 100, 290, 100, 20);

  // change individual settings for a controller
  cp5.getController("numberboxA").setMax(255);
  cp5.getController("numberboxA").setMin(0);
}

void draw() {
  background(myColorBackground);
  fill(myColorRect);
  rect(0, 0, width, 100);
}


// events from controller numberboxC are received here
public void numberboxC(int theValue) {
  println("### got an event from numberboxC : "+theValue);
}


// an event from slider sliderA will change the value of textfield textA here
public void sliderA(int theValue) {
  Textfield txt = ((Textfield)cp5.getController("textA"));
  txt.setValue(""+theValue);
}


// for every change (a textfield event confirmed with a return) in textfield textA,
// function textA will be invoked
public void textA(String theValue) {
  println("### got an event from textA : "+theValue);
}


// function controlEvent will be invoked with every value change 
// in any registered controller
public void controlEvent(ControlEvent theEvent) {
  println("got a control event from controller with id "+theEvent.getId());
  switch(theEvent.getId()) {
    case(1): // numberboxA is registered with id 1
    myColorRect = (int)(theEvent.getController().getValue());
    break;
    case(2):  // numberboxB is registered with id 2
    myColorBackground = (int)(theEvent.getController().getValue());
    break;
  }
}

