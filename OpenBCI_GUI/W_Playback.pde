
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
//    W_playback.pde (ie "Playback History")
//
//    Allow user to load playback files from within GUI without having to restart the system
//                       Created: Richard Waltman - August 2018
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ControlP5 cp5_playback;

//Used mostly in W_playback.pde
JSONObject savePlaybackHistoryJSON;
JSONObject loadPlaybackHistoryJSON;
final String userPlaybackHistoryFile = settings.settingsPath+"UserPlaybackHistory.json";
boolean playbackHistoryFileExists = false;
String playbackData_ShortName;
boolean recentPlaybackFilesHaveUpdated = false;

class W_playback extends Widget {
    //allow access to dataProcessing
    DataProcessing dataProcessing;
    //Set up variables for Playback widget
    Button selectPlaybackFileButton;
    MenuList playbackMenuList;
    //Used for spacing
    int padding = 10;

    private boolean visible = true;
    private boolean updating = true;
    private boolean menuHasUpdated = false;
    private boolean menuListIsLocked = false;

    W_playback(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //make a button to load new files
        selectPlaybackFileButton = new Button (
            x + w/2 - (padding*2),
            y - navHeight + 2,
            200,
            navHeight - 6,
            "SELECT PLAYBACK FILE",
            fontInfo.buttonLabel_size);
        selectPlaybackFileButton.setHelpText("Click to open a dialog box to select an OpenBCI playback file (.txt or .csv).");
        //make a MenuList
        int initialWidth = w - padding*2;
        cp5_playback = new ControlP5(pApplet);
        playbackMenuList = new MenuList(cp5_playback, "playbackMenuList", initialWidth, h - padding*2, p4);
        playbackMenuList.setPosition(x + padding/2, y + 2);
        playbackMenuList.setSize(initialWidth, h - padding*2);
        playbackMenuList.scrollerLength = 40;
        cp5_playback.get(MenuList.class, "playbackMenuList").setVisible(true);
        cp5_playback.setAutoDraw(false);
    }

    public boolean isVisible() {
        return visible;
    }
    public boolean isUpdating() {
        return updating;
    }

    public void setVisible(boolean _visible) {
        visible = _visible;
    }
    public void setUpdating(boolean _updating) {
        updating = _updating;
    }

    void update() {
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
        if (!menuHasUpdated) {
            refreshPlaybackList();
            menuHasUpdated = true;
        }
        //Lock the MenuList if Widget selector is open, otherwise update
        if (cp5_widget.get(ScrollableList.class, "WidgetSelector").isOpen()) {
            if (!menuListIsLocked) {
                cp5_playback.get(MenuList.class, "playbackMenuList").lock();
                cp5_playback.get(MenuList.class, "playbackMenuList").setUpdate(false);
                menuListIsLocked = true;
            }
        } else {
            if (menuListIsLocked) {
                cp5_playback.get(MenuList.class, "playbackMenuList").unlock();
                cp5_playback.get(MenuList.class, "playbackMenuList").setUpdate(true);
                menuListIsLocked = false;
            }
            playbackMenuList.updateMenu();
        }

    }

    void draw() {
        //Only draw if the widget is visible and User settings have been loaded
        //settingsLoadedCheck is set to true after default settings are saved between Init checkpoints 4 and 5
        if(visible && settings.settingsLoaded) {
            super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

            //x,y,w,h are the positioning variables of the Widget class
            pushStyle();
            fill(boxColor);
            stroke(boxStrokeColor);
            strokeWeight(1);
            rect(x, y, w, h);
            //Add text if needed
            /*
            fill(bgColor);
            textFont(h3, 16);
            textAlign(LEFT, TOP);
            text("PLAYBACK FILE", x + padding, y + padding);
            */
            popStyle();

            pushStyle();
            selectPlaybackFileButton.draw();
            cp5_playback.draw();
            popStyle();
        }
    } //end draw loop

    void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //**IMPORTANT FOR CP5**//
        //This makes the cp5 objects within the widget scale properly
        cp5_playback.setGraphics(pApplet, 0, 0);

