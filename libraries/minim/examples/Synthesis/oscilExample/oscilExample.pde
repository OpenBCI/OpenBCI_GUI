/* oscilExample<br/>
   is an example of using the Oscil UGen inside an instrument.
   <p>
   For more information about Minim and additional features, visit http://code.compartmental.net/minim/
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
  AudioOutput out;
  
  // constructors for this intsrument
  ToneInstrument( float frequency, float amplitude, AudioOutput output )
  {
    // equate class variables to constructor variables as necessary 
    out = output;
    
    // create new instances of any UGen objects as necessary
    sineOsc = new Oscil( frequency, amplitude, Waves.SINE );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // and patch to the output
    sineOsc.patch( out );
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    // and unpatch the output 
    // this causes the entire instrument to stop calculating sampleframes
    // which is good when the instrument is no longer generating sound.
    sineOsc.unpatch( out );
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
  
  // initialize the myNote object as a ToneInstrument
  ToneInstrument myNote = new ToneInstrument( 587.3f, 0.9, out );
  // play a note with the myNote object
  out.playNote( 0.5, 2.6, myNote );
  // give a new note value to myNote
  myNote = new ToneInstrument( 415.3f, 0.9, out );
  // play another note with the myNote object
  out.playNote(3.5, 2.6, myNote );
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
    line( x1, 50 - out.left.get(i)*50, x2, 50 - out.left.get(i+1)*50);
    line( x1, 150 - out.right.get(i)*50, x2, 150 - out.right.get(i+1)*50);
  }  
}