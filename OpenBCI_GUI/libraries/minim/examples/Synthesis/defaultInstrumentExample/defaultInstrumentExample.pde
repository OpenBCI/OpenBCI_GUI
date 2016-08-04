/* defaultInstrumentExample<br/>
   is an example of using the extremely simple default
   instrument built into Minim.  The following is intended
   to be pretty much the minimum necessary to use the default
   instrument.
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

AudioOutput out;

void setup()
{
  // initialize the drawing window
  size(512, 200, P2D);
  
  Minim minim = new Minim( this );
  out = minim.getLineOut();
  
  // given start time, duration, and frequency
  out.playNote( 0.0, 0.9, 97.99 );
  out.playNote( 1.0, 0.9, 123.47 );
  
  // given start time, duration, and note name  
  out.playNote( 2.0, 2.9, "C3" );
  out.playNote( 3.0, 1.9, "E3" );
  out.playNote( 4.0, 0.9, "G3" );
    
  // given start time and note name or frequency
  // (duration defaults to 1.0)
  out.playNote( 5.0, "" );
  out.playNote( 6.0, 329.63);
  out.playNote( 7.0, "G4" );
  
  // set a note offset  
  out.setNoteOffset( 8.1 );
  
  // because only given a note name or frequency
  // starttime defaults to 0.0 and duration defaults to 1.0
  out.playNote( "G5" );
  out.playNote( 987.77 );
}

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