//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
                       This sketch saves and loads the following User Settings:    
                       -- All Time Series widget settings in Live, Playback, and Synthetic modes
                       -- All FFT widget settings
                       -- Default Layout, Notch, Bandpass Filter, Framerate
                       -- Networking Mode and All settings for active networking protocol 
                       -- Analog Read, Head Plot, EMG, and Focus
                       -- Widget/Container Pairs
                       
                       Created: Richard Waltman - May/June 2018  
                       
    -- Start System first!                   
    -- Capital 'S' to Save                                                                                            
    -- Capital 'L' to Load                                                                                           
    -- Functions SaveGUIsettings() and LoadGUIsettings() are called in Interactivty.pde with the rest of the keyboard shortcuts 
    -- After loading, only a few actions are required: start/stop the data stream and/or networking streams, open/close serial port,  Turn on/off Analog Read
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    Was going to add these functions to WidgetManager, then just decided to make a new tab
    
          Thoughts: 
          -- Add a drop down button somewhere near the top that says "Settings" or "Config", expands to show "Load" and "Save" -- no good place to do this, currently
          -- Better idea already put into place: use Capital 'S' for Save and Capital 'L' for Load -- THIS WORKS
          -- It might be best set up the text file as a JSON Array to accomodate a larger amount of settings and to help with parsing on Load -- THIS WORKS
          -- Need to apply Time Series settings after they are loaded by sending a message for each channel to the Cyton/Ganglion boards -- DONE
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
String[] NWbaudratesarray = {"57600", "115200", "250000", "500000"};

//Used to set text in dropdown menus when loading Analog Read settings
String[] ARvertscaleArray = {"Auto", "50", "100", "200", "400", "1000", "10000"};
String[] ARhorizscaleArray = {"1 sec", "3 sec", "5 sec", "7 sec"};

//Used to set text in dropdown menus when loading Head Plot settings
String[] HPintensityArray = {"4x", "2x", "1x", "0.5x", "0.2x", "0.02x"};
String[] HPpolarityArray = {"+/-", " + "};
String[] HPcontoursArray = {"ON", "OFF"};
String[] HPsmoothingArray = {"0.0", "0.5", "0.75", "0.9", "0.95", "0.98"};

//Used to set text in dropdown menus when loading EMG settings
String[] EMGsmoothingArray = {"0.01 s", "0.1 s", "0.15 s", "0.25 s", "0.5 s", "0.75 s", "1.0 s", "2.0 s"};
String[] EMGuVlimArray = {"50 uV", "100 uV", "200 uV", "400 uV"};
String[] EMGcreepArray = {"0.9", "0.95", "0.98", "0.99", "0.999"};
String[] EMGmindeltauVArray = {"10 uV", "20 uV", "40 uV", "80 uV"};

//Used to set text in dropdown menus when loading Focus Setings
String[] FocusthemeArray = {"Green", "Orange", "Cyan"};
String[] FocuskeyArray = {"OFF", "UP", "SPACE"};

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

//Load TS dropdown variables
int loadTimeSeriesVertScale;
int loadTimeSeriesHorizScale;

//Load Analog Read dropdown variables
int loadAnalogReadVertScale;
int loadAnalogReadHorizScale;

//Load FFT dropdown variables
int FFTmaxfrqload;
int FFTmaxuVload;
int FFTloglinload;
int FFTsmoothingload;
int FFTfilterload;

//Load Headplot dropdown variables
int HPintensityload;
int HPpolarityload;
int HPcontoursload;
int HPsmoothingload;

//EMG settings
int EMGsmoothingload;
int EMGuVlimload;
int EMGcreepload;
int EMGmindeltauVload;

//Focus widget settings
int FocusThemeload;
int FocusKeyload;

//Networking Settings save/load variables
int NWprotocolload;
//OSC load variables
String NWoscip1load;  String NWoscip2load;  String NWoscip3load;  String NWoscip4load;
String NWoscport1load;  String NWoscport2load;  String NWoscport3load;  String NWoscport4load;
String NWoscaddress1load;  String NWoscaddress2load; String NWoscaddress3load; String NWoscaddress4load;
int NWoscfilter1load;  int NWoscfilter2load;  int NWoscfilter3load;  int NWoscfilter4load;
//UDP load variables
String NWudpip1load;  String NWudpip2load;  String NWudpip3load;
String NWudpport1load;  String NWudpport2load;  String NWudpport3load;
int NWudpfilter1load;  int NWudpfilter2load;  int NWudpfilter3load;
//LSL load variables
String NWlslname1load;  String NWlslname2load;  String NWlslname3load;
String NWlsltype1load;  String NWlsltype2load;  String NWlsltype3load;
String NWlslnumchan1load;  String NWlslnumchan2load; String NWlslnumchan3load;
int NWlslfilter1load;  int NWlslfilter2load;  int NWlslfilter3load;
//Serial load variables
int NWserialbaudrateload;
int NWserialfilter1load;

