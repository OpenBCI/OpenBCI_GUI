/*
* Demonstrates the use of the GifAnimation library.
* the left animation is looping, the one in the middle 
* plays once on mouse click and the one in the right
* is a PImage array. 
* the first two pause if you hit the spacebar.
*/

import gifAnimation.*;

PImage[] animation;
Gif loopingGif;
Gif nonLoopingGif;
boolean pause = false;

public void setup() {
  size(400, 200);
  frameRate(100);
  
  println("gifAnimation " + Gif.version());
  // create the GifAnimation object for playback
  loopingGif = new Gif(this, "lavalamp.gif");
  loopingGif.loop();
  nonLoopingGif = new Gif(this, "lavalamp.gif");
  nonLoopingGif.play();
  nonLoopingGif.ignoreRepeat();
  // create the PImage array for the interactive display
  animation = Gif.getPImages(this, "lavalamp.gif");
}

void draw() {
  background(255 / (float)height * mouseY);
  image(loopingGif, 10, height / 2 - loopingGif.height / 2);
  image(nonLoopingGif, width/2 - nonLoopingGif.width/2, height / 2 - nonLoopingGif.height / 2);
  image(animation[(int) (animation.length / (float) (width) * mouseX)], width - 10 - animation[0].width, height / 2 - animation[0].height / 2);
}

void mousePressed() {
  nonLoopingGif.play();
}

void keyPressed() {
  if (key == ' ') {
    if (pause) {
      nonLoopingGif.play();
      loopingGif.play();
      pause = false;
    } 
    else {
      nonLoopingGif.pause();
      loopingGif.pause();
      pause = true;
    }
  }
}
