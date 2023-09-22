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

static class ConsoleWindow extends PApplet implements Runnable {
    private static ConsoleWindow instance = null;

    PApplet logApplet;

    private ControlP5 cp5;
    private Textarea consoleTextArea;
    private ClipHelper clipboardCopy;

    private final int headerHeight = 42;
    private final int defaultWidth = 620;
    private final int defaultHeight = 620;
    private final int buttonWidth = 142;
    private final int buttonHeight = 34;

    //for screen resizing
    private boolean screenHasBeenResized = false;
    private float timeOfLastScreenResize = 0;
    private int widthOfLastScreen = defaultWidth;
    private int heightOfLastScreen = defaultHeight;

    static void display() {        // enforce only one Console Window
        if (instance == null) {
            instance = new ConsoleWindow();
            Thread t = new Thread(instance);
            t.start();
        }
    }

    @Override
    public void run() {
        PApplet.runSketch(new String[] {instance.getClass().getSimpleName()}, instance);
    }

    private ConsoleWindow() {
        super();
    }

    void settings() {
        size(defaultWidth, defaultHeight);
    }

    void setup() {

        logApplet = this;

        surface.setAlwaysOnTop(false);
        surface.setResizable(false);

        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.toFront();
        frame.requestFocus();

        clipboardCopy = new ClipHelper();
        cp5 = new ControlP5(this);
        PFont textAreaFont = createFont("Arial", 12, true);
        consoleTextArea = cp5.addTextarea("ConsoleWindow")
            .setPosition(0, headerHeight)
            .setSize(width, height - headerHeight)
            .setFont(textAreaFont)
            .setLineHeight(18)
            .setColor(color(242))
            .setColorBackground(color(42, 100))
            .setColorForeground(color(42, 100))
            .setScrollBackground(color(70, 100))
            .setScrollForeground(color(144, 100))
        ;

        // register this console's Textarea with the output stream object
        outputStream.registerTextArea(consoleTextArea);

        int cW = int(width/4);
        int bX = int((cW - buttonWidth) / 2);
        createConsoleLogButton("openLogFileAsText", "Open Log as Text (F)", bX);
        bX += cW;
        createConsoleLogButton("copyFullTextToClipboard", "Copy Full Text (C)", bX);
        bX += cW;
        createConsoleLogButton("copyLastLineToClipboard", "Copy Last Line (L)", bX);
        bX += cW;
        createConsoleLogButton("jumpToLastLine", "Jump to Last Line (J)", bX);
    }

    void createConsoleLogButton (String bName, String bText, int x) {
        int y = 4;  // vertical position for button
        PFont buttonFont = createFont("Arial", 14, true);
        cp5.addButton(bName)
                .setPosition(x, y)
                .setSize(buttonWidth, buttonHeight)
                .setColorLabel(color(255))
                .setColorForeground(color(31, 69, 110)) //openbci blue
                .setColorBackground(color(144, 100));
        cp5.getController(bName)
                .getCaptionLabel()
                .setFont(buttonFont)
                .toUpperCase(false)
                .setText(bText);
    }

    void draw() {
        clear();
        scene();
        cp5.draw();
        //checks if the screen is resized, similar to main GUI window
        screenResized();
    }

    void screenResized() {
        if (this.widthOfLastScreen != width || this.heightOfLastScreen != height) {
            //println("ConsoleLog: RESIZED");
            this.screenHasBeenResized = true;
            this.timeOfLastScreenResize = millis();
            this.widthOfLastScreen = width;
            this.heightOfLastScreen = height;
        }
        if (this.screenHasBeenResized) {
            //setGraphics() is very important, it lets the cp5 elements know where the origin is.
            //Without this, cp5 elements won't work after screen is resized.
            //This also happens in most widgets when the main GUI window is resized.
            logApplet = this;
            cp5.setGraphics(logApplet, 0, 0);

            imposeMinConsoleLogDimensions();
            // dynamically resize text area to fit widget
            consoleTextArea.setSize(width, height - headerHeight);
            // update button positions when screen width changes
            updateButtonPositions();
        }
        //re-initialize console log if screen has been resized and it's been more than 1 seccond (to prevent reinitialization happening too often)
        if (this.screenHasBeenResized == true && (millis() - this.timeOfLastScreenResize) > 1000) {
            this.screenHasBeenResized = false;
        }
    }

