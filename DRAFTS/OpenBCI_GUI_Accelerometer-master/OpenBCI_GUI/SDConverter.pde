
//////////////////////////////////
//
//		This file contains code used to convert HEX files (stored by OpenBCI on the local SD) into 
//		text files that can be used for PLAYBACK mode.
//		Created: Conor Russomanno - 10/22/14 (based on code written by Joel Murphy summer 2014)
//
//////////////////////////////////

//variables for SD file conversion
BufferedReader dataReader;
String dataLine;
PrintWriter dataWriter;
String convertedLine;
String thisLine;
String h;
float[] intData = new float[20];
String logFileName;
long thisTime;
long thatTime;

public void convertSDFile() {
  println("");
  try {
    dataLine = dataReader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    dataLine = null;
  }

  if (dataLine == null) {
    // Stop reading because of an error or file is empty
    thisTime = millis() - thatTime;
    controlPanel.convertingSD = false;
    println("nothing left in file"); 
    println("SD file conversion took "+thisTime+" mS");
    dataWriter.flush();
    dataWriter.close();
  } else {
    //        println(dataLine);
    String[] hexNums = splitTokens(dataLine, ",");

    if (hexNums[0].charAt(0) == '%') {
      //          println(dataLine);
      dataWriter.println(dataLine);
      println(dataLine);
    } else {
      for (int i=0; i<hexNums.length; i++) {
        h = hexNums[i];
        if (i > 0) {
          if (h.charAt(0) > '7') {  // if the number is negative 
            h = "FF" + hexNums[i];   // keep it negative
          } else {                  // if the number is positive
            h = "00" + hexNums[i];   // keep it positive
          }
          if (i > 8) { // accelerometer data needs another byte
            if (h.charAt(0) == 'F') {
              h = "FF" + h;
            } else {
              h = "00" + h;
            }
          }
        }
        // println(h); // use for debugging
        if (h.length()%2 == 0) {  // make sure this is a real number
          intData[i] = unhex(h);
        } else {
          intData[i] = 0;
        }

        //if not first column(sample #) or columns 9-11 (accelerometer), convert to uV
        if (i>=1 && i<=8) {
          intData[i] *= openBCI.get_scale_fac_uVolts_per_count();
        }

        //print the current channel value
        dataWriter.print(intData[i]);
        if (i < hexNums.length-1) {
          //print "," separator
          dataWriter.print(",");
        }
      }
      //println();
      dataWriter.println();
    }
  }
}

void createPlaybackFileFromSD() {
  logFileName = "data/EEG_Data/SDconverted-"+getDateString()+".txt";
  dataWriter = createWriter(logFileName);
  dataWriter.println("%OBCI Data Log - " + getDateString());
}

void sdFileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    dataReader = createReader(selection.getAbsolutePath()); // ("positions.txt");
    controlPanel.convertingSD = true;
    println("Timing SD file conversion...");
    thatTime = millis();
  }
}