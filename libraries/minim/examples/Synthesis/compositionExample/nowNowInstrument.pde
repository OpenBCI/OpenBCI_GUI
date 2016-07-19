// The NowNowInstrument is intended to create a nasaly tonal sound.

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class NowNowInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Oscil sineOsc;
  ADSR  adsr;
  Summer sum;
  BitCrush crush;
  Multiplier multiplyLo, multiplyHi;
  IIRFilter bpFilt1, bpFilt2;
  AudioOutput out;
  
  // This instrument has several constructors.  This is done because as I was building
  // the composition and the instrument, I had realized that I wanted to add some features
  // to the instrument.  I simply made a different constructor with a different (usually
  // expanded) signature.  The main constructor is the last one, and all of those before it
  // call the main constructor with some automatic values for some variables.
  NowNowInstrument( float frequency, float amplitude, float tweak, AudioOutput output )
  {
    this(frequency, amplitude, tweak, 0.5, 16.0, output);
  }
  NowNowInstrument(float frequency, float amplitude, float tweak, float high, AudioOutput output)
  {
    this( frequency, amplitude, tweak, high, 16.0, output );
  }
  // This is the main constructor for this instrument and specifies the frequency of the tone,
  // the amplitude of the note, how "tweaked" the tone should be (just affects the CF Q of the 
  // filters), the balance toward the higher of two filters, the bit resolution for bit crushing,
  // and finally the AudioOutput
  NowNowInstrument(float frequency, float amplitude, float tweak, float high, float bitRes, AudioOutput output)
  {
    // equate class variables to constructor variables as necessary
    out = output;
    
    // Some calculations are necessary before creating UGens to get the correct values.
    amplitude = 0.7*amplitude;
    // I want a little bit of randomness in these instruments, too.
    float cf1 = frequency*( 1+( (float)Math.random() - 0.5 ) ) * tweak;
    float cf2 = cf1*10.0*tweak;
    float bw1 = 1.0*cf1*tweak;
    float bw2 = bw1*( 2 + ( (float)Math.random() ) )*tweak;
 
    // create new instances of any UGen objects as necessary
    sineOsc = new Oscil( frequency, amplitude, Waves.SAW );
    adsr = new ADSR( 0.5, 0.005, 0.01, 0.5, 0.2 );
    bpFilt1 = new BandPass( cf1, bw1, out.sampleRate() );
    bpFilt2 = new BandPass( cf2, bw2, out.sampleRate() );
    multiplyLo = new Multiplier( 2*( 1 - high ) );
    multiplyHi = new Multiplier( 2*high);
    crush = new BitCrush( bitRes, out.sampleRate() );
    sum = new Summer();
    
    // patch everything togethe up to the final output
    // basically the sawtooth oscilator goes through two filters
    sineOsc.patch(bpFilt1).patch(multiplyLo).patch(sum);
    sineOsc.patch(bpFilt2).patch(multiplyHi).patch(sum);
    // then the sum of those goes through bit crushing and into an ADSR
    sum.patch(crush).patch(adsr);
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
    // after the release is over, unpatch from the out
    adsr.unpatchAfterRelease( out );
  }
}

