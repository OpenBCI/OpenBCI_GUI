// Refactored: Richard Waltman, April 2025

class SessionSettings {
    // Current version and configuration
    private String settingsVersion = "5.0.0";
    public int currentLayout;
    
    // Screen resizing variables
    public boolean screenHasBeenResized = false;
    public float timeOfLastScreenResize = 0;
    public int widthOfLastScreen = 0, heightOfLastScreen = 0;
    
    // Animation timer
    public int introAnimationInit = 0;
    public final int INTRO_ANIMATION_DURATION = 2500;
    
    // JSON data for saving/loading
    private JSONObject saveSettingsJSONData;
    private JSONObject loadSettingsJSONData;
    
    // Dialog control variables
    String saveDialogName; 
    String loadDialogName;
    String controlEventDataSource;
    
    // Error handling
    boolean chanNumError = false;
    boolean dataSourceError = false;
    boolean errorUserSettingsNotFound = false; 
    boolean loadErrorCytonEvent = false;
    int loadErrorTimerStart;
    int loadErrorTimeWindow = 5000; 
    final int initTimeoutThreshold = 12000;
    
    // Constants for JSON keys
    private final String 
        KEY_GLOBAL = "globalSettings",
        KEY_VERSION = "guiVersion",
        KEY_SETTINGS_VERSION = "sessionSettingsVersion",
        KEY_CHANNELS = "channelCount",
        KEY_DATA_SOURCE = "dataSource",
        KEY_SMOOTHING = "dataSmoothing",
        KEY_LAYOUT = "widgetLayout",
        KEY_NETWORKING = "networking",
        KEY_CONTAINERS = "widgetContainerSettings",
        KEY_WIDGET_SETTINGS = "widgetSettings",
        KEY_FILTER_SETTINGS = "filterSettings",
        KEY_EMG_SETTINGS = "emgSettings";
    
    // File paths configuration
    private final String[][] SETTING_FILES = {
        {"CytonUserSettings.json", "CytonDefaultSettings.json"},
        {"DaisyUserSettings.json", "DaisyDefaultSettings.json"},
        {"GanglionUserSettings.json", "GanglionDefaultSettings.json"},
        {"PlaybackUserSettings.json", "PlaybackDefaultSettings.json"},
        {"SynthFourUserSettings.json", "SynthFourDefaultSettings.json"},
        {"SynthEightUserSettings.json", "SynthEightDefaultSettings.json"},
        {"SynthSixteenUserSettings.json", "SynthSixteenDefaultSettings.json"}
    };
    private final int FILE_USER = 0, FILE_DEFAULT = 1;

    /**
     * Initialize settings during system startup
     */
    void init() {
        String defaultFile = getPath("Default", eegDataSource, globalChannelCount);
        println("InitSettings: Saving Default Settings to file!");
        try {
            save(defaultFile);
        } catch (Exception e) {
            outputError("Failed to save Default Settings during Init. Please submit an Issue on GitHub.");
            e.printStackTrace();
        }
    }

    /**
     * Save current settings to a file
     */
    void save(String saveFilePath) {
        // Create main JSON object and global settings
        saveSettingsJSONData = new JSONObject();
        JSONObject globalSettings = new JSONObject();
        
        // Add global settings
        globalSettings.setString(KEY_VERSION, localGUIVersionString);
        globalSettings.setString(KEY_SETTINGS_VERSION, settingsVersion);
        globalSettings.setInt(KEY_CHANNELS, globalChannelCount);
        globalSettings.setInt(KEY_DATA_SOURCE, eegDataSource);
        globalSettings.setInt(KEY_LAYOUT, currentLayout);
        
        // Add data smoothing setting if applicable
        if (currentBoard instanceof SmoothingCapableBoard) {
            globalSettings.setBoolean(KEY_SMOOTHING, 
                ((SmoothingCapableBoard)currentBoard).getSmoothingActive());
        }
        
        // Add all settings to the main JSON object
        saveSettingsJSONData.setJSONObject(KEY_GLOBAL, globalSettings);
        saveSettingsJSONData.setJSONObject(KEY_NETWORKING, 
            parseJSONObject(dataProcessing.networkingSettings.getJson()));
        saveSettingsJSONData.setJSONObject(KEY_CONTAINERS, saveWidgetContainerPositions());
        saveSettingsJSONData.setJSONObject(KEY_WIDGET_SETTINGS, 
            parseJSONObject(widgetManager.getWidgetSettingsAsJson()));
        saveSettingsJSONData.setJSONObject(KEY_FILTER_SETTINGS,
            parseJSONObject(filterSettings.getJson()));
        saveSettingsJSONData.setJSONObject(KEY_EMG_SETTINGS,
            parseJSONObject(dataProcessing.emgSettings.getJson()));
        
        // Save to file
        saveJSONObject(saveSettingsJSONData, saveFilePath);
    }

