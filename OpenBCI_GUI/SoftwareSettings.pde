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

Loading and applying settings contained in dropdown menus are at the bottomw in LoadApplyWidgetDropdowns()
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////S
/*
                       This sketch saves and loads the following User Settings:    
                       -- All Time Series widget settings
                       -- All FFT widget settings
                       -- Default Layout, Notch, 
                       

                                         Created: RGW - May 2018                                                      
    -- Capital 'S' to Save                                                                                            
    -- Capital 'L' to Load                                                                                           
    -- Functions are called in Interactivty.pde with the rest of the keyboard shortcuts                               
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



JSONArray SaveSettingsJSONData;
JSONArray LoadSettingsJSONData;

// Used to set text in Time Series dropdown settings
String[] TSvertscalearray = {"Auto", "50 uV", "100 uV", "200 uV", "400 uV", "1000 uV", "10000 uV"};
String[] TShorizscalearray = {"1 sec", "3 sec", "5 sec", "7 sec"};

//Used to print the status of each channel in the console when loading settings
String[] channelsActivearray = {"Active", "Not Active"};
String[] gainSettingsarray = { "x1", "x2", "x4", "x6", "x8", "x12", "x24"};
String[] inputTypearray = { "Normal", "Shorted", "BIAS_MEAS", "MVDD", "Temp.", "Test", "BIAS_DRP", "BIAS_DRN"};
String[] BiasIncludearray = {"Don't Include", "Include"};
String[] SRB2settingarray = {"Off", "On"};
String[] SRB1settingarray = {"Off", "On"};

//Used to set text in dropdown menus when loading FFT settings
String[] FFTmaxfrqarray = {"20 Hz", "40 Hz", "60 Hz", "100 Hz", "120 Hz", "250 Hz", "500 Hz", "800 Hz"};
String[] FFTvertscalearray = {"10 uV", "50 uV", "100 uV", "1000 uV"};
String[] FFTloglinarray = {"Log", "Linear"};
String[] FFTsmoothingarray = {"0.0", "0.5", "0.75", "0.9", "0.95", "0.98"};
String[] FFTfilterarray = {"Filtered", "Unfilt."};

//Used to set text in dropdown menus when loading Networking settings
String[] NWdatatypesarray = {"None", "TimesSeries", "FFT", "EMG", "BandPower", "Focus", "Pulse", "Widget"};

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
int loadTimeSeriesHorizScale;
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
            if (channelSettingValues[i][j] == '0')  TSactivesetting = 0;
            if (channelSettingValues[i][j] == '1')  TSactivesetting = 1;
            // TSactivesetting = int(channelSettingValues[i][j]));  // For some reason this approach doesn't work, still returns 48 and 49 '0' and '1'

            break;
          case 1: //GAIN
            //TSgainsetting = int(channelSettingValues[i][j]);
            if (channelSettingValues[i][j] == '0') TSgainsetting = 0;
            if (channelSettingValues[i][j] == '1') TSgainsetting = 1;
            if (channelSettingValues[i][j] == '2') TSgainsetting = 2;
            if (channelSettingValues[i][j] == '3') TSgainsetting = 3;
            if (channelSettingValues[i][j] == '4') TSgainsetting = 4;
            if (channelSettingValues[i][j] == '5') TSgainsetting = 5;
            if (channelSettingValues[i][j] == '6') TSgainsetting = 6;            
            break;
          case 2: //input type
            //TSinputtypesetting = int(channelSettingValues[i][j]);
            if (channelSettingValues[i][j] == '0') TSinputtypesetting = 0;
            if (channelSettingValues[i][j] == '1') TSinputtypesetting = 1;
            if (channelSettingValues[i][j] == '2') TSinputtypesetting = 2;
            if (channelSettingValues[i][j] == '3') TSinputtypesetting = 3;
            if (channelSettingValues[i][j] == '4') TSinputtypesetting = 4;
            if (channelSettingValues[i][j] == '5') TSinputtypesetting = 5;
            if (channelSettingValues[i][j] == '6') TSinputtypesetting = 6;
            if (channelSettingValues[i][j] == '7') TSinputtypesetting = 7;
            break;
          case 3: //BIAS
            //TSbiassetting = int(channelSettingValues[i][j]);
            if (channelSettingValues[i][j] == '0') TSbiassetting = 0;
            if (channelSettingValues[i][j] == '1') TSbiassetting = 1;     
            break;
          case 4: // SRB2
            //TSsrb2setting = int(channelSettingValues[i][j]);
            if (channelSettingValues[i][j] == '0') TSsrb2setting = 0;
            if (channelSettingValues[i][j] == '1') TSsrb2setting = 1;
            break;
          case 5: // SRB1
            //TSsrb1setting = channelSettingValues[i][j];
            if (channelSettingValues[i][j] == '0') TSsrb1setting = 0;
            if (channelSettingValues[i][j] == '1') TSsrb1setting = 1;
            break;
          }
      }  
      //Store all channel settings in Time Series JSON object, one channel at a time
      SaveTimeSeriesSettings.setInt("Channel_Number", (i+1));
      SaveTimeSeriesSettings.setInt("Active", TSactivesetting);
      SaveTimeSeriesSettings.setInt("PGA Gain", int(TSgainsetting));
      SaveTimeSeriesSettings.setInt("Input Type", TSinputtypesetting);
      SaveTimeSeriesSettings.setInt("Bias", TSbiassetting);
      SaveTimeSeriesSettings.setInt("SRB2", TSsrb2setting);
      SaveTimeSeriesSettings.setInt("SRB1", TSsrb1setting);
      SaveSettingsJSONData.setJSONObject(i, SaveTimeSeriesSettings);
    }
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //              Case for saving settings when in Synthetic or Playback data modes                          //
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
  }    
  //Make a second JSON object within our JSONArray to store Global settings for the GUI
  JSONObject SaveGlobalSettings = new JSONObject();
  
  SaveGlobalSettings.setInt("Current Layout", currentLayout);
  SaveGlobalSettings.setInt("Notch", dataProcessing.currentNotch_ind);
  SaveGlobalSettings.setInt("Time Series Vert Scale", TSvertscalesave);
  SaveGlobalSettings.setInt("Time Series Horiz Scale", TShorizscalesave);
  SaveGlobalSettings.setInt("Analog Read Vert Scale", AnalogReadStartingVertScaleIndex);
  SaveGlobalSettings.setInt("Analog Read Horiz Scale", AnalogReadStartingHorizontalScaleIndex);
  SaveSettingsJSONData.setJSONObject(slnchan, SaveGlobalSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save FFT settings
  JSONObject SaveFFTSettings = new JSONObject();

  //Save FFT Max Freq Setting. The max frq variable is updated every time the user selects a dropdown in the FFT widget
  SaveFFTSettings.setInt("FFT Max Freq", FFTmaxfrqsave);
  //Save FFT max uV Setting. The max uV variable is updated also when user selects dropdown in the FFT widget
  SaveFFTSettings.setInt("FFT Max uV", FFTmaxuVsave);
  //Save FFT LogLin Setting. Same thing happens for LogLin
  SaveFFTSettings.setInt("FFT LogLin", FFTloglinsave);
  //Save FFT Smoothing Setting
  SaveFFTSettings.setInt("FFT Smoothing", smoothFac_ind);
  //Save FFT Filter Setting
  if (isFFTFiltered == true)  FFTfiltersave = 0;
  if (isFFTFiltered == false)  FFTfiltersave = 1;  
  SaveFFTSettings.setInt("FFT Filter",  FFTfiltersave);
  //Set the FFT JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+1, SaveFFTSettings); //next object will be set to slnchan+2, etc.  
  
  ///////////////////////////////////////////////Setup new JSON object to save Networking settings
  JSONObject SaveNetworkingSettings = new JSONObject();
  
  //***Save User networking protocol mode
  
  //Save Data Types
  SaveNetworkingSettings.setInt("Data Type 1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));
  SaveNetworkingSettings.setInt("Data Type 2", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").getValue()));
  SaveNetworkingSettings.setInt("Data Type 3", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").getValue()));
  SaveNetworkingSettings.setInt("Data Type 4", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").getValue()));
  
  //Set Networking Settings JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+2, SaveNetworkingSettings);  

  ////////////////////////////////////////////////////////////////////////////////
  ///ADD more global settings below this line in the same format as above/////////

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
    
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //                        Case for loading settings in Live Data move                                       //
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
        
        
        //Hopefully This can be shortened into somthing more efficient like with above, there is a datatype conversion involved. Simple if-then works for now.
        //channelSettingValues[i][1] = char(GainSettings);
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
      
      //////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //              Case for loading settings when in Synthetic or Playback data modes                          //
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
        loadTimeSeriesHorizScale = LoadAllSettings.getInt("Time Series Horiz Scale");
        loadAnalogReadVertScale = LoadAllSettings.getInt("Analog Read Vert Scale");
        loadAnalogReadHorizScale = LoadAllSettings.getInt("Analog Read Horiz Scale");
        //Load more global settings after this line, if needed
        
        //Create a string array to print global settings to console
        final String[] LoadedGlobalSettings = {
          "Using Layout Number: " + loadLayoutsetting, 
          "Default Notch: " + loadNotchsetting, //default notch
          "TS Vert Scale: " + loadTimeSeriesVertScale,
          "TS Horiz Scale: " + loadTimeSeriesHorizScale,
          "Analog Vert Scale: " + loadAnalogReadVertScale,
          "Analog Horiz Scale: " + loadAnalogReadHorizScale,
          //Add new global settings after this line to print to console
          };
        //Print the global settings that have been loaded to the console  
        printArray(LoadedGlobalSettings);
      }
      //parse the FFT settings that appear after the channel settings 
      if (i == slnchan + 1) {
        FFTmaxfrqload = LoadAllSettings.getInt("FFT Max Freq");
        FFTmaxuVload = LoadAllSettings.getInt("FFT Max uV");
        FFTloglinload = LoadAllSettings.getInt("FFT LogLin");
        FFTsmoothingload = LoadAllSettings.getInt("FFT Smoothing");
        FFTfilterload = LoadAllSettings.getInt("FFT Filter");
        
        //Create a string array to print to console
        final String[] LoadedFFTSettings = {
          "FFT_Max Frequency: " + FFTmaxfrqload, 
          "FFT_Max uV: " + FFTmaxuVload,
          "FFT_Log/Lin: " + FFTloglinload,
          "FFT_Smoothing: " + FFTsmoothingload,
          "FFT_Filter: " + FFTfilterload,
          };
        //Print the global settings that have been loaded to the console  
        printArray(LoadedFFTSettings);
      }
      
      /////////////////////////////////////////////////////////////
      //    Load more widget settings below this line as above   //
      if (i == slnchan + 2) {
        nwdatatype1 = LoadAllSettings.getInt("Data Type 1");
        nwdatatype2 = LoadAllSettings.getInt("Data Type 2");
        nwdatatype3 = LoadAllSettings.getInt("Data Type 3");        
        nwdatatype4 = LoadAllSettings.getInt("Data Type 4");        
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
  
  //follow example of applying time series dropdowns to this
  AnalogReadStartingVertScaleIndex = loadAnalogReadVertScale;
  AnalogReadStartingHorizontalScaleIndex = loadAnalogReadHorizScale;
  //println("Vert/Horiz Scales Loaded!");  
   
  //Load and apply all of the settings that are in dropdown menus. It's a bit much, so it has it's own function at the bottom of this tab.
  LoadApplyWidgetDropdowns(); 

}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void LoadApplyWidgetDropdowns() {
  
  ////////Apply Time Series widget settings
  VertScale_TS(loadTimeSeriesVertScale);// changes backend
  w_timeSeries.cp5_widget.getController("VertScale_TS") //Reference the dropdown from the appropriate widget
    .getCaptionLabel() //the caption label is the text object in the primary bar
    .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
    .setText(TSvertscalearray[loadTimeSeriesVertScale]) //This updates the text of the dropdown!
    .setFont(h5)
    .setSize(12)
    .getStyle() //need to grab style before affecting the paddingTop
    .setPaddingTop(4)
    ;
  Duration(loadTimeSeriesHorizScale);
  w_timeSeries.cp5_widget.getController("Duration") //Reference the dropdown from the appropriate widget
    .getCaptionLabel() //the caption label is the text object in the primary bar
    .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
    .setText(TShorizscalearray[loadTimeSeriesHorizScale]) //This updates the text of the dropdown!
    .setFont(h5)
    .setSize(12)
    .getStyle() //need to grab style before affecting the paddingTop
    .setPaddingTop(4)
    ;  
    
  //////Apply FFT settings
  MaxFreq(FFTmaxfrqload); //This changes the backend
    w_fft.cp5_widget.getController("MaxFreq") //Reference the dropdown from the appropriate widget
    .getCaptionLabel() //the caption label is the text object in the primary bar
    .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
    .setText(FFTmaxfrqarray[FFTmaxfrqload]) //This updates the text of the dropdown!
    .setFont(h5)
    .setSize(12)
    .getStyle() //need to grab style before affecting the paddingTop
    .setPaddingTop(4)
    ;
  VertScale(FFTmaxuVload);
    w_fft.cp5_widget.getController("VertScale") //Reference the dropdown from the appropriate widget
    .getCaptionLabel() //the caption label is the text object in the primary bar
    .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
    .setText(FFTvertscalearray[FFTmaxuVload]) //This updates the text of the dropdown!
    .setFont(h5)
    .setSize(12)
    .getStyle() //need to grab style before affecting the paddingTop
    .setPaddingTop(4)
    ;  
  LogLin(FFTloglinload);
     w_fft.cp5_widget.getController("LogLin") //Reference the dropdown from the appropriate widget
    .getCaptionLabel() //the caption label is the text object in the primary bar
    .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
    .setText(FFTloglinarray[FFTloglinload]) //This updates the text of the dropdown!
    .setFont(h5)
    .setSize(12)
    .getStyle() //need to grab style before affecting the paddingTop
    .setPaddingTop(4)
    ;   
  Smoothing(FFTsmoothingload);
     w_fft.cp5_widget.getController("Smoothing") //Reference the dropdown from the appropriate widget
    .getCaptionLabel() //the caption label is the text object in the primary bar
    .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
    .setText(FFTsmoothingarray[FFTsmoothingload]) //This updates the text of the dropdown!
    .setFont(h5)
    .setSize(12)
    .getStyle() //need to grab style before affecting the paddingTop
    .setPaddingTop(4)
    ;       
  UnfiltFilt(FFTfilterload);
     w_fft.cp5_widget.getController("UnfiltFilt") //Reference the dropdown from the appropriate widget
    .getCaptionLabel() //the caption label is the text object in the primary bar
    .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
    .setText(FFTfilterarray[FFTfilterload]) //This updates the text of the dropdown!
    .setFont(h5)
    .setSize(12)
    .getStyle() //need to grab style before affecting the paddingTop
    .setPaddingTop(4)
    ;     
  
  ///////////Apply Networking Settings
  w_networking.cp5_networking_dropdowns.getController("dataType1") //THIS WORKS!!!
      .getCaptionLabel() //the caption label is the text object in the primary bar
      .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
      .setText(NWdatatypesarray[nwdatatype1])
      .setFont(h4)
      .setSize(14)
      .getStyle() //need to grab style before affecting the paddingTop
      .setPaddingTop(4)
      ;  
  w_networking.cp5_networking_dropdowns.getController("dataType2") //THIS WORKS!!!
      .getCaptionLabel() //the caption label is the text object in the primary bar
      .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
      .setText(NWdatatypesarray[nwdatatype1])
      .setFont(h4)
      .setSize(14)
      .getStyle() //need to grab style before affecting the paddingTop
      .setPaddingTop(4)
      ;  
  w_networking.cp5_networking_dropdowns.getController("dataType3") //THIS WORKS!!!
      .getCaptionLabel() //the caption label is the text object in the primary bar
      .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
      .setText(NWdatatypesarray[nwdatatype1])
      .setFont(h4)
      .setSize(14)
      .getStyle() //need to grab style before affecting the paddingTop
      .setPaddingTop(4)
      ;  
  w_networking.cp5_networking_dropdowns.getController("dataType4") //THIS WORKS!!!
      .getCaptionLabel() //the caption label is the text object in the primary bar
      .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
      .setText(NWdatatypesarray[nwdatatype1])
      .setFont(h4)
      .setSize(14)
      .getStyle() //need to grab style before affecting the paddingTop
      .setPaddingTop(4)
      ;        
  ////////////////////////////////////////////////////////////
  //    Apply more loaded widget settings below this line   // 
}