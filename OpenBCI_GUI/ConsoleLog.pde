import java.awt.datatransfer.*;
import java.awt.Toolkit;

class ConsoleWindow extends PApplet {
  ClipHelper clipboardCopy = new ClipHelper();

  ConsoleWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(500, 200);
  }

  void setup() {
    background(150);
  }

  void draw() {
    //ellipse(random(width), random(height), random(50), random(50));
  }

  void mousePressed() {
    println("mousePressed in secondary window");
    String stringToCopy = "This is multi-line data \n Then a new line \n and another new ling \n how many moar lines?";
    clipboardCopy.copyString(stringToCopy);
  }

  void exit() {
    dispose();
  }
}

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
