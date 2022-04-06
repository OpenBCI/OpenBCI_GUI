import java.awt.Frame;
import processing.awt.PSurfaceAWT;

// Instantiate this class to show a popup message
class FilterUIPopup extends PApplet implements Runnable {
    private final int defaultWidth = 500;
    private final int defaultHeight = 500;

    private final int headerHeight = 32;
    private final int padding = 20;

    private final int buttonWidth = 120;
    private final int buttonHeight = 40;
    private final int spacer = 6; //space between buttons

    private String message = "Sample text string";
    private String headerMessage = "Filters";
    private String buttonMessage = "OK";
    private String buttonLink = null;

    private color headerColor = OPENBCI_BLUE;
    private color buttonColor = OPENBCI_BLUE;
    
    private ControlP5 cp5;
    private BFFilter brainFlowFilter = BFFilter.BANDSTOP;
    private FilterChannelSelect filterChannelSelect = FilterChannelSelect.ALL_CHANNELS;

    public FilterUIPopup() {
        super();

        Thread t = new Thread(this);
        t.start();        
    }

    @Override
    public void run() {
        PApplet.runSketch(new String[] {headerMessage}, this);
    }

    @Override
    void settings() {
        size(defaultWidth, defaultHeight);
    }

    @Override
    void setup() {
        surface.setTitle(headerMessage);
        surface.setAlwaysOnTop(true);
        surface.setResizable(false);

        cp5 = new ControlP5(this);
        cp5.setGraphics(this, 0,0);
        cp5.setAutoDraw(false);

        int filterX = int(defaultWidth/2 - spacer/2 - buttonWidth);
        int filterY = headerHeight + spacer;
        int chanSelectX = defaultWidth/2 + spacer/2;
        createDropdown("filter", filterX, filterY, brainFlowFilter, BFFilter.values());
        createDropdown("channelSelect", chanSelectX, filterY, filterChannelSelect, FilterChannelSelect.values());
        /*
        cp5.addButton("onButtonPressed")
            .setPosition(width/2 - buttonWidth/2, height - buttonHeight - padding)
            .setSize(buttonWidth, buttonHeight)
            .setColorLabel(color(255))
            .setColorForeground(buttonColor)
            .setColorBackground(buttonColor);
        cp5.getController("onButtonPressed")
            .getCaptionLabel()
            .setFont(p1)
            .toUpperCase(false)
            .setSize(20)
            .setText(buttonMessage);
            */
        List l = Arrays.asList("a", "b", "c", "d", "e", "f", "g", "h");
        /* add a ScrollableList, by default it behaves like a DropdownList */
        cp5.addScrollableList("dropdown")
            .setPosition(100, 100)
            .setSize(200, 100)
            .setBarHeight(20)
            .setItemHeight(20)
            .addItems(l)
            // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
            ;
    }

    @Override
    void draw() {
        final int w = defaultWidth;
        final int h = defaultHeight;

        pushStyle();

        // draw bg
        background(OPENBCI_DARKBLUE);
        stroke(204);
        fill(238);
        rect((width - w)/2, (height - h)/2, w, h);

        // draw header
        noStroke();
        fill(headerColor);
        rect((width - w)/2, (height - h)/2, w, headerHeight);

        //draw header text
        textFont(h4, 14);
        fill(255);
        textAlign(LEFT, CENTER);
        text(headerMessage, (width - w)/2 + padding, (height - h)/2, w, headerHeight);

        //draw message
        textFont(p3, 16);
        fill(102);
        textAlign(LEFT, TOP);
        text(message, (width - w)/2 + padding, (height - h)/2 + padding + headerHeight, w-padding*2, h-padding*2-headerHeight);

        popStyle();
        
        cp5.draw();
    }

    @Override
    void mousePressed() {

    }

    @Override
    void mouseReleased() {

    }

    @Override
    void exit() {
        dispose();
    }

    /*
    public void onButtonPressed() {
        if (buttonLink != null) {
            link(buttonLink);
        }
        noLoop();
        Frame frame = ( (PSurfaceAWT.SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame();
        frame.dispose();
        exit();
    }
    */

    private ScrollableList createDropdown(String name, int _x, int _y, FilterSettingsEnum e, FilterSettingsEnum[] eValues) {
        int dropdownW = buttonWidth;
        int dropdownH = 20;
        //ScrollableList list = new CustomScrollableList(cp5, name)
        ScrollableList list = cp5.addScrollableList(name)
            .setPosition(_x, _y)
            .setOpen(false)
            .setColorBackground(WHITE) // text field bg color
            .setColorValueLabel(color(0))       // text color
            .setColorCaptionLabel(color(0))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(BUTTON_PRESSED)       // border color when selected
            .setBackgroundColor(OBJECT_BORDER_GREY)
            .setSize(dropdownW, dropdownH * (eValues.length + 1))//temporary size
            .setBarHeight(dropdownH) //height of top/primary bar
            .setItemHeight(dropdownH) //height of all item/dropdown bars
            .setVisible(true)
            ;
        // for each entry in the enum, add it to the dropdown.
        for (FilterSettingsEnum value : eValues) {
            // this will store the *actual* enum object inside the dropdown!
            list.addItem(value.getString(), value);
        }
        //Style the text in the ScrollableList
        list.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getString())
            .setFont(h5)
            .setSize(12)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        list.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getString())
            .setFont(p6)
            .setSize(10) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        //list.addCallback(new SLCallbackListener(chanNum));
        return list;
    }
}
