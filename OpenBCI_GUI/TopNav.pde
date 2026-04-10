///////////////////////////////////////////////////////////////////////////////////////
//
//  Created by Conor Russomanno, 11/3/16
//  Extracting old code Gui_Manager.pde, adding new features for GUI v2 launch
//
//  Edited by Richard Waltman 9/24/18
//  Refactored by Richard Waltman 11/9/2020
//  Added feature to check GUI version using "latest version" tag on Github
///////////////////////////////////////////////////////////////////////////////////////

import java.awt.Desktop;
import java.nio.file.*;

class TopNav {
    private color strokeColor = OPENBCI_DARKBLUE;

    private ControlP5 topNav_cp5;

    public Button controlPanelCollapser;

    public Button toggleDataStreamingButton;

    public Button filtersButton;
    public Button smoothingButton;

    public Button debugButton;
    public Button screenshotButton;
    public Button tutorialsButton;
    public Button updateGuiVersionButton;

    public Button layoutButton;
    public Button settingsButton;
    public Button networkButton;

    public LayoutSelector layoutSelector;
    public TutorialSelector tutorialSelector;
    public ConfigSelector configSelector;
    private int previousSystemMode = 0;

    private boolean secondaryNavInit = false;

    private final int PAD_3 = 3;
    private final int DEBUG_BUT_W = 33;
    private final int TOPRIGHT_BUT_W = 80;
    private final int DATASTREAM_BUT_W = 170;
    private final int SUBNAV_BUT_Y = 35;
    private final int SUBNAV_BUT_W = 70;
    private final int SUBNAV_BUT_H = 26;
    private final int TOPNAV_BUT_H = SUBNAV_BUT_H;
    private final int NETWORK_BUT_W = 100;
    private final int CONFIG_SELECTOR_W = 150;

    private boolean topNavDropdownMenuIsOpen = true;

