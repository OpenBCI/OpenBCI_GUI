/* moogFilterExample<br/>
 * is an example of using a MoogFilter to filter white noise.<br/> 
 * Use the mouse to control the cutoff frequency and resonance of the filter.<br/>
 * Press 1 to set it to low pass<br/>
 * Press 2 to set it to high pass<br/>
 * Press 3 to set it to band pass<br/>
 * <p>
 * For more information about Minim and additional features, 
 * visit http://code.compartmental.net/minim/
 * <p> 
 * author: Damien Di Fede
 */

// import everything necessary to make sound.
import ddf.minim.*;
import ddf.minim.ugens.*;

// create all of the variables that will need to be accessed in
// more than one methods (setup(), draw(), stop()).
Minim       minim;
AudioOutput out;
MoogFilter  moog;

// setup is run once at the beginning
void setup()
{
// initialize the drawing window
  size(300, 300);
  
  // initialize the minim and out objects
  minim   = new Minim(this);
  out     = minim.getLineOut();
  // construct a law pass MoogFilter with a 
  // cutoff frequency of 1200 Hz and a resonance of 0.5
  moog    = new MoogFilter( 1200, 0.5 );
  
  // we will filter a white noise source,
  // which will allow us to hear the result of filtering
  Noise noize = new Noise( 0.5f );  

  // send the noise through the filter
  noize.patch( moog ).patch( out );
}

// we'll control the frequency and resonance of the filter
// using the position of the mouse, in typical x-y controller fashion
void mouseMoved()
{
  float freq = constrain( map( mouseX, 0, width, 200, 12000 ), 200, 12000 );
  float rez  = constrain( map( mouseY, height, 0, 0, 1 ), 0, 1 );
  
  moog.frequency.setLastValue( freq );
  moog.resonance.setLastValue( rez  );
}

void keyPressed()
{
  if ( key == '1' ) moog.type = MoogFilter.Type.LP;
  if ( key == '2' ) moog.type = MoogFilter.Type.HP;
  if ( key == '3' ) moog.type = MoogFilter.Type.BP;
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
  
  text( "Filter type: " + moog.type, 10, 225 );
  text( "Filter cutoff: " + moog.frequency.getLastValue() + " Hz", 10, 245 );
  text( "Filter resonance: " + moog.resonance.getLastValue(), 10, 265 ); 
}
