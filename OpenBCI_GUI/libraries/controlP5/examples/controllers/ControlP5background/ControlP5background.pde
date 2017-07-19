/**
* ControlP5 Background
*
*
* find a list of public methods available for the Group Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2014
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;

ControlP5 cp5;
int v1;
boolean lines = true;

void setup() {
  size(800, 400);  
  noStroke();
  cp5 = new ControlP5(this);
  
  cp5.begin(cp5.addBackground("abc"));
  
  cp5.addSlider("v1")
     .setPosition(10, 20)
     .setSize(200, 20)
     .setRange(100, 300)
     .setValue(250)
     ;
  
  cp5.addToggle("lines")
     .setPosition(10,50)
     .setSize(80,20)
     .setMode(Toggle.SWITCH)
     ;
     
  cp5.end();

}

void draw() {
  background(200, 200, 200);

  pushMatrix();

  pushMatrix();
  fill(255, 255, 0);
  rect(v1, 100, 60, 200);
  fill(0, 255, 110);
  rect(40, v1, 320, 40);
  translate(200, 200);
  rotate(map(v1, 100, 300, -PI, PI));
  fill(255, 0, 128);
  rect(0, 0, 100, 100);
  popMatrix();

  if(lines) {
  translate(600, 100);
  for (int i=0; i<20; i++) {
    pushMatrix();
    fill(255);
    translate(0, i*10);
    rotate(map(v1+i, 0, 300, -PI, PI));
    rect(-150, 0, 300, 4);
    popMatrix();
  }
  }

  popMatrix();
}

/*
a list of all methods available for the Background Controller
use ControlP5.printPublicMethodsFor(Background.class);
to print the following list into the console.

You can find further details about class Background in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.ControlGroup : Background activateEvent(boolean) 
controlP5.ControlGroup : Background addListener(ControlListener) 
controlP5.ControlGroup : Background removeListener(ControlListener) 
controlP5.ControlGroup : Background setBackgroundColor(int) 
controlP5.ControlGroup : Background setBackgroundHeight(int) 
controlP5.ControlGroup : Background setBarHeight(int) 
controlP5.ControlGroup : Background setSize(int, int) 
controlP5.ControlGroup : Background updateInternalEvents(PApplet) 
controlP5.ControlGroup : String getInfo() 
controlP5.ControlGroup : String toString() 
controlP5.ControlGroup : int getBackgroundHeight() 
controlP5.ControlGroup : int getBarHeight() 
controlP5.ControlGroup : int listenerSize() 
controlP5.ControllerGroup : Background add(ControllerInterface) 
controlP5.ControllerGroup : Background addListener(ControlListener) 
controlP5.ControllerGroup : Background bringToFront() 
controlP5.ControllerGroup : Background bringToFront(ControllerInterface) 
controlP5.ControllerGroup : Background close() 
controlP5.ControllerGroup : Background disableCollapse() 
controlP5.ControllerGroup : Background enableCollapse() 
controlP5.ControllerGroup : Background hide() 
controlP5.ControllerGroup : Background hideArrow() 
controlP5.ControllerGroup : Background hideBar() 
controlP5.ControllerGroup : Background moveTo(ControlWindow) 
controlP5.ControllerGroup : Background moveTo(PApplet) 
controlP5.ControllerGroup : Background open() 
controlP5.ControllerGroup : Background registerProperty(String) 
controlP5.ControllerGroup : Background registerProperty(String, String) 
controlP5.ControllerGroup : Background remove(CDrawable) 
controlP5.ControllerGroup : Background remove(ControllerInterface) 
controlP5.ControllerGroup : Background removeCanvas(Canvas) 
controlP5.ControllerGroup : Background removeListener(ControlListener) 
controlP5.ControllerGroup : Background removeProperty(String) 
controlP5.ControllerGroup : Background removeProperty(String, String) 
controlP5.ControllerGroup : Background setAddress(String) 
controlP5.ControllerGroup : Background setArrayValue(float[]) 
controlP5.ControllerGroup : Background setArrayValue(int, float) 
controlP5.ControllerGroup : Background setCaptionLabel(String) 
controlP5.ControllerGroup : Background setColor(CColor) 
controlP5.ControllerGroup : Background setColorActive(int) 
controlP5.ControllerGroup : Background setColorBackground(int) 
controlP5.ControllerGroup : Background setColorForeground(int) 
controlP5.ControllerGroup : Background setColorLabel(int) 
controlP5.ControllerGroup : Background setColorValue(int) 
controlP5.ControllerGroup : Background setHeight(int) 
controlP5.ControllerGroup : Background setId(int) 
controlP5.ControllerGroup : Background setLabel(String) 
controlP5.ControllerGroup : Background setMouseOver(boolean) 
controlP5.ControllerGroup : Background setMoveable(boolean) 
controlP5.ControllerGroup : Background setOpen(boolean) 
controlP5.ControllerGroup : Background setPosition(float, float) 
controlP5.ControllerGroup : Background setPosition(float[]) 
controlP5.ControllerGroup : Background setSize(int, int) 
controlP5.ControllerGroup : Background setStringValue(String) 
controlP5.ControllerGroup : Background setTitle(String) 
controlP5.ControllerGroup : Background setUpdate(boolean) 
controlP5.ControllerGroup : Background setValue(float) 
controlP5.ControllerGroup : Background setVisible(boolean) 
controlP5.ControllerGroup : Background setWidth(int) 
controlP5.ControllerGroup : Background show() 
controlP5.ControllerGroup : Background showArrow() 
controlP5.ControllerGroup : Background showBar() 
controlP5.ControllerGroup : Background update() 
controlP5.ControllerGroup : Background updateAbsolutePosition() 
controlP5.ControllerGroup : CColor getColor() 
controlP5.ControllerGroup : Canvas addCanvas(Canvas) 
controlP5.ControllerGroup : ControlWindow getWindow() 
controlP5.ControllerGroup : Controller getController(String) 
controlP5.ControllerGroup : ControllerProperty getProperty(String) 
controlP5.ControllerGroup : ControllerProperty getProperty(String, String) 
controlP5.ControllerGroup : Label getCaptionLabel() 
controlP5.ControllerGroup : Label getValueLabel() 
controlP5.ControllerGroup : String getAddress() 
controlP5.ControllerGroup : String getInfo() 
controlP5.ControllerGroup : String getName() 
controlP5.ControllerGroup : String getStringValue() 
controlP5.ControllerGroup : String toString() 
controlP5.ControllerGroup : Tab getTab() 
controlP5.ControllerGroup : boolean isBarVisible() 
controlP5.ControllerGroup : boolean isCollapse() 
controlP5.ControllerGroup : boolean isMouseOver() 
controlP5.ControllerGroup : boolean isMoveable() 
controlP5.ControllerGroup : boolean isOpen() 
controlP5.ControllerGroup : boolean isUpdate() 
controlP5.ControllerGroup : boolean isVisible() 
controlP5.ControllerGroup : boolean setMousePressed(boolean) 
controlP5.ControllerGroup : float getArrayValue(int) 
controlP5.ControllerGroup : float getValue() 
controlP5.ControllerGroup : float[] getArrayValue() 
controlP5.ControllerGroup : float[] getPosition() 
controlP5.ControllerGroup : int getHeight() 
controlP5.ControllerGroup : int getId() 
controlP5.ControllerGroup : int getWidth() 
controlP5.ControllerGroup : int listenerSize() 
controlP5.ControllerGroup : void controlEvent(ControlEvent) 
controlP5.ControllerGroup : void remove() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:25:35

*/