    TopNav() {
        int controlPanel_W = 256;

        //Instantiate local cp5 for this box
        topNav_cp5 = new ControlP5(ourApplet);
        topNav_cp5.setGraphics(ourApplet, 0, 0);
        topNav_cp5.setAutoDraw(false);

        //TOP LEFT OF GUI
        createControlPanelCollapser("System Control Panel", PAD_3, PAD_3, controlPanel_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);

        //TOP RIGHT OF GUI, FROM LEFT<---Right
        createDebugButton(" ", width - DEBUG_BUT_W - PAD_3, PAD_3, DEBUG_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createScreenshotButton(" ", (int)debugButton.getPosition()[0] - DEBUG_BUT_W - PAD_3, PAD_3, DEBUG_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createTutorialsButton("Docs", (int)screenshotButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createUpdateGuiButton("Update", (int)tutorialsButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);

        //SUBNAV TOP RIGHT
        createTopNavSettingsButton("Settings", width - SUBNAV_BUT_W - PAD_3, SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, h4, 14, SUBNAV_LIGHTBLUE, WHITE);
        
        tutorialSelector = new TutorialSelector();
        configSelector = new ConfigSelector(width - (SUBNAV_BUT_W * 2) - PAD_3, (navBarHeight * 2) - PAD_3, CONFIG_SELECTOR_W);

        try {
            updateNavButtonsBasedOnColorScheme();
            updateSecondaryNavButtonsColor();
        } catch (Exception e) {
            outputError("TopNav: Error initializing buttons. " + e);
        }
    }

    void initSecondaryNav() {
        boolean needToMakeSmoothingButton = (currentBoard instanceof SmoothingCapableBoard) && smoothingButton == null;

        if (!secondaryNavInit) {
            //Buttons on the left side of the GUI secondary nav bar
            createToggleDataStreamButton(stopButton_pressToStart_txt, PAD_3, SUBNAV_BUT_Y, DATASTREAM_BUT_W, SUBNAV_BUT_H, h4, 14, TURN_ON_GREEN, OPENBCI_DARKBLUE);
            createFiltersButton("Filters", PAD_3*2 + toggleDataStreamingButton.getWidth(), SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, h4, 14, SUBNAV_LIGHTBLUE, WHITE);

            //Appears at Top Right SubNav while in a Session
            createLayoutButton("Layout", width - SUBNAV_BUT_W - PAD_3, SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, h4, 14, SUBNAV_LIGHTBLUE, WHITE);
            createNetworkButton("Network", width - (SUBNAV_BUT_W*2) - PAD_3*2, SUBNAV_BUT_Y, NETWORK_BUT_W, SUBNAV_BUT_H, h4, 14, SUBNAV_LIGHTBLUE, WHITE);
            layoutSelector = new LayoutSelector();
            secondaryNavInit = true;
        }

        if (needToMakeSmoothingButton) {
            int pos_x = (int)filtersButton.getPosition()[0] + filtersButton.getWidth() + PAD_3;
            //Make smoothing button wider than most other topnav buttons to fit text comfortably
            createSmoothingButton(getSmoothingString(), pos_x, SUBNAV_BUT_Y, SUBNAV_BUT_W + 40, SUBNAV_BUT_H, h4, 14, SUBNAV_LIGHTBLUE, WHITE);
        }  
    }

    void updateNavButtonsBasedOnColorScheme() {
        color _colorNotPressed = WHITE;
        color _textColorNotActive = OPENBCI_DARKBLUE;
        color borderColor = OPENBCI_DARKBLUE;

        if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
            _colorNotPressed = OPENBCI_BLUE;
            _textColorNotActive = WHITE;
        }

        controlPanelCollapser.setColorBackground(_colorNotPressed);
        debugButton.setColorBackground(_colorNotPressed);
        screenshotButton.setColorBackground(_colorNotPressed);
        tutorialsButton.setColorBackground(_colorNotPressed);
        //updateGuiVersionButton.setColorBackground(_colorNotPressed);

        controlPanelCollapser.getCaptionLabel().setColor(_textColorNotActive);
        debugButton.getCaptionLabel().setColor(_textColorNotActive);
        screenshotButton.getCaptionLabel().setColor(_textColorNotActive);
        tutorialsButton.getCaptionLabel().setColor(_textColorNotActive);
        //updateGuiVersionButton.getCaptionLabel().setColor(_textColorNotActive);
        
        controlPanelCollapser.setBorderColor(borderColor);
        debugButton.setBorderColor(borderColor);
        screenshotButton.setBorderColor(borderColor);
        tutorialsButton.setBorderColor(borderColor);
        //updateGuiVersionButton.setBorderColor(borderColor);
    }

    void updateSecondaryNavButtonsColor() {
        color _colorNotPressed = WHITE;
        color _textColorNotActive = OPENBCI_DARKBLUE;
        color borderColor = OPENBCI_DARKBLUE;

        if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
            _colorNotPressed = SUBNAV_LIGHTBLUE;
            _textColorNotActive = WHITE;
        }

        settingsButton.setColorBackground(_colorNotPressed);
        settingsButton.getCaptionLabel().setColor(_textColorNotActive);
        settingsButton.setBorderColor(borderColor);

        if (systemMode >= SYSTEMMODE_POSTINIT) {
            filtersButton.setColorBackground(_colorNotPressed);
            layoutButton.setColorBackground(_colorNotPressed);
            networkButton.setColorBackground(_colorNotPressed);

            filtersButton.getCaptionLabel().setColor(_textColorNotActive);
            layoutButton.getCaptionLabel().setColor(_textColorNotActive);
            networkButton.getCaptionLabel().setColor(_textColorNotActive);

            filtersButton.setBorderColor(borderColor);
            layoutButton.setBorderColor(borderColor);
            networkButton.setBorderColor(borderColor);
        }

        if (currentBoard instanceof SmoothingCapableBoard) {
            smoothingButton.getCaptionLabel().setColor(_textColorNotActive);
            smoothingButton.setColorBackground(_colorNotPressed);
            smoothingButton.setBorderColor(borderColor);
        }
    }

    void update() {
        //ignore settings button when help dropdown is open
        settingsButton.setLock(tutorialSelector.isVisible);

        //Make sure these buttons don't get accidentally locked
        if (systemMode >= SYSTEMMODE_POSTINIT) {
            setLockTopLeftSubNavCp5Objects(controlPanel.isOpen);
            networkButton.setLock(tutorialSelector.isVisible);
            layoutButton.setLock(tutorialSelector.isVisible);
        }

        if (previousSystemMode != systemMode) {
            if (systemMode >= SYSTEMMODE_POSTINIT) {
                tutorialSelector.update();
            }

            updateNavButtonsBasedOnColorScheme();
            updateSecondaryNavButtonsColor();

            previousSystemMode = systemMode;
        }

        boolean layoutSelectorIsOpen = systemMode >= SYSTEMMODE_POSTINIT ? layoutSelector.isVisible : false;
        boolean topNavSubClassIsOpen = layoutSelectorIsOpen || configSelector.isVisible || tutorialSelector.isVisible;
        setDropdownMenuIsOpen(topNavSubClassIsOpen);
    }

    void draw() {
        PImage logo;
        int logo_w = 128;
        int logo_h = 22;
        color topNavBg;
        color subNavBg;
        
        if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
            topNavBg = OPENBCI_BLUE;
            subNavBg = SUBNAV_LIGHTBLUE;
            logo = logo_white;
        } else {
            topNavBg = WHITE;
            subNavBg = color(229);
            logo = logo_black;
        }

        //Draw background rectangles for TopNav and SubNav
        pushStyle();
        //stroke(OPENBCI_DARKBLUE);
        fill(topNavBg);
        rect(0, 0, width, navBarHeight);
        //noStroke();
        stroke(strokeColor);
        fill(subNavBg);
        rect(-1, navBarHeight, width+2, navBarHeight);
        popStyle();

        //hide the center logo if buttons would overlap it
        if (width > 860) {
            //this is the center logo
            image(logo, width/2 - (128/2) - 2, 1, 128, 29);
        }

        //Draw these buttons during a Session
        boolean isSession = systemMode == SYSTEMMODE_POSTINIT;
        if (secondaryNavInit) {
            toggleDataStreamingButton.setVisible(isSession);
            filtersButton.setVisible(isSession);
            layoutButton.setVisible(isSession);
            networkButton.setVisible(isSession);
        }
        if (smoothingButton != null) {
            smoothingButton.setVisible(isSession);
        }

        //Draw CP5 Objects
        topNav_cp5.draw();

        //Draw Network Button Status Circle on top of cp5 object
        if (isSession) {
            drawNetworkButtonStatusCircle();
        }

        //Draw everything in these selector boxes above all topnav cp5 objects
        if (isSession) {
            layoutSelector.draw();
        }
        configSelector.draw();
        tutorialSelector.draw();

        //Draw Console Log Image on top of cp5 object
        PImage _logo = (colorScheme == COLOR_SCHEME_DEFAULT) ? consoleImgBlue : consoleImgWhite;
        image(_logo, debugButton.getPosition()[0] + 6, debugButton.getPosition()[1] + 2, 22, 22);
        //Draw camera image on top of cp5 object
        image(screenshotImgWhite, screenshotButton.getPosition()[0] + 6, screenshotButton.getPosition()[1] + 2, 22, 22);
    }

