import java.awt.Frame;
import processing.awt.PSurfaceAWT;

public boolean filterUIPopupIsOpen = false;

// Instantiate this class to show a popup message
class FilterUIPopup extends PApplet implements Runnable {
    private int fixedWidth;
    private int variableHeight;
    private int newVariableHeight;
    private int shortHeight;
    private int maxHeight;
    private boolean needToResizePopup = false;
    private boolean needToResetCp5Graphics = false;

    private int middle;
    private final int sm_spacer = 6;
    private final int halfSmSpacer = sm_spacer/2;
    private final int lg_spacer = 12;
    private int uiObjectHeight = 26;
    private final int headerHeight = uiObjectHeight + sm_spacer*2;
    private final int headerObjWidth = 90;
    private final int halfObjWidth = headerObjWidth/2;
    private final int numHeaderObjects = 4;
    private final int numColumns = 5;
    private final int numFooterObjects = 3;
    private int[] headerObjX = new int[numHeaderObjects];
    private final int headerObjY = sm_spacer;
    private int[] columnObjX = new int[numColumns];
    private int footerObjY = 0;
    private int[] footerObjX = new int[numFooterObjects];

    private String message = "Sample text string";
    private String headerMessage = "Filters";
    private String buttonMessage = "OK";
    private String buttonLink = null;

    private color headerColor = OPENBCI_BLUE;
    private color buttonColor = OPENBCI_BLUE;
    
    private ControlP5 cp5;

    private final int textfieldWidth = 80;
    private final int halfTextfieldWidth = textfieldWidth/2;
    private final int onOff_diameter = uiObjectHeight;
    

    private ScrollableList bfGlobalFilterDropdown;
    private ScrollableList bfEnvironmentalNoiseDropdown;
    private Button saveButton;
    private Button loadButton;
    private Button defaultButton;

    private Button masterOnOffButton;
    private Textfield masterFirstColumnTextfield;
    private Textfield masterSecondColumnTextfield;
    private ScrollableList masterFilterTypeDropdown;
    private ScrollableList masterFilterOrderDropdown;

    private Button[] onOffButtons;
    private Textfield[] firstColumnTextfields;
    private Textfield[] secondColumnTextfields;
    private ScrollableList[] filterTypeDropdowns;
    private ScrollableList[] filterOrderDropdowns;
    
    private boolean masterFirstColumnTextfieldWasActive;
    private boolean masterSecondColumnTextfieldWasActive;
    private boolean[] firstColumnTextfieldWasActive;
    private boolean[] secondColumnTextfieldWasActive;
   
    private boolean[] filterSettingsWereModified;
    private int[] filterSettingsWereModifiedFadeCounter;
    private boolean masterFilterSettingWasModified;
    private int masterFilterSettingWasModifiedFadeCounter;
    private int filterSettingWasModifiedFadeTime = 1000;

    private final int typeDropdownWidth = headerObjWidth;
    private final int orderDropdownWidth = 60;
    private int widthOfAllChannelColumns;
    
    private int expanderX, expanderY, expanderW;
    private final int expanderH = 20;
    private boolean expanderIsHover = false;
    private int expanderTriangleWidth = 12;
    private int expanderTriangleHeight = 6;
    private int expanderBreakMiddle = 90;
    private int expanderLineOneEnd;
    private int expanderLineTwoStart;
    private int[] expanderTriangleXYCollapsed = new int[6];
    private int[] expanderTriangleXYExpanded = new int[6];
    private boolean ignoreExpanderInteraction = false;
    List<controlP5.ScrollableList> cp5ElementsToCheck = new ArrayList<controlP5.ScrollableList>();

    DecimalFormat df = new DecimalFormat("#.0");

    public FilterUIPopup() {
        super();
        filterUIPopupIsOpen = true;

        Thread t = new Thread(this);
        t.start();

        int numChans = filterSettings.getChannelCount();
        onOffButtons = new Button[numChans];
        firstColumnTextfields = new Textfield[numChans];
        secondColumnTextfields = new Textfield[numChans];
        filterTypeDropdowns = new ScrollableList[numChans];
        filterOrderDropdowns = new ScrollableList[numChans];
        firstColumnTextfieldWasActive = new boolean[numChans];
        secondColumnTextfieldWasActive = new boolean[numChans];
        filterSettingsWereModified = new boolean[numChans];
        filterSettingsWereModifiedFadeCounter = new int[numChans];

        fixedWidth = (headerObjWidth * 6) + sm_spacer*5;
        maxHeight = headerHeight*3 + sm_spacer*(numChans+5) + uiObjectHeight*(numChans+2) + expanderH;
        shortHeight = headerHeight*2 + sm_spacer*(1+5) + uiObjectHeight*(1+2) + lg_spacer + expanderH;
        variableHeight = shortHeight;
        //Include spacer on the outside left and right of all columns. Used to draw visual feedback
        widthOfAllChannelColumns = headerObjWidth*numColumns + lg_spacer*(numColumns-1) + lg_spacer*2;
    }

    @Override
    public void run() {
        PApplet.runSketch(new String[] {headerMessage}, this);
    }

    @Override
    void settings() {
        size(fixedWidth, variableHeight);
    }

    @Override
    void setup() {
        surface.setTitle(headerMessage);
        surface.setAlwaysOnTop(true);
        surface.setResizable(false);

        cp5 = new ControlP5(this);
        cp5.setGraphics(this, 0, 0);
        cp5.setAutoDraw(false);

        createAllCp5Objects();
    }

