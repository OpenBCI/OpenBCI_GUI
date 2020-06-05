
////////////////////////////////////////////////////
//
//  W_DigitalRead is used to visiualze digital input values
//
//  Created: AJ Keller
//
//
///////////////////////////////////////////////////,

class W_DigitalRead extends Widget {
    private int numDigitalReadDots;
    float xF, yF, wF, hF;
    int dot_padding;
    float dot_x, dot_y, dot_h, dot_w; //values for actual time series chart (rectangle encompassing all digitalReadDots)
    float plotBottomWell;
    float playbackWidgetHeight;
    int digitalReaddotHeight;

    DigitalReadDot[] digitalReadDots;

    private boolean visible = true;

    Button_obci digitalModeButton;

    private DigitalCapableBoard digitalBoard;

    W_DigitalRead(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function

        //set number of digital reads
        if (selectedProtocol == BoardProtocol.WIFI) {
            numDigitalReadDots = 3;
        } else {
            numDigitalReadDots = 5;
        }

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        dot_padding = 10;
        dot_x = xF + dot_padding;
        dot_y = yF + (dot_padding);
        dot_w = wF - dot_padding*2;
        dot_h = hF - playbackWidgetHeight - plotBottomWell - (dot_padding*2);
        digitalReaddotHeight = int(dot_h/numDigitalReadDots);

        digitalReadDots = new DigitalReadDot[numDigitalReadDots];

        //create our channel bars and populate our digitalReadDots array!
        for(int i = 0; i < numDigitalReadDots; i++){
            int digitalReaddotY = int(dot_y) + i*(digitalReaddotHeight); //iterate through bar locations
            int digitalReaddotX = int(dot_x) + i*(digitalReaddotHeight); //iterate through bar locations
            int digitalPin = 0;
            if (i == 0) {
                digitalPin = 11;
            } else if (i == 1) {
                digitalPin = 12;
            } else if (i == 2) {
                if (selectedProtocol == BoardProtocol.WIFI) {
                    digitalPin = 17;
                } else {
                    digitalPin = 13;
                }
            } else if (i == 3) {
                digitalPin = 17;
            } else {
                digitalPin = 18;
            }
            DigitalReadDot tempDot = new DigitalReadDot(_parent, digitalPin, digitalReaddotX, digitalReaddotY, int(dot_w), digitalReaddotHeight, dot_padding);
            digitalReadDots[i] = tempDot;
        }

        digitalModeButton = new Button_obci((int)(x + 3), (int)(y + 3 - navHeight), 128, navHeight - 6, "DIGITAL TOGGLE", 12);
        digitalModeButton.setCornerRoundess((int)(navHeight-6));
        digitalModeButton.setFont(p5,12);
        digitalModeButton.setColorNotPressed(color(57,128,204));
        digitalModeButton.textColorNotActive = color(255);
        digitalModeButton.hasStroke(false);

        if (selectedProtocol == BoardProtocol.WIFI) {
            digitalModeButton.setHelpText("Click this button to activate/deactivate digital read on Cyton pins D11, D12, and D17.");
        } else {
            digitalModeButton.setHelpText("Click this button to activate/deactivate digital read on Cyton pins D11, D12, D13, D17 and D18.");
        }

        digitalBoard = (DigitalCapableBoard)currentBoard;
    }

    public int getNumDigitalReads() {
        return numDigitalReadDots;
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean _visible) {
        visible = _visible;
    }

    void update(){
        if(visible){
            super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

            //update channel bars ... this means feeding new EEG data into plots
            for(int i = 0; i < numDigitalReadDots; i++){
                digitalReadDots[i].update();
            }

            //ignore top left button interaction when widgetSelector dropdown is active
            ignoreButtonCheck(digitalModeButton);
        }

        updateOnOffButton();
    }

    private void updateOnOffButton() {	
        if (digitalBoard.isDigitalActive()) {	
            digitalModeButton.setString("Turn Digital Read Off");	
            digitalModeButton.setIgnoreHover(!digitalBoard.canDeactivateDigital());
            if(!digitalBoard.canDeactivateDigital()) {
                digitalModeButton.setColorNotPressed(color(128));
            }
        }
        else {
            digitalModeButton.setString("Turn Digital Read On");	
            digitalModeButton.setIgnoreHover(false);
            digitalModeButton.setColorNotPressed(color(57,128,204));
        }
    }

