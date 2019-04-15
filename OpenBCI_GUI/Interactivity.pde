
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  This file contains all key commands for interactivity with GUI & OpenBCI
//  Created by Chip Audette, Joel Murphy, & Conor Russomanno
//  - Extracted from OpenBCI_GUI because it was getting too klunky
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

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

    if(!controlPanel.isOpen && !isNetworkingTextActive()){ //don't parse the key if the control panel is open
        if (settings.expertModeToggle || (int(key) == 32)) { //Check if Expert Mode is On or Spacebar has been pressed
            if ((int(key) >=32) && (int(key) <= 126)) {  //32 through 126 represent all the usual printable ASCII characters
                parseKey(key);
            } else {
                parseKeycode(keyCode);
            }
        }
    }

    if(key==27){
        key=0; //disable 'esc' quitting program
    }
}

void parseKey(char val) {
    int Ichan; boolean activate; int code_P_N_Both;

    //assumes that val is a usual printable ASCII character (ASCII 32 through 126)
    switch (val) {
        case ' ':
            stopButtonWasPressed();
            break;
        case '.':

            if(drawEMG){
                drawAccel = true;
                drawPulse = false;
                drawHead = false;
                drawEMG = false;
            }
            else if(drawAccel){
                drawAccel = false;
                drawPulse = true;
                drawHead = false;
                drawEMG = false;
            }
            else if(drawPulse){
                drawAccel = false;
                drawPulse = false;
                drawHead = true;
                drawEMG = false;
            }
            else if(drawHead){
                drawAccel = false;
                drawPulse = false;
                drawHead = false;
                drawEMG = true;
            }
            break;
        case ',':
            drawContainers = !drawContainers;
            break;
        case '<':
            //w_timeSeries.setUpdating(!w_timeSeries.isUpdating());
            break;
        case '>':
            /*
            if(eegDataSource == DATASOURCE_GANGLION){
                ganglion.enterBootloaderMode();
            }
            */
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
        case '/':
            drawAccel = !drawAccel;
            drawPulse = !drawPulse;
            break;
        case '\\':
            drawFFT = !drawFFT;
            drawBionics = !drawBionics;
            break;
        case '1':
            deactivateChannel(1-1);
            break;
        case '2':
            deactivateChannel(2-1);
            break;
        case '3':
            deactivateChannel(3-1);
            break;
        case '4':
            deactivateChannel(4-1);
            break;
        case '5':
            deactivateChannel(5-1);
            break;
        case '6':
            deactivateChannel(6-1);
            break;
        case '7':
            deactivateChannel(7-1);
            break;
        case '8':
            deactivateChannel(8-1);
            break;

        case 'q':
            if(nchan == 16){
                deactivateChannel(9-1);
            }
            break;
        case 'w':
            if(nchan == 16){
                deactivateChannel(10-1);
            }
            break;
        case 'e':
            if(nchan == 16){
                deactivateChannel(11-1);
            }
            break;
        case 'r':
            if(nchan == 16){
                deactivateChannel(12-1);
            }
            break;
        case 't':
            if(nchan == 16){
                deactivateChannel(13-1);
            }
            break;
        case 'y':
            if(nchan == 16){
                deactivateChannel(14-1);
            }
            break;
        case 'u':
            if(nchan == 16){
                deactivateChannel(15-1);
            }
            break;
        case 'i':
            if(nchan == 16){
                deactivateChannel(16-1);
            }
            break;
        case ':':
            println("test..."); //@@@@@
            boolean test = isNetworkingTextActive();
            break;

        //activate channels 1-8
        case '!':
            activateChannel(1-1);
            break;
        case '@':
            activateChannel(2-1);
            break;
        case '#':
            activateChannel(3-1);
            break;
        case '$':
            activateChannel(4-1);
            break;
        case '%':
            activateChannel(5-1);
            break;
        case '^':
            activateChannel(6-1);
            break;
        case '&':
            activateChannel(7-1);
            break;
        case '*':
            activateChannel(8-1);
            break;

        //activate channels 9-16 (DAISY MODE ONLY)
        case 'Q':
            if(nchan == 16){
                activateChannel(9-1);
            }
            break;
        case 'W':
            if(nchan == 16){
                activateChannel(10-1);
            }
            break;
        case 'E':
            if(nchan == 16){
                activateChannel(11-1);
            }
            break;
        case 'R':
            if(nchan == 16){
                activateChannel(12-1);
            }
            break;
        case 'T':
            if(nchan == 16){
                activateChannel(13-1);
            }
            break;
        case 'Y':
            if(nchan == 16){
                activateChannel(14-1);
            }
            break;
        case 'U':
            if(nchan == 16){
                activateChannel(15-1);
            }
            break;
        case 'I':
            if(nchan == 16){
                activateChannel(16-1);
            }
            break;

        //other controls
        case 's':
            println("case s...");
            stopRunning();
            //stopButtonWasPressed();
            break;

        case 'b':
            println("case b...");
            startRunning();
            //stopButtonWasPressed();
            break;

        //Lowercase k sets Bias Don't Include all channels
        case 'k':
            for (int i = 0; i < nchan; i++) { //for every channel
                //BIAS off all channels
                channelSettingValues[i][3] = '0';
                println ("chan " + i + " bias don't include");
            }
            break;
        //Lowercase l sets Bias Include all channels
        case 'l':
            for (int i = 0; i < nchan; i++) { //for every channel
                //buttons are updated in HardwareSettingsController based on channelSettingValues[i][j]
                //BIAS on all channells
                channelSettingValues[i][3] = '1';
                println ("chan " + i + " bias include");
            }
            break;

        ///////////////////// Save User settings lowercase n
        case 'n':
            println("Save key pressed!");
            settings.save(settings.getPath("User", eegDataSource, nchan));
            outputSuccess("Settings Saved!");
            break;

        ///////////////////// Load User settings uppercase N
        case 'N':
            println("Load key pressed!");
            settings.loadKeyPressed();
            break;

        case '?':
            cyton.printRegisters();
            break;

        case 'd':
            verbosePrint("Updating GUI's channel settings to default...");
            w_timeSeries.hsc.loadDefaultChannelSettings();
            //cyton.serial_openBCI.write('d');
            cyton.configureAllChannelsToDefault();
            break;

        case 'm':
            String picfname = "OpenBCI-" + getDateString() + ".jpg";
            println("OpenBCI_GUI: 'm' was pressed...taking screenshot:" + picfname);
            saveFrame("./SavedData/Screenshots/" + picfname);    // take a shot of that!
            break;

        default:
            if (eegDataSource == DATASOURCE_CYTON) {
                println("Interactivity: '" + key + "' Pressed...sending to Cyton...");
                cyton.write(key);
            } else if (eegDataSource == DATASOURCE_GANGLION) {
                println("Interactivity: '" + key + "' Pressed...sending to Ganglion...");
                hub.sendCommand(key);
            }
            break;
    }
}

