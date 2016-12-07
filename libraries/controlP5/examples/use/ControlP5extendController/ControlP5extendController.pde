/**
 * ControlP5 extending Controllers
 *
 * the following example shows how to extend the Controller class to 
 * create customizable Controllers. You can either extend the Controller class itself,
 * or any class that extends Controller itself like the Slider, Button, DropdownList, etc. 
 * 
 * How to:
 *
 * 1) do a super call to the convenience constructor requiring 
 * 2 parameter (ControlP5 instance, name)  
 *
 * 2) the Controller class has a set of empty methods that allow you to capture
 * inputs from the mouse including 
 * onEnter(), onLeave(), onPress(), onRelease(), onClick(), onScroll(int), onDrag()
 * These you can override and include functionality as needed.
 *
 * 3) use method getPointer() to return the local (relative) 
 * xy-coordinates of the controller
 *  
 * 4) after instantiation custom controllers are treated the same 
 * as default controlP5 controllers.
 *  
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */

import controlP5.*;

ControlP5 cp5;
PApplet p;

void setup() {
  size(400, 400);
  cp5 = new ControlP5(this);
  
  // create 2 groups to show nesting of custom controllers and
  //   
  Group g1 = cp5.addGroup("a").setPosition(0,100).setWidth(180);
  Group g2 = cp5.addGroup("b").setPosition(0,10).setWidth(180);
  g2.moveTo(g1);
  
  // create 2 custom Controllers from class MyButton
  // MyButton extends Controller and inherits all methods accordingly.
  new MyButton(cp5, "b1").setPosition(0, 0).setSize(180, 200).moveTo(g2);
  new MyButton(cp5, "b2").setPosition(205, 15).setSize(180, 200);
  
}


void draw() {
  background(0);
}

// b1 will be called from Controller b1
public void b1(float theValue) {
  println("yay button "+theValue);
}

public void controlEvent(ControlEvent theEvent) {
  println("controlEvent : "+theEvent);
}


// Create a custom Controller, please not that 
// MyButton extends Controller<MyButton>, <MyButton>
// is an indicator for the super class about the type of 
// custom controller to be created.

class MyButton extends Controller<MyButton> {

  int current = 0xffff0000;

  float a = 128;
  
  float na;
  
  int y;
  
  // use the convenience constructor of super class Controller
  // MyButton will automatically registered and move to the 
  // default controlP5 tab.
  
  MyButton(ControlP5 cp5, String theName) {
    super(cp5, theName);
    
    // replace the default view with a custom view.
    setView(new ControllerView() {
      public void display(PGraphics p, Object b) {
        // draw button background
        na += (a-na) * 0.1; 
        p.fill(current,na);
        p.rect(0, 0, getWidth(), getHeight());
        
        // draw horizontal line which can be moved on the x-axis 
        // using the scroll wheel. 
        p.fill(0,255,0);
        p.rect(0,y,width,10);
        
        // draw the custom label 
        p.fill(128);
        translate(0,getHeight()+14);
        p.text(getName(),0,0);
        p.text(getName(),0,0);
        
      }
    }
    );
  }

  // override various input methods for mouse input control
  void onEnter() {
    cursor(HAND);
    println("enter");
    a = 255;
  }
  
  void onScroll(int n) {
    println("scrolling");
    y -= n;
    y = constrain(y,0,getHeight()-10);
  }
  
  void onPress() {
    println("press");
    current = 0xffffff00;
  }
  
  void onClick() {
    Pointer p1 = getPointer();
    println("clicked at "+p1.x()+", "+p1.y());
    current = 0xffffff00;
    setValue(y);
  }

  void onRelease() {
    println("release");
    current = 0xffffffff;
  }
  
  void onMove() {
    println("moving "+this+" "+_myControlWindow.getMouseOverList());
  }

  void onDrag() {
    current = 0xff0000ff;
    Pointer p1 = getPointer();
    float dif = dist(p1.px(),p1.py(),p1.x(),p1.y());
    println("dragging at "+p1.x()+", "+p1.y()+" "+dif);
  }
  
  void onReleaseOutside() {
    onLeave();
  }

  void onLeave() {
    println("leave");
    cursor(ARROW);
    a = 128;
  }
}

