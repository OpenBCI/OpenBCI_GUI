
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    W_playback.pde (ie "Playback")

    Allow user playback control from within GUI system and address #48 and #55 on Github
                       Created: Richard Waltman - August 2018
 */
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class W_playback extends Widget {

  //allow access to dataProcessing
  DataProcessing dataProcessing;
  //Set up variables for Playback widget
  Button selectPlaybackFileButton;
  Button[] selectRecentFileButtons = new Button[10];
  int playbackNumButtonsToDraw = 1;
  String[] shortFileNames = new String[10];
  String[] longFilePaths = new String[10];
  //Used for spacing
  int padding = 10;

  private boolean visible = true;
  private boolean updating = true;

  W_playback(PApplet _parent) {
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //make a dropdown menu to select the rang
    String[] temp = rangePlaybackStringList.array();
    addDropdown("pbRecentRange", "Range", Arrays.asList(temp), 0);
    //make a button to load new files
    selectPlaybackFileButton = new Button (
      x + w/2 - (padding*2),
      y - navHeight + 2,
      200,
      navHeight - 6,
      "SELECT PLAYBACK FILE",
      fontInfo.buttonLabel_size);
    //make ten buttons for recent playback with blank text
    for (int i = 0; i < 10; i++) { //playbackNumButtonsToDraw
      selectRecentFileButtons[i] = new Button (
        x + (padding*4),
        y + int(i * (h/10)) + padding/10,
        int(w/2.4) - padding*2,
        30 - padding/10,
        " ",
        30);
        selectRecentFileButtons[i].setFont(p4,16);
        selectRecentFileButtons[i].setColorNotPressed(color(225,225,225));
    }

    updatePlaybackWidgetButtons();
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
    updatePlaybackWidgetButtons();
  }

  void draw() {
    //Only draw if the widget is visible and User settings have been loaded
    //settingsLoadedCheck is set to true after default settings are saved between Init checkpoints 4 and 5
    if(visible && settingsLoadedCheck) {
      super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

      //x,y,w,h are the positioning variables of the Widget class
      pushStyle();
      fill(boxColor);
      stroke(boxStrokeColor);
      strokeWeight(1);
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

      for (int i = 0; i < playbackNumButtonsToDraw; i++) {
        selectRecentFileButtons[i].draw();
      }
      popStyle();
    }
  } //end draw loop

  void screenResized() {
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //resize and position the playback file box and button
    selectPlaybackFileButton.setPos(x + w/2 - (padding*2), y - navHeight + 2);

    for (int i = 0; i < playbackNumButtonsToDraw; i++) { //playbackNumButtonsToDraw
      selectRecentFileButtons[i].setPos(
        x + (padding*4),
        y + int(i * (h/10)) + padding/10);
      }
  } //end screen Resized

  void mousePressed() {
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //check if mouse is over the select playback file button
    if (selectPlaybackFileButton.isMouseHere()) {
      selectPlaybackFileButton.setIsActive(true);
      //selectPlaybackFileButton.wasPressed = true;
    }

    //check if mouse is over the recent file buttons
    for (int i = 0; i < playbackNumButtonsToDraw ;i++) {
      if (selectRecentFileButtons[i].isMouseHere()) {
        selectRecentFileButtons[i].setIsActive(true);
      }
    }
  } // end mouse Pressed

  void mouseReleased() {
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //check if user has clicked on one of the recent file buttons
    for (int i = 0; i < playbackNumButtonsToDraw; i++) { //playbackNumButtonsToDraw
      if (selectRecentFileButtons[i].isMouseHere() && selectRecentFileButtons[i].isActive) {
        //load the playback file using the full file path
        //String fileToLoad = longFilePaths[i];
        //println("FILE PATH TO LOAD: " + longFilePaths[i] + " && Shrt file pth 2 ld: " + shortFileNames[i]);
        recentFileSelectedButton(longFilePaths[i], shortFileNames[i]);
      }
    }
    //make the button show it is inactive
    for (int i = 0; i < playbackNumButtonsToDraw; i++) {
      selectRecentFileButtons[i].setIsActive(false);
    }

    //check if user has clicked on the select playback file button
    if (selectPlaybackFileButton.isMouseHere() && selectPlaybackFileButton.isActive) {
      output("select a file for playback");
      selectInput("Select a pre-recorded file for playback:", "playbackSelectedWidgetButton");
    }
    selectPlaybackFileButton.setIsActive(false);
  } // end mouse Released

  void updatePlaybackWidgetButtons() {
    //Used to show 10 of 100 latest playback files
    int numFilesToShow = 10;
    //Load the JSON array for playback history
    if (playbackHistoryFileExists) {
      try {
        loadPlaybackHistoryJSON = loadJSONObject(userPlaybackHistoryFile);
        JSONArray loadPlaybackHistoryJSONArray = loadPlaybackHistoryJSON.getJSONArray("playbackFileHistory");
        //remove entries greater than 100
        if (loadPlaybackHistoryJSONArray.size() >= 100) {
          for (int i = 0; i < loadPlaybackHistoryJSONArray.size()-100; i++) {
            loadPlaybackHistoryJSONArray.remove(i);
          }
        }
        if (loadPlaybackHistoryJSONArray.size() <= 10) {
          //println("History Size = " + loadPlaybackHistoryJSONArray.size());
          //fileSelectTabsInt changes when user selects playback range from dropdown
          numFilesToShow = loadPlaybackHistoryJSONArray.size();
          playbackNumButtonsToDraw = loadPlaybackHistoryJSONArray.size();
          fileSelectTabsInt = 1;
        } else if (rangePlaybackSelected == 0 && loadPlaybackHistoryJSONArray.size() > 10) {
          numFilesToShow = 10;
          playbackNumButtonsToDraw = 10;
        } else if (rangePlaybackSelected > 0
        && rangePlaybackSelected == maxRangePlaybackSelect) {
          //fileSelectTabsInt changes when user selects playback range from dropdown
          numFilesToShow = fileSelectTabsInt + loadPlaybackHistoryJSONArray.size()%10; //if set to max, show the remainer only
          playbackNumButtonsToDraw = loadPlaybackHistoryJSONArray.size()%10; //and draw the remainder
        //} else if (loadPlaybackHistoryJSONArray.size()%10 == 0) {
        //  numFilesToShow = 10;
        //  playbackNumButtonsToDraw = 10;
        } else if (rangePlaybackSelected > 0
        && rangePlaybackSelected < maxRangePlaybackSelect) {
          numFilesToShow = fileSelectTabsInt + 10;
          playbackNumButtonsToDraw = 10;
        }
        //println ("min = " + int(loadPlaybackHistoryJSONArray.size()-fileSelectTabsInt)
        //+ " | max = " + int(loadPlaybackHistoryJSONArray.size() - numFilesToShow));

        //for all files that appear in JSON array in increments of 10
        //println(fileSelectTabsInt + " " + numFilesToShow);
        //println("Array Size:" + loadPlaybackHistoryJSONArray.size());
        int currentFileNameToDraw = 0;
        if (loadPlaybackHistoryJSONArray.size() > 1) {
          for (int i = (loadPlaybackHistoryJSONArray.size()-fileSelectTabsInt); //minimum
           i >= (loadPlaybackHistoryJSONArray.size() - numFilesToShow);  //maximum
           i--) { //go through array in reverse since using append
            JSONObject loadRecentPlaybackFile = loadPlaybackHistoryJSONArray.getJSONObject(i);
            int fileNumber = loadRecentPlaybackFile.getInt("recentFileNumber");
            String shortFileName = loadRecentPlaybackFile.getString("id");
            String longFilePath = loadRecentPlaybackFile.getString("filePath");
            //store to arrays to set recent playback buttons text and function
            shortFileNames[currentFileNameToDraw] = shortFileName;
            longFilePaths[currentFileNameToDraw] = longFilePath;
            //Set up the string that will be displayed for each recent file
            /*
            int digitPadding = 0;
            if (fileNumber == 100) {
              digitPadding = 3;
            } else if (fileNumber >= 10 && fileNumber <= 99) {
              digitPadding = 2;
            } else if (fileNumber <= 9) {
              digitPadding = 1;
            }
            String fileNumberString = nfs(fileNumber, digitPadding) + ". ";
            */
            //Draw the text for each fileName

            //printArray("short file names : " + shortFileNames);
            //set to visisble and change text
            for (int j = 0; j < playbackNumButtonsToDraw; j++) {
              selectRecentFileButtons[j].setString(shortFileNames[j]);
            }

            currentFileNameToDraw++;
            if (currentFileNameToDraw > 9) currentFileNameToDraw = 9;
          }
        } else { //if there is only 1 file in the playback history file...
          JSONObject loadRecentPlaybackFile = loadPlaybackHistoryJSONArray.getJSONObject(0);
          int fileNumber = loadRecentPlaybackFile.getInt("recentFileNumber");
          String shortFileName = loadRecentPlaybackFile.getString("id"); //used to display in playback widget
          String longFilePath = loadRecentPlaybackFile.getString("filePath"); //used to load file
          //store to arrays to set recent playback buttons text and function
          shortFileNames[currentFileNameToDraw] = shortFileName;
          longFilePaths[currentFileNameToDraw] = longFilePath;
          //set the text of the first button
          selectRecentFileButtons[0].setString(shortFileNames[0]);
          //increment which file name to draw
          currentFileNameToDraw++;
        }

      } catch (NullPointerException e) {
        println("PlaybackWidget: Playback history file not found.");
      }
    } else {
      println("PlaybackWidget: Found " + playbackHistoryFileExists); //playback History File Exists = false;
    }
  }
}; //end Playback widget class

