
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
//    W_playback.pde (ie "Playback History")
//
//    Allow user to load playback files from within GUI without having to restart the system
//                       Created: Richard Waltman - August 2018
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import java.io.FileReader;

ControlP5 cp5_playback;

//Used mostly in W_playback.pde
JSONObject savePlaybackHistoryJSON;
JSONObject loadPlaybackHistoryJSON;
final String userPlaybackHistoryFile = DirectoryManager.getSettingsPath()+"UserPlaybackHistory.json";
boolean playbackHistoryFileExists = false;
String playbackData_ShortName;
boolean recentPlaybackFilesHaveUpdated = false;

class W_playback extends Widget {
    //allow access to dataProcessing
    DataProcessing dataProcessing;
    //Set up variables for Playback widget
    Button_obci selectPlaybackFileButton;
    MenuList playbackMenuList;
    //Used for spacing
    int padding = 10;

    private boolean visible = true;
    private boolean menuHasUpdated = false;
    private boolean menuListIsLocked = false;

    W_playback(PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //make a button to load new files
        selectPlaybackFileButton = new Button_obci (
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
        playbackMenuList = new MenuList(cp5_playback, "playbackMenuList", initialWidth, h - padding*2, p3);
        playbackMenuList.setPosition(x + padding/2, y + 2);
        playbackMenuList.setSize(initialWidth, h - padding*2);
        playbackMenuList.scrollerLength = 40;
        cp5_playback.get(MenuList.class, "playbackMenuList").setVisible(true);
        cp5_playback.setAutoDraw(false);
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean _visible) {
        visible = _visible;
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
        //Only draw if the widget is visible
        if(visible) {
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

//Called when user selects a playback file from controlPanel dialog box
void playbackFileSelected(File selection) {
    if (selection == null) {
        println("DataLogging: playbackSelected: Window was closed or the user hit cancel.");
    } else {
        println("DataLogging: playbackSelected: User selected " + selection.getAbsolutePath());
        //Set the name of the file
        playbackFileSelected(selection.getAbsolutePath(), selection.getName());
    }
}


//Activated when user selects a file using the "Select Playback File" button in PlaybackHistory
void playbackSelectedWidgetButton(File selection) {
    if (selection == null) {
        println("W_Playback: playbackSelected: Window was closed or the user hit cancel.");
    } else {
        println("W_Playback: playbackSelected: User selected " + selection.getAbsolutePath());
        if (playbackFileSelected(selection.getAbsolutePath(), selection.getName())) {
            // restart the session with the new file
            requestReinit();
        }
    }
}

//Activated when user selects a file using the recent file MenuList
void userSelectedPlaybackMenuList (String filePath, int listItem) {
    if (new File(filePath).isFile()) {
        playbackFileFromList(filePath, listItem);
        // restart the session with the new file
        requestReinit();
    } else {
        verbosePrint("Playback: " + filePath);
        outputError("Playback: Selected file does not exist. Try another file or clear settings to remove this entry.");
    }
}

//Called when user selects a playback file from a list
void playbackFileFromList (String longName, int listItem) {
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
}

//Handles the work for the above cases
boolean playbackFileSelected (String longName, String shortName) {
    playbackData_fname = longName;
    playbackData_ShortName = shortName;
    //Process the playback file, check if SD card file or something else
    try {
        BufferedReader brTest = new BufferedReader(new FileReader(longName));
        String line = brTest.readLine();
        if (line.equals("%OpenBCI Raw EEG Data")) {
            verbosePrint("PLAYBACK: Found OpenBCI Header in File!");
            sdData_fname = "N/A";
            for (int i = 0; i < 3; i++) {
                line = brTest.readLine();
                verbosePrint("PLAYBACK: " + line);
            }
            if (!line.startsWith("%Board")) {
                playbackData_fname = "N/A";
                playbackData_ShortName = "N/A";
                outputError("Found GUI v4 or earlier file. Please convert this file using the provided Python script.");
                PopupMessage msg = new PopupMessage("GUI v4 to v5 File Converter", "Found GUI v4 or earlier file. Please convert this file using the provided Python script. Press the button below to access this open-source fix.", "LINK", "https://github.com/OpenBCI/OpenBCI_GUI/tree/development/tools");
                return false;
            }    
        } else if (line.equals("%STOP AT")) {
            verbosePrint("PLAYBACK: Found SD File Header in File!");
            playbackData_fname = "N/A";
            sdData_fname = longName;
        } else {
            outputError("ERROR: Tried to load an unsupported file for playback! Please try a valid file.");
            playbackData_fname = "N/A";
            playbackData_ShortName = "N/A";
            sdData_fname = "N/A";   
            return false;
        }
    } catch (FileNotFoundException e) {
        e.printStackTrace();
        return false;
    } catch (IOException e) {
        e.printStackTrace();
        return false;
    }

    //Output new playback settings to GUI as success
    outputSuccess("You have selected \""
    + shortName + "\" for playback.");

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
    return true;
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
