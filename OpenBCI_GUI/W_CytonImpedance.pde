//Cyton Signal Check Widget aka Cyton Impedance
//Uses classes found in CytonImpedanceEnums.pde and CytonElectrodeStatus.pde

import java.util.concurrent.*;

class W_CytonImpedance extends Widget {

    private BoardCyton cytonBoard;

    //Used to synchronize impedance command threads
    private final Object THREAD_LOCK = new Object();
    ExecutorService es = Executors.newCachedThreadPool();

    private Grid dataGrid;

    private ControlP5 imp_buttons_cp5;
    private ControlP5 threshold_ui_cp5;

    private CytonSignalCheckMode signalCheckMode = CytonSignalCheckMode.IMPEDANCE;
    private CytonImpedanceLabels labelMode = CytonImpedanceLabels.ADS_CHANNEL;
    private CytonImpedanceInterval masterCheckInterval = CytonImpedanceInterval.FIVE;
    
    private final int padding = 5;
    private final int padding_3 = 3;
    private final int numTableRows = 17;
    private final int numTableColumns = 3;
    private final int tableWidth = 190;
    private int tableHeight = 0;
    private int cellHeight = 10;
    
    private final float mapInitialW = 716f;
    private final float mapInitialH = 717f;
    private int imageContainerW, imageContainerH;
    private PImage cytonHeadplotStatic;
    private CytonElectrodeStatus[] cytonElectrodeStatus;
    private int facepad_x, facepad_y, facepad_w;
    private float facepad_h;
    private int translate_facepadX, translate_facepadY;
    private int imageFooterX, imageFooterY; //same width as imageContainerW
    private int footerHeight;

    private Gif checkingImpedanceOnElectrodeGif;

    private int signalQualityStatusTimer;
    private String signalQualityStatusDescription;

    private Button cytonImpedanceMasterCheck;
    private Button cytonResetAllChannels;
    private int masterCheckCounter = 0; //Used to iterate through electrodes
    private int prevMasterCheckCounter = -1;
    private int numElectrodesToMasterCheck = 0;
    private boolean wasDoingImpedanceMasterCheck = false; //Used for state change
    private int prevMasterCheckMillis = 0; //Used for simple timer

    private SignalCheckThresholdUI errorThreshold;
    private SignalCheckThresholdUI warningThreshold;
    private int thresholdTFHeight = 14;
    

