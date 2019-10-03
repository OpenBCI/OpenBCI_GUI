
int navHeight = 22;

//========================================================================================
//=================              ADD NEW WIDGETS HERE            =========================
//========================================================================================
/*
    Notes:
    - In this file all you have to do is MAKE YOUR WIDGET GLOBALLY, and then ADD YOUR WIDGET TO WIDGETS OF WIDGETMANAGER in the setupWidgets() function below
    - the order in which they are added will effect the order in which they appear in the GUI and in the WidgetSelector dropdown menu of each widget
    - use the WidgetTemplate.pde file as a starting point for creating new widgets (also check out W_timeSeries.pde, W_fft.pde, and W_HeadPlot.pde)
*/

// MAKE YOUR WIDGET GLOBALLY
W_timeSeries w_timeSeries;
W_fft w_fft;
W_Networking w_networking;
W_BandPower w_bandPower;
W_Accelerometer w_accelerometer;
W_GanglionImpedance w_ganglionImpedance;
W_HeadPlot w_headPlot;
W_template w_template1;
W_emg w_emg;
W_openBionics w_openbionics;
W_Focus w_focus;
W_PulseSensor w_pulsesensor;
W_AnalogRead w_analogRead;
W_DigitalRead w_digitalRead;
W_MarkerMode w_markermode;
W_playback w_playback;
W_SSVEP w_ssvep;

//ADD YOUR WIDGET TO WIDGETS OF WIDGETMANAGER
void setupWidgets(PApplet _this, ArrayList<Widget> w){
    // println("  setupWidgets start -- " + millis());

    //Widget_0
    w_timeSeries = new W_timeSeries(_this);
    w_timeSeries.setTitle("Time Series");
    addWidget(w_timeSeries, w);
    // println("  setupWidgets time series -- " + millis());

    //Widget_1
    w_fft = new W_fft(_this);
    w_fft.setTitle("FFT Plot");
    addWidget(w_fft, w);
    // println("  setupWidgets fft -- " + millis());

    //Widget_2
    w_accelerometer = new W_Accelerometer(_this);
    w_accelerometer.setTitle("Accelerometer");
    addWidget(w_accelerometer, w);

    //only instantiate this widget if you are using a Ganglion board for live streaming
    if(nchan == 4 && eegDataSource == DATASOURCE_GANGLION){
        //If using Ganglion, this is Widget_3
        w_ganglionImpedance = new W_GanglionImpedance(_this);
        w_ganglionImpedance.setTitle("Ganglion Signal");
        addWidget(w_ganglionImpedance, w);
    }

    if(eegDataSource == DATASOURCE_PLAYBACKFILE){
        //Playback Widget_3
        w_playback = new W_playback(_this);
        w_playback.setTitle("Playback History");
        addWidget(w_playback, w);
    }

    //Cyton/Synthetic Widget_3, Ganglion/Playback Widget_4
    w_networking = new W_Networking(_this);
    w_networking.setTitle("Networking");
    addWidget(w_networking, w);

    //Cyton/Synthetic Widget_4, Ganglion/Playback Widget_5
    w_bandPower = new W_BandPower(_this);
    w_bandPower.setTitle("Band Power");
    addWidget(w_bandPower, w);
    // println("  setupWidgets band power -- " + millis());

    //Cyton/Synthetic Widget_5, Ganglion/Playback Widget_6
    w_headPlot = new W_HeadPlot(_this);
    w_headPlot.setTitle("Head Plot");
    addWidget(w_headPlot, w);
    // println("  setupWidgets head plot -- " + millis());

    //Cyton/Synthetic Widget_6, Ganglion/Playback Widget_7
    w_emg = new W_emg(_this);
    w_emg.setTitle("EMG");
    addWidget(w_emg, w);
    // println("  setupWidgets emg -- " + millis());

    //Cyton/Synthetic Widget_7, Ganglion/Playback Widget_8
    w_focus = new W_Focus(_this);
    w_focus.setTitle("Focus Widget");
    addWidget(w_focus, w);
    // println("  setupWidgets focus widget -- " + millis());

    w_ssvep = new W_SSVEP(_this);
    w_ssvep.setTitle("SSVEP_beta");
    addWidget(w_ssvep, w);

    //only instantiate these widgets if you are using a Cyton board for live streaming
    if(eegDataSource == DATASOURCE_CYTON){
        //Cyton Widget_8
        w_pulsesensor = new W_PulseSensor(_this);
        w_pulsesensor.setTitle("Pulse Sensor");
        addWidget(w_pulsesensor, w);
        // println("  setupWidgets pulse sensor -- " + millis());

        //Cyton Widget_9
        w_digitalRead = new W_DigitalRead(_this);
        w_digitalRead.setTitle("Digital Read");
        addWidget(w_digitalRead, w);

        //Cyton Widget_10
        w_analogRead = new W_AnalogRead(_this);
        w_analogRead.setTitle("Analog Read");
        addWidget(w_analogRead, w);

        //Cyton Widget_11
        w_markermode = new W_MarkerMode(_this);
        w_markermode.setTitle("Marker Mode");
        addWidget(w_markermode, w);
    }

    
    //Cyton Widget_12, Synthetic Widget_8, Ganglion/Playback Widget_9
    //DEVELOPERS: Here is an example widget with the essentials/structure in place
    w_template1 = new W_template(_this);
    w_template1.setTitle("Widget Template 1");
    addWidget(w_template1, w);

    // w_template2 = new W_template(_this);
    // w_template2.setTitle("Widget Template 2");
    // addWidget(w_template2, w);

    // w_openbionics = new W_OpenBionics(_this);
    // w_openbionics.setTitle("OpenBionics");
    // addWidget(w_openbionics,w);

    // w_template3 = new W_template(_this);
    // w_template3.setTitle("LSL Stream");
    // addWidget(w_template3, w);

}

