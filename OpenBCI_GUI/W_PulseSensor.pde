
////////////////////////////////////////////////////
//                                                //
//                  W_PulseSensor.pde             //
//                                                //
//    Created: Joel Murphy, Spring 2017           //
//    Refactored: Richard Waltman, August 2023    //
//                                                //
////////////////////////////////////////////////////

class W_PulseSensor extends Widget {

    //to see all core variables/methods of the Widget class, refer to Widget.pde
    //put your custom variables here...
    private color graphStroke = #d2d2d2;
    private color graphBG = #f5f5f5;
    private color textColor = #000000;

    // Pulse Sensor Visualizer Stuff
    private int count = 0;
    private int heart = 0;
    private final int PULSE_BUFFER_SIZE = 3*currentBoard.getSampleRate(); // Originally 400
    private final int BPM_BUFFER_SIZE = 100;

    private int pulseWindowWidth;
    private int pulseWindowHeight;
    private int pulseWindowX;
    private int pulseWindowY;
    private int bpmWindowWidth;
    private int bpmWindowHeight;
    private int bpmWindowX;
    private int bpmWindowY;
    private int bpmPositionX;
    private int bpmPositionY;
    private int ibiPositionX;
    private int ibiPositionY;
    private int padding = 15;
    private color eggshell;
    private color pulseWave;
    private boolean rising;

    // Pulse Sensor Beat Finder Stuff
    // ASSUMES 250Hz SAMPLE RATE
    private int[] rate;                    // array to hold last ten IBI values
    private int sampleCounter;          // used to determine pulse timing
    private int lastBeatTime;           // used to find IBI
    private int peak =512;                      // used to find peak in pulse wave, seeded
    private int trough = 512;                     // used to find trough in pulse wave, seeded
    private int thresh = 530;                // used to find instant moment of heart beat, seeded
    private int amp = 0;                   // used to hold amplitude of pulse waveform, seeded
    private boolean firstBeat = true;        // used to seed rate array so we startup with reasonable BPM
    private boolean secondBeat = false;      // used to seed rate array so we startup with reasonable BPM
    private boolean pulseDetected = false;     // "True" when User's live heartbeat is detected. "False" when not a "live beat".
    private int lastProcessedDataPacketInd = 0;
    private Button analogModeButton;

    private int[] pulseWaveY;      // HOLDS HEARTBEAT WAVEFORM DATA
    private int[] bpmWaveY;        // HOLDS BPM WAVEFORM DATA

    private int bpmValue;              // int that holds calculated BPM
    private int ibiValue = 600;             // int that holds the time interval between beats! Must be seeded!

    private AnalogCapableBoard analogBoard;

    W_PulseSensor(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        analogBoard = (AnalogCapableBoard)currentBoard;

        eggshell = color(255, 253, 248);
        pulseWave = BOLD_RED;

        pulseWaveY = new int[PULSE_BUFFER_SIZE];
        bpmWaveY = new int[BPM_BUFFER_SIZE];
        rate = new int[10];
        setPulseWidgetVariables();
        initializePulseFinderVariables();

        createAnalogModeButton("pulseSensorAnalogModeButton", "Turn Analog Read On", (int)(x0 + 1), (int)(y0 + navHeight + 1), 128, navHeight - 3, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
    }

    public void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        if(currentBoard instanceof DataSourcePlayback) {
            if (((DataSourcePlayback)currentBoard) instanceof AnalogCapableBoard
                && (!((AnalogCapableBoard)currentBoard).isAnalogActive())) {
                    return;
            }
        }

        updateGraphPointsArray();

        //ignore top left button interaction when widgetSelector dropdown is active
        List<controlP5.Controller> cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
        cp5ElementsToCheck.add((controlP5.Controller)analogModeButton);
        lockElementsOnOverlapCheck(cp5ElementsToCheck);

        if (!analogBoard.canDeactivateAnalog()) {
            analogModeButton.setLock(true);
            analogModeButton.getCaptionLabel().setText("Analog Read On");
            analogModeButton.setColorBackground(BUTTON_LOCKED_GREY);
        }
    }