    W_CytonImpedance(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        cytonBoard = (BoardCyton) currentBoard;

        imp_buttons_cp5 = new ControlP5(ourApplet);
        imp_buttons_cp5.setGraphics(ourApplet, 0,0);
        imp_buttons_cp5.setAutoDraw(false);
        imp_buttons_cp5.setVisible(signalCheckMode == CytonSignalCheckMode.IMPEDANCE);
        threshold_ui_cp5 = new ControlP5(ourApplet);
        threshold_ui_cp5.setGraphics(ourApplet, 0,0);
        threshold_ui_cp5.setAutoDraw(false);

        checkingImpedanceOnElectrodeGif = new Gif(ourApplet, "Rolling-1s-200px.gif");
        checkingImpedanceOnElectrodeGif.loop();

        addDropdown("CytonImpedance_MasterCheckInterval", "Interval", masterCheckInterval.getEnumStringsAsList(), masterCheckInterval.getIndex());
        dropdownWidth = 85; //Override the widget header dropdown width to fit "impedance" mode
        addDropdown("CytonImpedance_LabelMode", "Labels", labelMode.getEnumStringsAsList(), labelMode.getIndex());
        addDropdown("CytonImpedance_Mode", "Mode", signalCheckMode.getEnumStringsAsList(), signalCheckMode.getIndex());

        footerHeight = navH/2;
        
        //Create Table first!
        dataGrid = new Grid(numTableRows, numTableColumns, cellHeight);
        dataGrid.setTableFontAndSize(p6, 10);
        dataGrid.setDrawTableBorder(true);

        //Set Column Labels
        dataGrid.setString("N Status", 0, 1);
        dataGrid.setString("P Status", 0, 2);

        setTableElectrodeNames();

        //Init the electrode map and fill and create signal check buttons
        initCytonImpedanceMap();

        cytonImpedanceMasterCheck = createCytonImpMasterCheckButton("cytonImpedanceMasterCheck", "Check All Channels", (int)(x + padding_3), (int)(y + padding_3 - navHeight), 120, navHeight - 6, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        cytonResetAllChannels = createCytonResetChannelsButton("cytonResetAllChannels", "Reset Channels", (int)(x + padding_3*2 + 120), (int)(y + padding_3 - navHeight), 90, navHeight - 6, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        errorThreshold = new SignalCheckThresholdUI(threshold_ui_cp5, "errorThreshold", 90, x + tableWidth + padding, y + h - navH, 30, thresholdTFHeight, SIGNAL_CHECK_RED, signalCheckMode);
        warningThreshold = new SignalCheckThresholdUI(threshold_ui_cp5, "warningThreshold", 75, x + tableWidth + padding, y + h - navH/2, 30, thresholdTFHeight, SIGNAL_CHECK_YELLOW, signalCheckMode);
    }

    public void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        if (is_railed == null) {
            return;
        }

        List<controlP5.Controller> cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        for (int i = 0; i < cytonElectrodeStatus.length; i++) {
            cytonElectrodeStatus[i].update(dataGrid, signalCheckMode.getIsImpedanceMode());
            cp5ElementsToCheck.add((controlP5.Controller)cytonElectrodeStatus[i].getTestingButton());
        }
        cp5ElementsToCheck.add((controlP5.Controller)cytonImpedanceMasterCheck);
        cp5ElementsToCheck.add((controlP5.Controller)cytonResetAllChannels);
        //Ignore button interaction when widgetSelector dropdown is active
        lockElementsOnOverlapCheck(cp5ElementsToCheck);

        errorThreshold.update();
        warningThreshold.update();

        //Use state change logic so we can run this test in the main thread using simple timer
        if (cytonMasterImpedanceCheckIsActive()) {
            doMasterImpedanceCheck();
        } else {
            if (!dropdownIsActive) {
                //setLockAllImpedanceTestingButtons(false);
            }
        }  
    }

    public void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        dataGrid.draw();

        /*
        pushStyle();
        stroke(0,0,0,255);
        fill(0,255,0,50);
        strokeWeight(3);
        rect(facepad_x, facepad_y, facepad_w, (int)facepad_h);
        popStyle();
        */
        //Scale the dataImage to fit in inside the widget
        float s = facepad_w / mapInitialW;
        /*
        pushStyle();
        stroke(0,0,0,255);
        fill(0,100,142,100);
        strokeWeight(3);
        rect(t_facepadX, t_facepadY, facepad_w, (int)facepad_h);
        popStyle();
        */
        pushMatrix(); // save the transformation matrix
        translate(translate_facepadX, translate_facepadY);
        scale(s); // scale the transformation matrix
        /*
        pushStyle();
        stroke(0,0,0,255);
        fill(0,255,0,100);
        strokeWeight(3);
        rect(0, 0, mapInitialW, mapInitialH);
        popStyle();
        */
        image(cytonHeadplotStatic, 0, 0);
        popMatrix(); // restore the transformation matrix

        drawUserLeftRightLabels();

        imp_buttons_cp5.draw();
        threshold_ui_cp5.draw();

        drawImageFooterInfo();
    }

    public void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        int overrideDropdownWidth = 64;
        cp5_widget.get(ScrollableList.class, "CytonImpedance_MasterCheckInterval").setWidth(overrideDropdownWidth);
        cp5_widget.get(ScrollableList.class, "CytonImpedance_MasterCheckInterval").setPosition(x0+w0-dropdownWidth*2-overrideDropdownWidth-6, navH+y0+2);

        //**IMPORTANT FOR CP5**//
        //This makes the cp5 objects within the widget scale properly
        imp_buttons_cp5.setGraphics(pApplet, 0, 0);
        threshold_ui_cp5.setGraphics(pApplet, 0, 0);

