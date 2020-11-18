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
    private color strokeColor = bgColor;

    private ControlP5 topNav_cp5;

    public Button controlPanelCollapser;

    public Button toggleDataStreamingButton;

    public Button filtBPButton;
    public Button filtNotchButton;
    public Button smoothingButton;
    public Button gainButton;

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
        topNav_cp5.setGraphics(ourApplet, 0,0);
        topNav_cp5.setAutoDraw(false);

        createControlPanelCollapser("System Control Panel", PAD_3, PAD_3, controlPanel_W, TOPNAV_BUT_H + PAD_3, h3, 16, TOPNAV_DARKBLUE, WHITE);

        //TOP RIGHT OF GUI, FROM LEFT<---Right
        createDebugButton(" ", width - DEBUG_BUT_W - PAD_3, PAD_3, DEBUG_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createTutorialsButton("Help", (int)debugButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createIssuesButton("Issues", (int)tutorialsButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createShopButton("Shop", (int)issuesButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);
        createUpdateGuiButton("Update", (int)shopButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3, TOPRIGHT_BUT_W, TOPNAV_BUT_H, h3, 16, TOPNAV_DARKBLUE, WHITE);

        //SUBNAV TOP RIGHT
        createTopNavSettingsButton("Settings", width - SUBNAV_BUT_W - PAD_3, SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, h4, 14, SUBNAV_LIGHTBLUE, WHITE);

        //Attempt to compare local and remote GUI versions when TopNav is instantiated
        guiVersionIsUpToDate();

        layoutSelector = new LayoutSelector();
        tutorialSelector = new TutorialSelector();
        configSelector = new ConfigSelector();

        //updateNavButtonsBasedOnColorScheme();
    }

    void initSecondaryNav() {

        //Buttons on the left side of the GUI secondary nav bar
        createToggleDataStreamButton(stopButton_pressToStart_txt, PAD_3, SUBNAV_BUT_Y, DATASTREAM_BUT_W, SUBNAV_BUT_H, h4, 14, isSelected_color, bgColor);
        createFiltNotchButton("Notch\n" + dataProcessing.getShortNotchDescription(), PAD_3*2 + toggleDataStreamingButton.getWidth(), SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, p5, 12, SUBNAV_LIGHTBLUE, WHITE);
        createFiltBPButton("BP Filt\n" + dataProcessing.getShortFilterDescription(), PAD_3*3 + toggleDataStreamingButton.getWidth() + SUBNAV_BUT_W, SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, p5, 12, SUBNAV_LIGHTBLUE, WHITE);
        if (currentBoard instanceof SmoothingCapableBoard) {
            createSmoothingButton(getSmoothingString(), (int)filtBPButton.getPosition()[0] + filtBPButton.getWidth() + PAD_3, SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, p5, 12, SUBNAV_LIGHTBLUE, WHITE);
        }
        if (currentBoard instanceof ADS1299SettingsBoard) {
            int pos_x = 0;
            if (currentBoard instanceof SmoothingCapableBoard) {
                pos_x = (int)smoothingButton.getPosition()[0] + smoothingButton.getWidth() + 4;
            } else {
                pos_x = (int)filtBPButton.getPosition()[0] + filtBPButton.getWidth() + 4;
            }
            createGainButton(getGainString(), pos_x, SUBNAV_BUT_Y, SUBNAV_BUT_W, SUBNAV_BUT_H, p5, 12, SUBNAV_LIGHTBLUE, WHITE);
        }

        //Appears at Top Right SubNav while in a Session
        createLayoutButton("Layout", width - 3 - 60, SUBNAV_BUT_Y, 60, SUBNAV_BUT_H, h4, 14, SUBNAV_LIGHTBLUE, WHITE);

        secondaryNavInit = true;
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

            controlPanelCollapser.textColorNotActive = color(bgColor);
            debugButton.textColorNotActive = color(bgColor);
            //highRezButton.textColorNotActive = color(bgColor);
            issuesButton.textColorNotActive = color(bgColor);
            shopButton.textColorNotActive = color(bgColor);
            tutorialsButton.textColorNotActive = color(bgColor);
            updateGuiVersionButton.textColorNotActive = color(bgColor);
            configButton.textColorNotActive = color(bgColor);
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

            filtBPButton.textColorNotActive = color(bgColor);
            filtNotchButton.textColorNotActive = color(bgColor);
            layoutButton.textColorNotActive = color(bgColor);

            if (currentBoard instanceof SmoothingCapableBoard) {
                smoothingButton.textColorNotActive = color(bgColor);
                smoothingButton.setColorNotPressed(color(255));
            }

            if (currentBoard instanceof ADS1299SettingsBoard) {
                gainButton.textColorNotActive = color(bgColor);
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
        if (tutorialSelector.isVisible) {
            settingsButton.setLock(true);
        } else {
            settingsButton.setLock(false);
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
            logo = logo_blue;
        }

        if (eegDataSource == DATASOURCE_GALEA) {
            topNavBg = color(3, 10, 18);
            subNavBg = color(33, 49, 65);
            strokeColor = subNavBg;
        }

        pushStyle();
        //stroke(bgColor);
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
            image(logo, width/2 - (128/2) - 2, 6, 128, 22);
        }

        //Draw these buttons during a Session
        boolean isSession = systemMode == SYSTEMMODE_POSTINIT;
        if (secondaryNavInit) {
            toggleDataStreamingButton.setVisible(isSession);
            filtBPButton.setVisible(isSession);
            filtNotchButton.setVisible(isSession);
            layoutButton.setVisible(isSession);
            if (currentBoard instanceof SmoothingCapableBoard) {
                smoothingButton.setVisible(isSession);
            }
            if (currentBoard instanceof ADS1299SettingsBoard) {
                gainButton.setVisible(isSession);
            }
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
        debugButton.setPosition(width - debugButton.getWidth() - PAD_3, PAD_3);
        tutorialsButton.setPosition((int)debugButton.getPosition()[0] - TOPRIGHT_BUT_W - PAD_3, PAD_3);
        issuesButton.setPosition(tutorialsButton.getPosition()[0] - tutorialsButton.getWidth() - PAD_3, PAD_3);
        shopButton.setPosition(issuesButton.getPosition()[0] - issuesButton.getWidth() - PAD_3, PAD_3);
        updateGuiVersionButton.setPosition(shopButton.getPosition()[0] - shopButton.getWidth() - PAD_3, PAD_3);
        settingsButton.setPosition(width - settingsButton.getWidth() - PAD_3, SUBNAV_BUT_Y);

        if (systemMode == SYSTEMMODE_POSTINIT) {
            layoutButton.setPosition(width - 3 - layoutButton.getWidth(), SUBNAV_BUT_Y);
            settingsButton.setPosition(width - (settingsButton.getWidth()*2) + PAD_3, SUBNAV_BUT_Y);
            //Make sure to re-position UI in selector boxes
            layoutSelector.screenResized();
            tutorialSelector.screenResized();
        }
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
                //updateGuiVersionButton.getCaptionLabel().setText("GUI needs to be updated. -- Local: " + localGUIVersionString +  " GitHub: " + remoteVersionString);
                return false;
            } else {
                println("GUI is up to date!");
                //updateGuiVersionButton.getCaptionLabel().setText("GUI is up to date! -- Local: " + localGUIVersionString +  " GitHub: " + remoteVersionString);
                return true;
            }
        } else {
            println("TopNav: Internet Connection Not Available");
            println("Local GUI Version: " + localGUIVersionString);
            //updateGuiVersionButton.getCaptionLabel().setText("Connect to internet to check GUI version. -- Local: " + localGUIVersionString);
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

    private String getSmoothingString() {
        return ((SmoothingCapableBoard)currentBoard).getSmoothingActive() ? "Smoothing\n       On" : "Smoothing\n     Off";
    }

    private String getGainString() {
        return ((ADS1299SettingsBoard)currentBoard).getUseDynamicScaler() ? "Gain Mode\n   Body uV" : "Gain Mode\n   Classic";
    }

    private Button createButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h, PFont _font, int _fontSize, color _bg, color _textColor) {
        final Button b = topNav_cp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setCornerRoundness(0)
            .setColorLabel(_textColor)
            .setColorForeground(BUTTON_HOVER)
            .setColorBackground(_bg)
            .setColorActive(BUTTON_PRESSED)
            ;
        b.getCaptionLabel()
            .setFont(_font)
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(text)
            ;
        b.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_ENTER) {
                    buttonHelpText.setButtonHelpText("testing", (int)b.getPosition()[0] + b.getWidth()/2, (int)b.getPosition()[1] + (3*b.getHeight())/4);
                    buttonHelpText.setVisible(true);
                } else if (theEvent.getAction() == ControlP5.ACTION_LEAVE) {
                    buttonHelpText.setVisible(false);
                }
            }
        });
        myButton = b;
        return myButton;
    }

    private void createToggleDataStreamButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        toggleDataStreamingButton = createButton(toggleDataStreamingButton, "toggleDataStreamingButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        toggleDataStreamingButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               stopButtonWasPressed();
            }
        });
        //stopButton.setHelpText("Press this button to Stop/Start the data stream. Or press <SPACEBAR>");
    }

    private void createFiltNotchButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        filtNotchButton = createButton(filtNotchButton, "filtNotchButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        filtNotchButton.getCaptionLabel().getStyle().setMarginTop(-int(_h/4));
        filtNotchButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               incrementNotchConfiguration();
            }
        });
        //filtNotchButton.setHelpText("Here you can adjust the Notch Filter that is applied to all \"Filtered\" data.");
    }

    private void createFiltBPButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        filtBPButton = createButton(filtBPButton, "filtBPButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        filtBPButton.getCaptionLabel().getStyle().setMarginTop(-int(_h/4));
        filtBPButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               incrementFilterConfiguration();
            }
        });
        //filtBPButton.setHelpText("Here you can adjust the Band Pass Filter that is applied to all \"Filtered\" data.");
    }

    private void createSmoothingButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        smoothingButton = createButton(smoothingButton, "smoothingButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        smoothingButton.getCaptionLabel().getStyle().setMarginTop(-int(_h/4));
        smoothingButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                SmoothingCapableBoard smoothBoard = (SmoothingCapableBoard)currentBoard;
                smoothBoard.setSmoothingActive(!smoothBoard.getSmoothingActive());
                smoothingButton.getCaptionLabel().setText(getSmoothingString());
            }
        });
        // smoothingButton.setHelpText("Click here to turn data smoothing on or off.");
    }

    private void createGainButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        gainButton = createButton(gainButton, "gainButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        gainButton.getCaptionLabel().getStyle().setMarginTop(-int(_h/4));
        gainButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                ADS1299SettingsBoard adsBoard = (ADS1299SettingsBoard)currentBoard;
                adsBoard.setUseDynamicScaler(!adsBoard.getUseDynamicScaler());
                gainButton.getCaptionLabel().setText(getGainString());;
            }
        });
        //gainButton.setHelpText("Click here to switch gain convention.");
    }

    private void createLayoutButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        layoutButton = createButton(layoutButton, "layoutButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        layoutButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //make sure that you can't open the layout selector accidentally
                if (!tutorialSelector.isVisible) {
                    println("TopNav: Layout Dropdown Toggled");
                    layoutSelector.toggleVisibility();
                }
            }
        });
        //layoutButton.setHelpText("Here you can alter the overall layout of the GUI, allowing for different container configurations with more or less widgets.");
    }

    private void createControlPanelCollapser(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        controlPanelCollapser = createButton(controlPanelCollapser, "controlPanelCollapser", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
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

    private void createDebugButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        debugButton = createButton(debugButton, "debugButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        debugButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               ConsoleWindow.display();
            }
        });
        //debugButton.setHelpText("Click to open the Console Log window.");
    }

    private void createTutorialsButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        tutorialsButton = createButton(tutorialsButton, "tutorialsButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        tutorialsButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               tutorialSelector.toggleVisibility();
            }
        });
        //tutorialsButton.setHelpText("Click to find links to helpful online tutorials and getting started guides. Also, check out how to create custom widgets for the GUI!");
    }

    private void createIssuesButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        final String helpText = "If you have suggestions or want to share a bug you've found, please create an issue on the GUI's Github repo!";
        issuesButton = createButton(issuesButton, "issuesButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        issuesButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               openURLInBrowser("https://github.com/OpenBCI/OpenBCI_GUI/issues");
            }
        });
        //issuesButton.setHelpText("If you have suggestions or want to share a bug you've found, please create an issue on the GUI's Github repo!");
    }

    private void createShopButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        shopButton = createButton(shopButton, "shopButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        shopButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               openURLInBrowser("https://shop.openbci.com/");
            }
        });
        //shopButton.setHelpText("Head to our online store to purchase the latest OpenBCI hardware and accessories.");
    }

    private void createUpdateGuiButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        updateGuiVersionButton = createButton(updateGuiVersionButton, "updateGuiVersionButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        updateGuiVersionButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
               openURLInBrowser(guiLatestReleaseLocation);
            }
        });
        //shopButton.setHelpText("Head to our online store to purchase the latest OpenBCI hardware and accessories.");
    }

    private void createTopNavSettingsButton(String text, int _x, int _y, int _w, int _h, PFont font, int _fontSize, color _bg, color _textColor) {
        settingsButton = createButton(settingsButton, "settingsButton", text, _x, _y, _w, _h, font, _fontSize, _bg, _textColor);
        settingsButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                //make Help button and Settings button mutually exclusive
                if (!tutorialSelector.isVisible) {
                    configSelector.toggleVisibility();
                }   
            }
        });
        //configButton.setHelpText("Save and Load GUI Settings! Click Default to revert to factory settings.");
    }

    //Execute this function whenver the stop button is pressed
    public void stopButtonWasPressed() {
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

    void incrementFilterConfiguration() {
        dataProcessing.incrementFilterConfiguration();

        //update the button strings
        topNav.filtBPButton.getCaptionLabel().setText("BP Filt\n" + dataProcessing.getShortFilterDescription());
        // topNav.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
    }

    void incrementNotchConfiguration() {
        dataProcessing.incrementNotchConfiguration();

        //update the button strings
        topNav.filtNotchButton.getCaptionLabel().setText("Notch\n" + dataProcessing.getShortNotchDescription());
        // topNav.titleMontage.string = "EEG Data (" + dataProcessing.getFilterDescription() + ")";
    }
}

