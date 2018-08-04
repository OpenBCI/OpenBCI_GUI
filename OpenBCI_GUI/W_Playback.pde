
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    W_playback.pde (ie "Playback")

    Allow user playback control from within GUI system and address #48 and #55 on Github
                       Created: Richard Waltman - August 2018
 */
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class W_playback extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...
  PlaybackFileBox2 playbackFileBox2;
  Button selectPlaybackFile2;
  Button widgetTemplateButton;
  int padding = 10;
  Boolean initHasOccured = false;

  W_playback(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)
    x = x0;
    y = y0;
    w = w0;
    h = h0;

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    addDropdown("pbDropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
    addDropdown("pbDropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
    addDropdown("pbDropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

    playbackFileBox2 = new PlaybackFileBox2(x, y, 200, navHeight, 12);

    widgetTemplateButton = new Button (x + w/2 + 50, y + h/2, 200, navHeight, "Design Your Own Widget!", 12);
    widgetTemplateButton.setFont(p4, 14);
    widgetTemplateButton.setURL("http://docs.openbci.com/Tutorials/15-Custom_Widgets");
  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...

    //init system if the user has selected a new playback file from dialog box
    if (systemMode == SYSTEMMODE_POSTINIT && !initHasOccured){
      initHasOccured = true;
      playbackData_fname = "N/A";
    }
    if (playbackData_fname != "N/A" && initHasOccured){
      initSystem();
      playbackData_fname = "N/A";
    }

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    pushStyle();
    fill(boxColor);
    stroke(boxStrokeColor);
    strokeWeight(1);
    rect(x, y, w, h);
    fill(bgColor);
    textFont(h3, 16);
    textAlign(LEFT, TOP);
    text("PLAYBACK FILE", x + padding, y + padding);
    popStyle();

    pushStyle();
    widgetTemplateButton.draw();
    playbackFileBox2.draw();

    popStyle();

  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    widgetTemplateButton.setPos(x + w/2 - widgetTemplateButton.but_dx/2, y + h/2 - widgetTemplateButton.but_dy/2);

    //resize and position the playback file box and button
    playbackFileBox2.screenResized(x + padding, y + padding*2 + 13);

    //selectPlaybackFile2.setPos(x + padding, y + padding*2 + 13);


  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    if (selectPlaybackFile2.isMouseHere()) {
      selectPlaybackFile2.setIsActive(true);
      selectPlaybackFile2.wasPressed = true;
    }

    //put your code here...
    if(widgetTemplateButton.isMouseHere()){
      widgetTemplateButton.setIsActive(true);
    }

  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(widgetTemplateButton.isActive && widgetTemplateButton.isMouseHere()){
      widgetTemplateButton.goToURL();
    }
    widgetTemplateButton.setIsActive(false);

    if (selectPlaybackFile2.isMouseHere() && selectPlaybackFile2.wasPressed) {
      playbackData_fname = "N/A"; //reset the filename variable
      output("select a file for playback");
      selectInput("Select a pre-recorded file for playback:", "playbackSelected");
    }
    selectPlaybackFile2.setIsActive(false);

  }

  //add custom functions here
  void customFunction(){
    //this is a fake function... replace it with something relevant to this widget

  }

  class PlaybackFileBox2 {
    int x, y, w, h, padding; //size and position

    PlaybackFileBox2(int _x, int _y, int _w, int _h, int _padding) {
      x = _x;
      y = _y;
      w = _w;
      h = 67;
      padding = _padding;

      selectPlaybackFile2 = new Button (x + padding, y + padding*2 + 13, w - padding*2, 24, "SELECT PLAYBACK FILE", fontInfo.buttonLabel_size);
    }

    public void update() {
    }

    public void draw() {

      //drawPlaybackFileBox(x,y,w,h);
      selectPlaybackFile2.draw();
      // chanButton16.draw();
    }

    public void screenResized(int _x, int _y) {
      selectPlaybackFile2.setPos(_x,_y);
      drawPlaybackFileBox(_x,_y,w,h);
    }

    public void drawPlaybackFileBox(int x, int y, int w, int h) {
      pushStyle();
      fill(boxColor);
      stroke(boxStrokeColor);
      strokeWeight(1);
      rect(x, y, w, h);
      fill(bgColor);
      textFont(h3, 16);
      textAlign(LEFT, TOP);
      text("PLAYBACK FILE", x + padding, y + padding);
      popStyle();
    }
  };

};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void pbDropdown1(int n){
  println("Item " + (n+1) + " selected from Dropdown 1");
  if(n==0){
    //do this
  } else if(n==1){
    //do this instead
  }

  closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}

void pbDropdown2(int n){
  println("Item " + (n+1) + " selected from Dropdown 2");
  closeAllDropdowns();
}

void pbDropdown3(int n){
  println("Item " + (n+1) + " selected from Dropdown 3");
  closeAllDropdowns();
}
