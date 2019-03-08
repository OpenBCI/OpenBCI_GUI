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

  ControlP5 cp5ConsoleWindow;
  Textarea consoleTextArea;
  int headerHeight = 42;
  float heightOfConsoleCanvas = 500 - headerHeight;

  int previousConsoleDataSize = 0;
  boolean consoleMouseEvent = false;

  private boolean visible = true;
  private boolean updating = false;

  ClipHelper clipboardCopy = new ClipHelper();

  ConsoleWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(620, 500);
  }

  void setup() {
    //println("This goes to the console.");
    surface.setAlwaysOnTop(true);
    cp5ConsoleWindow = new ControlP5(this);
    consoleTextArea = cp5ConsoleWindow.addTextarea("ConsoleWindow")
      .setPosition(0, headerHeight)
      .setSize(width, height - headerHeight)
      .setFont(createFont("arial", 14))
      .setLineHeight(18)
      .setColor(color(242))
      .setColorBackground(color(42, 100))
      .setColorForeground(color(42, 100))
      .setScrollBackground(color(70, 100))
      .setScrollForeground(color(144, 100))
    ;

    // add all available console info when opening a new console window
    for (int i = 0; i < consoleData.data.size(); i++) {
      consoleTextArea.append(consoleData.data.get(i)+"\n");
    }

    consolePrint("ConsoleWindow: Console opened!");

    setVisible(true);
    setUpdating(true);
  }

  void draw() {

    clear();

    if (consoleData.data.size() > previousConsoleDataSize) {
      String s = consoleData.data.get(consoleData.data.size()-1);
      consoleTextArea.append(s+"\n");
    }

    scene();
    cp5ConsoleWindow.draw();
    previousConsoleDataSize =  consoleData.data.size();

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
  }

  void mousePressed() {
    //consolePrint("mousePressed in secondary window");
    consoleMouseEvent = true;
  }

  void mouseReleased() {
    consoleMouseEvent = false;
  }

  void exit() {
    consolePrint("ConsoleWindow: Console closed!");
    consoleWindowExists = false;
    dispose();
  }

  // --------------------------------------------------------------

  void scene() {
    background(42);
    pushMatrix();

    int fontHeight = 12;
    float fontSpacing = 1.2;
    int textY = 4;

    fill(42);
    rect(0, 0, width, headerHeight);

    //text("mouseY = " + mouseY, width-130, heightOfConsoleCanvas-48);
    //text("End of virtual canvas", width-130, heightOfConsoleCanvas-32);

    popMatrix();
  }

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
  }//end class
}//end class

// --------------------------------------------------------------

class ConsoleData {

  StringList data = new StringList();
  int outputLine = 0;

  void setupConsoleOutput() {
    try {
      String file = sketchPath() + "/SavedData/Settings/console-data.txt";

      File consoleDataFile = new File(sketchPath()+"/SavedData/Settings/");
      if (!consoleDataFile.isDirectory()) consoleDataFile.mkdir();

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