void parseKeycode(int val) {
    //assumes that val is Java keyCode
    switch (val) {
        case 8:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received BACKSPACE keypress.  Ignoring...");
            break;
        case 9:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received TAB keypress.  Ignoring...");
            //gui.showImpedanceButtons = !gui.showImpedanceButtons;
            // gui.incrementGUIpage(); //deprecated with new channel controller
            break;
        case 10:
            println("Enter was pressed.");
            drawPresentation = !drawPresentation;
            break;
        case 16:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received SHIFT keypress.  Ignoring...");
            break;
        case 17:
            //println("OpenBCI_GUI: parseKeycode(" + val + "): received CTRL keypress.  Ignoring...");
            break;
        case 18:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received ALT keypress.  Ignoring...");
            break;
        case 20:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received CAPS LOCK keypress.  Ignoring...");
            break;
        case 27:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received ESC keypress.  Stopping OpenBCI...");
            //stopRunning();
            break;
        case 33:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received PAGE UP keypress.  Ignoring...");
            break;
        case 34:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received PAGE DOWN keypress.  Ignoring...");
            break;
        case 35:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received END keypress.  Ignoring...");
            break;
        case 36:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received HOME keypress.  Ignoring...");
            break;
        case 37:
            if (millis() - myPresentation.timeOfLastSlideChange >= 250) {
                if(myPresentation.currentSlide >= 0){
                    myPresentation.slideBack();
                    myPresentation.timeOfLastSlideChange = millis();
                }
            }
            break;
        case 38:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received UP ARROW keypress.  Ignoring...");
            break;
        case 39:
            if (millis() - myPresentation.timeOfLastSlideChange >= 250) {
                if(myPresentation.currentSlide < myPresentation.presentationSlides.length - 1){
                    myPresentation.slideForward();
                    myPresentation.timeOfLastSlideChange = millis();
                }
            }
            break;
        case 40:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received DOWN ARROW keypress.  Ignoring...");
            break;
        case 112:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F1 keypress.  Ignoring...");
            break;
        case 113:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F2 keypress.  Ignoring...");
            break;
        case 114:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F3 keypress.  Ignoring...");
            break;
        case 115:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F4 keypress.  Ignoring...");
            break;
        case 116:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F5 keypress.  Ignoring...");
            break;
        case 117:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F6 keypress.  Ignoring...");
            break;
        case 118:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F7 keypress.  Ignoring...");
            break;
        case 119:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F8 keypress.  Ignoring...");
            break;
        case 120:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F9 keypress.  Ignoring...");
            break;
        case 121:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F10 keypress.  Ignoring...");
            break;
        case 122:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F11 keypress.  Ignoring...");
            break;
        case 123:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received F12 keypress.  Ignoring...");
            break;
        case 127:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received DELETE keypress.  Ignoring...");
            break;
        case 155:
            println("OpenBCI_GUI: parseKeycode(" + val + "): received INSERT keypress.  Ignoring...");
            break;
        default:
            println("OpenBCI_GUI: parseKeycode(" + val + "): value is not known.  Ignoring...");
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
    // controlPanel.CPmousePressed();

    //if not before "Start System" ... i.e. after initial setup
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
                controlPanel.CPmousePressed();
            }
            //if clicked out of panel
            else {
                println("OpenBCI_GUI: mousePressed: outside of CP clicked");
                controlPanel.isOpen = false;
                topNav.controlPanelCollapser.setIsActive(false);
                output("Press the \"Press to Start\" button to initialize the data stream.");
            }
        }
    }

    redrawScreenNow = true;  //command a redraw of the GUI whenever the mouse is pressed
}

