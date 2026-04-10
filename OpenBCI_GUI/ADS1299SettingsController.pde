import org.apache.commons.lang3.tuple.Pair;


class ADS1299SettingsController {
    private PApplet parentApplet;
    private boolean isVisible = false;
    protected int x, y, w, h;
    protected final int PADDING_3 = 3;
    protected final int NAV_HEIGHT = 22;
    private final int COLUMN_COUNT = 6;

    protected ControlP5 hwsCp5;
    private final int CONTROL_BUTTON_COUNT = 4;
    private Button loadButton;
    private Button saveButton;
    private Button resetButton;
    private Button sendButton;
    private int buttonWidth = 80;
    private int buttonHeight = NAV_HEIGHT;
    private final int DEFAULT_TOGGLE_WIDTH = 20;
    private final int MINIMUM_TOGGLE_WIDTH = 12;
    protected int toggleWidthAndHeight = DEFAULT_TOGGLE_WIDTH;
    private final int COLUMN_LABEL_HEIGHT = NAV_HEIGHT;
    protected final int CONTROLLER_HEADER_HEIGHT = (NAV_HEIGHT * 2) + (PADDING_3 * 2);
    private final int COMMAND_BAR_HEIGHT = NAV_HEIGHT + PADDING_3 * 2;
    protected int channelBarHeight;

    protected int spaceBetweenButtons = 5;

    protected TextBox channelSelectLabel;
    protected TextBox gainLabel;
    private TextBox inputTypeLabel;
    protected TextBox biasLabel;
    private TextBox srb2Label;
    private TextBox srb1Label;

    protected Toggle toggleAllChannels;
    protected ScrollableList gainListAll;
    protected ScrollableList inputTypeListAll;
    protected ScrollableList biasListAll;
    protected ScrollableList srb2ListAll;
    protected ScrollableList srb1ListAll;
    protected Toggle[] channelSelectToggles;
    protected ScrollableList[] gainLists;
    protected ScrollableList[] inputTypeLists;
    protected ScrollableList[] biasLists;
    protected ScrollableList[] srb2Lists;
    protected ScrollableList[] srb1Lists;
    private boolean[] channelHasUnappliedChanges;
    private boolean[] channelIsSelected;
    protected final color YES_ON_COLOR = #DFF2BF;
    protected final color NO_OFF_COLOR = #FFD2D2;

    protected Button openCustomCommandPopup;
    private int customCommandUIX;
    private int customCommandUIWidth;
    protected int customCommandUIMiddle;
    protected int customCommandObjectW;
    protected int customCommandObjectY;
    protected int customCommandObjectH;

    private ADS1299Settings boardSettings;

    protected int channelCount;
    protected List<Integer> activeChannels;

    ADS1299SettingsController(PApplet _parentApplet, List<Integer> _activeChannels, int _x, int _y, int _w, int _h, int _channelBarHeight) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        channelBarHeight = _channelBarHeight;
        
        this.parentApplet = _parentApplet;
        hwsCp5 = new ControlP5(parentApplet);
        hwsCp5.setGraphics(parentApplet, 0,0);
        hwsCp5.setAutoDraw(false);
        
        int colOffset = (w / CONTROL_BUTTON_COUNT) / 2;
        int button_y = y + h + PADDING_3;

        createLoadButton("HardwareSettingsLoad", "Load", x + colOffset - buttonWidth/2, button_y, buttonWidth, buttonHeight);
        createSaveButton("HardwareSettingsSave", "Save", x + colOffset + (w/CONTROL_BUTTON_COUNT) - buttonWidth/2, button_y, buttonWidth, buttonHeight);
        createResetButton("HardwareSettingsReset", "Reset", x + colOffset + (w/CONTROL_BUTTON_COUNT)*2 - buttonWidth/2, button_y, buttonWidth, buttonHeight);
        createSendButton("HardwareSettingsSend", "Send", x + colOffset + (w/CONTROL_BUTTON_COUNT)*3 - buttonWidth/2, button_y, buttonWidth, buttonHeight);

