
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Widget
//      the idea here is that the widget class takes care of all of the responsiveness/structural stuff in the bg so that it is very easy to create a new custom widget to add to the GUI
//      the "Widgets" will be able to be mapped to the various containers of the GUI
//      created by Conor Russomanno ... 11/17/2016
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CColor cp5_colors; //this is a global CColor that determines the style of all widget dropdowns ... this should go in WidgetManager.pde

class Widget{

  int x, y, w, h;
  int parentContainer; //this determines where the widget is located ... based on the x/y/w/h of the parent container

  boolean isVisible;

  ArrayList<WidgetDropdown> dropdowns;
  ControlP5 cp5;
  String widgetTitle = "Not Title Set";
  Button widgetSelector;

  int navH = 22;
  int dropdownWidth = 60;


  Widget(PApplet _parent){
    cp5 = new ControlP5(_parent);
    //setup dropdown menus

  }

  void updateWidget(){
    updateDropdowns();

  }
  void drawWidget(){

    pushStyle();
    fill(255);
    ; //draw white widget background

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
    textSize(18);
    text(widgetTitle, x+navH+2, y+navH/2 - 2); //title of widget -- left

    drawDropdowns();

    popStyle();

  }

  void addDropdown(String _id, String _title, String[] _items, int _defaultItem){
    WidgetDropdown dropdownToAdd = new WidgetDropdown(_id, _title, _items, _defaultItem);
    dropdowns.add(dropdownToAdd);
  }

  void setupDropdowns(){

  }
  void updateDropdowns(){
    //if a dropdown is open and mouseX/mouseY is outside of dropdown, then close it
    for(int i = 0; i < dropdowns.size(); i++){
      if(cp5.get(ScrollableList.class, dropdowns.get(i).id).isOpen()){
        // println("1");
        if(!cp5.getController(dropdowns.get(i).id).isMouseOver()){
          // println("2");
          cp5.get(ScrollableList.class, dropdowns.get(i).id).close();
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
      text(dropdowns.get(i).title, x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navH-2));
    }

    //drop backgrounds to dropdown scrollableLists ... unfortunately ControlP5 doesn't have this by default, so we have to hack it to make it look nice...
    fill(200);
    for(int i = 0; i < dropdowns.size(); i++){
      rect(cp5.getController(dropdowns.get(i).id).getPosition()[0] - 1, cp5.getController(dropdowns.get(i).id).getPosition()[1] - 1, dropdownWidth + 2, cp5.get(ScrollableList.class, dropdowns.get(i).id).getHeight()+2);

    }

    cp5.draw();

  }
  void screenResized(){

  }
  void mousePressed(){

  }
  void mouseReleased(){

  }
  void setTitle(String _widgetTitle){
    widgetTitle = _widgetTitle;
  }
  void setContainer(int _parentContainer){
    parentContainer = _parentContainer;
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
  String[] items;
  int defaultItem;

  WidgetDropdown(String _id, String _title, String[] _items, int _defaultItem){
    id = _id;
    title = _title;
    // int dropdownSize = _items.length;
    items = new String[_items.length];
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

}
