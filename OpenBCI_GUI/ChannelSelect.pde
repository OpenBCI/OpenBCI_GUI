class ChannelSelect {
    public ControlP5 cp5_chanSelect;
    protected List<controlP5.Controller> cp5ElementsToCheck = new ArrayList<controlP5.Controller>();
    protected int x, y, w, h, navH;
    private float tri_xpos = 0;
    protected float chanSelectXPos = 0;
    protected final int button_spacer = 10;
    protected int offset;  //offset on nav bar of checkboxes
    protected int buttonW, buttonH;
    protected boolean channelSelectHover;
    protected boolean isVisible;

    ChannelSelect(PApplet _parentApplet, int _x, int _y, int _w, int _navH) {
        x = _x;
        y = _y;
        w = _w;
        h = _navH;
        navH = _navH;

        //setup for checkboxes
        cp5_chanSelect = new ControlP5(_parentApplet);
        cp5_chanSelect.setGraphics(_parentApplet, 0, 0);
        cp5_chanSelect.setAutoDraw(false); //draw only when specified
    }

    public void update(int _x, int _y, int _w) {
        x = _x;
        y = _y;
        w = _w;
        if (mouseX > (chanSelectXPos) && mouseX < (tri_xpos + 10) && mouseY < (y - navH*0.25) && mouseY > (y - navH*0.65)) {
            channelSelectHover = true;
        } else {
            channelSelectHover = false;
        }
    }

    public void draw() {
        drawChannelSelectExpander();
        if (isVisible) {
            cp5_chanSelect.draw();
        }
    }

    protected void drawChannelSelectExpander() {
        chanSelectXPos = x + 2;
        pushStyle();
        noStroke();
        //change "Channels" text color and triangle color on hover
        if (channelSelectHover) {
            fill(OPENBCI_BLUE);
        } else {
            fill(OPENBCI_DARKBLUE);
        }
        textFont(p5, 12);
        
        text("Channels", chanSelectXPos, y - 6);
        tri_xpos = x + textWidth("Channels") + 7;

        //draw triangle as pointing up or down, depending on if channel Select is active or closed
        if (isVisible) {
            triangle(tri_xpos, y - 13, tri_xpos + 6, y - 7, tri_xpos + 12, y - 13);
            drawGrayBackground(x, y, w, navH);
        } else {
            triangle(tri_xpos, y - 7, tri_xpos + 6, y - 13, tri_xpos + 12, y - 7);
        }
        popStyle();
    }

    public void screenResized(PApplet _parentApplet) {
        cp5_chanSelect.setGraphics(_parentApplet, 0, 0);
    }

    public void mousePressed(boolean dropdownIsActive) {
        if (!dropdownIsActive) {
            if (mouseX > (chanSelectXPos) && mouseX < (tri_xpos + 10) && mouseY < (y - navH*0.25) && mouseY > (y - navH*0.65)) {
                isVisible = !isVisible;
            }
        }
    }

    protected int getMarginLeftOffset(int chan) {
        return chan > 9 ? -9 : -6;
    }

    public List<controlP5.Controller> getCp5ElementsForOverlapCheck() {
        return cp5ElementsToCheck;
    }

    public boolean isVisible() {
        return isVisible;
    }

    public void setIsVisible(boolean b) {
        isVisible = b;
    }

    public int getHeight() {
        return h;
    }

    public void drawGrayBackground(int _x, int _y, int _w, int _h) {
        pushStyle();
        fill(200);
        rect(_x, _y, _w, _h);
        popStyle();
    }
}

class ExGChannelSelect extends ChannelSelect {

    protected List<Toggle> channelButtons;
    private List<Integer> activeChannels = new ArrayList<Integer>();

    ExGChannelSelect(PApplet _parentApplet, int _x, int _y, int _w, int _navH) {
        super(_parentApplet, _x, _y, _w, _navH);
        createButtons();
    }

    public void draw() {
        super.draw();

        if (isVisible) {
            drawExGChannelOnOffStatus();
        }
    }

    public void update(int _x, int _y, int _w) {
        super.update(_x, _y, _w);
        updateChannelButtonPositions();
    }

    protected void drawExGChannelOnOffStatus() {
        //Draw a border around toggle buttons to indicate if channel is on or off
        pushStyle();
        int weight = 1;
        strokeWeight(weight);
        noFill();
        for (int i = 0; i < globalChannelCount; i++) {
            color c = currentBoard.isEXGChannelActive(i) ? color(0,255,0,255) : color(255,0,0,255);
            stroke(c);
            float[] buttonXY = channelButtons.get(i).getPosition();
            rect(buttonXY[0] - weight, buttonXY[1] - weight, channelButtons.get(i).getWidth() + weight, channelButtons.get(i).getHeight() + weight);
        }
        popStyle();
    }

    protected void createButtons() {
        channelButtons = new ArrayList<Toggle>();
        int numButtons = currentBoard.getNumEXGChannels();
        
        int checkSize = navH - 6;
        offset = (navH - checkSize)/2;

        channelSelectHover = false;
        isVisible = false;

        buttonW = checkSize;
        buttonH = buttonW;

        for (int i = 0; i < numButtons; i++) {
            //start all items as invisible until user clicks dropdown to show checkboxes
            channelButtons.add(
                createToggle("ch"+(i+1), (i+1), x + (button_spacer*(i+2)) + (buttonW*i), y + offset, buttonW, buttonH)
            );
            cp5ElementsToCheck.add((controlP5.Controller)channelButtons.get(i));
        }
    }

