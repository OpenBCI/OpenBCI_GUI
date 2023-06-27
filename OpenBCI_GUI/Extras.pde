import java.io.OutputStream;
import java.io.PrintStream;
import java.util.prefs.Preferences;
import static java.lang.System.setErr;
import static java.util.prefs.Preferences.systemRoot;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

import java.util.regex.Matcher;
import java.util.regex.Pattern;

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

private void checkIsMacFullDetail() {
    StringBuilder response = new StringBuilder("MacOS Details: ");
    if (isMacOsLowerThanCatalina()) {
        response.append("MacOS Mojave or earlier");
    } else if (isMacOsBigSur()) {
        response.append("MacOS Big Sur");
    } else if (isMacOsMonterey()) {
        response.append("MacOS Monterey");
    } else {
        response.append("MacOS Catalina");
    }
    println(response);
}

// For a full list of modern Mac OS versions, visit https://en.wikipedia.org/wiki/MacOS_version_history
private boolean isMacOsLowerThanCatalina() {
    int[] versionInfo = fetchAndParseMacOsVersion();
    return versionInfo[0] <= 10 && versionInfo[1] < 15;
}

private boolean isMacOsBigSur() {
    int[] versionInfo = fetchAndParseMacOsVersion();
    //This should return 11, but there was a recently discovered bug in Java 8 -- https://bugs.openjdk.java.net/browse/JDK-8274907
    int[] javaInfo = fetchAndParseJavaVersion();
    boolean usingJava8_202 = javaInfo[0] == 1 && javaInfo[1] == 8 && javaInfo[2] == 202;
    if (usingJava8_202) {
        return versionInfo[0] == 10 && versionInfo[1] == 16;
    } else {
        return versionInfo[0] == 11;
    }
}

private boolean isMacOsMonterey() {
    int[] versionInfo = fetchAndParseMacOsVersion();
    return versionInfo[0] == 12;
}

private String getOperatingSystemVersion() {
    return System.getProperty("os.version");
}

private int[] fetchAndParseMacOsVersion() {
    if (!isMac()) {
        println("Oops! Please only call this method on MacOS");
        return null;
    }
    final String version = getOperatingSystemVersion();
    final String[] splitStrings = split(version, '.');
    int[] versionVals = new int[splitStrings.length];
    for (int i = 0; i < splitStrings.length; i++) {
        versionVals[i] = Integer.valueOf(splitStrings[i]);
    }
    return versionVals;
}

private int[] fetchAndParseJavaVersion() {
    final String version = System.getProperty("java.version");
    final String[] splitStrings = split(version, '.');
    int[] versionVals = new int[splitStrings.length];
    versionVals[0] = Integer.valueOf(splitStrings[0]);
    versionVals[1] = Integer.valueOf(splitStrings[1]);
    final String[] minorVersion = split(splitStrings[2], "_");
    versionVals[2] = Integer.valueOf(minorVersion[minorVersion.length - 1]);
    return versionVals;
}

//BrainFlow only supports Windows 8 and 10. This will help with OpenBCI support tickets. #964
private void checkIsOldVersionOfWindowsOS() {
    boolean isOld = SystemUtils.IS_OS_WINDOWS_7 || SystemUtils.IS_OS_WINDOWS_VISTA || SystemUtils.IS_OS_WINDOWS_XP;
    if (isOld) {
        PopupMessage msg = new PopupMessage("Old Windows OS Detected", "OpenBCI GUI v5 and BrainFlow are made for 64-bit Windows 8, 8.1, and 10. Please update your OS, computer, or revert to GUI v4.2.0.");
    }
}

