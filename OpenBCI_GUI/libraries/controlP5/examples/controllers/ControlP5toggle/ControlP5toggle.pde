
/**
* ControlP5 Toggle
*
*
* find a list of public methods available for the Toggle Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2011
* www.sojamo.de/libraries/controlp5
*
*/


import controlP5.*;

ControlP5 cp5;

int col = color(255);

boolean toggleValue = false;

void setup() {
  size(400,400);
  smooth();
  cp5 = new ControlP5(this);
  
  // create a toggle
  cp5.addToggle("toggleValue")
     .setPosition(40,100)
     .setSize(50,20)
     ;
  
  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("toggle")
     .setPosition(40,250)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     ;
     
}
  

void draw() {
  background(0);
  
  pushMatrix();
  
  if(toggleValue==true) {
    fill(255,255,220);
  } else {
    fill(128,128,110);
  }
  translate(280,100);
  ellipse(0,0,100,100);
  
  
  translate(0,150);
  fill(col);
  ellipse(0,0,40,40);
  
  popMatrix();
}



void toggle(boolean theFlag) {
  if(theFlag==true) {
    col = color(255);
  } else {
    col = color(100);
  }
  println("a toggle event.");
}






/*
a list of all methods available for the Toggle Controller
use ControlP5.printPublicMethodsFor(Toggle.class);
to print the following list into the console.

You can find further details about class Toggle in the javadoc.

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
controlP5.Controller : Pointer getPointer() 
controlP5.Controller : String getAddress() 
controlP5.Controller : String getInfo() 
controlP5.Controller : String getName() 
controlP5.Controller : String getStringValue() 
controlP5.Controller : String toString() 
controlP5.Controller : Tab getTab() 
controlP5.Controller : Toggle addCallback(CallbackListener) 
controlP5.Controller : Toggle addListener(ControlListener) 
controlP5.Controller : Toggle addListenerFor(int, CallbackListener) 
controlP5.Controller : Toggle align(int, int, int, int) 
controlP5.Controller : Toggle bringToFront() 
controlP5.Controller : Toggle bringToFront(ControllerInterface) 
controlP5.Controller : Toggle hide() 
controlP5.Controller : Toggle linebreak() 
controlP5.Controller : Toggle listen(boolean) 
controlP5.Controller : Toggle lock() 
controlP5.Controller : Toggle onChange(CallbackListener) 
controlP5.Controller : Toggle onClick(CallbackListener) 
controlP5.Controller : Toggle onDoublePress(CallbackListener) 
controlP5.Controller : Toggle onDrag(CallbackListener) 
controlP5.Controller : Toggle onDraw(ControllerView) 
controlP5.Controller : Toggle onEndDrag(CallbackListener) 
controlP5.Controller : Toggle onEnter(CallbackListener) 
controlP5.Controller : Toggle onLeave(CallbackListener) 
controlP5.Controller : Toggle onMove(CallbackListener) 
controlP5.Controller : Toggle onPress(CallbackListener) 
controlP5.Controller : Toggle onRelease(CallbackListener) 
controlP5.Controller : Toggle onReleaseOutside(CallbackListener) 
controlP5.Controller : Toggle onStartDrag(CallbackListener) 
controlP5.Controller : Toggle onWheel(CallbackListener) 
controlP5.Controller : Toggle plugTo(Object) 
controlP5.Controller : Toggle plugTo(Object, String) 
controlP5.Controller : Toggle plugTo(Object[]) 
controlP5.Controller : Toggle plugTo(Object[], String) 
controlP5.Controller : Toggle registerProperty(String) 
controlP5.Controller : Toggle registerProperty(String, String) 
controlP5.Controller : Toggle registerTooltip(String) 
controlP5.Controller : Toggle removeBehavior() 
controlP5.Controller : Toggle removeCallback() 
controlP5.Controller : Toggle removeCallback(CallbackListener) 
controlP5.Controller : Toggle removeListener(ControlListener) 
controlP5.Controller : Toggle removeListenerFor(int, CallbackListener) 
controlP5.Controller : Toggle removeListenersFor(int) 
controlP5.Controller : Toggle removeProperty(String) 
controlP5.Controller : Toggle removeProperty(String, String) 
controlP5.Controller : Toggle setArrayValue(float[]) 
controlP5.Controller : Toggle setArrayValue(int, float) 
controlP5.Controller : Toggle setBehavior(ControlBehavior) 
controlP5.Controller : Toggle setBroadcast(boolean) 
controlP5.Controller : Toggle setCaptionLabel(String) 
controlP5.Controller : Toggle setColor(CColor) 
controlP5.Controller : Toggle setColorActive(int) 
controlP5.Controller : Toggle setColorBackground(int) 
controlP5.Controller : Toggle setColorCaptionLabel(int) 
controlP5.Controller : Toggle setColorForeground(int) 
controlP5.Controller : Toggle setColorLabel(int) 
controlP5.Controller : Toggle setColorValue(int) 
controlP5.Controller : Toggle setColorValueLabel(int) 
controlP5.Controller : Toggle setDecimalPrecision(int) 
controlP5.Controller : Toggle setDefaultValue(float) 
controlP5.Controller : Toggle setHeight(int) 
controlP5.Controller : Toggle setId(int) 
controlP5.Controller : Toggle setImage(PImage) 
controlP5.Controller : Toggle setImage(PImage, int) 
controlP5.Controller : Toggle setImages(PImage, PImage, PImage) 
controlP5.Controller : Toggle setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Toggle setLabel(String) 
controlP5.Controller : Toggle setLabelVisible(boolean) 
controlP5.Controller : Toggle setLock(boolean) 
controlP5.Controller : Toggle setMax(float) 
controlP5.Controller : Toggle setMin(float) 
controlP5.Controller : Toggle setMouseOver(boolean) 
controlP5.Controller : Toggle setMoveable(boolean) 
controlP5.Controller : Toggle setPosition(float, float) 
controlP5.Controller : Toggle setPosition(float[]) 
controlP5.Controller : Toggle setSize(PImage) 
controlP5.Controller : Toggle setSize(int, int) 
controlP5.Controller : Toggle setStringValue(String) 
controlP5.Controller : Toggle setUpdate(boolean) 
controlP5.Controller : Toggle setValue(float) 
controlP5.Controller : Toggle setValueLabel(String) 
controlP5.Controller : Toggle setValueSelf(float) 
controlP5.Controller : Toggle setView(ControllerView) 
controlP5.Controller : Toggle setVisible(boolean) 
controlP5.Controller : Toggle setWidth(int) 
controlP5.Controller : Toggle show() 
controlP5.Controller : Toggle unlock() 
controlP5.Controller : Toggle unplugFrom(Object) 
controlP5.Controller : Toggle unplugFrom(Object[]) 
controlP5.Controller : Toggle unregisterTooltip() 
controlP5.Controller : Toggle update() 
controlP5.Controller : Toggle updateSize() 
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
controlP5.Toggle : Toggle linebreak() 
controlP5.Toggle : Toggle setMode(int) 
controlP5.Toggle : Toggle setState(boolean) 
controlP5.Toggle : Toggle setValue(boolean) 
controlP5.Toggle : Toggle setValue(float) 
controlP5.Toggle : Toggle toggle() 
controlP5.Toggle : Toggle update() 
controlP5.Toggle : boolean getBooleanValue() 
controlP5.Toggle : boolean getState() 
controlP5.Toggle : int getMode() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:35

*/


