//author: Drose

class W_headPlotImp extends Widget {

    String showingScreen;

    ControlP5 topFrame;
    int widgetColorBkgr = 255;
    /* header */
    Button backBtn;
    Button nextBtn;
    int rectOff = 8;
    public String intensity_data_uV;    
    int navButtonWidth, navButtonHeight; //dims of nav buttons

    /* widget grid */
    int col0;
    int row0;
    int colWidth = 150;

    /* widget dims */
    final int screenTitleTextSizeW = 120, screenTitleTextSizeH = 20;
    int headerHeight;
    int titleTextSize = 14;

    /* screens */
    Boolean headConnVisible;
    Boolean eegVisible;
    Boolean concenVisible;
    Boolean trainingVisible;

    String[] screenNames = {"connectivity","eeg","concentration","profile"};
    String[] firstLabelNames = {"first screen",
    "second screen", "third screen", "fourth screen"};

    W_headPlotImp(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)
        
        showingScreen = "connectivity";
        navButtonHeight = 20;
        navButtonWidth = 100; 
        col0 = 150;
        headerHeight = navButtonHeight + rectOff;
        row0 = y + headerHeight + 30;
        topFrame = new ControlP5(pApplet);
               
        initialize_UI();   
        topFrame.setAutoDraw(false);   
    }

    public void update(){
        super.update();
    }

    public void draw(){
        super.draw();
        background(color(widgetColorBkgr));

        pushStyle();
        fill(color(128));
        stroke(0);
        rect(x, y, x + w, headerHeight);
        popStyle(); 

        //showWidgetGrid();

        pushStyle();
        topFrame.draw();

        widgetFactory(showingScreen);
        
        popStyle(); 
    }
    
    void initialize_UI(){
        drawTransitionBtns();
    }

    public void screenResized(){
        super.screenResized();
    }

    public void mousePressed(){
        super.mousePressed();
    }

    //This draws the header buttons that allows the use to nav thru the widgets
    void drawTransitionBtns(){         
        backBtn = createButton(topFrame, "buttonID1", "Back", x + 10, y+5, navButtonWidth, navButtonHeight, 0, p4, 14, WHITE, BLACK, BUTTON_HOVER, BUTTON_PRESSED, OBJECT_BORDER_GREY, 0);
        backBtn.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                print("back button pressed\n");
                int ind = 0;
                int size = screenNames.length;
                for(int i=0;i<size;i++){
                    if(screenNames[i].equals(showingScreen)){
                        ind = i;
                    }
                }
                showingScreen = screenNames[(ind+size-1)%size];
            }
        });
        backBtn.setDescription("Click here to go back.");
        nextBtn = createButton(topFrame, "buttonID2", "Forward", x + w - navButtonWidth - 10, y+5, navButtonWidth, navButtonHeight, 0, p4, 14, WHITE, BLACK, BUTTON_HOVER, BUTTON_PRESSED, OBJECT_BORDER_GREY, 0);
        nextBtn.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                print("next button pressed\n");
                int ind = 0;
                int size = screenNames.length;
                for(int i=0;i<size;i++){
                    if(screenNames[i].equals(showingScreen)){
                        ind = i;
                    }
                }                
                showingScreen = screenNames[(ind+1)%size];
            }
        });
        nextBtn.setDescription("Click here to go forward.");              
    }

    //Draws gridlines to visualise grid coordinates
    void showWidgetGrid(){
        pushStyle();
        strokeWeight(1);
        stroke(255,0,0);
        line(x,row0,x+w,row0);
        line(col0,y,col0,y+h);
        popStyle();
    }

    //Load the required widgets given its name
    void widgetFactory(String showingScreen){
        titleTextFactory(showingScreen);
    }

    void titleTextFactory(String shownScreen){
        pushStyle();
        int txtW = (int) textWidth(shownScreen);
        int txtH = titleTextSize;
        txtW+=10;
        txtH+=4;
        strokeWeight(2);
        stroke(0);
        fill(255);
        rect(col0, row0, txtW, -20);
        int topLeftPadding = 5;
        fill(0);
        textSize(titleTextSize);
        text(shownScreen,col0+topLeftPadding,row0-topLeftPadding); 
        popStyle();
    }

};

