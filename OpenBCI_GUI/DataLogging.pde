
////////////////////////////////////////////////////////////
// Class: OutputFile_rawtxt
// Purpose: handle file creation and writing for the text log file
// Created: Chip Audette  May 2, 2014
//
// DATA FORMAT:
//
////////////////////////////////////////////////////////////

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.io.OutputStream;


DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss.SSS");
//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

void openNewLogFile(String _fileName) {
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
}

/**
  * @description Opens (and closes if already open) and BDF file. BDF is the
  *  biosemi data format.
  * @param `_fileName` {String} - The meat of the file name
  */
void openNewLogFileBDF(String _fileName) {
    if (fileoutput_bdf != null) {
        println("OpenBCI_GUI: closing log file");
        closeLogFile();
    }
    //open the new file
    fileoutput_bdf = new OutputFile_BDF(getSampleRateSafe(), nchan, _fileName);

    output_fname = fileoutput_bdf.fname;
    println("cyton: openNewLogFile: opened BDF output file: " + output_fname); //Print filename of new BDF file to console
    //output("cyton: openNewLogFile: opened BDF output file: " + output_fname);
}

/**
  * @description Opens (and closes if already open) and ODF file. ODF is the
  *  openbci data format.
  * @param `_fileName` {String} - The meat of the file name
  */
void openNewLogFileODF(String _fileName) {
    if (fileoutput_odf != null) {
        println("OpenBCI_GUI: closing log file");
        closeLogFile();
    }
    //open the new file
    fileoutput_odf = new OutputFile_rawtxt(getSampleRateSafe(), _fileName);

    output_fname = fileoutput_odf.fname;
    println("cyton: openNewLogFile: opened ODF output file: " + output_fname); //Print filename of new ODF file to console
    //output("cyton: openNewLogFile: opened ODF output file: " + output_fname);
}

//Called when user selects a playback file from dialog box
void playbackSelectedControlPanel(File selection) {
    if (selection == null) {
        println("DataLogging: playbackSelected: Window was closed or the user hit cancel.");
    } else {
        println("DataLogging: playbackSelected: User selected " + selection.getAbsolutePath());
        //Set the name of the file
        playbackFileSelectedCP(selection.getAbsolutePath(), selection.getName());
    }
}

void playbackFileSelectedCP (String longName, String shortName) {
    playbackData_fname = longName;
    playbackData_ShortName = shortName;
    //Process the playback file
    processNewPlaybackFile();
    //Determine the number of channels
    determineNumChanFromFile(playbackData_table);
    //Output new playback settings to GUI as success
    outputSuccess("You have selected \""
    + shortName + "\" for playback. "
    + str(nchan) + " channels found.");
    //look at the JSON file to set the range menu using number of recent file entries
    try {
        savePlaybackHistoryJSON = loadJSONObject(userPlaybackHistoryFile);
        JSONArray recentFilesArray = savePlaybackHistoryJSON.getJSONArray("playbackFileHistory");
        maxRangePlaybackSelect = recentFilesArray.size()/10;

        for (int i = 0; i <= maxRangePlaybackSelect; i++) {
            rangePlaybackStringList.append(rangeSelectStringArray[i]);
        }
        playbackHistoryFileExists = true;
    } catch (NullPointerException e) {
        //println("Playback history JSON file does not exist. Load first file to make it.");
        playbackHistoryFileExists = false;
    }
    //add playback file that was processed to the JSON history
    savePlaybackFileToHistory(playbackData_ShortName);
}



//NEEDS TO BE UPDATED TO MORE EFFICIENT METHOD
//Currently looks at the total number of Columns
//Maybe try counting the number of columns after first index and before X...
//...where X is the unique data type that occurs after last channel
void determineNumChanFromFile(Table datatable) {
    int numColumnsPlaybackFile = datatable.getColumnCount();
    int numChannelsFoundInPlaybackFile;
    if (numColumnsPlaybackFile > totalColumns16ChanThresh) {
        numChannelsFoundInPlaybackFile = 16;
    } else if (numColumnsPlaybackFile <= totalColumns4ChanThresh) {
        numChannelsFoundInPlaybackFile = 4;
    } else {
        numChannelsFoundInPlaybackFile = 8;
    }
    updateToNChan(numChannelsFoundInPlaybackFile);
}

void closeLogFile() {
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
}

/**
  * @description Close an open BDF file. This will also update the number of data
  *  records.
  */
void closeLogFileBDF() {
    if (fileoutput_bdf != null) {
        //TODO: Need to update the rows written in the header
        fileoutput_bdf.closeFile();
    }
}

/**
  * @description Close an open ODF file.
  */
void closeLogFileODF() {
    if (fileoutput_odf != null) {
        fileoutput_odf.closeFile();
    }
}

void fileSelected(File selection) {  //called by the Open File dialog box after a file has been selected
    if (selection == null) {
        println("fileSelected: no selection so far...");
    } else {
        //inputFile = selection;
        playbackData_fname = selection.getAbsolutePath(); //<>// //<>//
    }
}

String getDateString() {
    String fname = year() + "-";
    if (month() < 10) fname=fname+"0";
    fname = fname + month() + "-";
    if (day() < 10) fname = fname + "0";
    fname = fname + day();

    fname = fname + "_";
    if (hour() < 10) fname = fname + "0";
    fname = fname + hour() + "-";
    if (minute() < 10) fname = fname + "0";
    fname = fname + minute() + "-";
    if (second() < 10) fname = fname + "0";
    fname = fname + second();
    return fname;
}

//these functions are relevant to convertSDFile
void createPlaybackFileFromSD() {
    logFileName = "SavedData/SDconverted-"+getDateString()+".csv";
    dataWriter = createWriter(logFileName);
    dataWriter.println("%OBCI SD Convert - " + getDateString());
    dataWriter.println("%");
    dataWriter.println("%Sample Rate = 250.0 Hz");
    dataWriter.println("%First Column = SampleIndex");
    dataWriter.println("%Last Column = Timestamp");
    dataWriter.println("%Other Columns = EEG data in microvolts followed by Accel Data (in G) interleaved with Aux Data");

}

void sdFileSelected(File selection) {
    if (selection == null) {
        println("Window was closed or the user hit cancel.");
    } else {
        println("User selected " + selection.getAbsolutePath());
        dataReader = createReader(selection.getAbsolutePath()); // ("positions.txt");
        controlPanel.convertingSD = true;
        println("Timing SD file conversion...");
        thatTime = millis();
    }
}

//------------------------------------------------------------------------
//                            CLASSES
//------------------------------------------------------------------------

//write data to a text file
public class OutputFile_rawtxt {
    PrintWriter output;
    String fname;
    private int rowsWritten;

