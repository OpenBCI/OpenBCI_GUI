
//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

DataProcessing_User dataProcessing_user;
boolean drawEMG = false; //if true... toggles on EEG_Processing_User.draw and toggles off the headplot in Gui_Manager


String oldCommand = "";
boolean hasGestured = false;

//------------------------------------------------------------------------
//                            Classes
//------------------------------------------------------------------------

class DataProcessing_User {
  private float fs_Hz;  //sample rate
  private int nchan;  
  
  boolean switchesActive = false;

  
  Button leftConfig = new Button(3*(width/4) - 65,height/4 - 120,20,20,"\\/",fontInfo.buttonLabel_size);
  Button midConfig = new Button(3*(width/4) + 63,height/4 - 120,20,20,"\\/",fontInfo.buttonLabel_size);
  Button rightConfig = new Button(3*(width/4) + 190,height/4 - 120,20,20,"\\/",fontInfo.buttonLabel_size);
  
  

  //class constructor
  DataProcessing_User(int NCHAN, float sample_rate_Hz) {
    nchan = NCHAN;
    fs_Hz = sample_rate_Hz;
  }

  //add some functions here...if you'd like

  //here is the processing routine called by the OpenBCI main program...update this with whatever you'd like to do
  public void process(float[][] data_newest_uV, //holds raw bio data that is new since the last call
    float[][] data_long_uV, //holds a longer piece of buffered EEG data, of same length as will be plotted on the screen
    float[][] data_forDisplay_uV, //this data has been filtered and is ready for plotting on the screen
    FFT[] fftData) {              //holds the FFT (frequency spectrum) of the latest data

    //for example, you could loop over each EEG channel to do some sort of time-domain processing 
    //using the sample values that have already been filtered, as will be plotted on the display
    float EEG_value_uV;

    
    
    //  if (millis() - timeOfLastTrip_R >= 1250) {
    //    switch(switchBrowCounter){
    //      case 1:
    //        //println("Single Brow Raise");
            
    //        switch(switchCounter){
            
    //          case 1:
    //            //RED CIRCLE FOR JAW, RED FOR BROW
    //            //hand.write(oldCommand);
                
    //            break;
    //          case 2:
    //            //GREEN CIRCLE FOR JAW, RED FOR BROW
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "1234";
    //            hand.write(oldCommand);
    //            break;
    //          case 3:
    //            //BLUE CIRCLE FOR JAW, RED FOR BROW
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "01";
    //            hand.write(oldCommand);
    //            break;
    //          case 4:
    //            //VIOLET CIRCLE FOR JAW, RED FOR BROW
    //            hand.write("0");
    //            break;
    //        }
    //        break;
    //      case 2:
    //        //println("Two Brow Raises");
            
    //        switch(switchCounter){
            
    //          case 1:
    //            //RED CIRCLE FOR JAW, GREEN FOR BROW
    //            break;
    //          case 2:
    //            //GREEN CIRCLE FOR JAW, GREEN FOR BROW
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "23";
    //            hand.write(oldCommand);
    //            break;
    //          case 3:
    //            //BLUE CIRCLE FOR JAW, GREEN FOR BROW
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "012";
    //            hand.write(oldCommand);
    //            break;
    //          case 4:
    //            //VIOLET CIRCLE FOR JAW, GREEN FOR BROW
    //            hand.write("1");
    //            break;
    //        }
    //        break;
    //      case 3:
    //        //println("Three Brow Raises");
            
    //        switch(switchCounter){
            
    //          case 1:
    //            //RED CIRCLE FOR JAW, BLUE FOR BROW
    //            break;
    //          case 2:
    //            //GREEN CIRCLE FOR JAW, BLUE FOR BROW                
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "234";
    //            hand.write(oldCommand);
    //            break;
    //          case 3:
    //            //BLUE CIRCLE FOR JAW, BLUE FOR BROW
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "0123";
    //            hand.write(oldCommand);
    //            break;
    //          case 4:
    //            //VIOLET CIRCLE FOR JAW, BLUE FOR BROW
    //            hand.write("2");
    //            break;
    //        }
    //        break;
    //      case 4:
    //        //println("Four Brow Raises");
            
    //        switch(switchCounter){
            
    //          case 1:
    //            //RED CIRCLE FOR JAW, VIOLET FOR BROW
    //            break;
    //          case 2:
    //            //GREEN CIRCLE FOR JAW, VIOLET FOR BROW
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "0134";
    //            hand.write(oldCommand);
    //            break;
    //          case 3:
    //            //BLUE CIRCLE FOR JAW, VIOLET FOR BROW
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "01234";
    //            hand.write(oldCommand);
    //            break;
    //          case 4:
    //            //VIOLET CIRCLE FOR JAW, VIOLET FOR BROW
    //            hand.write("3");
    //            break;
    //        }
    //        break;
    //      case 5:
    //        //println("Five Brow Raises");
            
    //        switch(switchCounter){
            
    //          case 1:
    //            //RED CIRCLE FOR JAW, YELLOW FOR BROW
    //            break;
    //          case 2:
    //            //GREEN CIRCLE FOR JAW, YELLOW FOR BROW
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "0134";
    //            hand.write(oldCommand);
    //            break;
    //          case 3:
    //            //BLUE CIRCLE FOR JAW, YELLOW FOR BROW
    //            hand.write(oldCommand);
    //            delay(100);
    //            oldCommand = "01234";
    //            hand.write(oldCommand);
    //            break;
    //          case 4:
    //            //VIOLET CIRCLE FOR JAW, YELLOW FOR BROW
    //            hand.write("4");
    //            break;
    //        }
    //        break;
    //      //case 6: 
    //      //  println("Six Brow Raises");
    //      //  break;
    //    }
        
    //    switchBrowCounter = 0;
    //  }
      
   
    }

  }

  