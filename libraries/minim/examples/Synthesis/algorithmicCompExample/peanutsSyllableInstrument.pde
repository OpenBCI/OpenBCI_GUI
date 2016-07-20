// The PeanutsSyllableInstrument is intended to create a syllable in a style
// reminiscent of the old peanuts cartoons.

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class PeanutsSyllableInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Oscil toneOsc;
  ADSR adsr;
  ADSR upDown;
  Constant one;
  Balance balance;
  Summer sum;
  AudioOutput out;
  IIRFilter lpFiltFixed, lpFilterSlide, bpFilter1, bpFilter2;
  float fadeTime;

  // create a bunch of constants   
  float lpFixedLoFreq = 523.0;
  float lpFixedHiFreq = 848.0;
  float bp1LoFreq = 2297.0;
  float bp1HiFreq = 2820.0;
  float bp1BW = 750.0;  
  float bp2LoFreq = 3147.0;
  float bp2HiFreq = 4500.0;
  float bp2BW = 500.0;
  float slideHeightMin = 999.0;
  float slideHeightMax = 2786.0; 
  float slideHeight;
  
  // the constructor specifies the amplitude, tone frequency, time of fade, stereo position,
  // base waveform, and audio output for the class
  PeanutsSyllableInstrument( float amp, float toneFreq, float fadeTime, float balanceVal, 
     Wavetable baseWave, AudioOutput output )
  {
    // equate class variables to constructor variables as necessary 
    out = output;
    this.fadeTime = fadeTime;
    
    // calculate/generate some values for the UGens
    float lpFixedFreq = lpFixedLoFreq + (float)Math.random()*( lpFixedHiFreq - lpFixedLoFreq );
    float bp1Freq = bp1LoFreq + (float)Math.random()*( bp1HiFreq - bp1LoFreq );
    float bp2Freq = bp2LoFreq + (float)Math.random()*( bp2HiFreq - bp2LoFreq );
    slideHeight = slideHeightMin + (float)Math.random()*( slideHeightMax - slideHeightMin );

    // create new instances of any UGen objects as necessary
    toneOsc = new Oscil( toneFreq, amp, baseWave );
    // set an overall ADSR so it has a nice fade in and out
    adsr = new ADSR( 1.0, fadeTime, 0.0, 1.0, fadeTime );
    // set up an ADSR to control the sliding sliding filter
    // the actual parameters will be set in noteOn()
    upDown = new ADSR( 1000.0, 1.0, 1.0, 0.1, 1.0 );
    one = new Constant( 1.0 );
    balance = new Balance( balanceVal );
    lpFiltFixed = new LowPassSP( lpFixedFreq, out.sampleRate() );
    lpFilterSlide = new LowPassSP( 1000.0, out.sampleRate() );
    // these filters somewhat simulate formants
    bpFilter1 = new BandPass( bp1Freq, bp1BW, out.sampleRate() );
    bpFilter2 = new BandPass( bp2Freq, bp2BW, out.sampleRate() );
    sum = new Summer();
  
    // patch everything together up to the final output
    // set up the fixed filters
    toneOsc.patch( lpFiltFixed ).patch( sum );
    toneOsc.patch( bpFilter1 ).patch( sum );
    toneOsc.patch( bpFilter2 ).patch( sum );
    // the constant patched into an ADSR gives a cutoff freq for the sliding filter
    one.patch( upDown ).patch( lpFilterSlide.cutoff );
    // take the previous sum, filter and balance it, then send it to the ADSR  
    sum.patch( lpFilterSlide ).patch( balance ).patch( adsr );
  }
 
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // the duration is used to determine parameters for the upDown ADSR
    float halfTime = dur/2.0;
    upDown.setParameters( slideHeight, halfTime, halfTime+2*fadeTime, 0.0, 1.0, 0.0, 0.0 ); 
    // patch the adsr all the way to the output 
    adsr.patch(out);
    // turn on the ADSR
    adsr.noteOn();
    // and the upDown ADSR
    upDown.noteOn();
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    // turn off the upDown ADSR.  This should fall to zero at the right
    // time, but it's best practice to turn it off.
    upDown.noteOff();
    // turn off adsr, which cause the release to begin
    adsr.noteOff();
    // after the release is over, unpatch from the out
    adsr.unpatchAfterRelease( out );
  }
}
