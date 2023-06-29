////////////////////////////////////////////////////////////
//                 EmgSettingsUI.pde                      //
//          Display the Emg Settings UI as a popup        //
//            Note: This window is never resized.         //
//                                                        //
////////////////////////////////////////////////////////////

public boolean emgSettingsPopupIsOpen = false;

class EmgSettingsUI extends PApplet implements Runnable {

    PApplet ourApplet;
    private final String HEADER_MESSAGE = "EMG Settings";

    private ControlP5 emgCp5;
    private int x, y, w, h;
    private final int HEADER_HEIGHT = 55;
    private final int FOOTER_PADDING = 90;
    private final int PADDING_3 = 3;
    private final int PADDING_12 = 12;
    private final int NUM_CONTROL_BUTTONS = 3;
    private final int ROW_HEIGHT = 40;
    private final int DROPDOWN_HEIGHT = 18; 
    private final int NUM_COLUMNS = 7;
    private final int DROPDOWN_SPACER = 5;
    private int dropdownWidth;
    private boolean isFixedHeight;
    private int fixedHeight;
    private int[] dropdownYPositions;
    private final int NUM_FOOTER_OBJECTS = 3;
    private final int FOOTER_OBJECT_WIDTH = 45;
    private final int FOOTER_OBJECT_HEIGHT = 26;
    private int footerObjY;
    private int[] footerObjX = new int[NUM_FOOTER_OBJECTS];

    private final color HEADER_COLOR = OPENBCI_BLUE;
    private final color BACKGROUND_COLOR = GREY_235;
    private final color LABEL_COLOR = WHITE;

    private final int defaultWidth = 600;
    private final int defaultHeight = 600;

    public EmgSettingsValues emgSettingsValues;

    private TextBox channelColumnLabel;
    private TextBox windowLabel;
    private TextBox uvLimitLabel;
    private TextBox creepIncLabel;
    private TextBox creepDecLabel;
    private TextBox minDeltaUvLabel;
    private TextBox lowLimitLabel;

    private ScrollableList[] windowLists;
    private ScrollableList[] uvLimitLists;
    private ScrollableList[] creepIncLists;
    private ScrollableList[] creepDecLists;
    private ScrollableList[] minDeltaUvLists;
    private ScrollableList[] lowLimitLists;

    private int channelCount;

    private String[] channelLabels;

    private Button saveButton;
    private Button loadButton;
    private Button defaultButton;

    @Override
    public void run() {
        PApplet.runSketch(new String[] {HEADER_MESSAGE}, this);
    }

    public EmgSettingsUI() {
        super();
        emgSettingsPopupIsOpen = true;

        Thread t = new Thread(this);
        t.start();

        emgSettingsValues = dataProcessing.emgSettings.values;

        channelCount = currentBoard.getNumEXGChannels();

        x = 0;
        y = 0;
        w = defaultWidth;
        h = HEADER_HEIGHT + (channelCount * ROW_HEIGHT) + FOOTER_PADDING;
    }

    @Override
    public void settings() {
        size(defaultWidth, h);
    }

    @Override
    public void setup() {

        ourApplet = this;

        surface.setTitle(HEADER_MESSAGE);
        surface.setAlwaysOnTop(false);
        surface.setResizable(false);

        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.toFront();
        frame.requestFocus();

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        emgCp5 = new ControlP5(ourApplet);
        emgCp5.setGraphics(ourApplet, 0,0);
        emgCp5.setAutoDraw(false);

        createAllUIObjects();
    }

    @Override
    public void draw() {
        clear();
        scene();

        // Draw header
        noStroke();
        fill(HEADER_COLOR);
        rect(0, 0, width, HEADER_HEIGHT);

        emgSettingsValues = dataProcessing.emgSettings.values;

        checkIfSessionWasClosed();
        checkIfSettingsWereLoaded();

        //Draw column labels
        channelColumnLabel.draw();
        windowLabel.draw();
        uvLimitLabel.draw();
        creepIncLabel.draw();
        creepDecLabel.draw();
        minDeltaUvLabel.draw();
        lowLimitLabel.draw();

        drawChannelLabels();

        //Draw cp5 objects on top of everything
        emgCp5.draw();
    }

    private void scene() {
        // Draw background
        background(BACKGROUND_COLOR);
    }

    @Override
    public void keyReleased() {
        
    }

