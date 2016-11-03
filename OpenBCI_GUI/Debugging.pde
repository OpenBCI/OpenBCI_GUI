
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

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

void verbosePrint(String _string) {
  if (isVerbose) {
    println(_string);
  }
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

  String currentOutput = "..."; //current text shown in help widget, based on most recent command

  int padding = 5;

  HelpWidget(float _xPos, float _yPos, float _width, float _height) {
    x = _xPos;
    y = _yPos;
    w = _width;
    h = _height;
  }

  public void update() {
    //nothing needed here
  }

  public void draw() {

    pushStyle();
    noStroke();

    // draw background of widget
    fill(255);
    rect(x, height-h, width, h);

    //draw bg of text field of widget
    strokeWeight(1);
    stroke(color(0, 5, 11));
    fill(color(0, 5, 11));
    rect(x + padding, height-h + padding, width - padding*5 - 128, h - padding *2);

    textSize(14);
    fill(255);
    textAlign(LEFT, TOP);
    text(currentOutput, padding*2, height - h + padding + 4);

    //draw OpenBCI LOGO
    image(logo, width - (128+padding*2), height - 26, 128, 22);

    popStyle();
  }

  public void output(String _output) {
    currentOutput = _output;
    // prevOutputs.add(_output);
  }
};

public void output(String _output) {
  helpWidget.output(_output);
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
