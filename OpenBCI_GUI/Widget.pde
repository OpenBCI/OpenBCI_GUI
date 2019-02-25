///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Widget
//      the idea here is that the widget class takes care of all of the responsiveness/structural stuff in the bg so that it is very easy to create a new custom widget to add to the GUI
//      the "Widgets" will be able to be mapped to the various containers of the GUI
//      created by Conor Russomanno ... 11/17/2016
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


class Widget{

  PApplet pApplet;

  int x0, y0, w0, h0; //true x,y,w,h of container
  int x, y, w, h; //adjusted x,y,w,h of white space (blank rectangle) under the nav...

  int currentContainer; //this determines where the widget is located ... based on the x/y/w/h of the parent container

  boolean isActive = false;
  boolean dropdownsShouldBeClosed = false;

  ArrayList<NavBarDropdown> dropdowns;
  ControlP5 cp5_widget;
  String widgetTitle = "No Title Set";
  Button widgetSelector;

  //some variables for the dropdowns
  int navH = 22;
  int widgetSelectorWidth = 160;
  int dropdownWidth = 64;

  CColor dropdownColors = new CColor(); //this is a global CColor that determines the style of all widget dropdowns ... this should go in WidgetManager.pde

  Widget(PApplet _parent){
    pApplet = _parent;
    cp5_widget = new ControlP5(pApplet);
    dropdowns = new ArrayList<NavBarDropdown>();
    //setup dropdown menus

    currentContainer = 5; //central container by default
    mapToCurrentContainer();

  }

  void update(){

    updateDropdowns();

  }

