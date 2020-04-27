
////////////////////////////////////////////////////////////
// Purpose: Handle OpenBCI Data Format and BDF+ file writing
// Created: Chip Audette  May 2, 2014
// Modified: Richard Waltman July 1, 2019
//
////////////////////////////////////////////////////////////

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
    settings.setLogFileIsOpen(true);
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
    println("OpenBCI_GUI: openNewLogFile: opened BDF output file: " + output_fname); //Print filename of new BDF file to console
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
    fileoutput_odf = new OutputFile_rawtxt(getSampleRateSafe(), sessionName, _fileName);

    output_fname = fileoutput_odf.fname;
    println("OpenBCI_GUI: openNewLogFile: opened ODF output file: " + output_fname); //Print filename of new ODF file to console
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
    settings.setLogFileIsOpen(false);
}

/**
  * @description Close an open BDF file. This will also update the number of data
  *  records.
  */
void closeLogFileBDF() {
    if (fileoutput_bdf != null) {
        fileoutput_bdf.closeFile();
    }
    fileoutput_bdf = null;
}

/**
  * @description Close an open ODF file.
  */
void closeLogFileODF() {
    if (fileoutput_odf != null) {
        fileoutput_odf.closeFile();
    }
    fileoutput_odf = null;
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
    logFileName = settings.guiDataPath+"SDconverted-"+getDateString()+".csv";
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