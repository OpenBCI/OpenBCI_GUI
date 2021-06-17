//author: Drose

class W_headPlotImp extends Widget {

    //Button widgetTemplateButton;
    HeadPlotImp headPlot;

    W_headPlotImp(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)
        
        //This is the protocol for setting up dropdowns.
        //The last parameter is the default index selection
        //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
        addDropdown("MyDropdown1", "Drop 1", Arrays.asList("C", "D"), 0);

        createHeadPlot(_parent);
       
    }

    public void update(){
        super.update();
        headPlot.update(mouseX, mouseY);
    }

    public void draw(){
        super.draw();
        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        headPlot.draw();
    }

    public void screenResized(){
        super.screenResized();
        headPlot.hp_x = x;
        headPlot.hp_y = y;
        headPlot.hp_w = w;
        headPlot.hp_h = h;
        headPlot.hp_win_x = x;
        headPlot.hp_win_y = y;
    }

    public void mousePressed(){
        super.mousePressed();
        headPlot.mousePressed();
    }

    public void mouseReleased(){
        super.mouseReleased();
        //Since GUI v5, these methods should not really be used.
    }

    private void createHeadPlot(PApplet pApp){
        headPlot = new HeadPlotImp(pApp, x, y, w, h, win_w, win_h);
        headPlot.setIntensityData("test");
    }

};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void MyDropdown1(int n){
    if(n==0){
        w_headPlotImp.headPlot.setIntensityData("test");
    } else if(n==1){
        w_headPlotImp.headPlot.setIntensityData("Another test");
    }
}

class HeadPlotImp{
    public int hp_win_x = 0;
    public int hp_win_y = 0;
    public int hp_x = 0;
    public int hp_y = 0;
    public int hp_w = 0;
    public int hp_h = 0;

    ControlP5 topFrame;
    Button backBtn;
    Button nextBtn;
    public String intensity_data_uV;
    int rectX, rectY;      // Position of square button
    int circleX, circleY;  // Position of circle button
    int rectSize = 90;     // Diameter of rect
    int circleSize = 93;   // Diameter of circle
    color rectColor, circleColor, baseColor;
    color rectHighlight, circleHighlight;
    color currentColor;
    boolean rectOver = false;
    boolean circleOver = false;

    public HeadPlotImp(PApplet pApplet, int _x, int _y, int _w, int _h, int _win_x, int _win_y) {
        hp_x = _x;
        hp_y = _y;
        hp_w = _w;
        hp_h = _h;
        hp_win_x = _win_x;
        hp_win_y = _win_y;
        topFrame = new ControlP5(pApplet);

        rectColor = color(255);
        rectHighlight = color(51);
        circleColor = color(128);
        circleHighlight = color(204);
        baseColor = color(102);
        currentColor = baseColor;
        circleX = width/2+circleSize/2+10;
        circleY = height/2;
        rectX = width/2-rectSize-10;
        rectY = height/2-rectSize/2;
        ellipseMode(CENTER);  
        //this draws over the other widgets too...
        initialize_UI();   
        topFrame.setAutoDraw(false);   
    }

    void initialize_UI(){
        drawTransitionBtns();
    }

    public void draw(){
        update(mouseX, mouseY);
        background(currentColor);

        topFrame.draw();
        
        if (rectOver) {
            fill(rectHighlight);
        } else {
            fill(rectColor);
        }
        stroke(255);
        rect(rectX, rectY, rectSize, rectSize);
        textSize(32);
        fill(0, 102, 153);
        text(intensity_data_uV, 200, 200); 
        
        if (circleOver) {
            fill(circleHighlight);
        } else {
            fill(circleColor);
        }
        stroke(0);
        ellipse(circleX, circleY, circleSize, circleSize);
    }

    public void update(int x, int y){
        if ( isOverCircle(circleX, circleY, circleSize) ) {
            circleOver = true;
            rectOver = false;
        } else if ( isOverRect(rectX, rectY, rectSize, rectSize) ) {
            rectOver = true;
            circleOver = false;
        } else {
            circleOver = rectOver = false;
        }
    }

    void mousePressed() {
        if (circleOver) {
            currentColor = circleColor;
        }
        if (rectOver) {
            currentColor = rectColor;
        }
    }

    boolean isOverRect(int x, int y, int width, int height)  {
        if (mouseX >= x && mouseX <= x+width && 
            mouseY >= y && mouseY <= y+height) {
            return true;
        } else {
            return false;
        }
    }

    boolean isOverCircle(int x, int y, int diameter) {
        float disX = x - mouseX;
        float disY = y - mouseY;
        if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
            return true;
        } else {
            return false;
        }
    }

    void setIntensityData(String data){
        intensity_data_uV = data;
    }

    void drawTransitionBtns(){
        backBtn = createButton(topFrame, "buttonID1", "Back", hp_x + 70, hp_y+40, 200, 20, 0, p4, 14, WHITE, BLACK, BUTTON_HOVER, BUTTON_PRESSED, OBJECT_BORDER_GREY, 0);
        backBtn.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                print("back button pressed");
            }
        });
        backBtn.setDescription("Click here to go back.");
        nextBtn = createButton(topFrame, "buttonID2", "Forward", hp_x + hp_w/2 - 10, hp_y+40, 200, 20, 0, p4, 14, WHITE, BLACK, BUTTON_HOVER, BUTTON_PRESSED, OBJECT_BORDER_GREY, 0);
        nextBtn.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                print("next button pressed");
            }
        });
        nextBtn.setDescription("Click here to go forward.");        
    }
}