        cytonImpedanceMasterCheck.setPosition((int)(x + padding_3), (int)(y + padding_3 - navHeight));
        cytonResetAllChannels.setPosition((int)(x + padding_3*2 + 120), (int)(y + padding_3 - navHeight));

        resizeTable();

        imageContainerW = w - padding*3 - tableWidth;
        imageContainerH = h - padding*2 - navH;

        facepad_x = x + padding*2 + tableWidth;
        facepad_y = y + padding;
        facepad_w = w - padding*3 - tableWidth;
        //println("BEFORE="+facepad_w);
        //Get scale using container width for facepad divided by original width of image
        float _scale = facepad_w / mapInitialW;
        facepad_h = _scale * mapInitialH;
        if (facepad_h > imageContainerH) {
            //println("OOPS... FACEPAD WOULD BE TOO BIG, RESIZING TO FIT WIDGET AND KEEP ASPECT RATIO", facepad_h, imageContainerH);
            facepad_w = Math.round(facepad_w * (imageContainerH / facepad_h));
            _scale = facepad_w / mapInitialW;
            facepad_h = _scale * mapInitialH;
            //println("AFTER=="+facepad_w);
        }

        //Center the image horizontally and vertically
        translate_facepadX = (facepad_w < imageContainerW) ? facepad_x + int((imageContainerW - facepad_w) / 2) : facepad_x;
        translate_facepadY = (facepad_h < imageContainerH) ? facepad_y + (int(imageContainerH/2) - int(facepad_h/2)) : facepad_y;

        for (int i = 0; i < cytonElectrodeStatus.length; i++) {
            cytonElectrodeStatus[i].resizeButton(dataGrid);
        }

        //Calculate these values last
        imageFooterX = translate_facepadX + facepad_w / 2; //centered under the visual map container
        imageFooterY = y + h - footerHeight;
        
