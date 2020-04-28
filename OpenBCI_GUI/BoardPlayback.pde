class BoardPlayback extends Board {
    private String playbackFilePath;
    private double[][] rawData;
    private int newDataStartIndex;
    private int newDataEndIndex;
    private int timeOfLastUpdateMS;

    private boolean initialized = false;
    private boolean streaming = false;
    
    private Board underlyingBoard = null;
    private int sampleRate = -1;

    BoardPlayback(String filePath) {
        playbackFilePath = filePath;
    }

    protected boolean initializeInternal() {
        String[] lines = loadStrings(playbackFilePath);
        
        boolean headerParsed = parseHeader(lines);
        boolean dataParsed = parseData(lines);

        initialized = headerParsed && dataParsed;

        newDataStartIndex = 0;
        newDataEndIndex = 0;

        return initialized;
    }

    protected void uninitializeInternal() {
        initialized = false;
    }

    protected boolean parseHeader(String[] lines) {
        for (String line : lines) {
            if (!line.startsWith("%")) {
                break; // reached end of header
            }

            if (line.startsWith("%Sample Rate")) {
                int startIndex = line.indexOf('=') + 2;
                int endIndex = line.indexOf("Hz") - 1;

                String hzString = line.substring(startIndex, endIndex);
                sampleRate = Integer.parseInt(hzString);
            }

            if (line.startsWith("%Board")) {
                int startIndex = line.indexOf('=') + 2;
                String classString = line.substring(startIndex);

                try {
                    Class<?> boardClass = Class.forName(classString);
                    Constructor<?> constructor = boardClass.getConstructor(OpenBCI_GUI.class);
                    underlyingBoard = (Board)constructor.newInstance(ourApplet);
                } catch (Exception e) {
                    println("Cannot instantiate a board of class " + classString);
                    println(e.getMessage());
                    e.printStackTrace();
                    return false;
                }

            }
        }

        return sampleRate > 0 && underlyingBoard != null;
    }

    protected boolean parseData(String[] lines) {
        int dataStart;
        for (dataStart = 0; dataStart < lines.length; dataStart++) {
            String line = lines[dataStart];
            if (!line.startsWith("%")) {
                dataStart++; // skip column names
                break;
            }
        }

        int dataLength = lines.length - dataStart;
        rawData = new double[getTotalChannelCount()][dataLength];
        
        for (int iData=0; iData<dataLength; iData++) {
            String line = lines[dataStart + iData];
            String[] valStrs = line.split(",");
            for (int iCol = 0; iCol < getTotalChannelCount(); iCol++) {
                rawData[iCol][iData] = Double.parseDouble(valStrs[iCol]);
            }
        }

        return true;
    }

    public void startStreaming() {
        streaming = true;
        timeOfLastUpdateMS = millis();
    }

    public void stopStreaming() {
        streaming = false;
    }

    public boolean isConnected() {
        return initialized;
    }

    @Override
    public int getSampleRate() {
        return sampleRate;
    }

    public void setEXGChannelActive(int channelIndex, boolean active) {
        outputWarn("Deactivating channels is not possible for Playback board.");
    }

    public boolean isEXGChannelActive(int channelIndex) {
        return true;
    }

    @Override
    public void sendCommand(String command) {
        outputWarn("Sending commands is not implemented for Playback board. Command: " + command);
    }

    public void setSampleRate(int sampleRate) {
        outputWarn("Changing the sample rate is not possible for Playback board.");
    }

    @Override
    public int[] getEXGChannels() {
        return underlyingBoard.getEXGChannels();
    }

    public int getTimestampChannel() {
        return underlyingBoard.getTimestampChannel();
    }

    public int getSampleNumberChannel() {
        return underlyingBoard.getSampleNumberChannel();
    }

    protected int getTotalChannelCount() {
        return underlyingBoard.getTotalChannelCount();
    }

    protected double[][] getNewDataInternal() {
        int newDataCount = newDataEndIndex - newDataStartIndex;
        double[][] result = new double[getTotalChannelCount()][newDataCount];

        for (int iSample=0; iSample<newDataCount; iSample++) {
            for (int iChan=0; iChan<getTotalChannelCount(); iChan++) {
                result[iChan][iSample] = rawData[iChan][iSample + newDataStartIndex];
            }
        }

        newDataStartIndex = newDataEndIndex;

        return result;
    }

    protected void updateInternal() {
        if (!streaming) {
            return; // do not update
        }

        float sampleRateMS = getSampleRate() / 1000.f;

        int timeElapsedMS = millis() - timeOfLastUpdateMS;
        int numNewSamplesThisFrame = floor(timeElapsedMS * sampleRateMS);

        // account for the fact that each update will not coincide with a sample exactly. 
        // numNewSamplesThisFrame will actually be floor()'s down to the nearest sample
        // to keep the sample rate accurate, we increate the time of last update
        // based on how many samples we incremented this frame.
        timeOfLastUpdateMS += numNewSamplesThisFrame / sampleRateMS;

        newDataEndIndex += numNewSamplesThisFrame;
        newDataEndIndex = min(newDataEndIndex, rawData.length);
    }

    protected void addChannelNamesInternal(String[] channelNames) {
        underlyingBoard.addChannelNamesInternal(channelNames);
    }
}