    void screenHasBeenResized(int _x, int _y) {
        topNav_cp5.setGraphics(ourApplet, 0, 0); //Important!
        debugButton.setPosition(width - debugButton.getWidth() - PAD_3, PAD_3);
        screenshotButton.setPosition((int)debugButton.getPosition()[0] - screenshotButton.getWidth() - PAD_3, PAD_3);
        tutorialsButton.setPosition((int)screenshotButton.getPosition()[0] - tutorialsButton.getWidth() - PAD_3, PAD_3);
        //updateGuiVersionButton.setPosition(debugButton.getPosition()[0] - debugButton.getWidth() - PAD_3, PAD_3);
        settingsButton.setPosition(width - SUBNAV_BUT_W - PAD_3, SUBNAV_BUT_Y);

        if (systemMode == SYSTEMMODE_POSTINIT) {
            toggleDataStreamingButton.setPosition(PAD_3, SUBNAV_BUT_Y);
            filtersButton.setPosition(PAD_3*2 + toggleDataStreamingButton.getWidth(), SUBNAV_BUT_Y);

            layoutButton.setPosition(width - (SUBNAV_BUT_W*2) - PAD_3*2, SUBNAV_BUT_Y);
            networkButton.setPosition(width - (SUBNAV_BUT_W*2) - NETWORK_BUT_W - (PAD_3*3), SUBNAV_BUT_Y);
            //Make sure to re-position UI in selector boxes
            layoutSelector.screenResized();
        }
        
        tutorialSelector.screenResized();
        configSelector.screenResized();
    }

    void mouseReleased() {
        if (systemMode == SYSTEMMODE_POSTINIT) {
            layoutSelector.mouseReleased();
        }
        tutorialSelector.mouseReleased();
        configSelector.mouseReleased();
    }

    //Load data from the latest release page using Github API and compare to local version
    public Boolean guiVersionIsUpToDate() {
        //Copy the local GUI version from OpenBCI_GUI.pde
        float localVersion = getVersionAsFloat(localGUIVersionString);

        boolean internetIsConnected = pingWebsite(guiLatestVersionGithubAPI);

        if (internetIsConnected) {
            println("TopNav: Internet Connection Successful");
            //Get the latest release version from Github
            String remoteVersionString = getGUIVersionFromInternet(guiLatestVersionGithubAPI);
            float remoteVersion = getVersionAsFloat(remoteVersionString);   
            
            println("Local Version: " + localGUIVersionString + ", Latest Version: " + remoteVersionString);

            if (localVersion < remoteVersion) {
                println("GUI needs to be updated. Download at https://github.com/OpenBCI/OpenBCI_GUI/releases/latest");
                updateGuiVersionButton.setDescription("GUI needs to be updated. -- Local: " + localGUIVersionString +  " GitHub: " + remoteVersionString);
                return false;
            } else {
                println("GUI is up to date!");
                updateGuiVersionButton.setDescription("GUI is up to date! -- Local: " + localGUIVersionString +  " GitHub: " + remoteVersionString);
                return true;
            }
        } else {
            println("TopNav: Internet Connection Not Available");
            println("Local GUI Version: " + localGUIVersionString);
            updateGuiVersionButton.setDescription("Connect to internet to check GUI version. -- Local: " + localGUIVersionString);
            return null;
        }
    }

    private String getGUIVersionFromInternet(String _url) {
        String version = null;
        try {
            GetRequest get = new GetRequest(_url);
            get.send(); // program will wait untill the request is completed
            JSONObject response = parseJSONObject(get.getContent());
            version = response.getString("name");
        } catch (Exception e) {
            outputError("Network Error: Unable to resolve host @ " + _url);
        }
        return version;
    }

    //Convert version string to float using each segment as a digit.
    //Examples: 5.0.0-alpha.2 -> 500.12, 5.0.1-beta.9 -> 501.29, 5.0.1 -> 501.5
    private float getVersionAsFloat(String s) {
        float val = 0f;
        
        //Remove v
        if (s.charAt(0) == 'v') {
            String[] tempArr = split(s, 'v');
            s = tempArr[1];
        }
        
        //Check for minor version
        if (s.length() > 5) {
            String[] minorVersion = split(s, '-'); //separate the string at the dash between "5.0.0" and "alpha.2"
            s = minorVersion[0];
            String[] mv = split(minorVersion[1], '.');
            if (mv[0].equals("alpha")) {
                val += .1;
            } else if (mv[0].equals("beta")) {
                val += .2;
            }
            val += Integer.parseInt(mv[1]) * .01;
        } else {
            val += .5; //For stable version, add .5 so that it is greater than all alpha and beta versions
        }

        int[] webVersionCompareArray = int(split(s, '.'));
        val = webVersionCompareArray[0]*100 + webVersionCompareArray[1]*10 + webVersionCompareArray[2] + val;
        
        return val;
    }

    public void updateSmoothingButtonText() {
        smoothingButton.getCaptionLabel().setText(getSmoothingString());
    }

    private String getSmoothingString() {
        return ((SmoothingCapableBoard)currentBoard).getSmoothingActive() ? "Smoothing On" : "Smoothing Off";
    }

    private Button createTNButton(String name, String text, int _x, int _y, int _w, int _h, PFont _font, int _fontSize, color _bg, color _textColor) {
        return createButton(topNav_cp5, name, text, _x, _y, _w, _h, 0, _font, _fontSize, _bg, _textColor, BUTTON_HOVER, BUTTON_PRESSED, OPENBCI_DARKBLUE, -1);
    }

