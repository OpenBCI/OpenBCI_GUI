/* midiFreqExample<br/>
   is an example of using the midi2Freq UGen to get a "musical note"
   rise instead of a linear slide.
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

// setup is run once at the beginning
void setup()
{
  // initialize the drawing window
  size(512, 200, P2D);
  
  // initialize the minim and out objects
  minim = new Minim(this);
  out = minim.getLineOut(Minim.STEREO, 2048);
  
  // pause time when adding a bunch of notes at once
  out.pauseNotes();
  
  // play a linear slide in one channel and a musical slide in the other
  // the two slides have the same start and end points, but the path between them
  // is very different
  out.playNote(0.25, 5.5, new SlideInstrument(110, 880, 0.8 ) );
  out.playNote(0.25, 5.5, new MidiSlideInstrument(45.0, 81.0, 0.8 ));
  
  // replay the slide faster and alternating between the two types.
  out.playNote( 6.00, 0.2, new SlideInstrument( 110, 880, 0.8 ) );
  out.playNote( 6.25, 0.2, new MidiSlideInstrument( 45.0, 81.0, 0.8 ) );
  out.playNote( 6.50, 0.2, new SlideInstrument( 110, 880, 0.8 ) );
  out.playNote( 6.75, 0.2, new MidiSlideInstrument( 45.0, 81.0, 0.8 ) );
  out.playNote( 7.00, 0.2, new SlideInstrument( 110, 880, 0.8 ) );
  out.playNote( 7.25, 0.2, new MidiSlideInstrument( 45.0, 81.0, 0.8 ) );
  out.playNote( 7.50, 0.2, new SlideInstrument( 110, 880, 0.8 ) );
  out.playNote( 7.75, 0.2, new MidiSlideInstrument( 45.0, 81.0, 0.8 ) );
  
  // resume time for adding notes
  out.resumeNotes();  
}

// draw is run many times
void draw()
{
  // erase the window to brown
  background( 64, 32, 0 );
  // draw using a beige stroke
  stroke( 255, 238, 192 );
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
