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
import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PFont;

/**
 * Histogram class.
 * 
 * @author Javier Gracia Carpio http://jagracar.com
 */
public class GHistogram implements PConstants {
    // The parent Processing applet
    protected final PApplet parent;

    // General properties
    protected int type;
    protected float[] dim;
    protected GPointsArray plotPoints;
    protected boolean visible;
    protected float[] separations;
    protected int[] bgColors;
    protected int[] lineColors;
    protected float[] lineWidths;
    protected ArrayList<Float> differences;
    protected ArrayList<Float> leftSides;
    protected ArrayList<Float> rightSides;

    // Labels properties
    protected float labelsOffset;
    protected boolean drawLabels;
    protected boolean rotateLabels;
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
     *            the histogram type. It can be GPlot.VERTICAL or
     *            GPlot.HORIZONTAL
     * @param dim
     *            the plot box dimensions in pixels
     * @param plotPoints
     *            the points positions in the plot reference system
     */
    public GHistogram(PApplet parent, int type, float[] dim, GPointsArray plotPoints) {
        this.parent = parent;

        this.type = (type == GPlot.VERTICAL || type == GPlot.HORIZONTAL) ? type : GPlot.VERTICAL;
        this.dim = dim.clone();
        this.plotPoints = new GPointsArray(plotPoints);
        visible = true;
        separations = new float[] { 2 };
        bgColors = new int[] { this.parent.color(150, 150, 255) };
        lineColors = new int[] { this.parent.color(100, 100, 255) };
        lineWidths = new float[] { 1 };

        int nPoints = plotPoints.getNPoints();
        differences = new ArrayList<Float>(nPoints);
        leftSides = new ArrayList<Float>(nPoints);
        rightSides = new ArrayList<Float>(nPoints);
        initializeArrays(nPoints);
        updateArrays();

        labelsOffset = 8;
        drawLabels = false;
        rotateLabels = false;
        fontName = "SansSerif.plain";
        fontColor = this.parent.color(0);
        fontSize = 11;
        font = this.parent.createFont(fontName, fontSize);
    }

    /**
     * Fills the differences, leftSides and rightSides arrays
     */
    protected void initializeArrays(int nPoints) {
        if (differences.size() < nPoints) {
            for (int i = differences.size(); i < nPoints; i++) {
                differences.add(0f);
                leftSides.add(0f);
                rightSides.add(0f);
            }
        } else {
            differences.subList(nPoints, differences.size()).clear();
        }
    }

    /**
     * Updates the differences, leftSides and rightSides arrays
     */
    protected void updateArrays() {
        int nPoints = plotPoints.getNPoints();

        if (nPoints == 1) {
            leftSides.set(0, (type == GPlot.VERTICAL) ? 0.2f * dim[0] : 0.2f * dim[1]);
            rightSides.set(0, leftSides.get(0));
        } else if (nPoints > 1) {
            // Calculate the differences between consecutive points
            for (int i = 0; i < nPoints - 1; i++) {
                if (plotPoints.isValid(i) && plotPoints.isValid(i + 1)) {
                    float separation = separations[i % separations.length];
                    float diff;

                    if (type == GPlot.VERTICAL) {
                        diff = plotPoints.getX(i + 1) - plotPoints.getX(i);
                    } else {
                        diff = plotPoints.getY(i + 1) - plotPoints.getY(i);
                    }

                    if (diff > 0) {
                        differences.set(i, (diff - separation) / 2f);
                    } else {
                        differences.set(i, (diff + separation) / 2f);
                    }
                } else {
                    differences.set(i, 0f);
                }
            }

            // Fill the leftSides and rightSides arrays
            leftSides.set(0, differences.get(0));
            rightSides.set(0, differences.get(0));

            for (int i = 1; i < nPoints - 1; i++) {
                leftSides.set(i, differences.get(i - 1));
                rightSides.set(i, differences.get(i));
            }

            leftSides.set(nPoints - 1, differences.get(nPoints - 2));
            rightSides.set(nPoints - 1, differences.get(nPoints - 2));
        }
    }