    @Override
    public void keyPressed() {

    }

    @Override
    public void mousePressed() {

    }

    @Override
    public void mouseReleased() {

    }

    @Override
    public void exit() {
        dispose();
        emgSettingsPopupIsOpen = false;
    }

    private void checkIfSessionWasClosed() {
        if (systemMode == SYSTEMMODE_PREINIT) {
            noLoop();
            Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
            frame.dispose();
            exit();
        }
    }

    private void checkIfSettingsWereLoaded() {
        if (dataProcessing.emgSettings.getSettingsWereLoaded()) {
            try {
                updateCp5Objects();
            } catch (Exception e) {
                e.printStackTrace();
                outputError("EMG Settings UI: Unable to apply settings. Please save EMG Settings to a new file.");
            }
            dataProcessing.emgSettings.setSettingsWereLoaded(false);
        }
    }

    private void drawChannelLabels() {
        int colWidth = (w / NUM_COLUMNS);
        int colOffset = colWidth / 2;
        
        pushStyle();

        fill(OPENBCI_DARKBLUE);
        textFont(p5, 12);
        textLeading(12);
        textAlign(CENTER, CENTER);

        for (int i = 0; i < channelCount; i++) {
            String channelLabel = channelCount > channelLabels.length ? "Channel " + Integer.toString(i + 1) : channelLabels[i];
            text(channelLabel, x + colOffset, dropdownYPositions[i] + (DROPDOWN_HEIGHT / 2) - 2);
        }

        popStyle();
    }

    private void resizeDropdowns() {
        dropdownWidth = int((w - (DROPDOWN_SPACER * (NUM_COLUMNS + 1))) / NUM_COLUMNS);
        final int MAX_HEIGHT_ITEMS = 6;

        for (int i = 0; i < channelCount; i++) {
            int dropdownX = x + DROPDOWN_SPACER * 2 + dropdownWidth;
            dropdownYPositions[i] = HEADER_HEIGHT + int(y + ((ROW_HEIGHT) * i) + (((ROW_HEIGHT) - DROPDOWN_HEIGHT) / 2));
            final int buttonXIncrement = DROPDOWN_SPACER + dropdownWidth;

            windowLists[i].setPosition(dropdownX, dropdownYPositions[i]);
            windowLists[i].setSize(dropdownWidth, MAX_HEIGHT_ITEMS * DROPDOWN_HEIGHT);
            
            dropdownX += buttonXIncrement;
            uvLimitLists[i].setPosition(dropdownX, dropdownYPositions[i]);
            uvLimitLists[i].setSize(dropdownWidth, (uvLimitLists[i].getItems().size()+1) * DROPDOWN_HEIGHT);

            dropdownX += buttonXIncrement;
            creepIncLists[i].setPosition(dropdownX, dropdownYPositions[i]);
            creepIncLists[i].setSize(dropdownWidth, MAX_HEIGHT_ITEMS * DROPDOWN_HEIGHT);

            dropdownX += buttonXIncrement;
            creepDecLists[i].setPosition(dropdownX, dropdownYPositions[i]);
            creepDecLists[i].setSize(dropdownWidth, MAX_HEIGHT_ITEMS * DROPDOWN_HEIGHT);

            dropdownX += buttonXIncrement;
            minDeltaUvLists[i].setPosition(dropdownX, dropdownYPositions[i]);
            minDeltaUvLists[i].setSize(dropdownWidth, MAX_HEIGHT_ITEMS * DROPDOWN_HEIGHT);

            dropdownX += buttonXIncrement;
            lowLimitLists[i].setPosition(dropdownX, dropdownYPositions[i]);
            lowLimitLists[i].setSize(dropdownWidth, MAX_HEIGHT_ITEMS * DROPDOWN_HEIGHT);
        }
    }