        activeChannels = _activeChannels;
        ADS1299SettingsBoard settingsBoard = (ADS1299SettingsBoard)currentBoard;
        boardSettings = settingsBoard.getADS1299Settings();
        boardSettings.saveAllLastValues();
        channelCount = currentBoard.getNumEXGChannels();
        channelHasUnappliedChanges = new boolean[channelCount];
        Arrays.fill(channelHasUnappliedChanges, Boolean.FALSE);
        channelIsSelected = new boolean[channelCount];
        Arrays.fill(channelIsSelected, Boolean.FALSE);

        //color labelBG = color(220);
        color labelBG = color(255,255,255,0);
        color labelTxt = OPENBCI_DARKBLUE;
        colOffset = (w / 5) / 2;
        int label_y = y - (NAV_HEIGHT * 2) - (PADDING_3 * 2);
        channelSelectLabel = new TextBox("Select", x + colOffset, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        gainLabel = new TextBox("PGA Gain", x + colOffset, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        inputTypeLabel = new TextBox("Input Type", x + colOffset + (w/5), label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        biasLabel = new TextBox("Bias Include", x + colOffset + (w/5)*2, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        srb2Label = new TextBox("SRB2", x + colOffset + (w/5)*3, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        srb1Label = new TextBox("SRB1", x + colOffset + (w/5)*4, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);

        createCustomCommandUI();
        resizeCustomCommandUI();

        createUIObjects();
    }

    public void update() {
        //Empty for now
    }

    public void draw() {

        if (isVisible) {
            //Control button space above channels
            pushStyle();
            //stroke(OPENBCI_BLUE_ALPHA50);
            stroke(OBJECT_BORDER_GREY);
            fill(GREY_100);
            rect(x, y - CONTROLLER_HEADER_HEIGHT, w, CONTROLLER_HEADER_HEIGHT);
            popStyle();

            //background
            pushStyle();
            noStroke();
            fill(GREY_100);
            rect(x, y, w + 1, h);
            popStyle();

            drawLabels();

            setUIObjectVisibility();

            drawChannelStatus();

            boolean showCustomCommandUI = guiSettings.getExpertModeBoolean();
            
            //Draw background behind command buttons
            pushStyle();
            fill(GREY_100);
            rect(x, y + h, w + 1, COMMAND_BAR_HEIGHT);
            if (showCustomCommandUI) {
                rect(customCommandUIX, y + h + COMMAND_BAR_HEIGHT, customCommandUIWidth, COMMAND_BAR_HEIGHT); //keep above style for other command buttons
            }
            popStyle();

            hideShowCustomCommandUI(showCustomCommandUI);
            
            //Draw cp5 objects on top of everything
            hwsCp5.draw();

            //Draw check marks on top of the toggle buttons
            for (int i = 0; i < channelCount; i++) {
                drawCheckMark(channelSelectToggles[i]);
            }
            //Draw check mark for All Channels toggle
            drawCheckMark(toggleAllChannels);
        }
    }

    public void resize(int _x, int _y, int _w, int _h, int _channelBarHeight) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        channelBarHeight = _channelBarHeight;
        if (channelBarHeight - 2 < DEFAULT_TOGGLE_WIDTH) {
            toggleWidthAndHeight = channelBarHeight - 2;
            if (toggleWidthAndHeight < MINIMUM_TOGGLE_WIDTH) {
                toggleWidthAndHeight = MINIMUM_TOGGLE_WIDTH;
            }
        } else {
            toggleWidthAndHeight = DEFAULT_TOGGLE_WIDTH;
        }

        hwsCp5.setGraphics(parentApplet, 0, 0);

        int colOffset = (w / CONTROL_BUTTON_COUNT) / 2;
        int button_y = y + h + PADDING_3;
        loadButton.setPosition(x + colOffset - (buttonWidth / 2), button_y);
        saveButton.setPosition(x + colOffset + (w/CONTROL_BUTTON_COUNT) - (buttonWidth / 2), button_y);
        resetButton.setPosition(x + colOffset + ((w/CONTROL_BUTTON_COUNT) * 2) - (buttonWidth / 2), button_y);
        sendButton.setPosition(x + colOffset + ((w/CONTROL_BUTTON_COUNT) * 3) - (buttonWidth / 2), button_y);
        
        updateLabelPositions();

        resizeAndPositionUIObjects();

        resizeCustomCommandUI(); 
    }


    protected void resizeAndPositionUIObjects() {
        int columnCount = getColumnCount();
        int dropdownX = 0;
        int dropdownY = 0;
        int dropdownW = int((w - (spaceBetweenButtons * (columnCount + 1))) / columnCount);
        int dropdownH = 18;

        int allChannelObjectsY = y - CONTROLLER_HEADER_HEIGHT + PADDING_3*2 + NAV_HEIGHT;
        int allChannelObjectsX = x + spaceBetweenButtons;
        int allChannelObjectsW = dropdownW;
        int allChannelObjectsH = 5 * dropdownH;
        int toggleAllX = allChannelObjectsX + (allChannelObjectsW / 2) - (toggleWidthAndHeight / 2);
        toggleAllChannels.setPosition(toggleAllX, allChannelObjectsY);
        toggleAllChannels.setSize(toggleWidthAndHeight, toggleWidthAndHeight);
        allChannelObjectsX += dropdownW + spaceBetweenButtons;
        gainListAll.setPosition(allChannelObjectsX, allChannelObjectsY);
        gainListAll.setSize(allChannelObjectsW, allChannelObjectsH);
        allChannelObjectsX += dropdownW + spaceBetweenButtons;
        inputTypeListAll.setPosition(allChannelObjectsX, allChannelObjectsY);
        inputTypeListAll.setSize(allChannelObjectsW, allChannelObjectsH);
        allChannelObjectsX += dropdownW + spaceBetweenButtons;
        biasListAll.setPosition(allChannelObjectsX, allChannelObjectsY);
        biasListAll.setSize(allChannelObjectsW, allChannelObjectsH);
        allChannelObjectsX += dropdownW + spaceBetweenButtons;
        srb2ListAll.setPosition(allChannelObjectsX, allChannelObjectsY);
        srb2ListAll.setSize(allChannelObjectsW, allChannelObjectsH);
        allChannelObjectsX += dropdownW + spaceBetweenButtons;
        srb1ListAll.setPosition(allChannelObjectsX, allChannelObjectsY);
        srb1ListAll.setSize(allChannelObjectsW, allChannelObjectsH);

        int rowCount = 0;
        for (int i : activeChannels) {
            dropdownX = x + spaceBetweenButtons;
            dropdownY = int(y + (channelBarHeight * rowCount) + ((channelBarHeight - dropdownH) / 2));
            final int buttonXIncrement = spaceBetweenButtons + dropdownW;

            int toggleX = dropdownX + (dropdownW / 2) - (toggleWidthAndHeight / 2);
            channelSelectToggles[i].setPosition(toggleX, dropdownY);
            channelSelectToggles[i].setSize(toggleWidthAndHeight, toggleWidthAndHeight);

            dropdownX += buttonXIncrement;
            gainLists[i].setPosition(dropdownX, dropdownY);
            gainLists[i].setSize(dropdownW, 5 * dropdownH); //Only enough space for SelectedItem + 4 options in the latter channels
            
            dropdownX += buttonXIncrement;
            inputTypeLists[i].setPosition(dropdownX, dropdownY);
            inputTypeLists[i].setSize(dropdownW, 5 * dropdownH); //Only enough space for SelectedItem + 4 options in the latter channels

            dropdownX += buttonXIncrement;
            biasLists[i].setPosition(dropdownX, dropdownY);
            biasLists[i].setSize(dropdownW,(biasLists[i].getItems().size()+1)*dropdownH);

            dropdownX += buttonXIncrement;
            srb2Lists[i].setPosition(dropdownX, dropdownY);
            srb2Lists[i].setSize(dropdownW,(srb2Lists[i].getItems().size()+1)*dropdownH);

            dropdownX += buttonXIncrement;
            srb1Lists[i].setPosition(dropdownX, dropdownY);
            srb1Lists[i].setSize(dropdownW,(srb1Lists[i].getItems().size()+1)*dropdownH);

            rowCount++;
        }
    }

    protected void updateLabelPositions() {
        int columnCount = getColumnCount();
        int colOffset = (w / columnCount) / 2;
        int label_y = y - CONTROLLER_HEADER_HEIGHT + PADDING_3;
        channelSelectLabel.setPosition(x + colOffset, label_y);
        gainLabel.setPosition(x + colOffset + (w  /columnCount), label_y);
        inputTypeLabel.setPosition(x + colOffset + (w / columnCount) * 2, label_y);
        biasLabel.setPosition(x + colOffset + (w / columnCount) * 3, label_y);
        srb2Label.setPosition(x + colOffset + (w / columnCount) * 4, label_y);
        srb1Label.setPosition(x + colOffset + (w / columnCount) * 5, label_y);
    }

    protected int getColumnCount() {
        return COLUMN_COUNT;
    }

    //Returns true if board and UI are in sync
    public boolean setIsVisible (boolean v) {
        
        //Check if there are unapplied settings when trying to close Hardware Settings Controller
        if (!v) {
            boolean allChannelsInSync = true;

            for (int i = 0; i < channelHasUnappliedChanges.length; i++) {
                if (channelHasUnappliedChanges[i]) {
                    allChannelsInSync = false;
                }
            }

            if (!allChannelsInSync) {
                PopupMessage msg = new PopupMessage("Info", "Highlighted channels have unapplied Hardware Settings. Please press \"Send\" button to sync with board or revert settings.");
                return false;
            }
        }

        isVisible = v;
        return true;
    }

    public boolean getIsVisible() {
        return isVisible;
    }

    protected void hideShowCustomCommandUI(boolean showUI) {
        openCustomCommandPopup.setVisible(showUI);
    }

    private void createLoadButton(String name, String text, int _x, int _y, int _w, int _h) {
        loadButton = createButton(hwsCp5, name, text, _x, _y, _w, _h);
        loadButton.setBorderColor(OBJECT_BORDER_GREY);
        loadButton.setDescription("Load hardware settings from file.");
        loadButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (currentBoard.isStreaming()) {
                    PopupMessage msg = new PopupMessage("Info", "Streaming needs to be stopped before loading hardware settings.");
                } else {
                    FileChooser chooser = new FileChooser(
                        FileChooserMode.LOAD,
                        "loadHardwareSettings",
                        new File(directoryManager.getGuiDataPath() + "Settings"),
                        "Select settings file to load");
                }
            }
        });
    }

