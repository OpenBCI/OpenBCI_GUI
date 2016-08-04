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

import java.util.ArrayList;

import processing.core.PApplet;
import static controlP5.Controller.*;

public class ControlP5Legacy {

	private ControlP5Base base;
	public static boolean DEBUG = false;

	void init( ControlP5Base theControlP5 ) {
		base = theControlP5;
	}

	public Spacer addSpacer( final String theName ) {
		return addSpacer( theName , 0 , 0 , 100 , 20 );
	}

	public Spacer addSpacer( final String theName , final int theX , final int theY , final int theW , final int theH ) {
		ControllerGroup tab = ( ControllerGroup< ? > ) base.cp5.controlWindow.getTabs( ).get( 1 );
		Spacer myController = new Spacer( base.cp5 , tab , theName , theX , theY , theW , theH );
		base.cp5.register( null , "" , myController );
		return myController;
	}

	public Background addBackground( final String theName ) {
		return addBackground( null , "" , theName , 0 , 0 , 300 , base.cp5.papplet.height );
	}

	public Background addBackground( Object theObject , final String theIndex , String theName , int theX , int theY , int theW , int theHeight ) {
		Background myController = new Background( base.cp5 , ( ControllerGroup< ? > ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , theHeight );
		base.cp5.register( theObject , theIndex , myController );
		return myController;
	}

	public Button addButton( final Object theObject , String theIndex , final String theName , final float theValue , final int theX , final int theY , final int theW , final int theH ) {
		Button myController = new Button( base.cp5 , ( ControllerGroup< ? > ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theValue , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" );
		myController.getProperty( "value" ).disable( );
		return myController;
	}

	public Icon addIcon( final Object theObject , String theIndex , final String theName , final float theValue , final int theX , final int theY , final int theW , final int theH ) {
		Icon myController = new Icon( base.cp5 , ( ControllerGroup< ? > ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theValue , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" );
		myController.getProperty( "value" ).disable( );
		return myController;
	}

	public ButtonBar addButtonBar( final Object theObject , String theIndex , final String theName , final float theValue , final int theX , final int theY , final int theW , final int theH ) {
		ButtonBar myController = new ButtonBar( base.cp5 , ( ControllerGroup< ? > ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" );
		myController.getProperty( "value" ).disable( );
		return myController;
	}

	public Bang addBang( final Object theObject , String theIndex , final String theName , final int theX , final int theY , final int theWidth , final int theHeight ) {
		Bang myController = new Bang( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theWidth , theHeight );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" );
		myController.getProperty( "value" ).disable( );
		return myController;
	}

	public Toggle addToggle( final Object theObject , String theIndex , final String theName , final boolean theDefaultValue , final float theX , final float theY , final int theWidth , final int theHeight ) {
		Toggle myController = new Toggle( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , ( theDefaultValue == true ) ? 1f : 0f , theX , theY , theWidth , theHeight );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" );
		return myController;
	}

	public Tooltip addTooltip( ) {
		println( "Tooltip is not available with this Version (" , ControlP5.VERSION , ") of ControlP5" );
		return null;
	}

	public Matrix addMatrix( final Object theObject , final String theIndex , final String theName , final int theCellX , final int theCellY , final int theX , final int theY , final int theWidth , final int theHeight ) {
		Matrix myController = new Matrix( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theCellX , theCellY , theX , theY , theWidth , theHeight );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "cells" ).registerProperty( "interval" );
		return myController;
	}

	public Matrix addMatrix( final String theName , final int theCellX , final int theCellY , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addMatrix( null , "" , theName , theCellX , theCellY , theX , theY , theWidth , theHeight );
	}

	public Slider2D addSlider2D( Object theObject , final String theIndex , final String theName , float theMinX , float theMaxX , float theMinY , float theMaxY , float theDefaultValueX , float theDefaultValueY , int theX , int theY , int theW , int theH ) {
		Slider2D myController = new Slider2D( base.cp5 , ( ControllerGroup< ? > ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.setMinX( theMinX );
		myController.setMaxX( theMaxX );
		myController.setMinY( theMinY );
		myController.setMaxY( theMaxY );
		myController.setArrayValue( new float[] { theDefaultValueX , theDefaultValueY } );
		myController.updateValue( );
		myController.registerProperty( "arrayValue" ).registerProperty( "minX" ).registerProperty( "maxX" ).registerProperty( "minY" ).registerProperty( "maxY" );
		return myController;
	}

	public Slider addSlider( Object theObject , final String theIndex , final String theName , float theMin , float theMax , float theDefaultValue , int theX , int theY , int theW , int theH ) {
		Slider myController = new Slider( base.cp5 , ( ControllerGroup< ? > ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theMin , theMax , theDefaultValue , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" ).registerProperty( "min" ).registerProperty( "max" );
		return myController;
	}

	public Slider addSlider( String theName , float theMin , float theMax , float theDefaultValue , int theX , int theY , int theW , int theH ) {
		return addSlider( null , "" , theName , theMin , theMax , theDefaultValue , theX , theY , theW , theH );
	}

	public Slider addSlider( final String theName , final float theMin , final float theMax , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addSlider( null , "" , theName , theMin , theMax , theMin , theX , theY , theWidth , theHeight );
	}

	public Slider addSlider( Object theObject , final String theIndex , final String theName , float theMin , float theMax , int theX , int theY , int theW , int theH ) {
		return addSlider( theObject , theIndex , theName , theMin , theMax , theMin , theX , theY , theW , theH );
	}

	public Range addRange( Object theObject , final String theIndex , String theName , float theMin , float theMax , float theDefaultMinValue , float theDefaultMaxValue , int theX , int theY , int theW , int theH ) {
		Range myController = new Range( base.cp5 , ( ControllerGroup< ? > ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theMin , theMax , theDefaultMinValue , theDefaultMaxValue , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "lowValue" ).registerProperty( "highValue" );
		return myController;
	}

	public Range addRange( String theName , float theMin , float theMax , float theDefaultMinValue , float theDefaultMaxValue , int theX , int theY , int theW , int theH ) {
		return addRange( null , "" , theName , theMin , theMax , theDefaultMinValue , theDefaultMaxValue , theX , theY , theW , theH );
	}

	public Range addRange( final String theName , final float theMin , final float theMax , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addRange( null , "" , theName , theMin , theMax , theMin , theMax , theX , theY , theWidth , theHeight );
	}

	public Range addRange( final Object theObject , final String theIndex , final String theName , final float theMin , final float theMax , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addRange( theObject , theIndex , theName , theMin , theMax , theMin , theMax , theX , theY , theWidth , theHeight );
	}

	public Numberbox addNumberbox( final Object theObject , final String theIndex , final String theName , final float theDefaultValue , final int theX , final int theY , final int theWidth , final int theHeight ) {
		Numberbox myController = new Numberbox( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theDefaultValue , theX , theY , theWidth , theHeight );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" );
		return myController;
	}

	public Numberbox addNumberbox( final String theName , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addNumberbox( null , "" , theName , Float.NaN , theX , theY , theWidth , theHeight );
	}

	public Numberbox addNumberbox( final Object theObject , final String theIndex , final String theName , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addNumberbox( theObject , theIndex , theName , Float.NaN , theX , theY , theWidth , theHeight );
	}

	public Numberbox addNumberbox( final String theName , final float theDefaultValue , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addNumberbox( null , "" , theName , theDefaultValue , theX , theY , theWidth , theHeight );
	}

	public Knob addKnob( final Object theObject , final String theIndex , final String theName , final float theMin , final float theMax , final float theDefaultValue , final int theX , final int theY , final int theDiameter ) {
		Knob myController = new Knob( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theMin , theMax , theDefaultValue , theX , theY , theDiameter );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" );
		return myController;
	}

	public Knob addKnob( final String theName , final float theMin , final float theMax , final int theX , final int theY , final int theDiameter ) {
		return addKnob( null , "" , theName , theMin , theMax , theMin , theX , theY , theDiameter );
	}

	public Knob addKnob( final Object theObject , final String theIndex , final String theName , final float theMin , final float theMax , final int theX , final int theY , final int theDiameter ) {
		return addKnob( theObject , theIndex , theName , theMin , theMax , theX , theY , theDiameter );
	}

	public Knob addKnob( final String theName , final float theMin , final float theMax , final float theDefaultValue , final int theX , final int theY , final int theDiameter ) {
		return addKnob( null , "" , theName , theMin , theMax , theDefaultValue , theX , theY , theDiameter );
	}

	public MultiList addMultiList( final Object theObject , final String theIndex , final String theName , final int theX , final int theY , final int theWidth , final int theHeight ) {
		MultiList myController = new MultiList( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theWidth , theHeight );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" );
		return myController;
	}

	public MultiList addMultiList( final String theName , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addMultiList( null , "" , theName , theX , theY , theWidth , theHeight );
	}

	public Textlabel addLabel( String theIndex ) {
		return addTextlabel( theIndex , theIndex , 0 , 0 );
	}

	public Textlabel addLabel( String theIndex , int theX , int theY ) {
		return addTextlabel( theIndex , theIndex , theX , theY );
	}

	public Textlabel addTextlabel( final Object theObject , final String theIndex , final String theName , final String theText , final int theX , final int theY ) {
		Textlabel myController = new Textlabel( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theText , theX , theY );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" ).registerProperty( "stringValue" );
		return myController;
	}

	public Textlabel addTextlabel( final String theName , final String theText , final int theX , final int theY ) {
		return addTextlabel( null , "" , theName , theText , theX , theY );
	}

	public Textlabel addTextlabel( final Object theObject , final String theIndex , final String theName , final String theText ) {
		return addTextlabel( theObject , theIndex , theName , theText , 0 , 0 );
	}

	public Textlabel addTextlabel( final String theName , final String theText ) {
		return addTextlabel( null , "" , theName , theText , 0 , 0 );
	}

	public Textarea addTextarea( final String theName , final String theText , final int theX , final int theY , final int theW , final int theH ) {
		Textarea myController = new Textarea( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theText , theX , theY , theW , theH );
		base.cp5.register( null , "" , myController );
		myController.registerProperty( "text" );
		return myController;
	}

	public Textfield addTextfield( final Object theObject , final String theIndex , final String theName , final int theX , final int theY , final int theW , final int theH ) {
		Textfield myController = new Textfield( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , "" , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "text" );
		return myController;
	}

	public Textfield addTextfield( final String theName , final int theX , final int theY , final int theW , final int theH ) {
		return addTextfield( null , "" , theName , theX , theY , theW , theH );
	}

	public Textfield addTextfield( final Object theObject , final String theIndex , final String theName ) {
		return addTextfield( theObject , theIndex , theName , 0 , 0 , 99 , 19 );
	}

	public Accordion addAccordion( String theName , int theX , int theY , int theWidth ) {
		Accordion myController = new Accordion( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theWidth );
		base.cp5.register( null , "" , myController );
		return myController;
	}

	public Accordion addAccordion( final Object theObject , final String theIndex , final String theName ) {
		Accordion myController = new Accordion( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , 0 , 0 , 200 );
		base.cp5.register( theObject , theIndex , myController );
		return myController;
	}

	public RadioButton addRadioButton( final Object theObject , String theIndex , final String theName , final int theX , final int theY ) {
		RadioButton myController = new RadioButton( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "arrayValue" );
		return myController;
	}

	public RadioButton addRadioButton( final String theName , final int theX , final int theY ) {
		return addRadioButton( null , "" , theName , theX , theY );
	}

	/**
	 * Use radio buttons for multiple choice options.
	 */
	public RadioButton addRadio( final String theName ) {
		return addRadioButton( theName , 0 , 0 );
	}

	public RadioButton addRadio( final String theName , final int theX , final int theY ) {
		RadioButton myController = new RadioButton( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY );
		base.cp5.register( null , "" , myController );
		myController.registerProperty( "arrayValue" );
		return myController;
	}

	public CheckBox addCheckBox( final Object theObject , final String theIndex , final String theName , final int theX , final int theY ) {
		CheckBox myController = new CheckBox( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "arrayValue" );
		return myController;
	}

	public CheckBox addCheckBox( final String theName , final int theX , final int theY ) {
		return addCheckBox( null , "" , theName , theX , theY );
	}

	public ScrollableList addScrollableList( final Object theObject , String theIndex , final String theName ) {
		return addScrollableList( theObject , theIndex , theName , 0 , 0 , 100 , 100 );
	}

	public ScrollableList addScrollableList( final Object theObject , String theIndex , final String theName , final int theX , final int theY , final int theW , final int theH ) {
		ScrollableList myController = new ScrollableList( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "value" );
		return myController;
	}

	public ScrollableList addScrollableList( final String theName , final int theX , final int theY , final int theW , final int theH ) {
		return addScrollableList( null , "" , theName , theX , theY , theW , theH );
	}

	/**
	 * A list box is a list of items a user can choose from.
	 * When items exceed the dedicated area of a list box, a
	 * scrollbar is added to the right of the box. the Box
	 * can be navigated using mouse click, drag and the
	 * mouse-wheel.
	 */
	public ListBox addListBox( final String theName ) {
		return addListBox( theName , 0 , 0 , 99 , 199 );
	}

	public ListBox addListBox( final Object theObject , String theIndex , final String theName , final int theX , final int theY , final int theW , final int theH ) {
		ListBox myController = new ListBox( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "listBoxItems" ).registerProperty( "value" );
		return myController;
	}

	public ListBox addListBox( final String theName , final int theX , final int theY , final int theW , final int theH ) {
		return addListBox( null , "" , theName , theX , theY , theW , theH );
	}

	public DropdownList addDropdownList( final String theName ) {
		return addDropdownList( theName , 0 , 0 , 99 , 99 );
	}

	public DropdownList addDropdownList( final Object theObject , final String theIndex , final String theName , final int theX , final int theY , final int theW , final int theH ) {
		DropdownList myController = new DropdownList( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "listBoxItems" ).registerProperty( "value" );
		return myController;
	}

	public DropdownList addDropdownList( final String theName , final int theX , final int theY , final int theW , final int theH ) {
		return addDropdownList( null , "" , theName , theX , theY , theW , theH );
	}

	public ColorWheel addColorWheel( final Object theObject , final String theIndex , final String theName , final int theX , final int theY , final int theW ) {
		ColorWheel myController = new ColorWheel( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , theW );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "arrayValue" );
		return myController;
	}

	public ColorWheel addColorWheel( final String theName , final int theX , final int theY , final int theW ) {
		return addColorWheel( null , "" , theName , theX , theY , theW );
	}

	public ColorPicker addColorPicker( final String theName , final int theX , final int theY , final int theW , final int theH ) {
		return addColorPicker( null , "" , theName , theX , theY , theW , theH );
	}

	public ColorPicker addColorPicker( final Object theObject , final String theIndex , final String theName , final int theX , final int theY , final int theW , final int theH ) {
		ColorPicker myController = new ColorPicker( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , theH );
		base.cp5.register( theObject , theIndex , myController );
		myController.registerProperty( "arrayValue" );
		return myController;
	}

	public Chart addChart( String theName , int theX , int theY , int theW , int theH ) {
		Chart myController = new Chart( base.cp5 , ( Tab ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , theH );
		base.cp5.register( null , "" , myController );
		return myController;
	}

	public Group addGroup( Object theObject , final String theIndex , String theName , int theX , int theY , int theW ) {
		Group myController = new Group( base.cp5 , ( ControllerGroup< ? > ) base.cp5.controlWindow.getTabs( ).get( 1 ) , theName , theX , theY , theW , 9 );
		base.cp5.register( theObject , theIndex , myController );
		return myController;
	}

	public Group addGroup( Object theObject , String theIndex , String theName , int theX , int theY ) {
		return addGroup( theObject , theIndex , theName , theX , theY , 99 );
	}

	public Group addGroup( String theName , int theX , int theY , int theW ) {
		return addGroup( null , "" , theName , theX , theY , theW );
	}

	public Group addGroup( Object theObject , String theIndex , String theName ) {
		return addGroup( theObject , theIndex , theName , 0 , 0 );
	}

	public Group addGroup( String theName , int theX , int theY ) {
		return addGroup( null , "" , theName , theX , theY , 99 );
	}

	public Textlabel getTextlabel( String theText , int theX , int theY ) {
		return new Textlabel( base.cp5 , theText , theX , theY );
	}

	public Textlabel getTextlabel( ) {
		return getTextlabel( "" , 0 , 0 );
	}

	public Slider addSlider( Object theObject , final String theIndex , String theName ) {
		return addSlider( theObject , theIndex , theName , 0 , 100 );
	}

	public Slider addSlider( String theName , float theMin , float theMax ) {
		return addSlider( null , "" , theName , theMin , theMax );
	}

	public Slider addSlider( Object theObject , final String theIndex , String theName , float theMin , float theMax ) {
		int x = ( int ) x( base.currentGroupPointer.autoPosition );
		int y = ( int ) y( base.currentGroupPointer.autoPosition );
		Slider s = addSlider( theObject , theIndex , theName , theMin , theMax , theMin , x , y , Slider.autoWidth , Slider.autoHeight );
		base.linebreak( s , false , Slider.autoWidth , Slider.autoHeight , Slider.autoSpacing );
		s.moveTo( base.currentGroupPointer );
		if ( base.autoDirection == ControlP5Constants.VERTICAL ) {
			s.linebreak( );
		}
		return s;
	}

	public Button addButton( Object theObject , final String theIndex , String theName ) {
		return addButton( theObject , theIndex , theName , 1 );
	}

	public Button addButton( String theName , float theValue ) {
		return addButton( null , "" , theName , theValue );
	}

	public Button addButton( Object theObject , final String theIndex , String theName , float theValue ) {
		int x = ( int ) x( base.currentGroupPointer.autoPosition );
		int y = ( int ) y( base.currentGroupPointer.autoPosition );
		Button b = addButton( theObject , theIndex , theName , theValue , x , y , Button.autoWidth , Button.autoHeight );
		base.linebreak( b , false , Button.autoWidth , Button.autoHeight , Button.autoSpacing );
		b.moveTo( base.currentGroupPointer );
		return b;
	}

	public ButtonBar addButtonBar( Object theObject , final String theIndex , String theName , float theValue ) {
		int x = ( int ) x( base.currentGroupPointer.autoPosition );
		int y = ( int ) y( base.currentGroupPointer.autoPosition );
		ButtonBar b = addButtonBar( theObject , theIndex , theName , theValue , x , y , Button.autoWidth , Button.autoHeight );
		base.linebreak( b , false , Button.autoWidth , Button.autoHeight , Button.autoSpacing );
		b.moveTo( base.currentGroupPointer );
		return b;
	}

	public Icon addIcon( Object theObject , final String theIndex , String theName ) {
		return addIcon( theObject , theIndex , theName , 1 );
	}

	public Icon addIcon( String theName , float theValue ) {
		return addIcon( null , "" , theName , theValue );
	}

	public Icon addIcon( Object theObject , final String theIndex , String theName , float theValue ) {
		int x = ( int ) x( base.currentGroupPointer.autoPosition );
		int y = ( int ) y( base.currentGroupPointer.autoPosition );
		Icon icon = addIcon( theObject , theIndex , theName , theValue , x , y , Icon.autoWidth , Icon.autoHeight );
		base.linebreak( icon , false , Icon.autoWidth , Icon.autoHeight , Icon.autoSpacing );
		icon.moveTo( base.currentGroupPointer );
		return icon;
	}

	public Bang addBang( Object theObject , final String theIndex , String theName ) {
		int x = ( int ) x( base.currentGroupPointer.autoPosition );
		int y = ( int ) y( base.currentGroupPointer.autoPosition );
		Bang b = addBang( theObject , theIndex , theName , x , y , Bang.autoWidth , Bang.autoHeight );
		base.linebreak( b , false , Bang.autoWidth , Bang.autoHeight , Bang.autoSpacing );
		b.moveTo( base.currentGroupPointer );
		return b;
	}

	public Toggle addToggle( Object theObject , final String theIndex , String theName ) {
		return addToggle( theObject , theIndex , theName , false );
	}

	public Toggle addToggle( Object theObject , final String theIndex , String theName , boolean theValue ) {
		Toggle t = addToggle( theObject , theIndex , theName , theValue , x( base.currentGroupPointer.autoPosition ) , y( base.currentGroupPointer.autoPosition ) , Toggle.autoWidth , Toggle.autoHeight );
		base.linebreak( t , false , Toggle.autoWidth , Toggle.autoHeight , t.autoSpacing );
		t.moveTo( base.currentGroupPointer );
		return t;
	}

	public Numberbox addNumberbox( Object theObject , final String theIndex , String theName ) {
		int x = ( int ) x( base.currentGroupPointer.autoPosition );
		int y = ( int ) y( base.currentGroupPointer.autoPosition );
		Numberbox n = addNumberbox( theObject , theIndex , theName , x , y , Numberbox.autoWidth , Numberbox.autoHeight );
		base.linebreak( n , false , Numberbox.autoWidth , Numberbox.autoHeight , n.autoSpacing );
		n.moveTo( base.currentGroupPointer );
		return n;
	}

	public Toggle addToggle( String theName , boolean theValue ) {
		return addToggle( null , "" , theName , theValue );
	}

	public Knob addKnob( Object theObject , final String theIndex , String theName , int theMin , int theMax ) {
		Knob n = addKnob( theObject , theIndex , theName , theMin , theMax , theMin , ( int ) x( base.currentGroupPointer.autoPosition ) , ( int ) y( base.currentGroupPointer.autoPosition ) , Knob.autoWidth );
		base.linebreak( n , false , Knob.autoWidth , Knob.autoHeight , n.autoSpacing );
		n.moveTo( base.currentGroupPointer );
		return n;
	}

	public Knob addKnob( Object theObject , final String theIndex , String theName ) {
		return addKnob( theObject , theIndex , theName , 0 , 100 );
	}

	public Knob addKnob( String theName , int theMin , int theMax ) {
		return addKnob( null , "" , theName , theMin , theMax );
	}

	public ControlWindow addControlWindow( String theName ) {
		ControlP5.logger( ).warning( "ControlWindow has been disabled currently, please have a look at the changlog.txt file inside the src folder." );
		return null;
	}

	/**
	 * Adds Controllers by Object reference, currently
	 * supports Slider, Bang, Button, Knob, Numberbox,
	 * Toggle, Textlabel, Textfield, Range, Slider2D. For
	 * internal use rather than on application level.
	 */
	public < C > C addController( final Object theObject , final String theIndex , final String theName , final Class< C > theClass , int theX , int theY ) {
		Controller< ? > c = null;
		if ( theClass.equals( Slider.class ) ) {
			c = addSlider( theObject , theIndex , theName , 0 , 100 , 0 , 0 , 0 , 99 , 9 );
		} else if ( theClass.equals( Bang.class ) ) {
			c = addBang( theObject , theIndex , theName , 0 , 0 , 19 , 19 );
		} else if ( theClass.equals( Button.class ) ) {
			c = addButton( theObject , theIndex , theName , 0 , 0 , 0 , 49 , 19 );
		} else if ( theClass.equals( Knob.class ) ) {
			c = addKnob( theObject , theIndex , theName , 0 , 100 , 0 , 0 , 0 , 49 );
		} else if ( theClass.equals( Numberbox.class ) ) {
			c = addNumberbox( theObject , theIndex , theName , 0 , 0 , 0 , 99 , 19 );
		} else if ( theClass.equals( Toggle.class ) ) {
			c = addToggle( theObject , theIndex , theName , false , 0 , 0 , 49 , 19 );
		} else if ( theClass.equals( Textfield.class ) ) {
			c = addTextfield( theObject , theIndex , theName , 0 , 0 , 99 , 19 );
		} else if ( theClass.equals( Range.class ) ) {
			c = addRange( theObject , theIndex , theName , 0 , 100 , 0 , 100 , 0 , 0 , 99 , 9 );
		} else if ( theClass.equals( Slider2D.class ) ) {
			c = addSlider2D( theObject , theIndex , theName , 0 , 100 , 0 , 100 , 0 , 0 , 0 , 0 , 99 , 99 );
		} else if ( theClass.equals( DropdownList.class ) ) {
			c = addDropdownList( theObject , theIndex , theName , theX , theY , 199 , 99 );
		} else if ( theClass.equals( ListBox.class ) ) {
			c = addListBox( theObject , theIndex , theName , theX , theY , 199 , 99 );
		} else if ( theClass.equals( ScrollableList.class ) ) {
			c = addScrollableList( theObject , theIndex , theName , theX , theY , 199 , 99 );
		} else if ( theClass.equals( Textlabel.class ) ) {
			c = addTextlabel( theName , "<empty>" );
		}
		// TODO MultiList, Matrix
		c.setPosition( theX , theY );
		return ( C ) c;
	}

	/**
	 * Use with caution, only for internal use.
	 * 
	 * @exclude
	 */
	@ControlP5.Invisible public < C > C addGroup( final Object theObject , final String theIndex , final String theName , final Class< C > theClass , int theX , int theY , int theW , int theH ) {
		ControlGroup< ? > c = null;
		if ( theClass.equals( RadioButton.class ) ) {
			c = addRadioButton( theObject , theIndex , theName , theX , theY );
		} else if ( theClass.equals( CheckBox.class ) ) {
			c = addCheckBox( theObject , theIndex , theName , theX , theY );
		} else if ( theClass.equals( ControlGroup.class ) ) {
			c = addGroup( theObject , theIndex , theName , theX , theY );
		} else if ( theClass.equals( Group.class ) ) {
			c = addGroup( theObject , theIndex , theName , theX , theY );
		}
		c.setPosition( theX , theY );
		c.setWidth( theW );
		c.setHeight( theH );
		return ( C ) c;
	}

	public < C > C addController( String theName , Class< C > theClass , int theX , int theY ) {
		return addController( null , "" , theName , theClass , theX , theY );
	}

	static public void println( final Object ... strs ) {
		for ( Object str : strs ) {
			System.out.print( str + " " );
		}
		System.out.println( );
	}

	static public void debug( final Object ... strs ) {
		if ( DEBUG ) {
			println( strs );
		}
	}

	static public void printerr( final Object ... strs ) {
		for ( Object str : strs ) {
			System.err.print( str + " " );
		}
		System.err.println( );
	}

	@Deprecated public Controller< ? > getController( String theName , Object theObject ) {
		if ( base._myObjectToControllerMap.containsKey( theObject ) ) {
			ArrayList< ControllerInterface< ? >> cs = base._myObjectToControllerMap.get( theObject );
			for ( ControllerInterface< ? > c : cs ) {
				if ( c.getName( ).equals( theName ) ) {
					return ( Controller< ? > ) c;
				}
			}
		}
		return null;
	}

	@Deprecated public Tab addTab( PApplet theWindow , String theName ) {
		return addTab( base.cp5.controlWindow , theName );
	}

	@Deprecated public Tab addTab( ControlWindow theWindow , String theName ) {
		for ( int i = 0 ; i < theWindow.getTabs( ).size( ) ; i++ ) {
			if ( theWindow.getTabs( ).get( i ).getName( ).equals( theName ) ) {
				return ( Tab ) theWindow.getTabs( ).get( i );
			}
		}
		Tab myTab = new Tab( base.cp5 , theWindow , theName );
		theWindow.getTabs( ).add( myTab );
		return myTab;
	}

	@Deprecated public ControlWindow addControlWindow( final String theName , final int theX , final int theY , final int theWidth , final int theHeight , String theRenderer , int theFrameRate ) {
		return addControlWindow( theName );
	}

	@Deprecated public ControlWindow addControlWindow( final String theWindowName , final int theWidth , final int theHeight ) {
		return addControlWindow( theWindowName , 100 , 100 , theWidth , theHeight , "" , 30 );
	}

	@Deprecated public ControlWindow addControlWindow( final String theWindowName , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addControlWindow( theWindowName , theX , theY , theWidth , theHeight , "" , 30 );
	}

	@Deprecated public ControlWindow addControlWindow( final String theWindowName , final int theX , final int theY , final int theWidth , final int theHeight , final int theFrameRate ) {
		return addControlWindow( theWindowName , theX , theY , theWidth , theHeight , "" , theFrameRate );
	}

	@Deprecated public Slider2D addSlider2D( String theName , int theX , int theY , int theW , int theH ) {
		return addSlider2D( null , "" , theName , 0 , theW , 0 , theH , 0 , 0 , theX , theY , theW , theH );
	}

	@Deprecated public Slider2D addSlider2D( Object theObject , final String theIndex , final String theName , int theX , int theY , int theW , int theH ) {
		return addSlider2D( theObject , theIndex , theName , 0 , theW , 0 , theH , 0 , 0 , theX , theY , theW , theH );
	}

	@Deprecated public Slider2D addSlider2D( String theName , float theMinX , float theMaxX , float theMinY , float theMaxY , float theDefaultValueX , float theDefaultValueY , int theX , int theY , int theW , int theH ) {
		return addSlider2D( null , "" , theName , theMinX , theMaxX , theMinY , theMaxY , theDefaultValueX , theDefaultValueY , theX , theY , theW , theH );
	}

	@Deprecated public Button addButton( final String theName , final float theValue , final int theX , final int theY , final int theW , final int theH ) {
		return addButton( null , "" , theName , theValue , theX , theY , theW , theH );
	}

	@Deprecated public Bang addBang( final String theName , final int theX , final int theY ) {
		return addBang( null , "" , theName , theX , theY , 20 , 20 );
	}

	@Deprecated public Bang addBang( final String theName , final int theX , final int theY , final int theWidth , final int theHeight ) {
		return addBang( null , "" , theName , theX , theY , theWidth , theHeight );
	}

	@Deprecated public Toggle addToggle( final String theName , final boolean theDefaultValue , final float theX , final float theY , final int theWidth , final int theHeight ) {
		return addToggle( null , "" , theName , theDefaultValue , theX , theY , theWidth , theHeight );
	}

	@Deprecated public Toggle addToggle( final String theName , final float theX , final float theY , final int theWidth , final int theHeight ) {
		return addToggle( null , "" , theName , false , theX , theY , theWidth , theHeight );
	}

	@Deprecated public Toggle addToggle( final Object theObject , final String theIndex , final String theName , final float theX , final float theY , final int theWidth , final int theHeight ) {
		return addToggle( theObject , theIndex , theName , false , theX , theY , theWidth , theHeight );
	}
}
