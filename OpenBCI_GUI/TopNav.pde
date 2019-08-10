///////////////////////////////////////////////////////////////////////////////////////
//
//  Created by Conor Russomanno, 11/3/16
//  Extracting old code Gui_Manager.pde, adding new features for GUI v2 launch
//
//  Edited by Richard Waltman 9/24/18
//  Added feature to check GUI version using "latest version" tag on Github
///////////////////////////////////////////////////////////////////////////////////////

import java.awt.Desktop;
import java.net.*;
import java.nio.file.*;

int navBarHeight = 32;
TopNav topNav;

class TopNav {

    Button controlPanelCollapser;
    Button fpsButton;
    Button debugButton;

    Button stopButton;

    Button filtBPButton;
    Button filtNotchButton;

    Button tutorialsButton;
    Button shopButton;
    Button issuesButton;
    Button updateGuiVersionButton;
    Button layoutButton;
    Button configButton;

    LayoutSelector layoutSelector;
    TutorialSelector tutorialSelector;
    ConfigSelector configSelector;
    int previousSystemMode = 0;

    String webGUIVersionString;
    int webGUIVersionInt;
    int localGUIVersionInt;
    Boolean guiVersionIsUpToDate;

    //constructor
    TopNav() {
        int w = 256;
        controlPanelCollapser = new Button(3, 3, w, 26, "System Control Panel", fontInfo.buttonLabel_size);
        controlPanelCollapser.setFont(h3, 16);
        controlPanelCollapser.setIsActive(true);
        controlPanelCollapser.isDropdownButton = true;

        fpsButton = new Button(controlPanelCollapser.but_x + controlPanelCollapser.but_dx + 3, 3, 73, 26, "XX" + " fps", fontInfo.buttonLabel_size);
        if (frameRateCounter==0) {
            fpsButton.setString("24 fps");
        }
        if (frameRateCounter==1) {
            fpsButton.setString("30 fps");
        }
        if (frameRateCounter==2) {
            fpsButton.setString("45 fps");
        }
        if (frameRateCounter==3) {
            fpsButton.setString("60 fps");
        }

        fpsButton.setFont(h3, 16);
        fpsButton.setHelpText("If you're having latency issues, try adjusting the frame rate and see if it helps!");
        //highRezButton = new Button(3+3+w+73+3, 3, 26, 26, "XX", fontInfo.buttonLabel_size);
        controlPanelCollapser.setFont(h3, 16);

        //top right buttons from right to left
        debugButton = new Button(width - 33 - 3, 3, 33, 26, " ", fontInfo.buttonLabel_size);
        debugButton.setHelpText("Click to open the Console Log window.");

        tutorialsButton = new Button(debugButton.but_x - 80 - 3, 3, 80, 26, "Help", fontInfo.buttonLabel_size);
        tutorialsButton.setFont(h3, 16);
        tutorialsButton.setHelpText("Click to find links to helpful online tutorials and getting started guides. Also, check out how to create custom widgets for the GUI!");

        issuesButton = new Button(tutorialsButton.but_x - 80 - 3, 3, 80, 26, "Issues", fontInfo.buttonLabel_size);
        issuesButton.setHelpText("If you have suggestions or want to share a bug you've found, please create an issue on the GUI's Github repo!");
        issuesButton.setURL("https://github.com/OpenBCI/OpenBCI_GUI/issues");
        issuesButton.setFont(h3, 16);

        shopButton = new Button(issuesButton.but_x - 80 - 3, 3, 80, 26, "Shop", fontInfo.buttonLabel_size);
        shopButton.setHelpText("Head to our online store to purchase the latest OpenBCI hardware and accessories.");
        shopButton.setURL("http://shop.openbci.com/");
        shopButton.setFont(h3, 16);

        configButton = new Button(width - 70 - 3, 35, 70, 26, "Settings", fontInfo.buttonLabel_size);
        configButton.setHelpText("Save and Load GUI Settings! Click Default to revert to factory settings.");
        configButton.setFont(h4, 14);

        //Lookup and check the local GUI version against the latest Github release
        updateGuiVersionButton = new Button(shopButton.but_x - 80 - 3, 3, 80, 26, "Update", fontInfo.buttonLabel_size);
        try {
            loadGUIVersionData();
            //Print the message to the button help text that appears when mouse hovers over button
            if (!guiVersionCheckHasOccured) {
                if (guiVersionIsUpToDate) {
                    updateGuiVersionButton.setHelpText("GUI is up to date! -- Local: " + localGUIVersionString +  " GitHub: v" + webGUIVersionString);
                } else {
                    updateGuiVersionButton.setHelpText("GUI needs to be updated. -- Local: " + localGUIVersionString +  " GitHub: v" + webGUIVersionString);
                }
                guiVersionCheckHasOccured = true;
            }
        } catch (NullPointerException e)  {
            //e.printStackTrace();
            //If github is unreachable, catch the error update button help text
            updateGuiVersionButton.setHelpText("Connect to internet to check GUI version. -- Local: " + localGUIVersionString);
        }
        //Pressing the button opens web browser to Github latest release page
        updateGuiVersionButton.setURL(guiLatestReleaseLocation);
        updateGuiVersionButton.setFont(h3, 16);



        layoutSelector = new LayoutSelector();
        tutorialSelector = new TutorialSelector();
        configSelector = new ConfigSelector();

        updateNavButtonsBasedOnColorScheme();
    }

