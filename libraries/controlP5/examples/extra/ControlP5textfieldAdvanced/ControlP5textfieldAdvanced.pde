/**
 * ControlP5 textfield (advanced)
 *
 * demonstrates how to use keepFocus, setText, getText, getTextList,
 * clear, setAutoClear, isAutoClear and submit.
 *
 * by andreas schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 * 
 */

import controlP5.*;

ControlP5 cp5;

String textValue = "";

Textfield myTextfield;

void setup() {
  size(400, 600);

  cp5 = new ControlP5(this);
  myTextfield = cp5.addTextfield("textinput")
                   .setPosition(100, 200)
                   .setSize(200, 20)
                   .setFocus(true)
                   ;

  cp5.addTextfield("textValue")
     .setPosition(100, 300)
     .setSize(200, 20)
     ;

  // use setAutoClear(true/false) to clear a textfield or keep text displayed in
  // a textfield after pressing return.
  myTextfield.setAutoClear(true).keepFocus(true);

  cp5.addButton("clear", 0, 20, 200, 70, 20);
  cp5.addButton("submit", 0, 310, 200, 60, 20);
  cp5.addButton("performTextfieldActions", 0, 20, 100, 150, 20);
  cp5.addToggle("toggleAutoClear", true, 180, 100, 90, 20).setCaptionLabel("Auto Clear");
  cp5.addToggle("toggleKeepFocus", true, 280, 100, 90, 20).setCaptionLabel("Keep Focus");

  
}

void draw() {
  background(0);
}

void toggleAutoClear(boolean theFlag) {
  myTextfield.setAutoClear(theFlag);
}

void toggleKeepFocus(boolean theFlag) {
  myTextfield.keepFocus(theFlag);
}

void clear(int theValue) {
  myTextfield.clear();
}

void submit(int theValue) {
  myTextfield.submit();
}


void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    Textfield t = (Textfield)theEvent.getController();

    println("controlEvent: accessing a string from controller '"
      +t.getName()+"': "+t.getStringValue()
      );

    // Textfield.isAutoClear() must be true
    print("controlEvent: trying to setText, ");

    t.setText("controlEvent: changing text.");
    if (t.isAutoClear()==false) {
      println(" success!");
    } 
    else {
      println(" but Textfield.isAutoClear() is false, could not setText here.");
    }
  }
}

void performTextfieldActions() {
  println("\n");
  // Textfield.getText();
  println("the current text of myTextfield: "+myTextfield.getText());
  println("the current value of textValue: "+textValue);
  // Textfield.setText();
  myTextfield.setText("changed the text of a textfield");
  println("changing text of myTextfield to: "+myTextfield.getText());
  // Textfield.getTextList();
  println("the textlist of myTextfield has "+myTextfield.getTextList().length+" items.");
  for (int i=0;i<myTextfield.getTextList().length;i++) {
    println("\t"+myTextfield.getTextList()[i]);
  }
  println("\n");
}




public void textinput(String theText) {
  // receiving text from controller textinput
  println("a textfield event for controller 'textinput': "+theText);
}