  void draw(){
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

  void addDropdown(String _id, String _title, List _items, int _defaultItem){
    NavBarDropdown dropdownToAdd = new NavBarDropdown(_id, _title, _items, _defaultItem);
    dropdowns.add(dropdownToAdd);
  }

  void setupWidgetSelectorDropdown(ArrayList<String> _widgetOptions){
    cp5_widget.setAutoDraw(false); //this prevents the cp5 object from drawing automatically (if it is set to true it will be drawn last, on top of all other GUI stuff... not good)
    // cp5_widget.setFont(h2, 16);
    // cp5_widget.getCaptionLabel().toUpperCase(false);
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //      SETUP the widgetSelector dropdown
    //////////////////////////////////////////////////////////////////////////////////////////////////////

    dropdownColors.setActive((int)color(150, 170, 200)); //bg color of box when pressed
    dropdownColors.setForeground((int)color(125)); //when hovering over any box (primary or dropdown)
    dropdownColors.setBackground((int)color(255)); //bg color of boxes (including primary)
    dropdownColors.setCaptionLabel((int)color(1, 18, 41)); //color of text in primary box
    // dropdownColors.setValueLabel((int)color(1, 18, 41)); //color of text in all dropdown boxes
    dropdownColors.setValueLabel((int)color(100)); //color of text in all dropdown boxes

    cp5_widget.setColor(dropdownColors);
    cp5_widget.addScrollableList("WidgetSelector")
      .setPosition(x0+2, y0+2) //upper left corner
      // .setFont(h2)
      .setOpen(false)
      .setColor(dropdownColors)
      .setSize(widgetSelectorWidth, (_widgetOptions.size()+1)*(navH-4) )// + maxFreqList.size())
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

  void setupNavDropdowns(){

    cp5_widget.setAutoDraw(false); //this prevents the cp5 object from drawing automatically (if it is set to true it will be drawn last, on top of all other GUI stuff... not good)
    // cp5_widget.setFont(h3, 12);

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //      SETUP all NavBarDropdowns
    //////////////////////////////////////////////////////////////////////////////////////////////////////

    dropdownColors.setActive((int)color(150, 170, 200)); //bg color of box when pressed
    dropdownColors.setForeground((int)color(177, 184, 193)); //when hovering over any box (primary or dropdown)
    // dropdownColors.setForeground((int)color(125)); //when hovering over any box (primary or dropdown)
    dropdownColors.setBackground((int)color(255)); //bg color of boxes (including primary)
    dropdownColors.setCaptionLabel((int)color(1, 18, 41)); //color of text in primary box
    // dropdownColors.setValueLabel((int)color(1, 18, 41)); //color of text in all dropdown boxes
    dropdownColors.setValueLabel((int)color(100)); //color of text in all dropdown boxes

    cp5_widget.setColor(dropdownColors);
    // consolePrint("Setting up dropdowns...");
    for(int i = 0; i < dropdowns.size(); i++){
      int dropdownPos = dropdowns.size() - i;
      // consolePrint("dropdowns.get(i).id = " + dropdowns.get(i).id);
      cp5_widget.addScrollableList(dropdowns.get(i).id)
        .setPosition(x0+w0-(dropdownWidth*(dropdownPos))-(2*(dropdownPos)), y0 + navH + 2) //float right
        .setFont(h5)
        .setOpen(false)
        .setColor(dropdownColors)
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
  void updateDropdowns(){
    //if a dropdown is open and mouseX/mouseY is outside of dropdown, then close it
    // consolePrint("dropdowns.size() = " + dropdowns.size());
    if(cp5_widget.get(ScrollableList.class, "WidgetSelector").isOpen()){
      if(!cp5_widget.getController("WidgetSelector").isMouseOver()){
        // consolePrint("2");
        cp5_widget.get(ScrollableList.class, "WidgetSelector").close();
      }
    }

    for(int i = 0; i < dropdowns.size(); i++){
      // consolePrint("i = " + i);
      if(cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).isOpen()){
        // consolePrint("1");
        if(!cp5_widget.getController(dropdowns.get(i).id).isMouseOver()){
          // consolePrint("2");
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
          // consolePrint("2");
          cp5_widget.get(ScrollableList.class, "WidgetSelector").open();
        }
      }

      for(int i = 0; i < dropdowns.size(); i++){
        // consolePrint("i = " + i);
        if(!cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).isOpen()){
          // consolePrint("1");
          if(cp5_widget.getController(dropdowns.get(i).id).isMouseOver()){
            // consolePrint("2");
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

  void drawDropdowns(){

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

  void screenResized(){
    mapToCurrentContainer();
  }

  void mousePressed(){

  }

  void mouseReleased(){

  }

  void mouseDragged(){

  }

  void setTitle(String _widgetTitle){
    widgetTitle = _widgetTitle;
  }

  void setContainer(int _currentContainer){
    currentContainer = _currentContainer;
    mapToCurrentContainer();
    screenResized();

  }

  void mapToCurrentContainer(){
    x0 = (int)container[currentContainer].x;
    y0 = (int)container[currentContainer].y;
    w0 = (int)container[currentContainer].w;
    h0 = (int)container[currentContainer].h;

    x = x0;
    y = y0 + navH*2;
    w = w0;
    h = h0 - navH*2;

    cp5_widget.setGraphics(pApplet, 0, 0);

    // consolePrint("testing... 1. 2. 3....");
    try {
      cp5_widget.getController("WidgetSelector")
        .setPosition(x0+2, y0+2) //upper left corner
        ;
    }
    catch (Exception e) {
      // consolePrint(e.getMessage());
      // consolePrint("widgetOptions List not built yet..."); AJK 8/22/17 because this is annoyance
    }

    for(int i = 0; i < dropdowns.size(); i++){
      int dropdownPos = dropdowns.size() - i;
      cp5_widget.getController(dropdowns.get(i).id)
        //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
        .setPosition(x0+w0-(dropdownWidth*(dropdownPos))-(2*(dropdownPos)), navH +(y0+2)) //float right
        //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
        ;
    }
  }

  boolean isMouseHere(){
    if(isActive){
      if(mouseX >= x0 && mouseX <= x0 + w0 && mouseY >= y0 && mouseY <= y0 + h0){
        consolePrint("Your cursor is in " + widgetTitle);
        return true;
      } else{
        return false;
      }
    } else {
      return false;
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
  consolePrint("New widget [" + n + "] selected for container...");
  //find out if the widget you selected is already active
  boolean isSelectedWidgetActive = wm.widgets.get(n).isActive;

  //find out which widget & container you are currently in...
  int theContainer = -1;
  for(int i = 0; i < wm.widgets.size(); i++){
    if(wm.widgets.get(i).isMouseHere()){
      theContainer = wm.widgets.get(i).currentContainer; //keep track of current container (where mouse is...)
      if(isSelectedWidgetActive){ //if the selected widget was already active
        wm.widgets.get(i).setContainer(wm.widgets.get(n).currentContainer); //just switch the widget locations (ie swap containers)
      } else{
        wm.widgets.get(i).isActive = false;   //deactivate the current widget (if it is different than the one selected)
      }
    }
  }

  wm.widgets.get(n).isActive = true;//activate the new widget
  wm.widgets.get(n).setContainer(theContainer);//map it to the current container
  //set the text of the widgetSelector to the newly selected widget

  closeAllDropdowns();
}
