//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    Was going to add these functions to WidgetManager, then just decided to make a new tab
    
          Thoughts: 
          -- Add a drop down button somewhere near the top that says "Settings" or "Config", expands to show "Load" and "Save" -- no good place to do this, currently
          -- Better idea already put into place: use Capital 'S' for Save and Capital 'L' for Load -- THIS WORKS
          -- It might be best set up the text file as a JSON Array to accomodate a larger amount of settings and to help with parsing on Load -- THIS WORKS
          -- Need to apply Time Series settings after they are loaded by sending a message for each channel to the Cyton/Ganglion boards

Requested User Settings to save so far:
wm.currentContainerLayout //default layout --done
dataprocessing.currentNotch_ind //default notch --done
dataprocessing.currentFilter_ind //default BP filter --done
w_analogread.startingVertScaleIndex //default vert scale for analog read widget, not applied
w_timeseries.startingVertScaleIndex //default vert scale for time series widget, not applied
      
Activate/Deactivating channels:
deactivateChannel(Channel-1) --done
activateChannel(Channel-1) --done

Changing hardware settings (especially BIAS, SRB 2, and SRB 1) found below using ChangeSettingValues

Loading and applying settings contained in dropdown menus are at the bottomw in LoadApplyWidgetDropdowns()
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
                       This sketch saves and loads the following User Settings:    
                       -- All Time Series widget settings
                       -- All FFT widget settings
                       -- Default Layout, Notch, Bandpass Filter
                       -- Networking Protocol and All OSC settings
                       
                       Created: Richard Waltman - May/June 2018  
                       
    -- Capital 'S' to Save                                                                                            
    -- Capital 'L' to Load                                                                                           
    -- Functions are called in Interactivty.pde with the rest of the keyboard shortcuts                               
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



JSONArray SaveSettingsJSONData;
JSONArray LoadSettingsJSONData;

//Used to set text for Notch and BP filter settings
String [] DataProcessingNotcharray = {"60Hz", "50Hz", "None"};
String [] DataProcessingBParray = {"1-50 Hz", "7-13 Hz", "15-50 Hz", "5-50 Hz", "No Filter"};

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
String[] NWprotocolarray = {"OSC", "UDP", "LSL", "Serial"};
String[] NWdatatypesarray = {"None", "TimesSeries", "FFT", "EMG", "BandPower", "Focus", "Pulse", "Widget"};

//Save Time Series settings variables
int TSactivesetting = 1;
int TSgainsetting;
int TSinputtypesetting;
int TSbiassetting;
int TSsrb2setting;
int TSsrb1setting;

//Load global settings variables
int loadLayoutsetting;   
int loadNotchsetting;
int loadBandpasssetting;
int loadTimeSeriesVertScale;
int loadTimeSeriesHorizScale;
int loadAnalogReadVertScale;
int loadAnalogReadHorizScale;

//Networking Settings save/load variables
int NWprotocolload;
String NWoscip1load;  String NWoscip2load;  String NWoscip3load;  String NWoscip4load;
String NWoscport1load;  String NWoscport2load;  String NWoscport3load;  String NWoscport4load;
String NWoscaddress1load;  String NWoscaddress2load; String NWoscaddress3load; String NWoscaddress4load;
int NWoscfilter1load;  int NWoscfilter2load;  int NWoscfilter3load;  int NWoscfilter4load;

