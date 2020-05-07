/////////////////////////////////////////////////////////////////////////////////
//
//  Emg_Widget is used to visiualze EMG data by channel, and to trip events
//
//  Created: Colin Fausnaught, December 2016 (with a lot of reworked code from Tao)
//
//  Custom widget to visiualze EMG data. Features dragable thresholds, serial
//  out communication, channel configuration, digital and analog events.
//
//  KNOWN ISSUES: Cannot resize with window dragging events
//
//  TODO: Add dynamic threshold functionality
////////////////////////////////////////////////////////////////////////////////

void SmoothEMG(int n){

    float samplesPerSecond;
    if(eegDataSource == DATASOURCE_GANGLION){
        samplesPerSecond = 200;
    } else {
        samplesPerSecond = 250;
    }

    for(int i = 0 ; i < w_emg.motorWidgets.length; i++){
        if(n == 0){
            w_emg.motorWidgets[i].averagePeriod = samplesPerSecond * 0.01;
        }
        if(n == 1){
            w_emg.motorWidgets[i].averagePeriod = samplesPerSecond * 0.1;
        }
        if(n == 2){
            w_emg.motorWidgets[i].averagePeriod = samplesPerSecond * 0.15;
        }
        if(n == 3){
            w_emg.motorWidgets[i].averagePeriod = samplesPerSecond * 0.25;
        }
        if(n == 4){
            w_emg.motorWidgets[i].averagePeriod = samplesPerSecond * 0.5;
        }
        if(n == 5){
            w_emg.motorWidgets[i].averagePeriod = samplesPerSecond * 0.75;
        }
        if(n == 6){
            w_emg.motorWidgets[i].averagePeriod = samplesPerSecond * 1.0;
        }
        if(n == 7){
            w_emg.motorWidgets[i].averagePeriod = samplesPerSecond * 2.0;
        }
    }
    settings.emgSmoothingSave = n;
    closeAllDropdowns();
}

void uVLimit(int n){
    for(int i = 0 ; i < w_emg.motorWidgets.length; i++){
        if(n == 0){
            w_emg.motorWidgets[i].acceptableLimitUV = 50.0;
        }
        if(n == 1){
            w_emg.motorWidgets[i].acceptableLimitUV = 100.0;
        }
        if(n == 2){
            w_emg.motorWidgets[i].acceptableLimitUV = 200.0;
        }
        if(n == 3){
            w_emg.motorWidgets[i].acceptableLimitUV = 400.0;
        }
    }
    settings.emguVLimSave = n;
    closeAllDropdowns();
}

void CreepSpeed(int n){
    for(int i = 0 ; i < w_emg.motorWidgets.length; i++){
        if(n == 0){
            w_emg.motorWidgets[i].creepSpeed = 0.9;
        }
        if(n == 1){
            w_emg.motorWidgets[i].creepSpeed = 0.95;
        }
        if(n == 2){
            w_emg.motorWidgets[i].creepSpeed = 0.98;
        }
        if(n == 3){
            w_emg.motorWidgets[i].creepSpeed = 0.99;
        }
        if(n == 4){
            w_emg.motorWidgets[i].creepSpeed = 0.999;
        }
    }
    settings.emgCreepSave = n;
    closeAllDropdowns();
}

void minUVRange(int n){
    for(int i = 0 ; i < w_emg.motorWidgets.length; i++){
        if(n == 0){
            w_emg.motorWidgets[i].minRange = 10.0;
        }
        if(n == 1){
            w_emg.motorWidgets[i].minRange = 20.0;
        }
        if(n == 2){
            w_emg.motorWidgets[i].minRange = 40.0;
        }
        if(n == 3){
            w_emg.motorWidgets[i].minRange = 80.0;
        }
    }
    settings.emgMinDeltauVSave = n;
    closeAllDropdowns();
}

class W_emg extends Widget {
    Motor_Widget[] motorWidgets;
    TripSlider[] tripSliders;
    TripSlider[] untripSliders;
    List<String> baudList;
    List<String> serList;
    List<String> channelList;
    boolean[] events;
    int currChannel;
    int theBaud;
    Button connectButton;
    Serial serialOutEMG;
    String theSerial;

    Boolean emgAdvanced = false;

    PApplet parent;

    W_emg (PApplet _parent) {
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)
        parent = _parent;

