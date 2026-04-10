//========================================================================================
//=================              ADD NEW WIDGETS HERE            =========================
//========================================================================================
/*
    Notes:
    - The order in which they are added will effect the order in which they appear in the GUI and in the WidgetSelector dropdown menu of each widget.
    - Use the WidgetTemplate.pde file as a starting point for creating new widgets.
    - Also, check out W_TimeSeries.pde, W_Fft.pde, and W_Accelerometer.pde for examples.
*/
//========================================================================================
//========================================================================================
//========================================================================================

class WidgetManager {
    //This holds all of the widgets. When creating/adding new widgets, we will add them to this ArrayList (below)
    private ArrayList<Widget> widgets;
    private int currentContainerLayout; //This is the Layout structure for the main body of the GUI
    private ArrayList<Layout> layouts = new ArrayList<Layout>();  //This holds all of the different layouts ...

    private boolean visible = true;

    WidgetManager() {
        widgets = new ArrayList<Widget>();

        //DO NOT re-order the functions below
        setupLayouts();
        setupWidgets();
        setupWidgetSelectorDropdowns();

        if ((globalChannelCount == 4 && eegDataSource == DATASOURCE_GANGLION) || eegDataSource == DATASOURCE_PLAYBACKFILE) {
            currentContainerLayout = 1;
            sessionSettings.currentLayout = 1;
        } else {
            currentContainerLayout = 4; //default layout ... tall container left and 2 shorter containers stacked on the right
            sessionSettings.currentLayout = 4;
        }
        
        //Set and fill layout with widgets in order of widget index
        setNewContainerLayout(currentContainerLayout);
    }

    private void setupWidgets() {

        widgets.add(new W_TimeSeries());

        widgets.add(new W_Fft());

        if (currentBoard instanceof AccelerometerCapableBoard) {
            widgets.add(new W_Accelerometer());
        }

        if (currentBoard instanceof BoardCyton) {
            widgets.add(new W_CytonImpedance());
        }

        if (currentBoard instanceof DataSourcePlayback) {
            widgets.add(new W_playback());
        }

        if (globalChannelCount == 4 && currentBoard instanceof BoardGanglion) {
            widgets.add(new W_GanglionImpedance());
        }

        widgets.add(new W_Focus());

        widgets.add(new W_BandPower());

        widgets.add(new W_Emg());
    
        widgets.add(new W_EmgJoystick());

        widgets.add(new W_Spectrogram());

        if (currentBoard instanceof AnalogCapableBoard) {
            widgets.add(new W_PulseSensor());
        }

        if (currentBoard instanceof DigitalCapableBoard) {
            widgets.add(new W_DigitalRead());
        }
        
        if (currentBoard instanceof AnalogCapableBoard) {
            widgets.add(new W_AnalogRead());
        }

        if (currentBoard instanceof Board) {
            widgets.add(new W_PacketLoss());
        }

        widgets.add(new W_Marker());
        
        //DEVELOPERS: Here is an example widget with the essentials/structure in place
        widgets.add(new W_Template());
    }

    private void setupWidgetSelectorDropdowns() {
        // Create a temporary list of widget titles for dropdown setup
        ArrayList<String> widgetTitles = new ArrayList<String>();
        
        // Populate the titles list by calling getWidgetTitle() on each widget
        for (Widget widget : widgets) {
            widgetTitles.add(widget.getWidgetTitle());
        }
        
        // Setup the dropdown for each widget using the temporary list
        for (Widget widget : widgets) {
            widget.setupWidgetSelectorDropdown(widgetTitles);
            widget.setupNavDropdowns();
        }
    }

    public void update() {
        for (Widget currentWidget : widgets) {
            if (!currentWidget.getIsActive()) {
                continue;
            }
            
            currentWidget.update();
            
            // Check if widget position or dimensions have changed relative to its container
            boolean positionChanged = currentWidget.x0 != (int)container[currentWidget.currentContainer].x;
            boolean yPositionChanged = currentWidget.y0 != (int)container[currentWidget.currentContainer].y;
            boolean widthChanged = currentWidget.w0 != (int)container[currentWidget.currentContainer].w;
            boolean heightChanged = currentWidget.h0 != (int)container[currentWidget.currentContainer].h;
            
            if (positionChanged || yPositionChanged || widthChanged || heightChanged) {
                screenResized();
                println("WidgetManager.pde: Remapping widgets to container layout...");
            }
        }
    }

