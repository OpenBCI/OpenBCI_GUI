/**
 * ControlP5 Slider set value
 * changes the value of a slider on keyPressed
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlP5
 *
 */
 
import controlP5.*;


ControlP5 cp5;

int myColorBackground = color(0,0,0);

int sliderValue = 100;

void setup() {
  size(400,400);
  noStroke();
  cp5 = new ControlP5(this);

  cp5.addSlider("sliderValue")
     .setRange(100,200)
     .setValue(120)
     .setPosition(100,200)
     .setSize(100,10)
     ;

  
  cp5.addSlider("slider")
     .setRange(100,200)
     .setValue(128)
     .setPosition(100,160)
     .setSize(100,10);
     
}

void draw() {
  background(myColorBackground);
  fill(sliderValue);
  rect(0,0,width,100);
}

void slider(int theColor) {
  myColorBackground = color(theColor);
  println("a slider event. setting background to "+theColor);
  cp5.getController("sliderValue").setValue(theColor);
}

void keyPressed() {
  cp5.getController("sliderValue").setValue(150);
}
