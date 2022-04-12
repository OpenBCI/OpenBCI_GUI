import java.awt.Frame;
import processing.awt.PSurfaceAWT;

// Instantiate this class to show a popup message
class FilterUIPopup extends PApplet implements Runnable {
    private final int defaultWidth = 500;
    private final int defaultHeight = 650;

    private final int sm_spacer = 6;
    private final int lg_spacer = 12;
    private int uiObjectHeight = 26;
    private final int headerHeight = uiObjectHeight + sm_spacer*2;
    private final int headerObjWidth = 90;

    private String message = "Sample text string";
    private String headerMessage = "Filters";
    private String buttonMessage = "OK";
    private String buttonLink = null;

    private color headerColor = OPENBCI_BLUE;
    private color buttonColor = OPENBCI_BLUE;
    
    private ControlP5 cp5;

    private int textfieldWidth = 80;
    private int onOff_diameter = uiObjectHeight;
    private BFFilter brainFlowFilter = BFFilter.BANDPASS;
    private FilterChannelSelect filterChannelSelect = FilterChannelSelect.CUSTOM_CHANNELS;
    private GlobalEnvironmentalFilter globalEnvFilter = GlobalEnvironmentalFilter.FIFTY_AND_SIXTY;

    private Button saveButton;
    private Button loadButton;

    private Button masterOnOffButton;
    private Textfield masterFirstColumnTextfield;
    private Textfield masterSecondColumnTextfield;
    private ScrollableList masterFilterTypeDropdown;
    private ScrollableList masterFilterOrderDropdown;
    private BrainFlowFilterType masterFilterType = BrainFlowFilterType.BUTTERWORTH;
    private BrainFlowFilterOrder masterFilterOrder = BrainFlowFilterOrder.TWO;

    private Button[] onOffButtons;
    private Textfield[] firstColumnTextfields;
    private Textfield[] secondColumnTextfields;
    private ScrollableList[] filterTypeDropdowns;
    private ScrollableList[] filterOrderDropdowns;

    private final int typeDropdownWidth = headerObjWidth;
    private final int orderDropdownWidth = 60;

