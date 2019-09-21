import edu.ucsd.sccn.LSL;

LSL.StreamInfo info;
LSL.StreamOutlet outlet;
float[] sample;

void setup() { 
  size (300, 100);

  println("Creating a new StreamInfo...");
  info = new LSL.StreamInfo("BioSemi", "EEG", 8, 60, LSL.ChannelFormat.float32, "myuid324457");

  println("Creating an outlet...");
  outlet = new LSL.StreamOutlet(info);

  println("Sending data...");
  sample = new float[8];
} 

void draw() { 
  for (int k=0; k<8; k++) {
    sample[k] = (float)Math.random()*50-25;
  }
  outlet.push_sample(sample);
}

void dispose() {
  println("Closing stream...");
  outlet.close();
  info.destroy();
}