    void initSecondaryNav() {
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

        updateSecondaryNavButtonsColor();
    }

    void updateNavButtonsBasedOnColorScheme() {
        if (colorScheme == COLOR_SCHEME_DEFAULT) {
            controlPanelCollapser.setColorNotPressed(color(255));
            fpsButton.setColorNotPressed(color(255));
            debugButton.setColorNotPressed(color(255));
            //highRezButton.setColorNotPressed(color(255));
            issuesButton.setColorNotPressed(color(255));
            shopButton.setColorNotPressed(color(255));
            tutorialsButton.setColorNotPressed(color(255));
            updateGuiVersionButton.setColorNotPressed(color(255));
            configButton.setColorNotPressed(color(255));

            controlPanelCollapser.textColorNotActive = color(bgColor);
            fpsButton.textColorNotActive = color(bgColor);
            debugButton.textColorNotActive = color(bgColor);
            //highRezButton.textColorNotActive = color(bgColor);
            issuesButton.textColorNotActive = color(bgColor);
            shopButton.textColorNotActive = color(bgColor);
            tutorialsButton.textColorNotActive = color(bgColor);
            updateGuiVersionButton.textColorNotActive = color(bgColor);
            configButton.textColorNotActive = color(bgColor);
        } else if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
            controlPanelCollapser.setColorNotPressed(openbciBlue);
            fpsButton.setColorNotPressed(openbciBlue);
            debugButton.setColorNotPressed(openbciBlue);
            //highRezButton.setColorNotPressed(openbciBlue);
            issuesButton.setColorNotPressed(openbciBlue);
            shopButton.setColorNotPressed(openbciBlue);
            tutorialsButton.setColorNotPressed(openbciBlue);
            updateGuiVersionButton.setColorNotPressed(openbciBlue);
            configButton.setColorNotPressed(color(57, 128, 204));

            controlPanelCollapser.textColorNotActive = color(255);
            fpsButton.textColorNotActive = color(255);
            debugButton.textColorNotActive = color(255);
            //highRezButton.textColorNotActive = color(255);
            issuesButton.textColorNotActive = color(255);
            shopButton.textColorNotActive = color(255);
            tutorialsButton.textColorNotActive = color(255);
            updateGuiVersionButton.textColorNotActive = color(255);
            configButton.textColorNotActive = color(255);
        }

