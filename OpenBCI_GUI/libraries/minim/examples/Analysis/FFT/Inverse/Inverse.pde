/**
 * This sketch demonstrates very simply how you might use the inverse FFT to modify an audio signal.<br />
 * Press 'f' to perform the forward FFT, then press 's' to set one of the frequency bands to 150.<br />
 * Now press 'i' to take the inverse FFT. You will see that the wave form now looks like two sine waves that have
 * been added together. In fact, this is exactly the case. The sine wave that has been added has the
 * same frequency as the frequency band that we artificially changed the value of.<br />
 * <br />
 * You might wonder what the actual frequency added to the spectrum is.
 * That frequency is a fraction of the sampling rate, which can be found with the formula <b>f = i/N</b>
 * where <b>f</b> is the fraction of the sampling rate, <b>i</b> is the index of the frequency band,
 * and <b>N</b> is the time-domain size of the FFT. In this case we have a 512 point FFT and we are
 * changing the frequency band at index 20. So in our case <b>f = 20/512 = 0.0390625</b>
 * Our sampling rate is 44100 Hz, so the frequency in Hz that is being added to the spectrum 
 * is <b>44100 * 0.0390625 = 1722.65625 Hz</b>
 *
 * <p>
 * For more information about Minim and additional features, visit http://code.compartmental.net/minim/
 */
 
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
 
FFT fft;
Oscil   sine;
float[] buffer;
int bsize = 512;
 
void setup()
{
  size(512, 300, P3D);
  
  // create an FFT with a time-domain size the same as the size of buffer
  // it is required that these two values be the same
  // and also that the value is a power of two
  fft = new FFT(bsize, 44100);
  
  // create an Oscil we'll use to fill up our buffer
  sine = new Oscil( 600.f, 1.f, Waves.SINE );
  sine.setSampleRate( 44100 );
  buffer = new float[bsize];
  // fill the buffer with a sine wave
  float[] tmp = new float[1];
  for( int i = 0; i < bsize; ++i )
  {
    sine.tick( tmp );
    buffer[i] = tmp[0];
  }
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
  
  // draw the spectrum
  noFill();
  stroke(255);
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
  if ( key == 'i' )
  {
    println("Performing an Inverse FFT and putting the result in buffer.");
    fft.inverse(buffer);
  }
  if ( key == 's' )
  {
    // by setting frequency band 20 to a high value, 
    // we are basically mixing in a sine wave at that frequency
    // after setting the frequency band and then taking the inverse FFT, 
    // you will see the waveform change
    println("Setting frequency band 20 to 150.");
    fft.setBand(20, 150);
  }
}