    OutputFile_rawtxt(float fs_Hz) {

        //build up the file name
        fname = "SavedData"+System.getProperty("file.separator")+"OpenBCI-RAW-";

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
    OutputFile_rawtxt(float fs_Hz, String _fileName) {
        fname = "SavedData"+System.getProperty("file.separator")+"OpenBCI-RAW-";
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

    public void writeRawData_dataPacket(DataPacket_ADS1299 data, float scale_to_uV, float scale_for_aux, int stopByte, long timestamp) {
        //get current date time with Date()
        if (output != null) {
            output.print(Integer.toString(data.sampleIndex));
            writeValues(data.values,scale_to_uV);
            if (eegDataSource == DATASOURCE_GANGLION) {
                writeAccValues(data.auxValues, scale_for_aux);
            } else {
                if (stopByte == 0xC1) {
                    writeAuxValues(data);
                } else {
                    writeAccValues(data.auxValues, scale_for_aux);
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

    private void writeAccValues(int[] values, float scale_fac) {
        int nVal = values.length;
        for (int Ival = 0; Ival < nVal; Ival++) {
            output.print(", ");
            output.print(String.format(Locale.US, "%.3f", scale_fac * float(values[Ival])));
        }
    }

    private void writeAuxValues(DataPacket_ADS1299 data) {
        if (eegDataSource == DATASOURCE_CYTON) {
            // println("board mode: " + cyton.getBoardMode());
            if (cyton.getBoardMode() == BOARD_MODE_DIGITAL) {
                if (cyton.isWifi()) {
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
            } else if (cyton.getBoardMode() == BOARD_MODE_ANALOG) {
                if (cyton.isWifi()) {
                    output.print(", " + data.auxValues[0]);
                    output.print(", " + data.auxValues[1]);
                } else {
                    output.print(", " + data.auxValues[0]);
                    output.print(", " + data.auxValues[1]);
                    output.print(", " + data.auxValues[2]);
                }
            } else if (cyton.getBoardMode() == BOARD_MODE_MARKER) {
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
};

//write data to a text file in BDF+ format http://www.biosemi.com/faq/file_format.htm
public class OutputFile_BDF {
    private PrintWriter writer;
    private OutputStream dstream;
    // private FileOutputStream fstream;
    // private BufferedOutputStream bstream;
    // private DataOutputStream dstream;

    // Each header component has a max allocated amount of ascii spaces
    // SPECS FOR BDF http://www.biosemi.com/faq/file_format.htm
    // ADDITIONAL SPECS FOR EDF+ http://www.edfplus.info/specs/edfplus.html#additionalspecs
    // A good resource for a comparison between BDF and EDF http://www.teuniz.net/edfbrowser/bdfplus%20format%20description.html
    final static int BDF_HEADER_SIZE_VERSION = 8; // Version of this data format Byte 1: "255" (non ascii) Bytes 2-8 : "BIOSEMI" (ASCII)
    final static int BDF_HEADER_SIZE_PATIENT_ID = 80; // Local patient identification (mind item 3 of the additional EDF+ specs)
    final static int BDF_HEADER_SIZE_RECORDING_ID = 80; // Local recording identification (mind item 4 of the additional EDF+ specs)
    final static int BDF_HEADER_SIZE_RECORDING_START_DATE = 8; // Start date of recording (dd.mm.yy) (mind item 2 of the additional EDF+ specs)
    final static int BDF_HEADER_SIZE_RECORDING_START_TIME = 8; // Start time of recordign (hh.mm.ss)
    final static int BDF_HEADER_SIZE_BYTES_IN_HEADER = 8; // Number of bytes in header record
    final static int BDF_HEADER_SIZE_RESERVED = 44; // Reserved
    final static int BDF_HEADER_SIZE_NUMBER_DATA_RECORDS = 8; // Number of data records (-1 if unknown, obey item 10 of the additional EDF+ specs)
    final static int BDF_HEADER_SIZE_DURATION_OF_DATA_RECORD = 8; // Duration of a data record, in seconds
    final static int BDF_HEADER_SIZE_NUMBER_SIGNALS = 4; // Number of signals (ns) in data record
    final static int BDF_HEADER_NS_SIZE_LABEL = 16; // ns * 16 ascii : ns * label (e.g. EEG Fpz-Cz or Body temp) (mind item 9 of the additional EDF+ specs)
    final static int BDF_HEADER_NS_SIZE_TRANSDUCER_TYPE = 80; // ns * 80 ascii : ns * transducer type (e.g. AgAgCl electrode)
    final static int BDF_HEADER_NS_SIZE_PHYSICAL_DIMENSION = 8; // ns * 8 ascii : ns * physical dimension (e.g. uV or degreeC)
    final static int BDF_HEADER_NS_SIZE_PHYSICAL_MINIMUM = 8; // ns * 8 ascii : ns * physical minimum (e.g. -500 or 34)
    final static int BDF_HEADER_NS_SIZE_PHYSICAL_MAXIMUM = 8; // ns * 8 ascii : ns * physical maximum (e.g. 500 or 40)
    final static int BDF_HEADER_NS_SIZE_DIGITAL_MINIMUM = 8; // ns * 8 ascii : ns * digital minimum (e.g. -2048)
    final static int BDF_HEADER_NS_SIZE_DIGITAL_MAXIMUM = 8; // ns * 8 ascii : ns * digital maximum (e.g. 2047)
    final static int BDF_HEADER_NS_SIZE_PREFILTERING = 80; // ns * 80 ascii : ns * prefiltering (e.g. HP:0.1Hz LP:75Hz)
    final static int BDF_HEADER_NS_SIZE_NR = 8; // ns * 8 ascii : ns * nr of samples in each data record
    final static int BDF_HEADER_NS_SIZE_RESERVED = 32; // ns * 32 ascii : ns * reserved

    // Ref: http://www.edfplus.info/specs/edfplus.html#header
    final static String BDF_HEADER_DATA_CONTINUOUS = "BDF+C";
    final static String BDF_HEADER_DATA_DISCONTINUOUS = "BDF+D";
    final static String BDF_HEADER_PHYSICAL_DIMENISION_UV = "uV";
    final static String BDF_HEADER_PHYSICAL_DIMENISION_G = "g";
    final static String BDF_HEADER_TRANSDUCER_AGAGCL = "AgAgCl electrode";
    final static String BDF_HEADER_TRANSDUCER_MEMS = "MEMS";
    final static String BDF_HEADER_ANNOTATIONS = "BDF Annotations ";

    final static int BDF_HEADER_BYTES_BLOCK = 256;

    DateFormat startDateFormat = new SimpleDateFormat("dd.MM.yy");
    DateFormat startTimeFormat = new SimpleDateFormat("hh.mm.ss");

    private char bdf_version_header = 0xFF;
    private char[] bdf_version = {'B', 'I', 'O', 'S', 'E', 'M', 'I'};

    private String bdf_patient_id_subfield_hospoital_code = "X"; // The code by which the patient is known in the hospital administration.
    private String bdf_patient_id_subfield_sex = "X"; // Sex (English, so F or M).
    private String bdf_patient_id_subfield_birthdate = "X"; // (e.g. 24-NOV-1992) Birthdate in dd-MM-yyyy format using the English 3-character abbreviations of the month in capitals. 02-AUG-1951 is OK, while 2-AUG-1951 is not.
    private String bdf_patient_id_subfield_name = "X"; // the patients name. No spaces! Use "_" where ever a space is

    private String bdf_recording_id_subfield_prefix = "X"; //"Startdate"; // The text 'Startdate'
    private String bdf_recording_id_subfield_startdate = "X"; // getDateString(startDateFormat); // The startdate itself in dd-MM-yyyy format using the English 3-character abbreviations of the month in capitals.
    private String bdf_recording_id_subfield_admin_code = "X"; // The hospital administration code of the investigation, i.e. EEG number or PSG number.
    private String bdf_recording_id_subfield_investigator = "X"; // A code specifying the responsible investigator or technician.
    private String bdf_recording_id_subfield_equipment = "X"; // A code specifying the used equipment.

    // Digital max and mins
    private String bdf_digital_minimum_ADC_24bit = "-8388608"; // -1 * 2^23
    private String bdf_digital_maximum_ADC_24bit = "8388607"; // 2^23 - 1
    private String bdf_digital_minimum_ADC_12bit = "-2048"; // -1 * 2^11
    private String bdf_digital_maximum_ADC_12bit = "2047"; // 2^11 - 1

    // Physcial max and mins
    private String bdf_physical_minimum_ADC_24bit = "-187500"; // 4.5 / 24 / (2^23) * 1000000 *  (2^23)
    private String bdf_physical_maximum_ADC_24bit = "187500"; // 4.5 / 24 / (2^23) * 1000000 * -1 * (2^23)
    private String bdf_physical_minimum_ADC_Accel = "-4";
    private String bdf_physical_maximum_ADC_Accel = "4";

    private String bdf_physical_minimum_ADC_24bit_ganglion = "-15686";
    private String bdf_physical_maximum_ADC_24bit_ganglion = "15686";

    private final float ADS1299_Vref = 4.5f;  //reference voltage for ADC in ADS1299.  set by its hardware
    private float ADS1299_gain = 24.0;  //assumed gain setting for ADS1299.  set by its Arduino code
    private float scale_fac_uVolts_per_count = ADS1299_Vref / ((float)(pow(2,23)-1)) / ADS1299_gain  * 1000000.f; //ADS1299 datasheet Table 7, confirmed through experiment

    private int bdf_number_of_data_records = -1;

    public boolean continuous = true;
    public boolean write_accel = true;

    private float dataRecordDuration = 1; // second
    private int nbAnnotations = 1;
    private int nbAux = 3;
    private int nbChan = 8;
    private int sampleSize = 3; // Number of bytes in a sample

    private String labelsAnnotations[] = new String[nbAnnotations];
    private String transducerAnnotations[] = new String[nbAnnotations];
    private String physicalDimensionAnnotations[] = new String[nbAnnotations];
    private String physicalMinimumAnnotations[] = new String[nbAnnotations];
    private String physicalMaximumAnnotations[] = new String[nbAnnotations];
    private String digitalMinimumAnnotations[] = new String[nbAnnotations];
    private String digitalMaximumAnnotations[] = new String[nbAnnotations];
    private String prefilteringAnnotations[] = new String[nbAnnotations];
    private String nbSamplesPerDataRecordAnnotations[] = new String[nbAnnotations];
    private String reservedAnnotations[] = new String[nbAnnotations];

    private String labelsAux[] = new String[nbAux];
    private String transducerAux[] = new String[nbAux];
    private String physicalDimensionAux[] = new String[nbAux];
    private String physicalMinimumAux[] = new String[nbAux];
    private String physicalMaximumAux[] = new String[nbAux];
    private String digitalMinimumAux[] = new String[nbAux];
    private String digitalMaximumAux[] = new String[nbAux];
    private String prefilteringAux[] = new String[nbAux];
    private String nbSamplesPerDataRecordAux[] = new String[nbAux];
    private String reservedAux[] = new String[nbAux];

    private String labelsEEG[] = new String[nbChan];
    private String transducerEEG[] = new String[nbChan];
    private String physicalDimensionEEG[] = new String[nbChan];
    private String physicalMinimumEEG[] = new String[nbChan];
    private String physicalMaximumEEG[] = new String[nbChan];
    private String digitalMinimumEEG[] = new String[nbChan];
    private String digitalMaximumEEG[] = new String[nbChan];
    private String prefilteringEEG[] = new String[nbChan];
    private String nbSamplesPerDataRecordEEG[] = new String[nbChan];
    private String reservedEEG[] = new String[nbChan];

    private String tempWriterPrefix = "temp.txt";

    private int fs_Hz = 250;
    private int accel_Hz = 25;

    private int samplesInDataRecord = 0;
    private int dataRecordsWritten = 0;

    private Date startTime;
    private boolean startTimeCaptured = false;

    private int timeDataRecordStart = 0;

    private byte auxValBuf[][][];
    private byte auxValBuf_buffer[][][];
    private byte chanValBuf[][][];
    private byte chanValBuf_buffer[][][];

    public String fname = "";

    public int nbSamplesPerAnnontation = 20;

    public DataPacket_ADS1299 data_t;

    /**
      * @description Creates an EDF writer! Name of output file based on current
      *  date and time.
      * @param `_fs_Hz` {float} - The sample rate of the data source. Going to be
      *  `250` for OpenBCI 32bit board, `125` for OpenBCI 32bit board + daisy, or
      *  `256` for the Ganglion.
      * @param `_nbChan` {int} - The number of channels of the data source. Going to be
      *  `8` for OpenBCI 32bit board, `16` for OpenBCI 32bit board + daisy, or
      *  `4` for the Ganglion.
      * @constructor
      */
    OutputFile_BDF(float _fs_Hz, int _nbChan) {

        fname = getFileName();
        fs_Hz = (int)_fs_Hz;
        nbChan = _nbChan;

        init();
    }

    /**
      * @description Creates an EDF writer! The output file will contain the `_filename`.
      * @param `_fs_Hz` {float} - The sample rate of the data source. Going to be
      *  `250` for OpenBCI 32bit board, `125` for OpenBCI 32bit board + daisy, or
      *  `256` for the Ganglion.
      * @param `_nbChan` {int} - The number of channels of the data source. Going to be
      *  `8` for OpenBCI 32bit board, `16` for OpenBCI 32bit board + daisy, or
      *  `4` for the Ganglion.
      * @param `_fileName` {String} - Main component of the output file name.
      * @constructor
      */
    OutputFile_BDF(float _fs_Hz, int _nbChan, String _fileName) {

        fname = getFileName(_fileName);
        fs_Hz = (int)_fs_Hz;
        nbChan = _nbChan;

        init();
    }

    /**
      * @description Used to initalize the writer.
      */
    private void init() {

        // Set the arrays needed for header
        setNbAnnotations(nbAnnotations);
        setNbAux(nbAux);
        setNbChan(nbChan);

        // Create the aux value buffer
        auxValBuf = new byte[nbAux][fs_Hz][sampleSize];
        auxValBuf_buffer = new byte[nbAux][fs_Hz][sampleSize];

        // Create the channel value buffer
        chanValBuf = new byte[nbChan][fs_Hz][sampleSize];
        chanValBuf_buffer = new byte[nbChan][fs_Hz][sampleSize];

        // Create the output stream for raw data
        dstream = createOutput(tempWriterPrefix);

        // Init the counter
        dataRecordsWritten = 0;
    }

    /**
      * @description Writes a raw data packet to the buffer. Also will flush the
      *  buffer if it is filled with one second worth of data. Will also capture
      *  the start time, or the first time a packet is recieved.
      * @param `data` {DataPacket_ADS1299} - A data packet
      */
    public void writeRawData_dataPacket(DataPacket_ADS1299 data) {

        if (!startTimeCaptured) {
            startTime = new Date();
            startTimeCaptured = true;
            timeDataRecordStart = millis();
        }

        writeChannelDataValues(data.rawValues);
        if (eegDataSource == DATASOURCE_CYTON) {
            writeAuxDataValues(data.rawAuxValues);
        }
        samplesInDataRecord++;
        // writeValues(data.auxValues,scale_for_aux);
        if (samplesInDataRecord >= fs_Hz) {
            arrayCopy(chanValBuf,chanValBuf_buffer);
            if (eegDataSource == DATASOURCE_CYTON) {
                arrayCopy(auxValBuf,auxValBuf_buffer);
            }

            samplesInDataRecord = 0;
            writeDataOut();
        }
    }

    private void writeDataOut() {
        try {
            for (int i = 0; i < nbChan; i++) {
                for (int j = 0; j < fs_Hz; j++) {
                    for (int k = 0; k < 3; k++) {
                        dstream.write(chanValBuf_buffer[i][j][k]);
                    }
                }
            }
            if (eegDataSource == DATASOURCE_CYTON) {
                for (int i = 0; i < nbAux; i++) {
                    for (int j = 0; j < fs_Hz; j++) {
                        for (int k = 0; k < 3; k++) {
                            dstream.write(auxValBuf_buffer[i][j][k]);
                        }
                    }
                }
            }

            // Write the annotations
            dstream.write('+');
            String _t = str((millis() - timeDataRecordStart) / 1000);
            int strLen = _t.length();
            for (int i = 0; i < strLen; i++) {
                dstream.write(_t.charAt(i));
            }
            dstream.write(20);
            dstream.write(20);
            int lenWritten = 1 + strLen + 1 + 1;
            // for (int i = lenWritten; i < fs_Hz * sampleSize; i++) {
            for (int i = lenWritten; i < nbSamplesPerAnnontation * sampleSize; i++) {
                dstream.write(0);
            }
            dataRecordsWritten++;

        } catch (Exception e) {
            println("writeRawData_dataPacket: Exception ");
            e.printStackTrace();
        }
    }

    public void closeFile() {

        output("Closed the temp data file. Now opening a new file");
        try {
            dstream.close();
        } catch (Exception e) {
            println("closeFile: dstream close exception ");
            e.printStackTrace();
        }
        println("closeFile: started...");
        // File f = new File(fname);
        // fstream = new FileOutputStream(f);
        // bstream = new BufferedOutputStream(fstream);
        // dstream = new DataOutputStream(bstream);

        OutputStream o = createOutput(fname);
        println("closeFile: made file");

        // Create a new writer with the same file name
        // Write the header
        writeHeader(o);
        output("Header writen, now writing data.");
        println("closeFile: wrote header");

        writeData(o);
        output("Data written. Closing new file.");
        println("closeFile: wrote data");
        // Create write stream
        // try {
        //   println("closeFile: started...");
        //   // File f = new File(fname);
        //   // fstream = new FileOutputStream(f);
        //   // bstream = new BufferedOutputStream(fstream);
        //   // dstream = new DataOutputStream(bstream);
        //
        //   OutputStream o = createOutput(fname);
        //   println("closeFile: made file");
        //
        //   // Create a new writer with the same file name
        //   // Write the header
        //   writeHeader(o);
        //   output("Header writen, now writing data.");
        //   println("closeFile: wrote header");
        //
        //   writeData(o);
        //   output("Data written. Closing new file.");
        //   println("closeFile: wrote data");
        //
        //   // dstream.close();
        //
        //   // Try to delete the file
        //   // https://forum.processing.org/one/topic/noob-how-to-delete-a-file-in-the-data-folder.html
        //   // File f = new File(tempWriterPrefix);
        //   // if (f.exists()) {
        //   //   f.delete();
        //   //   output("Deleted temp data file.");
        //   // } else {
        //   //   output("Unable to delete temp data file.");
        //   // }
        // }
        // catch(IOException e) {
        //   println("closeFile: IOException");
        //   e.printStackTrace();
        // }

    }

    public int getRecordsWritten() {
        return dataRecordsWritten;
    }

    /**
      * @description Resizes and resets the per aux channel arrays to size `n`
      * @param `n` {int} - The new size of arrays
      */
    public void setAnnotationsArraysToSize(int n) {
        labelsAnnotations = new String[n];
        transducerAnnotations = new String[n];
        physicalDimensionAnnotations = new String[n];
        physicalMinimumAnnotations = new String[n];
        physicalMaximumAnnotations = new String[n];
        digitalMinimumAnnotations = new String[n];
        digitalMaximumAnnotations = new String[n];
        prefilteringAnnotations = new String[n];
        nbSamplesPerDataRecordAnnotations = new String[n];
        reservedAnnotations = new String[n];
    }

    /**
      * @description Resizes and resets the per aux channel arrays to size `n`
      * @param `n` {int} - The new size of arrays
      */
    public void setAuxArraysToSize(int n) {
        labelsAux = new String[n];
        transducerAux = new String[n];
        physicalDimensionAux = new String[n];
        physicalMinimumAux = new String[n];
        physicalMaximumAux = new String[n];
        digitalMinimumAux = new String[n];
        digitalMaximumAux = new String[n];
        prefilteringAux = new String[n];
        nbSamplesPerDataRecordAux = new String[n];
        reservedAux = new String[n];
    }

    /**
      * @description Resizes and resets the per channel arrays to size `n`
      * @param `n` {int} - The new size of arrays
      */
    public void setEEGArraysToSize(int n) {
        labelsEEG = new String[n];
        transducerEEG = new String[n];
        physicalDimensionEEG = new String[n];
        physicalMinimumEEG = new String[n];
        physicalMaximumEEG = new String[n];
        digitalMinimumEEG = new String[n];
        digitalMaximumEEG = new String[n];
        prefilteringEEG = new String[n];
        nbSamplesPerDataRecordEEG = new String[n];
        reservedEEG = new String[n];
    }

    /**
      * @description Set an EEG 10-20 label for a given channel. (e.g. EEG Fpz-Cz)
      * @param `s` {String} - The string to store to the `labels` string array
      * @param `index` {int} - The position in the `labels` array to insert the
      *  string `str`. Must be smaller than `nbChan`.
      * @returns {boolean} - `true` if the label was added, `false` if not able to
      */
    public boolean setEEGLabelForIndex(String s, int index) {
        if (index < nbChan) {
            labelsEEG[index] = s;
            return true;
        } else {
            return false;
        }
    }

    /**
      * @description Set the number of annotation signals.
      * @param `n` {int} - The new number of channels
      */
    public void setNbAnnotations(int n) {
        if (n < 1) n = 1;

        // Set the main variable
        nbAnnotations = n;
        // Resize the arrays
        setAnnotationsArraysToSize(n);
        // Fill any arrays that can be filled
        setAnnotationsArraysToDefaults();
    }

    /**
      * @description Set the number of aux signals.
      * @param `n` {int} - The new number of aux channels
      */
    public void setNbAux(int n) {
        if (n < 1) n = 1;

        // Set the main variable
        nbAux = n;
        // Resize the arrays
        setAuxArraysToSize(n);
        // Fill any arrays that can be filled
        setAuxArraysToDefaults();
    }

    /**
      * @description Set the number of channels. Important to do. This will nuke
      *  the labels array if the size increases or decreases.
      * @param `n` {int} - The new number of channels
      */
    public void setNbChan(int n) {
        if (n < 1) n = 1;

        // Set the main variable
        nbChan = n;
        // Resize the arrays
        setEEGArraysToSize(n);
        // Fill any arrays that can be filled
        setEEGArraysToDefaults();
    }

    /**
      * @description Sets the patient's sex.
      * @param `s` {String} - The patients sex (e.g. M or F)
      * @returns {String} - The string that was set.
      */
    public String setPatientIdSex(String s) {
        return bdf_patient_id_subfield_sex = swapSpacesForUnderscores(s);
    }

    /**
      * @description Sets the patient's birthdate.
      * @param `s` {String} - The patients birth date (e.g. 24-NOV-1992)
      * @returns {String} - The string that was set.
      */
    public String setPatientIdBirthdate(String s) {
        return bdf_patient_id_subfield_birthdate = swapSpacesForUnderscores(s);
    }

    /**
      * @description Sets the patient's name. Note that spaces will be swapped for
      *  underscores.
      * @param `s` {String} - The patients name.
      * @returns {String} - The string that was set.
      */
    public String setPatientIdName(String s) {
        return bdf_patient_id_subfield_name = swapSpacesForUnderscores(s);
    }

    /**
      * @description Set any prefilerting for a given channel. (e.g. HP:0.1Hz LP:75Hz)
      * @param `s` {String} - The string to store to the `prefiltering` string array
      * @param `index` {int} - The position in the `prefiltering` array to insert the
      *  string `str`. Must be smaller than `nbChan`.
      * @returns {boolean} - `true` if the string was added, `false` if not able to
      */
    public boolean setEEGPrefilterForIndex(String s, int index) {
        if (index < nbChan) {
            prefilteringEEG[index] = s;
            return true;
        } else {
            return false;
        }
    }

    /**
      * @description Sets the recording admin code. Note that spaces will be
      *  swapped for underscores.
      * @param `s` {String} - The recording admin code.
      * @returns {String} - The string that was set.
      */
    public String setRecordingIdAdminCode(String s) {
        return bdf_recording_id_subfield_admin_code = swapSpacesForUnderscores(s);
    }

    /**
      * @description Sets the recording admin code. Note that spaces will be
      *  swapped for underscores. (e.g. AJ Keller)
      * @param `s` {String} - The recording id of the investigator.
      * @returns {String} - The string that was set. (e.g. AJ_Keller)
      */
    public String setRecordingIdInvestigator(String s) {
        return bdf_recording_id_subfield_investigator = swapSpacesForUnderscores(s);
    }

    /**
      * @description Sets the recording equipment code. Note that spaces will be
      *  swapped for underscores. (e.g. OpenBCI 32bit or OpenBCI Ganglion)
      * @param `s` {String} - The recording equipment id.
      * @returns {String} - The string that was set.
      */
    public String setRecordingIdEquipment(String s) {
        return bdf_recording_id_subfield_equipment = swapSpacesForUnderscores(s);
    }

    /**
      * @description Set a transducer type for a given channel. (e.g. AgAgCl electrode)
      * @param `s` {String} - The string to store to the `transducerEEG` string array
      * @param `index` {int} - The position in the `transducerEEG` array to insert the
      *  string `str`. Must be smaller than `nbChan`.
      * @returns {boolean} - `true` if the string was added, `false` if not able to
      */
    public boolean setTransducerForIndex(String s, int index) {
        if (index < nbChan) {
            transducerEEG[index] = s;
            return true;
        } else {
            return false;
        }
    }

    /**
      * @description Used to combine a `str` (string) into one big string a certain number of
      *  `times` with left justification padding of `size`.
      * @param `s` {String} - The string to be inserted
      * @param `size` {int} - The total allowable size for `str` to be inserted.
      *  If `str.length()` < `size` then `str` will essentially be right padded with
      *  spaces till the `output` is of length `size`.
      * @param `times` {int} - The number of times to repeat the `str` with `padding`
      * @returns {String} - The `str` right padded with spaces to beome `size` length
      *  and that repeated `times`.
      */
    private String combineStringIntoSizeTimes(String s, int size, int times) {
        String output = "";
        for (int i = 0; i < times; i++) {
            output += padStringRight(s, size);
        }
        return output;
    }

    /**
      * @description Calculate the number of bytes in the header. Entirerly based
      *  off the number of channels (`nbChan`)
      * @returns {int} - The number of bytes in the header is 256 + (256 * N) where
      *  N is the number of channels (signals)
      */
    private int getBytesInHeader() {
        return BDF_HEADER_BYTES_BLOCK + (BDF_HEADER_BYTES_BLOCK * getNbSignals()); // Add one for the annotations channel
    }

    /**
      * @description Used to get the continuity of the EDF file based on class public
      *  boolean variable `continuous`. If stop stream then start stream is pressed
      *  we must set the variable `continuous` to false.
      * @returns {String} - The string with NO spacing
      */
    private String getContinuity() {
        if (continuous) {
            return BDF_HEADER_DATA_CONTINUOUS;
        } else {
            return BDF_HEADER_DATA_DISCONTINUOUS;
        }
    }

    /**
      * @description Returns a string of the date based on the input DateFormat `d`
      * @param `d` {DateFormat} - The format you want the date/time in
      * @returns {String} - The current date/time formatted based on `d`
      */
    private String getDateString(DateFormat d) {
        // Get current date time with Date()
        return d.format(new Date());
    }

    /**
      * @description Returns a string of the date based on the input DateFormat `d`
      * @param `d` {DateFormat} - The format you want the date/time in
      * @returns {String} - The current date/time formatted based on `d`
      */
    private String getDateString(Date d, DateFormat df) {
        // Get current date time with Date()
        return df.format(d);
    }

    /**
      * @description Generate a file name for the EDF file that has the current date
      *  and time injected into it.
      * @returns {String} - A fully qualified name of an output file with the date
      *  and time.
      */
    private String getFileName() {
        //build up the file name
        String output = "";

        // If no file name is supplied then we generate one based off the current
        //  date and time of day.
        output += year() + "-";
        if (month() < 10) output += "0";
        output += month() + "-";
        if (day() < 10) output += "0";
        output += day();

        output += "_";
        if (hour() < 10) output += "0";
        output += hour() + "-";
        if (minute() < 10) output += "0";
        output += minute() + "-";
        if (second() < 10) output += "0";
        output += second();

        return getFileName(output);
    }

    /**
      * @description Generate a file name for the EDF file with `str` string embedded
      *  within.
      * @param `s` {String} - The string to inject
      * @returns {String} - A fully qualified name of an output file with `str`.
      */
    private String getFileName(String s) {
        String output = "SavedData"+System.getProperty("file.separator")+"OpenBCI-BDF-";
        output += s;
        output += ".bdf";
        return output;
    }

    /**
      * @description Get's the number of signal channels to write out. Have to
      *  keep in mind that the annotations channel counts.
      * @returns {int} - The number of signals in the header.
      */
    private int getNbSignals() {
        if (eegDataSource == DATASOURCE_CYTON) {
            return nbChan + nbAux + nbAnnotations;
        } else {
            return nbChan + nbAnnotations;
        }

    }

    /**
      * @description Takes an array of strings and joins split by `delimiter`
      * @param `stringArray` {String []} - An array of strings
      * @param `delimiter` {String} - The delimiter to split the strings with
      * @returns `String` - All the strings from `stringArray` separated by
      *  `delimiter`.
      * @reference http://www.edfplus.info/specs/edf.html
      */
    private String joinStringArray(String[] stringArray, String delimiter) {
        String output = "";

        // Number of elecments to add
        int numberOfElements = stringArray.length;

        // Each element will be written
        for (int i = 0; i < numberOfElements; i++) {
            // Add the element
            output += stringArray[i];
            // Add a delimiter between
            output += delimiter;
        }

        return output;
    }

    /**
      * @description Used to combine a `str` (string) with left justification padding of `size`.
      * @param `s` {String} - The string to be inserted
      * @param `size` {int} - The total allowable size for `str` to be inserted.
      *  If `str.length()` < `size` then `str` will essentially be right padded with
      *  spaces till the `output` is of length `size`.
      * @returns {String} - The `str` right padded with spaces to become `size` length.
      */
    private String padStringRight(String s, int size) {
        char[] output = new char[size];
        int len = 0;
        if (s != null) len = s.length();
        for (int i = 0; i < size; i++) {
            if (i < len) {
                output[i] = s.charAt(i);
            } else {
                output[i] = ' ';
            }
        }
        return new String(output, 0, size);
    }

    /**
      * @description Sets the header per channel arrays to their default values
      */
    private void setAuxArraysToDefaults() {
        labelsAux[0] = "Accel X";
        labelsAux[1] = "Accel Y";
        labelsAux[2] = "Accel Z";
        setStringArray(transducerAux, BDF_HEADER_TRANSDUCER_MEMS, nbAux);
        setStringArray(physicalDimensionAux, BDF_HEADER_PHYSICAL_DIMENISION_G, nbAux);
        setStringArray(digitalMinimumAux, bdf_digital_minimum_ADC_12bit, nbAux);
        setStringArray(digitalMaximumAux, bdf_digital_maximum_ADC_12bit, nbAux);
        setStringArray(physicalMinimumAux, bdf_physical_minimum_ADC_Accel, nbAux);
        setStringArray(physicalMaximumAux, bdf_physical_maximum_ADC_Accel, nbAux);
        setStringArray(prefilteringAux, " ", nbAux);
        setStringArray(nbSamplesPerDataRecordAux, str(fs_Hz), nbAux);
        setStringArray(reservedAux, " ", nbAux);
    }

    /**
      * @description Sets the header per channel arrays to their default values
      */
    private void setAnnotationsArraysToDefaults() {
        setStringArray(labelsAnnotations, BDF_HEADER_ANNOTATIONS, 1); // Leave space for the annotations space
        setStringArray(transducerAnnotations, " ", 1);
        setStringArray(physicalDimensionAnnotations, " ", 1);
        setStringArray(digitalMinimumAnnotations, bdf_digital_minimum_ADC_24bit, 1);
        setStringArray(digitalMaximumAnnotations, bdf_digital_maximum_ADC_24bit, 1);
        if (eegDataSource == DATASOURCE_GANGLION) {
            setStringArray(physicalMinimumAnnotations, bdf_physical_minimum_ADC_24bit_ganglion, 1);
            setStringArray(physicalMaximumAnnotations, bdf_physical_maximum_ADC_24bit_ganglion, 1);
        } else {
            setStringArray(physicalMinimumAnnotations, bdf_physical_minimum_ADC_24bit, 1);
            setStringArray(physicalMaximumAnnotations, bdf_physical_maximum_ADC_24bit, 1);
        }
        setStringArray(prefilteringAnnotations, " ", 1);
        nbSamplesPerDataRecordAnnotations[0] = str(nbSamplesPerAnnontation);
        setStringArray(reservedAnnotations, " ", 1);
    }

    /**
      * @description Sets the header per channel arrays to their default values
      */
    private void setEEGArraysToDefaults() {
        for (int i = 1; i <= nbChan; i++) {
            labelsEEG[i - 1] = "EEG " + i;
        }
        setStringArray(transducerEEG, BDF_HEADER_TRANSDUCER_AGAGCL, nbChan);
        setStringArray(physicalDimensionEEG, BDF_HEADER_PHYSICAL_DIMENISION_UV, nbChan);
        setStringArray(digitalMinimumEEG, bdf_digital_minimum_ADC_24bit, nbChan);
        setStringArray(digitalMaximumEEG, bdf_digital_maximum_ADC_24bit, nbChan);
        setStringArray(physicalMinimumEEG, bdf_physical_minimum_ADC_24bit, nbChan);
        setStringArray(physicalMaximumEEG, bdf_physical_maximum_ADC_24bit, nbChan);
        setStringArray(prefilteringEEG, " ", nbChan);
        setStringArray(nbSamplesPerDataRecordEEG, str(fs_Hz), nbChan);
        setStringArray(reservedEEG, " ", nbChan);
    }

    /**
      * @description Convience function to fill a string array with the same values
      * @param `arr` {String []} - A string array to fill
      * @param `val` {Stirng} - The string to be inserted into `arr`
      */
    private void setStringArray(String[] arr, String val, int len) {
        for (int i = 0; i < len; i++) {
            arr[i] = val;
        }
    }

    /**
      * @description Converts a byte from Big Endian to Little Endian
      * @param `val` {byte} - The byte to swap
      * @returns {byte} - The swapped byte.
      */
    private byte swapByte(byte val) {
        int mask = 0x80;
        int res = 0;
        // println("swapByte: starting to swap val: 0b" + binary(val,8));
        for (int i = 0; i < 8; i++) {
            // println("\nswapByte: i: " + i);
            // Isolate the MSB with a big mask i.e. 10000000, 01000000, etc...
            int temp = (val & mask);
            // println("swapByte: temp:    0b" + binary(temp,8));
            // Save this temp value
            res = (res >> 1) | (temp << i);
            // println("swapByte: res:     0b" + binary(res,8));
            // Move mask one place
            mask = mask >> 1;
            // println("swapByte: mask: 0b" + binary(mask,32));
        }
        // println("swapByte: ending swapped val: 0b" + binary(res,8));
        return (byte)res;
    }

    /**
      * @description Swaps any spaces for underscores because EDF+ calls for it
      * @param `s` {String} - A string containing spaces
      * @returns {String} - A string with underscores instead of spaces.
      * @reference http://www.edfplus.info/specs/edfplus.html#additionalspecs
      */
    private String swapSpacesForUnderscores(String s) {
        int len = s.length();
        char[] output = new char[len];
        // Loop through the String
        for (int i = 0; i < len; i++) {
            if (s.charAt(i) == ' ') {
                output[i] = '_';
            } else {
                output[i] = s.charAt(i);
            }
        }
        return new String(output, 0, len);
    }

    /**
      * @description Moves a packet worth of data into channel buffer, also converts
      *  from Big Endian to Little Indian as per the specs of BDF+.
      *  Ref [1]: http://www.biosemi.com/faq/file_format.htm
      * @param `values` {byte[][]} - A byte array that is n_chan X sample size (3)
      */
    private void writeChannelDataValues(byte[][] values) {
        for (int i = 0; i < nbChan; i++) {
            // Make the values little endian
            chanValBuf[i][samplesInDataRecord][0] = swapByte(values[i][2]);
            chanValBuf[i][samplesInDataRecord][1] = swapByte(values[i][1]);
            chanValBuf[i][samplesInDataRecord][2] = swapByte(values[i][0]);
        }
    }

    /**
      * @description Moves a packet worth of data into aux buffer, also converts
      *  from Big Endian to Little Indian as per the specs of BDF+.
      *  Ref [1]: http://www.biosemi.com/faq/file_format.htm
      * @param `values` {byte[][]} - A byte array that is n_aux X sample size (3)
      */
    private void writeAuxDataValues(byte[][] values) {
        for (int i = 0; i < nbAux; i++) {
            if (write_accel) {
                // grab the lower part of
                boolean zeroPack = true;
                // shift right
                int t = (int)values[i][0] & 0x0F;
                values[i][0] = (byte)((int)values[i][0] >> 4);
                if (values[i][0] >= 8) {
                    zeroPack = false;
                }
                values[i][1] = (byte)((int)values[i][1] >> 4);
                values[i][1] = (byte)((int)values[i][1] | t);
                if (!zeroPack) {
                    values[i][0] = (byte)((int)values[i][0] | 0xF0);
                }
                // make msb -> lsb
                auxValBuf[i][samplesInDataRecord][0] = swapByte(values[i][1]);
                auxValBuf[i][samplesInDataRecord][1] = swapByte(values[i][0]);
                // pad byte
                if (zeroPack) {
                    auxValBuf[i][samplesInDataRecord][2] = (byte)0x00;
                } else {
                    auxValBuf[i][samplesInDataRecord][2] = (byte)0xFF;
                }
            } else {
                // TODO: Implement once GUI gets support for non standard packets
            }
        }
    }

    /**
      * @description Writes data from a temp file over to the final file with the
      *  header in place already.
      *  TODO: Stop keeping it in memory.
      * @param `o` {OutputStream} - An output stream to write to.
      */
    private void writeData(OutputStream o) {

        InputStream input = createInput(tempWriterPrefix);

        try {
            println("writeData: started...");
            int data = input.read();
            int byteCount = 0;
            while (data != -1) {
                o.write(data);
                data = input.read();
                byteCount++;
            }
            println("writeData: finished: wrote " + byteCount + " bytes");
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        finally {
            try {
                input.close();
            }
            catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
      * @description Writes a fully qualified BDF+ header
      */
    private void writeHeader(OutputStream o) {
        // writer.write(0xFF); // Write the first byte of the header here
        try {
            // println("writeHeader: starting...");

            o.write(0xFF);
            writeString(padStringRight(new String(bdf_version),BDF_HEADER_SIZE_VERSION - 1), o); // Do one less then supposed to because of the first byte already written.
            String[] temp1  = {bdf_patient_id_subfield_hospoital_code,bdf_patient_id_subfield_sex,bdf_patient_id_subfield_birthdate,bdf_patient_id_subfield_name};
            writeString(padStringRight(joinStringArray(temp1, " "), BDF_HEADER_SIZE_PATIENT_ID), o);
            String[] temp2 = {bdf_recording_id_subfield_prefix,bdf_recording_id_subfield_startdate,bdf_recording_id_subfield_admin_code,bdf_recording_id_subfield_investigator,bdf_recording_id_subfield_equipment};
            writeString(padStringRight(joinStringArray(temp2, " "), BDF_HEADER_SIZE_RECORDING_ID), o);
            writeString(getDateString(startTime, startDateFormat), o);
            writeString(getDateString(startTime, startTimeFormat), o);
            writeString(padStringRight(str(getBytesInHeader()),BDF_HEADER_SIZE_BYTES_IN_HEADER), o);
            writeString(padStringRight("24BIT",BDF_HEADER_SIZE_RESERVED), o);//getContinuity(),BDF_HEADER_SIZE_RESERVED), o);
            writeString(padStringRight(str(dataRecordsWritten),BDF_HEADER_SIZE_NUMBER_DATA_RECORDS), o);
            writeString(padStringRight("1",BDF_HEADER_SIZE_DURATION_OF_DATA_RECORD), o);
            writeString(padStringRight(str(getNbSignals()),BDF_HEADER_SIZE_NUMBER_SIGNALS), o);

            writeStringArrayWithPaddingTimes(labelsEEG, BDF_HEADER_NS_SIZE_LABEL, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(labelsAux, BDF_HEADER_NS_SIZE_LABEL, o);
            writeStringArrayWithPaddingTimes(labelsAnnotations, BDF_HEADER_NS_SIZE_LABEL, o);

            writeStringArrayWithPaddingTimes(transducerEEG, BDF_HEADER_NS_SIZE_TRANSDUCER_TYPE, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(transducerAux, BDF_HEADER_NS_SIZE_TRANSDUCER_TYPE, o);
            writeStringArrayWithPaddingTimes(transducerAnnotations, BDF_HEADER_NS_SIZE_TRANSDUCER_TYPE, o);

            writeStringArrayWithPaddingTimes(physicalDimensionEEG, BDF_HEADER_NS_SIZE_PHYSICAL_DIMENSION, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(physicalDimensionAux, BDF_HEADER_NS_SIZE_PHYSICAL_DIMENSION, o);
            writeStringArrayWithPaddingTimes(physicalDimensionAnnotations, BDF_HEADER_NS_SIZE_PHYSICAL_DIMENSION, o);

            writeStringArrayWithPaddingTimes(physicalMinimumEEG, BDF_HEADER_NS_SIZE_PHYSICAL_MINIMUM, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(physicalMinimumAux, BDF_HEADER_NS_SIZE_PHYSICAL_MINIMUM, o);
            writeStringArrayWithPaddingTimes(physicalMinimumAnnotations, BDF_HEADER_NS_SIZE_PHYSICAL_MINIMUM, o);

            writeStringArrayWithPaddingTimes(physicalMaximumEEG, BDF_HEADER_NS_SIZE_PHYSICAL_MAXIMUM, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(physicalMaximumAux, BDF_HEADER_NS_SIZE_PHYSICAL_MAXIMUM, o);
            writeStringArrayWithPaddingTimes(physicalMaximumAnnotations, BDF_HEADER_NS_SIZE_PHYSICAL_MAXIMUM, o);

            writeStringArrayWithPaddingTimes(digitalMinimumEEG, BDF_HEADER_NS_SIZE_DIGITAL_MINIMUM, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(digitalMinimumAux, BDF_HEADER_NS_SIZE_DIGITAL_MINIMUM, o);
            writeStringArrayWithPaddingTimes(digitalMinimumAnnotations, BDF_HEADER_NS_SIZE_DIGITAL_MINIMUM, o);

            writeStringArrayWithPaddingTimes(digitalMaximumEEG, BDF_HEADER_NS_SIZE_DIGITAL_MAXIMUM, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(digitalMaximumAux, BDF_HEADER_NS_SIZE_DIGITAL_MAXIMUM, o);
            writeStringArrayWithPaddingTimes(digitalMaximumAnnotations, BDF_HEADER_NS_SIZE_DIGITAL_MAXIMUM, o);

            writeStringArrayWithPaddingTimes(prefilteringEEG, BDF_HEADER_NS_SIZE_PREFILTERING, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(prefilteringAux, BDF_HEADER_NS_SIZE_PREFILTERING, o);
            writeStringArrayWithPaddingTimes(prefilteringAnnotations, BDF_HEADER_NS_SIZE_PREFILTERING, o);

            writeStringArrayWithPaddingTimes(nbSamplesPerDataRecordEEG, BDF_HEADER_NS_SIZE_NR, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(nbSamplesPerDataRecordAux, BDF_HEADER_NS_SIZE_NR, o);
            writeStringArrayWithPaddingTimes(nbSamplesPerDataRecordAnnotations, BDF_HEADER_NS_SIZE_NR, o);

            writeStringArrayWithPaddingTimes(reservedEEG, BDF_HEADER_NS_SIZE_RESERVED, o);
            if (eegDataSource == DATASOURCE_CYTON) writeStringArrayWithPaddingTimes(reservedAux, BDF_HEADER_NS_SIZE_RESERVED, o);
            writeStringArrayWithPaddingTimes(reservedAnnotations, BDF_HEADER_NS_SIZE_RESERVED, o);

            // println("writeHeader: done...");

        } catch(Exception e) {
            println("writeHeader: Exception " + e);
        }
    }

    /**
      * @description Write out an array of strings with `padding` on each element.
      *  Each element is padded right.
      * @param `arr` {String []} - An array of strings to write out
      * @param `padding` {int} - The amount of padding for each `arr` element.
      * @param `o` {OutputStream} - The output stream to write to.
      */
    private void writeStringArrayWithPaddingTimes(String[] arr, int padding, OutputStream o) {
        int len = arr.length;
        for (int i = 0; i < len; i++) {
            writeString(padStringRight(arr[i], padding), o);
        }
    }

    /**
      * @description Writes a string to an OutputStream s
      * @param `s` {String} - The string to write.
      * @param `o` {OutputStream} - The output stream to write to.
      */
    private void writeString(String s, OutputStream o) {
        int len = s.length();
        try {
            for (int i = 0; i < len; i++) {
                o.write((int)s.charAt(i));
            }
        } catch (Exception e) {
            println("writeString: exception: " + e);
        }
    }

};

///////////////////////////////////////////////////////////////
//
// Class: Table_CSV
// Purpose: Extend the Table class to handle data files with comment lines
// Created: Chip Audette  May 2, 2014
//
// Usage: Only invoke this object when you want to read in a data
//    file in CSV format.  Read it in at the time of creation via
//
//    String fname = "myfile.csv";
//    TableCSV myTable = new TableCSV(fname);
//
///////////////////////////////////////////////////////////////

class Table_CSV extends Table {
    private int sampleRate;
    public int getSampleRate() { return sampleRate; }
    Table_CSV(String fname) throws IOException {
        init();
        readCSV(PApplet.createReader(createInput(fname)));
    }

    //this function is nearly completely copied from parseBasic from Table.java
    void readCSV(BufferedReader reader) throws IOException {
        boolean header=false;  //added by Chip, May 2, 2014;
        boolean tsv = false;  //added by Chip, May 2, 2014;

        String line = null;
        int row = 0;
        if (rowCount == 0) {
            setRowCount(10);
        }
        //int prev = 0;  //-1;
        try {
            while ( (line = reader.readLine ()) != null) {
                //added by Chip, May 2, 2014 to ignore lines that are comments
                if (line.charAt(0) == '%') {
                    if (line.length() > 18) {
                        if (line.charAt(1) == 'S') {
                            // println(line.substring(15, 18));
                            sampleRate = Integer.parseInt(line.substring(15, 18));
                            if (sampleRate == 100 || sampleRate == 160) {
                                sampleRate = Integer.parseInt(line.substring(15, 19));
                            }
                            println("Sample rate set to " + sampleRate);
                            // String[] m = match(line, "\\d+");
                            // if (m != null) {
                                // println("Found '" + m[1] + "' inside the line");
                            // }
                        }
                    }
                    println(line);
                    // if (line.charAt(1) == 'S') {
                    //   println("sampel rarteakjdsf;ldj");
                    // }
                    continue;
                }

                if (row == getRowCount()) {
                    setRowCount(row << 1);
                }
                if (row == 0 && header) {
                    setColumnTitles(tsv ? PApplet.split(line, '\t') : split(line,','));
                    header = false;
                }
                else {
                    setRow(row, tsv ? PApplet.split(line, '\t') : split(line,','));
                    row++;
                }

                // this is problematic unless we're going to calculate rowCount first
                if (row % 10000 == 0) {
                    /*
                if (row < rowCount) {
                      int pct = (100 * row) / rowCount;
                      if (pct != prev) {  // also prevents "0%" from showing up
                      System.out.println(pct + "%");
                      prev = pct;
                      }
                      }
                      */
                    try {
                        // Sleep this thread so that the GC can catch up
                        Thread.sleep(10);
                    }
                    catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        catch (Exception e) {
            throw new RuntimeException("Error reading table on line " + row, e);
        }
        // shorten or lengthen based on what's left
        if (row != getRowCount()) {
            setRowCount(row);
        }
    }
}

//////////////////////////////////
//
//    This collection of functions/methods - convertSDFile, createPlaybackFileFromSD, & sdFileSelected - contains code
//    used to convert HEX files (stored by OpenBCI on the local SD) into text files that can be used for PLAYBACK mode.
//    Created: Conor Russomanno - 10/22/14 (based on code written by Joel Murphy summer 2014)
//    Updated: Joel Murphy - 6/26/17
//
//////////////////////////////////

//variables for SD file conversion
BufferedReader dataReader;
String dataLine;
PrintWriter dataWriter;
String convertedLine;
String thisLine;
String h;
float[] floatData = new float[20];
float[] intData = new float[20];
String logFileName;
String[] hexNums;
long thisTime;
long thatTime;
boolean printNextLine = false;

public void convertSDFile() {
    // println("");
    try {
        dataLine = dataReader.readLine();
    }
    catch (IOException e) {
        e.printStackTrace();
        dataLine = null;
    }

    if (dataLine == null) {
        // Stop reading because of an error or file is empty
        thisTime = millis() - thatTime;
        controlPanel.convertingSD = false;
        println("nothing left in file");
        println("SD file conversion took "+thisTime+" mS");
        outputSuccess("SD file converted to " + logFileName);
        dataWriter.flush();
        dataWriter.close();
    }
        else
    {
        hexNums = splitTokens(dataLine, ",");

        if (hexNums[0].charAt(0) == '%') {
            //          println(dataLine);
            // dataWriter.println(dataLine);
            println(dataLine);
            printNextLine = true;
        } else {
            if (hexNums.length < 13){
                convert8channelLine();
            } else {
                convert16channelLine();
            }
            if(printNextLine){
                printNextLine = false;
            }
        }
    }
}

void convert16channelLine() {
    if(printNextLine){
        for(int i=0; i<hexNums.length; i++){
            h = hexNums[i];
            if (h.length()%2 == 0 && h.length() <= 10) {  // make sure this is a real number
                intData[i] = unhex(h);
            } else {
                intData[i] = 0;
            }
            dataWriter.print(intData[i]);
            print(intData[i]);
            if(hexNums.length > 1){
                dataWriter.print(", ");
                print(", ");
            }
        }
        dataWriter.println();
        println();
        return;
    }
    for (int i=0; i<hexNums.length; i++) {
        h = hexNums[i];
        if (i > 0) {
            if (h.charAt(0) > '7') {  // if the number is negative
                h = "FF" + hexNums[i];   // keep it negative
            } else {                  // if the number is positive
                h = "00" + hexNums[i];   // keep it positive
            }
            if (i > 16) { // accelerometer data needs another byte
                if (h.charAt(0) == 'F') {
                    h = "FF" + h;
                } else {
                    h = "00" + h;
                }
            }
        }
        // println(h); // use for debugging
        if (h.length()%2 == 0 && h.length() <= 10) {  // make sure this is a real number
            floatData[i] = unhex(h);
        } else {
            floatData[i] = 0;
        }

        if (i>=1 && i<=16) {
            floatData[i] *= cyton.get_scale_fac_uVolts_per_count();
        }else if(i != 0){
            floatData[i] *= cyton.get_scale_fac_accel_G_per_count();
        }

        if(i == 0){
            dataWriter.print(int(floatData[i]));  // print the sample counter
        }else{
            dataWriter.print(floatData[i]);  // print the current channel value
        }
        if (i < hexNums.length-1) {  // print the current channel value
            dataWriter.print(",");  // print "," separator
        }
    }
    dataWriter.println();
}

void convert8channelLine() {
    if(printNextLine){
        for(int i=0; i<hexNums.length; i++){
            h = hexNums[i];
            if (h.length()%2 == 0) {  // make sure this is a real number
                intData[i] = unhex(h);
            } else {
                intData[i] = 0;
            }
            print(intData[i]);
            dataWriter.print(intData[i]);
            if(hexNums.length > 1){
                dataWriter.print(", ");
                print(", ");
            }
        }
        dataWriter.println();
        println();
        return;
    }
    for (int i=0; i<hexNums.length; i++) {
        h = hexNums[i];
        if (i > 0) {
            if (h.charAt(0) > '7') {  // if the number is negative
                h = "FF" + hexNums[i];   // keep it negative
            } else {                  // if the number is positive
                h = "00" + hexNums[i];   // keep it positive
            }
            if (i > 8) { // accelerometer data needs another byte
                if (h.charAt(0) == 'F') {
                    h = "FF" + h;
                } else {
                    h = "00" + h;
                }
            }
        }
        // println(h + " " + h.length()); // use for debugging
        if (h.length() > 8) {
            break;
        }
        if (h.length()%2 == 0) {  // make sure this is a real number
            floatData[i] = unhex(h);
        } else {
            floatData[i] = 0;
        }

        if (i>=1 && i<=8) {
            floatData[i] *= cyton.get_scale_fac_uVolts_per_count();
        }else if(i != 0){
            floatData[i] *= cyton.get_scale_fac_accel_G_per_count();
        }

        if(i == 0){
            dataWriter.print(int(floatData[i]));  // print the sample counter
        }else{
            dataWriter.print(floatData[i]);  // print the current channel value
        }
        if (i < hexNums.length-1) {
            dataWriter.print(",");  // print "," separator
        }
    }
    dataWriter.println();
}











//     BEWARE: Old Stuff Below
//
//     //        println(dataLine);
//     String[] hexNums = splitTokens(dataLine, ",");
//
//     if (hexNums[0].charAt(0) == '%') {
//       //          println(dataLine);
//       dataWriter.println(dataLine);
//       println(dataLine);
//       printNextLine = true;
//     } else {
//       for (int i=0; i<hexNums.length; i++) {
//         h = hexNums[i];
//         if (i > 0) {
//           if (h.charAt(0) > '7') {  // if the number is negative
//             h = "FF" + hexNums[i];   // keep it negative
//           } else {                  // if the number is positive
//             h = "00" + hexNums[i];   // keep it positive
//           }
//           if (i > 8) { // accelerometer data needs another byte
//             if (h.charAt(0) == 'F') {
//               h = "FF" + h;
//             } else {
//               h = "00" + h;
//             }
//           }
//         }
//         // println(h); // use for debugging
//         if (h.length()%2 == 0) {  // make sure this is a real number
//           intData[i] = unhex(h);
//         } else {
//           intData[i] = 0;
//         }
//
//         //if not first column(sample #) or columns 9-11 (accelerometer), convert to uV
//         if (i>=1 && i<=8) {
//           intData[i] *= openBCI.get_scale_fac_uVolts_per_count();
//         }
//
//         //print the current channel value
//         dataWriter.print(intData[i]);
//         if (i < hexNums.length-1) {
//           //print "," separator
//           dataWriter.print(",");
//         }
//       }
//       //println();
//       dataWriter.println();
//     }
//   }
// }
