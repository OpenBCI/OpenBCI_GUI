////////////////////////////////////////////////////////////
//                 ConsoleLog.pde                     //
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


//PrintStream original = new PrintStream(System.out);
//ConsoleData consoleData = new ConsoleData();

class ConsoleWindow extends PApplet {

  ScrollRect scrollRect;
  float heightOfConsoleCanvas = 500;  // realHeight of the entire scene

  int previousScrollRectY = 0;
  int previousConsoleDataSize = 0;

  ClipHelper clipboardCopy = new ClipHelper();

  ConsoleWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(620, 500);
  }

  void setup() {
    background(150);
    //println("This goes to the console.");

    //This function may need to be called when the GUI starts
    //After this point all println() goes to file
    //consoleData.setupConsoleOutput();

    //Thats why we use the new consolePrint()
    consolePrint("ConsoleWindow: Console opened!");

    scrollRect = new ScrollRect();
    background(90);
  }

  void draw() {
    //redraw window when user controls scrollbar or console data is updated
    if (scrollRect.holdScrollRect || (consoleData.data.size() > previousConsoleDataSize) ) {
      clear();
      scrollRect.display();
      scrollRect.update();

      scene();
      //consolePrint("ConsoleWindow: Console Window redrawn!");
      previousConsoleDataSize =  consoleData.data.size();
    }
  }

  void keyReleased() {
    if (key == 'c' || key == 'C') {
      consolePrint("Copying console log to clipboard!");
      String stringToCopy = join(consoleData.data.array(), "\n");
      String formattedCodeBlock = "```\n" + stringToCopy + "\n```";
      clipboardCopy.copyString(formattedCodeBlock);
    }
  }

  void mousePressed() {
    //consolePrint("mousePressed in secondary window");
    scrollRect.mousePressedRect();
  }

  void mouseReleased() {
    scrollRect.mouseReleasedRect();
  }


  void exit() {
    consolePrint("ConsoleWindow: Console closed!");
    dispose();
  }

  // --------------------------------------------------------------

  void scene() {
    pushMatrix();

    int fontHeight = 12;
    // reading scroll bar
    float newYValue = scrollRect.scrollValue();
    translate (0, newYValue);

    // if the text would draw past the scren, increase the heightOfCanvas
    if ((fontHeight*(consoleData.data.size()) + 4) > (heightOfConsoleCanvas - fontHeight*2)) {
      heightOfConsoleCanvas += fontHeight*4;
    }

    fill(255);

    for (int i = 0; i < consoleData.data.size(); i++) {
      String[] lines = split(consoleData.data.get(i), "\n");
      for (int j = 0; j < lines.length; j++) {
        text(lines[j], 10, fontHeight * i + fontHeight * j + 4 * 2, 500, fontHeight+4);
      }
    }
    text("mouseY = " + mouseY, width-130, heightOfConsoleCanvas-48);
    text("End of virtual canvas", width-130, heightOfConsoleCanvas-32);

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
      line (rectPosX-1, 0, rectPosX-1, height);
      rect(rectPosX, rectPosY, rectWidth, rectHeight);
      text("rectPosY = " + scrollRect.rectPosY, width-130, height-16);
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
        0, - (heightOfConsoleCanvas - height));
    }

    boolean mouseOver() {
      return mouseX>rectPosX&&
        mouseX<rectPosX+rectWidth&&
        mouseY>rectPosY&&
        mouseY<rectPosY+rectHeight;
    }//function
    //
  }//end class

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
        consolePrint("Error getting String from clipboard: " + e);
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
}//end class

// --------------------------------------------------------------

class ConsoleData {

  StringList data = new StringList();
  int outputLine = 0;

  void setupConsoleOutput() {
    try {
      String file = dataPath("console-data.txt");
      if (!new File(dataPath("")).isDirectory()) {
        if (!new File(dataPath("")).mkdirs()) {
          consolePrint("Directory creation failed!");
          exit();
        }
      }
      FileOutputStream outStr = new FileOutputStream(file, false);
      PrintStream printStream = new PrintStream(outStr);
      System.setOut(printStream);
      System.setErr(printStream);
    }
    catch (IOException e) {
      consolePrint("Error! Check path, or filename, or security manager! "+e);
    }
  }
}//end class
