/**
 * ControlP5 ScrollableList
 *
 * replaces DropdownList and and ListBox. 
 * List can be scrolled by dragging the list or using the scroll-wheel. 
 *
 * by Andreas Schlegel, 2014
 * www.sojamo.de/libraries/controlp5
 *
 */


import controlP5.*;
import java.util.*;


ControlP5 cp5;

void setup() {
  size(400, 400);
  cp5 = new ControlP5(this);
  List l = Arrays.asList("a", "b", "c", "d", "e", "f", "g", "h");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("dropdown")
     .setPosition(100, 100)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(l)
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ;
     
     
}

void draw() {
  background(240);
}

void dropdown(int n) {
  /* request the selected item based on index n */
  println(n, cp5.get(ScrollableList.class, "dropdown").getItem(n));
  
  /* here an item is stored as a Map  with the following key-value pairs:
   * name, the given name of the item
   * text, the given text of the item by default the same as name
   * value, the given value of the item, can be changed by using .getItem(n).put("value", "abc"); a value here is of type Object therefore can be anything
   * color, the given color of the item, how to change, see below
   * view, a customizable view, is of type CDrawable 
   */
  
   CColor c = new CColor();
  c.setBackground(color(255,0,0));
  cp5.get(ScrollableList.class, "dropdown").getItem(n).put("color", c);
  
}