    private void createAllUIObjects() {
        footerObjY = y + h - FOOTER_PADDING/2 - FOOTER_OBJECT_HEIGHT/2;
        int middle = x + w / 2;
        int halfObjWidth = FOOTER_OBJECT_WIDTH / 2;
        footerObjX[0] = middle - halfObjWidth - PADDING_12 - FOOTER_OBJECT_WIDTH;
        footerObjX[1] = middle - halfObjWidth;
        footerObjX[2] = middle + halfObjWidth + PADDING_12;
        createEmgSettingsSaveButton("saveEmgSettingsButton", "Save", footerObjX[0], footerObjY, FOOTER_OBJECT_WIDTH, FOOTER_OBJECT_HEIGHT);
        createEmgSettingsLoadButton("loadEmgSettingsButton", "Load", footerObjX[1], footerObjY, FOOTER_OBJECT_WIDTH, FOOTER_OBJECT_HEIGHT);
        createEmgSettingsDefaultButton("defaultEmgSettingsButton", "Reset", footerObjX[2], footerObjY, FOOTER_OBJECT_WIDTH, FOOTER_OBJECT_HEIGHT);

        channelLabels = new String[channelCount];
        for (int i = 0; i < channelCount; i++) {
            channelLabels[i] = "Channel " + (i+1);
        }

        //Create column labels
        color labelBG = color(255,255,255,0);
        color labelTxt = WHITE;
        int colWidth = (w / NUM_COLUMNS);
        int colOffset = colWidth / 2;
        int labelY = y + HEADER_HEIGHT / 2;
        channelColumnLabel = new TextBox("Channel", x + colOffset, labelY, labelTxt, labelBG, 12, h3, CENTER, CENTER);
        windowLabel = new TextBox("Window", x + colOffset + colWidth, labelY, labelTxt, labelBG, 12, h3, CENTER, CENTER);
        uvLimitLabel = new TextBox("uV Limit", x + colOffset + colWidth*2, labelY, labelTxt, labelBG, 12, h3, CENTER, CENTER);
        creepIncLabel = new TextBox("Creep +", x + colOffset + colWidth*3, labelY, labelTxt, labelBG, 12, h3, CENTER, CENTER);
        creepDecLabel = new TextBox("Creep -", x + colOffset + colWidth*4, labelY, labelTxt, labelBG, 12, h3, CENTER, CENTER);
        minDeltaUvLabel = new TextBox("Min \u0394uV", x + colOffset + colWidth*5, labelY, labelTxt, labelBG, 12, h3, CENTER, CENTER);
        lowLimitLabel = new TextBox("Low Limit", x + colOffset + colWidth*6, labelY, labelTxt, labelBG, 12, h3, CENTER, CENTER);

        createAllDropdowns();
    }

    private void createAllDropdowns() {
        //the size and space of these buttons are dependendant on the size of the screen and full ChannelController
        verbosePrint("EmgChannelSettingsUI: Creating EMG channel setting UI objects...");

        windowLists = new ScrollableList[channelCount];
        uvLimitLists = new ScrollableList[channelCount];
        creepIncLists = new ScrollableList[channelCount];
        creepDecLists = new ScrollableList[channelCount];
        minDeltaUvLists = new ScrollableList[channelCount];
        lowLimitLists = new ScrollableList[channelCount];

        dropdownYPositions = new int[channelCount];

        //Init dropdowns in reverse so that chan 1 draws on top of chan 2, etc.
        for (int i = channelCount - 1; i >= 0; i--) {
            int exgChannel = i;
            windowLists[i] = createDropdown(exgChannel, "smooth_ch_"+(i+1), emgSettingsValues.window[exgChannel].values(), emgSettingsValues.window[exgChannel]);
            uvLimitLists[i] = createDropdown(exgChannel, "uvLimit_ch_"+(i+1), emgSettingsValues.uvLimit[exgChannel].values(), emgSettingsValues.uvLimit[exgChannel]);
            creepIncLists[i] = createDropdown(exgChannel, "creep_inc_ch_"+(i+1), emgSettingsValues.creepIncreasing[exgChannel].values(), emgSettingsValues.creepIncreasing[exgChannel]);   
            creepDecLists[i] = createDropdown(exgChannel, "creep_dec_ch_"+(i+1), emgSettingsValues.creepDecreasing[exgChannel].values(), emgSettingsValues.creepDecreasing[exgChannel]);   
            minDeltaUvLists[i] = createDropdown(exgChannel, "minDeltaUv_ch_"+(i+1), emgSettingsValues.minimumDeltaUV[exgChannel].values(), emgSettingsValues.minimumDeltaUV[exgChannel]);       
            lowLimitLists[i] = createDropdown(exgChannel, "lowLimit_ch_"+(i+1), emgSettingsValues.lowerThresholdMinimum[exgChannel].values(), emgSettingsValues.lowerThresholdMinimum[exgChannel]);
        }

        resizeDropdowns();
    }