        //resize and position the playback file box and button
        selectPlaybackFileButton.setPos(x + w - selectPlaybackFileButton.but_dx - padding, y - navHeight + 2);

        playbackMenuList.setPosition(x + padding/2, y + 2);
        playbackMenuList.setSize(w - padding*2, h - padding*2);
        refreshPlaybackList();
    } //end screen Resized

    void mouseOver() {
        if (topNav.configSelector.isVisible) {
            selectPlaybackFileButton.setIsActive(false);
        }
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        if (!topNav.configSelector.isVisible) {
            //check if mouse is over the select playback file button
            if (selectPlaybackFileButton.isMouseHere()) {
                selectPlaybackFileButton.setIsActive(true);
            }
        }
    } // end mouse Pressed

    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
        //check if user has clicked on the select playback file button
        if (selectPlaybackFileButton.isMouseHere() && selectPlaybackFileButton.isActive) {
            output("select a file for playback");
            selectInput("Select a pre-recorded file for playback:", "playbackSelectedWidgetButton");
        }
        selectPlaybackFileButton.setIsActive(false);
    } // end mouse Released

    public void refreshPlaybackList() {
        try {
            playbackMenuList.items.clear();
            loadPlaybackHistoryJSON = loadJSONObject(userPlaybackHistoryFile);
            JSONArray loadPlaybackHistoryJSONArray = loadPlaybackHistoryJSON.getJSONArray("playbackFileHistory");
            //println("Array Size:" + loadPlaybackHistoryJSONArray.size());
            int currentFileNameToDraw = 0;
            for (int i = loadPlaybackHistoryJSONArray.size() - 1; i >= 0; i--) { //go through array in reverse since using append
                JSONObject loadRecentPlaybackFile = loadPlaybackHistoryJSONArray.getJSONObject(i);
                int fileNumber = loadRecentPlaybackFile.getInt("recentFileNumber");
                String shortFileName = loadRecentPlaybackFile.getString("id");
                String longFilePath = loadRecentPlaybackFile.getString("filePath");

                int totalPadding = padding + playbackMenuList.padding;
                shortFileName = shortenString(shortFileName, w-totalPadding*2.f, p4);
                //add as an item in the MenuList
                playbackMenuList.addItem(makeItem(shortFileName, Integer.toString(fileNumber), longFilePath));
                currentFileNameToDraw++;
            }
            playbackMenuList.updateMenu();
        } catch (NullPointerException e) {
            println("PlaybackWidget: Playback history file not found.");
        }
    }
}; //end Playback widget class

//////////////////////////////////////
// GLOBAL FUNCTIONS BELOW THIS LINE //
//////////////////////////////////////

//Activated when user selects a file using the "Select Playback File" button in PlaybackHistory
void playbackSelectedWidgetButton(File selection) {
    if (selection == null) {
        println("W_Playback: playbackSelected: Window was closed or the user hit cancel.");
    } else {
        println("W_Playback: playbackSelected: User selected " + selection.getAbsolutePath());
        playbackFileSelected(selection.getAbsolutePath(), selection.getName());
        if (playbackFileIsEmpty) {
            haltLoadingFile(selection.getAbsolutePath());
        } else {
            reInitAfterPlaybackSelected();
        }
    }
}

//Activated when user selects a file using the recent file MenuList
void userSelectedPlaybackMenuList (String filePath, int listItem) {
    if (new File(filePath).isFile()) {
        playbackFileSelected(filePath, listItem);
        if (playbackFileIsEmpty) {
            haltLoadingFile(filePath);
        } else {
            reInitAfterPlaybackSelected();
        }
    } else {
        outputError("W_Playback: Selected file does not exist. Try another file or clear settings to remove this entry.");
    }
}

void reInitAfterPlaybackSelected() {
    //Tell TS widget that the number of channel bars needs to be updated
    w_timeSeries.updateNumberOfChannelBars = true;
    //Reinitialize core data, EMG, FFT, and Headplot number of channels
    reinitializeCoreDataAndFFTBuffer();
    //Update the MenuList in the PlaybackHistory Widget
    w_playback.refreshPlaybackList();
    //Process the file again to fix issue. This makes indexes for playback slider load properly
    try {
        hasRepeated = false;
        has_processed = false;
        process_input_file();
        println("+++GUI update process file has occurred");
    }
    catch(Exception e) {
        isOldData = true;
        output("+++Error processing timestamps, are you using old data?");
    }
}

