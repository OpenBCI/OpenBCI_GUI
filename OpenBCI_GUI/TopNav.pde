///////////////////////////////////////////////////////////////////////////////////////
//
//  Created by Conor Russomanno, 11/3/16
//  Extracting old code Gui_Manager.pde, adding new features for GUI v2 launch
//
///////////////////////////////////////////////////////////////////////////////////////

import java.awt.Desktop;
import java.net.*;

int navBarHeight = 32;
TopNav topNav;

class TopNav {

  // PlotFontInfo fontInfo;

  Button controlPanelCollapser;

  Button fpsButton;
  Button highRezButton;

  Button stopButton;
  public final static String stopButton_pressToStop_txt = "Stop Data Stream";
  public final static String stopButton_pressToStart_txt = "Start Data Stream";

  Button filtBPButton;
  Button filtNotchButton;

  Button tutorialsButton;
  Button shopButton;
  Button issuesButton;


  Button layoutButton;
  Button configButton;

  LayoutSelector layoutSelector;
  TutorialSelector tutorialSelector;
  configSelector configSelector;

  boolean finishedInit = false;

  //constructor
  TopNav(){

    controlPanelCollapser = new Button(3, 3, 256, 26, "System Control Panel", fontInfo.buttonLabel_size);
    controlPanelCollapser.setFont(h3, 16);
    controlPanelCollapser.setIsActive(true);
    controlPanelCollapser.isDropdownButton = true;

    fpsButton = new Button(3+3+256, 3, 73, 26, "XX" + " fps", fontInfo.buttonLabel_size);
    if(frameRateCounter==0){
      fpsButton.setString("24 fps");
    }
    if(frameRateCounter==1){
      fpsButton.setString("30 fps");
    }
    if(frameRateCounter==2){
      fpsButton.setString("45 fps");
    }
    if(frameRateCounter==3){
      fpsButton.setString("60 fps");
    }

    fpsButton.setFont(h3, 16);
    fpsButton.setHelpText("If you're having latency issues, try adjusting the frame rate and see if it helps!");

    highRezButton = new Button(3+3+256+73+3, 3, 26, 26, "XX", fontInfo.buttonLabel_size);
    controlPanelCollapser.setFont(h3, 16);

    //top right buttons from right to left
    int butNum = 1;
    tutorialsButton = new Button(width - 3*(butNum) - 80, 3, 80, 26, "Help", fontInfo.buttonLabel_size);
    tutorialsButton.setFont(h3, 16);
    tutorialsButton.setHelpText("Click to find links to helpful online tutorials and getting started guides. Also, check out how to create custom widgets for the GUI!");

    butNum = 2;
    issuesButton = new Button(width - 3*(butNum) - 80 - tutorialsButton.but_dx, 3, 80, 26, "Issues", fontInfo.buttonLabel_size);
    issuesButton.setHelpText("If you have suggestions or want to share a bug you've found, please create an issue on the GUI's Github repo!");
    issuesButton.setURL("https://github.com/OpenBCI/OpenBCI_GUI/issues");
    issuesButton.setFont(h3, 16);

    butNum = 3;
    shopButton = new Button(width - 3*(butNum) - 80 - issuesButton.but_dx - tutorialsButton.but_dx, 3, 80, 26, "Shop", fontInfo.buttonLabel_size);
    shopButton.setHelpText("Head to our online store to purchase the latest OpenBCI hardware and accessories.");
    shopButton.setURL("http://shop.openbci.com/");
    shopButton.setFont(h3, 16);



    layoutSelector = new LayoutSelector();
    tutorialSelector = new TutorialSelector();
    configSelector = new configSelector();

    updateNavButtonsBasedOnColorScheme();

  }

