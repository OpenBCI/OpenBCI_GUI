
class ADS1299SettingsController {

    private boolean isVisible = false;
    private int x, y, w, h;

    private ControlP5 hwsCp5;
    private Button hardwareSettingsLoad;
    private Button hardwareSettingsSave;
    private int button_w = 80;
    private int button_h = navHeight - 6;

    private int spaceBetweenButtons = 5; //space between buttons

    private Button_obci[] gainButtons;
    private Button_obci[] inputTypeButtons;
    private Button_obci[] biasButtons;
    private Button_obci[] srb2Buttons;
    private Button_obci[] srb1Buttons;

    private ADS1299Settings boardSettings;

    private List<Integer> activeChannels;

    ADS1299SettingsController(PApplet _parent, List<Integer> _activeChannels, int _x, int _y, int _w, int _h, int _channelBarHeight){
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        hwsCp5 = new ControlP5(_parent);
        hwsCp5.setGraphics(_parent, 0,0);
        hwsCp5.setAutoDraw(false);

        hardwareSettingsLoad = createButton(hardwareSettingsLoad, "HardwareSettingsLoad", "Load Settings", x + (w/4) - button_w/2, y - button_h - 3, button_w, button_h);
        hardwareSettingsSave = createButton(hardwareSettingsSave, "HardwareSettingsSave", "Save Settings", x + (w/2) + (w/4) - button_w/2, y - button_h - 3, button_w, button_h);

        activeChannels = _activeChannels;
        ADS1299SettingsBoard settingsBoard = (ADS1299SettingsBoard)currentBoard;
        boardSettings = settingsBoard.getADS1299Settings();
        createAllButtons(_channelBarHeight);
    }

    public void update(){
        for (int i=0; i<currentBoard.getNumEXGChannels(); i++) {
            // grab the name out of the enum directly.
            gainButtons[i].setString(boardSettings.values.gain[i].getName());
            inputTypeButtons[i].setString(boardSettings.values.inputType[i].getName());
            biasButtons[i].setString(boardSettings.values.bias[i].getName());
            srb2Buttons[i].setString(boardSettings.values.srb2[i].getName());
            srb1Buttons[i].setString(boardSettings.values.srb1[i].getName());

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
        }
    }

    public void draw(){

        if (isVisible) {
            //Load and Save buttons
            pushStyle();
            stroke(31,69,110, 50);
            fill(0, 0, 0, 100);
            rect(x, y - navHeight, w, navHeight);
            hwsCp5.draw();

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

            boolean showCustomCommandUI = settings.expertModeToggle && !(currentBoard instanceof BoardCyton);
            customCommandTF.setVisible(showCustomCommandUI);
            sendCustomCmdButton.setVisible(showCustomCommandUI);
            if (showCustomCommandUI) {
                rect(customCmdUI_x, y + h + commandBarH, customCmdUI_w, commandBarH); //keep above style for other command buttons
            }

            //draw column headers for channel settings behind EEG graph
            fill(bgColor);
            textFont(p6, 10);
            textAlign(CENTER, TOP);
            text("PGA Gain", x + (w/10)*1, y-1);
            text("Input Type", x + (w/10)*3, y-1);
            text("  Bias ", x + (w/10)*5, y-1);
            text("SRB2", x + (w/10)*7, y-1);
            text("SRB1", x + (w/10)*9, y-1);
        }

        popStyle();
    }

