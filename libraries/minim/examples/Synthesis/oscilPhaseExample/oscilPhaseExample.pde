/* oscilPhaseExample<br/>
   is an example of controlling the phase of an Oscil UGen inside an Instrument.
   <p>
   For more information about Minim and additional features, 
   visit http://code.compartmental.net/minim/
   <p>
   author: Damien Di Fede
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
  // we use the Line to control the phase of sineOsc
  Line sinePhase;
  // the phase we should sweep to over the duration of the note
  float phaseTarget;
  
  // constructors for this intsrument
  ToneInstrument( float frequency, float amplitude, float target )
  {    
    // create new instances of any UGen objects as necessary
    sineOsc   = new Oscil( frequency, amplitude, Waves.SINE );
    sinePhase = new Line(); 
    phaseTarget = target;
    
    // connect the LFO to the phase of sineOsc
    sinePhase.patch( sineOsc.phase );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // reset sineOsc so we don't get a click when starting the note
    sineOsc.reset();
    // sweep the sine's phase from 0 to 1
    sinePhase.activate( dur, 0, phaseTarget );
    // and patch to the output
    sineOsc.patch( out );
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    sineOsc.unpatch( out );
  }
}

// we reuse this instrument to demonstrate 
// how you can resetPhase on an Oscil to
// start notes at a zero crossing, 
// regardless of where it left off
ToneInstrument sine440;

// setup is run once at the beginning
void setup()
{  
  // initialize the drawing window
  size( 512, 200, P2D );
  
    // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 1024 );

  // initialize our steady tone. 
  // we pass in 0 for the phase target 
  // because we don't want the phase of this instrument to sweep
  sine440 = new ToneInstrument( 440.f, 0.25, 0 );
  
  // pause time when adding a bunch of notes at once
  out.pauseNotes();
  
  // we'll add four sets of two tones, 
  // sweeping the phase of one of the tones each time
  // each time we sweep the phase of the second tone 
  // to 0.5 over the duration of the note. 
  // what ends up happening is that the second 
  // tone cancels out the first as the phase becomes 
  // exactly inverted, causing it to sound like 
  // a single tone fading away to silence
  float noteTime = 0;
  for(int i = 0; i < 4; i++)
  {
    float toneDur = 2.0f + i;
    out.playNote( noteTime, toneDur, sine440 );
    out.playNote( noteTime, toneDur, new ToneInstrument(440.f, 0.25f, 0.5f) );
    
    noteTime += toneDur + 1.0f;
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
