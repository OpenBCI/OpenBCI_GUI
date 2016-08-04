/**
  * This sketch demonstrates how to use the <code>loop</code> method of a <code>Playable</code> class. 
  * The class used here is <code>AudioPlayer</code>, but you can also loop an <code>AudioSnippet</code>.
  * When you call <code>loop()</code> it will make the <code>Playable</code> playback in an infinite loop.
  * If you want to make it stop looping you can call <code>play()</code> and it will finish the current loop 
  * and then stop. Press 'l' to start the player looping.
  *
  */

import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer groove;

void setup()
{
  size(512, 200, P3D);

  minim = new Minim(this);
  groove = minim.loadFile("groove.mp3", 2048);
}

void draw()
{
  background(0);
  
  stroke(255);
  
  for(int i = 0; i < groove.bufferSize() - 1; i++)
  {
    line(i, 50  + groove.left.get(i)*50,  i+1, 50  + groove.left.get(i+1)*50);
    line(i, 150 + groove.right.get(i)*50, i+1, 150 + groove.right.get(i+1)*50);
  }
}

void keyPressed()
{
  if ( key == 'l' ) groove.loop();
}