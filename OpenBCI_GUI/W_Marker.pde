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
            //Create marker buttons
            //Marker number is i + 1 because marker numbers start at 1, not 0. Otherwise, will throw BrainFlow error.
            markerButtons[i] = createMarkerButton(i + 1, x + 10 + (i * MARKER_BUTTON_WIDTH), y + 10);
        }
    }

    private Button createMarkerButton(int markerNumber, int _x, int _y) {
        Button newButton = createButton(localCP5, "markerButton" + markerNumber, "Insert Marker " + markerNumber, _x, _y, 125, navH - 3, p5, 12, colorNotPressed, OPENBCI_DARKBLUE);
        newButton.setBorderColor(OBJECT_BORDER_GREY);
        newButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                insertMarkerFromKeyboardOrButton(markerNumber);
            }
        });
        newButton.setDescription("Click to insert marker " + markerNumber + " into the data stream.");
        return newButton;
    }

    //Called in Interactivity.pde when a key is pressed
    //Returns true if a marker key was pressed, false otherwise
    //Can be used to check for marker key presses even when this widget is not active
    public boolean checkForMarkerKeyPress(char keyPress) {
        switch (keyPress) {
            case 'z':
                insertMarkerFromKeyboardOrButton(1);
                return true;
            case 'x':
                insertMarkerFromKeyboardOrButton(2);
                return true;
            case 'c':
                insertMarkerFromKeyboardOrButton(3);
                return true;
            case 'v':
                insertMarkerFromKeyboardOrButton(4);
                return true;
            default:
                return false;
        }
    }

    private void insertMarkerFromKeyboardOrButton(int markerNumber) {
        int markerChannel = ((Board)currentBoard).getMarkerChannel();
        if (markerChannel != -1) {
            ((Board)currentBoard).insertMarker(markerNumber);
        }
    }

};
