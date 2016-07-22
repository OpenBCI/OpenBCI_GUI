/**
* ControlP5 RenderIntoPGraphics
*
*
* experimental
*
* by Andreas Schlegel, 2013
* www.sojamo.de/libraries/controlp5
*
*/


import controlP5.*;

ControlP5 c1 , c2;
PGraphics panel1 , panel2;

void setup() {
  size( 1024, 500 , P3D ); // 
  panel1 = createGraphics( 200 , height/2 );
  panel2 = createGraphics( 200 , height/2 );
  c1 = new ControlP5( this );
  c1.enableShortcuts();
  c1.setBackground( color( 0 , 50 ) );
  c1.addButton("hello").setSize(200,20).setPosition( 0 , 0 );
  c1.addButton("world").setSize(200,100).setPosition( 0 , 70 );
  c1.addSlider("slider").setSize(50,20).setPosition( 0 , 40 );
  c1.setGraphics( panel1 , 0 , 0 );
  
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
  
  /* TODO update mouseevent when using setGraphics */
  c1.setGraphics( panel1 , 100 + int(sin(frameCount*0.1) * 100) , 250 );
}


void controlEvent( ControlEvent ce) {
  println(ce);
}
