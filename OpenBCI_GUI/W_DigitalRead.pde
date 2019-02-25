
////////////////////////////////////////////////////
//
//  W_DigitalRead is used to visiualze digital input values
//
//  Created: AJ Keller
//
//
///////////////////////////////////////////////////,

class W_DigitalRead extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...

  int numDigitalReadDots;
  float xF, yF, wF, hF;
  int dot_padding;
  float dot_x, dot_y, dot_h, dot_w; //values for actual time series chart (rectangle encompassing all digitalReadDots)
  float plotBottomWell;
  float playbackWidgetHeight;
  int digitalReadDotHeight;

  DigitalReadDot[] digitalReadDots;

  TextBox[] chanValuesMontage;
  boolean showMontageValues;

  private boolean visible = true;
  private boolean updating = true;
  boolean digitalReadOn = false;

  Button digitalModeButton;

  W_DigitalRead(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function

    //set number of digital reads
    if (cyton.isWifi()) {
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
    digitalReadDotHeight = int(dot_h/numDigitalReadDots);

    digitalReadDots = new DigitalReadDot[numDigitalReadDots];

    //create our channel bars and populate our digitalReadDots array!
    for(int i = 0; i < numDigitalReadDots; i++){
      int digitalReadDotY = int(dot_y) + i*(digitalReadDotHeight); //iterate through bar locations
      int digitalReadDotX = int(dot_x) + i*(digitalReadDotHeight); //iterate through bar locations
      int digitalPin = 0;
      if (i == 0) {
        digitalPin = 11;
      } else if (i == 1) {
        digitalPin = 12;
      } else if (i == 2) {
        if (cyton.isWifi()) {
          digitalPin = 17;
        } else {
          digitalPin = 13;
        }
      } else if (i == 3) {
        digitalPin = 17;
      } else {
        digitalPin = 18;
      }
      DigitalReadDot tempDot = new DigitalReadDot(_parent, digitalPin, digitalReadDotX, digitalReadDotY, int(dot_w), digitalReadDotHeight, dot_padding);
      digitalReadDots[i] = tempDot;
    }

    digitalModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "Turn Analog Read On", 12);
    digitalModeButton.setCornerRoundess((int)(navHeight-6));
    digitalModeButton.setFont(p6,10);
    digitalModeButton.setColorNotPressed(color(57,128,204));
    digitalModeButton.textColorNotActive = color(255);
    digitalModeButton.hasStroke(false);

    if (cyton.isWifi()) {
      digitalModeButton.setHelpText("Click this button to activate/deactivate digital reading on the Cyton D11, D12, and D17");
    } else {
      digitalModeButton.setHelpText("Click this button to activate/deactivate digital reading on the Cyton D11, D12, D13, D17 and D18");
    }
  }

  public boolean isVisible() {
    return visible;
  }
  public boolean isUpdating() {
    return updating;
  }

  public void setVisible(boolean _visible) {
    visible = _visible;
  }
  public void setUpdating(boolean _updating) {
    updating = _updating;
  }

  void update(){
    if(visible && updating){
      super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

      //put your code here...
      //update channel bars ... this means feeding new EEG data into plots
      for(int i = 0; i < numDigitalReadDots; i++){
        digitalReadDots[i].update();
      }
    }
  }

  void draw(){
    if(visible){
      super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

      //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
      pushStyle();
      //draw channel bars
      digitalModeButton.draw();
      if (cyton.getBoardMode() != BOARD_MODE_DIGITAL) {
        digitalModeButton.setString("Turn Digital Read On");
      } else {
        digitalModeButton.setString("Turn Digital Read Off");
        for(int i = 0; i < numDigitalReadDots; i++){
          digitalReadDots[i].draw();
        }
      }
      popStyle();
    }
  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    xF = float(x); //float(int( ... is a shortcut for rounding the float down... so that it doesn't creep into the 1px margin
    yF = float(y);
    wF = float(w);
    hF = float(h);
    // consolePrint("w_digitalRead: screenResized: x: " + x + " y: " + y + " w: "+ w + " h: " + h + " navBarHeight: " + navBarHeight);

    if (wF > hF) {
      digitalReadDotHeight = int(hF/(numDigitalReadDots+1));
    } else {
      digitalReadDotHeight = int(wF/(numDigitalReadDots+1));
    }

    if (numDigitalReadDots == 3) {
      digitalReadDots[0].screenResized(x+int(wF*(1.0/3.0)), y+int(hF*(1.0/3.0)), digitalReadDotHeight, digitalReadDotHeight); //bar x, bar y, bar w, bar h
      digitalReadDots[1].screenResized(x+int(wF/2), y+int(hF/2), digitalReadDotHeight, digitalReadDotHeight); //bar x, bar y, bar w, bar h
      digitalReadDots[2].screenResized(x+int(wF*(2.0/3.0)), y+int(hF*(2.0/3.0)), digitalReadDotHeight, digitalReadDotHeight); //bar x, bar y, bar w, bar h
    } else {
      int y_pad = y + dot_padding;
      digitalReadDots[0].screenResized(x+int(wF*(1.0/8.0)), y_pad+int(hF*(1.0/8.0)), digitalReadDotHeight, digitalReadDotHeight);
      digitalReadDots[2].screenResized(x+int(wF/2), y_pad+int(hF/2), digitalReadDotHeight, digitalReadDotHeight);
      digitalReadDots[4].screenResized(x+int(wF*(7.0/8.0)), y_pad+int(hF*(7.0/8.0)), digitalReadDotHeight, digitalReadDotHeight);
      digitalReadDots[1].screenResized(digitalReadDots[0].DotX+int(wF*(3.0/16.0)), digitalReadDots[0].DotY+int(hF*(3.0/16.0)), digitalReadDotHeight, digitalReadDotHeight);
      digitalReadDots[3].screenResized(digitalReadDots[2].DotX+int(wF*(3.0/16.0)), digitalReadDots[2].DotY+int(hF*(3.0/16.0)), digitalReadDotHeight, digitalReadDotHeight);

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

    //put your code here...
    if(digitalModeButton.isActive && digitalModeButton.isMouseHere()){
      // consolePrint("digitalModeButton...");
      if(cyton.isPortOpen()) {
        if (cyton.getBoardMode() != BOARD_MODE_DIGITAL) {
          cyton.setBoardMode(BOARD_MODE_DIGITAL);
          if (cyton.isWifi()) {
            output("Starting to read digital inputs on pin marked D11, D12 and D17");
          } else {
            output("Starting to read digital inputs on pin marked D11, D12, D13, D17 and D18");
          }
          w_accelerometer.accelerometerModeOn = false;
          w_analogRead.analogReadOn = false;
          w_pulsesensor.analogReadOn = false;
          w_markermode.markerModeOn = false;
        } else {
          cyton.setBoardMode(BOARD_MODE_DEFAULT);
          output("Starting to read accelerometer");
          w_accelerometer.accelerometerModeOn = true;
        }
        digitalReadOn = !digitalReadOn;
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

  int digitalInputPin;
  int digitalInputVal;
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

  int DotX;
  int DotY;
  int DotWidth;
  int DotHeight;
  float DotCorner;

  DigitalReadDot(PApplet _parent, int _digitalInputPin, int _x, int _y, int _w, int _h, int _padding){ // channel number, x/y location, height, width

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

    DotX = _x;
    DotY = _y;
    DotWidth = _w;
    DotHeight = _h;
    padding = _padding;

    digitalValue = new TextBox("", DotX, DotY);
    digitalValue.textColor = color(val0Fill);
    digitalValue.alignH = CENTER;
    digitalValue.alignV = CENTER;

    digitalPin = new TextBox("D" + digitalInputString, DotX, DotY - DotWidth);
    digitalPin.textColor = color(bgColor);
    digitalPin.alignH = CENTER;
    // digitalPin.alignV = CENTER;

    drawDigitalValue = true;
  }

  void update(){
    //update the voltage values
    if (digitalInputPin == 11) {
      digitalInputVal = (hub.validAccelValues[0] & 0xFF00) >> 8;
    } else if (digitalInputPin == 12) {
      digitalInputVal = hub.validAccelValues[0] & 0xFF;
    } else if (digitalInputPin == 13) {
      digitalInputVal = (hub.validAccelValues[1] & 0xFF00) >> 8;
    } else if (digitalInputPin == 17) {
      digitalInputVal = hub.validAccelValues[1] & 0xFF;
    } else { // 18
      digitalInputVal = hub.validAccelValues[2];
    }

    digitalValue.string = String.format("%d", digitalInputVal);
  }

  void draw(){
    pushStyle();

    //draw plot

    if (digitalInputVal == 1) {
      fill(dot1Fill);
      digitalValue.textColor = val1Fill;
    } else {
      fill(dot0Fill);
      digitalValue.textColor = val0Fill;
    }
    stroke(dotStroke);
    ellipse(DotX, DotY, DotWidth, DotHeight);

    if(drawDigitalValue){
      digitalValue.draw();
      digitalPin.draw();
    }

    popStyle();
  }

  void screenResized(int _x, int _y, int _w, int _h){
    DotX = _x;
    DotY = _y;
    DotWidth = _w;
    DotHeight = _h;
    DotCorner = (sqrt(2)*DotWidth/2)/2;

    // consolePrint("DigitalReadDot: " + digitalInputPin + " screenResized: DotX: " + DotX + " DotY: " + DotY + " DotWidth: "+ DotWidth + " DotHeight: " + DotHeight);

    digitalPin.x = DotX;
    digitalPin.y = DotY - int(DotWidth/2.0);

    digitalValue.x = DotX;
    digitalValue.y = DotY;
  }
};