    void scene() {
        background(42);
        fill(42);
        rect(0, 0, width, headerHeight);
    }

    void keyReleased() {
        if (key == 'c') {
            copyFullTextToClipboard();
        } else if (key == 'f') {
            openLogFileAsText();
        } else if (key == 'l') {
            copyLastLineToClipboard();
        } else if (key == 'j' ) {
            jumpToLastLine();
        }
        
    }

    void keyPressed() {
        if (key == CODED) {
            if (keyCode == UP) {
                consoleTextArea.scrolled(-5);
            } else if (keyCode == DOWN) {
                consoleTextArea.scrolled(5);
            }
        }
    }

    void mousePressed() {

    }

    void mouseReleased() {

    }

    void openLogFileAsText() {
        try {
            println("ConsoleLog: Opening console log as text file!");
            File file = new File (outputStream.getFilePath());
            Desktop desktop = Desktop.getDesktop();
            if (file.exists()) {
                desktop.open(file);
            } else {
                println("ConsoleLog: ERROR - Unable to open console log as text file...");
            }
        } catch (IOException e) {}
    }

    void copyFullTextToClipboard() {
        println("ConsoleLog: Copying console log to clipboard!");
        String stringToCopy = outputStream.getFullLog();
        String formattedCodeBlock = "```\n" + stringToCopy + "\n```";
        clipboardCopy.copyString(formattedCodeBlock);
    }

    void copyLastLineToClipboard() {
        clipboardCopy.copyString(outputStream.getLastLine());
        println("ConsoleLog: Previous line copied to clipboard.");
    }

    void jumpToLastLine() {
        consoleTextArea.scroll(1.0);
    }

    void updateButtonPositions() {
        int cW = width / 4;
        int bX = (cW - buttonWidth) / 2;
        int bY = 4;
        cp5.getController("openLogFileAsText").setPosition(bX, bY);
        bX += cW;
        cp5.getController("copyFullTextToClipboard").setPosition(bX, bY);
        bX += cW;
        cp5.getController("copyLastLineToClipboard").setPosition(bX, bY);
        bX += cW;
        cp5.getController("jumpToLastLine").setPosition(bX, bY);
    }

    void imposeMinConsoleLogDimensions() {
        //impose minimum gui dimensions
        int minHeight = int(defaultHeight/2);
        if (width < defaultWidth || height < minHeight) {
            int _w = (width < defaultWidth) ? defaultWidth : width;
            int _h = (height < minHeight) ? minHeight : height;
            surface.setSize(_w, _h);
        }
    }

    void exit() {
        println("ConsoleLog: Console closed!");
        instance = null;
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
                println("ConsoleLog: Error getting String from clipboard: " + e);
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
    private PrintWriter fileOutput;
    private Textarea textArea;
    private final String filePath = directoryManager.getConsoleDataPath()+"Console_"+directoryManager.getFileNameDateTime()+".txt";

    public CustomOutputStream(OutputStream out) {
        super(out);
        data = new StringList();
        // initialize the printwriter just in case the file open fails
        fileOutput = new PrintWriter(out);

        // create log file
        try {
            fileOutput = createWriter(filePath);
        }
        catch (RuntimeException e) {
            println("Error! Failed to open " + filePath + " for write.");
            println(e);
        }
    }

    public void println(String string) {
        string += "\n";
        super.print(string);  // don't call super.println() here, you'll get double prints

        // add to array
        data.append(string);

        // print to file
        fileOutput.print(string);
        fileOutput.flush();

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
        fileOutput.flush();

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