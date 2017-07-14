/* dampExample<br/>
   is an example of using the Damp UGen inside an instrument.
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
  // create all variables that must be used throughout the class
  Oscil sineOsc;
  Damp  damp;
  AudioOutput out;

  // constructors for this instrument  
  ToneInstrument(float frequency, float amplitude, AudioOutput output)
  {
    // equate class variables to constructor variables as necessary
    out = output;
    
    // create new instances of the UGen objects for this instrument
    sineOsc = new Oscil( frequency, amplitude, Waves.TRIANGLE );
    damp = new Damp( 0.001, 1.0 );
    
    // patch everything together up to the final output
    sineOsc.patch( damp );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn(float dur)
  {
    // set the damp time from the duration given to the note
    damp.setDampTimeFromDuration( dur );
    // activate the damp
    damp.activate();
    // and finally patch the damp to the output
    damp.patch( out );
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    // the damp time of a damp can be changed after damp has been started,
    // so unpatching after the entire damp is over is useful.
    damp.unpatchAfterDamp( out );
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
  
  // one can add an offset to all notes until the next noteOffset
  out.setNoteOffset( 2f );

  // one can set the tempo of the piece in beats per minute, too
  out.setTempo( 130f );

  for( int i = 0; i < 4; i++ )
  {
    // low notes
    out.playNote( 0.00 + i*4.0, 1.0, new ToneInstrument( 80, 0.5, out ) );
    out.playNote( 1.75 + i*4.0, 0.2, new ToneInstrument( 80, 0.4, out ) );
    // two extra low notes every other pattern
    if (( 0 == i ) || ( 2 == i ) )
    {
      out.playNote( 2.50 + i*4.0, 0.5, new ToneInstrument( 79, 0.3, out ) );
      out.playNote( 3.50 + i*4.0, 0.2, new ToneInstrument( 81, 0.4, out ) );
    }
    // middle notes
    out.playNote( 1.00 + i*4.0, 0.4, new ToneInstrument( 161, 0.3, out ) );
    out.playNote( 3.00 + i*4.0, 0.4, new ToneInstrument( 158, 0.3, out ) );
    
    // high notes
    out.playNote( 0.00 + i*4.0, 0.2, new ToneInstrument( 1610, 0.03, out ) );
    out.playNote( 0.50 + i*4.0, 0.2, new ToneInstrument( 2010, 0.03, out ) );
    out.playNote( 0.75 + i*4.0, 0.3, new ToneInstrument( 1650, 0.09, out ) );
    out.playNote( 1.00 + i*4.0, 0.6, new ToneInstrument( 1610, 0.09, out ) );
    out.playNote( 1.25 + i*4.0, 0.1, new ToneInstrument( 2010, 0.03, out ) );
    out.playNote( 1.50 + i*4.0, 0.5, new ToneInstrument( 1610, 0.06, out ) );

    // two extra high notes every other pattern
    if (( 1 == i ) || ( 3 == i ) )
    {
      out.playNote( 3.50 + i*4.0, 0.1, new ToneInstrument( 3210, 0.06, out ) );
      out.playNote( 3.75 + i*4.0, 0.5, new ToneInstrument( 2010, 0.09, out ) );
    }  
    
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
