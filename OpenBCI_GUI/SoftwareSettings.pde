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
    -- Functions SaveGUIsettings() and loadGUISettings() are called in Interactivty.pde with the rest of the keyboard shortcuts
    -- Functions are also called in TopNav.pde when "Config" --> "Save Settings" || "Load Settings" is clicked
    -- This allows User to store one snapshot of most GUI settings in /data/UserSettingsFile.json
    -- After loading, only a few actions are required: start/stop the data stream and/or networking streams, open/close serial port,  Turn on/off Analog Read
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

JSONArray SaveSettingsJSONData;
JSONArray LoadSettingsJSONData;

//Used to set text for Notch and BP filter settings
String [] dataProcessingNotcharray = {"60Hz", "50Hz", "None"};
String [] dataProcessingBParray = {"1-50 Hz", "7-13 Hz", "15-50 Hz", "5-50 Hz", "No Filter"};

// Used to set text in Time Series dropdown settings
String[] tsVertScaleArray = {"Auto", "50 uV", "100 uV", "200 uV", "400 uV", "1000 uV", "10000 uV"};
String[] tsHorizScaleArray = {"1 sec", "3 sec", "5 sec", "7 sec"};

//Used to print the status of each channel in the console when loading settings
String[] channelsActiveArray = {"Active", "Not Active"};
String[] gainSettingsArray = { "x1", "x2", "x4", "x6", "x8", "x12", "x24"};
String[] inputTypeArray = { "Normal", "Shorted", "BIAS_MEAS", "MVDD", "Temp.", "Test", "BIAS_DRP", "BIAS_DRN"};
String[] biasIncludeArray = {"Don't Include", "Include"};
String[] srb2SettingArray = {"Off", "On"};
String[] srb1SettingArray = {"Off", "On"};

//Used to set text in dropdown menus when loading FFT settings
String[] fftMaxFrqArray = {"20 Hz", "40 Hz", "60 Hz", "100 Hz", "120 Hz", "250 Hz", "500 Hz", "800 Hz"};
String[] fftVertScaleArray = {"10 uV", "50 uV", "100 uV", "1000 uV"};
String[] fftLogLinArray = {"Log", "Linear"};
String[] fftSmoothingArray = {"0.0", "0.5", "0.75", "0.9", "0.95", "0.98"};
String[] fftFilterArray = {"Filtered", "Unfilt."};

//Used to set text in dropdown menus when loading Networking settings
String[] nwProtocolArray = {"OSC", "UDP", "LSL", "Serial"};
String[] nwDataTypesArray = {"None", "TimesSeries", "FFT", "EMG", "BandPower", "Focus", "Pulse", "Widget"};
String[] nwBaudRatesArray = {"57600", "115200", "250000", "500000"};

//Used to set text in dropdown menus when loading Analog Read settings
String[] arVertScaleArray = {"Auto", "50", "100", "200", "400", "1000", "10000"};
String[] arHorizScaleArray = {"1 sec", "3 sec", "5 sec", "7 sec"};

//Used to set text in dropdown menus when loading Head Plot settings
String[] hpIntensityArray = {"4x", "2x", "1x", "0.5x", "0.2x", "0.02x"};
String[] hpPolarityArray = {"+/-", " + "};
String[] hpContoursArray = {"ON", "OFF"};
String[] hpSmoothingArray = {"0.0", "0.5", "0.75", "0.9", "0.95", "0.98"};

//Used to set text in dropdown menus when loading EMG settings
String[] emgSmoothingArray = {"0.01 s", "0.1 s", "0.15 s", "0.25 s", "0.5 s", "0.75 s", "1.0 s", "2.0 s"};
String[] emguVLimArray = {"50 uV", "100 uV", "200 uV", "400 uV"};
String[] emgCreepArray = {"0.9", "0.95", "0.98", "0.99", "0.999"};
String[] emgMinDeltauVArray = {"10 uV", "20 uV", "40 uV", "80 uV"};

//Used to set text in dropdown menus when loading Focus Setings
String[] focusThemeArray = {"Green", "Orange", "Cyan"};
String[] focusKeyArray = {"OFF", "UP", "SPACE"};

//Save Time Series settings variables
int tsActiveSetting = 1;
int tsGainSetting;
int tsInputTypeSetting;
int tsBiasSetting;
int tsSrb2Setting;
int tsSrb1Setting;

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
int fftMaxFrqLoad;
int fftMaxuVLoad;
int fftLogLinLoad;
int fftSmoothingLoad;
int fftFilterLoad;

//Load Headplot dropdown variables
int hpIntensityLoad;
int hpPolarityLoad;
int hpContoursLoad;
int hpSmoothingLoad;

//EMG settings
int emgSmoothingLoad;
int emguVLimLoad;
int emgCreepLoad;
int emgMinDeltauVLoad;

