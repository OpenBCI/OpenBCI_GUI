/**
  * This sketch demonstrates many of the methods available for 
  * modifying Wavetables. The controls are as follows:
  * <ul>
  *   <li>n: normalize the waveform</li>
  *   <li>s: smooth the waveform</li>
  *   <li>r: rectify the waveform</li>
  *   <li>z: add noise to the waveform</li>
  *   <li>q/a: scale the waveform up or down</li>
  *   <li>left click and drag: warp the waveform</li>
  *   <li>right click: flip the waveform around the y position of the mouse</li>
  * </ul>
  * The waveform shown in red is the Wavetable being used by the Oscil and 
  * the moving waveform in white is what the output looks like.
  * <p>
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  */

import ddf.minim.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioOutput out;
Oscil       wave;
Wavetable   table;

void setup()
{
  size(512, 200, P3D);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  // create a reasonably complex waveform to start, will be slightly different every time
  table = Waves.randomNHarms(16);
  wave  = new Oscil( 440, 0.5f, table );
  // patch the Oscil to the output
  wave.patch( out );
}

void draw()
{
  background(0);
  
  stroke(255, 64);
  strokeWeight(1);
  
  // draw the waveform of the output
  for(int i = 0; i < out.bufferSize() - 1; i++)
  {
    line( i, 50  - out.left.get(i)*50,  i+1, 50  - out.left.get(i+1)*50 );
    line( i, 150 - out.right.get(i)*50, i+1, 150 - out.right.get(i+1)*50 );
  }

  // draw the waveform we are using in the oscillator
  stroke( 200, 0, 0 );
  strokeWeight(4);
  for( int i = 0; i < width-1; ++i )
  {
    point( i, height/2 - (height*0.49) * table.value( (float)i / width ) );
  }
}

void keyPressed()
{ 
  switch( key )
  {
    case 'n':
      // scale the table so that the largest value is -1/1.
      table.normalize();
      break;
     
    case 's':
      // smooth out the table, similar to applying a low pass filter
      table.smooth( 64 );
      break;
     
    case 'r':
      // change all negative values to positive values
      table.rectify();
      break;
   
    case 'z':
      // add some noise
      table.addNoise( 0.1f );
      break;
    
    case 'q':
      table.scale( 1.1f );
      break;
      
    case 'a':
      table.scale( 0.9f );
      break;
     
    default: break; 
  }
}

void mousePressed()
{
  if ( mouseButton == RIGHT )
  {
    float flipPoint = map( mouseY, 0, height, 1, -1 );
    table.flip( flipPoint );
  }
}

void mouseDragged()
{
  if ( mouseButton == LEFT )
  {
    float warpPoint = constrain( (float)pmouseX / width, 0, 1 );
    float warpTarget = constrain( (float)mouseX / width, 0, 1 );
    table.warp( warpPoint, warpTarget );
  }
}