//////////////////////////////////////
// GLOBAL FUNCTIONS BELOW THIS LINE //
//////////////////////////////////////
//Activated when an item from the corresponding dropdown is selected
void pbRecentRange(int n) {
  println("Item " + (n+1) + " selected from Dropdown 1");
  if(n==0) {
    fileSelectTabsInt = 1;
  } else {
    fileSelectTabsInt = 10 * n;
  }
  rangePlaybackSelected = n;
  closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}

//Activated when user selects a file using the load playback file button
void playbackSelectedWidgetButton(File selection) {
  if (selection == null) {
    println("W_Playback: playbackSelected: Window was closed or the user hit cancel.");
  } else {
    println("W_Playback: playbackSelected: User selected " + selection.getAbsolutePath());
    //output("You have selected \"" + selection.getAbsolutePath() + "\" for playback.");
    playbackData_fname = selection.getAbsolutePath();
    playbackData_ShortName = selection.getName();

    //If a new file was selected, process it so we can set variables first.
    processNewPlaybackFile();

    //Determine the number of channels and updateToNChan()
    determineNumChanFromFile(playbackData_table);

    //Print success message
    outputSuccess("You have selected \""
    + selection.getName() + "\" for playback. "
    + str(nchan) + " channels found.");

    String nameToAdd = selection.getName();
    //add playback file that was processed to the JSON history
    savePlaybackFileToHistory(nameToAdd);

    //Tell TS widget that the number of channel bars needs to be updated
    w_timeSeries.updateNumberOfChannelBars = true;

    //Reinitialize core data, EMG, FFT, and Headplot number of channels
    reinitializeCoreDataAndFFTBuffer();

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
    int numToResize = w_playback.playbackNumButtonsToDraw;
    if (w_playback.playbackNumButtonsToDraw == 10) {
      numToResize = 9;
    }

    for (int i = 0; i <= numToResize; i++) { //playbackNumButtonsToDraw
      w_playback.selectRecentFileButtons[i].setPos(
        w_playback.x + (w_playback.padding*4),
        w_playback.y + int(i * (w_playback.h/10)) + w_playback.padding/10);
      }
  }
}

