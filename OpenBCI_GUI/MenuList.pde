//===================== MENU LIST CLASS =============================//
//================== EXTENSION OF CONTROLP5 =========================//
//============== USED FOR SOURCEBOX & SERIALBOX =====================//
//
// Created: Conor Russomanno Oct. 2014
// Based on ControlP5 Processing Library example, written by Andreas Schlegel
//
/////////////////////////////////////////////////////////////////////



//=======================================================================================================================================
//
//                    MenuList Class
//
//The MenuList class is implemented by the Control Panel. It allows you to set up a list of selectable items within a fixed rectangle size
//Currently used for Serial/COM select, SD settings, and System Mode
//
//=======================================================================================================================================

public class MenuList extends controlP5.Controller {

    float pos, npos;
    int itemHeight = 24;
    int scrollerLength = 40;
    int scrollerWidth = 15;
    List< Map<String, Object>> items = new ArrayList< Map<String, Object>>();
    PGraphics menu;
    boolean updateMenu;
    int hoverItem = -1;
    int activeItem = -1;
    PFont menuFont;
    int padding = 7;

    MenuList(ControlP5 c, String theName, int theWidth, int theHeight, PFont theFont) {

        super( c, theName, 0, 0, theWidth, theHeight );
        c.register( this );
        menu = createGraphics(getWidth(),getHeight());
        final ControlP5 cc = c; //allows check for isLocked() below
        final String _theName = theName;

        menuFont = theFont;

        setView(new ControllerView<MenuList>() {

            public void display(PGraphics pg, MenuList t) {
                if (updateMenu && !cc.get(MenuList.class, _theName).isLock()) {
                    updateMenu();
                }
                if (isMouseOver()) {
                    menu.beginDraw();
                    int len = -(itemHeight * items.size()) + getHeight();
                    int ty;
                    if(len != 0){
                        ty = int(map(pos, len, 0, getHeight() - scrollerLength - 2, 2 ) );
                    } else {
                        ty = 0;
                    }
                    menu.fill(bgColor, 100);
                    if(ty > 0){
                        menu.rect(getWidth()-scrollerWidth-2, ty, scrollerWidth, scrollerLength );
                    }
                    menu.endDraw();
                }
                pg.image(menu, 0, 0);
            }
        }
        );
        updateMenu();
    }

    //only update the image buffer when necessary - to save some resources
    void updateMenu() {
        int len = -(itemHeight * items.size()) + getHeight();
        npos = constrain(npos, len, 0);
        pos += (npos - pos) * 0.1;
        //    pos += (npos - pos) * 0.1;
        menu.beginDraw();
        menu.noStroke();
        menu.background(255, 64);
        // menu.textFont(cp5.getFont().getFont());
        menu.textFont(menuFont);
        menu.pushMatrix();
        menu.translate( 0, pos );
        menu.pushMatrix();

        int i0;
        if((itemHeight * items.size()) != 0){
            i0 = PApplet.max( 0, int(map(-pos, 0, itemHeight * items.size(), 0, items.size())));
        } else{
            i0 = 0;
        }
        int range = ceil((float(getHeight())/float(itemHeight))+1);
        int i1 = PApplet.min( items.size(), i0 + range );

        menu.translate(0, i0*itemHeight);

        for (int i=i0; i<i1; i++) {
            Map m = items.get(i);
            menu.fill(255, 100);
            if (i == hoverItem) {
                menu.fill(127, 134, 143);
            }
            if (i == activeItem) {
                menu.stroke(184, 220, 105, 255);
                menu.strokeWeight(1);
                menu.fill(184, 220, 105, 255);
                menu.rect(0, 0, getWidth()-1, itemHeight-1 );
                menu.noStroke();
            } else {
                menu.rect(0, 0, getWidth(), itemHeight-1 );
            }
            menu.fill(bgColor);
            menu.textFont(menuFont);

            //make sure there is something in the Ganglion serial list...
            try {
                menu.text(m.get("headline").toString(), 8, itemHeight - padding); // 5/17
                menu.translate( 0, itemHeight );
            } catch(Exception e){
                println("Nothing in list...");
            }
        }
        menu.popMatrix();
        menu.popMatrix();
        menu.endDraw();
        updateMenu = abs(npos-pos)>0.01 ? true:false;
    }

    // When detecting a click, check if the click happend to the far right, if yes, scroll to that position,
    // Otherwise do whatever this item of the list is supposed to do.
    public void onClick() {
        println(getName() + ": click! ");
        if (items.size() > 0) { //Fixes #480
            if (getPointer().x()>getWidth()-scrollerWidth) {
                if(getHeight() != 0){
                    npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
                }
                updateMenu = true;
            } else {
                int len = itemHeight * items.size();
                int index = 0;
                if(len != 0){
                    index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
                }
                setValue(index);
                activeItem = index;
            }
            updateMenu = true;
        }
    }

    public void onMove() {
        if (getPointer().x()>getWidth() || getPointer().x()<0 || getPointer().y()<0  || getPointer().y()>getHeight() ) {
            hoverItem = -1;
        } else {
            int len = itemHeight * items.size();
            int index = 0;
            if(len != 0){
                index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
            }
            hoverItem = index;
        }
        updateMenu = true;
    }

    public void onDrag() {
        if (getPointer().x() > (getWidth()-scrollerWidth)) {
            npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
            updateMenu = true;
        } else {
            npos += getPointer().dy() * 2;
            updateMenu = true;
        }
    }

    public void onScroll(int n) {
        npos += ( n * 4 );
        updateMenu = true;
    }

    public void addItem(Map<String, Object> m) {
        items.add(m);
        updateMenu = true;
    }

    public void addItem(String theHeadline) {
        Map m = new HashMap<String, Object>();
        m.put("headline", theHeadline);
        addItem(m);
    }

    public void addItem(String theHeadline, int value) {
        Map m = new HashMap<String, Object>();
        m.put("headline", theHeadline);
        m.put("value", value);
        items.add(m);
    }

    public void addItem(String theHeadline, String theSubline, String theCopy) {
        Map m = new HashMap<String, Object>();
        m.put("headline", theHeadline);
        m.put("subline", theSubline);
        m.put("copy", theCopy);
        items.add(m);
    }

    public void removeItem(Map<String, Object> m) {
        items.remove(m);
        updateMenu = true;
    }

    //Returns null if selecting an item that does not exist
    public Map<String, Object> getItem(int theIndex) {
        Map<String, Object> m = new HashMap<String, Object>();
        try {
            m = items.get(theIndex);
        } catch (Exception e) {
            //println("Item " + theIndex + " does not exist.");
        }
        return m;
    }

    public int getListSize() {
       return items.size(); 
    }
};