package controlP5;

/**
 * controlP5 is a processing gui library.
 * 
 * 2006-2015 by Andreas Schlegel
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 * 
 * @author Andreas Schlegel (http://www.sojamo.de)
 * @modified 04/14/2016
 * @version 2.2.6
 * 
 */

import processing.core.PApplet;

/**
 * Constant variables used with ControlP5 are stored here.
 */
public interface ControlP5Constants {

	public final static String eventMethod = "controlEvent";
	public final static boolean VERBOSE = false;
	public final static float PI = ( float ) Math.PI;
	public final static float TWO_PI = PI * 2;
	public final static float HALF_PI = PI / 2;
	public final static int INVALID = -1;
	public final static int METHOD = 0;
	public final static int FIELD = 1;
	public final static int EVENT = 2;
	public final static int INTEGER = 1;
	public final static int FLOAT = 2;
	public final static int BOOLEAN = 3;
	public final static int STRING = 4;
	public final static int ARRAY = 5;
	public final static int BITFONT = 100;
	public final static Class< ? >[] acceptClassList = { int.class , float.class , boolean.class , String.class };
	public final static Class< ? > controlEventClass = ControlEvent.class;
	public final static int UP = PApplet.UP; // KeyEvent.VK_UP;
	public final static int DOWN = PApplet.DOWN; // KeyEvent.VK_DOWN;
	public final static int LEFT = PApplet.LEFT; // KeyEvent.VK_LEFT;
	public final static int RIGHT = PApplet.RIGHT; // KeyEvent.VK_RIGHT;
	public final static int SHIFT = PApplet.SHIFT; // KeyEvent.VK_SHIFT;
	public final static int DELETE = PApplet.DELETE; // KeyEvent.VK_DELETE;
	public final static int BACKSPACE = PApplet.BACKSPACE; // KeyEvent.VK_BACK_SPACE;
	public final static int ENTER = PApplet.ENTER; // KeyEvent.VK_ENTER;
	public final static int ESCAPE = PApplet.ESC; // KeyEvent.VK_ESCAPE;
	public final static int ALT = PApplet.ALT; // KeyEvent.VK_ALT;
	public final static int CONTROL = PApplet.CONTROL;// KeyEvent.VK_CONTROL;
	public final static int COMMANDKEY = 157; // Event.VK_META;
	public final static int TAB = PApplet.TAB; // KeyEvent.VK_TAB;
	public final static char INCREASE = PApplet.UP;
	public final static char DECREASE = PApplet.DOWN;
	public final static char SWITCH_FORE = PApplet.LEFT;
	public final static char SWITCH_BACK = PApplet.RIGHT;
	public final static char SAVE = 'S';
	public final static char RESET = 'R';
	public final static char PRINT = ' ';
	public final static char HIDE = 'H';
	public final static char LOAD = 'L';
	public final static char MENU = 'M';
	public final static char KEYCONTROL = 'K';
	public final static int TOP = 101; // PApplet.TOP
	public final static int BOTTOM = 102; // PApplet.BOTTOM
	public final static int CENTER = 3; // PApplet.CENTER
	public final static int BASELINE = 0; // PApplet.BASELINE
	static public final int HORIZONTAL = 0;
	static public final int VERTICAL = 1;
	static public final int DEFAULT = 0;
	static public final int OVER = 1;
	static public final int ACTIVE = 2;
	static public final int HIGHLIGHT = 3;
	static public final int IMAGE = 1;
	static public final int SPRITE = 2;
	static public final int CUSTOM = 3;
	static public final int SWITCH = 100;
	static public final int MOVE = 0;
	static public final int RELEASE = 2;
	static public final int RELEASED = 2;
	static public final int PRESSED = 1;
	static public final int PRESS = 1;
	static public final int LINE = 1;
	static public final int ELLIPSE = 2;
	static public final int ARC = 3;
	static public final int INACTIVE = 0;
	static public final int WAIT = 1;
	static public final int TRANSITION_WAIT_FADEIN = 2;
	static public final int FADEIN = 3;
	static public final int IDLE = 4;
	static public final int FADEOUT = 5;
	static public final int DONE = 6;
	static public final int SINGLE_COLUMN = 0;
	static public final int SINGLE_ROW = 1;
	static public final int MULTIPLES = 2;
	static public final int LIST = 0;
	static public final int DROPDOWN = 1;
	static public final int CHECKBOX = 2; /* TODO */
	static public final int TREE = 3; /* TODO */

