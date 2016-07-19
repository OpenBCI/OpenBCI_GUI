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

import java.util.ArrayList;
import java.util.Iterator;
import processing.core.PVector;

/**
 * Array of points class.
 * 
 * @author Javier Gracia Carpio http://jagracar.com
 */
public class GPointsArray {
    protected ArrayList<GPoint> points;

    /**
     * Constructor
     */
    public GPointsArray() {
        points = new ArrayList<GPoint>();
    }

    /**
     * Constructor
     * 
     * @param initialSize
     *            the initial estimate for the size of the array
     */
    public GPointsArray(int initialSize) {
        points = new ArrayList<GPoint>(initialSize);
    }

    /**
     * Constructor
     * 
     * @param points
     *            an array of points
     */
    public GPointsArray(GPoint[] points) {
        this.points = new ArrayList<GPoint>(points.length);

        for (int i = 0; i < points.length; i++) {
            if (points[i] != null) {
                this.points.add(new GPoint(points[i]));
            }
        }
    }

    /**
     * Constructor
     * 
     * @param points
     *            an array of points
     */
    public GPointsArray(GPointsArray points) {
        this.points = new ArrayList<GPoint>(points.getNPoints());

        for (int i = 0; i < points.getNPoints(); i++) {
            this.points.add(new GPoint(points.get(i)));
        }
    }

    /**
     * Constructor
     * 
     * @param x
     *            the points x coordinates
     * @param y
     *            the points y coordinates
     * @param labels
     *            the points text labels
     */
    public GPointsArray(float[] x, float[] y, String[] labels) {
        points = new ArrayList<GPoint>(x.length);

        for (int i = 0; i < x.length; i++) {
            points.add(new GPoint(x[i], y[i], labels[i]));
        }
    }

    /**
     * Constructor
     * 
     * @param x
     *            the points x coordinates
     * @param y
     *            the points y coordinates
     */
    public GPointsArray(float[] x, float[] y) {
        points = new ArrayList<GPoint>(x.length);

        for (int i = 0; i < x.length; i++) {
            points.add(new GPoint(x[i], y[i]));
        }
    }

    /**
     * Constructor
     * 
     * @param vectors
     *            an array of Processing vectors with the points x and y
     *            coordinates
     * @param labels
     *            the points text labels
     */
    public GPointsArray(PVector[] vectors, String[] labels) {
        points = new ArrayList<GPoint>(vectors.length);

        for (int i = 0; i < vectors.length; i++) {
            points.add(new GPoint(vectors[i], labels[i]));
        }
    }

    /**
     * Constructor
     * 
     * @param vectors
     *            an array of Processing vectors with the points x and y
     *            coordinates
     */
    public GPointsArray(PVector[] vectors) {
        points = new ArrayList<GPoint>(vectors.length);

        for (int i = 0; i < vectors.length; i++) {
            points.add(new GPoint(vectors[i]));
        }
    }

    /**
     * Constructor
     * 
     * @param vectors
     *            an arrayList of Processing vectors with the points x and y
     *            coordinates
     */
    public GPointsArray(ArrayList<PVector> vectors) {
        points = new ArrayList<GPoint>(vectors.size());

        for (int i = 0; i < vectors.size(); i++) {
            points.add(new GPoint(vectors.get(i)));
        }
    }

    /**
     * Adds a new point to the array
     * 
     * @param point
     *            the point
     */
    public void add(GPoint point) {
        points.add(new GPoint(point));
    }

    /**
     * Adds a new point to the array
     * 
     * @param x
     *            the point x coordinate
     * @param y
     *            the point y coordinate
     * @param label
     *            the point text label
     */
    public void add(float x, float y, String label) {
        points.add(new GPoint(x, y, label));
    }

    /**
     * Adds a new point to the array
     * 
     * @param x
     *            the point x coordinate
     * @param y
     *            the point y coordinate
     */
    public void add(float x, float y) {
        points.add(new GPoint(x, y));
    }

    /**
     * Adds a new point to the array
     * 
     * @param v
     *            the Processing vector with the point x and y coordinates
     * @param label
     *            the point text label
     */
    public void add(PVector v, String label) {
        points.add(new GPoint(v, label));
    }

    /**
     * Adds a new point to the array
     * 
     * @param v
     *            the Processing vector with the point x and y coordinates
     */
    public void add(PVector v) {
        points.add(new GPoint(v));
    }

    /**
     * Adds a new point to the array
     * 
     * @param index
     *            the point position
     * @param point
     *            the point
     */
    public void add(int index, GPoint point) {
        points.add(index, new GPoint(point));
    }

