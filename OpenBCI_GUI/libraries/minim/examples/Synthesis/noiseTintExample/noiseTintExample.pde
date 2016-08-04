/* noiseTintExample<br/>
   is a example of how to set and get the Tint of a Noise UGen
   after constructing it.
   <p>
   For more information about Minim and additional features, 
   visit http://code.compartmental.net/minim/
   <p>
   author:Damien Di Fede<br/>
*/

// import everything necessary to make sound.
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioOutput out;
Noise       theNoise;

// used for the drawing
color noiseColor;

// setup is run once at the beginning
void setup()
{
  size( 400, 200 );
  
  // initialize the minim and out objects
  minim = new Minim(this);
  // the small buffer size of 512 is chosen to minimize delay between the visual and audio
  // this may cause problems with buffer underruns on slower systems
  out = minim.getLineOut(Minim.MONO, 512);
 
  // make a new Noise UGen with an amplitude of 0.5
  theNoise = new Noise( 0.5f );
  theNoise.patch( out );
}

// draw is run many times
void draw()
{
  // erase the window to black
  background(0);
  
  // because we are switching on a value that is a Noise.Tint, 
  // we can't qualify the names in the case labels 
  // with Noise.Tint as you might expect.
  switch( theNoise.getTint() )
  {
    case WHITE: noiseColor = color( 255, 255, 255 ); break;
    case PINK:  noiseColor = color( 255, 128, 128 ); break;
    case BROWN:
    case RED:   noiseColor = color( 255, 0,   0   ); break;
    
    default: break;
  }
  
  // color the drawing the same as the noise tint
  stroke( noiseColor );
  for(int i = 0; i < out.bufferSize() - 1; i++)
  {
    float x1 = map(i, 0, out.bufferSize(), 0, width);
    float x2 = map(i+1, 0, out.bufferSize(), 0, width);
    line(x1, 50 + out.left.get(i)*50, x2, 50 + out.left.get(i+1)*50);
    line(x1, 150 + out.right.get(i)*50, x2, 150 + out.right.get(i+1)*50);
  }
  
  text( "1: White, 2: Pink, 3: Red/Brown", 5, 15 );
}

void keyPressed()
{
  if ( key == '1' )
  {
    theNoise.setTint( Noise.Tint.WHITE );
  }
  
  if ( key == '2' )
  {
    theNoise.setTint( Noise.Tint.PINK );
  }
  
  if ( key == '3' )
  {
    theNoise.setTint( Noise.Tint.RED );
  }
}
