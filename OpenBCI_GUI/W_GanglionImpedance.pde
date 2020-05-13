
////////////////////////////////////////////////////
//
//    W_template.pde (ie "Widget Template")
//
//    This is a Template Widget, intended to be used as a starting point for OpenBCI Community members that want to develop their own custom widgets!
//    Good luck! If you embark on this journey, please let us know. Your contributions are valuable to everyone!
//
//    Created by: Conor Russomanno, November 2016
//
///////////////////////////////////////////////////,


class W_GanglionImpedance extends Widget {
    Button startStopCheck;
    int padding = 24;

    W_GanglionImpedance(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        startStopCheck = new Button (x + padding, y + padding, 200, navHeight, "Start Impedance Check", 12);
        startStopCheck.setFont(p4, 14);
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        pushStyle();

        startStopCheck.draw();

        //divide by 2 ... we do this assuming that the D_G (driven ground) electrode is "comprable in impedance" to the electrode being used.
        fill(bgColor);
        textFont(p4, 14);

        try {
            BoardGanglion ganglion = (BoardGanglion)currentBoard;
            if (!ganglion.isCheckingImpedance()) {
                return;
            }

            List<double[]> data = ganglion.getData(1);
            int resistanceChannels[] = BoardShim.get_resistance_channels(ganglion.getBoardIdInt());

            for(int i = 0; i < resistanceChannels.length; i++){
                String toPrint;
                float adjustedImpedance = (float)data.get(0)[resistanceChannels[i]]/2.0;
                if(i == 0) {
                    toPrint = "Reference Impedance \u2248 " + adjustedImpedance + " k\u2126";
                } else {
                    toPrint = "Channel[" + i + "] Impedance \u2248 " + adjustedImpedance + " k\u2126";
                }
                text(toPrint, x + padding + 40, y + padding*2 + 12 + startStopCheck.but_dy + padding*(i));

                pushStyle();
                stroke(bgColor);
                //change the fill color based on the signal quality...
                if(adjustedImpedance <= 0){ //no data yet...
                    fill(255);
                } else if(adjustedImpedance > 0 && adjustedImpedance <= 10){ //very good signal quality
                    fill(49, 113, 89); //dark green
                } else if(adjustedImpedance > 10 && adjustedImpedance <= 50){ //good signal quality
                    fill(184, 220, 105); //yellow green
                } else if(adjustedImpedance > 50 && adjustedImpedance <= 100){ //acceptable signal quality
                    fill(221, 178, 13); //yellow
                } else if(adjustedImpedance > 100 && adjustedImpedance <= 150){ //questionable signal quality
                    fill(253, 94, 52); //orange
                } else if(adjustedImpedance > 150){ //bad signal quality
                    fill(224, 56, 45); //red
                }

                ellipse(x + padding + 10, y + padding*2 + 7 + startStopCheck.but_dy + padding*(i), padding/2, padding/2);
                popStyle();
            }

            image(loadingGIF_blue, x + padding + startStopCheck.but_dx + 15, y + padding - 8, 40, 40);
            popStyle();
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)
        startStopCheck.setPos(x + padding, y + padding);
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        if(startStopCheck.isMouseHere()){
            startStopCheck.setIsActive(true);
        }
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

        // todo[brainflow] needs just a little more work to reach feature parity, see comment below
        if (startStopCheck.isActive && startStopCheck.isMouseHere()) {
            if (currentBoard instanceof BoardGanglion) {
                // ganglion is the only board which can check impedance, so we don't have an interface for it.
                // if that changes in the future, consider making an interface.
                BoardGanglion ganglionBoard = (BoardGanglion)currentBoard;
                if (!ganglionBoard.isCheckingImpedance()) {
                    // if is running... stopRunning and switch the state of the Start/Stop button back to Data Stream stopped
                    //stopRunning();
                    // We need to either stop the time series data, or allow it to scroll, like currently. 
                    // the values in time series are not meaningful when Impedance check is active
                    topNav.stopButton.setString(stopButton_pressToStart_txt);
                    topNav.stopButton.setColorNotPressed(color(184, 220, 105));
                    println("Starting Ganglion impedance check...");
                    //Start impedance check
                    ganglionBoard.setCheckingImpedance(true);
                    startStopCheck.but_txt = "Stop Impedance Check";
                } else {
                    //Stop impedance check
                    ganglionBoard.setCheckingImpedance(false);
                    //ganglion.impedanceStop();
                    startStopCheck.but_txt = "Start Impedance Check";
                }
            }
        }
        startStopCheck.setIsActive(false);
    }
};
