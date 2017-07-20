/**
* ControlP5 Icon
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

void setup() {
  size(800,400);
  cp5 = new ControlP5(this);
  cp5.addIcon("icon",10)
     .setPosition(100,100)
     .setSize(70,50)
     .setRoundedCorners(20)
     .setFont(createFont("fontawesome-webfont.ttf", 40))
     .setFontIcons(#00f205,#00f204)
     //.setScale(0.9,1)
     .setSwitch(true)
     .setColorBackground(color(255,100))
     .hideBackground()
     ;  
}

void draw() {
  background(220);
}

void icon(boolean theValue) {
  println("got an event for icon", theValue);
} 

/*
a list of all methods available for the Icon Controller
use ControlP5.printPublicMethodsFor(Icon.class);
to print the following list into the console.

You can find further details about class Icon in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Controller : CColor getColor() 
controlP5.Controller : ControlBehavior getBehavior() 
controlP5.Controller : ControlWindow getControlWindow() 
controlP5.Controller : ControlWindow getWindow() 
controlP5.Controller : ControllerProperty getProperty(String) 
controlP5.Controller : ControllerProperty getProperty(String, String) 
controlP5.Controller : ControllerView getView() 
controlP5.Controller : Icon addCallback(CallbackListener) 
controlP5.Controller : Icon addListener(ControlListener) 
controlP5.Controller : Icon addListenerFor(int, CallbackListener) 
controlP5.Controller : Icon align(int, int, int, int) 
controlP5.Controller : Icon bringToFront() 
controlP5.Controller : Icon bringToFront(ControllerInterface) 
controlP5.Controller : Icon hide() 
controlP5.Controller : Icon linebreak() 
controlP5.Controller : Icon listen(boolean) 
controlP5.Controller : Icon lock() 
controlP5.Controller : Icon onChange(CallbackListener) 
controlP5.Controller : Icon onClick(CallbackListener) 
controlP5.Controller : Icon onDoublePress(CallbackListener) 
controlP5.Controller : Icon onDrag(CallbackListener) 
controlP5.Controller : Icon onDraw(ControllerView) 
controlP5.Controller : Icon onEndDrag(CallbackListener) 
controlP5.Controller : Icon onEnter(CallbackListener) 
controlP5.Controller : Icon onLeave(CallbackListener) 
controlP5.Controller : Icon onMove(CallbackListener) 
controlP5.Controller : Icon onPress(CallbackListener) 
controlP5.Controller : Icon onRelease(CallbackListener) 
controlP5.Controller : Icon onReleaseOutside(CallbackListener) 
controlP5.Controller : Icon onStartDrag(CallbackListener) 
controlP5.Controller : Icon onWheel(CallbackListener) 
controlP5.Controller : Icon plugTo(Object) 
controlP5.Controller : Icon plugTo(Object, String) 
controlP5.Controller : Icon plugTo(Object[]) 
controlP5.Controller : Icon plugTo(Object[], String) 
controlP5.Controller : Icon registerProperty(String) 
controlP5.Controller : Icon registerProperty(String, String) 
controlP5.Controller : Icon registerTooltip(String) 
controlP5.Controller : Icon removeBehavior() 
controlP5.Controller : Icon removeCallback() 
controlP5.Controller : Icon removeCallback(CallbackListener) 
controlP5.Controller : Icon removeListener(ControlListener) 
controlP5.Controller : Icon removeListenerFor(int, CallbackListener) 
controlP5.Controller : Icon removeListenersFor(int) 
controlP5.Controller : Icon removeProperty(String) 
controlP5.Controller : Icon removeProperty(String, String) 
controlP5.Controller : Icon setArrayValue(float[]) 
controlP5.Controller : Icon setArrayValue(int, float) 
controlP5.Controller : Icon setBehavior(ControlBehavior) 
controlP5.Controller : Icon setBroadcast(boolean) 
controlP5.Controller : Icon setCaptionLabel(String) 
controlP5.Controller : Icon setColor(CColor) 
controlP5.Controller : Icon setColorActive(int) 
controlP5.Controller : Icon setColorBackground(int) 
controlP5.Controller : Icon setColorCaptionLabel(int) 
controlP5.Controller : Icon setColorForeground(int) 
controlP5.Controller : Icon setColorLabel(int) 
controlP5.Controller : Icon setColorValue(int) 
controlP5.Controller : Icon setColorValueLabel(int) 
controlP5.Controller : Icon setDecimalPrecision(int) 
controlP5.Controller : Icon setDefaultValue(float) 
controlP5.Controller : Icon setHeight(int) 
controlP5.Controller : Icon setId(int) 
controlP5.Controller : Icon setImage(PImage) 
controlP5.Controller : Icon setImage(PImage, int) 
controlP5.Controller : Icon setImages(PImage, PImage, PImage) 
controlP5.Controller : Icon setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Icon setLabel(String) 
controlP5.Controller : Icon setLabelVisible(boolean) 
controlP5.Controller : Icon setLock(boolean) 
controlP5.Controller : Icon setMax(float) 
controlP5.Controller : Icon setMin(float) 
controlP5.Controller : Icon setMouseOver(boolean) 
controlP5.Controller : Icon setMoveable(boolean) 
controlP5.Controller : Icon setPosition(float, float) 
controlP5.Controller : Icon setPosition(float[]) 
controlP5.Controller : Icon setSize(PImage) 
controlP5.Controller : Icon setSize(int, int) 
controlP5.Controller : Icon setStringValue(String) 
controlP5.Controller : Icon setUpdate(boolean) 
controlP5.Controller : Icon setValue(float) 
controlP5.Controller : Icon setValueLabel(String) 
controlP5.Controller : Icon setValueSelf(float) 
controlP5.Controller : Icon setView(ControllerView) 
controlP5.Controller : Icon setVisible(boolean) 
controlP5.Controller : Icon setWidth(int) 
controlP5.Controller : Icon show() 
controlP5.Controller : Icon unlock() 
controlP5.Controller : Icon unplugFrom(Object) 
controlP5.Controller : Icon unplugFrom(Object[]) 
controlP5.Controller : Icon unregisterTooltip() 
controlP5.Controller : Icon update() 
controlP5.Controller : Icon updateSize() 
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
controlP5.Icon : Icon activateBy(int) 
controlP5.Icon : Icon hideBackground() 
controlP5.Icon : Icon setFill(boolean) 
controlP5.Icon : Icon setFont(PFont) 
controlP5.Icon : Icon setFont(PFont, int) 
controlP5.Icon : Icon setFontIcon(int) 
controlP5.Icon : Icon setFontIcon(int, int) 
controlP5.Icon : Icon setFontIconOff(int) 
controlP5.Icon : Icon setFontIconOn(int) 
controlP5.Icon : Icon setFontIconSize(int) 
controlP5.Icon : Icon setFontIcons(int, int) 
controlP5.Icon : Icon setFontIndex(int) 
controlP5.Icon : Icon setOff() 
controlP5.Icon : Icon setOn() 
controlP5.Icon : Icon setRoundedCorners(int) 
controlP5.Icon : Icon setScale(float, float) 
controlP5.Icon : Icon setStroke(boolean) 
controlP5.Icon : Icon setStrokeWeight(float) 
controlP5.Icon : Icon setSwitch(boolean) 
controlP5.Icon : Icon setValue(float) 
controlP5.Icon : Icon showBackground() 
controlP5.Icon : Icon update() 
controlP5.Icon : String getInfo() 
controlP5.Icon : String toString() 
controlP5.Icon : boolean getBooleanValue() 
controlP5.Icon : boolean isOn() 
controlP5.Icon : boolean isPressed() 
controlP5.Icon : boolean isSwitch() 
controlP5.Icon : int getFontIcon(int) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:09

*/


