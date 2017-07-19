/* bypassExample<br/>
 * is an example of using the Bypass UGen in a continuous sound example.
 * Press the space bar to activate and deactivate the Bypass.
 * <p>
 * For more information about Minim and additional features, 
 * visit http://code.compartmental.net/minim/
 * <p>
 * author: Anderson Mills<br/>
 * Anderson Mills's work was supported by numediart (www.numediart.org)
 */

// import everything necessary to make sound.
import ddf.minim.*;
import ddf.minim.ugens.*;

// create all of the variables that will need to be accessed in
// more than one methods (setup(), draw(), stop()).
Minim         minim;
AudioOutput   out;
// the type in the angle brackets lets the program
// know the type that should be returned by the ugen method of Bypass
Bypass<Delay> bypassedDelay;

// setup is run once at the beginning
void setup()
{
  // initialize the drawing window
  size( 512, 200, P2D );

  // initialize the minim and out objects
  minim = new Minim(this);
  out = minim.getLineOut( Minim.MONO, 2048 );
  
  // initialize myDelay with continual feedback and no audio passthrough
  Delay myDelay = new Delay( 0.6, 0.9, true, true );
  
  // create a Bypass to wrap the Delay so we can turn it on and off
  bypassedDelay = new Bypass<Delay>( myDelay );
  
  // create the Blip that will be used
  Oscil myBlip = new Oscil( 245.0, 0.3, Waves.saw( 15 ) );
  
  // create an LFO to be used for an amplitude envelope
  Oscil myLFO = new Oscil( 1, 0.3, Waves.square( 0.95 ) );
  // offset the center value of the LFO so that it outputs 0 
  // for the long portion of the duty cycle
  myLFO.offset.setLastValue( 0.3f );

  myLFO.patch( myBlip.amplitude );
  
  // and the Blip is patched through the Bypass into the Summer.
  myBlip.patch( bypassedDelay ).patch( out );
}

// draw is run many times
void draw()
{
  // erase the window to dark grey
  background( 64 );
  // draw using a light gray stroke
  stroke( 192 );
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
  
  if ( bypassedDelay.isActive() )
  {
    text( "The Delay effect is bypassed.", 10, 15 );
  }
  else
  {
    text( "The Delay effect is active.", 10, 15 );
  } 
}

void keyPressed()
{
  if ( key == ' ' )
  {
    if ( bypassedDelay.isActive() ) 
    {
      bypassedDelay.deactivate();
    }
    else
    {
      bypassedDelay.activate();
    }
  }
}

// when the mouse is moved, change the delay parameters
void mouseMoved()
{
  // set the delay time by the horizontal location
  float delayTime = map( mouseX, 0, width, 0.0001, 0.5 );
  bypassedDelay.ugen().setDelTime( delayTime );
  
  // set the feedback factor by the vertical location
  float feedbackFactor = map( mouseY, 0, height, 0.0, 0.99 );
  bypassedDelay.ugen().setDelAmp( feedbackFactor );
}