synchronized void mouseReleased() {
    // don't allow mouse clicks until setup is complete and the UI is initialized
    if (!setupComplete) {
        return;
    }

    //some buttons light up only when being actively pressed.  Now that we've
    //released the mouse button, turn off those buttons.

    //interacting with control panel
    if (controlPanel.isOpen) {
        //if clicked in panel
        controlPanel.CPmouseReleased();
    }

    // gui.mouseReleased();
    topNav.mouseReleased();

    if (systemMode >= SYSTEMMODE_POSTINIT) {

        // GUIWidgets_mouseReleased(); // to replace GUI_Manager version (above) soon... cdr 7/25/16
        wm.mouseReleased();

        redrawScreenNow = true;  //command a redraw of the GUI whenever the mouse is released
    }

    if (screenHasBeenResized) {
        println("OpenBCI_GUI: mouseReleased: screen has been resized...");
        screenHasBeenResized = false;
    }
}

//------------------------------------------------------------------------
//                       Classes
//------------------------------------------------------------------------


////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Formerly Button.pde
// This class creates and manages a button for use on the screen to trigger actions.
//
// Created: Chip Audette, Oct 2013.
// Modified: Conor Russomanno, Oct 2014
//
// Based on Processing's "Button" example code
//
////////////////////////////////////////////////////////////////////////////////////////////////////

class Button {