    /**
     * Adds a new point to the array
     * 
     * @param index
     *            the point position
     * @param x
     *            the point x coordinate
     * @param y
     *            the point y coordinate
     * @param label
     *            the point text label
     */
    public void add(int index, float x, float y, String label) {
        points.add(index, new GPoint(x, y, label));
    }

    /**
     * Adds a new point to the array
     * 
     * @param index
     *            the point position
     * @param x
     *            the point x coordinate
     * @param y
     *            the point y coordinate
     */
    public void add(int index, float x, float y) {
        points.add(index, new GPoint(x, y));
    }

    /**
     * Adds a new point to the array
     * 
     * @param index
     *            the point position
     * @param v
     *            the Processing vector with the point x and y coordinates
     * @param label
     *            the point text label
     */
    public void add(int index, PVector v, String label) {
        points.add(index, new GPoint(v, label));
    }

    /**
     * Adds a new point to the array
     * 
     * @param index
     *            the point position
     * @param v
     *            the Processing vector with the point x and y coordinates
     */
    public void add(int index, PVector v) {
        points.add(index, new GPoint(v));
    }

    /**
     * Adds a new set of points to the array
     * 
     * @param pts
     *            the new set of points
     */
    public void add(GPoint[] pts) {
        for (int i = 0; i < pts.length; i++) {
            points.add(new GPoint(pts[i]));
        }
    }

    /**
     * Adds a new set of points to the array
     * 
     * @param pts
     *            the new set of points
     */
    public void add(GPointsArray pts) {
        for (int i = 0; i < pts.getNPoints(); i++) {
            points.add(new GPoint(pts.get(i)));
        }
    }

    /**
     * Adds a new set of points to the array
     * 
     * @param x
     *            the points x coordinates
     * @param y
     *            the points y coordinates
     * @param labels
     *            the points text labels
     */
    public void add(float[] x, float[] y, String[] labels) {
        for (int i = 0; i < x.length; i++) {
            points.add(new GPoint(x[i], y[i], labels[i]));
        }
    }

    /**
     * Adds a new set of points to the array
     * 
     * @param x
     *            the points x coordinates
     * @param y
     *            the points y coordinates
     */
    public void add(float[] x, float[] y) {
        for (int i = 0; i < x.length; i++) {
            points.add(new GPoint(x[i], y[i]));
        }
    }

    /**
     * Adds a new set of points to the array
     * 
     * @param vectors
     *            the Processing vectors with the points x and y coordinates
     * @param labels
     *            the points text labels
     */
    public void add(PVector[] vectors, String[] labels) {
        for (int i = 0; i < vectors.length; i++) {
            points.add(new GPoint(vectors[i], labels[i]));
        }
    }

    /**
     * Adds a new set of points to the array
     * 
     * @param vectors
     *            the Processing vectors with the points x and y coordinates
     */
    public void add(PVector[] vectors) {
        for (int i = 0; i < vectors.length; i++) {
            points.add(new GPoint(vectors[i]));
        }
    }

    /**
     * Adds a new set of points to the array
     * 
     * @param vectors
     *            the Processing vectors with the points x and y coordinates
     */
    public void add(ArrayList<PVector> vectors) {
        for (int i = 0; i < vectors.size(); i++) {
            points.add(new GPoint(vectors.get(i)));
        }
    }

    /**
     * Removes one of the points in the array
     * 
     * @param index
     *            the point index.
     */
    public void remove(int index) {
        points.remove(index);
    }

    /**
     * Removes a range of points in the array
     * 
     * @param fromIndex
     *            the lower point index.
     * @param toIndex
     *            the end point index.
     */
    public void removeRange(int fromIndex, int toIndex) {
        points.subList(fromIndex, toIndex).clear();
    }

    /**
     * Removes invalid points from the array
     */
    public void removeInvalidPoints() {
        for (Iterator<GPoint> it = points.iterator(); it.hasNext();) {
            if (!it.next().isValid()) {
                it.remove();
            }
        }
    }

    /**
     * Sets all the points in the array
     * 
     * @param pts
     *            the new points. The number of points could differ from the
     *            original.
     */
    public void set(GPointsArray pts) {
        if (pts.getNPoints() == points.size()) {
            for (int i = 0; i < points.size(); i++) {
                points.get(i).set(pts.get(i));
            }
        } else if (pts.getNPoints() > points.size()) {
            for (int i = 0; i < points.size(); i++) {
                points.get(i).set(pts.get(i));
            }

            for (int i = points.size(); i < pts.getNPoints(); i++) {
                points.add(new GPoint(pts.get(i)));
            }
        } else {
            for (int i = 0; i < pts.getNPoints(); i++) {
                points.get(i).set(pts.get(i));
            }

            points.subList(pts.getNPoints(), points.size()).clear();
        }
    }

