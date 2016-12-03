
///////////////////////////////////////////////////////////////////////////////
//
// OpenBionics Widget is an easy way to interface with your OpenBionics
// hand using the OpenBCI gui! Use '\' to toggle between FFT and the widget!
//
// Colin Fausnaught, October 2016
//
// KNOWN BUGS: Research mode is sometimes not toggled correctly, will need to fix this by v2 release.
//
///////////////////////////////////////////////////////////////////////////////



ControlP5 configP5;
String obName;
String obBaud;
List serialListOB;
List baudListOB;
int drawConfig;
int[] fingerChans;

class OpenBionics_Widget {

  int x, y, w, h;
  PApplet parent;

  Serial OpenBionicsHand;
  PFont f = createFont("Arial Bold", 24); //for "FFT Plot" Widget Title
  PFont f2 = createFont("Arial", 18); //for dropdown name titles (above dropdown widgets)

  int parentContainer = 9; //which container is it mapped to by default?
  boolean thumbPressed,indexPressed,middlePressed,ringPressed,littlePressed,palmPressed = false;
  boolean researchMode = false;


  PImage hand;
  PImage thumb;
  PImage index;
  PImage middle;
  PImage ring;
  PImage little;
  PImage palm;
  int last_command;

  Button configClose;
  Button configConfirm;
  Button connect;
  MenuList obChanList;

  //constructor 1
  OpenBionics_Widget(PApplet _parent) {
    parent = _parent;
    baudListOB = Arrays.asList("230400","115200","57600","38400","28800","19200","14400","9600","7200","4800","3600","2400","1800","1200","600","300");
    drawConfig = -1;

    fingerChans = new int[6];
    for(int i = 0; i<6; i++) fingerChans[i] = -1;

    configP5 = new ControlP5(parent);
    hand = loadImage("hand.png");
    thumb = loadImage("thumb_over.png");
    index = loadImage("index_over.png");
    middle = loadImage("middle_over.png");
    ring = loadImage("ring_over.png");
    little = loadImage("little_over.png");
    palm = loadImage("palm_over.png");

    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;
    configClose = new Button(int(x) + w/4,int(y) + 3*navHeight,int(w/25.3),int(w/25.3),"X",fontInfo.buttonLabel_size);
    configConfirm = new Button(int(x) + w/2 + w/7,int(y) + 12*navHeight,int(w/10.12),int(w/25.3),"OKAY",fontInfo.buttonLabel_size);
    connect = new Button(int(x) + w - (w/6), int(y) + 14*navHeight, int(w/8), int(w/25.3), "CONNECT", fontInfo.buttonLabel_size);

    obChanList = new MenuList(configP5, "obChanList", 100, 120, f2);
    obChanList.setPosition(x+w/3 + w/12, y + h/3 + h/16);

    obChanList.addItem(makeItem("NONE"));
    obChanList.activeItem = 0;
    for(int i = 0; i < nchan; i++) obChanList.addItem(makeItem("" + (i+1)));

    String[] serialPortsLocal = Serial.list();
    serialListOB = new ArrayList();
    for (int i = 0; i < serialPortsLocal.length; i++) {
      String tempPort = serialPortsLocal[(serialPortsLocal.length-1) - i]; //list backwards... because usually our port is at the bottom
      if(!tempPort.equals(openBCI_portName)) serialListOB.add(tempPort);
    }
    setupDropdownMenus(parent);
  }
  void process(){
    int output_normalized;
    StringBuilder researchCommand = new StringBuilder();

    if(OpenBionicsHand != null ){
        if(!researchMode){
          OpenBionicsHand.write("A10\n");
          researchMode = true;
        }
        byte inByte = byte(OpenBionicsHand.read());

        println(inByte);
    }

    if(fingerChans[5] == -1){

        if(OpenBionicsHand != null){


        for(int i = 0; i<5; i++){
          //================= OpenBionics Analog Movement =======================
          if(fingerChans[i] == -1) output_normalized = 0;
          else output_normalized = int(map(emg_widget.motorWidgets[fingerChans[i]].output_normalized, 0, 1, 0, 1023));

          if(i == 4) researchCommand.append(output_normalized + "\n");
          else researchCommand.append(output_normalized + ",");

        }
        OpenBionicsHand.write(researchCommand.toString());
      }
    }
    else {

      if(OpenBionicsHand != null){

        output_normalized = int(map(emg_widget.motorWidgets[fingerChans[5]].output_normalized, 0, 1, 0, 100));
        OpenBionicsHand.write("G0P" + output_normalized + "\n");

      }

    }
  }

