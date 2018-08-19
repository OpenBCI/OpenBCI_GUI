
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    W_playback.pde (ie "Playback")

    Allow user playback control from within GUI system and address #48 and #55 on Github
                       Created: Richard Waltman - August 2018
 */
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class W_playback extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...
  //PlaybackFileBox2 playbackFileBox2;
  Button selectPlaybackFileButton;
  Button widgetTemplateButton;
  int padding = 10;

  private boolean visible = true;
  private boolean updating = true;

  W_playback(PApplet _parent) {
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)
    x = x0;
    y = y0;
    w = w0;
    h = h0;

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    //addDropdown("pbDropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
    //addDropdown("pbDropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
    //addDropdown("pbDropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

    //playbackFileBox2 = new PlaybackFileBox2(x, y, 200, navHeight, 12);
    selectPlaybackFileButton = new Button (x + padding, y + padding*2 + 13, 200, 24, "SELECT PLAYBACK FILE", fontInfo.buttonLabel_size);


    widgetTemplateButton = new Button (x + w/2 + 50, y + h/2, 200, navHeight, "Design Your Own Widget!", 12);
    widgetTemplateButton.setFont(p4, 14);
    widgetTemplateButton.setURL("http://docs.openbci.com/Tutorials/15-Custom_Widgets");
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
      rect(x, y, w, h);
      fill(bgColor);
      textFont(h3, 16);
      textAlign(LEFT, TOP);
      text("PLAYBACK FILE", x + padding, y + padding);
      //println("DRAWING PLAYBACK FILE BOX");
      popStyle();

      pushStyle();
      widgetTemplateButton.draw();
      //playbackFileBox2.draw();
      selectPlaybackFileButton.draw();
      popStyle();
    }
  } //end draw loop

  void screenResized() {
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    widgetTemplateButton.setPos(x + w/2 - widgetTemplateButton.but_dx/2, y + h/2 - widgetTemplateButton.but_dy/2);

    //resize and position the playback file box and button
    //playbackFileBox2.screenResized(x + padding, y + padding*2 + 13);
    selectPlaybackFileButton.setPos(x + padding, y + padding*2 + 13);

    //selectPlaybackFileButton.setPos(x + padding, y + padding*2 + 13);


  }

  void mousePressed() {
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    if (selectPlaybackFileButton.isMouseHere()) {
      selectPlaybackFileButton.setIsActive(true);
      selectPlaybackFileButton.wasPressed = true;
    }

    //put your code here...
    if(widgetTemplateButton.isMouseHere()) {
      widgetTemplateButton.setIsActive(true);
    }

  }

  void mouseReleased() {
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(widgetTemplateButton.isActive && widgetTemplateButton.isMouseHere()) {
      widgetTemplateButton.goToURL();
    }
    widgetTemplateButton.setIsActive(false);

    if (selectPlaybackFileButton.isMouseHere() && selectPlaybackFileButton.wasPressed) {
      //playbackData_fname = "N/A"; //reset the filename variable
      has_processed = false; //reset has_processed variable
      output("select a file for playback");
      selectInput("Select a pre-recorded file for playback:", "playbackSelectedWidgetButton");
    }
    selectPlaybackFileButton.setIsActive(false);

  }

  //add custom functions here
  void customFunction() {
    //this is a fake function... replace it with something relevant to this widget

  }

  /*
  class PlaybackFileBox2 {
    int x, y, w, h, padding; //size and position

    PlaybackFileBox2(int _x, int _y, int _w, int _h, int _padding) {
      x = _x;
      y = _y;
      w = _w;
      h = 67;
      padding = _padding;

      selectPlaybackFileButton = new Button (x + padding, y + padding*2 + 13, w - padding*2, 24, "SELECT PLAYBACK FILE", fontInfo.buttonLabel_size);
    }

    public void update() {
    }

    public void draw() {

      //drawPlaybackFileBox(x,y,w,h);
      selectPlaybackFileButton.draw();
      // chanButton16.draw();
    }

    public void screenResized(int _x, int _y) {
      selectPlaybackFileButton.setPos(_x,_y);
      drawPlaybackFileBox(_x,_y,w,h);
    }

    public void drawPlaybackFileBox(int x, int y, int w, int h) {
      if(visible && settingsLoadedCheck) {
        pushStyle();
        fill(boxColor);
        stroke(boxStrokeColor);
        strokeWeight(1);
        rect(x, y, w, h);
        fill(bgColor);
        textFont(h3, 16);
        textAlign(LEFT, TOP);
        text("PLAYBACK FILE", x + padding, y + padding);
        popStyle();
      }
    }
  };
  */

};

//GLOBAL FUNCTIONS BELOW THIS LINE

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void pbDropdown1(int n) {
  println("Item " + (n+1) + " selected from Dropdown 1");
  if(n==0) {
    //do this
  } else if(n==1) {
    //do this instead
  }
  closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}