//Activated when user selects a file using the recent file buttons
void recentFileSelectedButton(String fullPath, String shortName) {
  //output("You have selected \"" + selection.getAbsolutePath() + "\" for playback.");
  playbackData_fname = fullPath;
  playbackData_ShortName = shortName;

  //If a new file was selected, process it so we can set variables first.
  processNewPlaybackFile();

  //Determine the number of channels and updateToNChan()
  determineNumChanFromFile(playbackData_table);

  //Print success message
  outputSuccess("You have selected \""
  + playbackData_ShortName + "\" for playback. "
  + str(nchan) + " channels found.");

  //add playback file that was processed to the JSON history
  savePlaybackFileToHistory(playbackData_ShortName);

  //Tell TS widget that the number of channel bars needs to be updated
  w_timeSeries.updateNumberOfChannelBars = true;

  //Reinitialize core data, EMG, FFT, and Headplot number of channels
  reinitializeCoreDataAndFFTBuffer();

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
  int numToResize = w_playback.playbackNumButtonsToDraw;
  if (w_playback.playbackNumButtonsToDraw == 10) {
    numToResize = 9;
  }

  for (int i = 0; i <= numToResize; i++) { //playbackNumButtonsToDraw
    w_playback.selectRecentFileButtons[i].setPos(
      w_playback.x + (w_playback.padding*4),
      w_playback.y + int(i * (w_playback.h/10)) + w_playback.padding/10);
    }
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

void initPlaybackFileToTable() { //also used in OpenBCI_GUI.pde on system start
  //open and load the data file
  println("OpenBCI_GUI: initSystem: loading playback data from " + playbackData_fname);
  try {
    playbackData_table = new Table_CSV(playbackData_fname);
    //removing first column of data from data file...the first column is a time index and not eeg data
    playbackData_table.removeColumn(0);
  } catch (Exception e) {
    println("OpenBCI_GUI: initSystem: could not open file for playback: " + playbackData_fname);
    println("   : quitting...");
    hub.killAndShowMsg("Could not open file for playback: " + playbackData_fname);
  }

  println("OpenBCI_GUI: initSystem: loading complete.  " + playbackData_table.getRowCount() + " rows of data, which is " + round(float(playbackData_table.getRowCount())/getSampleRateSafe()) + " seconds of EEG data");
}


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

}

