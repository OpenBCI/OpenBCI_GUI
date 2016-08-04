/**
 * ControlP5 Checkbox
 * an example demonstrating the use of a checkbox in controlP5. 
 * CheckBox extends the RadioButton class.
 * to control a checkbox use: 
 * activate(), deactivate(), activateAll(), deactivateAll(), toggle(), getState()
 *
 * find a list of public methods available for the Checkbox Controller 
 * at the bottom of this sketch's source code
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlP5
 *
 */


import controlP5.*;

ControlP5 cp5;

CheckBox checkbox;

int myColorBackground;

void setup() {
  size(800, 400);
  smooth();
  cp5 = new ControlP5(this);
  checkbox = cp5.addCheckBox("checkBox")
                .setPosition(100, 200)
                .setSize(40, 40)
                .setItemsPerRow(3)
                .setSpacingColumn(30)
                .setSpacingRow(20)
                .addItem("0", 0)
                .addItem("50", 50)
                .addItem("100", 100)
                .addItem("150", 150)
                .addItem("200", 200)
                .addItem("255", 255)
                ;
}

void keyPressed() {
  if (key==' ') {
    checkbox.deactivateAll();
  } 
  else {
    for (int i=0;i<6;i++) {
      // check if key 0-5 have been pressed and toggle
      // the checkbox item accordingly.
      if (keyCode==(48 + i)) { 
        // the index of checkbox items start at 0
        checkbox.toggle(i);
        println("toggle "+checkbox.getItem(i).getName());
        // also see 
        // checkbox.activate(index);
        // checkbox.deactivate(index);
      }
    }
  }
}

void draw() {
  background(170);
  pushMatrix();
  translate(width/2 + 200, height/2);
  stroke(255);
  strokeWeight(2);
  fill(myColorBackground);
  ellipse(0,0,200,200);
  popMatrix();
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(checkbox)) {
    myColorBackground = 0;
    print("got an event from "+checkbox.getName()+"\t\n");
    // checkbox uses arrayValue to store the state of 
    // individual checkbox-items. usage:
    println(checkbox.getArrayValue());
    int col = 0;
    for (int i=0;i<checkbox.getArrayValue().length;i++) {
      int n = (int)checkbox.getArrayValue()[i];
      print(n);
      if(n==1) {
        myColorBackground += checkbox.getItem(i).internalValue();
      }
    }
    println();    
  }
}

void checkBox(float[] a) {
  println(a);
}


