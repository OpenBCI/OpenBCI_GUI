
class ADS1299SettingsController{

    boolean isVisible = false;
    int x, y, w, h;

    int spaceBetweenButtons = 5; //space between buttons

    Button[] gainButtons;
    Button[] inputTypeButtons;
    Button[] biasButtons;
    Button[] srb2Buttons;
    Button[] srb1Buttons;

    ADS1299Settings boardSettings;

    ADS1299SettingsController(int _x, int _y, int _w, int _h, int _channelBarHeight){
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        ADS1299SettingsBoard settingsBoard = (ADS1299SettingsBoard)currentBoard;
        boardSettings = settingsBoard.getADS1299Settings();
        createAllButtons(_channelBarHeight);
    }

    public void activateChannel(int Ichan) {
        println("OpenBCI_GUI: activating channel " + (Ichan+1));
        currentBoard.setEXGChannelActive(Ichan, true);
    }

    public void deactivateChannel(int Ichan) {
        println("OpenBCI_GUI: deactivating channel " + (Ichan+1));
        currentBoard.setEXGChannelActive(Ichan, false);
    }

    public void update(){
        for (int i=0; i<currentBoard.getNumEXGChannels(); i++) {
            // grab the name out of the enum directly.
            gainButtons[i].setString(boardSettings.gain[i].getName());
            inputTypeButtons[i].setString(boardSettings.inputType[i].getName());
            biasButtons[i].setString(boardSettings.bias[i].getName());
            srb2Buttons[i].setString(boardSettings.srb2[i].getName());
            srb1Buttons[i].setString(boardSettings.srb1[i].getName());
        }
    }

    public void draw(){
        pushStyle();

        if (isVisible) {
            //background
            noStroke();
            fill(0, 0, 0, 100);
            rect(x, y, w, h);

            for (int i=0; i<currentBoard.getNumEXGChannels(); i++) {
                // grab the name out of the enum directly.
                gainButtons[i].draw();
                inputTypeButtons[i].draw();
                biasButtons[i].draw();
                srb2Buttons[i].draw();
                srb1Buttons[i].draw();
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

    public void initImpWrite(int _numChannel, char pORn, char onORoff) {
        verbosePrint("Writing impedance check settings (" + pORn + "," + onORoff +  ") for channel " + str(_numChannel+1) + " to OpenBCI!");

        // TODO[brainflow] clean this up
        if (pORn == 'p') {
            impedanceCheckValues[_numChannel][0] = onORoff;
        }
        if (pORn == 'n') {
            impedanceCheckValues[_numChannel][1] = onORoff;
        }

        if (currentBoard instanceof ImpedanceSettingsBoard) {
            ((ImpedanceSettingsBoard)currentBoard).setImpedanceSettings(_numChannel, pORn, onORoff == '1');
        }
        else {
            outputError("Impedance settings not implemented for this board");
        }
    }

    private void createAllButtons(int _channelBarHeight) {
        //the size and space of these buttons are dependendant on the size of the screen and full ChannelController
        verbosePrint("ChannelController: createChannelSettingButtons: creating channel setting buttons...");

        int channelCount = currentBoard.getNumEXGChannels();

        gainButtons = new Button[channelCount];
        inputTypeButtons = new Button[channelCount];
        biasButtons = new Button[channelCount];
        srb2Buttons = new Button[channelCount];
        srb1Buttons = new Button[channelCount];

        for (int i=0; i<channelCount; i++) {
            gainButtons[i] = new Button(0, 0, 0, 0, "Unlabeled");
            inputTypeButtons[i] = new Button(0, 0, 0, 0, "Unlabeled");
            biasButtons[i] = new Button(0, 0, 0, 0, "Unlabeled");
            srb2Buttons[i] = new Button(0, 0, 0, 0, "Unlabeled");
            srb1Buttons[i] = new Button(0, 0, 0, 0, "Unlabeled");
        }

        resizeButtons(_channelBarHeight);
    }

    private void resizeButtons(int _channelBarHeight) {
        int buttonW = int((w - (spaceBetweenButtons*6)) / 5);
        int buttonX = 0;
        int buttonH = 18;
        int buttonY = 0; //variables to be used for button creation below

        for (int i = 0; i < currentBoard.getNumEXGChannels(); i++) {
            buttonX = x + spaceBetweenButtons;
            buttonY = int(y + ((_channelBarHeight)*i) + (((_channelBarHeight)-buttonH)/2)); //timeSeries_widget.channelBarHeight

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
        }
    }


    public void mousePressed(){
        if (isVisible) {
            for (int i = 0; i < currentBoard.getNumEXGChannels(); i++) {
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

    public void mouseReleased(){
        if (isVisible) {
            for (int i = 0; i < currentBoard.getNumEXGChannels(); i++) {
                if(gainButtons[i].isMouseHere() && gainButtons[i].wasPressed) {
                    boardSettings.gain[i] = boardSettings.gain[i].getNext();
                    boardSettings.commit(i);
                    gainButtons[i].wasPressed = false;
                    gainButtons[i].isActive = false; 
                }
                if(inputTypeButtons[i].isMouseHere() && inputTypeButtons[i].wasPressed) {
                    boardSettings.inputType[i] = boardSettings.inputType[i].getNext();
                    boardSettings.commit(i);
                    inputTypeButtons[i].wasPressed = false;
                    inputTypeButtons[i].isActive = false;  
                }
                if(biasButtons[i].isMouseHere() && biasButtons[i].wasPressed) {
                    boardSettings.bias[i] = boardSettings.bias[i].getNext();
                    boardSettings.commit(i);
                    biasButtons[i].wasPressed = false;
                    biasButtons[i].isActive = false;   
                }
                if(srb2Buttons[i].isMouseHere() && srb2Buttons[i].wasPressed) {
                    boardSettings.srb2[i] = boardSettings.srb2[i].getNext();
                    boardSettings.commit(i);
                    srb2Buttons[i].wasPressed = false;
                    srb2Buttons[i].isActive = false;    
                }
                if(srb1Buttons[i].isMouseHere() && srb1Buttons[i].wasPressed) {
                    boardSettings.srb1[i] = boardSettings.srb1[i].getNext();
                    boardSettings.commit(i);
                    srb1Buttons[i].wasPressed = false;
                    srb1Buttons[i].isActive = false;  
                }
            }
        }
    }

    public void screenResized(int _x, int _y, int _w, int _h, int _channelBarHeight){
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        resizeButtons(_channelBarHeight);
    }

    void toggleImpedanceCheck(int _channelNumber){ //Channel Numbers start at 1
        if(boardSettings.srb2[_channelNumber] == Srb2.CONNECT){     //is N pin being used...
            if (impedanceCheckValues[_channelNumber][1] < '1') { //if not checking/drawing impedance
                initImpWrite(_channelNumber, 'n', '1');  // turn on the impedance check for the desired channel
            } else {
                initImpWrite(_channelNumber, 'n', '0'); //turn off impedance check for desired channel
            }
        }

        if(boardSettings.srb2[_channelNumber] == Srb2.DISCONNECT){     //is P pin being used
            if (impedanceCheckValues[_channelNumber][0] < '1') {    //is channel on
                initImpWrite(_channelNumber, 'p', '1');
            } else {
                initImpWrite(_channelNumber, 'p', '0');
            }
        }
    }
};