  void initSecondaryNav(){
    stopButton = new Button(3, 35, 170, 26, stopButton_pressToStart_txt, fontInfo.buttonLabel_size);
    stopButton.setFont(h4, 14);
    stopButton.setColorNotPressed(color(184, 220, 105));
    stopButton.setHelpText("Press this button to Stop/Start the data stream. Or press <SPACEBAR>");

    filtNotchButton = new Button(7 + stopButton.but_dx, 35, 70, 26, "Notch\n" + dataProcessing.getShortNotchDescription(), fontInfo.buttonLabel_size);
    filtNotchButton.setFont(p5, 12);
    filtNotchButton.setHelpText("Here you can adjust the Notch Filter that is applied to all \"Filtered\" data.");

    filtBPButton = new Button(11 + stopButton.but_dx + 70, 35, 70, 26, "BP Filt\n" + dataProcessing.getShortFilterDescription(), fontInfo.buttonLabel_size);
    filtBPButton.setFont(p5, 12);
    filtBPButton.setHelpText("Here you can adjust the Band Pass Filter that is applied to all \"Filtered\" data.");

    //right to left in top right (secondary nav)
    layoutButton = new Button(width - 3 - 60, 35, 60, 26, "Layout", fontInfo.buttonLabel_size);
    layoutButton.setHelpText("Here you can alter the overall layout of the GUI, allowing for different container configurations with more or less widgets.");
    layoutButton.setFont(h4, 14);
    configButton = new Button(width - 3 - 60 - 3 - 60, 35, 60, 26, "Config", fontInfo.buttonLabel_size);
    configButton.setHelpText("Save and Load your GUI configuration!");
    configButton.setFont(h4, 14);
    
    updateSecondaryNavButtonsColor();
  }

  void updateNavButtonsBasedOnColorScheme(){
    if(colorScheme == COLOR_SCHEME_DEFAULT){
      controlPanelCollapser.setColorNotPressed(color(255));
      fpsButton.setColorNotPressed(color(255));
      highRezButton.setColorNotPressed(color(255));
      issuesButton.setColorNotPressed(color(255));
      shopButton.setColorNotPressed(color(255));
      tutorialsButton.setColorNotPressed(color(255));

      controlPanelCollapser.textColorNotActive = color(bgColor);
      fpsButton.textColorNotActive = color(bgColor);
      highRezButton.textColorNotActive = color(bgColor);
      issuesButton.textColorNotActive = color(bgColor);
      shopButton.textColorNotActive = color(bgColor);
      tutorialsButton.textColorNotActive = color(bgColor);


    } else if(colorScheme == COLOR_SCHEME_ALTERNATIVE_A){
      // controlPanelCollapser.setColorNotPressed(color(150));
      // issuesButton.setColorNotPressed(color(150));
      // shopButton.setColorNotPressed(color(150));
      // tutorialsButton.setColorNotPressed(color(150));

      // controlPanelCollapser.setColorNotPressed(bgColor);
      // issuesButton.setColorNotPressed(bgColor);
      // shopButton.setColorNotPressed(bgColor);
      // tutorialsButton.setColorNotPressed(bgColor);

      controlPanelCollapser.setColorNotPressed(openbciBlue);
      fpsButton.setColorNotPressed(openbciBlue);
      highRezButton.setColorNotPressed(openbciBlue);
      issuesButton.setColorNotPressed(openbciBlue);
      shopButton.setColorNotPressed(openbciBlue);
      tutorialsButton.setColorNotPressed(openbciBlue);

      controlPanelCollapser.textColorNotActive = color(255);
      fpsButton.textColorNotActive = color(255);
      highRezButton.textColorNotActive = color(255);
      issuesButton.textColorNotActive = color(255);
      shopButton.textColorNotActive = color(255);
      tutorialsButton.textColorNotActive = color(255);

      // controlPanelCollapser.textColorNotActive = color(openbciBlue);
      // issuesButton.textColorNotActive = color(openbciBlue);
      // shopButton.textColorNotActive = color(openbciBlue);
      // tutorialsButton.textColorNotActive = color(openbciBlue);
      //
      // controlPanelCollapser.textColorNotActive = color(bgColor);
      // issuesButton.textColorNotActive = color(bgColor);
      // shopButton.textColorNotActive = color(bgColor);
      // tutorialsButton.textColorNotActive = color(bgColor);
    }

    if(systemMode >= SYSTEMMODE_POSTINIT){
      updateSecondaryNavButtonsColor();
    }
  }