    /**
     * Sets the x and y coordinates and the label of a point with those from
     * another point
     * 
     * @param index
     *            the point index. If the index equals the array size, it will
     *            add a new point to the array.
     * @param point
     *            the point to use
     */
    public void set(int index, GPoint point) {
        if (index == points.size()) {
            points.add(new GPoint(point));
        } else {
            points.get(index).set(point);
        }
    }

    /**
     * Sets the x and y coordinates of a specific point in the array
     * 
     * @param index
     *            the point index. If the index equals the array size, it will
     *            add a new point to the array.
     * @param x
     *            the point new x coordinate
     * @param y
     *            the point new y coordinate
     * @param label
     *            the point new text label
     */
    public void set(int index, float x, float y, String label) {
        if (index == points.size()) {
            points.add(new GPoint(x, y, label));
        } else {
            points.get(index).set(x, y, label);
        }
    }

    /**
     * Sets the x and y coordinates of a specific point in the array
     * 
     * @param index
     *            the point index. If the index equals the array size, it will
     *            add a new point to the array.
     * @param v
     *            the Processing vector with the point new x and y coordinates
     * @param label
     *            the point new text label
     */
    public void set(int index, PVector v, String label) {
        if (index == points.size()) {
            points.add(new GPoint(v, label));
        } else {
            points.get(index).set(v, label);
        }
    }

    /**
     * Sets the x coordinate of a specific point in the array
     * 
     * @param index
     *            the point index
     * @param x
     *            the point new x coordinate
     */
    public void setX(int index, float x) {
        points.get(index).setX(x);
    }

    /**
     * Sets the y coordinate of a specific point in the array
     * 
     * @param index
     *            the point index
     * @param y
     *            the point new y coordinate
     */
    public void setY(int index, float y) {
        points.get(index).setY(y);
    }

    /**
     * Sets the x and y coordinates of a specific point in the array
     * 
     * @param index
     *            the point index
     * @param x
     *            the point new x coordinate
     * @param y
     *            the point new y coordinate
     */
    public void setXY(int index, float x, float y) {
        points.get(index).setXY(x, y);
    }

    /**
     * Sets the x and y coordinates of a specific point in the array
     * 
     * @param index
     *            the point index
     * @param v
     *            the Processing vector with the point new x and y coordinates
     */
    public void setXY(int index, PVector v) {
        points.get(index).setXY(v);
    }

    /**
     * Sets the text label of a specific point in the array
     * 
     * @param index
     *            the point index
     * @param label
     *            the point new text label
     */
    public void setLabel(int index, String label) {
        points.get(index).setLabel(label);
    }

    /**
     * Sets the total number of points in the array
     * 
     * @param nPoints
     *            the new total number of points in the array. It should be
     *            smaller than the current number.
     */
    public void setNPoints(int nPoints) {
        points.subList(nPoints, points.size()).clear();
    }

    /**
     * Returns the total number of points in the array
     * 
     * @return the total number of points in the array
     */
    public int getNPoints() {
        return points.size();
    }

    /**
     * Returns a given point in the array
     * 
     * @param index
     *            the point index in the array
     * 
     * @return the point reference
     */
    public GPoint get(int index) {
        return points.get(index);
    }

    /**
     * Returns the x coordinate of a point in the array
     * 
     * @param index
     *            the point index in the array
     * 
     * @return the point x coordinate
     */
    public float getX(int index) {
        return points.get(index).getX();
    }

    /**
     * Returns the y coordinate of a point in the array
     * 
     * @param index
     *            the point index in the array
     * 
     * @return the point y coordinate
     */
    public float getY(int index) {
        return points.get(index).getY();
    }

    /**
     * Returns the text label of a point in the array
     * 
     * @param index
     *            the point index in the array
     * 
     * @return the point text label
     */
    public String getLabel(int index) {
        return points.get(index).getLabel();
    }

    /**
     * Returns if a point in the array is valid or not
     * 
     * @param index
     *            the point index in the array
     * 
     * @return true if the point is valid
     */
    public boolean getValid(int index) {
        return points.get(index).getValid();
    }

    /**
     * Returns if a point in the array is valid or not
     * 
     * @param index
     *            the point index in the array
     * 
     * @return true if the point is valid
     */
    public boolean isValid(int index) {
        return points.get(index).isValid();
    }

    /**
     * Returns the latest point added to the array
     * 
     * @return the latest point added to the array
     */
    public GPoint getLastPoint() {
        return (points.size() > 0) ? points.get(points.size() - 1) : null;
    }
}
