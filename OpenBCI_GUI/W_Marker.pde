//////////////////////////////////////////////////////
//                                                  //
//                  W_Marker.pde                    //
//                                                  //
//    Created by: Richard Waltman, August 2023      //
//    Purpose: Add software markers to data         //
//    Marker Shortcuts: z x c v                     //
//                                                  //
//////////////////////////////////////////////////////

class W_Marker extends Widget {

    private ControlP5 localCP5;

    final int MARKER_BUTTON_WIDTH = 125;
    final int NUMBER_OF_MARKER_BUTTONS = 4;
    private Button[] markerButtons = new Button[NUMBER_OF_MARKER_BUTTONS];

    W_Marker(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        //Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false);

        createMarkerButtons();
       
    }

    public void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    }

    public void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //This draws all cp5 objects in the local instance
        localCP5.draw();
    }

    public void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        //Very important to allow users to interact with objects after app resize        
        localCP5.setGraphics(ourApplet, 0, 0);

        //Update positions of marker buttons
        for (int i = 0; i < NUMBER_OF_MARKER_BUTTONS; i++) {
            markerButtons[i].setPosition(x + 10 + (i * MARKER_BUTTON_WIDTH), y + 10);
        }

    }

    private void createMarkerButtons() {
        for (int i = 0; i < NUMBER_OF_MARKER_BUTTONS; i++) {
            markerButtons[i] = createMarkerButton(i, x + 10 + (i * MARKER_BUTTON_WIDTH), y + 10);
        }
    }

    private Button createMarkerButton(int markerNumber, int _x, int _y) {
        Button newButton = createButton(localCP5, "markerButton" + markerNumber, "Insert Marker " + markerNumber, _x, _y, 125, navH - 3, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        newButton.setBorderColor(OBJECT_BORDER_GREY);
        newButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                insertMarker(markerNumber);
            }
        });
        newButton.setDescription("Click to insert marker " + markerNumber + " into the data stream.");
        return newButton;
    }

    //Called in Interactivity.pde when a key is pressed
    public boolean checkForMarkerKeyPress(char keyPress) {
        switch (keyPress) {
            case 'z':
                insertMarker(0);
                return true;
            case 'x':
                insertMarker(1);
                return true;
            case 'c':
                insertMarker(2);
                return true;
            case 'v':
                insertMarker(3);
                return true;
            default:
                return false;
        }
    }

    private void insertMarker(int markerNumber) {
        int markerChannel = ((BoardBrainFlow)currentBoard).getMarkerChannel();
        if (markerChannel != -1) {
            ((BoardBrainFlow)currentBoard).insertMarker(markerNumber);
        }
        println("Marker " + markerNumber + " inserted.");
    }

};