//Sanity check for 64-bit Java for Windows users #964
private void checkIs64BitJava() {
    boolean is64Bit = System.getProperty("sun.arch.data.model").indexOf("64") >= 0;
    if (!is64Bit) {
        PopupMessage msg = new PopupMessage("32-bit Java Detected", "OpenBCI GUI v5 and BrainFlow are made for 64-bit Java (Windows, Linux, and Mac). Please update your OS, computer, Processing IDE, or revert to GUI v4 or earlier.");
    }
}
/**
* Determines if elevated rights are required to install/uninstall the application.
*
* @return <code>true</code> if elevation is needed to have administrator permissions, <code>false</code> otherwise.
*/
public boolean isElevationNeeded() {
    return isElevationNeeded(null);
}
/**
* Determines if elevated rights are required to install/uninstall the application.
*
* @param path the installation path, or <tt>null</tt> if the installation path is unknown
* @return <tt>true</tt> if elevation is needed to have administrator permissions, <tt>false</tt> otherwise.
*/
public boolean isElevationNeeded(String path) {
    boolean result;
    if (isWindows()) {
        if (path != null) {
            // use the parent path, as that needs to be written to in order to delete the tree
            path = new File(path).getParent();
        }
        if (path == null || path.trim().length() == 0) {
            path = getWindowsProgramFiles();
        }
        result = !canWrite(path);
    } else {
        if (path != null) {
            result = !canWrite(path);
        } else {
            if (isMac()) {
                //Mac user name is never simply "root"
                return false;
            }
            result = !System.getProperty("user.name").equals("root");
        }
    }
    return result;
}
/**
* Determine if user has administrative privileges.
*
* @return
*/
public boolean isAdminUser() {
    if (isMac()) {
        return true;
    }
    if (isWindows()) {
        try {
            String NTAuthority = "HKU\\S-1-5-19";
            String command = "reg query \""+ NTAuthority + "\"";
            Process p = Runtime.getRuntime().exec(command);
            p.waitFor();
            return (p.exitValue() == 0);
        } catch (Exception e) {
            return canWrite(getWindowsProgramFiles());
        }
    }
    try {
        String command = "id -u";
        Process p = Runtime.getRuntime().exec(command);
        p.waitFor();
        InputStream stdIn = p.getInputStream();
        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(stdIn));
        String value = bufferedReader.readLine();
        return value.equals("0");
    } catch (Exception e) {
        return System.getProperty("user.name").equals("root");
    }
}
/**
* Tries to determine the Windows Program Files directory.
*
* @return the Windows Program Files directory
*/
private String getWindowsProgramFiles() {
    String path = System.getenv("ProgramFiles");
    if (path == null) {
        path = "C:\\Program Files";
    }
    return path;
}
/**
* Determines if the specified path can be written to.
*
* @param path the path to check
* @return <tt>true</tt> if the path can be written to, otherwise <tt>false</tt>
*/
private boolean canWrite(String path) {
    File file = new File(path);
    boolean canWrite = file.canWrite();
    if (canWrite) {
        // make sure that the path can actually be written to, for IZPACK-727
        try {
            File test = File.createTempFile(".izpackwritecheck", null, file);
            if (!test.delete()) {
                test.deleteOnExit();
            }
        } catch (IOException exception) {
            canWrite = false;
        }
    }
    return canWrite;
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

// cp5 textfields adds garbage chars to text field and they are invisible
String dropNonPrintableChars(String myString)
{
    StringBuilder newString = new StringBuilder(myString.length());
    for (int offset = 0; offset < myString.length();)
    {
        int codePoint = myString.codePointAt(offset);
        offset += Character.charCount(codePoint);

        // Replace invisible control characters and unused code points
        switch (Character.getType(codePoint))
        {
            case Character.CONTROL:     // \p{Cc}
            case Character.FORMAT:      // \p{Cf}
            case Character.PRIVATE_USE: // \p{Co}
            case Character.SURROGATE:   // \p{Cs}
            case Character.UNASSIGNED:  // \p{Cn}
                break;
            default:
                newString.append(Character.toChars(codePoint));
                break;
        }
    }
    String res = newString.toString();
    res = res.replace("\r", "");
    res = res.replace("\n", "");
    res = res.replace("\t", "");
    return res;
}

String getIpAddrFromStr(String strWithIP) {
    String temp = dropNonPrintableChars(strWithIP);
    String IPADDRESS_PATTERN = 
        "(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)";
    Pattern pattern = Pattern.compile(IPADDRESS_PATTERN);
    Matcher matcher = pattern.matcher(temp);
    if (matcher.find()) {
        return matcher.group();
    } else{
        output("Invalid Ip address");
        println("Provided Ip address doesn't match regexp");
        return "";
    }
}

float getFontStringHeight(PFont _font, String string) {
    float minY = Float.MAX_VALUE;
    float maxY = Float.NEGATIVE_INFINITY;
    for (Character c : string.toCharArray()) {
        PShape character = _font.getShape(c); // create character vector
        for (int i = 0; i < character.getVertexCount(); i++) {
            minY = min(character.getVertex(i).y, minY);
            maxY = max(character.getVertex(i).y, maxY);
        }
    }
    return maxY - minY;
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
    public boolean is_railed_warn;
    private double percentage;
    public String notificationString;
    private final color default_color = OPENBCI_DARKBLUE;
    private final color yellow = SIGNAL_CHECK_YELLOW;
    private final color red = BOLD_RED;
    private color colorIndicator = default_color;
    // thresholds are pecentages of max possible value
    private double threshold_railed = 90.0;
    private double threshold_railed_warn = 75.0;

    DataStatus() {
        notificationString = "";
        is_railed = false;
        is_railed_warn = false;
        percentage = 0.0;
    }
    // here data is a full range for 20sec of data and doesnt take in account window size
    public void update(float[] data, int channel) {
        percentage = 0.0;
        is_railed = false;
        is_railed_warn = false;

        if (data.length < 1) {
            return;
        }

        if (currentBoard instanceof ADS1299SettingsBoard) {
            double scaler =  (4.5 / (pow (2, 23) - 1) / ((ADS1299SettingsBoard)currentBoard).getGain(channel) * 1000000.);
            double maxVal = scaler * pow (2, 23);
            int numSeconds = 3;
            int nPoints = numSeconds * currentBoard.getSampleRate();
            int endPos = data.length;
            int startPos = Math.max(0, endPos - nPoints);

            boolean is_straight_line = true;
            if (!currentBoard.isStreaming()) {
                is_straight_line = false;
            }
            float max = Math.abs(data[startPos]);
            for (int i = startPos + 1; i < endPos; i++) {
                if (Math.abs(data[i]) > max) {
                    max = Math.abs(data[i]);
                }
                if ((Math.abs(data[i - 1] - data[i]) > 0.00001) && (Math.abs(data[i]) > 0.00001)) {
                    is_straight_line = false;
                }
            }
            percentage = (max / maxVal) * 100.0;

            notificationString = "Not Railed " + String.format("%1$,.2f", percentage) + "% ";
            colorIndicator = default_color;
            if (percentage > threshold_railed_warn) {
                is_railed_warn = true;
                notificationString = "Near Railed " + String.format("%1$,.2f", percentage) + "% ";
                colorIndicator = yellow;
            }
            if (percentage > threshold_railed) {
                is_railed = true;
                notificationString = "Railed " + String.format("%1$,.2f", percentage) + "% ";
                colorIndicator = red;
            } else {
                if (is_straight_line) {
                    is_railed = true;
                    notificationString = "Data from the board doesn't change";
                    colorIndicator = red;
                }
            }

        }
    }
    public color getColor() {
        return colorIndicator;
    }
    public double getPercentage() {
        return percentage;
    }

    public void setRailedWarnThreshold(double d) {
        threshold_railed_warn = d;
    }

    public void setRailedThreshold(double d) {
        threshold_railed = d;
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
    private int w, h;
    private color textColor;
    private color backgroundColor;
    private PFont font;
    private int fontSize;
    private String string;
    private boolean drawBackground = true;
    private int backgroundEdge_pixels;
    private int alignH,alignV;
    private boolean drawObject = true;

    TextBox(String s, int x1, int y1) {
        string = s; x = x1; y = y1;
        textColor = OPENBCI_DARKBLUE;
        backgroundColor = color(255);
        fontSize = 12;
        font = p5;
        backgroundEdge_pixels = 1;
        drawBackground = false;
        alignH = LEFT;
        alignV = BOTTOM;
    }

    TextBox(String s, int x1, int y1, color _textColor, color _backgroundColor, int _alignH, int _alignV) {
        this(s, x1, y1);
        textColor = _textColor;
        backgroundColor = _backgroundColor;
        drawBackground = true;
        alignH = _alignH;
        alignV = _alignV;
    }

    TextBox(String s, int x1, int y1, color _textColor, color _backgroundColor, int _fontSize, PFont _font, int _alignH, int _alignV) {
        this(s, x1, y1, _textColor, _backgroundColor, _alignH, _alignV);
        fontSize = _fontSize;
        font = _font;
    }
    
    public void draw() {

        if (!drawObject) {
            return;
        }

        pushStyle();
        noStroke();
        textFont(font);

        //draw the box behind the text
        if (drawBackground == true) {
            w = int(round(textWidth(string)));
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
            
            h = int(textAscent()) + backgroundEdge_pixels*2;
            int ybox = y;
            if (alignV == CENTER) {
                ybox -= textAscent() / 2 - backgroundEdge_pixels;
            } else if (alignV == BOTTOM) {
                ybox -= textAscent() + backgroundEdge_pixels*3;
            }
            fill(backgroundColor);
            rect(xbox,ybox,w,h);
        }
        popStyle();
        
        //draw the text itself
        pushStyle();
        noStroke();
        fill(textColor);
        textAlign(alignH,alignV);
        textFont(font);
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

    public void setTextColor(color c) {
        textColor = c;
    }

    public void setBackgroundColor(color c) {
        backgroundColor = c;
    }

    public int getWidth() {
        return w;
    }

    public int getHeight() {
        return h;
    }

    public void setVisible(boolean b) {
        drawObject = b;
    }
};

public boolean pingWebsite(String url) {
    int code = 200;
    try {
        URL siteURL = new URL(url);
        HttpURLConnection connection = (HttpURLConnection) siteURL.openConnection();
        connection.setRequestMethod("GET");
        connection.setConnectTimeout(2000);
        connection.connect();

        code = connection.getResponseCode();
        if (code == 200) {
            return true;
        } else {
            return false;
        }
    } catch (IOException e) {
        return false;

    }
}

public BufferedReader createBufferedReader(String filepath) {
    File file;
    BufferedReader reader;
    try {
        file = new File(filepath);
        reader = new BufferedReader(new FileReader(file));
        return reader;
    } catch (IOException e) {
        e.printStackTrace();
        return null;
    }
}

//Used to check for one string in a text file
//Uses a buffered reader for this method so that we do not load entire file to memory
boolean checkTextFileForInfo(String path, String infoToCheck, int maxLinesToCheck) {
    verbosePrint("Checking " + path + " for " + infoToCheck);
    String strCurrentLine;
    int lineCounter = 0;
    BufferedReader reader = createBufferedReader(path);
    try {
        while (lineCounter < maxLinesToCheck) {
            strCurrentLine = reader.readLine();
            verbosePrint(strCurrentLine);
            if (strCurrentLine.equals(infoToCheck)) {
                return true;
            }
            lineCounter++;
        }
    } catch (IOException e) {
        e.printStackTrace();
    } finally {
        try {
            if (reader != null) {
                reader.close();
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
    return false;
}
