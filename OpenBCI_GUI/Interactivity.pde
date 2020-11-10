
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  This file contains all key commands for interactivity with GUI & OpenBCI
//  Created by Chip Audette, Joel Murphy, & Conor Russomanno
//  - Extracted from OpenBCI_GUI because it was getting too klunky
//  - Refactored Nov. 2020 - Richard Waltman
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//interpret a keypress...the key pressed comes in as "key"
synchronized void keyPressed() {
    // don't allow key presses until setup is complete and the UI is initialized
    if (!setupComplete) {
        return;
    }

    //note that the Processing variable "key" is the keypress as an ASCII character
    //note that the Processing variable "keyCode" is the keypress as a JAVA keycode.  This differs from ASCII
    //println("OpenBCI_GUI: keyPressed: key = " + key + ", int(key) = " + int(key) + ", keyCode = " + keyCode);

    boolean anyActiveTextfields = isNetworkingTextActive() || textFieldIsActive;

    if(!controlPanel.isOpen && !anyActiveTextfields){ //don't parse the key if the control panel is open
        if (settings.expertModeToggle || key == ' ') { //Check if Expert Mode is On or Spacebar has been pressed
            if ((int(key) >=32) && (int(key) <= 126)) {  //32 through 126 represent all the usual printable ASCII characters
                parseKey(key);
            }
        }
    }

    if(key==27){
        key=0; //disable 'esc' quitting program
    }
}

void parseKey(char val) {
    //assumes that val is a usual printable ASCII character (ASCII 32 through 126)
    switch (val) {
        case ' ':
            // space to start/stop the stream
            topNav.stopButtonWasPressed();
            break;
        case ',':
            drawContainers = !drawContainers;
            break;
        case '{':
            if(colorScheme == COLOR_SCHEME_DEFAULT){
                colorScheme = COLOR_SCHEME_ALTERNATIVE_A;
            } else if(colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
                colorScheme = COLOR_SCHEME_DEFAULT;
            }
            topNav.updateNavButtonsBasedOnColorScheme();
            println("Changing color scheme.");
            break;

        //deactivate channels 1-16
        case '1':
            currentBoard.setEXGChannelActive(1-1, false);
            break;
        case '2':
            currentBoard.setEXGChannelActive(2-1, false);
            break;
        case '3':
            currentBoard.setEXGChannelActive(3-1, false);
            break;
        case '4':
            currentBoard.setEXGChannelActive(4-1, false);
            break;
        case '5':
            currentBoard.setEXGChannelActive(5-1, false);
            break;
        case '6':
            currentBoard.setEXGChannelActive(6-1, false);
            break;
        case '7':
            currentBoard.setEXGChannelActive(7-1, false);
            break;
        case '8':
            currentBoard.setEXGChannelActive(8-1, false);
            break;
        case 'q':
            currentBoard.setEXGChannelActive(9-1, false);
            break;
        case 'w':
            currentBoard.setEXGChannelActive(10-1, false);
            break;
        case 'e':
            currentBoard.setEXGChannelActive(11-1, false);
            break;
        case 'r':
            currentBoard.setEXGChannelActive(12-1, false);
            break;
        case 't':
            currentBoard.setEXGChannelActive(13-1, false);
            break;
        case 'y':
            currentBoard.setEXGChannelActive(14-1, false);
            break;
        case 'u':
            currentBoard.setEXGChannelActive(15-1, false);
            break;
        case 'i':
            currentBoard.setEXGChannelActive(16-1, false);
            break;

        //activate channels 1-16
        case '!':
            currentBoard.setEXGChannelActive(1-1, true);
            break;
        case '@':
            currentBoard.setEXGChannelActive(2-1, true);
            break;
        case '#':
            currentBoard.setEXGChannelActive(3-1, true);
            break;
        case '$':
            currentBoard.setEXGChannelActive(4-1, true);
            break;
        case '%':
            currentBoard.setEXGChannelActive(5-1, true);
            break;
        case '^':
            currentBoard.setEXGChannelActive(6-1, true);
            break;
        case '&':
            currentBoard.setEXGChannelActive(7-1, true);
            break;
        case '*':
            currentBoard.setEXGChannelActive(8-1, true);
            break;
        case 'Q':
            currentBoard.setEXGChannelActive(9-1, true);
            break;
        case 'W':
            currentBoard.setEXGChannelActive(10-1, true);
            break;
        case 'E':
            currentBoard.setEXGChannelActive(11-1, true);
            break;
        case 'R':
            currentBoard.setEXGChannelActive(12-1, true);
            break;
        case 'T':
            currentBoard.setEXGChannelActive(13-1, true);
            break;
        case 'Y':
            currentBoard.setEXGChannelActive(14-1, true);
            break;
        case 'U':
            currentBoard.setEXGChannelActive(15-1, true);
            break;
        case 'I':
            currentBoard.setEXGChannelActive(16-1, true);
            break;

        //other controls
        case 's':
            stopRunning();
            break;

        case 'b':
            startRunning();
            break;

        ///////////////////// Save User settings lowercase n
        case 'n':
            println("Save key pressed!");
            settings.save(settings.getPath("User", eegDataSource, nchan));
            outputSuccess("Settings Saved! The GUI will now load with these settings. Click \"Default\" to revert to factory settings.");
            break;

        ///////////////////// Load User settings uppercase N
        case 'N':
            println("Load key pressed!");
            settings.loadKeyPressed();
            break;

        case '?':
            if(currentBoard instanceof BoardCyton) {
                ((BoardCyton)currentBoard).printRegisters();
            }
            break;

        case 'd':   
            break;

        case 'm':
            String picfname = "OpenBCI-" + directoryManager.getFileNameDateTime() + ".jpg";
            //println("OpenBCI_GUI: 'm' was pressed...taking screenshot:" + picfname);
            saveFrame(directoryManager.getGuiDataPath() + "Screenshots" + System.getProperty("file.separator") + picfname);    // take a shot of that!
            output("Screenshot captured! Saved to /Documents/OpenBCI_GUI/Screenshots/" + picfname);
            break;
            
        default:
            if (currentBoard instanceof Board) {
                println("Interactivity: '" + key + "' Pressed...sending to Board...");
                ((Board)currentBoard).sendCommand(str(key));
            }
            break;
    }
}

