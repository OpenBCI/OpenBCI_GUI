public class DataWriterODF {
    protected PrintWriter output;
    private String fname;
    protected int rowsWritten;
    protected DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    protected String fileNamePrependString = "OpenBCI-RAW-";
    protected String headerFirstLineString = "%OpenBCI Raw EXG Data";

    DataWriterODF(String _sessionName, String _fileName) {
        dataLogger.setSessionPath(directoryManager.getRecordingsPath() + "OpenBCISession_" + _sessionName + File.separator);
        fname = dataLogger.getSessionPath();
        fname += fileNamePrependString;
        fname += _fileName;
        fname += ".txt";
        output = createWriter(fname);        //open the file
        writeHeader();    //add the header
        rowsWritten = 0;    //init the counter
    }

    // Overloaded constructor to allow for custom header and filename prepend string
    DataWriterODF(String _sessionName, String _fileName, String _fileNamePrependString, String _headerFirstLineString) {
        fileNamePrependString = _fileNamePrependString;
        headerFirstLineString = _headerFirstLineString;
        dataLogger.setSessionPath(directoryManager.getRecordingsPath() + "OpenBCISession_" + _sessionName + File.separator);
        fname = dataLogger.getSessionPath();
        fname += fileNamePrependString;
        fname += _fileName;
        fname += ".txt";
        output = createWriter(fname);        //open the file
        writeHeader();    //add the header
        rowsWritten = 0;    //init the counter
    }

    public void writeHeader() {
        output.println(headerFirstLineString);
        output.println("%Number of channels = " + getNumberOfChannels());
        output.println("%Sample Rate = " + getSamplingRate() + " Hz");
        output.println("%Board = " + getUnderlyingBoardClass());

        String[] colNames = getChannelNames();
        
        for (int i = 0; i < colNames.length; i++) {
            output.print(colNames[i]);
            output.print(", ");
        }
        output.print("Timestamp (Formatted)");
        output.println();
    }

    public void append(double[][] data) {
        for (int iSample = 0; iSample < data[0].length; iSample++) {
            
            StringBuilder sb = new StringBuilder();

            for (int iChan = 0; iChan < data.length; iChan++) {
                sb.append(data[iChan][iSample]);
                sb.append(", ");
            }

            int timestampChan = getTimestampChannel();
            // *1000 to convert from seconds to milliserconds
            long timestampMS = (long)(data[timestampChan][iSample] * 1000.0);

            sb.append(dateFormat.format(new Date(timestampMS)));
            output.println(sb.toString());
            
            rowsWritten++;
        }
    }

    public void closeFile() {
        output.flush();
        output.close();
    }

    public int getRowsWritten() {
        return rowsWritten;
    }

    protected int getNumberOfChannels() {
        return globalChannelCount;
    }

    protected int getSamplingRate() {
        return ((Board)currentBoard).getSampleRate();
    }

    protected String getUnderlyingBoardClass() {
        return ((Board)currentBoard).getClass().getName();
    }

    protected String[] getChannelNames() {
        return ((Board)currentBoard).getChannelNames();
    }

    protected int getTimestampChannel() {
        return ((Board)currentBoard).getTimestampChannel();
    }

    protected int getMarkerChannel() {
        return ((Board)currentBoard).getMarkerChannel();
    }

    public String getFileName() {
        return fname;
    }
    
};
