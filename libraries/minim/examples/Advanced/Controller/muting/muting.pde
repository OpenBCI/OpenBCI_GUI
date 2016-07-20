/**
  * This sketch demonstrates how to use the <code>mute</code>, <code>unmute</code>, and <code>isMuted</code> methods
  * of a <code>Controller</code> object. The class used here is an <code>AudioOutput</code> but you can also 
  * mute/unmute <code>AudioSample</code>, <code>AudioSnippet</code>, <code>AudioInput</code>, and <code>AudioPlayer</code> objects. 
  * <code>isMuted</code> returns true or false depending on the current mute state. <code>mute</code> and <code>unmute</code> 
  * do exactly what they claim to. However, it is possible that your object will not have a mute control, in which case 
  * <code>isMuted</code> will always return false and <code>mute</code> and <code>unmute</code> will do nothing. If 
  * muting is available you will notice that muting the output doesn't change the waveform being drawn. The reason for 
  * this is that the <code>DataLine</code> carrying the audio to the system is what is being muted and *not* the 
  * output's signal generation (see the example Polyphonic >> soundNoSound for more about that).
  * <p>
  * Hold down the mouse button to mute the output and release the mouse button to unmute it.
  */

import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioOutput out;
WaveformRenderer waveform;
SawWave saw;

void setup()
{
  size(512, 200);
  minim = new Minim(this);
  out = minim.getLineOut();
  
  waveform = new WaveformRenderer();
  // see the example Recordable >> addListener for more about this
  out.addListener(waveform);
  
  // see the example AudioOutput >> SawWaveSignal for more about this
  saw = new SawWave(100, 0.2, out.sampleRate());
  // see the example Polyphonic >> addSignal for more about this
  out.addSignal(saw);
  
  textFont(createFont("Arial", 12));
}

void draw()
{
  background(0);
  // see waveform.pde for more about this
  waveform.draw();
  
  if ( out.hasControl(Controller.MUTE) )
  {
    if (mousePressed) 
    {
      out.mute();
    }
    else 
    {
      out.unmute();
    }
    if ( out.isMuted() )
    {
      text("The output is muted.", 5, 15);
    }
    else
    {
      text("The output is not muted.", 5, 15);
    }
  }
  else
  {
    text("The output doesn't have a mute control.", 5, 15);
  }
}

