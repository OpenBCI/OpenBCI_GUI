//////////////////////////////////////////////////////////////////////////
//
//    Hardware Settings Controller
//    - this is the user interface for allowing you to control the hardware settings of the 32bit Board & 16chan Setup (32bit + Daisy)
//
//    Written by: Conor Russomanno (Oct. 2016) ... adapted from ChannelController.pde of GUI V1 ... it's a little bit simpler now :|
//
//////////////////////////////////////////////////////////////////////////

class HardwareSettingsController{

  boolean isVisible = false;

  int x, y, w, h;

  int numSettingsPerChannel = 6; //each channel has 6 different settings
  char[][] channelSettingValues = new char [nchan][numSettingsPerChannel]; // [channel#][Button#-value] ... this will incfluence text of button
  char[][] impedanceCheckValues = new char [nchan][2];

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

  //variables used for channel write timing in writeChannelSettings()
  int channelToWrite = -1;

  //variables use for imp write timing with writeImpedanceSettings()
  int impChannelToWrite = -1;

  boolean rewriteChannelWhenDoneWriting = false;
  int channelToWriteWhenDoneWriting = 0;

  boolean rewriteImpedanceWhenDoneWriting = false;
  int impChannelToWriteWhenDoneWriting = 0;
  char final_pORn = '0';
  char final_onORoff = '0';

  HardwareSettingsController(int _x, int _y, int _w, int _h, int _channelBarHeight){
    x = _x;
    y = _y;
    w = _w;
    h = _h;

    createChannelSettingButtons(_channelBarHeight);

  }