        if (systemMode >= SYSTEMMODE_POSTINIT) {
            updateSecondaryNavButtonsColor();
        }
    }

    void updateSecondaryNavButtonsColor() {
        if (colorScheme == COLOR_SCHEME_DEFAULT) {
            filtBPButton.setColorNotPressed(color(255));
            filtNotchButton.setColorNotPressed(color(255));
            layoutButton.setColorNotPressed(color(255));

            filtBPButton.textColorNotActive = color(bgColor);
            filtNotchButton.textColorNotActive = color(bgColor);
            layoutButton.textColorNotActive = color(bgColor);
        } else if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
            filtBPButton.setColorNotPressed(color(57, 128, 204));
            filtNotchButton.setColorNotPressed(color(57, 128, 204));
            layoutButton.setColorNotPressed(color(57, 128, 204));

            filtBPButton.textColorNotActive = color(255);
            filtNotchButton.textColorNotActive = color(255);
            layoutButton.textColorNotActive = color(255);
        }
    }

    void update() {
        if (previousSystemMode != systemMode) {
            if (systemMode >= SYSTEMMODE_POSTINIT) {
                layoutSelector.update();
                tutorialSelector.update();
                if (configButton.but_x != width - (70*2) + 3) {
                    configButton.but_x = width - (70*2) + 3;
                    verbosePrint("TopNav: Updated Settings Button Position");
                }
            } else {
                if (configButton.but_x != width - 70 - 3) {
                    configButton.but_x = width - 70 - 3;
                    verbosePrint("TopNav: Updated Settings Button Position");
                }
            }
            configSelector.update();
            previousSystemMode = systemMode;
        }
    }

    void draw() {
        pushStyle();

        if (colorScheme == COLOR_SCHEME_DEFAULT) {
            noStroke();
            fill(229);
            rect(0, 0, width, topNav_h);
            stroke(bgColor);
            fill(255);
            rect(-1, 0, width+2, navBarHeight);
            //this is the center logo
            image(logo_blue, width/2 - (128/2) - 2, 6, 128, 22);
        } else if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
            noStroke();
            fill(100);
            fill(57, 128, 204);
            rect(0, 0, width, topNav_h);
            stroke(bgColor);
            fill(31, 69, 110);
            rect(-1, 0, width+2, navBarHeight);
            image(logo_white, width/2 - (128/2) - 2, 6, 128, 22);
        }

        popStyle();

        if (systemMode == SYSTEMMODE_POSTINIT) {
            stopButton.draw();
            filtBPButton.draw();
            filtNotchButton.draw();
            layoutButton.draw();
        }

        controlPanelCollapser.draw();
        fpsButton.draw();
        debugButton.draw();
        configButton.draw();
        if (colorScheme == COLOR_SCHEME_DEFAULT) {
            image(consoleImgBlue, debugButton.but_x + 6, debugButton.but_y + 2, 22, 22);
        } else {
            image(consoleImgWhite, debugButton.but_x + 6, debugButton.but_y + 2, 22, 22);
        }
        tutorialsButton.draw();
        issuesButton.draw();
        shopButton.draw();
        updateGuiVersionButton.draw();

        layoutSelector.draw();
        tutorialSelector.draw();
        configSelector.draw();
    }

    void screenHasBeenResized(int _x, int _y) {
        debugButton.but_x = width - debugButton.but_dx - 3;
        tutorialsButton.but_x = debugButton.but_x - 80 - 3;
        issuesButton.but_x = tutorialsButton.but_x - 80 - 3;
        shopButton.but_x = issuesButton.but_x - 80 - 3;
        updateGuiVersionButton.but_x = shopButton.but_x - 80 - 3;
        configButton.but_x = width - configButton.but_dx - 3;

        if (systemMode == SYSTEMMODE_POSTINIT) {
            layoutButton.but_x = width - 3 - layoutButton.but_dx;
            configButton.but_x = width - (configButton.but_dx*2) + 3;
            layoutSelector.screenResized();     //pass screenResized along to layoutSelector
            tutorialSelector.screenResized();
        }
        configSelector.screenResized();
    }

    void mousePressed() {
        if (systemMode >= SYSTEMMODE_POSTINIT) {
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
        } else {
            if (controlPanel.isOpen) {
                controlPanel.CPmousePressed();
            }
        }

        //this is super hacky... but needs to be done otherwise... the controlPanelCollapser doesn't match the open control panel
        if (controlPanel.isOpen) {
            controlPanelCollapser.setIsActive(true);
        }

        if (fpsButton.isMouseHere()) {
            fpsButton.setIsActive(true);
        }

        if (debugButton.isMouseHere()) {
            debugButton.setIsActive(true);
        }

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
        if (updateGuiVersionButton.isMouseHere() && !guiVersionIsUpToDate) {
            updateGuiVersionButton.setIsActive(true);
            //toggle help/tutorial dropdown menu
        }
        if (configButton.isMouseHere()) {
            configButton.setIsActive(true);
            //toggle save/load window
        }


        layoutSelector.mousePressed();     //pass mousePressed along to layoutSelector
        tutorialSelector.mousePressed();
        configSelector.mousePressed();
    }

    void mouseReleased() {

        if (fpsButton.isMouseHere() && fpsButton.isActive()) {
            toggleFrameRate();
        }
        if (debugButton.isMouseHere() && debugButton.isActive()) {
            thread("openConsole");
        }

        if (tutorialsButton.isMouseHere() && tutorialsButton.isActive()) {
            tutorialSelector.toggleVisibility();
            tutorialsButton.setIsActive(true);
            configButton.setIgnoreHover(true);
        }

        if (issuesButton.isMouseHere() && issuesButton.isActive()) {
            //go to Github issues
            issuesButton.goToURL();
        }

        if (shopButton.isMouseHere() && shopButton.isActive()) {
            //go to OpenBCI Shop
            shopButton.goToURL();
        }

        if (updateGuiVersionButton.isMouseHere() && updateGuiVersionButton.isActive()) {
            //go to OpenBCI Shop
            updateGuiVersionButton.goToURL();
        }

        //make Help button and Settings button mutually exclusive
        if (!tutorialSelector.isVisible && configButton.isMouseHere() && configButton.isActive()) {
            configSelector.toggleVisibility();
            configButton.setIsActive(true);
        }

        if (systemMode == SYSTEMMODE_POSTINIT) {
            if (!tutorialSelector.isVisible) { //make sure that you can't open the layout selector accidentally
                if (layoutButton.isMouseHere() && layoutButton.isActive()) {
                    layoutSelector.toggleVisibility();
                    layoutButton.setIsActive(true);
                    //wm.printLayouts(); //Used for debugging
                    println("TopNav: Layout Dropdown Opened");
                }
            }
            stopButton.setIsActive(false);
            filtBPButton.setIsActive(false);
            filtNotchButton.setIsActive(false);
            layoutButton.setIsActive(false);
        }

        fpsButton.setIsActive(false);
        debugButton.setIsActive(false);
        //highRezButton.setIsActive(false);
        tutorialsButton.setIsActive(false);
        issuesButton.setIsActive(false);
        shopButton.setIsActive(false);
        updateGuiVersionButton.setIsActive(false);
        configButton.setIsActive(false);


        layoutSelector.mouseReleased();    //pass mouseReleased along to layoutSelector
        tutorialSelector.mouseReleased();
        configSelector.mouseReleased();
    } //end mouseReleased

    //Load data from the latest release page from Github and the info.plist file
    void loadGUIVersionData() {

        //Get the latest release version from Github
        String webTitle;
        String[] version;
        String[] lines = loadStrings(guiLatestReleaseLocation);
        String html = join(lines, "");
        String start = "<title>";
        String end = "</title>";
        webTitle = giveMeTextBetween(html, start, end);
        version = split(webTitle, '·'); //split the string in the html title
        String[] webVersionNumberArray = split(version[0], ' ');

        webGUIVersionString = removeV(webVersionNumberArray[1]);
        webGUIVersionString = removeAlphaBeta(webGUIVersionString);

        //Copy the local GUI version from OpenBCI_GUI.pde
        String localVersionString = localGUIVersionString;
        localVersionString = removeV(localVersionString);
        localVersionString = removeAlphaBeta(localVersionString);

        ///////Perform Comparison (000-1000 format)
        int[] webVersionCompareArray = int(split(webGUIVersionString, '.'));
        int[] localVersionCompareArray = int(split(localVersionString, '.'));
        webGUIVersionInt = webVersionCompareArray[0]*100 + webVersionCompareArray[1]*10 + webVersionCompareArray[2];
        localGUIVersionInt = localVersionCompareArray[0]*100 + localVersionCompareArray[1]*10 + localVersionCompareArray[2];
        println("Local Version: " + localGUIVersionInt + ", Latest Version: " + webGUIVersionInt);
        if (localGUIVersionInt < webGUIVersionInt) {
            guiVersionIsUpToDate = false;
            println("GUI needs to be updated. Download at https://github.com/OpenBCI/OpenBCI_GUI/releases/latest");
        } else if (localGUIVersionInt >= webGUIVersionInt) {
            guiVersionIsUpToDate = true;
            println("GUI is up to date!");
        }
    }

    // This function returns a substring between two substrings (before and after).
    String giveMeTextBetween(String s, String before, String after) {
        // Find the index of before
        int start = s.indexOf(before);
        if (start == -1) {
            return "";
        }

        // Move to the end of the beginning tag
        // and find the index of the "after" String
        start += before.length();
        int end = s.indexOf(after, start);
        if (end == -1) {
            return "";
        }

        // Return the text in between
        return s.substring(start, end);
    }

    String removeV(String s) {
        if (s.charAt(0) == 'v') {
            String[] tempArr = split(s, 'v');
            s = tempArr[1];
        }
        return s;
    }

    String removeAlphaBeta(String s) {
        if (s.length() > 5) {
            String[] tempArr = split(s, '-');
            s = tempArr[0];
        }
        return s;
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

class LayoutSelector {

    int x, y, w, h, margin, b_w, b_h;
    boolean isVisible;

    ArrayList<Button> layoutOptions; //

    LayoutSelector() {
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

    void update() {
        if (isVisible) { //only update if visible
            // //close dropdown when mouse leaves
            // if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.layoutButton.isMouseHere()){
            //   toggleVisibility();
            // }
        }
    }

    void draw() {
        if (isVisible) { //only draw if visible
            pushStyle();

            stroke(bgColor);
            // fill(229); //bg
            fill(57, 128, 204); //bg
            rect(x, y, w, h);

            for (int i = 0; i < layoutOptions.size(); i++) {
                layoutOptions.get(i).draw();
            }

            fill(57, 128, 204);
            // fill(177, 184, 193);
            noStroke();
            rect(x+w-(topNav.layoutButton.but_dx-1), y, (topNav.layoutButton.but_dx-1), 1);

            popStyle();
        }
    }

    void isMouseHere() {
    }

    void mousePressed() {
        //only allow button interactivity if isVisible==true
        if (isVisible) {
            for (int i = 0; i < layoutOptions.size(); i++) {
                if (layoutOptions.get(i).isMouseHere()) {
                    layoutOptions.get(i).setIsActive(true);
                }
            }
        }
    }

    void mouseReleased() {
        //only allow button interactivity if isVisible==true
        if (isVisible) {
            if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.layoutButton.isMouseHere()) {
                toggleVisibility();
            }
            for (int i = 0; i < layoutOptions.size(); i++) {
                if (layoutOptions.get(i).isMouseHere() && layoutOptions.get(i).isActive()) {
                    int layoutSelected = i+1;
                    println("Layout [" + layoutSelected + "] selected.");
                    output("Layout [" + layoutSelected + "] selected.");
                    layoutOptions.get(i).setIsActive(false);
                    toggleVisibility(); //shut layoutSelector if something is selected
                    wm.setNewContainerLayout(layoutSelected-1); //have WidgetManager update Layout and active widgets
                    settings.currentLayout = layoutSelected; //copy this value to be used when saving Layout setting
                }
            }
        }
    }

    void screenResized() {
        //update position of outer box and buttons
        int oldX = x;
        x = width - w - 3;
        int dx = oldX - x;
        for (int i = 0; i < layoutOptions.size(); i++) {
            layoutOptions.get(i).setX(layoutOptions.get(i).but_x - dx);
        }
    }

    void toggleVisibility() {
        isVisible = !isVisible;
        if (isVisible) {
            //the very convoluted way of locking all controllers of a single controlP5 instance...
            for (int i = 0; i < wm.widgets.size(); i++) {
                for (int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
                    wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).lock();
                }
            }
        } else {
            //the very convoluted way of unlocking all controllers of a single controlP5 instance...
            for (int i = 0; i < wm.widgets.size(); i++) {
                for (int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
                    wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).unlock();
                }
            }
        }
    }

    void addLayoutOptionButton() {

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
}