    @Override
    void draw() {

        // Important: Reset the CP5 graphics reference points X,Y,W,H at the beginning of the next draw after screen has been resized.
        // Otherwise, the numbers are wrong.
        if (needToResetCp5Graphics) {
            variableHeight = height;
            arrangeAllObjectsXY();
            cp5.setGraphics(this, 0, 0);
        }

        if (needToResizePopup) {
            // Resize the window. Reset the CP5 graphics at the beginning of the next draw().
            surface.setSize(fixedWidth, newVariableHeight);
            needToResizePopup = false;
            needToResetCp5Graphics = true;
        }

        checkIfSessionWasClosed();
        checkIfSettingsWereLoaded();

        final int w = fixedWidth;
        final int h = variableHeight;

        pushStyle();

        // Draw background
        background(OPENBCI_DARKBLUE);
        stroke(204);
        fill(238);
        rect(0, 0, width, height);

        // Draw visual feedback that a channel was modified
        // When a user interacts with an object for a channel, it will highlight blue and fade out
        if (masterFilterSettingWasModified) {
            // Fade out the color alpha value from 190 to 0 over time (ex. 1 second)
            int timeDelta = millis() - masterFilterSettingWasModifiedFadeCounter;
            int alphaFadeValue = (int)map(timeDelta, 0, filterSettingWasModifiedFadeTime, 190, 0);
            fill(color(57, 128, 204, alphaFadeValue)); //light blue from TopNav
            noStroke();
            rect(columnObjX[0] - lg_spacer, (int)masterOnOffButton.getPosition()[1] - (int)sm_spacer/2, widthOfAllChannelColumns, uiObjectHeight + sm_spacer);
            if (timeDelta > filterSettingWasModifiedFadeTime) {
                masterFilterSettingWasModified = false;
            }
        }
        
        for (int i = 0; i < filterSettings.getChannelCount(); i++) {
            if (filterSettingsWereModified[i]) {
                int timeDelta = millis() - filterSettingsWereModifiedFadeCounter[i];
                // Fade the color alpha value from 190 to 0
                int alphaFadeValue = (int)map(timeDelta, 0, filterSettingWasModifiedFadeTime, 190, 0);
                fill(color(57, 128, 204, alphaFadeValue)); //light blue from TopNav
                noStroke();
                rect(columnObjX[0] - lg_spacer, (int)onOffButtons[i].getPosition()[1] - (int)sm_spacer/2, widthOfAllChannelColumns, uiObjectHeight + sm_spacer);
                if (timeDelta > filterSettingWasModifiedFadeTime) {
                    filterSettingsWereModified[i] = false;
                }
            }
        }
        
        // Draw header
        noStroke();
        fill(headerColor);
        rect(0, 0, width, headerHeight);

        // Draw Channel Expander
        lockExpanderOnOverlapCheck(cp5ElementsToCheck);
        expanderIsHover = mouseY > expanderY - expanderH/2
            && mouseX < expanderX + expanderW
            && mouseY < expanderY + expanderH/2
            && mouseX > expanderX
            && !ignoreExpanderInteraction;
        color expanderColor = expanderIsHover ? OPENBCI_BLUE : color(102);
        int[] triXY = filterSettings.values.filterChannelSelect == FilterChannelSelect.ALL_CHANNELS ?
            expanderTriangleXYCollapsed :
            expanderTriangleXYExpanded;
        stroke(expanderColor);
        fill(expanderColor);
        line(expanderX, expanderY, expanderLineOneEnd, expanderY);
        line(expanderLineTwoStart, expanderY, expanderX + expanderW - 1, expanderY);
        textAlign(CENTER, TOP);
        textFont(p6, 10);
        StringBuilder expanderString = new StringBuilder();
        expanderString.append(filterSettings.values.filterChannelSelect == FilterChannelSelect.ALL_CHANNELS ? "Show " : "Hide ");
        expanderString.append("Channels");
        int expanderTextWidth = (int)textWidth(expanderString.toString()) + 4;
        text(expanderString.toString(), middle - expanderTextWidth/2, expanderY - expanderH/2 - 2, expanderTextWidth, expanderH);
        noStroke();
        triangle(triXY[0], triXY[1], triXY[2], triXY[3], triXY[4], triXY[5]);
        
        // Draw text labels
        textFont(p3, 16);
        textAlign(RIGHT, TOP);
        // Header labels
        fill(WHITE);
        text("Filter", headerObjX[0], headerObjY, headerObjWidth, uiObjectHeight);
        text("Notch", headerObjX[2], headerObjY, headerObjWidth, uiObjectHeight);
        // Column labels
        textAlign(CENTER, TOP);
        fill(102);
        text("Channel", columnObjX[0], headerHeight + sm_spacer, textfieldWidth, headerHeight);
        String firstColumnHeader = "";
        String secondColumnHeader = "";
        if (filterSettings.values.brainFlowFilter == BFFilter.BANDPASS) {
            firstColumnHeader = "Start (Hz)";
            secondColumnHeader = "Stop (Hz)";
        } else if (filterSettings.values.brainFlowFilter == BFFilter.BANDSTOP) {
            firstColumnHeader = "Start (Hz)";
            secondColumnHeader = "Stop (Hz)";
        }
        text(firstColumnHeader, columnObjX[1], headerHeight + sm_spacer, textfieldWidth, headerHeight);
        text(secondColumnHeader, columnObjX[2], headerHeight + sm_spacer, textfieldWidth, headerHeight);
        text("Type", columnObjX[3], headerHeight + sm_spacer, textfieldWidth, headerHeight);
        text("Order", columnObjX[4], headerHeight + sm_spacer, textfieldWidth, headerHeight);
        
        popStyle();
        
        // Catch an exception that only really happens when trying to close the Filter UI.
        // This is the only class that has write access to FilterSettings.
        // No other Classes have access to the private Cp5 objects in this class.
        try {
            cp5.draw();
        } catch (Exception e) {
            //println(e.getMessage());
            println("Caught ConcurrentModificationExcpetion in Filter UI...");
        }
        
    }

