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
 * Axis label class.
 * 
 * @author Javier Gracia Carpio http://jagracar.com
 */
public class GAxisLabel implements PConstants {
    // The parent Processing applet
    protected final PApplet parent;

    // General properties
    protected final int type;
    protected float[] dim;
    protected float relativePos;
    protected float plotPos;
    protected float offset;
    protected boolean rotate;

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
     * @param type
     *            the axis label type. It can be X, Y, TOP or RIGHT
     * @param dim
     *            the plot box dimensions in pixels
     */
    public GAxisLabel(PApplet parent, int type, float[] dim) {
        this.parent = parent;

        this.type = (type == X || type == Y || type == TOP || type == RIGHT) ? type : X;
        this.dim = dim.clone();
        relativePos = 0.5f;
        plotPos = (this.type == X || this.type == TOP) ? relativePos * this.dim[0] : -relativePos * this.dim[1];
        offset = 35;
        rotate = (this.type == X || this.type == TOP) ? false : true;

        text = "";
        textAlignment = CENTER;
        fontName = "SansSerif.plain";
        fontColor = this.parent.color(0);
        fontSize = 13;
        font = this.parent.createFont(fontName, fontSize);
    }

    /**
     * Draws the axis label
     */
    public void draw() {
        switch (type) {
        case X:
            drawAsXLabel();
            break;
        case Y:
            drawAsYLabel();
            break;
        case TOP:
            drawAsTopLabel();
            break;
        case RIGHT:
            drawAsRightLabel();
            break;
        }
    }

    /**
     * Draws the axis label as an X axis label
     */
    protected void drawAsXLabel() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.noStroke();

        if (rotate) {
            parent.textAlign(RIGHT, CENTER);

            parent.pushMatrix();
            parent.translate(plotPos, offset);
            parent.rotate(-HALF_PI);
            parent.text(text, 0, 0);
            parent.popMatrix();
        } else {
            parent.textAlign(textAlignment, TOP);
            parent.text(text, plotPos, offset);
        }

        parent.popStyle();
    }

    /**
     * Draws the axis label as a Y axis label
     */
    protected void drawAsYLabel() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.noStroke();

        if (rotate) {
            parent.textAlign(textAlignment, BOTTOM);

            parent.pushMatrix();
            parent.translate(-offset, plotPos);
            parent.rotate(-HALF_PI);
            parent.text(text, 0, 0);
            parent.popMatrix();
        } else {
            parent.textAlign(RIGHT, CENTER);
            parent.text(text, -offset, plotPos);
        }

        parent.popStyle();
    }

    /**
     * Draws the axis label as a TOP axis label
     */
    protected void drawAsTopLabel() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.noStroke();

        if (rotate) {
            parent.textAlign(LEFT, CENTER);

            parent.pushMatrix();
            parent.translate(plotPos, -offset - dim[1]);
            parent.rotate(-HALF_PI);
            parent.text(text, 0, 0);
            parent.popMatrix();
        } else {
            parent.textAlign(textAlignment, BOTTOM);
            parent.text(text, plotPos, -offset - dim[1]);
        }

        parent.popStyle();
    }

    /**
     * Draws the axis label as a RIGHT axis label
     */
    protected void drawAsRightLabel() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.noStroke();

        if (rotate) {
            parent.textAlign(textAlignment, TOP);

            parent.pushMatrix();
            parent.translate(offset + dim[0], plotPos);
            parent.rotate(-HALF_PI);
            parent.text(text, 0, 0);
            parent.popMatrix();
        } else {
            parent.textAlign(LEFT, CENTER);
            parent.text(text, offset + dim[0], plotPos);
        }

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
            plotPos = (type == X || type == TOP) ? relativePos * dim[0] : -relativePos * dim[1];
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
     * Sets the label relative position in the axis
     * 
     * @param newRelativePos
     *            the new relative position in the axis
     */
    public void setRelativePos(float newRelativePos) {
        relativePos = newRelativePos;
        plotPos = (type == X || type == TOP) ? relativePos * dim[0] : -relativePos * dim[1];
    }

    /**
     * Sets the axis label offset
     * 
     * @param newOffset
     *            the new axis label offset
     */
    public void setOffset(float newOffset) {
        offset = newOffset;
    }

    /**
     * Sets if the axis label should be rotated or not
     * 
     * @param newRotate
     *            true if the axis label should be rotated
     */
    public void setRotate(boolean newRotate) {
        rotate = newRotate;
    }

    /**
     * Sets the axis label text
     * 
     * @param newText
     *            the new axis label text
     */
    public void setText(String newText) {
        text = newText;
    }

    /**
     * Sets the axis label type of text alignment
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