    private ScrollableList createDropdown(int chanNum, String name, EmgSettingsEnum[] enumValues, EmgSettingsEnum e) {
        dropdownWidth = int((w - (DROPDOWN_SPACER * (NUM_COLUMNS + 1))) / NUM_COLUMNS);
        color _backgroundColor = #FFFFFF;
        ScrollableList list = emgCp5.addScrollableList(name)
            .setOpen(false)
            .setColorBackground(_backgroundColor) // text field bg color
            .setColorValueLabel(OPENBCI_DARKBLUE)       // text color
            .setColorCaptionLabel(OPENBCI_DARKBLUE)
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(BUTTON_PRESSED)       // border color when selected
            .setOutlineColor(OBJECT_BORDER_GREY)
            .setSize(dropdownWidth, DROPDOWN_HEIGHT)//temporary size
            .setBarHeight(DROPDOWN_HEIGHT) //height of top/primary bar
            .setItemHeight(DROPDOWN_HEIGHT) //height of all item/dropdown bars
            .setVisible(true)
            ;
        // for each entry in the enum, add it to the dropdown.
        for (EmgSettingsEnum value : enumValues) {
            // this will store the *actual* enum object inside the dropdown!
            list.addItem(value.getString(), value);
        }
        //Style the text in the ScrollableList
        list.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getString())
            .setFont(h5)
            .setSize(12)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        list.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getString())
            .setFont(p6)
            .setSize(10) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        list.addCallback(new SLCallbackListener(chanNum));
        return list;
    }

    private class SLCallbackListener implements CallbackListener {
        private int channel;
    
        SLCallbackListener(int _i)  {
            channel = _i;
        }
        public void controlEvent(CallbackEvent theEvent) {
            color _bgColor = #FFFFFF;
            //Selecting an item from ScrollableList triggers Broadcast
            if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) { 
                int val = (int)(theEvent.getController()).getValue();
                Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
                EmgSettingsEnum myEnum = (EmgSettingsEnum)bob.get("value");
                verbosePrint("EmgSettings: " + (theEvent.getController()).getName() + " == " + myEnum.getString());

                if (myEnum instanceof EmgWindow) {
                    emgSettingsValues.window[channel] = (EmgWindow)myEnum;
                } else if (myEnum instanceof EmgUVLimit) {
                    emgSettingsValues.uvLimit[channel] = (EmgUVLimit)myEnum;
                } else if (myEnum instanceof EmgCreepIncreasing) {
                    emgSettingsValues.creepIncreasing[channel] = (EmgCreepIncreasing)myEnum;
                } else if (myEnum instanceof EmgCreepDecreasing) {
                    emgSettingsValues.creepDecreasing[channel] = (EmgCreepDecreasing)myEnum;
                } else if (myEnum instanceof EmgMinimumDeltaUV) {
                    emgSettingsValues.minimumDeltaUV[channel] = (EmgMinimumDeltaUV)myEnum;
                } else if (myEnum instanceof EmgLowerThresholdMinimum) {
                    emgSettingsValues.lowerThresholdMinimum[channel] = (EmgLowerThresholdMinimum)myEnum;
                }
            }
        }
    }

    private void createEmgSettingsSaveButton(String name, String text, int _x, int _y, int _w, int _h) {
        saveButton = createButton(emgCp5, name, text, _x, _y, _w, _h, h5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        saveButton.setBorderColor(OBJECT_BORDER_GREY);
        saveButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                dataProcessing.emgSettings.storeSettings();
            }
        });
    }

    private void createEmgSettingsLoadButton(String name, String text, int _x, int _y, int _w, int _h) {
        loadButton = createButton(emgCp5, name, text, _x, _y, _w, _h, h5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        loadButton.setBorderColor(OBJECT_BORDER_GREY);
        loadButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                dataProcessing.emgSettings.loadSettings();
            }
        });
    }

    private void createEmgSettingsDefaultButton(String name, String text, int _x, int _y, int _w, int _h) {
        defaultButton = createButton(emgCp5, name, text, _x, _y, _w, _h, h5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        defaultButton.setBorderColor(OBJECT_BORDER_GREY);
        defaultButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                dataProcessing.emgSettings.revertAllChannelsToDefaultValues();
            }
        });
    }

    private void updateCp5Objects() {
        for (int i = 0; i < channelCount; i++) {
            //Fetch values from the EmgSettingsValues object
            EmgWindow updateSmoothing = emgSettingsValues.window[i];
            EmgUVLimit updateUVLimit = emgSettingsValues.uvLimit[i];
            EmgCreepIncreasing updateCreepIncreasing = emgSettingsValues.creepIncreasing[i];
            EmgCreepDecreasing updateCreepDecreasing = emgSettingsValues.creepDecreasing[i];
            EmgMinimumDeltaUV updateMinimumDeltaUV = emgSettingsValues.minimumDeltaUV[i];
            EmgLowerThresholdMinimum updateLowerThresholdMinimum = emgSettingsValues.lowerThresholdMinimum[i];

            //Update the ScrollableLists
            windowLists[i].getCaptionLabel().setText(updateSmoothing.getString());
            uvLimitLists[i].getCaptionLabel().setText(updateUVLimit.getString());
            creepIncLists[i].getCaptionLabel().setText(updateCreepIncreasing.getString());
            creepDecLists[i].getCaptionLabel().setText(updateCreepDecreasing.getString());
            minDeltaUvLists[i].getCaptionLabel().setText(updateMinimumDeltaUV.getString());
            lowLimitLists[i].getCaptionLabel().setText(updateLowerThresholdMinimum.getString());
        }
    }

    //We have to add an implementation of this class since this is a child instance of PApplet.
    class TextBox {
        private int x, y;
        private int w, h;
        private color textColor;
        private color backgroundColor;
        private PFont font;
        private int fontSize;
        private String string;
        private boolean drawBackground = true;
        private int backgroundEdge_pixels;
        private int alignH,alignV;
        private boolean drawObject = true;

        TextBox(String s, int x1, int y1) {
            string = s; x = x1; y = y1;
            textColor = OPENBCI_DARKBLUE;
            backgroundColor = color(255);
            fontSize = 12;
            font = p5;
            backgroundEdge_pixels = 1;
            drawBackground = false;
            alignH = LEFT;
            alignV = BOTTOM;
        }

        TextBox(String s, int x1, int y1, color _textColor, color _backgroundColor, int _alignH, int _alignV) {
            this(s, x1, y1);
            textColor = _textColor;
            backgroundColor = _backgroundColor;
            drawBackground = true;
            alignH = _alignH;
            alignV = _alignV;
        }

        TextBox(String s, int x1, int y1, color _textColor, color _backgroundColor, int _fontSize, PFont _font, int _alignH, int _alignV) {
            this(s, x1, y1, _textColor, _backgroundColor, _alignH, _alignV);
            fontSize = _fontSize;
            font = _font;
        }
        
        public void draw() {

            if (!drawObject) {
                return;
            }

            pushStyle();
            noStroke();
            textFont(font);

            //draw the box behind the text
            if (drawBackground == true) {
                w = int(round(textWidth(string)));
                int xbox = x - backgroundEdge_pixels;
                switch (alignH) {
                    case LEFT:
                        xbox = x - backgroundEdge_pixels;
                        break;
                    case RIGHT:
                        xbox = x - w - backgroundEdge_pixels;
                        break;
                    case CENTER:
                        xbox = x - int(round(w/2.0)) - backgroundEdge_pixels;
                        break;
                }
                w = w + 2*backgroundEdge_pixels;
                
                h = int(textAscent()) + backgroundEdge_pixels*2;
                int ybox = y;
                if (alignV == CENTER) {
                    ybox -= textAscent() / 2 - backgroundEdge_pixels;
                } else if (alignV == BOTTOM) {
                    ybox -= textAscent() + backgroundEdge_pixels*3;
                }
                fill(backgroundColor);
                rect(xbox,ybox,w,h);
            }
            popStyle();
            
            //draw the text itself
            pushStyle();
            noStroke();
            fill(textColor);
            textAlign(alignH,alignV);
            textFont(font);
            text(string,x,y);
            strokeWeight(1);
            popStyle();
        }

        public void setPosition(int _x, int _y) {
            x = _x;
            y = _y;
        }

        public void setText(String s) {
            string = s;
        }

        public void setTextColor(color c) {
            textColor = c;
        }

        public void setBackgroundColor(color c) {
            backgroundColor = c;
        }

        public int getWidth() {
            return w;
        }

        public int getHeight() {
            return h;
        }

        public void setVisible(boolean b) {
            drawObject = b;
        }
    };
}