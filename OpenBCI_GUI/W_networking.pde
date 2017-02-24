///////////////////////////////////////////////////////////////////////////////
//
//    W_networking.pde (Networking Widget)
//
//    This widget provides networking capabilities in the OpenBCI GUI.
//    The networking protocols can be used for outputting data
//    from the OpenBCI GUI to any program that can receive UDP, OSC,
//    or LSL input, such as Matlab, MaxMSP, Python, C/C++, etc.
//
//    The protocols included are: UDP, OSC, and LSL.
//
//
//    Created by: Gabriel Ibagon (github.com/gabrielibagon), January 2017
//
///////////////////////////////////////////////////////////////////////////////


class W_networking extends Widget {

  /* Variables for protocol selection */
  int protocolIndex;
  String protocolMode;

  /* Widget CP5 */
  ControlP5 cp5_networking;
  boolean dataDropdownsShouldBeClosed = false;
  // CColor dropdownColors_networking = new CColor();



  /* UI Organization */
  /* Widget grid */
  int column0;
  int column1;
  int column2;
  int column3;
  int row0;
  int row1;
  int row2;
  int row3;
  int row4;
  int row5;

  /* UI */
  Boolean osc_visible;
  Boolean udp_visible;
  Boolean lsl_visible;
  List<String> dataTypes;
  Button startButton;

  /* Networking */
  Boolean networkActive;

  Stream stream1;
  Stream stream2;
  Stream stream3;

  W_networking(PApplet _parent){
    super(_parent);
    networkActive = false;
    stream1 = null;
    stream2 = null;
    stream3 = null;
    dataTypes = Arrays.asList("None", "TimeSeries", "FFT", "Widget");
    protocolMode = "OSC"; //default to OSC
    addDropdown("Protocol", "Protocol", Arrays.asList("OSC", "UDP", "LSL"), protocolIndex);
    initialize_UI();
    cp5_networking.setAutoDraw(false);
  }

  /* ----- USER INTERFACE ----- */

