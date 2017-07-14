/**
  * This sketch demonstrates how to use the <code>getFormat</code> method of a <code>Recordable</code> class. 
  * The class used here is <code>AudioOutput</code>, but you can also get the format of <code>AudioInput</code>, 
  * <code>AudioPlayer</code>, and <code>AudioSample</code> objects. The <code>getFormat</code> method returns 
  * an object of type <code>AudioFormat</code> which is a class defined in the JavaSound API. An <code>AudioFormat</code>
  * is a container for information about an audio source, such as the framerate, encoding and so forth. The following 
  * methods are available on an <code>AudioFormat</code> object and all are demonstrated in this sketch.
  * 
  * <pre>
    int getChannels()
      Obtains the number of channels.
       
    AudioFormat.Encoding getEncoding()
      Obtains the type of encoding for sounds in this format.
      
    float getFrameRate()
      Obtains the frame rate in frames per second.

    int getFrameSize()
      Obtains the frame size in bytes.
      
    float getSampleRate()
      Obtains the sample rate.
      
    int getSampleSizeInBits()
      Obtains the size of a sample.
      
    boolean isBigEndian()
      Indicates whether the audio data is stored in big-endian or little-endian byte order.

    boolean matches(AudioFormat format)
      Indicates whether this format matches the one specified.
      
    String toString()
      Returns a string that describes the format, such as: "PCM SIGNED 22050 Hz 16 bit mono big-endian".
    </pre>
  */

import ddf.minim.*;

Minim minim;
AudioOutput out;

void setup()
{
  size(760, 140, P3D);
  textFont(loadFont("CourierNewPSMT-12.vlw"));

  minim = new Minim(this);
  // this should give us a stereo output with a 1024 sample buffer, 
  // a sample rate of 44100 and a bit depth of 16
  out = minim.getLineOut();
}

void draw()
{
  background(0);
  text("The output has " + out.getFormat().getChannels() + " channels.", 5, 15);
  text("The output's encoding is " + out.getFormat().getEncoding() + ".", 5, 30);
  text("The output's frame rate is " + out.getFormat().getFrameRate() + " frames per second.", 5, 45);
  text("The output's frame size is " + out.getFormat().getFrameSize() + " bytes.", 5, 60);
  text("The output's sample rate is " + out.getFormat().getSampleRate() + " Hz.", 5, 75);
  text("The output's sample size is " + out.getFormat().getSampleSizeInBits() + " bits.", 5, 90);
  String endianess = out.getFormat().isBigEndian() ? "big-endian" : "little-endian";
  text("The output's byte order is " + endianess + ".", 5, 105);
  text("The output's format as a string is " + out.getFormat(), 5, 120);
}