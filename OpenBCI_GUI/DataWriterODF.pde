
//write data to a text file
public class DataWriterODF {
    private PrintWriter output;
    private String fname;
    private int rowsWritten;
    private DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

    private Board streamingBoard;

    //variation on constructor to have custom name
    DataWriterODF(String _sessionName, String _fileName) {
        streamingBoard = (Board)currentBoard;
        settings.setSessionPath(directoryManager.getRecordingsPath() + "OpenBCISession_" + _sessionName + File.separator);
        fname = settings.getSessionPath();
        fname += "OpenBCI-RAW-";
        fname += _fileName;
        fname += ".txt";
        output = createWriter(fname);        //open the file
        writeHeader();    //add the header
        rowsWritten = 0;    //init the counter
    }

    public void writeHeader() {
        output.println("%OpenBCI Raw EEG Data");
        output.println("%Number of channels = " + nchan);
        output.println("%Sample Rate = " + streamingBoard.getSampleRate() + " Hz");
        output.println("%Board = " + streamingBoard.getClass().getName());

        String[] colNames = streamingBoard.getChannelNames();
        
        for (int i=0; i<colNames.length; i++) {
            output.print(colNames[i]);
            output.print(", ");
        }
        output.print("Timestamp (Formatted)");
        output.println();
        output.flush();
    }

    public void append(double[][] data) {
        //get current date time with Date()
        for (int iSample=0; iSample<data[0].length; iSample++) {
            for (int iChan=0; iChan<data.length; iChan++) {
                output.print(data[iChan][iSample]);
                output.print(", ");
            }

            int timestampChan = streamingBoard.getTimestampChannel();
            // *1000 to convert from seconds to milliserconds
            long timestampMS = (long)(data[timestampChan][iSample] * 1000.0);

            output.print(dateFormat.format(new Date(timestampMS)));
            output.println();
            
            rowsWritten++;
        }
    }

    public void closeFile() {
        output.close();
    }

    public int getRowsWritten() {
        return rowsWritten;
    }
};
