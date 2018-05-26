//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    Was going to add these functions to WidgetManager, then just decided to make a new tab
    
          Thoughts: 
          -- Add a drop down button somewhere near the top that says "Settings" or "Config", expands to show "Load" and "Save" -- no good place to do this, currently
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

FFT info is at the bottom for working purposes currently. See commented out section for help with applying FFT settings once loaded.
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

//these string arrays are used to print the status of each channel in the console when loading settings
String[] channelsActivearray = {"Active", "Not Active"};
String[] gainSettingsarray = { "x1", "x2", "x4", "x6", "x8", "x12", "x24"};
String[] inputTypearray = { "Normal", "Shorted", "BIAS_MEAS", "MVDD", "Temp.", "Test", "BIAS_DRP", "BIAS_DRN"};
String[] BiasIncludearray = {"Don't Include", "Include"};
String[] SRB2settingarray = {"Off", "On"};
String[] SRB1settingarray = {"Off", "On"};



//Save Time Series settings variables
int TSactivesetting = 1;
int TSgainsetting;
int TSinputtypesetting;
int TSbiassetting;
int TSsrb2setting;
int TSsrb1setting;


//Load global settings variables
int loadLayoutsetting = 4;   
int loadNotchsetting;
int loadTimeSeriesVertScale;
int loadAnalogReadVertScale;
int loadAnalogReadHorizScale;


//used only in this tab to count the number of channels being used while saving/loading, this gets updated in updateToNChan whenever the number of channels being used changes
int slnchan; 

/* moved to first tab to make global accessible
//FFT plot settings
int FFTmaxfrqsave;
int FFTmaxfrqload;
int FFTmaxuVsave;
int FFTmaxuVload;
int FFTloglinsave;
int FFTloglinload;
int FFTsmoothingsave;
int FFTsmoothingload;
int FFTfiltersave;
int FFTfilterload;
*/

