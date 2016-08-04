/**
  * This sketch demonstrates how to use the <code>rewind</code> method of a <code>Playable</code> class. 
  * The class used here is <code>AudioPlayer</code>, but you can also rewind an <code>AudioSnippet</code>.
  * Rewinding a <code>Playable</code> sets the position to zero, the beginning. Rewinding doesn't change 
  * the play state of a <code>Playable</code> so if it is playing or looping when you rewind, it will 
  * continue to play or loop after you rewind it. Press 'r' to rewind the player.
  *
  */

import ddf.minim.*;

Minim minim;
AudioPlayer groove;

void setup()
{
  size(512, 200, P3D);

  minim = new Minim(this);
  groove = minim.loadFile("groove.mp3", 2048);
  groove.loop();
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
  
  float posx = map(groove.position(), 0, groove.length(), 0, width);
  stroke(0,200,0);
  line(posx, 0, posx, height);
  
  stroke(255);
  text("Press any key to rewind.", 10, 20);
}

void keyPressed()
{
  groove.rewind();
}