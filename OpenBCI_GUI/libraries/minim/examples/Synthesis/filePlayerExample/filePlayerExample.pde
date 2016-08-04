/**
  This is an example of how to use a FilePlayer UGen to play an audio file. It support all of the same formats that 
  AudioPlayer does, but allows you to insert the audio from the file into a UGen chain. FilePlayer provides all the 
  same methods that AudioPlayer does for controlling the file playback: play(), loop(), cue(int position), etc.
  <p>
  Press any key to pause and unpause playback!
  <p>
  For more information about Minim and additional features, visit http://code.compartmental.net/minim/
  <p>  
  author: Damien Di Fede
*/

import ddf.minim.*;
import ddf.minim.spi.*; // for AudioRecordingStream
import ddf.minim.ugens.*;

// declare everything we need to play our file
Minim minim;
FilePlayer filePlayer;
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
                                                  
  // a FilePlayer reads from an AudioRecordingStream, which we 
  // can easily get from Minim using loadFileStream
  filePlayer = new FilePlayer( minim.loadFileStream(fileName) );
  // and then we'll tell the file player to loop indefinitely
  filePlayer.loop();
  
  // get a line out from Minim. It's important that the file is the same audio format 
  // as our output (i.e. same sample rate, number of channels, etc).
  out = minim.getLineOut();
  
  // patch the file player to the output
  filePlayer.patch(out);
                        
}

// keyPressed is called whenever a key on the keyboard is pressed
void keyPressed()
{
  // you can query whether the file is playing or not
  // playing simply means that it is generating sound
  // this will be true if you tell it to play() or loop()
  if ( filePlayer.isPlaying() )
  {
    // pauses playback of the file
    filePlayer.pause();
  }
  else
  {
    // starts the file looping again, picking up where we left off
    filePlayer.loop();
  }
}

void mousePressed()
{
  float pos = map(mouseX, 0, width, 0, filePlayer.length());
  filePlayer.cue((int)pos);
}


// draw is run many times
void draw()
{
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

  float songPos = map( filePlayer.position(), 0, filePlayer.length(), 0, width );

  stroke( 255, 0, 0 );
  line( songPos, 0, songPos, height );
  
  text( "loopCount: " + filePlayer.loopCount(), 15, 15 );
}