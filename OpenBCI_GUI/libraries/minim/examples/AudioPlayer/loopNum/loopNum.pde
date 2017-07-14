/**
  * This sketch demonstrates how to use the <code>loop(int)</code> method of a <code>Playable</code> class. 
  * The class used here is <code>AudioPlayer</code>, but you can also loop an <code>AudioSnippet</code>.
  * When you call <code>loop(int)</code> it will make the <code>Playable</code> loop for the number of times 
  * you specify. So, <code>loop(3)</code> will loop the recording three times, which will result in the recording 
  * being played 4 times. This may seem odd, but it is consistent with the behavior of a JavaSound <code>Clip</code>.
  * If you want to make it stop looping you can call <code>play()</code> and it will finish the current loop 
  * and then stop. Press any of the number keys to make the player loop that many times. Text will be displayed 
  * on the screen indicating your most recent choice.
  *
  */

import ddf.minim.*;

Minim minim;
AudioPlayer groove;
int loopcount;

void setup()
{
  size(512, 200, P3D);

  minim = new Minim(this);
  groove = minim.loadFile("groove.mp3", 2048);
  
  textFont(createFont("Arial", 12));
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
  
  text("The player has " + groove.loopCount() + " loops left." 
     + " Is playing: " + groove.isPlaying() 
     + ", Is looping: " + groove.isLooping(), 5, 15);
}

void keyPressed()
{
  String keystr = String.valueOf(key);
  int num = int(keystr);
  if ( num > 0 && num < 10 )
  {
    groove.loop(num);
    loopcount = num;
  }    
}
