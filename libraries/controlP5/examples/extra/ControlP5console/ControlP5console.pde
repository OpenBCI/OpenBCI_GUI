/**
 * ControlP5 Println
 *
 *
 * a console like textarea which captures the output from the System.out stream
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */

import controlP5.*;

ControlP5 cp5;

Textarea myTextarea;

int c = 0;

Println console;

void setup() {
  size(700, 400);
  cp5 = new ControlP5(this);
  cp5.enableShortcuts();
  frameRate(50);
  myTextarea = cp5.addTextarea("txt")
                  .setPosition(100, 100)
                  .setSize(200, 200)
                  .setFont(createFont("", 10))
                  .setLineHeight(14)
                  .setColor(color(200))
                  .setColorBackground(color(0, 100))
                  .setColorForeground(color(255, 100));
  ;

  console = cp5.addConsole(myTextarea);//
}


void draw() {
  background(128);
  noStroke();
  ellipseMode(CENTER);
  float n = sin(frameCount*0.01)*300;
  fill(110, 255,220);  
  ellipse(width/2, height/2, n , n);
  
  println(frameCount+"\t"+String.format("%.2f", frameRate)+"\t"+String.format("%.2f", n));
}

void keyPressed() {
  switch(key) {
    case('1'):
    console.pause();
    break;
    case('2'):
    console.play();
    break;
    case('3'):
    console.setMax(8);
    break;
    case('4'):
    console.setMax(-1);
    break;
    case('5'):
    console.clear();
    break;
  }
}

