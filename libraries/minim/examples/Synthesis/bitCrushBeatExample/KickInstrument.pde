// this KickInstrument will make a sound that is like an analog kick drum
class KickInstrument implements Instrument
{
  // our kick sound is just an sine wave
  Oscil sineOsc;
  // which we will quickly sweep the frequency of using this line
  Line  freqLine;
  // we'll patch to a summer
  Summer out;
  
  KickInstrument( Summer output )
  {
    out = output;
    sineOsc = new Oscil(100.f, 0.5f, Waves.SINE);
    freqLine = new Line( 0.08f, 200.f, 50.f );
    
    // patch the line to the frequency of the osc
    freqLine.patch( sineOsc.frequency );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn(float dur)
  {
    // patch our oscil to the summer we were given and start the line
    freqLine.activate();
    sineOsc.patch(out);
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    sineOsc.unpatch(out);
  }
}
