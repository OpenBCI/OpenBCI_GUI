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
import java.net.*;
import java.nio.file.*;

class TopNav {

    private final color TOPNAV_DARKBLUE = OPENBCI_BLUE;
    private final color SUBNAV_LIGHTBLUE = buttonsLightBlue;
    private color strokeColor = OPENBCI_DARKBLUE;

    private ControlP5 topNav_cp5;

    public Button controlPanelCollapser;

    public Button toggleDataStreamingButton;

    public Button filtBPButton;
    public Button filtNotchButton;
    public Button smoothingButton;

    public Button debugButton;
    public Button tutorialsButton;
    public Button shopButton;
    public Button issuesButton;
    public Button updateGuiVersionButton;

    public Button layoutButton;
    public Button settingsButton;

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
        createTutorialsButton("Help", (int)debugButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createIssuesButton("Issues", (int)tutorialsButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createShopButton("Shop", (int)issuesButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createUpdateGuiButton("Update", (int)shopButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);

        //SUBNAV TOP RIGHT
        createTopNavSettingsButton("Settings", width - SUBNAV_BUT_W - PAD_3, SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, h4, 14, SUBNAV_LIGHTBLUE, WHITE);

        layoutSelector = new LayoutSelector();
        tutorialSelector = new TutorialSelector();
        configSelector = new ConfigSelector();

        //updateNavButtonsBasedOnColorScheme();
    }

    void initSecondaryNav() {

        boolean needToMakeSmoothingButton = (currentBoard instanceof SmoothingCapableBoard) && smoothingButton == null;

        if (!secondaryNavInit) {
            //Buttons on the left side of the GUI secondary nav bar
            createToggleDataStreamButton(stopButton_pressToStart_txt, PAD_3, SUBNAV_BUT_Y, DATASTREAM_BUT_W, SUBNAV_BUT_H, h4, 14, isSelected_color, OPENBCI_DARKBLUE);
            createFiltNotchButton("Notch\n" + dataProcessing.getShortNotchDescription(), PAD_3*2 + toggleDataStreamingButton.getWidth(), SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, p5, 12, SUBNAV_LIGHTBLUE, WHITE);
            createFiltBPButton("BP Filt\n" + dataProcessing.getShortFilterDescription(), PAD_3*3 + toggleDataStreamingButton.getWidth() + SUBNAV_BUT_W, SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, p5, 12, SUBNAV_LIGHTBLUE, WHITE);

            //Appears at Top Right SubNav while in a Session
            createLayoutButton("Layout", width - 3 - 60, SUBNAV_BUT_Y, 60, SUBNAV_BUT_H, h4, 14, SUBNAV_LIGHTBLUE, WHITE);
            secondaryNavInit = true;
        }

        if (needToMakeSmoothingButton) {
            int pos_x = (int)filtBPButton.getPosition()[0] + filtBPButton.getWidth() + PAD_3;
            createSmoothingButton(getSmoothingString(), pos_x, SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, p5, 12, SUBNAV_LIGHTBLUE, WHITE);
        }
        
        
        //updateSecondaryNavButtonsColor();
    }

    /*
    void updateNavButtonsBasedOnColorScheme() {
        if (colorScheme == COLOR_SCHEME_DEFAULT) {
            controlPanelCollapser.setColorNotPressed(color(255));
            debugButton.setColorNotPressed(color(255));
            //highRezButton.setColorNotPressed(color(255));
            issuesButton.setColorNotPressed(color(255));
            shopButton.setColorNotPressed(color(255));
            tutorialsButton.setColorNotPressed(color(255));
            updateGuiVersionButton.setColorNotPressed(color(255));
            configButton.setColorNotPressed(color(255));

            controlPanelCollapser.textColorNotActive = OPENBCI_DARKBLUE;
            debugButton.textColorNotActive = OPENBCI_DARKBLUE;
            //highRezButton.textColorNotActive = OPENBCI_DARKBLUE;
            issuesButton.textColorNotActive = OPENBCI_DARKBLUE;
            shopButton.textColorNotActive = OPENBCI_DARKBLUE;
            tutorialsButton.textColorNotActive = OPENBCI_DARKBLUE;
            updateGuiVersionButton.textColorNotActive = OPENBCI_DARKBLUE;
            configButton.textColorNotActive = OPENBCI_DARKBLUE;
        } else if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
            controlPanelCollapser.setColorNotPressed(OPENBCI_BLUE);
            debugButton.setColorNotPressed(OPENBCI_BLUE);
            //highRezButton.setColorNotPressed(OPENBCI_BLUE);
            issuesButton.setColorNotPressed(OPENBCI_BLUE);
            shopButton.setColorNotPressed(OPENBCI_BLUE);
            tutorialsButton.setColorNotPressed(OPENBCI_BLUE);
            updateGuiVersionButton.setColorNotPressed(OPENBCI_BLUE);
            configButton.setColorNotPressed(SUBNAV_LIGHTBLUE);

            controlPanelCollapser.textColorNotActive = color(255);
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
    */

    /*
    void updateSecondaryNavButtonsColor() {
        if (colorScheme == COLOR_SCHEME_DEFAULT) {
            filtBPButton.setColorNotPressed(color(255));
            filtNotchButton.setColorNotPressed(color(255));
            layoutButton.setColorNotPressed(color(255));

            filtBPButton.textColorNotActive = OPENBCI_DARKBLUE;
            filtNotchButton.textColorNotActive = OPENBCI_DARKBLUE;
            layoutButton.textColorNotActive = OPENBCI_DARKBLUE;

            if (currentBoard instanceof SmoothingCapableBoard) {
                smoothingButton.textColorNotActive = OPENBCI_DARKBLUE;
                smoothingButton.setColorNotPressed(color(255));
            }

            if (currentBoard instanceof ADS1299SettingsBoard) {
                gainButton.textColorNotActive = OPENBCI_DARKBLUE;
                gainButton.setColorNotPressed(color(255));
            }
        } else if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
            filtBPButton.setColorNotPressed(SUBNAV_LIGHTBLUE);
            filtNotchButton.setColorNotPressed(SUBNAV_LIGHTBLUE);
            layoutButton.setColorNotPressed(SUBNAV_LIGHTBLUE);

            filtBPButton.textColorNotActive = color(255);
            filtNotchButton.textColorNotActive = color(255);
            layoutButton.textColorNotActive = color(255);

            if (currentBoard instanceof SmoothingCapableBoard) {
                smoothingButton.setColorNotPressed(SUBNAV_LIGHTBLUE);
                smoothingButton.textColorNotActive = color(255);
            }

            if (currentBoard instanceof ADS1299SettingsBoard) {
                gainButton.setColorNotPressed(SUBNAV_LIGHTBLUE);
                gainButton.textColorNotActive = color(255);
            }
        }
    }
    */

    void update() {
        //ignore settings button when help dropdown is open
        settingsButton.setLock(tutorialSelector.isVisible);

        //Make sure these buttons don't get accidentally locked
        if (systemMode >= SYSTEMMODE_POSTINIT) {
            setLockTopLeftSubNavCp5Objects(controlPanel.isOpen);
        }

        if (previousSystemMode != systemMode) {
            if (systemMode >= SYSTEMMODE_POSTINIT) {
                layoutSelector.update();
                tutorialSelector.update();
                if (int(settingsButton.getPosition()[0]) != width - (SUBNAV_BUT_W*2) + 3) {
                    settingsButton.setPosition(width - (SUBNAV_BUT_W*2) + 3, SUBNAV_BUT_Y);
                    verbosePrint("TopNav: Updated Settings Button Position");
                }
            } else {
                if (int(settingsButton.getPosition()[0]) != width - 70 - 3) {
                    settingsButton.setPosition(width - 70 - 3, SUBNAV_BUT_Y);
                    verbosePrint("TopNav: Updated Settings Button Position");
                }
            }
            configSelector.update();
            previousSystemMode = systemMode;
        }
    }

    void draw() {
        PImage logo;
        color topNavBg;
        color subNavBg;
        if (colorScheme == COLOR_SCHEME_ALTERNATIVE_A) {
            topNavBg = OPENBCI_BLUE;
            subNavBg = SUBNAV_LIGHTBLUE;
            logo = logo_white;
        } else {
            topNavBg = color(255);
            subNavBg = color(229);
            logo = logo_black;
        }

        if (eegDataSource == DATASOURCE_GALEA) {
            topNavBg = color(3, 10, 18);
            subNavBg = color(33, 49, 65);
            strokeColor = subNavBg;
        }

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
            filtBPButton.setVisible(isSession);
            filtNotchButton.setVisible(isSession);
            layoutButton.setVisible(isSession);
           
        }
        if (smoothingButton != null) {
            smoothingButton.setVisible(isSession);
        }

        //Draw CP5 Objects
        topNav_cp5.draw();

        //Draw everything in these selector boxes above all topnav cp5 objects
        layoutSelector.draw();
        tutorialSelector.draw();
        configSelector.draw();

        //Draw Console Log Image on top of cp5 object
        PImage _logo = (colorScheme == COLOR_SCHEME_DEFAULT) ? consoleImgBlue : consoleImgWhite;
        image(_logo, debugButton.getPosition()[0] + 6, debugButton.getPosition()[1] + 2, 22, 22);        
        

    }

    void screenHasBeenResized(int _x, int _y) {
        topNav_cp5.setGraphics(ourApplet, 0, 0); //Important!
        debugButton.setPosition(width - debugButton.getWidth() - PAD_3, PAD_3);
        tutorialsButton.setPosition((int)debugButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3);
        issuesButton.setPosition(tutorialsButton.getPosition()[0] - tutorialsButton.getWidth() - PAD_3, PAD_3);
        shopButton.setPosition(issuesButton.getPosition()[0] - issuesButton.getWidth() - PAD_3, PAD_3);
        updateGuiVersionButton.setPosition(shopButton.getPosition()[0] - shopButton.getWidth() - PAD_3, PAD_3);
        settingsButton.setPosition(width - settingsButton.getWidth() - PAD_3, SUBNAV_BUT_Y);

        if (systemMode == SYSTEMMODE_POSTINIT) {
            toggleDataStreamingButton.setPosition(PAD_3, SUBNAV_BUT_Y);
            filtNotchButton.setPosition(PAD_3*2 + toggleDataStreamingButton.getWidth(), SUBNAV_BUT_Y);
            filtBPButton.setPosition(PAD_3*3 + toggleDataStreamingButton.getWidth() + SUBNAV_BUT_W, SUBNAV_BUT_Y);

            layoutButton.setPosition(width - 3 - layoutButton.getWidth(), SUBNAV_BUT_Y);
            settingsButton.setPosition(width - (settingsButton.getWidth()*2) + PAD_3, SUBNAV_BUT_Y);
            //Make sure to re-position UI in selector boxes
            layoutSelector.screenResized();
        }
        
        tutorialSelector.screenResized();
        configSelector.screenResized();
    }

    void mousePressed() {
        layoutSelector.mousePressed();     //pass mousePressed along to layoutSelector
        tutorialSelector.mousePressed();
        configSelector.mousePressed();
    }

    void mouseReleased() {
        layoutSelector.mouseReleased();    //pass mouseReleased along to layoutSelector
        tutorialSelector.mouseReleased();
        configSelector.mouseReleased();
    } //end mouseReleased

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
        return ((SmoothingCapableBoard)currentBoard).getSmoothingActive() ? "Smoothing\n       On" : "Smoothing\n       Off";
    }

