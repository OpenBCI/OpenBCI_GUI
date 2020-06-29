//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
//                       This sketch saves and loads the following User Settings:
//                       -- All Time Series widget settings in Live, Playback, and Synthetic modes
//                       -- All FFT widget settings
//                       -- Default Layout, Notch, Bandpass Filter, Framerate, Board Mode, and other Global Settings
//                       -- Networking Mode and All settings for active networking protocol
//                       -- Accelerometer, Analog Read, Head Plot, EMG, Band Power, and Spectrogram
//                       -- Widget/Container Pairs
//                       -- OpenBCI Data Format Settings (.txt and .csv)
//                       Created: Richard Waltman - May/June 2018
//
//    -- Start System first!
//    -- Lowercase 'n' to Save
//    -- Capital 'N' to Load
//    -- Functions saveGUIsettings() and loadGUISettings() are called:
//        - during system initialization between checkpoints 4 and 5
//        - in Interactivty.pde with the rest of the keyboard shortcuts
//        - in TopNav.pde when "Config" --> "Save Settings" || "Load Settings" is clicked
//    -- This allows User to store snapshots of most GUI settings in Users/.../Documents/OpenBCI_GUI/Settings/
//    -- After loading, only a few actions are required: start/stop the data stream and networking streams, open/close serial port
//
//      Tips on adding a new setting:
//      -- figure out if the setting is Global, in an existing widget, or in a new class or widget
//      -- read the comments
//      -- once you find the right place to add your setting, you can copy the surrounding style
//      -- uses JSON keys
//      -- Example: Expert Mode is a global boolean, so we include it under kJSONKeySettings
//      -- We use one variable to load from JSON: loadExpertModeToggle
//      -- And another variable to use in the GUI and with saving to JSON: expertModeToggle
//      -- Example2: GUI version and settings version
//      -- Requires new JSON key 'version` and settingsVersion
//
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////
//   SoftwareSettings Class    //
/////////////////////////////////
class SoftwareSettings {
    //Current version to save to JSON
    String settingsVersion = "3.0.0";
    //impose minimum gui width and height in openBCI_GUI.pde
    int minGUIWidth = 705;
    int minGUIHeight = 400;
    //for screen resizing
    boolean screenHasBeenResized = false;
    float timeOfLastScreenResize = 0;
    int widthOfLastScreen = 0;
    int heightOfLastScreen = 0;
    //default layout variables
    int currentLayout;
    //Used to time the GUI intro animation
    int introAnimationInit = 0;
    final int introAnimationDuration = 2500;
    //Max File Size #461, default option 4 -> 60 minutes
    public final String[] fileDurations = {"5 Minutes", "15 minutes", "30 Minutes", "60 Minutes", "120 Minutes", "No Limit"};
    public final int[] fileDurationInts = {5, 15, 30, 60, 120, -1};
    public final int defaultOBCIMaxFileSize = 3; //4th option from the above list
    private boolean logFileIsOpen = false;
    private long logFileStartTime;
    private long logFileMaxDurationNano = -1;
    //this is a global CColor that determines the style of all widget dropdowns ... this should go in WidgetManager.pde
    CColor dropdownColors = new CColor();
    ///These `Save` vars are set to default when each widget instantiates
    ///and updated every time user selects from dropdown
    //Notch and Bandpass filter variables for save
    int dataProcessingNotchSave = 0;
    int dataProcessingBandpassSave = 3;
    //Time Series settings
    int tsVertScaleSave;
    int tsHorizScaleSave;
    //Accelerometer settings
    int accVertScaleSave;
    int accHorizScaleSave;
    //FFT plot settings,
    int fftMaxFrqSave;
    int fftMaxuVSave;
    int fftLogLinSave;
    int fftSmoothingSave;
    int fftFilterSave;
    //Analog Read settings
    int arVertScaleSave; //updates in VertScale_AR()
    int arHorizScaleSave; //updates in Duration_AR()
    //Headplot settings
    int hpIntensitySave;
    int hpPolaritySave;
    int hpContoursSave;
    int hpSmoothingSave;
    //EMG settings
    int emgSmoothingSave;
    int emguVLimSave;
    int emgCreepSave;
    int emgMinDeltauVSave;
    //default data types for streams 1-4 in Networking widget
    int nwDataType1;
    int nwDataType2;
    int nwDataType3;
    int nwDataType4;
    String nwSerialPort;
    int nwProtocolSave;
    //Used to check if a playback file has data
    int minNumRowsPlaybackFile = int(currentBoard.getSampleRate());
    //Spectrogram Widget settings
    int spectMaxFrqSave;
    int spectSampleRateSave;
    int spectLogLinSave;

    //default configuration settings file location and file name variables
    public final String guiDataPath = System.getProperty("user.home")+File.separator+"Documents"+File.separator+"OpenBCI_GUI"+File.separator;
    public final String recordingsPath = guiDataPath+"Recordings"+File.separator;
    public final String settingsPath = guiDataPath+"Settings"+File.separator;
    public final String consoleDataPath = guiDataPath+"Console_Data"+File.separator;
    private String sessionPath = "";
    final String[] userSettingsFiles = {
        "CytonUserSettings.json",
        "DaisyUserSettings.json",
        "GanglionUserSettings.json",
        "NovaXRUserSettings.json",
        "PlaybackUserSettings.json",
        "SynthFourUserSettings.json",
        "SynthEightUserSettings.json",
        "SynthSixteenUserSettings.json"
        };
    final String[] defaultSettingsFiles = {
        "CytonDefaultSettings.json",
        "DaisyDefaultSettings.json",
        "GanglionDefaultSettings.json",
        "NovaXRDefaultSettings.json",
        "PlaybackDefaultSettings.json",
        "SynthFourDefaultSettings.json",
        "SynthEightDefaultSettings.json",
        "SynthSixteenDefaultSettings.json"
        };

    //Used to set text for Notch and BP filter settings
    String [] dataProcessingNotchArray = {"60Hz", "50Hz", "None"};
    String [] dataProcessingBPArray = {"1-50 Hz", "7-13 Hz", "15-50 Hz", "5-50 Hz", "No Filter"};

    // Used to set text in Time Series dropdown settings
    String[] tsVertScaleArray = {"Auto", "50 uV", "100 uV", "200 uV", "400 uV", "1000 uV", "10000 uV"};
    String[] tsHorizScaleArray = {"1 sec", "3 sec", "5 sec", "10 sec", "20 sec"};

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
    String[] fftLogLinArray = {"Log", "Linear"}; //share this with spectrogram also
    String[] fftSmoothingArray = {"0.0", "0.5", "0.75", "0.9", "0.95", "0.98"};
    String[] fftFilterArray = {"Filtered", "Unfilt."};

    //Used to set text in dropdown menus when loading Accelerometer settings
    String[] accVertScaleArray = {"Auto","1 g", "2 g", "4 g"};
    String[] accHorizScaleArray = {"Sync", "1 sec", "3 sec", "5 sec", "10 sec", "20 sec"};

    //Used to set text in dropdown menus when loading Networking settings
    String[] nwProtocolArray = {"Serial", "LSL", "UDP", "OSC"};
    String[] nwDataTypesArray = {"None", "TimeSeries", "FFT", "EMG", "BandPower", "Accel/Aux", "Pulse"};
    String[] nwBaudRatesArray = {"57600", "115200", "250000", "500000"};

    //Used to set text in dropdown menus when loading Analog Read settings
    String[] arVertScaleArray = {"Auto", "50", "100", "200", "400", "1000", "10000"};
    String[] arHorizScaleArray = {"Sync", "1 sec", "3 sec", "5 sec", "10 sec", "20 sec"};

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

