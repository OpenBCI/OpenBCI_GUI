package controlP5;

public class Background extends ControlGroup< Background > {

	public Background( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , int theX , int theY , int theW , int theH ) {
		super( theControlP5 , theParent , theName , theX , theY , theW , theH );
		hideBar( );
		setBackgroundColor( 0x55000000 );
		setSize(theW, theH);
	}

}
