/**
  * This sketch demonstrates how to use an EnvelopeFollower, which will 
  * analyze the audio coming into it and output a value that reflects 
  * the volume level of that audio. It is similar to what AudioBuffer's 
  * level method provides, but has the advantage of being able to be 
  * inserted into the signal chain anywhere.
  * <p>
  * This sketch also demonstrates using a Sink UGen, which can have 
  * many UGens patched to it, like a Summer, but that generates silence.
  * It is used here because we need a way to tick the EnvelopeFollower
  * but we are not interested in hearing the output of the EnvelopeFollower.
  * <p>
  * For more information about Minim and additional features,<br/>
  * visit http://code.compartmental.net/minim/
  */

import ddf.minim.*;
import ddf.minim.ugens.*;

Minim             minim;
AudioOutput       out;
Oscil             wave;
Oscil             mod;
EnvelopeFollower envFollow;

void setup()
{
  size(512, 200, P3D);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  // create a triangle wave Oscil, set to 440 Hz, at 1.0 amplitude
  // in this case, the amplitude we construct the Oscil with 
  // doesn't matter because we will be patching something to
  // its amplitude input.
  wave = new Oscil( 440, 1.0f, Waves.TRIANGLE );
 
  // create a sine wave Oscil for modulating the amplitude of wave
  mod  = new Oscil( 2, 0.4f, Waves.SINE );
 
  // connect up the modulator
  mod.patch( wave.amplitude );
  
  // patch wave to the output
  wave.patch( out );
  
  // now create an envelope follower to show the level of the wave
  
  envFollow = new EnvelopeFollower( 0,   // attack time in seconds
                                    0.1, // release time in seconds
                                    1024 // size of buffer to analyze 
                                  );
  
  // a sink to tick the envelope follower because 
  // we won't use the output of it in the signal chain
  Sink sink = new Sink();
  wave.patch( envFollow ).patch( sink ).patch( out );
}

void draw()
{
  // adjust the modulator amplitude based on mouseY
  // this should mean that when the modulator has 
  // a high amplitude that the envelope follower 
  // will report a larger range of values
  float amp = constrain( map( mouseY, 0, height, 1, 0), 0, 1 );
  mod.amplitude.setLastValue( amp );
  
  // and we can connect the frequency of modulation to mouseX
  // and see the result of that in the follower, as well
  float freq = constrain( map( mouseX, 0, width, 0.1, 1 ), 0.1, 1 );
  mod.frequency.setLastValue( freq );
  
  background(0);
  stroke(0);
  fill(255);
  
  // draw the output of the envelope follower
  float h = envFollow.getLastValues()[0] * height;
  rect( 0, height - h, width, height );
}