    /**
     * Save widget container positions
     */
    private JSONObject saveWidgetContainerPositions() {
        JSONObject widgetLayout = new JSONObject();
        int numActiveWidgets = 0;
        
        // Save active widgets and their container positions
        for (int i = 0; i < widgetManager.widgets.size(); i++) {
            Widget widget = widgetManager.widgets.get(i);
            if (widget.getIsActive()) {
                numActiveWidgets++;
                widgetLayout.setInt("Widget_" + i, widget.currentContainer);
            }
        }
        
        println("SessionSettings: " + numActiveWidgets + " active widgets saved!");
        return widgetLayout;
    }

    /**
     * Load settings from a file
     */
    void load(String loadFilePath) throws Exception {
        // Load and parse JSON data
        loadSettingsJSONData = loadJSONObject(loadFilePath);
        JSONObject globalSettings = loadSettingsJSONData.getJSONObject(KEY_GLOBAL);
        
        // Validate settings match current configuration
        validateSettings(globalSettings);
        
        // Apply settings in order
        currentLayout = globalSettings.getInt(KEY_LAYOUT);
        applyDataSmoothingSettings(globalSettings);
        applyNetworkingSettings();
        applyWidgetLayout();
        applyWidgetSettings();
        applyFilterSettings();
        applyEmgSettings();
    }
    
    /**
     * Validate that loaded settings are compatible with current configuration
     */
    private void validateSettings(JSONObject globalSettings) throws Exception {
        // Check channel count match
        int loadedChannels = globalSettings.getInt(KEY_CHANNELS);
        if (loadedChannels != globalChannelCount) {
            chanNumError = true;
            throw new Exception("Channel count mismatch");
        }
        chanNumError = false;
        
        // Check data source match
        int loadedDataSource = globalSettings.getInt(KEY_DATA_SOURCE);
        if (loadedDataSource != eegDataSource) {
            dataSourceError = true;
            throw new Exception("Data source mismatch");
        }
        dataSourceError = false;
    }
    
    /**
     * Apply data smoothing settings if available
     */
    private void applyDataSmoothingSettings(JSONObject globalSettings) {
        if (currentBoard instanceof SmoothingCapableBoard && 
            globalSettings.hasKey(KEY_SMOOTHING)) {
            
            ((SmoothingCapableBoard)currentBoard).setSmoothingActive(
                globalSettings.getBoolean(KEY_SMOOTHING));
            topNav.updateSmoothingButtonText();
        }
    }
    
    /**
     * Apply networking settings
     */
    private void applyNetworkingSettings() {
        dataProcessing.networkingSettings.loadJson(
            loadSettingsJSONData.getJSONObject(KEY_NETWORKING).toString());
    }
    
    /**
    * Apply widget layout and container positions
    */
    private void applyWidgetLayout() {
        // Set layout first
        widgetManager.setNewContainerLayout(currentLayout);
        
        // Deactivate all widgets initially
        for (Widget widget : widgetManager.widgets) {
            widget.setIsActive(false);
        }
        
        // Get widget container settings
        JSONObject containerSettings = loadSettingsJSONData.getJSONObject(KEY_CONTAINERS);
        
        // Activate widgets and set containers
        // Fix: Properly handle keys as a Set<String> from containerSettings.keys()
        for (Object keyObj : containerSettings.keys()) {
            String key = keyObj.toString();
            String[] keyParts = split(key, '_');
            int widgetIndex = Integer.valueOf(keyParts[1]);
            int containerIndex = containerSettings.getInt(key);
            
            Widget widget = widgetManager.widgets.get(widgetIndex);
            widget.setIsActive(true);
            widget.setContainer(containerIndex);
        }
    }
    
    /**
     * Apply individual widget settings
     */
    private void applyWidgetSettings() {
        widgetManager.loadWidgetSettingsFromJson(
            loadSettingsJSONData.getJSONObject(KEY_WIDGET_SETTINGS).toString());
    }

    private void applyFilterSettings() {
        JSONObject filterSettingsJSON = loadSettingsJSONData.getJSONObject(KEY_FILTER_SETTINGS);
        String filterSettingsString = filterSettingsJSON.toString();
        filterSettings.loadSettingsFromJson(filterSettingsString);
    }

    private void applyEmgSettings() {
        JSONObject emgSettingsJSON = loadSettingsJSONData.getJSONObject(KEY_EMG_SETTINGS);
        String emgSettingsString = emgSettingsJSON.toString();
        dataProcessing.emgSettings.loadSettingsFromJson(emgSettingsString);
    }

    /**
     * Get the appropriate settings file path based on mode and configuration
     */
    String getPath(String mode, int dataSource, int channelCount) {
        // Determine which settings file to use
        int modeIndex = mode.equals("Default") ? FILE_DEFAULT : FILE_USER;
        int fileIndex;
        
        if (dataSource == DATASOURCE_CYTON) {
            fileIndex = (channelCount == CYTON_CHANNEL_COUNT) ? 0 : 1;
        } else if (dataSource == DATASOURCE_GANGLION) {
            fileIndex = 2;
        } else if (dataSource == DATASOURCE_PLAYBACKFILE) {
            fileIndex = 3;
        } else if (dataSource == DATASOURCE_SYNTHETIC) {
            if (channelCount == GANGLION_CHANNEL_COUNT) {
                fileIndex = 4;
            } else if (channelCount == CYTON_CHANNEL_COUNT) {
                fileIndex = 5;
            } else {
                fileIndex = 6;
            }
        } else {
            return "Error";
        }
        
        return directoryManager.getSettingsPath() + SETTING_FILES[fileIndex][modeIndex];
    }

