/**
  * This sketch demonstrates how to use the <code>hasControl</code> method of a <code>Controller</code> object. 
  * The class used here is an <code>AudioOutput</code> but you can also use test for controls of  
  * <code>AudioSample</code>, <code>AudioSnippet</code>, <code>AudioInput</code>, and <code>AudioPlayer</code> objects. 
  * <code>hasControl</code> takes one of the static control types of <code>Controller</code> as the argument. These are 
  * <code>Controller.BALANCE</code>, <code>Controller.GAIN</code>, <code>Controller.MUTE</code>, <code>Controller.PAN</code>, 
  * <code>Controller.SAMPLE_RATE</code>, and <code>Controller.VOLUME</code>. You should always check if a control 
  * is available before you attempt to use it.
  */

import ddf.minim.*;

Minim minim;
AudioOutput out;

void setup()
{
  size(512, 200);
  minim = new Minim(this);
  out = minim.getLineOut();
  
  textFont(createFont("Arial", 12));
}

void draw()
{
  background(0);
  
  if ( out.hasControl(Controller.PAN) )
  {
    text("The output has a pan control.", 5, 15);
  }
  else
  {
    text("The output doesn't have a pan control.", 5, 15);
  }
  
  if ( out.hasControl(Controller.VOLUME) )
  {
    text("The output has a volume control.", 5, 30);
  }
  else
  {
    text("The output doesn't have a volume control.", 5, 30);
  }
  
  if ( out.hasControl(Controller.SAMPLE_RATE) )
  {
    text("The output has a sample rate control.", 5, 45);
  }
  else
  {
    text("The output doesn't have a sample rate control.", 5, 45);
  }
  
  if ( out.hasControl(Controller.BALANCE) )
  {
    text("The output has a balance control.", 5, 60);
  }
  else
  {
    text("The output doesn't have a balance control.", 5, 60);
  }
  
  if ( out.hasControl(Controller.MUTE) )
  {
    text("The output has a mute control.", 5, 75);
  }
  else
  {
    text("The output doesn't have a mute control.", 5, 75);
  }
  
  if ( out.hasControl(Controller.GAIN) )
  {
    text("The output has a gain control.", 5, 90);
  }
  else
  {
    text("The output doesn't have a gain control.", 5, 105);
  }
}
