/**
 * ControlP5 Annotation
 *
 * Lately annotation support has been added to processing. 
 * Making use of annotations to create controllers is a great strategy i learned
 * from Karsten Schmidt's (toxi) cp5magic library. 
 * Loving the simplicity of annotations and how it is aplied with cp5magic,
 * i had to include it into controlp5 and the following example 
 * shows how to use annotations with controlp5. 
 *
 * Annotations can be applied to variables and functions of the main program 
 * as well as individual classes. More details are included in the comments below.
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */
import controlP5.*;

ControlP5 cp5;

TestControl tc1, tc2;

Tab extraTab;

// create controllers using the ControlElement annotation
// by default a slider is created for int and float 
// values will range from 0-100 by default
// default attributes are x,y and label
@ControlElement (x=10, y=80)
int n = 20;

// to customize a controller with a CoontrolElement use the
// properties attribute. values passed using properties have a key and a value
// here the key corresponds with a function found within a controller which 
// starts with set followed by the name of the key. the value is then applied accordingly.
// e.g. min=10 will translate to controller.setMin(10)
@ControlElement (properties = { "min=0", "max=255", "type=numberbox", "height=10", "width=50"} , x=10, y=40, label="Change Background")
float m = 40;


void setup() {
  size(600, 400);
  noStroke();

  cp5 = new ControlP5(this);
  
  // Annotations:
  // addControllersFor(PApplet) checks the main sketch for 
  // annotations and adds controllers accordingly.
  cp5.addControllersFor(this);
  
  
  
  
  extraTab = cp5.addTab("extra");

  // create an instance of class testControl
  tc1 = new TestControl();

  // addControllersFor cycles throught object tc1
  // and assigns controllers according to available annotations.
  // an address will be assigned to these controllers, in the example
  // below the address is /world and the individual controllers can be 
  // accessed adding a / and the controller's name 
  // e.g. variable x
  // /world/x
  cp5.addControllersFor("world", tc1);

  // set the Position of controllers contained within object tc1
  cp5.setPosition(10, 150, tc1);


  // a more advanced example of using functions with ControllerObjects
  tc2 = new TestControl();
  CColor col = new CColor();
  col.setActive(color(0, 200, 100));
  
  cp5.addControllersFor("hello", tc2)
     .setPosition(200, 150, tc2)
     .moveTo(extraTab, tc2)
     .setColor(col, tc2);
     
  cp5.getController("s", tc2)
     .setStringValue("Second Control"); 
  
  // with listening turned on, a controller can listen to changes made to its connected variable 
  // here the controller will listen to variable x of object tc2
  cp5.getController("x", tc2).listen(true);


  // (uncomment line below) print the a map of all available controller addresses
  // cp5.printControllerMap();

  // (uncomment line below) access a controller via its address:
  // println(cp5.getController("/world/x").getInfo());
}



void draw() {
  background(m);

  pushMatrix();  
  if (tc1.b) {
    fill(tc1.x);
    translate(10, tc1.y);
    rect(0, 300, 100, 20);
  }
  popMatrix();
  fill(255);
  text(tc1.in,400,100,150,300);
  
  
  pushMatrix();
  if (tc2.b) {
    fill(tc2.x);
    translate(200, tc2.y);
    for (int i=0;i<1;i++) {
      rect(0, 300, 100, 20);
    }
  }
  popMatrix();
  fill(255);
  text(tc2.in,400,300,150,300);
  
  // the variable x of object tt is controlled by the main program,
  // the matching controller will update accordingly since it is 
  // listening for changes.
  tc2.x = (int)random(100);

  
}


public class TestControl {

  @ControlElement (properties = { "min=0", "max=255" }, x=0, y=0, label="Brightness")
    public int x = 100;

  @ControlElement (x=0, y=14, label="Y-Position")
    public float y = 0;

  @ControlElement (x=0, y=40, label="show")
    public boolean b = true;

  @ControlElement (x=50, y=40)
    public void toggle(boolean b) {
      println("hello world");
    }

  @ControlElement (x=0, y=-20, label="Control", properties = { "type=textlabel"})
    String s;

  @ControlElement (x=0, y=100, label="Type here")
    String in = "";
    
  @ControlElement (x=200, y=25, properties = {"type=list", "items=hello, world, how are you"}, label="Sample-list") 
    public void a(int val) {  
      println(val);
    }
}