    private void createControlPanelCollapser(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        controlPanelCollapser = createTNButton("controlPanelCollapser", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        controlPanelCollapser.setSwitch(true);
        controlPanelCollapser.setOn();
        controlPanelCollapser.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               if (controlPanelCollapser.isOn()) {
                   controlPanel.open();
               } else {
                   controlPanel.close();
               }
            }
        });
    }

    private void createToggleDataStreamButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        toggleDataStreamingButton = createTNButton("toggleDataStreamingButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        toggleDataStreamingButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               dataStreamTogglePressed();
            }
        });
        toggleDataStreamingButton.setDescription("Press this button to Stop/Start the data stream. Or press <SPACEBAR>");
    }

    private void createFiltersButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        filtersButton = createTNButton("filtersButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        filtersButton.onRelease(new CallbackListener() {
            public synchronized void controlEvent(CallbackEvent theEvent) {
                if (!filterUIPopupIsOpen) {
                    filterUI = new FilterUIPopup();
                } else {
                    filterUI.exitPopup();
                    filterUI = null;
                }
            }
        });
        filtersButton.setDescription("Here you can adjust the Filters that are applied to \"Filtered\" data.");
    }

    private void createNetworkButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        networkButton = createTNButton("networkButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        networkButton.onRelease(new CallbackListener() {
            public synchronized void controlEvent(CallbackEvent theEvent) {
                if (!networkingUIPopupIsOpen) {
                    networkUI = new NetworkingUI();
                } else {
                    networkUI.exitPopup();
                    networkUI = null;
                }
            }
        });
        networkButton.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
        networkButton.getCaptionLabel().getStyle().setPaddingLeft(5);
        networkButton.setDescription("Configure network outputs from the OpenBCI GUI. Click \"Help\" -> \"Networking\" for more info.");
    }

    private void drawNetworkButtonStatusCircle() {
        float[] xy = networkButton.getPosition();
        float circleX = xy[0] + networkButton.getWidth() - networkButton.getWidth()/5 + 4;
        float circleY = xy[1] + networkButton.getHeight()/2 + 1;
        pushStyle();
        textFont(h4, 14);
        float circleH = textAscent();
        stroke(OPENBCI_DARKBLUE);
        strokeWeight(1);
        fill(dataProcessing.networkingSettings.getNetworkingIsStreaming() ? TURN_ON_GREEN : GREY_125);
        ellipseMode(CENTER);
        ellipse(circleX, circleY, circleH, circleH);
        popStyle();
    }

    private void createSmoothingButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, final color _bg, color _textColor) {
        SmoothingCapableBoard smoothBoard = (SmoothingCapableBoard)currentBoard;
        color bgColor = smoothBoard.getSmoothingActive() ? _bg : BUTTON_LOCKED_GREY;
        smoothingButton = createTNButton("smoothingButton", text, _x, _y, _w, _h, font, _fontSize, bgColor, _textColor);
        smoothingButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                SmoothingCapableBoard smoothBoard = (SmoothingCapableBoard)currentBoard;
                smoothBoard.setSmoothingActive(!smoothBoard.getSmoothingActive());
                smoothingButton.getCaptionLabel().setText(getSmoothingString());
                color _bgColor = smoothBoard.getSmoothingActive() ? _bg : BUTTON_LOCKED_GREY;
                smoothingButton.setColorBackground(_bgColor);
            }
        });
        smoothingButton.setDescription("The default settings for the Cyton Dongle driver can make data appear \"choppy.\" This feature will \"smooth\" the data for you. Click \"Help\" -> \"Cyton Driver Fix\" for more info. Clicking here will toggle this setting.");
    }

    private void createLayoutButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        layoutButton = createTNButton("layoutButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        layoutButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                layoutSelector.toggleVisibility();
            }
        });
        layoutButton.setDescription("Here you can alter the overall layout of the GUI, allowing for different container configurations with more or less widgets.");
    }

    private void createDebugButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        debugButton = createTNButton("debugButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        debugButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               ConsoleWindow.display();
            }
        });
        debugButton.setDescription("Click to open the Console Log window.");
    }

    private void createTutorialsButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        tutorialsButton = createTNButton("tutorialsButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        tutorialsButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               tutorialSelector.toggleVisibility();
            }
        });
        tutorialsButton.setDescription("Click to find links to helpful online tutorials and getting started guides. Also, check out how to create custom widgets for the GUI!");
    }

    private void createScreenshotButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        screenshotButton = createTNButton("screenshotButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        screenshotButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               takeGUIScreenshot();
            }
        });
        screenshotButton.setDescription("Click to take a screenshot of the GUI! Screenshots are saved to Documents/OpenBCI_GUI/Screenshots/.");
    }

    private void createUpdateGuiButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        updateGuiVersionButton = createTNButton("updateGuiVersionButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        //Attempt to compare local and remote GUI versions when TopNav is instantiated
        //This will also set the description/help-text for this cp5 button
        //Do this check on app start and store as a global variable
        guiIsUpToDate = guiVersionIsUpToDate();

        updateGuiVersionButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //Perform check again when button is pressed. User may have connected to internet by now!
                guiIsUpToDate = guiVersionIsUpToDate();

                if (guiIsUpToDate == null) {
                    outputError("Update GUI: Unable to check for new version of GUI. Try again when connected to the internet.");
                    return;
                }

                if (!guiIsUpToDate) {
                    openURLInBrowser(guiLatestReleaseLocation);
                    outputInfo("Update GUI: Opening latest GUI release page using default browser");
                } else {
                    outputSuccess("Update GUI: Local OpenBCI GUI is up-to-date!");
                }
            }
        });

        if (guiIsUpToDate == null) {
            return;
        }

        if (!guiIsUpToDate) {
            outputWarn("Update Available! Press the \"Update\" button at the top of the GUI to download the latest version.");
        }
    }

    private void createTopNavSettingsButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        settingsButton = createTNButton("settingsButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        settingsButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //make Help button and Settings button mutually exclusive
                if (!tutorialSelector.isVisible) {
                    configSelector.toggleVisibility();
                }
            }
        });
        settingsButton.setDescription("Save and Load GUI Settings! Click Default to revert to factory settings.");
    }

    //Execute this function whenver the stop button is pressed
    public void dataStreamTogglePressed() {

        //Exit method if doing Cyton impedance check. Avoids a BrainFlow error.
        if (currentBoard instanceof BoardCyton && widgetManager.getWidgetExists("W_CytonImpedance")) {
            Integer checkingImpOnChan = ((ImpedanceSettingsBoard)currentBoard).isCheckingImpedanceOnChannel();
            W_CytonImpedance cytonImpedanceWidget = (W_CytonImpedance) widgetManager.getWidget("W_CytonImpedance");
            if (checkingImpOnChan != null || cytonImpedanceWidget.cytonMasterImpedanceCheckIsActive() || cytonImpedanceWidget.getIsCheckingImpedanceOnAnything()) {
                PopupMessage msg = new PopupMessage("Busy Checking Impedance", "Please turn off impedance check to begin recording the data stream.");
                println("OpenBCI_GUI::Cyton: Please turn off impedance check to begin recording the data stream.");
                return;
            }
        }

        if (currentBoard.isStreaming()) {
            output("OpenBCI_GUI: stopButton was pressed. Stopping data transfer, wait a few seconds.");
            stopRunning();
            if (!currentBoard.isStreaming()) {
                toggleDataStreamingButton.getCaptionLabel().setText(stopButton_pressToStart_txt);
                toggleDataStreamingButton.setColorBackground(TURN_ON_GREEN);
            }
        } else {
            output("OpenBCI_GUI: startButton was pressed. Starting data transfer, wait a few seconds.");
            dataProcessing.clearCalculatedMetricWidgets();
            startRunning();
            if (currentBoard.isStreaming()) {
                toggleDataStreamingButton.getCaptionLabel().setText(stopButton_pressToStop_txt);
                toggleDataStreamingButton.setColorBackground(TURN_OFF_RED);
            }
        }
    }

    public boolean dataStreamingButtonIsActive() {
        return toggleDataStreamingButton.getCaptionLabel().getText().equals(stopButton_pressToStop_txt);
    }

    public void resetStartStopButton() {
        if (toggleDataStreamingButton != null) {
            toggleDataStreamingButton.getCaptionLabel().setText(stopButton_pressToStart_txt);
            toggleDataStreamingButton.setColorBackground(TURN_ON_GREEN);
        }
    }

    public void destroySmoothingButton() {
        topNav_cp5.remove("smoothingButton");
        smoothingButton = null;
    }

    public void setLockTopLeftSubNavCp5Objects(boolean _b) {
        toggleDataStreamingButton.setLock(_b);
        filtersButton.setLock(_b);
    }

    public boolean getDropdownMenuIsOpen() {
        return topNavDropdownMenuIsOpen;
    }

    public void setDropdownMenuIsOpen(boolean b) {
        topNavDropdownMenuIsOpen = b;
    }
}

