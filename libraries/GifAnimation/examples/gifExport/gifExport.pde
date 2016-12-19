/*
* Demonstrates the use of the GifAnimation library.
 * Exports a GIF-File to the sketch folder if space
 * bar is pressed. Wow, feels like 90's! ;)
 */

import gifAnimation.*;
import processing.opengl.*;

GifMaker gifExport;
PImage logo;
float rotation = 0.0;

public void setup() {
  size(200, 200, OPENGL);
  frameRate(12);
  logo = loadImage("processing.png");

  println("gifAnimation " + Gif.version());
  gifExport = new GifMaker(this, "export.gif");
  gifExport.setRepeat(0); // make it an "endless" animation
  gifExport.setTransparent(0,0,0); // make black the transparent color. every black pixel in the animation will be transparent
  // GIF doesn't know have alpha values like processing. a pixel can only be totally transparent or totally opaque.
  // set the processing background and the transparent gif color to the same value as the gifs destination background color 
  // (e.g. the website bg-color). Like this you can have the antialiasing from processing in the gif.
}

void draw() {
  background(0);
  translate(width/2, height/2);
  rotation+=.1;
  rotateY(rotation);
  image(logo, -logo.width/2,-logo.height/2);
  gifExport.setDelay(1);
  gifExport.addFrame();
}

void keyPressed() {
  gifExport.finish();
  println("gif saved");
}