void pbDropdown2(int n) {
  println("Item " + (n+1) + " selected from Dropdown 2");
  closeAllDropdowns();
}

void pbDropdown3(int n) {
  println("Item " + (n+1) + " selected from Dropdown 3");
  closeAllDropdowns();
}

void playbackSelectedWidgetButton(File selection) {
  if (selection == null) {
    println("W_Playback: playbackSelected: Window was closed or the user hit cancel.");
  } else {
    println("W_Playback: playbackSelected: User selected " + selection.getAbsolutePath());
    output("You have selected \"" + selection.getAbsolutePath() + "\" for playback.");
    playbackData_fname = selection.getAbsolutePath();

    //if a new file was selected, process it
    if (playbackData_fname != "N/A" && systemMode == SYSTEMMODE_POSTINIT) {
      processNewPlaybackFile();
    }

    //Determine the number of channels and updateToNChan()
    determineNumChanFromFile(playbackData_table);

    //Output new playback settings to GUI as success
    outputSuccess("You have selected \""
    + selection.getName() + "\" for playback. "
    + str(nchan) + " channels found.");
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

  /*
  if (systemMode == SYSTEMMODE_POSTINIT) {
    //Re-initialize the system
    initSystemFromPlaybackWidget();
  }
  */
}

void initPlaybackFileToTable() {
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

//This needs lots of work
void initSystemFromPlaybackWidget() {
  println();
  println();
  println("=================================================");
  println("||          RE-INITIALIZING SYSTEM             ||");
  println("=================================================");
  println();

  verbosePrint("W_Playback: initSystem: -- Init 0 -- " + millis());
  timeOfInit = millis(); //store this for timeout in case init takes too long
  verbosePrint("timeOfInit = " + timeOfInit);

  //prepare data variables
  //verbosePrint("W_Playback: initSystem: Preparing data variables...");
  //initPlaybackFileToTable(); //found in W_Playback.pde

  verbosePrint("W_Playback: initSystem: Initializing core data objects");

  // Nfft = getNfftSafe();
  nDataBackBuff = 3*(int)getSampleRateSafe();
  dataPacketBuff = new DataPacket_ADS1299[nDataBackBuff]; // call the constructor here
  nPointsPerUpdate = int(round(float(update_millis) * getSampleRateSafe()/ 1000.f));
  dataBuffX = new float[(int)(dataBuff_len_sec * getSampleRateSafe())];
  dataBuffY_uV = new float[nchan][dataBuffX.length];
  dataBuffY_filtY_uV = new float[nchan][dataBuffX.length];
  yLittleBuff = new float[nPointsPerUpdate];
  yLittleBuff_uV = new float[nchan][nPointsPerUpdate]; //small buffer used to send data to the filters
  auxBuff = new float[3][nPointsPerUpdate];
  accelerometerBuff = new float[3][500]; // 500 points
  for (int i=0; i<n_aux_ifEnabled; i++) {
    for (int j=0; j<accelerometerBuff[0].length; j++) {
      accelerometerBuff[i][j] = 0;
    }
  }
  //data_std_uV = new float[nchan];
  data_elec_imp_ohm = new float[nchan];
  is_railed = new DataStatus[nchan];
  for (int i=0; i<nchan; i++) is_railed[i] = new DataStatus(threshold_railed, threshold_railed_warn);
  for (int i=0; i<nDataBackBuff; i++) {
    dataPacketBuff[i] = new DataPacket_ADS1299(nchan, n_aux_ifEnabled);
  }
  dataProcessing = new DataProcessing(nchan, getSampleRateSafe());
  dataProcessing_user = new DataProcessing_User(nchan, getSampleRateSafe());

  //initialize the data
  prepareData(dataBuffX, dataBuffY_uV, getSampleRateSafe());

  verbosePrint("W_Playback: initSystem: -- Init 1 -- " + millis());
  verbosePrint("W_Playback: initSystem: Initializing FFT data objects");

  //initialize the FFT objects
  for (int Ichan=0; Ichan < nchan; Ichan++) {
    // verbosePrint("Init FFT Buff – " + Ichan);
    fftBuff[Ichan] = new FFT(getNfftSafe(), getSampleRateSafe());
  }  //make the FFT objects

  printArray(fftBuff);

  //Attempt initialization. If error, print to console and exit function.
  //Fixes GUI crash when trying to load outdated recordings
  try {
    initializeFFTObjects(fftBuff, dataBuffY_uV, getNfftSafe(), getSampleRateSafe());
  } catch (ArrayIndexOutOfBoundsException e) {
    //e.printStackTrace();
    outputError("Playback file load error. Try using a more recent recording.");
    return;
  }

  verbosePrint("OpenBCI_GUI: initSystem: -- Init 2 -- " + millis());
}
