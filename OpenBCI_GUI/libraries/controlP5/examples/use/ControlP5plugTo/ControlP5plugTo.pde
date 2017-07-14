/**
* ControlP5 plugTo
*
* This example demonstrate how to use the plugTo method to
* connect a controller to a field or method of a particular object.
* 
*
* find a list of public methods available for the ControlP5 Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2011
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;
import processing.opengl.*;

ControlP5 controlP5;

Test[] testarray;

Test test;

Button b;

int cnt;

void setup() {
  size(600,400);
  smooth();
  test = new Test(50);
  testarray = new Test[10];
  for(int i=0;i<10;i++) {
    testarray[i] = new Test(200 + i*20);
  }
  
  controlP5 = new ControlP5(this);
  
  controlP5.begin(100,20);
  
  b = controlP5.addButton("trigger",1);
  b.setColorBackground(ControlP5.RED);
  
  controlP5.addButton("plug",2);
  controlP5.addButton("unplug",3);
  
  // b is a button previously added to controlP5 with name 'trigger'
  // controlP5 no tries to find a field or method inside object test
  // in order to connect controller 'trigger' with test.trigger()
  b.plugTo(test);
  controlP5.end();
}

// connects controller 'trigger' with objects of type Test contained 
// inside arrat testarray
void plug(int theValue) {
   b.plugTo(testarray);
   b.setColorBackground(ControlP5.GREEN);
   println("plugging controller b1 to array 'testarray' and variable 'test'.");
}

// disconnects controller 'trigger' from objects of type Test stored 
// inside array testarray
void unplug(int theValue) {
  b.unplugFrom(testarray);
  b.setColorBackground(ControlP5.RED);
  println("removing array 'testarray' and variable 'test' from controller b1.");
}


void draw() {
  background(0);
  fill(255);
  for(int i=0;i<10;i++) {
    testarray[i].display();
  }
  test.display();
  cnt++;
  if(cnt%30 == 0) {
    controlP5.getController("trigger").update();
  }
}


class Test {
  float n0 = 0; 
  float n1 = 1; 
  float x;
  
  Test(float theX) {
    x = theX;
  } 
  
  void trigger(int theValue) {
    n1 = random(100);
  }
  
  void display() {
    n0 += (n1-n0) * 0.1;
    rect(x,200,10,n0);
  }

  void controlEvent(ControlEvent theEvent) {
    //println("\t\t b1 event sub \n\n");
  }
}


