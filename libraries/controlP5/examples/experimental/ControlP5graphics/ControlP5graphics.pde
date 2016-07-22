/**
 * ControlP5 ControlP5graphics
 * 
 * shows you how to render controlP5 instances into a PGraphics buffer.
 *
 */

import controlP5.*;

ControlP5 c1 , c2;
PGraphics panel1 , panel2;

void setup() {
  size( 1024, 500 ,P3D  );
  
  /* create 2 buffers */
  panel1 = createGraphics( 200 , height/2 );
  panel2 = createGraphics( 200 , height/2 );
  
  /* create the first instance of ControlP5 which will be rendered into panel1 */
  c1 = new ControlP5( this );
  c1.enableShortcuts();
  c1.setBackground( color( 0 , 50 ) );
  c1.addButton("hello").setSize(200,20).setPosition( 0 , 0 );
  c1.addButton("world").setSize(200,100).setPosition( 0 , 70 );
  c1.addSlider("slider").setSize(50,20).setPosition( 0 , 40 );
  c1.setGraphics( panel1 , 0 , 0 );
  
  /* create the second instance of ControlP5 which will be rendered into panel2 */
  c2 = new ControlP5( this );
  c2.enableShortcuts();
  c2.setBackground( color( 0 , 50 ) );
  c2.addButton("hello").setSize(200,20).setPosition( 0 , 0 );
  c2.addButton("world").setSize(200,100).setPosition( 0 , 70 );
  c2.addSlider("slider").setSize(50,20).setPosition( 0 , 40 );
  c2.setGraphics( panel2 , 220 , 0 );
  
}


void draw() {
  background( 100 , 0 , 0 );
  /* to change location, un-comment line below */
  // c1.setGraphics( panel1 , int(sin(frameCount*0.1) * 100) , 0 );
}


void controlEvent( ControlEvent ce) {
  println(ce);
}
