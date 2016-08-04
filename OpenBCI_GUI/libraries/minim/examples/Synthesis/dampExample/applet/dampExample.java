import processing.core.*; 
import processing.xml.*; 

import ddf.minim.*; 
import ddf.minim.ugens.*; 

import java.applet.*; 
import java.awt.*; 
import java.awt.image.*; 
import java.awt.event.*; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class dampExample extends PApplet {

/* dampExample
   is an example of using the Damp UGen inside an instrument.
   
   author: Anderson Mills
   Anderson Mills's work was supported by numediart (www.numediart.org)
*/

// import everything necessary to make sound.



// create all of the variables that will need to be accessed in
// more than one methods (setup(), draw(), stop()).
Minim minim;
AudioOutput out;

// setup is run once at the beginning
public void setup()
{
  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );
  
  // initialize the drawing window
  size( 512, 200, P2D );
  
  // pause time when adding a bunch of notes at once
  out.pauseNotes();
  
  // one can add an offset to all notes until the next noteOffset
  out.setNoteOffset( 2f );

  // one can set the tempo of the piece in beats per minute, too
  out.setTempo( 130f );

  for( int i = 0; i < 4; i++ )
  {
    // low notes
    out.playNote( 0.00f + i*4.0f, 1.0f, new ToneInstrument( 80, 0.5f, out ) );
    out.playNote( 1.75f + i*4.0f, 0.2f, new ToneInstrument( 80, 0.4f, out ) );
    // two extra low notes every other pattern
    if (( 0 == i ) || ( 2 == i ) )
    {
      out.playNote( 2.50f + i*4.0f, 0.5f, new ToneInstrument( 79, 0.3f, out ) );
      out.playNote( 3.50f + i*4.0f, 0.2f, new ToneInstrument( 81, 0.4f, out ) );
    }
    // middle notes
    out.playNote( 1.00f + i*4.0f, 0.4f, new ToneInstrument( 161, 0.3f, out ) );
    out.playNote( 3.00f + i*4.0f, 0.4f, new ToneInstrument( 158, 0.3f, out ) );
    
    // high notes
    out.playNote( 0.00f + i*4.0f, 0.2f, new ToneInstrument( 1610, 0.03f, out ) );
    out.playNote( 0.50f + i*4.0f, 0.2f, new ToneInstrument( 2010, 0.03f, out ) );
    out.playNote( 0.75f + i*4.0f, 0.3f, new ToneInstrument( 1650, 0.09f, out ) );
    out.playNote( 1.00f + i*4.0f, 0.6f, new ToneInstrument( 1610, 0.09f, out ) );
    out.playNote( 1.25f + i*4.0f, 0.1f, new ToneInstrument( 2010, 0.03f, out ) );
    out.playNote( 1.50f + i*4.0f, 0.5f, new ToneInstrument( 1610, 0.06f, out ) );

    // two extra high notes every other pattern
    if (( 1 == i ) || ( 3 == i ) )
    {
      out.playNote( 3.50f + i*4.0f, 0.1f, new ToneInstrument( 3210, 0.06f, out ) );
      out.playNote( 3.75f + i*4.0f, 0.5f, new ToneInstrument( 2010, 0.09f, out ) );
    }  
    
  }
  // resume time after a bunch of notes are added at once
  out.resumeNotes();
}

// draw is run many times
public void draw()
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

// stop is run when the user presses stop
public void stop()
{
  // close the AudioOutput
  out.close();
  // stop the minim object
  minim.stop();
  // stop the processing object
  super.stop();
}
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
    damp = new Damp( 0.001f, 1.0f );
    
    // patch everything together up to the final output
    sineOsc.patch( damp );
  }
  
  // every instrument must have a noteOn( float ) method
  public void noteOn(float dur)
  {
    // set the damp time from the duration given to the note
    damp.setDampTimeFromDuration( dur );
    // activate the damp
    damp.activate();
    // and finally patch the damp to the output
    damp.patch( out );
  }
  
  // every instrument must have a noteOff() method
  public void noteOff()
  {
    // the damp time of a damp can be changed after damp has been started,
    // so unpatching after the entire damp is over is useful.
    damp.unpatchAfterDamp( out );
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "dampExample" });
  }
}
