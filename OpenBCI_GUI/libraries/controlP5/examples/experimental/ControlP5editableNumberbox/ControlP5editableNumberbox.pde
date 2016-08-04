import controlP5.*;

// Editable Numberbox for ControlP5

ControlP5 cp5;

void setup() {
  size(400, 400);
  cp5 = new ControlP5(this);

  Numberbox n = cp5.addNumberbox("numbers")
                   .setSize(100, 20)
                   .setPosition(100, 100)
                   .setValue(0)
                   ;
                   
  makeEditable( n );                   
}


void draw() {
  background(0);
}


// function that will be called when controller 'numbers' changes
public void numbers(float f) {
  println("received "+f+" from Numberbox numbers ");
}


void makeEditable( Numberbox n ) {
  // allows the user to click a numberbox and type in a number which is confirmed with RETURN
  
   
  final NumberboxInput nin = new NumberboxInput( n ); // custom input handler for the numberbox
  
  // control the active-status of the input handler when releasing the mouse button inside 
  // the numberbox. deactivate input handler when mouse leaves.
  n.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( true ); 
    }
  }
  ).onLeave(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( false ); nin.submit();
    }
  });
}



// input handler for a Numberbox that allows the user to 
// key in numbers with the keyboard to change the value of the numberbox

public class NumberboxInput {

  String text = "";

  Numberbox n;

  boolean active;

  
  NumberboxInput(Numberbox theNumberbox) {
    n = theNumberbox;
    registerMethod("keyEvent", this );
  }

  public void keyEvent(KeyEvent k) {
    // only process key event if input is active 
    if (k.getAction()==KeyEvent.PRESS && active) {
      if (k.getKey()=='\n') { // confirm input with enter
        submit();
        return;
      } else if(k.getKeyCode()==BACKSPACE) { 
        text = text.isEmpty() ? "":text.substring(0, text.length()-1);
        //text = ""; // clear all text with backspace
      }
      else if(k.getKey()<255) {
        // check if the input is a valid (decimal) number
        final String regex = "\\d+([.]\\d{0,2})?";
        String s = text + k.getKey();
        if ( java.util.regex.Pattern.matches(regex, s ) ) {
          text += k.getKey();
        }
      }
      n.getValueLabel().setText(this.text);
    }
  }

  public void setActive(boolean b) {
    active = b;
    if(active) {
      n.getValueLabel().setText("");
      text = ""; 
    }
  }
  
  public void submit() {
    if (!text.isEmpty()) {
      n.setValue( float( text ) );
      text = "";
    } 
    else {
      n.getValueLabel().setText(""+n.getValue());
    }
  }
}