class LayoutSelector {

    public int x, y, w, h, margin, b_w, b_h;
    public boolean isVisible;
    private ControlP5 layout_cp5;
    public ArrayList<Button> layoutOptions;

    LayoutSelector() {
        w = 180;
        x = width - w - 3;
        y = (navBarHeight * 2) - 3;
        margin = 6;
        b_w = (w - 5*margin)/4;
        b_h = b_w;
        h = margin*4 + b_h*3;

        isVisible = false;
        
        //Instantiate local cp5 for this box
        layout_cp5 = new ControlP5(ourApplet);
        layout_cp5.setGraphics(ourApplet, 0,0);
        layout_cp5.setAutoDraw(false);

        layoutOptions = new ArrayList<Button>();
        addLayoutOptionButtons();
        screenResized();
    }

    public void draw() {
        if (isVisible) { //only draw if visible
            pushStyle();
            color strokeColor = OPENBCI_DARKBLUE;
            color fillColor = SUBNAV_LIGHTBLUE;

            stroke(strokeColor);
            // fill(229); //bg
            fill(fillColor); //bg
            rect(x, y, w, h);

            // fill(177, 184, 193);
            noStroke();
            rect(x+w-(topNav.layoutButton.getWidth()-1), y, (topNav.layoutButton.getWidth()-1), 1);

            popStyle();

            layout_cp5.draw();
        }
    }

    public void mouseReleased() {
        //only allow button interactivity if isVisible==true
        if (isVisible) {
            if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.layoutButton.isInside()) {
                toggleVisibility();
            }

        }
    }

    void screenResized() {
        layout_cp5.setGraphics(ourApplet, 0,0);
        //update position of outer box and buttons
        //int oldX = x;
        x = width - topNav.layoutButton.getWidth() - w - 3*2;
        //int dx = oldX - x;

        for (int i = 0; i < layoutOptions.size(); i++) {
            int row = (i/4)%4;
            int column = i%4;
            layoutOptions.get(i).setPosition(x + (column+1)*margin + (b_w*column), y + (row+1)*margin + row*b_h);
        }
    }

    void toggleVisibility() {
        isVisible = !isVisible;
        if (widgetManager != null) {
            widgetManager.lockCp5ObjectsInAllWidgets(isVisible);
        }
    }

    private void addLayoutOptionButtons() {
        final int numLayouts = 12;
        for (int i = 0; i < numLayouts; i++) {
            int row = (i/4)%4;
            int column = i%4;
            final int layoutNumber = i;
            Button tempLayoutButton = createButton(layout_cp5, "layoutButton"+i, "", x + (column+1)*margin + (b_w*column), y + (row+1)*margin + (row*b_h), b_w, b_h);
            PImage tempBackgroundImage = loadImage("layout_buttons/layout_"+(i+1)+".png");
            tempBackgroundImage.resize(b_w, b_h);
            tempLayoutButton.setImage(tempBackgroundImage);
            tempLayoutButton.setForceDrawBackground(true);
            tempLayoutButton.onRelease(new CallbackListener() {
                public void controlEvent(CallbackEvent theEvent) {
                    output("Layout [" + (layoutNumber) + "] selected.");
                    toggleVisibility(); //shut layoutSelector if something is selected
                    widgetManager.setNewContainerLayout(layoutNumber); //have WidgetManager update Layout and active widgets
                    sessionSettings.currentLayout = layoutNumber; //copy this value to be used when saving Layout setting
                }
            });
            layoutOptions.add(tempLayoutButton);
        }
    }
}

