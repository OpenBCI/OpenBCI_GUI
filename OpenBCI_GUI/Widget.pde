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

  int x, y, w, h;

  int currentContainer; //this determines where the widget is located ... based on the x/y/w/h of the parent container

  boolean isActive;

  ArrayList<WidgetDropdown> dropdowns;
  ControlP5 cp5_widget;
  String widgetTitle = "No Title Set";
  Button widgetSelector;

  int navH = 22;
  int dropdownWidth = 60;

  CColor dropdownColors = new CColor(); //this is a global CColor that determines the style of all widget dropdowns ... this should go in WidgetManager.pde

  Widget(PApplet _parent, int _currentContainer){
    pApplet = _parent;
    cp5_widget = new ControlP5(pApplet);
    dropdowns = new ArrayList<WidgetDropdown>();
    //setup dropdown menus

    currentContainer = _currentContainer;
    x = (int)container[currentContainer].x;
    y = (int)container[currentContainer].y;
    w = (int)container[currentContainer].w;
    h = (int)container[currentContainer].h;

  }

  void update(){
    updateDropdowns();

  }
  void draw(){
    pushStyle();
    fill(255);
    rect(x,y,w,h); //draw white widget background

    //draw nav bars and button bars
    fill(150, 150, 150);
    rect(x, y, w, navH); //top bar
    fill(200, 200, 200);
    rect(x, y+navH, w, navH); //button bar
    fill(255);
    rect(x+2, y+2, navH-4, navH-4);
    fill(bgColor, 100);
    rect(x+4, y+4, (navH-10)/2, (navH-10)/2);
    rect(x+4, y+((navH-10)/2)+5, (navH-10)/2, (navH-10)/2);
    rect(x+((navH-10)/2)+5, y+4, (navH-10)/2, (navH-10)/2);
    rect(x+((navH-10)/2)+5, y+((navH-10)/2)+5, (navH-10)/2, (navH-10 )/2);
    fill(bgColor);
    textAlign(LEFT, CENTER);
    textFont(h2);
    textSize(16);
    text(widgetTitle, x+navH+2, y+navH/2 - 2); //title of widget -- left

    drawDropdowns();

    popStyle();

  }

  void addDropdown(String _id, String _title, List _items, int _defaultItem){
    WidgetDropdown dropdownToAdd = new WidgetDropdown(_id, _title, _items, _defaultItem);
    dropdowns.add(dropdownToAdd);
  }

  void setupDropdowns(){

    cp5_widget.setAutoDraw(false); //this prevents the cp5 object from drawing automatically (if it is set to true it will be drawn last, on top of all other GUI stuff... not good)

    dropdownColors.setActive((int)color(150, 170, 200)); //bg color of box when pressed
    dropdownColors.setForeground((int)color(125)); //when hovering over any box (primary or dropdown)
    dropdownColors.setBackground((int)color(255)); //bg color of boxes (including primary)
    dropdownColors.setCaptionLabel((int)color(1, 18, 41)); //color of text in primary box
    dropdownColors.setValueLabel((int)color(1, 18, 41)); //color of text in all dropdown boxes

    cp5_widget.setColor(dropdownColors);
    println("Setting up dropdowns...");
    for(int i = 0; i < dropdowns.size(); i++){
      int dropdownPos = dropdowns.size() - i;
      println("dropdowns.get(i).id = " + dropdowns.get(i).id);
      cp5_widget.addScrollableList(dropdowns.get(i).id)
        //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
        // .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), y + navH + 2) //float right
        .setPosition(x+w-(dropdownWidth*(dropdownPos))-(2*(dropdownPos)), y + navH + 2) //float right
        .setOpen(false)
        .setColor(dropdownColors)
        .setSize(dropdownWidth, (dropdowns.get(i).items.size()+1)*(navH-4) )// + maxFreqList.size())
        .setScrollSensitivity(0.0)
        .setBarHeight(navH-4)
        .setItemHeight(navH-4)
        .addItems(dropdowns.get(i).items) // used to be .addItems(maxFreqList)
        // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
        ;

      cp5_widget.getController(dropdowns.get(i).id)
        .getCaptionLabel()
        .setText(dropdowns.get(i).returnDefaultAsString())
        .setSize(12)
        .getStyle()
        //.setPaddingTop(4)
        ;
    }
  }
  void updateDropdowns(){
    //if a dropdown is open and mouseX/mouseY is outside of dropdown, then close it
    // println("dropdowns.size() = " + dropdowns.size());
    for(int i = 0; i < dropdowns.size(); i++){
      // println("i = " + i);
      if(cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).isOpen()){
        // println("1");
        if(!cp5_widget.getController(dropdowns.get(i).id).isMouseOver()){
          // println("2");
          cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).close();
        }
      }
    }

  }
  void drawDropdowns(){

    //draw dropdown titles
    textFont(h2);
    textSize(12);
    textAlign(CENTER, BOTTOM);
    fill(bgColor);
    for(int i = 0; i < dropdowns.size(); i++){
      int dropdownPos = dropdowns.size() - i;
      // text(dropdowns.get(i).title, x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navH-2));
      text(dropdowns.get(i).title, x+w-(dropdownWidth*(dropdownPos))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navH-2));

    }

    //drop backgrounds to dropdown scrollableLists ... unfortunately ControlP5 doesn't have this by default, so we have to hack it to make it look nice...
    fill(200);
    for(int i = 0; i < dropdowns.size(); i++){
      rect(cp5_widget.getController(dropdowns.get(i).id).getPosition()[0] - 1, cp5_widget.getController(dropdowns.get(i).id).getPosition()[1] - 1, dropdownWidth + 2, cp5_widget.get(ScrollableList.class, dropdowns.get(i).id).getHeight()+2);

    }

    cp5_widget.draw(); //this draws all cp5 elements... in this case, the scrollable lists that populate our dropdowns<>

  }
  void screenResized(){
    x = (int)container[currentContainer].x;
    y = (int)container[currentContainer].y;
    w = (int)container[currentContainer].w;
    h = (int)container[currentContainer].h;


    cp5_widget.setGraphics(pApplet, 0, 0);
    for(int i = 0; i < dropdowns.size(); i++){
      int dropdownPos = dropdowns.size() - i;
      cp5_widget.getController(dropdowns.get(i).id)
        //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
        .setPosition(x+w-(dropdownWidth*(dropdownPos))-(2*(dropdownPos)), navH +(y+2)) //float right
        //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
        ;
    }


  }
  void mousePressed(){

  }
  void mouseReleased(){

  }
  void setTitle(String _widgetTitle){
    widgetTitle = _widgetTitle;
  }
  void setContainer(int _currentContainer){
    currentContainer = _currentContainer;
  }

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    WidgetDropdown is a single dropdown item in any instance of a Widget
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class WidgetDropdown{

  String id;
  String title;
  // String[] items;
  List<String> items;
  int defaultItem;

  WidgetDropdown(String _id, String _title, List _items, int _defaultItem){
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
