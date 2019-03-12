////////////////////////////////////////////////////////////
//                 ConsoleLog.pde                         //
//  This is an example of how to print console messages:  //
//      -- to console                                     //
//      -- to a file                                      //
//      -- to the screen with scrolling                   //
//                                                        //
////////////////////////////////////////////////////////////


import java.io.PrintStream;
import java.io.FileOutputStream;
import java.awt.datatransfer.*;
import java.awt.Toolkit;
import java.awt.Desktop;

class ConsoleWindow extends PApplet {

  private ControlP5 cp5;
  private Textarea consoleTextArea;
  private ClipHelper clipboardCopy;

  private final int headerHeight = 42;
  private final int defaultWidth = 620;
  private final int defaultHeight = 500;
  private final int buttonWidth = 170;
  private final int buttonHeight = 34;
  private int previousWidth = defaultWidth;

  ConsoleWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(defaultWidth, defaultHeight);
  }

  void setup() {
    surface.setAlwaysOnTop(true);
    surface.setResizable(true);

    clipboardCopy = new ClipHelper();
    cp5 = new ControlP5(this);

    consoleTextArea = cp5.addTextarea("ConsoleWindow")
      .setPosition(0, headerHeight)
      .setFont(createFont("arial", 14))
      .setLineHeight(18)
      .setColor(color(242))
      .setColorBackground(color(42, 100))
      .setColorForeground(color(42, 100))
      .setScrollBackground(color(70, 100))
      .setScrollForeground(color(144, 100))
    ;

    // register this console's Textarea with the output stream object
    outputStream.registerTextArea(consoleTextArea);

    int cW = int(width/3);
    int bX = int((cW - buttonWidth) / 2);
    createConsoleLogButton("openLogFileAsText", "Open Log as Text (F)", bX);
    bX += cW;
    createConsoleLogButton("copyFullTextToClipboard", "Copy Full Log Text (C)", bX);
    bX += cW;
    createConsoleLogButton("copyLastLineToClipboard", "Copy Last Line (L)", bX);
  }

  void createConsoleLogButton (String bName, String bText, int x) {
    int y = 4;  // vertical position for button
    cp5.addButton(bName)
        .setPosition(x, y)
        .setSize(buttonWidth, buttonHeight)
        .setColorLabel(color(255))
        .setColorForeground(color(31, 69, 110))
        .setColorBackground(color(144, 100));
    cp5.getController(bName)
        .getCaptionLabel()
        .setFont(createFont("Arial",16,true))
        .toUpperCase(false)
        .setSize(16)
        .setText(bText);
  }

  void draw() {
    // dynamically resize text area to fit widget
    consoleTextArea.setSize(width, height - headerHeight);
    // update button positions when screen width changes
    updateButtonPositions();

    clear();
    scene();
    cp5.draw();
  }

  void scene() {
    background(42);
    fill(42);
    rect(0, 0, width, headerHeight);
  }

  void keyReleased() {
    if (key == 'c') {
      copyFullTextToClipboard();
    }

    if (key == 'f') {
      openLogFileAsText();
    }

    if (key == 'l') {
      copyLastLineToClipboard();
    }
  }

  void mousePressed() {

  }

  void mouseReleased() {

  }

  void openLogFileAsText() {
    try {
      println("Opening console log as text file!");
      File file = new File (outputStream.getFilePath());
      Desktop desktop = Desktop.getDesktop();
      if(file.exists()) {
        desktop.open(file);
      }
    } catch (IOException e) {}
  }

  void copyFullTextToClipboard() {
    println("Copying console log to clipboard!");
    String stringToCopy = outputStream.getFullLog();
    String formattedCodeBlock = "```\n" + stringToCopy + "\n```";
    clipboardCopy.copyString(formattedCodeBlock);
  }

  void copyLastLineToClipboard() {
    clipboardCopy.copyString(outputStream.getLastLine());
    println("Previous line copied to clipboard.");
  }

  void updateButtonPositions() {
    if (width != previousWidth) {
      int cW = width / 3;
      int bX = (cW - 170) / 2;
      int bY = 4;
      cp5.getController("openLogFileAsText").setPosition(bX, bY);
      bX += cW;
      cp5.getController("copyFullTextToClipboard").setPosition(bX, bY);
      bX += cW;
      cp5.getController("copyLastLineToClipboard").setPosition(bX, bY);
      previousWidth = width;
    }
  }

  void exit() {
    println("ConsoleWindow: Console closed!");
    consoleWindowExists = false;
    dispose();
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
        println("Error getting String from clipboard: " + e);
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

class CustomOutputStream extends PrintStream {

  private StringList data;
  private PrintStream fileOutput;
  private Textarea textArea;
  private String filePath;

  public CustomOutputStream(OutputStream out) {
    super(out);
    data = new StringList();

    // create log file
    // TODO: Figure out clean way to create file on all platforms
    try {
      File consoleDataFile = null;
      if (isWindows()) {
        consoleDataFile = new File(sketchPath("/SavedData/Settings/"));
      } else {
        consoleDataFile = new File(sketchPath()+"/SavedData/Settings/");
      }
      if (!consoleDataFile.isDirectory()) consoleDataFile.mkdir();
      filePath = consoleDataFile.getAbsolutePath() + System.getProperty("file.separator") + "console-data.txt";

      FileOutputStream outStr = new FileOutputStream(filePath, false);
      fileOutput = new PrintStream(outStr);
    }
    catch (IOException e) {
      println("Error! Check path, or filename, or security manager! "+e);
    }
  }

  public void println(String string) {
    string += "\n";
    super.print(string);  // don't call super.println() here, you'll get double prints

    // add to array
    data.append(string);

    // print to file
    fileOutput.print(string);

    // add to text area, if registered
    if (textArea != null) {
      textArea.append(string);
    }
  }

  public void print(String string) {
    super.print(string);
    string += "\n"; // TODO: shouldn't have to do this, but exceptions were printing on one line. investigate?

    // add to array
    data.append(string);

    // print to file
    fileOutput.print(string);

    // add to text area, if registered
    if (textArea != null) {
      textArea.append(string);
    }
  }

  public void registerTextArea(Textarea area) {
    textArea = area;
    textArea.setText(getFullLog());
  }

  public String getFilePath() {
    return filePath;
  }

  public String getLastLine() {
    return data.get(data.size()-1);
  }

  public String getFullLog() {
    return join(data.array(), "");
  }
}