    /**
     * Draws the histogram
     * 
     * @param plotBasePoint
     *            the histogram base point in the plot reference system
     */
    public void draw(GPoint plotBasePoint) {
        if (visible) {
            // Calculate the baseline for the histogram
            float baseline = 0;

            if (plotBasePoint.isValid()) {
                baseline = (type == GPlot.VERTICAL) ? plotBasePoint.getY() : plotBasePoint.getX();
            }

            // Draw the rectangles
            parent.pushStyle();
            parent.rectMode(CORNERS);
            parent.strokeCap(SQUARE);

            for (int i = 0; i < plotPoints.getNPoints(); i++) {
                if (plotPoints.isValid(i)) {
                    // Obtain the corners
                    float x1, x2, y1, y2;

                    if (type == GPlot.VERTICAL) {
                        x1 = plotPoints.getX(i) - leftSides.get(i);
                        x2 = plotPoints.getX(i) + rightSides.get(i);
                        y1 = plotPoints.getY(i);
                        y2 = baseline;
                    } else {
                        x1 = baseline;
                        x2 = plotPoints.getX(i);
                        y1 = plotPoints.getY(i) - leftSides.get(i);
                        y2 = plotPoints.getY(i) + rightSides.get(i);
                    }

                    if (x1 < 0) {
                        x1 = 0;
                    } else if (x1 > dim[0]) {
                        x1 = dim[0];
                    }

                    if (-y1 < 0) {
                        y1 = 0;
                    } else if (-y1 > dim[1]) {
                        y1 = -dim[1];
                    }

                    if (x2 < 0) {
                        x2 = 0;
                    } else if (x2 > dim[0]) {
                        x2 = dim[0];
                    }

                    if (-y2 < 0) {
                        y2 = 0;
                    } else if (-y2 > dim[1]) {
                        y2 = -dim[1];
                    }

                    // Draw the rectangle
                    float lw = lineWidths[i % lineWidths.length];
                    parent.fill(bgColors[i % bgColors.length]);
                    parent.stroke(lineColors[i % lineColors.length]);
                    parent.strokeWeight(lw);

                    if (Math.abs(x2 - x1) > 2 * lw && Math.abs(y2 - y1) > 2 * lw) {
                        parent.rect(x1, y1, x2, y2);
                    } else if ((type == GPlot.VERTICAL && x2 != x1 && !(y1 == y2 && (y1 == 0 || y1 == -dim[1])))
                            || (type == GPlot.HORIZONTAL && y2 != y1 && !(x1 == x2 && (x1 == 0 || x1 == dim[0])))) {
                        parent.rect(x1, y1, x2, y2);
                        parent.line(x1, y1, x1, y2);
                        parent.line(x2, y1, x2, y2);
                        parent.line(x1, y1, x2, y1);
                        parent.line(x1, y2, x2, y2);
                    }
                }
            }

            parent.popStyle();

            // Draw the labels
            if (drawLabels) {
                drawHistLabels();
            }
        }
    }

    /**
     * Draws the histogram labels
     */
    protected void drawHistLabels() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.noStroke();

        if (type == GPlot.VERTICAL) {
            if (rotateLabels) {
                parent.textAlign(RIGHT, CENTER);

                for (int i = 0; i < plotPoints.getNPoints(); i++) {
                    if (plotPoints.isValid(i) && plotPoints.getX(i) >= 0 && plotPoints.getX(i) <= dim[0]) {
                        parent.pushMatrix();
                        parent.translate(plotPoints.getX(i), labelsOffset);
                        parent.rotate(-HALF_PI);
                        parent.text(plotPoints.getLabel(i), 0, 0);
                        parent.popMatrix();
                    }
                }
            } else {
                parent.textAlign(CENTER, TOP);

                for (int i = 0; i < plotPoints.getNPoints(); i++) {
                    if (plotPoints.isValid(i) && plotPoints.getX(i) >= 0 && plotPoints.getX(i) <= dim[0]) {
                        parent.text(plotPoints.getLabel(i), plotPoints.getX(i), labelsOffset);
                    }
                }
            }
        } else {
            if (rotateLabels) {
                parent.textAlign(CENTER, BOTTOM);

                for (int i = 0; i < plotPoints.getNPoints(); i++) {
                    if (plotPoints.isValid(i) && -plotPoints.getY(i) >= 0 && -plotPoints.getY(i) <= dim[1]) {
                        parent.pushMatrix();
                        parent.translate(-labelsOffset, plotPoints.getY(i));
                        parent.rotate(-HALF_PI);
                        parent.text(plotPoints.getLabel(i), 0, 0);
                        parent.popMatrix();
                    }
                }
            } else {
                parent.textAlign(RIGHT, CENTER);

                for (int i = 0; i < plotPoints.getNPoints(); i++) {
                    if (plotPoints.isValid(i) && -plotPoints.getY(i) >= 0 && -plotPoints.getY(i) <= dim[1]) {
                        parent.text(plotPoints.getLabel(i), -labelsOffset, plotPoints.getY(i));
                    }
                }
            }
        }

