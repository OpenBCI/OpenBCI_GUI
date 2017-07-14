/**
 * ControlP5 ControlKey
 * use ControlKeys to map key combinations to particular events.
 * multi-keypress supported.
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */

import controlP5.*;

ControlP5 cp5;

int col;
int colEllipse;
boolean visible;

void setup() {
  size(400, 600);
  smooth();
  noStroke();
  col = color(0);
  colEllipse = color(0,255,90);  
  cp5 = new ControlP5(this);
  
  // press key 1 to change background to white             
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {col = color(255);}}, '1');
  
  // press key 2 to change background to black
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {col = color(0);}}, '2');
  
  // press key 1 and ALT to make circles visible
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {visible = true;}}, ALT,'1');
  
  // press key 2 and ALT to hide circles
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {visible = false;}}, ALT,'2');

  // press key 1 and ALT and SHIFT to change the color of circles
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {colEllipse = color(random(255));}}, ALT,'1',SHIFT);  
}
  
void draw() {
  background(col);
  if(visible) {
    fill(colEllipse);
    ellipse(100,100,50,50);
    ellipse(150,400,200,200);
  } 
}
