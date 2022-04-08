public class FilterSettingsValues {
    //public BandPassStart[] bpStartFreq;
    //public BandPassStop[] bpStopFreq;
    //public BandStopCenter[] bsCenterFreq;
    //public FilterType[] bpFilterType;
    public FilterActiveOnChannel[] bandstopFilterActive;
    public FilterActiveOnChannel[] bandpassFilterActive;

    public FilterSettingsValues() {
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
        values = new FilterSettingsValues();
        //previousValues = new FilterSettingsValues();
        defaultValues = new FilterSettingsValues();

        channelCount = board.getNumEXGChannels();

        values.bandstopFilterActive = new FilterActiveOnChannel[channelCount];
        Arrays.fill(values.bandstopFilterActive, FilterActiveOnChannel.ON);

        values.bandpassFilterActive = new FilterActiveOnChannel[channelCount];
        Arrays.fill(values.bandpassFilterActive, FilterActiveOnChannel.ON);

        /*
        // initialize all arrays with some defaults
        // (which happen to be Cyton defaults, but they don't have to be.
        // we set defaults on board contruction)
        values.powerDown = new PowerDown[channelCount];
        previousValues.powerDown = new PowerDown[channelCount];
        Arrays.fill(values.powerDown, PowerDown.ON);

        values.gain = new Gain[channelCount];
        previousValues.gain = new Gain[channelCount];
        Arrays.fill(values.gain, Gain.X24);

        values.inputType = new InputType[channelCount];
        previousValues.inputType = new InputType[channelCount];
        Arrays.fill(values.inputType, InputType.NORMAL);
        
        values.bias = new Bias[channelCount];
        previousValues.bias = new Bias[channelCount];
        Arrays.fill(values.bias, Bias.INCLUDE);

        values.srb2 = new Srb2[channelCount];
        previousValues.srb2 = new Srb2[channelCount];
        Arrays.fill(values.srb2, Srb2.CONNECT);

        values.srb1 = new Srb1[channelCount];
        previousValues.srb1 = new Srb1[channelCount];
        Arrays.fill(values.srb1, Srb1.DISCONNECT);
        */

        /*
        values.previousBias = values.bias.clone();
        values.previousSrb2 = values.srb2.clone();
        values.previousInputType = values.inputType.clone();
        */

        String currentVals = getJson();
        Gson gson = new Gson();
        defaultValues = gson.fromJson(currentVals, FilterSettingsValues.class);
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

    /*
    public boolean isChannelActive(int chan) {
        return values.powerDown[chan] == PowerDown.ON;
    }

    public void setChannelActive(int chan, boolean active) {
        values.powerDown[chan] = active ? PowerDown.ON : PowerDown.OFF;
    }
    */

    public void revertAllChannelsToDefaultValues() {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String defaultValsAsString = gson.toJson(defaultValues);
        values = gson.fromJson(defaultValsAsString, FilterSettingsValues.class);
    }

    public int getChannelCount() {
        return channelCount;
    }
}

interface FilterSettingsInterface {

    // Interface methods
    public ADS1299Settings getADS1299Settings();
    public char getChannelSelector(int channel);
    public double getGain(int channel);
    public void setUseDynamicScaler(boolean val);
    public boolean getUseDynamicScaler();
};