    //Used to set text in dropdown menus when loading Spectrogram Setings
    String[] spectMaxFrqArray = {"20 Hz", "40 Hz", "60 Hz", "100 Hz", "120 Hz", "250 Hz"};
    String[] spectSampleRateArray = {"1 Hz", "5 hz", "10 Hz", "20 Hz", "40 Hz"};

    //Load global settings variables
    int loadLayoutSetting;
    int loadNotchSetting;
    int loadBandpassSetting;

    //Load TS dropdown variables
    int loadTimeSeriesVertScale;
    int loadTimeSeriesHorizScale;

    //Load Accel. dropdown variables
    int loadAccelVertScale;
    int loadAccelHorizScale;

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


    //Band Power widget settings
    //smoothing and filter dropdowns are linked to FFT, so no need to save again
    List<Integer> loadBPActiveChans = new ArrayList<Integer>();

    //Spectrogram widget settings
    List<Integer> loadSpectActiveChanTop = new ArrayList<Integer>();
    List<Integer> loadSpectActiveChanBot = new ArrayList<Integer>();
    int spectMaxFrqLoad;
    int spectSampleRateLoad;
    int spectLogLinLoad;

    //Networking Settings save/load variables
    int nwProtocolLoad;
    //OSC load variables
    String nwOscIp1Load;  String nwOscIp2Load;  String nwOscIp3Load;  String nwOscIp4Load;
    String nwOscPort1Load;  String nwOscPort2Load;  String nwOscPort3Load;  String nwOscPort4Load;
    String nwOscAddress1Load;  String nwOscAddress2Load; String nwOscAddress3Load; String nwOscAddress4Load;
    boolean nwOscFilter1Load, nwOscFilter2Load, nwOscFilter3Load, nwOscFilter4Load;
    //UDP load variables
    String nwUdpIp1Load;  String nwUdpIp2Load;  String nwUdpIp3Load;
    String nwUdpPort1Load;  String nwUdpPort2Load;  String nwUdpPort3Load;
    boolean nwUdpFilter1Load, nwUdpFilter2Load, nwUdpFilter3Load;
    //LSL load variables
    String nwLSLName1Load;  String nwLSLName2Load;  String nwLSLName3Load;
    String nwLSLType1Load;  String nwLSLType2Load;  String nwLSLType3Load;
    boolean nwLSLFilter1Load, nwLSLFilter2Load, nwLSLFilter3Load;
    //Serial load variables
    int nwSerialBaudRateLoad;
    boolean nwSerialFilter1Load;

    //Primary JSON objects for saving and loading data
    private JSONObject saveSettingsJSONData;
    private JSONObject loadSettingsJSONData;

    private final String kJSONKeyDataInfo = "dataInfo";
    private final String kJSONKeyTimeSeries = "timeSeries";
    private final String kJSONKeySettings = "settings";
    private final String kJSONKeyFFT = "fft";
    private final String kJSONKeyAccel = "accelerometer";
    private final String kJSONKeyNetworking = "networking";
    private final String kJSONKeyHeadplot = "headplot";
    private final String kJSONKeyEMG = "emg";
    private final String kJSONKeyBandPower = "bandPower";
    private final String kJSONKeyWidget = "widget";
    private final String kJSONKeyVersion = "version";
    private final String kJSONKeySpectrogram = "spectrogram";

    //used only in this class to count the number of channels being used while saving/loading, this gets updated in updateToNChan whenever the number of channels being used changes
    int slnchan;
    int numChanloaded;
    boolean chanNumError = false;
    int numLoadedWidgets;
    String [] loadedWidgetsArray;
    int loadFramerate;
    int loadDatasource;
    boolean dataSourceError = false;
    //used globally to track and determine if expertMode is on or off
    boolean expertModeToggle = false;

    String saveDialogName; //Used when Save button is pressed
    String loadDialogName; //Used when Load button is pressed
    String controlEventDataSource; //Used for output message on system start
    Boolean errorUserSettingsNotFound = false; //For error catching
    int loadErrorTimerStart;
    int loadErrorTimeWindow = 5000; //Time window in milliseconds to apply channel settings to Cyton board. This is to avoid a GUI crash at ~ 4500-5000 milliseconds.
    Boolean loadErrorCytonEvent = false;
    final int initTimeoutThreshold = 12000; //Timeout threshold in milliseconds

    SoftwareSettings() {
        //Instantiated on app start in OpenBCI_GUI.pde
        dropdownColors.setActive((int)color(150, 170, 200)); //bg color of box when pressed
        dropdownColors.setForeground((int)color(177, 184, 193)); //when hovering over any box (primary or dropdown)
        dropdownColors.setBackground((int)color(255)); //bg color of boxes (including primary)
        dropdownColors.setCaptionLabel((int)color(1, 18, 41)); //color of text in primary box
        // dropdownColors.setValueLabel((int)color(1, 18, 41)); //color of text in all dropdown boxes
        dropdownColors.setValueLabel((int)color(100)); //color of text in all dropdown boxes
    }

    ///////////////////////////////////
    // OpenBCI Data Format Functions //
    ///////////////////////////////////

    public void setLogFileIsOpen (boolean _toggle) {
        logFileIsOpen = _toggle;
    }

    public boolean isLogFileOpen() {
        return logFileIsOpen;
    }

    public void setLogFileStartTime(long _time) {
        logFileStartTime = _time;
        verbosePrint("Settings: LogFileStartTime = " + _time);
    }

    public void setLogFileDurationChoice(int choice) {
        logFileMaxDurationNano = fileDurationInts[choice] * 1000000000L * 60;
        println("Settings: LogFileMaxDuration = " + fileDurationInts[choice] + " minutes");
    }

    //Only called during live mode && using OpenBCI Data Format
    public boolean maxLogTimeReached() {
        if (logFileMaxDurationNano < 0) {
            return false;
        } else {
            return (System.nanoTime() - logFileStartTime) > (logFileMaxDurationNano);
        }
    }

    public void setSessionPath (String _path) {
        sessionPath = _path;
    }

    public String getSessionPath() {
        return sessionPath;
    }

    ////////////////////////////////////////////////////////////////
    //               Init GUI Software Settings                   //
    //                                                            //
    //  - Called during system initialization in OpenBCI_GUI.pde  //
    ////////////////////////////////////////////////////////////////
    void init() {
        String defaultSettingsFileToSave = getPath("Default", eegDataSource, nchan);
        int defaultNumChanLoaded = 0;
        int defaultLoadedDataSource = 0;
        String defaultSettingsVersion = "";
        String defaultGUIVersion = "";

        //Take a snapshot of the default GUI settings on every system init
        println("InitSettings: Saving Default Settings to file!");
        try {
            this.save(defaultSettingsFileToSave); //to avoid confusion with save() image
        } catch (Exception e) {
            println("InitSettings: Error trying to save default settings");
            //e.printStackTrace();
        }
    }

