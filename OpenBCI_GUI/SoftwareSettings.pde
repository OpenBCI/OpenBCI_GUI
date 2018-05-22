//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    Was going to add these functions to WidgetManager, then just decided to make a new tab
    
          Basics: 
          -- Add a drop down button somewhere near the top that says "Settings" or "Config", expands to show "Load" and "Save"
          --

Requested User Settings to save so far:

widgetmanager.currentContainerLayout //default layout
dataprocessing.currentNotch_ind //default notch
w_analogread.startingVertScaleIndex //default vert scale for analog read widget
w_timeseries.startingVertScaleIndex //default vert scale for time series widget
 
        
Activate/Deactivating channels





Changing hardware settings (especially BIAS, SRB 2, and SRB 1) FOUND HERE:


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

    Capital 'S' to Save
    
    Capital 'L' to Load
    
    Created: RGW, May 2018
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------
/*
void keyPressed() {
  //note that the Processing variable "key" is the keypress as an ASCII character
  //note that the Processing variable "keyCode" is the keypress as a JAVA keycode.  This differs from ASCII
  //println("OpenBCI_GUI: keyPressed: key = " + key + ", int(key) = " + int(key) + ", keyCode = " + keyCode);

  if(!controlPanel.isOpen && !isNetworkingTextActive()){ //don't parse the key if the control panel is open
    if ((int(key) >=32) && (int(key) <= 126)) {  //32 through 126 represent all the usual printable ASCII characters
      parseKey(key);
    } else {
      parseKeycode(keyCode);
    }
  }

  //assumes that val is a usual printable ASCII character (ASCII 32 through 126)
  switch (val) {
         //Uppercase B Includes Bias on all channels, lowercase b tells all channels Don't Include Bias
    case 'S':
      /*
      for (int i = 0; i < nchan; i++) { //for every channel
      //update buttons based on channelSettingValues[i][j]
      //BIAS ??
      //String includeAll = "Include"; 
      channelSettingValues[i][3] = '0';
      channelSettingButtons[i][3].setString("Don't Include");
      println ("chan " + i + " bias don't include");
      }
      
      
      final String[] data = { "These strings should save to a new file.", "Yay!" };
      final String   path  = dataPath("FirstSettingsFileEvar.txt");
      
      saveStrings(path, data);
      println("Settings Succesfully Saved!");
      
      break;
    case 'L':

      for (int i = 0; i < nchan; i++) { //for every channel
      //update buttons based on channelSettingValues[i][j]
      //BIAS ??
      //String includeAll = "Include"; 
      channelSettingValues[i][3] = '1';
      channelSettingButtons[i][3].setString("Include");
      println ("chan " + i + " bias include");
      }
      break;
  }
*/