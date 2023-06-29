/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                     //
//  w_EMGjoystick was first built in Koblenz Germany (Feb 11, 2023)                                    //
//                                                                                                     //
//  Created: Conor Russomanno, Richard Waltman, Philip Pitts, Blake Larkin, & Christian Bayerlain      //
//                                                                                                     //
//  Custom widget to map EMG signals into a 2D X/Y axis to represent a virtual joystick                //
//                                                                                                     //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class W_EMGJoystick extends Widget {

    private ControlP5 emgCp5;
    private Button emgSettingsButton;
    private List<controlP5.Controller> cp5ElementsToCheck;

    EmgSettingsValues emgSettingsValues;

    private final int NUM_EMG_CHANNELS = 4;

    private float joystickRawX;
    private float joystickRawY;
    private float previousJoystickRawX;
    private float previousJoystickRawY;
    private boolean inputIsDisabled;

    //Circular joystick X/Y graph. Made similar to the one found in Accelerometer widget.
    private float polarWindowX;
    private float polarWindowY;
    private int polarWindowDiameter;
    private int polarWindowHalfDiameter;
    private color graphStroke = color(210);
    private color graphBG = color(245);
    private color textColor = OPENBCI_DARKBLUE;
    private color strokeColor = color(138, 146, 153);
    private final int INDICATOR_DIAMETER = 15;
    private final int BAR_WIDTH = 10;
    private final int BAR_HEIGHT = 30;
    private final int BAR_CIRCLE_SPACER = 20; //Space between bar graph and circle graph

    private float topPolarX, topPolarY;         //12:00
    private float rightPolarX, rightPolarY;     //3:00
    private float bottomPolarX, bottomPolarY;   //6:00
    private float leftPolarX, leftPolarY;       //9:00
    private final int EMG_PLOT_OFFSET = 40;     //Used to arrange EMG displays outside of X/Y graph

    private String[] plotChannelLabels = new String[NUM_EMG_CHANNELS];

    EmgJoystickSmoothing joystickSmoothing = EmgJoystickSmoothing.POINT_9;

    private int DROPDOWN_HEIGHT = navH - 4;
    private int DROPDOWN_WIDTH = 80;
    private int DROPDOWN_SPACER = 10;
    private int DROPDOWN_LABEL_WIDTH = 24;

    EmgJoystickInput[] emgJoystickInputs = new EmgJoystickInput[NUM_EMG_CHANNELS];

    ScrollableList xNegativeInputDropdown;
    ScrollableList xPositiveInputDropdown;
    ScrollableList yPositiveInputDropdown;
    ScrollableList yNegativeInputDropdown;

    TextBox xNegativeInputDropdownLabel;
    TextBox xPositiveInputDropdownLabel;
    TextBox yPositiveInputDropdownLabel;
    TextBox yNegativeInputDropdownLabel;

    W_EMGJoystick(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        emgCp5 = new ControlP5(ourApplet);
        emgCp5.setGraphics(ourApplet, 0,0);
        emgCp5.setAutoDraw(false);

        createEmgSettingsButton();
        
        cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.add((controlP5.Controller) emgSettingsButton);

        emgSettingsValues = dataProcessing.emgSettings.values;

        emgJoystickInputs[0] = EmgJoystickInput.CHANNEL_1;
        emgJoystickInputs[1] = EmgJoystickInput.CHANNEL_2;
        emgJoystickInputs[2] = EmgJoystickInput.CHANNEL_3;
        emgJoystickInputs[3] = EmgJoystickInput.CHANNEL_4;

        for (int i = 0; i < NUM_EMG_CHANNELS; i++) {
            plotChannelLabels[i] = Integer.toString(emgJoystickInputs[i].getIndex() + 1);
        }

        addDropdown("emgJoystickSmoothingDropdown", "Smoothing", joystickSmoothing.getEnumStringsAsList(), joystickSmoothing.getIndex());

        createInputDropdowns();
    }

    public void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
    
        updateJoystickInput();
    }

    public void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        drawJoystickXYGraph();

        drawEmgVisualization(emgJoystickInputs[0].getIndex(), leftPolarX, leftPolarY);
        drawEmgVisualization(emgJoystickInputs[1].getIndex(), rightPolarX, rightPolarY);
        drawEmgVisualization(emgJoystickInputs[2].getIndex(), topPolarX, topPolarY);
        drawEmgVisualization(emgJoystickInputs[3].getIndex(), bottomPolarX, bottomPolarY);
        
        //drawChannelLabels();

        drawInputDropdownLabels();

        emgCp5.draw();
    }

    public void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        emgCp5.setGraphics(ourApplet, 0, 0);
        emgSettingsButton.setPosition(x0 + 1, y0 + navH + 1);

        updateJoystickGraphSizeAndPosition();
        updateInputDropdownPositions();
    }

    private void updateJoystickGraphSizeAndPosition() {
        //Make a unit circle constrained by the max height or width of the widget
        //Shrink the X/Y plot so that the EMG displays fit on the outside of the circle
        int horizontalPadding = 80;
        int verticalPadding = 48;
        if (h + verticalPadding*2 > w) {
            polarWindowDiameter = w - horizontalPadding*2;
        } else {
            polarWindowDiameter = h - verticalPadding*2;
        }

        polarWindowHalfDiameter = polarWindowDiameter / 2;
        polarWindowX = x + w / 2;
        polarWindowY = y + h / 2;

        topPolarX = polarWindowX;
        topPolarY = polarWindowY - polarWindowHalfDiameter - (EMG_PLOT_OFFSET / 2);

        rightPolarX = polarWindowX + polarWindowHalfDiameter + (EMG_PLOT_OFFSET);
        rightPolarY = polarWindowY;

        bottomPolarX = polarWindowX;
        bottomPolarY =  polarWindowY + polarWindowHalfDiameter + (EMG_PLOT_OFFSET / 2);

        leftPolarX = polarWindowX - polarWindowHalfDiameter - (EMG_PLOT_OFFSET);
        leftPolarY = polarWindowY;
    }

    private void drawJoystickXYGraph() {
        pushStyle();

        /*
        //X and Y axis labels
        fill(50);
        textFont(p4, 14);
        textAlign(CENTER,CENTER);
        text("x", (polarWindowX + polarWindowHalfDiameter) + 8, polarWindowY - 5);
        text("y", polarWindowX, (polarWindowY - polarWindowHalfDiameter) - 14);
        */

        //Background for graph
        fill(graphBG);
        stroke(graphStroke);
        circle(polarWindowX, polarWindowY, polarWindowDiameter);

        //X and Y axis lines
        stroke(180);
        line(polarWindowX - polarWindowHalfDiameter, polarWindowY, polarWindowX + polarWindowHalfDiameter, polarWindowY);
        line(polarWindowX, polarWindowY - polarWindowHalfDiameter, polarWindowX, polarWindowY + polarWindowHalfDiameter);

        //Keep the indicator circle inside the graph by accounting for the size of the indicator
        float min = -polarWindowHalfDiameter + (INDICATOR_DIAMETER * 2);
        float max = polarWindowHalfDiameter - (INDICATOR_DIAMETER  * 2);
        float xMapped = polarWindowX + map(joystickRawX, -1, 1, min, max);
        float yMapped = polarWindowY + map(joystickRawY, 1, -1, min, max); //Inverse drawn position of Y axis

        //Draw middle of graph for reference
        /*
        fill(255, 0, 0);
        stroke(graphStroke);
        circle(polarWindowX, polarWindowY, 15);
        */

        //Draw indicator
        noFill();
        stroke(color(31,69,110));
        strokeWeight(2);
        circle(xMapped, yMapped, INDICATOR_DIAMETER);
        line(xMapped-10, yMapped, xMapped+10, yMapped);
        line(xMapped, yMapped-10, xMapped, yMapped+10);

        popStyle();
    }
    
    //This is the core method that updates the joystick input
    private void updateJoystickInput() {
        previousJoystickRawX = joystickRawX;
        previousJoystickRawY = joystickRawY;

        if (inputIsDisabled) {
            joystickRawX = 0;
            joystickRawY = 0;
            return;
        }

        float xNegativeValue = emgSettingsValues.outputNormalized[emgJoystickInputs[0].getIndex()];
        float xPositiveValue = emgSettingsValues.outputNormalized[emgJoystickInputs[1].getIndex()];
        float yPositiveValue = emgSettingsValues.outputNormalized[emgJoystickInputs[2].getIndex()];
        float yNegativeValue = emgSettingsValues.outputNormalized[emgJoystickInputs[3].getIndex()];
        
        //Here we subtract the value of the right channel from the left channel to get the X axis
        joystickRawX = xPositiveValue - xNegativeValue;
        //Here we subtract the value of the top channel from the bottom channel to get the Y axis
        joystickRawY = yPositiveValue - yNegativeValue;

        //Map the joystick values to a unit circle
        float[] unitCircleXY = mapToUnitCircle(joystickRawX, joystickRawY);
        joystickRawX = unitCircleXY[0];
        joystickRawY = unitCircleXY[1];
        //Lerp the joystick values to smooth them out
        float amount = 1.0f - joystickSmoothing.getValue();
        joystickRawX = lerp(previousJoystickRawX, joystickRawX, amount);
        joystickRawY = lerp(previousJoystickRawY, joystickRawY, amount);
    }

    public float[] getJoystickXY() {
        return new float[] {joystickRawX, joystickRawY};
    }

    public void setInputIsDisabled(boolean value) {
        inputIsDisabled = value;
    }

    public float[] mapToUnitCircle(float _x, float _y) {
        _x = _x * sqrt(1 - (_y * _y) / 2);
        _y = _y * sqrt(1 - (_x * _x) / 2);
        return new float[] {_x, _y};
    }

    private void drawEmgVisualization(int channel, float currentX, float currentY) {
        float scaleFactor = 1.0;
        float scaleFactorJaw = 1.5;
        int index = 0;
        int colorIndex = channel % 8;
        
        int barX = (int)currentX + BAR_CIRCLE_SPACER;
        int barY = (int)currentY + BAR_HEIGHT / 2;
        int circleX = (int)currentX - BAR_CIRCLE_SPACER;
        int circleY = (int)currentY;
        

        pushStyle();

        //Realtime
        fill(channelColors[colorIndex], 200);
        noStroke();
        circle(circleX, circleY, scaleFactor * emgSettingsValues.averageuV[channel]);

        //Circle for outer threshold
        noFill();
        strokeWeight(1);
        stroke(OPENBCI_DARKBLUE);
        circle(circleX, circleY, scaleFactor * emgSettingsValues.upperThreshold[channel]);

        //Circle for inner threshold
        stroke(OPENBCI_DARKBLUE);
        circle(circleX, circleY, scaleFactor * emgSettingsValues.lowerThreshold[channel]);

        //Map value for height of bar graph
        float normalizedBAR_HEIGHTeight = map(emgSettingsValues.outputNormalized[channel], 0, 1, 0, BAR_HEIGHT * -1);

        //Draw normalized bar graph of uV w/ matching channel color
        noStroke();
        fill(channelColors[colorIndex], 200);
        rect(barX, barY, BAR_WIDTH, normalizedBAR_HEIGHTeight);

        //Draw background bar container for mapped uV value indication
        strokeWeight(1);
        stroke(OPENBCI_DARKBLUE);
        noFill();
        rect(barX, barY, BAR_WIDTH, BAR_HEIGHT * -1);

        popStyle();
    }

    private void drawChannelLabels() {
        pushStyle();

        fill(OPENBCI_DARKBLUE);
        textFont(p4, 14);
        textLeading(14);
        textAlign(CENTER,CENTER);
        
        text(plotChannelLabels[0], leftPolarX, leftPolarY - BAR_CIRCLE_SPACER * 2);
        text(plotChannelLabels[1], rightPolarX, rightPolarY - BAR_CIRCLE_SPACER *2);
        text(plotChannelLabels[2], topPolarX + BAR_CIRCLE_SPACER * 4, topPolarY);
        text(plotChannelLabels[3], bottomPolarX + BAR_CIRCLE_SPACER * 4, bottomPolarY);

        popStyle();
    }

    public void setJoystickSmoothing(int n) {
        joystickSmoothing = joystickSmoothing.values()[n];
    }

    private void createEmgSettingsButton() {
        emgSettingsButton = createButton(emgCp5, "emgSettingsButton", "EMG Settings", (int) (x0 + 1),
                (int) (y0 + navH + 1), 125, navH - 3, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        emgSettingsButton.setBorderColor(OBJECT_BORDER_GREY);
        emgSettingsButton.onRelease(new CallbackListener() {
            public synchronized void controlEvent(CallbackEvent theEvent) {
                if (!emgSettingsPopupIsOpen) {
                    EmgSettingsUI emgSettingsUI = new EmgSettingsUI();
                }
            }
        });
        emgSettingsButton.setDescription("Click to open the EMG Settings UI to adjust how this metric is calculated.");
    }

    private ScrollableList createEmgJoystickInputDropdown(String name, EmgJoystickInput joystickInput, int inputNumber) {
        ScrollableList list = emgCp5.addScrollableList(name)
            .setOpen(false)
            .setColorBackground(WHITE) // text field bg color
            .setColorValueLabel(OPENBCI_DARKBLUE)       // text color
            .setColorCaptionLabel(OPENBCI_DARKBLUE)
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(BUTTON_PRESSED)       // border color when selected
            .setOutlineColor(OBJECT_BORDER_GREY)
            .setSize(DROPDOWN_WIDTH, DROPDOWN_HEIGHT * 6)//temporary size
            .setBarHeight(DROPDOWN_HEIGHT) //height of top/primary bar
            .setItemHeight(DROPDOWN_HEIGHT) //height of all item/dropdown bars
            .setVisible(true)
            ;
        // this will store the *actual* enum object inside the dropdown!
        for (EmgJoystickInput input : EmgJoystickInput.values()) {
            if (input.getIndex() >= currentBoard.getNumEXGChannels()) {
                continue;
            }
            list.addItem(input.getString(), input);
        }
        //Style the text in the ScrollableList
        list.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(joystickInput.getString())
            .setFont(h5)
            .setSize(12)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        list.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(joystickInput.getString())
            .setFont(p6)
            .setSize(10) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        list.addCallback(new SLCallbackListener(inputNumber));
        return list;
    }

    private class SLCallbackListener implements CallbackListener {
        private int inputNumber;
    
        SLCallbackListener(int _i)  {
            inputNumber = _i;
        }
        public void controlEvent(CallbackEvent theEvent) {
            //Selecting an item from ScrollableList triggers Broadcast
            if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) { 
                int val = (int)(theEvent.getController()).getValue();
                Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
                emgJoystickInputs[inputNumber] = (EmgJoystickInput)bob.get("value");
                verbosePrint("EmgJoystickInput: " + (theEvent.getController()).getName() + " == " + emgJoystickInputs[inputNumber].getString());

                plotChannelLabels[inputNumber] = Integer.toString(emgJoystickInputs[inputNumber].getIndex() + 1);
            }
        }
    }

    private void createInputDropdowns() {
        //Create the dropdowns in reverse order so that top dropdown draws over bottom dropdown
        yNegativeInputDropdown = createEmgJoystickInputDropdown("yNegativeDropdown", emgJoystickInputs[3], 3);
        yPositiveInputDropdown = createEmgJoystickInputDropdown("yPositiveDropdown", emgJoystickInputs[2], 2);
        xPositiveInputDropdown = createEmgJoystickInputDropdown("xPositiveDropdown", emgJoystickInputs[1], 1);
        xNegativeInputDropdown = createEmgJoystickInputDropdown("xNegativeDropdown", emgJoystickInputs[0], 0);
        //Add the dropdowns to the list of cp5 elements to check for mouseover
        cp5ElementsToCheck.add(xNegativeInputDropdown);
        cp5ElementsToCheck.add(xPositiveInputDropdown);
        cp5ElementsToCheck.add(yPositiveInputDropdown);
        cp5ElementsToCheck.add(yNegativeInputDropdown);
        //Create labels for the dropdowns
        color labelBG = color(255,255,255,0);
        xNegativeInputDropdownLabel = new TextBox("X-", x, y, OPENBCI_DARKBLUE, WHITE, 12, h3, LEFT, TOP);
        xPositiveInputDropdownLabel = new TextBox("X+", x, y, OPENBCI_DARKBLUE, WHITE, 12, h3, LEFT, TOP);
        yPositiveInputDropdownLabel = new TextBox("Y+", x, y, OPENBCI_DARKBLUE, WHITE, 12, h3, LEFT, TOP);
        yNegativeInputDropdownLabel = new TextBox("Y-", x, y, OPENBCI_DARKBLUE, WHITE, 12, h3, LEFT, TOP);
    }

    private void updateInputDropdownPositions(){
        xNegativeInputDropdown.setPosition((int) (x + navH + DROPDOWN_LABEL_WIDTH), (int) (y + navH + 1));
        xPositiveInputDropdown.setPosition((int) (x + navH + DROPDOWN_LABEL_WIDTH), (int) (y + navH + DROPDOWN_SPACER + DROPDOWN_HEIGHT));
        yPositiveInputDropdown.setPosition((int) (x + w - navH - DROPDOWN_WIDTH), (int) (y + navH + 1));
        yNegativeInputDropdown.setPosition((int) (x + w - navH - DROPDOWN_WIDTH), (int) (y + navH + DROPDOWN_SPACER + DROPDOWN_HEIGHT));
        xNegativeInputDropdownLabel.setPosition((int) xNegativeInputDropdown.getPosition()[0] - DROPDOWN_LABEL_WIDTH, (int) xNegativeInputDropdown.getPosition()[1]);
        xPositiveInputDropdownLabel.setPosition((int) xPositiveInputDropdown.getPosition()[0] - DROPDOWN_LABEL_WIDTH, (int) xPositiveInputDropdown.getPosition()[1]);
        yPositiveInputDropdownLabel.setPosition((int) yPositiveInputDropdown.getPosition()[0] - DROPDOWN_LABEL_WIDTH, (int) yPositiveInputDropdown.getPosition()[1]);
        yNegativeInputDropdownLabel.setPosition((int) yNegativeInputDropdown.getPosition()[0] - DROPDOWN_LABEL_WIDTH, (int) yNegativeInputDropdown.getPosition()[1]);
    }

    private void drawInputDropdownLabels() {
        xNegativeInputDropdownLabel.draw();
        xPositiveInputDropdownLabel.draw();
        yPositiveInputDropdownLabel.draw();
        yNegativeInputDropdownLabel.draw();
    }

};

