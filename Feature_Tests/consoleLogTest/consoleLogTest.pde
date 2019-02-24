import java.io.PrintStream;
import java.io.FileOutputStream;

int myTimer;

ScrollRect scrollRect;        // the vertical scroll bar
float heightOfCanvas = 500;  // realHeight of the entire scene

PrintStream original = new PrintStream(System.out);
ConsoleData consoleData = new ConsoleData();

void setup() {
  size(500,500);
  println("This goes to the console.");
  consoleData.setupConsoleOutput();
  consolePrint("This goes to the file and the Console");
  consolePrint("Hello Major Tom!");

  scrollRect = new ScrollRect();
  background(90);
}

void draw() {
  clear();

  if (millis() > myTimer + 100) {
    consolePrint(Integer.toString(++consoleData.outputLine));
    myTimer = millis();
  }

  scene();
  scrollRect.display();
  scrollRect.update();
}

void mousePressed() {
  scrollRect.mousePressedRect();
}

void mouseReleased() {
  scrollRect.mouseReleasedRect();
}

void consolePrint(String _output) {
  println(_output);
  original.println(_output);
  consoleData.data.append(_output);
}

class ConsoleData {

  StringList data = new StringList();
  int outputLine = 0;

  void setupConsoleOutput() {
    try {
      String file = dataPath("dataConsole.txt");
      if (!new File(dataPath("")).isDirectory()) {
        if (!new File(dataPath("")).mkdirs()) {
          System.err.println("Directory creation failed!");
          exit();
        }
      }
      FileOutputStream outStr = new FileOutputStream(file, false);
      PrintStream printStream = new PrintStream(outStr);
      System.setOut(printStream);
      System.setErr(printStream);
    }
    catch (IOException e) {
      System.err.println("Error! Check path, or filename, or security manager! "+e);
    }
  }

}

// --------------------------------------------------------------

void scene() {
  pushMatrix();

  int fontHeight = 12;
  // reading scroll bar
  float newYValue = scrollRect.scrollValue();
  translate (0, newYValue);

  if ((fontHeight*(consoleData.data.size() - 1) + 4) > heightOfCanvas) {
    heightOfCanvas += 80;
  }

  fill(255);
  for (int i = 0; i < consoleData.data.size(); i++) {
    text(consoleData.data.get(i), 10, fontHeight * i + 4, 255, 80);
  }

  text("End of virtual canvas", width-130, heightOfCanvas-16);
  fill(122);
  popMatrix();
}

// ===============================================================

class ScrollRect {

  float rectPosX=0;
  float rectPosY=0;
  float rectWidth=14;
  float rectHeight=30;

  boolean holdScrollRect=false;

  float offsetMouseY;

  //constr
  ScrollRect() {
    // you have to make a scrollRect in setup after size()
    rectPosX=width-rectWidth-1;
  }//constr

  void display() {
    fill(122);
    stroke(0);
    line (rectPosX-1, 0,
      rectPosX-1, height);
    rect(rectPosX, rectPosY,
      rectWidth, rectHeight);

    // Three small lines in the center
    centerLine(-3);
    centerLine(0);
    centerLine(3);
  }

  void centerLine(float offset) {
    line(rectPosX+3, rectPosY+rectHeight/2+offset,
      rectPosX+rectWidth-3, rectPosY+rectHeight/2+offset);
  }

  void mousePressedRect() {
    if (mouseOver()) {
      holdScrollRect=true;
      offsetMouseY=mouseY-rectPosY;
    }
  }

  void mouseReleasedRect() {
    scrollRect.holdScrollRect=false;
  }

  void update() {
    // dragging of the mouse
    if (holdScrollRect) {
      rectPosY=mouseY-offsetMouseY;
      if (rectPosY<0)
        rectPosY=0;
      if (rectPosY+rectHeight>height-1)
        rectPosY=height-rectHeight-1;
    }
  }

  float scrollValue() {
    return
      map(rectPosY,
      0, height-rectHeight,
      0, - (heightOfCanvas - height));
  }

  boolean mouseOver() {
    return mouseX>rectPosX&&
      mouseX<rectPosX+rectWidth&&
      mouseY>rectPosY&&
      mouseY<rectPosY+rectHeight;
  }//function
  //
}//class