void keyPressed() {
  switch(key) {
    case('1'):
    /* make the ScrollableList behave like a ListBox */
    cp5.get(ScrollableList.class, "dropdown").setType(ControlP5.LIST);
    break;
    case('2'):
    /* make the ScrollableList behave like a DropdownList */
    cp5.get(ScrollableList.class, "dropdown").setType(ControlP5.DROPDOWN);
    break;
    case('3'):
    /*change content of the ScrollableList */
    List l = Arrays.asList("a-1", "b-1", "c-1", "d-1", "e-1", "f-1", "g-1", "h-1", "i-1", "j-1", "k-1");
    cp5.get(ScrollableList.class, "dropdown").setItems(l);
    break;
    case('4'):
    /* remove an item from the ScrollableList */
    cp5.get(ScrollableList.class, "dropdown").removeItem("k-1");
    break;
    case('5'):
    /* clear the ScrollableList */
    cp5.get(ScrollableList.class, "dropdown").clear();
    break;
  }
}
/*
a list of all methods available for the ScrollableList Controller
use ControlP5.printPublicMethodsFor(ScrollableList.class);
to print the following list into the console.

You can find further details about class ScrollableList in the javadoc.

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
controlP5.Controller : ScrollableList addCallback(CallbackListener) 
controlP5.Controller : ScrollableList addListener(ControlListener) 
controlP5.Controller : ScrollableList addListenerFor(int, CallbackListener) 
controlP5.Controller : ScrollableList align(int, int, int, int) 
controlP5.Controller : ScrollableList bringToFront() 
controlP5.Controller : ScrollableList bringToFront(ControllerInterface) 
controlP5.Controller : ScrollableList hide() 
controlP5.Controller : ScrollableList linebreak() 
controlP5.Controller : ScrollableList listen(boolean) 
controlP5.Controller : ScrollableList lock() 
controlP5.Controller : ScrollableList onChange(CallbackListener) 
controlP5.Controller : ScrollableList onClick(CallbackListener) 
controlP5.Controller : ScrollableList onDoublePress(CallbackListener) 
controlP5.Controller : ScrollableList onDrag(CallbackListener) 
controlP5.Controller : ScrollableList onDraw(ControllerView) 
controlP5.Controller : ScrollableList onEndDrag(CallbackListener) 
controlP5.Controller : ScrollableList onEnter(CallbackListener) 
controlP5.Controller : ScrollableList onLeave(CallbackListener) 
controlP5.Controller : ScrollableList onMove(CallbackListener) 
controlP5.Controller : ScrollableList onPress(CallbackListener) 
controlP5.Controller : ScrollableList onRelease(CallbackListener) 
controlP5.Controller : ScrollableList onReleaseOutside(CallbackListener) 
controlP5.Controller : ScrollableList onStartDrag(CallbackListener) 
controlP5.Controller : ScrollableList onWheel(CallbackListener) 
controlP5.Controller : ScrollableList plugTo(Object) 
controlP5.Controller : ScrollableList plugTo(Object, String) 
controlP5.Controller : ScrollableList plugTo(Object[]) 
controlP5.Controller : ScrollableList plugTo(Object[], String) 
controlP5.Controller : ScrollableList registerProperty(String) 
controlP5.Controller : ScrollableList registerProperty(String, String) 
controlP5.Controller : ScrollableList registerTooltip(String) 
controlP5.Controller : ScrollableList removeBehavior() 
controlP5.Controller : ScrollableList removeCallback() 
controlP5.Controller : ScrollableList removeCallback(CallbackListener) 
controlP5.Controller : ScrollableList removeListener(ControlListener) 
controlP5.Controller : ScrollableList removeListenerFor(int, CallbackListener) 
controlP5.Controller : ScrollableList removeListenersFor(int) 
controlP5.Controller : ScrollableList removeProperty(String) 
controlP5.Controller : ScrollableList removeProperty(String, String) 
controlP5.Controller : ScrollableList setArrayValue(float[]) 
controlP5.Controller : ScrollableList setArrayValue(int, float) 
controlP5.Controller : ScrollableList setBehavior(ControlBehavior) 
controlP5.Controller : ScrollableList setBroadcast(boolean) 
controlP5.Controller : ScrollableList setCaptionLabel(String) 
controlP5.Controller : ScrollableList setColor(CColor) 
controlP5.Controller : ScrollableList setColorActive(int) 
controlP5.Controller : ScrollableList setColorBackground(int) 
controlP5.Controller : ScrollableList setColorCaptionLabel(int) 
controlP5.Controller : ScrollableList setColorForeground(int) 
controlP5.Controller : ScrollableList setColorLabel(int) 
controlP5.Controller : ScrollableList setColorValue(int) 
controlP5.Controller : ScrollableList setColorValueLabel(int) 
controlP5.Controller : ScrollableList setDecimalPrecision(int) 
controlP5.Controller : ScrollableList setDefaultValue(float) 
controlP5.Controller : ScrollableList setHeight(int) 
controlP5.Controller : ScrollableList setId(int) 
controlP5.Controller : ScrollableList setImage(PImage) 
controlP5.Controller : ScrollableList setImage(PImage, int) 
controlP5.Controller : ScrollableList setImages(PImage, PImage, PImage) 
controlP5.Controller : ScrollableList setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : ScrollableList setLabel(String) 
controlP5.Controller : ScrollableList setLabelVisible(boolean) 
controlP5.Controller : ScrollableList setLock(boolean) 
controlP5.Controller : ScrollableList setMax(float) 
controlP5.Controller : ScrollableList setMin(float) 
controlP5.Controller : ScrollableList setMouseOver(boolean) 
controlP5.Controller : ScrollableList setMoveable(boolean) 
controlP5.Controller : ScrollableList setPosition(float, float) 
controlP5.Controller : ScrollableList setPosition(float[]) 
controlP5.Controller : ScrollableList setSize(PImage) 
controlP5.Controller : ScrollableList setSize(int, int) 
controlP5.Controller : ScrollableList setStringValue(String) 
controlP5.Controller : ScrollableList setUpdate(boolean) 
controlP5.Controller : ScrollableList setValue(float) 
controlP5.Controller : ScrollableList setValueLabel(String) 
controlP5.Controller : ScrollableList setValueSelf(float) 
controlP5.Controller : ScrollableList setView(ControllerView) 
controlP5.Controller : ScrollableList setVisible(boolean) 
controlP5.Controller : ScrollableList setWidth(int) 
controlP5.Controller : ScrollableList show() 
controlP5.Controller : ScrollableList unlock() 
controlP5.Controller : ScrollableList unplugFrom(Object) 
controlP5.Controller : ScrollableList unplugFrom(Object[]) 
controlP5.Controller : ScrollableList unregisterTooltip() 
controlP5.Controller : ScrollableList update() 
controlP5.Controller : ScrollableList updateSize() 
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
controlP5.ScrollableList : List getItems() 
controlP5.ScrollableList : Map getItem(String) 
controlP5.ScrollableList : Map getItem(int) 
controlP5.ScrollableList : ScrollableList addItem(String, Object) 
controlP5.ScrollableList : ScrollableList addItems(List) 
controlP5.ScrollableList : ScrollableList addItems(Map) 
controlP5.ScrollableList : ScrollableList addItems(String[]) 
controlP5.ScrollableList : ScrollableList clear() 
controlP5.ScrollableList : ScrollableList close() 
controlP5.ScrollableList : ScrollableList open() 
controlP5.ScrollableList : ScrollableList removeItem(String) 
controlP5.ScrollableList : ScrollableList removeItems(List) 
controlP5.ScrollableList : ScrollableList setBackgroundColor(int) 
controlP5.ScrollableList : ScrollableList setBarHeight(int) 
controlP5.ScrollableList : ScrollableList setBarVisible(boolean) 
controlP5.ScrollableList : ScrollableList setItemHeight(int) 
controlP5.ScrollableList : ScrollableList setItems(List) 
controlP5.ScrollableList : ScrollableList setItems(Map) 
controlP5.ScrollableList : ScrollableList setItems(String[]) 
controlP5.ScrollableList : ScrollableList setOpen(boolean) 
controlP5.ScrollableList : ScrollableList setScrollSensitivity(float) 
controlP5.ScrollableList : ScrollableList setType(int) 
controlP5.ScrollableList : boolean isBarVisible() 
controlP5.ScrollableList : boolean isOpen() 
controlP5.ScrollableList : int getBackgroundColor() 
controlP5.ScrollableList : int getBarHeight() 
controlP5.ScrollableList : int getHeight() 
controlP5.ScrollableList : void controlEvent(ControlEvent) 
controlP5.ScrollableList : void keyEvent(KeyEvent) 
controlP5.ScrollableList : void setDirection(int) 
controlP5.ScrollableList : void updateItemIndexOffset() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:22

*/


