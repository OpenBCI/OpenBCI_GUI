
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

    //----------CHANNEL SELECT INFRASTRUCTURE
    ControlP5 cp5_channelCheckboxes;   //ControlP5 for which channels to use
    CheckBox checkList;
    //draw checkboxes vars
    int numChecks = nchan;
    int offset;                      //offset on nav bar of checks
    int checkHeight = y0 + navH;
    //checkbox dropdown vars
    boolean channelSelectHover;
    boolean channelSelectPressed;
    List<Integer> activeChannels = new ArrayList<Integer>();

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

        //setup for checkboxes
        cp5_channelCheckboxes = new ControlP5(pApplet);

        int checkSize = navH - 4;
        offset = (navH - checkSize)/2;

        channelSelectHover = false;
        channelSelectPressed = false;
        checkList = cp5_channelCheckboxes.addCheckBox("channelList")
                              .setPosition(x + 5, y + offset)
                              .setSize(checkSize, checkSize)
                              .setItemsPerRow(numChecks)
                              .setSpacingColumn(13)
                              .setSpacingRow(2)
                              .setColorLabel(color(0)) //Set the color of the text label
                              .setColorForeground(color(120)) //checkbox color when mouse is hovering over it
                              .setColorBackground(color(150)) //checkbox background color
                              .setColorActive(color(57, 128, 204)) //checkbox color when active
                              ;


        for (int i = 0; i < numChecks; i++) {
          int chNum = i+1;
          cp5_channelCheckboxes.get(CheckBox.class, "channelList")
                        .addItem(String.valueOf(chNum), chNum)
                        ;

          checkList.getItem(i).setVisible(false);           //set invisible after adding items, so make sure they won't stay invisible
          checkList.activate(i);
          activeChannels.add(i);
        }

        cp5_channelCheckboxes.setAutoDraw(false);
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        float[] activePower = new float[nchan];

        for (int i = 0; i < 5; i++){
            float sum = 0;

            for (int j = 0; j < activeChannels.size(); j++){
                int chan = activeChannels.get(j);
                sum += dataProcessing.avgPowerInBins[chan][i];
                activePower[i] = sum/activeChannels.size();
            }
        }

        GPointsArray bp_points = new GPointsArray(dataProcessing.headWidePower.length);
        bp_points.add(DELTA + 0.5, activePower[DELTA], "DELTA");
        bp_points.add(THETA + 0.5, activePower[THETA], "THETA");
        bp_points.add(ALPHA + 0.5, activePower[ALPHA], "ALPHA");
        bp_points.add(BETA + 0.5, activePower[BETA], "BETA");
        bp_points.add(GAMMA + 0.5, activePower[GAMMA], "GAMMA");

        bp_plot.setPoints(bp_points);

        //Toggle open/closed the channel menu
        if (mouseX > (x + 57) && mouseX < (x + 67) && mouseY < (y - navH*0.25) && mouseY > (y - navH*0.65)) {
            channelSelectHover = true;
        } else {
            channelSelectHover = false;
        }

        //Update the active channels to include in data processing
        activeChannels.clear();
        for (int i = 0; i < numChecks; i++) {
            if(checkList.getState(i)){
                activeChannels.add(i);
            }
        }
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

        textSize(12);
        fill(0);
        text("Channels", x + 2, y - 6);

        if (!channelSelectPressed) {
            if(!channelSelectHover){
                fill(0);
            } else {
                fill(130);
            }
            triangle(x + 57.0, y - navH*0.65, x + 62.0, y - navH*0.25, x + 67.0, y - navH*0.65);
        } else {
            if(!channelSelectHover){
                fill(0);
            } else {
                fill(130);
            }
            triangle(x + 57.0, y - navH*0.25, x + 62.0, y - navH*0.65, x + 67.0, y - navH*0.25);
            fill(180);
            rect(x,y,w,navH);
        }
        pushStyle();

        cp5_channelCheckboxes.draw();
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        bp_plot.setPos(x, y-navHeight);//update position
        bp_plot.setOuterDim(w, h+navHeight);//update dimensions

        cp5_channelCheckboxes.setGraphics(pApplet, 0, 0);
        cp5_channelCheckboxes.get(CheckBox.class, "channelList").setPosition(x + 2, y + offset);
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

        if(!this.dropdownIsActive) {
            if (mouseX > (x + 57) && mouseX < (x + 67) && mouseY < (y - navH*0.25) && mouseY > (y - navH*0.65)) {
                channelSelectPressed = !channelSelectPressed;
                if(channelSelectPressed){
                    for (int i = 0; i < nchan; i++) {
                        checkList.getItem(i).setVisible(true);
                    }
                } else {
                    for (int i = 0; i < nchan; i++) {
                        checkList.getItem(i).setVisible(false);
                    }
                }
            }
        }
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    }
};
