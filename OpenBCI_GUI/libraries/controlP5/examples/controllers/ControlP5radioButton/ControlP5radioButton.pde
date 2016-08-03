/**
* ControlP5 RadioButton
*
*
* find a list of public methods available for the RadioButton Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/


import controlP5.*;

ControlP5 cp5;

int myColorBackground = color(0,0,0);

RadioButton r1, r2;

void setup() {
  size(700,400);
  
  cp5 = new ControlP5(this);
  r1 = cp5.addRadioButton("radioButton")
         .setPosition(100,180)
         .setSize(40,20)
         .setColorForeground(color(120))
         .setColorActive(color(255))
         .setColorLabel(color(255))
         .setItemsPerRow(5)
         .setSpacingColumn(50)
         .addItem("50",1)
         .addItem("100",2)
         .addItem("150",3)
         .addItem("200",4)
         .addItem("250",5)
         ;
     
     for(Toggle t:r1.getItems()) {
       t.getCaptionLabel().setColorBackground(color(255,80));
       t.getCaptionLabel().getStyle().moveMargin(-7,0,0,-3);
       t.getCaptionLabel().getStyle().movePadding(7,0,0,3);
       t.getCaptionLabel().getStyle().backgroundWidth = 45;
       t.getCaptionLabel().getStyle().backgroundHeight = 13;
     }
   
}


void draw() {
  background(myColorBackground);
}


void keyPressed() {
  switch(key) {
    case('0'): r1.deactivateAll(); break;
    case('1'): r1.activate(0); break;
    case('2'): r1.activate(1); break;
    case('3'): r1.activate(2); break;
    case('4'): r1.activate(3); break;
    case('5'): r1.activate(4); break;
  }
  
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(r1)) {
    print("got an event from "+theEvent.getName()+"\t");
    for(int i=0;i<theEvent.getGroup().getArrayValue().length;i++) {
      print(int(theEvent.getGroup().getArrayValue()[i]));
    }
    println("\t "+theEvent.getValue());
    myColorBackground = color(int(theEvent.getGroup().getValue()*50),0,0);
  }
}

void radioButton(int a) {
  println("a radio Button event: "+a);
}

/*
a list of all methods available for the RadioButton Controller
use ControlP5.printPublicMethodsFor(RadioButton.class);
to print the following list into the console.

You can find further details about class RadioButton in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.ControlGroup : RadioButton activateEvent(boolean) 
controlP5.ControlGroup : RadioButton addListener(ControlListener) 
controlP5.ControlGroup : RadioButton removeListener(ControlListener) 
controlP5.ControlGroup : RadioButton setBackgroundColor(int) 
controlP5.ControlGroup : RadioButton setBackgroundHeight(int) 
controlP5.ControlGroup : RadioButton setBarHeight(int) 
controlP5.ControlGroup : RadioButton setSize(int, int) 
controlP5.ControlGroup : RadioButton updateInternalEvents(PApplet) 
controlP5.ControlGroup : String getInfo() 
controlP5.ControlGroup : String toString() 
controlP5.ControlGroup : int getBackgroundHeight() 
controlP5.ControlGroup : int getBarHeight() 
controlP5.ControlGroup : int listenerSize() 
controlP5.ControllerGroup : CColor getColor() 
controlP5.ControllerGroup : Canvas addCanvas(Canvas) 
controlP5.ControllerGroup : ControlWindow getWindow() 
controlP5.ControllerGroup : Controller getController(String) 
controlP5.ControllerGroup : ControllerProperty getProperty(String) 
controlP5.ControllerGroup : ControllerProperty getProperty(String, String) 
controlP5.ControllerGroup : Label getCaptionLabel() 
controlP5.ControllerGroup : Label getValueLabel() 
controlP5.ControllerGroup : RadioButton add(ControllerInterface) 
controlP5.ControllerGroup : RadioButton addListener(ControlListener) 
controlP5.ControllerGroup : RadioButton bringToFront() 
controlP5.ControllerGroup : RadioButton bringToFront(ControllerInterface) 
controlP5.ControllerGroup : RadioButton close() 
controlP5.ControllerGroup : RadioButton disableCollapse() 
controlP5.ControllerGroup : RadioButton enableCollapse() 
controlP5.ControllerGroup : RadioButton hide() 
controlP5.ControllerGroup : RadioButton hideArrow() 
controlP5.ControllerGroup : RadioButton hideBar() 
controlP5.ControllerGroup : RadioButton moveTo(ControlWindow) 
controlP5.ControllerGroup : RadioButton moveTo(PApplet) 
controlP5.ControllerGroup : RadioButton open() 
controlP5.ControllerGroup : RadioButton registerProperty(String) 
controlP5.ControllerGroup : RadioButton registerProperty(String, String) 
controlP5.ControllerGroup : RadioButton remove(CDrawable) 
controlP5.ControllerGroup : RadioButton remove(ControllerInterface) 
controlP5.ControllerGroup : RadioButton removeCanvas(Canvas) 
controlP5.ControllerGroup : RadioButton removeListener(ControlListener) 
controlP5.ControllerGroup : RadioButton removeProperty(String) 
controlP5.ControllerGroup : RadioButton removeProperty(String, String) 
controlP5.ControllerGroup : RadioButton setAddress(String) 
controlP5.ControllerGroup : RadioButton setArrayValue(float[]) 
controlP5.ControllerGroup : RadioButton setArrayValue(int, float) 
controlP5.ControllerGroup : RadioButton setCaptionLabel(String) 
controlP5.ControllerGroup : RadioButton setColor(CColor) 
controlP5.ControllerGroup : RadioButton setColorActive(int) 
controlP5.ControllerGroup : RadioButton setColorBackground(int) 
controlP5.ControllerGroup : RadioButton setColorForeground(int) 
controlP5.ControllerGroup : RadioButton setColorLabel(int) 
controlP5.ControllerGroup : RadioButton setColorValue(int) 
controlP5.ControllerGroup : RadioButton setHeight(int) 
controlP5.ControllerGroup : RadioButton setId(int) 
controlP5.ControllerGroup : RadioButton setLabel(String) 
controlP5.ControllerGroup : RadioButton setMouseOver(boolean) 
controlP5.ControllerGroup : RadioButton setMoveable(boolean) 
controlP5.ControllerGroup : RadioButton setOpen(boolean) 
controlP5.ControllerGroup : RadioButton setPosition(float, float) 
controlP5.ControllerGroup : RadioButton setPosition(float[]) 
controlP5.ControllerGroup : RadioButton setSize(int, int) 
controlP5.ControllerGroup : RadioButton setStringValue(String) 
controlP5.ControllerGroup : RadioButton setTitle(String) 
controlP5.ControllerGroup : RadioButton setUpdate(boolean) 
controlP5.ControllerGroup : RadioButton setValue(float) 
controlP5.ControllerGroup : RadioButton setVisible(boolean) 
controlP5.ControllerGroup : RadioButton setWidth(int) 
controlP5.ControllerGroup : RadioButton show() 
controlP5.ControllerGroup : RadioButton showArrow() 
controlP5.ControllerGroup : RadioButton showBar() 
controlP5.ControllerGroup : RadioButton update() 
controlP5.ControllerGroup : RadioButton updateAbsolutePosition() 
controlP5.ControllerGroup : String getAddress() 
controlP5.ControllerGroup : String getInfo() 
controlP5.ControllerGroup : String getName() 
controlP5.ControllerGroup : String getStringValue() 
controlP5.ControllerGroup : String toString() 
controlP5.ControllerGroup : Tab getTab() 
controlP5.ControllerGroup : boolean isBarVisible() 
controlP5.ControllerGroup : boolean isCollapse() 
controlP5.ControllerGroup : boolean isMouseOver() 
controlP5.ControllerGroup : boolean isMoveable() 
controlP5.ControllerGroup : boolean isOpen() 
controlP5.ControllerGroup : boolean isUpdate() 
controlP5.ControllerGroup : boolean isVisible() 
controlP5.ControllerGroup : boolean setMousePressed(boolean) 
controlP5.ControllerGroup : float getArrayValue(int) 
controlP5.ControllerGroup : float getValue() 
controlP5.ControllerGroup : float[] getArrayValue() 
controlP5.ControllerGroup : float[] getPosition() 
controlP5.ControllerGroup : int getHeight() 
controlP5.ControllerGroup : int getId() 
controlP5.ControllerGroup : int getWidth() 
controlP5.ControllerGroup : int listenerSize() 
controlP5.ControllerGroup : void controlEvent(ControlEvent) 
controlP5.ControllerGroup : void remove() 
controlP5.RadioButton : List getItems() 
controlP5.RadioButton : RadioButton activate(String) 
controlP5.RadioButton : RadioButton activate(int) 
controlP5.RadioButton : RadioButton addItem(String, float) 
controlP5.RadioButton : RadioButton addItem(Toggle, float) 
controlP5.RadioButton : RadioButton align(int, int) 
controlP5.RadioButton : RadioButton align(int[]) 
controlP5.RadioButton : RadioButton alignX(int) 
controlP5.RadioButton : RadioButton alignY(int) 
controlP5.RadioButton : RadioButton deactivate(String) 
controlP5.RadioButton : RadioButton deactivate(int) 
controlP5.RadioButton : RadioButton deactivateAll() 
controlP5.RadioButton : RadioButton hideLabels() 
controlP5.RadioButton : RadioButton plugTo(Object) 
controlP5.RadioButton : RadioButton plugTo(Object, String) 
controlP5.RadioButton : RadioButton removeItem(String) 
controlP5.RadioButton : RadioButton setArrayValue(float[]) 
controlP5.RadioButton : RadioButton setColorLabels(int) 
controlP5.RadioButton : RadioButton setImage(PImage) 
controlP5.RadioButton : RadioButton setImage(PImage, int) 
controlP5.RadioButton : RadioButton setImages(PImage, PImage, PImage) 
controlP5.RadioButton : RadioButton setItemHeight(int) 
controlP5.RadioButton : RadioButton setItemWidth(int) 
controlP5.RadioButton : RadioButton setItemsPerRow(int) 
controlP5.RadioButton : RadioButton setLabelPadding(int, int) 
controlP5.RadioButton : RadioButton setNoneSelectedAllowed(boolean) 
controlP5.RadioButton : RadioButton setSize(PImage) 
controlP5.RadioButton : RadioButton setSize(int, int) 
controlP5.RadioButton : RadioButton setSpacingColumn(int) 
controlP5.RadioButton : RadioButton setSpacingRow(int) 
controlP5.RadioButton : RadioButton showLabels() 
controlP5.RadioButton : RadioButton toUpperCase(boolean) 
controlP5.RadioButton : RadioButton toggle(int) 
controlP5.RadioButton : String getInfo() 
controlP5.RadioButton : Toggle getItem(String) 
controlP5.RadioButton : Toggle getItem(int) 
controlP5.RadioButton : boolean getState(String) 
controlP5.RadioButton : boolean getState(int) 
controlP5.RadioButton : int[] getAlign() 
controlP5.RadioButton : void updateLayout() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:19

*/