  void setupDropdownMenus(PApplet _parent) {
    //ControlP5 Stuff
    int dropdownPos;
    int dropdownWidth = 100;
    cp5_colors = new CColor();
    cp5_colors.setActive(color(150, 170, 200)); //when clicked
    cp5_colors.setForeground(color(125)); //when hovering
    cp5_colors.setBackground(color(255)); //color of buttons
    cp5_colors.setCaptionLabel(color(1, 18, 41)); //color of text
    cp5_colors.setValueLabel(color(0, 0, 255));

    configP5.setColor(cp5_colors);
    configP5.setAutoDraw(false);
    //-------------------------------------------------------------
    //MAX FREQUENCY (ie X Axis) DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 4; //work down from 4 since we're starting on the right side now...
    configP5.addScrollableList("OpenBionicsSerialOut")
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-((dropdownPos+1)), navHeight+(y+2)) //float right
      .setOpen(false)
      .setSize(dropdownWidth, (serialListOB.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(serialListOB)
      .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    configP5.getController("OpenBionicsSerialOut")
      .getCaptionLabel()
      .setText("Serial Port")
      .setSize(12)
      .getStyle()
      ;

    //-------------------------------------------------------------
    //Logarithmic vs. Linear DROPDOWN
    //-------------------------------------------------------------
    dropdownPos = 0;
    configP5.addScrollableList("BaudList")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (baudListOB.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(baudListOB)
      .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    configP5.getController("BaudList")
      .getCaptionLabel()
      .setText("BAUD")
      .setSize(12)
      .getStyle()
      ;

  }

  void update() { }   //may be used later


  void draw() {

    if(drawBionics){
      pushStyle();

      configP5.setVisible(true);

      //draw FFT Graph w/ all plots
      noStroke();
      fill(255);
      rect(x, y, w, h);


      //draw nav bars and button bars
      fill(150, 150, 150);
      rect(x, y, w, navHeight); //top bar
      fill(200, 200, 200);
      rect(x, y+navHeight, w, navHeight); //button bar
      fill(255);
      rect(x+2, y+2, navHeight-4, navHeight-4);
      fill(bgColor, 100);
      //rect(x+3,y+3, (navHeight-7)/2, navHeight-10);
      rect(x+4, y+4, (navHeight-10)/2, (navHeight-10)/2);
      rect(x+4, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10)/2);
      rect(x+((navHeight-10)/2)+5, y+4, (navHeight-10)/2, (navHeight-10)/2);
      rect(x+((navHeight-10)/2)+5, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10 )/2);
      //text("FFT Plot", x+w/2, y+navHeight/2)
      fill(bgColor);
      textAlign(LEFT, CENTER);
      textFont(f);
      textSize(18);
      text("OpenBionics", x+navHeight+2, y+navHeight/2 - 2); //title of widget -- left
      //textAlign(CENTER,CENTER); text("FFT Plot", w/2, y+navHeight/2 - 2); //title of widget -- left
      //fill(255,0,0,150);
      //rect(x,y,w,h);

      //draw dropdown titles
      int dropdownPos = 1; //used to loop through drop down titles ... should use for loop with titles in String array, but... laziness has ensued. -Conor
      int dropdownWidth = 100;
      textFont(f2);
      textSize(12);
      textAlign(CENTER, BOTTOM);
      fill(bgColor);
      text("OpenBionics Serial Out", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
      dropdownPos = 0;
      text("Baud List", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));

      //draw dropdown menus


      switch(drawConfig){
        case -1:
          image(hand,x + w/4,y+2*navHeight + 2, w/2,h/2 + h/3 );

          if(overThumb()) image(thumb,x + w/4,y+2*navHeight + 2, w/2,h/2 + h/3 );
          else if(overIndex()) image(index,x + w/4,y+2*navHeight + 2, w/2,h/2 + h/3 );
          else if(overMiddle()) image(middle,x + w/4,y+2*navHeight + 2, w/2,h/2 + h/3 );
          else if(overRing()) image(ring,x + w/4,y+2*navHeight + 2, w/2,h/2 + h/3 );
          else if(overLittle()) image(little,x + w/4,y+2*navHeight + 2, w/2,h/2 + h/3 );
          else if(overPalm()) image(palm,x + w/4,y+2*navHeight + 2, w/2,h/2 + h/3 );
          configP5.get(MenuList.class, "obChanList").setVisible(false);
          configP5.get(MenuList.class, "obChanList").activeItem = 0;
          connect.draw();
          break;
        case 0:
          configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
          configP5.get(MenuList.class, "obChanList").setVisible(true);
          fill(180,180,180);
          rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
          configClose.draw();
          configConfirm.draw();
          textFont(f);
          textSize(12);
          text("Thumb Finger Channel Selection", x + w/2, y + 4*navHeight);
          break;
        case 1:
          configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
          configP5.get(MenuList.class, "obChanList").setVisible(true);
          fill(180,180,180);
          rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
          configClose.draw();
          configConfirm.draw();
          textFont(f);
          textSize(12);
          text("Index Finger Channel Selection", x + w/2, y + 4*navHeight);
          break;
        case 2:
          configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
          configP5.get(MenuList.class, "obChanList").setVisible(true);
          fill(180,180,180);
          rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
          configClose.draw();
          configConfirm.draw();
          textFont(f);
          textSize(12);
          text("Middle Finger Channel Selection", x + w/2, y + 4*navHeight);
          break;
        case 3:
          configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
          configP5.get(MenuList.class, "obChanList").setVisible(true);
          fill(180,180,180);
          rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
          configClose.draw();
          configConfirm.draw();
          textFont(f);
          textSize(12);
          text("Ring Finger Channel Selection", x + w/2, y + 4*navHeight);
          break;
        case 4:
          configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
          configP5.get(MenuList.class, "obChanList").setVisible(true);
          fill(180,180,180);
          rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
          configClose.draw();
          configConfirm.draw();
          textFont(f);
          textSize(12);
          text("Little Finger Channel Selection", x + w/2, y + 4*navHeight);
          break;
        case 5:
          configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
          configP5.get(MenuList.class, "obChanList").setVisible(true);
          fill(180,180,180);
          rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
          configClose.draw();
          configConfirm.draw();
          textFont(f);
          textSize(12);
          text("Hand Channel Selection", x + w/2, y + 4*navHeight);
          break;
      }
      configP5.draw();

      popStyle();
    }
  }