///////////////////////////////  
//      Save GUI Settings    //
///////////////////////////////  
void SaveGUIsettings() {
  
  //Set up a JSON array
  SaveSettingsJSONData = new JSONArray();
  
  ///////Case for Live Data Modes
  if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON)  {
    //Save all of the channel settings for number of Time Series channels being used
    for (int i = 0; i < slnchan; i++) {
      
      //Make a JSON Object for each of the Time Series Channels
      JSONObject SaveTimeSeriesSettings = new JSONObject();
      
      //Let's set some random variables to test for fun
      //int ra = (int) random(0,2); //random active/not active channels in time series
      //int rg = (int) random(0,7); //random gain setting active channels in time series
      //int rit = (int) random(0,8); //random input type in time series
      //int rb = (int) random(0,2); //random bias in time series
      //int rsrb2 = (int) random(0,2); //random srb2 in time series    
      //int rsrb1 = (int) random(0,2); //random srb1 in time series
        
      for (int j = 0; j < numSettingsPerChannel; j++) {
        switch(j) {  //what setting are we looking at
          case 0: //on/off
            //if (channelSettingValues[i][j] == '0')  TSactivesetting = 0;
            //if (channelSettingValues[i][j] == '1')  TSactivesetting = 1;
            TSactivesetting = channelSettingValues[i][j];
            break;
          case 1: //GAIN
            TSgainsetting = channelSettingValues[i][j];
            break;
          case 2: //input type
            TSinputtypesetting = channelSettingValues[i][j];
            break;
          case 3: //BIAS
            TSbiassetting = channelSettingValues[i][j];
            break;
          case 4: // SRB2
            TSsrb2setting = channelSettingValues[i][j];
            break;
          case 5: // SRB1
            TSsrb1setting = channelSettingValues[i][j];
            break;
          }
      }  
      SaveTimeSeriesSettings.setInt("Channel_Number", (i+1));
      SaveTimeSeriesSettings.setInt("Active", TSactivesetting);
      SaveTimeSeriesSettings.setInt("PGA Gain", TSgainsetting);
      SaveTimeSeriesSettings.setInt("Input Type", TSinputtypesetting);
      SaveTimeSeriesSettings.setInt("Bias", TSbiassetting);
      SaveTimeSeriesSettings.setInt("SRB2", TSsrb2setting);
      SaveTimeSeriesSettings.setInt("SRB1", TSsrb1setting);
      SaveSettingsJSONData.setJSONObject(i, SaveTimeSeriesSettings);
    }
  //Make a second JSON object within our JSONArray to store Global settings for the GUI
  JSONObject SaveGlobalSettings = new JSONObject();
  
  SaveGlobalSettings.setInt("Current Layout", currentLayout);
  SaveGlobalSettings.setInt("Notch", dataProcessing.currentNotch_ind);
  SaveGlobalSettings.setInt("Time Series Vert Scale", TimeSeriesStartingVertScaleIndex);
  SaveGlobalSettings.setInt("Analog Read Vert Scale", AnalogReadStartingVertScaleIndex);
  SaveGlobalSettings.setInt("Analog Read Horiz Scale", AnalogReadStartingHorizontalScaleIndex);
  ////////////////////////////////////////////////////////////////////////////////
  //ADD more global settings below this line in the same format as above//////////


  SaveSettingsJSONData.setJSONObject(slnchan, SaveGlobalSettings);

  //Let's save the JSON array to a file!
  saveJSONArray(SaveSettingsJSONData, "data/UserSettingsFile-Dev.json");
  }
  
  ////////////Case for Playback and Synthetic Data Modes
  if(eegDataSource == DATASOURCE_PLAYBACKFILE || eegDataSource == DATASOURCE_SYNTHETIC) {
    for (int i = 0; i < slnchan; i++) {
      
      //Make a JSON Object for each of the Time Series Channels
      JSONObject SaveTimeSeriesSettings = new JSONObject();
     
      for (int j = 0; j < 1; j++) {
        switch(j) { 
          case 0: //Just save what channels are active
            if (channelSettingValues[i][j] == '0')  TSactivesetting = 0;
            if (channelSettingValues[i][j] == '1')  TSactivesetting = 1;
            break;
          }
      }  
      SaveTimeSeriesSettings.setInt("Channel_Number", (i+1));
      SaveTimeSeriesSettings.setInt("Active", TSactivesetting);
      SaveSettingsJSONData.setJSONObject(i, SaveTimeSeriesSettings);
    }    
    
    ////////////////////////////////////////////////Make a JSON object within our JSONArray to store Global settings for the GUI
    JSONObject SaveGlobalSettings = new JSONObject();
    SaveGlobalSettings.setInt("Current Layout", currentLayout);
    SaveGlobalSettings.setInt("Notch", dataProcessing.currentNotch_ind);
    SaveGlobalSettings.setInt("Time Series Vert Scale", TimeSeriesStartingVertScaleIndex);
    SaveGlobalSettings.setInt("Analog Read Vert Scale", AnalogReadStartingVertScaleIndex);
    SaveGlobalSettings.setInt("Analog Read Horiz Scale", AnalogReadStartingHorizontalScaleIndex);
    SaveSettingsJSONData.setJSONObject(slnchan, SaveGlobalSettings);
  
    ///////////////////////////////////////////////Setup new JSON object to save FFT settings
    JSONObject SaveFFTSettings = new JSONObject();
    //Save FFT Max Freq Setting
    if (w_fft.xLim == 20) FFTmaxfrqsave = 0;
    if (w_fft.xLim == 40) FFTmaxfrqsave = 1;  
    if (w_fft.xLim == 60) FFTmaxfrqsave = 2;
    if (w_fft.xLim == 100) FFTmaxfrqsave = 3;    
    if (w_fft.xLim == 120) FFTmaxfrqsave = 4;
    if (w_fft.xLim == 250) FFTmaxfrqsave = 5;  
    if (w_fft.xLim == 500) FFTmaxfrqsave = 6;
    if (w_fft.xLim == 800) FFTmaxfrqsave = 7;  
    SaveFFTSettings.setInt("FFT Max Freq", FFTmaxfrqsave);
    //Save FFT max uV Setting
    if (w_fft.yLim == 10) FFTmaxuVsave = 0;
    if (w_fft.yLim == 50) FFTmaxuVsave = 1;  
    if (w_fft.yLim == 100) FFTmaxuVsave = 2;
    if (w_fft.yLim == 1000) FFTmaxuVsave = 3;    
    SaveFFTSettings.setInt("FFT Max uV", w_fft.yLim);
    //Save FFT LogLin Setting
    SaveFFTSettings.setInt("LogLin", FFTloglinsave);
    //Save FFT Smoothing Setting
    SaveFFTSettings.setInt("FFT Smoothing", smoothFac_ind);
    //Save FFT Filter Setting
    if (isFFTFiltered == true)  FFTfiltersave = 1;
    if (isFFTFiltered == false)  FFTfiltersave = 0;  
    SaveFFTSettings.setInt("FFT Filter",  FFTfiltersave);
    //Set the FFT JSON Object
    SaveSettingsJSONData.setJSONObject(slnchan+1, SaveFFTSettings);
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////ADD more global settings below this line in the same format as above//////////
    
    //Let's save the JSON array to a file!
    saveJSONArray(SaveSettingsJSONData, "data/UserSettingsFile-Dev.json");
  }
}  //End of Save GUI Settings function
  
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
    
    
   //Case for loading settings in Live Data move
   if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON)  { //Need help adding a case for DATASOURCE_SYNTHETIC to skip writing time series settings, without writing Null to the JSON array. Also need to add a case for Playback settings.
      
      //parse the channel settings first for only the number of channels being used
      if (i < slnchan) {    
        int Channel = LoadAllSettings.getInt("Channel_Number") - 1; //when using with channelSettingsValues, will need to subtract 1
        int Active = LoadAllSettings.getInt("Active");
        int GainSettings = LoadAllSettings.getInt("PGA Gain");
        int inputType = LoadAllSettings.getInt("Input Type");
        int BiasSetting = LoadAllSettings.getInt("Bias");
        int SRB2Setting = LoadAllSettings.getInt("SRB2");
        int SRB1Setting = LoadAllSettings.getInt("SRB1");
        println("Ch " + Channel + ", " + 
          channelsActivearray[Active] + ", " + 
          gainSettingsarray[GainSettings] + ", " + 
          inputTypearray[inputType] + ", " + 
          BiasIncludearray[BiasSetting] + ", " + 
          SRB2settingarray[SRB2Setting] + ", " + 
          SRB1settingarray[SRB1Setting]);
          
        //Use channelSettingValues variable to activate these settings once they are loaded from JSON file 
        if (Active == 0) {channelSettingValues[i][0] = '0'; activateChannel(Channel);}// power down == false, set color to vibrant
        if (Active == 1) {channelSettingValues[i][0] = '1'; deactivateChannel(Channel);} // power down == true, set color to dark gray, indicating power down
        
        if (GainSettings == 0) channelSettingValues[i][1] = 0;
        if (GainSettings == 1) channelSettingValues[i][1] = 1;
        if (GainSettings == 2) channelSettingValues[i][1] = 2;
        if (GainSettings == 3) channelSettingValues[i][1] = 3;        
        if (GainSettings == 4) channelSettingValues[i][1] = 4;
        if (GainSettings == 5) channelSettingValues[i][1] = 5;
        if (GainSettings == 6) channelSettingValues[i][1] = 6;
        
        if (inputType == 0) channelSettingValues[i][2] = 0;
        if (inputType == 1) channelSettingValues[i][2] = 1;
        if (inputType == 2) channelSettingValues[i][2] = 2;
        if (inputType == 3) channelSettingValues[i][2] = 3;        
        if (inputType == 4) channelSettingValues[i][2] = 4;
        if (inputType == 5) channelSettingValues[i][2] = 5;        
        if (inputType == 6) channelSettingValues[i][2] = 6;
        if (inputType == 7) channelSettingValues[i][2] = 7;
        
        if (BiasSetting == 0) channelSettingValues[i][3] = 0;
        if (BiasSetting == 1) channelSettingValues[i][3] = 1;
        
        if (SRB2Setting == 0) channelSettingValues[i][4] = 0;
        if (SRB2Setting == 1) channelSettingValues[i][4] = 1;

        if (SRB1Setting == 0) channelSettingValues[i][5] = 0;
        if (SRB1Setting == 1) channelSettingValues[i][5] = 1;        
        }  
      }
      
      //Case for loading settings when in Synthetic or Playback data modes
      if(eegDataSource == DATASOURCE_SYNTHETIC || eegDataSource == DATASOURCE_PLAYBACKFILE) {
        //parse the channel settings first for only the number of channels being used
        if (i < slnchan) {   
          int Channel = LoadAllSettings.getInt("Channel_Number") - 1; //when using with channelSettingsValues, will need to subtract 1
          int Active = LoadAllSettings.getInt("Active");
          println("Ch " + Channel + ", " + channelsActivearray[Active]);
          //Use channelSettingValues variable to activate these settings once they are loaded from JSON file 
          if (Active == 0) {channelSettingValues[i][0] = '0'; activateChannel(Channel);}// power down == false, set color to vibrant
          if (Active == 1) {channelSettingValues[i][0] = '1'; deactivateChannel(Channel);} // power down == true, set color to dark gray, indicating power down         
        }
      }
      
      //parse the global settings that appear after the channel settings 
      if (i == slnchan) {
        loadLayoutsetting = LoadAllSettings.getInt("Current Layout");
        loadNotchsetting = LoadAllSettings.getInt("Notch");
        loadTimeSeriesVertScale = LoadAllSettings.getInt("Time Series Vert Scale");
        loadAnalogReadVertScale = LoadAllSettings.getInt("Analog Read Vert Scale");
        loadAnalogReadHorizScale = LoadAllSettings.getInt("Analog Read Horiz Scale");
        
        final String[] LoadedGlobalSettings = {
          "Using Layout Number: " + loadLayoutsetting, 
          "Default Notch: " + loadNotchsetting, //default notch
          "Default Time Series Vert Scale: " + loadTimeSeriesVertScale,
          "Analog Series Vert Scale: " + loadAnalogReadVertScale,
          "Analog Series Horiz Scale: " + loadAnalogReadHorizScale,
          };
        //Print the global settings that have been loaded to the console  
        printArray(LoadedGlobalSettings);
      }
      ////////working here 
      //parse the FFT settings that appear after the channel settings 
      if (i > slnchan) {
        FFTmaxfrqload = LoadAllSettings.getInt("FFT Max Freq");
        FFTmaxuVload = LoadAllSettings.getInt("FFT Max uV");
        
        final String[] LoadedFFTSettings = {
          "FFT Max Frequency: " + FFTmaxfrqload, 
          "FFT Max uV: " + FFTmaxuVload, 
          };
        //Print the global settings that have been loaded to the console  
        printArray(LoadedFFTSettings);
      }      
    }
  
  //Apply the loaded settings to the GUI
  println("Loading Settings...");
  //Apply layout
  currentLayout = loadLayoutsetting;
  wm.setNewContainerLayout(currentLayout-1);
  println("Layout Loaded!");
  //Apply notch
  loadNotchsetting = dataProcessing.currentNotch_ind;
  println("Notch Loaded!");
  //Apply vert/horz scales
  TimeSeriesStartingVertScaleIndex  = loadTimeSeriesVertScale;
  AnalogReadStartingVertScaleIndex = loadAnalogReadVertScale;
  AnalogReadStartingHorizontalScaleIndex = loadAnalogReadHorizScale;
  println("Vert/Horiz Scales Loaded!");  
  
  //////////////WORK HERE 
  //Apply FFT settings
  MaxFreq(FFTmaxfrqload);

}

