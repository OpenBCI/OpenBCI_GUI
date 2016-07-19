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

import processing.core.PVector;

/**
 * Point class. A GPoint is composed of two coordinates (x, y) and a text label
 * 
 * @author Javier Gracia Carpio http://jagracar.com
 */
public class GPoint {
    protected float x;
    protected float y;
    protected String label;
    protected boolean valid;

    /**
     * Constructor
     * 
     * @param x
     *            the x coordinate
     * @param y
     *            the y coordinate
     * @param label
     *            the text label
     */
    public GPoint(float x, float y, String label) {
        this.x = x;
        this.y = y;
        this.label = label;
        valid = isValidNumber(this.x) && isValidNumber(this.y);
    }

    /**
     * Constructor
     * 
     * @param x
     *            the x coordinate
     * @param y
     *            the y coordinate
     */
    public GPoint(float x, float y) {
        this(x, y, "");
    }

    /**
     * Constructor
     * 
     * @param v
     *            the Processing vector containing the point coordinates
     * @param label
     *            the text label
     */
    public GPoint(PVector v, String label) {
        this(v.x, v.y, label);
    }

    /**
     * Constructor
     * 
     * @param v
     *            the Processing vector containing the point coordinates
     */
    public GPoint(PVector v) {
        this(v.x, v.y, "");
    }

    /**
     * Constructor
     * 
     * @param point
     *            a GPoint
     */
    public GPoint(GPoint point) {
        this(point.getX(), point.getY(), point.getLabel());
    }

    /**
     * Checks if the provided number is valid (i.e., is not NaN or Infinite)
     * 
     * @param number
     *            the number to check
     * 
     * @return true if its valid
     */
    protected boolean isValidNumber(float number) {
        return !Float.isNaN(number) && !Float.isInfinite(number);
    }

    /**
     * Sets the point x and y coordinates and the label
     * 
     * @param newX
     *            the new x coordinate
     * @param newY
     *            the new y coordinate
     * @param newLabel
     *            the new point text label
     */
    public void set(float newX, float newY, String newLabel) {
        x = newX;
        y = newY;
        label = newLabel;
        valid = isValidNumber(x) && isValidNumber(y);
    }

    /**
     * Sets the point x and y coordinates and the label
     * 
     * @param point
     *            the point to use as a reference
     */
    public void set(GPoint point) {
        set(point.getX(), point.getY(), point.getLabel());
    }

    /**
     * Sets the point x and y coordinates and the label
     * 
     * @param v
     *            the Processing vector with the new point coordinates
     * @param newLabel
     *            the new point text label
     */
    public void set(PVector v, String newLabel) {
        set(v.x, v.y, newLabel);
    }

    /**
     * Sets the point x coordinate
     * 
     * @param newX
     *            the new x coordinate
     */
    public void setX(float newX) {
        x = newX;
        valid = isValidNumber(x) && isValidNumber(y);
    }

    /**
     * Sets the point y coordinate
     * 
     * @param newY
     *            the new y coordinate
     */
    public void setY(float newY) {
        y = newY;
        valid = isValidNumber(x) && isValidNumber(y);
    }

    /**
     * Sets the point x and y coordinates
     * 
     * @param newX
     *            the new x coordinate
     * @param newY
     *            the new y coordinate
     */
    public void setXY(float newX, float newY) {
        x = newX;
        y = newY;
        valid = isValidNumber(x) && isValidNumber(y);
    }

    /**
     * Sets the point x and y coordinates
     * 
     * @param v
     *            the Processing vector with the new point coordinates
     */
    public void setXY(PVector v) {
        setXY(v.x, v.y);
    }

    /**
     * Sets the point text label
     * 
     * @param newLabel
     *            the new point text label
     */
    public void setLabel(String newLabel) {
        label = newLabel;
    }

    /**
     * Returns the point x coordinate
     * 
     * @return the point x coordinate
     */
    public float getX() {
        return x;
    }

    /**
     * Returns the point y coordinate
     * 
     * @return the point y coordinate
     */
    public float getY() {
        return y;
    }

    /**
     * Returns the point text label
     * 
     * @return the point text label
     */
    public String getLabel() {
        return label;
    }

    /**
     * Returns if the point coordinates are valid or not
     * 
     * @return true if the point coordinates are valid
     */
    public boolean getValid() {
        return valid;
    }

    /**
     * Returns if the point coordinates are valid or not
     * 
     * @return true if the point coordinates are valid
     */
    public boolean isValid() {
        return valid;
    }
}
