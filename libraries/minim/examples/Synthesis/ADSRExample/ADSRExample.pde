/* ADSRExample<br/>
   is an example of using the ADSR envelope within an instrument.
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

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class ToneInstrument implements Instrument
{
  // create all variables that must be used througout the class
  Oscil sineOsc;
  ADSR  adsr;
  
  // constructor for this instrument
  ToneInstrument( float frequency, float amplitude )
  {    
    // create new instances of any UGen objects as necessary
    sineOsc = new Oscil( frequency, amplitude, Waves.TRIANGLE );
    adsr = new ADSR( 0.5, 0.01, 0.05, 0.5, 0.5 );
    
    // patch everything together up to the final output
    sineOsc.patch( adsr );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // turn on the ADSR
    adsr.noteOn();
    // patch to the output
    adsr.patch( out );
   }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    // tell the ADSR to unpatch after the release is finished
    adsr.unpatchAfterRelease( out );
    // call the noteOff 
    adsr.noteOff();
  }
}

// setup is run once at the beginning
void setup()
{
  // initialize the drawing window
  size( 512, 200, P2D );

  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );
  
  // pause time when adding a bunch of notes at once
  out.pauseNotes();
  
  // make four repetitions of the same pattern
  for( int i = 0; i < 4; i++ )
  {
    // add some low notes
    out.playNote( 1.25 + i*2.0, 0.3, new ToneInstrument( 75, 0.49 ) );
    out.playNote( 2.50 + i*2.0, 0.3, new ToneInstrument( 75, 0.49 ) );
    
    // add some middle notes
    out.playNote( 1.75 + i*2.0, 0.3, new ToneInstrument( 175, 0.4 ) );
    out.playNote( 2.75 + i*2.0, 0.3, new ToneInstrument( 175, 0.4 ) );
    
    // add some high notes
    out.playNote( 1.25 + i*2.0, 0.3, new ToneInstrument( 3750, 0.07 ) );
    out.playNote( 1.5 + i*2.0, 0.3, new ToneInstrument( 1750, 0.02 ) );
    out.playNote( 1.75 + i*2.0, 0.3, new ToneInstrument( 3750, 0.07 ) );
    out.playNote( 2.0 + i*2.0, 0.3, new ToneInstrument( 1750, 0.02 ) );
    out.playNote( 2.25 + i*2.0, 0.3, new ToneInstrument( 3750, 0.07 ) );
    out.playNote( 2.5 + i*2.0, 0.3, new ToneInstrument( 5550, 0.09 ) );
    out.playNote( 2.75 + i*2.0, 0.3, new ToneInstrument( 3750, 0.07 ) );
  }
  // resume time after a bunch of notes are added at once
  out.resumeNotes();
  
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
