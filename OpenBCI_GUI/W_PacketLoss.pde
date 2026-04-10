
enum CalculationWindowSize {
    SECONDS1("Last 1s", 1*1000),
    SECONDS10("Last 10s", 10*1000),
    MINUTE1("Last 1m", 60*1000);

    private String name;
    private int milliseconds;

    CalculationWindowSize(String _name, int _millis) {
        this.name = _name;
        this.milliseconds = _millis;
    }
    
    public String  getName() {
        return name;
    }

    public int getMilliseconds() {
        return milliseconds;
    }
}

class W_PacketLoss extends Widget {
    protected Grid dataGrid;
    private PacketLossTracker packetLossTracker;

    private PacketRecord sessionPacketRecord;
    private PacketRecord streamPacketRecord;
    private PacketRecord lastMillisPacketRecord;

    protected ScrollableList tableDropdown;
    
    protected final int PADDING_5 = 5;
    protected final int CELL_HEIGHT = 20;
    protected final int TOP_PADDING = 50;

    private CalculationWindowSize tableWindowSize = CalculationWindowSize.SECONDS10;

    W_PacketLoss() {
        super();
        widgetTitle = "Packet Loss";

        dataGrid = new Grid(5/*numRows*/, 4/*numCols*/, CELL_HEIGHT);
        packetLossTracker = ((Board)currentBoard).getPacketLossTracker();
        sessionPacketRecord = packetLossTracker.getSessionPacketRecord();
        streamPacketRecord = packetLossTracker.getStreamPacketRecord();
        
        dataGrid.setString("Session", 0, 1);
        dataGrid.setString("Stream", 0, 2);

        dataGrid.setString("Packets", 0, 0);
        dataGrid.setString("Lost", 1, 0);
        dataGrid.setString("Received", 2, 0);
        dataGrid.setString("Expected", 3, 0);
        dataGrid.setString("% Lost", 4, 0);

        createTableDropdown();

        resizeGrid();
    }

    private void createTableDropdown() {
        tableDropdown = cp5_widget.addScrollableList("TableTimeWindow")
            .setDrawOutline(false)
            .setOpen(false)
            .setColor(dropdownColorsGlobal)
            .setOutlineColor(OBJECT_BORDER_GREY)
            .setBarHeight(CELL_HEIGHT) //height of top/primary bar
            .setItemHeight(CELL_HEIGHT) //height of all item/dropdown bars
            ;

        // for each entry in the enum, add it to the dropdown.
        for (CalculationWindowSize value : CalculationWindowSize.values()) {
            // this will store the *actual* enum object inside the dropdown!
            tableDropdown.addItem(value.getName(), value);
        }

        tableDropdown.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(tableWindowSize.getName())
            .setFont(h5)
            .setSize(12)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3)
            ;
        tableDropdown.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText("VALUE LABEL")
            .setFont(h5)
            .setSize(12) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;

        tableDropdown.onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                int val = (int)tableDropdown.getValue();
                Map bob = tableDropdown.getItem(val);
                tableWindowSize = (CalculationWindowSize)bob.get("value");
            }
        });
    }

    public void update(){
        super.update();

        lastMillisPacketRecord = packetLossTracker.getCumulativePacketRecordForLast(tableWindowSize.getMilliseconds());

        dataGrid.setString(nfc(sessionPacketRecord.numLost), 1, 1);
        dataGrid.setString(nfc(sessionPacketRecord.numReceived), 2, 1);
        dataGrid.setString(nfc(sessionPacketRecord.getNumExpected()), 3, 1);
        dataGrid.setString(nf(sessionPacketRecord.getLostPercent(), 0, 4 /*decimals*/) + " %", 4, 1);

        dataGrid.setString(nfc(streamPacketRecord.numLost), 1, 2);
        dataGrid.setString(nfc(streamPacketRecord.numReceived), 2, 2);
        dataGrid.setString(nfc(streamPacketRecord.getNumExpected()), 3, 2);
        dataGrid.setString(nf(streamPacketRecord.getLostPercent(), 0, 4 /*decimals*/) + " %", 4, 2);

        dataGrid.setString(nfc(lastMillisPacketRecord.numLost), 1, 3);
        dataGrid.setString(nfc(lastMillisPacketRecord.numReceived), 2, 3);
        dataGrid.setString(nfc(lastMillisPacketRecord.getNumExpected()), 3, 3);
        dataGrid.setString(nf(lastMillisPacketRecord.getLostPercent(), 0, 4 /*decimals*/) + " %", 4, 3);

        // place dropdown on table
        RectDimensions cellDim = dataGrid.getCellDims(0, 3);
        tableDropdown.setPosition(cellDim.x, cellDim.y);
        int dropdownHeight = tableDropdown.getBarHeight() + tableDropdown.getBarHeight() * tableDropdown.getItems().size();
        tableDropdown.setSize(cellDim.w, dropdownHeight);
    }

    public void draw(){
        super.draw();

        pushStyle();
        fill(OPENBCI_DARKBLUE);
        textFont(p5, 12);
        text("Session length: " + sessionTimeElapsed.toString(), x + PADDING_5, y + 15);
        text("Stream length: " + streamTimeElapsed.toString(), x + PADDING_5, y + 35);
        popStyle();

        dataGrid.draw();
    }

    public void screenResized(){
        super.screenResized();
        resizeGrid();
    }

    public void mousePressed(){
        super.mousePressed();

    }

    public void mouseReleased(){
        super.mouseReleased();

    }

    private float calcPercent(float total, float fraction) {
        if(total == 0) {
            return 0;
        }

        return fraction * 100 / total;
    }

    private void resizeGrid() {
        dataGrid.setDim(x, y + TOP_PADDING, w);
    }

};
