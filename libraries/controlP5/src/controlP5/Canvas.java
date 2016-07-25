package controlP5;

import processing.core.PApplet;
import processing.core.PGraphics;

/**
 * Use a Canvas to draw custom graphics into a control
 * window or the default sketch window.
 * 
 * The Canvas is an abstract class and must be extended by
 * your custom Canvas class, see the ControlP5canvas example
 * for details.
 * 
 * @example controllers/ControlP5canvas
 * 
 */

public abstract class Canvas {

	protected ControlWindow _myControlWindow;

	public final static int PRE = 0;

	public final static int POST = 1;

	protected int _myMode = PRE;

	public void setup( PGraphics theGraphics ) {
	}

	// TODO should be called from within ControlWindow when
	// calling draw(PGraphics)
	public void update( PApplet theApplet ) {
	}

	/**
	 * controlWindowCanvas is an abstract class and
	 * therefore needs to be extended by your class.
	 * draw(PApplet theApplet) is the only method that needs
	 * to be overwritten.
	 */
	public abstract void draw( PGraphics theGraphics );

	/**
	 * move a canvas to another controlWindow
	 * 
	 * @param theControlWindow
	 */
	public void moveTo( ControlWindow theControlWindow ) {
		if ( _myControlWindow != null ) {
			_myControlWindow.removeCanvas( this );
		}
		theControlWindow.addCanvas( this );
	}

	/**
	 * get the drawing mode of a Canvas. this can be PRE or
	 * POST.
	 * 
	 * @return
	 */
	public final int mode( ) {
		return _myMode;
	}

	/**
	 * set the drawing mode to PRE. PRE is the default.
	 */
	public final void pre( ) {
		setMode( PRE );
	}

	/**
	 * set the drawing mode to POST.
	 */
	public final void post( ) {
		setMode( POST );
	}

	/**
	 * 
	 * @param theMode
	 */
	public final void setMode( int theMode ) {
		if ( theMode == PRE ) {
			_myMode = PRE;
		} else {
			_myMode = POST;
		}
	}

	protected final void setControlWindow( ControlWindow theControlWindow ) {
		_myControlWindow = theControlWindow;
	}

	public final ControlWindow window( ) {
		return _myControlWindow;
	}
}