class ConfigSelector {
    private int x, y, w, h, margin, b_w, b_h;
    private boolean clearAllSettingsPressed;
    public boolean isVisible;
    private ControlP5 settings_cp5;
    private Button expertMode;
    private Button autoStartDataStream;
    private Button autoStartNetworkStream;
    private Button autoLoadSessionSettings;
    private Button saveSessionSettings;
    private Button loadSessionSettings;
    private Button defaultSessionSettings;
    private Button clearAllGUISettings;
    private Button clearAllSettingsNo;
    private Button clearAllSettingsYes;

    private int configHeight = 0;

    private int osPadding = 0;
    private int osPadding2 = 0;
    private int buttonSpacer = 0;

    ConfigSelector(int _x, int _y, int _w) {
        //int _padding = (systemMode == SYSTEMMODE_POSTINIT) ? -3 : 3;
        x = _x;
        y = _y;
        w = _w;
        margin = 6;
        b_w = w - margin*2;
        b_h = 22;
        h = margin*10 + b_h*9;
        //makes the setting text "are you sure" display correctly on linux
        osPadding = isLinux() ? -3 : -2;
        osPadding2 = isLinux() ? 5 : 0;

        //Instantiate local cp5 for this box
        settings_cp5 = new ControlP5(ourApplet);
        settings_cp5.setGraphics(ourApplet, 0,0);
        settings_cp5.setAutoDraw(false);

        isVisible = false;

        int buttonNumber = 0;
        createExpertModeButton("expertMode", "Turn Expert Mode On", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createAutoStartDataStreamButton("autoStartDataStream", "Auto Start Data Stream", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createAutoStartNetworkStreamButton("autoStartNetworkStream", "Auto Start Network Stream", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createAutoLoadSessionSettingsButton("autoLoadSessionSettings", "Auto Load Session Settings", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createSaveSettingsButton("saveSessionSettings", "Save", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createLoadSettingsButton("loadSessionSettings", "Load", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createDefaultSettingsButton("defaultSessionSettings", "Default", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createClearAllSettingsButton("clearAllGUISettings", "Clear All", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber += 2;
        createClearSettingsNoButton("clearAllSettingsNo", "No", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createClearSettingsYesButton("clearAllSettingsYes", "Yes", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
    }

    public void draw() {
        if (isVisible) { //only draw if visible
            color strokeColor = OPENBCI_DARKBLUE;
            color fillColor = SUBNAV_LIGHTBLUE;
            
            pushStyle();

            stroke(strokeColor);
            fill(fillColor); //bg
            rect(x, y, w, h);

            boolean isSessionStarted = (systemMode == SYSTEMMODE_POSTINIT);
            saveSessionSettings.setVisible(isSessionStarted);
            loadSessionSettings.setVisible(isSessionStarted);
            defaultSessionSettings.setVisible(isSessionStarted);

            if (clearAllSettingsPressed) {
                textFont(p2, 16);
                fill(255);
                textAlign(CENTER);
                text("Are You Sure?", x + w/2, clearAllGUISettings.getPosition()[1] + b_h*2);
            }
            clearAllSettingsYes.setVisible(clearAllSettingsPressed);
            clearAllSettingsNo.setVisible(clearAllSettingsPressed);

            fill(fillColor);
            noStroke();
            //This makes the dropdown box look like it's apart of the button by drawing over the part that overlaps
            rect(x+w-(topNav.settingsButton.getWidth()-1), y, (topNav.settingsButton.getWidth()-1), 1);

            popStyle();

            settings_cp5.draw();
        }
    }

    public void mouseReleased() {
        //only allow button interactivity if isVisible==true
        if (isVisible) {
            if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.settingsButton.isInside()) {
                toggleVisibility();
                clearAllSettingsPressed = false;
            }
        }
    }

    public void screenResized() {
        settings_cp5.setGraphics(ourApplet, 0,0);
        updateConfigButtonPositions();
    }

    private void updateConfigButtonPositions() {
        //update position of outer box and buttons
        final boolean isSessionStarted = (systemMode == SYSTEMMODE_POSTINIT);
        int oldX = x;
        x = width - w - 3;
        int dx = oldX - x;

        h = !isSessionStarted ? margin*6 + b_h*5 : margin*9 + b_h*8;

        //Update the Y position for the clear settings buttons
        float clearSettingsButtonY = !isSessionStarted ? 
            autoLoadSessionSettings.getPosition()[1] + margin + b_h : 
            defaultSessionSettings.getPosition()[1] + margin + b_h;
        clearAllGUISettings.setPosition(clearAllGUISettings.getPosition()[0], clearSettingsButtonY);
        clearAllSettingsNo.setPosition(clearAllSettingsNo.getPosition()[0], clearSettingsButtonY + margin*2 + b_h*2);
        clearAllSettingsYes.setPosition(clearAllSettingsYes.getPosition()[0], clearSettingsButtonY + margin*3 + b_h*3);
        
        //Update the X position for all buttons
        for (int j = 0; j < settings_cp5.getAll().size(); j++) {
            Button c = (Button) settings_cp5.getController(settings_cp5.getAll().get(j).getAddress());
            c.setPosition(c.getPosition()[0] - dx, c.getPosition()[1]);
        }

        //println("TopNav: ConfigSelector: Button Positions Updated");
    }

    void toggleVisibility() {
        isVisible = !isVisible;
        if (widgetManager != null) {
            widgetManager.lockCp5ObjectsInAllWidgets(isVisible);
            clearAllSettingsPressed = !isVisible;
        }

        //When closed by any means and confirmation buttons are open...
        //Hide confirmation buttons and shorten height of this box
        if (clearAllSettingsPressed && !isVisible) {
            //Shorten height of this box
            h -= margin*4 + b_h*3;
            clearAllSettingsPressed = false;
        }

        updateConfigButtonPositions();
    }

    private void createAutoStartDataStreamButton(String name, String text, int _x, int _y, int _w, int _h) {
        autoStartDataStream = createButton(settings_cp5, name, text, _x, _y, _w, _h, p5, 12, BUTTON_NOOBGREEN, WHITE);
        autoStartDataStream.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                boolean isActive = !guiSettings.getAutoStartDataStream();
                toggleAutoStartDataStreamFrontEnd(isActive);
                String outputMsg = isActive ?
                    "Auto-Start Data Stream ON: Data stream will start automatically when the GUI is opened." : 
                    "Auto-Start Data Stream OFF: Use spacebar to start/stop the data stream.";
                output(outputMsg);
                guiSettings.setAutoStartDataStream(isActive);
            }
        });
    }

    private void createAutoStartNetworkStreamButton(String name, String text, int _x, int _y, int _w, int _h) {
        autoStartNetworkStream = createButton(settings_cp5, name, text, _x, _y, _w, _h, p5, 12, BUTTON_NOOBGREEN, WHITE);
        autoStartNetworkStream.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                boolean isActive = !guiSettings.getAutoStartNetworkStream();
                toggleAutoStartNetworkStreamFrontEnd(isActive);
                String outputMsg = isActive ?
                    "Auto-Start Network Stream ON: Network stream will start automatically when the GUI is opened." : 
                    "Auto-Start Network Stream OFF: Open the Network UI to start the stream.";
                output(outputMsg);
                guiSettings.setAutoStartNetworkStream(isActive);
            }
        });
    }

    private void createAutoLoadSessionSettingsButton(String name, String text, int _x, int _y, int _w, int _h) {
        autoLoadSessionSettings = createButton(settings_cp5, name, text, _x, _y, _w, _h, p5, 12, BUTTON_NOOBGREEN, WHITE);
        autoLoadSessionSettings.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                boolean isActive = !guiSettings.getAutoLoadSessionSettings();
                toggleAutoLoadSessionSettingsFrontEnd(isActive);
                String outputMsg = isActive ?
                    "Auto-Load Session Settings ON: Session settings will load automatically when the GUI is opened." : 
                    "Auto-Load Session Settings OFF: Use the Settings UI to load session settings.";
                output(outputMsg);
                guiSettings.setAutoLoadSessionSettings(isActive);
            }
        });
    }

