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

class W_EmgJoystick extends WidgetWithSettings {
    private ControlP5 emgCp5;
    private Button emgSettingsButton;
    private List<controlP5.Controller> cp5ElementsToCheck;

    EmgSettingsValues emgSettingsValues;

    private final int NUM_EMG_INPUTS = 4;

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

    private String[] plotChannelLabels = new String[NUM_EMG_INPUTS];

    private int DROPDOWN_HEIGHT = navH - 4;
    private int DROPDOWN_WIDTH = 80;
    private int DROPDOWN_SPACER = 10;
    private int DROPDOWN_LABEL_WIDTH = 24;

    public EMGJoystickInputs emgJoystickInputs;

    private ScrollableList xNegativeInputDropdown;
    private ScrollableList xPositiveInputDropdown;
    private ScrollableList yPositiveInputDropdown;
    private ScrollableList yNegativeInputDropdown;

    private TextBox xNegativeInputDropdownLabel;
    private TextBox xPositiveInputDropdownLabel;
    private TextBox yPositiveInputDropdownLabel;
    private TextBox yNegativeInputDropdownLabel;

    private PImage xNegativeInputLabelImage = loadImage("EMG_Joystick/LEFT_100x100.png");
    private PImage xPositiveInputLabelImage = loadImage("EMG_Joystick/RIGHT_100x100.png");
    private PImage yPositiveInputLabelImage = loadImage("EMG_Joystick/UP_100x100.png");
    private PImage yNegativeInputLabelImage = loadImage("EMG_Joystick/DOWN_100x100.png");

    W_EmgJoystick() {
        super();
        widgetTitle = "EMG Joystick";

        emgCp5 = new ControlP5(ourApplet);
        emgCp5.setGraphics(ourApplet, 0,0);
        emgCp5.setAutoDraw(false);

        createEmgSettingsButton();
        
        cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.add((controlP5.Controller) emgSettingsButton);

        emgSettingsValues = dataProcessing.emgSettings.values;

        emgJoystickInputs = new EMGJoystickInputs(currentBoard.getNumEXGChannels());

        emgJoystickInputs.setInputToChannel(0, 0);
        emgJoystickInputs.setInputToChannel(1, 1);
        emgJoystickInputs.setInputToChannel(2, 2);
        emgJoystickInputs.setInputToChannel(3, 3);

        for (int i = 0; i < NUM_EMG_INPUTS; i++) {
            plotChannelLabels[i] = Integer.toString(emgJoystickInputs.getInput(i).getIndex() + 1);
        }

        createInputDropdowns();
    }

    @Override
    protected void initWidgetSettings() {
        super.initWidgetSettings();
        widgetSettings.set(EmgJoystickSmoothing.class, EmgJoystickSmoothing.POINT_9);
        initDropdown(EmgJoystickSmoothing.class, "emgJoystickSmoothingDropdown", "Smoothing");
        widgetSettings.saveDefaults();
    }

    @Override
    protected void applySettings() {
        updateDropdownLabel(EmgJoystickSmoothing.class, "emgJoystickSmoothingDropdown");
    }

    public void update(){
        super.update();
        lockElementsOnOverlapCheck(cp5ElementsToCheck);
    }

    public void draw(){
        super.draw();

        drawJoystickXYGraph();

        drawEmgVisualization(emgJoystickInputs.getInput(0).getIndex(), leftPolarX, leftPolarY);
        drawEmgVisualization(emgJoystickInputs.getInput(1).getIndex(), rightPolarX, rightPolarY);
        drawEmgVisualization(emgJoystickInputs.getInput(2).getIndex(), topPolarX, topPolarY);
        drawEmgVisualization(emgJoystickInputs.getInput(3).getIndex(), bottomPolarX, bottomPolarY);

        drawInputDropdownLabels();

        emgCp5.draw();
    }

