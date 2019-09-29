
//////////////////////////////////////
//
// This file contains classes that are helfpul in some way.
// Created: Chip Audette, Oct 2013 - Dec 2014
//
/////////////////////////////////////

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//////////////////////////////////////////////////
//
// Formerly, Math.pde
//  - std
//  - mean
//  - medianDestructive
//  - findMax
//  - mean
//  - sum
//  - CalcDotProduct
//  - log10
//  - filterWEA_1stOrderIIR
//  - filterIIR
//  - removeMean
//  - rereferenceTheMontage
//  - CLASS RunningMean
//
// Created: Chip Audette, Oct 2013
//
//////////////////////////////////////////////////

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


static float log10(float val) {
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

// shortens a string to a given width by adding [...] in the middle
// make sure to pass the right font for accurate sizing
String shortenString(String str, float maxWidth, PFont font) {
    if (textWidth(str) <= maxWidth) {
        return str;
    }

    textFont(font); // set font for accurate sizing
    int firstIndex = 0; // forward iterator
    int lastIndex = str.length()-1; // reverse iterator
    float spaceLeft = maxWidth - textWidth("..."); // account for the space taken by "..."

    while (firstIndex < lastIndex && spaceLeft >= 0.f) {
        spaceLeft -= textWidth(str.charAt(firstIndex)); // subtract space taken by first char
        spaceLeft -= textWidth(str.charAt(lastIndex)); // and last char

        // move interators inward
        firstIndex ++;
        lastIndex --;
    }

    String s1 = str.substring(0, firstIndex); // firstIndex is excluded here
    String s2 = str.substring(lastIndex + 1, str.length()); // manually exclude lastIndex
    return s1 + "..." + s2;
}

//------------------------------------------------------------------------
//                            Classes
//------------------------------------------------------------------------

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

class DataPacket_ADS1299 {
    private final int rawAdsSize = 3;
    private final int rawAuxSize = 2;

    int sampleIndex;
    int[] values;
    int[] auxValues;
    byte[][] rawValues;
    byte[][] rawAuxValues;

    //constructor, give it "nValues", which should match the number of values in the
    //data payload in each data packet from the Arduino.  This is likely to be at least
    //the number of EEG channels in the OpenBCI system (ie, 8 channels if a single OpenBCI
    //board) plus whatever auxiliary data the Arduino is sending.
    DataPacket_ADS1299(int nValues, int nAuxValues) {
        values = new int[nValues];
        auxValues = new int[nAuxValues];
        rawValues = new byte[nValues][rawAdsSize];
        rawAuxValues = new byte[nAuxValues][rawAdsSize];
    }

    int copyTo(DataPacket_ADS1299 target) { return copyTo(target, 0, 0); }
    int copyTo(DataPacket_ADS1299 target, int target_startInd_values, int target_startInd_aux) {
        target.sampleIndex = sampleIndex;
        return copyValuesAndAuxTo(target, target_startInd_values, target_startInd_aux);
    }
    int copyValuesAndAuxTo(DataPacket_ADS1299 target, int target_startInd_values, int target_startInd_aux) {
        int nvalues = values.length;
        for (int i=0; i < nvalues; i++) {
            target.values[target_startInd_values + i] = values[i];
            target.rawValues[target_startInd_values + i] = rawValues[i];
        }
        nvalues = auxValues.length;
        for (int i=0; i < nvalues; i++) {
            target.auxValues[target_startInd_aux + i] = auxValues[i];
            target.rawAuxValues[target_startInd_aux + i] = rawAuxValues[i];
        }
        return 0;
    }
};

class DataStatus {
    public boolean is_railed;
    private int threshold_railed;
    public boolean is_railed_warn;
    private int threshold_railed_warn;

    DataStatus(int thresh_railed, int thresh_railed_warn) {
        is_railed = false;
        threshold_railed = thresh_railed;
        is_railed_warn = false;
        threshold_railed_warn = thresh_railed_warn;
    }
    public void update(int data_value) {
        is_railed = false;
        if (abs(data_value) >= threshold_railed) is_railed = true;
        is_railed_warn = false;
        if (abs(data_value) >= threshold_railed_warn) is_railed_warn = true;
    }
};

class FilterConstants {
    public double[] a;
    public double[] b;
    public String name;
    public String short_name;
    FilterConstants(double[] b_given, double[] a_given, String name_given, String short_name_given) {
        b = new double[b_given.length];a = new double[b_given.length];
        for (int i=0; i<b.length;i++) { b[i] = b_given[i];}
        for (int i=0; i<a.length;i++) { a[i] = a_given[i];}
        name = name_given;
        short_name = short_name_given;
    }
};

class DetectionData_FreqDomain {
    public float inband_uV = 0.0f;
    public float inband_freq_Hz = 0.0f;
    public float guard_uV = 0.0f;
    public float thresh_uV = 0.0f;
    public boolean isDetected = false;

    DetectionData_FreqDomain() {
    }
};

class GraphDataPoint {
    public double x;
    public double y;
    public String x_units;
    public String y_units;
};

class PlotFontInfo {
        String fontName = "fonts/Raleway-Regular.otf";
        int axisLabel_size = 16;
        int tickLabel_size = 14;
        int buttonLabel_size = 12;
};

class TextBox {
    public int x, y;
    public color textColor;
    public color backgroundColor;
    private PFont font;
    private int fontSize;
    public String string;
    public boolean drawBackground;
    public int backgroundEdge_pixels;
    public int alignH,alignV;

    TextBox(String s, int x1, int y1) {
        string = s; x = x1; y = y1;
        backgroundColor = color(255,255,255);
        textColor = color(0,0,0);
        fontSize = 12;
        font = p5;
        backgroundEdge_pixels = 1;
        drawBackground = false;
        alignH = LEFT;
        alignV = BOTTOM;
    }
    public void setFontSize(int size) {
        fontSize = size;
        font = p5;
    }
    public void draw() {
        //define text
        noStroke();
        textFont(font);

        //draw the box behind the text
        if (drawBackground == true) {
            int w = int(round(textWidth(string)));
            int xbox = x - backgroundEdge_pixels;
            switch (alignH) {
                case LEFT:
                    xbox = x - backgroundEdge_pixels;
                    break;
                case RIGHT:
                    xbox = x - w - backgroundEdge_pixels;
                    break;
                case CENTER:
                    xbox = x - int(round(w/2.0)) - backgroundEdge_pixels;
                    break;
            }
            w = w + 2*backgroundEdge_pixels;
            int h = int(textAscent())+2*backgroundEdge_pixels;
            int ybox = y - int(round(textAscent())) - backgroundEdge_pixels -2;
            fill(backgroundColor);
            rect(xbox,ybox,w,h);
        }
        //draw the text itself
        fill(textColor);
        textAlign(alignH,alignV);
        text(string,x,y);
        strokeWeight(1);
    }
};
