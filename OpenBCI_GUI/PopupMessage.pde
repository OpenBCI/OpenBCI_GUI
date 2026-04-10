import java.awt.Frame;
import processing.awt.PSurfaceAWT;

// Instantiate this class to show a popup message

class PopupMessage extends PApplet implements Runnable {
    private final int defaultWidth = 500;
    private final int defaultHeight = 250;

    private final int headerHeight = 55;
    protected final int padding = 20;

    private final int buttonWidth = 120;
    protected final int buttonHeight = 40;

    private String message = "Empty Popup";
    private String headerMessage = "Error";
    protected String buttonMessage = "OK";
    private String buttonLink = null;

    private color headerColor = OPENBCI_BLUE;
    protected color buttonColor = OPENBCI_BLUE;
    private color backgroundColor = GREY_235;
    
    protected ControlP5 cp5;

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
        surface.setAlwaysOnTop(true);
        surface.setResizable(false);

        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.toFront();
        frame.requestFocus();

        cp5 = new ControlP5(this);
        cp5.setAutoDraw(false);

        createPrimaryButton();
    }

    @Override
    void draw() {

        final int w = width;
        final int h = height;

        pushStyle();

        // draw bg
        background(OPENBCI_DARKBLUE);
        stroke(204);
        fill(backgroundColor);
        rect(0, 0, w, h);

        // draw header
        noStroke();
        fill(headerColor);
        rect(0, 0, w, headerHeight);

        //draw header text
        textFont(p0, 24);
        fill(WHITE);
        textAlign(LEFT, CENTER);
        text(headerMessage, 0 + padding, headerHeight/2);

        //draw message
        textFont(p3, 16);
        fill(GREY_100);
        textAlign(LEFT, TOP);
        text(message, 0 + padding, 0 + padding + headerHeight, w - padding*2, h - padding*2 - headerHeight);

        popStyle();
        
        try {
            cp5.draw();
        } catch (ConcurrentModificationException e) {
            println("PopupMessage Base Class: Error drawing cp5" + e.getMessage());
        }
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

    protected void createPrimaryButton() {
        cp5.addButton("onPrimaryButtonPressed")
            .setPosition(width/2 - buttonWidth/2, height - buttonHeight - padding)
            .setSize(buttonWidth, buttonHeight)
            .setColorLabel(color(255))
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(buttonColor);
        cp5.getController("onPrimaryButtonPressed")
            .getCaptionLabel()
            .setFont(p1)
            .toUpperCase(false)
            .setSize(20)
            .setText(buttonMessage)
            .getStyle()
            .setMarginTop(-2);
    }

    public void onPrimaryButtonPressed() {
        if (buttonLink != null) {
            link(buttonLink);
        }
        noLoop();
        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.dispose();
        exit();
    }
};
