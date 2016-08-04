// This NumberInstrument just plays a single sine wave, but takes in an integer to
// be able to print which instrument it is.  Just for giggles, it also prints the
// frequency and amplitude of the note as it starts.

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class NumberInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Oscil sineOsc, lFOOsc;
  Multiplier  multiply;
  AudioOutput out;
  int iNote;
  float amp;
  float freq;
  
  // constructor for this instrument
  NumberInstrument(float frequency, float amplitude, int iN, AudioOutput output)
  {
    // equate class variables to constructor variables as necessary
    out = output;
    iNote = iN;
    amp = amplitude;
    freq = frequency;
    
    // create new instances of any UGen objects as necessary
    sineOsc = new Oscil(frequency, amplitude, Waves.SINE);
    multiply = new Multiplier(0);

    // patch everything together up to the final output
    sineOsc.patch(multiply);
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn(float dur)
  {
    // want to print information about this instrument
    println("Instron number " + iNote + "   amp = " + amp + "   freq = " + freq );
    // turn on the gain
    multiply.setValue(1.0);
    // and patch to the output
    multiply.patch(out);
  }
  
  // every instrument must have a noteOff method
  void noteOff()
  {
    // print that we're turning this off
    println("Instroff number " + iNote );
    // turn the gain to 0
    multiply.setValue(0);
    // and unpatch it
    multiply.unpatch( out );
  }
}
