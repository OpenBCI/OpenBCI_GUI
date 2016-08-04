// The MidiSlideInstrument is intended to slide between two pitches
// specified in midi note number.  This only plays out of one channel
// (ostensibly the left ).

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class MidiSlideInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Multiplier  gate;
  Line  freqControl;
  
  // constructor for this instrument
  MidiSlideInstrument(float begNote, float endNote, float amp)
  {
    // create new instances of the UGens necessary
    gate = new Multiplier( 0 );
    Oscil tone = new Oscil( begNote, amp, Waves.TRIANGLE );
    freqControl = new Line( 1.0, begNote, endNote );
    Midi2Hz midi2Hz = new Midi2Hz();
    Balance left = new Balance( -1 );

    // and patch everything together up to the final output
    freqControl.patch( midi2Hz ).patch( tone.frequency );
    tone.patch( left ).patch( gate );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // set the time for the line with the duration of the note
    freqControl.setLineTime( dur );
    // activate the line
    freqControl.activate();
    // set the gate on
    gate.setValue( 1 );
    // and patch it to the output
    gate.patch( out );
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    // turn off the gain
    gate.setValue( 0 );
    // and unpatch the output 
    // this causes the entire instrument to stop calculating sampleframes
    // which is good when the instrument is no longer generating sound.
    gate.unpatch( out );
  }
}

