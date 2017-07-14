import edu.ucsd.sccn.LSL;

LSL.StreamInfo[] results;
LSL.StreamInlet inlet;
float[] sample;

void setup() { 
  size (300, 100);

  println("Resolving an EEG stream...");
  // NB: blocking until at least on stream is found
  results = LSL.resolve_stream("type", "EEG");

  println("Number of streams found: " + results.length);

  // open an inlet
  inlet = new LSL.StreamInlet(results[0]);

  try {
    sample = new float[inlet.info().channel_count()];
  }
  catch(Exception e) {
    println("Error: Can't open a stream!");
    exit();
  }
} 

void draw() { 
  println("-- FPS: " + frameRate + " --");
  try {
    // NB: blocking call, FPS will drop to stream's sample rate
    inlet.pull_sample(sample);
  }
  catch(Exception e) {
    println("Error: Can't get a sample!");
    exit();
  }

  for (int k=0; k<sample.length; k++)
    print("\t" + Double.toString(sample[k]));
  println();
}

