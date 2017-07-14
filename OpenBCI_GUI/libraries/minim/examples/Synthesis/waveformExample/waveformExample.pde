/* waveformExample<br/>
   is an example of how to construct different waveforms 
   for different tones from an oscillator.
   <p>
   For more information about Minim and additional features, visit http://code.compartmental.net/minim/
   <p>   
   author: Anderson Mills<br/>
   Anderson Mills's work is supported by numediart (www.numediart.org).
*/

// import everything necessary to make sound.
import ddf.minim.*;
import ddf.minim.ugens.*;

// create all of the variables that will need to be accessed in
// more than one method (setup(), draw()).
Minim minim;
AudioOutput out;

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class ToneInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Oscil toneOsc;
  ADSR adsr;
  AudioOutput out;
  
  // constructors for this intsrument
  ToneInstrument( String note, float amplitude, Waveform wave, AudioOutput output )
  {
    // equate class variables to constructor variables as necessary
    out = output;
    
    // make any calculations necessary for the new UGen objects
    // this turns a note name into a frequency
    float frequency = Frequency.ofPitch( note ).asHz();
    
    // create new instances of any UGen objects as necessary
    toneOsc = new Oscil( frequency, amplitude, wave );
    adsr = new ADSR( 1.0, 0.04, 0.01, 1.0, 0.1 );
 
    // patch everything together up to the final output
    toneOsc.patch( adsr );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // turn on the adsr
    adsr.noteOn();
    // patch the adsr into the output
    adsr.patch( out );
  }
  
  void noteOff()
  {
    // turn off the note in the adsr
    adsr.noteOff();
    // but don't unpatch until the release is through
    adsr.unpatchAfterRelease( out );
  }
}

