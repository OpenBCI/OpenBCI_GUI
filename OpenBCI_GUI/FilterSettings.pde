//Global variable to track if filter settings were loaded.
public boolean filterSettingsWereLoadedFromFile = false;

public class FilterSettingsValues {
    
    public BFFilter brainFlowFilter;
    public FilterChannelSelect filterChannelSelect;
    public GlobalEnvironmentalFilter globalEnvFilter;

    public FilterActiveOnChannel masterBandStopFilterActive;
    public double masterBandStopStartFreq;
    public double masterBandStopStopFreq;
    public BrainFlowFilterType masterBandStopFilterType = BrainFlowFilterType.BUTTERWORTH;
    public BrainFlowFilterOrder masterBandStopFilterOrder = BrainFlowFilterOrder.TWO;

    public FilterActiveOnChannel[] bandStopFilterActive;
    public double[] bandStopStartFreq;
    public double[] bandStopStopFreq;
    public BrainFlowFilterType[] bandStopFilterType;
    public BrainFlowFilterOrder[] bandStopFilterOrder;
    
    public FilterActiveOnChannel masterBandPassFilterActive;
    public double masterBandPassStartFreq;
    public double masterBandPassStopFreq;
    public BrainFlowFilterType masterBandPassFilterType = BrainFlowFilterType.BUTTERWORTH;
    public BrainFlowFilterOrder masterBandPassFilterOrder = BrainFlowFilterOrder.TWO;

    public FilterActiveOnChannel[] bandPassFilterActive;
    public double[] bandPassStartFreq;
    public double[] bandPassStopFreq;
    public BrainFlowFilterType[] bandPassFilterType;
    public BrainFlowFilterOrder[] bandPassFilterOrder;

    public FilterSettingsValues(int channelCount) {
        brainFlowFilter = BFFilter.BANDPASS;
        filterChannelSelect = FilterChannelSelect.ALL_CHANNELS;
        globalEnvFilter = GlobalEnvironmentalFilter.FIFTY_AND_SIXTY;

        //Set Master Values for all channels for BandStop Filter
        masterBandStopFilterActive = FilterActiveOnChannel.OFF;
        masterBandStopStartFreq = 58;
        masterBandStopStopFreq = 62;
        masterBandStopFilterType = BrainFlowFilterType.BUTTERWORTH;
        masterBandStopFilterOrder = BrainFlowFilterOrder.FOUR;
        //Create and assign master value to all channels
        bandStopFilterActive = new FilterActiveOnChannel[channelCount];
        bandStopStartFreq = new double[channelCount];
        bandStopStopFreq = new double[channelCount];
        bandStopFilterType = new BrainFlowFilterType[channelCount];
        bandStopFilterOrder = new BrainFlowFilterOrder[channelCount];
        Arrays.fill(bandStopFilterActive, masterBandStopFilterActive);
        Arrays.fill(bandStopStartFreq, masterBandStopStartFreq);
        Arrays.fill(bandStopStopFreq, masterBandStopStopFreq);
        Arrays.fill(bandStopFilterType, masterBandStopFilterType);
        Arrays.fill(bandStopFilterOrder, masterBandStopFilterOrder);

        //Set Master Values for all channels for BandPass Filter
        //Default to 5-50Hz BandPass on all channels since this has been the default for years
        masterBandPassFilterActive = FilterActiveOnChannel.ON;
        masterBandPassStartFreq = 5;
        masterBandPassStopFreq = 50;
        masterBandPassFilterType = BrainFlowFilterType.BUTTERWORTH;
        masterBandPassFilterOrder = BrainFlowFilterOrder.FOUR;
        //Create and assign master value to all channels
        bandPassFilterActive = new FilterActiveOnChannel[channelCount];
        bandPassStartFreq = new double[channelCount];
        bandPassStopFreq = new double[channelCount];
        bandPassFilterType = new BrainFlowFilterType[channelCount];
        bandPassFilterOrder = new BrainFlowFilterOrder[channelCount];
        Arrays.fill(bandPassFilterActive, masterBandPassFilterActive);
        Arrays.fill(bandPassStartFreq, masterBandPassStartFreq);
        Arrays.fill(bandPassStopFreq, masterBandPassStopFreq);
        Arrays.fill(bandPassFilterType, masterBandPassFilterType);
        Arrays.fill(bandPassFilterOrder, masterBandPassFilterOrder);
    }
}

class FilterSettings {
    
    public FilterSettingsValues values;
    //public FilterSettingsValues previousValues;
    private FilterSettingsValues defaultValues;

    protected DataSource board;
    public int channelCount;

    FilterSettings(DataSource theBoard) {
        board = theBoard;
        channelCount = board.getNumEXGChannels();

        values = new FilterSettingsValues(channelCount);
        defaultValues = new FilterSettingsValues(channelCount);
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
            values = gson.fromJson(fileContents.toString(), FilterSettingsValues.class);
            return true;
        } catch (IOException e) {
            e.printStackTrace();    
            File f = new File(filename);
            if (f.exists()) {
                if (f.delete()) {
                    println("FilterSettings: Could not load filter settings from disk. Deleting this file...");
                } else {
                    println("FilterSettings: Error deleting old/broken filter settings file! Please make sure the GUI has proper read/write permissions.");
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
        values = new FilterSettingsValues(channelCount);
    }

    //Called in UI to control number of channels. This is set from the board when this class is instantiated.
    public int getChannelCount() {
        return channelCount;
    }

    //Avoid error with popup being in another thread.
    public void storeSettings() {
        StringBuilder settingsFilename = new StringBuilder(directoryManager.getSettingsPath());
        settingsFilename.append("FilterSettings");
        settingsFilename.append("_");
        settingsFilename.append(getChannelCount());
        settingsFilename.append("Channels.json");
        String filename = settingsFilename.toString();
        File fileToSave = new File(filename);
        selectOutput("Save filter settings to file", "storeFilterSettings", fileToSave);
    }
    //Avoid error with popup being in another thread.
    public void loadSettings() {
        StringBuilder settingsFilename = new StringBuilder(directoryManager.getSettingsPath());
        settingsFilename.append("FilterSettings");
        settingsFilename.append("_");
        settingsFilename.append(getChannelCount());
        settingsFilename.append("Channels.json");
        String filename = settingsFilename.toString();
        File fileToLoad = new File(filename);
        selectInput("Select settings file to load", "loadFilterSettings", fileToLoad);
    }
}

//Used by button in the Filter UI. Must be global and public.
public void loadFilterSettings(File selection) {
    if (selection == null) {
        output("Filters Settings file not selected.");
    } else {
        if (filterSettings.loadSettingsValues(selection.getAbsolutePath())) {
            outputSuccess("Filter Settings Loaded!");
            filterSettingsWereLoadedFromFile = true;
        } else {
            outputError("Failed to load Filter Settings. The old/broken file has been deleted.");
        }
    }
}

//Used by button in the Filter UI. Must be global and public.
public void storeFilterSettings(File selection) {
    if (selection == null) {
        output("Filter Settings file not selected.");
    } else {
        if (filterSettings.saveToFile(selection.getAbsolutePath())) {
            outputSuccess("Filter Settings Saved!");
        } else {
            outputError("Failed to save Filter Settings.");
        }
    }
}