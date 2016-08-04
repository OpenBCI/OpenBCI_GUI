/* compositionExample<br/>
   is an example of one way to go about doing electronic music with Minim.
   Basically, all notes are written down in some sort of notation and then played through.
   This is a generally traditional and non-algorithmic approach to composition. 
   In the later sections of this, though, there are a couple of for loops with some i
   changing varibles, so that's nat completely traditional.
   <p>
   I'm a rhythm and techno guy, so this is what I made.
   <p>
   For more information about Minim and additional features, visit http://code.compartmental.net/minim/
   <p>
   author: Anderson Mills<br/>
   Anderson Mills's work was supported by numediart (www.numediart.org).
*/

// import everything necessary to make sound.
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

// create all of the variables that will need to be accessed in
// more than one methods (setup(), draw(), stop()).
Minim minim;
AudioOutput out;

// setup is run once at the beginning
// In this example, all of the sound work is done in the setup.
void setup()
{
  // initialize the drawing window
  size( 512, 200, P2D );

  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );
  
  // I'll need to a wave available, and it's nice to be able
  // to change it in every instrument if I want.
  Wavetable baseWave = Waves.square(3);
  // I want to remove the tone from some of the instances of the instrument
  // and specifying a 0 wave was the easiest way to do that.
  Wavetable noWave = Waves.square(0);

  // pause time when adding a bunch of notes at once
  // This guarantees accurate timing between all notes added at once.
  out.pauseNotes();

  // set the tempo for the piece
  out.setTempo( 202f );
  
  // I find it's easiest for me to think in sections of music, so I use comments
  // like this to separate the sections
  //---sectian 0--------------------------------------------------------------
  // I want a pause before the music starts
  out.setNoteOffset( 4f );

  // The NowNowInstrument makes a tinny sound and is used throughout the
  // piece.  I program a good bit, so I think of measures of 4/4 music
  // as the 0, 1, 2, and 3 beats, so that's reflected in my choice of 
  // start times here.  I could've set the offset above at 3.0 and started
  // with the 1.0 beat just as easily.
  out.playNote(0.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(1.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(2.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(2.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(3.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(4.5, 0.4, new NowNowInstrument(349.00, 0.8, 0.6, out));
  out.playNote(5.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(6.0, 0.4, new NowNowInstrument(349.00, 0.8, 0.6, out));
  out.playNote(6.5, 0.8, new NowNowInstrument(349.22, 0.8, 1.0, out));
  
  // I separated out the section into groups of 8 beats by spacing.
  out.playNote(8.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(9.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(9.5, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, out));
  out.playNote(9.67, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, out));
  out.playNote(9.83, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, out));
  out.playNote(10.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(11.0, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(11.33, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(11.67, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(12.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(13.0, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(13.33, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(13.67, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(14.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(15.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  
  out.playNote(16.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.6, out));
  out.playNote(17.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.6, out));
  out.playNote(17.5, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.6, out));
  out.playNote(17.67, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.6, out));
  out.playNote(17.83, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.7, out));
  out.playNote(18.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.7, out));
  out.playNote(18.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.7, out));
  out.playNote(19.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.7, out));
  out.playNote(20.0, 0.6, new NowNowInstrument(349.23, 0.8, 0.6, 0.7, out));
  out.playNote(20.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.8, out));
  out.playNote(21.0, 0.6, new NowNowInstrument(349.23, 0.8, 0.5, 0.8, out));
  out.playNote(21.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.8, out));
  out.playNote(22.0, 0.6, new NowNowInstrument(349.23, 0.8, 0.4, 0.9, out));
  out.playNote(22.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.9, out));
  out.playNote(23.0, 0.6, new NowNowInstrument(349.23, 0.8, 0.3, 0.9, out));
  out.playNote(23.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.9, out));
  
  out.playNote(24.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.96, out));
  out.playNote(25.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.96, out));
  out.playNote(25.5, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.96, out));
  out.playNote(25.67, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.96, out));
  out.playNote(25.83, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.97, out));
  out.playNote(26.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.97, out));
  out.playNote(26.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.97, out));
  out.playNote(27.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.97, out));
  out.playNote(28.0, 0.6, new NowNowInstrument(349.23, 0.8, 1.6, 0.97, out));
  out.playNote(28.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.98, out));
  out.playNote(29.0, 0.6, new NowNowInstrument(349.23, 0.8, 1.5, 0.98, out));
  out.playNote(29.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.98, out));
  out.playNote(30.0, 0.6, new NowNowInstrument(349.23, 0.8, 1.4, 0.99, out));
  out.playNote(30.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.99, out));
  out.playNote(31.0, 0.6, new NowNowInstrument(349.23, 0.8, 1.3, 0.99, out));
  out.playNote(31.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.99, out));

  //---section 1-----------------------------------------------------------------------
  out.setNoteOffset( 36f );

  // The Brap and PooWah istruments almost always hit at the same time.
  // Here, I chose to intermix the instruments to be able to see the rhythm better.
  out.playNote(0.0, 1.8, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(0.0, 0.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(1.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(2.0, 0.4, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(2.0, 0.3, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(2.5, 1.8, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(2.5, 0.8, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(3.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(4.5, 0.3, new NowNowInstrument(349.23, 0.8, 0.3, out));
  out.playNote(5.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(6.0, 0.3, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(6.5, 0.3, new NowNowInstrument(349.23, 0.8, 0.3, out));
  out.playNote(7.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));

  out.playNote(8.0, 1.0, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(8.0, 1.0, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(10.0, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(10.5, 0.7, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(11.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(12.5, 0.9, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(13.5, 0.3, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(14.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, out));
  out.playNote(15.0, 0.3, new NowNowInstrument(349.23, 0.8, 0.8, out));

  out.playNote(16.0, 1.8, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(16.0, 0.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(16.5, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.6, out));
  out.playNote(17.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.6, out));
  out.playNote(17.5, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.6, out));
  out.playNote(17.67, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.6, out));
  out.playNote(17.83, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.7, out));
  out.playNote(18.0, 0.8, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(18.0, 0.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(18.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.7, out));
  out.playNote(19.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.7, out));
  out.playNote(20.0, 3.8, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(20.0, 0.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(20.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.8, out));
  out.playNote(21.0, 0.6, new NowNowInstrument(349.23, 0.8, 0.5, 0.8, out));
  out.playNote(21.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.8, out));
  out.playNote(22.0, 0.6, new NowNowInstrument(349.23, 0.8, 0.4, 0.9, out));
  out.playNote(22.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.9, out));
  out.playNote(23.0, 0.6, new NowNowInstrument(349.23, 0.8, 0.3, 0.9, out));
  out.playNote(23.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.9, out));
  
  out.playNote(24.0, 1.8, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(24.0, 0.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(24.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.96, out));
  out.playNote(25.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.96, out));
  out.playNote(25.5, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.96, out));
  out.playNote(25.67, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.96, out));
  out.playNote(25.83, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.97, out));
  out.playNote(26.0, 1.8, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(26.0, 0.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(26.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.97, out));
  out.playNote(27.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.97, out));
  out.playNote(28.0, 0.8, new PooWahInstrument(0.3, 133.3, 34.65, baseWave, out));
  out.playNote(28.0, 0.7, new BrapInstrument(0.08, 349.23, 0.010, 0.018, out));
  out.playNote(28.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.98, out));
  out.playNote(29.0, 0.8, new PooWahInstrument(0.3, 133.3, 43.65, baseWave, out));
  out.playNote(29.0, 0.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
  out.playNote(29.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.98, out));
  out.playNote(30.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.99, out));
  out.playNote(31.0, 0.6, new NowNowInstrument(349.23, 0.8, 1.3, 0.99, out));
  out.playNote(31.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.99, out));
 
  //---section 2------------------------------------------------------------------------------
  out.setNoteOffset( 68f );

  // This section uses a for loop to create a repeating pattern.
  // In this section I separated the PooWahs from the Braps.
  // I create a "snare" sound by removing the tone from the PooWah and shifting
  //   the base frequency up.
  for( int i=0; i<4; i++)
  {
    out.playNote(i*8+0.0, 1.8, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+1.0, 0.2, new PooWahInstrument(0.5, 233.3, 1396.91, noWave, out));
    out.playNote(i*8+2.0, 1.8, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+2.5, 0.2, new PooWahInstrument(0.5, 233.3, 1396.91, noWave, out));
    out.playNote(i*8+3.5, 0.8, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+4.5, 1.8, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+5.0, 0.2, new PooWahInstrument(0.5, 233.3, 1396.91, noWave, out));
    out.playNote(i*8+6.0, 0.4, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+6.5, 1.8, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+7.0, 0.2, new PooWahInstrument(0.5, 233.3, 1396.91, noWave, out));
  }
  
  // and here are the Braps which are much longer for this section.
  out.playNote(0.0, 7.0, new BrapInstrument(0.08, 349.23, 0.020, 0.003, out));
  out.playNote(7.0, 1.0, new BrapInstrument(0.08, 349.23, 0.010, 0.0015, out));
  out.playNote(8.0, 7.0, new BrapInstrument(0.08, 349.23, 0.012, 0.011, out));
  out.playNote(15.0, 1.0, new BrapInstrument(0.08, 349.23, 0.010, 0.0015, out));
  out.playNote(16.0, 7.0, new BrapInstrument(0.08, 349.23, 0.018, 0.005, out));
  out.playNote(23.0, 1.0, new BrapInstrument(0.08, 349.23, 0.010, 0.0015, out));
  out.playNote(24.0, 7.0, new BrapInstrument(0.16, 349.23, 0.004, 0.019, out));
  out.playNote(31.0, 1.0, new BrapInstrument(0.08, 349.23, 0.010, 0.0015, out));

  //---section 3--------------------------------------------------------------------------
  out.setNoteOffset( 100f );

  // Agoin, the for loop is used to create a repeated rhythm
  for( int i=0; i<4; i++)
  {
    out.playNote(i*8+0.0, 1.8, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+0.0, 1.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
    out.playNote(i*8+1.0, 0.2, new PooWahInstrument(0.5, 233.3, 1396.91, noWave, out));
    out.playNote(i*8+2.0, 1.8, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+2.0, 1.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
 
    // This time, however, part 0 and 2 of this section are given an extra PooWah 
    if (( 0 == i ) || ( 2 == i ) )
    {
      out.playNote(i*8+3.0, 0.2, new PooWahInstrument(0.5, 233.3, 1396.91, noWave, out));
    }
  
    out.playNote(i*8+4.5, 1.8, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+4.5, 1.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
    out.playNote(i*8+5.0, 0.2, new PooWahInstrument(0.5, 233.3, 1396.91, noWave, out));
    out.playNote(i*8+6.0, 0.4, new PooWahInstrument(0.4, 133.3, 43.65, baseWave, out));
    out.playNote(i*8+6.5, 1.7, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));
    out.playNote(i*8+7.0, 0.2, new PooWahInstrument(0.5, 233.3, 1396.91, noWave, out));
  }

  // The NowNows are listed here separately from the repeated rhythm.
  // Using a single variable, bc, allows me to change the "bitCrush" parameter
  //   across a large group of instrument calls. 
  float bc = 4.0;
  out.playNote(0.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(0.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(1.5, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(2.5, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(3.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(4.0, 0.4, new NowNowInstrument(349.00, 0.8, 0.9, 0.5, bc, out));
  out.playNote(5.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(6.5, 0.8, new NowNowInstrument(349.00, 0.8, 0.8, 0.5, bc, out));
  out.playNote(7.5, 0.4, new NowNowInstrument(349.22, 0.8, 1.0, 0.5, bc, out));
  
  out.playNote(8.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(8.5, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(9.5, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.5, bc, out));
  out.playNote(9.67, 0.8, new NowNowInstrument(349.00, 0.8, 0.5, 0.5, bc, out));
  out.playNote(9.83, 0.8, new NowNowInstrument(349.23, 0.8, 0.5, 0.5, bc, out));
  out.playNote(10.0, 0.8, new NowNowInstrument(349.63, 0.8, 1.0, 0.5, bc, out));
  out.playNote(11.0, 0.9, new NowNowInstrument(698.46, 0.7, 0.7, 1.0, 2.7, out));
  out.playNote(12.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(13.0, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(13.33, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(13.67, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(14.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  out.playNote(15.0, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.5, bc, out));
  
  bc = 3.5;
  out.playNote(16.0, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, 0.6, bc, out));
  out.playNote(17.5, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, 0.6, bc, out));
  out.playNote(18.5, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, 0.7, bc, out));
  out.playNote(19.5, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, 0.7, bc, out));
  out.playNote(20.0, 0.2, new NowNowInstrument(349.23, 0.8, 0.6, 0.7, bc, out));
  out.playNote(20.5, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, 0.8, bc, out));
  out.playNote(21.5, 1.8, new NowNowInstrument(350.03, 0.8, 1.0, 0.8, bc, out));
  out.playNote(22.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.9, bc, out));
  out.playNote(23.5, 0.2, new NowNowInstrument(349.23, 0.8, 1.0, 0.9, bc, out));
  
  bc = 3.0;
  out.playNote(24.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.96, bc, out));
  out.playNote(25.0, 0.4, new NowNowInstrument(349.23, 0.8, 1.0, 0.96, bc, out));
  out.playNote(25.5, 0.1, new NowNowInstrument(349.23, 0.8, 0.5, 0.96, bc, out));
  out.playNote(26.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.97, bc, out));
  out.playNote(27.5, 0.8, new NowNowInstrument(349.23, 0.8, 1.0, 0.97, bc, out));
  out.playNote(28.0, 1.6, new NowNowInstrument(349.03, 0.8, 1.6, 0.97, bc, out));
  out.playNote(28.5, 1.0, new NowNowInstrument(349.23, 0.8, 1.0, 0.98, bc, out));
  out.playNote(29.0, 0.6, new NowNowInstrument(349.99, 0.8, 1.5, 0.98, bc, out));
  out.playNote(29.5, 0.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.98, bc, out));
  out.playNote(30.5, 1.6, new NowNowInstrument(349.23, 0.8, 1.0, 0.99, bc, out));

  // This is a set of Braps that I wanted to be able to automatically change the 
  // parameters of over the course of half the section.  The idea vas to switch
  // between an on-the-beat to a synchopated feel.
  float totLen = 0.0286;
  float endSpace = 0.01;
  float n = 16.0;
  for ( int i = 0; i < n; i++ )
  {
    float onTime = ( i/n )*( totLen - 2*endSpace ) + endSpace;
    float offTime = totLen - onTime;
    out.playNote(16+i+0.0, 0.1, new BrapInstrument(0.2, 349.23, onTime, offTime, out));
    out.playNote(16+i+0.5, 0.1, new BrapInstrument(0.2, 349.23, offTime, onTime, out));        
  }

  // This is the final sound that ends the rhythm
  //---section 4--------------------------------------------------------------------------
  out.setNoteOffset( 132f );

  // one hit
  out.playNote(0.0, 7.8, new PooWahInstrument(0.2, 133.3, 43.65, baseWave, out));
  out.playNote(0.0, 3.8, new BrapInstrument(0.08, 349.23, 0.010, 0.013, out));

  // a low tone made by the NowNow
  out.playNote(0.0, 7.0, new NowNowInstrument(43.65, 0.8, 1.0, 0.1, out));

  // and a bunch of repetitive Braps that die out
  out.playNote(0.05, 8.0, new BrapInstrument(0.06, 349.23, 0.1, 0.2, out));
  out.playNote(0.01, 6.0, new BrapInstrument(0.06, 349.23, 0.050, 0.05, out));
  out.playNote(0.02, 5.0, new BrapInstrument(0.05, 349.23, 0.020, 0.03, out));
  out.playNote(0.03, 4.5, new BrapInstrument(0.05, 349.23, 0.010, 0.02, out));
  out.playNote(0.04, 4.0, new BrapInstrument(0.05, 349.23, 0.005, 0.01, out));
 
  // finally, resume time after adding all of these notes at once.
  out.resumeNotes();
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
}