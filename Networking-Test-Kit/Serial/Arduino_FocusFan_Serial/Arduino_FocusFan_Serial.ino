/////////////////////////////////////////////////////////////////////////////////////////
//            OpenBCI_GUI to Arduino via Serial: Focus Fan!                            //
//                                                                                     //
//            - The Arduino Built-In LED blinks when the user is Focused               //
//        - A button on pin 7 toggles motor speed: Full, Medium, Low, and Off          //
//                                                                                     //
//          Tested 7/13/2021 using iMac, Arduino Pro Mini, OpenBCI_GUI 5.0.5           //
//    Uses https://learn.adafruit.com/adafruit-arduino-lesson-15-dc-motor-reversing/   //
//        and https://docs.openbci.com/Tutorials/17-Arduino_Focus_Example              //
/////////////////////////////////////////////////////////////////////////////////////////

const byte numChars = 32;
char receivedChars[numChars];   // an array to store the received data
String previousData = "";
boolean newData = false;
boolean isFocused = false;
boolean lastFocusState = false;

int enablePin = 11;
int in1Pin = 10;
int in2Pin = 9;
int buttonPin = 7;
int ledPin = 13;

int buttonPushCounter = 0;   // counter for the number of button presses
int buttonState = 0;         // current state of the button
int lastButtonState = 0;     // previous state of the button

void setup() {
    pinMode(in1Pin, OUTPUT);
    pinMode(in2Pin, OUTPUT);
    pinMode(enablePin, OUTPUT);
    pinMode(buttonPin, INPUT_PULLUP);

    Serial.begin(57600);
    pinMode(LED_BUILTIN, OUTPUT);
    Serial.println("<Arduino is ready>");
}

void loop() {
    recvWithEndMarker();
    showNewData();
      
    handleButtonState();
    //check for state change
    if (isFocused) {
      setMotor(getMotorPower(), true);
    } else {
      setMotor(0, true);
    }
    lastFocusState = isFocused;
}

//Recieve data and look for the endMarker '\n' (new line)
void recvWithEndMarker() {
    static byte ndx = 0;
    char endMarker = '\n';
    char rc;
    
    while (Serial.available() > 0 && newData == false) {
        rc = Serial.read();

        if (rc != endMarker) {
            receivedChars[ndx] = rc;
            ndx++;
            if (ndx >= numChars) {
                ndx = numChars - 1;
            }
        }
        else {
            receivedChars[ndx] = '\0'; // terminate the string
            ndx = 0;
            newData = true;
        }
    }
}

void showNewData() {
    if (newData == true) {
        //Convert char array into string
        String s = receivedChars;
        //Only perform an action when the incoming data changes
        if (!s.equals(previousData)) {
          //Check if the string is "true" or "false"
          if (s.equals("0")) {
            Serial.println("Input: FALSE");
            isFocused = false;
            digitalWrite(LED_BUILTIN, LOW);
          } else if (s.equals("1")) {
            Serial.println("Input: TRUE");
            digitalWrite(LED_BUILTIN, HIGH);
            isFocused = true;
          } else {
            //Otherwise print the incoming with no action
            Serial.println("This just in ... " + s);
          }
        }
        newData = false;
        previousData = s;
    }
}

void setMotor(int speed, boolean reverse) {
    analogWrite(enablePin, speed);
    digitalWrite(in1Pin, !reverse);
    digitalWrite(in2Pin, reverse);
}

void handleButtonState () {
  buttonState = digitalRead(buttonPin);
    
    // compare the buttonState to its previous state
    if (buttonState != lastButtonState) {
      // if the state has changed, increment the counter
      if (buttonState == HIGH) {
        // if the current state is HIGH then the button went from off to on:
        buttonPushCounter++;
        //Serial.println("on");
      } else {
        // if the current state is LOW then the button went from on to off:
        //Serial.println("off");
      }
      // Delay a little bit to avoid bouncing
      delay(50);
    }
    // save the current state as the last state, for next time through the loop
    lastButtonState = buttonState;
}

int getMotorPower() {
    //Toggle the fan power between four settings, shown below
    //Default: Full Power
    int power;
    switch (buttonPushCounter % 4) {
      case 0: //Every 4 clicks reverts to full power
        power = 255; //Full power
        break;
      case 1:
        power = 180; //Medium power
        break;
      case 2:
        power = 90;  //Low power
        break;
      case 3:
        power = 0;  //Motor off
        break;
    }
    return power;
}