class ConfigSelector {
    int x, y, w, h, margin, b_w, b_h;
    boolean clearAllSettingsPressed;
    boolean isVisible;
    ArrayList<Button> configOptions;
    int configHeight = 0;
    color newGreen = color(114,204,171);
    color expertPurple = color(135,95,154);
    color cautionRed = color(214,100,100);

    int osPadding = 0;
    int osPadding2 = 0;
    int buttonSpacer = 0;

    ConfigSelector() {
        int _padding = (systemMode == SYSTEMMODE_POSTINIT) ? -3 : 3;
        w = 120;
        x = width - 70*2 - _padding + 20;
        y = (navBarHeight * 2) - 3;
        margin = 6;
        b_w = w - margin*2;
        b_h = 22;
        h = margin*3 + b_h;
        //makes the setting text "are you sure" display correctly on linux
        osPadding = isLinux() ? -3 : -2;
        osPadding2 = isLinux() ? 5 : 0;

        isVisible = false;

        configOptions = new ArrayList<Button>();
        addConfigButtons();
    }

    void update() {
        updateConfigButtonPositions();
    }

    void draw() {
        if (isVisible) { //only draw if visible
            pushStyle();

            stroke(bgColor);
            fill(57, 128, 204); //bg
            rect(x, y, w, h);

            //configOptions.get(0).draw();
            if (systemMode == SYSTEMMODE_POSTINIT) {
                for (int i = 0; i < 4; i++) {
                    configOptions.get(i).draw();
                }
            }
            configOptions.get(4).draw();
            if (clearAllSettingsPressed) {
                int fontSize = 16;
                textFont(p2, fontSize);
                fill(255);
                text("Are You Sure?", x + margin, y + margin*(buttonSpacer + osPadding) + b_h*(buttonSpacer-1) + osPadding2);
                configOptions.get(configOptions.size()-2).draw();
                configOptions.get(configOptions.size()-1).draw();
            }

            fill(57, 128, 204);
            noStroke();
            //This makes the dropdown box look like it's apart of the button by drawing over the bottom edge of the button
            rect(x+w-(topNav.configButton.but_dx-1), y, (topNav.configButton.but_dx-1), 1);

            popStyle();
        }
    }