        parent.popStyle();
    }

    /**
     * Sets the type of histogram to display
     * 
     * @param newType
     *            the new type of histogram to display
     */
    public void setType(int newType) {
        if (newType != type && (newType == GPlot.VERTICAL || newType == GPlot.HORIZONTAL)) {
            type = newType;
            updateArrays();
        }
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
            updateArrays();
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
     * Sets the histogram plot points
     * 
     * @param newPlotPoints
     *            the new point positions in the plot reference system
     */
    public void setPlotPoints(GPointsArray newPlotPoints) {
        plotPoints.set(newPlotPoints);
        initializeArrays(plotPoints.getNPoints());
        updateArrays();
    }

    /**
     * Sets one of the histogram plot points
     * 
     * @param index
     *            the point position
     * @param newPlotPoint
     *            the new point positions in the plot reference system
     */
    public void setPlotPoint(int index, GPoint newPlotPoint) {
        plotPoints.set(index, newPlotPoint);
        updateArrays();
    }

    /**
     * Adds a new plot point to the histogram
     * 
     * @param newPlotPoint
     *            the new point position in the plot reference system
     */
    public void addPlotPoint(GPoint newPlotPoint) {
        plotPoints.add(newPlotPoint);
        initializeArrays(plotPoints.getNPoints());
        updateArrays();
    }

    /**
     * Adds a new plot point to the histogram
     * 
     * @param index
     *            the position to add the point
     * @param newPlotPoint
     *            the new point position in the plot reference system
     */
    public void addPlotPoint(int index, GPoint newPlotPoint) {
        plotPoints.add(index, newPlotPoint);
        initializeArrays(plotPoints.getNPoints());
        updateArrays();
    }

    /**
     * Adds a new plot points to the histogram
     * 
     * @param newPlotPoints
     *            the new points positions in the plot reference system
     */
    public void addPlotPoints(GPointsArray newPlotPoints) {
        plotPoints.add(newPlotPoints);
        initializeArrays(plotPoints.getNPoints());
        updateArrays();
    }

    /**
     * Removes one of the points from the histogram
     * 
     * @param index
     *            the point position
     */
    public void removePlotPoint(int index) {
        plotPoints.remove(index);
        initializeArrays(plotPoints.getNPoints());
        updateArrays();
    }

    /**
     * Sets the separations between the histogram elements
     * 
     * @param newSeparations
     *            the new separations between the histogram elements
     */
    public void setSeparations(float[] newSeparations) {
        separations = newSeparations.clone();
        updateArrays();
    }

    /**
     * Sets the background colors of the histogram elements
     * 
     * @param newBgColors
     *            the new background colors of the histogram elements
     */
    public void setBgColors(int[] newBgColors) {
        bgColors = newBgColors.clone();
    }

    /**
     * Sets the line colors of the histogram elements
     * 
     * @param newLineColors
     *            the new line colors of the histogram elements
     */
    public void setLineColors(int[] newLineColors) {
        lineColors = newLineColors.clone();
    }

    /**
     * Sets the line widths of the histogram elements
     * 
     * @param newLineWidths
     *            the new line widths of the histogram elements
     */
    public void setLineWidths(float[] newLineWidths) {
        lineWidths = newLineWidths.clone();
    }

    /**
     * Sets if the histogram should be visible or not
     * 
     * @param newVisible
     *            true if the histogram should be visible
     */
    public void setVisible(boolean newVisible) {
        visible = newVisible;
    }

    /**
     * Sets the histogram labels offset
     * 
     * @param newLabelsOffset
     *            the new histogram labels offset
     */
    public void setLabelsOffset(float newLabelsOffset) {
        labelsOffset = newLabelsOffset;
    }

    /**
     * Sets if the histogram labels should be drawn or not
     * 
     * @param newDrawLabels
     *            true if the histogram labels should be drawn
     */
    public void setDrawLabels(boolean newDrawLabels) {
        drawLabels = newDrawLabels;
    }

    /**
     * Sets if the histogram labels should be rotated or not
     * 
     * @param newRotateLabels
     *            true if the histogram labels should be rotated
     */
    public void setRotateLabels(boolean newRotateLabels) {
        rotateLabels = newRotateLabels;
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
