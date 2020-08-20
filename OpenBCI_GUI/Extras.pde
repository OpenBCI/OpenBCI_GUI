//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

/**
  * @description Helper function to determine if the system is linux or not.
  * @return {boolean} true if os is linux, false otherwise.
  */
private boolean isLinux() {
    return System.getProperty("os.name").toLowerCase().indexOf("linux") > -1;
}

/**
  * @description Helper function to determine if the system is windows or not.
  * @return {boolean} true if os is windows, false otherwise.
  */
private boolean isWindows() {
    return System.getProperty("os.name").toLowerCase().indexOf("windows") > -1;
}

/**
  * @description Helper function to determine if the system is macOS or not.
  * @return {boolean} true if os is windows, false otherwise.
  */
private boolean isMac() {
    return !isWindows() && !isLinux();
}


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


float log10(float val) {
    return (float)Math.log10(val);
}

float log10(int val) {
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

void removeMean(float[] filty, int Nback) {
    float meanVal = mean(filty,Nback);
    for (int i=0; i < filty.length; i++) {
        filty[i] -= meanVal;
    }
}

double[] floatToDoubleArray(float[] array) {
    double[] res = new double[array.length];
    for (int i = 0; i < res.length; i++) {
        res[i] = (double)array[i];
    }
    return res;
}

float[] doubleToFloatArray(double[] array) {
    float[] res = new float[array.length];
    for (int i = 0; i < res.length; i++) {
        res[i] = (float)array[i];
    }
    return res;
}

void floatToDoubleArray(float[] array, double[] res) {
    for (int i = 0; i < array.length; i++) {
        res[i] = (double)array[i];
    }
}

void doubleToFloatArray(double[] array, float[] res) {
    for (int i = 0; i < array.length; i++) {
        res[i] = (float)array[i];
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

int lerpInt(long first, long second, float bias) {
    return round(lerp(first, second, bias));    
}

int[] range(int first, int second) {
    int total = abs(first-second);
    int[] result = new int[total];

    for(int i=0; i<total; i++) {
        int newNumber = first;
        if(first > second) {
            newNumber -= i;
        }
        else {
            newNumber += i;
        }

        result[i] = newNumber;
    }

    return result;
}

//------------------------------------------------------------------------
//                            Classes
//------------------------------------------------------------------------

class RectDimensions {
    public int x, y, w, h;
}

class DataStatus {
    public boolean is_railed;
    private double threshold_railed;
    public boolean is_railed_warn;
    private double threshold_railed_warn;

    DataStatus(int thresh_railed, int thresh_railed_warn) {
        // convert int24 value to uV
        is_railed = false;
        // convert thresholds to uV
        threshold_railed = thresh_railed;
        is_railed_warn = false;
        threshold_railed_warn = thresh_railed_warn;
    }
    public void update(float data_value, int channel) {
        is_railed = false;
        is_railed_warn = false;
        if (currentBoard instanceof ADS1299SettingsBoard) {
            double scaler =  (4.5 / (pow (2, 23) - 1) / ((ADS1299SettingsBoard)currentBoard).getGain(channel) * 1000000.);
            if (abs(data_value) >= threshold_railed * scaler) {
                is_railed = true;
            }
            if (abs(data_value) >= threshold_railed_warn * scaler) {
                is_railed_warn = true;
            }
        }
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

class PlotFontInfo {
        String fontName = "fonts/Raleway-Regular.otf";
        int axisLabel_size = 16;
        int tickLabel_size = 14;
        int buttonLabel_size = 12;
};


class TextBox {
    private int x, y;
    private color textColor;
    private color backgroundColor;
    private PFont font;
    private int fontSize;
    private String string;
    private boolean drawBackground = true;
    private int backgroundEdge_pixels;
    private int alignH,alignV;

    TextBox(String s, int x1, int y1) {
        string = s; x = x1; y = y1;
        textColor = color(0);
        backgroundColor = color(255);
        fontSize = 12;
        font = p5;
        backgroundEdge_pixels = 1;
        drawBackground = false;
        alignH = LEFT;
        alignV = BOTTOM;
    }

    TextBox(String s, int x1, int y1, color _textColor, color _backgroundColor, int _alignH, int _alignV) {
        string = s;
        x = x1;
        y = y1;
        textColor = _textColor;
        backgroundColor = _backgroundColor;
        fontSize = 12;
        font = p5;
        backgroundEdge_pixels = 1;
        drawBackground = true;
        alignH = _alignH;
        alignV = _alignV;
    }

    TextBox(String s, int x1, int y1, color _textColor, color _backgroundColor, int _fontSize, PFont _font, int _alignH, int _alignV) {
        string = s;
        x = x1;
        y = y1;
        textColor = _textColor;
        backgroundColor = _backgroundColor;
        fontSize = _fontSize;
        font = _font;
        backgroundEdge_pixels = 1;
        drawBackground = true;
        alignH = _alignH;
        alignV = _alignV;
    }
    
    public void draw() {
        pushStyle();
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
            
            int h = int(textAscent()) + backgroundEdge_pixels*2;
            int ybox = y;
            if (alignV == CENTER) {
                ybox -= textAscent() / 2 - backgroundEdge_pixels;
            } else if (alignV == BOTTOM) {
                ybox -= textAscent() + backgroundEdge_pixels*3;
            }
            fill(backgroundColor);
            rect(xbox,ybox,w,h);
        }
        //draw the text itself
        pushStyle();
        noStroke();
        fill(textColor);
        textAlign(alignH,alignV);
        text(string,x,y);
        strokeWeight(1);
        popStyle();
    }

    public void setPosition(int _x, int _y) {
        x = _x;
        y = _y;
    }

    public void setText(String s) {
        string = s;
    }
};
