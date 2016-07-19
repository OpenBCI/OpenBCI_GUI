/* constantExample<br/>
   is an example of using a Constant UGen to control the frequency of an Oscil.
   You can patch a Constant UGen into any input of any other UGen, which gives you
   an easy way of interactively controlling that input. In this case, you move 
   the mouse left and right to change the frequency of the oscillator. You'll hear the 
   frequency "stair step" because we don't smoothly change the value, we simply set it
   every frame.
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
Constant freqControl;

void setup()
{
  // initialize the drawing window
  size(512, 200, P2D);
  
  // initialize the minim and out objects
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO, 2048);
    
  // make our Oscil, which we'll simply patch to the output
  // arguments are frequency, amplitude and waveform
  Oscil osc = new Oscil( 220.f, 0.5f, Waves.SINE );
  // make a constant UGen that starts with the same value 
  // that we used for the frequency of osc. however, 
  // we are going to change this value over time
  // using mouseX.
  freqControl = new Constant(220.f);
  // patch it directly to the frequency of the Oscil
  freqControl.patch( osc.frequency );
  
  // and connect the oscil to the output
  osc.patch(out);
  
}

// draw is run many times
void draw()
{
  // set the value of our Constant UGen based on mouse position
  float freq = map(mouseX, 0, width, 220.f, 880.f);
  freqControl.setConstant( freq );
  
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

