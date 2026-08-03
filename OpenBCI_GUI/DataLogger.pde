class DataLogger {
    //variables for writing EEG data out to a file
    private DataWriterODF fileWriterODF;
    private DataWriterFilteredODF fileWriterFilteredODF;
    private DataWriterBDF fileWriterBDF;
    public DataWriterBF fileWriterBF; //Add the ability to simulataneously save to BrainFlow CSV, independent of BDF or ODF
    private String sessionName = "N/A";
    public final int OUTPUT_SOURCE_NONE = 0;
    public final int OUTPUT_SOURCE_ODF = 1; // The OpenBCI CSV Data Format
    public final int OUTPUT_SOURCE_BDF = 2; // The BDF data format http://www.biosemi.com/faq/file_format.htm
    private int outputDataSource;
    private String sessionPath = "";
    private boolean logFileIsOpen = false;
    private long logFileStartTime;
    private long logFileMaxDurationNano = -1;
    private String currentRecordingName = "";
    private String activeFilterSettingsJson = "";
    private boolean activeSmoothingSetting = false;
    private int filteredEpochNumber = 0;
    private long nextFilteredSampleIndex = 0;
    private boolean filteredRecordingFailed = false;

    DataLogger() {
        //Default to OpenBCI CSV Data Format
        outputDataSource = OUTPUT_SOURCE_ODF;
        fileWriterBF = new DataWriterBF();
    }

    public void initialize() {
        activeFilterSettingsJson = "";
        filteredEpochNumber = 0;
        nextFilteredSampleIndex = 0;
        filteredRecordingFailed = false;
    }

    public void uninitialize() {
        closeLogFile();  //close log file
        fileWriterBF.resetBrainFlowStreamer();
    }

    public void update() {
        limitRecordingFileDuration();

        saveNewData();
    }

    
    private void saveNewData() {
        //If data is available, save to playback file...
        if(!isLogFileOpen()) {
            return;
        }

        double[][] newData = currentBoard.getFrameData();

        switch (outputDataSource) {
            case OUTPUT_SOURCE_ODF:
                fileWriterODF.append(newData);
                break;
            case OUTPUT_SOURCE_BDF:
                fileWriterBDF.writeRawData_dataPacket(newData);
                break;
            case OUTPUT_SOURCE_NONE:
            default:
                // Do nothing...
                break;
        }
    }

    /**
     * Save the exact filtered tail produced for the current raw board frame.
     * This is called from processNewData() only after GUI filtering completes.
     */
    public void saveFilteredData(float[][] filteredDisplayData) {
        if (!isLogFileOpen()
                || outputDataSource != OUTPUT_SOURCE_ODF
                || guiSettings == null
                || !guiSettings.getSaveFilteredTimeSeries()
                || filteredRecordingFailed) {
            return;
        }

        double[][] rawFrameData = currentBoard.getFrameData();
        int[] exgChannels = currentBoard.getEXGChannels();
        if (exgChannels.length == 0
                || rawFrameData.length == 0
                || rawFrameData[exgChannels[0]].length == 0) {
            return;
        }

        try {
            String currentFilterSettingsJson = filterSettings.getJson();
            boolean currentSmoothingSetting = getCurrentSmoothingSetting();
            if (fileWriterFilteredODF == null
                    || !currentFilterSettingsJson.equals(activeFilterSettingsJson)
                    || currentSmoothingSetting != activeSmoothingSetting) {
                FilteredDataMetadata metadata = getFilteredDataMetadata(
                    currentFilterSettingsJson,
                    currentSmoothingSetting
                );
                openNewFilteredLogFile(
                    metadata,
                    currentFilterSettingsJson,
                    currentSmoothingSetting
                );
            }

            int samplesWritten = fileWriterFilteredODF.append(
                filteredDisplayData,
                rawFrameData,
                nextFilteredSampleIndex
            );
            nextFilteredSampleIndex += samplesWritten;
        } catch (RuntimeException e) {
            e.printStackTrace();
            outputError("Filtered data recording stopped because sample alignment could not be guaranteed. Raw recording will continue.");
            closeFilteredLogFile();
            filteredRecordingFailed = true;
        }
    }

    private boolean getCurrentSmoothingSetting() {
        if (currentBoard instanceof SmoothingCapableBoard) {
            return ((SmoothingCapableBoard)currentBoard).getSmoothingActive();
        }
        return false;
    }

    private FilteredDataMetadata getFilteredDataMetadata(
        String currentFilterSettingsJson,
        boolean smoothingActive
    ) {
        String brainFlowVersion = "Unknown";
        try {
            brainFlowVersion = BoardShim.get_version();
        } catch (BrainFlowError e) {
            println("DataLogging: Unable to read BrainFlow version for filtered metadata.");
        }

        return new FilteredDataMetadata(
            currentBoard.getSampleRate(),
            currentBoard.getClass().getName(),
            localGUIVersionString,
            brainFlowVersion,
            smoothingActive,
            currentFilterSettingsJson
        );
    }

    private void openNewFilteredLogFile(
        FilteredDataMetadata metadata,
        String currentFilterSettingsJson,
        boolean smoothingActive
    ) {
        closeFilteredLogFile();
        filteredEpochNumber++;
        fileWriterFilteredODF = new DataWriterFilteredODF(
            getSessionPath(),
            fileWriterODF.getFileName(),
            currentRecordingName,
            filteredEpochNumber,
            nextFilteredSampleIndex,
            metadata
        );
        activeFilterSettingsJson = currentFilterSettingsJson;
        activeSmoothingSetting = smoothingActive;
        println("OpenBCI_GUI: opened filtered ODF output file: " + fileWriterFilteredODF.getFileName());
    }

    private void closeFilteredLogFile() {
        if (fileWriterFilteredODF != null) {
            fileWriterFilteredODF.closeFile();
        }
        fileWriterFilteredODF = null;
        activeFilterSettingsJson = "";
    }

    public void limitRecordingFileDuration() {
        if (isLogFileOpen() && outputDataSource == OUTPUT_SOURCE_ODF && maxLogTimeReached()) {
            println("DataLogging: Max recording duration reached for OpenBCI data format. Creating a new recording file in the session folder.");
            closeLogFile();
            openNewLogFile(directoryManager.getFileNameDateTime());
            setLogFileStartTime(System.nanoTime());
        }
    }

    public void onStartStreaming() {
        if (outputDataSource > OUTPUT_SOURCE_NONE && eegDataSource != DATASOURCE_PLAYBACKFILE) {
            //open data file if it has not already been opened
            if (!isLogFileOpen()) {
                openNewLogFile(directoryManager.getFileNameDateTime());
            }
            setLogFileStartTime(System.nanoTime());
        }

        //Print BrainFlow Streamer Info here after ODF and BDF println
        if (eegDataSource != DATASOURCE_PLAYBACKFILE && eegDataSource != DATASOURCE_STREAMING) {
            controlPanel.setBrainFlowStreamerOutput();
            StringBuilder sb = new StringBuilder("OpenBCI_GUI: BrainFlow Streamer Location: ");
            sb.append(brainflowStreamer);
            println(sb.toString());
        }
    }

    public void onStopStreaming() {
        //Close the log file when using OpenBCI Data Format (.txt)
        if (outputDataSource == OUTPUT_SOURCE_ODF) closeLogFile();
    }

    public float getSecondsWritten() {
        if (outputDataSource == OUTPUT_SOURCE_ODF && fileWriterODF != null) {
            return float(fileWriterODF.getRowsWritten())/currentBoard.getSampleRate();
        }
        
        if (outputDataSource == OUTPUT_SOURCE_BDF && fileWriterBDF != null) {
            return fileWriterBDF.getRecordsWritten();
        }

        return 0.f;
    }

    private void openNewLogFile(String _fileName) {
        currentRecordingName = _fileName;
        filteredEpochNumber = 0;
        activeFilterSettingsJson = "";
        filteredRecordingFailed = false;
        //close the file if it's open
        switch (outputDataSource) {
            case OUTPUT_SOURCE_ODF:
                openNewLogFileODF(_fileName);
                break;
            case OUTPUT_SOURCE_BDF:
                openNewLogFileBDF(_fileName);
                break;
            case OUTPUT_SOURCE_NONE:
            default:
                // Do nothing...
                break;
        }
        setLogFileIsOpen(true);
    }

    /**
    * @description Opens (and closes if already open) and BDF file. BDF is the
    *  biosemi data format.
    * @param `_fileName` {String} - The meat of the file name
    */
    private void openNewLogFileBDF(String _fileName) {
        if (fileWriterBDF != null) {
            println("OpenBCI_GUI: closing log file");
            closeLogFile();
        }
        //open the new file
        fileWriterBDF = new DataWriterBDF(_fileName);

        println("OpenBCI_GUI: openNewLogFile: opened BDF output file: " + fileWriterBDF.getFileName());
    }

    /**
    * @description Opens (and closes if already open) and ODF file. ODF is the
    *  openbci data format.
    * @param `_fileName` {String} - The meat of the file name
    */
    private void openNewLogFileODF(String _fileName) {
        if (fileWriterODF != null) {
            println("OpenBCI_GUI: closing log file");
            closeLogFile();
        }
        //open the new file
        fileWriterODF = new DataWriterODF(sessionName, _fileName);

        println("OpenBCI_GUI: openNewLogFile: opened ODF output file: " + fileWriterODF.getFileName());
    }

    private void closeLogFile() {
        switch (outputDataSource) {
            case OUTPUT_SOURCE_ODF:
                closeLogFileODF();
                break;
            case OUTPUT_SOURCE_BDF:
                closeLogFileBDF();
                break;
            case OUTPUT_SOURCE_NONE:
            default:
                // Do nothing...
                break;
        }
        setLogFileIsOpen(false);
    }

    private void closeLogFileBDF() {
        if (fileWriterBDF != null) {
            fileWriterBDF.closeFile();
        }
        fileWriterBDF = null;
    }

    private void closeLogFileODF() {
        closeFilteredLogFile();
        if (fileWriterODF != null) {
            fileWriterODF.closeFile();
        }
        fileWriterODF = null;
    }

    public int getDataLoggerOutputFormat() {
        return outputDataSource;
    }

    public void setDataLoggerOutputFormat(int outputSource) {
        outputDataSource = outputSource;
    }

    public void setSessionName(String s) {
        sessionName = s;
    }

    public String getSessionName() {
        return sessionName;
    }

    
    public void setSessionPath (String _path) {
        sessionPath = _path;
    }

    public String getSessionPath() {
        return sessionPath;
    }

    
    public void setBfWriterFolder(String _folderName, String _folderPath) {
        fileWriterBF.setBrainFlowStreamerFolderName(_folderName, _folderPath);
    }

    public void setBfWriterDefaultFolder() {
        if (getSessionPath() != "") {
            setSessionPath(directoryManager.getRecordingsPath() + "OpenBCISession_" + sessionName);
        }
        fileWriterBF.setBrainFlowStreamerFolderName(sessionName, getSessionPath());
    }

    public String getBfWriterFilePath() {
        return fileWriterBF.getBrainFlowStreamerRecordingFileName();
    }

    
    private void setLogFileIsOpen(boolean _toggle) {
        logFileIsOpen = _toggle;
    }

    private boolean isLogFileOpen() {
        return logFileIsOpen;
    }

    private void setLogFileStartTime(long _time) {
        logFileStartTime = _time;
        verbosePrint("Settings: LogFileStartTime = " + _time);
    }

    public void setLogFileDurationChoice(int n) {
        int fileDurationMinutes = odfFileDuration.values()[n].getValue();
        logFileMaxDurationNano = fileDurationMinutes * 1000000000L * 60;
        println("Settings: LogFileMaxDuration = " + fileDurationMinutes + " minutes");
    }

    //Only called during live mode && using OpenBCI Data Format
    private boolean maxLogTimeReached() {
        if (logFileMaxDurationNano < 0) {
            return false;
        } else {
            return (System.nanoTime() - logFileStartTime) > (logFileMaxDurationNano);
        }
    }
};
