/**
 * ControlP5 Bang
 * A bang triggers an event that can be received by a function named after the bang.
 * By default a bang is triggered when pressed, this can be changed to 'release' 
 * using theBang.setTriggerEvent(Bang.RELEASE).
 *
 * find a list of public methods available for the Bang Controller 
 * at the bottom of this sketch.
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 * 
 */

import controlP5.*;

ControlP5 cp5;

int myColorBackground = color(0, 0, 0);

color[] col = new color[] {
  color(100), color(150), color(200), color(250)
};


void setup() {
  size(400, 600);
  noStroke();
  cp5 = new ControlP5(this);
  for (int i=0;i<col.length;i++) {
    cp5.addBang("bang"+i)
       .setPosition(40+i*80, 200)
       .setSize(40, 40)
       .setId(i)
       ;
  }
  
  // change the trigger event, by default it is PRESSED.
  cp5.addBang("bang")
     .setPosition(40, 300)
     .setSize(280, 40)
     .setTriggerEvent(Bang.RELEASE)
     .setLabel("changeBackground")
     ;
           
}

void draw() {
  background(myColorBackground);
  for (int i=0;i<col.length;i++) {
    fill(col[i]);
    rect(40+i*80, 50, 40, 80);
  }
}


public void bang() {
  int theColor = (int)random(255);
  myColorBackground = color(theColor);
  println("### bang(). a bang event. setting background to "+theColor);
}

public void controlEvent(ControlEvent theEvent) {
  for (int i=0;i<col.length;i++) {
    if (theEvent.getController().getName().equals("bang"+i)) {
      col[i] = color(random(255));
    }
  }
  
  println(
  "## controlEvent / id:"+theEvent.controller().getId()+
    " / name:"+theEvent.controller().getName()+
    " / value:"+theEvent.controller().getValue()
    );
}


/*
a list of all methods available for the Bang Controller
use ControlP5.printPublicMethodsFor(Bang.class);
to print the following list into the console.

You can find further details about class Bang in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Bang : Bang setTriggerEvent(int) 
controlP5.Bang : Bang setValue(float) 
controlP5.Bang : Bang update() 
controlP5.Bang : String getInfo() 
controlP5.Bang : String toString() 
controlP5.Bang : int getTriggerEvent() 
controlP5.Controller : Bang addCallback(CallbackListener) 
controlP5.Controller : Bang addListener(ControlListener) 
controlP5.Controller : Bang addListenerFor(int, CallbackListener) 
controlP5.Controller : Bang align(int, int, int, int) 
controlP5.Controller : Bang bringToFront() 
controlP5.Controller : Bang bringToFront(ControllerInterface) 
controlP5.Controller : Bang hide() 
controlP5.Controller : Bang linebreak() 
controlP5.Controller : Bang listen(boolean) 
controlP5.Controller : Bang lock() 
controlP5.Controller : Bang onChange(CallbackListener) 
controlP5.Controller : Bang onClick(CallbackListener) 
controlP5.Controller : Bang onDoublePress(CallbackListener) 
controlP5.Controller : Bang onDrag(CallbackListener) 
controlP5.Controller : Bang onDraw(ControllerView) 
controlP5.Controller : Bang onEndDrag(CallbackListener) 
controlP5.Controller : Bang onEnter(CallbackListener) 
controlP5.Controller : Bang onLeave(CallbackListener) 
controlP5.Controller : Bang onMove(CallbackListener) 
controlP5.Controller : Bang onPress(CallbackListener) 
controlP5.Controller : Bang onRelease(CallbackListener) 
controlP5.Controller : Bang onReleaseOutside(CallbackListener) 
controlP5.Controller : Bang onStartDrag(CallbackListener) 
controlP5.Controller : Bang onWheel(CallbackListener) 
controlP5.Controller : Bang plugTo(Object) 
controlP5.Controller : Bang plugTo(Object, String) 
controlP5.Controller : Bang plugTo(Object[]) 
controlP5.Controller : Bang plugTo(Object[], String) 
controlP5.Controller : Bang registerProperty(String) 
controlP5.Controller : Bang registerProperty(String, String) 
controlP5.Controller : Bang registerTooltip(String) 
controlP5.Controller : Bang removeBehavior() 
controlP5.Controller : Bang removeCallback() 
controlP5.Controller : Bang removeCallback(CallbackListener) 
controlP5.Controller : Bang removeListener(ControlListener) 
controlP5.Controller : Bang removeListenerFor(int, CallbackListener) 
controlP5.Controller : Bang removeListenersFor(int) 
controlP5.Controller : Bang removeProperty(String) 
controlP5.Controller : Bang removeProperty(String, String) 
controlP5.Controller : Bang setArrayValue(float[]) 
controlP5.Controller : Bang setArrayValue(int, float) 
controlP5.Controller : Bang setBehavior(ControlBehavior) 
controlP5.Controller : Bang setBroadcast(boolean) 
controlP5.Controller : Bang setCaptionLabel(String) 
controlP5.Controller : Bang setColor(CColor) 
controlP5.Controller : Bang setColorActive(int) 
controlP5.Controller : Bang setColorBackground(int) 
controlP5.Controller : Bang setColorCaptionLabel(int) 
controlP5.Controller : Bang setColorForeground(int) 
controlP5.Controller : Bang setColorLabel(int) 
controlP5.Controller : Bang setColorValue(int) 
controlP5.Controller : Bang setColorValueLabel(int) 
controlP5.Controller : Bang setDecimalPrecision(int) 
controlP5.Controller : Bang setDefaultValue(float) 
controlP5.Controller : Bang setHeight(int) 
controlP5.Controller : Bang setId(int) 
controlP5.Controller : Bang setImage(PImage) 
controlP5.Controller : Bang setImage(PImage, int) 
controlP5.Controller : Bang setImages(PImage, PImage, PImage) 
controlP5.Controller : Bang setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Bang setLabel(String) 
controlP5.Controller : Bang setLabelVisible(boolean) 
controlP5.Controller : Bang setLock(boolean) 
controlP5.Controller : Bang setMax(float) 
controlP5.Controller : Bang setMin(float) 
controlP5.Controller : Bang setMouseOver(boolean) 
controlP5.Controller : Bang setMoveable(boolean) 
controlP5.Controller : Bang setPosition(float, float) 
controlP5.Controller : Bang setPosition(float[]) 
controlP5.Controller : Bang setSize(PImage) 
controlP5.Controller : Bang setSize(int, int) 
controlP5.Controller : Bang setStringValue(String) 
controlP5.Controller : Bang setUpdate(boolean) 
controlP5.Controller : Bang setValue(float) 
controlP5.Controller : Bang setValueLabel(String) 
controlP5.Controller : Bang setValueSelf(float) 
controlP5.Controller : Bang setView(ControllerView) 
controlP5.Controller : Bang setVisible(boolean) 
controlP5.Controller : Bang setWidth(int) 
controlP5.Controller : Bang show() 
controlP5.Controller : Bang unlock() 
controlP5.Controller : Bang unplugFrom(Object) 
controlP5.Controller : Bang unplugFrom(Object[]) 
controlP5.Controller : Bang unregisterTooltip() 
controlP5.Controller : Bang update() 
controlP5.Controller : Bang updateSize() 
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

created: 2015/03/24 12:25:36

*/


