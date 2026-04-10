////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////                                                        ////
////    W_Template.pde (ie "Widget Template")               ////
////                                                        ////
////    This is a Template Widget, intended to be           ////
////    used as a starting point for OpenBCI                ////
////    Community members that want to develop              ////
////    their own custom widgets!                           ////
////                                                        ////
////    Good luck! If you embark on this journey,           ////
////    please let us know. Your contributions              ////
////    are valuable to everyone!                           ////
////                                                        ////
////    Created: Conor Russomanno, November 2016            ////
////    Refactored: Richard Waltman, April 2025             ////
////                                                        ////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

class W_Template extends WidgetWithSettings {
    
    // To see all core variables/methods of the Widget class, refer to Widget.pde
    // Put your custom variables here! Make sure to declare them as private by default.
    // In Java, if you need to access a variable from another class, you should create a getter/setter methods.
    // Example: public int getMyVariable(){ return myVariable; }
    // Example: public void setMyVariable(int myVariable){ this.myVariable = myVariable; }
    private ControlP5 localCP5;
    private Button widgetTemplateButton;

    W_Template() {
        // Call super() first! This sets up the widget and allows you to use all the methods in the Widget class.
        super();
        // Set the title of the widget. This is what will be displayed in the GUI.
        widgetTitle = "Widget Template";

        // Instantiate local cp5 for this box. This allows extra control of drawing cp5 elements specifically inside this class.
        localCP5 = new ControlP5(ourApplet);
        localCP5.setGraphics(ourApplet, 0,0);
        localCP5.setAutoDraw(false);

        createWidgetTemplateButton();
    }

    @Override
    protected void initWidgetSettings() {
        super.initWidgetSettings();
        // Widget Settings are used to store the state of the widget.
        // This is where you can set the default values for your dropdowns and other settings.
        widgetSettings.set(TemplateDropdown1.class, TemplateDropdown1.ITEM_A)
                    .set(TemplateDropdown2.class, TemplateDropdown2.ITEM_C)
                    .set(TemplateDropdown3.class, TemplateDropdown3.ITEM_F)
                    .saveDefaults();
        
        // This is the protocol for setting up dropdowns.
        // Note that these 3 dropdowns correspond to the 3 global functions below.
        // You just need to make sure the "id" (the 1st String) has the same name as the corresponding function.
        // Arguments: Class, String id, String label
        initDropdown(TemplateDropdown1.class, "widgetTemplateDropdown1", "Drop 1");
        initDropdown(TemplateDropdown2.class, "widgetTemplateDropdown2", "Drop 2");
        initDropdown(TemplateDropdown3.class, "widgetTemplateDropdown3", "Drop 3");
    }

    @Override
    protected void applySettings() {
        updateDropdownLabel(TemplateDropdown1.class, "widgetTemplateDropdown1");
        updateDropdownLabel(TemplateDropdown2.class, "widgetTemplateDropdown2");
        updateDropdownLabel(TemplateDropdown3.class, "widgetTemplateDropdown3");
    }

    public void update(){
        super.update();

        // put your code here...
    }

    public void draw(){
        super.draw();

        // remember to refer to x,y,w,h which are the positioning variables of the Widget class

        // This draws all cp5 objects in the local instance
        localCP5.draw();
    }

    public void screenResized(){
        super.screenResized();

        // Very important to allow users to interact with objects after app resize        
        localCP5.setGraphics(ourApplet, 0, 0);

        // We need to set the position of our Cp5 object after the screen is resized
        widgetTemplateButton.setPosition(x + w/2 - widgetTemplateButton.getWidth()/2, y + h/2 - widgetTemplateButton.getHeight()/2);

    }

    public void mousePressed(){
        super.mousePressed();
        // Since GUI v5, these methods should not really be used.
        // Instead, use ControlP5 objects and callbacks. 
        // Example: createWidgetTemplateButton() found below
    }

    public void mouseReleased(){
        super.mouseReleased();
        // Since GUI v5, these methods should not really be used.
    }

    // When creating new UI objects, follow this rough pattern.
    // Using custom methods like this allows us to condense the code required to create new objects.
    // You can find more detailed examples in the Control Panel, where there are many UI objects with varying functionality.
    private void createWidgetTemplateButton() {
        // This is a generalized createButton method that allows us to save code by using a few patterns and method overloading
        widgetTemplateButton = createButton(localCP5, "widgetTemplateButton", "Design Your Own Widget!", x + w/2, y + h/2, 200, NAV_HEIGHT, p4, 14, colorNotPressed, OPENBCI_DARKBLUE);
        // Set the border color explicitely
        widgetTemplateButton.setBorderColor(OBJECT_BORDER_GREY);
        // For this button, only call the callback listener on mouse release
        widgetTemplateButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                // If using a TopNav object, ignore interaction with widget object (ex. widgetTemplateButton)
                if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
                    openURLInBrowser("https://docs.openbci.com/Software/OpenBCISoftware/GUIWidgets/#custom-widget");
                }
            }
        });
        widgetTemplateButton.setDescription("Here is the description for this UI object. It will fade in as help text when hovering over the object.");
    }

    // add custom functions here
    private void customFunction(){
        // this is a fake function... replace it with something relevant to this widget

    }

    public void setDropdown1(int n){
        widgetSettings.setByIndex(TemplateDropdown1.class, n);
        println("Item " + (n+1) + " selected from Dropdown 1");
        if(n == 0){
            println("Item A selected from Dropdown 1");
        } else if(n == 1){
            println("Item B selected from Dropdown 1");
        }
    }

    public void setDropdown2(int n) {
        widgetSettings.setByIndex(TemplateDropdown2.class, n);
        println("Item " + (n+1) + " selected from Dropdown 2");
    }

    public void setDropdown3(int n) {
        widgetSettings.setByIndex(TemplateDropdown3.class, n);
        println("Item " + (n+1) + " selected from Dropdown 3");
    }
};


public void widgetTemplateDropdown1(int n) {
    // This is the callback function for the first dropdown. It will be called when the user selects an item from the dropdown.
    // The parameter "n" is the index of the selected item.
    ((W_Template) widgetManager.getWidget("W_Template")).setDropdown1(n);
}

public void widgetTemplateDropdown2(int n) {
    ((W_Template) widgetManager.getWidget("W_Template")).setDropdown2(n);
}

public void widgetTemplateDropdown3(int n) {
    ((W_Template) widgetManager.getWidget("W_Template")).setDropdown3(n);
}