    public void draw() {
        for (Widget widget : widgets) {
            if (widget.getIsActive()) {
                widget.draw();
                widget.drawDropdowns();
            }
        }
    }

    public void screenResized() {
        for (Widget widget : widgets) {
            widget.screenResized();
        }
    }

    public void mousePressed() {
        for (Widget widget : widgets) {
            if (widget.getIsActive()) {
                widget.mousePressed();
            }
        }
    }

    public void mouseReleased() {
        for (Widget widget : widgets) {
            if (widget.getIsActive()) {
                widget.mouseReleased();
            }
        }
    }

    public void mouseDragged() {
        for (Widget widget : widgets) {
            if (widget.getIsActive()) {
                widget.mouseDragged();
            }
        }
    }

    private void setupLayouts() {
        // Reference for layouts: [PUT_LINK_HERE] for layouts/numbers image
        // Note: Order matters for the LayoutSelector UI
        layouts.add(new Layout(new int[]{5}));                  // layout 1: Single container
        layouts.add(new Layout(new int[]{1,3,7,9}));            // layout 2: Four equal containers
        layouts.add(new Layout(new int[]{4,6}));                // layout 3: Left/right split
        layouts.add(new Layout(new int[]{2,8}));                // layout 4: Top/bottom split
        layouts.add(new Layout(new int[]{4,3,9}));              // layout 5
        layouts.add(new Layout(new int[]{1,7,6}));              // layout 6
        layouts.add(new Layout(new int[]{1,3,8}));              // layout 7
        layouts.add(new Layout(new int[]{2,7,9}));              // layout 8
        layouts.add(new Layout(new int[]{4,11,12,13,14}));      // layout 9
        layouts.add(new Layout(new int[]{4,15,16,17,18}));      // layout 10
        layouts.add(new Layout(new int[]{1,7,11,12,13,14}));    // layout 11
        layouts.add(new Layout(new int[]{1,7,15,16,17,18}));    // layout 12
        
        if (isVerbose) {
            printLayouts();
        }
    }

    private void printLayouts() {
        for (int i = 0; i < layouts.size(); i++) {
            println("Widget Manager:printLayouts: " + layouts.get(i));
            StringBuilder layoutString = new StringBuilder();
            
            for (int j = 0; j < layouts.get(i).myContainers.length; j++) {
                layoutString.append(layouts.get(i).myContainers[j].x).append(", ");
                layoutString.append(layouts.get(i).myContainers[j].y).append(", ");
                layoutString.append(layouts.get(i).myContainers[j].w).append(", ");
                layoutString.append(layouts.get(i).myContainers[j].h);
                
                if (j < layouts.get(i).myContainers.length - 1) {
                    layoutString.append(" | ");
                }
            }
            println("Widget Manager:printLayouts: " + layoutString.toString());
        }
    }

    public void setNewContainerLayout(int _newLayout) {
        // Determine how many widgets are needed for the new layout
        int numActiveWidgetsNeeded = layouts.get(_newLayout).myContainers.length;
        
        // Count currently active widgets
        int numActiveWidgets = 0;
        for (Widget widget : widgets) {
            if (widget.getIsActive()) {
                numActiveWidgets++;
            }
        }

        if (numActiveWidgets > numActiveWidgetsNeeded) {
            // Need to deactivate some widgets
            int numToShutDown = numActiveWidgets - numActiveWidgetsNeeded;
            int counter = 0;
            println("Widget Manager: Powering " + numToShutDown + " widgets down, and remapping.");
            
            // Deactivate widgets starting from the end
            for (int i = widgets.size()-1; i >= 0 && counter < numToShutDown; i--) {
                if (widgets.get(i).getIsActive()) {
                    verbosePrint("Widget Manager: Deactivating widget [" + i + "]");
                    widgets.get(i).setIsActive(false);
                    counter++;
                }
            }

            // Map active widgets to containers
            mapActiveWidgetsToContainers(_newLayout);

        } else if (numActiveWidgetsNeeded > numActiveWidgets) {
            // Need to activate more widgets
            int numToPowerUp = numActiveWidgetsNeeded - numActiveWidgets;
            int counter = 0;
            verbosePrint("Widget Manager: Powering " + numToPowerUp + " widgets up, and remapping.");
            
            // Activate widgets from the beginning
            for (int i = 0; i < widgets.size() && counter < numToPowerUp; i++) {
                if (!widgets.get(i).getIsActive()) {
                    verbosePrint("Widget Manager: Activating widget [" + i + "]");
                    widgets.get(i).setIsActive(true);
                    counter++;
                }
            }

            // Map active widgets to containers
            mapActiveWidgetsToContainers(_newLayout);

        } else {
            // Same number of active widgets as needed, just remap
            verbosePrint("Widget Manager: Remapping widgets.");
            mapActiveWidgetsToContainers(_newLayout);
        }
    }

