/**
  * This sketch demonstrates how to use the <code>pause</code> method of a <code>Playable</code> class. 
  * The class used here is <code>AudioPlayer</code>, but you can also pause an <code>AudioSnippet</code>.
  * Pausing a <code>Playable</code> causes it to cease playback but not change position, so that when you 
  * resume playback it will start from where you last paused it. Press 'p' to pause the player.
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
}

void keyPressed()
{
  if ( groove.isPlaying() )
  {
    groove.pause();
  }
  else
  {
    // simply call loop again to resume playing from where it was paused
    groove.loop();
  }
}