  void screenResized(PApplet _parent, int _winX, int _winY) {
    //when screen is resized...
    //update position/size of FFT widget
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;


    configClose = new Button(int(x) + w/4,int(y) + 3*navHeight,int(w/25.3),int(w/25.3),"X",fontInfo.buttonLabel_size);
    configConfirm = new Button(int(x) + w/2 + w/7,int(y) + 12*navHeight,int(w/10.12),int(w/25.3),"OKAY",fontInfo.buttonLabel_size);

    //update dropdown menu positions
    configP5.setGraphics(_parent, 0, 0); //remaps the cp5 controller to the new PApplet window size
    int dropdownPos;
    int dropdownWidth = 60;
    dropdownPos = 1; //work down from 4 since we're starting on the right side now...
    configP5.getController("OpenBionicsSerialOut")
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      ;
    dropdownPos = 0;
    try{
    configP5.getController("LogLin")
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      ;
    }
    catch(Exception e){
      println("error resizing...");
    }

  }

  void mousePressed() {
    //called by GUI_Widgets.pde
    if(drawConfig == -1){
      if(overThumb()) thumbPressed = true;
      else if(overIndex()) indexPressed = true;
      else if(overMiddle()) middlePressed = true;
      else if(overRing()) ringPressed = true;
      else if(overLittle()) littlePressed = true;
      else if(overPalm()) palmPressed = true;
      else if(connect.isMouseHere()) connect.wasPressed = true;
    }
    else{
      if(configClose.isMouseHere()) configClose.wasPressed= true;
      else if(configConfirm.isMouseHere()) configConfirm.wasPressed= true;
    }

  }
  void mouseReleased() {
    //called by GUI_Widgets.pde
    if(drawConfig == -1){
      if (overThumb() && thumbPressed){drawConfig = 0;}
      else if (overIndex() && indexPressed){drawConfig= 1;}
      else if (overMiddle() && middlePressed){drawConfig = 2;}
      else if (overRing() && ringPressed){drawConfig = 3;}
      else if (overLittle() && littlePressed){drawConfig = 4;}
      else if (overPalm() && palmPressed){drawConfig = 5;}
      else if(connect.isMouseHere() && connect.wasPressed){

        //Connect to OpenBionics Hand
        try{

          OpenBionicsHand = new Serial(parent,obName,Integer.parseInt(obBaud));
          verbosePrint("Connected to OpenBionics Hand");
        }
        catch(Exception e){
          println(e);
          verbosePrint("Could not connect to OpenBionics Hand");
        }
      }

      thumbPressed = false;
      indexPressed = false;
      middlePressed = false;
      ringPressed = false;
      littlePressed = false;
      palmPressed = false;
      cursor(ARROW);


    }
    else{
      if(configClose.isMouseHere() && configClose.wasPressed) {
        configClose.wasPressed= false;
        drawConfig = -1;
      }
      else if(configConfirm.isMouseHere() && configConfirm.wasPressed){
        configConfirm.wasPressed= false;
        drawConfig = -1;
      }
    }
  }