  void update(){
    super.update();
    if(protocolMode.equals("LSL")){
      if(stream1!=null){
        stream1.run();
      }
      if(stream2!=null){
        stream2.run();
      }
      if(stream2!=null){
        stream2.run();
      }
    }

    //put your code here...
    if(dataDropdownsShouldBeClosed){ //this if takes care of the scenario where you select the same widget that is active...
      dataDropdownsShouldBeClosed = false;
    } else {
      if(cp5_networking.get(ScrollableList.class, "dataType1").isOpen()){
        if(!cp5_networking.getController("dataType1").isMouseOver()){
          // println("2");
          cp5_networking.get(ScrollableList.class, "dataType1").close();
        }
      }
      if(!cp5_networking.get(ScrollableList.class, "dataType1").isOpen()){
        if(cp5_networking.getController("dataType1").isMouseOver()){
          // println("2");
          cp5_networking.get(ScrollableList.class, "dataType1").open();
        }
      }

      if(cp5_networking.get(ScrollableList.class, "dataType2").isOpen()){
        if(!cp5_networking.getController("dataType2").isMouseOver()){
          // println("2");
          cp5_networking.get(ScrollableList.class, "dataType2").close();
        }
      }
      if(!cp5_networking.get(ScrollableList.class, "dataType2").isOpen()){
        if(cp5_networking.getController("dataType2").isMouseOver()){
          // println("2");
          cp5_networking.get(ScrollableList.class, "dataType2").open();
        }
      }

      if(cp5_networking.get(ScrollableList.class, "dataType3").isOpen()){
        if(!cp5_networking.getController("dataType3").isMouseOver()){
          // println("2");
          cp5_networking.get(ScrollableList.class, "dataType3").close();
        }
      }
      if(!cp5_networking.get(ScrollableList.class, "dataType3").isOpen()){
        if(cp5_networking.getController("dataType3").isMouseOver()){
          // println("2");
          cp5_networking.get(ScrollableList.class, "dataType3").open();
        }
      }
    }
  }


  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)
    pushStyle();

    // fill(255,0,0);
    // rect(cp5_networking.getController("dataType1").getPosition()[0] - 1, cp5_networking.getController("dataType1").getPosition()[1] - 1, 100 + 2, cp5_networking.get(ScrollableList.class, "dataType1").getHeight()+2);

    showCP5();

    fill(0,0,0);// Background fill: white
    textFont(h1,20);
    text(" Stream 1",column1,row0);
    text(" Stream 2",column2,row0);
    text(" Stream 3",column3,row0);
    text("Data Type", column0,row1);
    startButton.draw();

    // textAlign(RIGHT,TOP);

    if(protocolMode.equals("OSC")){
      textFont(f4,40);
      text("OSC", x+20,y+h/8+15);
      textFont(h1,20);
      text("IP", column0,row2);
      text("Port", column0,row3);
      text("Address",column0,row4);
      text("Filters",column0,row5);
    }else if (protocolMode.equals("UDP")){
      textFont(f4,40);
      text("UDP", x+20,y+h/8+15);
      textFont(h1,20);
      text("IP", column0,row2);
      text("Port", column0,row3);
      text("Filters",column0,row4);
    }else if (protocolMode.equals("LSL")){
      textFont(f4,40);
      text("LSL", x+20,y+h/8+15);
      textFont(h1,20);
      text("Name", column0,row2);
      text("Type", column0,row3);
      text("# Chan", column0, row4);
    }
    popStyle();

  }

  void initialize_UI(){
    cp5_networking = new ControlP5(pApplet);

    /* Textfields */
    // OSC
    createTextFields("osc_ip1","127.0.0.1");
    createTextFields("osc_port1","12345");
    createTextFields("osc_address1","/openbci");
    createTextFields("osc_ip2","127.0.0.1");
    createTextFields("osc_port2","12346");
    createTextFields("osc_address2","/openbci");
    createTextFields("osc_ip3","127.0.0.1");
    createTextFields("osc_port3","12347");
    createTextFields("osc_address3","/openbci");
    // UDP
    createTextFields("udp_ip1","127.0.0.1");
    createTextFields("udp_port1","12345");
    createTextFields("udp_ip2","127.0.0.1");
    createTextFields("udp_port2","12346");
    createTextFields("udp_ip3","127.0.0.1");
    createTextFields("udp_port3","12347");
    // LSL
    createTextFields("lsl_name1","obci_eeg1");
    createTextFields("lsl_type1","EEG");
    createTextFields("lsl_numchan1",Integer.toString(nchan));
    createTextFields("lsl_name2","obci_eeg2");
    createTextFields("lsl_type2","EEG");
    createTextFields("lsl_numchan2",Integer.toString(nchan));
    createTextFields("lsl_name3","obci_eeg3");
    createTextFields("lsl_type3","EEG");
    createTextFields("lsl_numchan3",Integer.toString(nchan));

    /* General Elements */
    createDropdown("dataType1");
    createDropdown("dataType2");
    createDropdown("dataType3");
    createRadioButtons("filter1");
    createRadioButtons("filter2");
    createRadioButtons("filter3");

    // Start Button
    startButton = new Button(x + w/2 - 70,y+h-40,200,20,"Start",14);
    startButton.setFont(p4,14);
    startButton.setColorNotPressed(color(184,220,105));
  }

  void showCP5(){

    osc_visible=false;
    udp_visible=false;
    lsl_visible=false;

    if(protocolMode.equals("OSC")){
      osc_visible = true;
    }else if (protocolMode.equals("UDP")){
      udp_visible = true;
    }else if (protocolMode.equals("LSL")){
      lsl_visible = true;
    }
    cp5_networking.get(Textfield.class, "osc_ip1").setVisible(osc_visible);
    cp5_networking.get(Textfield.class, "osc_port1").setVisible(osc_visible);
    cp5_networking.get(Textfield.class, "osc_address1").setVisible(osc_visible);
    cp5_networking.get(Textfield.class, "osc_ip2").setVisible(osc_visible);
    cp5_networking.get(Textfield.class, "osc_port2").setVisible(osc_visible);
    cp5_networking.get(Textfield.class, "osc_address2").setVisible(osc_visible);
    cp5_networking.get(Textfield.class, "osc_ip3").setVisible(osc_visible);
    cp5_networking.get(Textfield.class, "osc_port3").setVisible(osc_visible);
    cp5_networking.get(Textfield.class, "osc_address3").setVisible(osc_visible);
    cp5_networking.get(Textfield.class, "udp_ip1").setVisible(udp_visible);
    cp5_networking.get(Textfield.class, "udp_port1").setVisible(udp_visible);
    cp5_networking.get(Textfield.class, "udp_ip2").setVisible(udp_visible);
    cp5_networking.get(Textfield.class, "udp_port2").setVisible(udp_visible);
    cp5_networking.get(Textfield.class, "udp_ip3").setVisible(udp_visible);
    cp5_networking.get(Textfield.class, "udp_port3").setVisible(udp_visible);
    cp5_networking.get(Textfield.class, "lsl_name1").setVisible(lsl_visible);
    cp5_networking.get(Textfield.class, "lsl_type1").setVisible(lsl_visible);
    cp5_networking.get(Textfield.class, "lsl_numchan1").setVisible(lsl_visible);
    cp5_networking.get(Textfield.class, "lsl_name2").setVisible(lsl_visible);
    cp5_networking.get(Textfield.class, "lsl_type2").setVisible(lsl_visible);
    cp5_networking.get(Textfield.class, "lsl_numchan2").setVisible(lsl_visible);
    cp5_networking.get(Textfield.class, "lsl_name3").setVisible(lsl_visible);
    cp5_networking.get(Textfield.class, "lsl_type3").setVisible(lsl_visible);
    cp5_networking.get(Textfield.class, "lsl_numchan3").setVisible(lsl_visible);

    cp5_networking.get(ScrollableList.class, "dataType1").setVisible(true);
    cp5_networking.get(ScrollableList.class, "dataType2").setVisible(true);
    cp5_networking.get(ScrollableList.class, "dataType3").setVisible(true);

    cp5_networking.get(RadioButton.class, "filter1").setVisible(true);
    cp5_networking.get(RadioButton.class, "filter2").setVisible(true);
    cp5_networking.get(RadioButton.class, "filter3").setVisible(true);

    cp5_networking.draw();

  }



  void createTextFields(String name, String default_text){
    cp5_networking.addTextfield(name)
      .align(10,100,10,100)                   // Alignment
      .setSize(100,20)                         // Size of textfield
      .setFont(f2)
      .setFocus(false)                        // Deselects textfield
      .setColor(color(26,26,26))
      .setColorBackground(color(255,255,255)) // text field bg color
      .setColorValueLabel(color(0,0,0))       // text color
      .setColorForeground(color(26,26,26))    // border color when not selected
      .setColorActive(isSelected_color)       // border color when selected
      .setColorCursor(color(26,26,26))
      .setText(default_text)                  // Default text in the field
      .setCaptionLabel("")                    // Remove caption label
      .setVisible(false)                      // Initially hidden
      .setAutoClear(true)                     // Autoclear
      ;
  }
  void createRadioButtons(String name){
    String id = name.substring(name.length()-1);
    cp5_networking.addRadioButton(name)
        .setSize(10,10)
        .setColorForeground(color(120))
        .setColorBackground(color(200,200,200)) // text field bg color
        .setColorActive(color(184,220,105))
        .setColorLabel(color(0))
        .setItemsPerRow(2)
        .setSpacingColumn(40)
        .addItem(id + "-Off", 0)
        .addItem(id + "-On", 1)
        // .addItem("Off",0)
        // .addItem("On",1)
        .activate(0)
        .setVisible(false)
        ;
  }

  void createDropdown(String name){

    // dropdownColors.setActive((int)color(150, 170, 200)); //bg color of box when pressed
    // dropdownColors.setForeground((int)color(177, 184, 193)); //when hovering over any box (primary or dropdown)
    // dropdownColors.setBackground((int)color(31,69,110)); //bg color of boxes (including primary)
    // dropdownColors.setCaptionLabel((int)color(1, 18, 41)); //color of text in primary box
    // dropdownColors.setValueLabel((int)color(100)); //color of text in all dropdown boxes
    // cp5_networking.setColor(dropdownColors);

    cp5_networking.addScrollableList(name)
        .setOpen(false)

        // dropdownColors.setActive((int)color(150, 170, 200)); //bg color of box when pressed
        // dropdownColors.setForeground((int)color(125)); //when hovering over any box (primary or dropdown)
        // dropdownColors.setBackground((int)color(255)); //bg color of boxes (including primary)
        // dropdownColors.setCaptionLabel((int)color(1, 18, 41)); //color of text in primary box
        // // dropdownColors.setValueLabel((int)color(1, 18, 41)); //color of text in all dropdown boxes
        // dropdownColors.setValueLabel((int)color(100)); //color of text in all dropdown boxes

        .setColorBackground(color(31,69,110)) // text field bg color
        .setColorValueLabel(color(255))       // text color
        .setColorCaptionLabel(color(255))
        .setColorForeground(color(125))    // border color when not selected
        .setColorActive(color(150, 170, 200))       // border color when selected
        // .setColorCursor(color(26,26,26))

        .setSize(100,200)// + maxFreqList.size())
        .setBarHeight(navH-4) //height of top/primary bar
        .setItemHeight(navH-4) //height of all item/dropdown bars
        .addItems(dataTypes) // used to be .addItems(maxFreqList)
        .setVisible(false)
        ;
    cp5_networking.getController(name)
      .getCaptionLabel() //the caption label is the text object in the primary bar
      .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
      .setText("None")
      .setFont(h4)
      .setSize(14)
      .getStyle() //need to grab style before affecting the paddingTop
      .setPaddingTop(4)
      ;
    cp5_networking.getController(name)
      .getValueLabel() //the value label is connected to the text objects in the dropdown item bars
      .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
      .setText("None")
      .setFont(h5)
      .setSize(12) //set the font size of the item bars to 14pt
      .getStyle() //need to grab style before affecting the paddingTop
      .setPaddingTop(3) //4-pixel vertical offset to center text
      ;

  }



  void screenResized(){
    super.screenResized();
    column0 = x+w/20;
    // column1 = x+3*w/10;
    // column2 = x+5*w/10;
    // column3 = x+7*w/10;

    column1 = x+12*w/40;
    column2 = x+21*w/40;
    column3 = x+30*w/40;

    row0 = y+h/4+10;
    row1 = y+4*h/10;
    row2 = y+5*h/10;
    row3 = y+6*h/10;
    row4 = y+7*h/10;
    row5 = y+8*h/10;
    int offset = 17;

    startButton.setPos(x + w/2 - 70, y + h - 40 );
    cp5_networking.get(Textfield.class, "osc_ip1").setPosition(column1, row2 - offset);
    cp5_networking.get(Textfield.class, "osc_port1").setPosition(column1, row3 - offset);
    cp5_networking.get(Textfield.class, "osc_address1").setPosition(column1, row4 - offset);
    cp5_networking.get(Textfield.class, "osc_ip2").setPosition(column2, row2 - offset);
    cp5_networking.get(Textfield.class, "osc_port2").setPosition(column2, row3 - offset);
    cp5_networking.get(Textfield.class, "osc_address2").setPosition(column2, row4 - offset);
    cp5_networking.get(Textfield.class, "osc_ip3").setPosition(column3, row2 - offset);
    cp5_networking.get(Textfield.class, "osc_port3").setPosition(column3, row3 - offset);
    cp5_networking.get(Textfield.class, "osc_address3").setPosition(column3, row4 - offset);
    cp5_networking.get(Textfield.class, "udp_ip1").setPosition(column1, row2 - offset);
    cp5_networking.get(Textfield.class, "udp_port1").setPosition(column1, row3 - offset);
    cp5_networking.get(Textfield.class, "udp_ip2").setPosition(column2, row2 - offset);
    cp5_networking.get(Textfield.class, "udp_port2").setPosition(column2, row3 - offset);
    cp5_networking.get(Textfield.class, "udp_ip3").setPosition(column3, row2 - offset);
    cp5_networking.get(Textfield.class, "udp_port3").setPosition(column3, row3 - offset);
    cp5_networking.get(Textfield.class, "lsl_name1").setPosition(column1,row2 - offset);
    cp5_networking.get(Textfield.class, "lsl_type1").setPosition(column1,row3 - offset);
    cp5_networking.get(Textfield.class, "lsl_numchan1").setPosition(column1,row4 - offset);
    cp5_networking.get(Textfield.class, "lsl_name2").setPosition(column2,row2 - offset);
    cp5_networking.get(Textfield.class, "lsl_type2").setPosition(column2,row3 - offset);
    cp5_networking.get(Textfield.class, "lsl_numchan2").setPosition(column2,row4 - offset);
    cp5_networking.get(Textfield.class, "lsl_name3").setPosition(column3,row2 - offset);
    cp5_networking.get(Textfield.class, "lsl_type3").setPosition(column3,row3 - offset);
    cp5_networking.get(Textfield.class, "lsl_numchan3").setPosition(column3,row4 - offset);

    if (protocolMode.equals("OSC") || protocolMode.equals("LSL")){
      cp5_networking.get(RadioButton.class, "filter1").setPosition(column1, row5 - 10);
      cp5_networking.get(RadioButton.class, "filter2").setPosition(column2, row5 - 10);
      cp5_networking.get(RadioButton.class, "filter3").setPosition(column3, row5 - 10);
    } else if (protocolMode.equals("UDP")){
      cp5_networking.get(RadioButton.class, "filter1").setPosition(column1, row4 - 10);
      cp5_networking.get(RadioButton.class, "filter2").setPosition(column2, row4 - 10);
      cp5_networking.get(RadioButton.class, "filter3").setPosition(column3, row4 - 10);
    }

    cp5_networking.get(ScrollableList.class, "dataType1").setPosition(column1, row1-offset);
    cp5_networking.get(ScrollableList.class, "dataType2").setPosition(column2, row1-offset);
    cp5_networking.get(ScrollableList.class, "dataType3").setPosition(column3, row1-offset);
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
    if(startButton.isMouseHere()){
      startButton.setIsActive(true);
    }


  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    if(startButton.isActive && startButton.isMouseHere()){
      if(!networkActive){
        turnOnButton();
        initializeStreams();
        startNetwork();
      }else{
        turnOffButton();
        stopNetwork();
      }
    }
    startButton.setIsActive(false);
  }
  void hideElements(){
    cp5_networking.get(Textfield.class, "osc_ip1").setVisible(false);
    cp5_networking.get(Textfield.class, "osc_port1").setVisible(false);
    cp5_networking.get(Textfield.class, "osc_address1").setVisible(false);
    cp5_networking.get(Textfield.class, "osc_ip2").setVisible(false);
    cp5_networking.get(Textfield.class, "osc_port2").setVisible(false);
    cp5_networking.get(Textfield.class, "osc_address2").setVisible(false);
    cp5_networking.get(Textfield.class, "osc_ip3").setVisible(false);
    cp5_networking.get(Textfield.class, "osc_port3").setVisible(false);
    cp5_networking.get(Textfield.class, "osc_address3").setVisible(false);
    cp5_networking.get(Textfield.class, "udp_ip1").setVisible(false);
    cp5_networking.get(Textfield.class, "udp_port1").setVisible(false);
    cp5_networking.get(Textfield.class, "udp_ip2").setVisible(false);
    cp5_networking.get(Textfield.class, "udp_port2").setVisible(false);
    cp5_networking.get(Textfield.class, "udp_ip3").setVisible(false);
    cp5_networking.get(Textfield.class, "udp_port3").setVisible(false);
    cp5_networking.get(Textfield.class, "lsl_name1").setVisible(false);
    cp5_networking.get(Textfield.class, "lsl_type1").setVisible(false);
    cp5_networking.get(Textfield.class, "lsl_numchan1").setVisible(false);
    cp5_networking.get(Textfield.class, "lsl_name2").setVisible(false);
    cp5_networking.get(Textfield.class, "lsl_type2").setVisible(false);
    cp5_networking.get(Textfield.class, "lsl_numchan2").setVisible(false);
    cp5_networking.get(Textfield.class, "lsl_name3").setVisible(false);
    cp5_networking.get(Textfield.class, "lsl_type3").setVisible(false);
    cp5_networking.get(Textfield.class, "lsl_numchan3").setVisible(false);
    cp5_networking.get(ScrollableList.class, "dataType1").setVisible(false);
    cp5_networking.get(ScrollableList.class, "dataType2").setVisible(false);
    cp5_networking.get(ScrollableList.class, "dataType3").setVisible(false);
    cp5_networking.get(RadioButton.class, "filter1").setVisible(false);
    cp5_networking.get(RadioButton.class, "filter2").setVisible(false);
    cp5_networking.get(RadioButton.class, "filter3").setVisible(false);
  }

  void turnOffButton(){
    networkActive = false;
    startButton.setColorNotPressed(color(184,220,105));
    startButton.setString("Start");
  }

  void turnOnButton(){
    networkActive = true;
    startButton.setColorNotPressed(color(224, 56, 45));
    startButton.setString("Stop");
  }


  /* -----NETWORKING MECHANISMS ---- */

  void initializeStreams(){
    String ip;
    int port;
    String address;
    int filt_pos;
    String name;
    int nChanLSL;
    String type;
    String dt1="None";
    String dt2="None";
    String dt3="None";
    switch ((int)cp5_networking.get(ScrollableList.class, "dataType1").getValue()){
      case 0 : dt1 = "None";
        break;
      case 1 : dt1 = "TimeSeries";
        break;
      case 2 : dt1 = "FFT";
        break;
      case 3 : dt1 = "Widget";
        break;
    }
    switch ((int)cp5_networking.get(ScrollableList.class, "dataType2").getValue()){
      case 0 : dt2 = "None";
        break;
      case 1 : dt2 = "TimeSeries";
        break;
      case 2 : dt2 = "FFT";
        break;
      case 3 : dt2 = "Widget";
        break;
    }
    switch ((int)cp5_networking.get(ScrollableList.class, "dataType3").getValue()){
      case 0 : dt3 = "None";
        break;
      case 1 : dt3 = "TimeSeries";
        break;
      case 2 : dt3 = "FFT";
        break;
      case 3 : dt3 = "Widget";
        break;
    }
    if (protocolMode.equals("OSC")){
      if(!dt1.equals("None")){
        ip = cp5_networking.get(Textfield.class, "osc_ip1").getText();
        port = Integer.parseInt(cp5_networking.get(Textfield.class, "osc_port1").getText());
        address = cp5_networking.get(Textfield.class, "osc_address1").getText();
        filt_pos = (int)cp5_networking.get(RadioButton.class, "filter1").getValue();
        stream1 = new Stream(dt1,ip,port,address,filt_pos);
      }else{
        stream1 = null;
      }
      if(!dt2.equals("None")){
        ip = cp5_networking.get(Textfield.class, "osc_ip2").getText();
        port = Integer.parseInt(cp5_networking.get(Textfield.class, "osc_port2").getText());
        address = cp5_networking.get(Textfield.class, "osc_address2").getText();
        filt_pos = (int)cp5_networking.get(RadioButton.class, "filter2").getValue();
        stream2 = new Stream(dt2, ip,port,address,filt_pos);
      }else{
        stream2 = null;
      }
      if(!dt3.equals("None")){
        ip = cp5_networking.get(Textfield.class, "osc_ip3").getText();
        port = Integer.parseInt(cp5_networking.get(Textfield.class, "osc_port3").getText());
        address = cp5_networking.get(Textfield.class, "osc_address3").getText();
        filt_pos = (int)cp5_networking.get(RadioButton.class, "filter3").getValue();
        stream3 = new Stream(dt3, ip,port,address,filt_pos);
      }else{
        stream3 = null;
      }
    }else if (protocolMode.equals("UDP")){
      if(!dt1.equals("None")){
        ip = cp5_networking.get(Textfield.class, "udp_ip1").getText();
        port = Integer.parseInt(cp5_networking.get(Textfield.class, "udp_port1").getText());
        filt_pos = (int)cp5_networking.get(RadioButton.class, "filter1").getValue();
        stream1 = new Stream(dt1,ip,port,filt_pos);
      }else{
        stream1 = null;
      }
      if(!dt2.equals("None")){
        ip = cp5_networking.get(Textfield.class, "udp_ip2").getText();
        port = Integer.parseInt(cp5_networking.get(Textfield.class, "udp_port2").getText());
        filt_pos = (int)cp5_networking.get(RadioButton.class, "filter2").getValue();
        stream2 = new Stream(dt2,ip,port,filt_pos);
      }else{
        stream2 = null;
      }
      if(!dt3.equals("None")){
        ip = cp5_networking.get(Textfield.class, "udp_ip3").getText();
        port = Integer.parseInt(cp5_networking.get(Textfield.class, "udp_port3").getText());
        filt_pos = (int)cp5_networking.get(RadioButton.class, "filter3").getValue();
        stream3 = new Stream(dt3,ip,port,filt_pos);
      }else{
        stream3 = null;
      }
    }else if (protocolMode.equals("LSL")){
      if(!dt1.equals("None")){
        name = cp5_networking.get(Textfield.class, "lsl_name1").getText();
        type = cp5_networking.get(Textfield.class, "lsl_type1").getText();
        nChanLSL = Integer.parseInt(cp5_networking.get(Textfield.class, "lsl_numchan1").getText());
        filt_pos = (int)cp5_networking.get(RadioButton.class, "filter1").getValue();
        stream1 = new Stream(dt1,name,type,nChanLSL,filt_pos);
      }else{
        stream1 = null;
      }
      if(!dt2.equals("None")){
        name = cp5_networking.get(Textfield.class, "lsl_name2").getText();
        type = cp5_networking.get(Textfield.class, "lsl_type2").getText();
        nChanLSL = Integer.parseInt(cp5_networking.get(Textfield.class, "lsl_numchan2").getText());
        filt_pos = (int)cp5_networking.get(RadioButton.class, "filter2").getValue();
        stream2 = new Stream(dt2,name,type,nChanLSL,filt_pos);
      }else{
        stream2 = null;
      }
      if(!dt3.equals("None")){
        name = cp5_networking.get(Textfield.class, "lsl_name3").getText();
        type = cp5_networking.get(Textfield.class, "lsl_type3").getText();
        nChanLSL = Integer.parseInt(cp5_networking.get(Textfield.class, "lsl_numchan3").getText());
        filt_pos = (int)cp5_networking.get(RadioButton.class, "filter3").getValue();
        stream3 = new Stream(dt3,name,type,nChanLSL,filt_pos);
      }else{
        stream3 = null;
      }
    }
  }


  void startNetwork(){
    if(stream1!=null){
      stream1.start();
    }
    if(stream2!=null){
      stream2.start();
    }
    if(stream3!=null){
      stream3.start();
    }
  }

  void stopNetwork(){
    if (stream1!=null){
      stream1.quit();
      stream1=null;
    }
    if (stream2!=null){
      stream2.quit();
      stream2=null;
    }
    if (stream3!=null){
      stream3.quit();
      stream3=null;
    }
  }

  void shutDown(){
    hideElements();
    turnOffButton();

  }

  void clearCP5(){
    //clears all controllers from ControlP5 instance...
    w_networking.cp5_networking.dispose();
    println("clearing cp5_networking...");
  }

  void closeAllDropdowns(){
    dataDropdownsShouldBeClosed = true;
    w_networking.cp5_networking.get(ScrollableList.class, "dataType1").close();
    w_networking.cp5_networking.get(ScrollableList.class, "dataType2").close();
    w_networking.cp5_networking.get(ScrollableList.class, "dataType3").close();
  }

};