    private void createSaveButton(String name, String text, int _x, int _y, int _w, int _h) {
        saveButton = createButton(hwsCp5, name, text, _x, _y, _w, _h);
        saveButton.setBorderColor(OBJECT_BORDER_GREY);
        saveButton.setDescription("Save hardware settings to file.");
        saveButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                FileChooser chooser = new FileChooser(
                    FileChooserMode.SAVE,
                    "storeHardwareSettings",
                    new File(directoryManager.getGuiDataPath() + "Settings"),
                    "Save settings to file");
            }
        });
    }

    private void createResetButton(String name, String text, int _x, int _y, int _w, int _h) {
        resetButton = createButton(hwsCp5, name, text, _x, _y, _w, _h);
        resetButton.setBorderColor(OBJECT_BORDER_GREY);
        resetButton.setDescription("Reset hardware settings to last saved values.");
        resetButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                for (int i = 0; i < channelCount; i++) {
                    boardSettings.revertAllChannelsToDefaultValues();
                    updateChanSettingsDropdowns(i, true);
                }
                output("Hardware Settings reset to last saved values.");
            }
        });
    }

    private void createSendButton(String name, String text, int _x, int _y, int _w, int _h) {
        sendButton = createButton(hwsCp5, name, text, _x, _y, _w, _h);
        sendButton.setBorderColor(OBJECT_BORDER_GREY);
        sendButton.setDescription("Send hardware settings to the board.");
        sendButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {

                boolean noErrors = true;
                boolean atLeastOneChannelHasChanged = false;

                for (int i = 0; i < channelCount; i++) {
                    if (channelHasUnappliedChanges[i]) {
                        boolean sendCommandSuccess = ((ADS1299SettingsBoard)currentBoard).getADS1299Settings().commit(i);
                        if (!sendCommandSuccess) {
                            noErrors = false;
                        } else {
                            setHasUnappliedSettings(i, false);
                            atLeastOneChannelHasChanged = true;
                            boardSettings.saveLastValues(i);
                        }
                    }
                }

                if (!atLeastOneChannelHasChanged) {
                    output("No new settings to send to board.");
                } else if (noErrors) {
                    outputSuccess("Hardware Settings sent to board!");
                } else {
                    PopupMessage msg = new PopupMessage("Error", "Failed to send one or more Hardware Settings to board. Check hardware and battery level. Cyton users, check that your dongle is connected with blue light shining.");
                }         
            }
        });
    }

    private ScrollableList createDropdown(String name, ADSSettingsEnum[] enumValues, ADSSettingsEnum e, color _backgroundColor) {
        int dropdownW = int((w - (spaceBetweenButtons*6)) / 5);
        int dropdownH = 18;
        ScrollableList list = hwsCp5.addScrollableList(name)
            .setOpen(false)
            .setColorBackground(_backgroundColor) // text field bg color
            .setColorValueLabel(OPENBCI_DARKBLUE)       // text color
            .setColorCaptionLabel(OPENBCI_DARKBLUE)
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(BUTTON_PRESSED)       // border color when selected
            .setOutlineColor(OBJECT_BORDER_GREY)
            .setSize(dropdownW, dropdownH)//temporary size
            .setBarHeight(dropdownH) //height of top/primary bar
            .setItemHeight(dropdownH) //height of all item/dropdown bars
            .setVisible(true)
            ;
        // for each entry in the enum, add it to the dropdown.
        for (ADSSettingsEnum value : enumValues) {
            // this will store the *actual* enum object inside the dropdown!
            list.addItem(value.getName(), value);
        }
        //Style the text in the ScrollableList
        list.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getName())
            .setFont(h5)
            .setSize(12)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        list.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getName())
            .setFont(p6)
            .setSize(10) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        return list;
    }

    private void createUIObjects() {
        //the size and space of these buttons are dependendant on the size of the screen and full ChannelController
        verbosePrint("ChannelController: createChannelSettingButtons: creating channel setting buttons...");

        channelSelectToggles = new Toggle[channelCount];
        gainLists = new ScrollableList[channelCount];
        inputTypeLists = new ScrollableList[channelCount];
        biasLists = new ScrollableList[channelCount];
        srb2Lists = new ScrollableList[channelCount];
        srb1Lists = new ScrollableList[channelCount];
        color _bgColor;

        //Init dropdowns in reverse so that chan 1 draws on top of chan 2, etc.
        for (int i = channelCount - 1; i >= 0; i--) {
            channelSelectToggles[i] = createChannelSelectToggle(i, "channelSelectToggle_" + i);

            _bgColor = #FFFFFF;
            gainLists[i] = createDropdown("gain_ch_" + i,  boardSettings.values.gain[i].values(), boardSettings.values.gain[i], _bgColor);
            gainLists[i].addCallback(new SLCallbackListener(i));

            _bgColor = #FFFFFF;
            inputTypeLists[i] = createDropdown("inputType_ch_" + i,  boardSettings.values.inputType[i].values(), boardSettings.values.inputType[i], _bgColor);
            inputTypeLists[i].addCallback(new SLCallbackListener(i));

            _bgColor = boardSettings.values.bias[i] == Bias.INCLUDE ? YES_ON_COLOR : NO_OFF_COLOR;
            biasLists[i] = createDropdown("bias_ch_" + i,  boardSettings.values.bias[i].values(), boardSettings.values.bias[i], _bgColor);
            biasLists[i].addCallback(new SLCallbackListener(i));

            _bgColor = boardSettings.values.srb2[i] == Srb2.CONNECT ? YES_ON_COLOR : NO_OFF_COLOR;            
            srb2Lists[i] = createDropdown("srb2_ch_" + i,  boardSettings.values.srb2[i].values(), boardSettings.values.srb2[i], _bgColor);
            srb2Lists[i].addCallback(new SLCallbackListener(i));

            _bgColor = boardSettings.values.srb1[i] == Srb1.CONNECT ? YES_ON_COLOR : NO_OFF_COLOR;           
            srb1Lists[i] = createDropdown("srb1_ch_" + i,  boardSettings.values.srb1[i].values(), boardSettings.values.srb1[i], _bgColor);
            srb1Lists[i].addCallback(new SLCallbackListener(i));
        }
        
        _bgColor = #FFFFFF;
        toggleAllChannels = createChannelSelectToggle(-1, "channelSelectToggle_all");
        gainListAll = createDropdown("gain_all",  boardSettings.values.gain[0].values(), boardSettings.values.gain[0], _bgColor);
        gainListAll.addCallback(new AllChannelSLCallbackListener());
        inputTypeListAll = createDropdown("inputType_all",  boardSettings.values.inputType[0].values(), boardSettings.values.inputType[0], _bgColor);
        inputTypeListAll.addCallback(new AllChannelSLCallbackListener());
        biasListAll = createDropdown("bias_all",  boardSettings.values.bias[0].values(), boardSettings.values.bias[0], _bgColor);
        biasListAll.addCallback(new AllChannelSLCallbackListener());
        srb2ListAll = createDropdown("srb2_all",  boardSettings.values.srb2[0].values(), boardSettings.values.srb2[0], _bgColor);
        srb2ListAll.addCallback(new AllChannelSLCallbackListener());
        srb1ListAll = createDropdown("srb1_all",  boardSettings.values.srb1[0].values(), boardSettings.values.srb1[0], _bgColor);
        srb1ListAll.addCallback(new AllChannelSLCallbackListener());

        resizeAndPositionUIObjects();
    }

    protected void createCustomCommandUI() {
        openCustomCommandPopup = createButton(hwsCp5, "openCustomCommandPopup", "Developer Commands", 0, 0, 10, 10);
        openCustomCommandPopup.setBorderColor(OBJECT_BORDER_GREY);
        openCustomCommandPopup.getCaptionLabel().getStyle().setMarginLeft(1);
        openCustomCommandPopup.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!developerCommandPopupIsOpen) {
                    developerCommandPopup = new DeveloperCommandPopup();
                } else {
                    developerCommandPopup.exitPopup();
                    developerCommandPopup = null;
                }
            }
        });
    }

    public void resizeCustomCommandUI() {
        customCommandUIX = x;
        customCommandUIWidth = w + 1;
        customCommandUIMiddle = customCommandUIX + Math.round(customCommandUIWidth / 2f);
        customCommandObjectW = Math.round(buttonWidth * 1.7);
        customCommandObjectY = y + h + COMMAND_BAR_HEIGHT + PADDING_3;
        customCommandObjectH = COMMAND_BAR_HEIGHT - (PADDING_3 * 2);
        openCustomCommandPopup.setPosition(customCommandUIMiddle - (customCommandObjectW / 2), customCommandObjectY);
        openCustomCommandPopup.setSize(customCommandObjectW, customCommandObjectH - 1);
    }

    private void updateHasUnappliedSettings(int _channel) {
        channelHasUnappliedChanges[_channel] = !boardSettings.equalsLastValues(_channel);
    }

    public void updateHasUnappliedSettings() {
        for (int i : activeChannels) {
            updateHasUnappliedSettings(i);
        }
    }

    public void setHasUnappliedSettings(int _channel, boolean b) {
        channelHasUnappliedChanges[_channel] = b;
    }

    public void updateChanSettingsDropdowns(int chan, boolean isActive) {
        color darkNotActive = color(57);
        color c = isActive ? color(255) : darkNotActive;
    
        gainLists[chan].setValue(boardSettings.values.gain[chan].ordinal());
        gainLists[chan].setColorBackground(c);
        gainLists[chan].setLock(!isActive);
    
        inputTypeLists[chan].setValue(boardSettings.values.inputType[chan].ordinal());
        inputTypeLists[chan].setColorBackground(c);
        inputTypeLists[chan].setLock(!isActive);
    
        c = isActive ? (boardSettings.values.bias[chan] == Bias.INCLUDE ? YES_ON_COLOR : NO_OFF_COLOR) : darkNotActive;
        biasLists[chan].setValue(boardSettings.values.bias[chan].ordinal());
        biasLists[chan].setColorBackground(c);
        biasLists[chan].setLock(!isActive);
    
        c = isActive ? (boardSettings.values.srb2[chan] == Srb2.CONNECT ? YES_ON_COLOR : NO_OFF_COLOR) : darkNotActive; 
        srb2Lists[chan].setValue(boardSettings.values.srb2[chan].ordinal());
        srb2Lists[chan].setColorBackground(c);
        srb2Lists[chan].setLock(!isActive);
    
        c = isActive ? (boardSettings.values.srb1[chan] == Srb1.CONNECT ? YES_ON_COLOR : NO_OFF_COLOR) : darkNotActive;   
        srb1Lists[chan].setValue(boardSettings.values.srb1[chan].ordinal());
        srb1Lists[chan].setColorBackground(c);
        srb1Lists[chan].setLock(!isActive);
    }

    public void updateAllChanSettingsDropdowns() {
        for (int i = 0; i < currentBoard.getNumEXGChannels(); i++) {
            updateChanSettingsDropdowns(i, currentBoard.isEXGChannelActive(i));
            setHasUnappliedSettings(i, false);
        }
    }

    private class SLCallbackListener implements CallbackListener {
        private int channel;
    
        SLCallbackListener(int _i)  {
            channel = _i;
        }
        public void controlEvent(CallbackEvent theEvent) {
            //Selecting an item from ScrollableList triggers Broadcast
            if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                int val = (int)(theEvent.getController()).getValue();
                Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
                ADSSettingsEnum myEnum = (ADSSettingsEnum)bob.get("value");
                verbosePrint("HardwareSettings: " + (theEvent.getController()).getName() + " == " + myEnum.getName());
                updateBoardSettingsValues(channel, myEnum, theEvent.getController());
            }
        }
    }

    private class AllChannelSLCallbackListener implements CallbackListener {
            
        AllChannelSLCallbackListener()  {
        }

        public void controlEvent(CallbackEvent theEvent) {
            //Selecting an item from ScrollableList triggers Broadcast
            if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
                int val = (int)(theEvent.getController()).getValue();
                Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
                ADSSettingsEnum myEnum = (ADSSettingsEnum)bob.get("value");

                for (int i = 0; i < channelIsSelected.length; i++) {
                    if (channelIsSelected[i]) {
                        updateBoardSettingsValues(i, myEnum, theEvent.getController());
                        updateChanSettingsDropdowns(i, true);
                    }
                }
            }
        }
    }

    private void updateBoardSettingsValues(int channel, ADSSettingsEnum myEnum, controlP5.Controller theController) {
        color _bgColor = #FFFFFF;
        if (myEnum instanceof Gain) {
            //verbosePrint("HardwareSettings: previousVal == " + boardSettings.previousValues.gain[channel]);
            boardSettings.values.gain[channel] = (Gain)myEnum;
        } else if (myEnum instanceof InputType) {
            boardSettings.values.inputType[channel] = (InputType)myEnum;
        } else if (myEnum instanceof Bias) {
            boardSettings.values.bias[channel] = (Bias)myEnum;
            _bgColor = (Bias)myEnum == Bias.INCLUDE ? YES_ON_COLOR : NO_OFF_COLOR;
            theController.setColorBackground(_bgColor);
        } else if (myEnum instanceof Srb2) {
            boardSettings.values.srb2[channel] = (Srb2)myEnum;
            _bgColor = (Srb2)myEnum == Srb2.CONNECT ? YES_ON_COLOR : NO_OFF_COLOR;
            theController.setColorBackground(_bgColor);
        } else if (myEnum instanceof Srb1) {
            boardSettings.values.srb1[channel] = (Srb1)myEnum;
            _bgColor = (Srb1)myEnum == Srb1.CONNECT ? YES_ON_COLOR : NO_OFF_COLOR;
            theController.setColorBackground(_bgColor);
            updateAllSrb1Channels((Srb1) myEnum);
        }

        updateHasUnappliedSettings(channel);
    }

    private void updateAllSrb1Channels(Srb1 srb1State) {
        boolean allOn = srb1State == Srb1.CONNECT;
        for (int i = 0; i < channelCount; i++) {
            if (boardSettings.values.srb1[i] != srb1State) {
                boardSettings.values.srb1[i] = allOn ? Srb1.CONNECT : Srb1.DISCONNECT;
                srb1Lists[i].setValue(allOn ? Srb1.CONNECT.ordinal() : Srb1.DISCONNECT.ordinal());
                srb1Lists[i].setColorBackground(allOn ? YES_ON_COLOR : NO_OFF_COLOR);
                srb1Lists[i].setLock(false);
            }
        }
    }

    protected void setUIObjectVisibility() {
        for (int i = 0; i < channelCount; i++) {
            boolean b = activeChannels.contains(i);
            channelSelectToggles[i].setVisible(b);
            gainLists[i].setVisible(b);
            inputTypeLists[i].setVisible(b);
            biasLists[i].setVisible(b);
            srb2Lists[i].setVisible(b);
            srb1Lists[i].setVisible(b);
        }
    }

    protected void drawChannelStatus() {
        for (int i = 0; i < channelCount; i++) {
            if (channelHasUnappliedChanges[i]) {
                pushStyle();
                fill(color(57, 128, 204, 190)); //light blue from TopNav
                //fill(color(245, 64, 64, 180)); //light red
                rect(x, y + channelBarHeight * i, w, channelBarHeight);
                popStyle();
            }
        }
    }

    protected void drawLabels() {
        channelSelectLabel.draw();
        gainLabel.draw();
        inputTypeLabel.draw();
        biasLabel.draw();
        srb2Label.draw();
        srb1Label.draw();
    }

    private Toggle createChannelSelectToggle(int _channel, String name) {
        int _w = DEFAULT_TOGGLE_WIDTH;
        int _h = DEFAULT_TOGGLE_WIDTH;
        int _x = 0;
        int _y = 0;
        boolean _value = false;
        final int channel = _channel;

        int _fontSize = 16;
        Toggle thisToggle = hwsCp5.addToggle(name)
            .setPosition(_x, _y) // temporary position
            .setSize(_w, _h)
            .setColorLabel(GREY_100)
            .setColorForeground(color(120))
            .setColorBackground(color(150))
            .setColorActive(color(57, 128, 204))
            .setVisible(true)
            .setValue(_value)
            ;
        thisToggle.getCaptionLabel()
            .setFont(p3)
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText("")
            .getStyle() //need to grab style before affecting margin and padding
            .setMargin(0, 0, 0, 0)
            .setPaddingLeft(0)
            ;
        thisToggle.onPress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                boolean b = ((Toggle)theEvent.getController()).getBooleanValue();
                if (channel == -1) {
                    for (int i = 0; i < channelCount; i++) {
                        channelSelectToggles[i].setValue(b);
                        channelIsSelected[i] = b;
                    }
                } else {
                    channelIsSelected[channel] = b;
                }
            }
        });

        if (checkMark_20x20 == null) {
            checkMark_20x20 = loadImage("Checkmark_20x20.png");
        }

        if (checkMark_20x20 == null) {
            println("Error: Could not load checkmark image");
        }

        return thisToggle;
    }

    private void drawCheckMark(Toggle _toggle) {
        float[] xy = _toggle.getPosition();
        if (_toggle.getBooleanValue()) {
            pushStyle();
            image(checkMark_20x20, xy[0], xy[1], toggleWidthAndHeight, toggleWidthAndHeight);
            popStyle();
        }
    }

    public int getCommandBarHeight() {
        return COMMAND_BAR_HEIGHT;
    }

    public int getHeaderHeight() {
        return CONTROLLER_HEADER_HEIGHT;
    }
};

