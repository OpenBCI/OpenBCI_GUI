/**
* ControlP5 Textlabel
*
*
* find a list of public methods available for the Textlabel Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;

ControlP5 cp5;

Textlabel myTextlabelA;
Textlabel myTextlabelB;

void setup() {
  size(700,400);
  cp5 = new ControlP5(this);
  
  myTextlabelA = cp5.addTextlabel("label")
                    .setText("A single ControlP5 textlabel, in yellow.")
                    .setPosition(100,50)
                    .setColorValue(0xffffff00)
                    .setFont(createFont("Georgia",20))
                    ;
                    
  myTextlabelB = new Textlabel(cp5,"Another textlabel, not created through ControlP5 needs to be rendered separately by calling Textlabel.draw(PApplet).",100,100,400,200);

}



void draw() {
  background(0);
  myTextlabelB.draw(this); 
}



/*
a list of all methods available for the Textlabel Controller
use ControlP5.printPublicMethodsFor(Textlabel.class);
to print the following list into the console.

You can find further details about class Textlabel in the javadoc.

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
controlP5.Controller : Textlabel addCallback(CallbackListener) 
controlP5.Controller : Textlabel addListener(ControlListener) 
controlP5.Controller : Textlabel addListenerFor(int, CallbackListener) 
controlP5.Controller : Textlabel align(int, int, int, int) 
controlP5.Controller : Textlabel bringToFront() 
controlP5.Controller : Textlabel bringToFront(ControllerInterface) 
controlP5.Controller : Textlabel hide() 
controlP5.Controller : Textlabel linebreak() 
controlP5.Controller : Textlabel listen(boolean) 
controlP5.Controller : Textlabel lock() 
controlP5.Controller : Textlabel onChange(CallbackListener) 
controlP5.Controller : Textlabel onClick(CallbackListener) 
controlP5.Controller : Textlabel onDoublePress(CallbackListener) 
controlP5.Controller : Textlabel onDrag(CallbackListener) 
controlP5.Controller : Textlabel onDraw(ControllerView) 
controlP5.Controller : Textlabel onEndDrag(CallbackListener) 
controlP5.Controller : Textlabel onEnter(CallbackListener) 
controlP5.Controller : Textlabel onLeave(CallbackListener) 
controlP5.Controller : Textlabel onMove(CallbackListener) 
controlP5.Controller : Textlabel onPress(CallbackListener) 
controlP5.Controller : Textlabel onRelease(CallbackListener) 
controlP5.Controller : Textlabel onReleaseOutside(CallbackListener) 
controlP5.Controller : Textlabel onStartDrag(CallbackListener) 
controlP5.Controller : Textlabel onWheel(CallbackListener) 
controlP5.Controller : Textlabel plugTo(Object) 
controlP5.Controller : Textlabel plugTo(Object, String) 
controlP5.Controller : Textlabel plugTo(Object[]) 
controlP5.Controller : Textlabel plugTo(Object[], String) 
controlP5.Controller : Textlabel registerProperty(String) 
controlP5.Controller : Textlabel registerProperty(String, String) 
controlP5.Controller : Textlabel registerTooltip(String) 
controlP5.Controller : Textlabel removeBehavior() 
controlP5.Controller : Textlabel removeCallback() 
controlP5.Controller : Textlabel removeCallback(CallbackListener) 
controlP5.Controller : Textlabel removeListener(ControlListener) 
controlP5.Controller : Textlabel removeListenerFor(int, CallbackListener) 
controlP5.Controller : Textlabel removeListenersFor(int) 
controlP5.Controller : Textlabel removeProperty(String) 
controlP5.Controller : Textlabel removeProperty(String, String) 
controlP5.Controller : Textlabel setArrayValue(float[]) 
controlP5.Controller : Textlabel setArrayValue(int, float) 
controlP5.Controller : Textlabel setBehavior(ControlBehavior) 
controlP5.Controller : Textlabel setBroadcast(boolean) 
controlP5.Controller : Textlabel setCaptionLabel(String) 
controlP5.Controller : Textlabel setColor(CColor) 
controlP5.Controller : Textlabel setColorActive(int) 
controlP5.Controller : Textlabel setColorBackground(int) 
controlP5.Controller : Textlabel setColorCaptionLabel(int) 
controlP5.Controller : Textlabel setColorForeground(int) 
controlP5.Controller : Textlabel setColorLabel(int) 
controlP5.Controller : Textlabel setColorValue(int) 
controlP5.Controller : Textlabel setColorValueLabel(int) 
controlP5.Controller : Textlabel setDecimalPrecision(int) 
controlP5.Controller : Textlabel setDefaultValue(float) 
controlP5.Controller : Textlabel setHeight(int) 
controlP5.Controller : Textlabel setId(int) 
controlP5.Controller : Textlabel setImage(PImage) 
controlP5.Controller : Textlabel setImage(PImage, int) 
controlP5.Controller : Textlabel setImages(PImage, PImage, PImage) 
controlP5.Controller : Textlabel setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Textlabel setLabel(String) 
controlP5.Controller : Textlabel setLabelVisible(boolean) 
controlP5.Controller : Textlabel setLock(boolean) 
controlP5.Controller : Textlabel setMax(float) 
controlP5.Controller : Textlabel setMin(float) 
controlP5.Controller : Textlabel setMouseOver(boolean) 
controlP5.Controller : Textlabel setMoveable(boolean) 
controlP5.Controller : Textlabel setPosition(float, float) 
controlP5.Controller : Textlabel setPosition(float[]) 
controlP5.Controller : Textlabel setSize(PImage) 
controlP5.Controller : Textlabel setSize(int, int) 
controlP5.Controller : Textlabel setStringValue(String) 
controlP5.Controller : Textlabel setUpdate(boolean) 
controlP5.Controller : Textlabel setValue(float) 
controlP5.Controller : Textlabel setValueLabel(String) 
controlP5.Controller : Textlabel setValueSelf(float) 
controlP5.Controller : Textlabel setView(ControllerView) 
controlP5.Controller : Textlabel setVisible(boolean) 
controlP5.Controller : Textlabel setWidth(int) 
controlP5.Controller : Textlabel show() 
controlP5.Controller : Textlabel unlock() 
controlP5.Controller : Textlabel unplugFrom(Object) 
controlP5.Controller : Textlabel unplugFrom(Object[]) 
controlP5.Controller : Textlabel unregisterTooltip() 
controlP5.Controller : Textlabel update() 
controlP5.Controller : Textlabel updateSize() 
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

created: 2015/03/24 12:21:33

*/


