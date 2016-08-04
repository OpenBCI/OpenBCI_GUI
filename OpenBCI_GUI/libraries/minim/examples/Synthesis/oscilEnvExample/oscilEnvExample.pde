/* oscilEnvExample<br/>
   is an example of using the Oscil UGen as an amplitude envelope for a note.
   <p>
   For more information about Minim and additional features, 
   visit http://code.compartmental.net/minim/
   <p>
   author: Anderson Mills<br/>
   Anderson Mills's work was supported by numediart (www.numediart.org)
*/

// import everything necessary to make sound.
import ddf.minim.*;
import ddf.minim.ugens.*;

// create all of the variables that will need to be accessed in
// more than one methods (setup(), draw(), stop()).
Minim minim;
AudioOutput out;

// BumpyInstrument is an example of using an Oscil to run through
// a wave over the course of a note being played.  This is also an
// example of creating a wave using the WavetableGenerator gen7 function.

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class BumpyInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Oscil toneOsc, envOsc;

  // constructor for this instrument  
  BumpyInstrument( String pitch, float amplitude )
  {    
    // calculate the frequency for the oscillator from the note name    
    float frequency = Frequency.ofPitch( pitch ).asHz();
    
    // create a wave for the amplitude envelope.
    // The name of the method "gen7" is a reference to a genorator in Csound.
    // This is a somewhat silly, but demonstrative wave.  It rises from 0 to 1
    // over 1/8th of the time, then goes to 0.15 over 1/8th of it's time, then
    // rises to 1 again over 1/128th of it's time, and then decays again to 0
    // for the rest of the time.  
    // Note that this envelope is of fixed shape regardless of duration.
    Wavetable myEnv = WavetableGenerator.gen7( 8192, 
        new float[] { 0.00, 1.00, 0.15, 1.00, 0.00 }, 
        new int[]   { 1024, 1024,   64, 6080 } );

    // create new instances of any UGen objects as necessary
    // The tone is the first five harmonics of a square wave.
    toneOsc = new Oscil( frequency, 1.0f, Waves.squareh( 5 ) );
    envOsc = new Oscil( 1.0f, amplitude, myEnv );
    
    // patch everything up to the output
    envOsc.patch( toneOsc.amplitude );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // the duration of the amplitude envelope is set to the length of the note
    envOsc.setFrequency( 1.0f/dur );
    // the tone ascillator is patched directly to the output.
    toneOsc.patch( out );  
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    // unpatch the tone oscillator when the note is over
    toneOsc.unpatch( out );
  }
}

// setup is run once at the beginning
void setup()
{
  // initialize the drawing window
  size( 512, 200, P2D );

  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut();

  // play several notes of different base frequencies and lengths
  // using the BumpyInstrument and its envelope
  out.playNote( 0.5, 2.6, new BumpyInstrument( "A4", 0.5 ) );
  out.playNote( 2.5, 1.6, new BumpyInstrument( "F4", 0.5 ) );
  out.playNote( 3.6, 0.9, new BumpyInstrument( "D4", 0.5 ) );
}

// draw is run many times
void draw()
{
  background( 0 );
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
