
//write data to a text file
public class DataWriterODF {
    PrintWriter output;
    String fname;
    private int rowsWritten;
    private long logFileStartTime;

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
            long timestamp = (long)data[timestampChan][iSample];
            output.print(dateFormat.format(new Date(timestamp)));
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
