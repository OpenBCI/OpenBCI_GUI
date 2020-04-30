//////////////////////////////////////////////////////////////////////////
//
//    Hardware Settings Controller
//    - this is the user interface for allowing you to control the hardware settings of the 32bit Board & 16chan Setup (32bit + Daisy)
//
//    Written by: Conor Russomanno (Oct. 2016) ... adapted from ChannelController.pde of GUI V1 ... it's a little bit simpler now :|
//    Based on some original GUI code by: Chip Audette 2013/2014
//
//////////////////////////////////////////////////////////////////////////

public void updateChannelArrays(int _nchan) {
    channelSettingValues = new char [_nchan][numSettingsPerChannel]; // [channel#][Button#-value] ... this will incfluence text of button
    impedanceCheckValues = new char [_nchan][2];
}

//activateChannel: Ichan is [0 nchan-1] (aka zero referenced)
void activateChannel(int Ichan) {
    println("OpenBCI_GUI: activating channel " + (Ichan+1));

    currentBoard.setEXGChannelActive(Ichan, true);
    if (Ichan < nchan) {
        channelSettingValues[Ichan][0] = '0';
        // gui.cc.update();
    }
}

void deactivateChannel(int Ichan) {
    println("OpenBCI_GUI: deactivating channel " + (Ichan+1));
    
    currentBoard.setEXGChannelActive(Ichan, false);
    if (Ichan < nchan) {
        channelSettingValues[Ichan][0] = '1';
    }
}

class HardwareSettingsController{

    boolean isVisible = false;
    int x, y, w, h;

    int spaceBetweenButtons = 5; //space between buttons

    // [Number of Channels] x 6 array of buttons for channel settings
    Button[][] channelSettingButtons = new Button [nchan][numSettingsPerChannel];  // [channel#][Button#]

    // Array for storing SRB2 history settings of channels prior to shutting off .. so you can return to previous state when reactivating channel
    char[] previousSRB2 = new char [nchan];
    // Array for storing SRB2 history settings of channels prior to shutting off .. so you can return to previous state when reactivating channel
    char[] previousBIAS = new char [nchan];

    //maximum different values for the different settings (Power Down, Gain, Input Type, BIAS, SRB2, SRB1) of
    //refer to page 44 of ADS1299 Datasheet: http://www.ti.com/lit/ds/symlink/ads1299.pdf
    char[] maxValuesPerSetting = {
        '1', // Power Down :: (0)ON, (1)OFF
        '6', // Gain :: (0) x1, (1) x2, (2) x4, (3) x6, (4) x8, (5) x12, (6) x24 ... default
        '7', // Channel Input :: (0)Normal Electrode Input, (1)Input Shorted, (2)Used in conjunction with BIAS_MEAS, (3)MVDD for supply measurement, (4)Temperature Sensor, (5)Test Signal, (6)BIAS_DRP ... positive electrode is driver, (7)BIAS_DRN ... negative electrode is driver
        '1', // BIAS :: (0) Yes, (1) No
        '1', // SRB2 :: (0) Open, (1) Closed
        '1'
    }; // SRB1 :: (0) Yes, (1) No ... this setting affects all channels ... either all on or all off

    HardwareSettingsController(int _x, int _y, int _w, int _h, int _channelBarHeight){
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        createChannelSettingButtons(_channelBarHeight);
    }

