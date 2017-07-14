/* waveShaperExample<br/>
   is an example of using the WaveShaper UGen inside an instrument.
   <p>
   For more information about Minim and additional features, 
   visit http://code.compartmental.net/minim/
   <p>   
   author: Damien Di Fede, Anderson Mills<br/>
   Anderson Mills's work was supported by numediart (www.numediart.org).
*/

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*; // for BandPass

Minim minim;
AudioOutput out;

// setup is run once at the beginning
void setup()
{
  // initialize the drawing window
  size( 512, 200, P2D );
  
  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );
  
  // pause time when adding a bunch of notes at once
  out.pauseNotes();

  // one can set the tempo of the piece in beats per minute, too
  out.setTempo( 120f );
  
  // our chik sounds won't overlap, so we can reuse the same instance
  ChikInstrument chik = new ChikInstrument( out );
  float chikDur = 0.1f;
  
  float shaperAmp = 0.5f;
  // let's do a few repeats of this pattern
  for(int i = 0; i < 4; i++)
  {
    // first set the note offset so we put notes in the right measure
    out.setNoteOffset( i * 8 );
    
    // and now notes!
    out.playNote( 0.f, chikDur, chik );
    out.playNote( 0.f, 1.0f, new WaveShaperInstrument( Frequency.ofPitch("C2").asHz(), shaperAmp, out ) );
    out.playNote( 1.f, chikDur, chik );
    out.playNote( 2.f, chikDur, chik );
    out.playNote( 3.f, chikDur, chik );
    
    out.playNote( 4.f, 1.0f, new WaveShaperInstrument( Frequency.ofPitch("C2").asHz(), shaperAmp, out ) );
    out.playNote( 4.f, chikDur, chik );
    out.playNote( 5.f, chikDur, chik );
    out.playNote( 5.5f, 1.0f, new WaveShaperInstrument( Frequency.ofPitch("Eb2").asHz(), shaperAmp, out ) );
    out.playNote( 6.f, chikDur, chik );
    out.playNote( 7.f, chikDur, chik );
    out.playNote( 7.f, 1.0f, new WaveShaperInstrument( Frequency.ofPitch("Eb2").asHz(), shaperAmp, out ) );
  }
  // one last hit!
  out.playNote( 8.f, chikDur, chik );
  out.playNote( 8.f, 8.0f, new WaveShaperInstrument( Frequency.ofPitch("C1").asHz(), shaperAmp, out ) );
  
  // resume notes after you enter a bunch
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
    line( x1, 50  - out.left.get(i)*50,  x2, 50  - out.left.get(i+1)*50);
    line( x1, 150 - out.right.get(i)*50, x2, 150 - out.right.get(i+1)*50);
  }  
}

// this ChikInstrument will make a "chik" sound
class ChikInstrument implements Instrument
{
  // to make a chik sound we'll just filter some noise
  Noise noize;
  BandPass bpFilt;
  AudioOutput out;
  
  ChikInstrument( AudioOutput output )
  {
    out = output;
    
    // amplitude and noise tint
    noize = new Noise( 1.f, Noise.Tint.WHITE);
    
    // make a bandpass with center frequency of 400Hz, bandwidth of 20Hz and sample rate of 44100.
    bpFilt = new BandPass( 1000.f, 200.f, 44100.f );
    
    // patch the noise through the filter
    noize.patch( bpFilt );
  }
  
  // called by the note manager when this instrument should play
  void noteOn(float dur)
  {
    bpFilt.patch(out);
  }
  
  // called by the note manager when this instrument should stop playing
  void noteOff()
  {
    bpFilt.unpatch(out);
  }
}

// this instrument uses a WaveShaper to shape an Oscil
// over time.
class WaveShaperInstrument implements Instrument
{
  // our tone
  Oscil sineOsc;
  // what we'll shape our oscil with
  WaveShaper shaper;
  // a line to change the amount of shaping over time
  Line shaperAmountLine;
  // and a reciprocal to change the output amplitude over time
  Reciprocal reciprocal;
  
  AudioOutput out;

  WaveShaperInstrument(float frequency, float amplitude, AudioOutput output)
  {
    out = output;
    sineOsc = new Oscil(frequency, amplitude, Waves.SINE);
    // We've created three different waves to shape the sine with.  Just uncomment
    // one of the "shaper =" lines to hear the different waves.
    // The first is a modified saw wave.  We made this while we were experimenting
    // with the WaveShaper and liked it, so it remains.
    Wavetable shapeA = new Wavetable( Waves.SAW );
    shapeA.set(0, -1.0);
    shapeA.set(shapeA.size()-1, 1.0);
    // The second argument in WaveShaper
    // is the amount of shaping to be applied, which in our case doesn't 
    // really matter because we are going to drive that with a Line.
    shaper = new WaveShaper(amplitude, 5, shapeA);
    
    // If we want to shape the sine with a saw wave... 
    //shaper = new WaveShaper( amplitude, 5, Waves.SAW );
    
    // We can choose to wrap around the ends of the waveshaping map for interesting
    // effects, and one does this by setting the fourth argument to true.
    //shaper = new WaveShaper( amplitude, 5, Waves.SAW, true );
    
    shaperAmountLine = new Line(5.f, 1.f, 25.f);
    reciprocal = new Reciprocal();
   
    // patch the line into the mapAmplitude of the WaveShaper
    shaperAmountLine.patch( shaper.mapAmplitude );
    // Patch the reciprocal of the line into the outAmplitude.
    // Since the line goes from 1 to 25, the reciprocal goes from 1/1 to 1/25.
    // This creates a pretty good approximation of a drum envelope.
    shaperAmountLine.patch( reciprocal ).patch( shaper.outAmplitude );
    sineOsc.patch( shaper );
  }
 
  void noteOn(float dur)
  {
    // set our line time based on duration
    shaperAmountLine.setLineTime( dur );
    shaperAmountLine.activate();
    shaper.patch( out );
  }
  
  void noteOff()
  {
    shaper.unpatch( out );
  }
}