    private String getGainString() {
        return ((ADS1299SettingsBoard)currentBoard).getUseDynamicScaler() ? "Gain Mode\n   Body uV" : "Gain Mode\n   Classic";
    }

    private Button createTNButton(String name, String text, int _x, int _y, int _w, int _h, PFont _font, int _fontSize, color _bg, color _textColor) {
        return createButton(topNav_cp5, name, text, _x, _y, _w, _h, 0, _font, _fontSize, _bg, _textColor, BUTTON_HOVER, BUTTON_PRESSED, OPENBCI_DARKBLUE, -2);
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
               stopButtonWasPressed();
            }
        });
        toggleDataStreamingButton.setDescription("Press this button to Stop/Start the data stream. Or press <SPACEBAR>");
    }

    private void createFiltNotchButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        filtNotchButton = createTNButton("filtNotchButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        filtNotchButton.getCaptionLabel().getStyle().setMarginTop(-int(_h/4));
        filtNotchButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               incrementNotchConfiguration();
            }
        });
        filtNotchButton.setDescription("Here you can adjust the Notch Filter that is applied to all \"Filtered\" data.");
    }

    private void createFiltBPButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        filtBPButton = createTNButton("filtBPButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        filtBPButton.getCaptionLabel().getStyle().setMarginTop(-int(_h/4));
        filtBPButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               incrementFilterConfiguration();
            }
        });
        filtBPButton.setDescription("Here you can adjust the Band Pass Filter that is applied to all \"Filtered\" data.");
    }

    private void createSmoothingButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        SmoothingCapableBoard smoothBoard = (SmoothingCapableBoard)currentBoard;
        color bgColor = smoothBoard.getSmoothingActive() ? _bg : BUTTON_LOCKED_GREY;
        smoothingButton = createTNButton("smoothingButton", text, _x, _y, _w, _h, font, _fontSize, bgColor, _textColor);
        smoothingButton.getCaptionLabel().getStyle().setMarginTop(-int(_h/4));
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
                //make sure that you can't open the layout selector accidentally
                if (!tutorialSelector.isVisible) {
                    //println("TopNav: Layout Dropdown Toggled");
                    layoutSelector.toggleVisibility();
                }
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

    private void createIssuesButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        final String helpText = "If you have suggestions or want to share a bug you've found, please create an issue on the GUI's Github repo!";
        issuesButton = createTNButton("issuesButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        issuesButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               openURLInBrowser("https://github.com/OpenBCI/OpenBCI_GUI/issues");
            }
        });
        issuesButton.setDescription("If you have suggestions or want to share a bug you've found, please create an issue on the GUI's Github repo!");
    }

    private void createShopButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        shopButton = createTNButton("shopButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        shopButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               openURLInBrowser("https://shop.openbci.com/");
            }
        });
        shopButton.setDescription("Head to our online store to purchase the latest OpenBCI hardware and accessories.");
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
    public void stopButtonWasPressed() {

        //Exit method if doing Cyton impedance check. Avoids a BrainFlow error.
        if (currentBoard instanceof BoardCyton && w_cytonImpedance != null) {
            Integer checkingImpOnChan = ((ImpedanceSettingsBoard)currentBoard).isCheckingImpedanceOnChannel();
            //println("isCheckingImpedanceOnAnythingEZCHECK==",w_cytonImpedance.isCheckingImpedanceOnAnything);
            if (checkingImpOnChan != null || w_cytonImpedance.cytonMasterImpedanceCheckIsActive() || w_cytonImpedance.isCheckingImpedanceOnAnything) {
                PopupMessage msg = new PopupMessage("Busy Checking Impedance", "Please turn off impedance check to begin recording the data stream.");
                println("OpenBCI_GUI::Cyton: Please turn off impedance check to begin recording the data stream.");
                return;
            }
        }

        //toggle the data transfer state of the ADS1299...stop it or start it...
        if (currentBoard.isStreaming()) {
            output("openBCI_GUI: stopButton was pressed. Stopping data transfer, wait a few seconds.");
            stopRunning();
            if (!currentBoard.isStreaming()) {
                toggleDataStreamingButton.getCaptionLabel().setText(stopButton_pressToStart_txt);
                toggleDataStreamingButton.setColorBackground(isSelected_color);
            }
        } else { //not running
            output("openBCI_GUI: startButton was pressed. Starting data transfer, wait a few seconds.");
            startRunning();
            if (currentBoard.isStreaming()) {
                toggleDataStreamingButton.getCaptionLabel().setText(stopButton_pressToStop_txt);
                toggleDataStreamingButton.setColorBackground(TURN_OFF_RED);
                nextPlayback_millis = millis();  //used for synthesizeData and readFromFile.  This restarts the clock that keeps the playback at the right pace.
            }
        }
    }

    public boolean dataStreamingButtonIsActive() {
        return toggleDataStreamingButton.getCaptionLabel().getText().equals(stopButton_pressToStop_txt);
    }

    public void resetStartStopButton() {
        if (toggleDataStreamingButton != null) {
            toggleDataStreamingButton.getCaptionLabel().setText(stopButton_pressToStart_txt);
            toggleDataStreamingButton.setColorBackground(isSelected_color);
        }
    }

    public void destroySmoothingButton() {
        topNav_cp5.remove("smoothingButton");
        smoothingButton = null;
    }

    private void incrementFilterConfiguration() {
        dataProcessing.incrementFilterConfiguration();

        //update the button strings
        topNav.filtBPButton.getCaptionLabel().setText("BP Filt\n" + dataProcessing.getShortFilterDescription());
        // topNav.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
    }

    private void incrementNotchConfiguration() {
        dataProcessing.incrementNotchConfiguration();

        //update the button strings
        topNav.filtNotchButton.getCaptionLabel().setText("Notch\n" + dataProcessing.getShortNotchDescription());
        // topNav.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
    }

    public void setLockTopLeftSubNavCp5Objects(boolean _b) {
        toggleDataStreamingButton.setLock(_b);
        filtNotchButton.setLock(_b);
        filtBPButton.setLock(_b);
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
    }

    public void update() {
        if (isVisible) { //only update if visible
            // //close dropdown when mouse leaves
            // if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.layoutButton.isMouseHere()){
            //   toggleVisibility();
            // }
        }

        //Update the X position of this box on every update
        x = width - w - 3;
    }

    public void draw() {
        if (isVisible) { //only draw if visible
            pushStyle();

            stroke(OPENBCI_DARKBLUE);
            // fill(229); //bg
            fill(57, 128, 204); //bg
            rect(x, y, w, h);

            fill(57, 128, 204);
            // fill(177, 184, 193);
            noStroke();
            rect(x+w-(topNav.layoutButton.getWidth()-1), y, (topNav.layoutButton.getWidth()-1), 1);

            popStyle();

            layout_cp5.draw();
        }
    }

    public void isMouseHere() {
    }

    public void mousePressed() {
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
        //update position of outer box and buttons
        //int oldX = x;
        x = width - w - 3;
        //int dx = oldX - x;
        layout_cp5.setGraphics(ourApplet, 0,0);

        for (int i = 0; i < layoutOptions.size(); i++) {
            int row = (i/4)%4;
            int column = i%4;
            layoutOptions.get(i).setPosition(x + (column+1)*margin + (b_w*column), y + (row+1)*margin + row*b_h);
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
                    output("Layout [" + (layoutNumber+1) + "] selected.");
                    toggleVisibility(); //shut layoutSelector if something is selected
                    wm.setNewContainerLayout(layoutNumber); //have WidgetManager update Layout and active widgets
                    settings.currentLayout = layoutNumber+1; //copy this value to be used when saving Layout setting
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

    ConfigSelector() {
        int _padding = (systemMode == SYSTEMMODE_POSTINIT) ? -3 : 3;
        w = 140;
        x = width - w - _padding;
        y = (navBarHeight * 2) - 3;
        margin = 6;
        b_w = w - margin*2;
        b_h = 22;
        h = margin*9 + b_h*8;
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

    public void update() {
    }

    public void draw() {
        if (isVisible) { //only draw if visible
            pushStyle();

            stroke(OPENBCI_DARKBLUE);
            fill(57, 128, 204); //bg
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

            fill(57, 128, 204);
            noStroke();
            //This makes the dropdown box look like it's apart of the button by drawing over the part that overlaps
            rect(x+w-(topNav.settingsButton.getWidth()-1), y, (topNav.settingsButton.getWidth()-1), 1);

            popStyle();

            settings_cp5.draw();
        }
    }

    public void isMouseHere() {
    }

    public void mousePressed() {
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
        int multiplier = isSessionStarted ? 3 : 2;
        int _padding = isSessionStarted ? -3 : 3;
        x = width - 70*multiplier - _padding;
        int dx = oldX - x;

        h = !isSessionStarted ? margin*3 + b_h*2 : margin*6 + b_h*5;

        //Update the Y position for the clear settings buttons
        float clearSettingsButtonY = !isSessionStarted ? 
            expertMode.getPosition()[1] + margin + b_h : 
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
        if (systemMode >= SYSTEMMODE_POSTINIT) {
            if (isVisible) {
                //the very convoluted way of locking all controllers of a single controlP5 instance...
                for (int i = 0; i < wm.widgets.size(); i++) {
                    for (int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
                        wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).lock();
                    }
                }
                clearAllSettingsPressed = false;
            } else {
                //the very convoluted way of unlocking all controllers of a single controlP5 instance...
                for (int i = 0; i < wm.widgets.size(); i++) {
                    for (int j = 0; j < wm.widgets.get(i).cp5_widget.getAll().size(); j++) {
                        wm.widgets.get(i).cp5_widget.getController(wm.widgets.get(i).cp5_widget.getAll().get(j).getAddress()).unlock();
                    }
                }
            }
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
                settings.saveButtonPressed();
            }
        });
        saveSessionSettings.setDescription("Expert Mode enables advanced keyboard shortcuts and access to all GUI features.");
    }

    private void createLoadSettingsButton(String name, String text, int _x, int _y, int _w, int _h) {
        loadSessionSettings = createButton(settings_cp5, name, text, _x, _y, _w, _h);
        loadSessionSettings.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                settings.loadButtonPressed();
            }
        });
        loadSessionSettings.setDescription("Expert Mode enables advanced keyboard shortcuts and access to all GUI features.");
    }

    private void createDefaultSettingsButton(String name, String text, int _x, int _y, int _w, int _h) {
        defaultSessionSettings = createButton(settings_cp5, name, text, _x, _y, _w, _h);
        defaultSessionSettings.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                toggleVisibility();
                settings.defaultButtonPressed();
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
                settings.clearAll();
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
}

