/**
    This example demonstrates how you might use the note sequencing abilities 
    of Minim to drive a JavaSound Synthesizer. You might want to take this 
    approach if you want to tightly couple visuals and music, like this example does,
    but don't want to construct your own synthesis chains or try to hook into midi events
    from a JavaSound Sequence. Also, typically, Minim's sequencing will have more 
    solid timing than a JavaSound Sequence will.
    <p>
    For more info about what can be done with JavaSound midi synthesis, see 
    <a href="http://docs.oracle.com/javase/6/docs/api/javax/sound/midi/MidiChannel.html">javax.sound.midi.MidiChannel</a> and 
    <a href="http://docs.oracle.com/javase/6/docs/api/javax/sound/midi/Synthesizer.html">javax.sound.midi.Synthesizer</a>
    <p>
    For more information about Minim and additional features, visit http://code.compartmental.net/minim/
    <p>
    Author: Damien Di Fede  
  */
  
import ddf.minim.*;
import ddf.minim.ugens.*;

// this package is where we get our Synthesizer from
import javax.sound.midi.*;

// two things we need from Minim for note playing.  
Minim       minim;
AudioOutput out;

// what we need from JavaSound for sound making.
Synthesizer   synth;
// the MidiChannels of the synth.
MidiChannel[] channels;

// constants to refer to the channels we are going to put our instruments on.
int PIANO = 0;
int BASS  = 1;

// the Blip class is what handles our visuals.
// see below the draw function for the definition.
ArrayList<Blip> blips;

// the Instrument implementation we use for playing notes
// we have to explicitly specify the Instrument interface
// from Minim because there is also an Instrument interface
// in javax.sound.midi. We could avoid this by importing
// only the classes we need from javax.sound.midi, 
// rather than importing everything.
class MidiSynth implements ddf.minim.ugens.Instrument
{
  int         channel;
  int         noteNumber;
  int         noteVelocity;
  Blip        blip;
  
  MidiSynth( int channelIndex, String noteName, float vel )
  {
    channel = channelIndex;
    // to make our sequence code more readable, we use note names.
    // and then convert the note name to a Midi note value here.
    noteNumber = (int)Frequency.ofPitch(noteName).asMidiNote();
    // similarly, we specify velocity as a [0,1] volume and convert to [1,127] here.
    noteVelocity = 1 + int(126*vel); 
  }
  
  void noteOn( float dur )
  {
    // make visual
    color c = color( 0, 200, 64, 255*(noteVelocity/127.0) );
    if ( channel == BASS )
    {
      c = color( 200, 32, 0, 255*(noteVelocity/127.0) );
    }
    blip = new Blip( c, map(noteNumber, 30, 75, height, 0), 200*dur );
    blips.add( blip );
    
    // make sound
    channels[channel].noteOn( noteNumber, noteVelocity );
  }
  
  void noteOff()
  {
    channels[channel].noteOff( noteNumber );
    blips.remove( blip );
  }
}

// just a little helper function to reduce how much typing is required
// for the sequence code below.
void note( float time, float duration, int channelIndex, String noteName, float velocity )
{
  out.playNote( time, duration, new MidiSynth( channelIndex, noteName, velocity ) );
}

void setup()
{
  size( 640, 480 );
  
  minim = new Minim(this);
  out   = minim.getLineOut();
  
  // try to get the default synthesizer from JavaSound
  // if it fails, we print a message to the console
  // and don't do any of the sequencing.
  try
  {
    synth = MidiSystem.getSynthesizer();
    synth.open();
    // get all the channels for the synth
    channels = synth.getChannels();
    // we're only going to use two channels,
    // which we'll now configure to use particular midi instruments. 
    // but you should have up to 16 channels available.
    // for a list of general midi instrument program numbers, see: http://www.midi.org/techspecs/gm1sound.php
    channels[PIANO].programChange( 5 ); // should be "electric piano 1"
    channels[BASS].programChange( 33 ); // should be "acoustic bass"
    
    // ok make a sequence with our output and custom Instrument
    out.setTempo( 120 );
    out.pauseNotes();
    
    // remember that time and duration are expressed relative to the tempo.
    // so the first two arguments here mean: on beat 0, play a dotted quarter note.
    note( 0, 1.5, PIANO, "D4", 0.8 );
    note( 0, 1.5, PIANO, "E4", 0.8 );
    note( 0, 1.5, PIANO, "G4", 0.8 );
    
    note( 1.5, 2.5, PIANO, "C4", 1 );
    note( 1.5, 2.5, PIANO, "E4", 1 );
    note( 1.5, 2.5, PIANO, "G4", 1 );
    
    note( 4, 1.5, PIANO, "D4", 0.8 );
    note( 4, 1.5, PIANO, "E4", 0.8 );
    note( 4, 1.5, PIANO, "G4", 0.8 );
    
    note( 5.5, 2.5, PIANO, "C4", 1 );
    note( 5.5, 2.5, PIANO, "E4", 1 );
    note( 5.5, 2.5, PIANO, "G4", 1 );
    
    note( 8, 1.5, PIANO, "E4", 0.8 );
    note( 8, 1.5, PIANO, "G4", 0.8 );
    note( 8, 1.5, PIANO, "A4", 0.8 );
    
    note( 9.5, 2.5, PIANO, "E4", 1 );
    note( 9.5, 2.5, PIANO, "G4", 1 );
    note( 9.5, 2.5, PIANO, "A4", 1 );
    
    note( 12.5, 0.25, PIANO, "D4", 1 );
    note( 12.5, 0.25, PIANO, "A4", 1 );
    note( 12.5, 0.25, PIANO, "G4", 1 );
    
    note( 13.5, 0.25, PIANO, "D4", 1 );
    note( 13.5, 0.25, PIANO, "G4", 1 );
    note( 13.5, 0.25, PIANO, "B4", 1 );
    
    // and the bass part
    for( int i = 0; i < 8; ++i )
    {
      note( i, 0.25, BASS, "C2", 0.6 );
      note( i+0.5, 0.25, BASS, "C2", 0.8 );
    }
    
    for( int i = 8; i < 12; ++i )
    {
      note( i, 0.25, BASS, "F2", 0.6 );
      note( i+0.5, 0.25, BASS, "F2", 0.8 );
    }
    
    for( int i = 12; i < 16; ++i )
    {
      note( i, 0.25, BASS, "G2", 0.6 );
      note( i+0.5, 0.25, BASS, "G2", 0.8 );
    }    
    
    out.resumeNotes(); 
  }
  catch( MidiUnavailableException ex )
  {
    // oops there wasn't one.
    println( "No default synthesizer, sorry bud." );
  } 
  
  // and we need to make our Blip list
  blips = new ArrayList<Blip>();
  // and set our drawing preferences
  rectMode( CENTER );
}

void draw()
{
  background( 20 );
  
  // just draw all the Blips!
  for( int i = 0; i < blips.size(); ++i )
  {
    blips.get(i).draw();  
  }
}

// this class stores data for drawing one Blip on the screen.
// in this example, each Blip directly corresponds to a note
// played in the musical sequence. the pitch of the note
// is represented by the vertical position of the Blip on the screen,
// the velocity is represented by the opacity of the Blip,
// and the duration is represented by the width.
// The color is used to differentiate between the two
// midi instruments being used in the example.
class Blip
{
  // color
  color shade;
  // vertical position on screen
  float position;
  // width
  float size;
  
  Blip( color c, float p, float s )
  {
    shade = c;
    position = p;
    size = s;
  }
  
  void draw()
  {
    fill( shade );
    rect( width/2, position, size, 10 );
  }
}