/* USE THIS TO HELP APPLY FFT SETTINGS
    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    addDropdown("MaxFreq", "Max Freq", Arrays.asList("20 Hz", "40 Hz", "60 Hz", "100 Hz", "120 Hz", "250 Hz", "500 Hz", "800 Hz"), 2);
    addDropdown("VertScale", "Max uV", Arrays.asList("10 uV", "50 uV", "100 uV", "1000 uV"), 2);
    addDropdown("LogLin", "Log/Lin", Arrays.asList("Log", "Linear"), 0);
    addDropdown("Smoothing", "Smooth", Arrays.asList("0.0", "0.5", "0.75", "0.9", "0.95", "0.98"), smoothFac_ind); //smoothFac_ind is a global variable at the top of W_headPlot.pde
    addDropdown("UnfiltFilt", "Filters?", Arrays.asList("Filtered", "Unfilt."), 0);
    
      int[] xLimOptions = {20, 40, 60, 100, 120, 250, 500, 800};
  int[] yLimOptions = {10, 50, 100, 1000};
  
//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
//triggered when there is an event in the MaxFreq. Dropdown
void MaxFreq(int n) {
  // request the selected item based on index n
  w_fft.fft_plot.setXLim(0.1, w_fft.xLimOptions[n]); //update the xLim of the FFT_Plot
  closeAllDropdowns();
}

//triggered when there is an event in the VertScale Dropdown
void VertScale(int n) {

  w_fft.fft_plot.setYLim(0.1, w_fft.yLimOptions[n]); //update the yLim of the FFT_Plot
  closeAllDropdowns();
}

//triggered when there is an event in the LogLin Dropdown
void LogLin(int n) {
  if (n==0) {
    w_fft.fft_plot.setLogScale("y");
  } else {
    w_fft.fft_plot.setLogScale("");
  }
  closeAllDropdowns();
}

//triggered when there is an event in the Smoothing Dropdown
void Smoothing(int n) {
  smoothFac_ind = n;
  closeAllDropdowns();
}

//triggered when there is an event in the UnfiltFilt Dropdown
void UnfiltFilt(int n) {
  if (n==0) {
    //have FFT use filtered data -- default
    isFFTFiltered = true;
  } else {
    //have FFT use unfiltered data
    isFFTFiltered = false;
  }
  closeAllDropdowns();
}

*/