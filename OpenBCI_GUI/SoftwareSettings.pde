//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
                       This sketch saves and loads the following User Settings:    
                       -- All Time Series widget settings in Live, Playback, and Synthetic modes
                       -- All FFT widget settings
                       -- Default Layout, Notch, Bandpass Filter, Framerate, Board Mode
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

JSONArray saveSettingsJSONData;
JSONArray loadSettingsJSONData;

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
int loadBoardMode;

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
String [] loadedWidgetsArray;
int loadFramerate;
int loadDatasource;
Boolean dataSourceError = false;

///////////////////////////////  
//      Save GUI Settings    //
///////////////////////////////  
void saveGUISettings() {
  
  //Set up a JSON array
  saveSettingsJSONData = new JSONArray();
  
  //Save the number of channels being used and eegDataSource in the first object
  JSONObject saveNumChannels = new JSONObject();
  saveNumChannels.setInt("Channels", slnchan);
  saveNumChannels.setInt("Data Source", eegDataSource);
  //println(slnchan);
  saveSettingsJSONData.setJSONObject(0, saveNumChannels);
  
  ////////////////////////////////////////////////////////////////////////////////////
  //                 Case for saving TS settings in Live Data Modes                 //
  if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON)  {
    
    //Save all of the channel settings for number of Time Series channels being used
    for (int i = 0; i < slnchan; i++) {     
      //Make a JSON Object for each of the Time Series Channels
      JSONObject saveTimeSeriesSettings = new JSONObject();
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
      saveTimeSeriesSettings.setInt("Channel_Number", (i+1));
      saveTimeSeriesSettings.setInt("Active", tsActiveSetting);
      saveTimeSeriesSettings.setInt("PGA Gain", int(tsGainSetting));
      saveTimeSeriesSettings.setInt("Input Type", tsInputTypeSetting);
      saveTimeSeriesSettings.setInt("Bias", tsBiasSetting);
      saveTimeSeriesSettings.setInt("SRB2", tsSrb2Setting);
      saveTimeSeriesSettings.setInt("SRB1", tsSrb1Setting);
      saveSettingsJSONData.setJSONObject(i + 1, saveTimeSeriesSettings);
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //              Case for saving TS settings when in Synthetic or Playback data modes                       //
  if(eegDataSource == DATASOURCE_PLAYBACKFILE || eegDataSource == DATASOURCE_SYNTHETIC) {
    for (int i = 0; i < slnchan; i++) {
      
      //Make a JSON Object for each of the Time Series Channels
      JSONObject saveTimeSeriesSettings = new JSONObject();
     
      for (int j = 0; j < 1; j++) {
        switch(j) { 
          case 0: //Just save what channels are active
            if (channelSettingValues[i][j] == '0')  tsActiveSetting = 0;
            if (channelSettingValues[i][j] == '1')  tsActiveSetting = 1;
            break;
          }
      }  
      saveTimeSeriesSettings.setInt("Channel_Number", (i+1));
      saveTimeSeriesSettings.setInt("Active", tsActiveSetting);
      saveSettingsJSONData.setJSONObject(i + 1, saveTimeSeriesSettings);
    }      
  }    
  //Make a second JSON object within our JSONArray to store Global settings for the GUI
  JSONObject saveGlobalSettings = new JSONObject();
  
  
  saveGlobalSettings.setInt("Current Layout", currentLayout);
  saveGlobalSettings.setInt("Notch", dataProcessingNotchSave);
  saveGlobalSettings.setInt("Bandpass Filter", dataProcessingBandpassSave);
  saveGlobalSettings.setInt("Framerate", frameRateCounter);
  saveGlobalSettings.setInt("Time Series Vert Scale", tsVertScaleSave);
  saveGlobalSettings.setInt("Time Series Horiz Scale", tsHorizScaleSave);
  saveGlobalSettings.setInt("Analog Read Vert Scale", arVertScaleSave);
  saveGlobalSettings.setInt("Analog Read Horiz Scale", arHorizScaleSave);
  saveGlobalSettings.setBoolean("Pulse Analog Read", w_pulsesensor.analogReadOn);
  saveGlobalSettings.setBoolean("Analog Read", w_analogRead.analogReadOn);
  saveGlobalSettings.setBoolean("Digital Read", w_digitalRead.digitalReadOn);
  saveGlobalSettings.setBoolean("Marker Mode", w_markermode.markerModeOn);
  saveGlobalSettings.setBoolean("Accelerometer", w_accelerometer.accelerometerModeOn);
  saveGlobalSettings.setInt("Board Mode", cyton.curBoardMode);
  saveSettingsJSONData.setJSONObject(slnchan + 1, saveGlobalSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save FFT settings
  JSONObject saveFFTSettings = new JSONObject();

  //Save FFT Max Freq Setting. The max frq variable is updated every time the user selects a dropdown in the FFT widget
  saveFFTSettings.setInt("FFT Max Freq", fftMaxFrqSave);
  //Save FFT max uV Setting. The max uV variable is updated also when user selects dropdown in the FFT widget
  saveFFTSettings.setInt("FFT Max uV", fftMaxuVSave);
  //Save FFT LogLin Setting. Same thing happens for LogLin
  saveFFTSettings.setInt("FFT LogLin", fftLogLinSave);
  //Save FFT Smoothing Setting
  saveFFTSettings.setInt("FFT Smoothing", fftSmoothingSave);
  //Save FFT Filter Setting
  if (isFFTFiltered == true)  fftFilterSave = 0;
  if (isFFTFiltered == false)  fftFilterSave = 1;  
  saveFFTSettings.setInt("FFT Filter",  fftFilterSave);
  //Set the FFT JSON Object
  saveSettingsJSONData.setJSONObject(slnchan+2, saveFFTSettings); //next object will be set to slnchan+3, etc.  
  
  ///////////////////////////////////////////////Setup new JSON object to save Networking settings
  JSONObject saveNetworkingSettings = new JSONObject();
  //Save Protocol
  saveNetworkingSettings.setInt("Protocol", nwProtocolSave);//***Save User networking protocol mode
  
  switch(nwProtocolSave){
    case 0:
      //Save Data Types for OSC
      saveNetworkingSettings.setInt("OSC_DataType1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));
      saveNetworkingSettings.setInt("OSC_DataType2", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").getValue()));
      saveNetworkingSettings.setInt("OSC_DataType3", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").getValue()));
      saveNetworkingSettings.setInt("OSC_DataType4", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").getValue()));
      //Save IP addresses for OSC
      saveNetworkingSettings.setString("OSC_ip1", w_networking.cp5_networking.get(Textfield.class, "osc_ip1").getText());
      saveNetworkingSettings.setString("OSC_ip2", w_networking.cp5_networking.get(Textfield.class, "osc_ip2").getText());
      saveNetworkingSettings.setString("OSC_ip3", w_networking.cp5_networking.get(Textfield.class, "osc_ip3").getText());  
      saveNetworkingSettings.setString("OSC_ip4", w_networking.cp5_networking.get(Textfield.class, "osc_ip4").getText());
      //Save Ports for OSC
      saveNetworkingSettings.setString("OSC_port1", w_networking.cp5_networking.get(Textfield.class, "osc_port1").getText());
      saveNetworkingSettings.setString("OSC_port2", w_networking.cp5_networking.get(Textfield.class, "osc_port2").getText());
      saveNetworkingSettings.setString("OSC_port3", w_networking.cp5_networking.get(Textfield.class, "osc_port3").getText());  
      saveNetworkingSettings.setString("OSC_port4", w_networking.cp5_networking.get(Textfield.class, "osc_port4").getText());
      //Save addresses for OSC
      saveNetworkingSettings.setString("OSC_address1", w_networking.cp5_networking.get(Textfield.class, "osc_address1").getText());
      saveNetworkingSettings.setString("OSC_address2", w_networking.cp5_networking.get(Textfield.class, "osc_address2").getText());
      saveNetworkingSettings.setString("OSC_address3", w_networking.cp5_networking.get(Textfield.class, "osc_address3").getText());  
      saveNetworkingSettings.setString("OSC_address4", w_networking.cp5_networking.get(Textfield.class, "osc_address4").getText());
      //Save filters for OSC
      saveNetworkingSettings.setInt("OSC_filter1", int(w_networking.cp5_networking.get(RadioButton.class, "filter1").getValue()));
      saveNetworkingSettings.setInt("OSC_filter2", int(w_networking.cp5_networking.get(RadioButton.class, "filter2").getValue()));
      saveNetworkingSettings.setInt("OSC_filter3", int(w_networking.cp5_networking.get(RadioButton.class, "filter3").getValue()));
      saveNetworkingSettings.setInt("OSC_filter4", int(w_networking.cp5_networking.get(RadioButton.class, "filter4").getValue()));
      break;
    case 1:
      //Save UDP data types
      saveNetworkingSettings.setInt("UDP_DataType1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));
      saveNetworkingSettings.setInt("UDP_DataType2", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").getValue()));
      saveNetworkingSettings.setInt("UDP_DataType3", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").getValue()));      
      //Save UDP IPs
      saveNetworkingSettings.setString("UDP_ip1", w_networking.cp5_networking.get(Textfield.class, "udp_ip1").getText());
      saveNetworkingSettings.setString("UDP_ip2", w_networking.cp5_networking.get(Textfield.class, "udp_ip2").getText());
      saveNetworkingSettings.setString("UDP_ip3", w_networking.cp5_networking.get(Textfield.class, "udp_ip3").getText());      
      //Save UDP Ports
      saveNetworkingSettings.setString("UDP_port1", w_networking.cp5_networking.get(Textfield.class, "udp_port1").getText());
      saveNetworkingSettings.setString("UDP_port2", w_networking.cp5_networking.get(Textfield.class, "udp_port2").getText());
      saveNetworkingSettings.setString("UDP_port3", w_networking.cp5_networking.get(Textfield.class, "udp_port3").getText());        
      //Save UDP Filters
      saveNetworkingSettings.setInt("UDP_filter1", int(w_networking.cp5_networking.get(RadioButton.class, "filter1").getValue()));
      saveNetworkingSettings.setInt("UDP_filter2", int(w_networking.cp5_networking.get(RadioButton.class, "filter2").getValue()));
      saveNetworkingSettings.setInt("UDP_filter3", int(w_networking.cp5_networking.get(RadioButton.class, "filter3").getValue()));      
      break;
    case 2:   
      //Save LSL data types
      saveNetworkingSettings.setInt("LSL_DataType1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));
      saveNetworkingSettings.setInt("LSL_DataType2", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").getValue()));
      saveNetworkingSettings.setInt("LSL_DataType3", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").getValue()));            
      //Save LSL stream names
      saveNetworkingSettings.setString("LSL_name1", w_networking.cp5_networking.get(Textfield.class, "lsl_name1").getText());
      saveNetworkingSettings.setString("LSL_name2", w_networking.cp5_networking.get(Textfield.class, "lsl_name2").getText());
      saveNetworkingSettings.setString("LSL_name3", w_networking.cp5_networking.get(Textfield.class, "lsl_name3").getText());            
      //Save LSL type names
      saveNetworkingSettings.setString("LSL_type1", w_networking.cp5_networking.get(Textfield.class, "lsl_type1").getText());
      saveNetworkingSettings.setString("LSL_type2", w_networking.cp5_networking.get(Textfield.class, "lsl_type2").getText());
      saveNetworkingSettings.setString("LSL_type3", w_networking.cp5_networking.get(Textfield.class, "lsl_type3").getText());                  
      //Save LSL stream # Chan
      saveNetworkingSettings.setString("LSL_numchan1", w_networking.cp5_networking.get(Textfield.class, "lsl_numchan1").getText());
      saveNetworkingSettings.setString("LSL_numchan2", w_networking.cp5_networking.get(Textfield.class, "lsl_numchan2").getText());
      saveNetworkingSettings.setString("LSL_numchan3", w_networking.cp5_networking.get(Textfield.class, "lsl_numchan3").getText());          
      //Save LSL filters
      saveNetworkingSettings.setInt("LSL_filter1", int(w_networking.cp5_networking.get(RadioButton.class, "filter1").getValue()));
      saveNetworkingSettings.setInt("LSL_filter2", int(w_networking.cp5_networking.get(RadioButton.class, "filter2").getValue()));
      saveNetworkingSettings.setInt("LSL_filter3", int(w_networking.cp5_networking.get(RadioButton.class, "filter3").getValue()));            
      break;
    case 3:
      //Save Serial data type
      saveNetworkingSettings.setInt("Serial_DataType1", int(w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").getValue()));      
      //Save Serial baud rate. Not saving serial port. cp5_networking_baudRate.
      saveNetworkingSettings.setInt("Serial_baudrate", int(w_networking.cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").getValue()));      
      //Save Serial filter
      saveNetworkingSettings.setInt("Serial_filter1", int(w_networking.cp5_networking.get(RadioButton.class, "filter1").getValue()));      
      break;
  }//end of switch
  //Set Networking Settings JSON Object
  saveSettingsJSONData.setJSONObject(slnchan+3, saveNetworkingSettings);  

  ///////////////////////////////////////////////Setup new JSON object to save Headplot settings
  JSONObject saveHeadplotSettings = new JSONObject();

  //Save Headplot Intesity
  saveHeadplotSettings.setInt("HP_intensity", hpIntensitySave);
  //Save Headplot Polarity
  saveHeadplotSettings.setInt("HP_polarity", hpPolaritySave);
  //Save Headplot contours
  saveHeadplotSettings.setInt("HP_contours", hpContoursSave);
  //Save Headplot Smoothing Setting
  saveHeadplotSettings.setInt("HP_smoothing", hpSmoothingSave);
  //Set the Headplot JSON Object
  saveSettingsJSONData.setJSONObject(slnchan+4, saveHeadplotSettings);

  ///////////////////////////////////////////////Setup new JSON object to save Headplot settings
  JSONObject saveEMGSettings = new JSONObject();

  //Save EMG Smoothing
  saveEMGSettings.setInt("EMG_smoothing", emgSmoothingSave);
  //Save EMG uV limit
  saveEMGSettings.setInt("EMG_uVlimit", emguVLimSave);
  //Save EMG creep speed
  saveEMGSettings.setInt("EMG_creepspeed", emgCreepSave);
  //Save EMG min delta uV
  saveEMGSettings.setInt("EMG_minuV", emgMinDeltauVSave);
  //Set the EMG JSON Object
  saveSettingsJSONData.setJSONObject(slnchan+5, saveEMGSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save Headplot settings
  JSONObject saveFocusSettings = new JSONObject();

  //Save Focus theme
  saveFocusSettings.setInt("Focus_theme", focusThemeSave);
  //Save Focus keypress
  saveFocusSettings.setInt("Focus_keypress", focusKeySave);
  //Set the Focus JSON Object
  saveSettingsJSONData.setJSONObject(slnchan+6, saveFocusSettings);
  
  ///////////////////////////////////////////////Setup new JSON object to save Widgets Active in respective Containers
  JSONObject saveWidgetSettings = new JSONObject();
  
  int numActiveWidgets = 0;
  //Save what Widgets are active and respective Container number (see Containers.pde)
  for(int i = 0; i < wm.widgets.size(); i++){ //increment through all widgets
    if(wm.widgets.get(i).isActive){ //If a widget is active...
      numActiveWidgets++; //increment numActiveWidgets
      //println("Widget" + i + " is active");
      // activeWidgets.add(i); //keep track of the active widget
      int containerCountsave = wm.widgets.get(i).currentContainer;
      //println("Widget " + i + " is in Container " + containerCountsave);
      saveWidgetSettings.setInt("Widget_"+i, containerCountsave); 
    } else if (!wm.widgets.get(i).isActive) { //If a widget is not active...
      saveWidgetSettings.remove("Widget_"+i); //remove non-active widget from JSON
      //println("widget"+i+" is not active");
    }
  } 
  println(numActiveWidgets + " active widgets saved!");
  //Print what widgets are in the containers used by current layout for only the number of active widgets
  for(int i = 0; i < numActiveWidgets; i++){
        //int containerCounter = wm.layouts.get(currentLayout-1).containerInts[i];
        //println("Container " + containerCounter + " is available");          
  }  
  
  saveSettingsJSONData.setJSONObject(slnchan+7, saveWidgetSettings);
  
  /////////////////////////////////////////////////////////////////////////////////
  ///ADD more global settings above this line in the same formats as above/////////

  //Let's save the JSON array to a file!
  saveJSONArray(saveSettingsJSONData, "data/UserSettingsFile.json");

}  //End of Save GUI Settings function

///////////////////////////////  
//      Load GUI Settings    //
///////////////////////////////  
void loadGUISettings() {  
  //Load all saved User Settings from a JSON file
  loadSettingsJSONData = loadJSONArray("UserSettingsFile.json");

  //Check the number of channels saved to json first!
  JSONObject loadChanSettings = loadSettingsJSONData.getJSONObject(0); 
  numChanloaded = loadChanSettings.getInt("Channels");
  //Print error if trying to load a different number of channels
  if (numChanloaded != slnchan) {
    output("Channel Number Error..."); 
    println("Channels being loaded don't match channels being used!");
    chanNumError = true; 
    return;
  } else {
    chanNumError = false;
  }
  loadDatasource = loadChanSettings.getInt("Data Source");
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
  for (int i = 0; i < loadSettingsJSONData.size() - 1; i++) {
    
   //Make a JSON object, we only need one to load the remaining data, and call it loadAllSettings
   JSONObject loadAllSettings = loadSettingsJSONData.getJSONObject(i + 1); 
   
   //Case for loading time series settings in Live Data mode
   if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON)  { 
      //parse the channel settings first for only the number of channels being used
      if (i < slnchan) {    
        int channel = loadAllSettings.getInt("Channel_Number") - 1; //when using with channelSettingsValues, will need to subtract 1
        int active = loadAllSettings.getInt("Active");
        int gainSettings = loadAllSettings.getInt("PGA Gain");
        int inputType = loadAllSettings.getInt("Input Type");
        int biasSetting = loadAllSettings.getInt("Bias");
        int srb2Setting = loadAllSettings.getInt("SRB2");
        int srb1Setting = loadAllSettings.getInt("SRB1");
        println("Ch " + channel + ", " + 
          channelsActiveArray[active] + ", " + 
          gainSettingsArray[gainSettings] + ", " + 
          inputTypeArray[inputType] + ", " + 
          biasIncludeArray[biasSetting] + ", " + 
          srb2SettingArray[srb2Setting] + ", " + 
          srb1SettingArray[srb1Setting]);
          
        //Use channelSettingValues variable to activate these settings once they are loaded from JSON file 
        if (active == 0) {channelSettingValues[i][0] = '0'; activateChannel(channel);}// power down == false, set color to vibrant
        if (active == 1) {channelSettingValues[i][0] = '1'; deactivateChannel(channel);} // power down == true, set color to dark gray, indicating power down
             
        //Hopefully This can be shortened into somthing more efficient, there is a datatype conversion involved. Simple if-then works for now.
        //channelSettingValues[i][1] = char(gainSettings);
        if (gainSettings == 0) channelSettingValues[i][1] = '0';
        if (gainSettings == 1) channelSettingValues[i][1] = '1';
        if (gainSettings == 2) channelSettingValues[i][1] = '2';
        if (gainSettings == 3) channelSettingValues[i][1] = '3';        
        if (gainSettings == 4) channelSettingValues[i][1] = '4';
        if (gainSettings == 5) channelSettingValues[i][1] = '5';
        if (gainSettings == 6) channelSettingValues[i][1] = '6';   
            
        if (inputType == 0) channelSettingValues[i][2] = '0';
        if (inputType == 1) channelSettingValues[i][2] = '1';
        if (inputType == 2) channelSettingValues[i][2] = '2';
        if (inputType == 3) channelSettingValues[i][2] = '3';        
        if (inputType == 4) channelSettingValues[i][2] = '4';
        if (inputType == 5) channelSettingValues[i][2] = '5';        
        if (inputType == 6) channelSettingValues[i][2] = '6';
        if (inputType == 7) channelSettingValues[i][2] = '7';
        
        if (biasSetting == 0) channelSettingValues[i][3] = '0';
        if (biasSetting == 1) channelSettingValues[i][3] = '1';
        
        if (srb2Setting == 0) channelSettingValues[i][4] = '0';
        if (srb2Setting == 1) channelSettingValues[i][4] = '1';

        if (srb1Setting == 0) channelSettingValues[i][5] = '0';
        if (srb1Setting == 1) channelSettingValues[i][5] = '1';     
      }
    }//end Cyton/Ganglion case
      
    //////////Case for loading Time Series settings when in Synthetic or Playback data modes
    if(eegDataSource == DATASOURCE_SYNTHETIC || eegDataSource == DATASOURCE_PLAYBACKFILE) {
      //parse the channel settings first for only the number of channels being used
      if (i < slnchan) {   
        int channel = loadAllSettings.getInt("Channel_Number") - 1; //when using with channelSettingsValues, will need to subtract 1
        int active = loadAllSettings.getInt("Active");
        println("Ch " + channel + ", " + channelsActiveArray[active]);
        //Use channelSettingValues variable to activate these settings once they are loaded from JSON file 
        if (active == 0) {channelSettingValues[i][0] = '0'; activateChannel(channel);}// power down == false, set color to vibrant
        if (active == 1) {channelSettingValues[i][0] = '1'; deactivateChannel(channel);} // power down == true, set color to dark gray, indicating power down         
      }      
    } //end of Playback/Synthetic case
    
    //parse the global settings that appear after the channel settings 
    if (i == slnchan) {
      loadLayoutsetting = loadAllSettings.getInt("Current Layout");
      loadNotchsetting = loadAllSettings.getInt("Notch");
      loadBandpasssetting = loadAllSettings.getInt("Bandpass Filter");
      loadFramerate = loadAllSettings.getInt("Framerate");
      loadTimeSeriesVertScale = loadAllSettings.getInt("Time Series Vert Scale");
      loadTimeSeriesHorizScale = loadAllSettings.getInt("Time Series Horiz Scale");
      loadAnalogReadVertScale = loadAllSettings.getInt("Analog Read Vert Scale");
      loadAnalogReadHorizScale = loadAllSettings.getInt("Analog Read Horiz Scale");
      loadBoardMode = loadAllSettings.getInt("Board Mode");
      //Load more global settings after this line, if needed
      
      //Create a string array to print global settings to console
      final String[] loadedGlobalSettings = {
        "Using Layout Number: " + loadLayoutsetting, 
        "Default Notch: " + loadNotchsetting, //default notch
        "Default BP: " + loadBandpasssetting, //default bp
        "Default Framerate: " + loadFramerate, //default framerate
        "TS Vert Scale: " + loadTimeSeriesVertScale,
        "TS Horiz Scale: " + loadTimeSeriesHorizScale,
        "Analog Vert Scale: " + loadAnalogReadVertScale,
        "Analog Horiz Scale: " + loadAnalogReadHorizScale,
        "Board Mode: " + loadBoardMode,
        //Add new global settings above this line to print to console
        };
      //Print the global settings that have been loaded to the console  
      printArray(loadedGlobalSettings);
    }
    
    //parse the FFT settings that appear after the global settings 
    if (i == slnchan + 1) {
      fftMaxFrqLoad = loadAllSettings.getInt("FFT Max Freq");
      fftMaxuVLoad = loadAllSettings.getInt("FFT Max uV");
      fftLogLinLoad = loadAllSettings.getInt("FFT LogLin");
      fftSmoothingLoad = loadAllSettings.getInt("FFT Smoothing");
      fftFilterLoad = loadAllSettings.getInt("FFT Filter");
      
      //Create a string array to print to console
      final String[] loadedFFTSettings = {
        "FFT_Max Frequency: " + fftMaxFrqLoad, 
        "FFT_Max uV: " + fftMaxuVLoad,
        "FFT_Log/Lin: " + fftLogLinLoad,
        "FFT_Smoothing: " + fftSmoothingLoad,
        "FFT_Filter: " + fftFilterLoad,
        };
      //Print the FFT settings that have been loaded to the console  
      printArray(loadedFFTSettings);
    }
    
    //parse Networking settings that appear after FFT settings
    if (i == slnchan + 2) {
      nwProtocolLoad = loadAllSettings.getInt("Protocol");
      switch (nwProtocolLoad)  {
        case 0:
          nwDataType1 = loadAllSettings.getInt("OSC_DataType1");
          nwDataType2 = loadAllSettings.getInt("OSC_DataType2");
          nwDataType3 = loadAllSettings.getInt("OSC_DataType3");        
          nwDataType4 = loadAllSettings.getInt("OSC_DataType4"); 
          nwOscIp1Load = loadAllSettings.getString("OSC_ip1");
          nwOscIp2Load = loadAllSettings.getString("OSC_ip2");        
          nwOscIp3Load = loadAllSettings.getString("OSC_ip3");        
          nwOscIp4Load = loadAllSettings.getString("OSC_ip4");        
          nwOscPort1Load = loadAllSettings.getString("OSC_port1");
          nwOscPort2Load = loadAllSettings.getString("OSC_port2");        
          nwOscPort3Load = loadAllSettings.getString("OSC_port3");        
          nwOscPort4Load = loadAllSettings.getString("OSC_port4");                
          nwOscAddress1Load = loadAllSettings.getString("OSC_address1");
          nwOscAddress2Load = loadAllSettings.getString("OSC_address2");        
          nwOscAddress3Load = loadAllSettings.getString("OSC_address3");        
          nwOscAddress4Load = loadAllSettings.getString("OSC_address4");                
          nwOscFilter1Load = loadAllSettings.getInt("OSC_filter1");
          nwOscFilter2Load = loadAllSettings.getInt("OSC_filter2");        
          nwOscFilter3Load = loadAllSettings.getInt("OSC_filter3");        
          nwOscFilter4Load = loadAllSettings.getInt("OSC_filter4");  
          break;
        case 1:
          nwDataType1 = loadAllSettings.getInt("UDP_DataType1");
          nwDataType2 = loadAllSettings.getInt("UDP_DataType2");
          nwDataType3 = loadAllSettings.getInt("UDP_DataType3");        
          nwUdpIp1Load = loadAllSettings.getString("UDP_ip1");
          nwUdpIp2Load = loadAllSettings.getString("UDP_ip2");        
          nwUdpIp3Load = loadAllSettings.getString("UDP_ip3");            
          nwUdpPort1Load = loadAllSettings.getString("UDP_port1");
          nwUdpPort2Load = loadAllSettings.getString("UDP_port2");        
          nwUdpPort3Load = loadAllSettings.getString("UDP_port3");                                            
          nwUdpFilter1Load = loadAllSettings.getInt("UDP_filter1");
          nwUdpFilter2Load = loadAllSettings.getInt("UDP_filter2");        
          nwUdpFilter3Load = loadAllSettings.getInt("UDP_filter3");
          break;
        case 2:
          nwDataType1 = loadAllSettings.getInt("LSL_DataType1");
          nwDataType2 = loadAllSettings.getInt("LSL_DataType2");
          nwDataType3 = loadAllSettings.getInt("LSL_DataType3");        
          nwLSLName1Load = loadAllSettings.getString("LSL_name1");
          nwLSLName2Load = loadAllSettings.getString("LSL_name2");        
          nwLSLName3Load = loadAllSettings.getString("LSL_name3");            
          nwLSLType1Load = loadAllSettings.getString("LSL_type1");
          nwLSLType2Load = loadAllSettings.getString("LSL_type2");        
          nwLSLType3Load = loadAllSettings.getString("LSL_type3");                       
          nwLSLNumChan1Load = loadAllSettings.getString("LSL_numchan1");
          nwLSLNumChan2Load = loadAllSettings.getString("LSL_numchan2");        
          nwLSLNumChan3Load = loadAllSettings.getString("LSL_numchan3");                       
          nwLSLFilter1Load = loadAllSettings.getInt("LSL_filter1");
          nwLSLFilter2Load = loadAllSettings.getInt("LSL_filter2");        
          nwLSLFilter3Load = loadAllSettings.getInt("LSL_filter3");             
          break;
        case 3:
          nwDataType1 = loadAllSettings.getInt("Serial_DataType1");   
          nwSerialBaudRateLoad = loadAllSettings.getInt("Serial_baudrate");   
          nwSerialFilter1Load = loadAllSettings.getInt("Serial_filter1");
          break;
      } //end switch case for all networking types
    }// end parse loaded networking settings
    
    //parse the Headplot settings that appear after networking settings 
    if (i == slnchan + 3) {
      hpIntensityLoad = loadAllSettings.getInt("HP_intensity");
      hpPolarityLoad = loadAllSettings.getInt("HP_polarity");
      hpContoursLoad = loadAllSettings.getInt("HP_contours");
      hpSmoothingLoad = loadAllSettings.getInt("HP_smoothing");
      
      //Create a string array to print to console
      final String[] loadedHPSettings = {
        "HP_intensity: " + hpIntensityLoad, 
        "HP_polarity: " + hpPolarityLoad,
        "HP_contours: " + hpContoursLoad,
        "HP_smoothing: " + hpSmoothingLoad,
        };
      //Print the Headplot settings 
      printArray(loadedHPSettings);
    } 
    
    //parse the EMG settings that appear after Headplot settings
    if (i == slnchan + 4) {
      emgSmoothingLoad = loadAllSettings.getInt("EMG_smoothing");
      emguVLimLoad = loadAllSettings.getInt("EMG_uVlimit");
      emgCreepLoad = loadAllSettings.getInt("EMG_creepspeed");
      emgMinDeltauVLoad = loadAllSettings.getInt("EMG_minuV");
      
      //Create a string array to print to console
      final String[] loadedEMGSettings = {
        "EMG_smoothing: " + emgSmoothingLoad, 
        "EMG_uVlimit: " + emguVLimLoad,
        "EMG_creepspeed: " + emgCreepLoad,
        "EMG_minuV: " + emgMinDeltauVLoad,
        };
      //Print the EMG settings 
      printArray(loadedEMGSettings);
    }
    
    //parse the Focus settings that appear after EMG settings
      if (i == slnchan + 5) {
      focusThemeLoad = loadAllSettings.getInt("Focus_theme");
      focusKeyLoad = loadAllSettings.getInt("Focus_keypress");
      
      //Create a string array to print to console
      final String[] loadedFocusSettings = {
        "Focus_theme: " + focusThemeLoad, 
        "Focus_keypress: " + focusKeyLoad,
        };
      //Print the EMG settings 
      printArray(loadedFocusSettings);
    }

    //parse the Widget/Container settings that appear after Focus settings
    if (i == slnchan + 6) {
      //Apply Layout directly before loading and applying widgets to containers
      wm.setNewContainerLayout(loadLayoutsetting - 1);
      println("Layout " + loadLayoutsetting + " Loaded!");
      numLoadedWidgets = loadAllSettings.size();
      
      //int numActiveWidgets = 0; //reset the counter
      for(int w = 0; w < wm.widgets.size(); w++){ //increment through all widgets
        if(wm.widgets.get(w).isActive){ //If a widget is active...
          println("Deactivating widget [" + w + "]");
          wm.widgets.get(w).isActive = false;
          //numActiveWidgets++; //counter the number of de-activated widgets
        }
      }
      //println(numActiveWidgets
    
      //println(loadAllSettings.keys());
      //Store the Widget number keys from JSON to a string array
      loadedWidgetsArray = (String[]) loadAllSettings.keys().toArray(new String[loadAllSettings.size()]);
      //printArray(loadedWidgetsArray);
      int widgetToActivate = 0;
      for (int w = 0; w < numLoadedWidgets; w++) {
          String [] loadWidgetNameNumber = split(loadedWidgetsArray[w], '_');
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
          int containerToApply = loadAllSettings.getInt(loadedWidgetsArray[w]);
          
          wm.widgets.get(widgetToActivate).isActive = true;//activate the new widget
          wm.widgets.get(widgetToActivate).setContainer(containerToApply);//map it to the container that was loaded! 
          println("Applied Widget " + widgetToActivate + " to Container " + containerToApply);
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
  
  //Apply Board Mode
  applyBoardMode();
  
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
  loadApplyWidgetDropdownText(); 
  
  //Apply Time Series Settings Last!!!
  //Case for loading time series settings in Live Data mode last. Takes 100-105 ms per channel to ensure success.
  if(eegDataSource == DATASOURCE_GANGLION || eegDataSource == DATASOURCE_CYTON) loadApplyTimeSeriesSettings();
  
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void applyBoardMode()  {
  //Apply Board Mode
  switch(loadBoardMode){  //Then apply 
    case BOARD_MODE_DEFAULT:
      if(eegDataSource == DATASOURCE_GANGLION){ //This code has been copied from Accelerometer
        if(ganglion.isAccelModeActive()){
          ganglion.accelStop();

          w_accelerometer.accelModeButton.setString("Turn Accel On");
          w_accelerometer.accelerometerModeOn = false;
        } else{
          ganglion.accelStart();
          w_accelerometer.accelModeButton.setString("Turn Accel Off");
          w_accelerometer.accelerometerModeOn = true;
          w_analogRead.analogReadOn = false;
          w_pulsesensor.analogReadOn = false;
          w_digitalRead.digitalReadOn = false;
          w_markermode.markerModeOn = false;
        }
      } else if (eegDataSource == DATASOURCE_CYTON) {
        cyton.setBoardMode(BOARD_MODE_DEFAULT);
        output("Starting to read accelerometer");
        w_accelerometer.accelerometerModeOn = true;
        w_analogRead.analogReadOn = false;
        w_pulsesensor.analogReadOn = false;
        w_digitalRead.digitalReadOn = false;
        w_markermode.markerModeOn = false;
      }
      break;
    case BOARD_MODE_DEBUG: //Not being used currently
      break;
    case BOARD_MODE_ANALOG:
      if(cyton.isPortOpen()) { //This code has been copied from AnalogRead
        if (cyton.getBoardMode() != BOARD_MODE_ANALOG) {
          cyton.setBoardMode(BOARD_MODE_ANALOG);
          if (cyton.isWifi()) {
            output("Starting to read analog inputs on pin marked A5 (D11) and A6 (D12)");
          } else {
            output("Starting to read analog inputs on pin marked A5 (D11), A6 (D12) and A7 (D13)");
          }
          w_accelerometer.accelerometerModeOn = false;
          w_digitalRead.digitalReadOn = false;
          w_markermode.markerModeOn = false;
          w_pulsesensor.analogReadOn = true;
          w_analogRead.analogReadOn = true;
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
          w_accelerometer.accelerometerModeOn = true;
        }
      }
      break;
    case BOARD_MODE_DIGITAL:
      if(cyton.isPortOpen()) { //This code has been copied from DigitalRead
        if (cyton.getBoardMode() != BOARD_MODE_DIGITAL) {
          cyton.setBoardMode(BOARD_MODE_DIGITAL);
          if (cyton.isWifi()) {
            output("Starting to read digital inputs on pin marked D11, D12 and D17");
          } else {
            output("Starting to read digital inputs on pin marked D11, D12, D13, D17 and D18");
          }
          w_accelerometer.accelerometerModeOn = false;
          w_analogRead.analogReadOn = false;
          w_pulsesensor.analogReadOn = false;
          w_markermode.markerModeOn = false;
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
          w_accelerometer.accelerometerModeOn = true;
        }
      }
      break;
    case BOARD_MODE_MARKER:
      if((cyton.isPortOpen() && eegDataSource == DATASOURCE_CYTON) || eegDataSource == DATASOURCE_SYNTHETIC) {
        if (cyton.getBoardMode() != BOARD_MODE_MARKER) {
          cyton.setBoardMode(BOARD_MODE_MARKER);
          output("Starting to read markers");
          w_markermode.markerModeButton.setString("Turn Marker Off");
          w_accelerometer.accelerometerModeOn = false;
          w_analogRead.analogReadOn = false;
          w_pulsesensor.analogReadOn = false;
          w_digitalRead.digitalReadOn = false;
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
          w_markermode.markerModeButton.setString("Turn Marker On");
          w_accelerometer.accelerometerModeOn = true;
          w_analogRead.analogReadOn = false;
          w_pulsesensor.analogReadOn = false;
          w_digitalRead.digitalReadOn = false;
        }
      }
      break;
  }//end switch/case
}

//Apply Time Series Settings to the Board
void loadApplyTimeSeriesSettings() {
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

void loadApplyWidgetDropdownText() {
  
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
  
} //end of loadApplyWidgetDropdownText()
