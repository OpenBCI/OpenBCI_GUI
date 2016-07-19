package controlP5;

/*
 * Backwards compatibility, cp5magic for example uses it. 
 * But if possible, upgrade to RadioButton
 */

public class Radio extends RadioButton {

	public Radio( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , int theX , int theY ) {
		super( theControlP5 , theParent , theName , theX , theY );
	}

}
