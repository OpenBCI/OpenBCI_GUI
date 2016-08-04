/* instrCommunicationExample<br/>
   is an example of two instruments communicating with each other.
   In this case, a FollowInstrument continually makes a tone.  By passing
   the name of this object to the LeaderInstrument, the LeaderInstrument can
   call one of the FollowInstrument's method.  In this case it calls the method
   that changes the frequency of the tone the Follow Instrument is playing. 
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
FollowInstrument myFollow;

// setup is run once at the beginning
void setup()
{  
  // initialize the drawing window
  size( 512, 200, P2D );
  
  // initialize the minim and out objects
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO, 2048);
  
  // Here, we need to be able to give a reference to the Follow instrument to the 
  // leader instrument, so myFollow cannot be simply new-ed in the playNote call.
  myFollow = new FollowInstrument( 0.5, 87.3, 1.0, 0.150, out ); 
  // and play myFollow for 10.6 seconds.
  out.playNote( 0.0, 10.6, myFollow );
  
  // it's nice to be able to change the volume of all LeaderInstrument notes.
  float lVol = 0.4;
  
  // Here are the calls to the LeaderInstrument.  Note the "myFollow" in the
  // parameters of the LeaderInstrument. 
  out.playNote( 1.0, 1.4, new LeaderInstrument( lVol, 174.61, myFollow, out ) );  
  out.playNote( 2.5, 0.4, new LeaderInstrument( lVol, 233.08, myFollow, out ) );  
  out.playNote( 3.0, 1.4, new LeaderInstrument( lVol, 311.13, myFollow, out ) );
  out.playNote( 4.5, 0.4, new LeaderInstrument( lVol, 293.66, myFollow, out ) );  
  out.playNote( 5.0, 0.4, new LeaderInstrument( lVol, 233.08, myFollow, out ) );
  out.playNote( 5.5, 0.4, new LeaderInstrument( lVol, 196.00, myFollow, out ) );
  out.playNote( 6.0, 0.4, new LeaderInstrument( lVol, 261.63, myFollow, out ) );
  out.playNote( 6.5, 3.0, new LeaderInstrument( lVol, 349.23, myFollow, out ) );
}

// draw is run many times
void draw()
{
  // erase the window to a shift between blue and red associated with the 
  // frequency of the FollowInstrument
  float myBG = map ( myFollow.getCurrentFrequency(), 150, 500, 0, 255 );
  background( myBG, 0, 255 - myBG );
  // draw using a green stroke
  stroke( 0, 255, 0 );
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

