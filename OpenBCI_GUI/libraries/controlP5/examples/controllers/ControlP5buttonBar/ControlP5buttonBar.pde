/**
 * ControlP5 ButtonBar
 * 
 * work-in-progress
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */
 

import controlP5.*;

ControlP5 cp5;


void setup() {
  size(400, 400);
  cp5 = new ControlP5(this);
  ButtonBar b = cp5.addButtonBar("bar")
     .setPosition(0, 0)
     .setSize(400, 20)
     .addItems(split("a b c d e f g h i j"," "))
     ;
     println(b.getItem("a"));
  b.changeItem("a","text","first");
  b.changeItem("b","text","second");
  b.changeItem("c","text","third");
  b.onMove(new CallbackListener(){
    public void controlEvent(CallbackEvent ev) {
      ButtonBar bar = (ButtonBar)ev.getController();
      println("hello ",bar.hover());
    }
  });
}

void bar(int n) {
  println("bar clicked, item-value:", n);
}

void draw() {
  background(220);
}

/*
a list of all methods available for the ButtonBar Controller
use ControlP5.printPublicMethodsFor(ButtonBar.class);
to print the following list into the console.

You can find further details about class ButtonBar in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.ButtonBar : ButtonBar addItem(String, Object) 
controlP5.ButtonBar : ButtonBar addItems(List) 
controlP5.ButtonBar : ButtonBar addItems(Map) 
controlP5.ButtonBar : ButtonBar addItems(String[]) 
controlP5.ButtonBar : ButtonBar clear() 
controlP5.ButtonBar : ButtonBar removeItem(String) 
controlP5.ButtonBar : ButtonBar removeItems(List) 
controlP5.ButtonBar : ButtonBar setItems(List) 
controlP5.ButtonBar : ButtonBar setItems(Map) 
controlP5.ButtonBar : ButtonBar setItems(String[]) 
controlP5.ButtonBar : List getItems() 
controlP5.ButtonBar : Map getItem(String) 
controlP5.ButtonBar : int hover() 
controlP5.ButtonBar : void changeItem(String, String, Object) 
controlP5.ButtonBar : void onClick() 
controlP5.Controller : ButtonBar addCallback(CallbackListener) 
controlP5.Controller : ButtonBar addListener(ControlListener) 
controlP5.Controller : ButtonBar addListenerFor(int, CallbackListener) 
controlP5.Controller : ButtonBar align(int, int, int, int) 
controlP5.Controller : ButtonBar bringToFront() 
controlP5.Controller : ButtonBar bringToFront(ControllerInterface) 
controlP5.Controller : ButtonBar hide() 
controlP5.Controller : ButtonBar linebreak() 
controlP5.Controller : ButtonBar listen(boolean) 
controlP5.Controller : ButtonBar lock() 
controlP5.Controller : ButtonBar onChange(CallbackListener) 
controlP5.Controller : ButtonBar onClick(CallbackListener) 
controlP5.Controller : ButtonBar onDoublePress(CallbackListener) 
controlP5.Controller : ButtonBar onDrag(CallbackListener) 
controlP5.Controller : ButtonBar onDraw(ControllerView) 
controlP5.Controller : ButtonBar onEndDrag(CallbackListener) 
controlP5.Controller : ButtonBar onEnter(CallbackListener) 
controlP5.Controller : ButtonBar onLeave(CallbackListener) 
controlP5.Controller : ButtonBar onMove(CallbackListener) 
controlP5.Controller : ButtonBar onPress(CallbackListener) 
controlP5.Controller : ButtonBar onRelease(CallbackListener) 
controlP5.Controller : ButtonBar onReleaseOutside(CallbackListener) 
controlP5.Controller : ButtonBar onStartDrag(CallbackListener) 
controlP5.Controller : ButtonBar onWheel(CallbackListener) 
controlP5.Controller : ButtonBar plugTo(Object) 
controlP5.Controller : ButtonBar plugTo(Object, String) 
controlP5.Controller : ButtonBar plugTo(Object[]) 
controlP5.Controller : ButtonBar plugTo(Object[], String) 
controlP5.Controller : ButtonBar registerProperty(String) 
controlP5.Controller : ButtonBar registerProperty(String, String) 
controlP5.Controller : ButtonBar registerTooltip(String) 
controlP5.Controller : ButtonBar removeBehavior() 
controlP5.Controller : ButtonBar removeCallback() 
controlP5.Controller : ButtonBar removeCallback(CallbackListener) 
controlP5.Controller : ButtonBar removeListener(ControlListener) 
controlP5.Controller : ButtonBar removeListenerFor(int, CallbackListener) 
controlP5.Controller : ButtonBar removeListenersFor(int) 
controlP5.Controller : ButtonBar removeProperty(String) 
controlP5.Controller : ButtonBar removeProperty(String, String) 
controlP5.Controller : ButtonBar setArrayValue(float[]) 
controlP5.Controller : ButtonBar setArrayValue(int, float) 
controlP5.Controller : ButtonBar setBehavior(ControlBehavior) 
controlP5.Controller : ButtonBar setBroadcast(boolean) 
controlP5.Controller : ButtonBar setCaptionLabel(String) 
controlP5.Controller : ButtonBar setColor(CColor) 
controlP5.Controller : ButtonBar setColorActive(int) 
controlP5.Controller : ButtonBar setColorBackground(int) 
controlP5.Controller : ButtonBar setColorCaptionLabel(int) 
controlP5.Controller : ButtonBar setColorForeground(int) 
controlP5.Controller : ButtonBar setColorLabel(int) 
controlP5.Controller : ButtonBar setColorValue(int) 
controlP5.Controller : ButtonBar setColorValueLabel(int) 
controlP5.Controller : ButtonBar setDecimalPrecision(int) 
controlP5.Controller : ButtonBar setDefaultValue(float) 
controlP5.Controller : ButtonBar setHeight(int) 
controlP5.Controller : ButtonBar setId(int) 
controlP5.Controller : ButtonBar setImage(PImage) 
controlP5.Controller : ButtonBar setImage(PImage, int) 
controlP5.Controller : ButtonBar setImages(PImage, PImage, PImage) 
controlP5.Controller : ButtonBar setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : ButtonBar setLabel(String) 
controlP5.Controller : ButtonBar setLabelVisible(boolean) 
controlP5.Controller : ButtonBar setLock(boolean) 
controlP5.Controller : ButtonBar setMax(float) 
controlP5.Controller : ButtonBar setMin(float) 
controlP5.Controller : ButtonBar setMouseOver(boolean) 
controlP5.Controller : ButtonBar setMoveable(boolean) 
controlP5.Controller : ButtonBar setPosition(float, float) 
controlP5.Controller : ButtonBar setPosition(float[]) 
controlP5.Controller : ButtonBar setSize(PImage) 
controlP5.Controller : ButtonBar setSize(int, int) 
controlP5.Controller : ButtonBar setStringValue(String) 
controlP5.Controller : ButtonBar setUpdate(boolean) 
controlP5.Controller : ButtonBar setValue(float) 
controlP5.Controller : ButtonBar setValueLabel(String) 
controlP5.Controller : ButtonBar setValueSelf(float) 
controlP5.Controller : ButtonBar setView(ControllerView) 
controlP5.Controller : ButtonBar setVisible(boolean) 
controlP5.Controller : ButtonBar setWidth(int) 
controlP5.Controller : ButtonBar show() 
controlP5.Controller : ButtonBar unlock() 
controlP5.Controller : ButtonBar unplugFrom(Object) 
controlP5.Controller : ButtonBar unplugFrom(Object[]) 
controlP5.Controller : ButtonBar unregisterTooltip() 
controlP5.Controller : ButtonBar update() 
controlP5.Controller : ButtonBar updateSize() 
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

created: 2015/03/24 12:20:51

*/


