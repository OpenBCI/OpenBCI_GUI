/**
 * This sketch demonstrates very simply how you might use the inverse FFT to modify an audio signal.<br />
 * Press 'f' to perform the forward FFT, then press 's' to scale the large frequency band.<br />
 * Now press 'd' to take the inverse FFT. You will see that the wave form has a smaller amplitude.<br />
 * <br />
 * You might wonder how we knew which band to scale. You should read 
 * <a href="http://code.compartmental.net/2007/03/21/fft-averages/">this blog post</a> about calculating 
 * FFT averages for the answer to that question.
 * <p>
 * For more information about Minim and additional features, visit http://code.compartmental.net/minim/
 */

import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.signals.*;

FFT fft;
SineWave sine;
float[] buffer;
int bsize = 512;

void setup()
{
  size(512, 300, P3D);

  // create an FFT with a time-domain size the same as the size of buffer
  // it is required that these two values be the same
  // and also that the value is a power of two
  fft = new FFT(bsize, 44100);
  sine = new SineWave(600, 1, 44100);
  buffer = new float[bsize];
  // fill the buffer with a sine wave
  sine.generate(buffer);
}

void draw()
{
  background(0);
  noStroke();
  fill(255, 128);
  // draw the waveform
  for(int i = 0; i < buffer.length; i++)
  {
    ellipse(i, 50 + buffer[i]*10, 2, 2);
  }
  noFill();
  stroke(255);
  // draw the spectrum
  for(int i = 0; i < fft.specSize(); i++)
  {
    line(i, height, i, height - fft.getBand(i));
  }
  stroke(255, 0, 0);
  line(width/2, height, width/2, 0);
}


void keyReleased()
{
  if ( key == 'f' ) 
  {
    println("Performing a Forward FFT on buffer.");
    fft.forward(buffer);
  }
  if ( key == 'd' ) 
  {
    println("Performing an Inverse FFT and putting the result in buffer.");
    fft.inverse(buffer);
  }
  if ( key == 's' )
  {
    println("Scaling frequency band 7 by 0.5.");
    fft.scaleBand(7, 0.5);
  }
}
