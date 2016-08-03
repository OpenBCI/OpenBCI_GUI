/**
  This is an example of how to use a TickRate UGen to control 
  the tick rate of another UGen, in this case a FilePlayer. <br/>
  A TickRate will tick the UGen patched to it at a rate relative 
  to the normal tick rate. So a TickRate with a value of 1 
  will simply pass the audio. A TickRate with a value of 2 
  will tick the incoming UGen twice as fast as normal. 
  If the value of TickRate is ever set to 0 or lower, 
  it will simply generate silence and not tick its incoming UGen at all. 
  This is because there isn't a way to tell a UGen to tick backwards.
  <p>
  Slide the mouse left and right in the window 
  to control the playback rate of the loop.
  <br/>
  Hold 'i' to make TickRate interpolate between actual sample values 
  (this will remove the "crunch" when at rates less than 1).
  <p>
  For more information about Minim and additional features, 
  visit http://code.compartmental.net/minim/
  <p>
  author: Damien Di Fede
*/

import ddf.minim.*;
import ddf.minim.spi.*; // for AudioRecordingStream
import ddf.minim.ugens.*;

// declare everything we need to play our file and control the playback rate
Minim minim;
TickRate rateControl;
FilePlayer filePlayer;
AudioOutput out;

// you can use your own file by putting it in the data directory of this sketch
// and changing the value assigned to fileName here.
String fileName = "again_loop.aif";

void setup()
{
  // setup the size of the app
  size(640, 200);
  
  // create our Minim object for loading audio
  minim = new Minim(this);
                               
  // this opens the file and puts it in the "play" state.                           
  filePlayer = new FilePlayer( minim.loadFileStream(fileName) );
  // and then we'll tell the recording to loop indefinitely
  filePlayer.loop();
  
  // this creates a TickRate UGen with the default playback speed of 1.
  // ie, it will sound as if the file is patched directly to the output
  rateControl = new TickRate(1.f);
  
  // get a line out from Minim. It's important that the file is the same audio format 
  // as our output (i.e. same sample rate, number of channels, etc).
  out = minim.getLineOut();
  
  // patch the file player through the TickRate to the output.
  filePlayer.patch(rateControl).patch(out);
                        
}

// keyPressed is called whenever a key on the keyboard is pressed
void keyPressed()
{
  if ( key == 'i' || key == 'I' )
  {
    // with interpolation on, it will sound as a record would when slowed down or sped up
    rateControl.setInterpolation( true );
  }
}

void keyReleased()
{
  if ( key == 'i' || key == 'I' )
  {
    // with interpolation off, the sound will become "crunchy" when playback is slowed down
    rateControl.setInterpolation( false );
  }
}

// draw is run many times
void draw()
{
  // change the rate control value based on mouse position
  float rate = map(mouseX, 0, width, 0.0f, 3.f);
  
  rateControl.value.setLastValue(rate);
  
  // erase the window to black
  background( 0 );
  // draw using a white stroke
  stroke( 255 );
  // draw the waveforms
  for( int i = 0; i < out.bufferSize() - 1; i++ )
  {
    // find the x position of each buffer value
    float x1  =  map( i, 0, out.bufferSize(), 0, width );
    float x2  =  map( i+1, 0, out.bufferSize(), 0, width );
    // draw a line from one buffer position to the next for both channels
    line( x1, 50  - out.left.get(i)*50,  x2, 50  - out.left.get(i+1)*50);
    line( x1, 150 - out.right.get(i)*50, x2, 150 - out.right.get(i+1)*50);
  }  
}