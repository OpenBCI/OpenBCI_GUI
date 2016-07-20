/**
  * This sketch demonstrates how to use a Convolver effect. A Convolver is an effect that convolves a signal with a kernel.
  * The kernel can be thought of as the impulse response of an audio filter, or simply as a set of weighting coefficients.
  * A Convolver performs brute-force convolution, meaning that it is slow, relatively speaking. However, the algorithm is 
  * very straighforward. Each output sample 'i' is calculated by multiplying each kernel value 'j' with the input sample 
  * 'i - j' and then summing the resulting values. The output will be 'kernel.length + signal.length - 1' samples long,
  * so the extra samples are stored in an overlap array. The overlap array from the previous signal convolution is added into the 
  * beginning of the output array, which results in a output signal without pops.
  * <p>
  * This sketch is not interactive.
  * <p>
  * For more information about Minim and additional features, visit http://code.compartmental.net/minim/
  */

import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer groove;
Convolver lpf;

void setup()
{
  size(512, 200, P3D);
  minim = new Minim(this);
  groove = minim.loadFile("groove.mp3");
  groove.loop();
  // the kernal can be thought of as the impulse response of a filter, 
  // or as a set of weighting coefficients.
  // this particular set is roughly the impulse response of a low pass filter
  float[] kernel = new float[] { 0, 0.005, 0.01, 0.018, 0.021, 0.03, 0.034, 0.037, 0.04, 0.042, 0.044, 0.046, 0.048, 0.049, 0.05,
                                 0.049, 0.048, 0.046, 0.044, 0.042, 0.04, 0.037, 0.034, 0.03, 0.021, 0.018, 0.01, 0.005, 0 };
  // make a new Convolver, passing the kernal array and the buffer size 
  // of the signal that will be convolved with the kernal                              
  lpf = new Convolver(kernel, groove.bufferSize());
  groove.addEffect(lpf);
}

void draw()
{
  background(0);
  stroke(255);
  // we multiply the values returned by get by 50 so we can see the waveform
  for ( int i = 0; i < groove.bufferSize() - 1; i++ )
  {
    float x1 = map(i, 0, groove.bufferSize(), 0, width);
    float x2 = map(i+1, 0, groove.bufferSize(), 0, width);
    line(x1, height/4 - groove.left.get(i)*50, x2, height/4 - groove.left.get(i+1)*50);
    line(x1, 3*height/4 - groove.right.get(i)*50, x2, 3*height/4 - groove.right.get(i+1)*50);
  }
}
