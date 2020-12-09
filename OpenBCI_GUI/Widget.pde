///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Widget
//      the idea here is that the widget class takes care of all of the responsiveness/structural stuff in the bg so that it is very easy to create a new custom widget to add to the GUI
//      the "Widgets" will be able to be mapped to the various containers of the GUI
//      created by Conor Russomanno ... 11/17/2016
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Widget{

    protected PApplet pApplet;

    protected int x0, y0, w0, h0; //true x,y,w,h of container
    protected int x, y, w, h; //adjusted x,y,w,h of white space `blank rectangle` under the nav...

    private int currentContainer; //this determines where the widget is located ... based on the x/y/w/h of the parent container

    protected boolean dropdownIsActive = false;
    private boolean previousDropdownIsActive = false;
    private boolean widgetSelectorIsActive = false;

    private ArrayList<NavBarDropdown> dropdowns;
    protected ControlP5 cp5_widget;
    protected String widgetTitle = "No Title Set";
    //used to limit the size of the widget selector, forces a scroll bar to show and allows us to add even more widgets in the future
    private final float widgetDropdownScaling = .90;
    private boolean isWidgetActive = false;

    //some variables for the dropdowns
    protected final int navH = 22;
    private int widgetSelectorWidth = 160;
    private int widgetSelectorHeight = 0;
    private final int dropdownWidth = 64;
    private boolean initialResize = false; //used to properly resize the widgetSelector when loading default settings

    Widget(PApplet _parent){
        pApplet = _parent;
        cp5_widget = new ControlP5(pApplet);
        cp5_widget.setAutoDraw(false); //this prevents the cp5 object from drawing automatically (if it is set to true it will be drawn last, on top of all other GUI stuff... not good)
        dropdowns = new ArrayList<NavBarDropdown>();
        //setup dropdown menus

        currentContainer = 5; //central container by default
        mapToCurrentContainer();

    }

    public boolean getIsActive() {
        return isWidgetActive;
    }

    public void setIsActive(boolean isActive) {
        isWidgetActive = isActive;
        //mapToCurrentContainer();
    }

    public void update(){
        updateDropdowns();
    }

    public void draw(){
        pushStyle();
        noStroke();
        fill(255);
        rect(x,y-1,w,h+1); //draw white widget background

        //draw nav bars and button bars
        pushStyle();
        fill(150, 150, 150);
        rect(x0, y0, w0, navH); //top bar
        fill(200, 200, 200);
        rect(x0, y0+navH, w0, navH); //button bar

        popStyle();
    }

    public void addDropdown(String _id, String _title, List _items, int _defaultItem){
        NavBarDropdown dropdownToAdd = new NavBarDropdown(_id, _title, _items, _defaultItem);
        dropdowns.add(dropdownToAdd);
    }

    public void setupWidgetSelectorDropdown(ArrayList<String> _widgetOptions){
        cp5_widget.setColor(settings.dropdownColors);
        ScrollableList scrollList = new CustomScrollableList(cp5_widget, "WidgetSelector")
            .setPosition(x0+2, y0+2) //upper left corner
            // .setFont(h2)
            .setOpen(false)
            .setColor(settings.dropdownColors)
            .setBackgroundColor(OBJECT_BORDER_GREY)
            //.setSize(widgetSelectorWidth, int(h0 * widgetDropdownScaling) )// + maxFreqList.size())
            //.setSize(widgetSelectorWidth, (NUM_WIDGETS_TO_SHOW+1)*(navH-4) )// + maxFreqList.size())
            // .setScrollSensitivity(0.0)
            .setBarHeight(navH-4) //height of top/primary bar
            .setItemHeight(navH-4) //height of all item/dropdown bars
            .addItems(_widgetOptions) // used to be .addItems(maxFreqList)
            ;
        
        scrollList.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(widgetTitle)
            .setFont(h4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        
        scrollList.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(widgetTitle)
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;        
    }

    public void setupNavDropdowns(){
        cp5_widget.setColor(settings.dropdownColors);
        // println("Setting up dropdowns...");
        for(int i = 0; i < dropdowns.size(); i++){
            int dropdownPos = dropdowns.size() - i;
            // println("dropdowns.get(i).id = " + dropdowns.get(i).id);
            ScrollableList scrollList = new CustomScrollableList(cp5_widget, dropdowns.get(i).id)
                .setPosition(x0+w0-(dropdownWidth*(dropdownPos))-(2*(dropdownPos)), y0 + navH + 2) //float right
                .setFont(h5)
                .setOpen(false)
                .setColor(settings.dropdownColors)
                .setBackgroundColor(OBJECT_BORDER_GREY)
                .setSize(dropdownWidth, (dropdowns.get(i).items.size()+1)*(navH-4) )// + maxFreqList.size())
                .setBarHeight(navH-4)
                .setItemHeight(navH-4)
                .addItems(dropdowns.get(i).items) // used to be .addItems(maxFreqList)
                ;
                
            scrollList.getCaptionLabel()
                .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
                .setText(dropdowns.get(i).returnDefaultAsString())
                .setSize(12)
                .getStyle()
                .setPaddingTop(4)
                ;

            scrollList.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
                .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
                .setText(widgetTitle)
                .setSize(12) //set the font size of the item bars to 14pt
                .getStyle() //need to grab style before affecting the paddingTop
                .setPaddingTop(3) //4-pixel vertical offset to center text
                ;
        }
    }
    private void updateDropdowns(){
        //if a dropdown is open and mouseX/mouseY is outside of dropdown, then close it
        // println("dropdowns.size() = " + dropdowns.size());
        dropdownIsActive = false;

        if (!initialResize) {
            resizeWidgetSelector(); //do this once after instantiation to fix grey background drawing error
            initialResize = true;
        }

        //auto close dropdowns based on mouse location
        if(cp5_widget.get(ScrollableList.class, "WidgetSelector").isOpen()){
            dropdownIsActive = true;

        }
        for(int i = 0; i < dropdowns.size(); i++){
            if(cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).isOpen()){
                //println("++++++++Mouse is over " + dropdowns.get(i).id);
                dropdownIsActive = true;
            }
        }

        //make sure that the widgetSelector CaptionLabel always corresponds to its widget
        cp5_widget.getController("WidgetSelector")
            .getCaptionLabel()
            .setText(widgetTitle)
            ;

    }

    private void drawDropdowns(){
        cp5_widget.draw(); //this draws all cp5 elements... in this case, the scrollable lists that populate our dropdowns<>

        //draw dropdown titles		
        pushStyle();		
        noStroke();		
        textFont(h5);		
        textSize(12);		
        textAlign(CENTER, BOTTOM);		
        fill(OPENBCI_DARKBLUE);		
        for(int i = 0; i < dropdowns.size(); i++){		
            int dropdownPos = dropdowns.size() - i;		
            // text(dropdowns.get(i).title, x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navH-2));		
            text(dropdowns.get(i).title, x0+w0-(dropdownWidth*(dropdownPos))-(2*(dropdownPos+1))+dropdownWidth/2, y0+(navH-2));		
        }
    }

    public void mouseDragged(){

    }

    public void mousePressed(){

    }

    public void mouseReleased(){

    }

    public void screenResized(){
        mapToCurrentContainer();
    }

    public void setTitle(String _widgetTitle){
        widgetTitle = _widgetTitle;
    }

    public void setContainer(int _currentContainer){
        currentContainer = _currentContainer;
        mapToCurrentContainer();
        screenResized();

    }

    private void resizeWidgetSelector() {
        int dropdownsItemsToShow = int((h0 * widgetDropdownScaling) / (navH - 4));
        widgetSelectorHeight = (dropdownsItemsToShow + 1) * (navH - 4);
        if (wm != null) {
            int maxDropdownHeight = (wm.widgetOptions.size() + 1) * (navH - 4);
            if (widgetSelectorHeight > maxDropdownHeight) widgetSelectorHeight = maxDropdownHeight;
        }

        cp5_widget.getController("WidgetSelector")
            .setPosition(x0+2, y0+2) //upper left corner
            ;
        cp5_widget.getController("WidgetSelector")
            .setSize(widgetSelectorWidth, widgetSelectorHeight);
            ;
    }

    private void mapToCurrentContainer(){
        x0 = (int)container[currentContainer].x;
        y0 = (int)container[currentContainer].y;
        w0 = (int)container[currentContainer].w;
        h0 = (int)container[currentContainer].h;

        x = x0;
        y = y0 + navH*2;
        w = w0;
        h = h0 - navH*2;

        //This line resets the origin for all cp5 elements under "cp5_widget" when the screen is resized, otherwise there will be drawing errors
        cp5_widget.setGraphics(pApplet, 0, 0);

        if (cp5_widget.getController("WidgetSelector") != null) {
            resizeWidgetSelector();
        }

        //Other dropdowns
        for(int i = 0; i < dropdowns.size(); i++){
            int dropdownPos = dropdowns.size() - i;
            cp5_widget.getController(dropdowns.get(i).id)
                //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
                .setPosition(x0+w0-(dropdownWidth*(dropdownPos))-(2*(dropdownPos)), navH +(y0+2)) //float right
                //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
                ;
        }
    }

    public boolean isMouseHere(){
        if(getIsActive()){
            if(mouseX >= x0 && mouseX <= x0 + w0 && mouseY >= y0 && mouseY <= y0 + h0){
                println("Your cursor is in " + widgetTitle);
                return true;
            } else{
                return false;
            }
        } else {
            return false;
        }
    }
    
    //For use with Cp5 Elements
    protected void lockElementOnOverlapCheck(controlP5.Controller c) {
        if (dropdownIsActive != previousDropdownIsActive) {
            //println(c.getName(), " lock == ", dropdownIsActive);
            c.setLock(dropdownIsActive);
            previousDropdownIsActive = dropdownIsActive;
        }
    }
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    NavBarDropdown is a single dropdown item in any instance of a Widget
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class NavBarDropdown{

    String id;
    String title;
    // String[] items;
    List<String> items;
    int defaultItem;

    NavBarDropdown(String _id, String _title, List _items, int _defaultItem){
        id = _id;
        title = _title;
        // int dropdownSize = _items.length;
        // items = new String[_items.length];
        items = _items;

        defaultItem = _defaultItem;
    }

    void update(){

    }

    void draw(){

    }

    void screenResized(){

    }

    void mousePressed(){

    }

    void mouseReleased(){

    }

    String returnDefaultAsString(){
        String _defaultItem = items.get(defaultItem);
        return _defaultItem;
    }

}

void WidgetSelector(int n){
    println("New widget [" + n + "] selected for container...");
    //find out if the widget you selected is already active
    boolean isSelectedWidgetActive = wm.widgets.get(n).getIsActive();

    //find out which widget & container you are currently in...
    int theContainer = -1;
    for(int i = 0; i < wm.widgets.size(); i++){
        if(wm.widgets.get(i).isMouseHere()){
            theContainer = wm.widgets.get(i).currentContainer; //keep track of current container (where mouse is...)
            if(isSelectedWidgetActive){ //if the selected widget was already active
                wm.widgets.get(i).setContainer(wm.widgets.get(n).currentContainer); //just switch the widget locations (ie swap containers)
            } else{
                wm.widgets.get(i).setIsActive(false);   //deactivate the current widget (if it is different than the one selected)
            }
        }
    }

    wm.widgets.get(n).setIsActive(true);//activate the new widget
    wm.widgets.get(n).setContainer(theContainer);//map it to the current container
    //set the text of the widgetSelector to the newly selected widget
}

// This is a helpful class that will add a channel select feature to a Widget
class ChannelSelect {
    private Widget widget;
    private int x, y, w, navH;
    public float tri_xpos = 0;
    private float chanSelectXPos = 0;
    private final int button_spacer = 10;
    public ControlP5 cp5_chanSelect;   //ControlP5 to contain our checkboxes
    private List<Toggle> channelButtons;
    private int offset;  //offset on nav bar of checkboxes
    private int buttonW;
    private int buttonH;
    private boolean channelSelectHover;
    private boolean isVisible;
    public List<Integer> activeChan;
    public String chanDropdownName;
    private boolean showChannelText = true;
    private boolean wasVisible = false;

    ChannelSelect(PApplet _parent, Widget _widget, int _x, int _y, int _w, int _navH, String checkBoxName) {
        widget = _widget;
        x = _x;
        y = _y;
        w = _w;
        navH = _navH;
        activeChan = new ArrayList<Integer>();
        chanDropdownName = checkBoxName;

        //setup for checkboxes
        cp5_chanSelect = new ControlP5(_parent);
        cp5_chanSelect.setGraphics(_parent, 0, 0);
        cp5_chanSelect.setAutoDraw(false); //draw only when specified
        createButtons(nchan);
    }

    public void update(int _x, int _y, int _w) {
        //update the x,y,w for this class using the parent class
        x = _x;
        y = _y;
        w = _w;
        //Toggle open/closed the channel menu
        if (mouseX > (chanSelectXPos) && mouseX < (tri_xpos + 10) && mouseY < (y - navH*0.25) && mouseY > (y - navH*0.65)) {
            channelSelectHover = true;
        } else {
            channelSelectHover = false;
        }
        //Update position of buttons on every update and check for UI overlap
        for (int i = 0; i < nchan; i++) {
            channelButtons.get(i).setPosition(x + (button_spacer*(i+1)) + (buttonW*i), y + offset);
            widget.lockElementOnOverlapCheck(channelButtons.get(i));
        }
    }

    public void draw() {
        pushStyle();
        noStroke();
        if (showChannelText) {
            //change "Channels" text color and triangle color on hover
            if (channelSelectHover) {
                fill(OPENBCI_BLUE);
            } else {
                fill(0);
            }
            textFont(p5, 12);
            chanSelectXPos = x + 2;
            text("Channels", chanSelectXPos, y - 6);
            tri_xpos = x + textWidth("Channels") + 7;

            //draw triangle as pointing up or down, depending on if channel Select is active or closed
            if (!isVisible) {
                triangle(tri_xpos, y - navH*0.65, tri_xpos + 5, y - navH*0.25, tri_xpos + 10, y - navH*0.65);
            } else {
                triangle(tri_xpos, y - navH*0.25, tri_xpos + 5, y - navH*0.65, tri_xpos + 10, y - navH*0.25);
                //if active, draw a grey background for the channel select checkboxes
                fill(200);
                rect(x,y,w,navH);
            }
        } else { //This is the case in Spectrogram where we need a second channel selector
            //check for state change
            if (isVisible != wasVisible) {
                wasVisible = isVisible;
                setAllButtonsVisibility(isVisible);
            }
            //this draws extra grey space behind the checklist buttons
            if (isVisible) {
                fill(200);
                rect(x,y,w,navH);
            }
        }

        //Draw channel select buttons
        cp5_chanSelect.draw();

        //Draw a border around toggle buttons to indicate if channel is on or off
        if (isVisible) {
            pushStyle();
            int weight = 1;
            strokeWeight(weight);
            noFill();
            for (int i = 0; i < nchan; i++) {
                color c = currentBoard.isEXGChannelActive(i) ? color(0,255,0,255) : color(255,0,0,255);
                stroke(c);
                rect(x + (button_spacer*(i+1)) + (buttonW*i) - weight, y + offset - weight, channelButtons.get(i).getWidth() + weight, channelButtons.get(i).getHeight() + weight);
            }
            popStyle();
        }
    }

    public void screenResized(PApplet _parent) {
        cp5_chanSelect.setGraphics(_parent, 0, 0);
    }

    public void mousePressed(boolean dropdownIsActive) {
        if (!dropdownIsActive && showChannelText) {
            if (mouseX > (chanSelectXPos) && mouseX < (tri_xpos + 10) && mouseY < (y - navH*0.25) && mouseY > (y - navH*0.65)) {
                isVisible = !isVisible;
                setAllButtonsVisibility(isVisible);
            }
        }
    }

    private void createButtons(int _nchan) {
        channelButtons = new ArrayList<Toggle>();
        
        int checkSize = navH - 6;
        offset = (navH - checkSize)/2;

        channelSelectHover = false;
        isVisible = false;

        buttonW = checkSize;
        buttonH = buttonW;

        for (int i = 0; i < _nchan; i++) {
            //start all items as invisible until user clicks dropdown to show checkboxes
            channelButtons.add(
                createButton("ch"+(i+1), (i+1), false, x + (button_spacer*(i+2)) + (buttonW*i), y + offset, buttonW, buttonH)
            );
        }
    }

    private Toggle createButton(String name, int chan, boolean _isVisible, int _x, int _y, int _w, int _h) {
        int _fontSize = 12;
        int marginLeftOffset = chan > 9 ? -9 : -6;
        Toggle myButton = cp5_chanSelect.addToggle(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(OPENBCI_DARKBLUE)
            .setColorForeground(color(120))
            .setColorBackground(color(150))
            .setColorActive(color(57, 128, 204))
            .setVisible(_isVisible)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(String.valueOf(chan))
            .getStyle() //need to grab style before affecting margin and padding
            .setMargin(-_h - 3, 0, 0, marginLeftOffset)
            .setPaddingLeft(10)
            ;
        myButton.onPress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                int chan = Integer.parseInt(((Toggle)theEvent.getController()).getCaptionLabel().getText()) - 1;  
                if (((Toggle)theEvent.getController()).getBooleanValue()) {
                    if (!activeChan.contains(chan)) {
                        activeChan.add(chan);
                        Collections.sort(activeChan);
                    }
                } else {
                    activeChan.remove(Integer.valueOf(chan));
                }
                //println(widget + " || " + activeChan);
            }
        });
        return myButton;
    }

    void showChannelText() {
        showChannelText = true;
    }

    void hideChannelText() {
        showChannelText = false;
    }

    boolean isVisible() {
        return isVisible;
    }

    void setIsVisible(boolean b) {
        isVisible = b;
    }

    public void deactivateAllButtons() {
        activeChan.clear();
        for (int i = 0; i < nchan; i++) {
            channelButtons.get(i).setState(false);
        }
    }

    public void activateAllButtons() {
        activeChan.clear();
        for (int i = 0; i < nchan; i++) {
            channelButtons.get(i).setState(true);
            activeChan.add(i); //already sorted
        }
    }

    public void setToggleState(Integer chan, boolean b) {
        channelButtons.get(chan).setState(b);
        if (b) {
            activeChan.add(chan);
            Collections.sort(activeChan);
        } else {
            activeChan.remove((Integer)chan);
        }
        //print("SET BUTTON TOGGLE -- " + widget + " || " + activeChan);
    }

    private void setAllButtonsVisibility(boolean b) {
        for (int i = 0; i < nchan; i++) {
            channelButtons.get(i).setVisible(b);
        }
    }

} //end of ChannelSelect class