    void isMouseHere() {
    }

    void mousePressed() {
        //only allow button interactivity if isVisible==true
        if (isVisible) {
            for (int i = 0; i < configOptions.size(); i++) {
                //Allow interaction with all settings buttons after init
                if (systemMode == SYSTEMMODE_POSTINIT) {
                    if (i >= 0 && i < 5) {
                        if (configOptions.get(i).isMouseHere()) {
                            configOptions.get(i).setIsActive(true);
                            //println("TopNav: Settings: Button Pressed");
                        }
                    } else if (i == 5 || i == 6){
                        if (configOptions.get(i).isMouseHere() && clearAllSettingsPressed) {
                            configOptions.get(i).setIsActive(true);
                            //println("TopNav: ClearSettings: AreYouSure? Button Pressed");
                        }
                    }
                //Before system start, Only allow interaction with "Expert Mode" and "Clear All"
                } else if (systemMode == SYSTEMMODE_PREINIT) {
                    if (i == 4) {
                        if (configOptions.get(i).isMouseHere()) {
                            configOptions.get(i).setIsActive(true);
                            //println("TopNav: Settings: Clear Settings Pressed");
                        }
                    } else if (i == 5 || i == 6){
                        if (configOptions.get(i).isMouseHere() && clearAllSettingsPressed) {
                            configOptions.get(i).setIsActive(true);
                            //println("TopNav: ClearSettings: AreYouSure? Button Pressed");
                        }
                    }
                }
            }
        }
    }

