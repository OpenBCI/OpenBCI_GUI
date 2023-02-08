abstract class DataSourcePlayback implements DataSource, FileBoard  {
    private String playbackFilePathExg;
    private ArrayList<double[]> rawDataExg;
    private int currentSampleExg;
    private int timeOfLastUpdateMSExg;
    private String underlyingClassName;
    private int numNewSamplesThisFrameExg;

    private boolean initialized = false;
    private boolean streaming = false;
    
    public Board underlyingBoard = null;
    private int sampleRateExg = -1;
    private int numChannelsExg = 0;  // use it instead getTotalChannelCount() method for old playback files

    DataSourcePlayback(String filePath) {
        playbackFilePathExg = filePath;
    }

    @Override
    public boolean initialize() {
        currentSampleExg = 0;
        String[] lines = loadStrings(playbackFilePathExg);
        
        if(!parseExgHeader(lines)) {
            return false;
        }
        if(!instantiateUnderlyingBoard()) {
            return false;
        }
        if(!parseExgData(lines)) {
            return false;
        }

        return true;
    }

    @Override
    public void uninitialize() {
        initialized = false;
    }

    protected boolean parseExgHeader(String[] lines) {
        for (String line : lines) {
            if (!line.startsWith("%")) {
                break; // reached end of header
            }

            //only needed for synthetic board. can delete if we get rid of synthetic board.
            if (line.startsWith("%Number of channels")) {
                int startIndex = line.indexOf('=') + 2;
                String nchanStr = line.substring(startIndex);
                int chanCount = Integer.parseInt(nchanStr);
                updateToNChan(chanCount); // sythetic board depends on this being set before it's initialized
            }

            // some boards have configurable sample rate, so read it from header
            if (line.startsWith("%Sample Rate")) {
                int startIndex = line.indexOf('=') + 2;
                int endIndex = line.indexOf("Hz") - 1;

                String hzString = line.substring(startIndex, endIndex);
                sampleRateExg = Integer.parseInt(hzString);
            }

            // used to figure out the underlying board type
            if (line.startsWith("%Board")) {
                int startIndex = line.indexOf('=') + 2;
                underlyingClassName = line.substring(startIndex);
            }
        }

        boolean success = sampleRateExg > 0 && underlyingClassName != "";
        if(!success) {
            outputError("Playback file does not contain the required header data.");
        }
        return success;
    }

    protected boolean instantiateUnderlyingBoard() {
        try {
            // get class from name
            Class<?> boardClass = Class.forName(underlyingClassName);
            // find default contructor (since this is processing, PApplet is required arg in all constructors)
            Constructor<?> constructor = boardClass.getConstructor(OpenBCI_GUI.class);
            underlyingBoard = (Board)constructor.newInstance(ourApplet);
        } catch (Exception e) {
            outputError("Cannot instantiate underlying board of class " + underlyingClassName);
            println(e.getMessage());
            e.printStackTrace();
            return false;
        }

        return underlyingBoard != null;
    }

    protected boolean parseExgData(String[] lines) {
        int dataStart;
        // set data start to first line of data (skip header)
        for (dataStart = 0; dataStart < lines.length; dataStart++) {
            String line = lines[dataStart];
            if (!line.startsWith("%")) {
                dataStart++; // skip column names
                break;
            }
        }

        int dataLength = lines.length - dataStart;
        rawDataExg = new ArrayList<double[]>(dataLength);
        
        for (int iData=0; iData<dataLength; iData++) {
            String line = lines[dataStart + iData];
            String[] valStrs = line.split(",");
            if (((valStrs.length - 1) != getTotalChannelCount()) && (numChannelsExg == 0)) {
                outputWarn("you are using old file for playback.");
            }
            numChannelsExg = valStrs.length - 1;  // -1 becaise of gui's timestamps

            double[] row = new double[numChannelsExg];
            for (int iCol = 0; iCol < numChannelsExg; iCol++) {
                row[iCol] = Double.parseDouble(valStrs[iCol]);
            }
            rawDataExg.add(row);
        }

        return true;
    }

    @Override
    public void update() {
        if (!streaming) {
            return; // do not update
        }

        float sampleRateMS = getSampleRate() / 1000.f;

        int timeElapsedMS = millis() - timeOfLastUpdateMSExg;
        numNewSamplesThisFrameExg = floor(timeElapsedMS * sampleRateMS);

        // account for the fact that each update will not coincide with a sample exactly. 
        // to keep the streaming rate accurate, we increment the time of last update
        // based on how many samples we incremented this frame.
        timeOfLastUpdateMSExg += numNewSamplesThisFrameExg / sampleRateMS;

        currentSampleExg += numNewSamplesThisFrameExg;
        
        if (endOfFileReached()) {
            topNav.stopButtonWasPressed();
        }

        // don't go beyond raw data array size
        currentSampleExg = min(currentSampleExg, getTotalSamples());
    }

    @Override
    public void startStreaming() {
        streaming = true;
        timeOfLastUpdateMSExg = millis();
    }

    @Override
    public void stopStreaming() {
        streaming = false;
    }

    @Override
    public boolean isStreaming() {
        return streaming;
    }

    @Override
    public int getSampleRate() {
        return sampleRateExg;
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
        return underlyingBoard.getEXGChannels();
    }
    
    @Override
    public int getNumEXGChannels() {
        return getEXGChannels().length;
    }

    @Override
    public int getTimestampChannel() {
        return underlyingBoard.getTimestampChannel();
    }

    @Override
    public int getSampleIndexChannel() {
        return underlyingBoard.getSampleIndexChannel();
    }

    public int getTotalSamples() {
        return rawDataExg.size();
    }

    public float getTotalTimeSeconds() {
        return float(getTotalSamples()) / float(getSampleRate());
    }

    public int getCurrentSample() {
        return currentSampleExg;
    }

    public float getCurrentTimeSeconds() {
        return float(getCurrentSample()) / float(getSampleRate());
    }

    public void goToIndex(int index) {
        currentSampleExg = index;
    }

    @Override
    public int getTotalChannelCount() {
        if (numChannelsExg == 0)
            return underlyingBoard.getTotalChannelCount();
        return numChannelsExg;
    }

    @Override
    public double[][] getFrameData() {
        double[][] array = new double[numChannelsExg][numNewSamplesThisFrameExg];
        List<double[]> list = getData(numNewSamplesThisFrameExg);
        for (int i = 0; i < numNewSamplesThisFrameExg; i++) {
            for (int j = 0; j < numChannelsExg; j++) {
                array[j][i] = list.get(i)[j];
            }
        }
        return array;
    }

    @Override
    public List<double[]> getData(int maxSamples) {
        int firstSample = max(0, currentSampleExg - maxSamples);
        List<double[]> result = rawDataExg.subList(firstSample, currentSampleExg);

        // if needed, pad the beginning of the array with empty data
        if (maxSamples > currentSampleExg) {
            int sampleDiff = maxSamples - currentSampleExg;

            double[] emptyData = new double[numChannelsExg];
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
    public boolean endOfFileReached() {
        return currentSampleExg >= getTotalSamples();
    }

}

public DataSourcePlayback getDataSourcePlaybackClassFromFile(String path) {
    verbosePrint("Checking " + path + " for underlying board class.");
    String strCurrentLine;
    int lineCounter = 0;
    int maxLinesToCheck = 4;
    String infoToCheck = "%Board = ";
    String underlyingBoardClassName = "";
    BufferedReader reader = createBufferedReader(path);
    try {
        while (lineCounter < maxLinesToCheck) {
            strCurrentLine = reader.readLine();
            verbosePrint(strCurrentLine);
            if (strCurrentLine.startsWith(infoToCheck)) {
                String[] splitCurrentLine = split(strCurrentLine, "OpenBCI_GUI$");
                underlyingBoardClassName = splitCurrentLine[1];
            }
            lineCounter++;
        }
    } catch (IOException e) {
        e.printStackTrace();
    } finally {
        try {
            if (reader != null) {
                reader.close();
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
    
    switch (underlyingBoardClassName) {
        case ("BoardCytonSerial"):
            return new DataSourcePlaybackCyton(path);
        default:
            return null;
    }
}