//Called when user selects a playback file from dialog box
void playbackFileSelected(File selection) {
    if (selection == null) {
        println("DataLogging: playbackSelected: Window was closed or the user hit cancel.");
    } else {
        println("DataLogging: playbackSelected: User selected " + selection.getAbsolutePath());
        //Set the name of the file
        playbackFileSelected(selection.getAbsolutePath(), selection.getName());
        if (playbackFileIsEmpty) {
            haltLoadingFile(selection.getAbsolutePath());
            return;
        }
    }
}

//Called when user selects a playback file from a list
void playbackFileSelected (String longName, int listItem) {
    String shortName = "";
    //look at the JSON file to set the range menu using number of recent file entries
    try {
        savePlaybackHistoryJSON = loadJSONObject(userPlaybackHistoryFile);
        JSONArray recentFilesArray = savePlaybackHistoryJSON.getJSONArray("playbackFileHistory");
        JSONObject playbackFile = recentFilesArray.getJSONObject(-listItem + recentFilesArray.size() - 1);
        shortName = playbackFile.getString("id");
        playbackHistoryFileExists = true;
    } catch (NullPointerException e) {
        //println("Playback history JSON file does not exist. Load first file to make it.");
        playbackHistoryFileExists = false;
    }
    playbackFileSelected(longName, shortName);
    if (playbackFileIsEmpty) {
        haltLoadingFile(longName);
        return;
    }
}

//Handles the work for the above two cases
void playbackFileSelected (String longName, String shortName) {
    playbackData_fname = longName;
    playbackData_ShortName = shortName;
    //Process the playback file
    processNewPlaybackFile();
    if (playbackFileIsEmpty) return;
    //Determine the number of channels
    if (playbackData_table != null) {
        determineNumChanFromFile(playbackData_table);
    } else {
        outputError("playbackFileSelected: Data table appears to be null! Please submit an issue on GitHub!");
        return;
    }
    //Output new playback settings to GUI as success
    outputSuccess("You have selected \""
    + shortName + "\" for playback. "
    + str(nchan) + " channels found.");
    try {
        savePlaybackHistoryJSON = loadJSONObject(userPlaybackHistoryFile);
        JSONArray recentFilesArray = savePlaybackHistoryJSON.getJSONArray("playbackFileHistory");
        playbackHistoryFileExists = true;
    } catch (NullPointerException e) {
        //println("Playback history JSON file does not exist. Load first file to make it.");
        playbackHistoryFileExists = false;
    } catch (RuntimeException e) {
        outputError("Found an error in UserPlaybackHistory.json. Deleting this file. Please, Restart the GUI.");
        File file = new File(userPlaybackHistoryFile);
        if (!file.isDirectory()) {
            file.delete();
        }
    }
    //add playback file that was processed to the JSON history
    savePlaybackFileToHistory(longName);
}

