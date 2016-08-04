/**
  * This sketch demonstrates how to get a channel of audio from an AudioSample 
  * and then manipulate it to change the AudioSample after it has been loaded. 
  * <p>
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  */

import ddf.minim.*;

Minim minim;
AudioSample jingle;

void setup()
{
  size(512, 200, P3D);

  minim = new Minim(this);
  
  jingle = minim.loadSample("jingle.mp3", 2048);
  // get the left channel of the audio as a float array
  // getChannel expects either AudioSample.LEFT or AudioSample.RIGHT as an argument
  float[] leftChannel = jingle.getChannel(AudioSample.LEFT);
  // now we are just going to reverse the left channel
  float[] reversed = reverse(leftChannel);
  System.arraycopy(reversed, 0, leftChannel, 0, leftChannel.length);
}

void draw()
{
  background(0);
  stroke(255);
  for(int i = 0; i < jingle.bufferSize() - 1; i++)
  {
    line(i, 50 - jingle.left.get(i)*50, i+1, 50 - jingle.left.get(i+1)*50);
    line(i, 150 - jingle.right.get(i)*50, i+1, 150 - jingle.right.get(i+1)*50);
  }
  
  text("Press any key to trigger the sample.", 10, 20);
}

void keyPressed()
{
  jingle.trigger();
}