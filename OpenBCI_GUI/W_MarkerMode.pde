
////////////////////////////////////////////////////
//
//  W_MarkerMode is used to put the board into marker mode
//  by Gerrie van Zyl
//  Basd on W_Analogread by AJ Keller
//
//
///////////////////////////////////////////////////,

class W_MarkerMode extends Widget {
    // color boxBG;
    color graphStroke = #d2d2d2;
    color graphBG = #f5f5f5;
    color textColor = #000000;
    color strokeColor;
    color eggshell;
    color xColor;

    // Accelerometer Stuff
    int markerBuffSize = 500; //points registered in accelerometer buff
    int padding = 30;

    // bottom xyz graph
    int markerWindowWidth;
    int markerWindowHeight;
    int markerWindowX;
    int markerWindowY;

    float yMaxMin;

    int[] makerBuffer;
    int lastMarker=0;
    int localValidLastMarker;

    // for the synthetic markers
    float synthTime;
    int synthCount;

    boolean markerModeOn = false;
    Button markerModeButton;

    W_MarkerMode(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        // boxBG = bgColor;
        strokeColor = color(138, 146, 153);

        // Marker Sensor Stuff
        eggshell = color(255, 253, 248);
        xColor = color(224, 56, 45);

        setGraphDimensions();

        // The range of markers
        yMaxMin = 256;

        // XYZ buffer for bottom graph
        makerBuffer = new int[markerBuffSize];

        // for synthesizing values
        synthTime = 0.0;

        markerModeButton = new Button((int)(x + 3), (int)(y + 3 - navHeight), 120, navHeight - 6, "Turn MarkerMode On", 12);
        markerModeButton.setCornerRoundess((int)(navHeight-6));
        markerModeButton.setFont(p6,10);
        markerModeButton.setColorNotPressed(color(57,128,204));
        markerModeButton.textColorNotActive = color(255);
        markerModeButton.hasStroke(false);
        markerModeButton.setHelpText("Click this button to activate/deactivate the MarkerMode of your Cyton board!");
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        localValidLastMarker =  hub.validLastMarker;  // make a local copy so it can be manipulated in SYNTHETIC mode
        hub.validLastMarker = 0;

        if (eegDataSource == DATASOURCE_SYNTHETIC) {
            localValidLastMarker = synthesizeMarkerData();
        }
        if (eegDataSource == DATASOURCE_CYTON || eegDataSource == DATASOURCE_SYNTHETIC) {
            if (isRunning && cyton.getBoardMode() == BoardMode.MARKER) {
                if (localValidLastMarker > 0){
                    lastMarker = localValidLastMarker;  // this holds the last marker for the display
                }
                makerBuffer[makerBuffer.length-1] =
                    int(map(logScaleMarker(localValidLastMarker), 0, yMaxMin, float(markerWindowY+markerWindowHeight), float(markerWindowY)));
                makerBuffer[makerBuffer.length-1] = constrain(makerBuffer[makerBuffer.length-1], markerWindowY, markerWindowY+markerWindowHeight);

                shiftWave();
            }
        }
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        pushStyle();
        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        if (true) {

            fill(50);
            textFont(p4, 14);
            textAlign(CENTER,CENTER);

            fill(graphBG);
            stroke(graphStroke);
            rect(markerWindowX, markerWindowY, markerWindowWidth, markerWindowHeight);
            line(markerWindowX, markerWindowY + markerWindowHeight/2, markerWindowX+markerWindowWidth, markerWindowY + markerWindowHeight/2); //midline

            fill(50);
            textFont(p5, 12);
            textAlign(CENTER,CENTER);
            text((int)yMaxMin, markerWindowX+markerWindowWidth + 12, markerWindowY);
            text((int)16, markerWindowX+markerWindowWidth + 12, markerWindowY + markerWindowHeight/2);
            text("0", markerWindowX+markerWindowWidth + 12, markerWindowY + markerWindowHeight);


            fill(graphBG);  // pulse window background
            stroke(graphStroke);

            stroke(180);

            fill(50);
            textFont(p3, 16);

            if (eegDataSource == DATASOURCE_CYTON && cyton.getBoardMode() != BoardMode.MARKER) {
                markerModeButton.setString("Turn Marker On");
                markerModeButton.draw();
            } else if (eegDataSource == DATASOURCE_SYNTHETIC) {
                markerModeButton.draw();
                drawMarkerValues();
                drawMarkerWave();
            } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) {  // PLAYBACK
                drawMarkerValues();
                drawMarkerWave2();
            } else {
                markerModeButton.setString("Turn Marker Off");
                markerModeButton.draw();
                drawMarkerValues();
                drawMarkerWave();
            }
        }
        popStyle();
    }

    void setGraphDimensions(){
        markerWindowWidth = w - padding*2;
        markerWindowHeight = int((float(h) - float(padding*3)));
        markerWindowX = x + padding;
        markerWindowY = y + h - markerWindowHeight - padding;

    }

    void screenResized(){
        int prevX = x;
        int prevY = y;
        int prevW = w;
        int prevH = h;

        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        int dy = y - prevY;
        println("dy = " + dy);
        println("Acc Widget -- Screen Resized.");

        setGraphDimensions();

        //empty arrays to start redrawing from scratch
        for (int i=0; i<makerBuffer.length; i++) {  // initialize the accelerometer data
            makerBuffer[i] = markerWindowY + markerWindowHeight; // X at 1/4
        }

        markerModeButton.setPos((int)(x + 3), (int)(y + 3 - navHeight));
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        if (markerModeButton.isMouseHere()) {
            markerModeButton.setIsActive(true);
        }
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        if(markerModeButton.isActive && markerModeButton.isMouseHere()){
            if((cyton.isPortOpen() && eegDataSource == DATASOURCE_CYTON) || eegDataSource == DATASOURCE_SYNTHETIC) {
                if (cyton.getBoardMode() != BoardMode.MARKER) {
                    cyton.setBoardMode(BoardMode.MARKER.getValue());
                    output("Starting to read markers");
                    markerModeButton.setString("Turn Marker Off");
                    w_analogRead.analogReadOn = false;
                    w_pulsesensor.analogReadOn = false;
                    w_digitalRead.digitalReadOn = false;
                } else {
                    cyton.setBoardMode(BoardMode.DEFAULT.getValue());
                    output("Starting to read accelerometer");
                    markerModeButton.setString("Turn Marker On");
                    w_analogRead.analogReadOn = false;
                    w_pulsesensor.analogReadOn = false;
                    w_digitalRead.digitalReadOn = false;
                }
                markerModeOn = !markerModeOn;
            }
        }
        markerModeButton.setIsActive(false);
    }

    //add custom classes functions here
    void drawMarkerValues() {
        textAlign(LEFT,CENTER);
        textFont(h1,20);
        fill(xColor);
        text("Last Marker = " + lastMarker, x+padding , y + (h/12)*1.5);
    }

    void shiftWave() {
        for (int i = 0; i < makerBuffer.length-1; i++) {      // move the pulse waveform by
            makerBuffer[i] = makerBuffer[i+1];
        }
    }

    void drawMarkerWave() {
        noFill();
        strokeWeight(2);
        beginShape();                                  // using beginShape() renders fast
        stroke(xColor);
        for (int i = 0; i < makerBuffer.length; i++) {
            // int xi = int(map(i, 0, X.length-1, 0, markerWindowWidth-1));
            // vertex(markerWindowX+xi, X[i]);                    //draw a line connecting the data points
            int xi = int(map(i, 0, makerBuffer.length-1, 0, markerWindowWidth-1));
            // int yi = int(map(X[i], yMaxMin, -yMaxMin, 0.0, markerWindowHeight-1));
            // int yi = 2;
            vertex(markerWindowX+xi, makerBuffer[i]);                    //draw a line connecting the data points
        }
        endShape();
    }

    void drawMarkerWave2() {
        noFill();
        strokeWeight(1);
        beginShape();                                  // using beginShape() renders fast
        stroke(xColor);
        for (int i = 0; i < accelerometerBuff[0].length; i++) {
            int x = int(map(accelerometerBuff[0][i], -yMaxMin, yMaxMin, float(markerWindowY+markerWindowHeight), float(markerWindowY)));  // ss
            x = constrain(x, markerWindowY, markerWindowY+markerWindowHeight);
            vertex(markerWindowX+i, x);                    //draw a line connecting the data points
        }
        endShape();
    }

    int synthesizeMarkerData() {
        synthTime += 0.02;
        int valueMarker;

        if (synthCount++ > 10){
            valueMarker =  int((sin(synthTime) +1.0)*127.);
            synthCount = 0;
        } else {
            valueMarker = 0;
        }

        return valueMarker;
    }

    int logScaleMarker( float value ) {
        // this returns log value between 0 and yMaxMin for a value between 0. and 255.
        return int(log(int(value)+1.0)*yMaxMin/log(yMaxMin+1));
    }
};