  void updateSecondaryNavButtonsColor(){
    if(colorScheme == COLOR_SCHEME_DEFAULT){
      filtBPButton.setColorNotPressed(color(255));
      filtNotchButton.setColorNotPressed(color(255));
      layoutButton.setColorNotPressed(color(255));
      configButton.setColorNotPressed(color(255));

      filtBPButton.textColorNotActive = color(bgColor);
      filtNotchButton.textColorNotActive = color(bgColor);
      layoutButton.textColorNotActive = color(bgColor);
      configButton.textColorNotActive = color(bgColor);
    }
    else if(colorScheme == COLOR_SCHEME_ALTERNATIVE_A){
      filtBPButton.setColorNotPressed(color(57,128,204));
      filtNotchButton.setColorNotPressed(color(57,128,204));
      layoutButton.setColorNotPressed(color(57,128,204));
      configButton.setColorNotPressed(color(57,128,204));

      filtBPButton.textColorNotActive = color(255);
      filtNotchButton.textColorNotActive = color(255);
      layoutButton.textColorNotActive = color(255);
      configButton.textColorNotActive = color(255);
    }

  }

  void update(){
    if(systemMode >= SYSTEMMODE_POSTINIT){
      layoutSelector.update();
      tutorialSelector.update();
    }
  }

  void draw(){
    pushStyle();

    if(colorScheme == COLOR_SCHEME_DEFAULT){
      noStroke();
      fill(229);
      rect(0, 0, width, topNav_h);
      stroke(bgColor);
      fill(255);
      rect(-1, 0, width+2, navBarHeight);
      image(logo_blue, width/2 - (128/2) - 2, 6, 128, 22);
    } else if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A){
      noStroke();
      fill(100);
      fill(57,128,204);
      rect(0, 0, width, topNav_h);
      stroke(bgColor);
      fill(31,69,110);
      rect(-1, 0, width+2, navBarHeight);
      image(logo_white, width/2 - (128/2) - 2, 6, 128, 22);
    }

    // if(colorScheme == COLOR_SCHEME_DEFAULT){
    //
    // } else if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A){
    //
    // }

    popStyle();

    if(systemMode == SYSTEMMODE_POSTINIT){
      stopButton.draw();
      filtBPButton.draw();
      filtNotchButton.draw();
      layoutButton.draw();
      configButton.draw();
    }

    controlPanelCollapser.draw();
    fpsButton.draw();
    // highRezButton.draw();
    tutorialsButton.draw();
    issuesButton.draw();
    shopButton.draw();

    // image(logo_blue, width/2 - (128/2) - 2, 6, 128, 22);