class Stream extends Thread{
  String protocol;
  String dataType;
  String ip;
  int port;
  String address;
  int filter;
  String streamType;
  String streamName;
  int nChanLSL;

  Boolean isStreaming;
  Boolean newData = false;
  int numChan = nchan;
  // Data buffers
  int start = dataBuffY_filtY_uV[0].length-11;
  int end = dataBuffY_filtY_uV[0].length-1;
  int bufferLen = end-start;
  float[] dataToSend = new float[numChan];

  //OSC Objects
  OscP5 osc;
  NetAddress netaddress;
  OscMessage msg;
  //UDP Objects
  UDP udp;
  ByteBuffer buffer;
  // LSL objects
  LSL.StreamInfo info_data;
  LSL.StreamOutlet outlet_data;
  LSL.StreamInfo info_aux;
  LSL.StreamOutlet outlet_aux;



  /* OSC Stream */
  Stream(String dataType, String ip, int port, String address, int filter){
    this.protocol = "OSC";
    this.dataType = dataType;
    this.ip = ip;
    this.port = port;
    this.address = address;
    this.filter = filter;
    this.isStreaming = false;
    try{
      closeNetwork(); //make sure everything is closed!
    }catch (Exception e){
    }
  }
  /*UDP Stream */
  Stream(String dataType, String ip, int port, int filter){
    this.protocol = "UDP";
    this.dataType = dataType;
    this.ip = ip;
    this.port = port;
    this.filter = filter;
    this.isStreaming = false;
    if(this.dataType.equals("TimeSeries")){
      buffer = ByteBuffer.allocate(4*numChan);
    }else{
      buffer = ByteBuffer.allocate(4*126);
    }
    try{
      closeNetwork(); //make sure everything is closed!
    }catch (Exception e){
    }
  }  /* LSL Stream */
  Stream(String dataType, String streamName, String streamType, int nChanLSL, int filter){
    this.protocol = "LSL";
    this.dataType = dataType;
    this.streamName = streamName;
    this.streamType = streamType;
    this.nChanLSL = nChanLSL;
    this.filter = filter;
    this.isStreaming = false;
    try{
      closeNetwork(); //make sure everything is closed!
    }catch (Exception e){
    }
  }
  void start(){
    this.isStreaming = true;
    if(!this.protocol.equals("LSL")){
      super.start();
    }else{
      openNetwork();
    }
  }

