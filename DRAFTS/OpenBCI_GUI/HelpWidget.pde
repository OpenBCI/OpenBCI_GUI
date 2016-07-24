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