void processNewPlaybackFile() { //Also used in DataLogging.pde
    //Fix issue for processing successive playback files
    indices = 0;
    hasRepeated = false;
    has_processed = false;
    if (systemMode == SYSTEMMODE_POSTINIT) {
        w_timeSeries.scrollbar.skipToStartButtonAction(); //sets scrollbar to 0
    }
    //initialize playback file
    initPlaybackFileToTable();
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

void initPlaybackFileToTable() { //also used in OpenBCI_GUI.pde on system start
    //open and load the data file
    println("OpenBCI_GUI: initSystem: loading playback data from " + playbackData_fname);
    playbackFileIsEmpty = false; //reset this flag each time playback data is loaded
    boolean errorLoadingTable = false;

    errorLoadingTable = loadTableFromCSV();

    //Sometimes the SD card converted files have blank space at the end, remove it and try to connect again
    if (errorLoadingTable) {
        println("initPlaybackFileToTable: Deleting last line of file and trying again...");
        try {
            RandomAccessFile f = new RandomAccessFile(playbackData_fname, "rw");
            long length = f.length() - 1;
            byte b; 
            do {                     
                length -= 1;
                f.seek(length);
                b = f.readByte();
            } while (b != 10 && length > 0);
            f.setLength(length+1);
            f.close();
            errorLoadingTable = loadTableFromCSV();
        } catch (FileNotFoundException e) {
            println("initPlaybackFileToTable: Unable to locate file : " + playbackData_fname);
        } catch (IOException e) {
            println("initPlaybackFileToTable: Unable to locate file : " + playbackData_fname);
        }
    }

    //If we are still unable to load data into a table from file, exit method
    if (errorLoadingTable) {
        return;
    }

    try {
        int rowCount = playbackData_table.getRowCount();
        int fileDurationInSeconds = round(float(playbackData_table.getRowCount())/getSampleRateSafe());
        println("OpenBCI_GUI: initSystem: loading complete.  " 
                + rowCount 
                + " rows of data, which is " 
                +  fileDurationInSeconds
                + " seconds of EEG data");
        
        //If a playback file has less than one second of data, throw an error using a flag
        if (playbackData_table.getRowCount() <= settings.minNumRowsPlaybackFile) {
            playbackFileIsEmpty = true;
        }
    } catch (NullPointerException e) {
        println("initPlaybackFileToTable: Encountered an error - " + e);
        e.printStackTrace();
    }
}

boolean loadTableFromCSV () {
    try {
        playbackData_table = null;
        playbackData_table = new Table_CSV(playbackData_fname);
        //removing first column of data from data file...the first column is a time index and not eeg data
        playbackData_table.removeColumn(0);
        return false;
    } catch (Exception e) {
        println("initPlaybackFileToTable: Encountered an error while loading " + playbackData_fname);
        return true;
    }
}

void haltLoadingFile(String _filePath) {
    if (systemMode == SYSTEMMODE_POSTINIT) {
        abandonInit = true;
        initSystemButton.setString("START SESSION");
        controlPanel.open();
        haltSystem();
    }
    //Go ahead and remove this file from the Playback History
    JSONObject playbackHistoryJSON = loadJSONObject(userPlaybackHistoryFile);
    JSONArray recentFilesArray = playbackHistoryJSON.getJSONArray("playbackFileHistory");
    removePlaybackFileFromHistory(recentFilesArray, _filePath);
    outputError("Playback file appears empty. Try loading a different file.");
}

//This gets called when a playback file is selected from the Playback History Widget
void reinitializeCoreDataAndFFTBuffer() {
    //println("Data Processing Number of Channels is: " + dataProcessing.nchan);
    dataProcessing.nchan = nchan;
    dataProcessing.fs_Hz = getSampleRateSafe();
    dataProcessing.data_std_uV = new float[nchan];
    dataProcessing.polarity = new float[nchan];
    dataProcessing.newDataToSend = false;
    dataProcessing.avgPowerInBins = new float[nchan][dataProcessing.processing_band_low_Hz.length];
    dataProcessing.headWidePower = new float[dataProcessing.processing_band_low_Hz.length];
    dataProcessing.defineFilters();  //define the filters anyway just so that the code doesn't bomb

    //initialize core data objects
    initCoreDataObjects();
    //verbosePrint("W_Playback: initSystem: -- Init 1 -- " + millis());

    initFFTObjectsAndBuffer();

    //verbosePrint("W_Playback: initSystem: -- Init 2 -- " + millis());

    //Update the number of channels for FFT
    w_fft.fft_points = null;
    w_fft.fft_points = new GPointsArray[nchan];
    w_fft.initializeFFTPlot(ourApplet);
    w_fft.update();

    //Update the number of channels for EMG
    w_emg.motorWidgets = null;
    w_emg.updateEMGMotorWidgets(nchan);

    //Update the number of channels for HeadPlot
    w_headPlot.headPlot = null;
    w_headPlot.updateHeadPlot(nchan);
    
    //Update channelSelect in bandPower and SSVEP widgets
    w_bandPower.bpChanSelect.createCheckList(nchan);
    w_bandPower.activateAllChannels();
    w_ssvep.ssvepChanSelect.createCheckList(nchan);
    w_ssvep.activateDefaultChannels();
}

void savePlaybackFileToHistory(String fileName) {
    int maxNumHistoryFiles = 36;
    if (playbackHistoryFileExists) {
        println("Found user playback history file!");
        savePlaybackHistoryJSON = loadJSONObject(userPlaybackHistoryFile);
        JSONArray recentFilesArray = savePlaybackHistoryJSON.getJSONArray("playbackFileHistory");
        //println("ARRAYSIZE-Check1: " + int(recentFilesArray.size()));
        //Recent file has recentFileNumber=0, and appears at the end of the JSON array
        //check if already in the list, if so, remove from the list
        removePlaybackFileFromHistory(recentFilesArray, playbackData_fname);
        //next, increment fileNumber of all current entries +1
        for (int i = 0; i < recentFilesArray.size(); i++) {
            JSONObject playbackFile = recentFilesArray.getJSONObject(i);
            playbackFile.setInt("recentFileNumber", recentFilesArray.size()-i);
            //println(recentFilesArray.size()-i);
            playbackFile.setString("id", playbackFile.getString("id"));
            playbackFile.setString("filePath", playbackFile.getString("filePath"));
            recentFilesArray.setJSONObject(i, playbackFile);
        }
        //println("ARRAYSIZE-Check2: " + int(recentFilesArray.size()));
        //append selected playback file to position 1 at the end of the JSONArray
        JSONObject mostRecentFile = new JSONObject();
        mostRecentFile.setInt("recentFileNumber", 0);
        mostRecentFile.setString("id", playbackData_ShortName);
        mostRecentFile.setString("filePath", playbackData_fname);
        recentFilesArray.append(mostRecentFile);
        //remove entries greater than max num files
        if (recentFilesArray.size() >= maxNumHistoryFiles) {
            for (int i = 0; i <= recentFilesArray.size()-maxNumHistoryFiles; i++) {
                recentFilesArray.remove(i);
                println("ARRAY INDEX " + i + " REMOVED----");
            }
        }
        //println("ARRAYSIZE-Check3: " + int(recentFilesArray.size()));
        //printArray(recentFilesArray);

        //save the JSON array and file
        savePlaybackHistoryJSON.setJSONArray("playbackFileHistory", recentFilesArray);
        saveJSONObject(savePlaybackHistoryJSON, userPlaybackHistoryFile);

    } else if (!playbackHistoryFileExists) {
        println("Playback history file not found. making a new one.");
        //do this if the file does not exist
        JSONObject newHistoryFile;
        newHistoryFile = new JSONObject();
        JSONArray newHistoryFileArray = new JSONArray();
        //save selected playback file to position 1 in recent file history
        JSONObject mostRecentFile = new JSONObject();
        mostRecentFile.setInt("recentFileNumber", 0);
        mostRecentFile.setString("id", playbackData_ShortName);
        mostRecentFile.setString("filePath", playbackData_fname);
        newHistoryFileArray.setJSONObject(0, mostRecentFile);
        //newHistoryFile.setJSONArray("")

        //save the JSON array and file
        newHistoryFile.setJSONArray("playbackFileHistory", newHistoryFileArray);
        saveJSONObject(newHistoryFile, userPlaybackHistoryFile);

        //now the file exists!
        println("Playback history JSON has been made!");
        playbackHistoryFileExists = true;
    }
}

void removePlaybackFileFromHistory(JSONArray array, String _filePath) {
    //check if already in the list, if so, remove from the list
    for (int i = 0; i < array.size(); i++) {
        JSONObject playbackFile = array.getJSONObject(i);
        //println("CHECKING " + i + " : " + playbackFile.getString("id") + " == " + fileName + " ?");
        if (playbackFile.getString("filePath").equals(_filePath)) {
            array.remove(i);
            //println("REMOVED: " + fileName);
        }
    }
}