/*
a list of all methods available for the CheckBox Controller
use ControlP5.printPublicMethodsFor(CheckBox.class);
to print the following list into the console.

You can find further details about class CheckBox in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.CheckBox : CheckBox addItem(String, float) 
controlP5.CheckBox : CheckBox addItem(Toggle, float) 
controlP5.CheckBox : CheckBox deactivateAll() 
controlP5.CheckBox : CheckBox hideLabels() 
controlP5.CheckBox : CheckBox plugTo(Object) 
controlP5.CheckBox : CheckBox plugTo(Object, String) 
controlP5.CheckBox : CheckBox removeItem(String) 
controlP5.CheckBox : CheckBox setArrayValue(float[]) 
controlP5.CheckBox : CheckBox setColorLabels(int) 
controlP5.CheckBox : CheckBox setImage(PImage) 
controlP5.CheckBox : CheckBox setImage(PImage, int) 
controlP5.CheckBox : CheckBox setImages(PImage, PImage, PImage) 
controlP5.CheckBox : CheckBox setItemHeight(int) 
controlP5.CheckBox : CheckBox setItemWidth(int) 
controlP5.CheckBox : CheckBox setItemsPerRow(int) 
controlP5.CheckBox : CheckBox setNoneSelectedAllowed(boolean) 
controlP5.CheckBox : CheckBox setSize(PImage) 
controlP5.CheckBox : CheckBox setSize(int, int) 
controlP5.CheckBox : CheckBox setSpacingColumn(int) 
controlP5.CheckBox : CheckBox setSpacingRow(int) 
controlP5.CheckBox : CheckBox showLabels() 
controlP5.CheckBox : CheckBox toUpperCase(boolean) 
controlP5.CheckBox : List getItems() 
controlP5.CheckBox : String getInfo() 
controlP5.CheckBox : String toString() 
controlP5.CheckBox : Toggle getItem(int) 
controlP5.CheckBox : boolean getState(String) 
controlP5.CheckBox : boolean getState(int) 
controlP5.CheckBox : void updateLayout() 
controlP5.ControlGroup : CheckBox activateEvent(boolean) 
controlP5.ControlGroup : CheckBox addListener(ControlListener) 
controlP5.ControlGroup : CheckBox removeListener(ControlListener) 
controlP5.ControlGroup : CheckBox setBackgroundColor(int) 
controlP5.ControlGroup : CheckBox setBackgroundHeight(int) 
controlP5.ControlGroup : CheckBox setBarHeight(int) 
controlP5.ControlGroup : CheckBox setSize(int, int) 
controlP5.ControlGroup : CheckBox updateInternalEvents(PApplet) 
controlP5.ControlGroup : String getInfo() 
controlP5.ControlGroup : String toString() 
controlP5.ControlGroup : int getBackgroundHeight() 
controlP5.ControlGroup : int getBarHeight() 
controlP5.ControlGroup : int listenerSize() 
controlP5.ControllerGroup : CColor getColor() 
controlP5.ControllerGroup : Canvas addCanvas(Canvas) 
controlP5.ControllerGroup : CheckBox add(ControllerInterface) 
controlP5.ControllerGroup : CheckBox addListener(ControlListener) 
controlP5.ControllerGroup : CheckBox bringToFront() 
controlP5.ControllerGroup : CheckBox bringToFront(ControllerInterface) 
controlP5.ControllerGroup : CheckBox close() 
controlP5.ControllerGroup : CheckBox disableCollapse() 
controlP5.ControllerGroup : CheckBox enableCollapse() 
controlP5.ControllerGroup : CheckBox hide() 
controlP5.ControllerGroup : CheckBox hideArrow() 
controlP5.ControllerGroup : CheckBox hideBar() 
controlP5.ControllerGroup : CheckBox moveTo(ControlWindow) 
controlP5.ControllerGroup : CheckBox moveTo(PApplet) 
controlP5.ControllerGroup : CheckBox open() 
controlP5.ControllerGroup : CheckBox registerProperty(String) 
controlP5.ControllerGroup : CheckBox registerProperty(String, String) 
controlP5.ControllerGroup : CheckBox remove(CDrawable) 
controlP5.ControllerGroup : CheckBox remove(ControllerInterface) 
controlP5.ControllerGroup : CheckBox removeCanvas(Canvas) 
controlP5.ControllerGroup : CheckBox removeListener(ControlListener) 
controlP5.ControllerGroup : CheckBox removeProperty(String) 
controlP5.ControllerGroup : CheckBox removeProperty(String, String) 
controlP5.ControllerGroup : CheckBox setAddress(String) 
controlP5.ControllerGroup : CheckBox setArrayValue(float[]) 
controlP5.ControllerGroup : CheckBox setArrayValue(int, float) 
controlP5.ControllerGroup : CheckBox setCaptionLabel(String) 
controlP5.ControllerGroup : CheckBox setColor(CColor) 
controlP5.ControllerGroup : CheckBox setColorActive(int) 
controlP5.ControllerGroup : CheckBox setColorBackground(int) 
controlP5.ControllerGroup : CheckBox setColorForeground(int) 
controlP5.ControllerGroup : CheckBox setColorLabel(int) 
controlP5.ControllerGroup : CheckBox setColorValue(int) 
controlP5.ControllerGroup : CheckBox setHeight(int) 
controlP5.ControllerGroup : CheckBox setId(int) 
controlP5.ControllerGroup : CheckBox setLabel(String) 
controlP5.ControllerGroup : CheckBox setMouseOver(boolean) 
controlP5.ControllerGroup : CheckBox setMoveable(boolean) 
controlP5.ControllerGroup : CheckBox setOpen(boolean) 
controlP5.ControllerGroup : CheckBox setPosition(float, float) 
controlP5.ControllerGroup : CheckBox setPosition(float[]) 
controlP5.ControllerGroup : CheckBox setSize(int, int) 
controlP5.ControllerGroup : CheckBox setStringValue(String) 
controlP5.ControllerGroup : CheckBox setTitle(String) 
controlP5.ControllerGroup : CheckBox setUpdate(boolean) 
controlP5.ControllerGroup : CheckBox setValue(float) 
controlP5.ControllerGroup : CheckBox setVisible(boolean) 
controlP5.ControllerGroup : CheckBox setWidth(int) 
controlP5.ControllerGroup : CheckBox show() 
controlP5.ControllerGroup : CheckBox showArrow() 
controlP5.ControllerGroup : CheckBox showBar() 
controlP5.ControllerGroup : CheckBox update() 
controlP5.ControllerGroup : CheckBox updateAbsolutePosition() 
controlP5.ControllerGroup : ControlWindow getWindow() 
controlP5.ControllerGroup : Controller getController(String) 
controlP5.ControllerGroup : ControllerProperty getProperty(String) 
controlP5.ControllerGroup : ControllerProperty getProperty(String, String) 
controlP5.ControllerGroup : Label getCaptionLabel() 
controlP5.ControllerGroup : Label getValueLabel() 
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
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:20:56

*/