  void update(){
    //make false to check again below
    // for (int i = 0; i < nchan; i++) {
    //   drawImpedanceValues[i] = false;
    // }

    for (int i = 0; i < nchan; i++) { //for every channel
      //update buttons based on channelSettingValues[i][j]
      for (int j = 0; j < numSettingsPerChannel; j++) {
        switch(j) {  //what setting are we looking at
          case 0: //on/off ??
            // if (channelSettingValues[i][j] == '0') channelSettingButtons[i][0].setColorNotPressed(channelColors[i%8]);// power down == false, set color to vibrant
            if (channelSettingValues[i][j] == '0') timeSeries_widget.channelBars[i].onOffButton.setColorNotPressed(channelColors[i%8]);// power down == false, set color to vibrant
            if (channelSettingValues[i][j] == '1') timeSeries_widget.channelBars[i].onOffButton.setColorNotPressed(75); // power down == true, set color to dark gray, indicating power down
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

      // needs to be updated to work with single imp button ...
      // for (int k = 0; k < 2; k++) {
      //   switch(k) {
      //     case 0: // P Imp Buttons
      //       if (impedanceCheckValues[i][k] == '0') {
      //         impedanceCheckButtons[i][0].setColorNotPressed(color(75));
      //         impedanceCheckButtons[i][0].setString("");
      //       }
      //       if (impedanceCheckValues[i][k] == '1') {
      //         impedanceCheckButtons[i][0].setColorNotPressed(isSelected_color);
      //         impedanceCheckButtons[i][0].setString("");
      //         if (showFullController) {
      //           drawImpedanceValues[i] = false;
      //         } else {
      //           drawImpedanceValues[i] = true;
      //         }
      //       }
      //       break;
      //     case 1: // N Imp Buttons
      //       if (impedanceCheckValues[i][k] == '0') {
      //         impedanceCheckButtons[i][1].setColorNotPressed(color(75));
      //         impedanceCheckButtons[i][1].setString("");
      //       }
      //       if (impedanceCheckValues[i][k] == '1') {
      //         impedanceCheckButtons[i][1].setColorNotPressed(isSelected_color);
      //         impedanceCheckButtons[i][1].setString("");
      //         if (showFullController) {
      //           drawImpedanceValues[i] = false;
      //         } else {
      //           drawImpedanceValues[i] = true;
      //         }
      //       }
      //       break;
      //   }
      // }
    }
    //then reset to 1

    //
    if (openBCI.get_isWritingChannel()) {
      openBCI.writeChannelSettings(channelToWrite,channelSettingValues);
    }

    if (rewriteChannelWhenDoneWriting == true && openBCI.get_isWritingChannel() == false) {
      initChannelWrite(channelToWriteWhenDoneWriting);
      rewriteChannelWhenDoneWriting = false;
    }

    if (openBCI.get_isWritingImp()) {
      openBCI.writeImpedanceSettings(impChannelToWrite,impedanceCheckValues);
    }

    if (rewriteImpedanceWhenDoneWriting == true && openBCI.get_isWritingImp() == false) {
      initImpWrite(impChannelToWriteWhenDoneWriting, final_pORn, final_onORoff);
      rewriteImpedanceWhenDoneWriting = false;
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
          // fill(bgColor);
          // text("PGA Gain", x2 + (w2/10)*1, y1 - 12);
          // text("Input Type", x2 + (w2/10)*3, y1 - 12);
          // text("  Bias ", x2 + (w2/10)*5, y1 - 12);
          // text("SRB2", x2 + (w2/10)*7, y1 - 12);
          // text("SRB1", x2 + (w2/10)*9, y1 - 12);

          //if mode is not from OpenBCI, draw a dark overlay to indicate that you cannot edit these settings
          if (eegDataSource != DATASOURCE_NORMAL_W_AUX) {
            fill(0, 0, 0, 200);
            noStroke();
            rect(x-2, y, w+1, h);
            fill(255);
            textAlign(CENTER,CENTER);
            textFont(h1,18);
            text("DATA SOURCE (LIVE) only", x + (w/2), y + (h/2));
          }
        }

        // for (int i = 0; i < nchan; i++) {
        //   if (drawImpedanceValues[i] == true) {
        //     gui.impValuesMontage[i].draw();  //impedance values on montage plot
        //   }
        // }

        popStyle();
  }

  public void loadDefaultChannelSettings() {
    verbosePrint("ChannelController: loading default channel settings to GUI's channel controller...");
    for (int i = 0; i < nchan; i++) {
      verbosePrint("chan: " + i + " ");
      for (int j = 0; j < numSettingsPerChannel; j++) { //channel setting values
        channelSettingValues[i][j] = char(openBCI.get_defaultChannelSettings().toCharArray()[j]); //parse defaultChannelSettings string created in the OpenBCI_ADS1299 class
        if (j == numSettingsPerChannel - 1) {
          println(char(openBCI.get_defaultChannelSettings().toCharArray()[j]));
        } else {
          print(char(openBCI.get_defaultChannelSettings().toCharArray()[j]) + ",");
        }
      }
      for (int k = 0; k < 2; k++) { //impedance setting values
        impedanceCheckValues[i][k] = '0';
      }
    }
    verbosePrint("made it!");
    update(); //update 1 time to refresh button values based on new loaded settings
  }

  void updateChannelArrays(int _nchan) {
    channelSettingValues = new char [_nchan][numSettingsPerChannel]; // [channel#][Button#-value] ... this will incfluence text of button
    impedanceCheckValues = new char [_nchan][2];
  }

  //activateChannel: Ichan is [0 nchan-1] (aka zero referenced)
  void activateChannel(int Ichan) {
    println("OpenBCI_GUI: activating channel " + (Ichan+1));
    if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
      if (openBCI.isSerialPortOpen()) {
        verbosePrint("**");
        openBCI.changeChannelState(Ichan, true); //activate
      }
    } else if (eegDataSource == DATASOURCE_GANGLION) {
      // println("activating channel on ganglion");
      ganglion.changeChannelState(Ichan, true);
    }
    if (Ichan < gui.chanButtons.length) {
      channelSettingValues[Ichan][0] = '0';
      timeSeries_widget.hsc.update(); //previously gui.cc.update();
    }
  }

  void deactivateChannel(int Ichan) {
    println("OpenBCI_GUI: deactivating channel " + (Ichan+1));
    if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
      if (openBCI.isSerialPortOpen()) {
        verbosePrint("**");
        openBCI.changeChannelState(Ichan, false); //de-activate
      }
    } else if (eegDataSource == DATASOURCE_GANGLION) {
      // println("deactivating channel on ganglion");
      ganglion.changeChannelState(Ichan, false);
    }
    if (Ichan < gui.chanButtons.length) {
      channelSettingValues[Ichan][0] = '1';
      timeSeries_widget.hsc.update();
    }
  }

  //Ichan is zero referenced (not one referenced)
  boolean isChannelActive(int Ichan) {
    boolean return_val = false;
    if (channelSettingValues[Ichan][0] == '1') {
      return_val = false;
    } else {
      return_val = true;
    }
    return return_val;
  }

  public void powerDownChannel(int _numChannel) {
    verbosePrint("Powering down channel " + str(int(_numChannel) + int(1)));
    //save SRB2 and BIAS settings in 2D history array (to turn back on when channel is reactivated)
    previousBIAS[_numChannel] = channelSettingValues[_numChannel][3];
    previousSRB2[_numChannel] = channelSettingValues[_numChannel][4];
    channelSettingValues[_numChannel][3] = '0'; //make sure to disconnect from BIAS
    channelSettingValues[_numChannel][4] = '0'; //make sure to disconnect from SRB2

    channelSettingValues[_numChannel][0] = '1'; //update powerUp/powerDown value of 2D array
    verbosePrint("Command: " + command_deactivate_channel[_numChannel]);
    openBCI.deactivateChannel(_numChannel);  //assumes numChannel counts from zero (not one)...handles regular and daisy channels
  }

