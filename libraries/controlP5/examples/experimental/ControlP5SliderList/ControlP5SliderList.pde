
/**
 * ControlP5 SilderList
 * 
 * A custom Controller, a scrollable Menu List, using a PGraphics buffer.
 * Allows custom designs for List Item.
 * 
 * you will need a controlP5 version >= 2.1.5
 * you can download a copy from 
 * http://sojamo.de/files/archive/controlP5-2.1.5.zip
 *
 * by Andreas Schlegel, 2013
 * www.sojamo.de/libraries/controlp5
 *
 */

import controlP5.*;
import java.util.*;


ControlP5 cp5;

PFont f1;
int NUM = 100;
float[] rotation = new float[NUM];


void setup() {
  size(800, 400 ,P3D);
  f1 = createFont("Helvetica", 12);

  cp5 = new ControlP5( this );


  // create a custom SilderList with name menu, notice that function 
  // menu will be called when a menu item has been clicked.

  SilderList m = new SilderList( cp5, "menu", 250, 350 );

  m.setPosition(40, 20);
  // add some items to our SilderList
  for (int i=0;i<NUM;i++) {
    m.addItem(makeItem("slider-"+i, 0, -PI, PI ));
  }
}

// a convenience function to build a map that contains our key-value  
// pairs which we will then use to render each item of the SilderList.
//
Map<String, Object> makeItem(String theLabel, float theValue, float theMin, float theMax) {
  Map m = new HashMap<String, Object>();
  m.put("label", theLabel);
  m.put("sliderValue", theValue);
  m.put("sliderValueMin", theMin);
  m.put("sliderValueMax", theMax);
  return m;
}

void menu(int i) {
  println("got some slider-list event from item with index "+i);
}

public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom("menu")) {
    int index = int(theEvent.getValue());
    Map m = ((SilderList)theEvent.getController()).getItem(index);
    println("got a slider event from item : "+m);
    rotation[index] = f(m.get("sliderValue"));
  }
}

void draw() {
  background( 220 );
  fill(0, 128, 255);
  noStroke();
  pushMatrix();
  translate(width/2, 30 );
  for (int i=0;i<NUM;i++) {
    pushMatrix();
    translate((i%10)*35, int(i/10)*35);
    rotate(rotation[i]);
    rect(0, 0, 20, 20);
    popMatrix();
  }
  popMatrix();
}


// A custom Controller that implements a scrollable SilderList.  
// Here the controller uses a PGraphics element to render customizable 
// list items. The SilderList can be scrolled using the scroll-wheel,  
// touchpad, or mouse-drag. Slider are triggered by a press or drag.  
// clicking the scrollbar to the right makes the list scroll to the item  
// correspoinding to the click-location.  
 
class SilderList extends Controller<SilderList> {

  float pos, npos;
  int itemHeight = 60;
  int scrollerLength = 40;
  int sliderWidth = 150;
  int sliderHeight = 15;
  int sliderX = 10;
  int sliderY = 25;

  int dragMode = 0;
  int dragIndex = -1;

  List< Map<String, Object>> items = new ArrayList< Map<String, Object>>();
  PGraphics menu;
  boolean updateMenu;

  SilderList(ControlP5 c, String theName, int theWidth, int theHeight) {
    super( c, theName, 0, 0, theWidth, theHeight );
    c.register( this );
    menu = createGraphics(getWidth(), getHeight());

    setView(new ControllerView<SilderList>() {

      public void display(PGraphics pg, SilderList t ) {
        if (updateMenu) {
          updateMenu();
        }
        if (inside() ) { // draw scrollbar
          menu.beginDraw();
          int len = -(itemHeight * items.size()) + getHeight();
          int ty = int(map(pos, len, 0, getHeight() - scrollerLength - 2, 2 ) );
          menu.fill( 128 );
          menu.rect(getWidth()-6, ty, 4, scrollerLength );
          menu.endDraw();
        }
        pg.image(menu, 0, 0);
      }
    }
    );
    updateMenu();
  }

