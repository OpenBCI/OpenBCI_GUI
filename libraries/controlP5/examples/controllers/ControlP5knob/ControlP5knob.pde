/**
* ControlP5 Knob
*
*
* find a list of public methods available for the Knob Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;


ControlP5 cp5;

int myColorBackground = color(0,0,0);
int knobValue = 100;

Knob myKnobA;
Knob myKnobB;

void setup() {
  size(700,400);
  smooth();
  noStroke();
  
  cp5 = new ControlP5(this);
  
  myKnobA = cp5.addKnob("knob")
               .setRange(0,255)
               .setValue(50)
               .setPosition(100,70)
               .setRadius(50)
               .setDragDirection(Knob.VERTICAL)
               ;
                     
  myKnobB = cp5.addKnob("knobValue")
               .setRange(0,255)
               .setValue(220)
               .setPosition(100,210)
               .setRadius(50)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(4)
               .snapToTickMarks(true)
               .setColorForeground(color(255))
               .setColorBackground(color(0, 160, 100))
               .setColorActive(color(255,255,0))
               .setDragDirection(Knob.HORIZONTAL)
               ;
}

void draw() {
  background(myColorBackground);
  fill(knobValue);
  rect(0,height/2,width,height/2);
  fill(0,100);
  rect(80,40,140,320);
}


void knob(int theValue) {
  myColorBackground = color(theValue);
  println("a knob event. setting background to "+theValue);
}


void keyPressed() {
  switch(key) {
    case('1'):myKnobA.setValue(180);break;
    case('2'):myKnobB.setConstrained(false).hideTickMarks().snapToTickMarks(false);break;
    case('3'):myKnobA.shuffle();myKnobB.shuffle();break;
  }
  
}

/*
a list of all methods available for the Knob Controller
use ControlP5.printPublicMethodsFor(Knob.class);
to print the following list into the console.

You can find further details about class Knob in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Controller : CColor getColor() 
controlP5.Controller : ControlBehavior getBehavior() 
controlP5.Controller : ControlWindow getControlWindow() 
controlP5.Controller : ControlWindow getWindow() 
controlP5.Controller : ControllerProperty getProperty(String) 
controlP5.Controller : ControllerProperty getProperty(String, String) 
controlP5.Controller : ControllerView getView() 
controlP5.Controller : Knob addCallback(CallbackListener) 
controlP5.Controller : Knob addListener(ControlListener) 
controlP5.Controller : Knob addListenerFor(int, CallbackListener) 
controlP5.Controller : Knob align(int, int, int, int) 
controlP5.Controller : Knob bringToFront() 
controlP5.Controller : Knob bringToFront(ControllerInterface) 
controlP5.Controller : Knob hide() 
controlP5.Controller : Knob linebreak() 
controlP5.Controller : Knob listen(boolean) 
controlP5.Controller : Knob lock() 
controlP5.Controller : Knob onChange(CallbackListener) 
controlP5.Controller : Knob onClick(CallbackListener) 
controlP5.Controller : Knob onDoublePress(CallbackListener) 
controlP5.Controller : Knob onDrag(CallbackListener) 
controlP5.Controller : Knob onDraw(ControllerView) 
controlP5.Controller : Knob onEndDrag(CallbackListener) 
controlP5.Controller : Knob onEnter(CallbackListener) 
controlP5.Controller : Knob onLeave(CallbackListener) 
controlP5.Controller : Knob onMove(CallbackListener) 
controlP5.Controller : Knob onPress(CallbackListener) 
controlP5.Controller : Knob onRelease(CallbackListener) 
controlP5.Controller : Knob onReleaseOutside(CallbackListener) 
controlP5.Controller : Knob onStartDrag(CallbackListener) 
controlP5.Controller : Knob onWheel(CallbackListener) 
controlP5.Controller : Knob plugTo(Object) 
controlP5.Controller : Knob plugTo(Object, String) 
controlP5.Controller : Knob plugTo(Object[]) 
controlP5.Controller : Knob plugTo(Object[], String) 
controlP5.Controller : Knob registerProperty(String) 
controlP5.Controller : Knob registerProperty(String, String) 
controlP5.Controller : Knob registerTooltip(String) 
controlP5.Controller : Knob removeBehavior() 
controlP5.Controller : Knob removeCallback() 
controlP5.Controller : Knob removeCallback(CallbackListener) 
controlP5.Controller : Knob removeListener(ControlListener) 
controlP5.Controller : Knob removeListenerFor(int, CallbackListener) 
controlP5.Controller : Knob removeListenersFor(int) 
controlP5.Controller : Knob removeProperty(String) 
controlP5.Controller : Knob removeProperty(String, String) 
controlP5.Controller : Knob setArrayValue(float[]) 
controlP5.Controller : Knob setArrayValue(int, float) 
controlP5.Controller : Knob setBehavior(ControlBehavior) 
controlP5.Controller : Knob setBroadcast(boolean) 
controlP5.Controller : Knob setCaptionLabel(String) 
controlP5.Controller : Knob setColor(CColor) 
controlP5.Controller : Knob setColorActive(int) 
controlP5.Controller : Knob setColorBackground(int) 
controlP5.Controller : Knob setColorCaptionLabel(int) 
controlP5.Controller : Knob setColorForeground(int) 
controlP5.Controller : Knob setColorLabel(int) 
controlP5.Controller : Knob setColorValue(int) 
controlP5.Controller : Knob setColorValueLabel(int) 
controlP5.Controller : Knob setDecimalPrecision(int) 
controlP5.Controller : Knob setDefaultValue(float) 
controlP5.Controller : Knob setHeight(int) 
controlP5.Controller : Knob setId(int) 
controlP5.Controller : Knob setImage(PImage) 
controlP5.Controller : Knob setImage(PImage, int) 
controlP5.Controller : Knob setImages(PImage, PImage, PImage) 
controlP5.Controller : Knob setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Knob setLabel(String) 
controlP5.Controller : Knob setLabelVisible(boolean) 
controlP5.Controller : Knob setLock(boolean) 
controlP5.Controller : Knob setMax(float) 
controlP5.Controller : Knob setMin(float) 
controlP5.Controller : Knob setMouseOver(boolean) 
controlP5.Controller : Knob setMoveable(boolean) 
controlP5.Controller : Knob setPosition(float, float) 
controlP5.Controller : Knob setPosition(float[]) 
controlP5.Controller : Knob setSize(PImage) 
controlP5.Controller : Knob setSize(int, int) 
controlP5.Controller : Knob setStringValue(String) 
controlP5.Controller : Knob setUpdate(boolean) 
controlP5.Controller : Knob setValue(float) 
controlP5.Controller : Knob setValueLabel(String) 
controlP5.Controller : Knob setValueSelf(float) 
controlP5.Controller : Knob setView(ControllerView) 
controlP5.Controller : Knob setVisible(boolean) 
controlP5.Controller : Knob setWidth(int) 
controlP5.Controller : Knob show() 
controlP5.Controller : Knob unlock() 
controlP5.Controller : Knob unplugFrom(Object) 
controlP5.Controller : Knob unplugFrom(Object[]) 
controlP5.Controller : Knob unregisterTooltip() 
controlP5.Controller : Knob update() 
controlP5.Controller : Knob updateSize() 
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
controlP5.Knob : Knob hideTickMarks() 
controlP5.Knob : Knob setAngleRange(float) 
controlP5.Knob : Knob setConstrained(boolean) 
controlP5.Knob : Knob setDragDirection(int) 
controlP5.Knob : Knob setMax(float) 
controlP5.Knob : Knob setMin(float) 
controlP5.Knob : Knob setNumberOfTickMarks(int) 
controlP5.Knob : Knob setRadius(float) 
controlP5.Knob : Knob setRange(float, float) 
controlP5.Knob : Knob setResolution(float) 
controlP5.Knob : Knob setScrollSensitivity(float) 
controlP5.Knob : Knob setShowAngleRange(boolean) 
controlP5.Knob : Knob setSize(int, int) 
controlP5.Knob : Knob setStartAngle(float) 
controlP5.Knob : Knob setTickMarkLength(int) 
controlP5.Knob : Knob setTickMarkWeight(float) 
controlP5.Knob : Knob setValue(float) 
controlP5.Knob : Knob setViewStyle(int) 
controlP5.Knob : Knob showTickMarks() 
controlP5.Knob : Knob shuffle() 
controlP5.Knob : Knob snapToTickMarks(boolean) 
controlP5.Knob : boolean isConstrained() 
controlP5.Knob : boolean isShowAngleRange() 
controlP5.Knob : boolean isShowTickMarks() 
controlP5.Knob : float getAngle() 
controlP5.Knob : float getAngleRange() 
controlP5.Knob : float getRadius() 
controlP5.Knob : float getResolution() 
controlP5.Knob : float getStartAngle() 
controlP5.Knob : float getTickMarkWeight() 
controlP5.Knob : float getValue() 
controlP5.Knob : int getDragDirection() 
controlP5.Knob : int getNumberOfTickMarks() 
controlP5.Knob : int getTickMarkLength() 
controlP5.Knob : int getViewStyle() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:10

*/


