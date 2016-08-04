/* liveInputExample<br/>
   is an example of using a Vocoder UGen on a LiveInput UGen.
   This should let you hear the input from your microphone turned into a robot voice.
   <p>
   For more information about Minim and additional features, 
   visit http://code.compartmental.net/minim/
   <p>
   author: Damien Di Fede
*/

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.spi.*; // for AudioStream

Minim minim;
AudioOutput out;
LiveInput in;

void setup()
{
  // initialize the drawing window
  size(512, 200);
  
  // initialize the minim and out objects
  minim = new Minim(this);
  out = minim.getLineOut();
  
  // construct a LiveInput by giving it an InputStream from minim.
  // we ask for an input with the same audio properties as the output.
  AudioStream inputStream = minim.getInputStream( Minim.MONO, 
                                                  out.bufferSize(), 
                                                  out.sampleRate(), 
                                                  out.getFormat().getSampleSizeInBits()
                                                 );
  in = new LiveInput( inputStream );
  
  // create the vocoder with a 1024 sample frame FFT and 3 overlapping windows
  Vocoder vocode = new Vocoder( 1024, 8 );
  
  // patch the input into the vocoder modulator
  // we want to modulate the synth sound with the mic input, to create that "robot" effect
  in.patch( vocode.modulator );
  
  // create a synth with two notes an octave apart
  Oscil wave1 = new Oscil( 110, 0.8, Waves.SAW ); 
  Oscil wave2 = new Oscil( 220, 0.4, Waves.SAW );
  
  Summer synth = new Summer();
  wave1.patch( synth );
  wave2.patch( synth );
  
  // patch it to the input on the vocoder and on to the output 
  synth.patch( vocode ).patch( out );
}

// draw is run many times
void draw()
{
  // erase the window to black
  background( 0 );
  // draw using a white stroke
  stroke( 255 );
  // draw the waveforms
  for( int i = 0; i < out.bufferSize() - 1; i++ )
  {
    // find the x position of each buffer value
    float x1  =  map( i, 0, out.bufferSize(), 0, width );
    float x2  =  map( i+1, 0, out.bufferSize(), 0, width );
    // draw a line from one buffer position to the next for both channels
    line( x1, 50  - out.left.get(i)*50,  x2, 50  - out.left.get(i+1)*50);
    line( x1, 150 - out.right.get(i)*50, x2, 150 - out.right.get(i+1)*50);
  }  
}
