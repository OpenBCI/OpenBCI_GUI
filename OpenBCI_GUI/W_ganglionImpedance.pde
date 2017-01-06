
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

class W_ganglionImpedance extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...

  Button startStopCheck;
  int padding = 24;

  W_ganglionImpedance(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    // addDropdown("Dropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
    // addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
    // addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

    startStopCheck = new Button (x + padding, y + padding, 200, navHeight, "Start Impedance Check", 12);
    startStopCheck.setFont(p4, 14);

  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...

  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    pushStyle();

    startStopCheck.draw();

    // //without dividing by 2
    // for(int i = 0; i < ganglion.impedanceArray.length; i++){
    //   String toPrint;
    //   if(i == 0){
    //     toPrint = "Reference Impedance = " + ganglion.impedanceArray[i] + " k\u2126";
    //   } else {
    //     toPrint = "Channel[" + i + "] Impedance = " + ganglion.impedanceArray[i] + " k\u2126";
    //   }
    //   text(toPrint, x + 10, y + 60 + 20*(i));
    // }

    //divide by 2 ... we do this assuming that the D_G (driven ground) electrode is "comprable in impedance" to the electrode being used.
    fill(bgColor);
    textFont(p4, 14);
    for(int i = 0; i < ganglion.impedanceArray.length; i++){
      String toPrint;
      float adjustedImpedance = ganglion.impedanceArray[i]/2.0;
      if(i == 0){
        toPrint = "Reference Impedance \u2248 " + adjustedImpedance + " k\u2126";
      } else {
        toPrint = "Channel[" + i + "] Impedance \u2248 " + adjustedImpedance + " k\u2126";
      }
      text(toPrint, x + padding + 40, y + padding*2 + 12 + startStopCheck.but_dy + padding*(i));

      pushStyle();
      stroke(bgColor);
      //change the fill color based on the signal quality...
      if(adjustedImpedance <= 0){ //no data yet...
        fill(255);
      } else if(adjustedImpedance > 0 && adjustedImpedance <= 10){ //very good signal quality
        fill(49, 113, 89); //dark green
      } else if(adjustedImpedance > 10 && adjustedImpedance <= 50){ //good signal quality
        fill(184, 220, 105); //yellow green
      } else if(adjustedImpedance > 50 && adjustedImpedance <= 100){ //acceptable signal quality
        fill(221, 178, 13); //yellow
      } else if(adjustedImpedance > 100 && adjustedImpedance <= 150){ //questionable signal quality
        fill(253, 94, 52); //orange
      } else if(adjustedImpedance > 150){ //bad signal quality
        fill(224, 56, 45); //red
      }

      ellipse(x + padding + 10, y + padding*2 + 7 + startStopCheck.but_dy + padding*(i), padding/2, padding/2);
      popStyle();
    }

    if(isGanglion && eegDataSource == DATASOURCE_GANGLION){
      if(ganglion.isCheckingImpedance()){
        image(loadingGIF_blue, x + padding + startStopCheck.but_dx + 15, y + padding - 8, 40, 40);
      }
    }

    // // no longer need to do this because the math was moved to the firmware...
    // for(int i = 0; i < ganglion.impedanceArray.length; i++){
    //   String toPrint;
    //   float target = convertRawGanglionImpedanceToTarget(ganglion.impedanceArray[i]/1000.0);
    //   if(i == 0){
    //     toPrint = "Reference Impedance = " + target + " k\u2126";
    //   } else {
    //     toPrint = "Channel[" + i + "] Impedance = " + target + " k\u2126";
    //   }
    //   text(toPrint, x + 10, y + 220 + 20*(i));
    // }

    popStyle();

  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    startStopCheck.setPos(x + padding, y + padding);

  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...
    if(startStopCheck.isMouseHere()){
      startStopCheck.setIsActive(true);
    }

  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(startStopCheck.isActive && startStopCheck.isMouseHere()){
      if(isGanglion && eegDataSource == DATASOURCE_GANGLION){
        if(ganglion.isCheckingImpedance()){
          ganglion.impedanceStop();
          startStopCheck.but_txt = "Start Impedance Check";
        } else {
          ganglion.impedanceStart();
          startStopCheck.but_txt = "Stop Impedance Check";

          // if is running... stopRunning and switch the state of the Start/Stop button back to Data Stream stopped
          stopRunning();
          topNav.stopButton.setString(topNav.stopButton_pressToStart_txt);
          topNav.stopButton.setColorNotPressed(color(184, 220, 105));

        }
      }
    }
    startStopCheck.setIsActive(false);

  }

  //add custom classes functions here
  void customFunction(){
    //this is a fake function... replace it with something relevant to this widget
  }

};

public float convertRawGanglionImpedanceToTarget(float _actual){

  //the following impedance adjustment calculations were derived using empirical values from resistors between 1,2,3,4,REF-->D_G
  float _target;

  //V1 -- more accurate for lower impedances (< 22kOhcm) -> y = 0.0034x^3 - 0.1443x^2 + 3.1324x - 10.59
  if(_actual <= 22){
    // _target = (0.0004)*(pow(_actual,3)) - (0.0262)*(pow(_actual,2)) + (1.8349)*(_actual) - 6.6006;
    _target = (0.0034)*(pow(_actual,3)) - (0.1443)*(pow(_actual,2)) + (3.1324)*(_actual) - 10.59;
  }
  //V2 -- more accurate for higher impedances (> 22kOhm) -> y = 0.000009x^4 - 0.001x^3 + 0.0409x^2 + 0.6445x - 1
  else {
    _target = (0.000009)*(pow(_actual,4)) - (0.001)*pow(_actual,3) + (0.0409)*(pow(_actual,2)) + (0.6445)*(pow(_actual,1)) - 1;
  }

  return _target;

}

//These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
// void Dropdown1(int n){
//   println("Item " + (n+1) + " selected from Dropdown 1");
//   if(n==0){
//     //do this
//   } else if(n==1){
//     //do this instead
//   }
//
//   closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
// }
//
// void Dropdown2(int n){
//   println("Item " + (n+1) + " selected from Dropdown 2");
//   closeAllDropdowns();
// }
//
// void Dropdown3(int n){
//   println("Item " + (n+1) + " selected from Dropdown 3");
//   closeAllDropdowns();
// }
