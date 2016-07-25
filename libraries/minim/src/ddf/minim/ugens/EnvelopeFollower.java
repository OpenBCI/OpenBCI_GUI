package ddf.minim.ugens;

import ddf.minim.UGen;

//An envelope follower implementation I found on the internets: http://www.musicdsp.org/showone.php?id=97

/** 
 * An EnvelopeFollower will analyze the audio coming into it and output a value that reflects 
 * the volume level of that audio. It is similar to what AudioBuffer's level method provides, 
 * but has the advantage of being able to be inserted into the signal chain anywhere.
 * 
 * You may find that you are only interested in the output value of the EnvelopeFollower for 
 * visualization purposes, in which case you can use a Sink UGen to tick the EnvelopeFollower
 * without generating any sound. The following example demonstrates this technique.
 * 
 * We still consider EnveloperFollower to be a bit experimental, so YMMV.
 * 
 * @example Synthesis/envelopeFollowerExample
 * 
 * @related UGen
 * 
 */
public class EnvelopeFollower extends UGen
{ 
	/**
	 * Where incoming audio is patched.
	 * 
	 * @related EnvelopeFollower
	 * @related UGen.UGenInput
	 */
	public UGenInput audio;
  
  // attack and release time in seconds
  private float m_attack;
  private float m_release;
  
  // coefficients for our envelope following algorithm
  private float m_ga, m_gr;
  // for collecting a buffer to calculate the envelope value
  private float[] m_buffer;
  // to keep track of how full our buffer is.
  // when it fills all the way up, we calculate a value
  // and then go back to filling.
  private int     m_bufferCount;
  // the current value of the envelope
  private float m_envelope;
  // the previous value of the envelope
  private float m_prevEnvelope;
  
  /**
   * Construct an EnvelopeFollower.
   * 
   * @param attackInSeconds
   * 			float: how many seconds the follower should take to ramp up to a higher value
   * @param releaseInSeconds
   * 			float: how many seconds the follower should take to ramp down to a lower value
   * @param bufferSize
   * 			int: how many samples should be analyzed at once. smaller buffers will make
   * 				 the follower more responsive.
   */
  public EnvelopeFollower( float attackInSeconds, float releaseInSeconds, int bufferSize )
  {
    m_attack = attackInSeconds;
    m_release = releaseInSeconds;
    m_buffer = new float[bufferSize];
    m_bufferCount = 0;
    m_envelope = 0.f;
    m_prevEnvelope = 0.f;
    
    audio = new UGenInput( InputType.AUDIO );
  }
  
  protected void sampleRateChanged()
  {
    m_ga = (float)Math.exp( -1 / (sampleRate() * m_attack) );
    m_gr = (float)Math.exp( -1 / (sampleRate() * m_release) );
  }
  
  protected void uGenerate( float[] out )
  {
    // mono-ize the signal
    float signal = 0;
    float[] lastValues = audio.getLastValues();
    for(int i = 0; i < lastValues.length; ++i)
    {
      signal += lastValues[i] / lastValues.length;
    }
    
    m_buffer[m_bufferCount++] = signal;

    // full buffer, find the envelope value
    if ( m_bufferCount == m_buffer.length )
    {
      m_prevEnvelope = m_envelope;
      m_envelope = 0.f;
      
      for(int i = 0; i < m_buffer.length; ++i )
      {
        float envIn = Math.abs( m_buffer[i] );
        if ( m_envelope < envIn )
        {
          m_envelope *= m_ga;
          m_envelope += (1-m_ga)*envIn;
        }
        else
        {
          m_envelope *= m_gr;
          m_envelope += (1-m_gr)*envIn;
        }
      }
      
      m_bufferCount = 0;
    }
    
    // lerp between previous value and current value
    float outEnv = m_prevEnvelope + (m_envelope - m_prevEnvelope) * ( (float)m_bufferCount / (float)m_buffer.length );
    for (int i = 0; i < out.length; i++)
    {
      out[i] = outEnv;
    }
  }
}