  void run(){
    if (this.protocol.equals("OSC")){
      openNetwork();
      while(this.isStreaming){
        if(!isRunning){
          try{
            Thread.sleep(1);
            Boolean a = isRunning; //weird hack~
          }catch (InterruptedException e){
            println(e);
          }
        }else{
          try{
            Thread.sleep(1);
            newData = dataProcessing.newDataToSend;
          }catch (InterruptedException e){
            println(e);
          }
        }
        if (newData && isRunning){
          if (this.dataType.equals("TimeSeries")){
            if(filter==0){
              for(int i=0;i<bufferLen;i++){
                msg.clearArguments();
                for(int j=0;j<numChan;j++){
                  msg.add(yLittleBuff_uV[j][i]);
                }
               try{
                 this.osc.send(msg,this.netaddress);
               }catch (Exception e){
                 println(e);
               }
             }
            }else if (filter==1){
              for(int i=0;i<bufferLen;i++){
                msg.clearArguments();
                for(int j=0;j<numChan;j++){
                  msg.add(dataBuffY_filtY_uV[j][start+i]);
                }
               try{
                 this.osc.send(msg,this.netaddress);
               }catch (Exception e){
                 println(e);
               }
             }
           }
          }else if (this.dataType.equals("FFT")){
            for (int i=0;i<numChan;i++){
              msg.clearArguments();
              msg.add(i+1);
              for (int j=0;j<125;j++){
                msg.add(fftBuff[i].getBand(j));
              }
              try{
                this.osc.send(msg,this.netaddress);
              }catch (Exception e){
                println(e);
              }
            }
          }else if (this.dataType.equals("WIDGET")){
            // insert widget send here
          }
          dataProcessing.newDataToSend = false;
        }
      }
    }
    else if (this.protocol.equals("UDP")){
      openNetwork();
      while(this.isStreaming){
        if(!isRunning){
          try{
            Thread.sleep(1);
            Boolean a = isRunning; //weird hack~
          }catch (InterruptedException e){
            println(e);
          }
        }else{
          try{
            Thread.sleep(1);
            newData = dataProcessing.newDataToSend;
          }catch (InterruptedException e){
            println(e);
          }
        }
        if (newData && isRunning){
          if (this.dataType.equals("TimeSeries")){
            if(filter==0){
              for(int i=0;i<bufferLen;i++){
                buffer.rewind();
                for(int j=0;j<numChan;j++){
                  buffer.putFloat(yLittleBuff_uV[j][i]);
                }
                this.udp.send(buffer.array(),this.ip,this.port);
               }
             }else if (filter==1){
              for(int i=0;i<bufferLen;i++){
                buffer.rewind();
                for(int j=0;j<numChan;j++){
                  buffer.putFloat(dataBuffY_filtY_uV[j][start+i]);
                }
                this.udp.send(buffer.array(),this.ip,this.port);
             }
           }
          }else if (this.dataType.equals("FFT")){
            for (int i=0;i<numChan;i++){
              buffer.rewind();
              buffer.putFloat(i+1);
              for (int j=0;j<125;j++){
                buffer.putFloat(fftBuff[i].getBand(j));
              }
              try{
                this.udp.send(buffer.array(),this.ip,this.port);
              }catch (Exception e){
                println(e);
              }
            }
          }else if (this.dataType.equals("WIDGET")){
            // insert widget send here
          }
          dataProcessing.newDataToSend = false;
        }
      }

    }else if (this.protocol.equals("LSL")){
      newData = dataProcessing.newDataToSend;
      if (newData && isRunning){
        if (this.dataType.equals("TimeSeries")){
          if(filter==0){
             for(int i=0;i<bufferLen;i++){
               for(int j=0;j<numChan;j++){
                 dataToSend[j] = yLittleBuff_uV[j][i];
               }
               outlet_data.push_sample(dataToSend);
             }
          }else if (filter==1){
            for(int i=0;i<bufferLen;i++){
              for(int j=0;j<numChan;j++){
                dataToSend[j] = dataBuffY_filtY_uV[j][i];
              }
              outlet_data.push_sample(dataToSend);
            }
           }
         }
         dataProcessing.newDataToSend = false;
       }

    }
  }
  void quit(){
    this.isStreaming=false;
    closeNetwork();
    interrupt();
  }