    void update(){
        for (int i = 0; i < nchan; i++) { //for every channel
            //update buttons based on channelSettingValues[i][j]
            for (int j = 0; j < numSettingsPerChannel; j++) {
                switch(j) {  //what setting are we looking at
                    case 0: //on/off ??
                        // if (channelSettingValues[i][j] == '0') channelSettingButtons[i][0].setColorNotPressed(channelColors[i%8]);// power down == false, set color to vibrant
                        if (channelSettingValues[i][j] == '0') w_timeSeries.channelBars[i].onOffButton.setColorNotPressed(channelColors[i%8]);// power down == false, set color to vibrant
                        if (channelSettingValues[i][j] == '1') w_timeSeries.channelBars[i].onOffButton.setColorNotPressed(75); // power down == true, set color to dark gray, indicating power down
                        break;
                    case 1: //GAIN ??
                        if (channelSettingValues[i][j] == '0') channelSettingButtons[i][1].setString("x1");
                        if (channelSettingValues[i][j] == '1') channelSettingButtons[i][1].setString("x2");
                        if (channelSettingValues[i][j] == '2') channelSettingButtons[i][1].setString("x4");
                        if (channelSettingValues[i][j] == '3') channelSettingButtons[i][1].setString("x6");
                        if (channelSettingValues[i][j] == '4') channelSettingButtons[i][1].setString("x8");
                        if (channelSettingValues[i][j] == '5') channelSettingButtons[i][1].setString("x12");
                        if (channelSettingValues[i][j] == '6') channelSettingButtons[i][1].setString("x24");
                        break;
                    case 2: //input type ??
                        if (channelSettingValues[i][j] == '0') channelSettingButtons[i][2].setString("Normal");
                        if (channelSettingValues[i][j] == '1') channelSettingButtons[i][2].setString("Shorted");
                        if (channelSettingValues[i][j] == '2') channelSettingButtons[i][2].setString("BIAS_MEAS");
                        if (channelSettingValues[i][j] == '3') channelSettingButtons[i][2].setString("MVDD");
                        if (channelSettingValues[i][j] == '4') channelSettingButtons[i][2].setString("Temp.");
                        if (channelSettingValues[i][j] == '5') channelSettingButtons[i][2].setString("Test");
                        if (channelSettingValues[i][j] == '6') channelSettingButtons[i][2].setString("BIAS_DRP");
                        if (channelSettingValues[i][j] == '7') channelSettingButtons[i][2].setString("BIAS_DRN");
                        break;
                    case 3: //BIAS ??
                        if (channelSettingValues[i][j] == '0') channelSettingButtons[i][3].setString("Don't Include");
                        if (channelSettingValues[i][j] == '1') channelSettingButtons[i][3].setString("Include");
                        break;
                    case 4: // SRB2 ??
                        if (channelSettingValues[i][j] == '0') channelSettingButtons[i][4].setString("Off");
                        if (channelSettingValues[i][j] == '1') channelSettingButtons[i][4].setString("On");
                        break;
                    case 5: // SRB1 ??
                        if (channelSettingValues[i][j] == '0') channelSettingButtons[i][5].setString("No");
                        if (channelSettingValues[i][j] == '1') channelSettingButtons[i][5].setString("Yes");
                        break;
                }
            }
        }
    }