  // only update the image buffer when necessary - to save some resources
  void updateMenu() {
    int len = -(itemHeight * items.size()) + getHeight();
    npos = constrain(npos, len, 0);
    pos += (npos - pos) * 0.1;

    /// draw the SliderList
    menu.beginDraw();
    menu.noStroke();
    menu.background(240);
    menu.textFont(cp5.getFont().getFont());
    menu.pushMatrix();
    menu.translate( 0, int(pos) );
    menu.pushMatrix();

    int i0 = PApplet.max( 0, int(map(-pos, 0, itemHeight * items.size(), 0, items.size())));
    int range = ceil((float(getHeight())/float(itemHeight))+1);
    int i1 = PApplet.min( items.size(), i0 + range );

    menu.translate(0, i0*itemHeight);

    for (int i=i0;i<i1;i++) {
      Map m = items.get(i);
      menu.noStroke();
      menu.fill(200);
      menu.rect(0, itemHeight-1, getWidth(), 1 );
      menu.fill(150);
      // uncomment the following line to use a different font than the default controlP5 font
      //menu.textFont(f1); 
      String txt = String.format("%s   %.2f", m.get("label").toString().toUpperCase(), f(items.get(i).get("sliderValue")));
      menu.text(txt, 10, 20 );
      menu.fill(255);
      menu.rect(sliderX, sliderY, sliderWidth, sliderHeight);
      menu.fill(100, 230, 128);
      float min = f(items.get(i).get("sliderValueMin"));
      float max = f(items.get(i).get("sliderValueMax"));
      float val = f(items.get(i).get("sliderValue"));
      menu.rect(sliderX, sliderY, map(val, min, max, 0, sliderWidth), sliderHeight);
      menu.translate( 0, itemHeight );
    }
    menu.popMatrix();
    menu.popMatrix();
    menu.endDraw();
    updateMenu = abs(npos-pos)>0.01 ? true:false;
  }

  // when detecting a click, check if the click happend to the far right,  
  // if yes, scroll to that position, otherwise do whatever this item of 
  // the list is supposed to do.
  public void onClick() {
    if (getPointer().x()>getWidth()-10) {
      npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
      updateMenu = true;
    }
  }


  public void onPress() {
    int x = getPointer().x();
    int y = (int)(getPointer().y()-pos)%itemHeight;
    boolean withinSlider = within(x, y, sliderX, sliderY, sliderWidth, sliderHeight); 
    dragMode =  withinSlider ? 2:1;
    if (dragMode==2) {
      dragIndex = getIndex();
      float min = f(items.get(dragIndex).get("sliderValueMin"));
      float max = f(items.get(dragIndex).get("sliderValueMax"));
      float val = constrain(map(getPointer().x()-sliderX, 0, sliderWidth, min, max), min, max);
      items.get(dragIndex).put("sliderValue", val);
      setValue(dragIndex);
    }
    updateMenu = true;
  }

  public void onDrag() {
    switch(dragMode) {
      case(1): // drag and scroll the list
      npos += getPointer().dy() * 2;
      updateMenu = true;
      break;
      case(2): // drag slider
      float min = f(items.get(dragIndex).get("sliderValueMin"));
      float max = f(items.get(dragIndex).get("sliderValueMax"));
      float val = constrain(map(getPointer().x()-sliderX, 0, sliderWidth, min, max), min, max);
      items.get(dragIndex).put("sliderValue", val);
      setValue(dragIndex);
      updateMenu = true;
      break;
    }
  } 

  public void onScroll(int n) {
    npos += ( n * 4 );
    updateMenu = true;
  }

  void addItem(Map<String, Object> m) {
    items.add(m);
    updateMenu = true;
  }

  Map<String, Object> getItem(int theIndex) {
    return items.get(theIndex);
  }

  private int getIndex() {
    int len = itemHeight * items.size();
    int index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
    return index;
  }
}

public static float f( Object o ) {
  return ( o instanceof Number ) ? ( ( Number ) o ).floatValue( ) : Float.MIN_VALUE;
}

public static boolean within(int theX, int theY, int theX1, int theY1, int theW1, int theH1) {
  return (theX>theX1 && theX<theX1+theW1 && theY>theY1 && theY<theY1+theH1);
}

