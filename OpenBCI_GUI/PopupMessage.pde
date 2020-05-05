import java.awt.Frame;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;

// Instantiate this class to show a popup message

class PopupMessage extends PApplet {
    private final int defaultWidth = 500;
    private final int defaultHeight = 250;

    private final int headerHeight = 55;
    private final int padding = 20;

    private final int buttonWidth = 100;
    private final int buttonHeight = 40;

    private String message = "Empty Popup";
    private String headerMessage = "Error";

    private color headerColor = openbciBlue;
    private color buttonColor = openbciBlue;
    
    private ControlP5 cp5;

    public PopupMessage(String header, String msg) {
        super();

        headerMessage = header;
        message = msg;

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

        cp5 = new ControlP5(this);

        cp5.addButton("onOkButtonPressed")
            .setPosition(width/2 - buttonWidth/2, height - buttonHeight - padding)
            .setSize(buttonWidth, buttonHeight)
            .setColorLabel(color(255))
            .setColorForeground(buttonColor)
            .setColorBackground(buttonColor);
        cp5.getController("onOkButtonPressed")
            .getCaptionLabel()
            .setFont(createFont("Arial",20,true))
            .toUpperCase(false)
            .setSize(20)
            .setText("OK");
    }

    @Override
    void draw() {
        final int w = defaultWidth;
        final int h = defaultHeight;

        pushStyle();
        background(bgColor);
        stroke(204);
        fill(238);
        rect((width - w)/2, (height - h)/2, w, h);
        noStroke();
        fill(headerColor);
        rect((width - w)/2, (height - h)/2, w, headerHeight);
        textFont(p0, 24);
        fill(255);
        textAlign(LEFT, CENTER);
        text(headerMessage, (width - w)/2 + padding, (height - h)/2, w, headerHeight);
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

    public void onOkButtonPressed() {
        noLoop();
        Frame frame = ( (SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.dispose();
        exit();
    }
};
