class EmgSettings {
    
    public EmgSettingsValues values;

    private int channelCount;

    private boolean settingsWereLoaded = false;

    EmgSettings() {
        channelCount = currentBoard.getNumEXGChannels();
        values = new EmgSettingsValues();
    }

    public boolean loadSettingsValues(String filename) {
        try {
            File file = new File(filename);
            StringBuilder fileContents = new StringBuilder((int)file.length());        
            Scanner scanner = new Scanner(file);
            while(scanner.hasNextLine()) {
                fileContents.append(scanner.nextLine() + System.lineSeparator());
            }
            Gson gson = new Gson();
            EmgSettingsValues tempValues = gson.fromJson(fileContents.toString(), EmgSettingsValues.class);
            if (tempValues.smoothing.length != channelCount) {
                outputError("Emg Settings: Loaded EMG Settings file has different number of channels than the current board.");
                return false;
            }
            //Explicitely copy values over to avoid reference issues
            //(e.g. values = tempValues "nukes" the old values object)
            values.smoothing = tempValues.smoothing;
            values.uvLimit = tempValues.uvLimit;
            values.creepIncreasing = tempValues.creepIncreasing;
            values.creepDecreasing = tempValues.creepDecreasing;
            values.minimumDeltaUV = tempValues.minimumDeltaUV;
            values.lowerThresholdMinimum = tempValues.lowerThresholdMinimum;
            return true;
        } catch (IOException e) {
            e.printStackTrace();    
            File f = new File(filename);
            if (f.exists()) {
                if (f.delete()) {
                    outputError("Emg Settings: Could not load EMG settings from disk. Deleting this file...");
                } else {
                    outputError("Emg Settings: Error deleting old/broken EMG settings file! Please make sure the GUI has proper read/write permissions.");
                }
            }
            return false;
        }
    }

    public String getJson() {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        return gson.toJson(values);
    }

    public boolean saveToFile(String filename) {
        String json = getJson();
        try {
            FileWriter writer = new FileWriter(filename);
            writer.write(json);
            writer.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public void revertAllChannelsToDefaultValues() {
        values = new EmgSettingsValues();
        settingsWereLoaded = true;
    }

    //Called in UI to control number of channels. This is set from the board when this class is instantiated.
    public int getChannelCount() {
        return channelCount;
    }

    //Avoid error with popup being in another thread.
    public void storeSettings() {
        StringBuilder settingsFilename = new StringBuilder(directoryManager.getSettingsPath());
        settingsFilename.append("EmgSettings");
        settingsFilename.append("_");
        settingsFilename.append(getChannelCount());
        settingsFilename.append("Channels.json");
        String filename = settingsFilename.toString();
        File fileToSave = new File(filename);
        selectOutput("Save EMG settings to file", "storeEmgSettings", fileToSave);
    }

    //Avoid error with popup being in another thread.
    public void loadSettings() {
        StringBuilder settingsFilename = new StringBuilder(directoryManager.getSettingsPath());
        settingsFilename.append("EmgSettings");
        settingsFilename.append("_");
        settingsFilename.append(getChannelCount());
        settingsFilename.append("Channels.json");
        String filename = settingsFilename.toString();
        File fileToLoad = new File(filename);
        selectInput("Select EMG settings file to load", "loadEmgSettings", fileToLoad);
    }

    public boolean getSettingsWereLoaded() {
        return settingsWereLoaded;
    }

    public void setSettingsWereLoaded(boolean settingsWereLoaded) {
        this.settingsWereLoaded = settingsWereLoaded;
    }
}

//Used by button in the EMG UI. Must be global and public. Called in above loadSettings method.
public void loadEmgSettings(File selection) {
    if (selection == null) {
        output("EMG Settings file not selected.");
    } else {
        if (dataProcessing.emgSettings.loadSettingsValues(selection.getAbsolutePath())) {
            outputSuccess("EMG Settings Loaded!");
            dataProcessing.emgSettings.setSettingsWereLoaded(true);
        }
    }
}

//Used by button in the EMG UI. Must be global and public. Called in above storeSettings method.
public void storeEmgSettings(File selection) {
    if (selection == null) {
        output("EMG Settings file not selected.");
    } else {
        if (dataProcessing.emgSettings.saveToFile(selection.getAbsolutePath())) {
            outputSuccess("EMG Settings Saved!");
        } else {
            outputError("Failed to save EMG Settings.");
        }
    }
}