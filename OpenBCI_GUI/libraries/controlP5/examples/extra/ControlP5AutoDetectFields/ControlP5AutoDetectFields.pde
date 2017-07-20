/**
 * ControlP5 Autodetect Fields
 *
 * test sketch, controller values will automatically be set 
 * to its corresponding sketch fields.
 *
 * by Andreas Schlegel, 2011
 * www.sojamo.de/libraries/controlp5
 *
 */


import controlP5.*;

int s1 = 50;
int s2 = 50;

int nb1 = 50;
int nb2 = 50;

int k1 = 50;
int k2 = 50;

boolean t1 = false;
boolean t2 = false;

int r1 = 20;
int r2 = 50;

void setup() {
  size(400,400);
  ControlP5 cp5 = new ControlP5(this);
  cp5.addSlider("s1",10,150,10,10,100,15).setLabel("50");
  cp5.addSlider("s2",10,150,20,150,10,100,15).setLabel("20");
  
  cp5.addNumberbox("nb1",10,50,100,15).setLabel("50");
  cp5.addNumberbox("nb2",20,150,50,100,15).setLabel("20");
  
  cp5.addKnob("k1",10,150,10,150,50).setLabel("50");
  cp5.addKnob("k2",10,150,20,150,150,50).setLabel("20");
  
  cp5.addToggle("t1",10,240,100,15).setLabel("false");
  cp5.addToggle("t2",true,150,240,100,15).setLabel("true");
  
  cp5.addButton("b1",50,10,280,100,15).setLabel("50");
  cp5.addButton("b2",20,150,280,100,15).setLabel("20");
  
  cp5.addRange("r1",10,150,r1,r2,10,320,100,15).setLabel("50");
  
}

void draw() {
  background(0);
}

void controlEvent(ControlEvent c) {
  println(c.getValue());
}
