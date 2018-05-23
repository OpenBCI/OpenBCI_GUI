//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    Was going to add these functions to WidgetManager, then just decided to make a new tab
    
          Thoughts: 
          -- Add a drop down button somewhere near the top that says "Settings" or "Config", expands to show "Load" and "Save" -- no good place to do this!
          
          -- Better idea already put into place: use Capital 'S' for Save and Capital 'L' for Load -- THIS WORKS
          -- It might be best set up the text file as a JSON Array to accomodate a larger amount of settings and to help with parsing on Load -- THIS WORKS 

Requested User Settings to save so far:

wm.currentContainerLayout //default layout
dataprocessing.currentNotch_ind //default notch
w_analogread.startingVertScaleIndex //default vert scale for analog read widget
w_timeseries.startingVertScaleIndex //default vert scale for time series widget
      
Activate/Deactivating channels:

deactivateChannel(Channel-1)
activateChannel(Channel-1)

Changing hardware settings (especially BIAS, SRB 2, and SRB 1) found below using ChangeSettingValues
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                      //
//                            This sketch saves Time Series & Global User Settings                                      //
//                                                                                                                      //
//                                         Created: RGW - May 2018                                                      //
//    -- Capital 'S' to Save                                                                                            //
//    -- Capital 'L' to Load                                                                                            //
//    -- Functions are called in Interactivty.pde with the rest of the keyboard shortcuts                               //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


JSONArray SaveSettingsJSONData;
JSONArray LoadSettingsJSONData;

String[] channelsActivearray = {"Active", "Not Active"};
String[] gainSettingsarray = { "x1", "x2", "x4", "x6", "x8", "x12", "x24"};
String[] inputTypearray = { "Normal", "Shorted", "BIAS_MEAS", "MVDD", "Temp.", "Test", "BIAS_DRP", "BIAS_DRN"};
String[] BiasIncludearray = {"Don't Include", "Include"};
String[] SRB2settingarray = {"Off", "On"};
String[] SRB1settingarray = {"Off", "On"};

int slnchan = nchan;

int TSactivesetting = 1;
int TSgainsetting;
int TSinputtypesetting;
int TSbiassetting;
int TSsrb2setting;
int TSsrb1setting;

///////////////////////////////  
//      Save GUI Settings    //
///////////////////////////////  
void SaveGUIsettings() {

  //Set up a JSON array
  SaveSettingsJSONData = new JSONArray();
  
 if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON)  {
  //Save all of the channel settings for number of Time Series channels being used
  for (int i = 0; i < slnchan; i++) {
    
    //Make a JSON Object for each of the Time Series Channels
    JSONObject SaveTimeSeriesSettings = new JSONObject();
    
    //Let's set some random variables to show 
    int ra = (int) random(0,2); //random active/not active channels in time series
    int rg = (int) random(0,7); //random gain setting active channels in time series
    int rit = (int) random(0,8); //random input type in time series
    int rb = (int) random(0,2); //random bias in time series
    int rsrb2 = (int) random(0,2); //random srb2 in time series    
    int rsrb1 = (int) random(0,2); //random srb1 in time series
       
    for (int j = 0; j < numSettingsPerChannel; j++) {
      switch(j) {  //what setting are we looking at
        case 0: //on/off ??
          if (channelSettingValues[i][j] == '0')  TSactivesetting = 0;
          if (channelSettingValues[i][j] == '1')  TSactivesetting = 1;
          break;
        case 1: //GAIN ??
          if (channelSettingValues[i][j] == '0') TSgainsetting = 0;
          if (channelSettingValues[i][j] == '1') TSgainsetting = 1;
          if (channelSettingValues[i][j] == '2') TSgainsetting = 2;
          if (channelSettingValues[i][j] == '3') TSgainsetting = 3;
          if (channelSettingValues[i][j] == '4') TSgainsetting = 4;
          if (channelSettingValues[i][j] == '5') TSgainsetting = 5;
          if (channelSettingValues[i][j] == '6') TSgainsetting = 6;
          break;
        case 2: //input type ??
          if (channelSettingValues[i][j] == '0') TSinputtypesetting = 0;
          if (channelSettingValues[i][j] == '1') TSinputtypesetting = 1;
          if (channelSettingValues[i][j] == '2') TSinputtypesetting = 2;
          if (channelSettingValues[i][j] == '3') TSinputtypesetting = 3;
          if (channelSettingValues[i][j] == '4') TSinputtypesetting = 4;
          if (channelSettingValues[i][j] == '5') TSinputtypesetting = 5;
          if (channelSettingValues[i][j] == '6') TSinputtypesetting = 6;
          if (channelSettingValues[i][j] == '7') TSinputtypesetting = 7;
          break;
        case 3: //BIAS ??
          if (channelSettingValues[i][j] == '0') TSbiassetting = 0;
          if (channelSettingValues[i][j] == '1') TSbiassetting = 1;
          break;
        case 4: // SRB2 ??
          if (channelSettingValues[i][j] == '0') TSsrb2setting = 0;
          if (channelSettingValues[i][j] == '1') TSsrb2setting = 1;
          break;
        case 5: // SRB1 ??
          if (channelSettingValues[i][j] == '0') TSsrb1setting = 0;
          if (channelSettingValues[i][j] == '1') TSsrb1setting = 1;
          break;
        }
      }  
  
      SaveTimeSeriesSettings.setInt("Channel Number", (i+1));
      SaveTimeSeriesSettings.setInt("Active", TSactivesetting);
      SaveTimeSeriesSettings.setInt("PGA Gain", TSgainsetting);
      SaveTimeSeriesSettings.setInt("Input Type", TSinputtypesetting);
      SaveTimeSeriesSettings.setInt("Bias", TSbiassetting);
      SaveTimeSeriesSettings.setInt("SRB2", TSsrb2setting);
      SaveTimeSeriesSettings.setInt("SRB1", TSsrb1setting);
      SaveSettingsJSONData.setJSONObject(i, SaveTimeSeriesSettings);
    }
  }
    
  //Make a second JSON object within our JSONArray to store Global settings for the GUI
  JSONObject SaveGlobalSettings = new JSONObject();
  
  SaveGlobalSettings.setInt("Current Layout", currentLayout-1);
  SaveGlobalSettings.setInt("Notch", dataProcessing.currentNotch_ind);
  SaveGlobalSettings.setInt("Time Series Vert Scale", TimeSeriesStartingVertScaleIndex);
  SaveGlobalSettings.setInt("Analog Read Vert Scale", AnalogReadStartingVertScaleIndex);
  SaveGlobalSettings.setInt("Analog Read Horiz Scale", AnalogReadStartingHorizontalScaleIndex);
  SaveSettingsJSONData.setJSONObject(slnchan, SaveGlobalSettings);
  
  //Let's save the JSON array to a file!
  saveJSONArray(SaveSettingsJSONData, "data/UserSettingsFile-Dev.json");
}  
  