//Focus widget settings
int focusThemeLoad;
int focusKeyLoad;

//Networking Settings save/load variables
int nwProtocolLoad;
//OSC load variables
String nwOscIp1Load;  String nwOscIp2Load;  String nwOscIp3Load;  String nwOscIp4Load;
String nwOscPort1Load;  String nwOscPort2Load;  String nwOscPort3Load;  String nwOscPort4Load;
String nwOscAddress1Load;  String nwOscAddress2Load; String nwOscAddress3Load; String nwOscAddress4Load;
int nwOscFilter1Load;  int nwOscFilter2Load;  int nwOscFilter3Load;  int nwOscFilter4Load;
//UDP load variables
String nwUdpIp1Load;  String nwUdpIp2Load;  String nwUdpIp3Load;
String nwUdpPort1Load;  String nwUdpPort2Load;  String nwUdpPort3Load;
int nwUdpFilter1Load;  int nwUdpFilter2Load;  int nwUdpFilter3Load;
//LSL load variables
String nwLSLName1Load;  String nwLSLName2Load;  String nwLSLName3Load;
String nwLSLType1Load;  String nwLSLType2Load;  String nwLSLType3Load;
String nwLSLNumChan1Load;  String nwLSLNumChan2Load; String nwLSLNumChan3Load;
int nwLSLFilter1Load;  int nwLSLFilter2Load;  int nwLSLFilter3Load;
//Serial load variables
int nwSerialBaudRateLoad;
int nwSerialFilter1Load;

//used only in this tab to count the number of channels being used while saving/loading, this gets updated in updateToNChan whenever the number of channels being used changes
int slnchan; 
int numChanloaded;
Boolean chanNumError = false;
int numLoadedWidgets;
String [] LoadedWidgetsArray;
int loadFramerate;
int loadDatasource;
Boolean dataSourceError = false;

