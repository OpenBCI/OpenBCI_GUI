class DataSourceSDCard implements DataSource, FileBoard  {

    private String filePath;
    private int samplingRate;
    private ArrayList<double[]> data;
    private int[] exgChannels;
    private boolean streaming;
    private double startTime;
    private int counter;
    private int currentSample;
    private int timeOfLastUpdateMS;
    private boolean initialized;

    DataSourceSDCard(String filePath) {
        this.filePath = filePath;
        samplingRate = 0;
        data = new ArrayList<double[]>();
        streaming = false;
        exgChannels = null;
        counter = 0;
        startTime = 0.0;
        timeOfLastUpdateMS = 0;
        initialized = false;
    }

    @Override
    public boolean initialize() {
        try {
        File file = new File(this.filePath);
        Scanner reader = new Scanner(file);
        startTime = millis() / 1000.0;
        while (reader.hasNextLine()) {
            String data = reader.nextLine();
            String[] splitted = data.split(",");
            if (splitted.length < 8) {
                continue;
            }
            if (splitted.length < 15) {
                parseRow(splitted, 8);
                if (samplingRate == 0) {
                    samplingRate = 250;
                    exgChannels = new int[] {1,2,3,4,5,6,7,8};
                }
            }
            else {
                parseRow(splitted, 16);
                if (samplingRate == 0) {
                    samplingRate = 125;
                    exgChannels = new int[] {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
                }
            }
            counter++;
        }
        reader.close();
        println("Initialized, data len is " + data.size() + " Num Channels is " + exgChannels.length);
        initialized = true;
        return true;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void parseRow(String[] row, int numChannels) {
        double[] line = new double[numChannels + 2]; // add package num and timestamp
        if (row.length < numChannels - 1) {
            return;
        }
        for (int i = 0; i < numChannels + 1; i++) {
            Integer val = Integer.parseInt(row[i], 16);
            double res = val;
            if (i != 0) {
                res = val * BoardCytonConstants.scale_fac_uVolts_per_count;
            }
            line[i] = res;
        }
        // add timestamp
        double delay = (numChannels == 16) ? (1.0 / 125) : (1.0 / 250);
        double timestamp = startTime + counter * delay;
        line[line.length - 1] = timestamp;
        data.add(line);
    }

    @Override
    public void uninitialize() {
        data = new ArrayList<double[]>();
        streaming = false;
        exgChannels = null;
        counter = 0;
        startTime = 0.0;
        timeOfLastUpdateMS = 0;
        initialized = false;
    }

    @Override
    public void update() {
        if (!streaming) {
            return; // do not update
        }

        float sampleRateMS = getSampleRate() / 1000.f;
        int timeElapsedMS = millis() - timeOfLastUpdateMS;
        int numNewSamplesThisFrame = floor(timeElapsedMS * sampleRateMS);

        // account for the fact that each update will not coincide with a sample exactly. 
        // to keep the streaming rate accurate, we increment the time of last update
        // based on how many samples we incremented this frame.
        timeOfLastUpdateMS += numNewSamplesThisFrame / sampleRateMS;

        currentSample += numNewSamplesThisFrame;

        // don't go beyond raw data array size
        currentSample = min(currentSample, data.size());
    }

    @Override
    public void startStreaming() {
        streaming = true;
        timeOfLastUpdateMS = millis();
    }

    @Override
    public void stopStreaming() {
        streaming = false;
    }

    @Override
    public int getSampleRate() {
        return samplingRate;
    }

    @Override
    public void setEXGChannelActive(int channelIndex, boolean active) {
        outputWarn("Deactivating channels is not possible for Playback board.");
    }

    @Override
    public boolean isEXGChannelActive(int channelIndex) {
        return true;
    }
    
    @Override
    public int[] getEXGChannels() {
        return exgChannels;
    }
    
    @Override
    public int getNumEXGChannels() {
        return getEXGChannels().length;
    }

    @Override
    public int getTimestampChannel() {
        if ((data == null) || (data.size() == 0)) {
            return 0;
        }
        return data.size() - 1;
    }

    @Override
    public int getSampleNumberChannel() {
        return 0;
    }

    @Override
    public int getTotalChannelCount() {
        return exgChannels.length + 2;
    }

    @Override
    public double[][] getFrameData() {
        // empty data (for now?)
        return new double[getTotalChannelCount()][0];
    }

    @Override
    public List<double[]> getData(int maxSamples) {
        int firstSample = max(0, currentSample - maxSamples);
        List<double[]> result = data.subList(firstSample, currentSample);

        // if needed, pad the beginning of the array with empty data
        if (maxSamples > currentSample) {
            int sampleDiff = maxSamples - currentSample;

            double[] emptyData = new double[getTotalChannelCount()];
            ArrayList<double[]> newResult = new ArrayList(maxSamples);
            for (int i=0; i<sampleDiff; i++) {
                newResult.add(emptyData);
            }
            
            newResult.addAll(result);
            return newResult;
        }

        return result;
    }

    @Override
    public int getTotalSamples() {
        return data.size();
    }

    @Override
    public float getTotalTimeSeconds() {
        return float(getTotalSamples()) / float(getSampleRate());
    }

    @Override
    public int getCurrentSample() {
        return currentSample;
    }

    @Override
    public float getCurrentTimeSeconds() {
        return float(getCurrentSample()) / float(getSampleRate());
    }

    @Override
    public void goToIndex(int index) {
        currentSample = index;
    }

}