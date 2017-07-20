/**
 * grafica
 * Create simple and configurable 2D plots with Processing.
 * http://jagracar.com/grafica.php
 *
 * Copyright (c) 2015 Javier Gracia Carpio http://jagracar.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 * 
 * @author      Javier Gracia Carpio http://jagracar.com
 * @modified    03/15/2016
 * @version     1.5.0 (6)
 */

package grafica;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PFont;

/**
 * Title class.
 * 
 * @author Javier Gracia Carpio http://jagracar.com
 */
public class GTitle implements PConstants {
    // The parent Processing applet
    protected final PApplet parent;

    // General properties
    protected float[] dim;
    protected float relativePos;
    protected float plotPos;
    protected float offset;

    // Text properties
    protected String text;
    protected int textAlignment;
    protected String fontName;
    protected int fontColor;
    protected int fontSize;
    protected PFont font;

    /**
     * Constructor
     * 
     * @param parent
     *            the parent Processing applet
     * @param dim
     *            the plot box dimensions in pixels
     */
    public GTitle(PApplet parent, float[] dim) {
        this.parent = parent;

        this.dim = dim.clone();
        relativePos = 0.5f;
        plotPos = relativePos * this.dim[0];
        offset = 10;

        text = "";
        textAlignment = CENTER;
        fontName = "SansSerif.bold";
        fontColor = this.parent.color(100);
        fontSize = 13;
        font = this.parent.createFont(fontName, fontSize);
    }

    /**
     * Draws the plot title
     */
    public void draw() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.noStroke();
        parent.textAlign(textAlignment, BOTTOM);
        parent.text(text, plotPos, -offset - dim[1]);
        parent.popStyle();
    }

    /**
     * Sets the plot box dimensions information
     * 
     * @param xDim
     *            the new plot box x dimension
     * @param yDim
     *            the new plot box y dimension
     */
    public void setDim(float xDim, float yDim) {
        if (xDim > 0 && yDim > 0) {
            dim[0] = xDim;
            dim[1] = yDim;
            plotPos = relativePos * dim[0];
        }
    }

    /**
     * Sets the plot box dimensions information
     * 
     * @param newDim
     *            the new plot box dimensions information
     */
    public void setDim(float[] newDim) {
        setDim(newDim[0], newDim[1]);
    }

    /**
     * Sets the title relative position in the plot
     * 
     * @param newRelativePos
     *            the new relative position in the plot
     */
    public void setRelativePos(float newRelativePos) {
        relativePos = newRelativePos;
        plotPos = relativePos * dim[0];
    }

    /**
     * Sets the title offset
     * 
     * @param newOffset
     *            the new title offset
     */
    public void setOffset(float newOffset) {
        offset = newOffset;
    }

    /**
     * Sets the title text
     * 
     * @param newText
     *            the new title text
     */
    public void setText(String newText) {
        text = newText;
    }

    /**
     * Sets the title type of text alignment
     * 
     * @param newTextAlignment
     *            the new type of text alignment
     */
    public void setTextAlignment(int newTextAlignment) {
        if (newTextAlignment == CENTER || newTextAlignment == LEFT || newTextAlignment == RIGHT) {
            textAlignment = newTextAlignment;
        }
    }

    /**
     * Sets the font name
     * 
     * @param newFontName
     *            the name of the new font
     */
    public void setFontName(String newFontName) {
        fontName = newFontName;
        font = parent.createFont(fontName, fontSize);
    }

    /**
     * Sets the font color
     * 
     * @param newFontColor
     *            the new font color
     */
    public void setFontColor(int newFontColor) {
        fontColor = newFontColor;
    }

    /**
     * Sets the font size
     * 
     * @param newFontSize
     *            the new font size
     */
    public void setFontSize(int newFontSize) {
        if (newFontSize > 0) {
            fontSize = newFontSize;
            font = parent.createFont(fontName, fontSize);
        }
    }

    /**
     * Sets all the font properties at once
     * 
     * @param newFontName
     *            the name of the new font
     * @param newFontColor
     *            the new font color
     * @param newFontSize
     *            the new font size
     */
    public void setFontProperties(String newFontName, int newFontColor, int newFontSize) {
        if (newFontSize > 0) {
            fontName = newFontName;
            fontColor = newFontColor;
            fontSize = newFontSize;
            font = parent.createFont(fontName, fontSize);
        }
    }
}
