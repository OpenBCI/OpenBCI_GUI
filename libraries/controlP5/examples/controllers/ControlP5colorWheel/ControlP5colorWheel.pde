/**
* ControlP5 ColorWheel
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
  size(800, 400);
  cp5 = new ControlP5( this );
  cp5.addColorWheel("c" , 250 , 10 , 200 ).setRGB(color(128,0,255));
  noStroke();
}
  
int c = color(100);

void draw() {  
  background(50);
  fill( c );
  rect(0,240,width,200);
 println(cp5.get(ColorWheel.class,"c").getRGB()); 
}

/*
a list of all methods available for the ColorWheel Controller
use ControlP5.printPublicMethodsFor(ColorWheel.class);
to print the following list into the console.

You can find further details about class ColorWheel in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.ColorWheel : ColorWheel scrolled(int) 
controlP5.ColorWheel : ColorWheel setAlpha(int) 
controlP5.ColorWheel : ColorWheel setHSL(double, double, double) 
controlP5.ColorWheel : ColorWheel setRGB(int) 
controlP5.ColorWheel : double[] RGBtoHSL(int) 
controlP5.ColorWheel : double[] RGBtoHSL(int, int, int) 
controlP5.ColorWheel : int HSLtoRGB(double, double, double) 
controlP5.ColorWheel : int HSLtoRGB(double[]) 
controlP5.ColorWheel : int HSVtoRGB(double, double, double) 
controlP5.ColorWheel : int HSVtoRGB(double[]) 
controlP5.ColorWheel : int a() 
controlP5.ColorWheel : int b() 
controlP5.ColorWheel : int g() 
controlP5.ColorWheel : int getRGB() 
controlP5.ColorWheel : int r() 
controlP5.ColorWheel : void onDrag() 
controlP5.ColorWheel : void onEndDrag() 
controlP5.ColorWheel : void onPress() 
controlP5.ColorWheel : void onRelease() 
controlP5.ColorWheel : void onStartDrag() 
controlP5.ColorWheel : void setHue(double) 
controlP5.ColorWheel : void setLightness(double) 
controlP5.ColorWheel : void setSaturation(double) 
controlP5.Controller : CColor getColor() 
controlP5.Controller : ColorWheel addCallback(CallbackListener) 
controlP5.Controller : ColorWheel addListener(ControlListener) 
controlP5.Controller : ColorWheel addListenerFor(int, CallbackListener) 
controlP5.Controller : ColorWheel align(int, int, int, int) 
controlP5.Controller : ColorWheel bringToFront() 
controlP5.Controller : ColorWheel bringToFront(ControllerInterface) 
controlP5.Controller : ColorWheel hide() 
controlP5.Controller : ColorWheel linebreak() 
controlP5.Controller : ColorWheel listen(boolean) 
controlP5.Controller : ColorWheel lock() 
controlP5.Controller : ColorWheel onChange(CallbackListener) 
controlP5.Controller : ColorWheel onClick(CallbackListener) 
controlP5.Controller : ColorWheel onDoublePress(CallbackListener) 
controlP5.Controller : ColorWheel onDrag(CallbackListener) 
controlP5.Controller : ColorWheel onDraw(ControllerView) 
controlP5.Controller : ColorWheel onEndDrag(CallbackListener) 
controlP5.Controller : ColorWheel onEnter(CallbackListener) 
controlP5.Controller : ColorWheel onLeave(CallbackListener) 
controlP5.Controller : ColorWheel onMove(CallbackListener) 
controlP5.Controller : ColorWheel onPress(CallbackListener) 
controlP5.Controller : ColorWheel onRelease(CallbackListener) 
controlP5.Controller : ColorWheel onReleaseOutside(CallbackListener) 
controlP5.Controller : ColorWheel onStartDrag(CallbackListener) 
controlP5.Controller : ColorWheel onWheel(CallbackListener) 
controlP5.Controller : ColorWheel plugTo(Object) 
controlP5.Controller : ColorWheel plugTo(Object, String) 
controlP5.Controller : ColorWheel plugTo(Object[]) 
controlP5.Controller : ColorWheel plugTo(Object[], String) 
controlP5.Controller : ColorWheel registerProperty(String) 
controlP5.Controller : ColorWheel registerProperty(String, String) 
controlP5.Controller : ColorWheel registerTooltip(String) 
controlP5.Controller : ColorWheel removeBehavior() 
controlP5.Controller : ColorWheel removeCallback() 
controlP5.Controller : ColorWheel removeCallback(CallbackListener) 
controlP5.Controller : ColorWheel removeListener(ControlListener) 
controlP5.Controller : ColorWheel removeListenerFor(int, CallbackListener) 
controlP5.Controller : ColorWheel removeListenersFor(int) 
controlP5.Controller : ColorWheel removeProperty(String) 
controlP5.Controller : ColorWheel removeProperty(String, String) 
controlP5.Controller : ColorWheel setArrayValue(float[]) 
controlP5.Controller : ColorWheel setArrayValue(int, float) 
controlP5.Controller : ColorWheel setBehavior(ControlBehavior) 
controlP5.Controller : ColorWheel setBroadcast(boolean) 
controlP5.Controller : ColorWheel setCaptionLabel(String) 
controlP5.Controller : ColorWheel setColor(CColor) 
controlP5.Controller : ColorWheel setColorActive(int) 
controlP5.Controller : ColorWheel setColorBackground(int) 
controlP5.Controller : ColorWheel setColorCaptionLabel(int) 
controlP5.Controller : ColorWheel setColorForeground(int) 
controlP5.Controller : ColorWheel setColorLabel(int) 
controlP5.Controller : ColorWheel setColorValue(int) 
controlP5.Controller : ColorWheel setColorValueLabel(int) 
controlP5.Controller : ColorWheel setDecimalPrecision(int) 
controlP5.Controller : ColorWheel setDefaultValue(float) 
controlP5.Controller : ColorWheel setHeight(int) 
controlP5.Controller : ColorWheel setId(int) 
controlP5.Controller : ColorWheel setImage(PImage) 
controlP5.Controller : ColorWheel setImage(PImage, int) 
controlP5.Controller : ColorWheel setImages(PImage, PImage, PImage) 
controlP5.Controller : ColorWheel setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : ColorWheel setLabel(String) 
controlP5.Controller : ColorWheel setLabelVisible(boolean) 
controlP5.Controller : ColorWheel setLock(boolean) 
controlP5.Controller : ColorWheel setMax(float) 
controlP5.Controller : ColorWheel setMin(float) 
controlP5.Controller : ColorWheel setMouseOver(boolean) 
controlP5.Controller : ColorWheel setMoveable(boolean) 
controlP5.Controller : ColorWheel setPosition(float, float) 
controlP5.Controller : ColorWheel setPosition(float[]) 
controlP5.Controller : ColorWheel setSize(PImage) 
controlP5.Controller : ColorWheel setSize(int, int) 
controlP5.Controller : ColorWheel setStringValue(String) 
controlP5.Controller : ColorWheel setUpdate(boolean) 
controlP5.Controller : ColorWheel setValue(float) 
controlP5.Controller : ColorWheel setValueLabel(String) 
controlP5.Controller : ColorWheel setValueSelf(float) 
controlP5.Controller : ColorWheel setView(ControllerView) 
controlP5.Controller : ColorWheel setVisible(boolean) 
controlP5.Controller : ColorWheel setWidth(int) 
controlP5.Controller : ColorWheel show() 
controlP5.Controller : ColorWheel unlock() 
controlP5.Controller : ColorWheel unplugFrom(Object) 
controlP5.Controller : ColorWheel unplugFrom(Object[]) 
controlP5.Controller : ColorWheel unregisterTooltip() 
controlP5.Controller : ColorWheel update() 
controlP5.Controller : ColorWheel updateSize() 
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
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:00

*/


