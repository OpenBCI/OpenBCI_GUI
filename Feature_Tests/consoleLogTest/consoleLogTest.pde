////////////////////////////////////////////////////////////
//                 consoleLogTest.pde                     //
//  This is an example of how to print console messages:  //
//      -- to console                                     //
//      -- to a file                                      //
//      -- to the screen with scrolling                   //
//                                                        //
//           Use consolePrint() over println()            //
////////////////////////////////////////////////////////////

import java.io.PrintStream;
import java.io.FileOutputStream;
import java.awt.datatransfer.*;
import java.awt.Toolkit;


int myTimer;
int secondTimer;
int timerInterval = 1500;
Boolean timerRunning = true;

ScrollRect scrollRect;        // the vertical scroll bar
float heightOfCanvas = 500;  // realHeight of the entire scene

int previousMouseY = 0;
int previousConsoleDataSize = 0;

private boolean visible = true;
private boolean updating = false;

PrintStream original = new PrintStream(System.out);
ConsoleData consoleData = new ConsoleData();
ClipHelper clipboardCopy = new ClipHelper();

void settings() {
  size(620, 500);
}

void setup() {
  //set the window to be on top of all other windows, always!
  surface.setAlwaysOnTop(true);
  //requestFocus makes the app look like there is a notification
  //((java.awt.Canvas) surface.getNative()).requestFocus();

  println("This goes to the console.");

  consoleData.setupConsoleOutput();

  consolePrint("This goes to the file and the console.");
  consolePrint("Hello Major Tom!");

  scrollRect = new ScrollRect();
  setVisible(true);
}

void draw() {
  if (timerRunning) {
    if (millis() > myTimer + timerInterval) {
      consolePrint(Integer.toString(++consoleData.outputLine));
      myTimer = millis();
    }
  }

  if (millis() > secondTimer + timerInterval*50 ) {
     ((java.awt.Canvas) surface.getNative()).requestFocus();
     consolePrint("Focus requested");
     secondTimer= millis();
     consolePrint("//redraw window when user controls scrollbar or console data is updated//redraw window when user controls scrollbar or console data is updated//redraw window when user controls scrollbar or console data is updated");
  }

  //redraw window when user controls scrollbar or console data is updated
  if ((scrollRect.holdScrollRect && (mouseY != previousMouseY))
    || (consoleData.data.size() > previousConsoleDataSize)) {
    setUpdating(true);
  } else {
    setUpdating(false);
  }
  if (updating) {
    clear();
    background(41);
    scrollRect.display();
    scrollRect.update();
    scene();
    //consolePrint("ConsoleWindow: Console Window redrawn!");
    previousConsoleDataSize =  consoleData.data.size();
  }
  previousMouseY = mouseY;
}

public boolean isVisible() {
  return visible;
}
public boolean isUpdating() {
  return updating;
}

public void setVisible(boolean _visible) {
  visible = _visible;
}
public void setUpdating(boolean _updating) {
  updating = _updating;
}

void keyReleased() {
  if (key == 'c' || key == 'C') {
    consolePrint("Copying console log to clipboard!");
    String stringToCopy = join(consoleData.data.array(), "\n");
    String formattedCodeBlock = "```\n" + stringToCopy + "\n```";
    clipboardCopy.copyString(formattedCodeBlock);
  }

  if (key == 's' || key == 'S') {
    if (!timerRunning) {
      consolePrint("Starting the timer.. \n \n new line \n \n \n \n \n \n HEYTHISISANEWLINE");
    } else {
      consolePrint("Stopping the timer..");
    }
    timerRunning = !timerRunning;
  }
}

void mousePressed() {
  scrollRect.mousePressedRect();
}

void mouseReleased() {
  scrollRect.mouseReleasedRect();
}

// --------------------------------------------------------------

void consolePrint(String _output) {
  println(_output);
  original.println(_output);
  consoleData.data.append(_output);
}

// --------------------------------------------------------------

class ConsoleData {

  StringList data = new StringList();
  int outputLine = 0;

  void setupConsoleOutput() {
    try {
      String file = dataPath("console-data.txt");
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
  float fontSpacing = 1.2;
  int textY = 4;
  // reading scroll bar
  float newYValue = scrollRect.scrollValue();
  translate (headerHeight, newYValue);
  // if the text would draw past the scren, increase the heightOfCanvas
  if ((fontHeight*(consoleData.data.size()) + 4) > (heightOfCanvas - fontHeight*2)) {
    heightOfCanvas += fontHeight*4;
  }
  //draw the text to the screen in white, adjust font and spacing as needed
  fill(255);
  for (int i = 0; i < consoleData.data.size(); i++) {
    String[] lines = split(consoleData.data.get(i), "\n");
    for (int j = 0; j < lines.length; j++) {
      textY += (int)(fontHeight*fontSpacing);
      text(lines[j], 10, textY, (int)textWidth(consoleData.data.get(i))+1, fontHeight+4);
    }
  }

  //draw header bar
  stroke(155);
  rect(0, 0, width - scrollRect.rectWidth, 30);

  text("End of virtual canvas", width-130, heightOfCanvas-16);
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

// ===============================================================
// CLIPHELPER OBJECT CLASS
class ClipHelper {
  Clipboard clipboard;

  ClipHelper() {
    getClipboard();
  }

  void getClipboard () {
    // this is our simple thread that grabs the clipboard
    Thread clipThread = new Thread() {
  public void run() {
    clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  }
    };

    // start the thread as a daemon thread and wait for it to die
    if (clipboard == null) {
  try {
    clipThread.setDaemon(true);
    clipThread.start();
    clipThread.join();
  }
  catch (Exception e) {}
    }
  }

  void copyString (String data) {
    copyTransferableObject(new StringSelection(data));
  }

  void copyTransferableObject (Transferable contents) {
    getClipboard();
    clipboard.setContents(contents, null);
  }

  String pasteString () {
    String data = null;
    try {
  data = (String)pasteObject(DataFlavor.stringFlavor);
    }
    catch (Exception e) {
  System.err.println("Error getting String from clipboard: " + e);
    }
    return data;
  }

  Object pasteObject (DataFlavor flavor)
  throws UnsupportedFlavorException, IOException
  {
    Object obj = null;
    getClipboard();

    Transferable content = clipboard.getContents(null);
    if (content != null)
    obj = content.getTransferData(flavor);

    return obj;
  }
}
