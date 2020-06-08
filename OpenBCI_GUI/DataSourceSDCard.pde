class DataSourceSDCard implements DataSource, FileBoard, AccelerometerCapableBoard  {

    private String filePath;
    private int samplingRate;
    private ArrayList<double[]> data;
    private int[] exgChannels;
    private int totalChannels;
    private boolean streaming;
    private double startTime;
    private int counter;
    private int currentSample;
    private int timeOfLastUpdateMS;
    private double accel_x;
    private double accel_y;
    private double accel_z;

    DataSourceSDCard(String filePath) {
        this.filePath = filePath;
        samplingRate = 0;
        data = new ArrayList<double[]>();
        streaming = false;
        exgChannels = null;
        counter = 0;
        startTime = 0.0;
        timeOfLastUpdateMS = 0;
        totalChannels = 0;
        accel_x = 0.0;
        accel_y = 0.0;
        accel_z = 0.0;
    }

    @Override
    public boolean initialize() {
        try {
        File file = new File(this.filePath);
        Scanner reader = new Scanner(file);
        startTime = millis() / 1000.0;
        while (reader.hasNextLine()) {
            String line = reader.nextLine();
            String[] splitted = line.split(",");
            if (splitted.length < 8) {
                continue;
            }
            if (splitted.length < 15) {
                if (samplingRate == 0) {
                    samplingRate = 250;
                    exgChannels = new int[] {1,2,3,4,5,6,7,8};
                    totalChannels = 13;
                }
                parseRow(splitted, 8);
            }
            else {
                if (samplingRate == 0) {
                    samplingRate = 125;
                    exgChannels = new int[] {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
                    totalChannels = 21;
                }
                parseRow(splitted, 16);
            }
            counter++;
        }
        reader.close();
        println("Initialized, data len is " + data.size() + " Num EXG Channels is " + exgChannels.length);
        return true;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void parseRow(String[] row, int numChannels) {
        double[] line = new double[totalChannels];
        if (row.length < numChannels - 1) {
            return;
        }
        for (int i = 0; i < numChannels + 1; i++) {
            double res = 0.0;
            if (i == 0) {
                res = Integer.parseInt(row[i], 16);
            }
            else {
                res = parseInt24Hex(row[i]) * BoardCytonConstants.scale_fac_uVolts_per_count;
            }
            line[i] = res;
        }
        // new accel
        if (row.length >= numChannels + 4) {
            accel_x = parseInt16Hex(row[numChannels + 1]);
            accel_y = parseInt16Hex(row[numChannels + 2]);
            accel_z = parseInt16Hex(row[numChannels + 3]);
        }
        line[line.length - 4] = BoardCytonConstants.accelScale * accel_x;
        line[line.length - 3] = BoardCytonConstants.accelScale * accel_y;
        line[line.length - 2] = BoardCytonConstants.accelScale * accel_z;
        // add timestamp
        double delay = 1.0 / samplingRate;
        double timestamp = startTime + counter * delay;
        line[line.length - 1] = timestamp;
        data.add(line);
    }

    @Override
    public void uninitialize() {
        samplingRate = 0;
        data = new ArrayList<double[]>();
        streaming = false;
        exgChannels = null;
        counter = 0;
        startTime = 0.0;
        timeOfLastUpdateMS = 0;
        totalChannels = 0;
        accel_x = 0.0;
        accel_y = 0.0;
        accel_z = 0.0;
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
        currentSample = min(currentSample, data.size() - 1);
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
        return totalChannels - 1;
    }

    @Override
    public int getSampleNumberChannel() {
        return 0;
    }

    @Override
    public int getTotalChannelCount() {
        return totalChannels;
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

    @Override
    public boolean isAccelerometerActive() { 
        return true;
    }

    @Override
    public void setAccelerometerActive(boolean active) {
        // nothing
    }

    @Override
    public boolean canDeactivateAccelerometer() {
        return false;
    }

    @Override
    public int[] getAccelerometerChannels() {
        return new int[]{totalChannels - 4, totalChannels - 3, totalChannels - 2};
    }

    private int parseInt24Hex(String hex) {
        if (hex.charAt(0) > '7') {  // if the number is negative
            hex = "FF" + hex;   // keep it negative
        } else {                  // if the number is positive
            hex = "00" + hex;   // keep it positive
        }

        return unhex(hex);
    }

    private int parseInt16Hex(String hex) {
        if (hex.charAt(0) > '7') {  // if the number is negative
            hex = "FFFF" + hex;   // keep it negative
        } else {                  // if the number is positive
            hex = "0000" + hex;   // keep it positive
        }

        return unhex(hex);
    }

}