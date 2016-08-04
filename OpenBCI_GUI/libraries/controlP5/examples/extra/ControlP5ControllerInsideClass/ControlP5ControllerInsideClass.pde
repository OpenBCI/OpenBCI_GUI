import controlP5.*;

ControlP5 cp5;
Test t;
void setup() {
  size(400,400);
  cp5 = new ControlP5( this );
  t = new Test( "test" );
}

void draw() {
  background(20);
  println( t.value );
}

class Test {

  int value;

  Test( String thePrefix ) {
    cp5.addSlider( "value-"+thePrefix )
       .setRange( 0, 255 )
       .plugTo( this, "setValue" )
       .setValue( 127 )
       .setLabel("value")
       ;
  }

  void setValue(int theValue) {
    value = theValue;
  }
}