    @Override
    void mousePressed() {
        if (expanderIsHover) {
            filterSettings.values.filterChannelSelect = 
                filterSettings.values.filterChannelSelect == FilterChannelSelect.CUSTOM_CHANNELS ?
                FilterChannelSelect.ALL_CHANNELS :
                FilterChannelSelect.CUSTOM_CHANNELS;
            setUItoChannelMode(filterSettings.values.filterChannelSelect);
        }
    }

    @Override
    void mouseReleased() {

    }

    @Override
    void exit() {
        dispose();
        filterUIPopupIsOpen = false;
    }

    private void checkIfSessionWasClosed() {
        if (systemMode == SYSTEMMODE_PREINIT) {
            noLoop();
            Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
            frame.dispose();
            exit();
        }
    }

    private void checkIfSettingsWereLoaded() {
        if (filterSettingsWereLoadedFromFile) {
            try {
                updateHeaderCp5Objects();
                updateChannelCp5Objects();
                setUItoChannelMode(filterSettings.values.filterChannelSelect);
            } catch (Exception e) {
                println(e.getMessage());
                outputError("Filter Settings: Unable to apply settings. Please save Filter Settings to a new file.");
            }
            filterSettingsWereLoadedFromFile = false;
        }   
    }

    private void createAllCp5Objects() {
        calculateXYForHeaderColumnsAndFooter();
        
        createFilterSettingsSaveButton("saveFilterSettingsButton", "Save", footerObjX[0], footerObjY, headerObjWidth, uiObjectHeight);
        createFilterSettingsLoadButton("loadFilterSettingsButton", "Load", footerObjX[1], footerObjY, headerObjWidth, uiObjectHeight);
        createFilterSettingsDefaultButton("defaultFilterSettingsButton", "Reset", footerObjX[2], footerObjY, headerObjWidth, uiObjectHeight);
        
        createOnOffButtons();
        createTextfields();
        createTypeDropdowns();
        createOrderDropdowns();

        // Create header objects last so they always draw on top!
        bfGlobalFilterDropdown = createDropdown("filter", -1, headerObjX[1], headerObjY, headerObjWidth, filterSettings.values.brainFlowFilter, BFFilter.values());
        bfEnvironmentalNoiseDropdown = createDropdown("environmentalFilter", -1, headerObjX[3], headerObjY, headerObjWidth - 10, filterSettings.values.globalEnvFilter, GlobalEnvironmentalFilter.values());
        cp5ElementsToCheck.add(bfGlobalFilterDropdown);
        cp5ElementsToCheck.add(bfEnvironmentalNoiseDropdown);
        
        updateChannelCp5Objects();
        arrangeAllObjectsXY();
        setUItoChannelMode(filterSettings.values.filterChannelSelect);
    }

    private void updateHeaderCp5Objects() {
        bfGlobalFilterDropdown.getCaptionLabel().setText(filterSettings.values.brainFlowFilter.getString());
        bfEnvironmentalNoiseDropdown.getCaptionLabel().setText(filterSettings.values.globalEnvFilter.getString());
    }

    private void calculateXYForHeaderColumnsAndFooter() {
        middle = width / 2;

        headerObjX[0] = middle - sm_spacer*2 - headerObjWidth*2;
        headerObjX[1] = middle - sm_spacer - headerObjWidth;
        headerObjX[2] = middle + sm_spacer - halfObjWidth;
        headerObjX[3] = middle + sm_spacer*2 + headerObjWidth - halfObjWidth;
        
        columnObjX[0] = middle - halfObjWidth - lg_spacer*2 - headerObjWidth*2;
        columnObjX[1] = middle - halfObjWidth - lg_spacer - headerObjWidth;
        columnObjX[2] = middle - halfObjWidth;
        columnObjX[3] = middle + halfObjWidth + lg_spacer;
        columnObjX[4] = middle + halfObjWidth + lg_spacer*2 + headerObjWidth;

        footerObjX[0] = middle - halfObjWidth - lg_spacer - headerObjWidth;
        footerObjX[1] = middle - halfObjWidth;
        footerObjX[2] = middle + halfObjWidth + lg_spacer;
        setFooterObjYPosition(filterSettings.values.filterChannelSelect);

        expanderLineOneEnd = middle - expanderBreakMiddle/2;
        expanderLineTwoStart = middle + expanderBreakMiddle/2;
    }

