// The BrapInstrument is intended to give a chopped up mixture of tone and noise.

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class BrapInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Oscil toneOsc, fmOsc;
  ADSR  adsr;
  Noise pinkNoise;
  Constant fmConstant;
  Summer sum, fmSummer;
  GranulateSteady chopper;
  AudioOutput out;
  
  // the constructor for this instrument specifies the amplitude of the output,
  // the frequency of the tone, and the on and off time of the granulating gate
  BrapInstrument( float amp, float toneFreq, float onTime, float offTime, AudioOutput output )
  {
    // equate class variables to constructor variables as necessary 
    out = output;
    
    // create new instances of any UGen objects as necessary
    toneOsc = new Oscil( toneFreq, amp, Waves.TRIANGLE );
    // a little frequency modulation for added harmonics never hurt anyone, right?
    fmOsc = new Oscil( toneFreq/2.0, toneFreq/2.0, Waves.SAW );
    fmConstant = new Constant( toneFreq );
    fmSummer = new Summer();
    
    pinkNoise = new Noise( amp/3.0, Noise.Tint.PINK);
    adsr = new ADSR( 1.0, 0.003, 0.003, 1.0, 0.003 );
    chopper = new GranulateSteady( onTime, offTime, 0.0025 );
    sum = new Summer();
    
    // patch everything together up to the final output 
    // put some freq modulation on the tone
    fmOsc.patch( fmSummer );
    fmConstant.patch( fmSummer );
    fmSummer.patch( toneOsc.frequency ); 
    
    // put both the tone and the noise into the summer
    toneOsc.patch( sum );
    pinkNoise.patch( sum );
    // pass the summer through a granulating gate to the adsr
    sum.patch( chopper ).patch( adsr );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // patch the adsr all the way to the output 
    adsr.patch( out );
    // and turn it on
    adsr.noteOn();
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    // turn off adsr, which cause the release to begin
    adsr.noteOff();
    // after the release is over, unpatch from the ou
    adsr.unpatchAfterRelease( out );
  }
}