///////////////////////////////  
//      Load GUI Settings    //
///////////////////////////////  
void LoadGUIsettings() { 
  //Load all saved User Settings from a JSON file
  LoadSettingsJSONData = loadJSONArray("UserSettingsFile-Dev.json");

  //We want to read the whole JSON Array!
  for (int i = 0; i < LoadSettingsJSONData.size(); i++) {
    
    //Make a JSON object, we only need one to load data, and call it LoadAllSettings
    JSONObject LoadAllSettings = LoadSettingsJSONData.getJSONObject(i); 
    
   if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON)  {
      //parse the channel settings first for only the number of channels being used
      if (i < slnchan) {
        int Channel = LoadAllSettings.getInt("Channel Number"); //when using with channelSettingsValues, will need to subtract 1
        int Active = LoadAllSettings.getInt("Active");
        int GainSettings = LoadAllSettings.getInt("PGA Gain");
        int inputType = LoadAllSettings.getInt("Input Type");
        int BiasSetting = LoadAllSettings.getInt("Bias");
        int SRB2setting = LoadAllSettings.getInt("SRB2");
        int SRB1setting = LoadAllSettings.getInt("SRB1");
        println("Ch " + Channel + ", " + 
          channelsActivearray[Active] + ", " + 
          gainSettingsarray[GainSettings] + ", " + 
          inputTypearray[inputType] + ", " + 
          BiasIncludearray[BiasSetting] + ", " + 
          SRB2settingarray[SRB2setting] + ", " + 
          SRB1settingarray[SRB1setting]);
      }
      
      //parse the global settings that appear after the channel settings 
      if (i >= slnchan) {
        int loadlayoutsetting = LoadAllSettings.getInt("Current Layout");
        int loadnotchsetting = LoadAllSettings.getInt("Notch");
        int loadTimeSeriesVertScale = LoadAllSettings.getInt("Time Series Vert Scale");
        int loadAnalogReadVertScale = LoadAllSettings.getInt("Analog Read Vert Scale");
        int loadAnalogReadHorizScale = LoadAllSettings.getInt("Analog Read Horiz Scale");
        
        final String[] LoadedGlobalSettings = {
          "Using Layout Number: " + loadlayoutsetting, 
          "Default Notch: " + loadnotchsetting, //default notch
          "Default Time Series Vert Scale: " + loadTimeSeriesVertScale,
          "Analog Series Vert Scale: " + loadAnalogReadVertScale,
          "Analog Series Horiz Scale: " + loadAnalogReadHorizScale,
          };
          
        printArray(LoadedGlobalSettings);
      }   
    }
  }  
}


//Use channelSettingValues variable to activate these settings once they are loaded from JSON file
/*
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
*/

/////////////////////Use channelSettingValues variable to activate these settings once they are loaded from JSON file