    void mouseReleased() {
        //only allow button interactivity if isVisible==true
        if (isVisible) {
            if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.configButton.isMouseHere()) {
                toggleVisibility();
                clearAllSettingsPressed = false;
            }
            for (int i = 0; i < configOptions.size(); i++) {
                if (configOptions.get(i).isMouseHere() && configOptions.get(i).isActive()) {
                    int configSelected = i;
                    configOptions.get(i).setIsActive(false);
                    if (configSelected == 0) { //If expert mode toggle button is pressed...
                        if (configOptions.get(0).getButtonText().equals("Expert Mode Off")) {
                            configOptions.get(0).setString("Expert Mode On");
                            configOptions.get(0).setColorNotPressed(expertPurple);
                            println("TopNav: Expert Mode On");
                            settings.expertModeToggle = true;
                        } else {
                            configOptions.get(0).setString("Expert Mode Off");
                            configOptions.get(0).setColorNotPressed(newGreen);
                            println("TopNav: Expert Mode Off");
                            settings.expertModeToggle = false;
                        }
                    } else if (configSelected == 1) { ////Save Button
                        settings.saveButtonPressed();
                    } else if (configSelected == 2) { ////Load Button
                        settings.loadButtonPressed();
                    } else if (configSelected == 3) { ////Default Button
                        settings.defaultButtonPressed();
                    } else if (configSelected == 4) { ///ClearAllSettings Button
                        clearAllSettingsPressed = true;
                        //expand the height of the dropdown
                        h = margin*(buttonSpacer+2) + b_h*(buttonSpacer+1);
                    } else if (configSelected == 5 && clearAllSettingsPressed) {
                        //Do nothing because the user clicked Are You Sure?->No
                        clearAllSettingsPressed = false;
                    } else if (configSelected == 6 && clearAllSettingsPressed) {
                        //User has selected Are You Sure?->Yes
                        settings.clearAll();
                        clearAllSettingsPressed = false;
                        //Stop the system if the user clears all settings
                        if (systemMode == SYSTEMMODE_POSTINIT) {
                            haltSystem();
                        }
                    }
                    //shut configSelector if something other than clear settings was pressed
                    if (!clearAllSettingsPressed) toggleVisibility();
                } //end case mouseHere && Active
            } //end for all configOptions loop
        }
    }

    void screenResized() {
        updateConfigButtonPositions();
    }

    void toggleVisibility() {
        isVisible = !isVisible;
        if (systemMode >= SYSTEMMODE_POSTINIT) {
            if (isVisible) {
                //the very convoluted way of locking all controllers of a single controlP5 instance...
                for (int i = 0; i < wm.widgets.size(); i++) {
                    for (int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
                        wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).lock();
                    }
                }
                //resize the height of the settings dropdown
                h = margin*(configOptions.size()-4) + b_h*(configOptions.size()-1);
                clearAllSettingsPressed = false;
            } else {
                //the very convoluted way of unlocking all controllers of a single controlP5 instance...
                for (int i = 0; i < wm.widgets.size(); i++) {
                    for (int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
                        wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).unlock();
                    }
                }
            }
        } else if ((systemMode < SYSTEMMODE_POSTINIT) && isVisible && topNav.configButton.isActive()) {
            //resize the height of the settings dropdown
            h = margin*2 + b_h;
            clearAllSettingsPressed = false;
        }
    }

    void addConfigButtons() {
        //Customize initial button appearance here
        //setup button 0 -- Expert Mode Toggle Button
        int buttonNumber = 0;
        Button tempConfigButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Expert Mode Off");
        tempConfigButton.setFont(p5, 12);
        tempConfigButton.setColorNotPressed(newGreen);
        tempConfigButton.setFontColorNotActive(color(255));
        tempConfigButton.setHelpText("Expert Mode enables advanced keyboard shortcuts and access to all GUI features.");
        configOptions.add(tempConfigButton);

        //setup button 1 -- Save Custom Settings
        buttonNumber++;
        tempConfigButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Save");
        tempConfigButton.setFont(p5, 12); 
        configOptions.add(tempConfigButton);

        //setup button 2 -- Load Custom Settings
        buttonNumber++;
        tempConfigButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Load");
        tempConfigButton.setFont(p5, 12);
        configOptions.add(tempConfigButton);

        //setup button 3 -- Default Settings
        buttonNumber++;
        tempConfigButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Default");
        tempConfigButton.setFont(p5, 12);
        configOptions.add(tempConfigButton);

        //setup button 4 -- Clear All Settings
        buttonNumber = 0;
        //Update the height of the Settings dropdown
        h = margin*(buttonNumber+1) + b_h*(buttonNumber+1);
        tempConfigButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Clear All");
        tempConfigButton.setFont(p5, 12);
        tempConfigButton.setColorNotPressed(cautionRed);
        tempConfigButton.setFontColorNotActive(color(255));
        tempConfigButton.setHelpText("This will clear all user settings and playback history. You will be asked to confirm.");
        configOptions.add(tempConfigButton);

        //setup button 5 -- Are You Sure? No
        buttonNumber++;
        //leave space for "Are You Sure?"
        tempConfigButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber+1), b_w, b_h, "No");
        tempConfigButton.setFont(p5, 12);
        configOptions.add(tempConfigButton);


        //setup button 6 -- Are You Sure? Yes
        buttonNumber++;
        tempConfigButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber+1), b_w, b_h, "Yes");
        tempConfigButton.setFont(p5, 12);
        tempConfigButton.setHelpText("Clicking 'Yes' will delete all user settings and stop the session if running.");
        configOptions.add(tempConfigButton);
    }

    void updateConfigButtonPositions() {
        //update position of outer box and buttons
        int oldX = x;
        int multiplier = (systemMode == SYSTEMMODE_POSTINIT) ? 3 : 2;
        int _padding = (systemMode == SYSTEMMODE_POSTINIT) ? -3 : 3;
        x = width - 70*multiplier - _padding + 20;
        int dx = oldX - x;
        buttonSpacer = (systemMode == SYSTEMMODE_POSTINIT) ? configOptions.size() : configOptions.size() - 4;
        if (systemMode == SYSTEMMODE_POSTINIT) {
            for (int i = 0; i < configOptions.size(); i++) {
                configOptions.get(i).setX(x + multiplier*2);
                int spacer = (i > configOptions.size() - 3) ? 1 : 0;
                int newY = y + margin*(i+spacer+1) + b_h*(i+spacer);
                configOptions.get(i).setY(newY);
            }
        } else if (systemMode < SYSTEMMODE_POSTINIT) {
            int[] t = {4, 5, 6}; //button numbers
            for (int i = 0; i < t.length; i++) {
                configOptions.get(t[i]).setX(configOptions.get(t[i]).but_x - dx);
                int spacer = (t[i] > 4) ? i + 1 : i;
                int newY = y + margin*(spacer+1) + b_h*(spacer);
                configOptions.get(t[i]).setY(newY);
            }
        }
        //println("TopNav: ConfigSelector: Button Positions Updated");
    }
}

