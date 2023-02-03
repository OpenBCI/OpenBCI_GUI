
// todo refactor to avoid copypaste with DataWriterODF
//write data to a text file
public class DataWriterAuxODF {
    private PrintWriter output;
    private String fname;
    private int rowsWritten;
    private DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

    private AuxDataBoard streamingBoard;

    //variation on constructor to have custom name
    DataWriterAuxODF(String _sessionName, String _fileName) {
        streamingBoard = (AuxDataBoard)currentBoard;
        fname = settings.getSessionPath();
        fname += "OpenBCI-RAW-Aux-";
        fname += _fileName;
        fname += ".txt";
        output = createWriter(fname);        //open the file
        writeHeader();    //add the header
        rowsWritten = 0;    //init the counter
    }

    public void writeHeader() {
        output.println("%OpenBCI Raw Aux Data");
        output.println("%Number of channels = " + streamingBoard.getNumAuxChannels());
        output.println("%Sample Rate = " + streamingBoard.getAuxSampleRate() + " Hz");
        output.println("%Board = " + streamingBoard.getClass().getName());

        String[] colNames = streamingBoard.getAuxChannelNames();
        
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

            int timestampChan = streamingBoard.getAuxTimestampChannel();
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