//========================================================================================
//========================================================================================
//========================================================================================

WidgetManager wm;
boolean wmVisible = true;
CColor cp5_colors;

//Channel Colors -- Defaulted to matching the OpenBCI electrode ribbon cable
color[] channelColors = {
    color(129, 129, 129),
    color(124, 75, 141),
    color(54, 87, 158),
    color(49, 113, 89),
    color(221, 178, 13),
    color(253, 94, 52),
    color(224, 56, 45),
    color(162, 82, 49)
};


class WidgetManager{

    //this holds all of the widgets ... when creating/adding new widgets, we will add them to this ArrayList (below)
    ArrayList<Widget> widgets;
    ArrayList<String> widgetOptions; //List of Widget Titles, used to populate cp5 widgetSelector dropdown of all widgets

    //Variables for
    int currentContainerLayout; //this is the Layout structure for the main body of the GUI ... refer to [PUT_LINK_HERE] for layouts/numbers image
    ArrayList<Layout> layouts = new ArrayList<Layout>();  //this holds all of the different layouts ...

    public boolean isWMInitialized = false;
    private boolean visible = true;
    private boolean updating = true;

    WidgetManager(PApplet _this){
        widgets = new ArrayList<Widget>();
        widgetOptions = new ArrayList<String>();
        isWMInitialized = false;

        //DO NOT re-order the functions below
        setupLayouts();
        setupWidgets(_this, widgets);
        setupWidgetSelectorDropdowns();

        if(nchan == 4 && eegDataSource == DATASOURCE_GANGLION) {
            currentContainerLayout = 1;
            settings.currentLayout = 1; // used for save/load settings
            setNewContainerLayout(currentContainerLayout); //sets and fills layout with widgets in order of widget index, to reorganize widget index, reorder the creation in setupWidgets()
        } else if (eegDataSource == DATASOURCE_PLAYBACKFILE) {
            currentContainerLayout = 1;
            settings.currentLayout = 1; // used for save/load settings
            setNewContainerLayout(currentContainerLayout); //sets and fills layout with widgets in order of widget index, to reorganize widget index, reorder the creation in setupWidgets()
        } else {
            currentContainerLayout = 4; //default layout ... tall container left and 2 shorter containers stacked on the right
            settings.currentLayout = 4; // used for save/load settings
            setNewContainerLayout(currentContainerLayout); //sets and fills layout with widgets in order of widget index, to reorganize widget index, reorder the creation in setupWidgets()
        }

        delay(1000);

        isWMInitialized = true;
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
    void setupWidgetSelectorDropdowns(){
        //create the widgetSelector dropdown of each widget
        //println("widgets.size() = " + widgets.size());
        //create list of WidgetTitles.. we will use this to populate the dropdown (widget selector) of each widget
        for(int i = 0; i < widgets.size(); i++){
            widgetOptions.add(widgets.get(i).widgetTitle);
        }
        //println("widgetOptions.size() = " + widgetOptions.size());
        for(int i = 0; i <widgetOptions.size(); i++){
            widgets.get(i).setupWidgetSelectorDropdown(widgetOptions);
            widgets.get(i).setupNavDropdowns();
        }
    }

    void update(){
        // if(visible && updating){
        if(visible){
            for(int i = 0; i < widgets.size(); i++){
                if(widgets.get(i).isActive){
                    widgets.get(i).update();
                    //if the widgets are not mapped to containers correctly, remap them..
                    // if(widgets.get(i).x != container[widgets.get(i).currentContainer].x || widgets.get(i).y != container[widgets.get(i).currentContainer].y || widgets.get(i).w != container[widgets.get(i).currentContainer].w || widgets.get(i).h != container[widgets.get(i).currentContainer].h){
                    if(widgets.get(i).x0 != (int)container[widgets.get(i).currentContainer].x || widgets.get(i).y0 != (int)container[widgets.get(i).currentContainer].y || widgets.get(i).w0 != (int)container[widgets.get(i).currentContainer].w || widgets.get(i).h0 != (int)container[widgets.get(i).currentContainer].h){
                        screenResized();
                        println("WidgetManager.pde: Remapping widgets to container layout...");
                    }
                }
            }
        }
    }

    void draw(){
        if(visible){
            for(int i = 0; i < widgets.size(); i++){
                if(widgets.get(i).isActive){
                    pushStyle();
                    widgets.get(i).draw();
                    widgets.get(i).drawDropdowns();
                    popStyle();
                }else{
                    if(widgets.get(i).widgetTitle.equals("Networking")){
                        try{
                            w_networking.shutDown();
                        }catch (NullPointerException e){
                            println("WM:Networking_shutDown_Error: " + e);
                        }
                    }
                }
            }
        }
    }

    void screenResized(){
        for(int i = 0; i < widgets.size(); i++){
            widgets.get(i).screenResized();
        }
    }

    void mousePressed(){
        for(int i = 0; i < widgets.size(); i++){
            if(widgets.get(i).isActive){
                widgets.get(i).mousePressed();
            }

        }
    }

    void mouseReleased(){
        for(int i = 0; i < widgets.size(); i++){
            if(widgets.get(i).isActive){
                widgets.get(i).mouseReleased();
            }
        }
    }

    void mouseDragged(){
        for(int i = 0; i < widgets.size(); i++){
            if(widgets.get(i).isActive){
                widgets.get(i).mouseDragged();
            }
        }
    }

    void setupLayouts(){
        //refer to [PUT_LINK_HERE] for layouts/numbers image
        //note that the order you create/add these layouts matters... if you reorganize these, the LayoutSelector will be out of order
        layouts.add(new Layout(new int[]{5})); //layout 1
        layouts.add(new Layout(new int[]{1,3,7,9})); //layout 2
        layouts.add(new Layout(new int[]{4,6})); //layout 3
        layouts.add(new Layout(new int[]{2,8})); //etc.
        layouts.add(new Layout(new int[]{4,3,9}));
        layouts.add(new Layout(new int[]{1,7,6}));
        layouts.add(new Layout(new int[]{1,3,8}));
        layouts.add(new Layout(new int[]{2,7,9}));
        layouts.add(new Layout(new int[]{4,11,12,13,14}));
        layouts.add(new Layout(new int[]{4,15,16,17,18}));
        layouts.add(new Layout(new int[]{1,7,11,12,13,14}));
        layouts.add(new Layout(new int[]{1,7,15,16,17,18}));
    }

    void printLayouts(){
        for(int i = 0; i < layouts.size(); i++){
            println("WM:printLayouts: " + layouts.get(i));
            String layoutString = "";
            for(int j = 0; j < layouts.get(i).myContainers.length; j++){
                // println("WM:layoutContainers: " + layouts.get(i).myContainers[j]);
                layoutString += layouts.get(i).myContainers[j].x + ", ";
                layoutString += layouts.get(i).myContainers[j].y + ", ";
                layoutString += layouts.get(i).myContainers[j].w + ", ";
                layoutString += layouts.get(i).myContainers[j].h;
            }
            println("WM:printLayouts: " + layoutString);
        }
    }

    void setNewContainerLayout(int _newLayout){

        //find out how many active widgets we need...
        int numActiveWidgetsNeeded = layouts.get(_newLayout).myContainers.length;
        //calculate the number of current active widgets & keep track of which widgets are active
        int numActiveWidgets = 0;
        // ArrayList<int> activeWidgets = new ArrayList<int>();
        for(int i = 0; i < widgets.size(); i++){
            if(widgets.get(i).isActive){
                numActiveWidgets++; //increment numActiveWidgets
                // activeWidgets.add(i); //keep track of the active widget
            }
        }

        if(numActiveWidgets > numActiveWidgetsNeeded){ //if there are more active widgets than needed
            //shut some down
            int numToShutDown = numActiveWidgets - numActiveWidgetsNeeded;
            int counter = 0;
            println("WM: Powering " + numToShutDown + " widgets down, and remapping.");
            for(int i = widgets.size()-1; i >= 0; i--){
                if(widgets.get(i).isActive && counter < numToShutDown){
                    verbosePrint("WM: Deactivating widget [" + i + "]");
                    widgets.get(i).isActive = false;
                    counter++;
                }
            }

            //and map active widgets
            counter = 0;
            for(int i = 0; i < widgets.size(); i++){
                if(widgets.get(i).isActive){
                    widgets.get(i).setContainer(layouts.get(_newLayout).containerInts[counter]);
                    counter++;
                }
            }

        } else if(numActiveWidgetsNeeded > numActiveWidgets){ //if there are less active widgets than needed
            //power some up
            int numToPowerUp = numActiveWidgetsNeeded - numActiveWidgets;
            int counter = 0;
            verbosePrint("WM: Powering " + numToPowerUp + " widgets up, and remapping.");
            for(int i = 0; i < widgets.size(); i++){
                if(!widgets.get(i).isActive && counter < numToPowerUp){
                    verbosePrint("WM: Activating widget [" + i + "]");
                    widgets.get(i).isActive = true;
                    counter++;
                }
            }

            //and map active widgets
            counter = 0;
            for(int i = 0; i < widgets.size(); i++){
                if(widgets.get(i).isActive){
                    widgets.get(i).setContainer(layouts.get(_newLayout).containerInts[counter]);
                    // widgets.get(i).screenResized(); // do this to make sure the container is updated
                    counter++;
                }
            }

        } else{ //if there are the same amount
            //simply remap active widgets
            verbosePrint("WM: Remapping widgets.");
            int counter = 0;
            for(int i = 0; i < widgets.size(); i++){
                if(widgets.get(i).isActive){
                    widgets.get(i).setContainer(layouts.get(_newLayout).containerInts[counter]);
                    counter++;
                }
            }
        }
    }
};

//this is a global function for adding new widgets--and their children (timeSeries, FFT, headPlot, etc.)--to the WidgetManager's widget ArrayList
void addWidget(Widget myNewWidget, ArrayList<Widget> w){
    w.add(myNewWidget);
}

//the Layout class is an orgnanizational tool ... a layout consists of a combination of containers ... refer to Container.pde
class Layout{

    Container[] myContainers;
    int[] containerInts;

    Layout(int[] _myContainers){ //when creating a new layout, you pass in the integer #s of the containers you want as part of the layout ... so if I pass in the array {5}, my layout is 1 container that takes up the whole GUI body
        //constructor stuff
        myContainers = new Container[_myContainers.length]; //make the myContainers array equal to the size of the incoming array of ints
        containerInts = new int[_myContainers.length];
        for(int i = 0; i < _myContainers.length; i++){
            myContainers[i] = container[_myContainers[i]];
            containerInts[i] = _myContainers[i];
        }
    }

    Container getContainer(int _numContainer){
        if(_numContainer < myContainers.length){
            return myContainers[_numContainer];
        } else{
            println("WM: Tried to return a non-existant container...");
            return myContainers[myContainers.length-1];
        }
    }
};