class TutorialSelector {

    int x, y, w, h, margin, b_w, b_h;
    boolean isVisible;

    ArrayList<Button> tutorialOptions; //

    TutorialSelector() {
        w = 180;
        //account for consoleLog button, help button, and spacing
        x = width - 33 - w - 3*2;
        y = (navBarHeight) - 3;
        margin = 6;
        b_w = w - margin*2;
        b_h = 22;
        h = margin*3 + b_h*2;


        isVisible = false;

        tutorialOptions = new ArrayList<Button>();
        addTutorialButtons();
    }

    void update() {
        if (isVisible) { //only update if visible
            // //close dropdown when mouse leaves
            // if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.tutorialsButton.isMouseHere()){
            //   toggleVisibility();
            // }
        }
    }

    void draw() {
        if (isVisible) { //only draw if visible
            pushStyle();

            stroke(bgColor);
            // fill(229); //bg
            fill(31, 69, 110); //bg
            rect(x, y, w, h);

            for (int i = 0; i < tutorialOptions.size(); i++) {
                tutorialOptions.get(i).draw();
            }

            fill(openbciBlue);
            // fill(177, 184, 193);
            noStroke();
            rect(x+w-(topNav.tutorialsButton.but_dx-1), y, (topNav.tutorialsButton.but_dx-1), 1);

            popStyle();
        }
    }