//used only in this tab to count the number of channels being used while saving/loading, this gets updated in updateToNChan whenever the number of channels being used changes
int slnchan; 
int numChanloaded;
Boolean chanNumError = false;
int numLoadedWidgets;
String [] LoadedWidgetsArray;
int loadFramerate;

///////////////////////////////  
//      Save GUI Settings    //
///////////////////////////////  
void SaveGUIsettings() {
  
  //Set up a JSON array
  SaveSettingsJSONData = new JSONArray();
  
  //Save the number of channels being used in the first object
  JSONObject SaveNumChannels = new JSONObject();
  SaveNumChannels.setInt("Channels", slnchan);
  //println(slnchan);
  SaveSettingsJSONData.setJSONObject(0, SaveNumChannels);
  
  ////////////////////////////////////////////////////////////////////////////////////
  //                 Case for saving TS settings in Live Data Modes                 //
  if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON)  {
    
    //Save all of the channel settings for number of Time Series channels being used
    for (int i = 0; i < slnchan; i++) {     
      //Make a JSON Object for each of the Time Series Channels
      JSONObject SaveTimeSeriesSettings = new JSONObject();
      //Copy channel settings from channelSettingValues  
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
      SaveSettingsJSONData.setJSONObject(i + 1, SaveTimeSeriesSettings);
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //              Case for saving TS settings when in Synthetic or Playback data modes                       //
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
      SaveSettingsJSONData.setJSONObject(i + 1, SaveTimeSeriesSettings);
    }      
  }    
  //Make a second JSON object within our JSONArray to store Global settings for the GUI
  JSONObject SaveGlobalSettings = new JSONObject();
  
  
  SaveGlobalSettings.setInt("Current Layout", currentLayout);
  SaveGlobalSettings.setInt("Notch", dataProcessingNotchSave);
  SaveGlobalSettings.setInt("Bandpass Filter", dataProcessingBandpassSave);
  SaveGlobalSettings.setInt("Framerate", frameRateCounter);
  SaveGlobalSettings.setInt("Time Series Vert Scale", TSvertscalesave);
  SaveGlobalSettings.setInt("Time Series Horiz Scale", TShorizscalesave);
  SaveGlobalSettings.setInt("Analog Read Vert Scale", ARvertscalesave);
  SaveGlobalSettings.setInt("Analog Read Horiz Scale", ARhorizscalesave);
  SaveSettingsJSONData.setJSONObject(slnchan + 1, SaveGlobalSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save FFT settings
  JSONObject SaveFFTSettings = new JSONObject();

  //Save FFT Max Freq Setting. The max frq variable is updated every time the user selects a dropdown in the FFT widget
  SaveFFTSettings.setInt("FFT Max Freq", FFTmaxfrqsave);
  //Save FFT max uV Setting. The max uV variable is updated also when user selects dropdown in the FFT widget
  SaveFFTSettings.setInt("FFT Max uV", FFTmaxuVsave);
  //Save FFT LogLin Setting. Same thing happens for LogLin
  SaveFFTSettings.setInt("FFT LogLin", FFTloglinsave);
  //Save FFT Smoothing Setting
  SaveFFTSettings.setInt("FFT Smoothing", FFTsmoothingsave);
  //Save FFT Filter Setting
  if (isFFTFiltered == true)  FFTfiltersave = 0;
  if (isFFTFiltered == false)  FFTfiltersave = 1;  
  SaveFFTSettings.setInt("FFT Filter",  FFTfiltersave);
  //Set the FFT JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+2, SaveFFTSettings); //next object will be set to slnchan+3, etc.  
  
  ///////////////////////////////////////////////Setup new JSON object to save Networking settings
  JSONObject SaveNetworkingSettings = new JSONObject();
  //Save Protocol
  SaveNetworkingSettings.setInt("Protocol", NWprotocolsave);//***Save User networking protocol mode
  
  switch(NWprotocolsave){
    case 0:
      //Save Data Types for OSC
      SaveNetworkingSettings.setInt("OSC_DataType1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));
      SaveNetworkingSettings.setInt("OSC_DataType2", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").getValue()));
      SaveNetworkingSettings.setInt("OSC_DataType3", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").getValue()));
      SaveNetworkingSettings.setInt("OSC_DataType4", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").getValue()));
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
      break;
    case 1:
      //Save UDP data types
      SaveNetworkingSettings.setInt("UDP_DataType1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));
      SaveNetworkingSettings.setInt("UDP_DataType2", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").getValue()));
      SaveNetworkingSettings.setInt("UDP_DataType3", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").getValue()));      
      //Save UDP IPs
      SaveNetworkingSettings.setString("UDP_ip1", w_networking.cp5_networking.get(Textfield.class, "udp_ip1").getText());
      SaveNetworkingSettings.setString("UDP_ip2", w_networking.cp5_networking.get(Textfield.class, "udp_ip2").getText());
      SaveNetworkingSettings.setString("UDP_ip3", w_networking.cp5_networking.get(Textfield.class, "udp_ip3").getText());      
      //Save UDP Ports
      SaveNetworkingSettings.setString("UDP_port1", w_networking.cp5_networking.get(Textfield.class, "udp_port1").getText());
      SaveNetworkingSettings.setString("UDP_port2", w_networking.cp5_networking.get(Textfield.class, "udp_port2").getText());
      SaveNetworkingSettings.setString("UDP_port3", w_networking.cp5_networking.get(Textfield.class, "udp_port3").getText());        
      //Save UDP Filters
      SaveNetworkingSettings.setInt("UDP_filter1", int(w_networking.cp5_networking.get(RadioButton.class, "filter1").getValue()));
      SaveNetworkingSettings.setInt("UDP_filter2", int(w_networking.cp5_networking.get(RadioButton.class, "filter2").getValue()));
      SaveNetworkingSettings.setInt("UDP_filter3", int(w_networking.cp5_networking.get(RadioButton.class, "filter3").getValue()));      
      break;
    case 2:   
      //Save LSL data types
      SaveNetworkingSettings.setInt("LSL_DataType1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));
      SaveNetworkingSettings.setInt("LSL_DataType2", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").getValue()));
      SaveNetworkingSettings.setInt("LSL_DataType3", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").getValue()));            
      //Save LSL stream names
      SaveNetworkingSettings.setString("LSL_name1", w_networking.cp5_networking.get(Textfield.class, "lsl_name1").getText());
      SaveNetworkingSettings.setString("LSL_name2", w_networking.cp5_networking.get(Textfield.class, "lsl_name2").getText());
      SaveNetworkingSettings.setString("LSL_name3", w_networking.cp5_networking.get(Textfield.class, "lsl_name3").getText());            
      //Save LSL type names
      SaveNetworkingSettings.setString("LSL_type1", w_networking.cp5_networking.get(Textfield.class, "lsl_type1").getText());
      SaveNetworkingSettings.setString("LSL_type2", w_networking.cp5_networking.get(Textfield.class, "lsl_type2").getText());
      SaveNetworkingSettings.setString("LSL_type3", w_networking.cp5_networking.get(Textfield.class, "lsl_type3").getText());                  
      //Save LSL stream # Chan
      SaveNetworkingSettings.setString("LSL_numchan1", w_networking.cp5_networking.get(Textfield.class, "lsl_numchan1").getText());
      SaveNetworkingSettings.setString("LSL_numchan2", w_networking.cp5_networking.get(Textfield.class, "lsl_numchan2").getText());
      SaveNetworkingSettings.setString("LSL_numchan3", w_networking.cp5_networking.get(Textfield.class, "lsl_numchan3").getText());          
      //Save LSL filters
      SaveNetworkingSettings.setInt("LSL_filter1", int(w_networking.cp5_networking.get(RadioButton.class, "filter1").getValue()));
      SaveNetworkingSettings.setInt("LSL_filter2", int(w_networking.cp5_networking.get(RadioButton.class, "filter2").getValue()));
      SaveNetworkingSettings.setInt("LSL_filter3", int(w_networking.cp5_networking.get(RadioButton.class, "filter3").getValue()));            
      break;
    case 3:
      //Save Serial data type
      SaveNetworkingSettings.setInt("Serial_DataType1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));      
      //Save Serial baud rate. Not saving serial port. cp5_networking_baudRate.
      SaveNetworkingSettings.setInt("Serial_baudrate", int(w_networking.cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").getValue()));      
      //Save Serial filter
      SaveNetworkingSettings.setInt("Serial_filter1", int(w_networking.cp5_networking.get(RadioButton.class, "filter1").getValue()));      
      break;
  }//end of switch
  //Set Networking Settings JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+3, SaveNetworkingSettings);  

  ///////////////////////////////////////////////Setup new JSON object to save Headplot settings
  JSONObject SaveHeadplotSettings = new JSONObject();

  //Save Headplot Intesity
  SaveHeadplotSettings.setInt("HP_intensity", HPintensitysave);
  //Save Headplot Polarity
  SaveHeadplotSettings.setInt("HP_polarity", HPpolaritysave);
  //Save Headplot contours
  SaveHeadplotSettings.setInt("HP_contours", HPcontourssave);
  //Save Headplot Smoothing Setting
  SaveHeadplotSettings.setInt("HP_smoothing", HPsmoothingsave);
  //Set the Headplot JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+4, SaveHeadplotSettings);

  ///////////////////////////////////////////////Setup new JSON object to save Headplot settings
  JSONObject SaveEMGSettings = new JSONObject();

  //Save EMG Smoothing
  SaveEMGSettings.setInt("EMG_smoothing", EMGsmoothingsave);
  //Save EMG uV limit
  SaveEMGSettings.setInt("EMG_uVlimit", EMGuVlimsave);
  //Save EMG creep speed
  SaveEMGSettings.setInt("EMG_creepspeed", EMGcreepsave);
  //Save EMG min delta uV
  SaveEMGSettings.setInt("EMG_minuV", EMGmindeltauVsave);
  //Set the EMG JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+5, SaveEMGSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save Headplot settings
  JSONObject SaveFocusSettings = new JSONObject();

  //Save Focus theme
  SaveFocusSettings.setInt("Focus_theme", Focusthemesave);
  //Save Focus keypress
  SaveFocusSettings.setInt("Focus_keypress", Focuskeysave);
  //Set the Focus JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+6, SaveFocusSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save Widgets Active in respective Containers
  JSONObject SaveWidgetSettings = new JSONObject();
  
  int numActiveWidgets = 0;
  //Save what Widgets are active and respective Container number (see Containers.pde)
  for(int i = 0; i < wm.widgets.size(); i++){
    if(wm.widgets.get(i).isActive){
      numActiveWidgets++; //increment numActiveWidgets
      //println("Widget" + i + " is active");
      // activeWidgets.add(i); //keep track of the active widget
      int containerCountsave = wm.widgets.get(i).currentContainer;
      //println("Widget " + i + " is in Container " + containerCountsave);
      SaveWidgetSettings.setInt("Widget_"+i, containerCountsave); 
    }
  } 
  println(numActiveWidgets + " active widgets saved!");
  //Print what widgets are in the containers used by current layout for only the number of active widgets
  for(int i = 0; i < numActiveWidgets; i++){
        //int containerCounter = wm.layouts.get(currentLayout-1).containerInts[i];
        //println("Container " + containerCounter + " is available");          
  }  
  
  SaveSettingsJSONData.setJSONObject(slnchan+7, SaveWidgetSettings);
  
  /////////////////////////////////////////////////////////////////////////////////
  ///ADD more global settings above this line in the same formats as above/////////

  //Let's save the JSON array to a file!
  saveJSONArray(SaveSettingsJSONData, "data/UserSettingsFile-Dev.json");

}  //End of Save GUI Settings function
  
  
  
///////////////////////////////  
//      Load GUI Settings    //
///////////////////////////////  
void LoadGUIsettings() {  
  //Load all saved User Settings from a JSON file
  LoadSettingsJSONData = loadJSONArray("UserSettingsFile-Dev.json");

  //Check the number of channels saved to json first!
  JSONObject LoadChanSettings = LoadSettingsJSONData.getJSONObject(0); 
  numChanloaded = LoadChanSettings.getInt("Channels");
  //Print error if trying to load a different number of channels
  if (numChanloaded != slnchan) {
    output("Channel Number Error..."); 
    println("Channels being loaded don't match channels being used!");
    chanNumError = true; 
    return;
  } else {
    chanNumError = false;
  }
  
  //We want to read the rest of the JSON Array!
  for (int i = 0; i < LoadSettingsJSONData.size() - 1; i++) {
    
   //Make a JSON object, we only need one to load the remaining data, and call it LoadAllSettings
   JSONObject LoadAllSettings = LoadSettingsJSONData.getJSONObject(i + 1); 
   
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
      }
    }//end Cyton/Ganglion case
      
    //////////Case for loading Time Series settings when in Synthetic or Playback data modes
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
      loadFramerate = LoadAllSettings.getInt("Framerate");
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
        "Default Framerate: " + loadFramerate, //default framerate
        "TS Vert Scale: " + loadTimeSeriesVertScale,
        "TS Horiz Scale: " + loadTimeSeriesHorizScale,
        "Analog Vert Scale: " + loadAnalogReadVertScale,
        "Analog Horiz Scale: " + loadAnalogReadHorizScale,
        //Add new global settings above this line to print to console
        };
      //Print the global settings that have been loaded to the console  
      printArray(LoadedGlobalSettings);
    }
    
    //parse the FFT settings that appear after the global settings 
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
      //Print the FFT settings that have been loaded to the console  
      printArray(LoadedFFTSettings);
    }
    
    //parse Networking settings that appear after FFT settings
    if (i == slnchan + 2) {
      NWprotocolload = LoadAllSettings.getInt("Protocol");
      switch (NWprotocolload)  {
        case 0:
          nwdatatype1 = LoadAllSettings.getInt("OSC_DataType1");
          nwdatatype2 = LoadAllSettings.getInt("OSC_DataType2");
          nwdatatype3 = LoadAllSettings.getInt("OSC_DataType3");        
          nwdatatype4 = LoadAllSettings.getInt("OSC_DataType4"); 
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
          break;
        case 1:
          nwdatatype1 = LoadAllSettings.getInt("UDP_DataType1");
          nwdatatype2 = LoadAllSettings.getInt("UDP_DataType2");
          nwdatatype3 = LoadAllSettings.getInt("UDP_DataType3");        
          NWudpip1load = LoadAllSettings.getString("UDP_ip1");
          NWudpip2load = LoadAllSettings.getString("UDP_ip2");        
          NWudpip3load = LoadAllSettings.getString("UDP_ip3");            
          NWudpport1load = LoadAllSettings.getString("UDP_port1");
          NWudpport2load = LoadAllSettings.getString("UDP_port2");        
          NWudpport3load = LoadAllSettings.getString("UDP_port3");                                            
          NWudpfilter1load = LoadAllSettings.getInt("UDP_filter1");
          NWudpfilter2load = LoadAllSettings.getInt("UDP_filter2");        
          NWudpfilter3load = LoadAllSettings.getInt("UDP_filter3");
          break;
        case 2:
          nwdatatype1 = LoadAllSettings.getInt("LSL_DataType1");
          nwdatatype2 = LoadAllSettings.getInt("LSL_DataType2");
          nwdatatype3 = LoadAllSettings.getInt("LSL_DataType3");        
          NWlslname1load = LoadAllSettings.getString("LSL_name1");
          NWlslname2load = LoadAllSettings.getString("LSL_name2");        
          NWlslname3load = LoadAllSettings.getString("LSL_name3");            
          NWlsltype1load = LoadAllSettings.getString("LSL_type1");
          NWlsltype2load = LoadAllSettings.getString("LSL_type2");        
          NWlsltype3load = LoadAllSettings.getString("LSL_type3");                       
          NWlslnumchan1load = LoadAllSettings.getString("LSL_numchan1");
          NWlslnumchan2load = LoadAllSettings.getString("LSL_numchan2");        
          NWlslnumchan3load = LoadAllSettings.getString("LSL_numchan3");                       
          NWlslfilter1load = LoadAllSettings.getInt("LSL_filter1");
          NWlslfilter2load = LoadAllSettings.getInt("LSL_filter2");        
          NWlslfilter3load = LoadAllSettings.getInt("LSL_filter3");             
          break;
        case 3:
          nwdatatype1 = LoadAllSettings.getInt("Serial_DataType1");   
          NWserialbaudrateload = LoadAllSettings.getInt("Serial_baudrate");   
          NWserialfilter1load = LoadAllSettings.getInt("Serial_filter1");
          break;
      }
    }
    
    //parse the Headplot settings that appear after networking settings 
    if (i == slnchan + 3) {
      HPintensityload = LoadAllSettings.getInt("HP_intensity");
      HPpolarityload = LoadAllSettings.getInt("HP_polarity");
      HPcontoursload = LoadAllSettings.getInt("HP_contours");
      HPsmoothingload = LoadAllSettings.getInt("HP_smoothing");
      
      //Create a string array to print to console
      final String[] LoadedHPSettings = {
        "HP_intensity: " + HPintensityload, 
        "HP_polarity: " + HPpolarityload,
        "HP_contours: " + HPcontoursload,
        "HP_smoothing: " + HPsmoothingload,
        };
      //Print the Headplot settings 
      printArray(LoadedHPSettings);
    } 
    
    //parse the EMG settings that appear after Headplot settings
    if (i == slnchan + 4) {
      EMGsmoothingload = LoadAllSettings.getInt("EMG_smoothing");
      EMGuVlimload = LoadAllSettings.getInt("EMG_uVlimit");
      EMGcreepload = LoadAllSettings.getInt("EMG_creepspeed");
      EMGmindeltauVload = LoadAllSettings.getInt("EMG_minuV");
      
      //Create a string array to print to console
      final String[] LoadedEMGSettings = {
        "EMG_smoothing: " + EMGsmoothingload, 
        "EMG_uVlimit: " + EMGuVlimload,
        "EMG_creepspeed: " + EMGcreepload,
        "EMG_minuV: " + EMGmindeltauVload,
        };
      //Print the EMG settings 
      printArray(LoadedEMGSettings);
    }
    
    //parse the Focus settings that appear after EMG settings
      if (i == slnchan + 5) {
      FocusThemeload = LoadAllSettings.getInt("Focus_theme");
      FocusKeyload = LoadAllSettings.getInt("Focus_keypress");
      
      //Create a string array to print to console
      final String[] LoadedFocusSettings = {
        "Focus_theme: " + FocusThemeload, 
        "Focus_keypress: " + FocusKeyload,
        };
      //Print the EMG settings 
      printArray(LoadedFocusSettings);
    }

    //parse the Widget/Container settings that appear after Focus settings
    if (i == slnchan + 6) {
      //Apply Layout directly before loading and applying widgets to containers
      wm.setNewContainerLayout(loadLayoutsetting - 1);
      println("Layout " + loadLayoutsetting + " Loaded!");
      numLoadedWidgets = LoadAllSettings.size();
      //println(LoadAllSettings.keys());
      //Store the Widget number keys from JSON to a string array
      LoadedWidgetsArray = (String[]) LoadAllSettings.keys().toArray(new String[LoadAllSettings.size()]);
      //printArray(LoadedWidgetsArray);
      int widgetToActivate = 0;
      for (int w = 0; w < numLoadedWidgets; w++) {
          String [] loadWidgetNameNumber = split(LoadedWidgetsArray[w], '_');
          //This prints the widget numbers only to be used when applying widgets to containers       
          if (loadWidgetNameNumber[1].equals("0")) {widgetToActivate = 0;}
          if (loadWidgetNameNumber[1].equals("1")) {widgetToActivate = 1;}          
          if (loadWidgetNameNumber[1].equals("2")) {widgetToActivate = 2;}          
          if (loadWidgetNameNumber[1].equals("3")) {widgetToActivate = 3;}
          if (loadWidgetNameNumber[1].equals("4")) {widgetToActivate = 4;}
          if (loadWidgetNameNumber[1].equals("5")) {widgetToActivate = 5;}          
          if (loadWidgetNameNumber[1].equals("6")) {widgetToActivate = 6;}          
          if (loadWidgetNameNumber[1].equals("7")) {widgetToActivate = 7;}          
          if (loadWidgetNameNumber[1].equals("8")) {widgetToActivate = 8;}
          if (loadWidgetNameNumber[1].equals("9")) {widgetToActivate = 9;}          
          if (loadWidgetNameNumber[1].equals("10")) {widgetToActivate = 10;}          
          if (loadWidgetNameNumber[1].equals("11")) {widgetToActivate = 11;}
          if (loadWidgetNameNumber[1].equals("12")) {widgetToActivate = 12;} 
          
          //Load the container for the current widget[w]
          int ContainerToApply = LoadAllSettings.getInt(LoadedWidgetsArray[w]);
          
          wm.widgets.get(widgetToActivate).isActive = true;//activate the new widget
          wm.widgets.get(widgetToActivate).setContainer(ContainerToApply);//map it to the container that was loaded! 
          println("Applied Widget " + widgetToActivate + " to Container " + ContainerToApply);
      }      
    }//end case for widget/container settings
    
    /////////////////////////////////////////////////////////////
    //    Load more widget settings above this line as above   //   
    
  }//end case for all objects in JSON

  //Apply notch
  dataProcessing.currentNotch_ind = loadNotchsetting;
  topNav.filtNotchButton.but_txt = "Notch\n" + DataProcessingNotcharray[loadNotchsetting];
  //Apply Bandpass filter
  dataProcessing.currentFilt_ind = loadBandpasssetting;
  topNav.filtBPButton.but_txt = "BP Filt\n" + DataProcessingBParray[loadBandpasssetting]; //this works
  println(DataProcessingBParray[loadBandpasssetting]);
  
  //Apply Framerate
  frameRateCounter = loadFramerate;
  switch (frameRateCounter){
    case 0:
      topNav.fpsButton.setString("24 fps");
      frameRate(24); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
      break;
    case 1:
      topNav.fpsButton.setString("30 fps");
      frameRate(30); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
      break;
    case 2:
      topNav.fpsButton.setString("45 fps");
      frameRate(45); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
      break;
    case 3:
      topNav.fpsButton.setString("60 fps");
      frameRate(60); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
      break;
  }
  
  //Load and apply all of the settings that are in dropdown menus. It's a bit much, so it has it's own function at the bottom of this tab.
  LoadApplyWidgetDropdownText(); 
  
  //Apply Time Series Settings Last!!!
  //Case for loading time series settings in Live Data mode last. Takes 100-105 ms per channel to ensure success.
  if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON)  {LoadApplyTimeSeriesSettings();}
  
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void LoadApplyTimeSeriesSettings() {
  for (int i = 0; i < slnchan;) { //For all time series channels...
    cyton.writeChannelSettings(i, channelSettingValues); //Write the channel settings to the board!
    if (CheckForSuccessTS != null) { // If we receive a return code...
      println("Return code:" + CheckForSuccessTS);
      String[] list = split(CheckForSuccessTS, ',');
      int successcode = Integer.parseInt(list[1]);
      if (successcode == RESP_SUCCESS) {i++; CheckForSuccessTS = null;} //when successful, iterate to next channel(i++) and set Check to null
    }
    //delay(10);// Works on 8 chan sometimes
    delay(100); // Works on 8 and 16 channels 3/3 trials applying settings to all channels. Tested by setting gain 1x and loading 24x.
  }    
} 

void LoadApplyWidgetDropdownText() {
  
  ////////Apply Time Series widget settings
  VertScale_TS(loadTimeSeriesVertScale);// changes back-end
    w_timeSeries.cp5_widget.getController("VertScale_TS").getCaptionLabel().setText(TSvertscalearray[loadTimeSeriesVertScale]); //changes front-end

  Duration(loadTimeSeriesHorizScale);
    w_timeSeries.cp5_widget.getController("Duration").getCaptionLabel().setText(TShorizscalearray[loadTimeSeriesHorizScale]); 
  
  //////Apply FFT settings
  MaxFreq(FFTmaxfrqload); //This changes the back-end
    w_fft.cp5_widget.getController("MaxFreq").getCaptionLabel().setText(FFTmaxfrqarray[FFTmaxfrqload]); //This changes front-end... etc.

  VertScale(FFTmaxuVload);
    w_fft.cp5_widget.getController("VertScale").getCaptionLabel().setText(FFTvertscalearray[FFTmaxuVload]);

  LogLin(FFTloglinload);
     w_fft.cp5_widget.getController("LogLin").getCaptionLabel().setText(FFTloglinarray[FFTloglinload]); 
  
  Smoothing(FFTsmoothingload);
     w_fft.cp5_widget.getController("Smoothing").getCaptionLabel().setText(FFTsmoothingarray[FFTsmoothingload]); 
    
  UnfiltFilt(FFTfilterload);
     w_fft.cp5_widget.getController("UnfiltFilt").getCaptionLabel().setText(FFTfilterarray[FFTfilterload]);
  
  ////////Apply Analog Read settings
  VertScale_AR(loadAnalogReadVertScale);
    w_analogRead.cp5_widget.getController("VertScale_AR").getCaptionLabel().setText(ARvertscaleArray[loadAnalogReadVertScale]);

  Duration_AR(loadAnalogReadHorizScale);
    w_analogRead.cp5_widget.getController("Duration_AR").getCaptionLabel().setText(ARhorizscaleArray[loadAnalogReadHorizScale]);
  
  ////////////////////////////Apply Headplot settings
  Intensity(HPintensityload);
    w_headPlot.cp5_widget.getController("Intensity").getCaptionLabel().setText(HPintensityArray[HPintensityload]);

  Polarity(HPpolarityload);
    w_headPlot.cp5_widget.getController("Polarity").getCaptionLabel().setText(HPpolarityArray[HPpolarityload]);

  ShowContours(HPcontoursload);
    w_headPlot.cp5_widget.getController("ShowContours").getCaptionLabel().setText(HPcontoursArray[HPcontoursload]);
   
  SmoothingHeadPlot(HPsmoothingload);
    w_headPlot.cp5_widget.getController("SmoothingHeadPlot").getCaptionLabel().setText(HPsmoothingArray[HPsmoothingload]);
    
  ////////////////////////////Apply EMG settings
  SmoothEMG(EMGsmoothingload);
    w_emg.cp5_widget.getController("SmoothEMG").getCaptionLabel().setText(EMGsmoothingArray[EMGsmoothingload]);

  uVLimit(EMGuVlimload);
    w_emg.cp5_widget.getController("uVLimit").getCaptionLabel().setText(EMGuVlimArray[EMGuVlimload]);

  CreepSpeed(EMGcreepload);
    w_emg.cp5_widget.getController("CreepSpeed").getCaptionLabel().setText(EMGcreepArray[EMGcreepload]);

  minUVRange(EMGmindeltauVload);
    w_emg.cp5_widget.getController("minUVRange").getCaptionLabel().setText(EMGmindeltauVArray[EMGmindeltauVload]);
    
   ////////////////////////////Apply Focus settings
  ChooseFocusColor(FocusThemeload);
    w_focus.cp5_widget.getController("ChooseFocusColor").getCaptionLabel().setText(FocusthemeArray[FocusThemeload]);

  StrokeKeyWhenFocused(FocusKeyload);
    w_focus.cp5_widget.getController("StrokeKeyWhenFocused").getCaptionLabel().setText(FocuskeyArray[FocusKeyload]);  
    
  ///////////Apply Networking Settings
  //Update protocol with loaded value
  Protocol(NWprotocolload);
  //Update dropdowns and textfields in the Networking widget with loaded values
  w_networking.cp5_widget.getController("Protocol").getCaptionLabel().setText(NWprotocolarray[NWprotocolload]); //Reference the dropdown from the appropriate widget
  switch (NWprotocolload) {
    case 0:  //Apply OSC if loaded
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
      break;
    case 1:  //Apply UDP if loaded
      println("apply UDP nw mode");
      w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(NWdatatypesarray[nwdatatype1]); //THIS WORKS!!!
      w_networking.cp5_networking_dropdowns.getController("dataType2").getCaptionLabel().setText(NWdatatypesarray[nwdatatype2]); //THIS WORKS!!!
      w_networking.cp5_networking_dropdowns.getController("dataType3").getCaptionLabel().setText(NWdatatypesarray[nwdatatype3]); //THIS WORKS!!!
      w_networking.cp5_networking.get(Textfield.class, "udp_ip1").setText(NWudpip1load);
      w_networking.cp5_networking.get(Textfield.class, "udp_ip2").setText(NWudpip2load);
      w_networking.cp5_networking.get(Textfield.class, "udp_ip3").setText(NWudpip3load);  
      w_networking.cp5_networking.get(Textfield.class, "udp_port1").setText(NWudpport1load);
      w_networking.cp5_networking.get(Textfield.class, "udp_port2").setText(NWudpport2load);
      w_networking.cp5_networking.get(Textfield.class, "udp_port3").setText(NWudpport3load);     
      w_networking.cp5_networking.get(RadioButton.class, "filter1").activate(NWudpfilter1load);
      w_networking.cp5_networking.get(RadioButton.class, "filter2").activate(NWudpfilter2load);  
      w_networking.cp5_networking.get(RadioButton.class, "filter3").activate(NWudpfilter3load);    
      break;
    case 2:  //Apply LSL if loaded 
      println("apply LSL nw mode");
      w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(NWdatatypesarray[nwdatatype1]); //THIS WORKS!!!
      w_networking.cp5_networking_dropdowns.getController("dataType2").getCaptionLabel().setText(NWdatatypesarray[nwdatatype2]); //THIS WORKS!!!
      w_networking.cp5_networking_dropdowns.getController("dataType3").getCaptionLabel().setText(NWdatatypesarray[nwdatatype3]); //THIS WORKS!!!
      w_networking.cp5_networking.get(Textfield.class, "lsl_name1").setText(NWlslname1load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_name2").setText(NWlslname2load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_name3").setText(NWlslname3load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_type1").setText(NWlsltype1load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_type2").setText(NWlsltype2load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_type3").setText(NWlsltype3load);  
      w_networking.cp5_networking.get(Textfield.class, "lsl_numchan1").setText(NWlslnumchan1load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_numchan2").setText(NWlslnumchan2load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_numchan3").setText(NWlslnumchan3load);     
      w_networking.cp5_networking.get(RadioButton.class, "filter1").activate(NWlslfilter1load);
      w_networking.cp5_networking.get(RadioButton.class, "filter2").activate(NWlslfilter2load);  
      w_networking.cp5_networking.get(RadioButton.class, "filter3").activate(NWlslfilter3load);       
      break;  
    case 3:  //Apply Serial if loaded
      println("apply Serial nw mode");
      w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(NWdatatypesarray[nwdatatype1]); //THIS WORKS!!!
      w_networking.cp5_networking_baudRate.getController("baud_rate").getCaptionLabel().setText(NWbaudratesarray[NWserialbaudrateload]); //THIS WORKS!!! 
      w_networking.cp5_networking.get(RadioButton.class, "filter1").activate(NWserialfilter1load);      
      break;    
  }  
  ////////////////////////////////////////////////////////////
  //    Apply more loaded widget settings above this line   // 
  
  //w_networking.cp5_networking.get(Textfield.class, "osc_ip1").setText("Bananas"); //this works
  
} //end of LoadApplyWidgetDropdownText()