    void draw(){
        pushStyle();

        if (isVisible) {
            //background
            noStroke();
            fill(0, 0, 0, 100);
            rect(x, y, w, h);

            // [numChan] x 5 ... all channel setting buttons (other than on/off)
            for (int i = 0; i < nchan; i++) {
                for (int j = 1; j < 6; j++) {
                    channelSettingButtons[i][j].draw();
                }
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

    public void loadDefaultChannelSettings() {
        for (int i = 0; i < nchan; i++) {
            channelSettingValues[i][0] = '0';
            channelSettingValues[i][1] = '6';
            channelSettingValues[i][2] = '0';
            channelSettingValues[i][3] = '1';
            channelSettingValues[i][4] = '1';
            channelSettingValues[i][5] = '0';

            for (int k = 0; k < 2; k++) { //impedance setting values
                impedanceCheckValues[i][k] = '0';
            }
        }
        update(); //update 1 time to refresh button values based on new loaded settings
    }

    public void powerDownChannel(int _numChannel) {
        // TODO[brainflow] How is this different from deactivateChannel?
        verbosePrint("Powering down channel " + str(int(_numChannel) + int(1)));
        //save SRB2 and BIAS settings in 2D history array (to turn back on when channel is reactivated)
        previousBIAS[_numChannel] = channelSettingValues[_numChannel][3];
        previousSRB2[_numChannel] = channelSettingValues[_numChannel][4];
        channelSettingValues[_numChannel][3] = '0'; //make sure to disconnect from BIAS
        channelSettingValues[_numChannel][4] = '0'; //make sure to disconnect from SRB2

        channelSettingValues[_numChannel][0] = '1'; //update powerUp/powerDown value of 2D array
        currentBoard.setEXGChannelActive(_numChannel, false);
    }

    public void powerUpChannel(int _numChannel) {
        verbosePrint("Powering up channel " + str(int(_numChannel) + int(1)));
        //replace SRB2 and BIAS settings with values from 2D history array
        channelSettingValues[_numChannel][3] = previousBIAS[_numChannel];
        channelSettingValues[_numChannel][4] = previousSRB2[_numChannel];

        channelSettingValues[_numChannel][0] = '0'; //update powerUp/powerDown value of 2D array
        currentBoard.setEXGChannelActive(_numChannel, true);
    }

    public void initImpWrite(int _numChannel, char pORn, char onORoff) {
        verbosePrint("Writing impedance check settings (" + pORn + "," + onORoff +  ") for channel " + str(_numChannel) + " to OpenBCI!");

        // TODO[brainflow] clean this up
        if (pORn == 'p') {
            impedanceCheckValues[_numChannel-1][0] = onORoff;
        }
        if (pORn == 'n') {
            impedanceCheckValues[_numChannel-1][1] = onORoff;
        }

        if (currentBoard instanceof ImpedanceSettingsBoard) {
            ((ImpedanceSettingsBoard)currentBoard).setImpedanceSettings(_numChannel-1, pORn, onORoff == '1');
        }
        else {
            outputError("Impedance settings not implemented for this board");
        }
    }

    public void createChannelSettingButtons(int _channelBarHeight) {
        //the size and space of these buttons are dependendant on the size of the screen and full ChannelController
        verbosePrint("ChannelController: createChannelSettingButtons: creating channel setting buttons...");
        int buttonW = 0;
        int buttonX = 0;
        int buttonH = 0;
        int buttonY = 0; //variables to be used for button creation below
        String buttonString = "";
        Button tempButton;

        for (int i = 0; i < nchan; i++) {
            for (int j = 1; j < 6; j++) {
                buttonW = int((w - (spaceBetweenButtons*6)) / 5);
                buttonX = int((x + (spaceBetweenButtons * (j))) + ((j-1) * buttonW));
                buttonH = 18;
                // buttonY = int(y + ((30)*i) + (((30)-buttonH)/2)); //timeSeries_widget.channelBarHeight
                buttonY = int(y + ((_channelBarHeight)*i) + (((_channelBarHeight)-buttonH)/2)); //timeSeries_widget.channelBarHeight
                buttonString = "N/A";
                tempButton = new Button (buttonX, buttonY, buttonW, buttonH, buttonString, 14);
                channelSettingButtons[i][j] = tempButton;
            }
        }
    }

    void mousePressed(){
        if (isVisible) {
            for (int i = 0; i < nchan; i++) { //When [i][j] button is clicked
                for (int j = 1; j < numSettingsPerChannel; j++) {
                    if (channelSettingButtons[i][j].isMouseHere()) {
                        //increment [i][j] channelSettingValue by, until it reaches max values per setting [j],
                        channelSettingButtons[i][j].wasPressed = true;
                        channelSettingButtons[i][j].isActive = true;
                    }
                }
            }
        }
    }

    void mouseReleased(){
        if (isVisible) {
            for (int i = 0; i < nchan; i++) { //When [i][j] button is clicked
                for (int j = 1; j < numSettingsPerChannel; j++) {
                    if (channelSettingButtons[i][j].isMouseHere() && channelSettingButtons[i][j].wasPressed == true) {
                        if (channelSettingValues[i][j] < maxValuesPerSetting[j]) {
                            channelSettingValues[i][j]++;	//increment [i][j] channelSettingValue by, until it reaches max values per setting [j],
                        } else {
                            channelSettingValues[i][j] = '0';
                        }
                        // TODO[brainflow] some cleanup here
                        if (currentBoard instanceof BoardCyton) {
                            ((BoardCyton)currentBoard).setChannelSettings(i, channelSettingValues[i]);
                        }
                        else if (currentBoard instanceof BoardNovaXR) {
                            ((BoardNovaXR)currentBoard).setChannelSettings(i, channelSettingValues[i]);
                        }
                        else {
                            outputError("Channel settings not implemented for this board.");
                        }
                    }

                    // if(!channelSettingButtons[i][j].isMouseHere()){
                    channelSettingButtons[i][j].isActive = false;
                    channelSettingButtons[i][j].wasPressed = false;
                    // }
                }
            }
        }
    }

    void screenResized(int _x, int _y, int _w, int _h, int _channelBarHeight){
        x = _x;
        y = _y;
        w = _w;
        h = _h;

        int buttonW = 0;
        int buttonX = 0;
        int buttonH = 0;
        int buttonY = 0; //variables to be used for button creation below
        String buttonString = "";

        for (int i = 0; i < nchan; i++) {
            for (int j = 1; j < 6; j++) {
                buttonW = int((w - (spaceBetweenButtons*6)) / 5);
                buttonX = int((x + (spaceBetweenButtons * (j))) + ((j-1) * buttonW));
                buttonH = 18;
                buttonY = int(y + ((_channelBarHeight)*i) + (((_channelBarHeight)-buttonH)/2)); //timeSeries_widget.channelBarHeight
                buttonString = "N/A";
                channelSettingButtons[i][j].but_x = buttonX;
                channelSettingButtons[i][j].but_y = buttonY;
                channelSettingButtons[i][j].but_dx = buttonW;
                channelSettingButtons[i][j].but_dy = buttonH;
            }
        }
    }

    void toggleImpedanceCheck(int _channelNumber){ //Channel Numbers start at 1
        if(channelSettingValues[_channelNumber-1][4] == '1'){     //is N pin being used...
            if (impedanceCheckValues[_channelNumber-1][1] < '1') { //if not checking/drawing impedance
                initImpWrite(_channelNumber, 'n', '1');  // turn on the impedance check for the desired channel
                println("Imp[" + _channelNumber + "] is on.");
            } else {
                initImpWrite(_channelNumber, 'n', '0'); //turn off impedance check for desired channel
                println("Imp[" + _channelNumber + "] is off.");
            }
        }

        if(channelSettingValues[_channelNumber-1][4] == '0'){     //is P pin being used
            if (impedanceCheckValues[_channelNumber-1][0] < '1') {    //is channel on
                initImpWrite(_channelNumber, 'p', '1');
            } else {
                initImpWrite(_channelNumber, 'p', '0');
            }
        }
    }
};