    layoutSelector.draw();
    tutorialSelector.draw();
    configSelector.draw();

  }

  void screenHasBeenResized(int _x, int _y){
    tutorialsButton.but_x = width - 3 - tutorialsButton.but_dx;
    issuesButton.but_x = width - 3*2 - issuesButton.but_dx - tutorialsButton.but_dx;
    shopButton.but_x = width - 3*3 - shopButton.but_dx - issuesButton.but_dx - tutorialsButton.but_dx;

    if(systemMode == SYSTEMMODE_POSTINIT){
      layoutButton.but_x = width - 3 - layoutButton.but_dx;
      configButton.but_x = width - (3*2) - (layoutButton.but_dx*2);
      layoutSelector.screenResized();     //pass screenResized along to layoutSelector
      tutorialSelector.screenResized();
      configSelector.screenResized();
    }
  }

  void mousePressed(){
    if(systemMode >= SYSTEMMODE_POSTINIT){
      if (stopButton.isMouseHere()) {
        stopButton.setIsActive(true);
        stopButtonWasPressed();
      }
      if (filtBPButton.isMouseHere()) {
        filtBPButton.setIsActive(true);
        incrementFilterConfiguration();
      }
      if (topNav.filtNotchButton.isMouseHere()) {
        filtNotchButton.setIsActive(true);
        incrementNotchConfiguration();
      }
      if (layoutButton.isMouseHere()) {
        layoutButton.setIsActive(true);
        //toggle layout window to enable the selection of your container layoutButton...
      }
      if (configButton.isMouseHere()) {
        configButton.setIsActive(true);
        //toggle save/load window 
      }
    }

    //was control panel button pushed
    if (controlPanelCollapser.isMouseHere()) {
      if (controlPanelCollapser.isActive && systemMode == SYSTEMMODE_POSTINIT) {
        controlPanelCollapser.setIsActive(false);
        controlPanel.close();
      } else {
        controlPanelCollapser.setIsActive(true);
        // controlPanelCollapser.setIsActive(false);
        controlPanel.open();
      }
    }
    else {
      if (controlPanel.isOpen) {
        controlPanel.CPmousePressed();
      }
    }

    //this is super hacky... but needs to be done otherwise... the controlPanelCollapser doesn't match the open control panel
    if(controlPanel.isOpen){
      controlPanelCollapser.setIsActive(true);
    }

    if(fpsButton.isMouseHere()){
      fpsButton.setIsActive(true);
    }

    // Conor's attempt at adjusting the GUI to be 2x in size for High DPI screens ... attempt failed
    // if(highRezButton.isMouseHere()){
    //   highRezButton.setIsActive(true);
    // }

    if (tutorialsButton.isMouseHere()) {
      tutorialsButton.setIsActive(true);
      //toggle help/tutorial dropdown menu
    }
    if (issuesButton.isMouseHere()) {
      issuesButton.setIsActive(true);
      //toggle help/tutorial dropdown menu
    }
    if (shopButton.isMouseHere()) {
      shopButton.setIsActive(true);
      //toggle help/tutorial dropdown menu
    }

    layoutSelector.mousePressed();     //pass mousePressed along to layoutSelector
    tutorialSelector.mousePressed();
    configSelector.mousePressed();
  }

  void mouseReleased(){

    if (fpsButton.isMouseHere() && fpsButton.isActive()) {
      toggleFrameRate();
    }

    // Conor's attempt at adjusting the GUI to be 2x in size for High DPI screens ... attempt failed
    // if (highRezButton.isMouseHere() && highRezButton.isActive()) {
    //   toggleHighDPI();
    // }

    if (tutorialsButton.isMouseHere() && tutorialsButton.isActive()) {
      tutorialSelector.toggleVisibility();
      tutorialsButton.setIsActive(true);
    }

    if (issuesButton.isMouseHere() && issuesButton.isActive()) {
      //go to Github issues
      issuesButton.goToURL();
    }

    if (shopButton.isMouseHere() && shopButton.isActive()) {
      //go to OpenBCI Shop
      shopButton.goToURL();
    }



    if(systemMode == SYSTEMMODE_POSTINIT){

      if(!tutorialSelector.isVisible){ //make sure that you can't open the layout selector accidentally
        if (layoutButton.isMouseHere() && layoutButton.isActive()) {
          layoutSelector.toggleVisibility();
          layoutButton.setIsActive(true);
          wm.printLayouts();
        }
        if (configButton.isMouseHere() && configButton.isActive()) {
          //layoutSelector.toggleVisibility();
          configSelector.toggleVisibility();         
          configButton.setIsActive(true);

          //wm.printLayouts();
        }
      }

      stopButton.setIsActive(false);
      filtBPButton.setIsActive(false);
      filtNotchButton.setIsActive(false);
      layoutButton.setIsActive(false);
      configButton.setIsActive(false);
    }

    fpsButton.setIsActive(false);
    highRezButton.setIsActive(false);
    tutorialsButton.setIsActive(false);
    issuesButton.setIsActive(false);
    shopButton.setIsActive(false);


    layoutSelector.mouseReleased();    //pass mouseReleased along to layoutSelector
    tutorialSelector.mouseReleased();
    configSelector.mouseReleased();

  }

}

//=============== OLD STUFF FROM Gui_Manger.pde ===============//

void incrementFilterConfiguration() {
  dataProcessing.incrementFilterConfiguration();

  //update the button strings
  topNav.filtBPButton.but_txt = "BP Filt\n" + dataProcessing.getShortFilterDescription();
  // topNav.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
}

void incrementNotchConfiguration() {
  dataProcessing.incrementNotchConfiguration();

  //update the button strings
  topNav.filtNotchButton.but_txt = "Notch\n" + dataProcessing.getShortNotchDescription();
  // topNav.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
}

class LayoutSelector{

  int x, y, w, h, margin, b_w, b_h;
  boolean isVisible;

  ArrayList<Button> layoutOptions; //

  LayoutSelector(){
    w = 180;
    x = width - w - 3;
    y = (navBarHeight * 2) - 3;
    margin = 6;
    b_w = (w - 5*margin)/4;
    b_h = b_w;
    h = margin*3 + b_h*2;


    isVisible = false;

    layoutOptions = new ArrayList<Button>();
    addLayoutOptionButton();
  }

  void update(){
    if(isVisible){ //only update if visible
      // //close dropdown when mouse leaves
      // if((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.layoutButton.isMouseHere()){
      //   toggleVisibility();
      // }
    }
  }