void loadHardwareSettings(File selection) {
    if (selection == null) {
        output("Hardware Settings file not selected.");
    } else {
        if (currentBoard instanceof ADS1299SettingsBoard) {
            if (((ADS1299SettingsBoard)currentBoard).getADS1299Settings().loadSettingsValues(selection.getAbsolutePath())) {
                outputSuccess("Hardware Settings Loaded!");
                for (int i = 0; i < globalChannelCount; i++) {
                    W_TimeSeries timeSeriesWidget = widgetManager.getTimeSeriesWidget();
                    timeSeriesWidget.adsSettingsController.updateChanSettingsDropdowns(i, currentBoard.isEXGChannelActive(i));
                    timeSeriesWidget.adsSettingsController.updateHasUnappliedSettings(i);
                }
            } else {
                outputError("Failed to load Hardware Settings.");
            }
        }
    }
}

void storeHardwareSettings(File selection) {
    if (selection == null) {
        output("Hardware Settings file not selected.");
    } else {
        if (currentBoard instanceof ADS1299SettingsBoard) {
            if (((ADS1299SettingsBoard)currentBoard).getADS1299Settings().saveToFile(selection.getAbsolutePath())) {
                outputSuccess("Hardware Settings Saved!");
            } else {
                outputError("Failed to save Hardware Settings.");
            }
        }
    }
}