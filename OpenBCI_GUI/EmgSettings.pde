class EmgSettings {
    
    public EmgSettingsValues values;

    private int channelCount;

    private boolean settingsWereLoaded = false;

    EmgSettings() {
        channelCount = currentBoard.getNumEXGChannels();
        values = new EmgSettingsValues();
    }

    public String getJson() {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        return gson.toJson(values);
    }

    public boolean loadSettingsFromJson(String json) {
        try {
            Gson gson = new Gson();
            EmgSettingsValues tempValues = gson.fromJson(json, EmgSettingsValues.class);
            
            // Validate channel count matches
            if (tempValues.window.length != channelCount) {
                outputError("Emg Settings: Loaded EMG Settings JSON has different number of channels than the current board.");
                return false;
            }
            
            // Explicitly copy values to avoid reference issues
            values.window = tempValues.window;
            values.uvLimit = tempValues.uvLimit;
            values.creepIncreasing = tempValues.creepIncreasing;
            values.creepDecreasing = tempValues.creepDecreasing;
            values.minimumDeltaUV = tempValues.minimumDeltaUV;
            values.lowerThresholdMinimum = tempValues.lowerThresholdMinimum;
            
            settingsWereLoaded = true;
            return true;
        } catch (Exception e) {
            e.printStackTrace();    
            outputError("EmgSettings: Could not load EMG settings from JSON string.");
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

    public boolean getSettingsWereLoaded() {
        return settingsWereLoaded;
    }

    public void setSettingsWereLoaded(boolean settingsWereLoaded) {
        this.settingsWereLoaded = settingsWereLoaded;
    }
}