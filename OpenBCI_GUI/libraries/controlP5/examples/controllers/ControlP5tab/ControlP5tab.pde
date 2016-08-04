/**
* ControlP5 Tab
*
*
* find a list of public methods available for the Tab Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;

ControlP5 cp5;

int myColorBackground = color(128);

int sliderValue = 100;

void setup() {
  size(700,400);
  noStroke();
  cp5 = new ControlP5(this);
  
  // By default all controllers are stored inside Tab 'default' 
  // add a second tab with name 'extra'
  
  cp5.addTab("extra")
     .setColorBackground(color(0, 160, 100))
     .setColorLabel(color(255))
     .setColorActive(color(255,128,0))
     ;
     
  // if you want to receive a controlEvent when
  // a  tab is clicked, use activeEvent(true)
  
  cp5.getTab("default")
     .activateEvent(true)
     .setLabel("my default tab")
     .setId(1)
     ;

  cp5.getTab("extra")
     .activateEvent(true)
     .setId(2)
     ;

  
  // create a few controllers
  
  cp5.addButton("button")
     .setBroadcast(false)
     .setPosition(100,100)
     .setSize(80,40)
     .setValue(1)
     .setBroadcast(true)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
     
  cp5.addButton("buttonValue")
     .setBroadcast(false)
     .setPosition(220,100)
     .setSize(80,40)
     .setValue(2)
     .setBroadcast(true)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
  
  cp5.addSlider("slider")
     .setBroadcast(false)
     .setRange(100,200)
     .setValue(128)
     .setPosition(100,160)
     .setSize(200,20)
     .setBroadcast(true)
     ;
     
  cp5.addSlider("sliderValue")
     .setBroadcast(false)
     .setRange(0,255)
     .setValue(128)
     .setPosition(100,200)
     .setSize(200,20)
     .setBroadcast(true)
     ;
     
  // arrange controller in separate tabs
  
  cp5.getController("sliderValue").moveTo("extra");
  cp5.getController("slider").moveTo("global");
  
  // Tab 'global' is a tab that lies on top of any 
  // other tab and is always visible
  
}

void draw() {
  background(myColorBackground);
  fill(sliderValue);
  rect(0,0,width,100);
}

void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isTab()) {
    println("got an event from tab : "+theControlEvent.getTab().getName()+" with id "+theControlEvent.getTab().getId());
  }
}

void slider(int theColor) {
  myColorBackground = color(theColor);
  println("a slider event. setting background to "+theColor);
}


void keyPressed() {
  if(keyCode==TAB) {
    cp5.getTab("extra").bringToFront();
  }
}

/*
a list of all methods available for the Tab Controller
use ControlP5.printPublicMethodsFor(Tab.class);
to print the following list into the console.

You can find further details about class Tab in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


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
controlP5.ControllerGroup : Tab add(ControllerInterface) 
controlP5.ControllerGroup : Tab addListener(ControlListener) 
controlP5.ControllerGroup : Tab bringToFront() 
controlP5.ControllerGroup : Tab bringToFront(ControllerInterface) 
controlP5.ControllerGroup : Tab close() 
controlP5.ControllerGroup : Tab disableCollapse() 
controlP5.ControllerGroup : Tab enableCollapse() 
controlP5.ControllerGroup : Tab getTab() 
controlP5.ControllerGroup : Tab hide() 
controlP5.ControllerGroup : Tab hideArrow() 
controlP5.ControllerGroup : Tab hideBar() 
controlP5.ControllerGroup : Tab moveTo(ControlWindow) 
controlP5.ControllerGroup : Tab moveTo(PApplet) 
controlP5.ControllerGroup : Tab open() 
controlP5.ControllerGroup : Tab registerProperty(String) 
controlP5.ControllerGroup : Tab registerProperty(String, String) 
controlP5.ControllerGroup : Tab remove(CDrawable) 
controlP5.ControllerGroup : Tab remove(ControllerInterface) 
controlP5.ControllerGroup : Tab removeCanvas(Canvas) 
controlP5.ControllerGroup : Tab removeListener(ControlListener) 
controlP5.ControllerGroup : Tab removeProperty(String) 
controlP5.ControllerGroup : Tab removeProperty(String, String) 
controlP5.ControllerGroup : Tab setAddress(String) 
controlP5.ControllerGroup : Tab setArrayValue(float[]) 
controlP5.ControllerGroup : Tab setArrayValue(int, float) 
controlP5.ControllerGroup : Tab setCaptionLabel(String) 
controlP5.ControllerGroup : Tab setColor(CColor) 
controlP5.ControllerGroup : Tab setColorActive(int) 
controlP5.ControllerGroup : Tab setColorBackground(int) 
controlP5.ControllerGroup : Tab setColorForeground(int) 
controlP5.ControllerGroup : Tab setColorLabel(int) 
controlP5.ControllerGroup : Tab setColorValue(int) 
controlP5.ControllerGroup : Tab setHeight(int) 
controlP5.ControllerGroup : Tab setId(int) 
controlP5.ControllerGroup : Tab setLabel(String) 
controlP5.ControllerGroup : Tab setMouseOver(boolean) 
controlP5.ControllerGroup : Tab setMoveable(boolean) 
controlP5.ControllerGroup : Tab setOpen(boolean) 
controlP5.ControllerGroup : Tab setPosition(float, float) 
controlP5.ControllerGroup : Tab setPosition(float[]) 
controlP5.ControllerGroup : Tab setSize(int, int) 
controlP5.ControllerGroup : Tab setStringValue(String) 
controlP5.ControllerGroup : Tab setTitle(String) 
controlP5.ControllerGroup : Tab setUpdate(boolean) 
controlP5.ControllerGroup : Tab setValue(float) 
controlP5.ControllerGroup : Tab setVisible(boolean) 
controlP5.ControllerGroup : Tab setWidth(int) 
controlP5.ControllerGroup : Tab show() 
controlP5.ControllerGroup : Tab showArrow() 
controlP5.ControllerGroup : Tab showBar() 
controlP5.ControllerGroup : Tab update() 
controlP5.ControllerGroup : Tab updateAbsolutePosition() 
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
controlP5.Tab : String getStringValue() 
controlP5.Tab : Tab activateEvent(boolean) 
controlP5.Tab : Tab bringToFront() 
controlP5.Tab : Tab moveTo(ControlWindow) 
controlP5.Tab : Tab setActive(boolean) 
controlP5.Tab : Tab setAlwaysActive(boolean) 
controlP5.Tab : Tab setHeight(int) 
controlP5.Tab : Tab setLabel(String) 
controlP5.Tab : Tab setValue(float) 
controlP5.Tab : Tab setWidth(int) 
controlP5.Tab : boolean isActive() 
controlP5.Tab : boolean isAlwaysActive() 
controlP5.Tab : float getValue() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:25:49

*/


