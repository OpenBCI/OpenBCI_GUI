
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
  PlaybackFileBox2 playbackFileBox2;
  Button selectPlaybackFileWidget;
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
    addDropdown("pbDropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
    addDropdown("pbDropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
    addDropdown("pbDropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

    playbackFileBox2 = new PlaybackFileBox2(x, y, 200, navHeight, 12);

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

    //put your code here...

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
      playbackFileBox2.draw();

      popStyle();
    }
  } //end draw loop

  void screenResized() {
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    widgetTemplateButton.setPos(x + w/2 - widgetTemplateButton.but_dx/2, y + h/2 - widgetTemplateButton.but_dy/2);

    //resize and position the playback file box and button
    playbackFileBox2.screenResized(x + padding, y + padding*2 + 13);

    //selectPlaybackFileWidget.setPos(x + padding, y + padding*2 + 13);


  }

  void mousePressed() {
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    if (selectPlaybackFileWidget.isMouseHere()) {
      selectPlaybackFileWidget.setIsActive(true);
      selectPlaybackFileWidget.wasPressed = true;
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

    if (selectPlaybackFileWidget.isMouseHere() && selectPlaybackFileWidget.wasPressed) {
      //playbackData_fname = "N/A"; //reset the filename variable
      has_processed = false; //reset has_processed variable
      output("select a file for playback");
      selectInput("Select a pre-recorded file for playback:", "playbackSelectedFromWidget");
    }
    selectPlaybackFileWidget.setIsActive(false);

  }

  //add custom functions here
  void customFunction() {
    //this is a fake function... replace it with something relevant to this widget

  }

  class PlaybackFileBox2 {
    int x, y, w, h, padding; //size and position

    PlaybackFileBox2(int _x, int _y, int _w, int _h, int _padding) {
      x = _x;
      y = _y;
      w = _w;
      h = 67;
      padding = _padding;

      selectPlaybackFileWidget = new Button (x + padding, y + padding*2 + 13, w - padding*2, 24, "SELECT PLAYBACK FILE", fontInfo.buttonLabel_size);
    }

    public void update() {
    }

    public void draw() {

      //drawPlaybackFileBox(x,y,w,h);
      selectPlaybackFileWidget.draw();
      // chanButton16.draw();
    }

    public void screenResized(int _x, int _y) {
      selectPlaybackFileWidget.setPos(_x,_y);
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

void playbackSelectedFromWidget(File selection) {
  if (selection == null) {
    println("DataLogging: playbackSelected: Window was closed or the user hit cancel.");
  } else {
    println("DataLogging: playbackSelected: User selected " + selection.getAbsolutePath());
    output("You have selected \"" + selection.getAbsolutePath() + "\" for playback.");
    playbackData_fname = selection.getAbsolutePath();

    //if a new file was selected
    if (playbackData_fname != "N/A" && systemMode == SYSTEMMODE_POSTINIT) {
      //Fix issue for processing successive playback files
      indices = 0;
      hasRepeated = false;
      has_processed = false;
      w_timeSeries.scrollbar.skipToStartButtonAction(); //sets scrollbar to 0

      //initialize playback file
      initPlaybackFile();

      //try to process the new playback file
      if (has_processed = false) {
        try {
          process_input_file();
        } catch(Exception e) {
          isOldData = true;
          output("Error processing timestamps, are you using old data?");
        }
      }

    }
  }
}

void initPlaybackFile() {
  //open and load the data file
  println("OpenBCI_GUI: initSystem: loading playback data from " + playbackData_fname);
  try {
    playbackData_table = new Table_CSV(playbackData_fname);
    playbackData_table.removeColumn(0);
  } catch (Exception e) {
    println("OpenBCI_GUI: initSystem: could not open file for playback: " + playbackData_fname);
    println("   : quitting...");
    hub.killAndShowMsg("Could not open file for playback: " + playbackData_fname);
  }
  println("OpenBCI_GUI: initSystem: loading complete.  " + playbackData_table.getRowCount() + " rows of data, which is " + round(float(playbackData_table.getRowCount())/getSampleRateSafe()) + " seconds of EEG data");
  //removing first column of data from data file...the first column is a time index and not eeg data
}