    ///////////////////////////////
    //      Save GUI Settings    //
    ///////////////////////////////
    void save(String saveGUISettingsFileLocation) {

        //Set up a JSON array
        saveSettingsJSONData = new JSONObject();

        //Save the number of channels being used and eegDataSource in the first object
        JSONObject saveNumChannelsData = new JSONObject();
        saveNumChannelsData.setInt("Channels", slnchan);
        saveNumChannelsData.setInt("Data Source", eegDataSource);
        //println("Settings: NumChan: " + slnchan);
        saveSettingsJSONData.setJSONObject(kJSONKeyDataInfo, saveNumChannelsData);

        //Make a new JSON Object for Time Series Settings
        JSONObject saveTSSettings = new JSONObject();
        saveTSSettings.setInt("Time Series Vert Scale", tsVertScaleSave);
        saveTSSettings.setInt("Time Series Horiz Scale", tsHorizScaleSave);
        saveSettingsJSONData.setJSONObject(kJSONKeyTimeSeries, saveTSSettings);

        //Make a second JSON object within our JSONArray to store Global settings for the GUI
        JSONObject saveGlobalSettings = new JSONObject();
        saveGlobalSettings.setBoolean("Expert Mode", expertModeToggle);
        saveGlobalSettings.setInt("Current Layout", currentLayout);
        saveGlobalSettings.setInt("Notch", dataProcessingNotchSave);
        saveGlobalSettings.setInt("Bandpass Filter", dataProcessingBandpassSave);
        saveGlobalSettings.setInt("Framerate", frameRateCounter);
        saveGlobalSettings.setInt("Analog Read Vert Scale", arVertScaleSave);
        saveGlobalSettings.setInt("Analog Read Horiz Scale", arHorizScaleSave);
        saveSettingsJSONData.setJSONObject(kJSONKeySettings, saveGlobalSettings);

        /////Setup JSON Object for gui version and settings Version
        JSONObject saveVersionInfo = new JSONObject();
        saveVersionInfo.setString("gui", localGUIVersionString);
        saveVersionInfo.setString("settings", settingsVersion);
        saveSettingsJSONData.setJSONObject(kJSONKeyVersion, saveVersionInfo);

        ///////////////////////////////////////////////Setup new JSON object to save FFT settings
        JSONObject saveFFTSettings = new JSONObject();

        //Save FFT_Max Freq Setting. The max frq variable is updated every time the user selects a dropdown in the FFT widget
        saveFFTSettings.setInt("FFT_Max Freq", fftMaxFrqSave);
        //Save FFT_Max uV Setting. The max uV variable is updated also when user selects dropdown in the FFT widget
        saveFFTSettings.setInt("FFT_Max uV", fftMaxuVSave);
        //Save FFT_LogLin Setting. Same thing happens for LogLin
        saveFFTSettings.setInt("FFT_LogLin", fftLogLinSave);
        //Save FFT_Smoothing Setting
        saveFFTSettings.setInt("FFT_Smoothing", fftSmoothingSave);
        //Save FFT_Filter Setting
        if (isFFTFiltered == true)  fftFilterSave = 0;
        if (isFFTFiltered == false)  fftFilterSave = 1;
        saveFFTSettings.setInt("FFT_Filter",  fftFilterSave);
        //Set the FFT JSON Object
        saveSettingsJSONData.setJSONObject(kJSONKeyFFT, saveFFTSettings); //next object will be set to slnchan+3, etc.

        ///////////////////////////////////////////////Setup new JSON object to save Accelerometer settings
        JSONObject saveAccSettings = new JSONObject();
        saveAccSettings.setInt("Accelerometer Vert Scale", accVertScaleSave);
        saveAccSettings.setInt("Accelerometer Horiz Scale", accHorizScaleSave);
        saveSettingsJSONData.setJSONObject(kJSONKeyAccel, saveAccSettings);

        ///////////////////////////////////////////////Setup new JSON object to save Networking settings
        JSONObject saveNetworkingSettings = new JSONObject();
        //Save Protocol
        saveNetworkingSettings.setInt("Protocol", nwProtocolSave);//***Save User networking protocol mode
        switch(nwProtocolSave) {
            case 3:
                for (int i = 1; i <= 4; i++) {
                    saveNetworkingSettings.setInt("OSC_DataType"+i, (Integer) w_networking.getCP5Map().get(w_networking.datatypeNames[i-1]));
                    saveNetworkingSettings.setString("OSC_ip"+i, (String) w_networking.getCP5Map().get("OSC_ip"+i));
                    saveNetworkingSettings.setString("OSC_port"+i, (String) w_networking.getCP5Map().get("OSC_port"+i));
                    saveNetworkingSettings.setString("OSC_address"+i, (String) w_networking.getCP5Map().get("OSC_address"+i));
                    saveNetworkingSettings.setBoolean("OSC_filter"+i, (boolean) w_networking.getCP5Map().get("filter"+i));
                }
                break;
            case 2:
                for (int i = 1; i <= 3; i++) {
                    saveNetworkingSettings.setInt("UDP_DataType"+i, (Integer) w_networking.getCP5Map().get(w_networking.datatypeNames[i-1]));
                    saveNetworkingSettings.setString("UDP_ip"+i, (String) w_networking.getCP5Map().get("UDP_ip"+i));
                    saveNetworkingSettings.setString("UDP_port"+i, (String) w_networking.getCP5Map().get("UDP_port"+i));
                    saveNetworkingSettings.setBoolean("UDP_filter"+i, (boolean) w_networking.getCP5Map().get("filter"+i));
                }
                break;
            case 1:
                for (int i = 1; i <= 3; i++) {
                    saveNetworkingSettings.setInt("LSL_DataType"+i, (Integer) w_networking.getCP5Map().get(w_networking.datatypeNames[i-1]));
                    saveNetworkingSettings.setString("LSL_name"+i, (String) w_networking.getCP5Map().get("LSL_name"+i));
                    saveNetworkingSettings.setString("LSL_type"+i, (String) w_networking.getCP5Map().get("LSL_type"+i));
                    saveNetworkingSettings.setBoolean("LSL_filter"+i, (boolean) w_networking.getCP5Map().get("filter"+i));
                }
                break;
            case 0:
                saveNetworkingSettings.setInt("Serial_DataType1", (Integer) w_networking.getCP5Map().get("dataType1"));
                saveNetworkingSettings.setInt("Serial_baudrate", (Integer) w_networking.getCP5Map().get("baud_rate"));
                saveNetworkingSettings.setBoolean("Serial_filter1", (boolean) w_networking.getCP5Map().get("filter1"));
                saveNetworkingSettings.setString("Serial_portName", (String) w_networking.getCP5Map().get("port_name"));
                break;
        }//end of networking proctocol switch
        //Set Networking Settings JSON Object
        saveSettingsJSONData.setJSONObject(kJSONKeyNetworking, saveNetworkingSettings);

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
        saveSettingsJSONData.setJSONObject(kJSONKeyHeadplot, saveHeadplotSettings);

        ///////////////////////////////////////////////Setup new JSON object to save EMG settings
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
        saveSettingsJSONData.setJSONObject(kJSONKeyEMG, saveEMGSettings);

        ///////////////////////////////////////////////Setup new JSON object to save Band Power settings
        JSONObject saveBPSettings = new JSONObject();

        //Save data from the Active channel checkBoxes
        JSONArray saveActiveChanBP = new JSONArray();
        int numActiveBPChan = w_bandPower.bpChanSelect.activeChan.size();
        for (int i = 0; i < numActiveBPChan; i++) {
            int activeChan = w_bandPower.bpChanSelect.activeChan.get(i) + 1; //add 1 here so channel numbers are correct
            saveActiveChanBP.setInt(i, activeChan);
        }
        saveBPSettings.setJSONArray("activeChannels", saveActiveChanBP);
        saveSettingsJSONData.setJSONObject(kJSONKeyBandPower, saveBPSettings);

        ///////////////////////////////////////////////Setup new JSON object to save Spectrogram settings
        JSONObject saveSpectrogramSettings = new JSONObject();
        //Save data from the Active channel checkBoxes - Top
        JSONArray saveActiveChanSpectTop = new JSONArray();
        int numActiveSpectChanTop = w_spectrogram.spectChanSelectTop.activeChan.size();
        for (int i = 0; i < numActiveSpectChanTop; i++) {
            int activeChan = w_spectrogram.spectChanSelectTop.activeChan.get(i) + 1; //add 1 here so channel numbers are correct
            saveActiveChanSpectTop.setInt(i, activeChan);
        }
        saveSpectrogramSettings.setJSONArray("activeChannelsTop", saveActiveChanSpectTop);
        //Save data from the Active channel checkBoxes - Bottom
        JSONArray saveActiveChanSpectBot = new JSONArray();
        int numActiveSpectChanBot = w_spectrogram.spectChanSelectBot.activeChan.size();
        for (int i = 0; i < numActiveSpectChanBot; i++) {
            int activeChan = w_spectrogram.spectChanSelectBot.activeChan.get(i) + 1; //add 1 here so channel numbers are correct
            saveActiveChanSpectBot.setInt(i, activeChan);
        }
        saveSpectrogramSettings.setJSONArray("activeChannelsBot", saveActiveChanSpectBot);
        //Save Spectrogram_Max Freq Setting. The max frq variable is updated every time the user selects a dropdown in the spectrogram widget
        saveSpectrogramSettings.setInt("Spectrogram_Max Freq", spectMaxFrqSave);
        saveSpectrogramSettings.setInt("Spectrogram_Sample Rate", spectSampleRateSave);
        saveSpectrogramSettings.setInt("Spectrogram_LogLin", spectLogLinSave);
        saveSettingsJSONData.setJSONObject(kJSONKeySpectrogram, saveSpectrogramSettings);

        ///////////////////////////////////////////////Setup new JSON object to save Widgets Active in respective Containers
        JSONObject saveWidgetSettings = new JSONObject();

        int numActiveWidgets = 0;
        //Save what Widgets are active and respective Container number (see Containers.pde)
        for (int i = 0; i < wm.widgets.size(); i++) { //increment through all widgets
            if (wm.widgets.get(i).getIsActive()) { //If a widget is active...
                numActiveWidgets++; //increment numActiveWidgets
                //println("Widget" + i + " is active");
                // activeWidgets.add(i); //keep track of the active widget
                int containerCountsave = wm.widgets.get(i).currentContainer;
                //println("Widget " + i + " is in Container " + containerCountsave);
                saveWidgetSettings.setInt("Widget_"+i, containerCountsave);
            } else if (!wm.widgets.get(i).getIsActive()) { //If a widget is not active...
                saveWidgetSettings.remove("Widget_"+i); //remove non-active widget from JSON
                //println("widget"+i+" is not active");
            }
        }
        println("SoftwareSettings: " + numActiveWidgets + " active widgets saved!");
        //Print what widgets are in the containers used by current layout for only the number of active widgets
        //for (int i = 0; i < numActiveWidgets; i++) {
            //int containerCounter = wm.layouts.get(currentLayout-1).containerInts[i];
            //println("Container " + containerCounter + " is available"); //For debugging
        //}
        saveSettingsJSONData.setJSONObject(kJSONKeyWidget, saveWidgetSettings);

        /////////////////////////////////////////////////////////////////////////////////
        ///ADD more global settings above this line in the same formats as above/////////

        //Let's save the JSON array to a file!
        saveJSONObject(saveSettingsJSONData, saveGUISettingsFileLocation);

    }  //End of Save GUI Settings function

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                Load GUI Settings                                                       //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    void load(String loadGUISettingsFileLocation) throws Exception {
        //Load all saved User Settings from a JSON file if it exists
        loadSettingsJSONData = loadJSONObject(loadGUISettingsFileLocation);