        //final int thresholdTF_y = y + tableHeight + padding*2;
        RectDimensions dim = dataGrid.getCellDims(numTableRows - 1, 1);
        warningThreshold.setPosition(dim.x, dim.y + dim.h + padding);
        warningThreshold.setSize(dim.w, thresholdTFHeight);
        dim = dataGrid.getCellDims(numTableRows - 1, 2);
        errorThreshold.setPosition(dim.x + 1, dim.y + dim.h + padding);
        errorThreshold.setSize(dim.w, thresholdTFHeight);
    }

    private void resizeTable() {
        tableHeight = getTableContainerHeight();
        dataGrid.setDim(x + padding, y + padding, tableWidth);
        dataGrid.setTableHeight(tableHeight);
        dataGrid.dynamicallySetTextVerticalPadding(0, 1);
        dataGrid.setHorizontalCenterTextInCells(true);
    }

    private int getTableContainerHeight() {
        return h - (padding * 3) - footerHeight;
    }

    public void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
    }

    public void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    }

    private void initCytonImpedanceMap() {
        if (nchan == 8) {
            cytonHeadplotStatic = loadImage("Cyton_8Ch_Static_Headplot_Image.png");
        } else {
            cytonHeadplotStatic = loadImage("Cyton_16Ch_Static_Headplot_Image.png");
        }
        
        //Instantiate electrodeStatus for all electrodes!
        cytonElectrodeStatus = new CytonElectrodeStatus[nchan];
        for (int i = 0; i < cytonElectrodeStatus.length; i++) {
            cytonElectrodeStatus[i] = new CytonElectrodeStatus(imp_buttons_cp5, CytonElectrodeLocations.getByIndex(i), cytonBoard, checkingImpedanceOnElectrodeGif);
            println("CYTON ELECTRODE STATUS making electrode #", i);
        }
    }

    public void setTableElectrodeNames() {
        if (labelMode.getIsAnatomicalName()) {
            //If true, set anatomical names as text in the table.
            dataGrid.setString("Hi", 0, 0);
            dataGrid.setString("Hi", 1, 0);
            dataGrid.setString("Hi", 2, 0);
            dataGrid.setString("Hi", 3, 0);
            dataGrid.setString("Hi", 4, 0);
            dataGrid.setString("Hi", 5, 0);
            dataGrid.setString("Hi", 6, 0);
            dataGrid.setString("Hi", 7, 0);
            dataGrid.setString("Hi", 8, 0);
            dataGrid.setString("Hi", 9, 0);
            dataGrid.setString("Hi", 10, 0);
            dataGrid.setString("Hi", 11, 0);
            dataGrid.setString("Hi", 12, 0);
            dataGrid.setString("Hi", 13, 0);
            dataGrid.setString("Hi", 14, 0);
            dataGrid.setString("Hi", 15, 0);
            dataGrid.setString("Hi", 16, 0);
        } else {
            //Else, set ADS Channel names
            dataGrid.setString("Channel", 0, 0);
            for (int i = 1; i < numTableRows; i++) {
                dataGrid.setString(Integer.toString(i), i, 0);
            }
        }
    }


    //This is a very important method that helps this widget change signal check mode. Called when user selects option from Mode dropdown.
    public void setSignalCheckMode(int n) {
        signalCheckMode = signalCheckMode.values()[n];
        if (signalCheckMode == CytonSignalCheckMode.LIVE) {
            ////Toggle showing impedance test buttons
            imp_buttons_cp5.setVisible(false);
            //Green out all electrode positions initially when switching to railed/live mode
            for (int i = 0; i < cytonElectrodeStatus.length; i++) {
                cytonElectrodeStatus[i].setElectrodeGreenStatus();
            }
            turnOffImpedanceCheckPreviousElectrode();
            //Hide and disable master impedance check
            cytonImpedanceMasterCheck.setVisible(false);
            cytonImpedanceMasterCheck.setOff();
        } else if (signalCheckMode == CytonSignalCheckMode.IMPEDANCE) {
            //Attempt to close Hardware Settings view. Also, throws a popup if there are unsent changes.
            if (w_timeSeries.getAdsSettingsVisible()) {
                w_timeSeries.closeADSSettings();
            }
            //Clear the cells and show buttons instead
            for (int i = 1; i < numTableRows; i++) {
                dataGrid.setString(null, i, 1);
                dataGrid.setString(null, i, 2);
            }
            //Toggle showing impedance test buttons
            imp_buttons_cp5.setVisible(true);

            cytonImpedanceMasterCheck.setVisible(true);
        }
        errorThreshold.updateTextfieldModeChanged(signalCheckMode);
        warningThreshold.updateTextfieldModeChanged(signalCheckMode);
    }

    public void setShowAnatomicalName(int n) {
        labelMode = labelMode.values()[n];
        setTableElectrodeNames();
    }

    public void setMasterCheckInterval(int n) {
        masterCheckInterval = masterCheckInterval.values()[n];
    }
    
    public void drawUserLeftRightLabels() {
        pushStyle();
        fill(OPENBCI_DARKBLUE);
        textAlign(CENTER);
        textFont(h4, 14);
        String s = "User Left";
        float _x = translate_facepadX + facepad_w * .2;
        float _y = y + 20;
        text(s, _x , _y);
        s = "User Right";
        _x = translate_facepadX + facepad_w * .8;
        text(s, _x , _y);
        popStyle();
    }

    private void drawImageFooterInfo() {
        //Draw "thresholds" text label below the table under the first column
        RectDimensions dim = dataGrid.getCellDims(numTableRows - 1, 0);
        int thresholdTextX = dim.x + dim.w / 2;
        pushStyle();
        textFont(p6, 10);
        textAlign(CENTER, TOP);
        fill(ElectrodeState.GREYED_OUT.getColor());
        text("Thresholds", thresholdTextX, dim.y + dim.h + padding);
        popStyle();
        
        pushStyle();
        textFont(p5, 12);
        textAlign(CENTER);
        String s;
        color c = ElectrodeState.GREYED_OUT.getColor();
        if (signalCheckMode == CytonSignalCheckMode.IMPEDANCE) {
            Pair<String, ElectrodeState> pair = getImpedanceStringAndState();
            s = pair.getLeft();
            c = pair.getRight().getColor();
            //Skip over facepad electrodes that do not correspond to a channel number (PPG, EDA, BIAS, and SRB2)
            if (s == null) {
                if (cytonImpedanceMasterCheck.getBooleanValue()) {
                    popStyle();
                    return;
                } else {
                    //If not checking impedance on all channels, display this text in the footer
                    s = "Click a \"Test\" button in the table to start.";
                }
            }
        } else {
            s = numberOfRailedChanDescription();
        }
        fill(c);
        text(s, imageFooterX, imageFooterY);
        popStyle();
    }

    private String numberOfRailedChanDescription() {
        //Update roughly once a second, to keep text from jittering between options
        boolean timeToUpdate = millis() > signalQualityStatusTimer + 1000;
        if (timeToUpdate) {
            int counter = 0;
            for (int i = 0; i < is_railed.length; i++) {
                if (is_railed[i].is_railed) {
                    counter++;
                }
            }
            String s;
            if (counter == 0) {
                s = "Looks great! No railed channels.";
            } else if (counter > 0 && counter <= 5) {
                s = "A few channels are railed.";
            } else {
                s = "Many channels are railed right now."; 
            }
            signalQualityStatusTimer = millis();
            signalQualityStatusDescription = s;
        }     
        return signalQualityStatusDescription;
    }

    private Pair<String, ElectrodeState> getImpedanceStringAndState() {
        final Integer CHAN_X = cytonBoard.isCheckingImpedanceOnAnyChannelsNorP().getValue();
        final Boolean CHAN_X_ISNPIN = cytonBoard.isCheckingImpedanceOnAnyChannelsNorP().getKey();
        final int NUM_FRONT_CHAN = 8;
        if (CHAN_X == null && CHAN_X_ISNPIN == null) {
            return new ImmutablePair<String, ElectrodeState>(null, ElectrodeState.GREYED_OUT);
        }

        final Integer _CHAN = CHAN_X + 1;
        for (CytonElectrodeStatus e : cytonElectrodeStatus) {
            //println(_chan, e.getGUIChannelNumber(), " -- ", chanX_isNpin, e.getIsNPin());
            if (_CHAN.equals(e.getGUIChannelNumber())
                && CHAN_X_ISNPIN.equals(e.getIsNPin())) {
                    return new ImmutablePair<String, ElectrodeState>(
                        e.getImpedanceValueAsString(labelMode.getIsAnatomicalName()), 
                        e.getElectrodeState()
                    );
            }
        }
        return new ImmutablePair<String, ElectrodeState>("Oops?", ElectrodeState.GREYED_OUT);
    }

    private Button createCytonImpMasterCheckButton(String name, String text, int _x, int _y, int _w, int _h, PFont _font, int _fontSize, color _bg, color _textColor) {
        final Button myButton = createButton(cp5_widget, name, text, _x, _y, _w, _h, _font, _fontSize, _bg, _textColor);
        myButton.setSwitch(true);
        myButton.setVisible(signalCheckMode == CytonSignalCheckMode.IMPEDANCE);
        myButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                boolean isActive = myButton.getBooleanValue();
                StringBuilder sb = new StringBuilder("Signal Quality Test: User toggled checking impedance on all channels to ");
                sb.append(isActive);
                println(sb.toString());
                if (!isActive) {
                    Executors.newSingleThreadExecutor().execute(new Runnable() {
                        @Override
                        public void run() {
                            hardResetAllChannels();
                        }
                    });
                } else {
                    setLockAllImpedanceTestingButtons(isActive);
                }
            }
        });
        myButton.setDescription("Click to check impedance on all electrodes. Please allow time for commands to be sent to the board!");
        return myButton;
    }

    public boolean cytonMasterImpedanceCheckIsActive() {
        return cytonImpedanceMasterCheck.getBooleanValue();
    }

    private Button createCytonResetChannelsButton(String name, String text, int _x, int _y, int _w, int _h, PFont _font, int _fontSize, color _bg, color _textColor) {
        final Button myButton = createButton(cp5_widget, name, text, _x, _y, _w, _h, _font, _fontSize, _bg, _textColor);
        //myButton.setSwitch(true);
        myButton.setVisible(signalCheckMode == CytonSignalCheckMode.IMPEDANCE);
        myButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                println("Cyton Impedance Check: User clicked reset all channel settings.");
                Executors.newSingleThreadExecutor().execute(new Runnable() {
                    @Override
                    public void run() {
                        hardResetAllChannels();
                    }
                });
            }
        });
        myButton.setDescription("Click to reset all channel settings to default.");
        return myButton;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Toggle impedance on an electrode using commands sent to board and override the testing button.              //
    //  Do this asynchonously in a separate thread for the first time in the history of the GUI!!!                  //
    //  This is the most important method in this class.                                                            //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public void toggleImpedanceOnElectrode(final boolean toggle, final Integer checkingChanX, final Boolean checkingChanX_isNpin, final int curMillis) {
        try {
            es.submit(new Runnable() {
                @Override
                public void run() {
                    synchronized (THREAD_LOCK) {
                        setLockAllImpedanceTestingButtons(true);
                        //println("^^^^^^^^^^^NEW THREAD!!!");

                        if (topNav.dataStreamingButtonIsActive()) {
                            stopRunning();
                            topNav.resetStartStopButton();
                        } else {
                            cytonBoard.stopStreaming();
                        }

                        //Turn off impedance check on another electrode if checking there
                        Integer checkingOtherChan = cytonBoard.isCheckingImpedanceOnAnyChannelsNorP().getValue();
                        Boolean checkingOtherChan_isNpin = cytonBoard.isCheckingImpedanceOnAnyChannelsNorP().getKey();
                        if (checkingOtherChan != null) {
                            if (checkingChanX != checkingOtherChan || (checkingChanX == checkingOtherChan && checkingChanX_isNpin != checkingOtherChan_isNpin)) {
                                //println("-----SEND COMMAND TO TOGGLE OFF PREVIOUS ELECTRODE");
                                cytonBoard.setCheckingImpedanceCyton(checkingOtherChan, false, checkingOtherChan_isNpin);
                                
                                checkingOtherChan = checkingOtherChan + 1;
                                for (CytonElectrodeStatus e : cytonElectrodeStatus) {
                                    //println(_chan, e.getGUIChannelNumber(), " -- ", checkingChanX_isNpin, e.getIsNPin());
                                    if (checkingOtherChan.equals(e.getGUIChannelNumber())
                                        && checkingOtherChan_isNpin.equals(e.getIsNPin())) {
                                            //println("TOGGLE OFF", e.getGUIChannelNumber(), e.getIsNPin(), "TOGGLE TO ==", false);
                                            e.overrideTestingButtonSwitch(false);
                                            w_timeSeries.adsSettingsController.updateChanSettingsDropdowns(checkingOtherChan-1, cytonBoard.isEXGChannelActive(checkingOtherChan-1));
                                            w_timeSeries.adsSettingsController.setHasUnappliedSettings(checkingOtherChan-1, false);
                                    }
                                }

                                //Add a small delay between turning off previous channel check and checking impedance on new channel
                                //println("~*~*~* 150ms Delay");
                                delay(150);
                            }
                        }

                        //println("+++++TOGGLING IMPEDANCE");
                        final Pair<Boolean, String> fullResponse = cytonBoard.setCheckingImpedanceCyton(checkingChanX, toggle, checkingChanX_isNpin);
                        boolean response = fullResponse.getKey().booleanValue();
                        if (!response) {
                            println("Board Communication Error: Error sending impedance test commands. See additional info in Console Log. You may need to reset the hardware.");
                            PopupMessage msg = new PopupMessage("Board Communication Error", "Error sending impedance test commands during Check All Channels. See additional info in Console Log. You may need to reset the hardware.");
                            cytonImpedanceMasterCheck.setOff();
                        } else {
                            //If successful, update the front end components to reflect the new state
                            w_timeSeries.adsSettingsController.updateChanSettingsDropdowns(checkingChanX, cytonBoard.isEXGChannelActive(checkingChanX));
                            w_timeSeries.adsSettingsController.setHasUnappliedSettings(checkingChanX, false);
                        }

                        boolean shouldBeOn = toggle && response;
                        final Integer _chan = checkingChanX + 1;
                        for (CytonElectrodeStatus e : cytonElectrodeStatus) {
                            //println(_chan, e.getGUIChannelNumber(), " -- ", checkingChanX_isNpin, e.getIsNPin());
                            if (_chan.equals(e.getGUIChannelNumber())
                                && checkingChanX_isNpin.equals(e.getIsNPin())) {
                                    //println("TOGGLE ", e.getGUIChannelNumber(), e.getIsNPin(), "TOGGLE TO ==", shouldBeOn);
                                    e.overrideTestingButtonSwitch(shouldBeOn);
                                }
                        }

                        Boolean isCheckingImpedance = cytonBoard.isCheckingImpedanceOnAnyChannelsNorP().getLeft();
                        if (isCheckingImpedance != null) {
                            if (!currentBoard.isStreaming()) {
                                cytonBoard.startStreaming();
                            }
                        } else {
                            cytonBoard.stopStreaming();
                        }
                        
                        if (!cytonMasterImpedanceCheckIsActive()) {
                            setLockAllImpedanceTestingButtons(false);
                        } else {
                            prevMasterCheckMillis = curMillis;
                            masterCheckCounter++;
                        }
                    }
                }
            });
        } catch (RejectedExecutionException e) {
            println("CytonImpedanceError::"+e.getMessage());
            outputError("Cyton Signal Check Error: Please be patient when pressing \'Check All Channels\' button!");
            PopupMessage msg = new PopupMessage("Cyton Signal Check Error", "Please be patient when pressing \'Check All Channels\' button! You will likely need to restart a GUI session and turn the Cyton off and on.");
        }
    }

    ////////////////////////////////////////////////////////////////
    //  Master Impedance Check has been toggled on. Do the work!  //
    ////////////////////////////////////////////////////////////////
    private void doMasterImpedanceCheck() {
        setLockAllImpedanceTestingButtons(true);
        final int curMillis = millis();
        final boolean iterateNow = prevMasterCheckCounter != masterCheckCounter && curMillis - prevMasterCheckMillis > masterCheckInterval.getValue();
        //println("MASTER_CHECK_TIMER==",curMillis - prevMasterCheckMillis);
        
        if (iterateNow) {
            
            prevMasterCheckCounter = masterCheckCounter;

            numElectrodesToMasterCheck = currentBoard.getNumEXGChannels();

            /*
            if (guiSettings.getExpertModeBoolean()) {
                numElectrodesToMasterCheck += nchan; //CHECK N AND P IF EXPERT MODE
            }
            */
            
            if (masterCheckCounter == numElectrodesToMasterCheck) {
                masterCheckCounter = 0;
                prevMasterCheckCounter = 0;
            }

            boolean isNPin = true;
            Integer guiChanNum = null;
            isNPin = cytonElectrodeStatus[masterCheckCounter].getIsNPin();
            guiChanNum = cytonElectrodeStatus[masterCheckCounter].getGUIChannelNumber();
            //println("MASTER_CHECK_TIMER_CHECKING==", guiChanNum, isNPin);

            /*
            if (guiChanNum == null) {
                prevMasterCheckMillis = curMillis - masterCheckInterval.getValue();
                //println("SKIP!!!!!!");
                return;
            }
            */

            guiChanNum -= 1; //Subtract 1 here since the following methods count starting from 0

            // Toggle impedance on for the next electrode
            toggleImpedanceOnElectrode(true, guiChanNum, isNPin, curMillis);
            
        }
    }

    private void hardResetAllChannels() {

        if (cytonMasterImpedanceCheckIsActive()) {
            cytonImpedanceMasterCheck.setOff();
            cytonBoard.stopStreaming();
        }

        if (topNav.dataStreamingButtonIsActive()) {
            stopRunning();
            topNav.resetStartStopButton();
        }

        //es.shutdown();
        int timeElapsed = millis();
        //println("______________________________AWAITING TERMINATION OF EXECUTOR SERVICE___");
        es.shutdown();
        try {
            if (!es.awaitTermination(10, TimeUnit.SECONDS)) {
                es.shutdownNow();
                println("ERROR: HAD TO FORCE EXECUTOR SERVICE SHUTDOWN");
            }
        } catch (InterruptedException ex) {
            ex.printStackTrace();
            es.shutdownNow();
            Thread.currentThread().interrupt();
        }
        es = Executors.newCachedThreadPool();
        
        /*
        final Integer checkingChanX = cytonBoard.isCheckingImpedanceOnAnyChannelsNorP().getValue();
        final Boolean checkingChanX_isNpin = cytonBoard.isCheckingImpedanceOnAnyChannelsNorP().getKey();
        if (checkingChanX != null) {
            println("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&HAVING TO FORCE TURN OFF AN ELECTRODE THAT WAS LEFT ON");
        }
        */

        turnOffImpedanceCheckPreviousElectrode();
        setLockAllImpedanceTestingButtons(true);

        es.shutdown();
        try {
            if (!es.awaitTermination(10, TimeUnit.SECONDS)) {
                es.shutdownNow();
                println("ERROR: HAD TO FORCE EXECUTOR SERVICE SHUTDOWN");
            }
        } catch (InterruptedException ex) {
            ex.printStackTrace();
            es.shutdownNow();
            Thread.currentThread().interrupt();
        }
        es = Executors.newCachedThreadPool();
        
        // Send board reset twice to increase success rate
        cytonBoard.sendCommand("d");
        delay(100);
        cytonBoard.sendCommand("d");

        // Update ADS1299 settings to default but don't commit. Instead, sent "d" command twice.
        cytonBoard.getADS1299Settings().revertAllChannelsToDefaultValues();
        w_timeSeries.adsSettingsController.updateAllChanSettingsDropdowns();

        timeElapsed = millis() - timeElapsed;
        StringBuilder sb = new StringBuilder("Cyton Impedance Check: Hard reset to default board mode took -- ");
        sb.append(timeElapsed);
        sb.append(" ms");
        println(sb.toString());

        prevMasterCheckCounter--;
        setLockAllImpedanceTestingButtons(false);
        outputSuccess("Cyton: All channels have been reset and board is in default mode!\n");
    }

    private void turnOffImpedanceCheckPreviousElectrode() {
        //Turn off impedance check on another electrode if checking there
        final Integer checkingChanX = cytonBoard.isCheckingImpedanceOnAnyChannelsNorP().getValue();
        final Boolean checkingChanX_isNpin = cytonBoard.isCheckingImpedanceOnAnyChannelsNorP().getKey();
        if (checkingChanX != null) {
            //println("---------------------------TURN OFF IMPEDANCE CHECK ON ELECTRODE="+checkingChanX+" | IS_N_PIN="+checkingChanX_isNpin);
            toggleImpedanceOnElectrode(false, checkingChanX, checkingChanX_isNpin, millis());
        }
    }

    private void setLockAllImpedanceTestingButtons(boolean _b) {
        //println("*************************************************************LOCKING ALL TEST BUTTONS==",_b);
        for (int i = 0; i < cytonElectrodeStatus.length; i++) {
            cytonElectrodeStatus[i].setLockTestingButton(_b);
        }
    }

    public boolean signalCheckIsRailedMode() {
        return signalCheckMode == CytonSignalCheckMode.LIVE;
    }

    public void updateElectrodeStatusGreenThreshold(double _d) {
        for (int i = 0; i < cytonElectrodeStatus.length; i++) {
            cytonElectrodeStatus[i].updateGreenThreshold(_d);
        }
    }

    public void updateElectrodeStatusYellowThreshold(double _d) {
        for (int i = 0; i < cytonElectrodeStatus.length; i++) {
            cytonElectrodeStatus[i].updateYellowThreshold(_d);
        }
    }
};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
//Update: It's not worth the trouble to implement a callback listener in the widget for this specifc kind of dropdown. Keep using this pattern for widget Nav dropdowns. - February 2021 RW
void CytonImpedance_Mode(int n) {
    w_cytonImpedance.setSignalCheckMode(n);
}

void CytonImpedance_LabelMode(int n) {
    w_cytonImpedance.setShowAnatomicalName(n);
}

void CytonImpedance_MasterCheckInterval(int n) {
    w_cytonImpedance.setMasterCheckInterval(n);
}