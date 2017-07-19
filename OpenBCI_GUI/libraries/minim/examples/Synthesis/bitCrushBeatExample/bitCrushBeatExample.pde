/* bitCrushBeatExample
   <p>
   this is an example of how to use BitCrush. the kick and snare instruments are both
   patched through a Summer, which patches to a single BitCrush UGen. We then change 
   the bit resolution over time to slowly crush the beat.
   <p>
   For more information about Minim and additional features, visit http://code.compartmental.net/minim/
   <p>
   author: Damien Di Fede
*/

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*; // for BandPass

Minim minim;
// we use a summer as the thing that our instruments patch to
// so that we can patch the summer to a single BitCrush and
// have an effect that applies to everything going to our output.
Summer sum;
// the bit crush effect we'll apply to our beat
BitCrush bitCrush;
// the line that controls the bit rate of the bit crush
Line bitRateLine;

AudioOutput out;

void setup()
{
  // initialize the drawing window
  size( 512, 200, P2D );

  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO );
  
  // make our summer and bit crush ugens
  sum = new Summer();
  bitCrush = new BitCrush(16.f, out.sampleRate());
  
  // we're going to do 4 measures of 120 bpm, so that's 8 seconds.
  // we'll just ramp from half the sample rate to 100  Hz  
  bitRateLine = new Line(8.f, out.sampleRate()*0.25f, 100 );
 
  // connect the line to the bit crush resolution
  bitRateLine.patch( bitCrush.bitRate );
  
  // set up our signal chain
  sum.patch( bitCrush ).patch( out );
  
  // pause time when adding a bunch of notes at once
  out.pauseNotes();
  
  // we set the tempo of the output so that the time and duration arguments
  // of playNote now are expressed in beats
  out.setTempo( 120.f );
  
  // here's our beat that we do four measures of.
  float kickDur = 0.8;
  float snareDur = 0.2;
  for(int i = 0; i < 4; i++)
  {
    // we set the note offset so that each loop we are queuing up a new measure
    out.setNoteOffset( i * 4 );
    
    out.playNote( 0, kickDur, new KickInstrument( sum ) );
    
    out.playNote( 1, snareDur, new SnareInstrument( sum ) );
    out.playNote( 1.5, kickDur, new KickInstrument( sum ) );
    
    out.playNote( 2.5, kickDur, new KickInstrument( sum ) );
    
    out.playNote( 3, snareDur, new SnareInstrument( sum ) );
    out.playNote( 3.5, snareDur, new SnareInstrument( sum ) );
    
    // every other measure give a little kick at the end
    if ( i % 2 == 1 )
    {
      out.playNote( 3.75, 0.1, new KickInstrument( sum ) );
    }
  }
  
  // activate the line and unpause the output!
  bitRateLine.activate();
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

