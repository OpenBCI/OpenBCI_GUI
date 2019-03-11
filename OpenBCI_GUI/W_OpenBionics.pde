
////////////////////////////////////////////////////
//
//    W_template.pde (ie "Widget Template")
//
//    This is a Template Widget, intended to be used as a starting point for OpenBCI Community members that want to develop their own custom widgets!
//    Good luck! If you embark on this journey, please let us know. Your contributions are valuable to everyone!
//
//    Created by: Conor Russomanno, November 2016
//
///////////////////////////////////////////////////,

class W_openBionics extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...
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

  ControlP5 configP5;
  String obName;
  String obBaud;
  List serialListOB;
  List baudListOB;
  int drawConfig;
  int[] fingerChans;

  boolean wasConnected;


  W_openBionics(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function

    configP5 = new ControlP5(_parent);
    wasConnected = false;


    parent = _parent;
    baudListOB = Arrays.asList("NONE","230400","115200","57600","38400","28800","19200","14400","9600","7200","4800","3600","2400","1800","1200","600","300");
    drawConfig = -1;
    fingerChans = new int[6];
    for(int i = 0; i<6; i++) fingerChans[i] = -1;

    hand = loadImage("hand.png");
    thumb = loadImage("thumb_over.png");
    index = loadImage("index_over.png");
    middle = loadImage("middle_over.png");
    ring = loadImage("ring_over.png");
    little = loadImage("little_over.png");
    palm = loadImage("palm_over.png");

    String[] serialPortsLocal = Serial.list();
    serialListOB = new ArrayList();
    serialListOB.add("NONE");
    for (int i = 0; i < serialPortsLocal.length; i++) {
      String tempPort = serialPortsLocal[(serialPortsLocal.length-1) - i]; //list backwards... because usually our port is at the bottom
      if(!tempPort.equals(openBCI_portName)) serialListOB.add(tempPort);
    }

    configClose = new Button(int(x) + w/4,int(y) + 3*navHeight,int(w/25.3),int(w/25.3),"X",fontInfo.buttonLabel_size);
    configConfirm = new Button(int(x) + w/2 + w/7,int(y) + 12*navHeight,int(w/10.12),int(w/25.3),"OKAY",fontInfo.buttonLabel_size);
    connect = new Button(int(x) + w - (w/7), int(y) + 10*navHeight, int(w/8), int(w/25.3), "CONNECT", fontInfo.buttonLabel_size);

    obChanList = new MenuList(configP5, "obChanList", 100, 120, f2);
    obChanList.setPosition(x+w/3 + w/12, y + h/3 + h/16);
    obChanList.addItem(makeItem("NONE"));
    obChanList.activeItem = 0;
    for(int i = 0; i < nchan; i++) obChanList.addItem(makeItem("" + (i+1)));

    addDropdown("OpenBionicsSerialOut", "Serial Output", serialListOB, 0);
    addDropdown("BaudList", "Baud List", baudListOB, 0);
    configP5.get(MenuList.class, "obChanList").setVisible(false);
    // addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

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

        println("inByte = " + inByte);
    }

    if(fingerChans[5] == -1){

        if(OpenBionicsHand != null){


        for(int i = 0; i<5; i++){
          //================= OpenBionics Analog Movement =======================
          if(fingerChans[i] == -1) output_normalized = 0;
          else output_normalized = int(map(w_emg.motorWidgets[fingerChans[i]].output_normalized, 0, 1, 0, 1023));

          if(i == 4) researchCommand.append(output_normalized + "\n");
          else researchCommand.append(output_normalized + ",");

        }
        OpenBionicsHand.write(researchCommand.toString());
      }
    }
    else {

      if(OpenBionicsHand != null){

        output_normalized = int(map(w_emg.motorWidgets[fingerChans[5]].output_normalized, 0, 1, 0, 100));
        OpenBionicsHand.write("G0P" + output_normalized + "\n");

      }

    }
  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...
    process();

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    pushStyle();

    //configP5.setVisible(true);

    //draw FFT Graph w/ all plots
    noStroke();
    fill(255);
    rect(x, y, w, h);

    obChanList.setPosition(x+w/3 + w/12, y + h/3 + h/16);

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
        if(wasConnected){
          fill(0,250,0);
          ellipse(x + 5 * (w/6) ,y + 7 * (h/10),20,20);
        }
        else{
          fill(250,0,0);
          ellipse(x + 5 * (w/6),y + 7 * (h/10),20,20);
        }
        connect.draw();
        break;
      case 0:
        configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
        configP5.get(MenuList.class, "obChanList").setVisible(true);
        fill(180,180,180);
        rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
        configClose.draw();
        configConfirm.draw();
        fill(10,10,10);
        textFont(f);
        textSize(12);
        text("Thumb Channel Selection", x + w/3, y + 4*navHeight);
        break;
      case 1:
        configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
        configP5.get(MenuList.class, "obChanList").setVisible(true);
        fill(180,180,180);
        rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
        configClose.draw();
        configConfirm.draw();
        fill(10,10,10);
        textFont(f);
        textSize(12);
        text("Index Finger Channel Selection", x + w/3, y + 4*navHeight);
        break;
      case 2:
        configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
        configP5.get(MenuList.class, "obChanList").setVisible(true);
        fill(180,180,180);
        rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
        configClose.draw();
        configConfirm.draw();
        fill(10,10,10);
        textFont(f);
        textSize(12);
        text("Middle Finger Channel Selection", x + w/3, y + 4*navHeight);
        break;
      case 3:
        configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
        configP5.get(MenuList.class, "obChanList").setVisible(true);
        fill(180,180,180);
        rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
        configClose.draw();
        configConfirm.draw();
        fill(10,10,10);
        textFont(f);
        textSize(12);
        text("Ring Finger Channel Selection", x + w/3, y + 4*navHeight);
        break;
      case 4:
        configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
        configP5.get(MenuList.class, "obChanList").setVisible(true);
        fill(180,180,180);
        rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
        configClose.draw();
        configConfirm.draw();
        fill(10,10,10);
        textFont(f);
        textSize(12);
        text("Little Finger Channel Selection", x + w/3, y + 4*navHeight);
        break;
      case 5:
        configP5.get(MenuList.class, "obChanList").activeItem = fingerChans[drawConfig] + 1;
        configP5.get(MenuList.class, "obChanList").setVisible(true);
        fill(180,180,180);
        rect(int(x) + w/4,int(y) + 3*navHeight, w/2, h/2 + 2*navHeight + navHeight/2);
        configClose.draw();
        configConfirm.draw();
        fill(10,10,10);
        textFont(f);
        textSize(12);
        text("Hand Channel Selection", x + w/3, y + 4*navHeight);
        break;
    }
    configP5.draw();

    popStyle();

  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    configClose = new Button(int(x) + w/4,int(y) + 3*navHeight,int(w/25.3),int(w/25.3),"X",fontInfo.buttonLabel_size);
    configConfirm = new Button(int(x) + w/2 + w/7,int(y) + 12*navHeight,int(w/10.12),int(w/25.3),"OKAY",fontInfo.buttonLabel_size);

    //update dropdown menu positions
    configP5.setGraphics(parent, 0, 0); //remaps the cp5 controller to the new PApplet window size
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
      println("OpenBionics: error resizing...");
    }

  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...
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

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
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
          wasConnected = true;
        }
        catch(Exception e){
          wasConnected = false;
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

  //add custom classes functions here
  void customFunction(){
    //this is a fake function... replace it with something relevant to this widget
  }

};

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
void OpenBionicsSerialOut(int n){

  if(!w_openbionics.serialListOB.get(n).equals("NONE")) w_openbionics.obName = (String)w_openbionics.serialListOB.get(n);

  closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
}

void BaudList(int n){
  if(!w_openbionics.baudListOB.get(n).equals("NONE")) w_openbionics.obBaud = (String)w_openbionics.baudListOB.get(n);
  closeAllDropdowns();
}

void obChanList(int n){
  w_openbionics.fingerChans[w_openbionics.drawConfig] = n - 1;
  closeAllDropdowns();
}
