import org.apache.commons.lang3.tuple.Pair;


class ADS1299SettingsController {
    private PApplet _parentApplet;
    private boolean isVisible = false;
    private int x, y, w, h;
    private final int padding_3 = 3;
    private final int navH = 22;

    private ControlP5 hwsCp5;
    private final int numControlButtons = 3;
    private Button loadButton;
    private Button saveButton;
    private Button sendButton;
    private int button_w = 80;
    private int button_h = navH;
    private final int columnLabelH = navH;
    private final int commandBarH = navH + padding_3 * 2;
    private int chanBar_h;

    private int spaceBetweenButtons = 5; //space between buttons

    private TextBox gainLabel;
    private TextBox inputTypeLabel;
    private TextBox biasLabel;
    private TextBox srb2Label;
    private TextBox srb1Label;

    private ScrollableList[] gainLists;
    private ScrollableList[] inputTypeLists;
    private ScrollableList[] biasLists;
    private ScrollableList[] srb2Lists;
    private ScrollableList[] srb1Lists;
    private boolean[] hasUnappliedChanges;
    private final color yesOnColor = #DFF2BF;
    private final color noOffColor = #FFD2D2;

    private Textfield customCommandTF;
    private Button sendCustomCmdButton;
    private int customCmdUI_x;
    private int customCmdUI_w;

    private ADS1299Settings boardSettings;

    private int channelCount;
    private List<Integer> activeChannels;

    ADS1299SettingsController(PApplet _parent, List<Integer> _activeChannels, int _x, int _y, int _w, int _h, int _channelBarHeight) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        chanBar_h = _channelBarHeight;
        
        _parentApplet = _parent;
        hwsCp5 = new ControlP5(_parentApplet);
        hwsCp5.setGraphics(_parentApplet, 0,0);
        hwsCp5.setAutoDraw(false);
        
        int colOffset = (w / numControlButtons) / 2;
        int button_y = y + h + padding_3;
        createHWSettingsLoadButton("HardwareSettingsLoad", "Load", x + colOffset - button_w/2, button_y, button_w, button_h);
        createHWSettingsSaveButton("HardwareSettingsSave", "Save", x + colOffset + (w/numControlButtons) - button_w/2, button_y, button_w, button_h);
        createHWSettingsSendButton("HardwareSettingsSend", "Send", x + colOffset + (w/numControlButtons)*2 - button_w/2, button_y, button_w, button_h);

        activeChannels = _activeChannels;
        ADS1299SettingsBoard settingsBoard = (ADS1299SettingsBoard)currentBoard;
        boardSettings = settingsBoard.getADS1299Settings();
        boardSettings.saveAllLastValues();
        channelCount = currentBoard.getNumEXGChannels();
        hasUnappliedChanges = new boolean[channelCount];
        Arrays.fill(hasUnappliedChanges, Boolean.FALSE);