    // Helper method to map active widgets to containers
    private void mapActiveWidgetsToContainers(int layoutIndex) {
        int counter = 0;
        for (Widget widget : widgets) {
            if (widget.getIsActive()) {
                widget.setContainer(layouts.get(layoutIndex).containerInts[counter]);
                counter++;
            }
        }
    }

    public void setAllWidgetsNull() {
        widgets.clear();
        println("Widget Manager: All widgets set to null.");
    }

    // Useful in places like TopNav which overlap widget dropdowns
    public void lockCp5ObjectsInAllWidgets(boolean lock) {
        for (int i = 0; i < widgets.size(); i++) {
            ControlP5 cp5Instance = widgets.get(i).cp5_widget;
            List controllerList = cp5Instance.getAll();
            
            for (int j = 0; j < controllerList.size(); j++) {
                controlP5.Controller controller = (controlP5.Controller)controllerList.get(j);
                controller.setLock(lock);
            }
        }
    }

    public Widget getWidget(String className) {
        for (Widget widget : widgets) {
            String widgetClassName = widget.getClass().getSimpleName();
            if (widgetClassName.equals(className)) {
                return widget;
            }
        }
        return null;
    }

    public boolean getWidgetExists(String className) {
        return getWidget(className) != null;
    }

    public W_TimeSeries getTimeSeriesWidget() {
        return (W_TimeSeries) getWidget("W_TimeSeries");
    }

    public int getWidgetCount() {
        return widgets.size();
    }

    public String getWidgetSettingsAsJson() {
        StringBuilder allWidgetSettings = new StringBuilder();
        allWidgetSettings.append("{");
        boolean firstWidget = true;
        
        for (Widget widget : widgets) {
            if (!(widget instanceof WidgetWithSettings)) {
                continue;
            }
            
            WidgetWithSettings widgetWithSettings = (WidgetWithSettings) widget;
            
            // Call updateChannelSettings to ensure channel selections are saved
            widgetWithSettings.updateChannelSettings();
            
            String widgetTitle = widget.getWidgetTitle();
            WidgetSettings widgetSettings = widgetWithSettings.getSettings();
            String json = widgetSettings.toJSON();
            
            // Only add comma if not the first widget
            if (!firstWidget) {
                allWidgetSettings.append(", ");
            } else {
                firstWidget = false;
            }
            
            allWidgetSettings.append("\"").append(widgetTitle).append("\": ");
            allWidgetSettings.append(json);
        }
        
        allWidgetSettings.append("}");
        return allWidgetSettings.toString();
    }

    public void loadWidgetSettingsFromJson(String widgetSettingsJson) {
        JSONObject json = parseJSONObject(widgetSettingsJson);
        if (json == null) {
            println("WidgetManager:loadWidgetSettingsFromJson: Failed to parse JSON string.");
            return;
        }
        
        for (Widget widget : widgets) {
            if (!(widget instanceof WidgetWithSettings)) {
                continue;
            }
            
            WidgetWithSettings widgetWithSettings = (WidgetWithSettings) widget;
            String widgetTitle = widget.getWidgetTitle();
            if (!json.hasKey(widgetTitle)) {
                println("WidgetManager:loadWidgetSettingsFromJson: No settings found for " + widgetTitle);
                continue;
            }

            String settingsJson = json.getString(widgetTitle, "");
            WidgetSettings widgetSettings = widgetWithSettings.getSettings();
            boolean success = widgetSettings.loadFromJSON(settingsJson);
            if (!success) {
                println("WidgetManager:loadWidgetSettingsFromJson: Failed to load settings for " + widgetTitle);
                continue;
            }
            widgetWithSettings.applySettings();
        }
    }
};