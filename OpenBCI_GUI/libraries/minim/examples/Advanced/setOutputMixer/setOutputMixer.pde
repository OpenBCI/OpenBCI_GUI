/**
  * This sketch demonstrates how to use the <code>setOutputMixer</code> 
  * method of <code>Minim</code> in conjunction with the <code>getLineOut</code> 
  * method. By accessing the Mixer objects of Javasound, you can find one that 
  * corresponds to the output mixer of the sound device of your choice. You can 
  * then set this Mixer as the one that should use when creating an AudioOutput for you.
  * This Mixer will also be used when obtaining outputs for AudioPlayers, AudioSamples, 
  * and any other classes that result in sound being ouput to your speakers.
  * <p>
  * This sketch uses controlP5 for the GUI, a user-contributed Processing library.
  * <p>
  * For more information about Minim and additional features, visit http://code.compartmental.net/minim/
  */

import ddf.minim.*;
import ddf.minim.ugens.*;

// need to import this so we can use Mixer and Mixer.Info objects
import javax.sound.sampled.*;

Minim minim;
AudioOutput out;
// an array of info objects describing all of 
// the mixers the AudioSystem has. we'll use
// this to populate our gui scroll list and
// also to obtain an actual Mixer when the
// user clicks on an item in the list.
Mixer.Info[] mixerInfo;

// a signal for our output
Oscil sine;

int activeMixer = -1;

// simple class for drawing the gui
class Rect 
{
  String label;
  int x, y, w, h;
  int mixerId;
  
  public Rect(String _label, int _x, int _y, int _id)
  {
    label = _label;
    x = _x;
    y = _y;
    w = 200;
    h = 15;
    mixerId = _id;
  }
  
  public void draw()
  {
    if ( activeMixer == mixerId )
    {
      stroke(255);
      // indicate the mixer failed to return an input
      // by filling in the box with red
      if ( out == null )
      {
        fill( 255, 0, 0 );
      }
      else
      {
        fill( 0, 128, 0 );
      }
    }
    else
    {
      noStroke();
      fill( 128 );
    }
    
    rect(x,y,w,h);
    
    fill( 255 );
    text( label, x+5, y );
  }
  
  public boolean mousePressed()
  {
    return ( mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h );
  }
} 

ArrayList<Rect> mixerButtons = new ArrayList<Rect>();


void setup()
{
  size(512, 512);
  textAlign(LEFT, TOP);

  minim = new Minim(this);
  
  mixerInfo = AudioSystem.getMixerInfo();
  
  for(int i = 0; i < mixerInfo.length; i++)
  {
    Rect button = new Rect(mixerInfo[i].getName(), 10, 20+i*25, i);
    mixerButtons.add( button );
  } 
  
  sine = new Oscil(220f, 0.30f);
}

void draw()
{
  background(0);
  
  for(int i = 0; i < mixerButtons.size(); ++i)
  {
    mixerButtons.get(i).draw();
  }
  
  if ( out != null )
  {
    stroke(255);
    // draw the waveforms
    for(int i = 0; i < out.bufferSize() - 1; i++)
    {
      line(i, 50 + out.left.get(i)*50, i+1, 50 + out.left.get(i+1)*50);
      line(i, 150 + out.right.get(i)*50, i+1, 150 + out.right.get(i+1)*50);
    }
  }
}

void mousePressed()
{ 
  int selected = -1;
  for(int i = 0; i < mixerButtons.size(); ++i)
  {
    if ( mixerButtons.get(i).mousePressed() )
    {
      selected = i;
      break;
    }
  }
  
  if ( selected >= 0 && selected != activeMixer )
  {
    activeMixer = selected;
    Mixer mixer = AudioSystem.getMixer(mixerInfo[activeMixer]);
    
    minim.setOutputMixer(mixer);
    
    if ( out != null )
    {
      sine.unpatch( out );
      out.close();
    }
    
    out = minim.getLineOut(Minim.STEREO);
    
    if ( out != null )
    {
      sine.patch(out);
    }
  }
}