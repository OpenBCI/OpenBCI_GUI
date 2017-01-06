/**
* ControlP5 Slider2D
*
*
* find a list of public methods available for the Slider2D Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;

ControlP5 cp5;

Slider2D s;

void setup() {
  size(700,400);
  cp5 = new ControlP5(this);
  s = cp5.addSlider2D("wave")
         .setPosition(30,40)
         .setSize(100,100)
         .setMinMax(20,10,100,100)
         .setValue(50,50)
         //.disableCrosshair()
         ;
         
  smooth();
}

float cnt;
void draw() {
  background(0);
  pushMatrix();
  translate(160,140);
  noStroke();
  fill(50);
  rect(0, -100, 400,200);
  strokeWeight(1);
  line(0,0,200, 0);
  stroke(255);
  
  for(int i=1;i<400;i++) {
    float y0 = cos(map(i-1,0,s.getArrayValue()[0],-PI,PI)) * s.getArrayValue()[1]; 
    float y1 = cos(map(i,0,s.getArrayValue()[0],-PI,PI)) * s.getArrayValue()[1];
    line((i-1),y0,i,y1);
  }
  
  popMatrix();
}















/*
a list of all methods available for the Slider2D Controller
use ControlP5.printPublicMethodsFor(Slider2D.class);
to print the following list into the console.

You can find further details about class Slider2D in the javadoc.

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
controlP5.Controller : Slider2D addCallback(CallbackListener) 
controlP5.Controller : Slider2D addListener(ControlListener) 
controlP5.Controller : Slider2D addListenerFor(int, CallbackListener) 
controlP5.Controller : Slider2D align(int, int, int, int) 
controlP5.Controller : Slider2D bringToFront() 
controlP5.Controller : Slider2D bringToFront(ControllerInterface) 
controlP5.Controller : Slider2D hide() 
controlP5.Controller : Slider2D linebreak() 
controlP5.Controller : Slider2D listen(boolean) 
controlP5.Controller : Slider2D lock() 
controlP5.Controller : Slider2D onChange(CallbackListener) 
controlP5.Controller : Slider2D onClick(CallbackListener) 
controlP5.Controller : Slider2D onDoublePress(CallbackListener) 
controlP5.Controller : Slider2D onDrag(CallbackListener) 
controlP5.Controller : Slider2D onDraw(ControllerView) 
controlP5.Controller : Slider2D onEndDrag(CallbackListener) 
controlP5.Controller : Slider2D onEnter(CallbackListener) 
controlP5.Controller : Slider2D onLeave(CallbackListener) 
controlP5.Controller : Slider2D onMove(CallbackListener) 
controlP5.Controller : Slider2D onPress(CallbackListener) 
controlP5.Controller : Slider2D onRelease(CallbackListener) 
controlP5.Controller : Slider2D onReleaseOutside(CallbackListener) 
controlP5.Controller : Slider2D onStartDrag(CallbackListener) 
controlP5.Controller : Slider2D onWheel(CallbackListener) 
controlP5.Controller : Slider2D plugTo(Object) 
controlP5.Controller : Slider2D plugTo(Object, String) 
controlP5.Controller : Slider2D plugTo(Object[]) 
controlP5.Controller : Slider2D plugTo(Object[], String) 
controlP5.Controller : Slider2D registerProperty(String) 
controlP5.Controller : Slider2D registerProperty(String, String) 
controlP5.Controller : Slider2D registerTooltip(String) 
controlP5.Controller : Slider2D removeBehavior() 
controlP5.Controller : Slider2D removeCallback() 
controlP5.Controller : Slider2D removeCallback(CallbackListener) 
controlP5.Controller : Slider2D removeListener(ControlListener) 
controlP5.Controller : Slider2D removeListenerFor(int, CallbackListener) 
controlP5.Controller : Slider2D removeListenersFor(int) 
controlP5.Controller : Slider2D removeProperty(String) 
controlP5.Controller : Slider2D removeProperty(String, String) 
controlP5.Controller : Slider2D setArrayValue(float[]) 
controlP5.Controller : Slider2D setArrayValue(int, float) 
controlP5.Controller : Slider2D setBehavior(ControlBehavior) 
controlP5.Controller : Slider2D setBroadcast(boolean) 
controlP5.Controller : Slider2D setCaptionLabel(String) 
controlP5.Controller : Slider2D setColor(CColor) 
controlP5.Controller : Slider2D setColorActive(int) 
controlP5.Controller : Slider2D setColorBackground(int) 
controlP5.Controller : Slider2D setColorCaptionLabel(int) 
controlP5.Controller : Slider2D setColorForeground(int) 
controlP5.Controller : Slider2D setColorLabel(int) 
controlP5.Controller : Slider2D setColorValue(int) 
controlP5.Controller : Slider2D setColorValueLabel(int) 
controlP5.Controller : Slider2D setDecimalPrecision(int) 
controlP5.Controller : Slider2D setDefaultValue(float) 
controlP5.Controller : Slider2D setHeight(int) 
controlP5.Controller : Slider2D setId(int) 
controlP5.Controller : Slider2D setImage(PImage) 
controlP5.Controller : Slider2D setImage(PImage, int) 
controlP5.Controller : Slider2D setImages(PImage, PImage, PImage) 
controlP5.Controller : Slider2D setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Slider2D setLabel(String) 
controlP5.Controller : Slider2D setLabelVisible(boolean) 
controlP5.Controller : Slider2D setLock(boolean) 
controlP5.Controller : Slider2D setMax(float) 
controlP5.Controller : Slider2D setMin(float) 
controlP5.Controller : Slider2D setMouseOver(boolean) 
controlP5.Controller : Slider2D setMoveable(boolean) 
controlP5.Controller : Slider2D setPosition(float, float) 
controlP5.Controller : Slider2D setPosition(float[]) 
controlP5.Controller : Slider2D setSize(PImage) 
controlP5.Controller : Slider2D setSize(int, int) 
controlP5.Controller : Slider2D setStringValue(String) 
controlP5.Controller : Slider2D setUpdate(boolean) 
controlP5.Controller : Slider2D setValue(float) 
controlP5.Controller : Slider2D setValueLabel(String) 
controlP5.Controller : Slider2D setValueSelf(float) 
controlP5.Controller : Slider2D setView(ControllerView) 
controlP5.Controller : Slider2D setVisible(boolean) 
controlP5.Controller : Slider2D setWidth(int) 
controlP5.Controller : Slider2D show() 
controlP5.Controller : Slider2D unlock() 
controlP5.Controller : Slider2D unplugFrom(Object) 
controlP5.Controller : Slider2D unplugFrom(Object[]) 
controlP5.Controller : Slider2D unregisterTooltip() 
controlP5.Controller : Slider2D update() 
controlP5.Controller : Slider2D updateSize() 
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
controlP5.Slider2D : Slider2D disableCrosshair() 
controlP5.Slider2D : Slider2D enableCrosshair() 
controlP5.Slider2D : Slider2D setArrayValue(float[]) 
controlP5.Slider2D : Slider2D setCursorX(float) 
controlP5.Slider2D : Slider2D setCursorY(float) 
controlP5.Slider2D : Slider2D setMaxX(float) 
controlP5.Slider2D : Slider2D setMaxY(float) 
controlP5.Slider2D : Slider2D setMinMax(float, float, float, float) 
controlP5.Slider2D : Slider2D setMinX(float) 
controlP5.Slider2D : Slider2D setMinY(float) 
controlP5.Slider2D : Slider2D setValue(float) 
controlP5.Slider2D : Slider2D setValue(float, float) 
controlP5.Slider2D : Slider2D shuffle() 
controlP5.Slider2D : float getCursorHeight() 
controlP5.Slider2D : float getCursorWidth() 
controlP5.Slider2D : float getCursorX() 
controlP5.Slider2D : float getCursorY() 
controlP5.Slider2D : float getMaxX() 
controlP5.Slider2D : float getMaxY() 
controlP5.Slider2D : float getMinX() 
controlP5.Slider2D : float getMinY() 
controlP5.Slider2D : float[] getArrayValue() 
controlP5.Slider2D : void setValueLabelSeparator(String) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:25:47

*/