class TutorialSelector {

    private int x, y, w, h, margin, b_w, b_h;
    public boolean isVisible;
    private ControlP5 tutorial_cp5;
    private Button gettingStarted;
    private Button testingImpedance;
    private Button troubleshootingGuide;
    private Button customWidgets;
    private Button openbciForum;
    private Button ftdiBufferFix;
    private final int NUM_TUTORIAL_BUTTONS = 6;

    TutorialSelector() {
        w = 180;
        //account for consoleLog button, help button, and spacing
        x = width - 33 - w - 3*2;
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
        createTestingImpedanceButton("testingImpedance", "Testing Impedance", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createFtdiBufferFixButton("ftdiBufferFix", "Cyton Driver Fix", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createTroubleshootingGuideButton("troubleshootingGuide", "Troubleshooting Guide", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createCustomWidgetsButton("customWidgets", "Building Custom Widgets", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
        buttonNumber++;
        createOpenbciForumButton("openbciForum", "OpenBCI Forum", x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h);
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

            stroke(OPENBCI_DARKBLUE);
            // fill(229); //bg
            fill(OPENBCI_BLUE); //bg
            rect(x, y, w, h);


            // fill(177, 184, 193);
            noStroke();
            //Draw a tiny rectangle to make it look like the box and button are connected
            rect(x+w-(topNav.tutorialsButton.getWidth()-1), y, (topNav.tutorialsButton.getWidth()-1), 1);

            popStyle();

            tutorial_cp5.draw();
        }
    }

    void isMouseHere() {
    }

    void mousePressed() {
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
        x = width - 33 - w - 3*2;
        int dx = oldX - x;

        for (int j = 0; j < tutorial_cp5.getAll().size(); j++) {
            Button c = (Button) tutorial_cp5.getController(tutorial_cp5.getAll().get(j).getAddress());
            c.setPosition(c.getPosition()[0] - dx, c.getPosition()[1]);
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

    private void createGettingStartedButton(String name, String text, int _x, int _y, int _w, int _h) {
        gettingStarted = createButton(tutorial_cp5, name, text, _x, _y, _w, _h);
        gettingStarted.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                openURLInBrowser("https://docs.openbci.com/GettingStarted/GettingStartedLanding/");
                toggleVisibility(); //shut layoutSelector if something is selected
            }
        });
        gettingStarted.setDescription("Need help getting started? Click here to view the official OpenBCI Getting Started guides.");
    }

    private void createTestingImpedanceButton(String name, String text, int _x, int _y, int _w, int _h) {
        testingImpedance = createButton(tutorial_cp5, name, text, _x, _y, _w, _h);
        testingImpedance.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                openURLInBrowser("https://docs.openbci.com/Software/OpenBCISoftware/GUIDocs/#impedance-testing");
                toggleVisibility(); //shut layoutSelector if something is selected
            }
        });
        testingImpedance.setDescription("Click here to learn more about testing the impedance on electrodes using the OpenBCI GUI. This process is different for Cyton and Ganglion. Checking impedance only works with passive electrodes.");
    }

    private void createTroubleshootingGuideButton(String name, String text, int _x, int _y, int _w, int _h) {
        troubleshootingGuide = createButton(tutorial_cp5, name, text, _x, _y, _w, _h);
        troubleshootingGuide.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                openURLInBrowser("https://docs.openbci.com/Troubleshooting/GUI_Troubleshooting/");
                toggleVisibility(); //shut layoutSelector if something is selected
            }
        });
        troubleshootingGuide.setDescription("Having trouble? Start here with some general troubleshooting tips found on the OpenBCI Docs.");
    }

    private void createCustomWidgetsButton(String name, String text, int _x, int _y, int _w, int _h) {
        customWidgets = createButton(tutorial_cp5, name, text, _x, _y, _w, _h);
        customWidgets.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                openURLInBrowser("https://docs.openbci.com/Software/OpenBCISoftware/GUIWidgets/#custom-widget");
                toggleVisibility(); //shut layoutSelector if something is selected
            }
        });
        customWidgets.setDescription("Click here to learn about creating your own custom OpenBCI widgets!");
    }

    private void createOpenbciForumButton(String name, String text, int _x, int _y, int _w, int _h) {
        openbciForum = createButton(tutorial_cp5, name, text, _x, _y, _w, _h);
        openbciForum.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                openURLInBrowser("https://openbci.com/forum/");
                toggleVisibility(); //shut layoutSelector if something is selected
            }
        });
        openbciForum.setDescription("Click here to visit the official OpenBCI Forum.");
    }

    private void createFtdiBufferFixButton(String name, String text, int _x, int _y, int _w, int _h) {
        openbciForum = createButton(tutorial_cp5, name, text, _x, _y, _w, _h);
        openbciForum.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                String ftdiDriverDocUrl;
                if (isMac()) {
                    ftdiDriverDocUrl = "https://docs.openbci.com/Troubleshooting/FTDI_Fix_Mac/";
                } else if (isLinux()){
                    ftdiDriverDocUrl = "https://docs.openbci.com/Troubleshooting/FTDI_Fix_Linux/";
                } else {
                    ftdiDriverDocUrl = "https://docs.openbci.com/Troubleshooting/FTDI_Fix_Windows/";
                }
                openURLInBrowser(ftdiDriverDocUrl);
                toggleVisibility(); //shut layoutSelector if something is selected
            }
        });
        openbciForum.setDescription("Click here to view information on how to lower the Cyton Dongle latency for your current operating system.");
    }
}
