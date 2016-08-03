/* realtimeControlExample<br/>
   is an example of doing realtime control with an instrument
   <p>
   For more information about Minim and additional features, visit http://code.compartmental.net/minim/
   <p>   
   author: Anderson Mills<br/>
   Anderson Mills's work was supported by numediart (www.numediart.org)
*/

// import everything necessary to make sound.
import ddf.minim.*;
import ddf.minim.ugens.*;
// this time we also need effects because the filters are there for this release
import ddf.minim.effects.*;

// create all of the variables that will need to be accessed in
// more than one methods (setup(), draw(), stop()).
Minim minim;
AudioOutput out;
NoiseInstrument myNoise;

// setup is run once at the beginning
void setup()
{
  // initialize the drawing window
  size( 500, 500, P2D );

  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 512 );
  // need to initialize the myNoise object   
  myNoise = new NoiseInstrument( 1.0, out );
  
  // play the note for 100.0 seconds
  out.playNote( 0, 100.0, myNoise );
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

// this is run whenever the mouse is moved
void mouseMoved()
{
  // map the position of the mouse to useful values
  float freq = map( mouseY, 0, height, 1500, 150 );
  float q = map( mouseX, 0, width, 0.9, 100 );
  // and call the methods of the instrument to change the sound
  myNoise.setFilterCF( freq );
  myNoise.setFilterQ( q );
}