    private void createExpertModeButton(String name, String text, int _x, int _y, int _w, int _h) {
        expertMode = createButton(settings_cp5, name, text, _x, _y, _w, _h, p5, 12, BUTTON_NOOBGREEN, WHITE);
        expertMode.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                boolean isActive = !guiSettings.getExpertModeBoolean();
                toggleExpertModeFrontEnd(isActive);
                String outputMsg = isActive ?
                    "Expert Mode ON: All keyboard shortcuts and features are enabled!" : 
                    "Expert Mode OFF: Use spacebar to start/stop the data stream.";
                output(outputMsg);
                guiSettings.setExpertMode(isActive ? ExpertModeEnum.ON : ExpertModeEnum.OFF);
            }
        });
        expertMode.setDescription("Expert Mode enables advanced keyboard shortcuts and access to all GUI features.");
    }

    private void createSaveSettingsButton(String name, String text, int _x, int _y, int _w, int _h) {
        saveSessionSettings = createButton(settings_cp5, name, text, _x, _y, _w, _h);
        saveSessionSettings.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                sessionSettings.saveButtonPressed();
            }
        });
        saveSessionSettings.setDescription("Expert Mode enables advanced keyboard shortcuts and access to all GUI features.");
    }

    private void createLoadSettingsButton(String name, String text, int _x, int _y, int _w, int _h) {
        loadSessionSettings = createButton(settings_cp5, name, text, _x, _y, _w, _h);
        loadSessionSettings.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                sessionSettings.loadButtonPressed();
            }
        });
        loadSessionSettings.setDescription("Expert Mode enables advanced keyboard shortcuts and access to all GUI features.");
    }

    private void createDefaultSettingsButton(String name, String text, int _x, int _y, int _w, int _h) {
        defaultSessionSettings = createButton(settings_cp5, name, text, _x, _y, _w, _h);
        defaultSessionSettings.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                sessionSettings.defaultButtonPressed();
            }
        });
        defaultSessionSettings.setDescription("Expert Mode enables advanced keyboard shortcuts and access to all GUI features.");
    }

    private void createClearAllSettingsButton(String name, String text, int _x, int _y, int _w, int _h) {
        clearAllGUISettings = createButton(settings_cp5, name, text, _x, _y, _w, _h, p5, 12, BUTTON_CAUTIONRED, WHITE);
        clearAllGUISettings.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //Leave box open if this button was pressed and toggle flag
                clearAllSettingsPressed = !clearAllSettingsPressed;
                //Expand or shorten height of this box
                final int delta_h = margin*4 + b_h*3;
                h += clearAllSettingsPressed ? delta_h : -delta_h;
            }
        });
        clearAllGUISettings.setDescription("This will clear all user settings and playback history. You will be asked to confirm.");
    }

    private void createClearSettingsNoButton(String name, String text, int _x, int _y, int _w, int _h) {
        clearAllSettingsNo = createButton(settings_cp5, name, text, _x, _y, _w, _h);
        clearAllSettingsNo.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                //Do nothing because the user clicked Are You Sure?->No
                clearAllSettingsPressed = false;
                //Shorten height of this box
                h -= margin*4 + b_h*3;
            }
        });
    }

    private void createClearSettingsYesButton(String name, String text, int _x, int _y, int _w, int _h) {
        clearAllSettingsYes = createButton(settings_cp5, name, text, _x, _y, _w, _h);
        clearAllSettingsYes.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                //Shorten height of this box
                h -= margin*4 + b_h*3;
                //User has selected Are You Sure?->Yes
                sessionSettings.clearAll();
                guiSettings.resetAllSettings();
                clearAllSettingsPressed = false;
                //Stop the system if the user clears all settings
                if (systemMode == SYSTEMMODE_POSTINIT) {
                    haltSystem();
                }
            }
        });
        clearAllSettingsYes.setDescription("Clicking 'Yes' will delete all user settings and stop the session if running.");
    }

    public void toggleExpertModeFrontEnd(boolean b) {
        if (b) {
            expertMode.getCaptionLabel().setText("Turn Expert Mode Off");
            expertMode.setColorBackground(BUTTON_EXPERTPURPLE);
        } else {
            expertMode.getCaptionLabel().setText("Turn Expert Mode On");
            expertMode.setColorBackground(BUTTON_NOOBGREEN);
        }
    } 

    public void toggleAutoStartDataStreamFrontEnd(boolean b) {
        if (b) {
            autoStartDataStream.getCaptionLabel().setText("Auto-Start Data On");
            autoStartDataStream.setColorBackground(BUTTON_EXPERTPURPLE);
        } else {
            autoStartDataStream.getCaptionLabel().setText("Auto-Start Data Off");
            autoStartDataStream.setColorBackground(BUTTON_NOOBGREEN);
        }
    }

    public void toggleAutoStartNetworkStreamFrontEnd(boolean b) {
        if (b) {
            autoStartNetworkStream.getCaptionLabel().setText("Auto-Start Network On");
            autoStartNetworkStream.setColorBackground(BUTTON_EXPERTPURPLE);
        } else {
            autoStartNetworkStream.getCaptionLabel().setText("Auto-Start Network Off");
            autoStartNetworkStream.setColorBackground(BUTTON_NOOBGREEN);
        }
    }

    public void toggleAutoLoadSessionSettingsFrontEnd(boolean b) {
        if (b) {
            autoLoadSessionSettings.getCaptionLabel().setText("Auto-Load Settings On");
            autoLoadSessionSettings.setColorBackground(BUTTON_EXPERTPURPLE);
        } else {
            autoLoadSessionSettings.getCaptionLabel().setText("Auto-Load Settings Off");
            autoLoadSessionSettings.setColorBackground(BUTTON_NOOBGREEN);
        }
    }
}

