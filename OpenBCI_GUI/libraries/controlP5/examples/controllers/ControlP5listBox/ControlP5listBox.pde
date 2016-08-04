/**
*
* DEPRECATED, use ScrollableList instead.
*
* ControlP5 ListBox
*
* find a list of public methods available for the ListBox Controller
* at the bottom of this sketch.
* use the scrollwheel, up or down cursors to scroll through 
* a listbox when hovering with the mouse.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/


import controlP5.*;

ControlP5 cp5;

ListBox l;

int cnt = 0;

void setup() {
  
  size(700, 400);
  cp5 = new ControlP5(this);
  
  // ListBox is DEPRECATED, 
  // use ScrollableList instead, 
  // see example ControlP5scrollableList
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  l = cp5.addListBox("myList")
         .setPosition(100, 100)
         .setSize(120, 120)
         .setItemHeight(15)
         .setBarHeight(15)
         .setColorBackground(color(255, 128))
         .setColorActive(color(0))
         .setColorForeground(color(255, 100,0))
         ;

  l.getCaptionLabel().toUpperCase(true);
  l.getCaptionLabel().set("A Listbox");
  l.getCaptionLabel().setColor(0xffff0000);
  for (int i=0;i<80;i++) {
    l.addItem("item "+i, i);
    l.getItem("item "+i).put("color", new CColor().setBackground(0xffff0000).setBackground(0xffff8800));
  }
  
}

void keyPressed() {
  if (key=='0') {
    // will activate the listbox item with value 5
    l.setValue(5);
  }
  if (key=='1') {
    // set the height of a listBox should always be a multiple of itemHeight
    l.setHeight(210);
  } 
  else if (key=='2') {
    // set the height of a listBox should always be a multiple of itemHeight
    l.setHeight(120);
  } 
  else if (key=='3') {
    // set the width of a listBox
    l.setWidth(200);
  }
  else if (key=='i') {
    // set the height of a listBoxItem, should always be a fraction of the listBox
    l.setItemHeight(30);
  } 
  else if (key=='u') {
    // set the height of a listBoxItem, should always be a fraction of the listBox
    l.setItemHeight(10);
    l.setBackgroundColor(color(100, 0, 0));
  } 
  else if (key=='a') {
    int n = (int)(random(100000));
    l.addItem("item "+n, n);
  } 
  else if (key=='d') {
    l.removeItem("item "+cnt);
    cnt++;
  } else if (key=='c') {
    l.clear();
  }
}

void controlEvent(ControlEvent theEvent) {
  // ListBox is if type ControlGroup.
  // 1 controlEvent will be executed, where the event
  // originates from a ControlGroup. therefore
  // you need to check the Event with
  // if (theEvent.isGroup())
  // to avoid an error message from controlP5.

  if (theEvent.isGroup()) {
    // an event from a group e.g. scrollList
    println(theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  }
  
  if(theEvent.isGroup() && theEvent.getName().equals("myList")){
    int test = (int)theEvent.getGroup().getValue();
    println("test "+test);
}
}

void draw() {
  background(128);
  // scroll the scroll List according to the mouseX position
  // when holding down SPACE.
  if (keyPressed && key==' ') {
    //l.scroll(mouseX/((float)width)); // scroll taks values between 0 and 1
  }
  if (keyPressed && key==' ') {
    l.setWidth(mouseX);
  }
}



/*
a list of all methods available for the ListBox Controller
use ControlP5.printPublicMethodsFor(ListBox.class);
to print the following list into the console.

You can find further details about class ListBox in the javadoc.

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
controlP5.Controller : ListBox addCallback(CallbackListener) 
controlP5.Controller : ListBox addListener(ControlListener) 
controlP5.Controller : ListBox addListenerFor(int, CallbackListener) 
controlP5.Controller : ListBox align(int, int, int, int) 
controlP5.Controller : ListBox bringToFront() 
controlP5.Controller : ListBox bringToFront(ControllerInterface) 
controlP5.Controller : ListBox hide() 
controlP5.Controller : ListBox linebreak() 
controlP5.Controller : ListBox listen(boolean) 
controlP5.Controller : ListBox lock() 
controlP5.Controller : ListBox onChange(CallbackListener) 
controlP5.Controller : ListBox onClick(CallbackListener) 
controlP5.Controller : ListBox onDoublePress(CallbackListener) 
controlP5.Controller : ListBox onDrag(CallbackListener) 
controlP5.Controller : ListBox onDraw(ControllerView) 
controlP5.Controller : ListBox onEndDrag(CallbackListener) 
controlP5.Controller : ListBox onEnter(CallbackListener) 
controlP5.Controller : ListBox onLeave(CallbackListener) 
controlP5.Controller : ListBox onMove(CallbackListener) 
controlP5.Controller : ListBox onPress(CallbackListener) 
controlP5.Controller : ListBox onRelease(CallbackListener) 
controlP5.Controller : ListBox onReleaseOutside(CallbackListener) 
controlP5.Controller : ListBox onStartDrag(CallbackListener) 
controlP5.Controller : ListBox onWheel(CallbackListener) 
controlP5.Controller : ListBox plugTo(Object) 
controlP5.Controller : ListBox plugTo(Object, String) 
controlP5.Controller : ListBox plugTo(Object[]) 
controlP5.Controller : ListBox plugTo(Object[], String) 
controlP5.Controller : ListBox registerProperty(String) 
controlP5.Controller : ListBox registerProperty(String, String) 
controlP5.Controller : ListBox registerTooltip(String) 
controlP5.Controller : ListBox removeBehavior() 
controlP5.Controller : ListBox removeCallback() 
controlP5.Controller : ListBox removeCallback(CallbackListener) 
controlP5.Controller : ListBox removeListener(ControlListener) 
controlP5.Controller : ListBox removeListenerFor(int, CallbackListener) 
controlP5.Controller : ListBox removeListenersFor(int) 
controlP5.Controller : ListBox removeProperty(String) 
controlP5.Controller : ListBox removeProperty(String, String) 
controlP5.Controller : ListBox setArrayValue(float[]) 
controlP5.Controller : ListBox setArrayValue(int, float) 
controlP5.Controller : ListBox setBehavior(ControlBehavior) 
controlP5.Controller : ListBox setBroadcast(boolean) 
controlP5.Controller : ListBox setCaptionLabel(String) 
controlP5.Controller : ListBox setColor(CColor) 
controlP5.Controller : ListBox setColorActive(int) 
controlP5.Controller : ListBox setColorBackground(int) 
controlP5.Controller : ListBox setColorCaptionLabel(int) 
controlP5.Controller : ListBox setColorForeground(int) 
controlP5.Controller : ListBox setColorLabel(int) 
controlP5.Controller : ListBox setColorValue(int) 
controlP5.Controller : ListBox setColorValueLabel(int) 
controlP5.Controller : ListBox setDecimalPrecision(int) 
controlP5.Controller : ListBox setDefaultValue(float) 
controlP5.Controller : ListBox setHeight(int) 
controlP5.Controller : ListBox setId(int) 
controlP5.Controller : ListBox setImage(PImage) 
controlP5.Controller : ListBox setImage(PImage, int) 
controlP5.Controller : ListBox setImages(PImage, PImage, PImage) 
controlP5.Controller : ListBox setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : ListBox setLabel(String) 
controlP5.Controller : ListBox setLabelVisible(boolean) 
controlP5.Controller : ListBox setLock(boolean) 
controlP5.Controller : ListBox setMax(float) 
controlP5.Controller : ListBox setMin(float) 
controlP5.Controller : ListBox setMouseOver(boolean) 
controlP5.Controller : ListBox setMoveable(boolean) 
controlP5.Controller : ListBox setPosition(float, float) 
controlP5.Controller : ListBox setPosition(float[]) 
controlP5.Controller : ListBox setSize(PImage) 
controlP5.Controller : ListBox setSize(int, int) 
controlP5.Controller : ListBox setStringValue(String) 
controlP5.Controller : ListBox setUpdate(boolean) 
controlP5.Controller : ListBox setValue(float) 
controlP5.Controller : ListBox setValueLabel(String) 
controlP5.Controller : ListBox setValueSelf(float) 
controlP5.Controller : ListBox setView(ControllerView) 
controlP5.Controller : ListBox setVisible(boolean) 
controlP5.Controller : ListBox setWidth(int) 
controlP5.Controller : ListBox show() 
controlP5.Controller : ListBox unlock() 
controlP5.Controller : ListBox unplugFrom(Object) 
controlP5.Controller : ListBox unplugFrom(Object[]) 
controlP5.Controller : ListBox unregisterTooltip() 
controlP5.Controller : ListBox update() 
controlP5.Controller : ListBox updateSize() 
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
controlP5.ListBox : List getItems() 
controlP5.ListBox : ListBox addItem(String, Object) 
controlP5.ListBox : ListBox addItems(List) 
controlP5.ListBox : ListBox addItems(Map) 
controlP5.ListBox : ListBox addItems(String[]) 
controlP5.ListBox : ListBox clear() 
controlP5.ListBox : ListBox close() 
controlP5.ListBox : ListBox open() 
controlP5.ListBox : ListBox removeItem(String) 
controlP5.ListBox : ListBox removeItems(List) 
controlP5.ListBox : ListBox setBackgroundColor(int) 
controlP5.ListBox : ListBox setBarHeight(int) 
controlP5.ListBox : ListBox setBarVisible(boolean) 
controlP5.ListBox : ListBox setItemHeight(int) 
controlP5.ListBox : ListBox setItems(List) 
controlP5.ListBox : ListBox setItems(Map) 
controlP5.ListBox : ListBox setItems(String[]) 
controlP5.ListBox : ListBox setOpen(boolean) 
controlP5.ListBox : ListBox setScrollSensitivity(float) 
controlP5.ListBox : ListBox setType(int) 
controlP5.ListBox : Map getItem(String) 
controlP5.ListBox : Map getItem(int) 
controlP5.ListBox : boolean isBarVisible() 
controlP5.ListBox : boolean isOpen() 
controlP5.ListBox : int getBackgroundColor() 
controlP5.ListBox : int getBarHeight() 
controlP5.ListBox : int getHeight() 
controlP5.ListBox : void controlEvent(ControlEvent) 
controlP5.ListBox : void keyEvent(KeyEvent) 
controlP5.ListBox : void setDirection(int) 
controlP5.ListBox : void updateItemIndexOffset() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:12

*/


