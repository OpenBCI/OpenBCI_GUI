/* panExample<br/>
   is an example of using the Pan UGen inside an Instrument.
   The Instrument is designed to play a single tone that is panned 
   back and forth across the stereo field based on the value of a 
   low frequency oscillator (LFO). An LFO is simply an Oscil that 
   has a frequency that is usually well below audible range.
   <p>
   This sketch uses the Instrument to play two notes, one which 
   slowly pans back and forth across the entire stereo field (-1, 1)
   and one which more quickly pans back and forth between a 
   smaller range.
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

// define a PanInstrument that implements the Instrument interface
// so that we can use instances of it with playNote
class PanInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Oscil sineOsc, LFO;
  Pan pan;
  
  // constructors for this intsrument
  PanInstrument( float oscFrequency, float oscAmplitude, float lfoFrequency, float lfoAmplitude )
  {    
    // create new instances of any UGen objects as necessary
    sineOsc = new Oscil( oscFrequency, oscAmplitude, Waves.SINE );
    
    // the arguments to the Pan UGen are for the balance and width.
    // balance ranges from -1 to 1, which basically are hard-left and 
    // hard-right, respectively.
    // we create our pan with 0 because we will drive the value of 
    // the balance using Pan's balance UGenInput.
    pan = new Pan(0);
    
    // LFO stands for low frequency oscillator. we will use this to control
    // the balance input of the Pan Ugen.
    LFO = new Oscil( lfoFrequency, lfoAmplitude, Waves.SINE );
        
    // patch everything together up to the final output
    sineOsc.patch( pan );
    LFO.patch( pan.pan );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // and patch to the output
    pan.patch( out );
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    // and unpatch the output 
    // this causes the entire instrument to stop calculating sampleframes
    // which is good when the instrument is no longer generating sound.
    pan.unpatch( out );
  }
}

// setup is run once at the beginning
void setup()
{
  // initialize the drawing window
  size( 512, 200, P2D );
  
  // initialize the minim and out objects
  minim = new Minim( this );
  // because we are using a Pan UGen, we need a stereo output.
  out = minim.getLineOut( Minim.STEREO, 1024 );
  
  // initialize the myNote object as a PanInstrument
  PanInstrument myNote = new PanInstrument( 587.3f, 0.5, 0.5, 1.0 );
  
  // play a note with the myNote object
  out.playNote( 0.5, 2.6, myNote );
  
  // give a new note value to myNote
  myNote = new PanInstrument( 415.3f, 0.5, 3.0, 0.5 );
  
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
    line( x1, 50 + out.left.get(i)*50, x2, 50 + out.left.get(i+1)*50);
    line( x1, 150 + out.right.get(i)*50, x2, 150 + out.right.get(i+1)*50);
  }  
}
