public class FilterSettingsValues {
    //public BandPassStart[] bpStartFreq;
    //public BandPassStop[] bpStopFreq;
    //public BandStopCenter[] bsCenterFreq;
    //public FilterType[] bpFilterType;
    public FilterActiveOnChannel[] bandStopFilterActive;
    public double[] bandStopCenterFreq;
    public double[] bandStopWidth;
    public BrainFlowFilterType[] bandStopFilterType;
    public BrainFlowFilterOrder[] bandStopFilterOrder;

    public FilterActiveOnChannel[] bandPassFilterActive;
    public double[] bandPassCenterFreq;
    public double[] bandPassWidth;
    public BrainFlowFilterType[] bandPassFilterType;
    public BrainFlowFilterOrder[] bandPassFilterOrder;

    public GlobalEnvironmentalFilter globalEnvironmentalFilter;

    public FilterSettingsValues(int channelCount) {
        bandStopFilterActive = new FilterActiveOnChannel[channelCount];
        bandStopCenterFreq = new double[channelCount];
        bandStopWidth = new double[channelCount];
        bandStopFilterType = new BrainFlowFilterType[channelCount];
        bandStopFilterOrder = new BrainFlowFilterOrder[channelCount];
        Arrays.fill(bandStopFilterActive, FilterActiveOnChannel.OFF);
        Arrays.fill(bandStopCenterFreq, 60);
        Arrays.fill(bandStopWidth, 4);
        Arrays.fill(bandStopFilterType, BrainFlowFilterType.BUTTERWORTH);
        Arrays.fill(bandStopFilterOrder, BrainFlowFilterOrder.TWO);


        bandPassFilterActive = new FilterActiveOnChannel[channelCount];
        bandPassCenterFreq = new double[channelCount];
        bandPassWidth = new double[channelCount];
        bandPassFilterType = new BrainFlowFilterType[channelCount];
        bandPassFilterOrder = new BrainFlowFilterOrder[channelCount];
        //Default to 5-50Hz Bandpass on all channels since this has been the default for years
        Pair<Double, Double> bandPassRange = calcBandPassCenterAndWidth(5, 50);
        Arrays.fill(bandStopFilterActive, FilterActiveOnChannel.OFF);
        Arrays.fill(bandStopCenterFreq, bandPassRange.getLeft());
        Arrays.fill(bandStopWidth, bandPassRange.getRight());
        Arrays.fill(bandStopFilterType, BrainFlowFilterType.BUTTERWORTH);
        Arrays.fill(bandStopFilterOrder, BrainFlowFilterOrder.TWO);
    }

    public Pair<Double, Double> calcBandPassCenterAndWidth(int start, int stop) {
        double centerFreq = (start + stop) / 2.0;
        double bandWidth = stop - start;
        return new ImmutablePair<Double, Double>(centerFreq, bandWidth);
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

        /*
        String currentVals = getJson();
        Gson gson = new Gson();
        defaultValues = gson.fromJson(currentVals, FilterSettingsValues.class);
        */
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

    //Called in UI to control number of channels. This is set from the board when this class is instantiated.
    public int getChannelCount() {
        return channelCount;
    }
}