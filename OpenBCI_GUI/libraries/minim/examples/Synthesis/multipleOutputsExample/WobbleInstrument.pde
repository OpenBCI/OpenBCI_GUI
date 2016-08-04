// this instrument uses a single LFO to control the amplitude of one sine
// and the frequency modulation of another.
class WobbleInstrument implements Instrument
{
  // our two tones and LFO
  Oscil sine1, sine2, LFO;
  // a multiply that will be applied to the LFO before it is used for frequency modulation
  Multiplier  multiplyLFO;
  // the center frequency around which the LFO will modulate the frequency of sine2
  Constant LFOfreq;
  // a Summer to add together the LFO center frequency with the modulation amount
  Summer LFOsum;
  AudioOutput out;
  
  WobbleInstrument(float frequency, float amplitude, float lFOFreq, AudioOutput output)
  {
    out = output;
    sine1 = new Oscil(frequency, amplitude, Waves.SINE);
    sine2 = new Oscil(frequency*2.0, amplitude, Waves.SINE);
    LFO = new Oscil( lFOFreq/2.0, 0.5f, Waves.SINE );
    // to get the second oscillator to have a large frequency wobble, we need to increase the
    // multiply of the LFO a lot.
    multiplyLFO = new Multiplier(60.0);
    // our center frequency is the same as the frequency of sine2
    LFOfreq = new Constant( frequency * 2.0 );
    LFOsum = new Summer();
 
    // control the amplitude of sine1
    LFO.patch( sine1.amplitude );
    // LFO also goes to the LFOsum
    LFO.patch(multiplyLFO).patch( LFOsum );
    // along with the center frequency
    LFOfreq.patch( LFOsum );
    // and then the sum into the frequency of sine2
    LFOsum.patch( sine2.frequency );
  }
  
  void noteOn(float dur)
  {
    sine1.patch( out );
    sine2.patch( out );
  }
  
  void noteOff()
  {
    sine1.unpatch( out );
    sine2.unpatch( out );
  }
}