  boolean overThumb(){
    if(mouseX >= x + w/3.9 && mouseX <=x + w/2.5 && mouseY >= y + h/1.8 && mouseY <= y + h/1.32){
      cursor(HAND);
      return true;
    }
    else{
      cursor(ARROW);
      return false;
    }
  }
  boolean overIndex(){
    if(mouseX >= x + w/2.65 && mouseX <=x + w/2.07 && mouseY >= y + h/4.89 && mouseY <= y + h/1.99){
      cursor(HAND);
      return true;
    }
    else{
      cursor(ARROW);
      return false;
    }
  }
  boolean overMiddle(){
    if(mouseX >= x + w/2.01 && mouseX <=x + w/1.79 && mouseY >= y + h/7.08 && mouseY <= y + h/2.14){
      cursor(HAND);
      return true;
    }
    else{
      cursor(ARROW);
      return false;
    }
  }
  boolean overRing(){
    if(mouseX >= x + w/1.73 && mouseX <=x + w/1.5 && mouseY >= y + h/5.59 && mouseY <= y + h/1.95){
      cursor(HAND);
      return true;
    }
    else{
      cursor(ARROW);
      return false;
    }
  }
  boolean overLittle(){
    if(mouseX >= x + w/1.54 && mouseX <=x + w/1.34 && mouseY >= y + h/3.13 && mouseY <= y + h/1.78){
      cursor(HAND);
      return true;
    }
    else{
      cursor(ARROW);
      return false;
    }
  }
  boolean overPalm(){
    if(mouseX >= x + w/2.47 && mouseX <=x + w/1.48 && mouseY >= y + h/1.89 && mouseY <= y + h/1.05){
      cursor(HAND);
      return true;
    }
    else{
      cursor(ARROW);
      return false;
    }
  }

  //void keyPressed() {
  //  //called by GUI_Widgets.pde
  //}
  //void keyReleased() {
  //  //called by GUI_Widgets.pde
  //}
}

void OpenBionicsSerialOut(int n){
  obName = (String)serialListOB.get(n);
}

void BaudList(int n){
  obBaud = (String)baudListOB.get(n);
}

void obChanList(int n){
  //println("Value: "+ (n-1));
  fingerChans[drawConfig] = n - 1;
}