//used only in this tab to count the number of channels being used while saving/loading, this gets updated in updateToNChan whenever the number of channels being used changes
int slnchan; 



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
  SaveGlobalSettings.setInt("Notch", dataProcessingNotchSave);
  SaveGlobalSettings.setInt("Bandpass Filter", dataProcessingBandpassSave);
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
  //Save Protocol
  SaveNetworkingSettings.setInt("Protocol", NWprotocolsave);//***Save User networking protocol mode
  //Save Data Types
  SaveNetworkingSettings.setInt("Data Type 1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));
  SaveNetworkingSettings.setInt("Data Type 2", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").getValue()));
  SaveNetworkingSettings.setInt("Data Type 3", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").getValue()));
  SaveNetworkingSettings.setInt("Data Type 4", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").getValue()));
  //Save IP addresses for OSC
  SaveNetworkingSettings.setString("OSC_ip1", w_networking.cp5_networking.get(Textfield.class, "osc_ip1").getText());
  SaveNetworkingSettings.setString("OSC_ip2", w_networking.cp5_networking.get(Textfield.class, "osc_ip2").getText());
  SaveNetworkingSettings.setString("OSC_ip3", w_networking.cp5_networking.get(Textfield.class, "osc_ip3").getText());  
  SaveNetworkingSettings.setString("OSC_ip4", w_networking.cp5_networking.get(Textfield.class, "osc_ip4").getText());
  //Save Ports for OSC
  SaveNetworkingSettings.setString("OSC_port1", w_networking.cp5_networking.get(Textfield.class, "osc_port1").getText());
  SaveNetworkingSettings.setString("OSC_port2", w_networking.cp5_networking.get(Textfield.class, "osc_port2").getText());
  SaveNetworkingSettings.setString("OSC_port3", w_networking.cp5_networking.get(Textfield.class, "osc_port3").getText());  
  SaveNetworkingSettings.setString("OSC_port4", w_networking.cp5_networking.get(Textfield.class, "osc_port4").getText());
  //Save addresses for OSC
  SaveNetworkingSettings.setString("OSC_address1", w_networking.cp5_networking.get(Textfield.class, "osc_address1").getText());
  SaveNetworkingSettings.setString("OSC_address2", w_networking.cp5_networking.get(Textfield.class, "osc_address2").getText());
  SaveNetworkingSettings.setString("OSC_address3", w_networking.cp5_networking.get(Textfield.class, "osc_address3").getText());  
  SaveNetworkingSettings.setString("OSC_address4", w_networking.cp5_networking.get(Textfield.class, "osc_address4").getText());
  //Save filters for OSC
  SaveNetworkingSettings.setInt("OSC_filter1", int(w_networking.cp5_networking.get(RadioButton.class, "filter1").getValue()));
  SaveNetworkingSettings.setInt("OSC_filter2", int(w_networking.cp5_networking.get(RadioButton.class, "filter2").getValue()));
  SaveNetworkingSettings.setInt("OSC_filter3", int(w_networking.cp5_networking.get(RadioButton.class, "filter3").getValue()));
  SaveNetworkingSettings.setInt("OSC_filter4", int(w_networking.cp5_networking.get(RadioButton.class, "filter4").getValue()));  
  //Set Networking Settings JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+2, SaveNetworkingSettings);  

  ////////////////////////////////////////////////////////////////////////////////
  ///ADD more global settings below this line in the same format as above/////////

  //Let's save the JSON array to a file!
  saveJSONArray(SaveSettingsJSONData, "data/UserSettingsFile-Dev.json");

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
    
   //Case for loading time series settings in Live Data mode
   if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON)  { 
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
             
        //Hopefully This can be shortened into somthing more efficient, there is a datatype conversion involved. Simple if-then works for now.
        //channelSettingValues[i][1] = char(GainSettings);
        if (GainSettings == 0) channelSettingValues[i][1] = '0';
        if (GainSettings == 1) channelSettingValues[i][1] = '1';
        if (GainSettings == 2) channelSettingValues[i][1] = '2';
        if (GainSettings == 3) channelSettingValues[i][1] = '3';        
        if (GainSettings == 4) channelSettingValues[i][1] = '4';
        if (GainSettings == 5) channelSettingValues[i][1] = '5';
        if (GainSettings == 6) channelSettingValues[i][1] = '6';   
            
        if (inputType == 0) channelSettingValues[i][2] = '0';
        if (inputType == 1) channelSettingValues[i][2] = '1';
        if (inputType == 2) channelSettingValues[i][2] = '2';
        if (inputType == 3) channelSettingValues[i][2] = '3';        
        if (inputType == 4) channelSettingValues[i][2] = '4';
        if (inputType == 5) channelSettingValues[i][2] = '5';        
        if (inputType == 6) channelSettingValues[i][2] = '6';
        if (inputType == 7) channelSettingValues[i][2] = '7';
        
        if (BiasSetting == 0) channelSettingValues[i][3] = '0';
        if (BiasSetting == 1) channelSettingValues[i][3] = '1';
        
        if (SRB2Setting == 0) channelSettingValues[i][4] = '0';
        if (SRB2Setting == 1) channelSettingValues[i][4] = '1';

        if (SRB1Setting == 0) channelSettingValues[i][5] = '0';
        if (SRB1Setting == 1) channelSettingValues[i][5] = '1';     
          
        //neither of these seems to update
        
        //cyton.syncChannelSettings();
        /*
        //cyton.isWritingChannel = true;
        String output = "r,set,";
        output += Integer.toString(i) + ","; // 0 indexed channel number
        output += channelSettingValues[i][0] + ","; // power down
        output += cyton.getGainForCommand(channelSettingValues[i][1]) + ","; // gain
        output += cyton.getInputTypeForCommand(channelSettingValues[i][2]) + ",";
        output += channelSettingValues[i][3] + ",";
        output += channelSettingValues[i][4] + ",";
        output += channelSettingValues[i][5] + TCP_STOP;
        cyton.write(output);
        verbosePrint("done writing channel " + Channel);
        println(output);
        //cyton.isWritingChannel = false;
        */
       
      }
    }//end Cyton/Ganglion case
      
    //              Case for loading Time Series settings when in Synthetic or Playback data modes
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
    } //end of Playback/Synthetic case
    

  
    //parse the global settings that appear after the channel settings 
    if (i == slnchan) {
      loadLayoutsetting = LoadAllSettings.getInt("Current Layout");
      loadNotchsetting = LoadAllSettings.getInt("Notch");
      loadBandpasssetting = LoadAllSettings.getInt("Bandpass Filter");
      loadTimeSeriesVertScale = LoadAllSettings.getInt("Time Series Vert Scale");
      loadTimeSeriesHorizScale = LoadAllSettings.getInt("Time Series Horiz Scale");
      loadAnalogReadVertScale = LoadAllSettings.getInt("Analog Read Vert Scale");
      loadAnalogReadHorizScale = LoadAllSettings.getInt("Analog Read Horiz Scale");
      //Load more global settings after this line, if needed
      
      //Create a string array to print global settings to console
      final String[] LoadedGlobalSettings = {
        "Using Layout Number: " + loadLayoutsetting, 
        "Default Notch: " + loadNotchsetting, //default notch
        "Default BP: " + loadBandpasssetting, //default bp
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
      NWprotocolload = LoadAllSettings.getInt("Protocol");
      nwdatatype1 = LoadAllSettings.getInt("Data Type 1");
      nwdatatype2 = LoadAllSettings.getInt("Data Type 2");
      nwdatatype3 = LoadAllSettings.getInt("Data Type 3");        
      nwdatatype4 = LoadAllSettings.getInt("Data Type 4"); 
      NWoscip1load = LoadAllSettings.getString("OSC_ip1");
      NWoscip2load = LoadAllSettings.getString("OSC_ip2");        
      NWoscip3load = LoadAllSettings.getString("OSC_ip3");        
      NWoscip4load = LoadAllSettings.getString("OSC_ip4");        
      NWoscport1load = LoadAllSettings.getString("OSC_port1");
      NWoscport2load = LoadAllSettings.getString("OSC_port2");        
      NWoscport3load = LoadAllSettings.getString("OSC_port3");        
      NWoscport4load = LoadAllSettings.getString("OSC_port4");                
      NWoscaddress1load = LoadAllSettings.getString("OSC_address1");
      NWoscaddress2load = LoadAllSettings.getString("OSC_address2");        
      NWoscaddress3load = LoadAllSettings.getString("OSC_address3");        
      NWoscaddress4load = LoadAllSettings.getString("OSC_address4");                
      NWoscfilter1load = LoadAllSettings.getInt("OSC_filter1");
      NWoscfilter2load = LoadAllSettings.getInt("OSC_filter2");        
      NWoscfilter3load = LoadAllSettings.getInt("OSC_filter3");        
      NWoscfilter4load = LoadAllSettings.getInt("OSC_filter4");               
    }
  }//end case for all objects in JSON
  
  //trying to apply time series settings with this function
  LoadApplyTimeSeriesSettings();
  
  //Apply the loaded settings to the GUI
  //Apply layout
  wm.setNewContainerLayout(loadLayoutsetting);
  println("Layout Loaded!");
  
  //Apply notch
  dataProcessing.currentNotch_ind = loadNotchsetting;
  topNav.filtNotchButton.but_txt = "Notch\n" + DataProcessingNotcharray[loadNotchsetting];
  //Apply Bandpass filter
  dataProcessing.currentFilt_ind = loadBandpasssetting;
  topNav.filtBPButton.but_txt = "BP Filt\n" + DataProcessingBParray[loadBandpasssetting]; //this works
  println(DataProcessingBParray[loadBandpasssetting]);
  
  //follow example of applying time series dropdowns to this
  AnalogReadStartingVertScaleIndex = loadAnalogReadVertScale;
  AnalogReadStartingHorizontalScaleIndex = loadAnalogReadHorizScale;
  //println("Vert/Horiz Scales Loaded!");  
   
  //Load and apply all of the settings that are in dropdown menus. It's a bit much, so it has it's own function at the bottom of this tab.
  LoadApplyWidgetDropdownText(); 

}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void LoadApplyTimeSeriesSettings() {
  for (int i = 0; i < slnchan;) { //For all time series channels...
    cyton.writeChannelSettings(i, channelSettingValues); //Write the channel settings to the board!
    if (CheckForSuccessTS != null) {
      println("Return code:" + CheckForSuccessTS);
      String[] list = split(CheckForSuccessTS, ',');
      int successcode = Integer.parseInt(list[1]);
      if (successcode == RESP_SUCCESS) {i++; CheckForSuccessTS = null;} //when successful, iterate to next channel(i++) and set Check to null
    }
    //delay(10);// works on 8 chan sometimes
    delay(100); //works on 8 channels 3/3 trials applying settings to all channels
  }    
} 