    public void arrangeAllObjectsXY() {
        calculateXYForHeaderColumnsAndFooter();

        bfGlobalFilterDropdown.setPosition(headerObjX[1], headerObjY);
        bfEnvironmentalNoiseDropdown.setPosition(headerObjX[3], headerObjY);

        int rowY = (int)masterOnOffButton.getPosition()[1];
        int onOffButtonNewX = columnObjX[0] + textfieldWidth/2 - onOff_diameter/2;
        int filterOrderDropdownNewX = columnObjX[4] + textfieldWidth/2 - orderDropdownWidth/2;
        masterOnOffButton.setPosition(onOffButtonNewX, rowY);
        masterFirstColumnTextfield.setPosition(columnObjX[1], rowY);
        masterSecondColumnTextfield.setPosition(columnObjX[2], rowY);
        masterFilterTypeDropdown.setPosition(columnObjX[3], rowY);
        masterFilterOrderDropdown.setPosition(filterOrderDropdownNewX, rowY);

        expanderX = columnObjX[0] - lg_spacer;
        expanderY = (int)masterOnOffButton.getPosition()[1] + uiObjectHeight + sm_spacer + expanderH/2; 
        expanderW = widthOfAllChannelColumns;

        expanderTriangleXYExpanded[0] = expanderX + expanderW/2 - expanderTriangleWidth/2;
        expanderTriangleXYExpanded[1] = expanderY + 2;
        expanderTriangleXYExpanded[2] = expanderX + expanderW/2;
        expanderTriangleXYExpanded[3] = expanderY + 2 + expanderTriangleHeight;
        expanderTriangleXYExpanded[4] = expanderX + expanderW/2 + expanderTriangleWidth/2;
        expanderTriangleXYExpanded[5] = expanderTriangleXYExpanded[1];

        expanderTriangleXYCollapsed[0] = expanderTriangleXYExpanded[0];
        expanderTriangleXYCollapsed[1] = expanderTriangleXYExpanded[3];
        expanderTriangleXYCollapsed[2] = expanderTriangleXYExpanded[2];
        expanderTriangleXYCollapsed[3] = expanderTriangleXYExpanded[1];
        expanderTriangleXYCollapsed[4] = expanderTriangleXYExpanded[4];
        expanderTriangleXYCollapsed[5] = expanderTriangleXYExpanded[3];

        for (int chan = 0; chan < filterSettings.getChannelCount(); chan++) {
            rowY = (int)onOffButtons[chan].getPosition()[1];
            onOffButtons[chan].setPosition(onOffButtonNewX, rowY);
            firstColumnTextfields[chan].setPosition(columnObjX[1], rowY);
            secondColumnTextfields[chan].setPosition(columnObjX[2], rowY);
            filterTypeDropdowns[chan].setPosition(columnObjX[3], rowY);
            filterOrderDropdowns[chan].setPosition(filterOrderDropdownNewX, rowY);
        }

        saveButton.setPosition(footerObjX[0], footerObjY);
        loadButton.setPosition(footerObjX[1], footerObjY);
        defaultButton.setPosition(footerObjX[2], footerObjY);
    }

