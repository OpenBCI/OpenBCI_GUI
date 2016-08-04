/**
  * This sketch demonstrates how to use the <code>getGain</code> and <code>setGain</code> methods of a 
  * <code>Controller</code> object. The class used here is an <code>AudioOutput</code> but you can also 
  * get and set the gain of <code>AudioSample</code>, <code>AudioSnippet</code>, <code>AudioInput</code>, 
  * and <code>AudioPlayer</code> objects. <code>getGain</code> and <code>setGain</code> will get and set 
  * the gain of the <code>DataLine</code> that is being used for input or output, but only if that line has 
  * a gain control. A <code>DataLine</code> is a low-level JavaSound class that is used for sending audio to, 
  * or receiving audio from, the audio system. You will notice in this sketch that you will hear the gain 
  * changing (if it's available) but you will not see any difference in the waveform being drawn. The reason for this
  * is that what you see in the output's sample buffers is what it sends to the audio system. The system makes the 
  * gain change after receiving the samples.
  */

import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioOutput out;
Oscillator  osc;
WaveformRenderer waveform;

void setup()
{
  size(512, 200);
  minim = new Minim(this);
  out = minim.getLineOut();
  
  // see the example AudioOutput >> SawWaveSignal for more about this class
  osc = new SawWave(100, 0.2, out.sampleRate());
  // see the example Polyphonic >> addSignal for more about this
  out.addSignal(osc);
  
  waveform = new WaveformRenderer();
  // see the example Recordable >> addListener for more about this
  out.addListener(waveform); 
  
  textFont(createFont("Arial", 12));
}

void draw()
{
  background(0);
  // see waveform.pde for more about this
  waveform.draw();
  
  if ( out.hasControl(Controller.GAIN) )
  {
    // map the mouse position to the audible range of the gain
    float val = map(mouseX, 0, width, 6, -48);
    // if a gain control is not available, this will do nothing
    out.setGain(val); 
    // if a gain control is not available this will report zero
    text("The current gain is " + out.getGain() + ".", 5, 15);
  }
  else
  {
    text("The output doesn't have a gain control.", 5, 15);
  }
}
