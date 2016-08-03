/**
 * ControlP5 with PeasyCam support. tested with peasy 0.8.2
 *
 * by jeffg 2011
 */
 
import peasy.*;
import controlP5.*;
import processing.opengl.*;

PeasyCam cam;
ControlP5 cp5;

int buttonValue = 1;

int myColor = color(255, 0, 0);

void setup() {
  size(400, 400, OPENGL);
  cam = new PeasyCam(this, 100);
  cp5 = new ControlP5(this);
  cp5.addButton("button", 10, 100, 60, 80, 20).setId(1);
  cp5.addButton("buttonValue", 4, 100, 90, 80, 20).setId(2);
  cp5.setAutoDraw(false);
}
void draw() {

  background(0);
  fill(myColor);
  box(30);
  pushMatrix();
  translate(0, 0, 20);
  fill(0, 0, 255);
  box(5);
  popMatrix();
  // makes the gui stay on top of elements
  // drawn before.
 
  gui();
  
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getId());
}

void button(float theValue) {
  myColor = color(random(255), random(255), random(255));
  println("a button event. "+theValue);
}