	@Deprecated static public final int ACTION_PRESSED = 1; // MouseEvent.PRESS
	static public final int ACTION_PRESS = 1; // MouseEvent.PRESS

	@Deprecated static public final int ACTION_RELEASED = 2; // MouseEvent.RELEASE
	static public final int ACTION_RELEASE = 2; // MouseEvent.RELEASE

	static public final int ACTION_CLICK = 3; // MouseEvent.CLICK
	static public final int ACTION_DRAG = 4; // MouseEvent.DRAG
	static public final int ACTION_MOVE = 5; // MouseEvent.MOVE
	static public final int ACTION_ENTER = 6; // MouseEvent.ENTER
	static public final int ACTION_LEAVE = 7; // MouseEvent.EXIT
	static public final int ACTION_EXIT = 7; // MouseEvent.EXIT
	static public final int ACTION_WHEEL = 8; // MouseEvent.WHEEL
	@Deprecated static public final int ACTION_RELEASEDOUTSIDE = 9;
	static public final int ACTION_RELEASE_OUTSIDE = 9;
	static public final int ACTION_START_DRAG = 10;
	static public final int ACTION_END_DRAG = 11;
	static public final int ACTION_DOUBLE_PRESS = 12;
	static public final int ACTION_BROADCAST = 100;
	static public final int LEFT_OUTSIDE = 10;
	static public final int RIGHT_OUTSIDE = 11;
	static public final int TOP_OUTSIDE = 12;
	static public final int BOTTOM_OUTSIDE = 13;
	static public final int CAPTIONLABEL = 0;
	static public final int VALUELABEL = 1;
	static public final int SINGLE = 0;

	@Deprecated static public final int ALL = 1;
	static public final int MULTI = 1;

	/* http://clrs.cc/ */
	static public final int NAVY = 0xFF001F3F;
	static public final int BLUE = 0xFF0074D9;
	static public final int AQUA = 0xFF7FDBFF;
	static public final int TEAL = 0xFF39CCCC;
	static public final int OLIVE = 0xFF3D9970;
	static public final int GREEN = 0xFF2ECC40;
	static public final int LIME = 0xFF01FF70;
	static public final int YELLOW = 0xFFFFDC00;
	static public final int ORANGE = 0xFFFF851B;
	static public final int RED = 0xFFFF4136;
	static public final int MAROON = 0xFF85144B;
	static public final int FUCHSIA = 0xFFF012BE;
	static public final int PURPLE = 0xFFB10DC9;
	static public final int WHITE = 0xFFFFFFFF;
	static public final int SILVER = 0xFFDDDDDD;
	static public final int GRAY = 0xFFAAAAAA;
	static public final int BLACK = 0xFF111111;

	
	/*fg, bg, active, caption, value ) */
	public final static CColor THEME_RETRO = new CColor( 0xff00698c , 0xff003652 , 0xff08a2cf , 0xffffffff , 0xffffffff );
	public final static CColor THEME_CP52014 = new CColor( 0xff0074D9 , 0xff002D5A, 0xff00aaff , 0xffffffff , 0xffffffff );
	public final static CColor THEME_CP5BLUE = new CColor( 0xff016c9e , 0xff02344d , 0xff00b4ea , 0xffffffff , 0xffffffff );
	public final static CColor THEME_RED = new CColor( 0xffaa0000 , 0xff660000 , 0xffff0000 , 0xffffffff , 0xffffffff );
	public final static CColor THEME_GREY = new CColor( 0xffeeeeee, 0xffbbbbbb , 0xffffffff , 0xff555555 , 0xff555555 );
	public final static CColor THEME_A = new CColor( 0xff00FFC8 , 0xff00D7FF , 0xffffff00 , 0xff00B0FF , 0xff00B0FF );

	// other colors: #ff3838 red-salmon; #08ffb4 turquoise; #40afff light-blue; #f3eddb beige; 
	
	public static final int standard58 = 0;
	public static final int standard56 = 1;
	public static final int synt24 = 2;
	public static final int grixel = 3;
	public final static int J2D = 1;
	public final static int P2D = 2;
	public final static int P3D = 3;

	public final static String JSON = "JSON";
	public final static String SERIALIZED = "SERIALIZED";
	
	static public final String delimiter = " ";
	static public final String pathdelimiter = "/";
	
}