    int but_x, but_y, but_dx, but_dy;      // Position of square button
    //int rectSize = 90;     // Diameter of rect

    color currentColor;
    color color_hover = color(177, 184, 193);//color(252, 221, 198);
    color color_pressed = color(150,170,200); //bgColor;
    color color_notPressed = color(255); //color(227,118,37);
    color buttonStrokeColor = bgColor;
    color textColorActive = color(255);
    color textColorNotActive = bgColor;
    boolean drawHand = false;
    boolean isCircleButton = false;
    int cornerRoundness = 0;
    boolean buttonHasStroke = true;
    boolean isActive = false;
    boolean isDropdownButton = false;
    boolean wasPressed = false;
    public String but_txt;
    boolean showHelpText;
    boolean helpTimerStarted;
    String helpText= "";
    String myURL= "";
    int mouseOverButtonStart = 0;
    PFont buttonFont;
    int buttonTextSize;
    PImage bgImage;
    boolean hasbgImage = false;
    private boolean ignoreHover = false;

    public Button(int x, int y, int w, int h, String txt) {
        setup(x, y, w, h, txt);
        buttonFont = p5;
        buttonTextSize = 12;
    }

    public Button(int x, int y, int w, int h, String txt, int fontSize) {
        setup(x, y, w, h, txt);
        buttonFont = p5;
        buttonTextSize = 12;
    }

    public void setup(int x, int y, int w, int h, String txt) {
        but_x = x;
        but_y = y;
        but_dx = w;
        but_dy = h;
        setString(txt);
    }

    public boolean getIgnoreHover() {
        return ignoreHover;
    }

    public void setX(int _but_x){
        but_x = _but_x;
    }

    public void setY(int _but_y){
        but_y = _but_y;
    }

    public void setPos(int _but_x, int _but_y){
        but_x = _but_x;
        but_y = _but_y;
    }

    public void setFont(PFont _newFont){
        buttonFont = _newFont;
    }

    public void setFont(PFont _newFont, int _newTextSize){
        buttonFont = _newFont;
        buttonTextSize = _newTextSize;
    }

    public void setFontColorNotActive (color _color) {
        textColorNotActive = _color;
    }

    public void setCircleButton(boolean _isCircleButton){
        isCircleButton = _isCircleButton;
        if(isCircleButton){
            cornerRoundness = 0;
        }
    }

    public void setCornerRoundess(int _cornerRoundness){
        if(!isCircleButton){
            cornerRoundness = _cornerRoundness;
        }
    }

    public void setString(String txt) {
        but_txt = txt;
        //println("Button: setString: string = " + txt);
    }

    public void setHelpText(String _helpText){
        helpText = _helpText;
    }

    public void setIgnoreHover (boolean _ignoreHover) {
        ignoreHover = _ignoreHover;
    }

    public void setURL(String _myURL){
        myURL = _myURL;
    }

    public void goToURL(){
        if(myURL != ""){
            openURLInBrowser(myURL);
        }
    }

