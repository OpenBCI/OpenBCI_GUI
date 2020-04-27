class DataLogger {
    //variables for writing EEG data out to a file
    private DataWriterODF fileWriterODF;
    private OutputFile_BDF fileoutput_bdf;

    DataLogger() {

    }

    public void initialize() {

    }

    public void uninitialize() {
        if (eegDataSource != DATASOURCE_PLAYBACKFILE){
            closeLogFile();  //close log file
        } 
    }

    public void update() {
        limitRecordingFileDuration();

        saveNewData();
    }

    
    private void saveNewData() {
        //If data is available, save to playback file...
        if(!settings.isLogFileOpen()) {
            return;
        }

        double[][] newData = currentBoard.getFrameData();

        switch (outputDataSource) {
            case OUTPUT_SOURCE_ODF:
                fileWriterODF.append(newData);
                break;
            case OUTPUT_SOURCE_BDF:
                // curBDFDataPacketInd = curDataPacketInd;
                // thread("writeRawData_dataPacket_bdf");
                fileoutput_bdf.writeRawData_dataPacket(dataPacketBuff[curDataPacketInd]);
                break;
            case OUTPUT_SOURCE_NONE:
            default:
                // Do nothing...
                break;
        }
    }

    public void limitRecordingFileDuration() {
        if (settings.isLogFileOpen() && outputDataSource == OUTPUT_SOURCE_ODF && settings.maxLogTimeReached()) {
            println("DataLogging: Max recording duration reached for OpenBCI data format. Creating a new recording file in the session folder.");
            closeLogFile();
            openNewLogFile(DirectoryManager.getDateString());
            settings.setLogFileStartTime(System.nanoTime());
        }
    }

    public void onStartStreaming() {
        if (outputDataSource > OUTPUT_SOURCE_NONE && eegDataSource != DATASOURCE_PLAYBACKFILE) {
            //open data file if it has not already been opened
            if (!settings.isLogFileOpen()) {
                openNewLogFile(DirectoryManager.getDateString());
            }
            settings.setLogFileStartTime(System.nanoTime());
        }
    }

    public void onStopStreaming() {
        //Close the log file when using OpenBCI Data Format (.txt)
        if (outputDataSource == OUTPUT_SOURCE_ODF) closeLogFile();
    }

    public float getSecondsWritten() {
        if (outputDataSource == OUTPUT_SOURCE_ODF && fileWriterODF != null) {
            return float(fileWriterODF.getRowsWritten())/getSampleRateSafe();
        }
        
        if (outputDataSource == OUTPUT_SOURCE_BDF && fileoutput_bdf != null) {
            return fileoutput_bdf.getRecordsWritten();
        }

        return 0.f;
    }

    private void openNewLogFile(String _fileName) {
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
        settings.setLogFileIsOpen(true);
    }

    /**
    * @description Opens (and closes if already open) and BDF file. BDF is the
    *  biosemi data format.
    * @param `_fileName` {String} - The meat of the file name
    */
    private void openNewLogFileBDF(String _fileName) {
        if (fileoutput_bdf != null) {
            println("OpenBCI_GUI: closing log file");
            closeLogFile();
        }
        //open the new file
        fileoutput_bdf = new OutputFile_BDF(getSampleRateSafe(), nchan, _fileName);

        output_fname = fileoutput_bdf.fname;
        println("OpenBCI_GUI: openNewLogFile: opened BDF output file: " + output_fname); //Print filename of new BDF file to console
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

        output_fname = fileWriterODF.fname;
        println("OpenBCI_GUI: openNewLogFile: opened ODF output file: " + output_fname); //Print filename of new ODF file to console
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
        settings.setLogFileIsOpen(false);
    }

    /**
    * @description Close an open BDF file. This will also update the number of data
    *  records.
    */
    private void closeLogFileBDF() {
        if (fileoutput_bdf != null) {
            fileoutput_bdf.closeFile();
        }
        fileoutput_bdf = null;
    }

    /**
    * @description Close an open ODF file.
    */
    private void closeLogFileODF() {
        if (fileWriterODF != null) {
            fileWriterODF.closeFile();
        }
        fileWriterODF = null;
    }

    private void fileSelected(File selection) {  //called by the Open File dialog box after a file has been selected
        if (selection == null) {
            println("fileSelected: no selection so far...");
        } else {
            //inputFile = selection;
            playbackData_fname = selection.getAbsolutePath(); //<>// //<>//
        }
    }
};