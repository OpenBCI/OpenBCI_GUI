package controlP5;

import java.util.HashMap;
import java.util.Map;

import processing.core.PApplet;
import processing.core.PGraphics;

public class ColorWheel extends Controller< ColorWheel > {

	/* TODO _myColorValue should only be used internally,
	 * when broadcasting, a composed value based on the hsl
	 * and alpha value should be distributed, same goes for
	 * getValue. */

	private int _myColorValue = 0xffffffff;
	private final Map< String , PGraphics > _myColorResources;
	private final float[] _myCursor;
	private float scalar = 0.8f;
	private int yoff = 10;
	private boolean isInfo = false;
	private Label _myInfoLabel;
	private int drag = NONE;
	private final static int NONE = -1;
	private final static int SATURATION = 0;
	private final static int COLOR = 1;
	private final static int ALPHA = 2;
	int _sideHandleHeight = 8;
	private double[] hsl = new double[] { 1.0 , 1.0 , 1.0 };

	// argb = int ( 0-255 , 0-255 , 0-255 , 0-255 )
	// hue = double ( 0.0-1.0 ) 0-360
	// saturation = double ( 0.0-1.0 ) 0-100%
	// lightness = double ( 0.0-1.0 ) 0-100%
	// brightness = double ( 0.0-1.0 ) 0-100%

	public ColorWheel( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , autoWidth , autoHeight );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	public ColorWheel( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , int theX , int theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );

		_myColorResources = new HashMap< String , PGraphics >( );
		_myColorResources.put( "default" , cp5.papplet.createGraphics( theWidth , theHeight ) );
		_myCursor = new float[] { getWidth( ) / 2 , getHeight( ) / 2 };
		_myCaptionLabel.align( LEFT , BOTTOM_OUTSIDE );
		_myCaptionLabel.setPaddingX( 0 );
		_myInfoLabel = new Label( cp5 , theName + "-info" );
		_myInfoLabel.setPaddingX( 4 ).getStyle( ).marginTop = 4;
		yoff = ( int ) ( getWidth( ) * 0.05 );