    private void createAllButtons(int _channelBarHeight) {
        //the size and space of these buttons are dependendant on the size of the screen and full ChannelController
        verbosePrint("ChannelController: createChannelSettingButtons: creating channel setting buttons...");

        int channelCount = currentBoard.getNumEXGChannels();

        gainButtons = new Button_obci[channelCount];
        inputTypeButtons = new Button_obci[channelCount];
        biasButtons = new Button_obci[channelCount];
        srb2Buttons = new Button_obci[channelCount];
        srb1Buttons = new Button_obci[channelCount];

        for (int i=0; i<channelCount; i++) {
            gainButtons[i] = new Button_obci(0, 0, 0, 0, "Unlabeled");
            inputTypeButtons[i] = new Button_obci(0, 0, 0, 0, "Unlabeled");
            biasButtons[i] = new Button_obci(0, 0, 0, 0, "Unlabeled");
            srb2Buttons[i] = new Button_obci(0, 0, 0, 0, "Unlabeled");
            srb1Buttons[i] = new Button_obci(0, 0, 0, 0, "Unlabeled");
        }

        resizeButtons(_channelBarHeight);
    }

    private void resizeButtons(int _channelBarHeight) {
        int buttonW = int((w - (spaceBetweenButtons*6)) / 5);
        int buttonX = 0;
        int buttonH = 18;
        int buttonY = 0; //variables to be used for button creation below

        int rowCount = 0;
        for (int i : activeChannels) {
            buttonX = x + spaceBetweenButtons;
            buttonY = int(y + ((_channelBarHeight)*rowCount) + (((_channelBarHeight)-buttonH)/2)); //timeSeries_widget.channelBarHeight

            final int buttonXIncrement = spaceBetweenButtons + buttonW;

            gainButtons[i].but_x = buttonX;
            gainButtons[i].but_y = buttonY;
            gainButtons[i].but_dx = buttonW;
            gainButtons[i].but_dy = buttonH;

            buttonX += buttonXIncrement;

            inputTypeButtons[i].but_x = buttonX;
            inputTypeButtons[i].but_y = buttonY;
            inputTypeButtons[i].but_dx = buttonW;
            inputTypeButtons[i].but_dy = buttonH;

            buttonX += buttonXIncrement;

            biasButtons[i].but_x = buttonX;
            biasButtons[i].but_y = buttonY;
            biasButtons[i].but_dx = buttonW;
            biasButtons[i].but_dy = buttonH;

            buttonX += buttonXIncrement;

            srb2Buttons[i].but_x = buttonX;
            srb2Buttons[i].but_y = buttonY;
            srb2Buttons[i].but_dx = buttonW;
            srb2Buttons[i].but_dy = buttonH;

            buttonX += buttonXIncrement;

            srb1Buttons[i].but_x = buttonX;
            srb1Buttons[i].but_y = buttonY;
            srb1Buttons[i].but_dx = buttonW;
            srb1Buttons[i].but_dy = buttonH;

            rowCount++;
        }
    }


    public void mousePressed(){
        if (isVisible) {
            for (int i : activeChannels) {

                // buttons only work if the channel is active
                if (boardSettings.isChannelActive(i)) {

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
                }
            }
        }
    }

    public void mouseReleased(){
        if (isVisible) {
            for (int i : activeChannels) {
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
            }
        }
    }

    public void resize(int _x, int _y, int _w, int _h, int _channelBarHeight){
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        resizeButtons(_channelBarHeight);

        hardwareSettingsLoad.setPosition(x + (w/4) - button_w/2, y - button_h - 3);
        hardwareSettingsSave.setPosition(x + (w/2) + (w/4) - button_w/2, y - button_h - 3);
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
        switch(name) {
            case "HardwareSettingsLoad":
                myButton.onClick(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                        if (isRunning) {
                            PopupMessage msg = new PopupMessage("Info", "Streaming needs to be stopped before loading hardware settings.");
                        } else {
                            selectInput("Select settings file to load", "loadHardwareSettings");
                        }
                    }
                });
                break;
            case "HardwareSettingsSave":
                myButton.onClick(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                        selectOutput("Save settings to file", "storeHardwareSettings");
                    }
                });
                break;
            default:
                break;
        }
        return myButton;
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
                outputError("Failed to load hardware settings.");
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
                outputError("Failed to save hardware settings.");
            }
        }
    }
}