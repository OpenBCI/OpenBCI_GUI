

//////////////////////////////////
//
//    This collection of functions/methods - convertSDFile, createPlaybackFileFromSD, & sdFileSelected - contains code
//    used to convert HEX files (stored by OpenBCI on the local SD) into text files that can be used for PLAYBACK mode.
//    Created: Conor Russomanno - 10/22/14 (based on code written by Joel Murphy summer 2014)
//    Updated: Joel Murphy - 6/26/17
//
//////////////////////////////////

//variables for SD file conversion
BufferedReader dataReader;
String dataLine;
PrintWriter dataWriter;
String h;
float[] floatData = new float[20];
float[] intData = new float[20];
String logFileName;
String[] hexNums;
long thisTime;
long thatTime;
boolean printNextLine = false;

public void convertSDFile() {
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
        outputSuccess("SD file converted to " + logFileName);
        dataWriter.flush();
        dataWriter.close();
    }
        else
    {
        hexNums = splitTokens(dataLine, ",");

        if (hexNums[0].charAt(0) == '%') {
            //          println(dataLine);
            // dataWriter.println(dataLine);
            println("convertSDFile: " + dataLine);
            printNextLine = true;
        } else {
            if (hexNums.length < 13){
                convert8channelLine();
            } else {
                convert16channelLine();
            }
            if(printNextLine){
                printNextLine = false;
            }
        }
    }
}

void convert16channelLine() {
    String consoleMsg = "";
    if(printNextLine){
        for(int i=0; i<hexNums.length; i++){
            h = hexNums[i];
            if (h.length()%2 == 0 && h.length() <= 10) {  // make sure this is a real number
                intData[i] = unhex(h);
            } else {
                intData[i] = 0;
            }
            dataWriter.print(intData[i]);
            consoleMsg = Integer.toString(int(intData[i]));
            if(hexNums.length > 1){
                dataWriter.print(", ");
                consoleMsg += ", ";
            }
        }
        dataWriter.println();
        println("convert16channelLine: " + consoleMsg);
        return;
    }

    // for brainflow we dont need to apply gain but for non-brainflow boards we need and it can not be 
    // patched gracefully without major changes, sorry for this code
    float scaler = BoardCytonConstants.scale_fac_uVolts_per_count;
    if (currentBoard instanceof BoardBrainFlow) {
        scaler = 1;
    }

    for (int i=0; i<hexNums.length; i++) {
        h = hexNums[i];
        if (i > 0) {
            if (h.charAt(0) > '7') {  // if the number is negative
                h = "FF" + hexNums[i];   // keep it negative
            } else {                  // if the number is positive
                h = "00" + hexNums[i];   // keep it positive
            }
            if (i > 16) { // accelerometer data needs another byte
                if (h.charAt(0) == 'F') {
                    h = "FF" + h;
                } else {
                    h = "00" + h;
                }
            }
        }
        // println(h); // use for debugging
        if (h.length()%2 == 0 && h.length() <= 10) {  // make sure this is a real number
            floatData[i] = unhex(h);
        } else {
            floatData[i] = 0;
        }

        if (i>=1 && i<=16) {
            floatData[i] *= scaler;
        }else if(i != 0){
            floatData[i] *= scaler;
        }

        if(i == 0){
            dataWriter.print(int(floatData[i]));  // print the sample counter
        }else{
            dataWriter.print(floatData[i]);  // print the current channel value
        }
        if (i < hexNums.length-1) {  // print the current channel value
            dataWriter.print(",");  // print "," separator
        }
    }
    dataWriter.println();
}

void convert8channelLine() {
    String consoleMsg = "";
    if(printNextLine){
        for(int i=0; i<hexNums.length; i++){
            h = hexNums[i];
            if (h.length()%2 == 0) {  // make sure this is a real number
                intData[i] = unhex(h);
            } else {
                intData[i] = 0;
            }
            consoleMsg = str(int(intData[i]));
            dataWriter.print(intData[i]);
            if(hexNums.length > 1){
                dataWriter.print(", ");
                consoleMsg += ", ";
            }
        }
        dataWriter.println();
        println("convert8channelLine: " + consoleMsg);
        return;
    }
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
        // println(h + " " + h.length()); // use for debugging
        if (h.length() > 8) {
            break;
        }
        if (h.length()%2 == 0) {  // make sure this is a real number
            floatData[i] = unhex(h);
        } else {
            floatData[i] = 0;
        }

        if (i>=1 && i<=8) {
            floatData[i] *= BoardCytonConstants.scale_fac_uVolts_per_count;
        }else if(i != 0){
            floatData[i] *= BoardCytonConstants.scale_fac_uVolts_per_count;
        }

        if(i == 0){
            dataWriter.print(int(floatData[i]));  // print the sample counter
        }else{
            dataWriter.print(floatData[i]);  // print the current channel value
        }
        if (i < hexNums.length-1) {
            dataWriter.print(",");  // print "," separator
        }
    }
    dataWriter.println();
}
