package controlP5;

import processing.core.PGraphics;

public class Spacer extends Controller< Spacer > {

	private int _myWeight = 1;

	public Spacer( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 20 , 20 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	protected Spacer( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , float theX , float theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
		_myControllerView = new SpacerView( );
	}

	public Spacer setWeight( int theWeight ) {
		_myWeight = theWeight;
		return this;
	}

	public Spacer setColor( int theColor ) {
		getColor( ).setForeground( theColor );
		return this;
	}

	private class SpacerView implements ControllerView< Spacer > {

		public void display( PGraphics g , Spacer c ) {
			g.fill( c.getColor( ).getForeground( ) );
			g.noStroke( );
			if ( c.getWidth( ) >= c.getHeight( ) ) {
				g.rect( 0 , ( c.getHeight( ) / 2 ) - _myWeight / 2 , c.getWidth( ) , _myWeight );
			} else {
				g.rect( ( c.getWidth( ) / 2 ) - _myWeight / 2 , 0 , _myWeight , c.getHeight( ) );
			}
		}
	}

}