        verbosePrint(loadSettingsJSONData.toString());

        //Check the number of channels saved to json first!
        JSONObject loadDataSettings = loadSettingsJSONData.getJSONObject(kJSONKeyDataInfo);
        numChanloaded = loadDataSettings.getInt("Channels");
        //Print error if trying to load a different number of channels
        if (numChanloaded != slnchan) {
            println("Channels being loaded from " + loadGUISettingsFileLocation + " don't match channels being used!");
            chanNumError = true;
            throw new Exception();
        } else {
            chanNumError = false;
        }
        //Check the Data Source integer next: Cyton = 0, Ganglion = 1, Playback = 2, Synthetic = 3
        loadDatasource = loadDataSettings.getInt("Data Source");
        verbosePrint("loadGUISettings: Data source loaded: " + loadDatasource + ". Current data source: " + eegDataSource);
        //Print error if trying to load a different data source (ex. Live != Synthetic)
        if (loadDatasource != eegDataSource) {
            println("Data source being loaded from " + loadGUISettingsFileLocation + " doesn't match current data source.");
            dataSourceError = true;
            throw new Exception();
        } else {
            dataSourceError = false;
        }

        //get the global settings JSON object
        JSONObject loadGlobalSettings = loadSettingsJSONData.getJSONObject(kJSONKeySettings);
        loadLayoutSetting = loadGlobalSettings.getInt("Current Layout");
        loadNotchSetting = loadGlobalSettings.getInt("Notch");
        loadBandpassSetting = loadGlobalSettings.getInt("Bandpass Filter");
        loadFramerate = loadGlobalSettings.getInt("Framerate");
        Boolean loadExpertModeToggle = loadGlobalSettings.getBoolean("Expert Mode");
        loadAnalogReadVertScale = loadGlobalSettings.getInt("Analog Read Vert Scale");
        loadAnalogReadHorizScale = loadGlobalSettings.getInt("Analog Read Horiz Scale");
        //Store loaded layout to current layout variable
        currentLayout = loadLayoutSetting;
        //Load more global settings after this line, if needed

        //get the FFT settings
        JSONObject loadFFTSettings = loadSettingsJSONData.getJSONObject(kJSONKeyFFT);
        fftMaxFrqLoad = loadFFTSettings.getInt("FFT_Max Freq");
        fftMaxuVLoad = loadFFTSettings.getInt("FFT_Max uV");
        fftLogLinLoad = loadFFTSettings.getInt("FFT_LogLin");
        fftSmoothingLoad = loadFFTSettings.getInt("FFT_Smoothing");
        fftFilterLoad = loadFFTSettings.getInt("FFT_Filter");

        //get the Accelerometer settings
        JSONObject loadAccSettings = loadSettingsJSONData.getJSONObject(kJSONKeyAccel);
        loadAccelVertScale = loadAccSettings.getInt("Accelerometer Vert Scale");
        loadAccelHorizScale = loadAccSettings.getInt("Accelerometer Horiz Scale");

