import java.awt.Frame;
import processing.awt.PSurfaceAWT;

// Instantiate this class to show a popup message
class FilterUIPopup extends PApplet implements Runnable {
    private final int defaultWidth = 500;
    private final int defaultHeight = 600;

    private final int headerHeight = 32;
    private final int padding = 20;

    private final int buttonWidth = 120;
    private final int buttonHeight = 40;
    private final int spacer = 6; //space between buttons

    private String message = "Sample text string";
    private String headerMessage = "Filters";
    private String buttonMessage = "OK";
    private String buttonLink = null;

    private color headerColor = OPENBCI_BLUE;
    private color buttonColor = OPENBCI_BLUE;
    
    private ControlP5 cp5;
    private BFFilter brainFlowFilter = BFFilter.BANDSTOP;
    private FilterChannelSelect filterChannelSelect = FilterChannelSelect.ALL_CHANNELS;

    Button[] onOffButtons;

    public FilterUIPopup() {
        super();

        Thread t = new Thread(this);
        t.start();

        onOffButtons = new Button[filterSettings.getChannelCount()];
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

        cp5 = new ControlP5(this);
        cp5.setGraphics(this, 0,0);
        cp5.setAutoDraw(false);

        createAllCp5Objects();
    }

    @Override
    void draw() {
        final int w = defaultWidth;
        final int h = defaultHeight;

        pushStyle();

        // draw bg
        background(OPENBCI_DARKBLUE);
        stroke(204);
        fill(238);
        rect((width - w)/2, (height - h)/2, w, h);

        // draw header
        noStroke();
        fill(headerColor);
        rect((width - w)/2, (height - h)/2, w, headerHeight);
        
        /*
        //draw header text
        textFont(h3, 16);
        fill(255);
        textAlign(LEFT, CENTER);
        text(headerMessage, (width - w)/2 + padding, 0, w, headerHeight);
        */
        
        //draw message
        textFont(p3, 16);
        fill(102);
        textAlign(LEFT, TOP);
        text("Channel", spacer, headerHeight + spacer, w-padding*2, h-padding*2-headerHeight);
        
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

    /*
    public void onButtonPressed() {
        if (buttonLink != null) {
            link(buttonLink);
        }
        noLoop();
        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.dispose();
        exit();
    }
    */
    private void createAllCp5Objects() {
        int filterX = int(defaultWidth/2 - spacer/2 - buttonWidth);
        int filterY = spacer;
        int chanSelectX = defaultWidth/2 + spacer/2;
        createDropdown("filter", filterX, filterY, brainFlowFilter, BFFilter.values());
        createDropdown("channelSelect", chanSelectX, filterY, filterChannelSelect, FilterChannelSelect.values());

        createOnOffButtons();
    }

    private ScrollableList createDropdown(String name, int _x, int _y, FilterSettingsEnum e, FilterSettingsEnum[] eValues) {
        int dropdownW = buttonWidth;
        int dropdownH = 20;
        ScrollableList list = cp5.addScrollableList(name)
            .setPosition(_x, _y)
            .setOpen(false)
            .setColorBackground(WHITE) // text field bg color
            .setColorValueLabel(color(0))       // text color
            .setColorCaptionLabel(color(0))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(BUTTON_PRESSED)       // border color when selected
            .setOutlineColor(OBJECT_BORDER_GREY)
            .setSize(dropdownW, dropdownH * (eValues.length + 1))//temporary size
            .setBarHeight(dropdownH) //height of top/primary bar
            .setItemHeight(dropdownH) //height of all item/dropdown bars
            .setVisible(true)
            ;
        // for each entry in the enum, add it to the dropdown.
        for (FilterSettingsEnum value : eValues) {
            // this will store the *actual* enum object inside the dropdown!
            list.addItem(value.getString(), value);
        }
        //Style the text in the ScrollableList
        list.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getString())
            .setFont(h5)
            .setSize(12)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        list.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getString())
            .setFont(p6)
            .setSize(10) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        list.addCallback(new SLCallbackListener());
        return list;
    }

    private class SLCallbackListener implements CallbackListener {
        SLCallbackListener()  {
        }
        public void controlEvent(CallbackEvent theEvent) {
            //Selecting an item from ScrollableList triggers Broadcast
            if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) { 
                int val = (int)(theEvent.getController()).getValue();
                Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
                FilterSettingsEnum myEnum = (FilterSettingsEnum)bob.get("value");
                println("FilterSettings: " + (theEvent.getController()).getName() + " == " + myEnum.getString());

                if (myEnum instanceof BFFilter) {
                    brainFlowFilter = (BFFilter)myEnum;
                } else if (myEnum instanceof FilterChannelSelect) {
                    filterChannelSelect = (FilterChannelSelect)myEnum;
                }

                updateCp5Objects();
            }
        }
    }

    private void updateCp5Objects() {
        //Update button on/off visual state. We can reuse buttons in this way but maybe not other Cp5 objects.
        for (int chan = 0; chan < filterSettings.getChannelCount(); chan++) {
            color onColor = channelColors[chan%8];
            color offColor = color(50);
            color updateColor = offColor;
            switch (brainFlowFilter) {
                case BANDSTOP:
                    if (filterSettings.values.bandstopFilterActive[chan] == FilterActiveOnChannel.ON) {
                        updateColor = onColor;
                    }
                    break;
                case BANDPASS:
                    if (filterSettings.values.bandpassFilterActive[chan] == FilterActiveOnChannel.ON) {
                        updateColor = onColor;
                    }
                    break;
            }
            onOffButtons[chan].setColorBackground(updateColor);
        }
    }

    private void createOnOffButtons() {
        int onOff_diameter = 26;
        for (int chan = 0; chan < filterSettings.getChannelCount(); chan++) {
            createOnOffButton("onOffButton"+chan, str(chan+1), chan, spacer*2, headerHeight*2 + spacer*(chan+1) + onOff_diameter*chan, onOff_diameter, onOff_diameter);
        }
    }

    private void createOnOffButton(String name, final String text, int chan, int _x, int _y, int _w, int _h) {
        onOffButtons[chan] = createButton(cp5, name, text, _x, _y, _w, _h, 0, h2, 16, channelColors[chan%8], WHITE, BUTTON_HOVER, BUTTON_PRESSED, (Integer) null, -2);
        onOffButtons[chan].setCircularButton(true);
        onOffButtons[chan].onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //boolean newState = !currentBoard.isEXGChannelActive(channelIndex);
                println("[" + text + "] onOff released");
                switch (brainFlowFilter) {
                    case BANDSTOP:
                        if (filterSettings.values.bandstopFilterActive[chan] == FilterActiveOnChannel.ON) {
                            filterSettings.values.bandstopFilterActive[chan] = FilterActiveOnChannel.OFF;
                            onOffButtons[chan].setColorBackground(50);
                        } else {
                            filterSettings.values.bandstopFilterActive[chan] = FilterActiveOnChannel.ON;
                            onOffButtons[chan].setColorBackground(channelColors[chan%8]);
                        }
                        break;
                    case BANDPASS:
                        if (filterSettings.values.bandpassFilterActive[chan] == FilterActiveOnChannel.ON) {
                            filterSettings.values.bandpassFilterActive[chan] = FilterActiveOnChannel.OFF;
                            onOffButtons[chan].setColorBackground(50);
                        } else {
                            filterSettings.values.bandpassFilterActive[chan] = FilterActiveOnChannel.ON;
                            onOffButtons[chan].setColorBackground(channelColors[chan%8]);
                        }
                        break;
                }
                //printArray(filterSettings.values.bandstopFilterActive);
                //printArray(filterSettings.values.bandpassFilterActive);
                /*
                currentBoard.setEXGChannelActive(channelIndex, newState);
                if (currentBoard instanceof ADS1299SettingsBoard) {
                    w_timeSeries.adsSettingsController.updateChanSettingsDropdowns(channelIndex, currentBoard.isEXGChannelActive(channelIndex));
                    boolean hasUnappliedChanges = currentBoard.isEXGChannelActive(channelIndex) != newState;
                    w_timeSeries.adsSettingsController.setHasUnappliedSettings(channelIndex, hasUnappliedChanges);
                }
                */
            }
        });
        onOffButtons[chan].setDescription("Click to toggle filter on channel " + text + ".");
    }

    /*
    private Textfield createTextfield(String name, int intValue, int _x, int _y, int _w, int _h, color _textColor) {
        //Create these textfields under cp5_widget base instance so because they are always visible
        final Textfield myTextfield = cp5.addTextfield(name)
            .setPosition(_x, _y)
            .setCaptionLabel("")
            .setSize(_w, _h)
            .setFont(createFont("Arial",12,true))
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(_textColor)  // text color
            .setColorForeground(color(210))  // border color when not selected - grey
            .setColorActive(isSelected_color)  // border color when selected - green
            .setColorCursor(color(26, 26, 26))
            .setText("%") //set the text
            .align(5, 10, 20, 40)
            .setAutoClear(false)
            ; //Don't clear textfield when pressing Enter key
        //Clear textfield on double click
        myTextfield.onDoublePress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Custom Filtering: Enter your custom filter frequency.");
                myTextfield.clear();
            }
        });
        //Autogenerate session name if user presses Enter key and textfield value is null
        myTextfield.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && myTextfield.getText().equals("")) {
                    setTextfieldVal(getDefaultTextfieldIntVal());
                    customThreshold(myTextfield, getDefaultTextfieldIntVal());
                }
                //Pressing ENTER in the Textfield triggers a "Broadcast"
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    //Try to clean up typing accidents from user input in Textfield
                    String rcvString = theEvent.getController().getStringValue().replaceAll("[A-Za-z!@#$%^&()=/*_]","");
                    int rcvAsInt = NumberUtils.toInt(rcvString);
                    if (rcvAsInt <= 0) {
                        rcvAsInt = 0; //Only positive values will be used here
                    }
                    setTextfieldVal(rcvAsInt);
                    customThreshold(myTextfield, rcvAsInt);
                }
            }
        });
        //Autogenerate session name if user leaves textfield and value is null
        myTextfield.onReleaseOutside(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!myTextfield.isActive() && myTextfield.getText().equals("")) {
                    setTextfieldVal(getDefaultTextfieldIntVal());
                    customThreshold(myTextfield, getDefaultTextfieldIntVal());
                }
            }
        });
        return myTextfield;
    }

    private void customThreshold(Textfield tf, int value) {
        StringBuilder sb = new StringBuilder();
        sb.append(value);
        sb.append(isSignalCheckRailedMode() ? "%" : " k\u2126");
        tf.setText(sb.toString());
    }

    public void setPosition(int _x, int _y) {
        thresholdTF.setPosition(_x, _y);
    }

    private int getDefaultTextfieldIntVal() {
        return isSignalCheckRailedMode() ? defaultValue_Percentage : defaultValue_kOhms;
    }

    private int getTextfieldIntVal() {
        return isSignalCheckRailedMode() ? valuePercentage : valuekOhms;
    }

    private void setTextfieldVal(int val) {
        if (isSignalCheckRailedMode()) {
            if (name == "errorThreshold") {
                for (int i = 0; i < nchan; i++) {
                    is_railed[i].setRailedThreshold((double) val);
                }
            } else {
                for (int i = 0; i < nchan; i++) {
                    is_railed[i].setRailedWarnThreshold((double) val);
                }
            }
            valuePercentage = val;
        } else {
            if (name == "errorThreshold") {
                w_cytonImpedance.updateElectrodeStatusYellowThreshold((double)val);
            } else {
                w_cytonImpedance.updateElectrodeStatusGreenThreshold((double)val);
            }
            valuekOhms = val;
        }
    }
    */
}
