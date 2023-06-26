////////////////////////////////////////////////////////////
//                 EmgSettingsUI.pde                   //
//          Display the Emg Settings UI as a popup        //
//                                                        //
////////////////////////////////////////////////////////////

public boolean emgSettingsPopupIsOpen = false;

class EmgSettingsUI extends PApplet implements Runnable {

    PApplet ourApplet;
    private final String HEADER_MESSAGE = "EMG Settings";

    private final int defaultWidth = 620;
    private final int defaultHeight = 500;
    private final int buttonWidth = 142;
    private final int buttonHeight = 34;

    private ControlP5 emgCp5;
    private int x, y, w, h;
    private final int HEADER_PADDING = 42;
    private final int PADDING_3 = 3;
    private final int NAV_H = 22;
    private final int NUM_CONTROL_BUTTONS = 3;
    private final int COLUMN_LABEL_H = NAV_H;
    private final int NUM_COLUMNS = 7;
    private final int DROPDOWN_SPACER = 5;
    private int dropdownHeight = 18; 
    private int dropdownWidth;
    private boolean isFixedHeight;
    private int fixedHeight;
    private int[] dropdownYPositions;

    public EmgValues emgValues;

    private TextBox channelColumnLabel;
    private TextBox smoothLabel;
    private TextBox uvLimitLabel;
    private TextBox creepIncLabel;
    private TextBox creepDecLabel;
    private TextBox minDeltaUvLabel;
    private TextBox lowLimitLabel;

    private ScrollableList[] smoothLists;
    private ScrollableList[] uvLimitLists;
    private ScrollableList[] creepIncLists;
    private ScrollableList[] creepDecLists;
    private ScrollableList[] minDeltaUvLists;
    private ScrollableList[] lowLimitLists;

    private int channelCount;

    private String[] channelLabels;

    //for screen resizing
    private boolean screenHasBeenResized = false;
    private float timeOfLastScreenResize = 0;
    private int widthOfLastScreen = defaultWidth;
    private int heightOfLastScreen = defaultHeight;

    @Override
    public void run() {
        PApplet.runSketch(new String[] {HEADER_MESSAGE}, this);
    }

    public EmgSettingsUI() {
        super();
        emgSettingsPopupIsOpen = true;

        Thread t = new Thread(this);
        t.start();
    }

    void settings() {
        size(defaultWidth, defaultHeight);
    }

    void setup() {

        ourApplet = this;

        surface.setAlwaysOnTop(true);
        surface.setResizable(false);

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        emgCp5 = new ControlP5(ourApplet);
        emgCp5.setGraphics(ourApplet, 0,0);
        emgCp5.setAutoDraw(false);

        emgValues = dataProcessing.emgValues;
    }


    void draw() {
        clear();
        scene();
    
    }

    void screenResized() {

    }

    void scene() {
        // Draw background
        background(OPENBCI_DARKBLUE);
        stroke(204);
        fill(238);
        rect(0, 0, width, height);
    }

    void keyReleased() {
        
    }

    void keyPressed() {

    }

    void mousePressed() {

    }

    void mouseReleased() {

    }

    void exit() {
        dispose();
        emgSettingsPopupIsOpen = false;
    }

    private void checkIfSessionWasClosed() {
        if (systemMode == SYSTEMMODE_PREINIT) {
            noLoop();
            Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
            frame.dispose();
            exit();
        }
    }
}