    protected Toggle createToggle(String name, int chan, int _x, int _y, int _w, int _h) {
        int _fontSize = 12;
        Toggle myButton = cp5_chanSelect.addToggle(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(OPENBCI_DARKBLUE)
            .setColorForeground(color(120))
            .setColorBackground(color(150))
            .setColorActive(color(57, 128, 204))
            .setVisible(true)
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial", _fontSize, true))
            .toUpperCase(false)
            .setSize(_fontSize)
            .setText(String.valueOf(chan))
            .getStyle() //need to grab style before affecting margin and padding
            .setMargin(-_h - 3, 0, 0, getMarginLeftOffset(chan))
            .setPaddingLeft(10)
            ;
        myButton.onPress(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                int chan = Integer.parseInt(((Toggle)theEvent.getController()).getCaptionLabel().getText()) - 1;  
                boolean b = ((Toggle)theEvent.getController()).getBooleanValue();
                setToggleState(chan, b);
            }
        });
        return myButton;
    }

    protected void updateChannelButtonPositions() {
        for (int i = 0; i < currentBoard.getNumEXGChannels(); i++) {
            channelButtons.get(i).setPosition(x + (button_spacer*(i+1)) + (buttonW*i), y + offset);
        }
    }

    public void deactivateAllButtons() {
        for (int i = 0; i < globalChannelCount; i++) {
            channelButtons.get(i).setState(false);
        }
        activeChannels.clear();
    }

    public void activateAllButtons() {
        for (int i = 0; i < globalChannelCount; i++) {
            channelButtons.get(i).setState(true);
            activeChannels.add(i);
        }
        Collections.sort(activeChannels);
    }

    public void setToggleState(Integer chan, boolean b) {
        channelButtons.get(chan).setState(b);
        if (b && !activeChannels.contains(chan)) {
            activeChannels.add(chan);
        } else if (!b && activeChannels.contains(chan)) {
            activeChannels.remove(chan);
        }
        Collections.sort(activeChannels);
    }

    public List<Integer> getActiveChannels() {
        return activeChannels;
    }

    public void updateChannelSelection(List<Integer> channels) {
        // First deactivate all channels
        deactivateAllButtons();
        
        // Then activate only the selected channels
        for (Integer channel : channels) {
            if (channel >= 0 && channel < channelButtons.size()) {
                setToggleState(channel, true);  // Changed from toggleButton
            }
        }
    }
}

class DualChannelSelector {
    private final int ROW_LABEL_WIDTH = 28;
    private final int ROW_LABEL_SPACER = 4;

    private String firstRowLabel = "Top";
    private String secondRowLabel = "Bot";

    private boolean isFirstRowChannelSelect = true;

    DualChannelSelector (boolean isFirstRow) {
        isFirstRowChannelSelect = isFirstRow;
    }

    public boolean getIsFirstRowChannelSelect() {
        return isFirstRowChannelSelect;
    }

    public void setFirstRowLabel(String s) {
        firstRowLabel = s;
    }

    public void setSecondRowLabel(String s) {
        secondRowLabel = s;
    }

    public void drawRowLabel(int _x, int _y, int _offset) {
        pushStyle();
        fill(0);
        textFont(p5, 12);
        textAlign(CENTER, TOP);
        String label = isFirstRowChannelSelect ? firstRowLabel : secondRowLabel;
        text(label, _x + ROW_LABEL_SPACER + ROW_LABEL_WIDTH/2, _y + _offset);
        popStyle();
    }

    public int getRowLabelWidth() {
        return ROW_LABEL_WIDTH;
    }

    public int getRowLabelSpacer() {
        return ROW_LABEL_SPACER;
    }
}

class DualExGChannelSelect extends ExGChannelSelect {
    
    DualChannelSelector dualChannelSelector;

    DualExGChannelSelect(PApplet _parentApplet, int _x, int _y, int _w, int _navH, boolean isFirstRow) {
        super(_parentApplet, _x, _y, _w, _navH);
        dualChannelSelector = new DualChannelSelector(isFirstRow);
    }
    
    @Override
    public void draw() {
        if (dualChannelSelector.getIsFirstRowChannelSelect()) {
            drawChannelSelectExpander();
        } else {
            //Draw extra grey space behind the second row of checklist buttons
            if (isVisible) {
                drawGrayBackground(x, y, w, h);
            }
        }

        if (isVisible) {
            cp5_chanSelect.draw();
            drawExGChannelOnOffStatus();
            dualChannelSelector.drawRowLabel(x, y, offset);
        }
    }

    @Override
    protected void updateChannelButtonPositions() {
        final int ROW_LABEL_WIDTH = dualChannelSelector.getRowLabelWidth();
        final int ROW_LABEL_SPACER = dualChannelSelector.getRowLabelSpacer();
        for (int i = 0; i < globalChannelCount; i++) {
            channelButtons.get(i).setPosition(x + ROW_LABEL_WIDTH + ROW_LABEL_SPACER + (button_spacer*(i+1)) + (buttonW*i), y + offset);
        }
    }
}
