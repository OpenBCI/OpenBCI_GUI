
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

    GPlot bp_plot;

    W_BandPower(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //This is the protocol for setting up dropdowns.
        //Note that these 3 dropdowns correspond to the 3 global functions below
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        // addDropdown("Dropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
        // addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
        // addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);
        addDropdown("Smoothing", "Smooth", Arrays.asList(settings.fftSmoothingArray), smoothFac_ind); //smoothFac_ind is a global variable at the top of W_HeadPlot.pde
        addDropdown("UnfiltFilt", "Filters?", Arrays.asList(settings.fftFilterArray), settings.fftFilterSave);


        // Setup for the BandPower plot
        bp_plot = new GPlot(_parent, x, y-navHeight, w, h+navHeight);
        // bp_plot.setPos(x, y+navHeight);
        bp_plot.setDim(w, h);
        bp_plot.setLogScale("y");
        bp_plot.setYLim(0.1, 100);
        bp_plot.setXLim(0, 5);
        bp_plot.getYAxis().setNTicks(9);
        bp_plot.getXAxis().setNTicks(0);
        bp_plot.getTitle().setTextAlignment(LEFT);
        bp_plot.getTitle().setRelativePos(0);
        bp_plot.getYAxis().getAxisLabel().setText("Headwide Power — (uV)^2 / Hz");
        bp_plot.getXAxis().setAxisLabelText("EEG Power Bands");
        bp_plot.startHistograms(GPlot.VERTICAL);
        bp_plot.getHistogram().setDrawLabels(true);

        //setting border of histograms to match BG
        bp_plot.getHistogram().setLineColors(new color[]{
            color(245), color(245), color(245), color(245), color(245)
          }
        );

        //setting bg colors of histogram bars to match the color scheme of the channel colors w/ an opacity of 150/255
        bp_plot.getHistogram().setBgColors(new color[] {
                color((int)channelColors[2], 150), color((int)channelColors[1], 150),
                color((int)channelColors[3], 150), color((int)channelColors[4], 150), color((int)channelColors[6], 150)

            }
        );
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        GPointsArray bp_points = new GPointsArray(dataProcessing.headWidePower.length);
        bp_points.add(DELTA + 0.5, dataProcessing.headWidePower[DELTA], "DELTA");
        bp_points.add(THETA + 0.5, dataProcessing.headWidePower[THETA], "THETA");
        bp_points.add(ALPHA + 0.5, dataProcessing.headWidePower[ALPHA], "ALPHA");
        bp_points.add(BETA + 0.5, dataProcessing.headWidePower[BETA], "BETA");
        bp_points.add(GAMMA + 0.5, dataProcessing.headWidePower[GAMMA], "GAMMA");

        bp_plot.setPoints(bp_points);
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        pushStyle();

        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        // Draw the third plot
        bp_plot.beginDraw();
        bp_plot.drawBackground();
        bp_plot.drawBox();
        bp_plot.drawXAxis();
        bp_plot.drawYAxis();
        bp_plot.drawHistograms();
        bp_plot.endDraw();

        //for this widget need to redraw the grey bar, bc the FFT plot covers it up...
        fill(200, 200, 200);
        rect(x, y - navHeight, w, navHeight); //button bar

        popStyle();

    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        bp_plot.setPos(x, y-navHeight);//update position
        bp_plot.setOuterDim(w, h+navHeight);//update dimensions
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    }
};
