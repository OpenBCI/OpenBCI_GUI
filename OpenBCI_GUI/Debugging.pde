
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

//Help Widget initiation
HelpWidget helpWidget;

//use signPost(String identifier) to print 'identifier' text and time since last signPost() for debugging latency/timing issues
boolean printSignPosts = true;
float millisOfLastSignPost = 0.0;
float millisSinceLastSignPost = 0.0;

final static int OUTPUT_LEVEL_DEFAULT = 0;
final static int OUTPUT_LEVEL_INFO = 1;
final static int OUTPUT_LEVEL_SUCCESS = 2;
final static int OUTPUT_LEVEL_WARN = 3;
final static int OUTPUT_LEVEL_ERROR = 4;

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

void consolePrint(String _output) {
  println(_output);
  original.println(_output);
  consoleData.data.append(_output);
}

void consolePrint(StringList _list) {
  String[] list = _list.array();
  String s = join(list, "\n");
  consolePrint(s);
}

void consolePrint(Exception e) {
  StringWriter sw = new StringWriter();
  PrintWriter pw = new PrintWriter(sw);
  e.printStackTrace(pw);
  consolePrint(sw.toString());
}

void delay(int delay)
{
  int time = millis();
  while (millis() - time <= delay);
}

//this class is used to create the help widget that provides system feedback in response to interactivity
//it is intended to serve as a pseudo-console, allowing us to print useful information to the interface as opposed to an IDE console

class HelpWidget {

  public float x, y, w, h;
  // ArrayList<String> prevOutputs; //growing list of all previous system interactivity

  String currentOutput = "Learn how to use this application and more at docs.openbci.com/OpenBCI%20Software/01-OpenBCI_GUI"; //current text shown in help widget, based on most recent command

  int padding = 5;
  int outputStart = 0;
  int outputDurationMs = 3000;
  boolean animatingMessage = false;
  int curOutputLevel = OUTPUT_LEVEL_DEFAULT;

  HelpWidget(float _xPos, float _yPos, float _width, float _height) {
    x = _xPos;
    y = _yPos;
    w = _width;
    h = _height;
  }

  public void update() {
    if (animatingMessage) {
      if (millis() > outputStart + outputDurationMs) {
        animatingMessage = false;
        curOutputLevel = OUTPUT_LEVEL_DEFAULT;
      }
    }
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
      case OUTPUT_LEVEL_INFO:
        return #00529B;
      case OUTPUT_LEVEL_SUCCESS:
        return #4F8A10;
      case OUTPUT_LEVEL_WARN:
        return #9F6000;
      case OUTPUT_LEVEL_ERROR:
        return #D8000C;
      case OUTPUT_LEVEL_DEFAULT:
      default:
        return color(0, 5, 11);
    }
  }

  private color getBackgroundColor() {
    switch (curOutputLevel) {
      case OUTPUT_LEVEL_INFO:
        return #BDE5F8;
      case OUTPUT_LEVEL_SUCCESS:
        return #DFF2BF;
      case OUTPUT_LEVEL_WARN:
        return #FEEFB3;
      case OUTPUT_LEVEL_ERROR:
        return #FFD2D2;
      case OUTPUT_LEVEL_DEFAULT:
      default:
        return color(255);
    }
  }

  public void output(String _output, int level) {
    if (OUTPUT_LEVEL_DEFAULT == level) {
      animatingMessage = false;
    } else {
      animatingMessage = true;
      outputStart = millis();
    }
    curOutputLevel = level;
    currentOutput = _output;
    // prevOutputs.add(_output);
  }
};

public void output(String _output) {
  output(_output, OUTPUT_LEVEL_DEFAULT);
}

public void output(String _output, int level) {
  helpWidget.output(_output, level);
}

public void outputError(String _output) {
  output(_output, OUTPUT_LEVEL_ERROR);
}

public void outputInfo(String _output) {
  output(_output, OUTPUT_LEVEL_INFO);
}

public void outputSuccess(String _output) {
  output(_output, OUTPUT_LEVEL_SUCCESS);
}

public void outputWarn(String _output) {
  output(_output, OUTPUT_LEVEL_WARN);
}

// created 2/10/16 by Conor Russomanno to dissect the aspects of the GUI that are slowing it down
// here I will create methods used to identify where there are inefficiencies in the code
// note to self: make sure to check the frameRate() in setup... switched from 16 to 30... working much faster now... still a useful method below.
// --------------------------------------------------------------  START -------------------------------------------------------------------------------

//method for printing out an ["indentifier"][millisSinceLastSignPost] for debugging purposes... allows us to look at what is taking too long.
void signPost(String identifier) {
  if (printSignPosts) {
    millisSinceLastSignPost = millis() - millisOfLastSignPost;
    consolePrint("SIGN POST: [" + identifier + "][" + millisSinceLastSignPost + "]");
    millisOfLastSignPost = millis();
  }
}
// ---------------------------------------------------------------- FINISH -----------------------------------------------------------------------------