class LayoutSelector {

    int x, y, w, h, margin, b_w, b_h;
    boolean isVisible;

    ArrayList<Button_obci> layoutOptions; //

    LayoutSelector() {
        w = 180;
        x = width - w - 3;
        y = (navBarHeight * 2) - 3;
        margin = 6;
        b_w = (w - 5*margin)/4;
        b_h = b_w;
        h = margin*3 + b_h*2;


        isVisible = false;

        layoutOptions = new ArrayList<Button_obci>();
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
            rect(x+w-(topNav.layoutButton.getWidth()-1), y, (topNav.layoutButton.getWidth()-1), 1);

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
            if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.layoutButton.isInside()) {
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
        Button_obci tempLayoutButton = new Button_obci(x + margin, y + margin, b_w, b_h, "N/A");
        PImage tempBackgroundImage = loadImage("layout_buttons/layout_1.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //setup button 2 -- 2x2
        tempLayoutButton = new Button_obci(x + 2*margin + b_w*1, y + margin, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_2.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //setup button 3 -- 2x1
        tempLayoutButton = new Button_obci(x + 3*margin + b_w*2, y + margin, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_3.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //setup button 4 -- 1x2
        tempLayoutButton = new Button_obci(x + 4*margin + b_w*3, y + margin, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_4.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //SECOND ROW

        //setup button 5
        tempLayoutButton = new Button_obci(x + margin, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_5.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //setup button 6
        tempLayoutButton = new Button_obci(x + 2*margin + b_w*1, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_6.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //setup button 7
        tempLayoutButton = new Button_obci(x + 3*margin + b_w*2, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_7.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //setup button 8
        tempLayoutButton = new Button_obci(x + 4*margin + b_w*3, y + 2*margin + 1*b_h, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_8.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //THIRD ROW -- commented until more widgets are added

        h = margin*4 + b_h*3;
        //setup button 9
        tempLayoutButton = new Button_obci(x + margin, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_9.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //setup button 10
        tempLayoutButton = new Button_obci(x + 2*margin + b_w*1, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_10.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //setup button 11
        tempLayoutButton = new Button_obci(x + 3*margin + b_w*2, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_11.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);

        //setup button 12
        tempLayoutButton = new Button_obci(x + 4*margin + b_w*3, y + 3*margin + 2*b_h, b_w, b_h, "N/A");
        tempBackgroundImage = loadImage("layout_buttons/layout_12.png");
        tempLayoutButton.setBackgroundImage(tempBackgroundImage);
        layoutOptions.add(tempLayoutButton);
    }
}

class ConfigSelector {
    int x, y, w, h, margin, b_w, b_h;
    boolean clearAllSettingsPressed;
    boolean isVisible;
    ArrayList<Button_obci> configOptions;
    int configHeight = 0;
    color newGreen = color(114,204,171);
    color expertPurple = color(135,95,154);
    color cautionRed = color(214,100,100);

    int osPadding = 0;
    int osPadding2 = 0;
    int buttonSpacer = 0;

    ConfigSelector() {
        int _padding = (systemMode == SYSTEMMODE_POSTINIT) ? -3 : 3;
        w = 140;
        x = width - w - _padding;
        y = (navBarHeight * 2) - 3;
        margin = 6;
        b_w = w - margin*2;
        b_h = 22;
        h = margin*3 + b_h;
        //makes the setting text "are you sure" display correctly on linux
        osPadding = isLinux() ? -3 : -2;
        osPadding2 = isLinux() ? 5 : 0;

        isVisible = false;

        configOptions = new ArrayList<Button_obci>();
        addConfigButtons();

        buttonSpacer = (systemMode == SYSTEMMODE_POSTINIT) ? configOptions.size() : configOptions.size() - 4;
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
            rect(x+w-(topNav.settingsButton.getWidth()-1), y, (topNav.settingsButton.getWidth()-1), 1);

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
            if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.settingsButton.isInside()) {
                toggleVisibility();
                clearAllSettingsPressed = false;
            }
            for (int i = 0; i < configOptions.size(); i++) {
                if (configOptions.get(i).isMouseHere() && configOptions.get(i).isActive()) {
                    int configSelected = i;
                    configOptions.get(i).setIsActive(false);
                    if (configSelected == 0) { //If expert mode toggle button is pressed...
                        if (configOptions.get(0).getButtonText().equals("Turn Expert Mode On")) {
                            configOptions.get(0).setString("Turn Expert Mode Off");
                            configOptions.get(0).setColorNotPressed(expertPurple);
                            println("TopNav: Expert Mode On");
                            output("Expert Mode ON: All keyboard shortcuts and features are enabled!");
                            settings.expertModeToggle = true;
                        } else {
                            configOptions.get(0).setString("Turn Expert Mode On");
                            configOptions.get(0).setColorNotPressed(newGreen);
                            println("TopNav: Expert Mode Off");
                            output("Expert Mode OFF: Use spacebar to start/stop the data stream.");
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
        } else if ((systemMode < SYSTEMMODE_POSTINIT) && isVisible && topNav.settingsButton.isActive()) {
            //resize the height of the settings dropdown
            h = margin*2 + b_h;
            clearAllSettingsPressed = false;
        }
    }

    void addConfigButtons() {
        //Customize initial button appearance here
        //setup button 0 -- Expert Mode Toggle Button
        int buttonNumber = 0;
        Button_obci tempConfigButton = new Button_obci (x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Turn Expert Mode On");
        tempConfigButton.setFont(p5, 12);
        tempConfigButton.setColorNotPressed(newGreen);
        tempConfigButton.setFontColorNotActive(color(255));
        tempConfigButton.setHelpText("Expert Mode enables advanced keyboard shortcuts and access to all GUI features.");
        configOptions.add(tempConfigButton);

        //setup button 1 -- Save Custom Settings
        buttonNumber++;
        tempConfigButton = new Button_obci (x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Save");
        tempConfigButton.setFont(p5, 12); 
        configOptions.add(tempConfigButton);

        //setup button 2 -- Load Custom Settings
        buttonNumber++;
        tempConfigButton = new Button_obci (x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Load");
        tempConfigButton.setFont(p5, 12);
        configOptions.add(tempConfigButton);

        //setup button 3 -- Default Settings
        buttonNumber++;
        tempConfigButton = new Button_obci (x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Default");
        tempConfigButton.setFont(p5, 12);
        configOptions.add(tempConfigButton);

        //setup button 4 -- Clear All Settings
        buttonNumber = 0;
        //Update the height of the Settings dropdown
        h = margin*(buttonNumber+1) + b_h*(buttonNumber+1);
        tempConfigButton = new Button_obci (x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Clear All");
        tempConfigButton.setFont(p5, 12);
        tempConfigButton.setColorNotPressed(cautionRed);
        tempConfigButton.setFontColorNotActive(color(255));
        tempConfigButton.setHelpText("This will clear all user settings and playback history. You will be asked to confirm.");
        configOptions.add(tempConfigButton);

        //setup button 5 -- Are You Sure? No
        buttonNumber++;
        //leave space for "Are You Sure?"
        tempConfigButton = new Button_obci (x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber+1), b_w, b_h, "No");
        tempConfigButton.setFont(p5, 12);
        configOptions.add(tempConfigButton);


        //setup button 6 -- Are You Sure? Yes
        buttonNumber++;
        tempConfigButton = new Button_obci (x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber+1), b_w, b_h, "Yes");
        tempConfigButton.setFont(p5, 12);
        tempConfigButton.setHelpText("Clicking 'Yes' will delete all user settings and stop the session if running.");
        configOptions.add(tempConfigButton);
    }

    void updateConfigButtonPositions() {
        //update position of outer box and buttons
        int oldX = x;
        int multiplier = (systemMode == SYSTEMMODE_POSTINIT) ? 3 : 2;
        int _padding = (systemMode == SYSTEMMODE_POSTINIT) ? -3 : 3;
        x = width - 70*multiplier - _padding;
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

    public void toggleExpertMode(boolean b) {
        if (b) {
            configOptions.get(0).setString("Turn Expert Mode Off");
            configOptions.get(0).setColorNotPressed(expertPurple);
            println("LoadGUISettings: Expert Mode On");
            settings.expertModeToggle = true;
        } else {
            configOptions.get(0).setString("Turn Expert Mode On");
            configOptions.get(0).setColorNotPressed(newGreen);
            println("LoadGUISettings: Expert Mode Off");
            settings.expertModeToggle = false;
        }
    } 
}

class TutorialSelector {

    int x, y, w, h, margin, b_w, b_h;
    boolean isVisible;

    ArrayList<Button_obci> tutorialOptions; //

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

        tutorialOptions = new ArrayList<Button_obci>();
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

            fill(OPENBCI_BLUE);
            // fill(177, 184, 193);
            noStroke();
            rect(x+w-(topNav.tutorialsButton.getWidth()-1), y, (topNav.tutorialsButton.getWidth()-1), 1);

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
            if ((mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) && !topNav.tutorialsButton.isInside()) {
                toggleVisibility();
                //topNav.configButton.setIgnoreHover(false);
            }
            for (int i = 0; i < tutorialOptions.size(); i++) {
                if (tutorialOptions.get(i).isMouseHere() && tutorialOptions.get(i).isActive()) {
                    int tutorialSelected = i+1;
                    tutorialOptions.get(i).setIsActive(false);
                    tutorialOptions.get(i).goToURL();
                    println("Attempting to use your default web browser to open " + tutorialOptions.get(i).myURL);
                    //output("Help button [" + tutorialSelected + "] selected.");
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
        Button_obci tempTutorialButton = new Button_obci(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Getting Started");
        tempTutorialButton.setFont(p5, 12);
        tempTutorialButton.setURL("https://openbci.github.io/Documentation/docs/01GettingStarted/GettingStartedLanding");
        tutorialOptions.add(tempTutorialButton);

        buttonNumber = 1;
        h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
        tempTutorialButton = new Button_obci(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Testing Impedance");
        tempTutorialButton.setFont(p5, 12);
        tempTutorialButton.setURL("https://openbci.github.io/Documentation/docs/06Software/01-OpenBCISoftware/GUIDocs#impedance-testing");
        tutorialOptions.add(tempTutorialButton);

        buttonNumber = 2;
        h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
        tempTutorialButton = new Button_obci(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Troubleshooting Guide");
        tempTutorialButton.setFont(p5, 12);
        tempTutorialButton.setURL("https://docs.openbci.com/docs/10Troubleshooting/GUI_Troubleshooting");
        tutorialOptions.add(tempTutorialButton);

        buttonNumber = 3;
        h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
        tempTutorialButton = new Button_obci(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "Building Custom Widgets");
        tempTutorialButton.setFont(p5, 12);
        tempTutorialButton.setURL("https://openbci.github.io/Documentation/docs/06Software/01-OpenBCISoftware/GUIWidgets#custom-widget");
        tutorialOptions.add(tempTutorialButton);

        buttonNumber = 4;
        h = margin*(buttonNumber+2) + b_h*(buttonNumber+1);
        tempTutorialButton = new Button_obci(x + margin, y + margin*(buttonNumber+1) + b_h*(buttonNumber), b_w, b_h, "OpenBCI Forum");
        tempTutorialButton.setFont(p5, 12);
        tempTutorialButton.setURL("https://openbci.com/forum/");
        tutorialOptions.add(tempTutorialButton);
    }
}