    public void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)
        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        pushStyle();

        fill(graphBG);
        stroke(graphStroke);
        rect(pulseWindowX,pulseWindowY,pulseWindowWidth,pulseWindowHeight);
        rect(bpmWindowX,bpmWindowY,bpmWindowWidth,bpmWindowHeight);

        fill(50);
        textFont(p4, 16);
        textAlign(LEFT,CENTER);
        text("BPM "+bpmValue, bpmPositionX, bpmPositionY);
        text("IBI "+ibiValue+"mS", ibiPositionX, ibiPositionY);

        if (analogBoard.isAnalogActive()) {
            drawWaves();
        }

        popStyle();

    }

    public void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        setPulseWidgetVariables();
        analogModeButton.setPosition((int)(x0 + 1), (int)(y0 + navHeight + 1));
    }

    private void createAnalogModeButton(String name, String text, int _x, int _y, int _w, int _h, PFont _font, int _fontSize, color _bg, color _textColor) {
        analogModeButton = createButton(cp5_widget, name, text, _x, _y, _w, _h, 0, _font, _fontSize, _bg, _textColor, BUTTON_HOVER, BUTTON_PRESSED, OBJECT_BORDER_GREY, 0);
        analogModeButton.setSwitch(true);
        analogModeButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (!analogBoard.isAnalogActive()) {
                    analogBoard.setAnalogActive(true);
                    analogModeButton.getCaptionLabel().setText("Turn Analog Read Off");	
                    output("Starting to read analog inputs on pin marked D11.");
                    w_analogRead.toggleAnalogReadButton(true);
                    w_accelerometer.accelBoardSetActive(false);
                    w_digitalRead.toggleDigitalReadButton(false);
                } else {
                    analogBoard.setAnalogActive(false);
                    analogModeButton.getCaptionLabel().setText("Turn Analog Read On");
                    output("Starting to read accelerometer");
                    w_analogRead.toggleAnalogReadButton(false);
                    w_accelerometer.accelBoardSetActive(true);
                    w_digitalRead.toggleDigitalReadButton(false);
                }
            }
        });
        String _helpText = (selectedProtocol == BoardProtocol.WIFI) ? 
            "Click this button to activate/deactivate analog read on Cyton pins A5(D11) and A6(D12)." :
            "Click this button to activate/deactivate analog read on Cyton pins A5(D11), A6(D12) and A7(D13)."
            ;
        analogModeButton.setDescription(_helpText);
    }

    public void toggleAnalogReadButton(boolean _value) {
        String s = _value ? "Turn Analog Read Off" : "Turn Analog Read On";
        analogModeButton.getCaptionLabel().setText(s);
        if (_value) {
            analogModeButton.setOn();
        } else {
            analogModeButton.setOff();
        }
    }

    //add custom functions here
    private void setPulseWidgetVariables(){
        pulseWindowWidth = ((w/4)*3) - padding;
        pulseWindowHeight = h - padding *2;
        pulseWindowX = x + padding;
        pulseWindowY = y + h - pulseWindowHeight - padding;

        bpmWindowWidth = w/4 - (padding + padding/2);
        bpmWindowHeight = pulseWindowHeight; // - padding;
        bpmWindowX = pulseWindowX + pulseWindowWidth + padding/2;
        bpmWindowY = pulseWindowY; // + padding;

        bpmPositionX = bpmWindowX + padding/2;
        bpmPositionY = y - padding; // bpmWindowHeight + int(float(padding)*2.5);
        ibiPositionX = pulseWindowX + pulseWindowWidth/2; // + padding/2
        ibiPositionY = y - padding;
    }

    private void initializePulseFinderVariables(){
        sampleCounter = 0;
        lastBeatTime = 0;
        peak = 512;
        trough = 512;
        thresh = 530;
        amp = 0;
        firstBeat = true;
        secondBeat = false;
        bpmValue = 0;
        ibiValue = 600;
        pulseDetected = false;

        for(int i = 0; i < pulseWaveY.length; i++){
            pulseWaveY[i] = 512;
        }

        for(int i = 0; i < bpmWaveY.length; i++){
            bpmWaveY[i] = bpmValue;
        }
    }

    private void drawWaves(){
        int xi, yi;
        noFill();
        strokeWeight(1);
        stroke(pulseWave);
        beginShape();                                  // using beginShape() renders fast
        for(int i=0; i<pulseWaveY.length; i++){
            xi = int(map(i,0, pulseWaveY.length-1,0, pulseWindowWidth-1));
            xi += pulseWindowX;
            yi = int(map(pulseWaveY[i],0.0,1023.0,
                float(pulseWindowY + pulseWindowHeight),float(pulseWindowY)));
            vertex(xi, yi);
        }
        endShape();

        strokeWeight(2);
        stroke(pulseWave);
        beginShape();                                  // using beginShape() renders fast
        for(int i=0; i<bpmWaveY.length; i++){
            xi = int(map(i,0, bpmWaveY.length-1,0, bpmWindowWidth-1));
            xi += bpmWindowX;
            yi = int(map(bpmWaveY[i], 0.0,200.0,
                float(bpmWindowY + bpmWindowHeight), float(bpmWindowY)));
            vertex(xi, yi);
        }
        endShape();

    }

    // THIS IS THE BEAT FINDING FUNCTION
    // BASED ON CODE FROM World Famous Electronics, MAKERS OF PULSE SENSOR
    // https://github.com/WorldFamousElectronics/PulseSensor_Amped_Arduino
    private void processSignal(int sample) {                         // triggered when Timer2 counts to 124
        sampleCounter += 4;                         // keep track of the time in mS with this variable
        int N = sampleCounter - lastBeatTime;       // monitor the time since the last beat to avoid noise

            //  find the peak and trough of the pulse wave
        if(sample < thresh && N > (ibiValue/5)*3) {       // avoid dichrotic noise by waiting 3/5 of last IBI
            if (sample < trough) {
                trough = sample;                         // keep track of lowest point in pulse wave
            }
        }

        if(sample > thresh && sample > peak) {          // thresh condition helps avoid noise
            peak = sample;                             // keep track of highest point in pulse wave
        }                                        // keep track of highest point in pulse wave

        //  NOW IT'S TIME TO LOOK FOR THE HEART BEAT
        // signal surges up in value every time there is a pulse
        if (N > 250) {                                   // avoid high frequency noise
            if ( (sample > thresh) && (pulseDetected == false) && (N > (ibiValue/5)*3) ) {
                pulseDetected = true;                               // set the Pulse flag when we think there is a pulse
                ibiValue = sampleCounter - lastBeatTime;         // measure time between beats in mS
                lastBeatTime = sampleCounter;               // keep track of time for next pulse

                if(secondBeat){                        // if this is the second beat, if secondBeat == TRUE
                    secondBeat = false;                  // clear secondBeat flag
                    for(int i=0; i<=9; i++) {             // seed the running total to get a realisitic BPM at startup
                        rate[i] = ibiValue;
                    }
                }

                if(firstBeat){                         // if it's the first time we found a beat, if firstBeat == TRUE
                    firstBeat = false;                   // clear firstBeat flag
                    secondBeat = true;                   // set the second beat flag
                    // sei();                               // enable interrupts again
                    return;                              // IBI value is unreliable so discard it
                }


                // keep a running total of the last 10 IBI values
                int runningTotal = 0;                  // clear the runningTotal variable

                for(int i=0; i<=8; i++) {                // shift data in the rate array
                    rate[i] = rate[i+1];                  // and drop the oldest IBI value
                    runningTotal += rate[i];              // add up the 9 oldest IBI values
                }

                rate[9] = ibiValue;                          // add the latest IBI to the rate array
                runningTotal += rate[9];                // add the latest IBI to runningTotal
                runningTotal /= 10;                     // average the last 10 IBI values
                bpmValue = 60000 / runningTotal;        // how many beats can fit into a minute? that's BPM!
                bpmValue = constrain(bpmValue, 0, 200);
                
                for(int i = 0; i < bpmWaveY.length - 1; i++){
                    bpmWaveY[i] = bpmWaveY[i + 1];
                }
                bpmWaveY[bpmWaveY.length - 1] = bpmValue;
            }
        }

        if (sample < thresh && pulseDetected == true) {   // when the values are going down, the beat is over
            // digitalWrite(blinkPin,LOW);            // turn off pin 13 LED
            pulseDetected = false;                         // reset the Pulse flag so we can do it again
            amp = peak - trough;                           // get amplitude of the pulse wave
            thresh = amp/2 + trough;                    // set thresh at 50% of the amplitude
            peak = thresh;                            // reset these for next time
            trough = thresh;
        }

        if (N > 2500) {                           // if 2.5 seconds go by without a beat
            thresh = 530;                          // set thresh default
            peak = 512;                            // set peak to default value
            trough = 512;                          // set trough to default value default
            lastBeatTime = sampleCounter;          // bring the lastBeatTime up to date
            firstBeat = true;                      // set these to avoid noise
            secondBeat = false;                    // when we get the heartbeat back
        }
    }// end processSignal

    private void updateGraphPointsArray() {
        List<double[]> allData = currentBoard.getData(PULSE_BUFFER_SIZE);
        int[] analogChannels = analogBoard.getAnalogChannels();
        //Update array that holds points to draw pulse wave
        for (int i=0; i < PULSE_BUFFER_SIZE; i++ ) {
            int signal = (int)(allData.get(i)[analogChannels[0]]);
            pulseWaveY[i] = signal;
        }
    }

    public void updatePulseSensorWidgetData() {
        int[] analogChannels = analogBoard.getAnalogChannels();
        double[][] frameData = currentBoard.getFrameData();
        for (int i = 0; i < frameData[0].length; i++)
        {
            int signal = (int)(frameData[analogChannels[0]][i]);
            processSignal(signal);
        }
    }

    public int getBPM() {
        return bpmValue;
    }

    public int getIBI() {
        return ibiValue;
    }
};
