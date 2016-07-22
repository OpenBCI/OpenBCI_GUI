/**
  This is an example of how to use a Gain UGen to control the gain of an audio file. 
  Gain is expressed in dB, which is short for decibels, and is way that people 
  often think about the level of digital audio. dB is a change in amplitude 
  relative to whatever the incoming amplitude is, so a gain value of 0 will not change 
  the incoming amplitude at all. Positive gain values increase the amplitude of the 
  incoming signal and negative values decrease it. It's not really possible to completely 
  silence incoming audio with a Gain UGen, but you can set the gain value so low that you 
  effectively silence the audio. 
  <p>
  dB is a logarithmic scale, so while 0 dB will not change the amplitude of incoming 
  audio at all, 6 dB will approximately double the amplitude and -6 dB will approximately halve it.
  <p>
  Move the mouse left and right to change the gain of the looping audio file. 
  All the way left is -6 dB, all the way right is +6 dB.
  <p>
  For more information about Minim and additional features, 
  visit http://code.compartmental.net/minim/
  <p>
  author: Damien Di Fede
*/

import ddf.minim.*;
import ddf.minim.ugens.*;

// declare everything we need to play our file
Minim minim;
FilePlayer filePlayer;
Gain       gain;
AudioOutput out;

// you can use your own file by putting it in the data directory of this sketch
// and changing the value assigned to fileName here.
String fileName = "groove.mp3";

void setup()
{
  // setup the size of the app
  size(640, 240);
  
  // create our Minim object for loading audio
  minim = new Minim(this);
  // this opens the file and puts it in the "play" state.                           
  filePlayer = new FilePlayer( minim.loadFileStream(fileName) );
  // and then we'll tell the recording to loop indefinitely
  filePlayer.loop();
  
  // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0.f);
  
  // get a line out from Minim. It's important that the file is the same audio format 
  // as our output (i.e. same sample rate, number of channels, etc).
  out = minim.getLineOut();
  
  // patch the file player to the output
  filePlayer.patch(gain).patch(out);
                        
}

// draw is run many times
void draw()
{
  // update the gain value. middle of the width will be the original amplitude 
  // of the audio file, far right is twice as loud and far left is half as loud.
  float dB = map(mouseX, 0, width, -6, 6);
  gain.setValue(dB);
  
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
    line( x1, 50 + out.left.get(i)*50, x2, 50 + out.left.get(i+1)*50);
    line( x1, 150 + out.right.get(i)*50, x2, 150 + out.right.get(i+1)*50);
  }  
  
  text("Current Gain is " + dB + " dB.", 10, 20);
}