    public void screenResized(){
        super.screenResized();

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
    //Call this method in DataProcessing.pde to update the joystick input even when widget is closed
    public void updateEmgJoystickWidgetData() {
        previousJoystickRawX = joystickRawX;
        previousJoystickRawY = joystickRawY;

        if (inputIsDisabled) {
            joystickRawX = 0;
            joystickRawY = 0;
            return;
        }

        float xNegativeValue = emgSettingsValues.outputNormalized[emgJoystickInputs.getInput(0).getIndex()];
        float xPositiveValue = emgSettingsValues.outputNormalized[emgJoystickInputs.getInput(1).getIndex()];
        float yPositiveValue = emgSettingsValues.outputNormalized[emgJoystickInputs.getInput(2).getIndex()];
        float yNegativeValue = emgSettingsValues.outputNormalized[emgJoystickInputs.getInput(3).getIndex()];
        
        //Here we subtract the value of the right channel from the left channel to get the X axis
        joystickRawX = xPositiveValue - xNegativeValue;
        //Here we subtract the value of the top channel from the bottom channel to get the Y axis
        joystickRawY = yPositiveValue - yNegativeValue;

        //Map the joystick values to a unit circle
        float[] unitCircleXY = mapToUnitCircle(joystickRawX, joystickRawY);
        joystickRawX = unitCircleXY[0];
        joystickRawY = unitCircleXY[1];
        //Lerp the joystick values to smooth them out
        float amount = 1.0f - widgetSettings.get(EmgJoystickSmoothing.class).getValue();
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
        widgetSettings.setByIndex(EmgJoystickSmoothing.class, n);
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

    private ScrollableList createEmgJoystickInputDropdown(String name, EMGJoystickInput joystickInput, int inputNumber) {
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
        for (EMGJoystickInput input : emgJoystickInputs.getValues()) {
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
                emgJoystickInputs.setInputToChannel(inputNumber, ((EMGJoystickInput)bob.get("value")).getIndex());
                verbosePrint("EMGJoystickInput: " + (theEvent.getController()).getName() + " == " + emgJoystickInputs.getInput(inputNumber).getString());

                plotChannelLabels[inputNumber] = Integer.toString(emgJoystickInputs.getInput(inputNumber).getIndex() + 1);
            }
        }
    }

    private void createInputDropdowns() {
        //Create the dropdowns in reverse order so that top dropdown draws over bottom dropdown
        yNegativeInputDropdown = createEmgJoystickInputDropdown("yNegativeDropdown", emgJoystickInputs.getInput(3), 3);
        yPositiveInputDropdown = createEmgJoystickInputDropdown("yPositiveDropdown", emgJoystickInputs.getInput(2), 2);
        xPositiveInputDropdown = createEmgJoystickInputDropdown("xPositiveDropdown", emgJoystickInputs.getInput(1), 1);
        xNegativeInputDropdown = createEmgJoystickInputDropdown("xNegativeDropdown", emgJoystickInputs.getInput(0), 0);
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
        final int Y_AXIS_ARROW_LABEL_WIDTH = DROPDOWN_HEIGHT + DROPDOWN_SPACER;
        xNegativeInputDropdown.setPosition((int) (x + navH + DROPDOWN_LABEL_WIDTH), (int) (y + navH + 1));
        xPositiveInputDropdown.setPosition((int) (x + navH + DROPDOWN_LABEL_WIDTH), (int) (y + navH + DROPDOWN_SPACER + DROPDOWN_HEIGHT));
        yPositiveInputDropdown.setPosition((int) (x + w - navH - DROPDOWN_WIDTH - Y_AXIS_ARROW_LABEL_WIDTH), (int) (y + navH + 1));
        yNegativeInputDropdown.setPosition((int) (x + w - navH - DROPDOWN_WIDTH - Y_AXIS_ARROW_LABEL_WIDTH), (int) (y + navH + DROPDOWN_SPACER + DROPDOWN_HEIGHT));
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

        final int X_OFFSET = DROPDOWN_WIDTH + DROPDOWN_SPACER;
        image(xNegativeInputLabelImage, xNegativeInputDropdown.getPosition()[0] + X_OFFSET, xNegativeInputDropdown.getPosition()[1] + 2, DROPDOWN_HEIGHT, DROPDOWN_HEIGHT);
        image(xPositiveInputLabelImage, xPositiveInputDropdown.getPosition()[0] + X_OFFSET, xPositiveInputDropdown.getPosition()[1] + 2, DROPDOWN_HEIGHT, DROPDOWN_HEIGHT);
        image(yPositiveInputLabelImage, yPositiveInputDropdown.getPosition()[0] + X_OFFSET, yPositiveInputDropdown.getPosition()[1] + 2, DROPDOWN_HEIGHT, DROPDOWN_HEIGHT);
        image(yNegativeInputLabelImage, yNegativeInputDropdown.getPosition()[0] + X_OFFSET, yNegativeInputDropdown.getPosition()[1] + 2, DROPDOWN_HEIGHT, DROPDOWN_HEIGHT);
    }

    public void updateJoystickInput(int inputNumber, Integer value) {
        if (value == null) {
            return;
        }
        emgJoystickInputs.setInputToChannel(inputNumber, emgJoystickInputs.getValues()[value].getValue());
        String inputName = emgJoystickInputs.getInput(inputNumber).getString();
        switch (inputNumber) {
            case 0:
                xNegativeInputDropdown.getCaptionLabel().setText(inputName);
                break;
            case 1:
                xPositiveInputDropdown.getCaptionLabel().setText(inputName);
                break;
            case 2:
                yPositiveInputDropdown.getCaptionLabel().setText(inputName);
                break;
            case 3:
                yNegativeInputDropdown.getCaptionLabel().setText(inputName);
                break;
        }
    }

    public int getNumEMGInputs() {
        return NUM_EMG_INPUTS;
    }
};

public void emgJoystickSmoothingDropdown(int n) {
    ((W_EmgJoystick) widgetManager.getWidget("W_EmgJoystick")).setJoystickSmoothing(n);
}