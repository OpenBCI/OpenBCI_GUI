/**
  * This sketch demonstrates how to use the AudioBuffer objects of an AudioPlayer 
  * to draw the waveform and level of the sound as it is playing. These same 
  * AudioBuffer objects are available on AudioInput, AudioOuput, and AudioSample,
  * so they same drawing code will work in those cases.
  *
  */

import ddf.minim.*;

Minim minim;
AudioPlayer groove;

void setup()
{
  size(1024, 200);

  minim = new Minim(this);
  groove = minim.loadFile("groove.mp3", 1024);
  groove.loop();
}

void draw()
{
  background(0);
  
  stroke( 255 );
  
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  // note that if the file is MONO, left.get() and right.get() will return the same value
  for(int i = 0; i < groove.bufferSize() - 1; i++)
  {
    float x1 = map( i, 0, groove.bufferSize(), 0, width );
    float x2 = map( i+1, 0, groove.bufferSize(), 0, width );
    line( x1, 50 + groove.left.get(i)*50, x2, 50 + groove.left.get(i+1)*50 );
    line( x1, 150 + groove.right.get(i)*50, x2, 150 + groove.right.get(i+1)*50 );
  }
  
  noStroke();
  fill( 255, 128 );
  
  // the value returned by the level method is the RMS (root-mean-square) 
  // value of the current buffer of audio.
  // see: http://en.wikipedia.org/wiki/Root_mean_square
  rect( 0, 0, groove.left.level()*width, 100 );
  rect( 0, 100, groove.right.level()*width, 100 );
}