        //get the Networking Settings
        JSONObject loadNetworkingSettings = loadSettingsJSONData.getJSONObject(kJSONKeyNetworking);
        nwProtocolLoad = loadNetworkingSettings.getInt("Protocol");
        switch (nwProtocolLoad)  {
            case 3:
                nwDataType1 = loadNetworkingSettings.getInt("OSC_DataType1");
                nwDataType2 = loadNetworkingSettings.getInt("OSC_DataType2");
                nwDataType3 = loadNetworkingSettings.getInt("OSC_DataType3");
                nwDataType4 = loadNetworkingSettings.getInt("OSC_DataType4");
                nwOscIp1Load = loadNetworkingSettings.getString("OSC_ip1");
                nwOscIp2Load = loadNetworkingSettings.getString("OSC_ip2");
                nwOscIp3Load = loadNetworkingSettings.getString("OSC_ip3");
                nwOscIp4Load = loadNetworkingSettings.getString("OSC_ip4");
                nwOscPort1Load = loadNetworkingSettings.getString("OSC_port1");
                nwOscPort2Load = loadNetworkingSettings.getString("OSC_port2");
                nwOscPort3Load = loadNetworkingSettings.getString("OSC_port3");
                nwOscPort4Load = loadNetworkingSettings.getString("OSC_port4");
                nwOscAddress1Load = loadNetworkingSettings.getString("OSC_address1");
                nwOscAddress2Load = loadNetworkingSettings.getString("OSC_address2");
                nwOscAddress3Load = loadNetworkingSettings.getString("OSC_address3");
                nwOscAddress4Load = loadNetworkingSettings.getString("OSC_address4");
                nwOscFilter1Load = loadNetworkingSettings.getBoolean("OSC_filter1");
                nwOscFilter2Load = loadNetworkingSettings.getBoolean("OSC_filter2");
                nwOscFilter3Load = loadNetworkingSettings.getBoolean("OSC_filter3");
                nwOscFilter4Load = loadNetworkingSettings.getBoolean("OSC_filter4");
                break;
            case 2:
                nwDataType1 = loadNetworkingSettings.getInt("UDP_DataType1");
                nwDataType2 = loadNetworkingSettings.getInt("UDP_DataType2");
                nwDataType3 = loadNetworkingSettings.getInt("UDP_DataType3");
                nwUdpIp1Load = loadNetworkingSettings.getString("UDP_ip1");
                nwUdpIp2Load = loadNetworkingSettings.getString("UDP_ip2");
                nwUdpIp3Load = loadNetworkingSettings.getString("UDP_ip3");
                nwUdpPort1Load = loadNetworkingSettings.getString("UDP_port1");
                nwUdpPort2Load = loadNetworkingSettings.getString("UDP_port2");
                nwUdpPort3Load = loadNetworkingSettings.getString("UDP_port3");
                nwUdpFilter1Load = loadNetworkingSettings.getBoolean("UDP_filter1");
                nwUdpFilter2Load = loadNetworkingSettings.getBoolean("UDP_filter2");
                nwUdpFilter3Load = loadNetworkingSettings.getBoolean("UDP_filter3");
                break;
            case 1:
                nwDataType1 = loadNetworkingSettings.getInt("LSL_DataType1");
                nwDataType2 = loadNetworkingSettings.getInt("LSL_DataType2");
                nwDataType3 = loadNetworkingSettings.getInt("LSL_DataType3");
                nwLSLName1Load = loadNetworkingSettings.getString("LSL_name1");
                nwLSLName2Load = loadNetworkingSettings.getString("LSL_name2");
                nwLSLName3Load = loadNetworkingSettings.getString("LSL_name3");
                nwLSLType1Load = loadNetworkingSettings.getString("LSL_type1");
                nwLSLType2Load = loadNetworkingSettings.getString("LSL_type2");
                nwLSLType3Load = loadNetworkingSettings.getString("LSL_type3");
                nwLSLFilter1Load = loadNetworkingSettings.getBoolean("LSL_filter1");
                nwLSLFilter2Load = loadNetworkingSettings.getBoolean("LSL_filter2");
                nwLSLFilter3Load = loadNetworkingSettings.getBoolean("LSL_filter3");
                break;
            case 0:
                nwDataType1 = loadNetworkingSettings.getInt("Serial_DataType1");
                nwSerialBaudRateLoad = loadNetworkingSettings.getInt("Serial_baudrate");
                nwSerialFilter1Load = loadNetworkingSettings.getBoolean("Serial_filter1");
                nwSerialPort = loadNetworkingSettings.getString("Serial_portName");
                break;
        } //end switch case for all networking types

        //get the  Headplot settings
        JSONObject loadHeadplotSettings = loadSettingsJSONData.getJSONObject(kJSONKeyHeadplot);
        hpIntensityLoad = loadHeadplotSettings.getInt("HP_intensity");
        hpPolarityLoad = loadHeadplotSettings.getInt("HP_polarity");
        hpContoursLoad = loadHeadplotSettings.getInt("HP_contours");
        hpSmoothingLoad = loadHeadplotSettings.getInt("HP_smoothing");

        //get the EMG settings
        JSONObject loadEMGSettings = loadSettingsJSONData.getJSONObject(kJSONKeyEMG);
        emgSmoothingLoad = loadEMGSettings.getInt("EMG_smoothing");
        emguVLimLoad = loadEMGSettings.getInt("EMG_uVlimit");
        emgCreepLoad = loadEMGSettings.getInt("EMG_creepspeed");
        emgMinDeltauVLoad = loadEMGSettings.getInt("EMG_minuV");

        //Get Band Power widget settings
        loadBPActiveChans.clear();
        JSONObject loadBPSettings = loadSettingsJSONData.getJSONObject(kJSONKeyBandPower);
        JSONArray loadBPChan = loadBPSettings.getJSONArray("activeChannels");
        for (int i = 0; i < loadBPChan.size(); i++) {
            loadBPActiveChans.add(loadBPChan.getInt(i));
        }
        //println("Settings: band power active chans loaded = " + loadBPActiveChans );

        try {
            //Get Spectrogram widget settings
            loadSpectActiveChanTop.clear();
            loadSpectActiveChanBot.clear();
            JSONObject loadSpectSettings = loadSettingsJSONData.getJSONObject(kJSONKeySpectrogram);
            JSONArray loadSpectChanTop = loadSpectSettings.getJSONArray("activeChannelsTop");
            for (int i = 0; i < loadSpectChanTop.size(); i++) {
                loadSpectActiveChanTop.add(loadSpectChanTop.getInt(i));
            }
            JSONArray loadSpectChanBot = loadSpectSettings.getJSONArray("activeChannelsBot");
            for (int i = 0; i < loadSpectChanTop.size(); i++) {
                loadSpectActiveChanBot.add(loadSpectChanBot.getInt(i));
            }
            spectMaxFrqLoad = loadSpectSettings.getInt("Spectrogram_Max Freq");
            spectSampleRateLoad = loadSpectSettings.getInt("Spectrogram_Sample Rate");
            spectLogLinLoad = loadSpectSettings.getInt("Spectrogram_LogLin");
            //println(loadSpectActiveChanTop, loadSpectActiveChanBot);
        } catch (Exception e) {
            e.printStackTrace();
        }

        //get the  Widget/Container settings
        JSONObject loadWidgetSettings = loadSettingsJSONData.getJSONObject(kJSONKeyWidget);
        //Apply Layout directly before loading and applying widgets to containers
        wm.setNewContainerLayout(loadLayoutSetting);
        verbosePrint("LoadGUISettings: Layout " + loadLayoutSetting + " Loaded!");
        numLoadedWidgets = loadWidgetSettings.size();


        //int numActiveWidgets = 0; //reset the counter
        for (int w = 0; w < wm.widgets.size(); w++) { //increment through all widgets
            if (wm.widgets.get(w).getIsActive()) { //If a widget is active...
                verbosePrint("Deactivating widget [" + w + "]");
                wm.widgets.get(w).setIsActive(false);
                //numActiveWidgets++; //counter the number of de-activated widgets
            }
        }

        //Store the Widget number keys from JSON to a string array
        loadedWidgetsArray = (String[]) loadWidgetSettings.keys().toArray(new String[loadWidgetSettings.size()]);
        //printArray(loadedWidgetsArray);
        int widgetToActivate = 0;
        for (int w = 0; w < numLoadedWidgets; w++) {
                String [] loadWidgetNameNumber = split(loadedWidgetsArray[w], '_');
                //Store the value of the widget to be activated
                widgetToActivate = Integer.valueOf(loadWidgetNameNumber[1]);
                //Load the container for the current widget[w]
                int containerToApply = loadWidgetSettings.getInt(loadedWidgetsArray[w]);

                wm.widgets.get(widgetToActivate).setIsActive(true);//activate the new widget
                wm.widgets.get(widgetToActivate).setContainer(containerToApply);//map it to the container that was loaded!
                println("LoadGUISettings: Applied Widget " + widgetToActivate + " to Container " + containerToApply);
        }//end case for all widget/container settings

        /////////////////////////////////////////////////////////////
        //    Load more widget settings above this line as above   //

        //}//end case for all objects in JSON

        //Apply Expert Mode toggle
        if (loadExpertModeToggle) {
            topNav.configSelector.configOptions.get(0).setString("Turn Expert Mode Off");
            topNav.configSelector.configOptions.get(0).setColorNotPressed(topNav.configSelector.expertPurple);
            println("LoadGUISettings: Expert Mode On");
            expertModeToggle = true;
        } else {
            topNav.configSelector.configOptions.get(0).setString("Turn Expert Mode On");
            topNav.configSelector.configOptions.get(0).setColorNotPressed(topNav.configSelector.newGreen);
            println("LoadGUISettings: Expert Mode Off");
            expertModeToggle = false;
        }