		setColorResources( );
	}

	@Override public void onStartDrag( ) {
		checkDrag( );
	}

	private void checkDrag( ) {
		double x = getPointer( ).x( );
		double y = getPointer( ).y( ) + yoff;
		double xcenter = getWidth( ) / 2;
		double ycenter = getHeight( ) / 2;
		double d1 = ( ( getWidth( ) / 2 ) * scalar ) + 1;
		double d = Math.sqrt( Math.pow( x - xcenter , 2 ) + Math.pow( y - ycenter , 2 ) );
		double w = ( getWidth( ) - ( d1 * 2 ) ) / 2;
		drag = NONE;
		if ( d <= d1 ) {
			drag = COLOR;
		} else if ( x >= 0 && x <= w ) {
			drag = SATURATION;
		} else if ( x >= getWidth( ) - w && x <= getWidth( ) ) {
			drag = ALPHA;
		}
	}

	public void onEndDrag( ) {
		drag = NONE;
	}

	@Override public void onDrag( ) {
		switch ( drag ) {
		case ( COLOR ):
			double x = getPointer( ).x( );
			double y = getPointer( ).y( ) + yoff;
			double xcenter = getWidth( ) / 2;
			double ycenter = getHeight( ) / 2;
			double a = Math.atan2( y - ycenter , x - xcenter );
			double d0 = getWidth( ) * 0.1;
			double d1 = ( ( getWidth( ) / 2 ) * scalar ) + 1;
			double d = Math.sqrt( Math.pow( x - xcenter , 2 ) + Math.pow( y - ycenter , 2 ) );
			if ( d >= d1 - 1 ) {
				x = ( xcenter + Math.cos( a ) * d1 );
				y = ( ycenter + Math.sin( a ) * d1 );
			} else if ( d <= d0 ) {
				x = ( xcenter + Math.cos( a ) * d0 );
				y = ( ycenter + Math.sin( a ) * d0 );
			}
			set( _myCursor , ( float ) x , ( float ) y );

			int xx = ( int ) x;
			int yy = ( int ) y;

			double[] t = RGBtoHSL( _myColorResources.get( "default" ).get( xx , yy ) );
			hsl[ 0 ] = t[ 0 ];
			hsl[ 2 ] = t[ 2 ];
			_myColorValue = HSLtoRGB( hsl );
			setValue( _myColorValue );
			break;
		case ( SATURATION ):
			float s1 = ( getHeight( ) - ( yoff * 2 ) - _sideHandleHeight );
			setSaturation( map( getPointer( ).y( ) , 0 , s1 , 1.0 , 0.0 ) );
			_myColorValue = HSLtoRGB( hsl );
			setValue( _myColorValue );
			break;
		case ( ALPHA ):
			float a1 = ( getHeight( ) - ( yoff * 2 ) - _sideHandleHeight );
			setAlpha( ( int ) map( getPointer( ).y( ) , 0 , a1 , 255 , 0 ) );
			_myColorValue = HSLtoRGB( hsl );
			setValue( _myColorValue );
			break;
		}
	}

	@Override public void onPress( ) {
		checkDrag( );
	}

	@Override public void onRelease( ) {
		onDrag( );
	}

	public ColorWheel scrolled( int theRotationValue ) {
		if ( isVisible ) {
			double x = getPointer( ).x( );
			double d1 = ( ( getWidth( ) / 2 ) * scalar ) + 1;
			double w = ( getWidth( ) - ( d1 * 2 ) ) / 2;
			if ( x >= 0 && x <= w ) {
				setSaturation( hsl[ 1 ] + theRotationValue * 0.01 );
				_myColorValue = HSLtoRGB( hsl );
				setValue( _myColorValue );
			} else if ( x >= getWidth( ) - w && x <= getWidth( ) ) {
				setAlpha( a( ) + theRotationValue );
			}
		}
		return this;
	}

	private void setColorResources( ) {
		/* for now there is only a default resource but this
		 * can be extended to support other color models in
		 * the future. */

		PGraphics buffer = _myColorResources.get( "default" );

		buffer.beginDraw( );

		buffer.background( 0 , 0 );

		int w = buffer.width;

		int h = buffer.height;

		float[] center = new float[] { w / 2 , h / 2 };

		int inner_radius = ( int ) ( buffer.width * 0.1 );

		int outer_radius = ( int ) ( buffer.width * scalar / 2 );
		buffer.fill( 0 );
		buffer.ellipseMode( CENTER );
		buffer.ellipse( buffer.width / 2 , buffer.height / 2 , buffer.width * scalar + 4 , buffer.width * scalar + 4 );
		buffer.fill( 255 );
		buffer.ellipse( buffer.width / 2 , buffer.height / 2 , ( inner_radius + 1 ) * 2 , ( inner_radius + 1 ) * 2 );

		for ( int y = 0 ; y < h ; y++ ) {
			int dy = ( int ) ( y(center) - y );
			for ( int x = 0 ; x < w ; x++ ) {
				int dx = ( int ) ( x(center) - x );
				double dist = Math.sqrt( dx * dx + dy * dy );
				if ( dist >= inner_radius && dist <= outer_radius ) {
					double theta = Math.atan2( dy , dx );
					// theta can go from -pi to pi
					double hue = ( theta + PI ) / ( TWO_PI );
					double sat , val;
					if ( dist < ( inner_radius + ( outer_radius - inner_radius ) / 2 ) ) {
						sat = map( dist , inner_radius , outer_radius , 0 , 2 );
						val = 1;
					} else {
						sat = 1;
						val = map( dist , inner_radius , outer_radius , 2 , 0 );
					}
					buffer.set( x , y , HSVtoRGB( hue , sat , val ) );
				}
			}
		}
		buffer.endDraw( );
	}

	public void setHue( double theH ) {
		hsl[ 0 ] = Math.max( 0 , Math.min( 1 , theH ) );
	}

	public void setSaturation( double theS ) {
		hsl[ 1 ] = Math.max( 0 , Math.min( 1 , theS ) );
	}

	public void setLightness( double theL ) {
		hsl[ 2 ] = Math.max( 0 , Math.min( 1 , theL ) );
	}

	public ColorWheel setHSL( double theH , double theS , double theL ) {
		setHue( theH );
		setSaturation( theS );
		setLightness( theL );
		return this;
	}

	public int getRGB( ) {
		return _myColorValue;
	}

	public ColorWheel setRGB( int theColor ) {
		double[] t = RGBtoHSL( theColor );
		hsl[ 0 ] = t[ 0 ];
		hsl[ 2 ] = t[ 2 ];

		float theta = ( float ) ( t[ 0 ] * TWO_PI ) - PI;
		float d0 = getWidth( ) * 0.1f;
		float d1 = ( ( getWidth( ) / 2 ) * scalar ) + 1f;
		float s = ( float ) map( t[ 2 ] , 0f , 1f , d1 , d0 );
		float x = _myColorResources.get( "default" ).width / 2 - ( float ) Math.cos( theta ) * s;
		float y = _myColorResources.get( "default" ).height / 2 - ( float ) Math.sin( theta ) * s;
		set( _myCursor , x , y );
		setSaturation( t[ 1 ] );
		_myColorValue = HSLtoRGB( hsl );
		setValue( _myColorValue );

		return this;
	}

	public ColorWheel setAlpha( int theAlpha ) {
		/* TODO */
		return this;
	}

	/**
	 * @exclude
	 */
	@Override @ControlP5.Invisible public ColorWheel updateDisplayMode( int theMode ) {
		return updateViewMode( theMode );
	}

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public ColorWheel updateViewMode( int theMode ) {
		_myDisplayMode = theMode;
		switch ( theMode ) {
		case ( DEFAULT ):
		case ( IMAGE ):
		case ( CUSTOM ):
			_myControllerView = new ColorWheelView( );
		default:
			break;

		}
		return this;
	}

	public int a( ) {
		int a = ( _myColorValue & 0xff000000 ) >> 24;
		return ( a < 0 ) ? 255 : a;
	}

	public int r( ) {
		return ( _myColorValue & 0x00ff0000 ) >> 16;
	}

	public int g( ) {
		return ( _myColorValue & 0x0000ff00 ) >> 8;
	}

	public int b( ) {
		return ( _myColorValue & 0x000000ff ) >> 0;
	}

	private class ColorWheelView implements ControllerView< ColorWheel > {

		public void display( PGraphics theGraphics , ColorWheel theController ) {

			PGraphics buffer = _myColorResources.get( "default" );

			theGraphics.fill( 0 , 100 );
			theGraphics.rect( 0 , 0 , getWidth( ) , getHeight( ) );
			theGraphics.ellipseMode( PApplet.CENTER );
			theGraphics.pushMatrix( );
			theGraphics.translate( 0 , -yoff );
			theGraphics.image( buffer , 0 , 0 );
			theGraphics.pushMatrix( );
			theGraphics.translate( x( _myCursor ) , y( _myCursor ) );
			theGraphics.strokeWeight( 2 );
			theGraphics.noFill( );
			theGraphics.stroke( 255 , 40 );
			theGraphics.ellipse( 1 , 1 , 10 , 10 );
			theGraphics.stroke( 250 );
			theGraphics.fill( _myColorValue );
			theGraphics.ellipse( 0 , 0 , 10 , 10 );

			theGraphics.popMatrix( );
			theGraphics.noStroke( );
			theGraphics.translate( 0 , -yoff );
			theGraphics.fill( HSLtoRGB( hsl[ 0 ] , hsl[ 1 ] , hsl[ 2 ] ) );
			theGraphics.rect( 0 , getHeight( ) , getWidth( ) , yoff * 2 );
			theGraphics.popMatrix( );
			if ( isLabelVisible ) {
				_myCaptionLabel.draw( theGraphics , 0 , 0 , theController );
			}
			if ( isInfo ) {
				_myInfoLabel.setText( String.format( "RGB %d %d %d\nALPHA %d\nHSL %d %.2f %.2f " , r( ) , g( ) , b( ) , a( ) , ( int ) ( hsl[ 0 ] * 360 ) , hsl[ 1 ] , hsl[ 2 ] ) );
				_myInfoLabel.draw( theGraphics , 0 , 0 , theController );
			}
			theGraphics.fill( 255 );
			theGraphics.pushMatrix( );
			int s = _sideHandleHeight / 2;
			float v = ( getHeight( ) - ( yoff * 2 ) - _sideHandleHeight );
			theGraphics.translate( 2 , ( int ) map( hsl[ 1 ] , 1 , 0 , 0 , v ) );
			theGraphics.triangle( 0 , s , s , 0 , s , _sideHandleHeight );
			theGraphics.popMatrix( );
			/* TODO alpha handle theGraphics.pushMatrix( );
			 * theGraphics.translate( getWidth( ) - s - 2 ,
			 * ( int ) map( a( ) , 255 , 0 , 0 , v ) );
			 * theGraphics.triangle( s , s , 0 , 0 , 0 ,
			 * _sideHandleHeight ); theGraphics.popMatrix(
			 * ); */
		}
	}

	public double[] RGBtoHSL( int theRGB ) {
		return RGBtoHSL( theRGB >> 16 & 0xff , theRGB >> 8 & 0xff , theRGB >> 0 & 0xff );
	}

	/**
	 * 
	 * @param theR value between 0 and 255
	 * @param theG value between 0 and 255
	 * @param theB value between 0 and 255
	 * @return double[] values h,s,l are between 0-1
	 */
	public double[] RGBtoHSL( int theR , int theG , int theB ) {
		double[] rgb = new double[ 3 ];
		rgb[ 0 ] = theR / 255.0;
		rgb[ 1 ] = theG / 255.0;
		rgb[ 2 ] = theB / 255.0;
		double max = Math.max( rgb[ 0 ] , Math.max( rgb[ 1 ] , rgb[ 2 ] ) );
		double min = Math.min( rgb[ 0 ] , Math.min( rgb[ 1 ] , rgb[ 2 ] ) );
		double h = ( max + min ) / 2;
		double s = ( max + min ) / 2;
		double l = ( max + min ) / 2;

		if ( max == min ) {
			h = s = 0; // achromatic
		} else {
			double d = max - min;
			s = l > 0.5 ? ( d / ( 2 - max - min ) ) : ( d / ( max + min ) );
			if ( max == rgb[ 0 ] ) {
				h = ( rgb[ 1 ] - rgb[ 2 ] ) / d + ( rgb[ 1 ] < rgb[ 2 ] ? 6 : 0 );
			} else if ( max == rgb[ 1 ] ) {
				h = ( rgb[ 2 ] - rgb[ 0 ] ) / d + 2;
			} else if ( max == rgb[ 2 ] ) {
				h = ( rgb[ 0 ] - rgb[ 1 ] ) / d + 4;
			}
			h /= 6;
		}

		return new double[] { h , s , l };
	}

	public int HSVtoRGB( double[] hsv ) {
		return HSVtoRGB( hsv[ 0 ] , hsv[ 1 ] , hsv[ 2 ] );
	}

	/**
	 * 
	 * @param H value between 0-1
	 * @param S value between 0-1
	 * @param V value between 0-1
	 * @return int
	 */
	public int HSVtoRGB( double H , double S , double V ) {

		/* http://viziblr.com/news/2011/12/1/drawing-a-color-
		 * hue-wheel-with-c.html */

		double[] rgb = new double[ 3 ];

		if ( H == 1.0 ) {
			H = 0.0;
		}

		double step = 1.0 / 6.0;
		double vh = H / step;

		int i = ( int ) Math.floor( vh );

		double f = vh - i;
		double p = V * ( 1.0 - S );
		double q = V * ( 1.0 - ( S * f ) );
		double t = V * ( 1.0 - ( S * ( 1.0 - f ) ) );

		switch ( i ) {
		case 0: {
			rgb[ 0 ] = V;
			rgb[ 1 ] = t;
			rgb[ 2 ] = p;
			break;
		}
		case 1: {
			rgb[ 0 ] = q;
			rgb[ 1 ] = V;
			rgb[ 2 ] = p;
			break;
		}
		case 2: {
			rgb[ 0 ] = p;
			rgb[ 1 ] = V;
			rgb[ 2 ] = t;
			break;
		}
		case 3: {
			rgb[ 0 ] = p;
			rgb[ 1 ] = q;
			rgb[ 2 ] = V;
			break;
		}
		case 4: {
			rgb[ 0 ] = t;
			rgb[ 1 ] = p;
			rgb[ 2 ] = V;
			break;
		}
		case 5: {
			rgb[ 0 ] = V;
			rgb[ 1 ] = p;
			rgb[ 2 ] = q;
			break;
		}
		default: {
			// not possible - if we get here it is an
			// internal error
			// throw new ArgumentException();
			System.out.println( "hsv to rgb not possible" );
		}
		}
		return ( a( ) << 24 ) | ( ( int ) ( rgb[ 0 ] * 255 ) << 16 ) | ( ( int ) ( rgb[ 1 ] * 255 ) << 8 ) | ( int ) ( rgb[ 2 ] * 255 );
	}

	public final double[] RGBtoHSV( final int c ) {
		return RGBtoHSV( ( c & 0xff0000 ) >> 16 , ( c & 0x00ff00 ) >> 8 , ( c & 0x0000ff ) >> 0 );
	}

	/**
	 * 
	 * @param theR value between 0 and 255
	 * @param theG value between 0 and 255
	 * @param theB value between 0 and 255
	 * @return hsv [ hue (0-1) sat (0-1) val (0-1) ]
	 */
	public final double[] RGBtoHSV( final int theR , final int theG , final double theB ) {

		double hue = 0;

		double sat = 0;

		double val = 0;

		final double r = theR / 255.0;
		final double g = theG / 255.0;
		final double b = theB / 255.0;

		double minRGB = Math.min( r , Math.min( g , b ) );
		double maxRGB = Math.max( r , Math.max( g , b ) );

		// Black-gray-white
		if ( minRGB == maxRGB ) {
			return new double[] { 0 , 0 , minRGB };
		}

		// Colors other than black-gray-white:
		double d = ( r == minRGB ) ? g - b : ( ( b == minRGB ) ? r - g : b - r );
		double h = ( r == minRGB ) ? 3 : ( ( b == minRGB ) ? 1 : 5 );
		hue = map( ( h - ( d / ( maxRGB - minRGB ) ) ) , 0 , 6.0 , 0 , 1.0 );
		sat = ( maxRGB - minRGB ) / maxRGB;
		val = maxRGB;
		return new double[] { hue , sat , val };
	}

	public int HSLtoRGB( final double[] theHSL ) {
		if ( theHSL.length == 3 ) {
			return HSLtoRGB( theHSL[ 0 ] , theHSL[ 1 ] , theHSL[ 2 ] );
		} else {
			String message = "HSLtoRGB(double[]) a length of 3 is expected. ";
			throw new IllegalArgumentException( message );
		}

	}

	/**
	 * 
	 * @param h value between 0 and 360
	 * @param s value between 0 and 100
	 * @param l) value between 0 and 100
	 * @param alpha value between 0 and 1
	 * @return
	 */
	public int HSLtoRGB( final double h , double s , double l ) {
		if ( h < 0.0 || h > 1.0 ) {
			String message = "Color parameter outside of expected range - Hue ( 0.0 - 1.0 )";
			throw new IllegalArgumentException( message );
		}
		if ( s < 0.0 || s > 1.0 ) {
			String message = "Color parameter outside of expected range - Saturation ( 0.0 - 1.0 )";
			throw new IllegalArgumentException( message );
		}

		if ( l < 0.0 || l > 1.0 ) {
			String message = "Color parameter outside of expected range - Luminance ( 0.0 - 1.0 )";
			throw new IllegalArgumentException( message );
		}

		double q = 0;

		if ( l < 0.5 ) {
			q = l * ( 1 + s );
		} else {
			q = ( l + s ) - ( s * l );
		}

		double p = 2 * l - q;

		double r = Math.max( 0 , HueToRGB( p , q , h + ( 1.0f / 3.0f ) ) );
		double g = Math.max( 0 , HueToRGB( p , q , h ) );
		double b = Math.max( 0 , HueToRGB( p , q , h - ( 1.0f / 3.0f ) ) );

		return ( 255 << 24 ) | ( ( int ) ( r * 255 ) << 16 ) | ( ( int ) ( g * 255 ) << 8 ) | ( int ) ( b * 255 );
	}

	private static double HueToRGB( double p , double q , double h ) {
		if ( h < 0 )
			h += 1;

		if ( h > 1 )
			h -= 1;

		if ( 6 * h < 1 ) {
			return p + ( ( q - p ) * 6 * h );
		}

		if ( 2 * h < 1 ) {
			return q;
		}

		if ( 3 * h < 2 ) {
			return p + ( ( q - p ) * 6 * ( ( 2.0f / 3.0f ) - h ) );
		}

		return p;
	}

	private final double map( double val , double a1 , double a2 , double b1 , double b2 ) {
		return b1 + ( b2 - b1 ) * ( ( val - a1 ) / ( a2 - a1 ) );
	}
}
