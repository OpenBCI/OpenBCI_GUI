/**
    This example demonstrates how you might use JavaSound's midi file playing
    abilities to drive UGens in Minim for synthesis, rather than using the 
    midi sounds built into JavaSound. You might want to take this 
    approach if you want to tightly couple visuals and music, like this example does,
    but don't want to hand-code your sequence using AudioOutput's playNote method,
    or if you want to synthesize a midi file you've already created with custom
    synthesis chains and effects.
    <p>
    This is a simple example, as far as it goes, and ignores NoteOff midi messages. To handle NoteOff 
    messages, you would need to conceive of some kind of system for pairing NoteOn messages with 
    NoteOff messages so that your Instrument instances (or whatever classes you write to respond
    to midi messages) behave properly.
    <p>
    For more info about what can be done with the JavaSound Sequencer and Sequence classes, see:
    <a href="http://docs.oracle.com/javase/6/docs/api/javax/sound/midi/Sequence.html">javax.sound.midi.Sequence</a> and 
    <a href="http://docs.oracle.com/javase/6/docs/api/javax/sound/midi/Sequencer.html">javax.sound.midi.Sequencer</a>
    <p>
    For more information about Minim and additional features, visit http://code.compartmental.net/minim/
    <p>
    Author: Damien Di Fede  
  */
  
import ddf.minim.*;
import ddf.minim.ugens.*;

// this package is where we get our midi objects from
import javax.sound.midi.*;

// two things we need from Minim synthesis
Minim       minim;
AudioOutput out;

// what we need from JavaSound for sequence playback
Sequencer     sequencer;
// holds the actual midi data
Sequence      sequence;

// the Blip class is what handles our visuals.
// see below the draw function for the definition.
ArrayList<Blip> blips;

// in order to be send midi messages from the Sequencer
// we must implement the JavaSound interface Receiver.
// we then set an instance of this class as the Receiver
// for on of the Sequencer's Trasmitters.
// See: http://docs.oracle.com/javase/6/docs/api/javax/sound/midi/Receiver.html
class MidiReceiver implements Receiver
{
  void close() {}
  
  void send( MidiMessage msg, long timeStamp )
  { 
    // we only care about NoteOn midi messages.
    // here's how you check for that
    if ( msg instanceof ShortMessage )
    {
      ShortMessage sm = (ShortMessage)msg;
      // if you want to handle messages other than NOTE_ON, you can refer to the constants defined in 
      // ShortMessage: http://docs.oracle.com/javase/6/docs/api/javax/sound/midi/ShortMessage.html
      // And figure out what Data1 and Data2 will be, refer to the midi spec: http://www.midi.org/techspecs/midimessages.php
      if ( sm.getCommand() == ShortMessage.NOTE_ON )
      {
        // note number, between 1 and 127
        int note = sm.getData1();
        // velocity, between 1 and 127
        int vel  = sm.getData2();
        // we could also use sm.getChannel() to do something different depending on the channel of the message
        
        // see below the draw method for the definition of this sound generating Instrument
        out.playNote( 0, 0.1f, new Synth( note, vel ) ); 
      }
    }
  }
}

void setup()
{
  size( 640, 480 );
  
  minim = new Minim(this);
  out   = minim.getLineOut();
  
  // try to get the default sequencer from JavaSound
  // if it fails, we print a message to the console
  // and don't do any of the sequencing.
  try
  {
    // get a disconnected sequencer. this should prevent
    // us from hearing the general midi sounds the 
    // sequecer is automatically hooked up to.
    sequencer = MidiSystem.getSequencer( false );
    
    // have to open it
    sequencer.open();
    
    // load our sequence
    sequence  = MidiSystem.getSequence( createInput( "bassline.MID" ) );
    
    // put it in the sequencer
    sequencer.setSequence( sequence );
    
    // set the tempo
    sequencer.setTempoInBPM( 128 );
    
    // hook up an instance of our Receiver to the Sequencer's Transmitter
    sequencer.getTransmitter().setReceiver( new MidiReceiver() );
    
    // just keep looping
    sequencer.setLoopCount( Sequencer.LOOP_CONTINUOUSLY );
    
    // and away we go
    sequencer.start();
  }
  catch( MidiUnavailableException ex ) // getSequencer can throw this
  {
    // oops there wasn't one.
    println( "No default sequencer, sorry bud." );
  }
  catch( InvalidMidiDataException ex ) // getSequence can throw this
  {
    // oops, the file was bad
    println( "The midi file was hosed or not a midi file, sorry bud." );
  }
  catch( IOException ex ) // getSequence can throw this
  {
    println( "Had a problem accessing the midi file, sorry bud." );
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

// the Instrument implementation we use for playing notes
// we have to explicitly specify the Instrument interface
// from Minim because there is also an Instrument interface
// in javax.sound.midi. We could avoid this by importing
// only the classes we need from javax.sound.midi, 
// rather than importing everything.
class Synth implements ddf.minim.ugens.Instrument
{
  Oscil       wave;
  Damp        env;
  int         noteNumber;
  Blip        blip;
  
  Synth( int note, int velocity )
  {
    noteNumber = note;
    float freq = Frequency.ofMidiNote( noteNumber ).asHz();
    float amp  = (float)(velocity-1) / 126.0f;
    
    wave = new Oscil( freq, amp, Waves.QUARTERPULSE );
    // Damp arguments are: attack time, damp time, and max amplitude
    env  = new Damp( 0.001f, 0.1f, 1.0f );
    
    wave.patch( env );
  }
  
  void noteOn( float dur )
  {
    // make visual
    color c = color( 0, 200, 64, 255*(wave.amplitude.getLastValue()) );
    blip = new Blip( c, map(noteNumber, 30, 55, height, 0), 200 );
    blips.add( blip );
    
    // make sound
    env.activate();
    env.patch( out );
  }
  
  void noteOff()
  {
    env.unpatchAfterDamp( out );
    blips.remove( blip );
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