  public void powerUpChannel(int _numChannel) {
    verbosePrint("Powering up channel " + str(int(_numChannel) + int(1)));
    //replace SRB2 and BIAS settings with values from 2D history array
    channelSettingValues[_numChannel][3] = previousBIAS[_numChannel];
    channelSettingValues[_numChannel][4] = previousSRB2[_numChannel];

    channelSettingValues[_numChannel][0] = '0'; //update powerUp/powerDown value of 2D array
    verbosePrint("Command: " + command_activate_channel[_numChannel]);
    openBCI.activateChannel(_numChannel);  //assumes numChannel counts from zero (not one)...handles regular and daisy channels//assumes numChannel counts from zero (not one)...handles regular and daisy channels
  }

  public void initChannelWrite(int _numChannel) {
    //after clicking any button, write the new settings for that channel to OpenBCI
    if (!openBCI.get_isWritingImp()) { //make sure you aren't currently writing imp settings for a channel
      verbosePrint("Writing channel settings for channel " + str(_numChannel+1) + " to OpenBCI!");
      openBCI.initChannelWrite(_numChannel);
      channelToWrite = _numChannel;
    }
  }

  public void initImpWrite(int _numChannel, char pORn, char onORoff) {
    //after clicking any button, write the new settings for that channel to OpenBCI
    if (!openBCI.get_isWritingChannel()) { //make sure you aren't currently writing imp settings for a channel
      // if you're not currently writing a channel and not waiting to rewrite after you've finished mashing the button
      if (!openBCI.get_isWritingImp() && rewriteImpedanceWhenDoneWriting == false) {
        verbosePrint("Writing impedance check settings (" + pORn + "," + onORoff +  ") for channel " + str(_numChannel+1) + " to OpenBCI!");
        if (pORn == 'p') {
          impedanceCheckValues[_numChannel][0] = onORoff;
        }
        if (pORn == 'n') {
          impedanceCheckValues[_numChannel][1] = onORoff;
        }
        openBCI.initImpWrite(_numChannel);
        impChannelToWrite = _numChannel;
      } else { //else wait until a the current write has finished and then write again ... this is to not overwrite the wrong values while writing a channel
        verbosePrint("CONGRATULATIONS, YOU'RE MASHING BUTTONS!");
        rewriteImpedanceWhenDoneWriting = true;
        impChannelToWriteWhenDoneWriting = _numChannel;

        if (pORn == 'p') {
          final_pORn = 'p';
        }
        if (pORn == 'n') {
          final_pORn = 'n';
        }
        final_onORoff = onORoff;
      }
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

    //create all other channel setting buttons... these are only visible when the user toggles to "showFullController = true"
    // for (int i = 0; i < nchan; i++) {
    //   for (int j = 1; j < 6; j++) {
    //     buttonW = int((w2 - (spacer2*6)) / 5);
    //     buttonX = int((x2 + (spacer2 * (j))) + ((j-1) * buttonW));
    //     // buttonH = int((h2 / (nchan + 1)) - (spacer2/2));
    //     buttonY = int(y2 + (((h2-1)/(nchan+1))*(i+1)) - (buttonH/2));
    //     buttonString = "N/A";
    //     tempButton = new Button (buttonX, buttonY, buttonW, buttonH, buttonString, 14);
    //     channelSettingButtons[i][j] = tempButton;
    //   }
    // }
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

  // public void mousePressed() {
  //   //if fullChannelController and one of the buttons (other than ON/OFF) is clicked
  //
  //     //if dataSource is coming from OpenBCI, allow user to interact with channel controller
  //   if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
  //     if (showFullController) {
  //       for (int i = 0; i < nchan; i++) { //When [i][j] button is clicked
  //         for (int j = 1; j < numSettingsPerChannel; j++) {
  //           if (channelSettingButtons[i][j].isMouseHere()) {
  //             //increment [i][j] channelSettingValue by, until it reaches max values per setting [j],
  //             channelSettingButtons[i][j].wasPressed = true;
  //             channelSettingButtons[i][j].isActive = true;
  //           }
  //         }
  //       }
  //     }
  //   }
  //   //on/off button and Imp buttons can always be clicked/released
  //   for (int i = 0; i < nchan; i++) {
  //     if (channelSettingButtons[i][0].isMouseHere()) {
  //       channelSettingButtons[i][0].wasPressed = true;
  //       channelSettingButtons[i][0].isActive = true;
  //     }
  //
  //     //only allow editing of impedance if dataSource == from OpenBCI
  //     if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
  //       if (impedanceCheckButtons[i][0].isMouseHere()) {
  //         impedanceCheckButtons[i][0].wasPressed = true;
  //         impedanceCheckButtons[i][0].isActive = true;
  //       }
  //       if (impedanceCheckButtons[i][1].isMouseHere()) {
  //         impedanceCheckButtons[i][1].wasPressed = true;
  //         impedanceCheckButtons[i][1].isActive = true;
  //       }
  //     }
  //   }
  // }
  //
  // public void mouseReleased() {
  //   //if fullChannelController and one of the buttons (other than ON/OFF) is released
  //   if (showFullController) {
  //     for (int i = 0; i < nchan; i++) { //When [i][j] button is clicked
  //       for (int j = 1; j < numSettingsPerChannel; j++) {
  //         if (channelSettingButtons[i][j].isMouseHere() && channelSettingButtons[i][j].wasPressed == true) {
  //           if (channelSettingValues[i][j] < maxValuesPerSetting[j]) {
  //             channelSettingValues[i][j]++;	//increment [i][j] channelSettingValue by, until it reaches max values per setting [j],
  //           } else {
  //             channelSettingValues[i][j] = '0';
  //           }
  //           // if you're not currently writing a channel and not waiting to rewrite after you've finished mashing the button
  //           if (!openBCI.get_isWritingChannel() && rewriteChannelWhenDoneWriting == false) {
  //             initChannelWrite(i);//write new ADS1299 channel row values to OpenBCI
  //           } else { //else wait until a the current write has finished and then write again ... this is to not overwrite the wrong values while writing a channel
  //             verbosePrint("CONGRATULATIONS, YOU'RE MASHING BUTTONS!");
  //             rewriteChannelWhenDoneWriting = true;
  //             channelToWriteWhenDoneWriting = i;
  //           }
  //         }
  //
  //         // if(!channelSettingButtons[i][j].isMouseHere()){
  //         channelSettingButtons[i][j].isActive = false;
  //         channelSettingButtons[i][j].wasPressed = false;
  //         // }
  //       }
  //     }
  //   }
  //   //ON/OFF button can always be clicked/released
  //   for (int i = 0; i < nchan; i++) {
  //     //was on/off clicked?
  //     if (channelSettingButtons[i][0].isMouseHere() && channelSettingButtons[i][0].wasPressed == true) {
  //       if (channelSettingValues[i][0] < maxValuesPerSetting[0]) {
  //         channelSettingValues[i][0] = '1';	//increment [i][j] channelSettingValue by, until it reaches max values per setting [j],
  //         // channelSettingButtons[i][0].setColorNotPressed(color(25,25,25));
  //         // powerDownChannel(i);
  //         deactivateChannel(i);
  //       } else {
  //         channelSettingValues[i][0] = '0';
  //         // channelSettingButtons[i][0].setColorNotPressed(color(255));
  //         // powerUpChannel(i);
  //         activateChannel(i);
  //       }
  //       // writeChannelSettings(i);//write new ADS1299 channel row values to OpenBCI
  //     }
  //
  //     //was P imp check button clicked?
  //     if (impedanceCheckButtons[i][0].isMouseHere() && impedanceCheckButtons[i][0].wasPressed == true) {
  //       if (impedanceCheckValues[i][0] < '1') {
  //         // impedanceCheckValues[i][0] = '1';	//increment [i][j] channelSettingValue by, until it reaches max values per setting [j],
  //         // channelSettingButtons[i][0].setColorNotPressed(color(25,25,25));
  //         // writeImpedanceSettings(i);
  //         initImpWrite(i, 'p', '1');
  //         //initImpWrite
  //         verbosePrint("a");
  //       } else {
  //         // impedanceCheckValues[i][0] = '0';
  //         // channelSettingButtons[i][0].setColorNotPressed(color(255));
  //         // writeImpedanceSettings(i);
  //         initImpWrite(i, 'p', '0');
  //         verbosePrint("b");
  //       }
  //       // writeChannelSettings(i);//write new ADS1299 channel row values to OpenBCI
  //     }
  //
  //     //was N imp check button clicked?
  //     if (impedanceCheckButtons[i][1].isMouseHere() && impedanceCheckButtons[i][1].wasPressed == true) {
  //       if (impedanceCheckValues[i][1] < '1') {
  //         initImpWrite(i, 'n', '1');
  //         //initImpWrite
  //         verbosePrint("c");
  //       } else {
  //         initImpWrite(i, 'n', '0');
  //         verbosePrint("d");
  //       }
  //       // writeChannelSettings(i);//write new ADS1299 channel row values to OpenBCI
  //     }
  //
  //     channelSettingButtons[i][0].isActive = false;
  //     channelSettingButtons[i][0].wasPressed = false;
  //     impedanceCheckButtons[i][0].isActive = false;
  //     impedanceCheckButtons[i][0].wasPressed = false;
  //     impedanceCheckButtons[i][1].isActive = false;
  //     impedanceCheckButtons[i][1].wasPressed = false;
  //   }
  //
  //   update(); //update once to refresh button values
  // }

};
