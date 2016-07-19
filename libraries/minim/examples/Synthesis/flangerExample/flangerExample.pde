/* flangerExample
   <p>
   A Flanger is a specialized kind of delay that uses an LFO (low frequency oscillator) 
   to vary the amount of delay applied to each sample. This causes a sweeping frequency 
   kind of sound as the signal reinforces or cancels itself in various ways. In particular
   the peaks and notches created in the frequency spectrum are related to each other in 
   a linear harmonic series. This causes the spectrum to look like a comb and should be
   apparent in the visualization.
   <p>
   Inputs for the Flanger are:
   <ul>
   <li>delay (in milliseconds): the minimum amount of delay applied to an incoming sample</li>
   <li>rate (in Hz): the frequency of the LFO</li>
   <li>depth (in milliseconds): the maximum amount of delay added onto delay by the LFO</li>
   <li>feedback: how much of delayed signal should be fed back into the effect</li>
   <li>dry: how much of the uneffected input should be included in the output</li>
   <li>wet: how much of the effected signal should be included in the output</li>
   </ul>
   <p>
   A more thorough description can be found on wikipedia: http://en.wikipedia.org/wiki/Flanging
   <p>
   For more information about Minim and additional features, 
   visit http://code.compartmental.net/minim/
   <p>
   Author: Damien Di Fede
*/

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.analysis.*;

Minim       minim;
AudioOutput out;
Noise       noize;
Flanger     flange;

// we render the spectrum instead of the waveform
// because this lets you really see what the Flanger is doing.
FFT         fft;

void setup()
{
  size( 512, 512 );
  
  minim = new Minim(this);
  out   = minim.getLineOut();
  
  // we use white noise to demonstrate the Flanger effect
  // because the sound of the Flanger is more 
  // pronounced when the audio being flanged 
  // has high frequency content
  noize = new Noise( Noise.Tint.WHITE );
  
  flange = new Flanger( 1,     // delay length in milliseconds ( clamped to [0,100] )
                        0.2f,   // lfo rate in Hz ( clamped at low end to 0.001 )
                        1,     // delay depth in milliseconds ( minimum of 0 )
                        0.5f,   // amount of feedback ( clamped to [0,1] )
                        0.5f,   // amount of dry signal ( clamped to [0,1] )
                        0.5f    // amount of wet signal ( clamped to [0,1] )
                       );
                        
  noize.patch( flange ).patch( out );
  
  fft = new FFT( 1024, out.sampleRate() );
}

void draw()
{
  background( 0 );
  
  stroke( 200 );
  
  fft.forward( out.mix );
  
  for( int i = 0; i < fft.specSize(); ++i )
  {
    float val = fft.getBand( i );
    line( i, height, i, height - pow ( 10.0, (0.05 * val) )*2 );
  }
  
  fill( 255 );
  
  text( "delay: " + nf( flange.delay.getLastValue(), 1, 3 ) + " ms", 5, 15 );
  text( "depth: " + nf( flange.depth.getLastValue(), 1, 3 ) + " ms", 5, 30 );
}

void mouseMoved()
{
  flange.delay.setLastValue( map( mouseX, 0,      width, 0.01, 5 ) );
  flange.depth.setLastValue( map( mouseY, height, 0,     1.00, 5 ) );
}


