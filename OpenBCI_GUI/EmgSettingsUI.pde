////////////////////////////////////////////////////////////
//                 EmgSettingsUI.pde                   //
//          Display the Emg Settings UI as a popup        //
//                                                        //
////////////////////////////////////////////////////////////

public boolean emgSettingsPopupIsOpen = false;

class EmgSettingsUI extends PApplet implements Runnable {

    PApplet ourApplet;
    private final String HEADER_MESSAGE = "EMG Settings";

    private ControlP5 emgCp5;
    private int x, y, w, h;
    private final int HEADER_PADDING = 22;
    private final int FOOTER_PADDING = 80;
    private final int PADDING_3 = 3;
    private final int NUM_CONTROL_BUTTONS = 3;
    private final int ROW_HEIGHT = 40;
    private final int DROPDOWN_HEIGHT = 18; 
    private final int NUM_COLUMNS = 7;
    private final int DROPDOWN_SPACER = 5;
    private int dropdownWidth;
    private boolean isFixedHeight;
    private int fixedHeight;
    private int[] dropdownYPositions;

    private final int defaultWidth = 600;
    private final int defaultHeight = 600;

    public EmgValues emgValues;

    private TextBox channelColumnLabel;
    private TextBox smoothLabel;
    private TextBox uvLimitLabel;
    private TextBox creepIncLabel;
    private TextBox creepDecLabel;
    private TextBox minDeltaUvLabel;
    private TextBox lowLimitLabel;

    private ScrollableList[] smoothLists;
    private ScrollableList[] uvLimitLists;
    private ScrollableList[] creepIncLists;
    private ScrollableList[] creepDecLists;
    private ScrollableList[] minDeltaUvLists;
    private ScrollableList[] lowLimitLists;

    private int channelCount;

    private String[] channelLabels;

    @Override
    public void run() {
        PApplet.runSketch(new String[] {HEADER_MESSAGE}, this);
    }

    public EmgSettingsUI() {
        super();
        emgSettingsPopupIsOpen = true;

        Thread t = new Thread(this);
        t.start();

        emgValues = dataProcessing.emgValues;

        channelCount = currentBoard.getNumEXGChannels();

        x = 0;
        y = 0;
        w = defaultWidth;
        h = HEADER_PADDING + (channelCount * ROW_HEIGHT) + FOOTER_PADDING;
    }

    @Override
    public void settings() {
        size(defaultWidth, h);
    }

    @Override
    public void setup() {

        ourApplet = this;

        surface.setTitle(HEADER_MESSAGE);
        surface.setAlwaysOnTop(true);
        surface.setResizable(false);

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

        //Draw column labels
        channelColumnLabel.draw();
        smoothLabel.draw();
        uvLimitLabel.draw();
        creepIncLabel.draw();
        creepDecLabel.draw();
        minDeltaUvLabel.draw();
        lowLimitLabel.draw();

        drawChannelLabels();

        //Draw cp5 objects on top of everything
        emgCp5.draw();
    }

    private void screenResized() {
        x = 0;
        y = 0;
        w = width;
        h = height;

        emgCp5.setGraphics(ourApplet, 0, 0);

        int colWidth = (width / NUM_COLUMNS);
        int colOffset = colWidth / 2;
        int labelY = y + HEADER_PADDING / 2;
        channelColumnLabel.setPosition(x + colOffset, labelY);
        smoothLabel.setPosition(x + colOffset + colWidth, labelY);
        uvLimitLabel.setPosition(x + colOffset + colWidth*2, labelY);
        creepIncLabel.setPosition(x + colOffset + colWidth*3, labelY);
        creepDecLabel.setPosition(x + colOffset + colWidth*4, labelY);
        minDeltaUvLabel.setPosition(x + colOffset + colWidth*5, labelY);
        lowLimitLabel.setPosition(x + colOffset + colWidth*6, labelY);

        resizeDropdowns();
    }