    // Master method to update objects from the FilterSettings Class
    private void updateChannelCp5Objects() {

        //Reusable variables to update UI objects
        color onColor = SUBNAV_LIGHTBLUE;
        color offColor = BUTTON_PRESSED_DARKGREY;
        color updateColor = offColor;
        String firstColumnTFValue = "";
        String secondColumnTFValue = "";
        BrainFlowFilterType updateFilterType = BrainFlowFilterType.BUTTERWORTH;
        BrainFlowFilterOrder updateFilterOrder = BrainFlowFilterOrder.TWO;

        //Update master control UI objects in the "ALL" channel
        switch (filterSettings.values.brainFlowFilter) {
            case BANDSTOP:
                if (filterSettings.values.masterBandStopFilterActive == FilterActiveOnChannel.ON) {
                    updateColor = onColor;
                }
                firstColumnTFValue = df.format(filterSettings.values.masterBandStopStartFreq);
                secondColumnTFValue = df.format(filterSettings.values.masterBandStopStopFreq);
                updateFilterType = filterSettings.values.masterBandStopFilterType;
                updateFilterOrder = filterSettings.values.masterBandStopFilterOrder;
                break;
            case BANDPASS:
                if (filterSettings.values.masterBandPassFilterActive == FilterActiveOnChannel.ON) {
                    updateColor = onColor;
                }
                firstColumnTFValue = df.format(filterSettings.values.masterBandPassStartFreq);
                secondColumnTFValue = df.format(filterSettings.values.masterBandPassStopFreq);
                updateFilterType = filterSettings.values.masterBandPassFilterType;
                updateFilterOrder = filterSettings.values.masterBandPassFilterOrder;
                break;
        }
        masterOnOffButton.setColorBackground(updateColor);
        masterFirstColumnTextfield.setText(firstColumnTFValue);
        masterSecondColumnTextfield.setText(secondColumnTFValue);
        masterFilterTypeDropdown.getCaptionLabel().setText(updateFilterType.getString());
        masterFilterOrderDropdown.getCaptionLabel().setText(updateFilterOrder.getString());
        
        // Update UI objects for all channels
        for (int chan = 0; chan < filterSettings.getChannelCount(); chan++) {
            //Use same channel colors as the rest of the GUI for onOff buttons
            onColor = channelColors[chan%8];
            switch (filterSettings.values.brainFlowFilter) {
                case BANDSTOP:
                    //Fetch on/off button color
                    if (filterSettings.values.bandStopFilterActive[chan].isActive()) {
                        updateColor = onColor;
                    } else {
                        updateColor = offColor;
                    }
                    //Fetch filter values
                    firstColumnTFValue = df.format(filterSettings.values.bandStopStartFreq[chan]);
                    secondColumnTFValue = df.format(filterSettings.values.bandStopStopFreq[chan]);
                    //Fetch filter type
                    updateFilterType = filterSettings.values.bandStopFilterType[chan];
                    //Fetch order
                    updateFilterOrder = filterSettings.values.bandStopFilterOrder[chan];
                    break;
                case BANDPASS:
                    //Fetch on/off button color
                    if (filterSettings.values.bandPassFilterActive[chan].isActive()) {
                        updateColor = onColor;
                    }
                    //Fetch filter values
                    firstColumnTFValue = df.format(filterSettings.values.bandPassStartFreq[chan]);
                    secondColumnTFValue = df.format(filterSettings.values.bandPassStopFreq[chan]);
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
        createMasterOnOffButton("masterOnOffButton", "All", lg_spacer + textfieldWidth/2 - onOff_diameter/2, headerHeight*2 + sm_spacer, onOff_diameter, onOff_diameter);
        for (int chan = 0; chan < filterSettings.getChannelCount(); chan++) {
            createOnOffButton("onOffButton"+chan, str(chan+1), chan, lg_spacer + textfieldWidth/2 - onOff_diameter/2, headerHeight*2 + sm_spacer*(chan+3) + onOff_diameter*(chan+1) + expanderH, onOff_diameter, onOff_diameter);
        }
    }

    private void createOnOffButton(String name, final String text, final int chan, int _x, int _y, int _w, int _h) {
        onOffButtons[chan] = createButton(cp5, name, text, _x, _y, _w, _h, 0, h2, 16, channelColors[chan%8], WHITE, BUTTON_HOVER, BUTTON_PRESSED, (Integer) null, -2);
        onOffButtons[chan].setCircularButton(true);
        onOffButtons[chan].onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //println("[" + text + "] onOff released");
                switch (filterSettings.values.brainFlowFilter) {
                    case BANDSTOP:
                        if (filterSettings.values.bandStopFilterActive[chan].isActive()) {
                            filterSettings.values.bandStopFilterActive[chan] = FilterActiveOnChannel.OFF;
                            onOffButtons[chan].setColorBackground(BUTTON_PRESSED_DARKGREY);
                        } else {
                            filterSettings.values.bandStopFilterActive[chan] = FilterActiveOnChannel.ON;
                            onOffButtons[chan].setColorBackground(channelColors[chan%8]);
                        }
                        break;
                    case BANDPASS:
                        if (filterSettings.values.bandPassFilterActive[chan].isActive()) {
                            filterSettings.values.bandPassFilterActive[chan] = FilterActiveOnChannel.OFF;
                            onOffButtons[chan].setColorBackground(BUTTON_PRESSED_DARKGREY);
                        } else {
                            filterSettings.values.bandPassFilterActive[chan] = FilterActiveOnChannel.ON;
                            onOffButtons[chan].setColorBackground(channelColors[chan%8]);
                        }
                        break;
                }
                filterSettingWasModifiedOnChannel(chan);
                //printArray(filterSettings.values.bandStopFilterActive);
                //printArray(filterSettings.values.bandPassFilterActive);
            }
        });
    }

    private void createTextfields() {
        masterFirstColumnTextfield = createMasterColumnTextfield("masterFirstColumnTextfield", 0, lg_spacer*2 + headerObjWidth, headerHeight*2 + sm_spacer, headerObjWidth, uiObjectHeight);
        masterSecondColumnTextfield = createMasterColumnTextfield("masterSecondColumnTextfield", 0, lg_spacer*3 + headerObjWidth*2, headerHeight*2 + sm_spacer, headerObjWidth, uiObjectHeight);
        for (int chan = 0; chan < filterSettings.getChannelCount(); chan++) {
            firstColumnTextfields[chan] = createChannelTextfield("firstColumnTextfield"+chan, chan, 0, lg_spacer*2 + headerObjWidth, headerHeight*2 + sm_spacer*(chan+2) + uiObjectHeight*(chan+1), headerObjWidth, uiObjectHeight);
            secondColumnTextfields[chan] = createChannelTextfield("secondColumnTextfield"+chan, chan, 0, lg_spacer*3 + headerObjWidth*2, headerHeight*2 + sm_spacer*(chan+2) + uiObjectHeight*(chan+1), headerObjWidth, uiObjectHeight);
        }
    }

    private Textfield createTextfield(final String name, int intValue, int _x, int _y, int _w, int _h) {
        //Create these textfields under cp5_widget base instance so because they are always visible
        final Textfield myTextfield = cp5.addTextfield(name)
            .setPosition(_x, _y)
            .setCaptionLabel("")
            .setSize(_w, _h)
            .setFont(createFont("Arial",12,true))
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(OPENBCI_DARKBLUE)  // text color
            .setColorForeground(color(210))  // border color when not selected - grey
            .setColorActive(isSelected_color)  // border color when selected - green
            .setColorCursor(color(26, 26, 26))
            .setText(Integer.toString(intValue)) //set the text
            .align(5, 10, 20, 40)
            .setAutoClear(false)
            .setIsCentered(true)
            ; //Don't clear textfield when pressing Enter key
        myTextfield.getValueLabel().align(CENTER, CENTER);
        //Clear textfield on double click
        myTextfield.onDoublePress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Custom Filtering: Enter your custom filter frequency.");
                myTextfield.clear();
            }
        });
        return myTextfield;
    }

    private Textfield createMasterColumnTextfield(final String name, int intValue, int _x, int _y, int _w, int _h) {
        final Textfield myTextfield = createTextfield(name, intValue, _x, _y, _w, _h);
        //Autogenerate session name if user presses Enter key and textfield value is null
        myTextfield.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                float myTextfieldValue = 0;
                boolean isFirstColumn = name.startsWith("masterFirstColumn");
                //TODO: Set to default value if the textfield would be blank
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && myTextfield.getText().equals("")) {
                    myTextfieldValue = getDefaultMasterFilterValueAsInt(isFirstColumn);
                    setMasterFilterValueFromTextfield(isFirstColumn, myTextfieldValue);
                }
                //Pressing ENTER in the Textfield triggers a "Broadcast"
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    //Try to clean up typing accidents from user input in Textfield
                    String rcvString = theEvent.getController().getStringValue().replaceAll("[A-Za-z!@#$%^&()=/*_]","");
                    myTextfieldValue = NumberUtils.toFloat(rcvString);
                    if (myTextfieldValue <= 0) {
                        myTextfieldValue = 0; //Only positive values will be used here
                    }
                    String valToSet = df.format(myTextfieldValue);
                    myTextfield.setText(valToSet);
                    setMasterFilterValueFromTextfield(isFirstColumn, myTextfieldValue);
                }
                if (myTextfield.isActive()) {
                    if (isFirstColumn) {
                        masterFirstColumnTextfieldWasActive = true; 
                    } else {
                        masterSecondColumnTextfieldWasActive = true;
                    }
                }
            }
        });
        //Autogenerate session name if user leaves textfield and value is null
        myTextfield.onReleaseOutside(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                boolean isFirstColumn = name.startsWith("masterFirstColumn");
                if (!myTextfield.isActive() && myTextfield.getText().equals("")) {
                    float myTextfieldValue = getDefaultMasterFilterValueAsInt(isFirstColumn);
                    String valToSet = df.format(myTextfieldValue);
                    myTextfield.setText(valToSet);
                    setMasterFilterSettingWasModified();
                } else {
                    /// If released outside textfield and a state change has occured, submit, clean, and set the value
                    if (isFirstColumn) {
                        if (masterFirstColumnTextfieldWasActive != masterFirstColumnTextfield.isActive()) {
                            myTextfield.submit();
                            masterFirstColumnTextfieldWasActive = false;
                        }
                    } else {
                        if (masterSecondColumnTextfieldWasActive != masterSecondColumnTextfield.isActive()) {
                            myTextfield.submit();
                            masterSecondColumnTextfieldWasActive = false;
                        }
                    }
                }
            }
        });
        return myTextfield;
    }

    private Textfield createChannelTextfield(final String name, final int channel, int intValue, int _x, int _y, int _w, int _h) {
        final Textfield myTextfield = createTextfield(name, intValue, _x, _y, _w, _h);
        //Autogenerate session name if user presses Enter key and textfield value is null
        myTextfield.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                float myTextfieldValue = 0;
                boolean isFirstColumn = name.startsWith("firstColumn");
                //TODO: Set to default value if the textfield would be blank
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST && myTextfield.getText().equals("")) {
                    myTextfieldValue = getDefaultFilterValueAsInt(isFirstColumn, channel);
                    setFilterValueFromTextfield(isFirstColumn, channel, myTextfieldValue);
                }
                //Pressing ENTER in the Textfield triggers a "Broadcast"
                if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                    //Try to clean up typing accidents from user input in Textfield
                    String rcvString = theEvent.getController().getStringValue().replaceAll("[A-Za-z!@#$%^&()=/*_]","");
                    myTextfieldValue = NumberUtils.toFloat(rcvString);
                    if (myTextfieldValue <= 0) {
                        myTextfieldValue = 0; //Only positive values will be used here
                    }
                    String valToSet = df.format(myTextfieldValue);
                    myTextfield.setText(valToSet);
                    setFilterValueFromTextfield(isFirstColumn, channel, myTextfieldValue);
                }
                if (myTextfield.isActive()) {
                    if (isFirstColumn) {
                        firstColumnTextfieldWasActive[channel] = true; 
                    } else {
                        secondColumnTextfieldWasActive[channel] = true;
                    }
                }
            }
        });
        //Autogenerate session name if user leaves textfield and value is null
        myTextfield.onReleaseOutside(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                boolean isFirstColumn = name.startsWith("firstColumn");
                if (!myTextfield.isActive() && myTextfield.getText().equals("")) {
                    float myTextfieldValue = getDefaultFilterValueAsInt(isFirstColumn, channel);
                    String valToSet = df.format(myTextfieldValue);
                    myTextfield.setText(valToSet);
                    filterSettingWasModifiedOnChannel(channel);
                } else {
                    /// If released outside textfield and a state change has occured, submit, clean, and set the value
                    if (isFirstColumn) {
                        if (firstColumnTextfieldWasActive[channel] != firstColumnTextfields[channel].isActive()) {
                            myTextfield.submit();
                            firstColumnTextfieldWasActive[channel] = false;
                        }
                    } else {
                        if (secondColumnTextfieldWasActive[channel] != secondColumnTextfields[channel].isActive()) {
                            myTextfield.submit();
                            secondColumnTextfieldWasActive[channel] = false;
                        }
                    }
                }
            }
        });
        return myTextfield;
    }

    private float getDefaultMasterFilterValueAsInt(boolean isFirstColumn) {
        double val = 0;
        switch (filterSettings.values.brainFlowFilter) {
            case BANDSTOP:
                if (isFirstColumn) {
                    val = filterSettings.defaultValues.masterBandStopStartFreq;
                } else {
                    val = filterSettings.defaultValues.masterBandStopStopFreq;
                }
                break;
            case BANDPASS:
                if (isFirstColumn) {
                    val = filterSettings.defaultValues.masterBandPassStartFreq;
                } else {
                    val = filterSettings.defaultValues.masterBandPassStopFreq;
                }
                break;
        }
        float valAsFloat = (float)val;
        return valAsFloat;
    }

    private void setMasterFilterValueFromTextfield(boolean isFirstColumn, float val) {
        Double valAsDouble = Double.valueOf(val);
        switch (filterSettings.values.brainFlowFilter) {
            case BANDSTOP:
                if (isFirstColumn) {
                    filterSettings.values.masterBandStopStartFreq = valAsDouble;
                    Arrays.fill(filterSettings.values.bandStopStartFreq, filterSettings.values.masterBandStopStartFreq);
                } else {
                    filterSettings.values.masterBandStopStopFreq = valAsDouble;
                    Arrays.fill(filterSettings.values.bandStopStopFreq, filterSettings.values.masterBandStopStopFreq);
                }
                break;
            case BANDPASS:
                if (isFirstColumn) {
                    filterSettings.values.masterBandPassStartFreq = valAsDouble;
                    Arrays.fill(filterSettings.values.bandPassStartFreq, filterSettings.values.masterBandPassStartFreq);
                } else {
                    filterSettings.values.masterBandPassStopFreq = valAsDouble;
                    Arrays.fill(filterSettings.values.bandPassStopFreq, filterSettings.values.masterBandPassStopFreq);
                }
                break;
        }
        updateChannelCp5Objects();
        setMasterFilterSettingWasModified();
        //println(isFirstColumn, chan, val);
        //printArray(filterSettings.values.bandPassStartFreq);
        //printArray(filterSettings.values.bandPassStopFreq);
    }

    private float getDefaultFilterValueAsInt(boolean isFirstColumn, int chan) {
        double val = 0;
        switch (filterSettings.values.brainFlowFilter) {
            case BANDSTOP:
                if (isFirstColumn) {
                    val = filterSettings.defaultValues.bandStopStartFreq[chan];
                } else {
                    val = filterSettings.defaultValues.bandStopStopFreq[chan];
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
    
    private void setFilterValueFromTextfield(boolean isFirstColumn, int chan, float val) {
        Double valAsDouble = Double.valueOf(val);
        switch (filterSettings.values.brainFlowFilter) {
            case BANDSTOP:
                if (isFirstColumn) {
                    filterSettings.values.bandStopStartFreq[chan] = valAsDouble;
                } else {
                    filterSettings.values.bandStopStopFreq[chan] = valAsDouble;
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
        filterSettingWasModifiedOnChannel(chan);
        //println(isFirstColumn, chan, val);
        //printArray(filterSettings.values.bandPassStartFreq);
        //printArray(filterSettings.values.bandPassStopFreq);
    }

    private ScrollableList createDropdown(String name, final int chan, int _x, int _y, int _w, FilterSettingsEnum e, FilterSettingsEnum[] eValues) {
        int dropdownH = uiObjectHeight;
        ScrollableList list = cp5.addScrollableList(name)
            .setPosition(_x, _y)
            .setOpen(false)
            .setColorBackground(WHITE) // text field bg color
            .setColorValueLabel(OPENBCI_DARKBLUE)       // text color
            .setColorCaptionLabel(OPENBCI_DARKBLUE)
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
                //println("FilterSettings: " + (theEvent.getController()).getName() + " == " + myEnum.getString());

                if (theEvent.getController().getName().startsWith("masterFilter")) {
                    if (myEnum instanceof BrainFlowFilterType) {
                        switch (filterSettings.values.brainFlowFilter) {
                            case BANDSTOP:
                                filterSettings.values.masterBandStopFilterType = (BrainFlowFilterType)myEnum;
                                Arrays.fill(filterSettings.values.bandStopFilterType, filterSettings.values.masterBandStopFilterType);
                                break;
                            case BANDPASS:
                                filterSettings.values.masterBandPassFilterType = (BrainFlowFilterType)myEnum;
                                Arrays.fill(filterSettings.values.bandPassFilterType, filterSettings.values.masterBandPassFilterType);
                                break;
                        }
                    } else if (myEnum instanceof BrainFlowFilterOrder) {
                        switch (filterSettings.values.brainFlowFilter) {
                            case BANDSTOP:
                                filterSettings.values.masterBandStopFilterOrder = (BrainFlowFilterOrder)myEnum;
                                Arrays.fill(filterSettings.values.bandStopFilterOrder, filterSettings.values.masterBandStopFilterOrder);
                                break;
                            case BANDPASS:
                                filterSettings.values.masterBandPassFilterOrder = (BrainFlowFilterOrder)myEnum;
                                Arrays.fill(filterSettings.values.bandPassFilterOrder, filterSettings.values.masterBandPassFilterOrder);
                                break;
                        }
                    }
                    updateChannelCp5Objects();
                    setMasterFilterSettingWasModified();
                    return;
                }

                if (myEnum instanceof BFFilter) {
                    filterSettings.values.brainFlowFilter = (BFFilter)myEnum;
                    updateChannelCp5Objects();
                } else if (myEnum instanceof GlobalEnvironmentalFilter) {
                    filterSettings.values.globalEnvFilter = (GlobalEnvironmentalFilter)myEnum;
                } else if (myEnum instanceof BrainFlowFilterType) {
                    switch (filterSettings.values.brainFlowFilter) {
                        case BANDSTOP:
                            filterSettings.values.bandStopFilterType[chan] = (BrainFlowFilterType)myEnum;
                            break;
                        case BANDPASS:
                            filterSettings.values.bandPassFilterType[chan] = (BrainFlowFilterType)myEnum;
                            break;
                    }
                    filterSettingWasModifiedOnChannel(chan);
                } else if (myEnum instanceof BrainFlowFilterOrder) {
                    switch (filterSettings.values.brainFlowFilter) {
                        case BANDSTOP:
                            filterSettings.values.bandStopFilterOrder[chan] = (BrainFlowFilterOrder)myEnum;
                            break;
                        case BANDPASS:
                            filterSettings.values.bandPassFilterOrder[chan] = (BrainFlowFilterOrder)myEnum;
                            break;
                    }
                    filterSettingWasModifiedOnChannel(chan);
                }
            }
        }
    }

    private void createTypeDropdowns() {
        //Make these dropdowns in reverse so the top ones draw above the lower ones
        for (int chan = filterSettings.getChannelCount() - 1; chan >= 0; chan--) {
            filterTypeDropdowns[chan] = createDropdown("filterType"+chan, chan, lg_spacer*4 + textfieldWidth*3, headerHeight*2 + sm_spacer*(chan+2) + uiObjectHeight*(chan+1), typeDropdownWidth, filterSettings.values.masterBandPassFilterType, BrainFlowFilterType.values());
        }
        masterFilterTypeDropdown = createDropdown("masterFilterTypeDropdown", -1, lg_spacer*4 + textfieldWidth*3, headerHeight*2 + sm_spacer, typeDropdownWidth, filterSettings.values.masterBandPassFilterType, BrainFlowFilterType.values());
        cp5ElementsToCheck.add(masterFilterTypeDropdown);
    }

    private void createOrderDropdowns() {
        for (int chan = filterSettings.getChannelCount() - 1; chan >= 0; chan--) {
            filterOrderDropdowns[chan] = createDropdown("filterOrder"+chan, chan, lg_spacer*5 + textfieldWidth*3 + typeDropdownWidth, headerHeight*2 + sm_spacer*(chan+2) + uiObjectHeight*(chan+1), orderDropdownWidth, filterSettings.values.masterBandPassFilterOrder, BrainFlowFilterOrder.values());
        }
        masterFilterOrderDropdown = createDropdown("masterFilterOrderDropdown", -1, lg_spacer*5 + textfieldWidth*3 + typeDropdownWidth, headerHeight*2 + sm_spacer, orderDropdownWidth, filterSettings.values.masterBandPassFilterOrder, BrainFlowFilterOrder.values());
        cp5ElementsToCheck.add(masterFilterOrderDropdown);
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

    private void createFilterSettingsDefaultButton(String name, String text, int _x, int _y, int _w, int _h) {
        defaultButton = createButton(cp5, name, text, _x, _y, _w, _h, h5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        defaultButton.setBorderColor(OBJECT_BORDER_GREY);
        defaultButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                filterSettings.revertAllChannelsToDefaultValues();
                filterSettingsWereLoadedFromFile = true;
            }
        });
    }

    private void createMasterOnOffButton(String name, final String text, int _x, int _y, int _w, int _h) {
        masterOnOffButton = createButton(cp5, name, text, _x, _y, _w, _h, 0, h2, 16, SUBNAV_LIGHTBLUE, WHITE, BUTTON_HOVER, BUTTON_PRESSED, (Integer) null, -2);
        masterOnOffButton.setCircularButton(true);
        masterOnOffButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //println("[" + name + "] onOff released");
                switch (filterSettings.values.brainFlowFilter) {
                    case BANDSTOP:
                        if (filterSettings.values.masterBandStopFilterActive == FilterActiveOnChannel.ON) {
                            filterSettings.values.masterBandStopFilterActive = FilterActiveOnChannel.OFF;
                            //masterOnOffButton.setColorBackground(BUTTON_PRESSED_DARKGREY);
                        } else {
                            filterSettings.values.masterBandStopFilterActive = FilterActiveOnChannel.ON;
                            //masterOnOffButton.setColorBackground(TURN_ON_GREEN);
                        }
                        //Now, update all channels based on this state
                        Arrays.fill(filterSettings.values.bandStopFilterActive, filterSettings.values.masterBandStopFilterActive);
                        break;
                    case BANDPASS:
                        if (filterSettings.values.masterBandPassFilterActive == FilterActiveOnChannel.ON) {
                            filterSettings.values.masterBandPassFilterActive = FilterActiveOnChannel.OFF;
                            //masterOnOffButton.setColorBackground(BUTTON_PRESSED_DARKGREY);
                        } else {
                            filterSettings.values.masterBandPassFilterActive = FilterActiveOnChannel.ON;
                            //masterOnOffButton.setColorBackground(TURN_ON_GREEN);
                        }
                        Arrays.fill(filterSettings.values.bandPassFilterActive, filterSettings.values.masterBandPassFilterActive);
                        break;
                }
                //Update all channel cp5 objects, including master "all" channel, with new values
                updateChannelCp5Objects();
                setMasterFilterSettingWasModified();
                //printArray(filterSettings.values.bandStopFilterActive);
                //printArray(filterSettings.values.bandPassFilterActive);
            }
        });
    }

    private void setUItoChannelMode(FilterChannelSelect myEnum) {
        int numChans = filterSettings.getChannelCount();
        boolean showAllChannels = myEnum == FilterChannelSelect.CUSTOM_CHANNELS;
        newVariableHeight =  showAllChannels ? maxHeight : shortHeight;

        for (int chan = 0; chan < numChans; chan++) {
            onOffButtons[chan].setVisible(showAllChannels);
            firstColumnTextfields[chan].setVisible(showAllChannels);
            secondColumnTextfields[chan].setVisible(showAllChannels);
            filterTypeDropdowns[chan].setVisible(showAllChannels);
            filterOrderDropdowns[chan].setVisible(showAllChannels);
        }

        setFooterObjYPosition(myEnum);
        saveButton.setPosition(footerObjX[0], footerObjY);
        loadButton.setPosition(footerObjX[1], footerObjY);

        needToResizePopup = true;
    }

    private void setFooterObjYPosition(FilterChannelSelect myEnum) {
        boolean showAllChannels = myEnum == FilterChannelSelect.CUSTOM_CHANNELS;
        int numChans = filterSettings.getChannelCount();
        int footerMaxHeightY = headerHeight*2 + sm_spacer*(numChans+4) + uiObjectHeight*(numChans+1) + lg_spacer*2 + expanderH;
        int footerMinHeightY = headerHeight*2 + sm_spacer*4 + uiObjectHeight + lg_spacer + expanderH;
        footerObjY = showAllChannels ? footerMaxHeightY : footerMinHeightY;
    }

    private void filterSettingWasModifiedOnChannel(int chan) {
        filterSettingsWereModified[chan] = true;
        filterSettingsWereModifiedFadeCounter[chan] = millis();
    }

    private void setMasterFilterSettingWasModified() {
        masterFilterSettingWasModified = true;
        masterFilterSettingWasModifiedFadeCounter = millis();
    }

    private void checkIfExpanderWasClicked() {
        setUItoChannelMode(filterSettings.values.filterChannelSelect);
    }

    private void lockExpanderOnOverlapCheck(List<controlP5.ScrollableList> listOfControllers) { 
        for (controlP5.ScrollableList c : listOfControllers) {
            if (c == null) {
                continue; //Gracefully skip over a controller if it is null
            }
            if (c.isOpen()) {
                ignoreExpanderInteraction = true;
                return;
            } else {
                ignoreExpanderInteraction = false;
            }
        }
    }
}