  void closeNetwork(){
    if (this.protocol.equals("OSC")){
      try{
        this.osc.stop();
      }catch(Exception e){
        println(e);
      }
    }else if (this.protocol.equals("UDP")){
        this.udp.close();
    }else if (this.protocol.equals("LSL")){
      outlet_data.close();
    }
  }

  void openNetwork(){
    println(getAttributes());
    if(this.protocol.equals("OSC")){
      //Possibly enter a nice custom exception here
      this.osc = new OscP5(this,this.port + 1000);
      this.netaddress = new NetAddress(this.ip,this.port);
      this.msg = new OscMessage(this.address);
    }else if (this.protocol.equals("UDP")){
      this.udp = new UDP(this);
      // this.udp.broadcast(true);
      this.udp.setBuffer(1024);
      this.udp.listen(false);
      this.udp.log(false);
      println("UDP successfully connected");
      output("UDP successfully connected");
    }else if (this.protocol.equals("LSL")){
      String stream_id = "q4asdgdsg";
      info_data = new LSL.StreamInfo(
                            this.streamName,
                            this.streamType,
                            this.nChanLSL,
                            openBCI.get_fs_Hz(),
                            LSL.ChannelFormat.float32,
                            stream_id
                          );
      outlet_data = new LSL.StreamOutlet(info_data);
    }
  }

