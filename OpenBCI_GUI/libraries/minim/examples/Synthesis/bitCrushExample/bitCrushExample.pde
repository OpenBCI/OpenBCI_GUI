/* bitCrushExample<br/>
 * This is an example of using a BitCrush UGen to modify the sound of an Oscil.
 * <p>
 * For more information about Minim and additional features, 
 * visit http://code.compartmental.net/minim/
 */

import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;

// this CrushInstrument will play a sine wave bit crushed
// to a certain bit resolution. this results in the audio sounding
// "crunchier".
class CrushInstrument implements Instrument
{
  Oscil sineOsc;
  BitCrush bitCrush;
  
  CrushInstrument(float frequency, float amplitude, float bitRes)
  {
    sineOsc = new Oscil(frequency, amplitude, Waves.SINE);
    
    // BitCrush takes the bit resolution for an argument
    bitCrush = new BitCrush(bitRes, out.sampleRate());
    
    sineOsc.patch(bitCrush);
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn(float dur)
  {
    bitCrush.patch(out);
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    bitCrush.unpatch(out);
  }
}

// this CrushingInstrument will play a sine wave and then change the bit resulution of the BitCrush
// over time, based on a starting and ending resolution passed in.
class CrushingInstrument implements Instrument
{
  Oscil sineOsc;
  BitCrush bitCrush;
  Line crushLine;
  
  CrushingInstrument(float frequency, float amplitude, float hiBitRes, float loBitRes)
  {
    sineOsc = new Oscil(frequency, amplitude, Waves.SINE);
    bitCrush = new BitCrush(hiBitRes, out.sampleRate());
    crushLine = new Line(9.0, hiBitRes, loBitRes);
    
    // our Line will control the resolution of the bit crush
    crushLine.patch(bitCrush.bitRes);
    // patch the osc through the bit crush
    sineOsc.patch(bitCrush);
  }
  
  // called by the note manager when this instrument should play
  void noteOn(float dur)
  {
    // patch the bit crush to the output and active our Line when we want to have the note play
    crushLine.activate();
    bitCrush.patch(out);
  }
  
  // called by the note manager when this instrument should stop playing
  void noteOff()
  {
    // unpatch from the output to stop making sound
    bitCrush.unpatch(out);
  }
}

void setup()
{
  // initialize the drawing window
  size( 512, 200, P2D );

  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO );
  
  // queue up some notes using the Crush Instrument
  // its arguments are sine wave frequency, amplitude, and bit crush resolution
  out.playNote(0.5, 2.6, new CrushInstrument( 392.0, 0.5, 16.0) );
  out.playNote(3.5, 2.6, new CrushInstrument( 370.0, 0.5, 4.0) );
  out.playNote(6.5, 2.6, new CrushInstrument( 261.6, 0.5, 3.0) );
  out.playNote(9.5, 2.6, new CrushInstrument( 247.0, 0.5, 2.0) );
  
  // queue up a Crushing Instrument, which will change the bit resolution over time
  // its arguments are sine frequency, amplitude, bit crush resolution start and end
  out.playNote(12.5, 10.0, new CrushingInstrument( 191.0, 0.5, 5.2, 1.0 ) );
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
    line( x1, 50 + out.left.get(i)*50, x2, 50 + out.left.get(i+1)*50);
    line( x1, 150 + out.right.get(i)*50, x2, 150 + out.right.get(i+1)*50);
  }  
}
