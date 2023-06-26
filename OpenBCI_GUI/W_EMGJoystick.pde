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

    EmgValues emgValues;

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

    private final String CHANNEL_ONE_LABEL_EN = "Channel 1";
    private final String CHANNEL_TWO_LABEL_EN = "Channel 2";
    private final String CHANNEL_THREE_LABEL_EN = "Channel 3";
    private final String CHANNEL_FOUR_LABEL_EN = "Channel 4";

    private String channelOneLabel;
    private String channelTwoLabel;
    private String channelThreeLabel;
    private String channelFourLabel;

    EmgJoystickSmoothing joystickSmoothing = EmgJoystickSmoothing.POINT_9;

    W_EMGJoystick(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        emgValues = dataProcessing.emgValues;

        channelOneLabel = CHANNEL_ONE_LABEL_EN;
        channelTwoLabel = CHANNEL_TWO_LABEL_EN;
        channelThreeLabel = CHANNEL_THREE_LABEL_EN;
        channelFourLabel = CHANNEL_FOUR_LABEL_EN;

        addDropdown("emgJoystickSmoothingDropdown", "Smoothing", joystickSmoothing.getEnumStringsAsList(), joystickSmoothing.getIndex());

    }

    public void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
    
        updateJoystickInput();
    }

    public void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        drawJoystickXYGraph();

        drawEmgVisualization(0, leftPolarX, leftPolarY);
        drawEmgVisualization(1, rightPolarX, rightPolarY);
        drawEmgVisualization(2, topPolarX, topPolarY);
        drawEmgVisualization(3, bottomPolarX, bottomPolarY);
        
        drawChannelLabels();
    }

    public void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        updateJoystickGraphSizeAndPosition();
    }

    private void updateJoystickGraphSizeAndPosition() {
        //Make a unit circle constrained by the max height
        int _padding = 30;
        int distanceToUse = h > w ? w : h;
        polarWindowDiameter = distanceToUse - _padding*2 - EMG_PLOT_OFFSET; //Shrink the X/Y plot so that the EMG displays fit on the outside
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

    private void updateJoystickInput() {
        previousJoystickRawX = joystickRawX;
        previousJoystickRawY = joystickRawY;

        if (inputIsDisabled) {
            joystickRawX = 0;
            joystickRawY = 0;
            return;
        }
        
        //Here we subtract the values of the left and right channels to get the X axis
        joystickRawX = emgValues.outputNormalized[1] - emgValues.outputNormalized[0];
        //Here we subtract the values of the top and bottom channels to get the Y axis
        joystickRawY = emgValues.outputNormalized[2] - emgValues.outputNormalized[3];

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
        circle(circleX, circleY, scaleFactor * emgValues.averageuV[channel]);

        //Circle for outer threshold
        noFill();
        strokeWeight(1);
        stroke(OPENBCI_DARKBLUE);
        circle(circleX, circleY, scaleFactor * emgValues.upperThreshold[channel]);

        //Circle for inner threshold
        stroke(OPENBCI_DARKBLUE);
        circle(circleX, circleY, scaleFactor * emgValues.lowerThreshold[channel]);

        //Map value for height of bar graph
        float normalizedBAR_HEIGHTeight = map(emgValues.outputNormalized[channel], 0, 1, 0, BAR_HEIGHT * -1);

        //Draw normalized bar graph of uV w/ matching channel color
        noStroke();
        fill(channelColors[colorIndex], 200);
        rect(barX, barY, BAR_WIDTH, normalizedBAR_HEIGHTeight);

        //Draw background bar container for mapped uV value indication
        strokeWeight(1);
        stroke(OPENBCI_DARKBLUE);
        noFill();
        rect(barX, barY, BAR_WIDTH, BAR_HEIGHT * -1);

        /*
        //draw channel number at upper left corner of row/column cell
        pushStyle();
        stroke(OPENBCI_DARKBLUE);
        fill(OPENBCI_DARKBLUE);
        int _chan = index+1;
        textFont(p5, 12);
        text(_chan + "", 10, 20);
        popStyle();
        */

        popStyle();
    }

    private void drawChannelLabels() {
        pushStyle();

        fill(OPENBCI_DARKBLUE);
        textFont(p4, 14);
        textLeading(14);
        textAlign(CENTER,CENTER);

        text(channelOneLabel, leftPolarX, leftPolarY - BAR_CIRCLE_SPACER * 2);
        text(channelTwoLabel, rightPolarX, rightPolarY - BAR_CIRCLE_SPACER *2);
        text(channelThreeLabel, topPolarX + BAR_CIRCLE_SPACER * 4, topPolarY);
        text(channelFourLabel, bottomPolarX + BAR_CIRCLE_SPACER * 4, bottomPolarY);

        popStyle();
    }

    public void setJoystickSmoothing(int n) {
        joystickSmoothing = joystickSmoothing.values()[n];
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