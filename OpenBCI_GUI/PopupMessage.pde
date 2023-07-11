import java.awt.Frame;
import processing.awt.PSurfaceAWT;

// Instantiate this class to show a popup message

class PopupMessage extends PApplet implements Runnable {
    private final int defaultWidth = 500;
    private final int defaultHeight = 250;

    private final int headerHeight = 55;
    private final int padding = 20;

    private final int buttonWidth = 120;
    private final int buttonHeight = 40;

    private String message = "Empty Popup";
    private String headerMessage = "Error";
    private String buttonMessage = "OK";
    private String buttonLink = null;

    private color headerColor = OPENBCI_BLUE;
    private color buttonColor = OPENBCI_BLUE;
    private color backgroundColor = GREY_235;
    
    private ControlP5 cp5;

    public PopupMessage(String header, String msg) {
        super();

        headerMessage = header;
        message = msg;

        Thread t = new Thread(this);
        t.start();        
    }

    public PopupMessage(String header, String msg, String btnMsg, String btnLink) {
        super();

        headerMessage = header;
        message = msg;
        buttonMessage = btnMsg;
        buttonLink = btnLink;

        Thread t = new Thread(this);
        t.start();        
    }

    @Override
    public void run() {
        PApplet.runSketch(new String[] {headerMessage}, this);
    }

    @Override
    void settings() {
        size(defaultWidth, defaultHeight);
    }

    @Override
    void setup() {
        surface.setTitle(headerMessage);
        surface.setAlwaysOnTop(false);
        surface.setResizable(false);

        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.toFront();
        frame.requestFocus();

        cp5 = new ControlP5(this);

        cp5.addButton("onButtonPressed")
            .setPosition(width/2 - buttonWidth/2, height - buttonHeight - padding)
            .setSize(buttonWidth, buttonHeight)
            .setColorLabel(color(255))
            .setColorForeground(buttonColor)
            .setColorBackground(buttonColor);
        cp5.getController("onButtonPressed")
            .getCaptionLabel()
            .setFont(p1)
            .toUpperCase(false)
            .setSize(20)
            .setText(buttonMessage)
            .getStyle()
            .setMarginTop(-2);
    }

    @Override
    void draw() {
        final int w = defaultWidth;
        final int h = defaultHeight;

        pushStyle();

        // draw bg
        background(OPENBCI_DARKBLUE);
        stroke(204);
        fill(backgroundColor);
        rect((width - w)/2, (height - h)/2, w, h);

        // draw header
        noStroke();
        fill(headerColor);
        rect((width - w)/2, (height - h)/2, w, headerHeight);

        //draw header text
        textFont(p0, 24);
        fill(WHITE);
        textAlign(LEFT, CENTER);
        text(headerMessage, (width - w)/2 + padding, headerHeight/2);

        //draw message
        textFont(p3, 16);
        fill(102);
        textAlign(LEFT, TOP);
        text(message, (width - w)/2 + padding, (height - h)/2 + padding + headerHeight, w-padding*2, h-padding*2-headerHeight);

        popStyle();
        
        cp5.draw();
    }

    @Override
    void mousePressed() {

    }

    @Override
    void mouseReleased() {

    }

    @Override
    void exit() {
        dispose();
    }

    public void onButtonPressed() {
        if (buttonLink != null) {
            link(buttonLink);
        }
        noLoop();
        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.dispose();
        exit();
    }
};