        //EMG settings
        settings.emgSmoothingSave = 4;
        settings.emguVLimSave = 2;
        settings.emgCreepSave = 3;
        settings.emgMinDeltauVSave = 1;

        //Add dropdowns
        addDropdown("SmoothEMG", "Smooth", Arrays.asList("0.01 s", "0.1 s", "0.15 s", "0.25 s", "0.5 s", "0.75 s", "1.0 s", "2.0 s"), settings.emgSmoothingSave);
        addDropdown("uVLimit", "uV Limit", Arrays.asList("50 uV", "100 uV", "200 uV", "400 uV"), settings.emguVLimSave);
        addDropdown("CreepSpeed", "Creep", Arrays.asList("0.9", "0.95", "0.98", "0.99", "0.999"), settings.emgCreepSave);
        addDropdown("minUVRange", "Min \u0394uV", Arrays.asList("10 uV", "20 uV", "40 uV", "80 uV"), settings.emgMinDeltauVSave);

        updateEMGMotorWidgets(nchan);

        if (emgAdvanced) {
            channelList = new ArrayList<String>();
            baudList = new ArrayList<String>();
            serList = new ArrayList<String>();
            for (int i = 0; i < nchan; i++) {
                channelList.add(Integer.toString(i + 1));
            }

            currChannel = 0;
            theBaud = 230400;

            baudList.add("NONE");
            baudList.add(Integer.toString(230400));
            baudList.add(Integer.toString(115200));
            baudList.add(Integer.toString(57600));
            baudList.add(Integer.toString(38400));
            baudList.add(Integer.toString(28800));
            baudList.add(Integer.toString(19200));
            baudList.add(Integer.toString(14400));
            baudList.add(Integer.toString(9600));
            baudList.add(Integer.toString(7200));
            baudList.add(Integer.toString(4800));
            baudList.add(Integer.toString(3600));

            String[] serialPorts = Serial.list();
            serList.add("NONE");
            for (int i = 0; i < serialPorts.length; i++) {
                String tempPort = serialPorts[(serialPorts.length - 1) - i];
                if (!tempPort.equals(openBCI_portName)) serList.add(tempPort);
            }

            addDropdown("SerialSelection", "Output", serList, 0);
            addDropdown("ChannelSelection", "Channel", channelList, 0);
            addDropdown("EventType", "Event Type", Arrays.asList("Digital", "Analog"), 0);
            addDropdown("BaudRate", "Baud Rate", baudList, 0);
            tripSliders = new TripSlider[nchan];
            untripSliders = new TripSlider[nchan];

            initSliders(w, h);
        }
    }

    //Initalizes the threshold
    void initSliders(int rw, int rh) {
        //Stole some logic from the rectangle drawing in draw()
        int rowNum = 4;
        int colNum = motorWidgets.length / rowNum;
        int index = 0;

        float rowOffset = rh / rowNum;
        float colOffset = rw / colNum;

        for (int i = 0; i < rowNum; i++) {
            for (int j = 0; j < colNum; j++) {

                println("ROW: " + (4*rowOffset/8));
                tripSliders[index] = new TripSlider(int((5*colOffset/8) * 0.498), int((2 * rowOffset / 8) * 0.384), (4*rowOffset/8) * 0.408, int((3*colOffset/32) * 0.489), 2, tripSliders, true, motorWidgets[index]);
                untripSliders[index] = new TripSlider(int((5*colOffset/8) * 0.498), int((2 * rowOffset / 8) * 0.384), (4*rowOffset/8) * 0.408, int((3*colOffset/32) * 0.489), 2, tripSliders, false, motorWidgets[index]);
                tripSliders[index].setStretchPercentage(motorWidgets[index].tripThreshold);
                untripSliders[index].setStretchPercentage(motorWidgets[index].untripThreshold);
                index++;
            }
        }
    }

    void updateEMGMotorWidgets(int _nchan) {
        //setup EMG motor widgets using the number of channels selected
        motorWidgets = new Motor_Widget[_nchan];
        for (int i = 0; i < _nchan; i++) {
            motorWidgets[i] = new Motor_Widget();
            motorWidgets[i].ourChan = i;
            if(eegDataSource == DATASOURCE_GANGLION){
                motorWidgets[i].averagePeriod = 200 * 0.5;
            } else {
                motorWidgets[i].averagePeriod = 250 * 0.5;
            }
        }
        events = new boolean[_nchan];
        for (int i = 0; i < _nchan; i++) {
            events[i] = true;
        }
    }

    void update() {
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
        process(dataBuffY_filtY_uV, fftBuff);
    }

    void draw() {
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        pushStyle();
        noStroke();
        fill(255);
        rect(x, y, w, h);

        if (emgAdvanced) {
            if (connectButton != null) connectButton.draw();
            else connectButton = new Button(int(x) + 2, int(y) - navHeight + 2, 100, navHeight - 6, "Connect", fontInfo.buttonLabel_size);

            stroke(1, 18, 41, 125);

            if (connectButton != null && connectButton.wasPressed) {
                fill(0, 255, 0);
                ellipse(x + 120, y - navHeight/2, 16, 16);
            } else if (connectButton != null && !connectButton.wasPressed) {
                fill(255, 0, 0);
                ellipse(x + 120, y - navHeight/2, 16, 16);
            }
        }

        float rx = x, ry = y, rw = w, rh = h;
        float scaleFactor = 1.0;
        float scaleFactorJaw = 1.5;
        int rowNum = 4;
        int colNum = motorWidgets.length / rowNum;
        float rowOffset = rh / rowNum;
        float colOffset = rw / colNum;
        int index = 0;
        float currx, curry;

        for (int i = 0; i < rowNum; i++) {
            for (int j = 0; j < colNum; j++) {

                pushMatrix();
                currx = rx + j * colOffset;
                curry = ry + i * rowOffset; //never name variables on an empty stomach
                translate(currx, curry);

                //realtime
                fill(red(channelColors[index%8]), green(channelColors[index%8]), blue(channelColors[index%8]), 200);
                noStroke();
                ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * motorWidgets[i * colNum + j].myAverage, scaleFactor * motorWidgets[i * colNum + j].myAverage);

                //circle for outer threshold
                noFill();
                strokeWeight(1);
                stroke(red(bgColor), green(bgColor), blue(bgColor), 150);
                ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * motorWidgets[i * colNum + j].upperThreshold, scaleFactor * motorWidgets[i * colNum + j].upperThreshold);

                //circle for inner threshold
                stroke(red(bgColor), green(bgColor), blue(bgColor), 150);
                ellipse(2*colOffset/8, rowOffset / 2, scaleFactor * motorWidgets[i * colNum + j].lowerThreshold, scaleFactor * motorWidgets[i * colNum + j].lowerThreshold);

                int _x = int(5*colOffset/8);
                int _y = int(2 * rowOffset / 8);
                int _w = int(5*colOffset/32);
                int _h = int(4*rowOffset/8);

                //draw normalized bar graph of uV w/ matching channel color
                noStroke();
                fill(red(channelColors[index%8]), green(channelColors[index%8]), blue(channelColors[index%8]), 200);
                rect(_x, 3*_y + 1, _w, map(motorWidgets[i * colNum + j].output_normalized, 0, 1, 0, (-1) * int((4*rowOffset/8))));

                //draw background bar container for mapped uV value indication
                strokeWeight(1);
                stroke(red(bgColor), green(bgColor), blue(bgColor), 150);
                noFill();
                rect(_x, _y, _w, _h);

                //draw trip & untrip threshold bars
                if (emgAdvanced) {
                    tripSliders[index].update(currx, curry);
                    tripSliders[index].display(_x, _y, _w, _h);
                    untripSliders[index].update(currx, curry);
                    untripSliders[index].display(_x, _y, _w, _h);
                }

                //draw channel number at upper left corner of row/column cell
                pushStyle();
                stroke(0);
                fill(bgColor);
                int _chan = index+1;
                textFont(p5, 12);
                text(_chan + "", 10, 20);
                popStyle();

                index++;
                popMatrix();
            }
        }

        popStyle();
    }

    void screenResized() {
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        if (emgAdvanced) {
            connectButton.setPos(int(x) + 2, int(y) - navHeight + 2);

            for (int i = 0; i < tripSliders.length; i++) {
                //update slider positions
            }
        }
    }

    void mousePressed() {
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        if (emgAdvanced) {
            if (connectButton.isMouseHere()) {
                connectButton.setIsActive(true);
                println("Connect pressed");
            } else connectButton.setIsActive(false);
        }
    }

    void mouseReleased() {
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        if (emgAdvanced) {
            if (connectButton != null && connectButton.isMouseHere()) {
                //do some function

                try {
                    serialOutEMG = new Serial(parent, theSerial, theBaud);
                    connectButton.wasPressed = true;
                    verbosePrint("Connected");
                    output("Connected to " + theSerial);
                }
                catch (Exception e) {
                    connectButton.wasPressed = false;
                    verbosePrint("Could not connect!");
                    output("Could not connect. Confirm that your Serial/COM port is correct and active.");
                }

                connectButton.setIsActive(false);
            }

            for (int i = 0; i<nchan; i++) {
                tripSliders[i].releaseEvent();
                untripSliders[i].releaseEvent();
            }
        }
    }

    public void process(
        float[][] data_forDisplay_uV, //this data has been filtered and is ready for plotting on the screen
        FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

        //for example, you could loop over each EEG channel to do some sort of time-domain processing
        //using the sample values that have already been filtered, as will be plotted on the display
        //float EEG_value_uV;

        //looping over channels and analyzing input data
        for (Motor_Widget cfc : motorWidgets) {
            cfc.myAverage = 0.0;
            for (int i = data_forDisplay_uV[cfc.ourChan].length - int(cfc.averagePeriod); i < data_forDisplay_uV[cfc.ourChan].length; i++) {
                if (abs(data_forDisplay_uV[cfc.ourChan][i]) <= cfc.acceptableLimitUV) { //prevent BIG spikes from effecting the average
                    cfc.myAverage += abs(data_forDisplay_uV[cfc.ourChan][i]);  //add value to average ... we will soon divide by # of packets
                } else {
                    cfc.myAverage += cfc.acceptableLimitUV; //if it's greater than the limit, just add the limit
                }
            }
            cfc.myAverage = cfc.myAverage / cfc.averagePeriod; // float(cfc.averagePeriod); //finishing the average

            if (cfc.myAverage >= cfc.upperThreshold && cfc.myAverage <= cfc.acceptableLimitUV) { //
                cfc.upperThreshold = cfc.myAverage;
            }
            if (cfc.myAverage <= cfc.lowerThreshold) {
                cfc.lowerThreshold = cfc.myAverage;
            }
            if (cfc.upperThreshold >= (cfc.myAverage + cfc.minRange)) {  //minRange = 15
                cfc.upperThreshold *= cfc.creepSpeed; //adjustmentSpeed
            }
            if (cfc.lowerThreshold <= 1){
                cfc.lowerThreshold = 1.0;
            }
            if (cfc.lowerThreshold <= cfc.myAverage) {
                cfc.lowerThreshold *= (1)/(cfc.creepSpeed); //adjustmentSpeed
            }
            if (cfc.upperThreshold <= (cfc.lowerThreshold + cfc.minRange)){
                cfc.upperThreshold = cfc.lowerThreshold + cfc.minRange;
            }

            cfc.output_normalized = map(cfc.myAverage, cfc.lowerThreshold, cfc.upperThreshold, 0, 1);
            if(cfc.output_normalized < 0){
                cfc.output_normalized = 0; //always make sure this value is >= 0
            }
            cfc.output_adjusted = ((-0.1/(cfc.output_normalized*255.0)) + 255.0);

            //=============== TRIPPIN ==================
            //= Just calls all the trip events         =
            //==========================================

            switch(cfc.ourChan) {

            case 0:
                if (events[0]) digitalEventChan0(cfc);
                else analogEventChan0(cfc);
                break;
            case 1:
                if (events[1]) digitalEventChan1(cfc);
                else analogEventChan1(cfc);
                break;
            case 2:
                if (events[2]) digitalEventChan2(cfc);
                else analogEventChan2(cfc);
                break;
            case 3:
                if (events[3]) digitalEventChan3(cfc);
                else analogEventChan3(cfc);
                break;
            case 4:
                if (events[4]) digitalEventChan4(cfc);
                else analogEventChan4(cfc);
                break;
            case 5:
                if (events[5]) digitalEventChan5(cfc);
                else  analogEventChan5(cfc);
                break;
            case 6:
                if (events[6]) digitalEventChan6(cfc);
                else analogEventChan6(cfc);
                break;
            case 7:
                if (events[7]) digitalEventChan7(cfc);
                else analogEventChan7(cfc);
                break;
            case 8:
                if (events[8]) digitalEventChan8(cfc);
                else analogEventChan8(cfc);
                break;
            case 9:
                if (events[9]) digitalEventChan9(cfc);
                else analogEventChan9(cfc);
                break;
            case 10:
                if (events[10]) digitalEventChan10(cfc);
                else analogEventChan10(cfc);
                break;
            case 11:
                if (events[11]) digitalEventChan11(cfc);
                else analogEventChan11(cfc);
                break;
            case 12:
                if (events[12]) digitalEventChan12(cfc);
                else analogEventChan12(cfc);
                break;
            case 13:
                if (events[13]) digitalEventChan13(cfc);
                else analogEventChan13(cfc);
                break;
            case 14:
                if (events[14]) digitalEventChan14(cfc);
                else analogEventChan14(cfc);
                break;
            case 15:
                if (events[15]) digitalEventChan15(cfc);
                else analogEventChan15(cfc);
                break;
            default:
                break;
            }
        }
        //=================== OpenBionics switch example ==============================

        if (millis() - motorWidgets[0].timeOfLastTrip >= 2000 && serialOutEMG != null) {
            //println("Counter: " + motorWidgets[0].switchCounter);
            switch(motorWidgets[0].switchCounter) {
            case 1:
                serialOutEMG.write("G0");
                break;
            }
            motorWidgets[0].switchCounter = 0;
        }

        //----------------- Leftover from Tou Code, what does this do? ----------------------------
        //OR, you could loop over each EEG channel and do some sort of frequency-domain processing from the FFT data
        float FFT_freq_Hz, FFT_value_uV;
        for (int Ichan=0; Ichan < nchan; Ichan++) {
            //loop over each new sample
            for (int Ibin=0; Ibin < fftBuff[Ichan].specSize(); Ibin++) {
                FFT_freq_Hz = fftData[Ichan].indexToFreq(Ibin);
                FFT_value_uV = fftData[Ichan].getBand(Ibin);
            }
        }
        //---------------------------------------------------------------------------------
    }

    class Motor_Widget {
        //variables
        boolean isTriggered = false;
        float upperThreshold = 25;        //default uV upper threshold value ... this will automatically change over time
        float lowerThreshold = 0;         //default uV lower threshold value ... this will automatically change over time
        int thresholdPeriod = 1250;       //number of packets
        int ourChan = 0;                  //channel being monitored ... "3 - 1" means channel 3 (with a 0 index)
        float myAverage = 0.0;            //this will change over time ... used for calculations below
        //prez related
        boolean switchTripped = false;
        int switchCounter = 0;
        float timeOfLastTrip = 0;
        float tripThreshold = 0.75;
        float untripThreshold = 0.5;
        //if writing to a serial port
        int output = 0;                   //value between 0-255 that is the relative position of the current uV average between the rolling lower and upper uV thresholds
        float output_normalized = 0;      //converted to between 0-1
        float output_adjusted = 0;        //adjusted depending on range that is expected on the other end, ie 0-255?
        boolean analogBool = true;        //Analog events?
        boolean digitalBool = true;       //Digital events?

        //these are the 4 variables affected by the dropdown menus
        float averagePeriod; // = 125;          //number of data packets to average over (250 = 1 sec)
        float acceptableLimitUV = 200.0;    //uV values above this limit are excluded, as a result of them almost certainly being noise...
        float creepSpeed = 0.99;
        float minRange = 20.0;

    };

    //============= TripSlider =============
    //=  Class for moving thresholds. Can  =
    //=  be dragged up and down, but lower =
    //=  thresholds cannot go above upper  =
    //=  thresholds (and visa versa).      =
    //======================================
    class TripSlider {
        //Fields
        int lx, ly;
        int boxx, boxy;
        int stretch;
        int wid;
        int len;
        int boxLen;
        boolean over;
        boolean press;
        boolean locked = false;
        boolean otherslocked = false;
        boolean trip;
        boolean drawHand;
        TripSlider[] others;
        color current_color = color(255, 255, 255);
        Motor_Widget parent;

        //Constructor
        TripSlider(int ix, int iy, float il, int iwid, int ilen, TripSlider[] o, boolean wastrip, Motor_Widget p) {
            lx = ix;
            ly = iy;
            boxLen = int(il);
            wid = iwid;
            len = ilen;
            boxx = lx - wid/2;
            //boxx = lx;
            boxy = ly-stretch - len/2;
            //boxy = ly;
            others = o;
            trip = wastrip;  //Boolean to distinguish between trip and untrip thresholds
            parent = p;
            //boxLen = 31;
        }

        //Called whenever thresholds are dragged
        void update(float tx, float ty) {
            // println("testing...");
            boxx = lx;
            //boxy = (wid + (ly/2)) - int(((wid + (ly/2)) - ly) * (float(stretch) / float(wid)));
            //boxy = ly + (ly - int( ly * (float(stretch) / float(wid)))) ;
            boxy = int(ly + stretch); //- stretch;

            for (int i=0; i<others.length; i++) {
                if (others[i].locked == true) {
                    otherslocked = true;
                    break;
                } else {
                    otherslocked = false;
                }
            }

            if (otherslocked == false) {
                overEvent(tx, ty);
                pressEvent();
            }

            if (press) {
                //Some of this may need to be refactored in order to support window resizing
                int mappedVal = int(mouseY - (ty+ly));
                if (!trip) stretch = lock(mappedVal, int(parent.untripThreshold * (boxLen)), boxLen);
                else stretch =  lock(mappedVal, 0, int(parent.tripThreshold * (boxLen)));

                if (mappedVal > boxLen && !trip) parent.tripThreshold = 1;
                else if (mappedVal > boxLen && trip) parent.untripThreshold = 1;
                else if (mappedVal < 0 && !trip) parent.tripThreshold = 0;
                else if (mappedVal < 0 && trip) parent.untripThreshold = 0;
                else if (!trip) parent.tripThreshold = float(mappedVal) / (boxLen);
                else if (trip) parent.untripThreshold = float(mappedVal) / (boxLen);
            }
        }

        //Checks if mouse is here
        void overEvent(float tx, float ty) {
            if (overRect(int(boxx + tx), int(boxy + ty), wid, len)) {
                over = true;
            } else {
                over = false;
            }
        }

        //Checks if mouse is pressed
        void pressEvent() {
            if (over && mousePressed || locked) {
                press = true;
                locked = true;
            } else {
                press = false;
            }
        }

        //Mouse was released
        void releaseEvent() {
            locked = false;
        }

        //Color selector and cursor setter
        void setColor() {
            if (over) {
                current_color = color(127, 134, 143);
                if (!drawHand) {
                    cursor(HAND);
                    drawHand = true;
                }
            } else {

                if (trip) {
                    current_color = color(0, 255, 0); //trip switch bar color
                } else {
                    current_color = color(255, 0, 0); //untrip switch bar color
                }

                if (drawHand) {
                    cursor(ARROW);
                    drawHand = false;
                }
            }
        }

        //Helper function to make setting default threshold values easier.
        //Expects a float as input (0.25 is 25%)
        void setStretchPercentage(float val) {
            stretch = lock(int(boxLen - ((boxLen) * val)), 0, boxLen);
        }

        //Displays the thresholds %%%%%
        void display(float tx, float ty, float tw, float tl) {
            lx = int(tx);
            ly = int(ty);
            wid = int(tw);
            boxLen = int(tl);

            fill(255);
            strokeWeight(1);
            stroke(bgColor);
            setColor();
            fill(current_color);
            rect(boxx, boxy, wid, len);

            // rect(lx, ly, wid, len);
        }

        //Check if the mouse is here
        boolean overRect(int lx, int ly, int twidth, int theight) {
            if (mouseX >= lx && mouseX <= lx+twidth &&
                mouseY >= ly && mouseY <= ly+theight) {

                return true;
            } else {
                return false;
            }
        }

        //Locks the threshold in place
        int lock(int val, int minv, int maxv) {
            return  min(max(val, minv), maxv);
        }
    };

    //===================== DIGITAL EVENTS =============================
    //=  Digital Events work by tripping certain thresholds, and then  =
    //=  untripping said thresholds. In order to use digital events    =
    //=  you will need to observe the switchCounter field in any       =
    //=  given channel. Check out the OpenBionics Switch Example       =
    //=  in the process() function above to get an idea of how to do   =
    //=  this. It is important that your observation of switchCounter  =
    //=  is done in the process() function AFTER the Digital Events    =
    //=  are evoked.                                                   =
    //=                                                                =
    //=  This system supports both digital and analog events           =
    //=  simultaneously and seperated.                                 =
    //==================================================================

    //Channel 1 Event
    void digitalEventChan0(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 2 Event
    void digitalEventChan1(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 3 Event
    void digitalEventChan2(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 4 Event
    void digitalEventChan3(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 5 Event
    void digitalEventChan4(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 6 Event
    void digitalEventChan5(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 7 Event
    void digitalEventChan6(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 8 Event
    void digitalEventChan7(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 9 Event
    void digitalEventChan8(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 10 Event
    void digitalEventChan9(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 11 Event
    void digitalEventChan10(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 12 Event
    void digitalEventChan11(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 13 Event
    void digitalEventChan12(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 14 Event
    void digitalEventChan13(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 15 Event
    void digitalEventChan14(Motor_Widget cfc) {
        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //Channel 16 Event
    void digitalEventChan15(Motor_Widget cfc) {

        //Local instances of Motor_Widget fields
        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;

        //Custom waiting threshold
        int timeToWaitThresh = 750;

        if (output_normalized >= tripThreshold && !switchTripped && millis() - timeOfLastTrip >= timeToWaitThresh) {
            //Tripped
            cfc.switchTripped = true;
            cfc.timeOfLastTrip = millis();
            cfc.switchCounter++;
        }
        if (switchTripped && output_normalized <= untripThreshold) {
            //Untripped
            cfc.switchTripped = false;
        }
    }

    //===================== ANALOG EVENTS ===========================
    //=  Analog events are a big more complicated than digital      =
    //=  events. In order to use analog events you must map the     =
    //=  output_normalized value to whatver minimum and maximum     =
    //=  you'd like and then write that to the serialOutEMG.        =
    //=                                                             =
    //=  Check out analogEventChan0() for the OpenBionics analog    =
    //=  event example to get an idea of how to use analog events.  =
    //===============================================================

    //Channel 1 Event
    void analogEventChan0(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;


        //================= OpenBionics Analog Movement Example =======================
        if (serialOutEMG != null) {
            //println("Output normalized: " + int(map(output_normalized, 0, 1, 0, 100)));
            if (int(map(output_normalized, 0, 1, 0, 100)) > 10) {
                serialOutEMG.write("G0P" + int(map(output_normalized, 0, 1, 0, 100)));
                delay(10);
            } else serialOutEMG.write("G0P0");
        }
    }

    //Channel 2 Event
    void analogEventChan1(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 3 Event
    void analogEventChan2(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 4 Event
    void analogEventChan3(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 5 Event
    void analogEventChan4(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 6 Event
    void analogEventChan5(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 7 Event
    void analogEventChan6(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 8 Event
    void analogEventChan7(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 9 Event
    void analogEventChan8(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 10 Event
    void analogEventChan9(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 11 Event
    void analogEventChan10(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 12 Event
    void analogEventChan11(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 13 Event
    void analogEventChan12(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 14 Event
    void analogEventChan13(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 15 Event
    void analogEventChan14(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }

    //Channel 16 Event
    void analogEventChan15(Motor_Widget cfc) {

        float output_normalized = cfc.output_normalized;
        float tripThreshold = cfc.tripThreshold;
        float untripThreshold = cfc.untripThreshold;
        boolean switchTripped = cfc.switchTripped;
        float timeOfLastTrip = cfc.timeOfLastTrip;
    }
};

void ChannelSelection(int n) {
    w_emg.currChannel = n;
    closeAllDropdowns();
}

void EventType(int n) {
    if (n == 0) w_emg.events[w_emg.currChannel] = true;
    else if (n == 1) w_emg.events[w_emg.currChannel] = false;
    closeAllDropdowns();
}

void BaudRate(int n) {
    if (!w_emg.baudList.get(n).equals("NONE")) w_emg.theBaud = Integer.parseInt(w_emg.baudList.get(n));
    closeAllDropdowns();
}

void SerialSelection(int n) {
    if (!w_emg.serList.get(n).equals("NONE")) w_emg.theSerial = w_emg.serList.get(n);
    closeAllDropdowns();
}