void LoadApplyWidgetDropdownText() {
  
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
  //Update protocol with loaded value
  Protocol(NWprotocolload);
  //Update dropdowns and textfields in the Networking widget with loaded values
  w_networking.cp5_widget.getController("Protocol").getCaptionLabel().setText(NWprotocolarray[NWprotocolload]); //Reference the dropdown from the appropriate widget
  w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(NWdatatypesarray[nwdatatype1]); //THIS WORKS!!!
  w_networking.cp5_networking_dropdowns.getController("dataType2").getCaptionLabel().setText(NWdatatypesarray[nwdatatype2]); //THIS WORKS!!!
  w_networking.cp5_networking_dropdowns.getController("dataType3").getCaptionLabel().setText(NWdatatypesarray[nwdatatype3]); //THIS WORKS!!!
  w_networking.cp5_networking_dropdowns.getController("dataType4").getCaptionLabel().setText(NWdatatypesarray[nwdatatype4]); //THIS WORKS!!!
  w_networking.cp5_networking.get(Textfield.class, "osc_ip1").setText(NWoscip1load);
  w_networking.cp5_networking.get(Textfield.class, "osc_ip2").setText(NWoscip2load);
  w_networking.cp5_networking.get(Textfield.class, "osc_ip3").setText(NWoscip3load);
  w_networking.cp5_networking.get(Textfield.class, "osc_ip4").setText(NWoscip4load);  
  w_networking.cp5_networking.get(Textfield.class, "osc_port1").setText(NWoscport1load);
  w_networking.cp5_networking.get(Textfield.class, "osc_port2").setText(NWoscport2load);
  w_networking.cp5_networking.get(Textfield.class, "osc_port3").setText(NWoscport3load);
  w_networking.cp5_networking.get(Textfield.class, "osc_port4").setText(NWoscport4load);    
  w_networking.cp5_networking.get(Textfield.class, "osc_address1").setText(NWoscaddress1load);
  w_networking.cp5_networking.get(Textfield.class, "osc_address2").setText(NWoscaddress2load);
  w_networking.cp5_networking.get(Textfield.class, "osc_address3").setText(NWoscaddress3load);
  w_networking.cp5_networking.get(Textfield.class, "osc_address4").setText(NWoscaddress4load);      
  w_networking.cp5_networking.get(RadioButton.class, "filter1").activate(NWoscfilter1load);
  w_networking.cp5_networking.get(RadioButton.class, "filter2").activate(NWoscfilter2load);  
  w_networking.cp5_networking.get(RadioButton.class, "filter3").activate(NWoscfilter3load);
  w_networking.cp5_networking.get(RadioButton.class, "filter4").activate(NWoscfilter4load);  
  ////////////////////////////////////////////////////////////
  //    Apply more loaded widget settings below this line   // 

    //w_networking.cp5_networking.get(Textfield.class, "osc_ip1").setText("Bananas"); //this works
}
/*
  private void processRegisterQuery(String msg) {
    String[] list = split(msg, ',');
    int code = Integer.parseInt(list[1]);

    switch (code) {
      case RESP_ERROR_CHANNEL_SETTINGS:
        killAndShowMsg("Failed to sync with Cyton, please power cycle your dongle and board.");
        println("RESP_ERROR_CHANNEL_SETTINGS general error: " + list[2]);
        break;
      case RESP_ERROR_CHANNEL_SETTINGS_SYNC_IN_PROGRESS:
        println("tried to sync channel settings but there was already one in progress");
        break;
      case RESP_ERROR_CHANNEL_SETTINGS_FAILED_TO_SET_CHANNEL:
        println("an error was thrown trying to set the channels | error: " + list[2]);
        break;
      case RESP_ERROR_CHANNEL_SETTINGS_FAILED_TO_PARSE:
        println("an error was thrown trying to call the function to set the channels | error: " + list[2]);
        break;
      case RESP_SUCCESS:
        // Sent when either a scan was stopped or started Successfully
        String action = list[2];
        switch (action) {
          case TCP_ACTION_START:
            println("Query registers for cyton channel settings");
            break;
        }
        break;
      case RESP_SUCCESS_CHANNEL_SETTING:
        int channelNumber = Integer.parseInt(list[2]);
        // power down comes in as either 'true' or 'false', 'true' is a '1' and false is a '0'
        channelSettingValues[channelNumber][0] = list[3].equals("true") ? '1' : '0';
        // gain comes in as an int, either 1, 2, 4, 6, 8, 12, 24 and must get converted to
        //  '0', '1', '2', '3', '4', '5', '6' respectively, of course.
        channelSettingValues[channelNumber][1] = cyton.getCommandForGain(Integer.parseInt(list[4]));
        // input type comes in as a string version and must get converted to char
        channelSettingValues[channelNumber][2] = cyton.getCommandForInputType(list[5]);
        // bias is like power down
        channelSettingValues[channelNumber][3] = list[6].equals("true") ? '1' : '0';
        // srb2 is like power down
        channelSettingValues[channelNumber][4] = list[7].equals("true") ? '1' : '0';
        // srb1 is like power down
        channelSettingValues[channelNumber][5] = list[8].equals("true") ? '1' : '0';
        break;
    }
  }
  */