        //Apply Framerate
        frameRateCounter = loadFramerate;
        switch (frameRateCounter) {
            case 0:
                setFrameRate(24);
                break;
            case 1:
                setFrameRate(30);
                break;
            case 2:
                setFrameRate(45);
                break;
            case 3:
                setFrameRate(60);
                break;
        }

        //Load and apply all of the settings that are in dropdown menus. It's a bit much, so it has it's own function below.
        loadApplyWidgetDropdownText();

        //Apply Time Series Settings Last!!!
        loadApplyTimeSeriesSettings();

        //Force headplot to redraw if it is active
        int hpWidgetNumber;
        if (eegDataSource == DATASOURCE_GANGLION) {
            hpWidgetNumber = 6;
        } else {
            hpWidgetNumber = 5;
        }
        if (wm.widgets.get(hpWidgetNumber).getIsActive()) {
            w_headPlot.headPlot.setPositionSize(w_headPlot.headPlot.hp_x, w_headPlot.headPlot.hp_y, w_headPlot.headPlot.hp_w, w_headPlot.headPlot.hp_h, w_headPlot.headPlot.hp_win_x, w_headPlot.headPlot.hp_win_y);
            println("Headplot is active: Redrawing");
        }
    } //end of loadGUISettings
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private void loadApplyWidgetDropdownText() {

        ////////Apply Time Series dropdown settings in loadApplyTimeSeriesSettings() instead of here

        ////////Apply FFT settings
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

        ////////Apply Accelerometer settings;
        accelVertScale(loadAccelVertScale);
            w_accelerometer.cp5_widget.getController("accelVertScale").getCaptionLabel().setText(accVertScaleArray[loadAccelVertScale]);

        accelDuration(loadAccelHorizScale);
            w_accelerometer.cp5_widget.getController("accelDuration").getCaptionLabel().setText(accHorizScaleArray[loadAccelHorizScale]);

        ////////Apply Anolog Read dropdowns to Live Cyton Only
        if (eegDataSource == DATASOURCE_CYTON) {
            ////////Apply Analog Read settings
            VertScale_AR(loadAnalogReadVertScale);
                w_analogRead.cp5_widget.getController("VertScale_AR").getCaptionLabel().setText(arVertScaleArray[loadAnalogReadVertScale]);

            Duration_AR(loadAnalogReadHorizScale);
                w_analogRead.cp5_widget.getController("Duration_AR").getCaptionLabel().setText(arHorizScaleArray[loadAnalogReadHorizScale]);
        }

        ////////////////////////////Apply Headplot settings
        Intensity(hpIntensityLoad);
            w_headPlot.cp5_widget.getController("Intensity").getCaptionLabel().setText(hpIntensityArray[hpIntensityLoad]);

        Polarity(hpPolarityLoad);
            w_headPlot.cp5_widget.getController("Polarity").getCaptionLabel().setText(hpPolarityArray[hpPolarityLoad]);

        ShowContours(hpContoursLoad);
            w_headPlot.cp5_widget.getController("ShowContours").getCaptionLabel().setText(hpContoursArray[hpContoursLoad]);

        SmoothingHeadPlot(hpSmoothingLoad);
            w_headPlot.cp5_widget.getController("SmoothingHeadPlot").getCaptionLabel().setText(hpSmoothingArray[hpSmoothingLoad]);

        //Force redraw headplot on load. Fixes issue where heaplot draws outside of the widget.
        w_headPlot.headPlot.setPositionSize(w_headPlot.headPlot.hp_x, w_headPlot.headPlot.hp_y, w_headPlot.headPlot.hp_w, w_headPlot.headPlot.hp_h, w_headPlot.headPlot.hp_win_x, w_headPlot.headPlot.hp_win_y);

        ////////////////////////////Apply EMG settings
        SmoothEMG(emgSmoothingLoad);
            w_emg.cp5_widget.getController("SmoothEMG").getCaptionLabel().setText(emgSmoothingArray[emgSmoothingLoad]);

        uVLimit(emguVLimLoad);
            w_emg.cp5_widget.getController("uVLimit").getCaptionLabel().setText(emguVLimArray[emguVLimLoad]);

        CreepSpeed(emgCreepLoad);
            w_emg.cp5_widget.getController("CreepSpeed").getCaptionLabel().setText(emgCreepArray[emgCreepLoad]);

        minUVRange(emgMinDeltauVLoad);
            w_emg.cp5_widget.getController("minUVRange").getCaptionLabel().setText(emgMinDeltauVArray[emgMinDeltauVLoad]);

        ////////////////////////////Apply Band Power settings
        try {
            //apply channel checkbox settings
            w_bandPower.bpChanSelect.cp5_channelCheckboxes.get(CheckBox.class, "BP_Channels").deactivateAll();
            if (loadBPActiveChans.size() > 0) {
                int activeChanCounterBP = 0;
                for (int i = 0; i < nchan; i++) {
                    if (activeChanCounterBP  < loadBPActiveChans.size()) {
                        //subtract 1 because cp5 starts count from 0
                        if (i == (loadBPActiveChans.get(activeChanCounterBP) - 1)) {
                            w_bandPower.bpChanSelect.cp5_channelCheckboxes.get(CheckBox.class, "BP_Channels").activate(i);
                            activeChanCounterBP++;
                        }
                    }
                }
            }
        } catch (Exception e) {
            println("Settings: Exception caught applying band power settings " + e);
        }
        verbosePrint("Settings: Band Power Active Channels: " + loadBPActiveChans);

        ////////////////////////////Apply Spectrogram settings
        //Apply Max Freq dropdown
        SpectrogramMaxFreq(spectMaxFrqLoad);
            w_spectrogram.cp5_widget.getController("SpectrogramMaxFreq").getCaptionLabel().setText(spectMaxFrqArray[spectMaxFrqLoad]);
        SpectrogramSampleRate(spectSampleRateLoad);
            w_spectrogram.cp5_widget.getController("SpectrogramSampleRate").getCaptionLabel().setText(spectSampleRateArray[spectSampleRateLoad]);
        SpectrogramLogLin(spectLogLinLoad);
            w_spectrogram.cp5_widget.getController("SpectrogramLogLin").getCaptionLabel().setText(fftLogLinArray[spectLogLinLoad]);

        ///////////Apply Networking Settings
        //Update protocol with loaded value
        Protocol(nwProtocolLoad);
        //Update dropdowns and textfields in the Networking widget with loaded values
        w_networking.cp5_widget.getController("Protocol").getCaptionLabel().setText(nwProtocolArray[nwProtocolLoad]); //Reference the dropdown from the appropriate widget
        w_networking.cp5_networking.get(Toggle.class, "filter1").setState(false);
        w_networking.cp5_networking.get(Toggle.class, "filter2").setState(false);
        w_networking.cp5_networking.get(Toggle.class, "filter3").setState(false);
        w_networking.cp5_networking.get(Toggle.class, "filter4").setState(false);
        switch (nwProtocolLoad) {
            case 3:  //Apply OSC if loaded
                println("Apply OSC Networking Mode");
                w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(nwDataTypesArray[nwDataType1]); //Set text on frontend
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setValue(nwDataType1); //Set value in backend
                w_networking.cp5_networking_dropdowns.getController("dataType2").getCaptionLabel().setText(nwDataTypesArray[nwDataType2]); //etc...
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setValue(nwDataType2);
                w_networking.cp5_networking_dropdowns.getController("dataType3").getCaptionLabel().setText(nwDataTypesArray[nwDataType3]);
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setValue(nwDataType3);
                w_networking.cp5_networking_dropdowns.getController("dataType4").getCaptionLabel().setText(nwDataTypesArray[nwDataType4]);
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType4").setValue(nwDataType4);
                w_networking.cp5_networking.get(Textfield.class, "OSC_ip1").setText(nwOscIp1Load); //Simply set the text for text boxes
                w_networking.cp5_networking.get(Textfield.class, "OSC_ip2").setText(nwOscIp2Load); //The strings are referenced on command
                w_networking.cp5_networking.get(Textfield.class, "OSC_ip3").setText(nwOscIp3Load);
                w_networking.cp5_networking.get(Textfield.class, "OSC_ip4").setText(nwOscIp4Load);
                w_networking.cp5_networking.get(Textfield.class, "OSC_port1").setText(nwOscPort1Load);
                w_networking.cp5_networking.get(Textfield.class, "OSC_port2").setText(nwOscPort2Load);
                w_networking.cp5_networking.get(Textfield.class, "OSC_port3").setText(nwOscPort3Load);
                w_networking.cp5_networking.get(Textfield.class, "OSC_port4").setText(nwOscPort4Load);
                w_networking.cp5_networking.get(Textfield.class, "OSC_address1").setText(nwOscAddress1Load);
                w_networking.cp5_networking.get(Textfield.class, "OSC_address2").setText(nwOscAddress2Load);
                w_networking.cp5_networking.get(Textfield.class, "OSC_address3").setText(nwOscAddress3Load);
                w_networking.cp5_networking.get(Textfield.class, "OSC_address4").setText(nwOscAddress4Load);
                w_networking.cp5_networking.get(Toggle.class, "filter1").setState(nwOscFilter1Load);
                w_networking.cp5_networking.get(Toggle.class, "filter2").setState(nwOscFilter2Load);
                w_networking.cp5_networking.get(Toggle.class, "filter3").setState(nwOscFilter3Load);
                w_networking.cp5_networking.get(Toggle.class, "filter4").setState(nwOscFilter4Load);
                break;
            case 2:  //Apply UDP if loaded
                println("Apply UDP Networking Mode");
                w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(nwDataTypesArray[nwDataType1]); //Set text on frontend
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setValue(nwDataType1); //Set value in backend
                w_networking.cp5_networking_dropdowns.getController("dataType2").getCaptionLabel().setText(nwDataTypesArray[nwDataType2]); //etc...
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setValue(nwDataType2);
                w_networking.cp5_networking_dropdowns.getController("dataType3").getCaptionLabel().setText(nwDataTypesArray[nwDataType3]);
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setValue(nwDataType3);
                w_networking.cp5_networking.get(Textfield.class, "UDP_ip1").setText(nwUdpIp1Load);
                w_networking.cp5_networking.get(Textfield.class, "UDP_ip2").setText(nwUdpIp2Load);
                w_networking.cp5_networking.get(Textfield.class, "UDP_ip3").setText(nwUdpIp3Load);
                w_networking.cp5_networking.get(Textfield.class, "UDP_port1").setText(nwUdpPort1Load);
                w_networking.cp5_networking.get(Textfield.class, "UDP_port2").setText(nwUdpPort2Load);
                w_networking.cp5_networking.get(Textfield.class, "UDP_port3").setText(nwUdpPort3Load);
                w_networking.cp5_networking.get(Toggle.class, "filter1").setState(nwUdpFilter1Load);
                w_networking.cp5_networking.get(Toggle.class, "filter2").setState(nwUdpFilter2Load);
                w_networking.cp5_networking.get(Toggle.class, "filter3").setState(nwUdpFilter3Load);
                break;
            case 1:  //Apply LSL if loaded
                println("Apply LSL Networking Mode");
                w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(nwDataTypesArray[nwDataType1]); //Set text on frontend
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setValue(nwDataType1); //Set value in backend
                w_networking.cp5_networking_dropdowns.getController("dataType2").getCaptionLabel().setText(nwDataTypesArray[nwDataType2]); //etc...
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType2").setValue(nwDataType2);
                w_networking.cp5_networking_dropdowns.getController("dataType3").getCaptionLabel().setText(nwDataTypesArray[nwDataType3]);
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType3").setValue(nwDataType3);
                w_networking.cp5_networking.get(Textfield.class, "LSL_name1").setText(nwLSLName1Load);
                w_networking.cp5_networking.get(Textfield.class, "LSL_name2").setText(nwLSLName2Load);
                w_networking.cp5_networking.get(Textfield.class, "LSL_name3").setText(nwLSLName3Load);
                w_networking.cp5_networking.get(Textfield.class, "LSL_type1").setText(nwLSLType1Load);
                w_networking.cp5_networking.get(Textfield.class, "LSL_type2").setText(nwLSLType2Load);
                w_networking.cp5_networking.get(Textfield.class, "LSL_type3").setText(nwLSLType3Load);
                w_networking.cp5_networking.get(Toggle.class, "filter1").setState(nwLSLFilter1Load);
                w_networking.cp5_networking.get(Toggle.class, "filter2").setState(nwLSLFilter2Load);
                w_networking.cp5_networking.get(Toggle.class, "filter3").setState(nwLSLFilter3Load);
                break;
            case 0:  //Apply Serial if loaded
                println("Apply Serial Networking Mode");
                w_networking.cp5_networking_dropdowns.getController("dataType1").getCaptionLabel().setText(nwDataTypesArray[nwDataType1]); //Set text on frontend
                w_networking.cp5_networking_dropdowns.get(ScrollableList.class, "dataType1").setValue(nwDataType1); //Set value in backend
                w_networking.cp5_networking_baudRate.getController("baud_rate").getCaptionLabel().setText(nwBaudRatesArray[nwSerialBaudRateLoad]); //Set text
                w_networking.cp5_networking_baudRate.get(ScrollableList.class, "baud_rate").setValue(nwSerialBaudRateLoad); //Set value in backend
                w_networking.cp5_networking.get(Toggle.class, "filter1").setState(nwSerialFilter1Load);

                //Look for the portName in the dropdown list
                int listSize = w_networking.cp5_networking_portName.get(ScrollableList.class, "port_name").getItems().size();
                for (int i = 0; i < listSize; i++) {
                    String s = w_networking.cp5_networking_portName.get(ScrollableList.class, "port_name").getItem(i).get("name").toString();
                    if (s.equals(nwSerialPort)) {
                        verbosePrint("Settings: NWSerial: Found com port " + s + " !");
                        w_networking.cp5_networking_portName.getController("port_name").getCaptionLabel().setText(s);
                        w_networking.cp5_networking_portName.get(ScrollableList.class, "port_name").setValue(i);
                        break;
                    } else {
                        if (i == listSize - 1) verbosePrint("Settings: NWSerial: Port not found...");
                    }
                }
                break;
        }//end switch-case for networking settings for all networking protocols

        ////////////////////////////////////////////////////////////
        //    Apply more loaded widget settings above this line   //

    } //end of loadApplyWidgetDropdownText()

    private void loadApplyTimeSeriesSettings() {

        JSONObject loadTimeSeriesSettings = loadSettingsJSONData.getJSONObject(kJSONKeyTimeSeries);
        loadTimeSeriesVertScale = loadTimeSeriesSettings.getInt("Time Series Vert Scale");
        loadTimeSeriesHorizScale = loadTimeSeriesSettings.getInt("Time Series Horiz Scale");

        ////////Apply Time Series widget settings
        VertScale_TS(loadTimeSeriesVertScale);// changes back-end
            w_timeSeries.cp5_widget.getController("VertScale_TS").getCaptionLabel().setText(tsVertScaleArray[loadTimeSeriesVertScale]); //changes front-end
        Duration(loadTimeSeriesHorizScale);
            w_timeSeries.cp5_widget.getController("Duration").getCaptionLabel().setText(tsHorizScaleArray[loadTimeSeriesHorizScale]);
            
    } //end loadApplyTimeSeriesSettings

    /**
      * @description Used in TopNav when user clicks ClearSettings->AreYouSure->Yes
      * @params none
      * Output Success message to bottom of GUI when done
      */
    void clearAll() {
        for (File file: new File(settingsPath).listFiles())
            if (!file.isDirectory())
                file.delete();
        controlPanel.recentPlaybackBox.cp5_recentPlayback_dropdown.get(ScrollableList.class, "recentFiles").clear();
        controlPanel.recentPlaybackBox.shortFileNames.clear();
        controlPanel.recentPlaybackBox.longFilePaths.clear();
        outputSuccess("All settings have been cleared!");
    }

    /**
      * @description Used in System Init, TopNav, and Interactivity
      * @params mode="User"or"Default", dataSource, and number of channels
      * @returns {String} - filePath or Error if mode not specified correctly
      */
    String getPath(String _mode, int dataSource, int _nchan) {
        String filePath = settingsPath;
        String[] fileNames = new String[7];
        if (_mode.equals("Default")) {
            fileNames = defaultSettingsFiles;
        } else if (_mode.equals("User")) {
            fileNames = userSettingsFiles;
        } else {
            filePath = "Error";
        }
        if (!filePath.equals("Error")) {
            if (dataSource == DATASOURCE_CYTON) {
                filePath += (_nchan == NCHAN_CYTON) ?
                    fileNames[0] :
                    fileNames[1];
            } else if (dataSource == DATASOURCE_GANGLION) {
                filePath += fileNames[2];
            } else if (dataSource ==  DATASOURCE_NOVAXR) {
                filePath += fileNames[3];
            } else if (dataSource ==  DATASOURCE_PLAYBACKFILE) {
                filePath += fileNames[4];
            } else if (dataSource == DATASOURCE_SYNTHETIC) {
                if (_nchan == NCHAN_GANGLION) {
                    filePath += fileNames[5];
                } else if (_nchan == NCHAN_CYTON) {
                    filePath += fileNames[6];
                } else {
                    filePath += fileNames[7];
                }
            }
        }
        return filePath;
    }

    void initCheckPointFive() {
        if (eegDataSource == DATASOURCE_NOVAXR) {
            outputSuccess("NovaXR Firmware == " + "WIP");
        } else {
            outputSuccess("Session started!");
        }
    }

    void loadKeyPressed() {
        loadErrorTimerStart = millis();
        String settingsFileToLoad = getPath("User", eegDataSource, nchan);
        try {
            load(settingsFileToLoad);
            errorUserSettingsNotFound = false;
        } catch (Exception e) {
            //println(e.getMessage());
            e.printStackTrace();
            println(settingsFileToLoad + " not found or other error. Save settings with keyboard 'n' or using dropdown menu.");
            errorUserSettingsNotFound = true;
        }
        //Output message when Loading settings is complete
        String err = null;
        if (chanNumError == false && dataSourceError == false && errorUserSettingsNotFound == false && loadErrorCytonEvent == false) {
            outputSuccess("Settings Loaded!");
        } else if (chanNumError) {
            err = "Invalid number of channels";
        } else if (dataSourceError) {
            err = "Invalid data source";
        } else if (errorUserSettingsNotFound) {
            err = settingsFileToLoad + " not found.";
        }

        //Only try to delete file for SettingsNotFound/Broken settings
        if (err != null && (!chanNumError && !dataSourceError)) {
            println("Load Settings Error: " + err);
            File f = new File(settingsFileToLoad);
            if (f.exists()) {
                if (f.delete()) {
                    outputError("Found old/broken GUI settings. Please reconfigure the GUI and save new settings.");
                } else {
                    outputError("SoftwareSettings: Error deleting old/broken settings file...");
                }
            }
        }
    }

    void saveButtonPressed() {
        if (saveDialogName == null) {
            selectOutput("Save a custom settings file as JSON:",
                        "saveConfigFile",
                        dataFile(settings.getPath("User", eegDataSource, nchan)));
        } else {
            println("saveSettingsFileName = " + saveDialogName);
            saveDialogName = null;
        }
    }

    void loadButtonPressed() {
        //Select file to load from dialog box
        if (loadDialogName == null) {
            selectInput("Load a custom settings file from JSON:", "loadConfigFile");
            saveDialogName = null;
        } else {
            println("loadSettingsFileName = " + loadDialogName);
            loadDialogName = null;
        }
    }

    void defaultButtonPressed() {
        //Revert GUI to default settings that were flashed on system start!
        String defaultSettingsFileToLoad = getPath("Default", eegDataSource, nchan);
        try {
            //Load all saved User Settings from a JSON file to see if it exists
            JSONObject loadDefaultSettingsJSONData = loadJSONObject(defaultSettingsFileToLoad);
            this.load(defaultSettingsFileToLoad);
            outputSuccess("Default Settings Loaded!");
        } catch (Exception e) {
            outputError("Default Settings Error: Valid Default Settings will be saved next system start.");
            File f = new File(defaultSettingsFileToLoad);
            if (f.exists()) {
                if (f.delete()) {
                    println("SoftwareSettings: Old/Broken Default Settings file succesfully deleted.");
                } else {
                    println("SoftwareSettings: Error deleting Default Settings file...");
                }
            }
        }
    }

    
} //end of Software Settings class

