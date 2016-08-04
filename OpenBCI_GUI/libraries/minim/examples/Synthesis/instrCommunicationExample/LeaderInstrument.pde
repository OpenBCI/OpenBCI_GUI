// The LeaderInstrument plays a tone and tells the FollowInstrument what frequency
// to play.

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class LeaderInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Oscil toneOsc;
  ADSR  adsr;
  FollowInstrument follow;
  AudioOutput out;
  float frequency;
  
  // the class constructor specifies the amplitude, frequency, following insturment, and
  // audioOutput.
  LeaderInstrument( float amplitude, float frequency, FollowInstrument follow, AudioOutput out )
  {
    // equate class variables to constructor variables as necessary 
    this.out = out;
    this.follow = follow;
    // the real frequency is actually an octave high
    frequency *= 2.0;
    this.frequency = frequency;

    // create new instances of the UGen objects necessary
    toneOsc = new Oscil( frequency, amplitude, Waves.triangle(7) );
    adsr = new ADSR( 1.0, 0.1, 0.1, 1.0, 0.1 );

    // patch all the way up to the final output
    toneOsc.patch( adsr );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn(float dur)
  {
    // patch the adsr all the way to the output
    adsr.patch( out );
    // turn on the ADSR 
    adsr.noteOn();
    // if there is a follow instrument, tell it a new frequency
    if ( null != follow )
    {
      follow.setNewFreq( frequency );
    }
  }

  // every instrument must have a noteOff() method
  void noteOff()
  {
    // turn off adsr, which cause the release to begin
    adsr.noteOff();
    // after the release is over, unpatch from the out
    adsr.unpatchAfterRelease( out );
  }
}  

