
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
void keyPressed() {
  //note that the Processing variable "key" is the keypress as an ASCII character
  //note that the Processing variable "keyCode" is the keypress as a JAVA keycode.  This differs from ASCII  
  //println("OpenBCI_GUI: keyPressed: key = " + key + ", int(key) = " + int(key) + ", keyCode = " + keyCode);
  
  if(!controlPanel.isOpen){ //don't parse the key if the control panel is open
    if ((int(key) >=32) && (int(key) <= 126)) {  //32 through 126 represent all the usual printable ASCII characters
      parseKey(key);
    } else {
      parseKeycode(keyCode);
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
    case '.':
      drawEMG = !drawEMG; 
      break;
    case ',':
      drawContainers = !drawContainers; 
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
      // stopButtonWasPressed();
      break;
    case 'b':
      println("case b...");
      startRunning();
      // stopButtonWasPressed();
      break;
    case 'n':
      println("openBCI: " + openBCI);
      break;

    case '?':
      printRegisters();
      break;

    case 'd':
      verbosePrint("Updating GUI's channel settings to default...");
      gui.cc.loadDefaultChannelSettings();
      //openBCI.serial_openBCI.write('d');
      openBCI.configureAllChannelsToDefault();
      break;
      
    // //change the state of the impedance measurements...activate the N-channels
    // case 'A':
    //   Ichan = 1; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'S':
    //   Ichan = 2; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'D':
    //   Ichan = 3; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'F':
    //   Ichan = 4; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'G':
    //   Ichan = 5; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'H':
    //   Ichan = 6; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'J':
    //   Ichan = 7; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'K':
    //   Ichan = 8; activate = true; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
      
    // //change the state of the impedance measurements...deactivate the N-channels
    // case 'Z':
    //   Ichan = 1; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'X':
    //   Ichan = 2; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'C':
    //   Ichan = 3; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'V':
    //   Ichan = 4; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'B':
    //   Ichan = 5; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'N':
    //   Ichan = 6; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case 'M':
    //   Ichan = 7; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;
    // case '<':
    //   Ichan = 8; activate = false; code_P_N_Both = 1;  setChannelImpedanceState(Ichan-1,activate,code_P_N_Both);
    //   break;

      
    case 'm':
     String picfname = "OpenBCI-" + getDateString() + ".jpg";
     println("OpenBCI_GUI: 'm' was pressed...taking screenshot:" + picfname);
     saveFrame("./SavedData/" + picfname);    // take a shot of that!
     break;

    default:
     println("OpenBCI_GUI: '" + key + "' Pressed...sending to OpenBCI...");
     // if (openBCI.serial_openBCI != null) openBCI.serial_openBCI.write(key);//send the value as ascii with a newline character
     //if (openBCI.serial_openBCI != null) openBCI.serial_openBCI.write(key);//send the value as ascii with a newline character
     openBCI.sendChar(key);
    
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
      println("Entering Presentation Mode");
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
      println("Slide Back!");
      if (millis() - myPresentation.timeOfLastSlideChange >= 250) {
        if(myPresentation.currentSlide >= 0){
          myPresentation.slideBack();
          myPresentation.timeOfLastSlideChange = millis();
        }
      }
      break;  
    case 38:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received UP ARROW keypress.  Ignoring...");
      dataProcessing_user.switchesActive = true;
      break;  
    case 39:
      println("Forward!");
      if (millis() - myPresentation.timeOfLastSlideChange >= 250) {
        if(myPresentation.currentSlide < myPresentation.presentationSlides.length - 1){
          myPresentation.slideForward();
          myPresentation.timeOfLastSlideChange = millis();
        }
      }
      break;  
    case 40:
      println("OpenBCI_GUI: parseKeycode(" + val + "): received DOWN ARROW keypress.  Ignoring...");
      dataProcessing_user.switchesActive = false;
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


//swtich yard if a click is detected
void mousePressed() {

  verbosePrint("OpenBCI_GUI: mousePressed: mouse pressed");

  //if not in initial setup...
  if (systemMode >= 10) {

    //limit interactivity of main GUI if control panel is open
    if (controlPanel.isOpen == false) {
      //was the stopButton pressed?

      gui.mousePressed(); // trigger mousePressed function in GUI

      GUIWidgets_mousePressed(); // to replace GUI_Manager version (above) soon... cdr 7/25/16
      
      //most of the logic below should be migrated into the GUI_Manager specific function above

      if (gui.stopButton.isMouseHere()) { 
        gui.stopButton.setIsActive(true);
        stopButtonWasPressed();
      }

      // //was the gui page button pressed?
      // if (gui.guiPageButton.isMouseHere()) {
      //   gui.guiPageButton.setIsActive(true);
      //   gui.incrementGUIpage();
      // }

      //check the buttons
      switch (gui.guiPage) {
      case GUI_Manager.GUI_PAGE_CHANNEL_ONOFF:
        //check the channel buttons
        // for (int Ibut = 0; Ibut < gui.chanButtons.length; Ibut++) {
        //   if (gui.chanButtons[Ibut].isMouseHere()) { 
        //     toggleChannelState(Ibut);
        //   }
        // }

        //check the detection button
        //if (gui.detectButton.updateIsMouseHere()) toggleDetectionState();      
        //check spectrogram button
        //if (gui.spectrogramButton.updateIsMouseHere()) toggleSpectrogramState();

        break;
      case GUI_Manager.GUI_PAGE_IMPEDANCE_CHECK:
        // ============ DEPRECATED ============== //
        // //check the impedance buttons
        // for (int Ibut = 0; Ibut < gui.impedanceButtonsP.length; Ibut++) {
        //   if (gui.impedanceButtonsP[Ibut].isMouseHere()) { 
        //     toggleChannelImpedanceState(gui.impedanceButtonsP[Ibut],Ibut,0);
        //   }
        //   if (gui.impedanceButtonsN[Ibut].isMouseHere()) { 
        //     toggleChannelImpedanceState(gui.impedanceButtonsN[Ibut],Ibut,1);
        //   }
        // }
        // if (gui.biasButton.isMouseHere()) { 
        //   gui.biasButton.setIsActive(true);
        //   setBiasState(!openBCI.isBiasAuto);
        // }      
        // break;
      case GUI_Manager.GUI_PAGE_HEADPLOT_SETUP:
        if (gui.intensityFactorButton.isMouseHere()) {
          gui.intensityFactorButton.setIsActive(true);
          gui.incrementVertScaleFactor();
        }
        if (gui.loglinPlotButton.isMouseHere()) {
          gui.loglinPlotButton.setIsActive(true);
          gui.set_vertScaleAsLog(!gui.vertScaleAsLog); //toggle the state
        }
        if (gui.filtBPButton.isMouseHere()) {
          gui.filtBPButton.setIsActive(true);
          incrementFilterConfiguration();
        }
        if (gui.filtNotchButton.isMouseHere()) {
          gui.filtNotchButton.setIsActive(true);
          incrementNotchConfiguration();
        }
        if (gui.smoothingButton.isMouseHere()) {
          gui.smoothingButton.setIsActive(true);
          incrementSmoothing();
        }
        if (gui.showPolarityButton.isMouseHere()) {
          gui.showPolarityButton.setIsActive(true);
          toggleShowPolarity();
        }
        if (gui.maxDisplayFreqButton.isMouseHere()) {
          gui.maxDisplayFreqButton.setIsActive(true);
          gui.incrementMaxDisplayFreq();
        }
        break;
        //default:
      }

      //check the graphs
      if (gui.isMouseOnFFT(mouseX, mouseY)) {
        GraphDataPoint dataPoint = new GraphDataPoint();
        gui.getFFTdataPoint(mouseX, mouseY, dataPoint);
        println("OpenBCI_GUI: FFT data point: " + String.format("%4.2f", dataPoint.x) + " " + dataPoint.x_units + ", " + String.format("%4.2f", dataPoint.y) + " " + dataPoint.y_units);
      } else if (gui.headPlot1.isPixelInsideHead(mouseX, mouseY)) {
        //toggle the head plot contours
        gui.headPlot1.drawHeadAsContours = !gui.headPlot1.drawHeadAsContours;
      } else if (gui.isMouseOnMontage(mouseX, mouseY)) {
        //toggle the display of the montage values
        gui.showMontageValues  = !gui.showMontageValues;
      }
    }
  }

  //=============================//
  // CONTROL PANEL INTERACTIVITY //
  //=============================//

  //was control panel button pushed
  if (controlPanelCollapser.isMouseHere()) {
    if (controlPanelCollapser.isActive && systemMode == 10) {
      controlPanelCollapser.setIsActive(false);
      controlPanel.isOpen = false;
    } else {
      controlPanelCollapser.setIsActive(true);
      controlPanel.isOpen = true;
    }
  } else {
    if (controlPanel.isOpen) {
      controlPanel.CPmousePressed();
    }
  }

  //interacting with control panel
  if (controlPanel.isOpen) {
    //close control panel if you click outside...
    if (systemMode == 10) {
      if (mouseX > 0 && mouseX < controlPanel.w && mouseY > 0 && mouseY < controlPanel.initBox.y+controlPanel.initBox.h) {
        println("OpenBCI_GUI: mousePressed: clicked in CP box");
        controlPanel.CPmousePressed();
      }
      //if clicked out of panel
      else {
        println("OpenBCI_GUI: mousePressed: outside of CP clicked");
        controlPanel.isOpen = false;
        controlPanelCollapser.setIsActive(false);
        output("Press the \"Press to Start\" button to initialize the data stream.");
      }
    }
  }

  redrawScreenNow = true;  //command a redraw of the GUI whenever the mouse is pressed

  if (playground.isMouseHere()) {
    playground.mousePressed();
  }

  if (playground.isMouseInButton()) {
    playground.toggleWindow();
  }
}

void mouseReleased() {

  verbosePrint("OpenBCI_GUI: mouseReleased: mouse released");

  //some buttons light up only when being actively pressed.  Now that we've
  //released the mouse button, turn off those buttons.

  //interacting with control panel
  if (controlPanel.isOpen) {
    //if clicked in panel
    controlPanel.CPmouseReleased();
  }

  if (systemMode >= 10) {

    gui.mouseReleased();
    GUIWidgets_mouseReleased(); // to replace GUI_Manager version (above) soon... cdr 7/25/16
    
    redrawScreenNow = true;  //command a redraw of the GUI whenever the mouse is released
  }

  if (screenHasBeenResized) {
    println("OpenBCI_GUI: mouseReleased: screen has been resized...");
    screenHasBeenResized = false;
  }

  //Playground Interactivity
  if (playground.isMouseHere()) {
    playground.mouseReleased();
  }
  if (playground.isMouseInButton()) {
    // playground.toggleWindow();
  }
}

void incrementSmoothing() {
  smoothFac_ind++;
  if (smoothFac_ind >= smoothFac.length) smoothFac_ind = 0;

  //tell the GUI
  gui.setSmoothFac(smoothFac[smoothFac_ind]);

  //update the button
  gui.smoothingButton.but_txt = "Smooth\n" + smoothFac[smoothFac_ind];
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
  color color_hover = color(127, 134, 143);//color(252, 221, 198); 
  color color_pressed = color(150,170,200); //bgColor;
  color color_highlight = color(102);
  color color_notPressed = color(255); //color(227,118,37);
  color buttonStrokeColor = bgColor;
  color textColorActive = color(255);
  color textColorNotActive = bgColor;
  color rectHighlight;
  boolean drawHand = false;
  //boolean isMouseHere = false;
  boolean buttonHasStroke = true;
  boolean isActive = false;
  boolean isDropdownButton = false;
  boolean wasPressed = false;
  public String but_txt;
  PFont buttonFont = f2;

  public Button(int x, int y, int w, int h, String txt, int fontSize) {
    setup(x, y, w, h, txt);
    //println(PFont.list()); //see which fonts are available
    //font = createFont("SansSerif.plain",fontSize);
    //font = createFont("Lucida Sans Regular",fontSize);
    // font = createFont("Arial",fontSize);
    //font = loadFont("SansSerif.plain.vlw");
  }

  public void setup(int x, int y, int w, int h, String txt) {
    but_x = x;
    but_y = y;
    but_dx = w;
    but_dy = h;
    setString(txt);
  }

  public void setString(String txt) {
    but_txt = txt;
    //println("Button: setString: string = " + txt);
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
      cursor(HAND);
      return true;
    } else {
      return false;
    }
  }

  color getColor() {
    if (isActive) {
     currentColor = color_pressed;
    } else if (isMouseHere()) {
     currentColor = color_hover;
    } else {    
     currentColor = color_notPressed;
    }
    return currentColor;
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
    //draw the button
    fill(getColor());
    if (buttonHasStroke) {
      stroke(buttonStrokeColor); //button border
    } else {
      noStroke();
    }
    // noStroke();
    rect(but_x, but_y, but_dx, but_dy);

    //draw the text
    if (isActive) {
      fill(textColorActive);
    } else {
      fill(textColorNotActive);
    }
    stroke(255);
    textFont(buttonFont);  //load f2 ... from control panel 
    textSize(12);
    textAlign(CENTER, CENTER);
    textLeading(round(0.9*(textAscent()+textDescent())));
    //    int x1 = but_x+but_dx/2;
    //    int y1 = but_y+but_dy/2;
    int x1, y1;
    //no auto wrap
    x1 = but_x+but_dx/2;
    y1 = but_y+but_dy/2;
    text(but_txt, x1, y1);

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

    if (true) {
      if (!isMouseHere() && drawHand) {
        cursor(ARROW);
        drawHand = false;
        verbosePrint("don't draw hand");
      }
      //if cursor is over button change cursor icon to hand!
      if (isMouseHere() && !drawHand) {
        cursor(HAND);
        drawHand = true;
        verbosePrint("draw hand");
      }
    }
  }
};