void imposeMinimumGUIDimensions() {
    //impose minimum gui dimensions
    if (width < settings.minGUIWidth || height < settings.minGUIHeight) {
        if (width < settings.minGUIWidth) win_x = settings.minGUIWidth;
        if (height < settings.minGUIHeight) win_y = settings.minGUIHeight;
        surface.setSize(win_x, win_y);
    }
}


//////////////////////////////////////////
//  Global Functions                    //
// Called by Buttons with the same name //
//////////////////////////////////////////
// Select file to save custom settings using dropdown in TopNav.pde
void saveConfigFile(File selection) {
    if (selection == null) {
        println("SoftwareSettings: saveConfigFile: Window was closed or the user hit cancel.");
    } else {
        println("SoftwareSettings: saveConfigFile: User selected " + selection.getAbsolutePath());
        settings.saveDialogName = selection.getAbsolutePath();
        settings.save(settings.saveDialogName); //save current settings to JSON file in SavedData
        outputSuccess("Settings Saved! The GUI will now load with these settings. Click \"Default\" to revert to factory settings."); //print success message to screen
        settings.saveDialogName = null; //reset this variable for future use
    }
}
// Select file to load custom settings using dropdown in TopNav.pde
void loadConfigFile(File selection) {
    if (selection == null) {
        println("SoftwareSettings: loadConfigFile: Window was closed or the user hit cancel.");
    } else {
        println("SoftwareSettings: loadConfigFile: User selected " + selection.getAbsolutePath());
        //output("You have selected \"" + selection.getAbsolutePath() + "\" to Load custom settings.");
        settings.loadDialogName = selection.getAbsolutePath();
        try {
            settings.load(settings.loadDialogName); //load settings from JSON file in /data/
            //Output success message when Loading settings is complete without errors
            if (settings.chanNumError == false
                && settings.dataSourceError == false
                && settings.loadErrorCytonEvent == false) {
                    outputSuccess("Settings Loaded!");
                }
        } catch (Exception e) {
            println("SoftwareSettings: Incompatible settings file or other error");
            if (settings.chanNumError == true) {
                outputError("Settings Error:  Channel Number Mismatch Detected");
            } else if (settings.dataSourceError == true) {
                outputError("Settings Error: Data Source Mismatch Detected");
            } else {
                outputError("Error trying to load settings file, possibly from previous GUI. Removing old settings.");
                if (selection.exists()) selection.delete();
            }
        }
        settings.loadDialogName = null; //reset this variable for future use
    }
}