///////////////////////////////  
//      Save GUI Settings    //
///////////////////////////////  
void saveGUISettings() {
  
  //Set up a JSON array
  SaveSettingsJSONData = new JSONArray();
  
  //Save the number of channels being used and eegDataSource in the first object
  JSONObject SaveNumChannels = new JSONObject();
  SaveNumChannels.setInt("Channels", slnchan);
  SaveNumChannels.setInt("Data Source", eegDataSource);
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
            if (channelSettingValues[i][j] == '0')  tsActiveSetting = 0;
            if (channelSettingValues[i][j] == '1')  tsActiveSetting = 1;
            // tsActiveSetting = int(channelSettingValues[i][j]));  // For some reason this approach doesn't work, still returns 48 and 49 '0' and '1'
            break;
          case 1: //GAIN
            //tsGainSetting = int(channelSettingValues[i][j]);
            if (channelSettingValues[i][j] == '0') tsGainSetting = 0;
            if (channelSettingValues[i][j] == '1') tsGainSetting = 1;
            if (channelSettingValues[i][j] == '2') tsGainSetting = 2;
            if (channelSettingValues[i][j] == '3') tsGainSetting = 3;
            if (channelSettingValues[i][j] == '4') tsGainSetting = 4;
            if (channelSettingValues[i][j] == '5') tsGainSetting = 5;
            if (channelSettingValues[i][j] == '6') tsGainSetting = 6;            
            break;
          case 2: //input type
            //tsInputTypeSetting = int(channelSettingValues[i][j]);
            if (channelSettingValues[i][j] == '0') tsInputTypeSetting = 0;
            if (channelSettingValues[i][j] == '1') tsInputTypeSetting = 1;
            if (channelSettingValues[i][j] == '2') tsInputTypeSetting = 2;
            if (channelSettingValues[i][j] == '3') tsInputTypeSetting = 3;
            if (channelSettingValues[i][j] == '4') tsInputTypeSetting = 4;
            if (channelSettingValues[i][j] == '5') tsInputTypeSetting = 5;
            if (channelSettingValues[i][j] == '6') tsInputTypeSetting = 6;
            if (channelSettingValues[i][j] == '7') tsInputTypeSetting = 7;
            break;
          case 3: //BIAS
            //tsBiasSetting = int(channelSettingValues[i][j]);
            if (channelSettingValues[i][j] == '0') tsBiasSetting = 0;
            if (channelSettingValues[i][j] == '1') tsBiasSetting = 1;     
            break;
          case 4: // SRB2
            //tsSrb2Setting = int(channelSettingValues[i][j]);
            if (channelSettingValues[i][j] == '0') tsSrb2Setting = 0;
            if (channelSettingValues[i][j] == '1') tsSrb2Setting = 1;
            break;
          case 5: // SRB1
            //tsSrb1Setting = channelSettingValues[i][j];
            if (channelSettingValues[i][j] == '0') tsSrb1Setting = 0;
            if (channelSettingValues[i][j] == '1') tsSrb1Setting = 1;
            break;
          }
      }  
      //Store all channel settings in Time Series JSON object, one channel at a time
      SaveTimeSeriesSettings.setInt("Channel_Number", (i+1));
      SaveTimeSeriesSettings.setInt("Active", tsActiveSetting);
      SaveTimeSeriesSettings.setInt("PGA Gain", int(tsGainSetting));
      SaveTimeSeriesSettings.setInt("Input Type", tsInputTypeSetting);
      SaveTimeSeriesSettings.setInt("Bias", tsBiasSetting);
      SaveTimeSeriesSettings.setInt("SRB2", tsSrb2Setting);
      SaveTimeSeriesSettings.setInt("SRB1", tsSrb1Setting);
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
            if (channelSettingValues[i][j] == '0')  tsActiveSetting = 0;
            if (channelSettingValues[i][j] == '1')  tsActiveSetting = 1;
            break;
          }
      }  
      SaveTimeSeriesSettings.setInt("Channel_Number", (i+1));
      SaveTimeSeriesSettings.setInt("Active", tsActiveSetting);
      SaveSettingsJSONData.setJSONObject(i + 1, SaveTimeSeriesSettings);
    }      
  }    
  //Make a second JSON object within our JSONArray to store Global settings for the GUI
  JSONObject SaveGlobalSettings = new JSONObject();
  
  
  SaveGlobalSettings.setInt("Current Layout", currentLayout);
  SaveGlobalSettings.setInt("Notch", dataProcessingNotchSave);
  SaveGlobalSettings.setInt("Bandpass Filter", dataProcessingBandpassSave);
  SaveGlobalSettings.setInt("Framerate", frameRateCounter);
  SaveGlobalSettings.setInt("Time Series Vert Scale", tsVertScaleSave);
  SaveGlobalSettings.setInt("Time Series Horiz Scale", tsHorizScaleSave);
  SaveGlobalSettings.setInt("Analog Read Vert Scale", arVertScaleSave);
  SaveGlobalSettings.setInt("Analog Read Horiz Scale", arHorizScaleSave);
  SaveGlobalSettings.setBoolean("Pulse Analog Read", w_pulsesensor.analogReadOn);
  SaveGlobalSettings.setBoolean("Analog Read", w_analogRead.analogReadOn);
  SaveGlobalSettings.setBoolean("Digital Read", w_digitalRead.digitalReadOn);
  SaveGlobalSettings.setBoolean("Marker Mode", w_markermode.markerModeOn);
  SaveGlobalSettings.setBoolean("Accelerometer", w_accelerometer.accelerometerModeOn);
  SaveGlobalSettings.setInt("Board Mode", cyton.getBoardMode());
  SaveSettingsJSONData.setJSONObject(slnchan + 1, SaveGlobalSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save FFT settings
  JSONObject SaveFFTSettings = new JSONObject();

  //Save FFT Max Freq Setting. The max frq variable is updated every time the user selects a dropdown in the FFT widget
  SaveFFTSettings.setInt("FFT Max Freq", fftMaxFrqSave);
  //Save FFT max uV Setting. The max uV variable is updated also when user selects dropdown in the FFT widget
  SaveFFTSettings.setInt("FFT Max uV", fftMaxuVSave);
  //Save FFT LogLin Setting. Same thing happens for LogLin
  SaveFFTSettings.setInt("FFT LogLin", fftLogLinSave);
  //Save FFT Smoothing Setting
  SaveFFTSettings.setInt("FFT Smoothing", fftSmoothingSave);
  //Save FFT Filter Setting
  if (isFFTFiltered == true)  fftFilterSave = 0;
  if (isFFTFiltered == false)  fftFilterSave = 1;  
  SaveFFTSettings.setInt("FFT Filter",  fftFilterSave);
  //Set the FFT JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+2, SaveFFTSettings); //next object will be set to slnchan+3, etc.  
  
  ///////////////////////////////////////////////Setup new JSON object to save Networking settings
  JSONObject SaveNetworkingSettings = new JSONObject();
  //Save Protocol
  SaveNetworkingSettings.setInt("Protocol", nwProtocolSave);//***Save User networking protocol mode
  
  switch(nwProtocolSave){
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
  SaveHeadplotSettings.setInt("HP_intensity", hpIntensitySave);
  //Save Headplot Polarity
  SaveHeadplotSettings.setInt("HP_polarity", hpPolaritySave);
  //Save Headplot contours
  SaveHeadplotSettings.setInt("HP_contours", hpContoursSave);
  //Save Headplot Smoothing Setting
  SaveHeadplotSettings.setInt("HP_smoothing", hpSmoothingSave);
  //Set the Headplot JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+4, SaveHeadplotSettings);

  ///////////////////////////////////////////////Setup new JSON object to save Headplot settings
  JSONObject SaveEMGSettings = new JSONObject();

  //Save EMG Smoothing
  SaveEMGSettings.setInt("EMG_smoothing", emgSmoothingSave);
  //Save EMG uV limit
  SaveEMGSettings.setInt("EMG_uVlimit", emguVLimSave);
  //Save EMG creep speed
  SaveEMGSettings.setInt("EMG_creepspeed", emgCreepSave);
  //Save EMG min delta uV
  SaveEMGSettings.setInt("EMG_minuV", emgMinDeltauVSave);
  //Set the EMG JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+5, SaveEMGSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save Headplot settings
  JSONObject SaveFocusSettings = new JSONObject();

  //Save Focus theme
  SaveFocusSettings.setInt("Focus_theme", focusThemeSave);
  //Save Focus keypress
  SaveFocusSettings.setInt("Focus_keypress", focusKeySave);
  //Set the Focus JSON Object
  SaveSettingsJSONData.setJSONObject(slnchan+6, SaveFocusSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save Widgets Active in respective Containers
  JSONObject SaveWidgetSettings = new JSONObject();
  
  int numActiveWidgets = 0;
  //Save what Widgets are active and respective Container number (see Containers.pde)
  for(int i = 0; i < wm.widgets.size(); i++){ //increment through all widgets
    if(wm.widgets.get(i).isActive){ //If a widget is active...
      numActiveWidgets++; //increment numActiveWidgets
      //println("Widget" + i + " is active");
      // activeWidgets.add(i); //keep track of the active widget
      int containerCountsave = wm.widgets.get(i).currentContainer;
      //println("Widget " + i + " is in Container " + containerCountsave);
      SaveWidgetSettings.setInt("Widget_"+i, containerCountsave); 
    } else if (!wm.widgets.get(i).isActive) { //If a widget is not active...
      SaveWidgetSettings.remove("Widget_"+i); //remove non-active widget from JSON
      //println("widget"+i+" is not active");
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
  saveJSONArray(SaveSettingsJSONData, "data/UserSettingsFile.json");

}  //End of Save GUI Settings function
  
  
  
///////////////////////////////  
//      Load GUI Settings    //
///////////////////////////////  
void loadGUISettings() {  
  //Load all saved User Settings from a JSON file
  LoadSettingsJSONData = loadJSONArray("UserSettingsFile.json");

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
  loadDatasource = LoadChanSettings.getInt("Data Source");
  println("Data source loaded: " + loadDatasource + ". Current data source: " + eegDataSource);
  //Print error if trying to load a different data source (ex. Live != Synthetic)
  if (loadDatasource != eegDataSource) {
    output("Data Source Error..."); 
    println("Data source being loaded doesn't match current data source.");
    dataSourceError = true; 
    return;
  } else {
    dataSourceError = false;
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
          channelsActiveArray[Active] + ", " + 
          gainSettingsArray[GainSettings] + ", " + 
          inputTypeArray[inputType] + ", " + 
          biasIncludeArray[BiasSetting] + ", " + 
          srb2SettingArray[SRB2Setting] + ", " + 
          srb1SettingArray[SRB1Setting]);
          
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
        println("Ch " + Channel + ", " + channelsActiveArray[Active]);
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
      fftMaxFrqLoad = LoadAllSettings.getInt("FFT Max Freq");
      fftMaxuVLoad = LoadAllSettings.getInt("FFT Max uV");
      fftLogLinLoad = LoadAllSettings.getInt("FFT LogLin");
      fftSmoothingLoad = LoadAllSettings.getInt("FFT Smoothing");
      fftFilterLoad = LoadAllSettings.getInt("FFT Filter");
      
      //Create a string array to print to console
      final String[] LoadedFFTSettings = {
        "FFT_Max Frequency: " + fftMaxFrqLoad, 
        "FFT_Max uV: " + fftMaxuVLoad,
        "FFT_Log/Lin: " + fftLogLinLoad,
        "FFT_Smoothing: " + fftSmoothingLoad,
        "FFT_Filter: " + fftFilterLoad,
        };
      //Print the FFT settings that have been loaded to the console  
      printArray(LoadedFFTSettings);
    }
    
    //parse Networking settings that appear after FFT settings
    if (i == slnchan + 2) {
      nwProtocolLoad = LoadAllSettings.getInt("Protocol");
      switch (nwProtocolLoad)  {
        case 0:
          nwDataType1 = LoadAllSettings.getInt("OSC_DataType1");
          nwDataType2 = LoadAllSettings.getInt("OSC_DataType2");
          nwDataType3 = LoadAllSettings.getInt("OSC_DataType3");        
          nwDataType4 = LoadAllSettings.getInt("OSC_DataType4"); 
          nwOscIp1Load = LoadAllSettings.getString("OSC_ip1");
          nwOscIp2Load = LoadAllSettings.getString("OSC_ip2");        
          nwOscIp3Load = LoadAllSettings.getString("OSC_ip3");        
          nwOscIp4Load = LoadAllSettings.getString("OSC_ip4");        
          nwOscPort1Load = LoadAllSettings.getString("OSC_port1");
          nwOscPort2Load = LoadAllSettings.getString("OSC_port2");        
          nwOscPort3Load = LoadAllSettings.getString("OSC_port3");        
          nwOscPort4Load = LoadAllSettings.getString("OSC_port4");                
          nwOscAddress1Load = LoadAllSettings.getString("OSC_address1");
          nwOscAddress2Load = LoadAllSettings.getString("OSC_address2");        
          nwOscAddress3Load = LoadAllSettings.getString("OSC_address3");        
          nwOscAddress4Load = LoadAllSettings.getString("OSC_address4");                
          nwOscFilter1Load = LoadAllSettings.getInt("OSC_filter1");
          nwOscFilter2Load = LoadAllSettings.getInt("OSC_filter2");        
          nwOscFilter3Load = LoadAllSettings.getInt("OSC_filter3");        
          nwOscFilter4Load = LoadAllSettings.getInt("OSC_filter4");  
          break;
        case 1:
          nwDataType1 = LoadAllSettings.getInt("UDP_DataType1");
          nwDataType2 = LoadAllSettings.getInt("UDP_DataType2");
          nwDataType3 = LoadAllSettings.getInt("UDP_DataType3");        
          nwUdpIp1Load = LoadAllSettings.getString("UDP_ip1");
          nwUdpIp2Load = LoadAllSettings.getString("UDP_ip2");        
          nwUdpIp3Load = LoadAllSettings.getString("UDP_ip3");            
          nwUdpPort1Load = LoadAllSettings.getString("UDP_port1");
          nwUdpPort2Load = LoadAllSettings.getString("UDP_port2");        
          nwUdpPort3Load = LoadAllSettings.getString("UDP_port3");                                            
          nwUdpFilter1Load = LoadAllSettings.getInt("UDP_filter1");
          nwUdpFilter2Load = LoadAllSettings.getInt("UDP_filter2");        
          nwUdpFilter3Load = LoadAllSettings.getInt("UDP_filter3");
          break;
        case 2:
          nwDataType1 = LoadAllSettings.getInt("LSL_DataType1");
          nwDataType2 = LoadAllSettings.getInt("LSL_DataType2");
          nwDataType3 = LoadAllSettings.getInt("LSL_DataType3");        
          nwLSLName1Load = LoadAllSettings.getString("LSL_name1");
          nwLSLName2Load = LoadAllSettings.getString("LSL_name2");        
          nwLSLName3Load = LoadAllSettings.getString("LSL_name3");            
          nwLSLType1Load = LoadAllSettings.getString("LSL_type1");
          nwLSLType2Load = LoadAllSettings.getString("LSL_type2");        
          nwLSLType3Load = LoadAllSettings.getString("LSL_type3");                       
          nwLSLNumChan1Load = LoadAllSettings.getString("LSL_numchan1");
          nwLSLNumChan2Load = LoadAllSettings.getString("LSL_numchan2");        
          nwLSLNumChan3Load = LoadAllSettings.getString("LSL_numchan3");                       
          nwLSLFilter1Load = LoadAllSettings.getInt("LSL_filter1");
          nwLSLFilter2Load = LoadAllSettings.getInt("LSL_filter2");        
          nwLSLFilter3Load = LoadAllSettings.getInt("LSL_filter3");             
          break;
        case 3:
          nwDataType1 = LoadAllSettings.getInt("Serial_DataType1");   
          nwSerialBaudRateLoad = LoadAllSettings.getInt("Serial_baudrate");   
          nwSerialFilter1Load = LoadAllSettings.getInt("Serial_filter1");
          break;
      } //end switch case for all networking types
    }// end parse loaded networking settings
    
    //parse the Headplot settings that appear after networking settings 
    if (i == slnchan + 3) {
      hpIntensityLoad = LoadAllSettings.getInt("HP_intensity");
      hpPolarityLoad = LoadAllSettings.getInt("HP_polarity");
      hpContoursLoad = LoadAllSettings.getInt("HP_contours");
      hpSmoothingLoad = LoadAllSettings.getInt("HP_smoothing");
      
      //Create a string array to print to console
      final String[] LoadedHPSettings = {
        "HP_intensity: " + hpIntensityLoad, 
        "HP_polarity: " + hpPolarityLoad,
        "HP_contours: " + hpContoursLoad,
        "HP_smoothing: " + hpSmoothingLoad,
        };
      //Print the Headplot settings 
      printArray(LoadedHPSettings);
    } 
    
    //parse the EMG settings that appear after Headplot settings
    if (i == slnchan + 4) {
      emgSmoothingLoad = LoadAllSettings.getInt("EMG_smoothing");
      emguVLimLoad = LoadAllSettings.getInt("EMG_uVlimit");
      emgCreepLoad = LoadAllSettings.getInt("EMG_creepspeed");
      emgMinDeltauVLoad = LoadAllSettings.getInt("EMG_minuV");
      
      //Create a string array to print to console
      final String[] LoadedEMGSettings = {
        "EMG_smoothing: " + emgSmoothingLoad, 
        "EMG_uVlimit: " + emguVLimLoad,
        "EMG_creepspeed: " + emgCreepLoad,
        "EMG_minuV: " + emgMinDeltauVLoad,
        };
      //Print the EMG settings 
      printArray(LoadedEMGSettings);
    }
    
    //parse the Focus settings that appear after EMG settings
      if (i == slnchan + 5) {
      focusThemeLoad = LoadAllSettings.getInt("Focus_theme");
      focusKeyLoad = LoadAllSettings.getInt("Focus_keypress");
      
      //Create a string array to print to console
      final String[] LoadedFocusSettings = {
        "Focus_theme: " + focusThemeLoad, 
        "Focus_keypress: " + focusKeyLoad,
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
      
      //int numActiveWidgets = 0; //reset the counter
      for(int w = 0; w < wm.widgets.size(); w++){ //increment through all widgets
        if(wm.widgets.get(w).isActive){ //If a widget is active...
          println("Deactivating widget [" + w + "]");
          wm.widgets.get(w).isActive = false;
          //numActiveWidgets++; //counter the number of de-activated widgets
        }
      }
      //println(numActiveWidgets
    
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
  topNav.filtNotchButton.but_txt = "Notch\n" + dataProcessingNotcharray[loadNotchsetting];
  //Apply Bandpass filter
  dataProcessing.currentFilt_ind = loadBandpasssetting;
  topNav.filtBPButton.but_txt = "BP Filt\n" + dataProcessingBParray[loadBandpasssetting]; //this works
  println(dataProcessingBParray[loadBandpasssetting]);
  
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
    if (checkForSuccessTS != null) { // If we receive a return code...
      println("Return code:" + checkForSuccessTS);
      String[] list = split(checkForSuccessTS, ',');
      int successcode = Integer.parseInt(list[1]);
      if (successcode == RESP_SUCCESS) {i++; checkForSuccessTS = null;} //when successful, iterate to next channel(i++) and set Check to null
    }
    //delay(10);// Works on 8 chan sometimes
    delay(100); // Works on 8 and 16 channels 3/3 trials applying settings to all channels. Tested by setting gain 1x and loading 24x.
  }    
} 

void LoadApplyWidgetDropdownText() {
  
  ////////Apply Time Series widget settings
  VertScale_TS(loadTimeSeriesVertScale);// changes back-end
    w_timeSeries.cp5_widget.getController("VertScale_TS").getCaptionLabel().setText(tsVertScaleArray[loadTimeSeriesVertScale]); //changes front-end

  Duration(loadTimeSeriesHorizScale);
    w_timeSeries.cp5_widget.getController("Duration").getCaptionLabel().setText(tsHorizScaleArray[loadTimeSeriesHorizScale]); 
  
  //////Apply FFT settings
  MaxFreq(fftMaxFrqLoad); //This changes the back-end
    w_fft.cp5_widget.getController("MaxFreq").getCaptionLabel().setText(fftMaxFrqArray[fftMaxFrqLoad]); //This changes front-end... etc.

  VertScale(fftMaxuVLoad);
    w_fft.cp5_widget.getController("VertScale").getCaptionLabel().setText(fftVertScaleArray[fftMaxuVLoad]);

  LogLin(fftLogLinLoad);
     w_fft.cp5_widget.getController("LogLin").getCaptionLabel().setText(fftLogLinArray[fftLogLinLoad]); 
  
  Smoothing(fftSmoothingLoad);
     w_fft.cp5_widget.getController("Smoothing").getCaptionLabel().setText(fftSmoothingArray[fftSmoothingLoad]); 
    
  UnfiltFilt(fftFilterLoad);
     w_fft.cp5_widget.getController("UnfiltFilt").getCaptionLabel().setText(fftFilterArray[fftFilterLoad]);
  
  ////////Apply Analog Read settings
  VertScale_AR(loadAnalogReadVertScale);
    w_analogRead.cp5_widget.getController("VertScale_AR").getCaptionLabel().setText(arVertScaleArray[loadAnalogReadVertScale]);

  Duration_AR(loadAnalogReadHorizScale);
    w_analogRead.cp5_widget.getController("Duration_AR").getCaptionLabel().setText(arHorizScaleArray[loadAnalogReadHorizScale]);
  
  ////////////////////////////Apply Headplot settings
  Intensity(hpIntensityLoad);
    w_headPlot.cp5_widget.getController("Intensity").getCaptionLabel().setText(hpIntensityArray[hpIntensityLoad]);

  Polarity(hpPolarityLoad);
    w_headPlot.cp5_widget.getController("Polarity").getCaptionLabel().setText(hpPolarityArray[hpPolarityLoad]);

  ShowContours(hpContoursLoad);
    w_headPlot.cp5_widget.getController("ShowContours").getCaptionLabel().setText(hpContoursArray[hpContoursLoad]);
   
  SmoothingHeadPlot(hpSmoothingLoad);
    w_headPlot.cp5_widget.getController("SmoothingHeadPlot").getCaptionLabel().setText(hpSmoothingArray[hpSmoothingLoad]);
    
  ////////////////////////////Apply EMG settings
  SmoothEMG(emgSmoothingLoad);
    w_emg.cp5_widget.getController("SmoothEMG").getCaptionLabel().setText(emgSmoothingArray[emgSmoothingLoad]);

  uVLimit(emguVLimLoad);
    w_emg.cp5_widget.getController("uVLimit").getCaptionLabel().setText(emguVLimArray[emguVLimLoad]);

  CreepSpeed(emgCreepLoad);
    w_emg.cp5_widget.getController("CreepSpeed").getCaptionLabel().setText(emgCreepArray[emgCreepLoad]);

  minUVRange(emgMinDeltauVLoad);
    w_emg.cp5_widget.getController("minUVRange").getCaptionLabel().setText(emgMinDeltauVArray[emgMinDeltauVLoad]);
    
   ////////////////////////////Apply Focus settings
  ChooseFocusColor(focusThemeLoad);
    w_focus.cp5_widget.getController("ChooseFocusColor").getCaptionLabel().setText(focusThemeArray[focusThemeLoad]);

  StrokeKeyWhenFocused(focusKeyLoad);
    w_focus.cp5_widget.getController("StrokeKeyWhenFocused").getCaptionLabel().setText(focusKeyArray[focusKeyLoad]);  
    
  ///////////Apply Networking Settings
  //Update protocol with loaded value
  Protocol(nwProtocolLoad);
  //Update dropdowns and textfields in the Networking widget with loaded values
  w_networking.cp5_widget.getController("Protocol").getCaptionLabel().setText(nwProtocolArray[nwProtocolLoad]); //Reference the dropdown from the appropriate widget
  switch (nwProtocolLoad) {
    case 0:  //Apply OSC if loaded
      w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(nwDataTypesArray[nwDataType1]); //Set text on frontend
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setValue(nwDataType1); //Set value in backend
      w_networking.cp5_networking_dropdowns.getController("dataType2").getCaptionLabel().setText(nwDataTypesArray[nwDataType2]); //etc...
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setValue(nwDataType2);      
      w_networking.cp5_networking_dropdowns.getController("dataType3").getCaptionLabel().setText(nwDataTypesArray[nwDataType3]);
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setValue(nwDataType3);     
      w_networking.cp5_networking_dropdowns.getController("dataType4").getCaptionLabel().setText(nwDataTypesArray[nwDataType4]);
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").setValue(nwDataType4);
      w_networking.cp5_networking.get(Textfield.class, "osc_ip1").setText(nwOscIp1Load); //Simply set the text for text boxes
      w_networking.cp5_networking.get(Textfield.class, "osc_ip2").setText(nwOscIp2Load); //The strings are referenced on command
      w_networking.cp5_networking.get(Textfield.class, "osc_ip3").setText(nwOscIp3Load);
      w_networking.cp5_networking.get(Textfield.class, "osc_ip4").setText(nwOscIp4Load);  
      w_networking.cp5_networking.get(Textfield.class, "osc_port1").setText(nwOscPort1Load);
      w_networking.cp5_networking.get(Textfield.class, "osc_port2").setText(nwOscPort2Load);
      w_networking.cp5_networking.get(Textfield.class, "osc_port3").setText(nwOscPort3Load);
      w_networking.cp5_networking.get(Textfield.class, "osc_port4").setText(nwOscPort4Load);    
      w_networking.cp5_networking.get(Textfield.class, "osc_address1").setText(nwOscAddress1Load);
      w_networking.cp5_networking.get(Textfield.class, "osc_address2").setText(nwOscAddress2Load);
      w_networking.cp5_networking.get(Textfield.class, "osc_address3").setText(nwOscAddress3Load);
      w_networking.cp5_networking.get(Textfield.class, "osc_address4").setText(nwOscAddress4Load);      
      w_networking.cp5_networking.get(RadioButton.class, "filter1").activate(nwOscFilter1Load);
      w_networking.cp5_networking.get(RadioButton.class, "filter2").activate(nwOscFilter2Load);  
      w_networking.cp5_networking.get(RadioButton.class, "filter3").activate(nwOscFilter3Load);
      w_networking.cp5_networking.get(RadioButton.class, "filter4").activate(nwOscFilter4Load); 
      break;
    case 1:  //Apply UDP if loaded
      println("apply UDP nw mode");
      w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(nwDataTypesArray[nwDataType1]); //Set text on frontend
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setValue(nwDataType1); //Set value in backend
      w_networking.cp5_networking_dropdowns.getController("dataType2").getCaptionLabel().setText(nwDataTypesArray[nwDataType2]); //etc...
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setValue(nwDataType2);   
      w_networking.cp5_networking_dropdowns.getController("dataType3").getCaptionLabel().setText(nwDataTypesArray[nwDataType3]);
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setValue(nwDataType3);     
      w_networking.cp5_networking.get(Textfield.class, "udp_ip1").setText(nwUdpIp1Load);
      w_networking.cp5_networking.get(Textfield.class, "udp_ip2").setText(nwUdpIp2Load);
      w_networking.cp5_networking.get(Textfield.class, "udp_ip3").setText(nwUdpIp3Load);  
      w_networking.cp5_networking.get(Textfield.class, "udp_port1").setText(nwUdpPort1Load);
      w_networking.cp5_networking.get(Textfield.class, "udp_port2").setText(nwUdpPort2Load);
      w_networking.cp5_networking.get(Textfield.class, "udp_port3").setText(nwUdpPort3Load);     
      w_networking.cp5_networking.get(RadioButton.class, "filter1").activate(nwUdpFilter1Load);
      w_networking.cp5_networking.get(RadioButton.class, "filter2").activate(nwUdpFilter2Load);  
      w_networking.cp5_networking.get(RadioButton.class, "filter3").activate(nwUdpFilter3Load);    
      break;
    case 2:  //Apply LSL if loaded 
      println("apply LSL nw mode");
      w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(nwDataTypesArray[nwDataType1]); //Set text on frontend
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setValue(nwDataType1); //Set value in backend
      w_networking.cp5_networking_dropdowns.getController("dataType2").getCaptionLabel().setText(nwDataTypesArray[nwDataType2]); //etc...
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setValue(nwDataType2);     
      w_networking.cp5_networking_dropdowns.getController("dataType3").getCaptionLabel().setText(nwDataTypesArray[nwDataType3]);
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setValue(nwDataType3);      
      w_networking.cp5_networking.get(Textfield.class, "lsl_name1").setText(nwLSLName1Load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_name2").setText(nwLSLName2Load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_name3").setText(nwLSLName3Load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_type1").setText(nwLSLType1Load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_type2").setText(nwLSLType2Load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_type3").setText(nwLSLType3Load);  
      w_networking.cp5_networking.get(Textfield.class, "lsl_numchan1").setText(nwLSLNumChan1Load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_numchan2").setText(nwLSLNumChan2Load);
      w_networking.cp5_networking.get(Textfield.class, "lsl_numchan3").setText(nwLSLNumChan3Load);     
      w_networking.cp5_networking.get(RadioButton.class, "filter1").activate(nwLSLFilter1Load);
      w_networking.cp5_networking.get(RadioButton.class, "filter2").activate(nwLSLFilter2Load);  
      w_networking.cp5_networking.get(RadioButton.class, "filter3").activate(nwLSLFilter3Load);       
      break;  
    case 3:  //Apply Serial if loaded
      println("apply Serial nw mode");
      w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(nwDataTypesArray[nwDataType1]); //Set text on frontend
      w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setValue(nwDataType1); //Set value in backend
      w_networking.cp5_networking_baudRate.getController("baud_rate").getCaptionLabel().setText(nwBaudRatesArray[nwSerialBaudRateLoad]); //Set text 
      w_networking.cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").setValue(nwSerialBaudRateLoad); //Set value in backend
      w_networking.cp5_networking.get(RadioButton.class, "filter1").activate(nwSerialFilter1Load);      
      break;    
  }//end switch-case for networking settings for all networking protocols
  
  ////////////////////////////////////////////////////////////
  //    Apply more loaded widget settings above this line   // 
  
  //w_networking.cp5_networking.get(Textfield.class, "osc_ip1").setText("Bananas"); //this works
  
} //end of LoadApplyWidgetDropdownText()