// setup is run once at the beginning
void setup()
{
  // initialize the drawing window
  size( 512, 200, P2D );

  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 1024 );

  // set a volume variable
  float vol = 0.45;
  
  // From here through the end of setup() is an example of traditional 
  // composition, where every note is known completely beforehand.
  
  // set the tempo for here
  out.setTempo( 100.0f );
  // set a percentage for the actual duration
  out.setDurationFactor( 0.95f );
  // use pauseNotes to add a bunch of notes at once without time moving forward 
  out.pauseNotes();

  // specify the waveform for this group of notes
  Waveform disWave = Waves.sawh( 4 );
  // add these notes with disWave
  out.playNote( 0.0, 1.0, new ToneInstrument( "E4 ", vol, disWave, out ) );
  out.playNote( 1.0, 1.0, new ToneInstrument( "E4 ", vol, disWave, out ) );
  out.playNote( 2.0, 1.0, new ToneInstrument( "E4 ", vol, disWave, out ) );
  out.playNote( 3.0, 0.75, new ToneInstrument( "C4 ", vol, disWave, out ) );
  out.playNote( 3.75, 0.25, new ToneInstrument( "G4 ", vol, disWave, out ) );
  out.playNote( 4.0, 1.0, new ToneInstrument( "E4 ", vol, disWave, out ) );
  out.playNote( 5.0, 0.75, new ToneInstrument( "C4 ", vol, disWave, out ) );
  out.playNote( 5.75, 0.25, new ToneInstrument( "G4 ", vol, disWave, out ) );
  out.playNote( 6.0, 2.0, new ToneInstrument( "E4 ", vol, disWave, out ) );

  // specify the waveform for this group of notes
  disWave = Waves.triangleh( 9 );
  // add these notes with disWave
  out.playNote( 8.0, 1.0, new ToneInstrument( "B4 ", vol, disWave, out ) );
  out.playNote( 9.0, 1.0, new ToneInstrument( "B4 ", vol, disWave, out ) );
  out.playNote(10.0, 1.0, new ToneInstrument( "B4 ", vol, disWave, out ) );
  out.playNote(11.0, 0.75, new ToneInstrument( "C5 ", vol, disWave, out ) );
  out.playNote(11.75, 0.25, new ToneInstrument( "G4 ", vol, disWave, out ) );
  out.playNote(12.0, 1.0, new ToneInstrument( "Eb4 ", vol, disWave, out ) );
  out.playNote(13.0, 0.75, new ToneInstrument( "C4 ", vol, disWave, out ) );
  out.playNote(13.75, 0.25, new ToneInstrument( "G4 ", vol, disWave, out ) );
  out.playNote(14.0, 2.0, new ToneInstrument( "E4 ", vol, disWave, out ) );

  // specify the waveform for this group of notes
  disWave = Waves.randomNOddHarms( 3 );
  // add these notes with disWave
  out.playNote( 0.0, 1.9, new ToneInstrument( "E3 ", vol, disWave, out ) );
  out.playNote( 2.0, 1.9, new ToneInstrument( "E3 ", vol, disWave, out ) );
  out.playNote( 4.0, 1.9, new ToneInstrument( "E3 ", vol, disWave, out ) );
  out.playNote( 6.0, 1.9, new ToneInstrument( "E3 ", vol, disWave, out ) );

  // specify the waveform for this group of notes
  disWave = Waves.TRIANGLE;
  // add these notes with disWave
  out.playNote( 8.0, 1.9, new ToneInstrument( "E3 ", vol, disWave, out ) );
  out.playNote(10.0, 1.9, new ToneInstrument( "E3 ", vol, disWave, out ) );
  out.playNote(12.0, 1.9, new ToneInstrument( "C3 ", vol, disWave, out ) );
  out.playNote(14.0, 1.9, new ToneInstrument( "E3 ", vol, disWave, out ) );
    
  //-----  this is effectively a section marker
  // all notes from here until the next setNoteOffset will have this offset added to them
  out.setNoteOffset( 16.0 );
  // specify the waveform for this group of notes
  disWave = Waves.triangle( 0.75 );  
  // add these notes with disWave
  out.playNote( 0.0, 1.0, new ToneInstrument( "E5 ", vol, disWave, out ) );
  out.playNote( 1.0, 1.0, new ToneInstrument( "E4 ", vol, disWave, out ) );
  out.playNote( 2.0, 1.0, new ToneInstrument( "E5 ", vol, disWave, out ) );
  out.playNote( 3.0, 0.5, new ToneInstrument( "D#5", vol, disWave, out ) );
  out.playNote( 3.5, 0.5, new ToneInstrument( "D5 ", vol, disWave, out ) );
  out.playNote( 4.0, 0.25, new ToneInstrument( "Db5 ", vol, disWave, out ) );
  out.playNote( 4.25, 0.25, new ToneInstrument( "C5 ", vol, disWave, out ) );
  out.playNote( 4.5, 0.50, new ToneInstrument( "Db5 ", vol, disWave, out ) );
  out.playNote( 5.5, 0.5, new ToneInstrument( "F4 ", vol, disWave, out ) );
  out.playNote( 6.0, 1.0, new ToneInstrument( "Bb4 ", vol, disWave, out ) );
  out.playNote( 7.0, 0.5, new ToneInstrument( "A4 ", vol, disWave, out ) );
  out.playNote( 7.5, 0.5, new ToneInstrument( "Ab4 ", vol, disWave, out ) );

  // specify the waveform for this group of notes
  disWave = Waves.add( new float[] { 0.5, 0.5 }, Waves.triangle( 0.05 ), Waves.randomNOddHarms( 3 ) );
  // add these notes with disWave
  out.playNote( 8.0, 0.25, new ToneInstrument( "G4 ", vol, disWave, out ) );
  out.playNote( 8.25, 0.25, new ToneInstrument( "F#4 ", vol, disWave, out ) );
  out.playNote( 8.5, 0.50, new ToneInstrument( "G4 ", vol, disWave, out ) );
  out.playNote( 9.5, 0.5, new ToneInstrument( "C4 ", vol, disWave, out ) );
  out.playNote(10.0, 1.0, new ToneInstrument( "Eb4 ", vol, disWave, out ) );
  out.playNote(11.0, 0.75, new ToneInstrument( "C4 ", vol, disWave, out ) );
  out.playNote(11.75, 0.25, new ToneInstrument( "G4 ", vol, disWave, out ) );
  out.playNote(12.0, 1.0, new ToneInstrument( "E4 ", vol, disWave, out ) );
  out.playNote(13.0, 0.75, new ToneInstrument( "C4 ", vol, disWave, out ) );
  out.playNote(13.75, 0.25, new ToneInstrument( "G4 ", vol, disWave, out ) );
  out.playNote(14.0, 2.0, new ToneInstrument( "E4 ", vol, disWave, out ) );

  // specify the waveform for this group of notes
  disWave = Waves.randomNHarms( 9 );
  // add these notes with disWave
  out.playNote( 4.0, 1.9, new ToneInstrument( "Bb3 ", vol/2, disWave, out ) );
  out.playNote( 4.0, 1.9, new ToneInstrument( "F3 ", vol/2, disWave, out ) );
  out.playNote( 8.0, 1.9, new ToneInstrument( "C3 ", vol/2, disWave, out ) );
  out.playNote( 8.0, 1.9, new ToneInstrument( "Eb3 ", vol/2, disWave, out ) );
  out.playNote(10.0, 1.9, new ToneInstrument( "C3 ", vol, disWave, out ) );
  out.playNote(12.0, 1.9, new ToneInstrument( "E3 ", vol, disWave, out ) );
  out.playNote(14.0, 1.9, new ToneInstrument( "E3 ", vol, disWave, out ) );

  // use resumeNotes at the end of the section which needs guaranteed timing
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
    line( x1, 50 - out.left.get(i)*50, x2, 50 - out.left.get(i+1)*50);
    line( x1, 150 - out.right.get(i)*50, x2, 150 - out.right.get(i+1)*50);
  }  
}