        //color labelBG = color(220);
        color labelBG = color(255,255,255,0);
        color labelTxt = OPENBCI_DARKBLUE;
        colOffset = (w / 5) / 2;
        int label_y = y - 14 - padding_3;
        gainLabel = new TextBox("PGA Gain", x + colOffset, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        inputTypeLabel = new TextBox("Input Type", x + colOffset + (w/5), label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        biasLabel = new TextBox("Bias Include", x + colOffset + (w/5)*2, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        srb2Label = new TextBox("SRB2", x + colOffset + (w/5)*3, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        srb1Label = new TextBox("SRB1", x + colOffset + (w/5)*4, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);

        createCustomCommandUI();

        createAllDropdowns(chanBar_h);
    }

    public void update() {
        boolean tfactive = customCommandTF.isFocus();
        if (tfactive) {
            textFieldIsActive = true;
        }
    }

    public void draw() {

        if (isVisible) {
            //Control button space above channels
            pushStyle();
            stroke(31,69,110, 50);
            fill(0, 0, 0, 100);
            rect(x, y - columnLabelH, w, columnLabelH);

            //background
            pushStyle();
            noStroke();
            fill(0, 0, 0, 100);
            rect(x, y, w + 1, h);

            gainLabel.draw();
            inputTypeLabel.draw();
            biasLabel.draw();
            srb2Label.draw();
            srb1Label.draw();

            for (int i = 0; i < channelCount; i++) {
                boolean b = activeChannels.contains(i);
                gainLists[i].setVisible(b);
                inputTypeLists[i].setVisible(b);
                biasLists[i].setVisible(b);
                srb2Lists[i].setVisible(b);
                srb1Lists[i].setVisible(b);

                if (hasUnappliedChanges[i]) {
                    pushStyle();
                    fill(color(57, 128, 204, 190)); //light blue from TopNav
                    //fill(color(245, 64, 64, 180)); //light red
                    rect(x, y + chanBar_h * i, w, chanBar_h);
                }
            }

            //Draw background behind command buttons
            pushStyle();
            fill(0, 0, 0, 100);
            rect(x, y + h, w + 1, commandBarH);

            customCommandTF.setVisible(settings.expertModeToggle);
            sendCustomCmdButton.setVisible(settings.expertModeToggle);
            if (settings.expertModeToggle) {
                rect(customCmdUI_x, y + h + commandBarH, customCmdUI_w, commandBarH); //keep above style for other command buttons
            }

            //Draw cp5 objects on top of everything
            hwsCp5.draw();
        }

        popStyle();
    }

    private void resizeDropdowns(int _channelBarHeight) {
        int dropdownX = 0;
        int dropdownY = 0;
        int dropdownW = int((w - (spaceBetweenButtons*6)) / 5);
        int dropdownH = 18;

        int rowCount = 0;
        for (int i : activeChannels) {
            dropdownX = x + spaceBetweenButtons;
            dropdownY = int(y + ((_channelBarHeight)*rowCount) + (((_channelBarHeight)-dropdownH)/2));
            final int buttonXIncrement = spaceBetweenButtons + dropdownW;

            gainLists[i].setPosition(dropdownX, dropdownY);
            gainLists[i].setSize(dropdownW,5*dropdownH); //Only enough space for SelectedItem + 4 options in the latter channels
            
            dropdownX += buttonXIncrement;
            inputTypeLists[i].setPosition(dropdownX, dropdownY);
            inputTypeLists[i].setSize(dropdownW,5*dropdownH); //Only enough space for SelectedItem + 4 options in the latter channels

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

    public void resize(int _x, int _y, int _w, int _h, int _channelBarHeight) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        chanBar_h = _channelBarHeight;

        hwsCp5.setGraphics(_parentApplet, 0, 0);

        int colOffset = (w / numControlButtons) / 2;
        int button_y = y + h + padding_3;
        loadButton.setPosition(x + colOffset - button_w/2, button_y);
        saveButton.setPosition(x + colOffset + (w/numControlButtons) - button_w/2, button_y);
        sendButton.setPosition(x + colOffset + (w/numControlButtons)*2 - button_w/2, button_y);

        colOffset = (w / 5) / 2;
        int label_y = y - 14 - padding_3;
        gainLabel.setPosition(x + colOffset, label_y);
        inputTypeLabel.setPosition(x + colOffset + (w/5), label_y);
        biasLabel.setPosition(x + colOffset + (w/5)*2, label_y);
        srb2Label.setPosition(x + colOffset + (w/5)*3, label_y);
        srb1Label.setPosition(x + colOffset + (w/5)*4, label_y);

        resizeDropdowns(chanBar_h);

        resizeCustomCommandUI();
    }

    //Returns true if board and UI are in sync
    public boolean setIsVisible (boolean v) {
        
        //Check if there are unapplied settings when trying to close Hardware Settings Controller
        if (!v) {
            boolean allChannelsInSync = true;

            for (int i = 0; i < hasUnappliedChanges.length; i++) {
                if (hasUnappliedChanges[i]) {
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

    private void createHWSettingsLoadButton(String name, String text, int _x, int _y, int _w, int _h) {
        loadButton = createButton(hwsCp5, name, text, _x, _y, _w, _h);
        loadButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (currentBoard.isStreaming()) {
                    PopupMessage msg = new PopupMessage("Info", "Streaming needs to be stopped before loading hardware settings.");
                } else {
                    selectInput("Select settings file to load", "loadHardwareSettings");
                }
            }
        });
    }

    private void createHWSettingsSaveButton(String name, String text, int _x, int _y, int _w, int _h) {
        saveButton = createButton(hwsCp5, name, text, _x, _y, _w, _h);
        saveButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                selectOutput("Save settings to file", "storeHardwareSettings");
            }
        });
    }

    private void createHWSettingsSendButton(String name, String text, int _x, int _y, int _w, int _h) {
        sendButton = createButton(hwsCp5, name, text, _x, _y, _w, _h);
        sendButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                
                boolean[] sendCommandSuccess = ((ADS1299SettingsBoard)currentBoard).getADS1299Settings().commitAll();
                boolean noErrors = true;

                for (int i = 0; i < sendCommandSuccess.length; i++) {
                    if (!sendCommandSuccess[i]) {
                        noErrors = false;
                    } else {
                        hasUnappliedChanges[i] = false;
                        boardSettings.saveLastValues(i);
                    }
                }

                if (noErrors) {
                    output("Hardware Settings sent to board!");
                } else {
                    PopupMessage msg = new PopupMessage("Error", "Failed to send one or more Hardware Settings to board. Check hardware and battery level. Cyton users, check that your dongle is connected with blue light shining.");
                }         
            }
        });
    }

    private ScrollableList createDropdown(int chanNum, String name, ADSSettingsEnum[] enumValues, ADSSettingsEnum e, color _backgroundColor) {
        int dropdownW = int((w - (spaceBetweenButtons*6)) / 5);
        int dropdownH = 18;
        ScrollableList list = new CustomScrollableList(hwsCp5, name)
            .setOpen(false)
            .setColorBackground(_backgroundColor) // text field bg color
            .setColorValueLabel(color(0))       // text color
            .setColorCaptionLabel(color(0))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
            .setBackgroundColor(150)
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
        list.addCallback(new SLCallbackListener(chanNum));
        return list;
    }

    private void createAllDropdowns(int _channelBarHeight) {
        //the size and space of these buttons are dependendant on the size of the screen and full ChannelController
        verbosePrint("ChannelController: createChannelSettingButtons: creating channel setting buttons...");

        gainLists = new ScrollableList[channelCount];
        inputTypeLists = new ScrollableList[channelCount];
        biasLists = new ScrollableList[channelCount];
        srb2Lists = new ScrollableList[channelCount];
        srb1Lists = new ScrollableList[channelCount];
        color _bgColor;

        //Init dropdowns in reverse so that chan 1 draws on top of chan 2, etc.
        for (int i = channelCount - 1; i >= 0; i--) {
            _bgColor = #FFFFFF;
            gainLists[i] = createDropdown(i, "gain_ch_"+(i+1), boardSettings.values.gain[i].values(), boardSettings.values.gain[i], _bgColor);
            
            _bgColor = #FFFFFF;
            inputTypeLists[i] = createDropdown(i, "inputType_ch_"+(i+1), boardSettings.values.inputType[i].values(), boardSettings.values.inputType[i], _bgColor);
            
            _bgColor = boardSettings.values.bias[i] == Bias.INCLUDE ? yesOnColor : noOffColor;
            biasLists[i] = createDropdown(i, "bias_ch_"+(i+1), boardSettings.values.bias[i].values(), boardSettings.values.bias[i], _bgColor);

            _bgColor = boardSettings.values.srb2[i] == Srb2.CONNECT ? yesOnColor : noOffColor;            
            srb2Lists[i] = createDropdown(i, "srb2_ch_"+(i+1), boardSettings.values.srb2[i].values(), boardSettings.values.srb2[i], _bgColor);

            _bgColor = boardSettings.values.srb1[i] == Srb1.CONNECT ? yesOnColor : noOffColor;           
            srb1Lists[i] = createDropdown(i, "srb1_ch_"+(i+1), boardSettings.values.srb1[i].values(), boardSettings.values.srb1[i], _bgColor);
        }

        resizeDropdowns(_channelBarHeight);
    }

    private void createCustomCommandUI() {
        final Textfield _tf = hwsCp5.addTextfield("customCommand")
            .setPosition(0, 0)
            .setCaptionLabel("")
            .setSize(10, 10)
            .setFont(f2)
            .setFocus(false)
            .setColor(color(26, 26, 26))
            .setColorBackground(color(255, 255, 255)) // text field bg color
            .setColorValueLabel(color(0, 0, 0))  // text color
            .setColorForeground(color(26))  // border color when not selected
            .setColorActive(isSelected_color)  // border color when selected
            .setColorCursor(color(26, 26, 26))
            .setText("")
            .align(5, 10, 20, 40)
            .setAutoClear(false) //Don't clear textfield when pressing Enter key
            ;
        _tf.setDescription("Type a custom command and Send to board.");
        //Clear textfield on double click
        _tf.onDoublePress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("[ExpertMode] Enter the custom command you would like to send to the board.");
                _tf.clear();
            }
        });
        _tf.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if ((theEvent.getAction() == ControlP5.ACTION_BROADCAST) || (theEvent.getAction() == ControlP5.ACTION_LEAVE)) {
                    _tf.setFocus(false);
                }
            }
        });
        customCommandTF = _tf;

        sendCustomCmdButton = createButton(hwsCp5, "sendCustomCommand", "Send", 0, 0, 10, 10);
        sendCustomCmdButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                String text = dropNonPrintableChars(customCommandTF.getText());
                Pair<Boolean, String> res = ((BoardBrainFlow)currentBoard).sendCommand(text);
                if (res.getKey().booleanValue()) {
                    outputSuccess("[ExpertMode] Success sending command to board: " + text);
                } else {
                    outputError("[ExpertMode] Failure sending command to board: " + text);
                }
                //println("ADSSettingsController: Response == " + res.getValue());
            }
        });

        resizeCustomCommandUI();
    }

    private void resizeCustomCommandUI() {
        customCmdUI_x = x + Math.round(w / 6f) - 24;
        customCmdUI_w = (int)Math.ceil(w * (2f/3f)) + 24;
        int tf_x = customCmdUI_x + padding_3;
        int tf_y = y + h + commandBarH + padding_3;
        int tf_w = Math.round((customCmdUI_w - padding_3*2) * .75);
        int tf_h = commandBarH - padding_3*2;
        customCommandTF.setPosition(tf_x, tf_y);
        customCommandTF.setSize(tf_w, tf_h);
        int but_x = tf_x + customCommandTF.getWidth() + padding_3;
        int but_w = customCmdUI_w - customCommandTF.getWidth() - padding_3*3;
        sendCustomCmdButton.setPosition(but_x, tf_y);
        sendCustomCmdButton.setSize(but_w, tf_h);
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

        c = isActive ? (boardSettings.values.bias[chan] == Bias.INCLUDE ? yesOnColor : noOffColor) : darkNotActive;
        biasLists[chan].setValue(boardSettings.values.bias[chan].ordinal());
        biasLists[chan].setColorBackground(c);
        biasLists[chan].setLock(!isActive);

        c = isActive ? (boardSettings.values.srb2[chan] == Srb2.CONNECT ? yesOnColor : noOffColor) : darkNotActive; 
        srb2Lists[chan].setValue(boardSettings.values.srb2[chan].ordinal());
        srb2Lists[chan].setColorBackground(c);
        srb2Lists[chan].setLock(!isActive);

        c = isActive ? (boardSettings.values.srb1[chan] == Srb1.CONNECT ? yesOnColor : noOffColor) : darkNotActive;   
        srb1Lists[chan].setValue(boardSettings.values.srb1[chan].ordinal());
        srb1Lists[chan].setColorBackground(c);
        srb1Lists[chan].setLock(!isActive);

        hasUnappliedChanges[chan] = false;
    }

    private class SLCallbackListener implements CallbackListener {
        private int channel;
    
        SLCallbackListener(int _i)  {
            channel = _i;
        }
        public void controlEvent(CallbackEvent theEvent) {
            color _bgColor = #FFFFFF;
            //Selecting an item from ScrollableList triggers Broadcast
            if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) { 
                int val = (int)(theEvent.getController()).getValue();
                Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
                ADSSettingsEnum myEnum = (ADSSettingsEnum)bob.get("value");
                verbosePrint("HardwareSettings: " + (theEvent.getController()).getName() + " == " + myEnum.getName());

                if (myEnum instanceof Gain) {
                    //verbosePrint("HardwareSettings: previousVal == " + boardSettings.previousValues.gain[channel]);
                    hasUnappliedChanges[channel] = (Gain)myEnum != boardSettings.values.gain[channel];
                    boardSettings.values.gain[channel] = (Gain)myEnum;
                } else if (myEnum instanceof InputType) {
                    hasUnappliedChanges[channel] = (InputType)myEnum != boardSettings.values.inputType[channel];
                    boardSettings.values.inputType[channel] = (InputType)myEnum;
                } else if (myEnum instanceof Bias) {
                    hasUnappliedChanges[channel] = (Bias)myEnum != boardSettings.values.bias[channel];
                    boardSettings.values.bias[channel] = (Bias)myEnum;
                    _bgColor = (Bias)myEnum == Bias.INCLUDE ? yesOnColor : noOffColor;
                    (theEvent.getController()).setColorBackground(_bgColor);
                } else if (myEnum instanceof Srb2) {
                    hasUnappliedChanges[channel] = (Srb2)myEnum != boardSettings.values.srb2[channel];
                    boardSettings.values.srb2[channel] = (Srb2)myEnum;
                    _bgColor = (Srb2)myEnum == Srb2.CONNECT ? yesOnColor : noOffColor;
                    (theEvent.getController()).setColorBackground(_bgColor);
                } else if (myEnum instanceof Srb1) {
                    hasUnappliedChanges[channel] = (Srb1)myEnum != boardSettings.values.srb1[channel];
                    boardSettings.values.srb1[channel] = (Srb1)myEnum;
                    _bgColor = (Srb1)myEnum == Srb1.CONNECT ? yesOnColor : noOffColor;
                    (theEvent.getController()).setColorBackground(_bgColor);
                }

                hasUnappliedChanges[channel] = !boardSettings.equalsLastValues(channel);
            }
        }
    }
};

void loadHardwareSettings(File selection) {
    if (selection == null) {
        output("Hardware Settings file not selected.");
    } else {
        if (currentBoard instanceof ADS1299SettingsBoard) {
            if (((ADS1299SettingsBoard)currentBoard).getADS1299Settings().loadSettingsValues(selection.getAbsolutePath())) {
                outputSuccess("Hardware Settings Loaded!");
                for (int i = 0; i < nchan; i++) {
                    w_timeSeries.adsSettingsController.updateChanSettingsDropdowns(i, currentBoard.isEXGChannelActive(i));
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