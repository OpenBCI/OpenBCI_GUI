/**
 * controlP5workingWithIDs by andreas schlegel
 * an example to show how to distinguish controllers by IDs.
 * further information in the documentation folder provided in the controlP5 folder.
 * controlP5 website at http://www.sojamo.de/controlP5
 */

import controlP5.*;

ControlP5 cp5;

public int myColorRect = 200;

public int myColorBackground = 40;


void setup() {
  size(400,400);
  
  noStroke();
  
  /* new instance of ControlP5 */
  cp5 = new ControlP5(this);
  /* add 2 controllers and give each of them a unique id. */
  cp5.addNumberbox("numberbox1")
     .setPosition(100,160)
     .setSize(100,14)
     .setId(1)
     .setValue(myColorRect);
     
  cp5.addSlider("slider1")
     .setRange(10,200)
     .setValue(myColorBackground)
     .setPosition(100,220)
     .setSize(100,10)
     .setId(2);
}

void draw() {
  background(myColorBackground);
  fill(myColorRect);
  rect(0,0,width,100);
}


void controlEvent(ControlEvent theEvent) {
  /* events triggered by controllers are automatically forwarded to 
     the controlEvent method. by checking the id of a controller one can distinguish
     which of the controllers has been changed.
  */
  println("got a control event from controller with id "+theEvent.getController().getId());
  switch(theEvent.getController().getId()) {
    case(1):
    /* controller numberbox1 with id 1 */
    myColorRect = (int)theEvent.getValue();
    break;
    case(2):
    /* controller slider1 with id 2 */
    myColorBackground = (int)theEvent.getValue();
    break;  
  }
}
