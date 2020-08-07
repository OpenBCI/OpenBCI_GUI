
enum CalculationWindowSize
    {
        SECONDS1("1 sec", 1*1000),
        SECONDS10("10 sec", 10*1000),
        MINUTE1("1 min", 60*1000);

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
    private Grid dataGrid;
    private PacketLossTracker packetLossTracker;

    private PacketRecord sessionPacketRecord;
    private PacketRecord streamPacketRecord;
    private PacketRecord lastMillisPacketRecord;

    private ControlP5 cp5;
    private ScrollableList tableDropdown;
    
    private final int padding = 5;
    private final int cellHeight = 20;

    private CalculationWindowSize tableWindowSize = CalculationWindowSize.SECONDS10;

    W_PacketLoss(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        dataGrid = new Grid(5/*numRows*/, 4/*numCols*/, cellHeight);
        packetLossTracker = ((Board)currentBoard).getPacketLossTracker();
        sessionPacketRecord = packetLossTracker.getSessionPacketRecord();
        streamPacketRecord = packetLossTracker.getStreamPacketRecord();

        dataGrid.setString("entire session", 0, 1);
        dataGrid.setString("contiguous stream", 0, 2);

        dataGrid.setString("packets lost", 1, 0);
        dataGrid.setString("packets received", 2, 0);
        dataGrid.setString("packets expected", 3, 0);
        dataGrid.setString("% packets lost", 4, 0);

        createTableDropdown();

        // call once in constructor
        screenResized();
    }

    private void createTableDropdown() {
        tableDropdown = new CustomScrollableList(cp5_widget, "TableTimeWindow")
            .setDrawOutlineWhenClosed(false)
            .setOpen(false)
            .setColor(settings.dropdownColors)
            .setBackgroundColor(150)
            .setBarHeight(cellHeight) //height of top/primary bar
            .setItemHeight(cellHeight) //height of all item/dropdown bars
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

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

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

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        dataGrid.draw();
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

        dataGrid.setDim(x, y, w);
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    }

    private float calcPercent(float total, float fraction) {
        if(total == 0) {
            return 0;
        }

        return fraction * 100 / total;
    }

};
