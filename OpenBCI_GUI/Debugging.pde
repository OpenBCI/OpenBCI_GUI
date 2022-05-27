
//////////////////////////////////////
//
// This file contains classes that are helpful for debugging, as well as the HelpWidget,
// which is used to give feedback to the GUI user in the small text window at the bottom of the GUI
//
// Created: Conor Russomanno, June 2016
// Based on code: Chip Audette, Oct 2013 - Dec 2014
//
//
/////////////////////////////////////

import java.io.StringWriter;

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

//set true if you want more verbosity in console.. verbosePrint("print_this_thing") is used to output feedback when isVerbose = true
boolean isVerbose = false;

//Help Widget initiation
HelpWidget helpWidget;

//use signPost(String identifier) to print 'identifier' text and time since last signPost() for debugging latency/timing issues
boolean printSignPosts = true;
float millisOfLastSignPost = 0.0;
float millisSinceLastSignPost = 0.0;

static enum OutputLevel {
    DEFAULT,
    INFO,
    SUCCESS,
    WARN,
    ERROR
}

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

void verbosePrint(String _string) {
    if (isVerbose) {
        println(_string);
    }
}

//this class is used to create the help widget that provides system feedback in response to interactivity
//it is intended to serve as a pseudo-console, allowing us to print useful information to the interface as opposed to an IDE console
class HelpWidget {

    public float x, y, w, h;
    int padding;

    //current text shown in help widget, based on most recent command
    String currentOutput = "Learn how to use this application and more at docs.openbci.com";
    OutputLevel curOutputLevel = OutputLevel.INFO;
    private int colorFadeCounter;
    private int colorFadeTimeMillis = 1000;
    private boolean outputWasTriggered = false;

    HelpWidget(float _xPos, float _yPos, float _width, float _height) {
        x = _xPos;
        y = _yPos;
        w = _width;
        h = _height;
        padding = 5;
    }

    public void update() {
    }

    public void draw() {

        pushStyle();
        // draw background of widget
        stroke(OPENBCI_DARKBLUE);
        fill(31,69,110);
        rect(-1, height-h, width+2, h);
        noStroke();

        //draw bg of text field of widget
        strokeWeight(1);
        int saturationFadeValue = 0;
        if (outputWasTriggered) {
            int timeDelta = millis() - colorFadeCounter;
            saturationFadeValue = (int)map(timeDelta, 0, colorFadeTimeMillis, 100, 0);
            if (timeDelta > colorFadeTimeMillis) {
                outputWasTriggered = false;
            }
        }
        //Colors in this method are calculated using Hue, Saturation, Brightness
        colorMode(HSB, 360, 100, 100);
        color c = getBackgroundColor(saturationFadeValue);
        stroke(c);
        fill(c);
        rect(x + padding, height-h + padding, width - padding*2, h - padding *2);

        // Revert color mode back to standard RGB here
        colorMode(RGB, 255, 255, 255);
        textFont(p4);
        textSize(14);
        fill(getTextColor());
        textAlign(LEFT, TOP);
        text(currentOutput, padding*2, height - h + padding);
        popStyle();
    }

    private color getTextColor() {
        /*
        switch (curOutputLevel) {
            case INFO:
                return #00529B;
            case SUCCESS:
                return #4F8A10;
            case WARN:
                return #9F6000;
            case ERROR:
                return #D8000C;
            case DEFAULT:
            default:
                return color(0, 5, 11); 
        }
        */
        return OPENBCI_DARKBLUE;
    }

    private color getBackgroundColor(int fadeVal) {  
        int sat = 0;
        int maxSat = 75;
        switch (curOutputLevel) {
            case INFO:
                //base color - #BDE5F8;
                sat = 25;
                sat = (int)map(fadeVal, 0, 100, sat, maxSat);
                return color(199, sat, 97);
            case SUCCESS:
                //base color -  #DFF2BF;
                maxSat = 50;
                sat = 25;
                sat = (int)map(fadeVal, 0, 100, sat, maxSat);
                return color(106, sat, 95);
            case WARN:
                //base color -  #FEEFB3;
                sat = 30;
                sat = (int)map(fadeVal, 0, 100, sat, maxSat);
                return color(48, sat, 100);
            case ERROR:
                //base color -  #FFD2D2;
                sat = 18;
                sat = (int)map(fadeVal, 0, 100, sat, maxSat);
                return color(0, sat, 100);
            case DEFAULT:
            default:
                colorMode(RGB, 255, 255, 255);
                return WHITE;
        }
    }

    public void output(String _output, OutputLevel level) {
        curOutputLevel = level;
        currentOutput = _output;

        String outputWithPrefix = "[" + level.name() + "]: " + _output;
        println(outputWithPrefix); // add this output to the console log
        outputWasTriggered = true;
        colorFadeCounter = millis();
    }
};

public void output(String _output) {
    output(_output, OutputLevel.DEFAULT);
}

public void output(String _output, OutputLevel level) {
    if (helpWidget != null)
        helpWidget.output(_output, level);
    else
        println(level + "::" + _output);
}

public void outputError(String _output) {
    output(_output, OutputLevel.ERROR);
}

public void outputInfo(String _output) {
    output(_output, OutputLevel.INFO);
}

public void outputSuccess(String _output) {
    output(_output, OutputLevel.SUCCESS);
}

public void outputWarn(String _output) {
    output(_output, OutputLevel.WARN);
}

// created 2/10/16 by Conor Russomanno to dissect the aspects of the GUI that are slowing it down
// here I will create methods used to identify where there are inefficiencies in the code
// note to self: make sure to check the frameRate() in setup... switched from 16 to 30... working much faster now... still a useful method below.
// --------------------------------------------------------------  START -------------------------------------------------------------------------------

//method for printing out an ["indentifier"][millisSinceLastSignPost] for debugging purposes... allows us to look at what is taking too long.
void signPost(String identifier) {
    if (printSignPosts) {
        millisSinceLastSignPost = millis() - millisOfLastSignPost;
        println("SIGN POST: [" + identifier + "][" + millisSinceLastSignPost + "]");
        millisOfLastSignPost = millis();
    }
}
// ---------------------------------------------------------------- FINISH -----------------------------------------------------------------------------