class TutorialSelector {

    private int x, y, w, h, margin, b_w, b_h;
    public boolean isVisible;
    private ControlP5 tutorial_cp5;
    private Button gettingStarted;
    private Button troubleshootingGuide;
    private final int NUM_TUTORIAL_BUTTONS = 2;

    TutorialSelector() {
        w = 140;
        //account for consoleLog button, help button, and spacing
        x = width - 9 - w - 3*2;
        y = (navBarHeight) - 3;
        margin = 6;
        b_w = w - margin*2;
        b_h = 22;
        h = margin*(NUM_TUTORIAL_BUTTONS+1) + b_h*NUM_TUTORIAL_BUTTONS;

        //Instantiate local cp5 for this box
        tutorial_cp5 = new ControlP5(ourApplet);
        tutorial_cp5.setGraphics(ourApplet, 0,0);
        tutorial_cp5.setAutoDraw(false);

        isVisible = false;

        int buttonNumber = 0;
        createGettingStartedButton("gettingStarted", "Getting Started", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createTroubleshootingGuideButton("troubleshootingGuide", "Troubleshooting", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
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

            color strokeColor = OPENBCI_DARKBLUE;
            color fillColor = OPENBCI_BLUE;

            pushStyle();

            stroke(strokeColor);
            // fill(229); //bg
            fill(fillColor); //bg
            rect(x, y, w, h);


            // fill(177, 184, 193);
            noStroke();
            //Draw a tiny rectangle to make it look like the box and button are connected
            rect(x + 1 , y, (topNav.tutorialsButton.getWidth()-1), 1);            

            popStyle();

            tutorial_cp5.draw();
        }
    }

    void mouseReleased() {
        //only allow button interactivity if isVisible==true
        if (isVisible) {
            if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.tutorialsButton.isInside()) {
                toggleVisibility();
                //topNav.configButton.setIgnoreHover(false);
            }
        }
    }

    void screenResized() {
        tutorial_cp5.setGraphics(ourApplet, 0,0);

        //update position of outer box and buttons. Y values do not change for this box.
        int oldX = x;
        x = width - 9 - w - 3*2;
        int dx = oldX - x;

        for (int j = 0; j < tutorial_cp5.getAll().size(); j++) {
            Button c = (Button) tutorial_cp5.getController(tutorial_cp5.getAll().get(j).getAddress());
            c.setPosition(c.getPosition()[0] - dx, c.getPosition()[1]);
        }
    }

    void toggleVisibility() {
        isVisible = !isVisible;
        if (widgetManager != null) {
            widgetManager.lockCp5ObjectsInAllWidgets(isVisible);
        }
    }

    private void createGettingStartedButton(String name, String text, int _x, int _y, int _w, int _h) {
        gettingStarted = createButton(tutorial_cp5, name, text, _x, _y, _w, _h);
        gettingStarted.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                openURLInBrowser("https://docs.openbci.com/GettingStarted/GettingStartedLanding/");
                toggleVisibility();
            }
        });
        gettingStarted.setDescription("Need help getting started? Click here to view the official OpenBCI Getting Started guides.");
    }

    private void createTroubleshootingGuideButton(String name, String text, int _x, int _y, int _w, int _h) {
        troubleshootingGuide = createButton(tutorial_cp5, name, text, _x, _y, _w, _h);
        troubleshootingGuide.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                openURLInBrowser("https://docs.openbci.com/Troubleshooting/TroubleshootingLanding/");
                toggleVisibility();
            }
        });
        troubleshootingGuide.setDescription("Having trouble? Start here with some general troubleshooting tips found on the OpenBCI Docs.");
    }
}
