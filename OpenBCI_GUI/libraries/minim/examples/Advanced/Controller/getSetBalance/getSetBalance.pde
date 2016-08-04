/**
  * This sketch demonstrates how to use the <code>getBalance</code> and <code>setBalance</code> methods of a 
  * <code>Controller</code> object. The class used here is an <code>AudioOutput</code> but you can also 
  * get and set the balance of <code>AudioSample</code>, <code>AudioSnippet</code>, <code>AudioInput</code>, 
  * and <code>AudioPlayer</code> objects. <code>getBalance</code> and <code>setBalance</code> will get and set 
  * the balance of the <code>DataLine</code> that is being used for input or output, but only if that line has 
  * a balance control. A <code>DataLine</code> is a low-level JavaSound class that is used for sending audio to, 
  * or receiving audio from, the audio system. You will notice in this sketch that you will hear the balance 
  * changing (if it's available) but you will not see any difference in the waveform being drawn. The reason for this
  * is that what you see in the output's sample buffers is what it sends to the audio system. The system makes the 
  * balance change after receiving the samples.
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
  
  if ( out.hasControl(Controller.BALANCE) )
  {
    float val = map(mouseX, 0, width, -1, 1);
    // if a balance control is not available, this will do nothing
    out.setBalance(val); 
    // if a balance control is not available this will report zero
    text("The current balance is " + out.getBalance() + ".", 5, 15);
  }
  else
  {
    text("This output doesn't have a balance control.", 5, 15);
  }
}
