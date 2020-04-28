
//write data to a text file
public class DataWriterODF {
    private PrintWriter output;
    private String fname;
    private int rowsWritten;
    private DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

    //variation on constructor to have custom name
    DataWriterODF(String _sessionName, String _fileName) {
        settings.setSessionPath(settings.recordingsPath + "OpenBCISession_" + _sessionName + File.separator);
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
        output.println("%Sample Rate = " + currentBoard.getSampleRate() + " Hz");
        output.println("%Board = " + currentBoard.getClass().getName());

        String[] colNames = currentBoard.getChannelNames();
        
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

            int timestampChan = currentBoard.getTimestampChannel();
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
