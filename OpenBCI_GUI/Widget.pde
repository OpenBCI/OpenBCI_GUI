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

    private boolean dropdownsShouldBeClosed = false;
    protected boolean dropdownIsActive = false;
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
    }

    public void update(){
        updateDropdowns();
    }

    public void draw(){
        pushStyle();

        fill(255);
        rect(x,y-1,w,h+1); //draw white widget background

        //draw nav bars and button bars
        fill(150, 150, 150);
        rect(x0, y0, w0, navH); //top bar
        fill(200, 200, 200);
        rect(x0, y0+navH, w0, navH); //button bar

        // fill(255);
        // rect(x+2, y+2, navH-4, navH-4);
        // fill(bgColor, 100);
        // rect(x+4, y+4, (navH-10)/2, (navH-10)/2);
        // rect(x+4, y+((navH-10)/2)+5, (navH-10)/2, (navH-10)/2);
        // rect(x+((navH-10)/2)+5, y+4, (navH-10)/2, (navH-10)/2);
        // rect(x+((navH-10)/2)+5, y+((navH-10)/2)+5, (navH-10)/2, (navH-10 )/2);
        //
        // fill(bgColor);
        // textAlign(LEFT, CENTER);
        // textFont(h2);
        // textSize(16);
        // text(widgetTitle, x+navH+2, y+navH/2 - 2); //title of widget -- left

        // drawDropdowns(); //moved to WidgetManager, so that dropdowns draw on top of widget content

        popStyle();
    }

    public void addDropdown(String _id, String _title, List _items, int _defaultItem){
        NavBarDropdown dropdownToAdd = new NavBarDropdown(_id, _title, _items, _defaultItem);
        dropdowns.add(dropdownToAdd);
    }

    public void setupWidgetSelectorDropdown(ArrayList<String> _widgetOptions){
        cp5_widget.setAutoDraw(false); //this prevents the cp5 object from drawing automatically (if it is set to true it will be drawn last, on top of all other GUI stuff... not good)
        // cp5_widget.setFont(h2, 16);
        // cp5_widget.getCaptionLabel().toUpperCase(false);
        //////////////////////////////////////////////////////////////////////////////////////////////////////
        //      SETUP the widgetSelector dropdown
        //////////////////////////////////////////////////////////////////////////////////////////////////////

        cp5_widget.setColor(settings.dropdownColors);
        cp5_widget.addScrollableList("WidgetSelector")
            .setPosition(x0+2, y0+2) //upper left corner
            // .setFont(h2)
            .setOpen(false)
            .setColor(settings.dropdownColors)
            //.setSize(widgetSelectorWidth, int(h0 * widgetDropdownScaling) )// + maxFreqList.size())
            //.setSize(widgetSelectorWidth, (NUM_WIDGETS_TO_SHOW+1)*(navH-4) )// + maxFreqList.size())
            // .setScrollSensitivity(0.0)
            .setBarHeight(navH-4) //height of top/primary bar
            .setItemHeight(navH-4) //height of all item/dropdown bars
            .addItems(_widgetOptions) // used to be .addItems(maxFreqList)
            ;
        cp5_widget.getController("WidgetSelector")
            .getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(widgetTitle)
            .setFont(h4)
            .setSize(14)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        cp5_widget.getController("WidgetSelector")
            .getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(widgetTitle)
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
    }

    public void setupNavDropdowns(){

        cp5_widget.setAutoDraw(false); //this prevents the cp5 object from drawing automatically (if it is set to true it will be drawn last, on top of all other GUI stuff... not good)
        // cp5_widget.setFont(h3, 12);

        //////////////////////////////////////////////////////////////////////////////////////////////////////
        //      SETUP all NavBarDropdowns
        //////////////////////////////////////////////////////////////////////////////////////////////////////

        /*
        dropdownColors.setActive((int)color(150, 170, 200)); //bg color of box when pressed
        dropdownColors.setForeground((int)color(177, 184, 193)); //when hovering over any box (primary or dropdown)
        // dropdownColors.setForeground((int)color(125)); //when hovering over any box (primary or dropdown)
        dropdownColors.setBackground((int)color(255)); //bg color of boxes (including primary)
        dropdownColors.setCaptionLabel((int)color(1, 18, 41)); //color of text in primary box
        // dropdownColors.setValueLabel((int)color(1, 18, 41)); //color of text in all dropdown boxes
        dropdownColors.setValueLabel((int)color(100)); //color of text in all dropdown boxes
        */

        cp5_widget.setColor(settings.dropdownColors);
        // println("Setting up dropdowns...");
        for(int i = 0; i < dropdowns.size(); i++){
            int dropdownPos = dropdowns.size() - i;
            // println("dropdowns.get(i).id = " + dropdowns.get(i).id);
            cp5_widget.addScrollableList(dropdowns.get(i).id)
                .setPosition(x0+w0-(dropdownWidth*(dropdownPos))-(2*(dropdownPos)), y0 + navH + 2) //float right
                .setFont(h5)
                .setOpen(false)
                .setColor(settings.dropdownColors)
                .setSize(dropdownWidth, (dropdowns.get(i).items.size()+1)*(navH-4) )// + maxFreqList.size())
                .setBarHeight(navH-4)
                .setItemHeight(navH-4)
                .addItems(dropdowns.get(i).items) // used to be .addItems(maxFreqList)
                ;
            cp5_widget.getController(dropdowns.get(i).id)
                .getCaptionLabel()
                .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
                .setText(dropdowns.get(i).returnDefaultAsString())
                .setSize(12)
                .getStyle()
                .setPaddingTop(4)
                ;
            cp5_widget.getController(dropdowns.get(i).id)
                .getValueLabel() //the value label is connected to the text objects in the dropdown item bars
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
            if(!cp5_widget.getController("WidgetSelector").isMouseOver()){
                cp5_widget.get(ScrollableList.class, "WidgetSelector").close();
            }
        }
        for(int i = 0; i < dropdowns.size(); i++){
            if(cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).isOpen()){
                //println("++++++++Mouse is over " + dropdowns.get(i).id);
                dropdownIsActive = true;
                if(!cp5_widget.getController(dropdowns.get(i).id).isMouseOver()){
                    cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).close();
                }
            }
        }

        //onHover ... open ... no need to click
        if(dropdownsShouldBeClosed){ //this if takes care of the scenario where you select the same widget that is active...
            dropdownsShouldBeClosed = false;
        } else{
            if(!cp5_widget.get(ScrollableList.class, "WidgetSelector").isOpen()){
                if(cp5_widget.getController("WidgetSelector").isMouseOver()){
                    cp5_widget.get(ScrollableList.class, "WidgetSelector").open();
                }
            }
            for(int i = 0; i < dropdowns.size(); i++){
                if(!cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).isOpen()){
                    if(cp5_widget.getController(dropdowns.get(i).id).isMouseOver()){
                        cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).open();
                    }
                }
            }
        }

        //make sure that the widgetSelector CaptionLabel always corresponds to its widget
        cp5_widget.getController("WidgetSelector")
            .getCaptionLabel()
            .setText(widgetTitle)
            ;

    }

    private void drawDropdowns(){

        //draw dropdown titles
        pushStyle();

        noStroke();
        textFont(h5);
        textSize(12);
        textAlign(CENTER, BOTTOM);
        fill(bgColor);
        for(int i = 0; i < dropdowns.size(); i++){
            int dropdownPos = dropdowns.size() - i;
            // text(dropdowns.get(i).title, x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navH-2));
            text(dropdowns.get(i).title, x0+w0-(dropdownWidth*(dropdownPos))-(2*(dropdownPos+1))+dropdownWidth/2, y0+(navH-2));
        }

        //draw background/stroke of widgetSelector dropdown
        fill(150);
        rect(cp5_widget.getController("WidgetSelector").getPosition()[0]-1, cp5_widget.getController("WidgetSelector").getPosition()[1]-1, widgetSelectorWidth+2, cp5_widget.get(ScrollableList.class, "WidgetSelector").getHeight()+2);

        //draw backgrounds to dropdown scrollableLists ... unfortunately ControlP5 doesn't have this by default, so we have to hack it to make it look nice...
        fill(200);
        for(int i = 0; i < dropdowns.size(); i++){
            rect(cp5_widget.getController(dropdowns.get(i).id).getPosition()[0] - 1, cp5_widget.getController(dropdowns.get(i).id).getPosition()[1] - 1, dropdownWidth + 2, cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).getHeight()+2);
        }

        textAlign(RIGHT, TOP);
        cp5_widget.draw(); //this draws all cp5 elements... in this case, the scrollable lists that populate our dropdowns<>

        popStyle();
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
        //println("Widget " + widgetTitle +  " || show num dropdowns = " + dropdownsItemsToShow);
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

    void ignoreButtonCheck(Button_obci b) {
        //ignore top left button interaction when widgetSelector dropdown is active
        if (dropdownIsActive) {
            b.setIgnoreHover(true);
        } else {
            if (b.getIgnoreHover()) {
                b.setIgnoreHover(false);
            }
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

void closeAllDropdowns(){
    //close all dropdowns
    for(int i = 0; i < wm.widgets.size(); i++){
        wm.widgets.get(i).dropdownsShouldBeClosed = true;
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

    closeAllDropdowns();
}

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//    ChannelSelect is currently used by BandPower and SSVEP Widgets         //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

class ChannelSelect {

    //----------CHANNEL SELECT INFRASTRUCTURE
    private int x, y, w, navH;
    public float tri_xpos = 0;
    private float chanSelectXPos = 0;
    public ControlP5 cp5_channelCheckboxes;   //ControlP5 to contain our checkboxes
    public CheckBox checkList;
    private int offset;  //offset on nav bar of checkboxes
    private boolean channelSelectHover;
    private boolean channelSelectPressed;
    public List<Integer> activeChan;
    public String chanDropdownName;
    private boolean showChannelText = true;
    private boolean wasOpen = false;

    ChannelSelect(PApplet _parent, int _x, int _y, int _w, int _navH, String checkBoxName) {
        x = _x;
        y = _y;
        w = _w;
        navH = _navH;
        activeChan = new ArrayList<Integer>();
        chanDropdownName = checkBoxName;

        //setup for checkboxes
        cp5_channelCheckboxes = new ControlP5(_parent);

        createCheckList(nchan);
    }

    void update(int _x, int _y, int _w) {
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
        //Update the active channels to include in data processing
        activeChan.clear();
        for (int i = 0; i < nchan; i++) {
            if(checkList.getState(i)){
                activeChan.add(i);
            }
        }
        cp5_channelCheckboxes.get(CheckBox.class, chanDropdownName).setPosition(x + 2, y + offset);
    }

    void draw() {

        if (showChannelText) {
            //change "Channels" text color and triangle color on hover
            if (channelSelectHover) {
                fill(openbciBlue);
            } else {
                fill(0);
            }
            textFont(p5, 12);
            chanSelectXPos = x + 2;
            text("Channels", chanSelectXPos, y - 6);
            tri_xpos = x + textWidth("Channels") + 7;

            //draw triangle as pointing up or down, depending on if channel Select is active or closed
            if (!channelSelectPressed) {
                triangle(tri_xpos, y - navH*0.65, tri_xpos + 5, y - navH*0.25, tri_xpos + 10, y - navH*0.65);
            } else {
                triangle(tri_xpos, y - navH*0.25, tri_xpos + 5, y - navH*0.65, tri_xpos + 10, y - navH*0.25);
                //if active, draw a grey background for the channel select checkboxes
                fill(180);
                rect(x,y,w,navH);
            }
        } else { //This is the case in Spectrogram where we need a second channel selector
            //check for state change
            if (channelSelectPressed != wasOpen) {
                wasOpen = channelSelectPressed;
                if (channelSelectPressed) {
                    for (int i = 0; i < nchan; i++) {
                        checkList.getItem(i).setVisible(true);
                    }
                } else {
                    for (int i = 0; i < nchan; i++) {
                        checkList.getItem(i).setVisible(false);
                    }
                }
            }
            //this draws extra grey space behind the checklist buttons
            if (channelSelectPressed) {
                fill(180);
                rect(x,y,w,navH);
            }
        }

        cp5_channelCheckboxes.draw();
    }

    void screenResized(PApplet _parent) {
        cp5_channelCheckboxes.setGraphics(_parent, 0, 0);
        cp5_channelCheckboxes.get(CheckBox.class, chanDropdownName).setPosition(x + 2, y + offset);
    }

    void mousePressed(boolean dropdownIsActive) {
        if (!dropdownIsActive && showChannelText) {
            if (mouseX > (chanSelectXPos) && mouseX < (tri_xpos + 10) && mouseY < (y - navH*0.25) && mouseY > (y - navH*0.65)) {
                channelSelectPressed = !channelSelectPressed;
                if (channelSelectPressed) {
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

    boolean isVisible() {
        return channelSelectPressed;
    }

    void createCheckList(int _nchan) {
        int checkSize = navH - 4;
        offset = (navH - checkSize)/2;

        channelSelectHover = false;
        channelSelectPressed = false;

        //Name the checkbox the same as the text display on screen
        checkList = cp5_channelCheckboxes.addCheckBox(chanDropdownName)
                        .setPosition(x + 5, y + offset)
                        .setSize(checkSize, checkSize)
                        .setItemsPerRow(nchan)
                        .setSpacingColumn(13)
                        .setSpacingRow(2)
                        .setColorLabel(color(0)) //Set the color of the text label
                        .setColorForeground(color(120)) //checkbox color when mouse is hovering over it
                        .setColorBackground(color(150)) //checkbox background color
                        .setColorActive(color(57, 128, 204)) //checkbox color when active
                        ;

        //nchan is a global variable, so we can use it here with no problems
        for (int i = 0; i < _nchan; i++) {
            int chNum = i+1;
            cp5_channelCheckboxes.get(CheckBox.class, chanDropdownName)
                            .addItem(String.valueOf(chNum), chNum)
                            ;
            //start all items as invisible until user clicks dropdown to show checkboxes
            checkList.getItem(i).setVisible(false);
        }

        cp5_channelCheckboxes.setAutoDraw(false); //draw only when specified
        //cp5_channelCheckboxes.setGraphics(_parent, 0, 0);
        cp5_channelCheckboxes.get(CheckBox.class, chanDropdownName).setPosition(x + 2, y + offset);
    }

    void showChannelText() {
        showChannelText = true;
    }

    void hideChannelText() {
        showChannelText = false;
    }

    void setIsVisible(boolean b) {
        channelSelectPressed = b;
    }
} //end of ChannelSelect class