public void emgJoystickSmoothingDropdown(int n) {
    w_emgJoystick.setJoystickSmoothing(n);
}

public enum EmgJoystickSmoothing implements IndexingInterface
{
    OFF (0, "Off", 0f),
    POINT_9 (1, "0.9", .9f),
    POINT_95 (2, "0.95", .95f),
    POINT_98 (3, "0.98", .98f),
    POINT_99 (4, "0.99", .99f),
    POINT_999 (5, "0.999", .999f),
    POINT_9999 (6, "0.9999", .9999f);

    private int index;
    private String name;
    private float value;
    private static EmgJoystickSmoothing[] vals = values();
 
    EmgJoystickSmoothing(int index, String name, float value) {
        this.index = index;
        this.name = name;
        this.value = value;
    }

    public int getIndex() {
        return index;
    }
    
    public String getString() {
        return name;
    }

    public float getValue() {
        return value;
    }

    private static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (IndexingInterface val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}

public enum EmgJoystickInput implements IndexingInterface
{
    CHANNEL_1 (0, "Channel 1", 0),
    CHANNEL_2 (1, "Channel 2", 1),
    CHANNEL_3 (2, "Channel 3", 2),
    CHANNEL_4 (3, "Channel 4", 3),
    CHANNEL_5 (4, "Channel 5", 4),
    CHANNEL_6 (5, "Channel 6", 5),
    CHANNEL_7 (6, "Channel 7", 6),
    CHANNEL_8 (7, "Channel 8", 7),
    CHANNEL_9 (8, "Channel 9", 8),
    CHANNEL_10 (9, "Channel 10", 9),
    CHANNEL_11 (10, "Channel 11", 10),
    CHANNEL_12 (11, "Channel 12", 11),
    CHANNEL_13 (12, "Channel 13", 12),
    CHANNEL_14 (13, "Channel 14", 13),
    CHANNEL_15 (14, "Channel 15", 14),
    CHANNEL_16 (15, "Channel 16", 15);

    private int index;
    private String name;
    private int value;
    private static EmgJoystickInput[] vals = values();
 
    EmgJoystickInput(int index, String name, int value) {
        this.index = index;
        this.name = name;
        this.value = value;
    }

    public int getIndex() {
        return index;
    }
    
    public String getString() {
        return name;
    }

    public int getValue() {
        return value;
    }

    private static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (IndexingInterface val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}