    void isMouseHere() {
    }

    void mousePressed() {
        //only allow button interactivity if isVisible==true
        if (isVisible) {
            for (int i = 0; i < tutorialOptions.size(); i++) {
                if (tutorialOptions.get(i).isMouseHere()) {
                    tutorialOptions.get(i).setIsActive(true);
                }
            }
        }
    }

    void mouseReleased() {
        //only allow button interactivity if isVisible==true
        if (isVisible) {
            if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.tutorialsButton.isMouseHere()) {
                toggleVisibility();
                topNav.configButton.setIgnoreHover(false);
            }
            for (int i = 0; i < tutorialOptions.size(); i++) {
                if (tutorialOptions.get(i).isMouseHere() && tutorialOptions.get(i).isActive()) {
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

    void screenResized() {
        //update position of outer box and buttons
        int oldX = x;
        x = width - w - 3;
        int dx = oldX - x;
        for (int i = 0; i < tutorialOptions.size(); i++) {
            tutorialOptions.get(i).setX(tutorialOptions.get(i).but_x - dx);
        }
    }

    void toggleVisibility() {
        isVisible = !isVisible;
        if (systemMode >= SYSTEMMODE_POSTINIT) {
            if (isVisible) {
                //the very convoluted way of locking all controllers of a single controlP5 instance...
                for (int i = 0; i < wm.widgets.size(); i++) {
                    for (int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
                        wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).lock();
                    }
                }
            } else {
                //the very convoluted way of unlocking all controllers of a single controlP5 instance...
                for (int i = 0; i < wm.widgets.size(); i++) {
                    for (int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
                        wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).unlock();
                    }
                }
            }
        }
    }

    void addTutorialButtons() {

        //FIRST ROW

        //setup button 1 -- full screen
        int buttonNumber = 0;
        Button tempTutorialButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Getting Started");
        tempTutorialButton.setFont(p5, 12);
        tempTutorialButton.setURL("https://docs.openbci.com/Tutorials/01-Cyton_Getting%20Started_Guide");
        tutorialOptions.add(tempTutorialButton);

        buttonNumber = 1;
        h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
        tempTutorialButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Testing Impedance");
        tempTutorialButton.setFont(p5, 12);
        tempTutorialButton.setURL("https://docs.openbci.com/OpenBCI%20Software/01-OpenBCI_GUI#the-openbci-gui-impedance-testing");
        tutorialOptions.add(tempTutorialButton);

        buttonNumber = 2;
        h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
        tempTutorialButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "OpenBCI Forum");
        tempTutorialButton.setFont(p5, 12);
        tempTutorialButton.setURL("https://openbci.com/index.php/forum/");
        tutorialOptions.add(tempTutorialButton);

        buttonNumber = 3;
        h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
        tempTutorialButton = new Button(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Building Custom Widgets");
        tempTutorialButton.setFont(p5, 12);
        tempTutorialButton.setURL("https://docs.openbci.com/Tutorials/16-Custom_Widgets");
        tutorialOptions.add(tempTutorialButton);
    }
}
