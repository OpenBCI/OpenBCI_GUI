/**
* ControlP5 Range
*
* find a list of public methods available for the Range Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/


import controlP5.*;

ControlP5 cp5;

int myColorBackground = color(0,0,0);

int colorMin = 100;

int colorMax = 100;

Range range;

void setup() {
  size(700,400);
  cp5 = new ControlP5(this);
  range = cp5.addRange("rangeController")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(50,50)
             .setSize(400,40)
             .setHandleSize(20)
             .setRange(0,255)
             .setRangeValues(50,100)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(255,40))
             .setColorBackground(color(255,40))  
             ;
             
  noStroke();             
}

void draw() {
  background(colorMax);
  fill(colorMin);
  rect(0,0,width,height/2);
}

void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isFrom("rangeController")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    colorMin = int(theControlEvent.getController().getArrayValue(0));
    colorMax = int(theControlEvent.getController().getArrayValue(1));
    println("range update, done.");
  }
  
}


void keyPressed() {
  switch(key) {
    case('1'):range.setLowValue(0);break;
    case('2'):range.setLowValue(100);break;
    case('3'):range.setHighValue(120);break;
    case('4'):range.setHighValue(200);break;
    case('5'):range.setRangeValues(40,60);break;
  }
}


/*
a list of all methods available for the Range Controller
use ControlP5.printPublicMethodsFor(Range.class);
to print the following list into the console.

You can find further details about class Range in the javadoc.

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
controlP5.Controller : Range addCallback(CallbackListener) 
controlP5.Controller : Range addListener(ControlListener) 
controlP5.Controller : Range addListenerFor(int, CallbackListener) 
controlP5.Controller : Range align(int, int, int, int) 
controlP5.Controller : Range bringToFront() 
controlP5.Controller : Range bringToFront(ControllerInterface) 
controlP5.Controller : Range hide() 
controlP5.Controller : Range linebreak() 
controlP5.Controller : Range listen(boolean) 
controlP5.Controller : Range lock() 
controlP5.Controller : Range onChange(CallbackListener) 
controlP5.Controller : Range onClick(CallbackListener) 
controlP5.Controller : Range onDoublePress(CallbackListener) 
controlP5.Controller : Range onDrag(CallbackListener) 
controlP5.Controller : Range onDraw(ControllerView) 
controlP5.Controller : Range onEndDrag(CallbackListener) 
controlP5.Controller : Range onEnter(CallbackListener) 
controlP5.Controller : Range onLeave(CallbackListener) 
controlP5.Controller : Range onMove(CallbackListener) 
controlP5.Controller : Range onPress(CallbackListener) 
controlP5.Controller : Range onRelease(CallbackListener) 
controlP5.Controller : Range onReleaseOutside(CallbackListener) 
controlP5.Controller : Range onStartDrag(CallbackListener) 
controlP5.Controller : Range onWheel(CallbackListener) 
controlP5.Controller : Range plugTo(Object) 
controlP5.Controller : Range plugTo(Object, String) 
controlP5.Controller : Range plugTo(Object[]) 
controlP5.Controller : Range plugTo(Object[], String) 
controlP5.Controller : Range registerProperty(String) 
controlP5.Controller : Range registerProperty(String, String) 
controlP5.Controller : Range registerTooltip(String) 
controlP5.Controller : Range removeBehavior() 
controlP5.Controller : Range removeCallback() 
controlP5.Controller : Range removeCallback(CallbackListener) 
controlP5.Controller : Range removeListener(ControlListener) 
controlP5.Controller : Range removeListenerFor(int, CallbackListener) 
controlP5.Controller : Range removeListenersFor(int) 
controlP5.Controller : Range removeProperty(String) 
controlP5.Controller : Range removeProperty(String, String) 
controlP5.Controller : Range setArrayValue(float[]) 
controlP5.Controller : Range setArrayValue(int, float) 
controlP5.Controller : Range setBehavior(ControlBehavior) 
controlP5.Controller : Range setBroadcast(boolean) 
controlP5.Controller : Range setCaptionLabel(String) 
controlP5.Controller : Range setColor(CColor) 
controlP5.Controller : Range setColorActive(int) 
controlP5.Controller : Range setColorBackground(int) 
controlP5.Controller : Range setColorCaptionLabel(int) 
controlP5.Controller : Range setColorForeground(int) 
controlP5.Controller : Range setColorLabel(int) 
controlP5.Controller : Range setColorValue(int) 
controlP5.Controller : Range setColorValueLabel(int) 
controlP5.Controller : Range setDecimalPrecision(int) 
controlP5.Controller : Range setDefaultValue(float) 
controlP5.Controller : Range setHeight(int) 
controlP5.Controller : Range setId(int) 
controlP5.Controller : Range setImage(PImage) 
controlP5.Controller : Range setImage(PImage, int) 
controlP5.Controller : Range setImages(PImage, PImage, PImage) 
controlP5.Controller : Range setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Range setLabel(String) 
controlP5.Controller : Range setLabelVisible(boolean) 
controlP5.Controller : Range setLock(boolean) 
controlP5.Controller : Range setMax(float) 
controlP5.Controller : Range setMin(float) 
controlP5.Controller : Range setMouseOver(boolean) 
controlP5.Controller : Range setMoveable(boolean) 
controlP5.Controller : Range setPosition(float, float) 
controlP5.Controller : Range setPosition(float[]) 
controlP5.Controller : Range setSize(PImage) 
controlP5.Controller : Range setSize(int, int) 
controlP5.Controller : Range setStringValue(String) 
controlP5.Controller : Range setUpdate(boolean) 
controlP5.Controller : Range setValue(float) 
controlP5.Controller : Range setValueLabel(String) 
controlP5.Controller : Range setValueSelf(float) 
controlP5.Controller : Range setView(ControllerView) 
controlP5.Controller : Range setVisible(boolean) 
controlP5.Controller : Range setWidth(int) 
controlP5.Controller : Range show() 
controlP5.Controller : Range unlock() 
controlP5.Controller : Range unplugFrom(Object) 
controlP5.Controller : Range unplugFrom(Object[]) 
controlP5.Controller : Range unregisterTooltip() 
controlP5.Controller : Range update() 
controlP5.Controller : Range updateSize() 
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
controlP5.Range : ArrayList getTickMarks() 
controlP5.Range : Range setArrayValue(float[]) 
controlP5.Range : Range setColorCaptionLabel(int) 
controlP5.Range : Range setColorTickMark(int) 
controlP5.Range : Range setColorValueLabel(int) 
controlP5.Range : Range setHandleSize(int) 
controlP5.Range : Range setHeight(int) 
controlP5.Range : Range setHighValue(float) 
controlP5.Range : Range setHighValueLabel(String) 
controlP5.Range : Range setLowValue(float) 
controlP5.Range : Range setLowValueLabel(String) 
controlP5.Range : Range setMax(float) 
controlP5.Range : Range setMin(float) 
controlP5.Range : Range setNumberOfTickMarks(int) 
controlP5.Range : Range setRange(float, float) 
controlP5.Range : Range setRangeValues(float, float) 
controlP5.Range : Range setWidth(int) 
controlP5.Range : Range showTickMarks(boolean) 
controlP5.Range : Range snapToTickMarks(boolean) 
controlP5.Range : float getHighValue() 
controlP5.Range : float getLowValue() 
controlP5.Range : float[] getArrayValue() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:20

*/