  List getAttributes(){
    List attributes = new ArrayList();
    if (this.protocol.equals("OSC")){
      attributes.add(this.dataType);
      attributes.add(this.ip);
      attributes.add(this.port);
      attributes.add(this.address);
      attributes.add(this.filter);
    }else if(this.protocol.equals("UDP")){
      attributes.add(this.dataType);
      attributes.add(this.ip);
      attributes.add(this.port);
      attributes.add(this.filter);
    }
    else if (this.protocol.equals("LSL")){
      attributes.add(this.dataType);
      attributes.add(this.streamName);
      attributes.add(this.streamType);
      attributes.add(this.nChanLSL);
      attributes.add(this.filter);
    }
    return attributes;
  }
}

/* Dropdown Menu Callback Functions */
/**
 * @description Sets the selected protocol mode from the widget's dropdown menu
 * @param `n` {int} - Index of protocol item selected in menu
 */
void Protocol(int n){
  if (n == 0){
    w_networking.protocolMode = "OSC";
  }else if (n==1){
    w_networking.protocolMode = "UDP";
  }else if (n==2){
    w_networking.protocolMode = "LSL";
  }
  println(w_networking.protocolMode + " selected from Protocol Menu");
  w_networking.screenResized();
  w_networking.showCP5();
  closeAllDropdowns();


}

void dataType1(int n){
  w_networking.closeAllDropdowns();
}
void dataType2(int n){
  w_networking.closeAllDropdowns();
}
void dataType3(int n){
  w_networking.closeAllDropdowns();
}
