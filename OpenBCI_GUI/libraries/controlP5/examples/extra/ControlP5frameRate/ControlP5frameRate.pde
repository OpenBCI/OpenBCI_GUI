/**
 * ControlP5 FrameRate
 *
 *
 * uses a textlabel to display the current or average 
 * framerate of the sketch.
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */


import controlP5.*;

ControlP5 cp5;

void setup() {
  size(400,500);
  frameRate(60);
  cp5 = new ControlP5(this);
  cp5.addFrameRate().setInterval(10).setPosition(0,height - 10);
  
}

void draw() {
  background(129);
}

/*
a list of all methods available for the FrameRate Controller
use ControlP5.printPublicMethodsFor(FrameRate.class);
to print the following list into the console.

You can find further details about class FrameRate in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Controller : CColor getColor() 
controlP5.Controller : ControlBehavior getBehavior() 
controlP5.Controller : ControlWindow getControlWindow() 
controlP5.Controller : ControlWindow getWindow() 
controlP5.Controller : ControllerProperty getProperty(String) 
controlP5.Controller : ControllerProperty getProperty(String, String) 
controlP5.Controller : ControllerView getView() 
controlP5.Controller : FrameRate addCallback(CallbackListener) 
controlP5.Controller : FrameRate addListener(ControlListener) 
controlP5.Controller : FrameRate addListenerFor(int, CallbackListener) 
controlP5.Controller : FrameRate align(int, int, int, int) 
controlP5.Controller : FrameRate bringToFront() 
controlP5.Controller : FrameRate bringToFront(ControllerInterface) 
controlP5.Controller : FrameRate hide() 
controlP5.Controller : FrameRate linebreak() 
controlP5.Controller : FrameRate listen(boolean) 
controlP5.Controller : FrameRate lock() 
controlP5.Controller : FrameRate onChange(CallbackListener) 
controlP5.Controller : FrameRate onClick(CallbackListener) 
controlP5.Controller : FrameRate onDoublePress(CallbackListener) 
controlP5.Controller : FrameRate onDrag(CallbackListener) 
controlP5.Controller : FrameRate onDraw(ControllerView) 
controlP5.Controller : FrameRate onEndDrag(CallbackListener) 
controlP5.Controller : FrameRate onEnter(CallbackListener) 
controlP5.Controller : FrameRate onLeave(CallbackListener) 
controlP5.Controller : FrameRate onMove(CallbackListener) 
controlP5.Controller : FrameRate onPress(CallbackListener) 
controlP5.Controller : FrameRate onRelease(CallbackListener) 
controlP5.Controller : FrameRate onReleaseOutside(CallbackListener) 
controlP5.Controller : FrameRate onStartDrag(CallbackListener) 
controlP5.Controller : FrameRate onWheel(CallbackListener) 
controlP5.Controller : FrameRate plugTo(Object) 
controlP5.Controller : FrameRate plugTo(Object, String) 
controlP5.Controller : FrameRate plugTo(Object[]) 
controlP5.Controller : FrameRate plugTo(Object[], String) 
controlP5.Controller : FrameRate registerProperty(String) 
controlP5.Controller : FrameRate registerProperty(String, String) 
controlP5.Controller : FrameRate registerTooltip(String) 
controlP5.Controller : FrameRate removeBehavior() 
controlP5.Controller : FrameRate removeCallback() 
controlP5.Controller : FrameRate removeCallback(CallbackListener) 
controlP5.Controller : FrameRate removeListener(ControlListener) 
controlP5.Controller : FrameRate removeListenerFor(int, CallbackListener) 
controlP5.Controller : FrameRate removeListenersFor(int) 
controlP5.Controller : FrameRate removeProperty(String) 
controlP5.Controller : FrameRate removeProperty(String, String) 
controlP5.Controller : FrameRate setArrayValue(float[]) 
controlP5.Controller : FrameRate setArrayValue(int, float) 
controlP5.Controller : FrameRate setBehavior(ControlBehavior) 
controlP5.Controller : FrameRate setBroadcast(boolean) 
controlP5.Controller : FrameRate setCaptionLabel(String) 
controlP5.Controller : FrameRate setColor(CColor) 
controlP5.Controller : FrameRate setColorActive(int) 
controlP5.Controller : FrameRate setColorBackground(int) 
controlP5.Controller : FrameRate setColorCaptionLabel(int) 
controlP5.Controller : FrameRate setColorForeground(int) 
controlP5.Controller : FrameRate setColorLabel(int) 
controlP5.Controller : FrameRate setColorValue(int) 
controlP5.Controller : FrameRate setColorValueLabel(int) 
controlP5.Controller : FrameRate setDecimalPrecision(int) 
controlP5.Controller : FrameRate setDefaultValue(float) 
controlP5.Controller : FrameRate setHeight(int) 
controlP5.Controller : FrameRate setId(int) 
controlP5.Controller : FrameRate setImage(PImage) 
controlP5.Controller : FrameRate setImage(PImage, int) 
controlP5.Controller : FrameRate setImages(PImage, PImage, PImage) 
controlP5.Controller : FrameRate setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : FrameRate setLabel(String) 
controlP5.Controller : FrameRate setLabelVisible(boolean) 
controlP5.Controller : FrameRate setLock(boolean) 
controlP5.Controller : FrameRate setMax(float) 
controlP5.Controller : FrameRate setMin(float) 
controlP5.Controller : FrameRate setMouseOver(boolean) 
controlP5.Controller : FrameRate setMoveable(boolean) 
controlP5.Controller : FrameRate setPosition(float, float) 
controlP5.Controller : FrameRate setPosition(float[]) 
controlP5.Controller : FrameRate setSize(PImage) 
controlP5.Controller : FrameRate setSize(int, int) 
controlP5.Controller : FrameRate setStringValue(String) 
controlP5.Controller : FrameRate setUpdate(boolean) 
controlP5.Controller : FrameRate setValue(float) 
controlP5.Controller : FrameRate setValueLabel(String) 
controlP5.Controller : FrameRate setValueSelf(float) 
controlP5.Controller : FrameRate setView(ControllerView) 
controlP5.Controller : FrameRate setVisible(boolean) 
controlP5.Controller : FrameRate setWidth(int) 
controlP5.Controller : FrameRate show() 
controlP5.Controller : FrameRate unlock() 
controlP5.Controller : FrameRate unplugFrom(Object) 
controlP5.Controller : FrameRate unplugFrom(Object[]) 
controlP5.Controller : FrameRate unregisterTooltip() 
controlP5.Controller : FrameRate update() 
controlP5.Controller : FrameRate updateSize() 
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
controlP5.FrameRate : FrameRate setInterval(int) 
controlP5.FrameRate : void draw(PGraphics) 
controlP5.Textlabel : ControllerStyle getStyle() 
controlP5.Textlabel : Label get() 
controlP5.Textlabel : Textlabel append(String, int) 
controlP5.Textlabel : Textlabel setColor(int) 
controlP5.Textlabel : Textlabel setFont(ControlFont) 
controlP5.Textlabel : Textlabel setFont(PFont) 
controlP5.Textlabel : Textlabel setHeight(int) 
controlP5.Textlabel : Textlabel setLetterSpacing(int) 
controlP5.Textlabel : Textlabel setLineHeight(int) 
controlP5.Textlabel : Textlabel setMultiline(boolean) 
controlP5.Textlabel : Textlabel setStringValue(String) 
controlP5.Textlabel : Textlabel setText(String) 
controlP5.Textlabel : Textlabel setValue(String) 
controlP5.Textlabel : Textlabel setValue(float) 
controlP5.Textlabel : Textlabel setWidth(int) 
controlP5.Textlabel : int getLineHeight() 
controlP5.Textlabel : void draw() 
controlP5.Textlabel : void draw(PApplet) 
controlP5.Textlabel : void draw(PGraphics) 
controlP5.Textlabel : void draw(int, int) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:22:02

*/