    void draw(){
        if(visible){
            super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

            //remember to refer to x,y,w,h which are the positioning variables of the Widget class
            pushStyle();
            //draw channel bars
            digitalModeButton.draw();
            if (digitalBoard.isDigitalActive()) {
                for(int i = 0; i < numDigitalReadDots; i++){
                    digitalReadDots[i].draw();
                }
            }
            popStyle();
        }
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
        yF = float(y);
        wF = float(w);
        hF = float(h);

        if (wF > hF) {
            digitalReaddotHeight = int(hF/(numDigitalReadDots+1));
        } else {
            digitalReaddotHeight = int(wF/(numDigitalReadDots+1));
        }

        if (numDigitalReadDots == 3) {
            digitalReadDots[0].screenResized(x+int(wF*(1.0/3.0)), y+int(hF*(1.0/3.0)), digitalReaddotHeight, digitalReaddotHeight); //bar x, bar y, bar w, bar h
            digitalReadDots[1].screenResized(x+int(wF/2), y+int(hF/2), digitalReaddotHeight, digitalReaddotHeight); //bar x, bar y, bar w, bar h
            digitalReadDots[2].screenResized(x+int(wF*(2.0/3.0)), y+int(hF*(2.0/3.0)), digitalReaddotHeight, digitalReaddotHeight); //bar x, bar y, bar w, bar h
        } else {
            int y_pad = y + dot_padding;
            digitalReadDots[0].screenResized(x+int(wF*(1.0/8.0)), y_pad+int(hF*(1.0/8.0)), digitalReaddotHeight, digitalReaddotHeight);
            digitalReadDots[2].screenResized(x+int(wF/2), y_pad+int(hF/2), digitalReaddotHeight, digitalReaddotHeight);
            digitalReadDots[4].screenResized(x+int(wF*(7.0/8.0)), y_pad+int(hF*(7.0/8.0)), digitalReaddotHeight, digitalReaddotHeight);
            digitalReadDots[1].screenResized(digitalReadDots[0].dotX+int(wF*(3.0/16.0)), digitalReadDots[0].dotY+int(hF*(3.0/16.0)), digitalReaddotHeight, digitalReaddotHeight);
            digitalReadDots[3].screenResized(digitalReadDots[2].dotX+int(wF*(3.0/16.0)), digitalReadDots[2].dotY+int(hF*(3.0/16.0)), digitalReaddotHeight, digitalReaddotHeight);

        }

        digitalModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        if (digitalModeButton.isMouseHere()) {
            digitalModeButton.setIsActive(true);
        }
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        if(digitalModeButton.isActive && digitalModeButton.isMouseHere()){
            if (!digitalBoard.isDigitalActive()) {
                digitalBoard.setDigitalActive(true);
                if (selectedProtocol == BoardProtocol.WIFI) {
                    output("Starting to read digital inputs on pin marked D11, D12 and D17");
                } else {
                    output("Starting to read digital inputs on pin marked D11, D12, D13, D17 and D18");
                }
            } else {
                digitalBoard.setDigitalActive(false);
                output("Starting to read accelerometer");
            }
        }
        digitalModeButton.setIsActive(false);
    }
};

//========================================================================================================================
//                      Analog Voltage BAR CLASS -- Implemented by Analog Read Widget Class
//========================================================================================================================
//this class contains the plot and buttons for a single channel of the Time Series widget
//one of these will be created for each channel (4, 8, or 16)
class DigitalReadDot{

    private int digitalInputPin;
    private int digitalInputVal;
    String digitalInputString;
    int padding;
    boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware

    TextBox digitalValue;
    TextBox digitalPin;

    boolean drawDigitalValue;

    color dotStroke = #d2d2d2;
    color dot0Fill = #f5f5f5;
    color dot1Fill = #f5f5f5;
    color val0Fill = #000000;
    color val1Fill = #ffffff;

    int dotX;
    int dotY;
    int dotWidth;
    int dotHeight;
    float dotCorner;

    DigitalCapableBoard digitalBoard;

    DigitalReadDot(PApplet _parent, int _digitalInputPin, int _x, int _y, int _w, int _h, int _padding){ // channel number, x/y location, height, width

        digitalBoard = (DigitalCapableBoard)currentBoard;

        digitalInputPin = _digitalInputPin;
        digitalInputString = str(digitalInputPin);
        digitalInputVal = 0;
        isOn = true;

        if (digitalInputPin == 11) {
            dot1Fill = channelColors[0];
        } else if (digitalInputPin == 12) {
            dot1Fill = channelColors[1];
        } else if (digitalInputPin == 13) {
            dot1Fill = channelColors[2];
        } else if (digitalInputPin == 17) {
            dot1Fill = channelColors[3];
        } else { // 18
            dot1Fill = channelColors[4];
        }

        dotX = _x;
        dotY = _y;
        dotWidth = _w;
        dotHeight = _h;
        padding = _padding;

        digitalValue = new TextBox("", dotX, dotY);
        digitalValue.textColor = color(val0Fill);
        digitalValue.alignH = CENTER;
        digitalValue.alignV = CENTER;
        drawDigitalValue = true;

        digitalPin = new TextBox("D" + digitalInputString, dotX, dotY - dotWidth);
        digitalPin.textColor = color(bgColor);
        digitalPin.alignH = CENTER;
    }

    void update() {
        List<double[]> lastData = currentBoard.getData(1);
        double[] lastSample = lastData.get(0);
        int[] digitalChannels = digitalBoard.getDigitalChannels();

        //update the voltage values
        if (digitalInputPin == 11) {
            digitalInputVal = (int)lastSample[digitalChannels[0]];
        } else if (digitalInputPin == 12) {
            digitalInputVal = (int)lastSample[digitalChannels[1]];
        } else if (digitalInputPin == 13) {
            digitalInputVal = (int)lastSample[digitalChannels[2]];
        } else if (digitalInputPin == 17) {
            digitalInputVal = (int)lastSample[digitalChannels[3]];
        } else {
            // 18
            digitalInputVal = (int)lastSample[digitalChannels[4]];
        }

        digitalValue.string = String.format("%d", digitalInputVal);
    }

    void draw(){
        pushStyle();

        if (digitalInputVal == 1) {
            fill(dot1Fill);
            digitalValue.textColor = val1Fill;
        } else {
            fill(dot0Fill);
            digitalValue.textColor = val0Fill;
        }
        stroke(dotStroke);
        ellipse(dotX, dotY, dotWidth, dotHeight);

        if(drawDigitalValue){
            digitalValue.draw();
            digitalPin.draw();
        }

        popStyle();
    }

    public int getDigitalReadVal() {
        return digitalInputVal;
    }

    void screenResized(int _x, int _y, int _w, int _h){
        dotX = _x;
        dotY = _y;
        dotWidth = _w;
        dotHeight = _h;
        dotCorner = (sqrt(2)*dotWidth/2)/2;

        digitalPin.x = dotX;
        digitalPin.y = dotY - int(dotWidth/2.0);

        digitalValue.x = dotX;
        digitalValue.y = dotY;
    }
};