    public void setBackgroundImage(PImage _bgImage){
        bgImage = _bgImage;
        hasbgImage = true;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setIsActive(boolean val) {
        isActive = val;
    }

    public void makeDropdownButton(boolean val) {
        isDropdownButton = val;
    }

    public boolean isMouseHere() {
        if ( overRect(but_x, but_y, but_dx, but_dy) ) {
            // cursor(HAND);
            if(!helpTimerStarted){
                helpTimerStarted = true;
                mouseOverButtonStart = millis();
            } else {
                if(millis()-mouseOverButtonStart >= 1000){
                    showHelpText = true;
                }
            }
            return true;
        }
        else {
            setIsActive(false);
            if(helpTimerStarted){
                buttonHelpText.setVisible(false);
                showHelpText = false;
                helpTimerStarted = false;
            }
            return false;
        }
    }

    color getColor() {
        if (isActive) {
            currentColor = color_pressed;
        } else if (isMouseHere() && !ignoreHover) {
            currentColor = color_hover;
        } else if (ignoreHover) {
            currentColor = color_notPressed;
        } else {
            currentColor = color_notPressed;
        }
        return currentColor;
    }

    public String getButtonText() {
        return but_txt;
    }

    public void setCurrentColor(color _color){
        currentColor = _color;
    }

    public void setColorPressed(color _color) {
        color_pressed = _color;
    }
    public void setColorNotPressed(color _color) {
        color_notPressed = _color;
    }

    public void setStrokeColor(color _color) {
        buttonStrokeColor = _color;
    }

    public void hasStroke(boolean _trueORfalse) {
        buttonHasStroke = _trueORfalse;
    }

    boolean overRect(int x, int y, int width, int height) {
        if (mouseX >= x && mouseX <= x+width &&
            mouseY >= y && mouseY <= y+height) {
            return true;
        } else {
            return false;
        }
    }

    public void draw(int _x, int _y) {
        but_x = _x;
        but_y = _y;
        draw();
    }

    public void draw() {
        pushStyle();
        // rectMode(CENTER);
        ellipseMode(CORNER);

        //draw the button
        fill(getColor());
        if (buttonHasStroke) {
            stroke(buttonStrokeColor); //button border
        } else {
            noStroke();
        }
        // noStroke();
        if(isCircleButton){
            ellipse(but_x, but_y, but_dx, but_dy); //draw circular button
        } else{
            if(cornerRoundness == 0){
                rect(but_x, but_y, but_dx, but_dy); //draw normal rectangle button
            } else {
                rect(but_x, but_y, but_dx, but_dy, cornerRoundness); //draw button with rounded corners
            }
        }

        //draw the text
        if (isActive) {
            fill(textColorActive);
        } else {
            fill(textColorNotActive);
        }
        stroke(255);
        textFont(buttonFont);  //load f2 ... from control panel
        textSize(buttonTextSize);
        textAlign(CENTER, CENTER);
        textLeading(round(0.9*(textAscent()+textDescent())));
        //    int x1 = but_x+but_dx/2;
        //    int y1 = but_y+but_dy/2;
        int x1, y1;
        //no auto wrap
        x1 = but_x+but_dx/2;
        y1 = but_y+but_dy/2;

        if(hasbgImage){ //if there is a bg image ... don't draw text
            imageMode(CENTER);
            image(bgImage, but_x + (but_dx/2), but_y + (but_dy/2), but_dx-8, but_dy-8);
        } else{  //otherwise draw text
            if(buttonFont == h1 || buttonFont == h2 || buttonFont == h3 || buttonFont == h4 || buttonFont == h5){
                text(but_txt, x1, y1 - 1); //for some reason y looks better at -1 with montserrat
            } else if(buttonFont == p1 || buttonFont == p2 || buttonFont == p3 || buttonFont == p4 || buttonFont == p5 || buttonFont == p6){
                textLeading(12); //line spacing
                text(but_txt, x1, y1 - 2); //for some reason y looks better at -2 w/ Open Sans
            } else{
                text(but_txt, x1, y1); //as long as font is not Montserrat
            }
        }

        //send some info to the HelpButtonText object to be drawn last in OpenBCI_GUI.pde ... we want to make sure it is render last, and on top of all other GUI stuff
        if(showHelpText && helpText != ""){
            buttonHelpText.setButtonHelpText(helpText, but_x + but_dx/2, but_y + (3*but_dy)/4);
            buttonHelpText.setVisible(true);
        }
        //draw open/close arrow if it's a dropdown button
        if (isDropdownButton) {
            pushStyle();
            fill(255);
            noStroke();
            // smooth();
            // stroke(255);
            // strokeWeight(1);
            if (isActive) {
                float point1x = but_x + (but_dx - ((3f*but_dy)/4f));
                float point1y = but_y + but_dy/3f;
                float point2x = but_x + (but_dx-(but_dy/4f));
                float point2y = but_y + but_dy/3f;
                float point3x = but_x + (but_dx - (but_dy/2f));
                float point3y = but_y + (2f*but_dy)/3f;
                triangle(point1x, point1y, point2x, point2y, point3x, point3y); //downward triangle, indicating open
            } else {
                float point1x = but_x + (but_dx - ((3f*but_dy)/4f));
                float point1y = but_y + (2f*but_dy)/3f;
                float point2x = but_x + (but_dx-(but_dy/4f));
                float point2y = but_y + (2f*but_dy)/3f;
                float point3x = but_x + (but_dx - (but_dy/2f));
                float point3y = but_y + but_dy/3f;
                triangle(point1x, point1y, point2x, point2y, point3x, point3y); //upward triangle, indicating closed
            }
            popStyle();
        }
        popStyle();
    } //end of button draw
};

class ButtonHelpText{
    int x, y, w, h;
    String myText = "";
    boolean isVisible;
    int numLines;
    int lineSpacing = 14;
    int padding = 10;

