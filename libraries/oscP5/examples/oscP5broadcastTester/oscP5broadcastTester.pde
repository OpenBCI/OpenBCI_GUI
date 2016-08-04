import controlP5.*;


ControlP5 controlP5;

int myColorBackground = color(0,0,0);

int knobValue = 100;

void setup() {
  size(400,400);
  smooth();
  controlP5 = new ControlP5(this);
  controlP5.addKnob("knob",100,200,128,100,160,40);
  controlP5.addKnob("knobValue",0,255,128,100,240,40);
}

void draw() {
  background(myColorBackground);
  fill(knobValue);
  rect(0,0,width,100);
}

void knob(int theColor) {
  myColorBackground = color(theColor);
  println("a knob event. setting background to "+theColor);
}
