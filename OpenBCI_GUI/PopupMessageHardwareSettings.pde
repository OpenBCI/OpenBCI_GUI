import java.awt.Frame;
import processing.awt.PSurfaceAWT;

public boolean stopStreamHardwareSettingsPopupIsVisible = false;

class PopupMessageHardwareSettings extends PopupMessage {

    private final int DEFAULT_WIDTH = 500;
    private final int DEFAULT_HEIGHT = 300;

    private final String TOGGLE_CAPTION = "Don't show this popup again";
    private final int TOGGLE_CAPTION_WIDTH = 150; //Calculated from font size and caption length
    private final int TOGGLE_CAPTION_LEFT_MARGIN_PADDING = 10;
    
    private final int PRIMARY_BUTTON_WIDTH = 180;

    private Toggle hideShowToggle;

    public PopupMessageHardwareSettings() {
        super("Stop Streaming?", 
            "Streaming needs to be stopped before accessing Hardware Settings. Click the Stop Data Stream button to stop streaming and access Hardware Settings.",
            "No", 
            null)
            ;
        stopStreamHardwareSettingsPopupIsVisible = true;
    }

    @Override
    void settings() {
        size(DEFAULT_WIDTH, DEFAULT_HEIGHT);
    }

    @Override
    void setup() {
        super.setup();
        createSecondaryButton();
        createHideShowToggle();
    }

    @Override
    public void draw() {
        super.draw();
        drawCheckmark();
    }

    @Override
    void exit() {
        stopStreamHardwareSettingsPopupIsVisible = false;
        dispose();
    }

    @Override
    protected void createPrimaryButton() {
        cp5.addButton("onPrimaryButtonPressed")
            .setPosition(width/2 - padding - PRIMARY_BUTTON_WIDTH, height - buttonHeight - padding)
            .setSize(PRIMARY_BUTTON_WIDTH, buttonHeight)
            .setColorLabel(color(255))
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(buttonColor);
        cp5.getController("onPrimaryButtonPressed")
            .getCaptionLabel()
            .setFont(p3)
            .toUpperCase(false)
            .setSize(16)
            .setText(buttonMessage)
            .getStyle()
            .setMarginTop(-2);
    }

    @Override
    public void onPrimaryButtonPressed() {
        noLoop();
        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.dispose();
        exit();
    }

    private void createSecondaryButton() {
        Button myButton = cp5.addButton("onSecondaryButtonPressed")
            .setPosition(width/2 + padding,  height - buttonHeight - padding)
            .setSize(PRIMARY_BUTTON_WIDTH, buttonHeight)
            .setColorLabel(color(255))
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(buttonColor);
        myButton.getCaptionLabel()
            .setFont(p3)
            .toUpperCase(false)
            .setSize(16)
            .setText("Yes")
            .getStyle()
            .setMarginTop(-2);
        myButton.onPress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                topNav.dataStreamTogglePressed();
                widgetManager.getTimeSeriesWidget().setAdsSettingsVisible(true);
                Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
                frame.dispose();
                exit();
            }
        });
    }

    private void createHideShowToggle() {
        int _w = 20;
        int _h = 20;
        int _x = 0 + padding;
        int _y = height - buttonHeight - padding*3 - _h;
        boolean _value = !guiSettings.getShowStopStreamHardwareSettingsPopup();

        int _fontSize = 16;
        hideShowToggle = cp5.addToggle("showThisPopupToggle")
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(GREY_100)
            .setColorForeground(color(120))
            .setColorBackground(color(150))
            .setColorActive(color(57, 128, 204))
            .setVisible(true)
            .setValue(_value)
            ;
        hideShowToggle.getCaptionLabel()
            .setFont(p3)
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(TOGGLE_CAPTION)
            .getStyle() //need to grab style before affecting margin and padding
            .setMargin(-_h - 7, 0, 0, _w + TOGGLE_CAPTION_LEFT_MARGIN_PADDING)
            .setPaddingLeft(10)
            ;
        hideShowToggle.onPress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                boolean b = ((Toggle)theEvent.getController()).getBooleanValue();
                guiSettings.setShowStopStreamHardwareSettingsPopup(!b);
                if (b) {
                    println("Hardware Settings Popup: Don't show this popup in the future");
                } else {
                    println("Hardware Settings Popup: Show this popup in the future");
                }
            }
        });

        if (checkMark_20x20 == null) {
            checkMark_20x20 = loadImage("Checkmark_20x20.png");
        }

        if (checkMark_20x20 == null) {
            println("Error: Could not load checkmark image");
        }

        //hideShowToggle.setImage(checkMark_20x20, controlP5.Controller.ACTIVE);
    }

    private void drawCheckmark() {
        if (hideShowToggle.getBooleanValue()) {
            pushStyle();
            image(checkMark_20x20, padding, height - buttonHeight - padding*3 - 20);
            popStyle();
        }
    }
};