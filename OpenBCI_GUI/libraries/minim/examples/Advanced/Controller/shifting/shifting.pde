/**
  * This sketch demonstrates how to use the <code>shiftVolume</code>, <code>shiftGain</code>, <code>shiftBalance</code>, 
  * and <code>shiftPan</code> methods of a <code>Controller</code> object. The class used here is an <code>AudioOutput</code> 
  * but you can also shift controls of <code>AudioSample</code>, <code>AudioSnippet</code>, <code>AudioInput</code>, 
  * and <code>AudioPlayer</code> objects. The shift methods allow you to transition the value of a control from one 
  * value to another one over a given number of milliseconds. Shifting will only work if the control is available 
  * (see the example hasControl for more about that). Also, please note that the shift methods of <code>Controller</code> 
  * are not the same thing as the method <code>FloatControl.shift</code>. A <code>Controller</code>'s shift methods will 
  * always work if a control is available, but a <code>FloatControl</code>'s shift method will only work if the control 
  * supports shifting (see the example Controller >> FloatControl >> shift for more).
  * <p>
  * Press 'v' to shift the volume.<br />
  * Press 'g' to shift the gain.<br />
  * Press 'b' to shift the balance.<br />
  * Press 'p' to shift the pan.<br />
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
  
  if ( out.hasControl(Controller.PAN) )
  {
    text("The current pan value is " + out.getPan() + ".", 5, 15);
  }
  else
  {
    text("The output doesn't have a pan control.", 5, 15);
  }
  
  if ( out.hasControl(Controller.VOLUME) )
  {
    text("The current volume value is " + out.getVolume() + ".", 5, 30);
  }
  else
  {
    text("The output doesn't have a volume control.", 5, 30);
  }
  
  if ( out.hasControl(Controller.BALANCE) )
  {
    text("The current balance value is " + out.getBalance() + ".", 5, 45);
  }
  else
  {
    text("The output doesn't have a balance control.", 5, 45);
  }
  
  if ( out.hasControl(Controller.GAIN) )
  {
    text("The current gain value is " + out.getGain() + ".", 5, 60);
  }
  else
  {
    text("The output doesn't have a gain control.", 5, 60);
  }
}

void keyReleased()
{
  if ( key == 'v' ) out.shiftVolume(0, 1, 2000);
  if ( key == 'g' ) out.shiftGain(-40, 0, 2000);
  if ( key == 'b' ) out.shiftBalance(-1, 1, 2000);
  if ( key == 'p' ) out.shiftPan(1, -1, 2000);
}

