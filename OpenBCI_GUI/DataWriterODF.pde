
//write data to a text file
public class OutputFile_rawtxt {
    PrintWriter output;
    String fname;
    private int rowsWritten;
    private long logFileStartTime;

    OutputFile_rawtxt(float fs_Hz) {

        //build up the file name
        fname = settings.guiDataPath+"OpenBCI-RAW-";

        //add year month day to the file name
        fname = fname + year() + "-";
        if (month() < 10) fname=fname+"0";
        fname = fname + month() + "-";
        if (day() < 10) fname = fname + "0";
        fname = fname + day();

        //add hour minute sec to the file name
        fname = fname + "_";
        if (hour() < 10) fname = fname + "0";
        fname = fname + hour() + "-";
        if (minute() < 10) fname = fname + "0";
        fname = fname + minute() + "-";
        if (second() < 10) fname = fname + "0";
        fname = fname + second();

        //add the extension
        fname = fname + ".txt";

        //open the file
        output = createWriter(fname);

        //add the header
        writeHeader(fs_Hz);

        //init the counter
        rowsWritten = 0;
    }

    //variation on constructor to have custom name
    OutputFile_rawtxt(float fs_Hz, String _sessionName, String _fileName) {
        settings.setSessionPath(settings.recordingsPath + "OpenBCISession_" + _sessionName + File.separator);
        fname = settings.getSessionPath();
        fname += "OpenBCI-RAW-";
        fname += _fileName;
        fname += ".txt";
        output = createWriter(fname);        //open the file
        writeHeader(fs_Hz);    //add the header
        rowsWritten = 0;    //init the counter
    }

    public void writeHeader(float fs_Hz) {
        output.println("%OpenBCI Raw EEG Data");
        output.println("%Number of channels = " + nchan);
        output.println("%Sample Rate = " + fs_Hz + " Hz");
        output.println("%First Column = SampleIndex");
        output.println("%Last Column = Timestamp ");
        output.println("%Other Columns = EEG data in microvolts followed by Accel Data (in G) interleaved with Aux Data");
        output.flush();
    }

    //This has been updated to temporarily work with Brainflow
    public void writeRawData_dataPacket(DataPacket_ADS1299 data, float scale_to_uV, float[] auxData, float scale_for_aux, int stopByte, long timestamp) {
        //get current date time with Date()
        if (output != null) {
            output.print(Integer.toString(data.sampleIndex));
            writeValues(data.values,scale_to_uV);
            if (eegDataSource == DATASOURCE_GANGLION) {
                writeAccValues(auxData);
            } else {
                if (stopByte == 0xC1) {
                    writeAuxValues(data);
                } else {
                    writeAccValues(auxData);
                }
            }
            output.print( ", " + dateFormat.format(new Date(timestamp)));
            output.print( ", " + timestamp);
            output.println(); rowsWritten++;
            //output.flush();
        }
    }

    private void writeValues(int[] values, float scale_fac) {
        int nVal = values.length;
        for (int Ival = 0; Ival < nVal; Ival++) {
            output.print(", ");
            output.print(String.format(Locale.US, "%.2f", scale_fac * float(values[Ival])));
        }
    }

    //This is deprecated, and can be removed after brainflow is integrated
    private void writeAccValues(int[] values, float scale_fac) {
        int nVal = values.length;
        for (int Ival = 0; Ival < nVal; Ival++) {
            output.print(", ");
            output.print(String.format(Locale.US, "%.3f", scale_fac * float(values[Ival])));
        }
    }
    
    //This is the current method used to accept data from Brainflow as floats
    private void writeAccValues(float[] values) {
        int nVal = values.length;
        for (int i = 0; i < nVal; i++) {
            output.print(", ");
            output.print(String.format(Locale.US, "%.3f", values[i]));
        }
    }

    private void writeAuxValues(DataPacket_ADS1299 data) {
        // TODO[brainflow] does aux values work?
        if (eegDataSource == DATASOURCE_CYTON) {
            BoardCyton cytonBoard = (BoardCyton)currentBoard;
            // println("board mode: " + cyton.getBoardMode());
            if (cytonBoard.getBoardMode() == CytonBoardMode.DIGITAL) {
                if (selectedProtocol == BoardProtocol.WIFI) {
                    output.print(", " + ((data.auxValues[0] & 0xFF00) >> 8));
                    output.print(", " + (data.auxValues[0] & 0xFF));
                    output.print(", " + data.auxValues[1]);
                } else {
                    output.print(", " + ((data.auxValues[0] & 0xFF00) >> 8));
                    output.print(", " + (data.auxValues[0] & 0xFF));
                    output.print(", " + ((data.auxValues[1] & 0xFF00) >> 8));
                    output.print(", " + (data.auxValues[1] & 0xFF));
                    output.print(", " + data.auxValues[2]);
                }
            } else if (cytonBoard.getBoardMode() == CytonBoardMode.ANALOG) {
                if (selectedProtocol == BoardProtocol.WIFI) {
                    output.print(", " + data.auxValues[0]);
                    output.print(", " + data.auxValues[1]);
                } else {
                    output.print(", " + data.auxValues[0]);
                    output.print(", " + data.auxValues[1]);
                    output.print(", " + data.auxValues[2]);
                }
            } else if (cytonBoard.getBoardMode() == CytonBoardMode.MARKER) {
                output.print(", " + data.auxValues[0]);
                if ( data.auxValues[0] > 0) {
                    hub.validLastMarker = data.auxValues[0];
                }

            } else {
                for (int Ival = 0; Ival < 3; Ival++) {
                    output.print(", " + data.auxValues[Ival]);
                }
            }
        } else {
            for (int i = 0; i < 3; i++) {
                output.print(", " + (data.auxValues[i] & 0xFF));
                output.print(", " + ((data.auxValues[i] & 0xFF00) >> 8));
            }
        }
    }

    public void closeFile() {
        output.flush();
        output.close();
    }

    public int getRowsWritten() {
        return rowsWritten;
    }

    public void limitRecordingFileDuration() {
        if (settings.maxLogTimeReached()) {
            println("DataLogging: Max recording duration reached for OpenBCI data format. Creating a new recording file in the session folder.");
            closeLogFile();
            //open data file if it has not already been opened
            if (!settings.isLogFileOpen()) {
                if (eegDataSource == DATASOURCE_CYTON) openNewLogFile(getDateString());
                if (eegDataSource == DATASOURCE_GANGLION) openNewLogFile(getDateString());
            }
            settings.setLogFileStartTime(System.nanoTime());
        }
    }
};
