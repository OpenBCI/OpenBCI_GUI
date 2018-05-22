//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    Was going to add these functions to WidgetManager, then just decided to make a new tab
    
          Basics: 
          -- Add a drop down button somewhere near the top that says "Settings" or "Config", expands to show "Load" and "Save" -- no good place to do this!
          -- Better idea already put into place: use Capital 'S' for Save and Capital 'L' for Load
          -- It might be best set up the text file as a JSON Array to accomodate a larger amount of settings and to help with parsing on Load

Requested User Settings to save so far:

wm.currentContainerLayout //default layout
dataprocessing.currentNotch_ind //default notch
w_analogread.startingVertScaleIndex //default vert scale for analog read widget
w_timeseries.startingVertScaleIndex //default vert scale for time series widget
 
        
Activate/Deactivating channels:

deactivateChannel(Channel-1)
activateChannel(Channel-1)

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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                      //
//                            This sketch saves channel settings in the time series widget                              //
//                                                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
final int NCHAN_CYTON = 8;
final int NCHAN_CYTON_DAISY = 16;
final int NCHAN_GANGLION = 4;

//Define number of channels from cyton...first EEG channels, then aux channels
int nchan = NCHAN_CYTON_DAISY; //Normally, 8 or 16.  Choose a smaller number to show fewer on the GUI
int n_aux_ifEnabled = 3;  // this is the accelerometer data CHIP 2014-11-03

//variables from HardwareSettingsController
int numSettingsPerChannel = 6; //each channel has 6 different settings
char[][] channelSettingValues = new char [nchan][numSettingsPerChannel]; // [channel#][Button#-value] ... this will incfluence text of button

String[] channelsActivearray = {"Active", "Not Active"};
String[] gainSettingsarray = { "x1", "x2", "x4", "x6", "x8", "x12", "x24"};
String[] inputTypearray = { "Normal", "Shorted", "BIAS_MEAS", "MVDD", "Temp.", "Test", "BIAS_DRP", "BIAS_DRN"};
String[] BiasIncludearray = {"Don't Include", "Include"};
String[] SRB2settingarray = {"Off", "On"};
String[] SRB1settingarray = {"Off", "On"};

//OpenBCI SD Card setting (if eegDataSource == 0)
int sdSetting = 0; //0 = do not write; 1 = 5 min; 2 = 15 min; 3 = 30 min; etc...
String sdSettingString = "Do not write to SD";


JSONArray SaveSettingsJSONData;
JSONArray LoadSettingsJSONData;

void setup() {

  SaveSettingsJSONData = new JSONArray();
  

  for (int i = 0; i < nchan; i++) {
    
    JSONObject SaveTimeSeriesSettings = new JSONObject();
    
    int ra = (int) random(0,2); //random active/not active channels in time series
    int rg = (int) random(0,7); //random gain setting active channels in time series
    int rit = (int) random(0,8); //random input type in time series
    int rb = (int) random(0,2); //random bias in time series
    int rsrb2 = (int) random(0,2); //random srb2 in time series    
    int rsrb1 = (int) random(0,2); //random srb1 in time series
    
    SaveTimeSeriesSettings.setInt("Channel", (i+1));
    SaveTimeSeriesSettings.setString("Active", channelsActivearray[ra]);
    SaveTimeSeriesSettings.setString("PGA Gain",gainSettingsarray[rg]);
    SaveTimeSeriesSettings.setString("Input Type",inputTypearray[rit]);
    SaveTimeSeriesSettings.setString("Bias",BiasIncludearray[rb]);
    SaveTimeSeriesSettings.setString("SRB2",SRB2settingarray[rsrb2]);
    SaveTimeSeriesSettings.setString("SRB1",SRB2settingarray[rsrb1]);
    
    SaveSettingsJSONData.setJSONObject(i, SaveTimeSeriesSettings);
  }

  saveJSONArray(SaveSettingsJSONData, "data/UserSettingsFile-Dev.json");
  
  LoadSettingsJSONData = loadJSONArray("UserSettingsFile-Dev.json");

  for (int i = 0; i < LoadSettingsJSONData.size(); i++) {
    
    JSONObject LoadTimeSeriesSettings = LoadSettingsJSONData.getJSONObject(i); 

    int Channel = LoadTimeSeriesSettings.getInt("Channel");
    String Active = LoadTimeSeriesSettings.getString("Active");
    String GainSettings = LoadTimeSeriesSettings.getString("PGA Gain");
    String inputType = LoadTimeSeriesSettings.getString("Input Type");
    String BiasSetting = LoadTimeSeriesSettings.getString("Bias");
    String SRB2setting = LoadTimeSeriesSettings.getString("SRB2");
    String SRB1setting = LoadTimeSeriesSettings.getString("SRB1");
    

    println("Ch " + Channel + ", " + Active + ", " + GainSettings + ", " + inputType + ", " + BiasSetting + ", " + SRB2setting + ", " + SRB1setting);
    
    
  }
}
*/

/////////////////////Use channelSettingValues variable to activate these settings once they are loaded from JSON file