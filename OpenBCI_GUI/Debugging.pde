
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
boolean isVerbose = true;

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
    String currentOutput = "Learn how to use this application and more at docs.openbci.com/OpenBCI%20Software/01-OpenBCI_GUI";
    OutputLevel curOutputLevel = OutputLevel.DEFAULT;

    HelpWidget(float _xPos, float _yPos, float _width, float _height) {
        x = _xPos;
        y = _yPos;
        w = _width;
        h = _height;
        padding = 5;
    }

    public void update() {
        // empty
    }

    public void draw() {

        pushStyle();

        if(colorScheme == COLOR_SCHEME_DEFAULT){
            // draw background of widget
            stroke(bgColor);
            fill(255);
            rect(-1, height-h, width+2, h);
            noStroke();

            //draw bg of text field of widget
            strokeWeight(1);
            stroke(color(0, 5, 11));
            fill(color(0, 5, 11));
            rect(x + padding, height-h + padding, width - padding*2, h - padding *2);

            textFont(p4);
            textSize(14);
            fill(255);
            textAlign(LEFT, TOP);
            text(currentOutput, padding*2, height - h + padding);
        } else if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A){
            // draw background of widget
            stroke(bgColor);
            fill(31,69,110);
            rect(-1, height-h, width+2, h);
            noStroke();

            //draw bg of text field of widget
            strokeWeight(1);
            stroke(getBackgroundColor());
            // fill(200);
            // fill(255);
            fill(getBackgroundColor());
            // fill(57,128,204);
            rect(x + padding, height-h + padding, width - padding*2, h - padding *2);

            textFont(p4);
            textSize(14);
            // fill(bgColor);
            fill(getTextColor());
            // fill(57,128,204);
            // fill(openbciBlue);
            textAlign(LEFT, TOP);
            text(currentOutput, padding*2, height - h + padding);
        }

        popStyle();
    }

    private color getTextColor() {
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
    }

    private color getBackgroundColor() {
        switch (curOutputLevel) {
            case INFO:
                return #BDE5F8;
            case SUCCESS:
                return #DFF2BF;
            case WARN:
                return #FEEFB3;
            case ERROR:
                return #FFD2D2;
            case DEFAULT:
            default:
                return color(255);
        }
    }

    public void output(String _output, OutputLevel level) {
        curOutputLevel = level;
        currentOutput = _output;

        String outputWithPrefix = "[" + level.name() + "]: " + _output;
        println(outputWithPrefix); // add this output to the console log
    }
};

public void output(String _output) {
    output(_output, OutputLevel.DEFAULT);
}

public void output(String _output, OutputLevel level) {
    helpWidget.output(_output, level);
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
