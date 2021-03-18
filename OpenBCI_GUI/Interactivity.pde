
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

    //Check for Copy/Paste text keyboard shortcuts before anything else.
    if (copyPaste.checkIfPressedAllOS()) {
        return;
    }

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

synchronized void keyReleased() {
    copyPaste.checkIfReleasedAllOS();
}

void parseKey(char val) {
    //assumes that val is a usual printable ASCII character (ASCII 32 through 126)
    switch (val) {
        case ' ':
            // space to start/stop the stream
            topNav.stopButtonWasPressed();
            return;
        case ',':
            drawContainers = !drawContainers;
            return;
        case '{':
            if(colorScheme == COLOR_SCHEME_DEFAULT){
                colorScheme = COLOR_SCHEME_ALTERNATIVE_A;
            } else if(colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
                colorScheme = COLOR_SCHEME_DEFAULT;
            }
            //topNav.updateNavButtonsBasedOnColorScheme();
            output("New Dark color scheme coming soon!");
            return;

        //deactivate channels 1-4
        case '1':
            currentBoard.setEXGChannelActive(1-1, false);
            return;
        case '2':
            currentBoard.setEXGChannelActive(2-1, false);
            return;
        case '3':
            currentBoard.setEXGChannelActive(3-1, false);
            return;
        case '4':
            currentBoard.setEXGChannelActive(4-1, false);
            return;

        //activate channels 1-4
        case '!':
            currentBoard.setEXGChannelActive(1-1, true);
            return;
        case '@':
            currentBoard.setEXGChannelActive(2-1, true);
            return;
        case '#':
            currentBoard.setEXGChannelActive(3-1, true);
            return;
        case '$':
            currentBoard.setEXGChannelActive(4-1, true);
            return;

        //other controls
        case 's':
            stopRunning();
            return;

        case 'b':
            startRunning();
            return;

        ///////////////////// Save User settings lowercase n
        case 'n':
            println("Save key pressed!");
            settings.save(settings.getPath("User", eegDataSource, nchan));
            outputSuccess("Settings Saved! The GUI will now load with these settings. Click \"Default\" to revert to factory settings.");
            return;

        ///////////////////// Load User settings uppercase N
        case 'N':
            println("Load key pressed!");
            settings.loadKeyPressed();
            return;

        case '?':
            if(currentBoard instanceof BoardCyton) {
                ((BoardCyton)currentBoard).printRegisters();
            }
            return;

        case 'd':   
            return;

        case 'm':
            String picfname = "OpenBCI-" + directoryManager.getFileNameDateTime() + ".jpg";
            //println("OpenBCI_GUI: 'm' was pressed...taking screenshot:" + picfname);
            saveFrame(directoryManager.getGuiDataPath() + "Screenshots" + System.getProperty("file.separator") + picfname);    // take a shot of that!
            output("Screenshot captured! Saved to /Documents/OpenBCI_GUI/Screenshots/" + picfname);
            return;
        default:
            break;
    }

    if (nchan > 4) {
        switch (val) {
            case '5':
                currentBoard.setEXGChannelActive(5-1, false);
                return;
            case '6':
                currentBoard.setEXGChannelActive(6-1, false);
                return;
            case '7':
                currentBoard.setEXGChannelActive(7-1, false);
                return;
            case '8':
                currentBoard.setEXGChannelActive(8-1, false);
                return;
            case '%':
                currentBoard.setEXGChannelActive(5-1, true);
                return;
            case '^':
                currentBoard.setEXGChannelActive(6-1, true);
                return;
            case '&':
                currentBoard.setEXGChannelActive(7-1, true);
                return;
            case '*':
                currentBoard.setEXGChannelActive(8-1, true);
                return;
            default:
                break;
        }
    }

    if (nchan > 8) {
        switch (val) {
            case 'q':
                currentBoard.setEXGChannelActive(9-1, false);
                return;
            case 'w':
                currentBoard.setEXGChannelActive(10-1, false);
                return;
            case 'e':
                currentBoard.setEXGChannelActive(11-1, false);
                return;
            case 'r':
                currentBoard.setEXGChannelActive(12-1, false);
                return;
            case 't':
                currentBoard.setEXGChannelActive(13-1, false);
                return;
            case 'y':
                currentBoard.setEXGChannelActive(14-1, false);
                return;
            case 'u':
                currentBoard.setEXGChannelActive(15-1, false);
                return;
            case 'i':
                currentBoard.setEXGChannelActive(16-1, false);
                return;
            case 'Q':
                currentBoard.setEXGChannelActive(9-1, true);
                return;
            case 'W':
                currentBoard.setEXGChannelActive(10-1, true);
                return;
            case 'E':
                currentBoard.setEXGChannelActive(11-1, true);
                return;
            case 'R':
                currentBoard.setEXGChannelActive(12-1, true);
                return;
            case 'T':
                currentBoard.setEXGChannelActive(13-1, true);
                return;
            case 'Y':
                currentBoard.setEXGChannelActive(14-1, true);
                return;
            case 'U':
                currentBoard.setEXGChannelActive(15-1, true);
                return;
            case 'I':
                currentBoard.setEXGChannelActive(16-1, true);
                return;
            default:
                break;
        }
    }

    if (currentBoard instanceof BoardGanglion) {
        if (val == '[' ||  val == ']') {
            println("Expert Mode: '" + val + "' pressed. Sending to Ganglion...");
            Boolean success = ((Board)currentBoard).sendCommand(str(val)).getKey();
            if (success) {
                outputSuccess("Expert Mode: Success sending '" + val + "' to Ganglion!");
            } else {
                outputWarn("Expert Mode: Error sending '" + val + "' to Ganglion. Try again with data stream stopped.");
            }
            return;
        }
    }

    if (currentBoard instanceof Board) {
        output("Expert Mode: '" + key + "' pressed. This is not assigned or applicable to current setup.");
        //((Board)currentBoard).sendCommand(str(key));
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
                topNav.controlPanelCollapser.setOff();
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
        output("Opening URL: " + _url);
    }
    catch (java.io.IOException e) {
            //println(e.getMessage());
            println("Error launching url in browser: " + _url);
    }
}