void savePlaybackFileToHistory(String fileNameToAdd) {

  int maxNumHistoryFiles = 100;
  if (playbackHistoryFileExists) {
    println("Found user playback file!");
    //do this if the file exists
    savePlaybackHistoryJSON = loadJSONObject(userPlaybackHistoryFile);
    JSONArray recentFilesArray = savePlaybackHistoryJSON.getJSONArray("playbackFileHistory");
    //w_playback.oldArraySize = savePlaybackHistoryJSON.size();

    //move all current entries +1
    for (int i = 0; i < recentFilesArray.size(); i++) {
      JSONObject playbackFile = recentFilesArray.getJSONObject(i);
      playbackFile.setInt("recentFileNumber", recentFilesArray.size()-(i-1));
      playbackFile.setString("id", playbackFile.getString("id"));
      playbackFile.setString("filePath", playbackFile.getString("filePath"));
      recentFilesArray.setJSONObject(i, playbackFile);
    }
    //save selected playback file to position 1 in recent file history
    JSONObject mostRecentFile = new JSONObject();
    mostRecentFile.setInt("recentFileNumber", 1);
    mostRecentFile.setString("id", playbackData_ShortName);
    mostRecentFile.setString("filePath", playbackData_fname);
    recentFilesArray.append(mostRecentFile);
    //remove entries greater than 100
    if (recentFilesArray.size() >= maxNumHistoryFiles) {
      for (int i = 0; i <= recentFilesArray.size()-100; i++) {
        recentFilesArray.remove(i);
      }
    }
    //printArray(recentFilesArray);
    //newPlaybackArraySize = recentFilesArray.size();

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
    mostRecentFile.setInt("recentFileNumber", 1);
    mostRecentFile.setString("id", fileNameToAdd);
    mostRecentFile.setString("filePath", playbackData_fname);
    newHistoryFileArray.setJSONObject(0, mostRecentFile);
    //newHistoryFile.setJSONArray("")

    //save the JSON array and file
    newHistoryFile.setJSONArray("playbackFileHistory", newHistoryFileArray);
    saveJSONObject(newHistoryFile, userPlaybackHistoryFile);

    //set the dropdown menu array for range select
    rangePlaybackStringList.append(rangeSelectStringArray[0]);

    //now the file exists!
    println("Playback history JSON has been made!");
    playbackHistoryFileExists = true;
  }

  //make sure the dropdown list shows the correct ranges
  //w_playback.maxRangePlaybackSelect = recentFilesArray.size()/10;
  /*
  if (newArraySize > oldArraySize && oldArraySize%10 >= 1) {
    String itemToAdd = rangeSelectStringArray[maxRangePlaybackSelect];
    cp5.get(ScrollableList.class, "pbRecentRange").clear();
    cp5.get(ScrollableList.class, "pbRecentRange").addItem(itemToAdd, "pbRecentRange");
  }
  */
}
