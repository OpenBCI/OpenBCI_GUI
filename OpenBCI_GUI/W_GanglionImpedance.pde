
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

        // todo[brainflow] do smth with it
        try {
            //remember to refer to x,y,w,h which are the positioning variables of the Widget class
            pushStyle();

            startStopCheck.draw();

            //divide by 2 ... we do this assuming that the D_G (driven ground) electrode is "comprable in impedance" to the electrode being used.
            fill(bgColor);
            textFont(p4, 14);
            for(int i = 0; i < data_elec_imp_ohm.length; i++){
                String toPrint;
                float adjustedImpedance = data_elec_imp_ohm[i]/2.0;
                if(i == 0){
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

            // todo[brainflow] minor detail
            /*
            if(isCheckingImpedance()){
                image(loadingGIF_blue, x + padding + startStopCheck.but_dx + 15, y + padding - 8, 40, 40);
            }
            */

            popStyle();
        } catch (Exception e) {
            e.printStackTrace();
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
        
        // todo[brainflow] needs just a little more work to reach feature parity
        if (startStopCheck.isActive && startStopCheck.isMouseHere()) {
            if (currentBoard instanceof BoardGanglion) {
                if (((BoardGanglion)currentBoard).isCheckingImpedance()) {
                    // if is running... stopRunning and switch the state of the Start/Stop button back to Data Stream stopped
                    //stopRunning(); // WE NEED TO STOP TIME SERIES DATA BUT KEEP DATA FLOW
                    topNav.stopButton.setString(stopButton_pressToStart_txt);
                    topNav.stopButton.setColorNotPressed(color(184, 220, 105));
                    println("Starting Ganglion impedance check...");
                    //Start impedance check
                    ((BoardGanglion)currentBoard).setImpedanceSettings(true);
                    startStopCheck.but_txt = "Stop Impedance Check"; 
                } else {
                    //Stop impedance check
                    ((BoardGanglion)currentBoard).setImpedanceSettings(false);
                    //ganglion.impedanceStop();
                    startStopCheck.but_txt = "Start Impedance Check";
                }
            }
        }
        startStopCheck.setIsActive(false);
    }
};

public float convertRawGanglionImpedanceToTarget(float _actual){
    //the following impedance adjustment calculations were derived using empirical values from resistors between 1,2,3,4,REF-->D_G
    float _target;

    //V1 -- more accurate for lower impedances (< 22kOhcm) -> y = 0.0034x^3 - 0.1443x^2 + 3.1324x - 10.59
    if(_actual <= 22){
        // _target = (0.0004)*(pow(_actual,3)) - (0.0262)*(pow(_actual,2)) + (1.8349)*(_actual) - 6.6006;
        _target = (0.0034)*(pow(_actual,3)) - (0.1443)*(pow(_actual,2)) + (3.1324)*(_actual) - 10.59;
    }
    //V2 -- more accurate for higher impedances (> 22kOhm) -> y = 0.000009x^4 - 0.001x^3 + 0.0409x^2 + 0.6445x - 1
    else {
        _target = (0.000009)*(pow(_actual,4)) - (0.001)*pow(_actual,3) + (0.0409)*(pow(_actual,2)) + (0.6445)*(pow(_actual,1)) - 1;
    }

    return _target;
}