void mouseDragged() {

    if (systemMode >= SYSTEMMODE_POSTINIT) {

        //calling mouse dragged inly outside of Control Panel
        if (controlPanel.isOpen == false) {
            wm.mouseDragged();
        }
    }
}
//switch yard if a click is detected
synchronized void mousePressed() {
    // don't allow mouse clicks until setup is complete and the UI is initialized
    if (!setupComplete) {
        return;
    }
    // verbosePrint("OpenBCI_GUI: mousePressed: mouse pressed");
    // println("systemMode" + systemMode);

    //if not before "START SESSION" ... i.e. after initial setup
    if (systemMode >= SYSTEMMODE_POSTINIT) {

        //limit interactivity of main GUI if control panel is open
        if (controlPanel.isOpen == false) {
            //was the stopButton pressed?

            wm.mousePressed();

        }
    }

    //topNav is always clickable
    topNav.mousePressed();

    //interacting with control panel
    if (controlPanel.isOpen) {
        //close control panel if you click outside...
        if (systemMode == SYSTEMMODE_POSTINIT) {
            if (mouseX > 0 && mouseX < controlPanel.w && mouseY > 0 && mouseY < controlPanel.initBox.y+controlPanel.initBox.h) {
                println("OpenBCI_GUI: mousePressed: clicked in CP box");
            }
            //if clicked out of panel
            else {
                println("OpenBCI_GUI: mousePressed: outside of CP clicked");
                controlPanel.isOpen = false;
                topNav.controlPanelCollapser.setIsActive(false);
            }
        }
    }
}

synchronized void mouseReleased() {
    // don't allow mouse clicks until setup is complete and the UI is initialized
    if (!setupComplete) {
        return;
    }

    // gui.mouseReleased();
    topNav.mouseReleased();

    if (systemMode >= SYSTEMMODE_POSTINIT) {

        // GUIWidgets_mouseReleased(); // to replace GUI_Manager version (above) soon... cdr 7/25/16
        wm.mouseReleased();
    }
}

//Global function used to open a url in default browser, usually after pressing a button
void openURLInBrowser(String _url){
    try {
        //Set your page url in this string. For eg, I m using URL for Google Search engine
        java.awt.Desktop.getDesktop().browse(java.net.URI.create(_url));
        output("Attempting to use your default browser to launch: " + _url);
    }
    catch (java.io.IOException e) {
            //println(e.getMessage());
            println("Error launching url in browser: " + _url);
    }
}
