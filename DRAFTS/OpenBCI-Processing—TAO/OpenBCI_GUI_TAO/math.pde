
//compute the standard deviation
float std(float[] data) {
  //calc mean
  float ave = mean(data);
  
  //calc sum of squares relative to mean
  float val = 0;
  for (int i=0; i < data.length; i++) {
    val += pow(data[i]-ave,2);
  }
  
  // divide by n to make it the average
  val /= data.length;
  
  //take square-root and return the standard
  return (float)Math.sqrt(val);
}


float mean(float[] data) {
  return mean(data,data.length);
}

int medianDestructive(int[] data) {
  sort(data);
  int midPoint = data.length / 2;
  return data[midPoint];
}
  

//////////////////////////////////////////////////
//
// Some functions to implement some math and some filtering.  These functions
// probably already exist in Java somewhere, but it was easier for me to just
// recreate them myself as I needed them.
//
// Created: Chip Audette, Oct 2013
//
//////////////////////////////////////////////////

int findMax(float[] data) {
  float maxVal = data[0];
  int maxInd = 0;
  for (int I=1; I<data.length; I++) {
    if (data[I] > maxVal) {
      maxVal = data[I];
      maxInd = I;
    }
  }
  return maxInd;
}

float mean(float[] data, int Nback) {
  return sum(data,Nback)/Nback;
}

float sum(float[] data) {
  return sum(data, data.length);
}

float sum(float[] data, int Nback) {
  float sum = 0;
  if (Nback > 0) {
    for (int i=(data.length)-Nback; i < data.length; i++) {
      sum += data[i];
    }
  }
  return sum;
}

float calcDotProduct(float[] data1, float[] data2) {
  int len = min(data1.length, data2.length);
  float val=0.0;
  for (int I=0;I<len;I++) {
    val+=data1[I]*data2[I];
  }
  return val;
}
  

float log10(float val) {
  return (float)Math.log10(val);
}

float filterWEA_1stOrderIIR(float[] filty, float learn_fac, float filt_state) {
  float prev = filt_state;
  for (int i=0; i < filty.length; i++) {
    filty[i] = prev*(1-learn_fac) + filty[i]*learn_fac;
    prev = filty[i]; //save for next time
  }
  return prev;
}

void filterIIR(double[] filt_b, double[] filt_a, float[] data) {
  int Nback = filt_b.length;
  double[] prev_y = new double[Nback];
  double[] prev_x = new double[Nback];
  
  //step through data points
  for (int i = 0; i < data.length; i++) {   
    //shift the previous outputs
    for (int j = Nback-1; j > 0; j--) {
      prev_y[j] = prev_y[j-1];
      prev_x[j] = prev_x[j-1];
    }
    
    //add in the new point
    prev_x[0] = data[i];
    
    //compute the new data point
    double out = 0;
    for (int j = 0; j < Nback; j++) {
      out += filt_b[j]*prev_x[j];
      if (j > 0) {
        out -= filt_a[j]*prev_y[j];
      }
    }
    
    //save output value
    prev_y[0] = out;
    data[i] = (float)out;
  }
}
    

void removeMean(float[] filty, int Nback) {
  float meanVal = mean(filty,Nback);
  for (int i=0; i < filty.length; i++) {
    filty[i] -= meanVal;
  }
}

void rereferenceTheMontage(float[][] data) {
  int n_chan = data.length;
  int n_points = data[0].length;
  float sum, mean;
  
  //loop over all data points
  for (int Ipoint=0;Ipoint<n_points;Ipoint++) {
    //compute mean signal right now
    sum=0.0;
    for (int Ichan=0;Ichan<n_chan;Ichan++) sum += data[Ichan][Ipoint];
    mean = sum / n_chan;
    
    //remove the mean signal from all channels
    for (int Ichan=0;Ichan<n_chan;Ichan++) data[Ichan][Ipoint] -= mean;
  }
}
  
class RunningMean {
  private float[] values;
  private int cur_ind = 0;
  RunningMean(int N) {
    values = new float[N];
    cur_ind = 0;
  }
  public void addValue(float val) {
    values[cur_ind] = val;
    cur_ind = (cur_ind + 1) % values.length;
  }
  public float calcMean() {
    return mean(values);
  }
};