////////////////////////////////////////////////////////////////
//                      GUI CopyPaste                         //
// Custom class used by the GUI to handle both Copy and Paste //
// Use standard copy and paste keyboard shortcuts for all OS  //
//                                                            //
// Copy ControlP5 Textfield Text                              //
//      - Windows and Linux: Control + C                      //
//      - Mac: Command + C                                    //
// Paste Text into Textfield                                  //
//      - Windows and Linux: Control + V                      //
//      - Mac: Command + V                                    //
////////////////////////////////////////////////////////////////
class CopyPaste {

    private final int CMD_CNTL_KEYCODE = (isLinux() || isWindows()) ? 17 : 157;
    private final int C_KEYCODE = 67;
    private final int V_KEYCODE = 86;
    private boolean commandControlPressed;
    private boolean copyPressed;
    private String value;

    CopyPaste () {

    }
    
    public boolean checkIfPressedAllOS() {
        //This logic mimics the behavior of copy/paste in Mac OS X, and applied to all.
        if (keyCode == CMD_CNTL_KEYCODE) {
            commandControlPressed = true;
            //println("KEYBOARD SHORTCUT: COMMAND PRESSED");
            return true;
        }

        if (commandControlPressed && keyCode == V_KEYCODE) {
            //println("KEYBOARD SHORTCUT: PASTE PRESSED");
            // Get clipboard contents
            String s = GClip.paste();
            //println("FROM CLIPBOARD ~~ " + s);
            // Assign to stored value
            value = s;
            return true;
        }

        if (commandControlPressed && keyCode == C_KEYCODE) {
            //println("KEYBOARD SHORTCUT: COPY PRESSED");
            copyPressed = true;
            return true;
        }

        return false;
    }

    public void checkIfReleasedAllOS() {
        if (keyCode == CMD_CNTL_KEYCODE) {
            commandControlPressed = false;
        }
    }
    
    //Pull stored value from this class and set to null, otherwise return null.
    private String pullValue() {
        if (value == null) {
            return value;
        }
        String s = value;
        value = null;
        return s;
    }

    private void checkForPaste(Textfield tf) {
        if (value == null) {
            return;
        }

        if (tf.isFocus()) {
            StringBuilder status = new StringBuilder("OpenBCI_GUI: User pasted text from the clipboard into ");
            status.append(tf.toString());
            println(status);
            StringBuilder sb = new StringBuilder();
            String existingText = dropNonPrintableChars(tf.getText());
            String val = pullValue();
            //println("EXISTING TEXT =="+ existingText+ "__end. VALUE ==" + val + "__end.");

            // On Mac, Remove 'v' character from the end of the existing text
            existingText = existingText.length() > 0 && isMac() ? existingText.substring(0, existingText.length() - 1) : existingText;

            sb.append(existingText);
            sb.append(val);
            //The 'v' character does make it to the textfield, but this is immediately overwritten here.
            tf.setText(sb.toString());
        } 
    }

    private void checkForCopy(Textfield tf) {
        if (!copyPressed) {
            return;
        }

        if (tf.isFocus()) {
            String s = dropNonPrintableChars(tf.getText());
            if (s.length() == 0) {
                return;
            }
            StringBuilder status = new StringBuilder("OpenBCI_GUI: User copied text from ");
            status.append(tf.toString());
            status.append(" to the clipboard");
            println(status);
            //println("FOUND TEXT =="+ s+"__end.");
            if (isMac()) {
                //Remove the 'c' character that was just typed in the textfield
                s = s.substring(0, s.length() - 1);
                tf.setText(s);
                //println("MAC FIXED TEXT =="+ s+"__end.");
            }
            boolean b = GClip.copy(s);
            copyPressed = false;
        } 
    }

    public void checkForCopyPaste(Textfield tf) {
        checkForPaste(tf);
        checkForCopy(tf);
    }
}
