
////////////////////////////////////////////////////
//
//    W_BandPowers.pde
//
//    This is a band power visualization widget!
//    (Couldn't think up more)
//    This is for visualizing the power of each brainwave band: delta, theta, alpha, beta, gamma
//    Averaged over all channels
//
//    Created by: Wangshu Sun, May 2017
//
///////////////////////////////////////////////////,

class W_BandPower extends Widget {

    GPlot plot3;

    W_BandPower(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        // addDropdown("Dropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
        // addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
        // addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

        // Setup for the third plot
        plot3 = new GPlot(_parent, x, y-navHeight, w, h+navHeight);
        plot3.setPos(x, y);
        plot3.setDim(w, h);
        plot3.setLogScale("y");
        plot3.setYLim(0.1, 100);
        plot3.setXLim(0, 5);
        plot3.getYAxis().setNTicks(9);
        plot3.getTitle().setTextAlignment(LEFT);
        plot3.getTitle().setRelativePos(0);
        plot3.getYAxis().getAxisLabel().setText("(uV)^2 / Hz per channel");
        plot3.getYAxis().getAxisLabel().setTextAlignment(RIGHT);
        plot3.getYAxis().getAxisLabel().setRelativePos(1);
        // plot3.setPoints(points3);
        plot3.startHistograms(GPlot.VERTICAL);
        plot3.getHistogram().setDrawLabels(true);
        //plot3.getHistogram().setRotateLabels(true);
        plot3.getHistogram().setLineColors(new color[]{
            color(245), color(245), color(245), color(245), color(245)
          }
        );

        plot3.getHistogram().setBgColors(new color[] {
                // color(17,61,102), color(95, 127, 156),
                // color(81, 88, 98), color(241, 24, 25), color(255, 71, 27)

                // color(85,67,210, 100), color(211, 43, 142, 100),
                // color(233, 95, 42, 100), color(234, 152, 39, 100), color(239, 228, 124, 100)

                // color(43,90,230, 100), color(184, 43, 231, 100),
                // color(88, 231, 43, 100), color(231, 183, 43, 100), color(230, 43, 90, 100)

                color((int)channelColors[2], 150), color((int)channelColors[1], 150),
                color((int)channelColors[3], 150), color((int)channelColors[4], 150), color((int)channelColors[6], 150)

            }
        );
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        GPointsArray points3 = new GPointsArray(dataProcessing.headWidePower.length);
        points3.add(DELTA + 0.5, dataProcessing.headWidePower[DELTA], "DELTA");
        points3.add(THETA + 0.5, dataProcessing.headWidePower[THETA], "THETA");
        points3.add(ALPHA + 0.5, dataProcessing.headWidePower[ALPHA], "ALPHA");
        points3.add(BETA + 0.5, dataProcessing.headWidePower[BETA], "BETA");
        points3.add(GAMMA + 0.5, dataProcessing.headWidePower[GAMMA], "GAMMA");

        plot3.setPoints(points3);
        plot3.getTitle().setText("Band Power");
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        // Draw the third plot
        plot3.beginDraw();
        plot3.drawBackground();
        plot3.drawBox();
        plot3.drawYAxis();
        plot3.drawTitle();
        plot3.drawHistograms();
        plot3.endDraw();

    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        plot3.setPos(x, y-navHeight);//update position
        plot3.setOuterDim(w, h+navHeight);//update dimensions
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    }
};
