
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
    private final int columnLabelH = navH + (padding_3 * 2);

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

    private ADS1299Settings boardSettings;

    private int channelCount;
    private List<Integer> activeChannels;

    ADS1299SettingsController(PApplet _parent, List<Integer> _activeChannels, int _x, int _y, int _w, int _h, int _channelBarHeight){
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        
        _parentApplet = _parent;
        hwsCp5 = new ControlP5(_parentApplet);
        hwsCp5.setGraphics(_parentApplet, 0,0);
        hwsCp5.setAutoDraw(false);
        
        int colOffset = (w / numControlButtons) / 2;
        int button_y = y - button_h - padding_3;
        createHWSettingsLoadButton(loadButton, "HardwareSettingsLoad", "Load", x + colOffset - button_w/2, button_y, button_w, button_h);
        createHWSettingsSaveButton(saveButton, "HardwareSettingsSave", "Save", x + colOffset + (w/numControlButtons) - button_w/2, button_y, button_w, button_h);
        createHWSettingsSendButton(saveButton, "HardwareSettingsSend", "Send", x + colOffset + (w/numControlButtons)*2 - button_w/2, button_y, button_w, button_h);

        activeChannels = _activeChannels;
        ADS1299SettingsBoard settingsBoard = (ADS1299SettingsBoard)currentBoard;
        boardSettings = settingsBoard.getADS1299Settings();
        channelCount = currentBoard.getNumEXGChannels();

        color labelBG = color(220);
        color labelTxt = bgColor;
        colOffset = (w / 5) / 2;
        int label_y = y + h - navH + padding_3;
        gainLabel = new TextBox("PGA Gain", x + colOffset, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        inputTypeLabel = new TextBox("Input Type", x + colOffset + (w/5), label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        biasLabel = new TextBox("Bias Include", x + colOffset + (w/5)*2, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        srb2Label = new TextBox("SRB2", x + colOffset + (w/5)*3, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        srb1Label = new TextBox("SRB1", x + colOffset + (w/5)*4, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);

        createAllDropdowns(_channelBarHeight);
    }

    public void update(){
        for (int i=0; i<currentBoard.getNumEXGChannels(); i++) {
            
            /*
            // grab the name out of the enum directly.
            gainButtons[i].setString(boardSettings.values.gain[i].getName());
            inputTypeButtons[i].setString(boardSettings.values.inputType[i].getName());
            biasButtons[i].setString(boardSettings.values.bias[i].getName());
            srb2Buttons[i].setString(boardSettings.values.srb2[i].getName());
            srb1Buttons[i].setString(boardSettings.values.srb1[i].getName());
            */

            /*
            // grey out buttons when the channel is not active
            if (boardSettings.isChannelActive(i)) {
                gainButtons[i].setColorNotPressed(colorNotPressed);
                inputTypeButtons[i].setColorNotPressed(colorNotPressed);
                biasButtons[i].setColorNotPressed(colorNotPressed);
                srb2Buttons[i].setColorNotPressed(colorNotPressed);
                srb1Buttons[i].setColorNotPressed(colorNotPressed);

                gainButtons[i].setIgnoreHover(false);
                inputTypeButtons[i].setIgnoreHover(false);
                biasButtons[i].setIgnoreHover(false);
                srb2Buttons[i].setIgnoreHover(false);
                srb1Buttons[i].setIgnoreHover(false);
            } else {
                gainButtons[i].setColorNotPressed(color(128));
                inputTypeButtons[i].setColorNotPressed(color(128));
                biasButtons[i].setColorNotPressed(color(128));
                srb2Buttons[i].setColorNotPressed(color(128));
                srb1Buttons[i].setColorNotPressed(color(128));

                gainButtons[i].setIgnoreHover(true);
                inputTypeButtons[i].setIgnoreHover(true);
                biasButtons[i].setIgnoreHover(true);
                srb2Buttons[i].setIgnoreHover(true);
                srb1Buttons[i].setIgnoreHover(true);
            }
            */
        }
    }

    public void draw(){

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
            rect(x, y, w, h);

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


    public void mousePressed(){
        if (isVisible) {
            for (int i : activeChannels) {

                // buttons only work if the channel is active
                if (boardSettings.isChannelActive(i)) {

                    /*
                    if(gainButtons[i].isMouseHere()) {
                        gainButtons[i].wasPressed = true;
                        gainButtons[i].isActive = true;                    
                    }
                    if(inputTypeButtons[i].isMouseHere()) {
                        inputTypeButtons[i].wasPressed = true;
                        inputTypeButtons[i].isActive = true;                    
                    }
                    if(biasButtons[i].isMouseHere()) {
                        biasButtons[i].wasPressed = true;
                        biasButtons[i].isActive = true;                    
                    }
                    if(srb2Buttons[i].isMouseHere()) {
                        srb2Buttons[i].wasPressed = true;
                        srb2Buttons[i].isActive = true;                    
                    }
                    if(srb1Buttons[i].isMouseHere()) {
                        srb1Buttons[i].wasPressed = true;
                        srb1Buttons[i].isActive = true;                    
                    }
                    */
                }
            }
        }
    }

    public void mouseReleased(){
        if (isVisible) {
            for (int i : activeChannels) {
                /*
                if(gainButtons[i].isMouseHere() && gainButtons[i].wasPressed) {
                    // loops over the enum
                    boardSettings.values.gain[i] = boardSettings.values.gain[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.gain[i] = boardSettings.values.gain[i].getPrev();
                    }
                    gainButtons[i].wasPressed = false;
                    gainButtons[i].isActive = false; 
                }
                if(inputTypeButtons[i].isMouseHere() && inputTypeButtons[i].wasPressed) {
                    boardSettings.values.inputType[i] = boardSettings.values.inputType[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.inputType[i] = boardSettings.values.inputType[i].getPrev();
                    }
                    inputTypeButtons[i].wasPressed = false;
                    inputTypeButtons[i].isActive = false;  
                }
                if(biasButtons[i].isMouseHere() && biasButtons[i].wasPressed) {
                    boardSettings.values.bias[i] = boardSettings.values.bias[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.bias[i] = boardSettings.values.bias[i].getPrev();
                    }
                    biasButtons[i].wasPressed = false;
                    biasButtons[i].isActive = false;   
                }
                if(srb2Buttons[i].isMouseHere() && srb2Buttons[i].wasPressed) {
                    boardSettings.values.srb2[i] = boardSettings.values.srb2[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.srb2[i] = boardSettings.values.srb2[i].getPrev();
                    }
                    srb2Buttons[i].wasPressed = false;
                    srb2Buttons[i].isActive = false;    
                }
                if(srb1Buttons[i].isMouseHere() && srb1Buttons[i].wasPressed) {
                    boardSettings.values.srb1[i] = boardSettings.values.srb1[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.srb1[i] = boardSettings.values.srb1[i].getPrev();
                    }
                    srb1Buttons[i].wasPressed = false;
                    srb1Buttons[i].isActive = false;  
                }
                */
            }
        }
    }

    public void resize(int _x, int _y, int _w, int _h, int _channelBarHeight){
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        hwsCp5.setGraphics(_parentApplet, 0, 0);

        int colOffset = (w / numControlButtons) / 2;
        int button_y = y - button_h - padding_3;
        loadButton.setPosition(x + colOffset - button_w/2, button_y);
        saveButton.setPosition(x + colOffset + (w/numControlButtons) - button_w/2, button_y);
        sendButton.setPosition(x + colOffset + (w/numControlButtons)*2 - button_w/2, button_y);

        colOffset = (w / 5) / 2;
        int label_y = y + h - navH + padding_3;
        gainLabel.setPosition(x + colOffset, label_y);
        inputTypeLabel.setPosition(x + colOffset + (w/5), label_y);
        biasLabel.setPosition(x + colOffset + (w/5)*2, label_y);
        srb2Label.setPosition(x + colOffset + (w/5)*3, label_y);
        srb1Label.setPosition(x + colOffset + (w/5)*4, label_y);

        resizeDropdowns(_channelBarHeight);
    }

    public void setIsVisible (boolean v) {
        isVisible = v;
    }

    public boolean getIsVisible() {
        return isVisible;
    }

    private Button createButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h) {
        myButton = hwsCp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(color(177, 184, 193))
            .setColorBackground(colorNotPressed)
            .setColorActive(color(150,170,200))
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial",12,true))
            .toUpperCase(false)
            .setSize(12)
            .setText(text)
            ;
        return myButton;
    }

    private void createHWSettingsLoadButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h) {
        loadButton = createButton(myButton, name, text, _x, _y, _w, _h);
        loadButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (isRunning) {
                    PopupMessage msg = new PopupMessage("Info", "Streaming needs to be stopped before loading hardware settings.");
                } else {
                    selectInput("Select settings file to load", "loadHardwareSettings");
                }
            }
        });
    }

    private void createHWSettingsSaveButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h) {
        saveButton = createButton(myButton, name, text, _x, _y, _w, _h);
        saveButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                selectOutput("Save settings to file", "storeHardwareSettings");
            }
        });
    }

    private void createHWSettingsSendButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h) {
        sendButton = createButton(myButton, name, text, _x, _y, _w, _h);
        sendButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                ((ADS1299SettingsBoard)currentBoard).getADS1299Settings().commitAll();
                output("Hardware Settings sent to board!");
            }
        });
    }

    private ScrollableList createDropdown(int chanNum, String name, ADSSettingsEnum[] enumValues){
        int dropdownW = int((w - (spaceBetweenButtons*6)) / 5);
        int dropdownH = 18;
        ScrollableList list = new CustomScrollableList(hwsCp5, name)
            .setOpen(false)
            .setColorBackground((int)channelColors[chanNum%8]) // text field bg color
            .setColorValueLabel(color(255))       // text color
            .setColorCaptionLabel(color(255))
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
            .setText(enumValues[0].getName())
            .setFont(h5)
            .setSize(12)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        list.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(enumValues[0].getName())
            .setFont(p6)
            .setSize(10) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
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

        for (int i = channelCount - 1; i >= 0; i--) {

            gainLists[i] = createDropdown(i, "gain_ch_"+i, boardSettings.values.gain[i].values());
            gainLists[i].onClick(new CallbackListener() {
                public void controlEvent(CallbackEvent theEvent) {
                    /*
                    // loops over the enum
                    boardSettings.values.gain[i] = boardSettings.values.gain[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.gain[i] = boardSettings.values.gain[i].getPrev();
                    }
                    */
                }
            });
            
            inputTypeLists[i] = createDropdown(i, "inputType_ch_"+i, boardSettings.values.inputType[i].values());
            inputTypeLists[i].onClick(new CallbackListener() {
                public void controlEvent(CallbackEvent theEvent) {
                    /*
                    // loops over the enum
                    boardSettings.values.gain[i] = boardSettings.values.gain[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.gain[i] = boardSettings.values.gain[i].getPrev();
                    }
                    */
                }
            });

            biasLists[i] = createDropdown(i, "bias_ch_"+i, boardSettings.values.bias[i].values());
            biasLists[i].onClick(new CallbackListener() {
                public void controlEvent(CallbackEvent theEvent) {
                    /*
                    // loops over the enum
                    boardSettings.values.gain[i] = boardSettings.values.gain[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.gain[i] = boardSettings.values.gain[i].getPrev();
                    }
                    */
                }
            });

            srb2Lists[i] = createDropdown(i, "srb2_ch_"+i, boardSettings.values.srb2[i].values());
            srb2Lists[i].onClick(new CallbackListener() {
                public void controlEvent(CallbackEvent theEvent) {
                    /*
                    // loops over the enum
                    boardSettings.values.gain[i] = boardSettings.values.gain[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.gain[i] = boardSettings.values.gain[i].getPrev();
                    }
                    */
                }
            });

            srb1Lists[i] = createDropdown(i, "srb1_ch_"+i, boardSettings.values.srb1[i].values());
            srb1Lists[i].onClick(new CallbackListener() {
                public void controlEvent(CallbackEvent theEvent) {
                    /*
                    // loops over the enum
                    boardSettings.values.gain[i] = boardSettings.values.gain[i].getNext();
                    if(!boardSettings.commit(i)) {
                        boardSettings.values.gain[i] = boardSettings.values.gain[i].getPrev();
                    }
                    */
                }
            });
            /*
            inputTypeLists[i] = new ScrollableList(0, 0, 0, 0, "Unlabeled");
            biasLists[i] = new ScrollableList(0, 0, 0, 0, "Unlabeled");
            srb2Lists[i] = new ScrollableList(0, 0, 0, 0, "Unlabeled");
            srb1Lists[i] = new ScrollableList(0, 0, 0, 0, "Unlabeled");
            */
        }

        resizeDropdowns(_channelBarHeight);
    }
};

void loadHardwareSettings(File selection) {
    if (selection == null) {
        output("Hardware Settings file not selected.");
    } else {
        if (currentBoard instanceof ADS1299SettingsBoard) {
            if (((ADS1299SettingsBoard)currentBoard).getADS1299Settings().loadSettingsValues(selection.getAbsolutePath())) {
                outputSuccess("Hardware Settings Loaded!");
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