    /**
     * Clear all settings files
     */
    void clearAll() {
        // Delete all settings files
        for (File file : new File(directoryManager.getSettingsPath()).listFiles()) {
            if (!file.isDirectory()) {
                file.delete();
            }
        }
        
        // Clear playback history
        controlPanel.recentPlaybackBox.rpb_cp5.get(ScrollableList.class, "recentPlaybackFilesCP").clear();
        controlPanel.recentPlaybackBox.shortFileNames.clear();
        controlPanel.recentPlaybackBox.longFilePaths.clear();
        
        outputSuccess("All settings have been cleared!");
    }

    /**
     * Handle key press to load settings
     */
    void loadKeyPressed() {
        loadErrorTimerStart = millis();
        String settingsFile = getPath("User", eegDataSource, globalChannelCount);
        
        try {
            load(settingsFile);
            errorUserSettingsNotFound = false;
            outputSuccess("Settings Loaded!");
        } catch (Exception e) {
            errorUserSettingsNotFound = true;
            handleLoadError(settingsFile);
        }
    }
    
    /**
     * Handle errors when loading settings
     */
    private void handleLoadError(String settingsFile) {
        if (chanNumError) {
            outputError("Settings Error: Channel Number Mismatch");
        } else if (dataSourceError) {
            outputError("Settings Error: Data Source Mismatch");
        } else {
            File f = new File(settingsFile);
            if (f.exists() && f.delete()) {
                outputError("Found old/broken GUI settings. Please reconfigure the GUI and save new settings.");
            } else if (f.exists()) {
                outputError("Error deleting old/broken settings file.");
            }
        }
    }

    /**
     * Handle save button press
     */
    void saveButtonPressed() {
        if (saveDialogName == null) {
            // Open file chooser dialog
            File fileToSave = dataFile(getPath("User", eegDataSource, globalChannelCount));
            new FileChooser(FileChooserMode.SAVE, "saveConfigFile", fileToSave, 
                           "Save settings to file");
        } else {
            saveDialogName = null;
        }
    }

    /**
     * Handle load button press
     */
    void loadButtonPressed() {
        if (loadDialogName == null) {
            // Open file chooser dialog
            new FileChooser(FileChooserMode.LOAD, "loadConfigFile",
                           new File(directoryManager.getGuiDataPath() + "Settings"),
                           "Select a settings file to load");
            saveDialogName = null;
        } else {
            loadDialogName = null;
        }
    }

    /**
     * Reset to default settings
     */
    void defaultButtonPressed() {
        String defaultFile = getPath("Default", eegDataSource, globalChannelCount);
        try {
            // Check if default settings exist and load them
            loadJSONObject(defaultFile);
            load(defaultFile);
            outputSuccess("Default Settings Loaded!");
        } catch (Exception e) {
            outputError("Default Settings Error: Valid Default Settings will be saved next system start.");
            File f = new File(defaultFile);
            if (f.exists() && !f.delete()) {
                println("SessionSettings: Error deleting Default Settings file...");
            }
        }
    }

    /**
     * Auto-load settings at startup
     */
    public void autoLoadSessionSettings() {
        loadKeyPressed();
    }
}

/**
 * Process file selection for saving settings
 */
void saveConfigFile(File selection) {
    if (selection == null) {
        return;
    }
    
    sessionSettings.save(selection.getAbsolutePath());
    outputSuccess("Settings Saved! Using Expert Mode, you can load these settings using 'N' key.");
    sessionSettings.saveDialogName = null;
}

/**
 * Process file selection for loading settings
 */
void loadConfigFile(File selection) {
    if (selection == null) {
        return;
    }
    
    try {
        sessionSettings.load(selection.getAbsolutePath());
        if (!sessionSettings.chanNumError && !sessionSettings.dataSourceError && 
            !sessionSettings.loadErrorCytonEvent) {
            outputSuccess("Settings Loaded!");
        }
    } catch (Exception e) {
        handleLoadConfigError(selection);
    }
    
    sessionSettings.loadDialogName = null;
}

/**
 * Handle errors in loadConfigFile
 */
void handleLoadConfigError(File selection) {
    if (sessionSettings.chanNumError) {
        outputError("Settings Error: Channel Number Mismatch Detected");
    } else if (sessionSettings.dataSourceError) {
        outputError("Settings Error: Data Source Mismatch Detected");
    } else {
        outputError("Error trying to load settings file, possibly from previous GUI.");
        if (selection.exists()) {
            selection.delete();
        }
    }
}