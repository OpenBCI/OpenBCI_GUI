/**
  * This sketch demonstrates how to use the <code>createSample</code> method of <code>Minim</code>. 
  * The <code>createSample</code> method allows you to create an <code>AudioSample</code> by provided 
  * either one or two float arrays, which are the sound you want be able to trigger. 
  * <p>
  * See the loadSample example for more information about <code>AudioSample</code>s.
  * <p>
  * Press 't' to trigger the sample.
  * <p>
  * For more information about Minim and additional features, visit http://code.compartmental.net/minim/
  */

import ddf.minim.*;
import ddf.minim.ugens.*;
// we must import this package to create an AudioFormat object
import javax.sound.sampled.*;

Minim minim;
AudioSample wave;

void setup()
{
  size(512, 200, P3D);
  
  minim = new Minim(this);
  
  // we'll make a MONO sample, but there is also a version
  // of createSample that you can pass two float arrays to:
  // which will be used for the left and right channels
  // of a stereo sample.
  float[] samples = new float[1024*8];
  
  float waveFrequency  = 220f;
  float waveSampleRate = 44100f;
  
  // generate the sample by using Waves.SINE
  float lookUp = 0; 
  float lookUpStep = waveFrequency / waveSampleRate;
  for( int i = 0; i < samples.length; ++i )
  {
     samples[i] = Waves.SINE.value(lookUp);  
     lookUp = (lookUp + lookUpStep) % 1.0f;
  }
  
  // when we create a sample we need to provide an AudioFormat so 
  // the sound will be played back correctly.
  AudioFormat format = new AudioFormat( waveSampleRate, // sample rate
                                        16,    // sample size in bits
                                        1,     // channels
                                        true,  // signed
                                        true   // bigEndian
                                      );
                                      
  // finally, create the AudioSample
  wave = minim.createSample( samples, // the samples
                             format,  // the format
                             1024     // the output buffer size
                            );
}

void draw()
{
  background(0);
  stroke(255);
  // use the mix buffer to draw the waveforms.
  for (int i = 0; i < wave.bufferSize() - 1; i++)
  {
    line(i, 100 - wave.left.get(i)*50, i+1, 100 - wave.left.get(i+1)*50);
  }
}

void keyPressed()
{
  if ( key == 't' ) 
  {
    wave.trigger();
  }
}