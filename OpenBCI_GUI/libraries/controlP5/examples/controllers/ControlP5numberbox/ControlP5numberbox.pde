/**
* ControlP5 Numberbox
*
*
* find a list of public methods available for the Numberbox Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;

ControlP5 cp5;

int myColorBackground = color(0,0,0);

public float numberboxValue = 100;

void setup() {
  size(700,400);
  noStroke();
  cp5 = new ControlP5(this);
  
  cp5.addNumberbox("numberbox")
     .setPosition(100,160)
     .setSize(100,20)
     .setScrollSensitivity(1.1)
     .setValue(50)
     ;
  

  cp5.addNumberbox("numberboxValue")
     .setPosition(100,220)
     .setSize(100,20)
     .setRange(0,200)
     .setMultiplier(0.1) // set the sensitifity of the numberbox
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(100)
     ;
  
}

void draw() {
  background(myColorBackground);
  fill(numberboxValue);
  rect(0,0,width,100);
}

void numberbox(int theColor) {
  myColorBackground = color(theColor);
  println("a numberbox event. setting background to "+theColor);
}



/*
a list of all methods available for the Numberbox Controller
use ControlP5.printPublicMethodsFor(Numberbox.class);
to print the following list into the console.

You can find further details about class Numberbox in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Controller : CColor getColor() 
controlP5.Controller : ControlBehavior getBehavior() 
controlP5.Controller : ControlWindow getControlWindow() 
controlP5.Controller : ControlWindow getWindow() 
controlP5.Controller : ControllerProperty getProperty(String) 
controlP5.Controller : ControllerProperty getProperty(String, String) 
controlP5.Controller : ControllerView getView() 
controlP5.Controller : Label getCaptionLabel() 
controlP5.Controller : Label getValueLabel() 
controlP5.Controller : List getControllerPlugList() 
controlP5.Controller : Numberbox addCallback(CallbackListener) 
controlP5.Controller : Numberbox addListener(ControlListener) 
controlP5.Controller : Numberbox addListenerFor(int, CallbackListener) 
controlP5.Controller : Numberbox align(int, int, int, int) 
controlP5.Controller : Numberbox bringToFront() 
controlP5.Controller : Numberbox bringToFront(ControllerInterface) 
controlP5.Controller : Numberbox hide() 
controlP5.Controller : Numberbox linebreak() 
controlP5.Controller : Numberbox listen(boolean) 
controlP5.Controller : Numberbox lock() 
controlP5.Controller : Numberbox onChange(CallbackListener) 
controlP5.Controller : Numberbox onClick(CallbackListener) 
controlP5.Controller : Numberbox onDoublePress(CallbackListener) 
controlP5.Controller : Numberbox onDrag(CallbackListener) 
controlP5.Controller : Numberbox onDraw(ControllerView) 
controlP5.Controller : Numberbox onEndDrag(CallbackListener) 
controlP5.Controller : Numberbox onEnter(CallbackListener) 
controlP5.Controller : Numberbox onLeave(CallbackListener) 
controlP5.Controller : Numberbox onMove(CallbackListener) 
controlP5.Controller : Numberbox onPress(CallbackListener) 
controlP5.Controller : Numberbox onRelease(CallbackListener) 
controlP5.Controller : Numberbox onReleaseOutside(CallbackListener) 
controlP5.Controller : Numberbox onStartDrag(CallbackListener) 
controlP5.Controller : Numberbox onWheel(CallbackListener) 
controlP5.Controller : Numberbox plugTo(Object) 
controlP5.Controller : Numberbox plugTo(Object, String) 
controlP5.Controller : Numberbox plugTo(Object[]) 
controlP5.Controller : Numberbox plugTo(Object[], String) 
controlP5.Controller : Numberbox registerProperty(String) 
controlP5.Controller : Numberbox registerProperty(String, String) 
controlP5.Controller : Numberbox registerTooltip(String) 
controlP5.Controller : Numberbox removeBehavior() 
controlP5.Controller : Numberbox removeCallback() 
controlP5.Controller : Numberbox removeCallback(CallbackListener) 
controlP5.Controller : Numberbox removeListener(ControlListener) 
controlP5.Controller : Numberbox removeListenerFor(int, CallbackListener) 
controlP5.Controller : Numberbox removeListenersFor(int) 
controlP5.Controller : Numberbox removeProperty(String) 
controlP5.Controller : Numberbox removeProperty(String, String) 
controlP5.Controller : Numberbox setArrayValue(float[]) 
controlP5.Controller : Numberbox setArrayValue(int, float) 
controlP5.Controller : Numberbox setBehavior(ControlBehavior) 
controlP5.Controller : Numberbox setBroadcast(boolean) 
controlP5.Controller : Numberbox setCaptionLabel(String) 
controlP5.Controller : Numberbox setColor(CColor) 
controlP5.Controller : Numberbox setColorActive(int) 
controlP5.Controller : Numberbox setColorBackground(int) 
controlP5.Controller : Numberbox setColorCaptionLabel(int) 
controlP5.Controller : Numberbox setColorForeground(int) 
controlP5.Controller : Numberbox setColorLabel(int) 
controlP5.Controller : Numberbox setColorValue(int) 
controlP5.Controller : Numberbox setColorValueLabel(int) 
controlP5.Controller : Numberbox setDecimalPrecision(int) 
controlP5.Controller : Numberbox setDefaultValue(float) 
controlP5.Controller : Numberbox setHeight(int) 
controlP5.Controller : Numberbox setId(int) 
controlP5.Controller : Numberbox setImage(PImage) 
controlP5.Controller : Numberbox setImage(PImage, int) 
controlP5.Controller : Numberbox setImages(PImage, PImage, PImage) 
controlP5.Controller : Numberbox setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Numberbox setLabel(String) 
controlP5.Controller : Numberbox setLabelVisible(boolean) 
controlP5.Controller : Numberbox setLock(boolean) 
controlP5.Controller : Numberbox setMax(float) 
controlP5.Controller : Numberbox setMin(float) 
controlP5.Controller : Numberbox setMouseOver(boolean) 
controlP5.Controller : Numberbox setMoveable(boolean) 
controlP5.Controller : Numberbox setPosition(float, float) 
controlP5.Controller : Numberbox setPosition(float[]) 
controlP5.Controller : Numberbox setSize(PImage) 
controlP5.Controller : Numberbox setSize(int, int) 
controlP5.Controller : Numberbox setStringValue(String) 
controlP5.Controller : Numberbox setUpdate(boolean) 
controlP5.Controller : Numberbox setValue(float) 
controlP5.Controller : Numberbox setValueLabel(String) 
controlP5.Controller : Numberbox setValueSelf(float) 
controlP5.Controller : Numberbox setView(ControllerView) 
controlP5.Controller : Numberbox setVisible(boolean) 
controlP5.Controller : Numberbox setWidth(int) 
controlP5.Controller : Numberbox show() 
controlP5.Controller : Numberbox unlock() 
controlP5.Controller : Numberbox unplugFrom(Object) 
controlP5.Controller : Numberbox unplugFrom(Object[]) 
controlP5.Controller : Numberbox unregisterTooltip() 
controlP5.Controller : Numberbox update() 
controlP5.Controller : Numberbox updateSize() 
controlP5.Controller : Pointer getPointer() 
controlP5.Controller : String getAddress() 
controlP5.Controller : String getInfo() 
controlP5.Controller : String getName() 
controlP5.Controller : String getStringValue() 
controlP5.Controller : String toString() 
controlP5.Controller : Tab getTab() 
controlP5.Controller : boolean isActive() 
controlP5.Controller : boolean isBroadcast() 
controlP5.Controller : boolean isInside() 
controlP5.Controller : boolean isLabelVisible() 
controlP5.Controller : boolean isListening() 
controlP5.Controller : boolean isLock() 
controlP5.Controller : boolean isMouseOver() 
controlP5.Controller : boolean isMousePressed() 
controlP5.Controller : boolean isMoveable() 
controlP5.Controller : boolean isUpdate() 
controlP5.Controller : boolean isVisible() 
controlP5.Controller : float getArrayValue(int) 
controlP5.Controller : float getDefaultValue() 
controlP5.Controller : float getMax() 
controlP5.Controller : float getMin() 
controlP5.Controller : float getValue() 
controlP5.Controller : float[] getAbsolutePosition() 
controlP5.Controller : float[] getArrayValue() 
controlP5.Controller : float[] getPosition() 
controlP5.Controller : int getDecimalPrecision() 
controlP5.Controller : int getHeight() 
controlP5.Controller : int getId() 
controlP5.Controller : int getWidth() 
controlP5.Controller : int listenerSize() 
controlP5.Controller : void remove() 
controlP5.Controller : void setView(ControllerView, int) 
controlP5.Numberbox : Numberbox linebreak() 
controlP5.Numberbox : Numberbox setDirection(int) 
controlP5.Numberbox : Numberbox setMultiplier(float) 
controlP5.Numberbox : Numberbox setRange(float, float) 
controlP5.Numberbox : Numberbox setScrollSensitivity(float) 
controlP5.Numberbox : Numberbox setValue(float) 
controlP5.Numberbox : Numberbox shuffle() 
controlP5.Numberbox : Numberbox update() 
controlP5.Numberbox : float getMultiplier() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:25:44

*/