    private void scene() {
        // Draw background
        background(OPENBCI_DARKBLUE);
        stroke(204);
        fill(238);
        rect(0, 0, width, height);
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

    private void createAllUIObjects() {
        channelLabels = new String[channelCount];
        for (int i = 0; i < channelCount; i++) {
            channelLabels[i] = "Channel " + (i+1);
        }

        //Create column labels
        color labelBG = color(255,255,255,0);
        color labelTxt = OPENBCI_DARKBLUE;
        int colWidth = (w / NUM_COLUMNS);
        int colOffset = colWidth / 2;
        int labelY = y + HEADER_PADDING / 2;
        channelColumnLabel = new TextBox("Channel", x + colOffset, labelY, labelTxt, labelBG, 12, h5, CENTER, TOP);
        smoothLabel = new TextBox("Smooth", x + colOffset + colWidth, labelY, labelTxt, labelBG, 12, h5, CENTER, TOP);
        uvLimitLabel = new TextBox("uV Limit", x + colOffset + colWidth*2, labelY, labelTxt, labelBG, 12, h5, CENTER, TOP);
        creepIncLabel = new TextBox("Creep +", x + colOffset + colWidth*3, labelY, labelTxt, labelBG, 12, h5, CENTER, TOP);
        creepDecLabel = new TextBox("Creep -", x + colOffset + colWidth*4, labelY, labelTxt, labelBG, 12, h5, CENTER, TOP);
        minDeltaUvLabel = new TextBox("Min \u0394uV", x + colOffset + colWidth*5, labelY, labelTxt, labelBG, 12, h5, CENTER, TOP);
        lowLimitLabel = new TextBox("Low Limit", x + colOffset + colWidth*6, labelY, labelTxt, labelBG, 12, h5, CENTER, TOP);

        createAllDropdowns();
    }

    private void createAllDropdowns() {
        //the size and space of these buttons are dependendant on the size of the screen and full ChannelController
        verbosePrint("EmgChannelSettingsUI: Creating EMG channel setting UI objects...");

        smoothLists = new ScrollableList[channelCount];
        uvLimitLists = new ScrollableList[channelCount];
        creepIncLists = new ScrollableList[channelCount];
        creepDecLists = new ScrollableList[channelCount];
        minDeltaUvLists = new ScrollableList[channelCount];
        lowLimitLists = new ScrollableList[channelCount];

        dropdownYPositions = new int[channelCount];

        //Init dropdowns in reverse so that chan 1 draws on top of chan 2, etc.
        for (int i = channelCount - 1; i >= 0; i--) {
            int exgChannel = i;
            smoothLists[i] = createDropdown(exgChannel, "smooth_ch_"+(i+1), emgValues.smoothing[exgChannel].values(), emgValues.smoothing[exgChannel]);
            uvLimitLists[i] = createDropdown(exgChannel, "uvLimit_ch_"+(i+1), emgValues.uvLimit[exgChannel].values(), emgValues.uvLimit[exgChannel]);
            creepIncLists[i] = createDropdown(exgChannel, "creep_inc_ch_"+(i+1), emgValues.creepIncreasing[exgChannel].values(), emgValues.creepIncreasing[exgChannel]);   
            creepDecLists[i] = createDropdown(exgChannel, "creep_dec_ch_"+(i+1), emgValues.creepDecreasing[exgChannel].values(), emgValues.creepDecreasing[exgChannel]);   
            minDeltaUvLists[i] = createDropdown(exgChannel, "minDeltaUv_ch_"+(i+1), emgValues.minimumDeltaUV[exgChannel].values(), emgValues.minimumDeltaUV[exgChannel]);       
            lowLimitLists[i] = createDropdown(exgChannel, "lowLimit_ch_"+(i+1), emgValues.lowerThresholdMinimum[exgChannel].values(), emgValues.lowerThresholdMinimum[exgChannel]);
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

                if (myEnum instanceof EmgSmoothing) {
                    //verbosePrint("HardwareSettings: previousVal == " + emgValues.previousValues.gain[channel]);
                    emgValues.smoothing[channel] = (EmgSmoothing)myEnum;
                } else if (myEnum instanceof EmgUVLimit) {
                    emgValues.uvLimit[channel] = (EmgUVLimit)myEnum;
                } else if (myEnum instanceof EmgCreepIncreasing) {
                    emgValues.creepIncreasing[channel] = (EmgCreepIncreasing)myEnum;
                } else if (myEnum instanceof EmgCreepDecreasing) {
                    emgValues.creepDecreasing[channel] = (EmgCreepDecreasing)myEnum;
                } else if (myEnum instanceof EmgMinimumDeltaUV) {
                    emgValues.minimumDeltaUV[channel] = (EmgMinimumDeltaUV)myEnum;
                } else if (myEnum instanceof EmgLowerThresholdMinimum) {
                    emgValues.lowerThresholdMinimum[channel] = (EmgLowerThresholdMinimum)myEnum;
                }
            }
        }
    }

    private void resizeDropdowns() {
        dropdownWidth = int((w - (DROPDOWN_SPACER * (NUM_COLUMNS + 1))) / NUM_COLUMNS);
        final int MAX_HEIGHT_ITEMS = channelCount == 4 ? 8 : 5;

        for (int i = 0; i < channelCount; i++) {
            int dropdownX = x + DROPDOWN_SPACER * 2 + dropdownWidth;
            dropdownYPositions[i] = HEADER_PADDING + int(y + ((ROW_HEIGHT) * i) + (((ROW_HEIGHT) - DROPDOWN_HEIGHT) / 2));
            final int buttonXIncrement = DROPDOWN_SPACER + dropdownWidth;

            smoothLists[i].setPosition(dropdownX, dropdownYPositions[i]);
            smoothLists[i].setSize(dropdownWidth, MAX_HEIGHT_ITEMS * DROPDOWN_HEIGHT);
            
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
            text(channelLabel, x + colOffset, dropdownYPositions[i] + (DROPDOWN_HEIGHT / 2));
        }

        popStyle();
    }

    //We have add an implementation of this class since this is a child instance of PApplet
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