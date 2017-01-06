
import java.awt.*;
import java.awt.event.*;
import controlP5.*;

private ControlP5 cp5;

ControlFrame cf1, cf2;

int bgColor;

void setup() {
  size(400, 400 ,P3D );
  /* add a controlP5 instance for the main sketch window (not required for other ControlFrames to work) */
  cp5 = new ControlP5( this );
  cp5.addSlider( "s2" );


  /* Add a controlframe */

  cf1 = addControlFrame( "hello", 200, 200, 20, 20, color( 100 ) );

  // add a slider with an EventListener. When dragging the slider, 
  // variable bgColor will change accordingly. 
  cf1.control().addSlider( "s1" ).setRange( 0, 255 ).addListener( new ControlListener() {
    public void controlEvent( ControlEvent ev ) {
      bgColor = color( ev.getValue() );
    }
  }
  );


  /* Add a second controlframe */

  cf2 = addControlFrame( "world", 200, 200, 20, 240, color( 100 ) );

  // add a button with an EventListener. When releasing the button, 
  // variable bgColor will change to color( 255 );  
  cf2.control().addButton( "b1" ).addListener( new ControlListener() {
    public void controlEvent( ControlEvent ev ) {
      bgColor = color( 255 );
    }
  }
  );

  cf2.control().addButton( "b2" ).addListener( new ControlListener() {
    public void controlEvent(ControlEvent ev) {
      bgColor = color( random( 255 ), random( 255 ), random( 255 ) );
    }
  }
  );
}

void draw() {
  background( bgColor );
}


/* no changes required below */


ControlFrame addControlFrame(String theName, int theWidth, int theHeight) {
  return addControlFrame(theName, theWidth, theHeight, 100, 100, color( 0 ) );
}

ControlFrame addControlFrame(String theName, int theWidth, int theHeight, int theX, int theY, int theColor ) {
  final Frame f = new Frame( theName );
  final ControlFrame p = new ControlFrame( this, theWidth, theHeight, theColor );

  f.add( p );
  p.init();
  f.setTitle(theName);
  f.setSize( p.w, p.h );
  f.setLocation( theX, theY );
  f.addWindowListener( new WindowAdapter() {
    @Override
      public void windowClosing(WindowEvent we) {
      p.dispose();
      f.dispose();
    }
  } 
  );
  f.setResizable( false );
  f.setVisible( true );
  // sleep a little bit to allow p to call setup.
  // otherwise a nullpointerexception might be caused.
  try {
    Thread.sleep( 100 );
  } 
  catch(Exception e) {
  }
  return p;
}


// the ControlFrame class extends PApplet, so we 
// are creating a new processing applet inside a
// new frame with a controlP5 object loaded
public class ControlFrame extends PApplet {

  int w, h;

  int bg;

  public void setup() {
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5( this );
  }

  public void draw() {
    background( bg );
  }

  private ControlFrame() {
  }

  public ControlFrame(Object theParent, int theWidth, int theHeight, int theColor) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
    bg = theColor;
  }


  public ControlP5 control() {
    return this.cp5;
  }

  ControlP5 cp5;

  Object parent;
}

