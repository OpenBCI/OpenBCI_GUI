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
  CallbackListener net_cb;

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


  W_networking(PApplet _parent){
    super(_parent);
    dataTypes = Arrays.asList("None", "TimeSeries", "FFT", "Widget");
    protocolMode = "OSC"; //default to OSC
    addDropdown("Protocol", "Protocol", Arrays.asList("OSC", "UDP", "LSL","Widget"), protocolIndex);
    initialize_UI();

  }

  /* ----- USER INTERFACE ----- */


  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)


    pushStyle();
    showCP5();

    fill(0,0,0);                  // Background fill: white
    textFont(h1,20);
    text("Stream 1",column1,row0);
    text("Stream 2",column2,row0);
    text("Stream 3",column3,row0);
    text("Data Type", column0,row1);


    if(protocolMode.equals("OSC")){
      textFont(f4,40);
      text("OSC", x+10,y+h/8);
      textFont(h1,20);
      text("IP", column0,row2);
      text("Port", column0,row3);
      text("Address",column0,row4);
      text("Filter",column0,row5);
    }
    // UDP


    popStyle();

  }

  void initialize_UI(){

    /* Initialize CP5 and callback */
    cp5_networking = new ControlP5(pApplet);
    callback_init();


    /* Textfields */

    // OSC
    createTextFields("osc_ip1","localhost");
    createTextFields("osc_port1","12345");
    createTextFields("osc_address1","/openbci");
    createTextFields("osc_ip2","localhost");
    createTextFields("osc_port2","12345");
    createTextFields("osc_address2","/openbci");
    createTextFields("osc_ip3","localhost");
    createTextFields("osc_port3","12345");
    createTextFields("osc_address3","/openbci");

    // General
    createDropdown("dataType1");
    createDropdown("dataType2");
    createDropdown("dataType3");

    createRadioButtons("filter1");
    createRadioButtons("filter2");
    createRadioButtons("filter3");





  }

  void showCP5(){

  osc_visible=false;
  udp_visible=false;
  lsl_visible=false;

  if(protocolMode.equals("OSC")){
    osc_visible = true;
  }
  // int buttonRow=5;
  // if (protocolMode==0){
  //   buttonRow = row5;
  // }else if (protocolMode==1){
  //   buttonRow = row4;
  // }else if (protocolMode==2){
  //   buttonRow = row4;
  // }

  cp5_networking.get(Textfield.class, "osc_ip1").setVisible(osc_visible);
  cp5_networking.get(Textfield.class, "osc_port1").setVisible(osc_visible);
  cp5_networking.get(Textfield.class, "osc_address1").setVisible(osc_visible);
  cp5_networking.get(Textfield.class, "osc_ip2").setVisible(osc_visible);
  cp5_networking.get(Textfield.class, "osc_port2").setVisible(osc_visible);
  cp5_networking.get(Textfield.class, "osc_address2").setVisible(osc_visible);
  cp5_networking.get(Textfield.class, "osc_ip3").setVisible(osc_visible);
  cp5_networking.get(Textfield.class, "osc_port3").setVisible(osc_visible);
  cp5_networking.get(Textfield.class, "osc_address3").setVisible(osc_visible);
  // cp5_networking.get(Textfield.class, "udp_ip1").setVisible(udp_visible);
  // cp5_networking.get(Textfield.class, "udp_port1").setVisible(udp_visible);
  // cp5_networking.get(Textfield.class, "udp_ip2").setVisible(udp_visible);
  // cp5_networking.get(Textfield.class, "udp_port2").setVisible(udp_visible);
  // cp5_networking.get(Textfield.class, "udp_ip3").setVisible(udp_visible);
  // cp5_networking.get(Textfield.class, "udp_port3").setVisible(udp_visible);
  // cp5_networking.get(Textfield.class, "lsl_name1").setVisible(lsl_visible);
  // cp5_networking.get(Textfield.class, "lsl_name2").setVisible(lsl_visible);
  // cp5_networking.get(Textfield.class, "lsl_name3").setVisible(lsl_visible);
  //
  // /* TEMPORARY DATA TYPE TEXTFIELD */
  // cp5_networking.get(Textfield.class, "datatype_stream1").setVisible(true);
  // cp5_networking.get(Textfield.class, "datatype_stream2").setVisible(true);
  // cp5_networking.get(Textfield.class, "datatype_stream3").setVisible(true);

  cp5_networking.get(ScrollableList.class, "dataType1").setVisible(true);
  cp5_networking.get(ScrollableList.class, "dataType2").setVisible(true);
  cp5_networking.get(ScrollableList.class, "dataType3").setVisible(true);


  cp5_networking.get(RadioButton.class, "filter1").setVisible(true);
  cp5_networking.get(RadioButton.class, "filter2").setVisible(true);
  cp5_networking.get(RadioButton.class, "filter3").setVisible(true);

}

  /**
 * @description Initializes the callback function for the cp5_networking instance
 *
 */
  void callback_init(){
    net_cb = new CallbackListener() { //used by ControlP5 to clear text field on double-click
      public void controlEvent(CallbackEvent theEvent) {
        if (cp5_networking.isMouseOver(cp5_networking.get(Textfield.class, "osc_ip1"))){
            cp5_networking.get(Textfield.class, "osc_ip1").clear();
        }else if (cp5_networking.isMouseOver(cp5_networking.get(Textfield.class, "osc_port1"))){
            cp5_networking.get(Textfield.class, "osc_port1").clear();
        }else if (cp5_networking.isMouseOver(cp5_networking.get(Textfield.class, "osc_address1"))){
            cp5_networking.get(Textfield.class, "osc_address1").clear();
        }else if (cp5_networking.isMouseOver(cp5_networking.get(Textfield.class, "osc_ip2"))){
            cp5_networking.get(Textfield.class, "osc_ip2").clear();
        }else if (cp5_networking.isMouseOver(cp5_networking.get(Textfield.class, "osc_port2"))){
            cp5_networking.get(Textfield.class, "osc_port2").clear();
        }else if (cp5_networking.isMouseOver(cp5_networking.get(Textfield.class, "osc_address2"))){
            cp5_networking.get(Textfield.class, "osc_address2").clear();
        }else if (cp5_networking.isMouseOver(cp5_networking.get(Textfield.class, "osc_ip3"))){
            cp5_networking.get(Textfield.class, "osc_ip3").clear();
        }else if (cp5_networking.isMouseOver(cp5_networking.get(Textfield.class, "osc_port3"))){
            cp5_networking.get(Textfield.class, "osc_port3").clear();
        }else if (cp5_networking.isMouseOver(cp5_networking.get(Textfield.class, "osc_address3"))){
            cp5_networking.get(Textfield.class, "osc_address3").clear();}
      }
    };
  }


  void createTextFields(String name, String default_text){
    cp5_networking.addTextfield(name)
      .align(10,100,10,100)                   // Alignment
      .setSize(80,20)                         // Size of textfield
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
      .onDoublePress(net_cb)                  // Clear on double click
      .setVisible(false)                      // Initially hidden
      .setAutoClear(true)                     // Autoclear
      ;
  }
  void createRadioButtons(String name){
    String id = name.substring(name.length()-1);
    cp5_networking.addRadioButton(name)
        .setSize(10,10)
        .setColorForeground(color(120))
        .setColorActive(color(184,220,105))
        .setColorLabel(color(0))
        .setItemsPerRow(2)
        .setSpacingColumn(40)
        .addItem("Off" + id,0)
        .addItem("On" + id,1)
        .activate(0)
        .setVisible(false)
        ;
  }

  void createDropdown(String name){
    cp5_networking.addScrollableList(name)
        .setOpen(false)
        .setColor(dropdownColors)
        .setSize(80,200)// + maxFreqList.size())
        .setBarHeight(navH-4) //height of top/primary bar
        .setItemHeight(navH-4) //height of all item/dropdown bars
        .addItems(dataTypes) // used to be .addItems(maxFreqList)
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
    column1 = x+3*w/10;
    column2 = x+5*w/10;
    column3 = x+7*w/10;

    row0 = y+h/4-10;
    row1 = y+4*h/10;
    row2 = y+5*h/10;
    row3 = y+6*h/10;
    row4 = y+7*h/10;
    row5 = y+8*h/10;
    int offset = 17;
    cp5_networking.get(Textfield.class, "osc_ip1").setPosition(column1, row2 - offset);
    cp5_networking.get(Textfield.class, "osc_port1").setPosition(column1, row3 - offset);
    cp5_networking.get(Textfield.class, "osc_address1").setPosition(column1, row4 - offset);
    cp5_networking.get(Textfield.class, "osc_ip2").setPosition(column2, row2 - offset);
    cp5_networking.get(Textfield.class, "osc_port2").setPosition(column2, row3 - offset);
    cp5_networking.get(Textfield.class, "osc_address2").setPosition(column2, row4 - offset);
    cp5_networking.get(Textfield.class, "osc_ip3").setPosition(column3, row2 - offset);
    cp5_networking.get(Textfield.class, "osc_port3").setPosition(column3, row3 - offset);
    cp5_networking.get(Textfield.class, "osc_address3").setPosition(column3, row4 - offset);
    cp5_networking.get(RadioButton.class, "filter1").setPosition(column1, row5 - 10);
    cp5_networking.get(RadioButton.class, "filter2").setPosition(column2, row5 - 10);
    cp5_networking.get(RadioButton.class, "filter3").setPosition(column3, row5 - 10);
    cp5_networking.get(ScrollableList.class, "dataType1").setPosition(column1, row1-offset);
    cp5_networking.get(ScrollableList.class, "dataType2").setPosition(column2, row1-offset);
    cp5_networking.get(ScrollableList.class, "dataType3").setPosition(column3, row1-offset);
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...


  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...

  }

  /* -----NETWORKING MECHANISMS ---- */

  void update(){
    super.update();

  }

};


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

  // w_networking.showCP5();
  closeAllDropdowns();
}