    ButtonHelpText(){

    }

    public void setVisible(boolean _isVisible){
        isVisible = _isVisible;
    }

    public void setButtonHelpText(String _myText, int _x, int _y){
        myText = _myText;
        x = _x;
        y = _y;
    }

    public void draw(){
        if(isVisible){
            pushStyle();
            textAlign(CENTER, TOP);

            textFont(p5,12);
            textLeading(lineSpacing); //line spacing
            stroke(31,69,110);
            fill(255);
            numLines = (int)((float)myText.length()/30.0) + 1; //add 1 to round up
            // println("numLines: " + numLines);
            //if on left side of screen, draw box brightness to prevent box off screen
            if(x <= width/2){
                rect(x, y, 200, 2*padding + numLines*lineSpacing + 4);
                fill(31,69,110); //text colof
                text(myText, x + padding, y + padding, 180, (numLines*lineSpacing + 4));
            } else{ //if on right side of screen, draw box left to prevent box off screen
                rect(x - 200, y, 200, 2*padding + numLines*lineSpacing + 4);
                fill(31,69,110); //text colof
                text(myText, x + padding - 200, y + padding, 180, (numLines*lineSpacing + 4));
            }
            popStyle();
        }
    }
};

void openURLInBrowser(String _url){
    try {
        //Set your page url in this string. For eg, I m using URL for Google Search engine
        java.awt.Desktop.getDesktop().browse(java.net.URI.create(_url));
        output("Attempting to use your default browser to launch: " + _url);
    }
    catch (java.io.IOException e) {
            println(e.getMessage());
            println("Error launching url in browser: " + _url);
    }
}

void toggleFrameRate(){
    if(frameRateCounter<3){
        frameRateCounter++;
    } else {
        frameRateCounter = 1; // until we resolve the latency issue with 24hz, only allow 30hz minimum (aka frameRateCounter = 1)
    }
    if(frameRateCounter==0){
        frameRate(24); //refresh rate ... this will slow automatically, if your processor can't handle the specified rate
        topNav.fpsButton.setString("24 fps");
    }
    if(frameRateCounter==1){
        frameRate(30);
        topNav.fpsButton.setString("30 fps");
    }
    if(frameRateCounter==2){
        frameRate(45);
        topNav.fpsButton.setString("45 fps");
    }
    if(frameRateCounter==3){
        frameRate(60);
        topNav.fpsButton.setString("60 fps");
    }
}

//loop through networking textfields and find out if any are active
boolean isNetworkingTextActive(){
    boolean isAFieldActive = false;
    if (w_networking != null) {
        int numTextFields = w_networking.cp5_networking.getAll(Textfield.class).size();
        for(int i = 0; i < numTextFields; i++){
            if(w_networking.cp5_networking.getAll(Textfield.class).get(i).isFocus()){
                isAFieldActive = true;
            }
        }
    }
    println("Networking Text Field Active? " + isAFieldActive);
    return isAFieldActive; //if not, return false
}

boolean highDPI = false;
void toggleHighDPI(){
    highDPI = !highDPI;
    println("High DPI? " + highDPI);
}
