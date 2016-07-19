/**
* ControlP5 ControllerStyle
*
*
* find a list of public methods available for the ControllerStyle Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2011
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;

ControlP5 cp5;

float v1 = 50, v2 = 100, v3 = 100, v4 = 100;

void setup() {
  size(400,600);
  smooth();
  noStroke();
  cp5 = new ControlP5(this);
  
  cp5.begin(100,100);
  cp5.addSlider("v1",0,255).linebreak();
  cp5.addSlider("v2",0,200).linebreak();
  cp5.addSlider("v3",0,300).linebreak();
  cp5.addSlider("v4",0,400);
  cp5.end();
  
  // change the caption label for controller v1 and apply styles
  cp5.getController("v1").setCaptionLabel("Background");
  style("v1");
  
  // change the caption label for controller v2 and apply styles
  cp5.getController("v2").setCaptionLabel("Ellipse A");
  style("v2");
  
  // change the caption label for controller v3 and apply styles
  cp5.getController("v3").setCaptionLabel("Ellipse B");
  style("v3");
  
  // change the caption label for controller v3 and apply styles
  cp5.getController("v4").setCaptionLabel("Ellipse C");
  style("v4");
  
  
}

void style(String theControllerName) {
  Controller c = cp5.getController(theControllerName);
  // adjust the height of the controller
  c.setHeight(15);
  
  // add some padding to the caption label background
  c.getCaptionLabel().getStyle().setPadding(4,4,3,4);
  
  // shift the caption label up by 4px
  c.getCaptionLabel().getStyle().setMargin(-4,0,0,0); 
  
  // set the background color of the caption label
  c.getCaptionLabel().setColorBackground(color(10,20,30,140));
}

void draw() {
  background(v1);
  fill(255,255,220,100);
  ellipse(width/2-100, height/2-100,v2 + 50,v2 + 50);
  ellipse(width/2+100, height/2,v3,v3);
  ellipse(width/2, height/2+100,v4,v4);
}



/*
a list of all methods available for the ControllerStyle Controller
use ControlP5.printPublicMethodsFor(ControllerStyle.class);
to print the following list into the console.

You can find further details about class ControllerStyle in the javadoc.

Format:
ClassName : returnType methodName(parameter type)




controlP5.ControllerStyle : ControllerStyle margin(int) 
controlP5.ControllerStyle : ControllerStyle margin(int, int, int, int) 
controlP5.ControllerStyle : ControllerStyle moveMargin(int, int, int, int) 
controlP5.ControllerStyle : ControllerStyle movePadding(int, int, int, int) 
controlP5.ControllerStyle : ControllerStyle padding(int) 
controlP5.ControllerStyle : ControllerStyle padding(int, int, int, int) 
controlP5.ControllerStyle : ControllerStyle setMargin(int, int, int, int) 
controlP5.ControllerStyle : ControllerStyle setMarginBottom(int) 
controlP5.ControllerStyle : ControllerStyle setMarginLeft(int) 
controlP5.ControllerStyle : ControllerStyle setMarginRight(int) 
controlP5.ControllerStyle : ControllerStyle setMarginTop(int) 
controlP5.ControllerStyle : ControllerStyle setPadding(int, int, int, int) 
controlP5.ControllerStyle : ControllerStyle setPaddingBottom(int) 
controlP5.ControllerStyle : ControllerStyle setPaddingLeft(int) 
controlP5.ControllerStyle : ControllerStyle setPaddingRight(int) 
controlP5.ControllerStyle : ControllerStyle setPaddingTop(int) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 


*/