  void draw(){
    if(isVisible){ //only draw if visible
      pushStyle();

      // println("it's happening");
      stroke(bgColor);
      // fill(229); //bg
      fill(57,128,204); //bg
      rect(x, y, w, h);

      for(int i = 0; i < layoutOptions.size(); i++){
        layoutOptions.get(i).draw();
      }

      fill(57,128,204);
      // fill(177, 184, 193);
      noStroke();
      rect(x+w-(topNav.layoutButton.but_dx-1), y, (topNav.layoutButton.but_dx-1), 1);

      popStyle();
    }
  }

  void isMouseHere(){

  }

  void mousePressed(){
    //only allow button interactivity if isVisible==true
    if(isVisible){
      for(int i = 0; i < layoutOptions.size(); i++){
        if(layoutOptions.get(i).isMouseHere()){
          layoutOptions.get(i).setIsActive(true);
        }
      }
    }
  }

  void mouseReleased(){
    //only allow button interactivity if isVisible==true
    if(isVisible){
      if((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.layoutButton.isMouseHere()){
        toggleVisibility();
      }
      for(int i = 0; i < layoutOptions.size(); i++){
        if(layoutOptions.get(i).isMouseHere() && layoutOptions.get(i).isActive()){
          int layoutSelected = i+1;
          println("Layout [" + layoutSelected + "] selected.");
          output("Layout [" + layoutSelected + "] selected.");
          layoutOptions.get(i).setIsActive(false);
          toggleVisibility(); //shut layoutSelector if something is selected
          wm.setNewContainerLayout(layoutSelected-1); //have WidgetManager update Layout and active widgets
          currentLayout = layoutSelected; //copy this value to be used when saving Layout setting
        }
      }
    }
  }

  void screenResized(){
    //update position of outer box and buttons
    int oldX = x;
    x = width - w - 3;
    int dx = oldX - x;
    for(int i = 0; i < layoutOptions.size(); i++){
      layoutOptions.get(i).setX(layoutOptions.get(i).but_x - dx);
    }

  }

  void toggleVisibility(){
    isVisible = !isVisible;
    if(isVisible){
      //the very convoluted way of locking all controllers of a single controlP5 instance...
      for(int i = 0; i < wm.widgets.size(); i++){
        for(int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++){
          wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).lock();
        }
      }

    }else{
      //the very convoluted way of unlocking all controllers of a single controlP5 instance...
      for(int i = 0; i < wm.widgets.size(); i++){
        for(int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++){
          wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).unlock();
        }
      }
    }
  }

  void addLayoutOptionButton(){

    //FIRST ROW

    //setup button 1 -- full screen
    Button tempLayoutButton = new Button(x + margin, y + margin, b_w, b_h, "N/A");
    PImage tempBackgroundImage = loadImage("layout_buttons/layout_1.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 2 -- 2x2
    tempLayoutButton = new Button(x + 2*margin + b_w*1, y + margin, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_2.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 3 -- 2x1
    tempLayoutButton = new Button(x + 3*margin + b_w*2, y + margin, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_3.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 4 -- 1x2
    tempLayoutButton = new Button(x + 4*margin + b_w*3, y + margin, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_4.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //SECOND ROW

    //setup button 5
    tempLayoutButton = new Button(x + margin, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_5.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 6
    tempLayoutButton = new Button(x + 2*margin + b_w*1, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_6.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 7
    tempLayoutButton = new Button(x + 3*margin + b_w*2, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_7.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 8
    tempLayoutButton = new Button(x + 4*margin + b_w*3, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_8.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //THIRD ROW -- commented until more widgets are added

    h = margin*4 + b_h*3;
    //setup button 9
    tempLayoutButton = new Button(x + margin, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_9.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 10
    tempLayoutButton = new Button(x + 2*margin + b_w*1, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_10.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 11
    tempLayoutButton = new Button(x + 3*margin + b_w*2, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_11.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

    //setup button 12
    tempLayoutButton = new Button(x + 4*margin + b_w*3, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
    tempBackgroundImage = loadImage("layout_buttons/layout_12.png");
    tempLayoutButton.setBackgroundImage(tempBackgroundImage);
    layoutOptions.add(tempLayoutButton);

  }

  //void updateLayoutOptionButtons(){}

}

class configSelector{
  int x, y, w, h, margin, b_w, b_h;
  boolean isVisible;

  ArrayList<Button> configOptions; //

  configSelector(){
    w = 120;
    x = width- 3*2 - 60*3 - margin*3;
    y = (navBarHeight * 2) - 3;
    margin = 6;
    b_w = w - margin*2;
    b_h = 22;
    h = margin*3 + b_h*2;

    isVisible = false;

    configOptions = new ArrayList<Button>();
    addConfigButtons();
  }

  void update(){
    if(isVisible){ //only update if visible
      // //close dropdown when mouse leaves
      // if((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.ConfigsButton.isMouseHere()){
      //   toggleVisibility();
      // }
    }
  }

  void draw(){
    if(isVisible == true){ //only draw if visible
      pushStyle();

      //println("it's happening");
      stroke(bgColor);
      // fill(229); //bg
      fill(57,128,204); //bg
      rect(x, y, w, h);

      for(int i = 0; i < configOptions.size(); i++){
        configOptions.get(i).draw();
      }

      fill(57,128,204);
      // fill(177, 184, 193);
      noStroke();
      rect(x+w-(topNav.configButton.but_dx-1), y, (topNav.configButton.but_dx-1), 1);

      popStyle();
    }
  }

  void isMouseHere(){

  }

  void mousePressed(){
    //only allow button interactivity if isVisible==true
    if(isVisible){
      for(int i = 0; i < configOptions.size(); i++){
        if(configOptions.get(i).isMouseHere()){
          configOptions.get(i).setIsActive(true);
          println("config pressed");
        }
      }
    }
  }

  void mouseReleased(){
    //only allow button interactivity if isVisible==true
    if(isVisible){
      if((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.configButton.isMouseHere()){
        toggleVisibility();
      }
      for(int i = 0; i < configOptions.size(); i++){
        if(configOptions.get(i).isMouseHere() && configOptions.get(i).isActive()){
          int ConfigSelected = i;
          configOptions.get(i).setIsActive(false);
          if (ConfigSelected == 0) { //If save button is pressed..
             saveGUISettings(); //save current settings to JSON file in /data/
             output("Settings Saved!"); //print success message to screen
          } else if (ConfigSelected == 1) {
             loadGUISettings(); //load settings from JSON file in /data/
            //Output success message when Loading settings is complete without errors
            if (chanNumError == false && dataSourceError == false) output("Settings Loaded!");
          }
          toggleVisibility(); //shut configSelector if something is selected
          //open corresponding link
        }
      }
    }
  }

  void screenResized(){
    //update position of outer box and buttons
    int oldX = x;
    x = width - 3*2 - 60*3;
    int dx = oldX - x;
    for(int i = 0; i < configOptions.size(); i++){
      configOptions.get(i).setX(configOptions.get(i).but_x - dx);
    }

  }

  void toggleVisibility(){
    isVisible = !isVisible;
    if(systemMode >= SYSTEMMODE_POSTINIT){
      if(isVisible) {
        //the very convoluted way of locking all controllers of a single controlP5 instance...
        for(int i = 0; i < wm.widgets.size(); i++){
          for(int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++){
            wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).lock();
          }
        }

      } else {
        //the very convoluted way of unlocking all controllers of a single controlP5 instance...
        for(int i = 0; i < wm.widgets.size(); i++) {
          for(int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
            wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).unlock();
          }
        }
      }
    }
  }

  void addConfigButtons(){

    //FIRST ROW

    //setup button 1 -- Save Settings
    int buttonNumber = 0;
    Button tempConfigButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Save Settings");
    tempConfigButton.setFont(p5, 12);
    configOptions.add(tempConfigButton);
    
    //setup button 2 -- Load Settings
    buttonNumber = 1;
    h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
    tempConfigButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Load Settings");
    tempConfigButton.setFont(p5, 12);
    configOptions.add(tempConfigButton);

  }

  void updateConfigOptionButtons(){
  //dropdown is static, so no need to update
  }

}  

class TutorialSelector{

  int x, y, w, h, margin, b_w, b_h;
  boolean isVisible;

  ArrayList<Button> tutorialOptions; //

  TutorialSelector(){
    w = 180;
    x = width - w - 3;
    y = (navBarHeight) - 3;
    margin = 6;
    b_w = w - margin*2;
    b_h = 22;
    h = margin*3 + b_h*2;


    isVisible = false;

    tutorialOptions = new ArrayList<Button>();
    addTutorialButtons();
  }

  void update(){
    if(isVisible){ //only update if visible
      // //close dropdown when mouse leaves
      // if((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.tutorialsButton.isMouseHere()){
      //   toggleVisibility();
      // }
    }
  }

  void draw(){
    if(isVisible){ //only draw if visible
      pushStyle();

      // println("it's happening");
      stroke(bgColor);
      // fill(229); //bg
      fill(31,69,110); //bg
      rect(x, y, w, h);

      for(int i = 0; i < tutorialOptions.size(); i++){
        tutorialOptions.get(i).draw();
      }

      fill(openbciBlue);
      // fill(177, 184, 193);
      noStroke();
      rect(x+w-(topNav.tutorialsButton.but_dx-1), y, (topNav.tutorialsButton.but_dx-1) , 1);

      popStyle();
    }
  }

  void isMouseHere(){

  }

  void mousePressed(){
    //only allow button interactivity if isVisible==true
    if(isVisible){
      for(int i = 0; i < tutorialOptions.size(); i++){
        if(tutorialOptions.get(i).isMouseHere()){
          tutorialOptions.get(i).setIsActive(true);
        }
      }
    }
  }

  void mouseReleased(){
    //only allow button interactivity if isVisible==true
    if(isVisible){
      if((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.tutorialsButton.isMouseHere()){
        toggleVisibility();
      }
      for(int i = 0; i < tutorialOptions.size(); i++){
        if(tutorialOptions.get(i).isMouseHere() && tutorialOptions.get(i).isActive()){
          int tutorialSelected = i+1;
          tutorialOptions.get(i).setIsActive(false);
          tutorialOptions.get(i).goToURL();
          println("Attempting to use your default web browser to open " + tutorialOptions.get(i).myURL);
          output("Layout [" + tutorialSelected + "] selected.");
          toggleVisibility(); //shut layoutSelector if something is selected
          //open corresponding link
        }
      }
    }
  }

  void screenResized(){
    //update position of outer box and buttons
    int oldX = x;
    x = width - w - 3;
    int dx = oldX - x;
    for(int i = 0; i < tutorialOptions.size(); i++){
      tutorialOptions.get(i).setX(tutorialOptions.get(i).but_x - dx);
    }

  }

  void toggleVisibility(){
    isVisible = !isVisible;
    if(systemMode >= SYSTEMMODE_POSTINIT){
      if(isVisible) {
        //the very convoluted way of locking all controllers of a single controlP5 instance...
        for(int i = 0; i < wm.widgets.size(); i++){
          for(int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++){
            wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).lock();
          }
        }

      } else {
        //the very convoluted way of unlocking all controllers of a single controlP5 instance...
        for(int i = 0; i < wm.widgets.size(); i++) {
          for(int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
            wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).unlock();
          }
        }
      }
    }
  }

  void addTutorialButtons(){

    //FIRST ROW

    //setup button 1 -- full screen
    int buttonNumber = 0;
    Button tempTutorialButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Getting Started");
    tempTutorialButton.setFont(p5, 12);
    tempTutorialButton.setURL("http://docs.openbci.com/Tutorials/01-Cyton_Getting%20Started_Guide");
    tutorialOptions.add(tempTutorialButton);

    buttonNumber = 1;
    h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
    tempTutorialButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Testing Impedance");
    tempTutorialButton.setFont(p5, 12);
    tempTutorialButton.setURL("http://docs.openbci.com/Tutorials/01-Cyton_Getting%20Started_Guide#cyton-getting-started-guide-v-connect-yourself-to-openbci-4-launch-the-gui-and-adjust-your-channel-settings");
    tutorialOptions.add(tempTutorialButton);

    buttonNumber = 2;
    h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
    tempTutorialButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "OpenBCI Forum");
    tempTutorialButton.setFont(p5, 12);
    tempTutorialButton.setURL("http://openbci.com/index.php/forum/");
    tutorialOptions.add(tempTutorialButton);

    buttonNumber = 3;
    h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
    tempTutorialButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Building Custom Widgets");
    tempTutorialButton.setFont(p5, 12);
    tempTutorialButton.setURL("http://docs.openbci.com/Tutorials/15-Custom_Widgets");
    tutorialOptions.add(tempTutorialButton);

  }

  void updateLayoutOptionButtons(){

  }

}