    public FilterUIPopup() {
        super();

        Thread t = new Thread(this);
        t.start();

        onOffButtons = new Button[filterSettings.getChannelCount()];
        firstColumnTextfields = new Textfield[filterSettings.getChannelCount()];
        secondColumnTextfields = new Textfield[filterSettings.getChannelCount()];
        filterTypeDropdowns = new ScrollableList[filterSettings.getChannelCount()];
        filterOrderDropdowns = new ScrollableList[filterSettings.getChannelCount()];
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

        checkIfSessionWasClosed();

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
        
        //draw message
        textFont(p3, 16);
        fill(102);
        textAlign(CENTER, TOP);
        text("Channel", lg_spacer, headerHeight + sm_spacer, textfieldWidth, headerHeight);
        String firstColumnHeader = "";
        String secondColumnHeader = "";
        if (brainFlowFilter == BFFilter.BANDPASS) {
            firstColumnHeader = "Start (Hz)";
            secondColumnHeader = "Stop (Hz)";
        } else if (brainFlowFilter == BFFilter.BANDSTOP) {
            firstColumnHeader = "Center (Hz)";
            secondColumnHeader = "Width (Hz)";
        }
        text(firstColumnHeader, lg_spacer*2 + textfieldWidth, headerHeight + sm_spacer, textfieldWidth, headerHeight);
        text(secondColumnHeader, lg_spacer*3 + textfieldWidth*2, headerHeight + sm_spacer, textfieldWidth, headerHeight);
        text("Type", lg_spacer*4 + textfieldWidth*3, headerHeight + sm_spacer, typeDropdownWidth, headerHeight);
        text("Order", lg_spacer*5 + textfieldWidth*3 + typeDropdownWidth, headerHeight + sm_spacer, orderDropdownWidth, headerHeight);
        
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

    private void checkIfSessionWasClosed() {
        if (systemMode == SYSTEMMODE_PREINIT) {
            noLoop();
            Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
            frame.dispose();
            exit();
        }
    }

    private void createAllCp5Objects() {
        createOnOffButtons();
        createTextfields();
        createTypeDropdowns();
        createOrderDropdowns();

        // Create header objects last so they always draw on top!
        int headerObjY = sm_spacer;
        int halfObjWidth = headerObjWidth/2;
        int middle = defaultWidth / 2;
        int headerObj1_x = middle - halfObjWidth - sm_spacer*2 - headerObjWidth*2;
        int headerObj2_x = middle - halfObjWidth - sm_spacer - headerObjWidth;
        int headerObj3_x_middle = middle - halfObjWidth;
        int headerObj4_x = middle + halfObjWidth + sm_spacer;
        int headerObj5_x = middle + halfObjWidth + sm_spacer*2 + headerObjWidth;
        createDropdown("filter", 0, headerObj1_x, headerObjY, headerObjWidth, brainFlowFilter, BFFilter.values());
        createDropdown("channelSelect", 0, headerObj2_x, headerObjY, headerObjWidth, filterChannelSelect, FilterChannelSelect.values());
        createDropdown("environmentalFilter", 0, headerObj3_x_middle, headerObjY, headerObjWidth, globalEnvFilter, GlobalEnvironmentalFilter.values());
        createFilterSettingsSaveButton("saveFilterSettingsButton", "Save Settings", headerObj4_x, headerObjY, headerObjWidth, uiObjectHeight);
        createFilterSettingsLoadButton("loadFilterSettingsButton", "Load Settings", headerObj5_x, headerObjY, headerObjWidth, uiObjectHeight);

        updateCp5Objects();
    }

    // Master method to update objects from the FilterSettings Class
    private void updateCp5Objects() {
        
        // Update UI objects for all channels
        for (int chan = 0; chan < filterSettings.getChannelCount(); chan++) {

            color onColor = channelColors[chan%8];
            color offColor = color(50);
            color updateColor = offColor;

            String firstColumnTFValue = "";
            String secondColumnTFValue = "";

            BrainFlowFilterType updateFilterType = BrainFlowFilterType.BUTTERWORTH;

            BrainFlowFilterOrder updateFilterOrder = BrainFlowFilterOrder.TWO;

            switch (brainFlowFilter) {
                case BANDSTOP:
                    //Fetch on/off button color
                    if (filterSettings.values.bandStopFilterActive[chan] == FilterActiveOnChannel.ON) {
                        updateColor = onColor;
                    }
                    //Fetch filter values
                    firstColumnTFValue = String.valueOf(filterSettings.values.bandStopCenterFreq[chan]);
                    secondColumnTFValue = String.valueOf(filterSettings.values.bandStopWidth[chan]);
                    //Fetch filter type
                    updateFilterType = filterSettings.values.bandStopFilterType[chan];
                    //Fetch order
                    updateFilterOrder = filterSettings.values.bandStopFilterOrder[chan];
                    break;
                case BANDPASS:
                    //Fetch on/off button color
                    if (filterSettings.values.bandPassFilterActive[chan] == FilterActiveOnChannel.ON) {
                        updateColor = onColor;
                    }
                    //Fetch filter values
                    firstColumnTFValue = String.valueOf(filterSettings.values.bandPassStartFreq[chan]);
                    secondColumnTFValue = String.valueOf(filterSettings.values.bandPassStopFreq[chan]);
                    //Fetch filter type
                    updateFilterType = filterSettings.values.bandPassFilterType[chan];
                    //Fetch order
                    updateFilterOrder = filterSettings.values.bandPassFilterOrder[chan];
                    break;
            }

            //Apply changes to UI objects after fetching data
            onOffButtons[chan].setColorBackground(updateColor);
            firstColumnTextfields[chan].setText(firstColumnTFValue);
            secondColumnTextfields[chan].setText(secondColumnTFValue);
            filterTypeDropdowns[chan].getCaptionLabel().setText(updateFilterType.getString());
            filterOrderDropdowns[chan].getCaptionLabel().setText(updateFilterOrder.getString());

        }
    }

    private void createOnOffButtons() {
        //FIX ME: Master OnOff button needs to be made special
        createOnOffButton("masterOnOffButton", "All", 0, lg_spacer + textfieldWidth/2 - onOff_diameter/2, headerHeight*2 + sm_spacer, onOff_diameter, onOff_diameter);
        for (int chan = 0; chan < filterSettings.getChannelCount(); chan++) {
            createOnOffButton("onOffButton"+chan, str(chan+1), chan, lg_spacer + textfieldWidth/2 - onOff_diameter/2, headerHeight*2 + sm_spacer*(chan+2) + onOff_diameter*(chan+1), onOff_diameter, onOff_diameter);
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
                        if (filterSettings.values.bandStopFilterActive[chan] == FilterActiveOnChannel.ON) {
                            filterSettings.values.bandStopFilterActive[chan] = FilterActiveOnChannel.OFF;
                            onOffButtons[chan].setColorBackground(50);
                        } else {
                            filterSettings.values.bandStopFilterActive[chan] = FilterActiveOnChannel.ON;
                            onOffButtons[chan].setColorBackground(channelColors[chan%8]);
                        }
                        break;
                    case BANDPASS:
                        if (filterSettings.values.bandPassFilterActive[chan] == FilterActiveOnChannel.ON) {
                            filterSettings.values.bandPassFilterActive[chan] = FilterActiveOnChannel.OFF;
                            onOffButtons[chan].setColorBackground(50);
                        } else {
                            filterSettings.values.bandPassFilterActive[chan] = FilterActiveOnChannel.ON;
                            onOffButtons[chan].setColorBackground(channelColors[chan%8]);
                        }
                        break;
                }
                //printArray(filterSettings.values.bandstopFilterActive);
                //printArray(filterSettings.values.bandpassFilterActive);
            }
        });
    }

    private void createTextfields() {
        masterFirstColumnTextfield = createTextfield("masterFirstColumnTextfield", 0, 0, lg_spacer*2 + textfieldWidth, headerHeight*2 + sm_spacer, textfieldWidth, uiObjectHeight);
        masterSecondColumnTextfield = createTextfield("masterSecondColumnTextfield", 0, 0, lg_spacer*3 + textfieldWidth*2, headerHeight*2 + sm_spacer, textfieldWidth, uiObjectHeight);
        for (int chan = 0; chan < filterSettings.getChannelCount(); chan++) {
            firstColumnTextfields[chan] = createTextfield("firstColumnTextfield"+chan, chan, 0, lg_spacer*2 + textfieldWidth, headerHeight*2 + sm_spacer*(chan+2) + uiObjectHeight*(chan+1), textfieldWidth, uiObjectHeight);
            secondColumnTextfields[chan] = createTextfield("secondColumnTextfield"+chan, chan, 0, lg_spacer*3 + textfieldWidth*2, headerHeight*2 + sm_spacer*(chan+2) + uiObjectHeight*(chan+1), textfieldWidth, uiObjectHeight);
        }
    }

    private Textfield createTextfield(final String name, final int channel, int intValue, int _x, int _y, int _w, int _h) {
        //Create these textfields under cp5_widget base instance so because they are always visible
        final Textfield myTextfield = cp5.addTextfield(name)
            .setPosition(_x, _y)
            .setCaptionLabel("")
            .setSize(_w, _h)
            .setFont(createFont("Arial",12,true))
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(BLACK)  // text color
            .setColorForeground(color(210))  // border color when not selected - grey
            .setColorActive(isSelected_color)  // border color when selected - green
            .setColorCursor(color(26, 26, 26))
            .setText(Integer.toString(intValue)) //set the text
            .align(5, 10, 20, 40)
            .setAutoClear(false)
            ; //Don't clear textfield when pressing Enter key
        myTextfield.getValueLabel().align(CENTER, CENTER);
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
                float myTextfieldValue = 0;
                boolean isFirstColumn = name.startsWith("firstColumn");
                //TODO: Set to default value if the textfield would be blank
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && myTextfield.getText().equals("")) {
                    myTextfieldValue = getDefaultFilterValueAsInt(isFirstColumn, channel);
                    setFilterIntValueFromTextfield(isFirstColumn, channel, myTextfieldValue);
                }
                //Pressing ENTER in the Textfield triggers a "Broadcast"
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    //Try to clean up typing accidents from user input in Textfield
                    String rcvString = theEvent.getController().getStringValue().replaceAll("[A-Za-z!@#$%^&()=/*_]","");
                    myTextfieldValue = NumberUtils.toFloat(rcvString);
                    if (myTextfieldValue <= 0) {
                        myTextfieldValue = 0; //Only positive values will be used here
                    }
                    myTextfield.setText(String.valueOf(myTextfieldValue));
                    setFilterIntValueFromTextfield(isFirstColumn, channel, myTextfieldValue);
                }
            }
        });
        //Autogenerate session name if user leaves textfield and value is null
        // FIX ME
        myTextfield.onReleaseOutside(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!myTextfield.isActive() && myTextfield.getText().equals("")) {
                    boolean isFirstColumn = name.startsWith("firstColumn");
                    float myTextfieldValue = getDefaultFilterValueAsInt(isFirstColumn, channel);
                    myTextfield.setText(String.valueOf(myTextfieldValue));
                    //setFilterIntValueFromTextfield(isFirstColumn, channel, myTextfieldValue);
                } else {
                    String rcvString = theEvent.getController().getStringValue().replaceAll("[A-Za-z!@#$%^&()=/*_]","");
                    myTextfieldValue = NumberUtils.toFloat(rcvString);
                    if (myTextfieldValue <= 0) {
                        myTextfieldValue = 0; //Only positive values will be used here
                    }
                    myTextfield.setText(String.valueOf(myTextfieldValue));
                    setFilterIntValueFromTextfield(isFirstColumn, channel, myTextfieldValue);
                }
            }
        });
        return myTextfield;
    }

    private float getDefaultFilterValueAsInt(boolean isFirstColumn, int chan) {
        double val = 0;
        switch (brainFlowFilter) {
            case BANDSTOP:
                if (isFirstColumn) {
                    val = filterSettings.defaultValues.bandStopCenterFreq[chan];
                } else {
                    val = filterSettings.defaultValues.bandStopWidth[chan];
                }
                break;
            case BANDPASS:
                if (isFirstColumn) {
                    val = filterSettings.defaultValues.bandPassStartFreq[chan];
                } else {
                    val = filterSettings.defaultValues.bandPassStopFreq[chan];
                }
                break;
        }
        float valAsFloat = (float)val;
        return valAsFloat;
    }
    
    private void setFilterIntValueFromTextfield(boolean isFirstColumn, int chan, float val) {
        Double valAsDouble = Double.valueOf(val);
        switch (brainFlowFilter) {
            case BANDSTOP:
                if (isFirstColumn) {
                    filterSettings.values.bandStopCenterFreq[chan] = valAsDouble;
                } else {
                    filterSettings.values.bandStopWidth[chan] = valAsDouble;
                }
                break;
            case BANDPASS:
                if (isFirstColumn) {
                    filterSettings.values.bandPassStartFreq[chan] = valAsDouble;
                } else {
                    filterSettings.values.bandPassStopFreq[chan] = valAsDouble;
                }
                break;
        }
        println(isFirstColumn, chan, val);
        printArray(filterSettings.values.bandPassStartFreq);
        printArray(filterSettings.values.bandPassStopFreq);
    }

    private ScrollableList createDropdown(String name, final int chan, int _x, int _y, int _w, FilterSettingsEnum e, FilterSettingsEnum[] eValues) {
        int dropdownH = uiObjectHeight;
        ScrollableList list = cp5.addScrollableList(name)
            .setPosition(_x, _y)
            .setOpen(false)
            .setColorBackground(WHITE) // text field bg color
            .setColorValueLabel(color(0))       // text color
            .setColorCaptionLabel(color(0))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(BUTTON_PRESSED)       // border color when selected
            .setOutlineColor(OBJECT_BORDER_GREY)
            .setSize(_w, dropdownH * (eValues.length + 1))//temporary size
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
        list.addCallback(new SLCallbackListener(chan));
        return list;
    }

    private class SLCallbackListener implements CallbackListener {
        private int chan;
        SLCallbackListener(int _chan)  {
            chan = _chan;
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
                    updateCp5Objects();
                } else if (myEnum instanceof FilterChannelSelect) {
                    filterChannelSelect = (FilterChannelSelect)myEnum;
                } else if (myEnum instanceof BrainFlowFilterType) {
                    switch (brainFlowFilter) {
                        case BANDSTOP:
                            filterSettings.values.bandStopFilterType[chan] = (BrainFlowFilterType)myEnum;
                            break;
                        case BANDPASS:
                            filterSettings.values.bandPassFilterType[chan] = (BrainFlowFilterType)myEnum;
                            break;
                    }
                } else if (myEnum instanceof BrainFlowFilterOrder) {
                    switch (brainFlowFilter) {
                        case BANDSTOP:
                            filterSettings.values.bandStopFilterOrder[chan] = (BrainFlowFilterOrder)myEnum;
                            break;
                        case BANDPASS:
                            filterSettings.values.bandPassFilterOrder[chan] = (BrainFlowFilterOrder)myEnum;
                            break;
                    }
                }
            }
        }
    }

    private void createTypeDropdowns() {
        //Make these dropdowns in reverse so the top ones draw above the lower ones
        for (int chan = filterSettings.getChannelCount() - 1; chan >= 0; chan--) {
            
            filterTypeDropdowns[chan] = createDropdown("filterType"+chan, chan, lg_spacer*4 + textfieldWidth*3, headerHeight*2 + sm_spacer*(chan+2) + uiObjectHeight*(chan+1), typeDropdownWidth, masterFilterType, BrainFlowFilterType.values());
        }
        masterFilterTypeDropdown = createDropdown("masterFilterTypeDropdown", 0, lg_spacer*4 + textfieldWidth*3, headerHeight*2 + sm_spacer, typeDropdownWidth, masterFilterType, BrainFlowFilterType.values());
    }

    private void createOrderDropdowns() {
        for (int chan = filterSettings.getChannelCount() - 1; chan >= 0; chan--) {
            filterOrderDropdowns[chan] = createDropdown("filterOrder"+chan, chan, lg_spacer*5 + textfieldWidth*3 + typeDropdownWidth, headerHeight*2 + sm_spacer*(chan+2) + uiObjectHeight*(chan+1), orderDropdownWidth, masterFilterOrder, BrainFlowFilterOrder.values());
        }
        masterFilterOrderDropdown = createDropdown("masterFilterOrderDropdown", 0, lg_spacer*5 + textfieldWidth*3 + typeDropdownWidth, headerHeight*2 + sm_spacer, orderDropdownWidth, masterFilterOrder, BrainFlowFilterOrder.values());
    }

    private void createFilterSettingsSaveButton(String name, String text, int _x, int _y, int _w, int _h) {
        saveButton = createButton(cp5, name, text, _x, _y, _w, _h, h5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        saveButton.setBorderColor(OBJECT_BORDER_GREY);
        saveButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                filterSettings.storeSettings();
            }
        });
    }

    private void createFilterSettingsLoadButton(String name, String text, int _x, int _y, int _w, int _h) {
        loadButton = createButton(cp5, name, text, _x, _y, _w, _h, h5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        loadButton.setBorderColor(OBJECT_BORDER_GREY);
        loadButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                filterSettings.loadSettings();
            }
        });
    }
}