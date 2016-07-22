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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
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
import processing.core.PImage;
import processing.core.PShape;
import processing.event.MouseEvent;

/**
 * Plot class. It controls the rest of the graphical elements (layers, axes,
 * title, limits).
 * 
 * @author Javier Gracia Carpio http://jagracar.com
 */
public class GPlot implements PConstants {
    // The parent Processing applet
    protected final PApplet parent;

    // General properties
    protected float[] pos;
    protected float[] outerDim;
    protected float[] mar;
    protected float[] dim;
    protected float[] xLim;
    protected float[] yLim;
    protected boolean fixedXLim;
    protected boolean fixedYLim;
    protected boolean xLog;
    protected boolean yLog;
    protected boolean invertedXScale;
    protected boolean invertedYScale;
    protected boolean includeAllLayersInLim;
    protected float expandLimFactor;

    // Format properties
    protected int bgColor;
    protected int boxBgColor;
    protected int boxLineColor;
    protected float boxLineWidth;
    protected int gridLineColor;
    protected float gridLineWidth;

    // Layers
    protected final GLayer mainLayer;
    protected final ArrayList<GLayer> layerList;

    // Axes and title
    protected final GAxis xAxis;
    protected final GAxis topAxis;
    protected final GAxis yAxis;
    protected final GAxis rightAxis;
    protected final GTitle title;

    // Constants
    public static final String MAINLAYERID = "main layer";
    public static final int VERTICAL = 0;
    public static final int HORIZONTAL = 1;
    public static final int BOTH = 2;
    public static final int NONE = 0;
    public static final int ALTMOD = MouseEvent.ALT;
    public static final int CTRLMOD = MouseEvent.CTRL;
    public static final int METAMOD = MouseEvent.META;
    public static final int SHIFTMOD = MouseEvent.SHIFT;
    public static final float LOG10 = (float) Math.log(10);

    // Mouse events
    protected boolean zoomingIsActive;
    protected float zoomFactor;
    protected int increaseZoomButton;
    protected int decreaseZoomButton;
    protected int increaseZoomKeyModifier;
    protected int decreaseZoomKeyModifier;
    protected boolean centeringIsActive;
    protected int centeringButton;
    protected int centeringKeyModifier;
    protected boolean panningIsActive;
    protected int panningButton;
    protected int panningKeyModifier;
    protected float[] panningReferencePoint;
    protected boolean labelingIsActive;
    protected int labelingButton;
    protected int labelingKeyModifier;
    protected float[] mousePos;
    protected boolean resetIsActive;
    protected int resetButton;
    protected int resetKeyModifier;
    protected float[] xLimReset;
    protected float[] yLimReset;

    /**
     * GPlot constructor
     * 
     * @param parent
     *            the parent Processing applet
     * @param xPos
     *            the plot x position on the screen
     * @param yPos
     *            the plot y position on the screen
     * @param plotWidth
     *            the plot width (x outer dimension)
     * @param plotHeight
     *            the plot height (y outer dimension)
     */
    public GPlot(PApplet parent, float xPos, float yPos, float plotWidth, float plotHeight) {
        this.parent = parent;

        pos = new float[] { xPos, yPos };
        outerDim = new float[] { plotWidth, plotHeight };
        mar = new float[] { 60, 70, 40, 30 };
        dim = new float[] { outerDim[0] - mar[1] - mar[3], outerDim[1] - mar[0] - mar[2] };
        xLim = new float[] { 0, 1 };
        yLim = new float[] { 0, 1 };
        fixedXLim = false;
        fixedYLim = false;
        xLog = false;
        yLog = false;
        invertedXScale = false;
        invertedYScale = false;
        includeAllLayersInLim = true;
        expandLimFactor = 0.1f;

        bgColor = this.parent.color(255);
        boxBgColor = this.parent.color(245);
        boxLineColor = this.parent.color(210);
        boxLineWidth = 1;
        gridLineColor = this.parent.color(210);
        gridLineWidth = 1;

        mainLayer = new GLayer(this.parent, MAINLAYERID, dim, xLim, yLim, xLog, yLog);
        layerList = new ArrayList<GLayer>();

        xAxis = new GAxis(this.parent, X, dim, xLim, xLog);
        topAxis = new GAxis(this.parent, TOP, dim, xLim, xLog);
        yAxis = new GAxis(this.parent, Y, dim, yLim, yLog);
        rightAxis = new GAxis(this.parent, RIGHT, dim, yLim, yLog);
        title = new GTitle(this.parent, dim);

        // Setup for the mouse events
        this.parent.registerMethod("mouseEvent", this);
        zoomingIsActive = false;
        zoomFactor = 1.3f;
        increaseZoomButton = LEFT;
        decreaseZoomButton = RIGHT;
        increaseZoomKeyModifier = NONE;
        decreaseZoomKeyModifier = NONE;
        centeringIsActive = false;
        centeringButton = LEFT;
        centeringKeyModifier = NONE;
        panningIsActive = false;
        panningButton = LEFT;
        panningKeyModifier = NONE;
        panningReferencePoint = null;
        labelingIsActive = false;
        labelingButton = LEFT;
        labelingKeyModifier = NONE;
        mousePos = null;
        resetIsActive = false;
        resetButton = RIGHT;
        resetKeyModifier = CTRLMOD;
        xLimReset = null;
        yLimReset = null;
    }

    /**
     * GPlot constructor
     * 
     * @param parent
     *            the parent Processing applet
     * @param xPos
     *            the plot x position on the screen
     * @param yPos
     *            the plot y position on the screen
     */
    public GPlot(PApplet parent, float xPos, float yPos) {
        this(parent, xPos, yPos, 450, 300);
    }

    /**
     * GPlot constructor
     * 
     * @param parent
     *            the parent Processing applet
     */
    public GPlot(PApplet parent) {
        this(parent, 0, 0, 450, 300);
    }

    /**
     * Adds a layer to the plot
     * 
     * @param newLayer
     *            the layer to add
     */
    public void addLayer(GLayer newLayer) {
        // Check that it is the only layer with that id
        String id = newLayer.getId();
        boolean sameId = false;

        if (mainLayer.isId(id)) {
            sameId = true;
        } else {
            for (int i = 0; i < layerList.size(); i++) {
                if (layerList.get(i).isId(id)) {
                    sameId = true;
                    break;
                }
            }
        }

        // Add the layer to the list
        if (!sameId) {
            newLayer.setDim(dim);
            newLayer.setLimAndLog(xLim, yLim, xLog, yLog);
            layerList.add(newLayer);

            // Calculate and update the new plot limits if necessary
            if (includeAllLayersInLim) {
                updateLimits();
            }
        } else {
            PApplet.println("A layer with the same id exists. Please change the id and try to add it again.");
        }
    }

    /**
     * Adds a new layer to the plot
     * 
     * @param id
     *            the id to use for the new layer
     * @param points
     *            the points to be included in the layer
     */
    public void addLayer(String id, GPointsArray points) {
        // Check that it is the only layer with that id
        boolean sameId = false;

        if (mainLayer.isId(id)) {
            sameId = true;
        } else {
            for (int i = 0; i < layerList.size(); i++) {
                if (layerList.get(i).isId(id)) {
                    sameId = true;
                    break;
                }
            }
        }

        // Add the layer to the list
        if (!sameId) {
            GLayer newLayer = new GLayer(parent, id, dim, xLim, yLim, xLog, yLog);
            newLayer.setPoints(points);
            layerList.add(newLayer);

            // Calculate and update the new plot limits if necessary
            if (includeAllLayersInLim) {
                updateLimits();
            }
        } else {
            PApplet.println("A layer with the same id exists. Please change the id and try to add it again.");
        }
    }

    /**
     * Removes an exiting layer from the plot, provided it is not the plot main
     * layer
     * 
     * @param id
     *            the id of the layer to remove
     */
    public void removeLayer(String id) {
        int index = -1;

        for (int i = 0; i < layerList.size(); i++) {
            if (layerList.get(i).isId(id)) {
                index = i;
                break;
            }
        }

        if (index >= 0) {
            layerList.remove(index);

            // Calculate and update the new plot limits if necessary
            if (includeAllLayersInLim) {
                updateLimits();
            }
        } else {
            PApplet.println("Couldn't find a layer in the plot with id = " + id);
        }
    }

    /**
     * Calculates the position of a point in the screen, relative to the plot
     * reference system
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     * 
     * @return the x and y positions in the plot reference system
     */
    public float[] getPlotPosAt(float xScreen, float yScreen) {
        float xPlot = xScreen - (pos[0] + mar[1]);
        float yPlot = yScreen - (pos[1] + mar[2] + dim[1]);

        return new float[] { xPlot, yPlot };
    }

    /**
     * Calculates the position of a given (x, y) point in the parent Processing
     * applet screen
     * 
     * @param xValue
     *            the x value
     * @param yValue
     *            the y value
     * 
     * @return the position of the (x, y) point in the parent Processing applet
     *         screen
     */
    public float[] getScreenPosAtValue(float xValue, float yValue) {
        float xScreen = mainLayer.valueToXPlot(xValue) + (pos[0] + mar[1]);
        float yScreen = mainLayer.valueToYPlot(yValue) + (pos[1] + mar[2] + dim[1]);

        return new float[] { xScreen, yScreen };
    }

    /**
     * Returns the closest point in the main layer to a given screen position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     * 
     * @return the closest point in the plot main layer. Null if there is not a
     *         close point
     */
    public GPoint getPointAt(float xScreen, float yScreen) {
        float[] plotPos = getPlotPosAt(xScreen, yScreen);

        return mainLayer.getPointAtPlotPos(plotPos[0], plotPos[1]);
    }

    /**
     * Returns the closest point in the specified layer to a given screen
     * position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     * @param layerId
     *            the layer id
     * 
     * @return the closest point in the specified layer. Null if there is not a
     *         close point
     */
    public GPoint getPointAt(float xScreen, float yScreen, String layerId) {
        GPoint p = null;

        if (mainLayer.isId(layerId)) {
            p = getPointAt(xScreen, yScreen);
        } else {
            for (int i = 0; i < layerList.size(); i++) {
                if (layerList.get(i).isId(layerId)) {
                    float[] plotPos = getPlotPosAt(xScreen, yScreen);
                    p = layerList.get(i).getPointAtPlotPos(plotPos[0], plotPos[1]);
                    break;
                }
            }
        }

        return p;
    }

    /**
     * Adds a point to the main layer at a given screen position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     */
    public void addPointAt(float xScreen, float yScreen) {
        float[] value = getValueAt(xScreen, yScreen);
        addPoint(value[0], value[1]);
    }

    /**
     * Adds a point to the specified layer at a given screen position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     * @param layerId
     *            the layer id
     */
    public void addPointAt(float xScreen, float yScreen, String layerId) {
        float[] value = getValueAt(xScreen, yScreen);
        addPoint(value[0], value[1], layerId);
    }

    /**
     * Removes a point from the main layer at a given screen position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     */
    public void removePointAt(float xScreen, float yScreen) {
        float[] plotPos = getPlotPosAt(xScreen, yScreen);
        int pointIndex = mainLayer.getPointIndexAtPlotPos(plotPos[0], plotPos[1]);

        if (pointIndex >= 0) {
            removePoint(pointIndex);
        }
    }

    /**
     * Removes a point from the specified layer at a given screen position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     * @param layerId
     *            the layer id
     */
    public void removePointAt(float xScreen, float yScreen, String layerId) {
        float[] plotPos = getPlotPosAt(xScreen, yScreen);
        int pointIndex = getLayer(layerId).getPointIndexAtPlotPos(plotPos[0], plotPos[1]);

        if (pointIndex >= 0) {
            removePoint(pointIndex, layerId);
        }
    }

    /**
     * Returns the plot value at a given screen position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     * 
     * @return the plot value
     */
    public float[] getValueAt(float xScreen, float yScreen) {
        float[] plotPos = getPlotPosAt(xScreen, yScreen);

        return mainLayer.plotToValue(plotPos[0], plotPos[1]);
    }

    /**
     * Returns the relative plot position of a given screen position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     * 
     * @return the relative position in the plot reference system
     */
    public float[] getRelativePlotPosAt(float xScreen, float yScreen) {
        float[] plotPos = getPlotPosAt(xScreen, yScreen);

        return new float[] { plotPos[0] / dim[0], -plotPos[1] / dim[1] };
    }

    /**
     * Indicates if a given screen position is inside the main plot area
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     * 
     * @return true if the position is inside the main plot area
     */
    public boolean isOverPlot(float xScreen, float yScreen) {
        return (xScreen >= pos[0]) && (xScreen <= pos[0] + outerDim[0]) && (yScreen >= pos[1]) && (yScreen <= pos[1] + outerDim[1]);
    }

    /**
     * Indicates if a given screen position is inside the plot box area
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     * 
     * @return true if the position is inside the plot box area
     */
    public boolean isOverBox(float xScreen, float yScreen) {
        return (xScreen >= pos[0] + mar[1]) && (xScreen <= pos[0] + outerDim[0] - mar[3]) && (yScreen >= pos[1] + mar[2])
                && (yScreen <= pos[1] + outerDim[1] - mar[0]);
    }

    /**
     * Calculates and updates the plot x and y limits
     */
    public void updateLimits() {
        // Calculate the new limits and update the axes if needed
        if (!fixedXLim) {
            xLim = calculatePlotXLim();
            xAxis.setLim(xLim);
            topAxis.setLim(xLim);
        }

        if (!fixedYLim) {
            yLim = calculatePlotYLim();
            yAxis.setLim(yLim);
            rightAxis.setLim(yLim);
        }

        // Update the layers
        mainLayer.setXYLim(xLim, yLim);

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).setXYLim(xLim, yLim);
        }
    }

    /**
     * Calculates the plot x limits
     * 
     * @return the x limits
     */
    protected float[] calculatePlotXLim() {
        // Find the limits for the main layer
        float[] lim = calculatePointsXLim(mainLayer.getPointsRef());

        // Include the other layers in the limit calculation if necessary
        if (includeAllLayersInLim) {
            for (int i = 0; i < layerList.size(); i++) {
                float[] newLim = calculatePointsXLim(layerList.get(i).getPointsRef());

                if (newLim != null) {
                    if (lim != null) {
                        lim[0] = PApplet.min(lim[0], newLim[0]);
                        lim[1] = PApplet.max(lim[1], newLim[1]);
                    } else {
                        lim = newLim;
                    }
                }
            }
        }

        if (lim != null) {
            // Expand the axis limits a bit
            float delta = (lim[0] == 0) ? 0.1f : 0.1f * lim[0];

            if (xLog) {
                if (lim[0] != lim[1]) {
                    delta = PApplet.exp(expandLimFactor * PApplet.log(lim[1] / lim[0]));
                }

                lim[0] = lim[0] / delta;
                lim[1] = lim[1] * delta;
            } else {
                if (lim[0] != lim[1]) {
                    delta = expandLimFactor * (lim[1] - lim[0]);
                }

                lim[0] = lim[0] - delta;
                lim[1] = lim[1] + delta;
            }
        } else {
            if (xLog && (xLim[0] <= 0 || xLim[1] <= 0)) {
                lim = new float[] { 0.1f, 10 };
            } else {
                lim = xLim;
            }
        }

        // Invert the limits if necessary
        if (invertedXScale && lim[0] < lim[1]) {
            lim = new float[] { lim[1], lim[0] };
        }

        return lim;
    }

    /**
     * Calculates the plot y limits
     * 
     * @return the y limits
     */
    protected float[] calculatePlotYLim() {
        // Find the limits for the main layer
        float[] lim = calculatePointsYLim(mainLayer.getPointsRef());

        // Include the other layers in the limit calculation if necessary
        if (includeAllLayersInLim) {
            for (int i = 0; i < layerList.size(); i++) {
                float[] newLim = calculatePointsYLim(layerList.get(i).getPointsRef());

                if (newLim != null) {
                    if (lim != null) {
                        lim[0] = PApplet.min(lim[0], newLim[0]);
                        lim[1] = PApplet.max(lim[1], newLim[1]);
                    } else {
                        lim = newLim;
                    }
                }
            }
        }

        if (lim != null) {
            // Expand the axis limits a bit
            float delta = (lim[0] == 0) ? 0.1f : 0.1f * lim[0];

            if (yLog) {
                if (lim[0] != lim[1]) {
                    delta = PApplet.exp(expandLimFactor * PApplet.log(lim[1] / lim[0]));
                }

                lim[0] = lim[0] / delta;
                lim[1] = lim[1] * delta;
            } else {
                if (lim[0] != lim[1]) {
                    delta = expandLimFactor * (lim[1] - lim[0]);
                }

                lim[0] = lim[0] - delta;
                lim[1] = lim[1] + delta;
            }
        } else {
            if (yLog && (yLim[0] <= 0 || yLim[1] <= 0)) {
                lim = new float[] { 0.1f, 10 };
            } else {
                lim = yLim;
            }
        }

        // Invert the limits if necessary
        if (invertedYScale && lim[0] < lim[1]) {
            lim = new float[] { lim[1], lim[0] };
        }

        return lim;
    }

    /**
     * Calculates the x limits of a given set of points, considering the plot
     * properties (axis log scale, if the other axis limits are fixed, etc)
     * 
     * @param points
     *            the points for which we want to calculate the x limits
     * 
     * @return the x limits. Null if none of the points satisfies the plot
     *         properties
     */
    public float[] calculatePointsXLim(GPointsArray points) {
        // Find the points limits
        float[] lim = new float[] { Float.MAX_VALUE, -Float.MAX_VALUE };

        for (int i = 0; i < points.getNPoints(); i++) {
            if (points.isValid(i)) {
                // Use the point if it's inside, and it's not negative if
                // the scale is logarithmic
                float x = points.getX(i);
                float y = points.getY(i);
                boolean isInside = true;

                if (fixedYLim) {
                    isInside = ((yLim[1] >= yLim[0]) && (y >= yLim[0]) && (y <= yLim[1]))
                            || ((yLim[1] < yLim[0]) && (y <= yLim[0]) && (y >= yLim[1]));
                }

                if (isInside && !(xLog && x <= 0)) {
                    if (x < lim[0]) {
                        lim[0] = x;
                    }
                    if (x > lim[1]) {
                        lim[1] = x;
                    }
                }
            }
        }

        // Check that the new limits make sense
        if (lim[1] < lim[0]) {
            lim = null;
        }

        return lim;
    }

    /**
     * Calculates the y limits of a given set of points, considering the plot
     * properties (axis log scale, if the other axis limits are fixed, etc)
     * 
     * @param points
     *            the points for which we want to calculate the y limSits
     * 
     * @return the y limits. Null if none of the points satisfies the plot
     *         properties
     */
    public float[] calculatePointsYLim(GPointsArray points) {
        // Find the points limits
        float[] lim = new float[] { Float.MAX_VALUE, -Float.MAX_VALUE };

        for (int i = 0; i < points.getNPoints(); i++) {
            if (points.isValid(i)) {
                // Use the point if it's inside, and it's not negative if
                // the scale is logarithmic
                float x = points.getX(i);
                float y = points.getY(i);
                boolean isInside = true;

                if (fixedXLim) {
                    isInside = ((xLim[1] >= xLim[0]) && (x >= xLim[0]) && (x <= xLim[1]))
                            || ((xLim[1] < xLim[0]) && (x <= xLim[0]) && (x >= xLim[1]));
                }

                if (isInside && !(yLog && y <= 0)) {
                    if (y < lim[0]) {
                        lim[0] = y;
                    }
                    if (y > lim[1]) {
                        lim[1] = y;
                    }
                }
            }
        }

        // Check that the new limits make sense
        if (lim[1] < lim[0]) {
            lim = null;
        }

        return lim;
    }

    /**
     * Moves the horizontal axes limits by a given amount specified in pixel
     * units
     * 
     * @param delta
     *            pixels to move
     */
    public void moveHorizontalAxesLim(float delta) {
        // Obtain the new x limits
        if (xLog) {
            float deltaLim = PApplet.exp(PApplet.log(xLim[1] / xLim[0]) * delta / dim[0]);
            xLim[0] *= deltaLim;
            xLim[1] *= deltaLim;
        } else {
            float deltaLim = (xLim[1] - xLim[0]) * delta / dim[0];
            xLim[0] += deltaLim;
            xLim[1] += deltaLim;
        }

        // Fix the limits
        fixedXLim = true;

        // Move the horizontal axes
        xAxis.moveLim(xLim);
        topAxis.moveLim(xLim);

        // Update the plot limits
        updateLimits();
    }

    /**
     * Moves the vertical axes limits by a given amount specified in pixel units
     * 
     * @param delta
     *            pixels to move
     */
    public void moveVerticalAxesLim(float delta) {
        // Obtain the new y limits
        if (yLog) {
            float deltaLim = PApplet.exp(PApplet.log(yLim[1] / yLim[0]) * delta / dim[1]);
            yLim[0] *= deltaLim;
            yLim[1] *= deltaLim;
        } else {
            float deltaLim = (yLim[1] - yLim[0]) * delta / dim[1];
            yLim[0] += deltaLim;
            yLim[1] += deltaLim;
        }

        // Fix the limits
        fixedYLim = true;

        // Move the vertical axes
        yAxis.moveLim(yLim);
        rightAxis.moveLim(yLim);

        // Update the plot limits
        updateLimits();
    }

    /**
     * Centers the plot coordinates on the specified (x, y) point and zooms the
     * limits range by a given factor
     * 
     * @param factor
     *            the plot limits will be zoomed by this factor
     * @param xValue
     *            the x plot value
     * @param yValue
     *            the y plot value
     */
    public void centerAndZoom(float factor, float xValue, float yValue) {
        // Calculate the new limits
        if (xLog) {
            float deltaLim = PApplet.exp(PApplet.log(xLim[1] / xLim[0]) / (2 * factor));
            xLim = new float[] { xValue / deltaLim, xValue * deltaLim };
        } else {
            float deltaLim = (xLim[1] - xLim[0]) / (2 * factor);
            xLim = new float[] { xValue - deltaLim, xValue + deltaLim };
        }

        if (yLog) {
            float deltaLim = PApplet.exp(PApplet.log(yLim[1] / yLim[0]) / (2 * factor));
            yLim = new float[] { yValue / deltaLim, yValue * deltaLim };
        } else {
            float deltaLim = (yLim[1] - yLim[0]) / (2 * factor);
            yLim = new float[] { yValue - deltaLim, yValue + deltaLim };
        }

        // Fix the limits
        fixedXLim = true;
        fixedYLim = true;

        // Update the horizontal and vertical axes
        xAxis.setLim(xLim);
        topAxis.setLim(xLim);
        yAxis.setLim(yLim);
        rightAxis.setLim(yLim);

        // Update the plot limits (the layers, because the limits are fixed)
        updateLimits();
    }

    /**
     * Zooms the limits range by a given factor
     * 
     * @param factor
     *            the plot limits will be zoomed by this factor
     */
    public void zoom(float factor) {
        float[] centerValue = mainLayer.plotToValue(dim[0] / 2, -dim[1] / 2);

        centerAndZoom(factor, centerValue[0], centerValue[1]);
    }

    /**
     * Zooms the limits range by a given factor keeping the same plot value at
     * the specified screen position
     * 
     * @param factor
     *            the plot limits will be zoomed by this factor
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     */
    public void zoom(float factor, float xScreen, float yScreen) {
        float[] plotPos = getPlotPosAt(xScreen, yScreen);
        float[] value = mainLayer.plotToValue(plotPos[0], plotPos[1]);

        if (xLog) {
            float deltaLim = PApplet.exp(PApplet.log(xLim[1] / xLim[0]) / (2 * factor));
            float offset = PApplet.exp((PApplet.log(xLim[1] / xLim[0]) / factor) * (0.5f - plotPos[0] / dim[0]));
            xLim = new float[] { value[0] * offset / deltaLim, value[0] * offset * deltaLim };
        } else {
            float deltaLim = (xLim[1] - xLim[0]) / (2 * factor);
            float offset = 2 * deltaLim * (0.5f - plotPos[0] / dim[0]);
            xLim = new float[] { value[0] + offset - deltaLim, value[0] + offset + deltaLim };
        }

        if (yLog) {
            float deltaLim = PApplet.exp(PApplet.log(yLim[1] / yLim[0]) / (2 * factor));
            float offset = PApplet.exp((PApplet.log(yLim[1] / yLim[0]) / factor) * (0.5f + plotPos[1] / dim[1]));
            yLim = new float[] { value[1] * offset / deltaLim, value[1] * offset * deltaLim };
        } else {
            float deltaLim = (yLim[1] - yLim[0]) / (2 * factor);
            float offset = 2 * deltaLim * (0.5f + plotPos[1] / dim[1]);
            yLim = new float[] { value[1] + offset - deltaLim, value[1] + offset + deltaLim };
        }

        // Fix the limits
        fixedXLim = true;
        fixedYLim = true;

        // Update the horizontal and vertical axes
        xAxis.setLim(xLim);
        topAxis.setLim(xLim);
        yAxis.setLim(yLim);
        rightAxis.setLim(yLim);

        // Update the plot limits (the layers, because the limits are fixed)
        updateLimits();
    }

    /**
     * Shifts the plot coordinates in a way that the value at a given plot
     * position will have after that the specified new plot position
     * 
     * @param valuePlotPos
     *            current plot position of the value
     * @param newPlotPos
     *            new plot position of the value
     */
    protected void shiftPlotPos(float[] valuePlotPos, float[] newPlotPos) {
        // Calculate the new limits
        float deltaXPlot = valuePlotPos[0] - newPlotPos[0];
        float deltaYPlot = valuePlotPos[1] - newPlotPos[1];

        if (xLog) {
            float deltaLim = PApplet.exp(PApplet.log(xLim[1] / xLim[0]) * deltaXPlot / dim[0]);
            xLim = new float[] { xLim[0] * deltaLim, xLim[1] * deltaLim };
        } else {
            float deltaLim = (xLim[1] - xLim[0]) * deltaXPlot / dim[0];
            xLim = new float[] { xLim[0] + deltaLim, xLim[1] + deltaLim };
        }

        if (yLog) {
            float deltaLim = PApplet.exp(-PApplet.log(yLim[1] / yLim[0]) * deltaYPlot / dim[1]);
            yLim = new float[] { yLim[0] * deltaLim, yLim[1] * deltaLim };
        } else {
            float deltaLim = -(yLim[1] - yLim[0]) * deltaYPlot / dim[1];
            yLim = new float[] { yLim[0] + deltaLim, yLim[1] + deltaLim };
        }

        // Fix the limits
        fixedXLim = true;
        fixedYLim = true;

        // Move the horizontal and vertical axes
        xAxis.moveLim(xLim);
        topAxis.moveLim(xLim);
        yAxis.moveLim(yLim);
        rightAxis.moveLim(yLim);

        // Update the plot limits (the layers, because the limits are fixed)
        updateLimits();
    }

    /**
     * Shifts the plot coordinates in a way that after that the given plot value
     * will be at the specified screen position
     * 
     * @param xValue
     *            the x plot value
     * @param yValue
     *            the y plot value
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     */
    public void align(float xValue, float yValue, float xScreen, float yScreen) {
        float[] valuePlotPos = mainLayer.valueToPlot(xValue, yValue);
        float[] newPlotPos = getPlotPosAt(xScreen, yScreen);

        shiftPlotPos(valuePlotPos, newPlotPos);
    }

    /**
     * Shifts the plot coordinates in a way that after that the given plot value
     * will be at the specified screen position
     * 
     * @param value
     *            the x and y plot values
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     */
    public void align(float[] value, float xScreen, float yScreen) {
        align(value[0], value[1], xScreen, yScreen);
    }

    /**
     * Centers the plot coordinates at the plot value that is at the specified
     * screen position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     */
    public void center(float xScreen, float yScreen) {
        float[] valuePlotPos = getPlotPosAt(xScreen, yScreen);
        float[] newPlotPos = new float[] { dim[0] / 2, -dim[1] / 2 };

        shiftPlotPos(valuePlotPos, newPlotPos);
    }

    /**
     * Initializes the histograms in all the plot layers
     * 
     * @param histType
     *            the type of histogram to use. It can be GPlot.VERTICAL or
     *            GPlot.HORIZONTAL
     */
    public void startHistograms(int histType) {
        mainLayer.startHistogram(histType);

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).startHistogram(histType);
        }
    }

    /**
     * Draws the plot on the screen with default parameters
     */
    public void defaultDraw() {
        beginDraw();
        drawBackground();
        drawBox();
        drawXAxis();
        drawYAxis();
        drawTitle();
        drawLines();
        drawPoints();
        endDraw();
    }

    /**
     * Prepares the environment to start drawing the different plot components
     * (points, axes, title, etc). Use endDraw() to return the sketch to its
     * original state
     */
    public void beginDraw() {
        parent.pushStyle();
        parent.pushMatrix();
        parent.translate(pos[0] + mar[1], pos[1] + mar[2] + dim[1]);
    }

    /**
     * Returns the sketch to the state that it had before calling beginDraw()
     */
    public void endDraw() {
        parent.popMatrix();
        parent.popStyle();
    }

    /**
     * Draws the plot background. This includes the box area and the margins
     */
    public void drawBackground() {
        parent.pushStyle();
        parent.rectMode(CORNER);
        parent.fill(bgColor);
        parent.noStroke();
        parent.rect(-mar[1], -mar[2] - dim[1], outerDim[0], outerDim[1]);
        parent.popStyle();
    }

    /**
     * Draws the box area. This doesn't include the plot margins
     */
    public void drawBox() {
        parent.pushStyle();
        parent.rectMode(CORNER);
        parent.fill(boxBgColor);
        parent.stroke(boxLineColor);
        parent.strokeWeight(boxLineWidth);
        parent.strokeCap(SQUARE);
        parent.rect(0, -dim[1], dim[0], dim[1]);
        parent.popStyle();
    }

    /**
     * Draws the x axis
     */
    public void drawXAxis() {
        xAxis.draw();
    }

    /**
     * Draws the top axis
     */
    public void drawTopAxis() {
        topAxis.draw();
    }

    /**
     * Draws the y axis
     */
    public void drawYAxis() {
        yAxis.draw();
    }

    /**
     * Draws the right axis
     */
    public void drawRightAxis() {
        rightAxis.draw();
    }

    /**
     * Draws the title
     */
    public void drawTitle() {
        title.draw();
    }

    /**
     * Draws the points from all layers in the plot
     */
    public void drawPoints() {
        mainLayer.drawPoints();

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).drawPoints();
        }
    }

    /**
     * Draws the points from all layers in the plot
     * 
     * @param pointShape
     *            the shape that should be used to represent the points
     */
    public void drawPoints(PShape pointShape) {
        mainLayer.drawPoints(pointShape);

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).drawPoints(pointShape);
        }
    }

    /**
     * Draws the points from all layers in the plot
     * 
     * @param pointImg
     *            the image that should be used to represent the points
     */
    public void drawPoints(PImage pointImg) {
        mainLayer.drawPoints(pointImg);

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).drawPoints(pointImg);
        }
    }

    /**
     * Draws a point in the plot
     * 
     * @param point
     *            the point to draw
     * @param pointColor
     *            color to use
     * @param pointSize
     *            point size in pixels
     */
    public void drawPoint(GPoint point, int pointColor, float pointSize) {
        mainLayer.drawPoint(point, pointColor, pointSize);
    }

    /**
     * Draws a point in the plot
     * 
     * @param point
     *            the point to draw
     */
    public void drawPoint(GPoint point) {
        mainLayer.drawPoint(point);
    }

    /**
     * Draws a point in the plot
     * 
     * @param point
     *            the point to draw
     * @param pointShape
     *            the shape that should be used to represent the point
     */
    public void drawPoint(GPoint point, PShape pointShape) {
        mainLayer.drawPoint(point, pointShape);
    }

    /**
     * Draws a point in the plot
     * 
     * @param point
     *            the point to draw
     * @param pointShape
     *            the shape that should be used to represent the points
     * @param pointColor
     *            color to use
     */
    public void drawPoint(GPoint point, PShape pointShape, int pointColor) {
        mainLayer.drawPoint(point, pointShape, pointColor);
    }

    /**
     * Draws a point in the plot
     * 
     * @param point
     *            the point to draw
     * @param pointImg
     *            the image that should be used to represent the point
     */
    public void drawPoint(GPoint point, PImage pointImg) {
        mainLayer.drawPoint(point, pointImg);
    }

    /**
     * Draws lines connecting the points from all layers in the plot
     */
    public void drawLines() {
        mainLayer.drawLines();

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).drawLines();
        }
    }

    /**
     * Draws a line in the plot, defined by two extreme points
     * 
     * @param point1
     *            first point
     * @param point2
     *            second point
     * @param lineColor
     *            line color
     * @param lineWidth
     *            line width
     */
    public void drawLine(GPoint point1, GPoint point2, int lineColor, float lineWidth) {
        mainLayer.drawLine(point1, point2, lineColor, lineWidth);
    }

    /**
     * Draws a line in the plot, defined by two extreme points
     * 
     * @param point1
     *            first point
     * @param point2
     *            second point
     */
    public void drawLine(GPoint point1, GPoint point2) {
        mainLayer.drawLine(point1, point2);
    }

    /**
     * Draws a line in the plot, defined by the slope and the cut in the y axis
     * 
     * @param slope
     *            the line slope
     * @param yCut
     *            the line y axis cut
     * @param lineColor
     *            line color
     * @param lineWidth
     *            line width
     */
    public void drawLine(float slope, float yCut, int lineColor, float lineWidth) {
        mainLayer.drawLine(slope, yCut, lineColor, lineWidth);
    }

    /**
     * Draws a line in the plot, defined by the slope and the cut in the y axis
     * 
     * @param slope
     *            the line slope
     * @param yCut
     *            the line y axis cut
     */
    public void drawLine(float slope, float yCut) {
        mainLayer.drawLine(slope, yCut);
    }

    /**
     * Draws an horizontal line in the plot
     * 
     * @param value
     *            line horizontal value
     * @param lineColor
     *            line color
     * @param lineWidth
     *            line width
     */
    public void drawHorizontalLine(float value, int lineColor, float lineWidth) {
        mainLayer.drawHorizontalLine(value, lineColor, lineWidth);
    }

    /**
     * Draws an horizontal line in the plot
     * 
     * @param value
     *            line horizontal value
     */
    public void drawHorizontalLine(float value) {
        mainLayer.drawHorizontalLine(value);
    }

    /**
     * Draws a vertical line in the plot
     * 
     * @param value
     *            line vertical value
     * @param lineColor
     *            line color
     * @param lineWidth
     *            line width
     */
    public void drawVerticalLine(float value, int lineColor, float lineWidth) {
        mainLayer.drawVerticalLine(value, lineColor, lineWidth);
    }

    /**
     * Draws a vertical line in the plot
     * 
     * @param value
     *            line vertical value
     */
    public void drawVerticalLine(float value) {
        mainLayer.drawVerticalLine(value);
    }

    /**
     * Draws filled contours connecting the points from all layers in the plot
     * and a reference value
     * 
     * @param contourType
     *            the type of contours to use. It can be GPlot.VERTICAL or
     *            GPlot.HORIZONTAL
     * @param referenceValue
     *            the reference value to use to close the contour
     */
    public void drawFilledContours(int contourType, float referenceValue) {
        mainLayer.drawFilledContour(contourType, referenceValue);

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).drawFilledContour(contourType, referenceValue);
        }
    }

    /**
     * Draws the label of a given point
     * 
     * @param point
     *            the point
     */
    public void drawLabel(GPoint point) {
        mainLayer.drawLabel(point);
    }

    /**
     * Draws the labels of the points in the layers that are close to a given
     * screen position
     * 
     * @param xScreen
     *            x screen position in the parent Processing applet
     * @param yScreen
     *            y screen position in the parent Processing applet
     */
    public void drawLabelsAt(float xScreen, float yScreen) {
        float[] plotPos = getPlotPosAt(xScreen, yScreen);
        mainLayer.drawLabelAtPlotPos(plotPos[0], plotPos[1]);

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).drawLabelAtPlotPos(plotPos[0], plotPos[1]);
        }
    }

    /**
     * Draws the labels of the points in the layers that are close to the mouse
     * position. In order to work, you need to activate first the points
     * labeling with the command plot.activatePointLabels()
     */
    public void drawLabels() {
        if (labelingIsActive && mousePos != null) {
            drawLabelsAt(mousePos[0], mousePos[1]);
        }
    }

    /**
     * Draws lines connecting the horizontal and vertical axis ticks
     * 
     * @param gridType
     *            the type of grid to use. It could be GPlot.HORIZONTAL,
     *            GPlot.VERTICAL or GPlot.BOTH
     */
    public void drawGridLines(int gridType) {
        parent.pushStyle();
        parent.noFill();
        parent.stroke(gridLineColor);
        parent.strokeWeight(gridLineWidth);
        parent.strokeCap(SQUARE);

        if (gridType == BOTH || gridType == VERTICAL) {
            ArrayList<Float> xPlotTicks = xAxis.getPlotTicksRef();

            for (int i = 0; i < xPlotTicks.size(); i++) {
                if (xPlotTicks.get(i) >= 0 && xPlotTicks.get(i) <= dim[0]) {
                    parent.line(xPlotTicks.get(i), 0, xPlotTicks.get(i), -dim[1]);
                }
            }
        }

        if (gridType == BOTH || gridType == HORIZONTAL) {
            ArrayList<Float> yPlotTicks = yAxis.getPlotTicksRef();

            for (int i = 0; i < yPlotTicks.size(); i++) {
                if (-yPlotTicks.get(i) >= 0 && -yPlotTicks.get(i) <= dim[1]) {
                    parent.line(0, yPlotTicks.get(i), dim[0], yPlotTicks.get(i));
                }
            }
        }

        parent.popStyle();
    }

    /**
     * Draws the histograms of all layers
     */
    public void drawHistograms() {
        mainLayer.drawHistogram();

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).drawHistogram();
        }
    }

    /**
     * Draws a polygon defined by a set of points
     * 
     * @param polygonPoints
     *            the points that define the polygon
     * @param polygonColor
     *            the color to use to draw the polygon (contour and background)
     */
    public void drawPolygon(GPointsArray polygonPoints, int polygonColor) {
        mainLayer.drawPolygon(polygonPoints, polygonColor);
    }

    /**
     * Draws an annotation at a given plot value
     * 
     * @param text
     *            the annotation text
     * @param x
     *            x plot value
     * @param y
     *            y plot value
     * @param horAlign
     *            text horizontal alignment. It can be RIGHT, LEFT or CENTER
     * @param verAlign
     *            text vertical alignment. It can be TOP, BOTTOM or CENTER
     */
    public void drawAnnotation(String text, float x, float y, int horAlign, int verAlign) {
        mainLayer.drawAnnotation(text, x, y, horAlign, verAlign);
    }

    /**
     * Draws a legend at the specified relative position
     * 
     * @param text
     *            the text to use for each layer in the plot
     * @param xRelativePos
     *            the plot x relative position for each layer in the plot
     * @param yRelativePos
     *            the plot y relative position for each layer in the plot
     */
    public void drawLegend(String[] text, float[] xRelativePos, float[] yRelativePos) {
        parent.pushStyle();
        parent.rectMode(CENTER);
        parent.noStroke();

        for (int i = 0; i < text.length; i++) {
            float[] plotPosition = new float[] { xRelativePos[i] * dim[0], -yRelativePos[i] * dim[1] };
            float[] position = mainLayer.plotToValue(plotPosition[0], plotPosition[1]);

            if (i == 0) {
                parent.fill(mainLayer.getLineColor());
                parent.rect(plotPosition[0] - 15, plotPosition[1], 14, 14);
                mainLayer.drawAnnotation(text[i], position[0], position[1], LEFT, CENTER);
            } else {
                parent.fill(layerList.get(i - 1).getLineColor());
                parent.rect(plotPosition[0] - 15, plotPosition[1], 14, 14);
                layerList.get(i - i).drawAnnotation(text[i], position[0], position[1], LEFT, CENTER);
            }
        }

        parent.popStyle();
    }

    /**
     * Sets the plot position
     * 
     * @param x
     *            the new plot x position on the screen
     * @param y
     *            the new plot y position on the screen
     */
    public void setPos(float x, float y) {
        pos[0] = x;
        pos[1] = y;
    }

    /**
     * Sets the plot position
     * 
     * @param newPos
     *            the new plot (x, y) position
     */
    public void setPos(float[] newPos) {
        setPos(newPos[0], newPos[1]);
    }

    /**
     * Sets the plot outer dimensions
     * 
     * @param xOuterDim
     *            the new plot x outer dimension
     * @param yOuterDim
     *            the new plot y outer dimension
     */
    public void setOuterDim(float xOuterDim, float yOuterDim) {
        if (xOuterDim > 0 && yOuterDim > 0) {
            // Make sure that the new plot dimensions are positive
            float xDim = xOuterDim - mar[1] - mar[3];
            float yDim = yOuterDim - mar[0] - mar[2];

            if (xDim > 0 && yDim > 0) {
                outerDim[0] = xOuterDim;
                outerDim[1] = yOuterDim;
                dim[0] = xDim;
                dim[1] = yDim;
                xAxis.setDim(dim);
                topAxis.setDim(dim);
                yAxis.setDim(dim);
                rightAxis.setDim(dim);
                title.setDim(dim);

                // Update the layers
                mainLayer.setDim(dim);

                for (int i = 0; i < layerList.size(); i++) {
                    layerList.get(i).setDim(dim);
                }
            }
        }
    }

    /**
     * Sets the plot outer dimensions
     * 
     * @param newOuterDim
     *            the new plot outer dimensions
     */
    public void setOuterDim(float[] newOuterDim) {
        setOuterDim(newOuterDim[0], newOuterDim[1]);
    }

    /**
     * Sets the plot margins
     * 
     * @param bottomMargin
     *            the new plot bottom margin
     * @param leftMargin
     *            the new plot left margin
     * @param topMargin
     *            the new plot top margin
     * @param rightMargin
     *            the new plot right margin
     */
    public void setMar(float bottomMargin, float leftMargin, float topMargin, float rightMargin) {
        // Make sure that the new outer dimensions are positive
        float xOuterDim = dim[0] + leftMargin + rightMargin;
        float yOuterDim = dim[1] + bottomMargin + topMargin;

        if (xOuterDim > 0 && yOuterDim > 0) {
            mar[0] = bottomMargin;
            mar[1] = leftMargin;
            mar[2] = topMargin;
            mar[3] = rightMargin;
            outerDim[0] = xOuterDim;
            outerDim[1] = yOuterDim;
        }
    }

    /**
     * Sets the plot margins
     * 
     * @param newMar
     *            the new plot margins
     */
    public void setMar(float[] newMar) {
        setMar(newMar[0], newMar[1], newMar[2], newMar[3]);
    }

    /**
     * Sets the plot box dimensions
     * 
     * @param xDim
     *            the new plot box x dimension
     * @param yDim
     *            the new plot box y dimension
     */
    public void setDim(float xDim, float yDim) {
        if (xDim > 0 && yDim > 0) {
            // Make sure that the new outer dimensions are positive
            float xOuterDim = xDim + mar[1] + mar[3];
            float yOuterDim = yDim + mar[0] + mar[2];

            if (xOuterDim > 0 && yOuterDim > 0) {
                outerDim[0] = xOuterDim;
                outerDim[1] = yOuterDim;
                dim[0] = xDim;
                dim[1] = yDim;
                xAxis.setDim(dim);
                topAxis.setDim(dim);
                yAxis.setDim(dim);
                rightAxis.setDim(dim);
                title.setDim(dim);

                // Update the layers
                mainLayer.setDim(dim);

                for (int i = 0; i < layerList.size(); i++) {
                    layerList.get(i).setDim(dim);
                }
            }
        }
    }

    /**
     * Sets the plot box dimensions
     * 
     * @param newDim
     *            the new plot box dimensions
     */
    public void setDim(float[] newDim) {
        setDim(newDim[0], newDim[1]);
    }

    /**
     * Sets the horizontal axes limits
     * 
     * @param lowerLim
     *            the new axes lower limit
     * @param upperLim
     *            the new axes upper limit
     */
    public void setXLim(float lowerLim, float upperLim) {
        if (lowerLim != upperLim) {
            // Make sure the new limits makes sense
            if (xLog && (lowerLim <= 0 || upperLim <= 0)) {
                PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
            } else {
                xLim[0] = lowerLim;
                xLim[1] = upperLim;
                invertedXScale = xLim[0] > xLim[1];

                // Fix the limits
                fixedXLim = true;

                // Update the axes
                xAxis.setLim(xLim);
                topAxis.setLim(xLim);

                // Update the plot limits
                updateLimits();
            }
        }
    }

    /**
     * Sets the horizontal axes limits
     * 
     * @param newXLim
     *            the new horizontal axes limits
     */
    public void setXLim(float[] newXLim) {
        setXLim(newXLim[0], newXLim[1]);
    }

    /**
     * Sets the vertical axes limits
     * 
     * @param lowerLim
     *            the new axes lower limit
     * @param upperLim
     *            the new axes upper limit
     */
    public void setYLim(float lowerLim, float upperLim) {
        if (lowerLim != upperLim) {
            // Make sure the new limits makes sense
            if (yLog && (lowerLim <= 0 || upperLim <= 0)) {
                PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
            } else {
                yLim[0] = lowerLim;
                yLim[1] = upperLim;
                invertedYScale = yLim[0] > yLim[1];

                // Fix the limits
                fixedYLim = true;

                // Update the axes
                yAxis.setLim(yLim);
                rightAxis.setLim(yLim);

                // Update the plot limits
                updateLimits();
            }
        }
    }

    /**
     * Sets the vertical axes limits
     * 
     * @param newYLim
     *            the new vertical axes limits
     */
    public void setYLim(float[] newYLim) {
        setYLim(newYLim[0], newYLim[1]);
    }

    /**
     * Sets if the horizontal axes limits are fixed or not
     * 
     * @param newFixedXLim
     *            the fixed condition for the horizontal axes
     */
    public void setFixedXLim(boolean newFixedXLim) {
        fixedXLim = newFixedXLim;

        // Update the plot limits
        updateLimits();
    }

    /**
     * Sets if the vertical axes limits are fixed or not
     * 
     * @param newFixedYLim
     *            the fixed condition for the vertical axes
     */
    public void setFixedYLim(boolean newFixedYLim) {
        fixedYLim = newFixedYLim;

        // Update the plot limits
        updateLimits();
    }

    /**
     * Sets if the scale for the horizontal and vertical axes is logarithmic or
     * not
     * 
     * @param logType
     *            the type of scale for the horizontal and vertical axes
     */
    public void setLogScale(String logType) {
        boolean newXLog = xLog;
        boolean newYLog = yLog;

        if (logType.equals("xy") || logType.equals("yx")) {
            newXLog = true;
            newYLog = true;
        } else if (logType.equals("x")) {
            newXLog = true;
            newYLog = false;
        } else if (logType.equals("y")) {
            newXLog = false;
            newYLog = true;
        } else if (logType.equals("")) {
            newXLog = false;
            newYLog = false;
        }

        // Do something only if the scale changed
        if (newXLog != xLog || newYLog != yLog) {
            // Set the new log scales
            xLog = newXLog;
            yLog = newYLog;

            // Unfix the limits if the old ones don't make sense
            if (xLog && fixedXLim && (xLim[0] <= 0 || xLim[1] <= 0)) {
                fixedXLim = false;
            }

            if (yLog && fixedYLim && (yLim[0] <= 0 || yLim[1] <= 0)) {
                fixedYLim = false;
            }

            // Calculate the new limits if needed
            if (!fixedXLim) {
                xLim = calculatePlotXLim();
            }

            if (!fixedYLim) {
                yLim = calculatePlotYLim();
            }

            // Update the axes
            xAxis.setLimAndLog(xLim, xLog);
            topAxis.setLimAndLog(xLim, xLog);
            yAxis.setLimAndLog(yLim, yLog);
            rightAxis.setLimAndLog(yLim, yLog);

            // Update the layers
            mainLayer.setLimAndLog(xLim, yLim, xLog, yLog);

            for (int i = 0; i < layerList.size(); i++) {
                layerList.get(i).setLimAndLog(xLim, yLim, xLog, yLog);
            }
        }
    }

    /**
     * Sets if the scale of the horizontal axes should be inverted or not
     * 
     * @param newInvertedXScale
     *            true if the horizontal scale should be inverted
     */
    public void setInvertedXScale(boolean newInvertedXScale) {
        if (newInvertedXScale != invertedXScale) {
            invertedXScale = newInvertedXScale;
            float temp = xLim[0];
            xLim[0] = xLim[1];
            xLim[1] = temp;

            // Update the axes
            xAxis.setLim(xLim);
            topAxis.setLim(xLim);

            // Update the layers
            mainLayer.setXLim(xLim);

            for (int i = 0; i < layerList.size(); i++) {
                layerList.get(i).setXLim(xLim);
            }
        }
    }

    /**
     * Inverts the horizontal axes scale
     */
    public void invertXScale() {
        setInvertedXScale(!invertedXScale);
    }

    /**
     * Sets if the scale of the vertical axes should be inverted or not
     * 
     * @param newInvertedYScale
     *            true if the vertical scale should be inverted
     */
    public void setInvertedYScale(boolean newInvertedYScale) {
        if (newInvertedYScale != invertedYScale) {
            invertedYScale = newInvertedYScale;
            float temp = yLim[0];
            yLim[0] = yLim[1];
            yLim[1] = temp;

            // Update the axes
            yAxis.setLim(yLim);
            rightAxis.setLim(yLim);

            // Update the layers
            mainLayer.setYLim(yLim);

            for (int i = 0; i < layerList.size(); i++) {
                layerList.get(i).setYLim(yLim);
            }
        }
    }

    /**
     * Inverts the vertical axes scale
     */
    public void invertYScale() {
        setInvertedYScale(!invertedYScale);
    }

    /**
     * Sets if all the plot layers should be considered in the axes limits
     * calculation
     * 
     * @param includeAllLayers
     *            true if all layers should be considered and not only the main
     *            layer
     */
    public void setIncludeAllLayersInLim(boolean includeAllLayers) {
        if (includeAllLayers != includeAllLayersInLim) {
            includeAllLayersInLim = includeAllLayers;

            // Update the plot limits
            updateLimits();
        }
    }

    /**
     * Sets the factor that is used to expand the axes limits
     * 
     * @param expandFactor
     *            the new expansion factor
     */
    public void setExpandLimFactor(float expandFactor) {
        if (expandFactor >= 0 && expandFactor != expandLimFactor) {
            expandLimFactor = expandFactor;

            // Update the plot limits
            updateLimits();
        }
    }

    /**
     * Sets the plot background color
     * 
     * @param newBgColor
     *            the new plot background color
     */
    public void setBgColor(int newBgColor) {
        bgColor = newBgColor;
    }

    /**
     * Sets the box background color
     * 
     * @param newBoxBgColor
     *            the new box background color
     */
    public void setBoxBgColor(int newBoxBgColor) {
        boxBgColor = newBoxBgColor;
    }

    /**
     * Sets the box line color
     * 
     * @param newBoxLineColor
     *            the new box background color
     */
    public void setBoxLineColor(int newBoxLineColor) {
        boxLineColor = newBoxLineColor;
    }

    /**
     * Sets the box line width
     * 
     * @param newBoxLineWidth
     *            the new box line width
     */
    public void setBoxLineWidth(float newBoxLineWidth) {
        if (newBoxLineWidth > 0) {
            boxLineWidth = newBoxLineWidth;
        }
    }

    /**
     * Sets the grid line color
     * 
     * @param newGridLineColor
     *            the new grid line color
     */
    public void setGridLineColor(int newGridLineColor) {
        gridLineColor = newGridLineColor;
    }

    /**
     * Sets the grid line width
     * 
     * @param newGridLineWidth
     *            the new grid line width
     */
    public void setGridLineWidth(float newGridLineWidth) {
        if (newGridLineWidth > 0) {
            gridLineWidth = newGridLineWidth;
        }
    }

    /**
     * Sets the points for the main layer
     * 
     * @param points
     *            the new points for the main layer
     */
    public void setPoints(GPointsArray points) {
        mainLayer.setPoints(points);
        updateLimits();
    }

    /**
     * Sets the points for the specified layer
     * 
     * @param points
     *            the new points for the main layer
     * @param layerId
     *            the layer id
     */
    public void setPoints(GPointsArray points, String layerId) {
        getLayer(layerId).setPoints(points);
        updateLimits();
    }

    /**
     * Sets one of the main layer points
     * 
     * @param index
     *            the point position
     * @param x
     *            the point new x coordinate
     * @param y
     *            the point new y coordinate
     * @param label
     *            the point new label
     */
    public void setPoint(int index, float x, float y, String label) {
        mainLayer.setPoint(index, x, y, label);
        updateLimits();
    }

    /**
     * Sets one of the specified layer points
     * 
     * @param index
     *            the point position
     * @param x
     *            the point new x coordinate
     * @param y
     *            the point new y coordinate
     * @param label
     *            the point new label
     * @param layerId
     *            the layer id
     */
    public void setPoint(int index, float x, float y, String label, String layerId) {
        getLayer(layerId).setPoint(index, x, y, label);
        updateLimits();
    }

    /**
     * Sets one of the main layer points
     * 
     * @param index
     *            the point position
     * @param x
     *            the point new x coordinate
     * @param y
     *            the point new y coordinate
     */
    public void setPoint(int index, float x, float y) {
        mainLayer.setPoint(index, x, y);
        updateLimits();
    }

    /**
     * Sets one of the main layer points
     * 
     * @param index
     *            the point position
     * @param newPoint
     *            the new point
     */
    public void setPoint(int index, GPoint newPoint) {
        mainLayer.setPoint(index, newPoint);
        updateLimits();
    }

    /**
     * Sets one of the specified layer points
     * 
     * @param index
     *            the point position
     * @param newPoint
     *            the new point
     * @param layerId
     *            the layer id
     */
    public void setPoint(int index, GPoint newPoint, String layerId) {
        getLayer(layerId).setPoint(index, newPoint);
        updateLimits();
    }

    /**
     * Adds a new point to the main layer points
     * 
     * @param x
     *            the new point x coordinate
     * @param y
     *            the new point y coordinate
     * @param label
     *            the new point label
     */
    public void addPoint(float x, float y, String label) {
        mainLayer.addPoint(x, y, label);
        updateLimits();
    }

    /**
     * Adds a new point to the specified layer points
     * 
     * @param x
     *            the new point x coordinate
     * @param y
     *            the new point y coordinate
     * @param label
     *            the new point label
     * @param layerId
     *            the layer id
     */
    public void addPoint(float x, float y, String label, String layerId) {
        getLayer(layerId).addPoint(x, y, label);
        updateLimits();
    }

    /**
     * Adds a new point to the main layer points
     * 
     * @param x
     *            the new point x coordinate
     * @param y
     *            the new point y coordinate
     */
    public void addPoint(float x, float y) {
        mainLayer.addPoint(x, y);
        updateLimits();
    }

    /**
     * Adds a new point to the main layer points
     * 
     * @param newPoint
     *            the point to add
     */
    public void addPoint(GPoint newPoint) {
        mainLayer.addPoint(newPoint);
        updateLimits();
    }

    /**
     * Adds a new point to the specified layer points
     * 
     * @param newPoint
     *            the point to add
     * @param layerId
     *            the layer id
     */
    public void addPoint(GPoint newPoint, String layerId) {
        getLayer(layerId).addPoint(newPoint);
        updateLimits();
    }

    /**
     * Adds a new point to the main layer points
     * 
     * @param index
     *            the position to add the point
     * @param x
     *            the new point x coordinate
     * @param y
     *            the new point y coordinate
     * @param label
     *            the new point label
     */
    public void addPoint(int index, float x, float y, String label) {
        mainLayer.addPoint(index, x, y, label);
        updateLimits();
    }

    /**
     * Adds a new point to the specified layer points
     * 
     * @param index
     *            the position to add the point
     * @param x
     *            the new point x coordinate
     * @param y
     *            the new point y coordinate
     * @param label
     *            the new point label
     * @param layerId
     *            the layer id
     */
    public void addPoint(int index, float x, float y, String label, String layerId) {
        getLayer(layerId).addPoint(index, x, y, label);
        updateLimits();
    }

    /**
     * Adds a new point to the main layer points
     * 
     * @param index
     *            the position to add the point
     * @param x
     *            the new point x coordinate
     * @param y
     *            the new point y coordinate
     */
    public void addPoint(int index, float x, float y) {
        mainLayer.addPoint(index, x, y);
        updateLimits();
    }

    /**
     * Adds a new point to the main layer points
     * 
     * @param index
     *            the position to add the point
     * @param newPoint
     *            the point to add
     */
    public void addPoint(int index, GPoint newPoint) {
        mainLayer.addPoint(index, newPoint);
        updateLimits();
    }

    /**
     * Adds a new point to the specified layer points
     * 
     * @param index
     *            the position to add the point
     * @param newPoint
     *            the point to add
     * @param layerId
     *            the layer id
     */
    public void addPoint(int index, GPoint newPoint, String layerId) {
        getLayer(layerId).addPoint(index, newPoint);
        updateLimits();
    }

    /**
     * Adds new points to the main layer points
     * 
     * @param newPoints
     *            the points to add
     */
    public void addPoints(GPointsArray newPoints) {
        mainLayer.addPoints(newPoints);
        updateLimits();
    }

    /**
     * Adds new points to the specified layer points
     * 
     * @param newPoints
     *            the points to add
     * @param layerId
     *            the layer id
     */
    public void addPoints(GPointsArray newPoints, String layerId) {
        getLayer(layerId).addPoints(newPoints);
        updateLimits();
    }

    /**
     * Removes one of the main layer points
     * 
     * @param index
     *            the point position
     */
    public void removePoint(int index) {
        mainLayer.removePoint(index);
        updateLimits();
    }

    /**
     * Removes one of the specified layer points
     * 
     * @param index
     *            the point position
     * @param layerId
     *            the layer id
     */
    public void removePoint(int index, String layerId) {
        getLayer(layerId).removePoint(index);
        updateLimits();
    }

    /**
     * Sets the point colors for the main layer
     * 
     * @param pointColors
     *            the point colors for the main layer
     */
    public void setPointColors(int[] pointColors) {
        mainLayer.setPointColors(pointColors);
    }

    /**
     * Sets the point color for the main layer
     * 
     * @param pointColor
     *            the point color for the main layer
     */
    public void setPointColor(int pointColor) {
        mainLayer.setPointColor(pointColor);
    }

    /**
     * Sets the point sizes for the main layer
     * 
     * @param pointSizes
     *            the point sizes for the main layer
     */
    public void setPointSizes(float[] pointSizes) {
        mainLayer.setPointSizes(pointSizes);
    }

    /**
     * Sets the point size for the main layer
     * 
     * @param pointSize
     *            the point sizes for the main layer
     */
    public void setPointSize(float pointSize) {
        mainLayer.setPointSize(pointSize);
    }

    /**
     * Sets the line color for the main layer
     * 
     * @param lineColor
     *            the line color for the main layer
     */
    public void setLineColor(int lineColor) {
        mainLayer.setLineColor(lineColor);
    }

    /**
     * Sets the line width for the main layer
     * 
     * @param lineWidth
     *            the line with for the main layer
     */
    public void setLineWidth(float lineWidth) {
        mainLayer.setLineWidth(lineWidth);
    }

    /**
     * Sets the base point for the histogram in the main layer
     * 
     * @param basePoint
     *            the base point for the histogram in the main layer
     */
    public void setHistBasePoint(GPoint basePoint) {
        mainLayer.setHistBasePoint(basePoint);
    }

    /**
     * Sets the histogram type for the histogram in the main layer
     * 
     * @param histType
     *            the histogram type for the histogram in the main layer. It can
     *            be GPlot.HORIZONTAL or GPlot.VERTICAL
     */
    public void setHistType(int histType) {
        mainLayer.setHistType(histType);
    }

    /**
     * Sets if the histogram in the main layer is visible or not
     * 
     * @param visible
     *            if true, the histogram is visible
     */
    public void setHistVisible(boolean visible) {
        mainLayer.setHistVisible(visible);
    }

    /**
     * Sets if the labels of the histogram in the main layer will be drawn or
     * not
     * 
     * @param drawHistLabels
     *            if true, the histogram labels will be drawn
     */
    public void setDrawHistLabels(boolean drawHistLabels) {
        mainLayer.setDrawHistLabels(drawHistLabels);
    }

    /**
     * Sets the label background color of the points in the main layer
     * 
     * @param labelBgColor
     *            the label background color of the points in the main layer
     */
    public void setLabelBgColor(int labelBgColor) {
        mainLayer.setLabelBgColor(labelBgColor);
    }

    /**
     * Sets the label separation of the points in the main layer
     * 
     * @param labelSeparation
     *            the label separation of the points in the main layer
     */
    public void setLabelSeparation(float[] labelSeparation) {
        mainLayer.setLabelSeparation(labelSeparation);
    }

    /**
     * Set the plot title text
     * 
     * @param text
     *            the plot title text
     */
    public void setTitleText(String text) {
        title.setText(text);
    }

    /**
     * Sets the axis offset for all the axes in the plot
     * 
     * @param offset
     *            the new axis offset
     */
    public void setAxesOffset(float offset) {
        xAxis.setOffset(offset);
        topAxis.setOffset(offset);
        yAxis.setOffset(offset);
        rightAxis.setOffset(offset);
    }

    /**
     * Sets the tick length for all the axes in the plot
     * 
     * @param tickLength
     *            the new tick length
     */
    public void setTicksLength(float tickLength) {
        xAxis.setTickLength(tickLength);
        topAxis.setTickLength(tickLength);
        yAxis.setTickLength(tickLength);
        rightAxis.setTickLength(tickLength);
    }

    /**
     * Sets the approximate number of ticks in the horizontal axes. The actual
     * number of ticks depends on the axes limits and the axes scale
     * 
     * @param nTicks
     *            the new approximate number of ticks in the horizontal axes
     */
    public void setHorizontalAxesNTicks(int nTicks) {
        xAxis.setNTicks(nTicks);
        topAxis.setNTicks(nTicks);
    }

    /**
     * Sets the separation between the ticks in the horizontal axes
     * 
     * @param ticksSeparation
     *            the new ticks separation in the horizontal axes
     */
    public void setHorizontalAxesTicksSeparation(float ticksSeparation) {
        xAxis.setTicksSeparation(ticksSeparation);
        topAxis.setTicksSeparation(ticksSeparation);
    }

    /**
     * Sets the horizontal axes ticks
     * 
     * @param ticks
     *            the new horizontal axes ticks
     */
    public void setHorizontalAxesTicks(float[] ticks) {
        xAxis.setTicks(ticks);
        topAxis.setTicks(ticks);
    }

    /**
     * Sets the approximate number of ticks in the vertical axes. The actual
     * number of ticks depends on the axes limits and the axes scale
     * 
     * @param nTicks
     *            the new approximate number of ticks in the vertical axes
     */
    public void setVerticalAxesNTicks(int nTicks) {
        yAxis.setNTicks(nTicks);
        rightAxis.setNTicks(nTicks);
    }

    /**
     * Sets the separation between the ticks in the vertical axes
     * 
     * @param ticksSeparation
     *            the new ticks separation in the vertical axes
     */
    public void setVerticalAxesTicksSeparation(float ticksSeparation) {
        yAxis.setTicksSeparation(ticksSeparation);
        rightAxis.setTicksSeparation(ticksSeparation);
    }

    /**
     * Sets the vertical axes ticks
     * 
     * @param ticks
     *            the new vertical axes ticks
     */
    public void setVerticalAxesTicks(float[] ticks) {
        yAxis.setTicks(ticks);
        rightAxis.setTicks(ticks);
    }

    /**
     * Sets the name of the font that is used in the main layer
     * 
     * @param fontName
     *            the name of the font that will be used in the main layer
     */
    public void setFontName(String fontName) {
        mainLayer.setFontName(fontName);
    }

    /**
     * Sets the color of the font that is used in the main layer
     * 
     * @param fontColor
     *            the color of the font that will be used in the main layer
     */
    public void setFontColor(int fontColor) {
        mainLayer.setFontColor(fontColor);
    }

    /**
     * Sets the size of the font that is used in the main layer
     * 
     * @param fontSize
     *            the size of the font that will be used in the main layer
     */
    public void setFontSize(int fontSize) {
        mainLayer.setFontSize(fontSize);
    }

    /**
     * Sets the properties of the font that is used in the main layer
     * 
     * @param fontName
     *            the name of the font that will be used in the main layer
     * @param fontColor
     *            the color of the font that will be used in the main layer
     * @param fontSize
     *            the size of the font that will be used in the main layer
     */
    public void setFontProperties(String fontName, int fontColor, int fontSize) {
        mainLayer.setFontProperties(fontName, fontColor, fontSize);
    }

    /**
     * Sets the properties of the font that will be used in all plot elements
     * (layer, axes, title, histogram)
     * 
     * @param fontName
     *            the name of the font that will be used in all plot elements
     * @param fontColor
     *            the color of the font that will be used in all plot elements
     * @param fontSize
     *            the size of the font that will be used in all plot elements
     */
    public void setAllFontProperties(String fontName, int fontColor, int fontSize) {
        xAxis.setAllFontProperties(fontName, fontColor, fontSize);
        topAxis.setAllFontProperties(fontName, fontColor, fontSize);
        yAxis.setAllFontProperties(fontName, fontColor, fontSize);
        rightAxis.setAllFontProperties(fontName, fontColor, fontSize);
        title.setFontProperties(fontName, fontColor, fontSize);

        mainLayer.setAllFontProperties(fontName, fontColor, fontSize);

        for (int i = 0; i < layerList.size(); i++) {
            layerList.get(i).setAllFontProperties(fontName, fontColor, fontSize);
        }
    }

    /**
     * Returns the plot position
     * 
     * @return the plot position
     */
    public float[] getPos() {
        return pos.clone();
    }

    /**
     * Returns the plot outer dimensions
     * 
     * @return the plot outer dimensions
     */
    public float[] getOuterDim() {
        return outerDim.clone();
    }

    /**
     * Returns the plot margins
     * 
     * @return the plot margins
     */
    public float[] getMar() {
        return mar.clone();
    }

    /**
     * Returns the box dimensions
     * 
     * @return the box dimensions
     */
    public float[] getDim() {
        return dim.clone();
    }

    /**
     * Returns the limits of the horizontal axes
     * 
     * @return the limits of the horizontal axes
     */
    public float[] getXLim() {
        return xLim.clone();
    }

    /**
     * Returns the limits of the vertical axes
     * 
     * @return the limits of the vertical axes
     */
    public float[] getYLim() {
        return yLim.clone();
    }

    /**
     * Returns true if the horizontal axes limits are fixed
     * 
     * @return true, if the horizontal axes limits are fixed
     */
    public boolean getFixedXLim() {
        return fixedXLim;
    }

    /**
     * Returns true if the vertical axes limits are fixed
     * 
     * @return true, if the vertical axes limits are fixed
     */
    public boolean getFixedYLim() {
        return fixedYLim;
    }

    /**
     * Returns true if the horizontal axes scale is logarithmic
     * 
     * @return true, if the horizontal axes scale is logarithmic
     */
    public boolean getXLog() {
        return xLog;
    }

    /**
     * Returns true if the vertical axes scale is logarithmic
     * 
     * @return true, if the vertical axes scale is logarithmic
     */
    public boolean getYLog() {
        return yLog;
    }

    /**
     * Returns true if the horizontal axes limits are inverted
     * 
     * @return true, if the horizontal axes limits are inverted
     */
    public boolean getInvertedXScale() {
        return invertedXScale;
    }

    /**
     * Returns true if the vertical axes limits are inverted
     * 
     * @return true, if the vertical axes limits are inverted
     */
    public boolean getInvertedYScale() {
        return invertedYScale;
    }

    /**
     * Returns the plot main layer
     * 
     * @return the plot main layer
     */
    public GLayer getMainLayer() {
        return mainLayer;
    }

    /**
     * Returns a layer with an specific id
     * 
     * @param id
     *            the id of the layer to return
     * 
     * @return the layer with the specified id
     */
    public GLayer getLayer(String id) {
        GLayer l = null;

        if (mainLayer.isId(id)) {
            l = mainLayer;
        } else {
            for (int i = 0; i < layerList.size(); i++) {
                if (layerList.get(i).isId(id)) {
                    l = layerList.get(i);
                    break;
                }
            }
        }

        if (l == null) {
            PApplet.println("Couldn't find a layer in the plot with id = " + id);
        }

        return l;
    }

    /**
     * Returns the plot x axis
     * 
     * @return the plot x axis
     */
    public GAxis getXAxis() {
        return xAxis;
    }

    /**
     * Returns the plot top axis
     * 
     * @return the plot top axis
     */
    public GAxis getTopAxis() {
        return topAxis;
    }

    /**
     * Returns the plot y axis
     * 
     * @return the plot y axis
     */
    public GAxis getYAxis() {
        return yAxis;
    }

    /**
     * Returns the plot right axis
     * 
     * @return the plot right axis
     */
    public GAxis getRightAxis() {
        return rightAxis;
    }

    /**
     * Returns the plot title
     * 
     * @return the plot title
     */
    public GTitle getTitle() {
        return title;
    }

    /**
     * Returns a copy of the points of the main layer
     * 
     * @return a copy of the points of the main layer
     */
    public GPointsArray getPoints() {
        return mainLayer.getPoints();
    }

    /**
     * Returns a copy of the points of the specified layer
     * 
     * @param layerId
     *            the layer id
     * 
     * @return a copy of the points of the specified layer
     */
    public GPointsArray getPoints(String layerId) {
        return getLayer(layerId).getPoints();
    }

    /**
     * Returns the points of the main layer
     * 
     * @return the points of the main layer
     */
    public GPointsArray getPointsRef() {
        return mainLayer.getPointsRef();
    }

    /**
     * Returns the points of the specified layer
     * 
     * @param layerId
     *            the layer id
     * 
     * @return the points of the specified layer
     */
    public GPointsArray getPointsRef(String layerId) {
        return getLayer(layerId).getPointsRef();
    }

    /**
     * Returns the histogram of the main layer
     * 
     * @return the histogram of the main layer
     */
    public GHistogram getHistogram() {
        return mainLayer.getHistogram();
    }

    /**
     * Returns the histogram of the specified layer
     * 
     * @param layerId
     *            the layer id
     * 
     * @return the histogram of the specified layer
     */
    public GHistogram getHistogram(String layerId) {
        return getLayer(layerId).getHistogram();
    }

    /**
     * Activates the option to zoom with the mouse using the specified buttons
     * and the specified key modifiers
     * 
     * @param factor
     *            the zoom factor to increase or decrease with each mouse click
     * @param increaseButton
     *            the mouse button to increase the zoom. It could be LEFT, RIGHT
     *            or CENTER. Select CENTER to use the mouse wheel
     * @param decreaseButton
     *            the mouse button to decrease the zoom. It could be LEFT, RIGHT
     *            or CENTER. Select CENTER to use the mouse wheel
     * @param increaseKeyModifier
     *            the key modifier to use in conjunction with the increase zoom
     *            mouse button. It could be GPlot.SHIFTMOD, GPlot.CTRLMOD,
     *            GPlot.METAMOD, GPlot.ALTMOD, or GPlot.NONE if no key is needed
     * @param decreaseKeyModifier
     *            the key modifier to use in conjunction with the decrease zoom
     *            mouse button. It could be GPlot.SHIFTMOD, GPlot.CTRLMOD,
     *            GPlot.METAMOD, GPlot.ALTMOD, or GPlot.NONE if no key is needed
     */
    public void activateZooming(float factor, int increaseButton, int decreaseButton, int increaseKeyModifier, int decreaseKeyModifier) {
        zoomingIsActive = true;

        if (factor > 0) {
            zoomFactor = factor;
        }

        if (increaseButton == LEFT || increaseButton == RIGHT || increaseButton == CENTER) {
            increaseZoomButton = increaseButton;
        }

        if (decreaseButton == LEFT || decreaseButton == RIGHT || decreaseButton == CENTER) {
            decreaseZoomButton = decreaseButton;
        }

        if (increaseKeyModifier == SHIFTMOD || increaseKeyModifier == CTRLMOD || increaseKeyModifier == METAMOD
                || increaseKeyModifier == ALTMOD || increaseKeyModifier == NONE) {
            increaseZoomKeyModifier = increaseKeyModifier;
        }

        if (decreaseKeyModifier == SHIFTMOD || decreaseKeyModifier == CTRLMOD || decreaseKeyModifier == METAMOD
                || decreaseKeyModifier == ALTMOD || decreaseKeyModifier == NONE) {
            decreaseZoomKeyModifier = decreaseKeyModifier;
        }
    }

    /**
     * Activates the option to zoom with the mouse using the specified buttons
     * 
     * @param factor
     *            the zoom factor to increase or decrease with each mouse click
     * @param increaseButton
     *            the mouse button to increase the zoom. It could be LEFT, RIGHT
     *            or CENTER. Select CENTER to use the mouse wheel
     * @param decreaseButton
     *            the mouse button to decrease the zoom. It could be LEFT, RIGHT
     *            or CENTER. Select CENTER to use the mouse wheel
     */
    public void activateZooming(float factor, int increaseButton, int decreaseButton) {
        activateZooming(factor, increaseButton, decreaseButton, NONE, NONE);
    }

    /**
     * Activates the option to zoom with the mouse using the LEFT and RIGHT
     * buttons
     * 
     * @param factor
     *            the zoom factor to increase or decrease with each mouse click
     */
    public void activateZooming(float factor) {
        activateZooming(factor, LEFT, RIGHT, NONE, NONE);
    }

    /**
     * Activates the option to zoom with the mouse using the LEFT and RIGHT
     * buttons
     */
    public void activateZooming() {
        activateZooming(1.3f, LEFT, RIGHT, NONE, NONE);
    }

    /**
     * Deactivates the option to zoom with the mouse
     */
    public void deactivateZooming() {
        zoomingIsActive = false;
    }

    /**
     * Activates the option to center the plot with the mouse using the
     * specified button and the specified key modifier
     * 
     * @param button
     *            the mouse button to use. It could be LEFT, RIGHT or CENTER.
     *            Select CENTER to use the mouse wheel
     * @param keyModifier
     *            the key modifier to use in conjunction with the mouse button.
     *            It could be GPlot.SHIFTMOD, GPlot.CTRLMOD, GPlot.METAMOD,
     *            GPlot.ALTMOD, or GPlot.NONE if no key is need
     */
    public void activateCentering(int button, int keyModifier) {
        centeringIsActive = true;

        if (button == LEFT || button == RIGHT || button == CENTER) {
            centeringButton = button;
        }

        if (keyModifier == SHIFTMOD || keyModifier == CTRLMOD || keyModifier == METAMOD || keyModifier == ALTMOD || keyModifier == NONE) {
            centeringKeyModifier = keyModifier;
        }
    }

    /**
     * Activates the option to center the plot with the mouse using the
     * specified button
     * 
     * @param button
     *            the mouse button to use. It could be LEFT, RIGHT or CENTER.
     *            Select CENTER to use the mouse wheel
     */
    public void activateCentering(int button) {
        activateCentering(button, NONE);
    }

    /**
     * Activates the option to center the plot with the mouse using the LEFT
     * button
     */
    public void activateCentering() {
        activateCentering(LEFT, NONE);
    }

    /**
     * Deactivates the option to center the plot with the mouse
     */
    public void deactivateCentering() {
        centeringIsActive = false;
    }

    /**
     * Activates the option to pan the plot with the mouse using the specified
     * button and the specified key modifier
     * 
     * @param button
     *            the mouse button to use. It could be LEFT, RIGHT or CENTER
     * @param keyModifier
     *            the key modifier to use in conjunction with the mouse button.
     *            It could be GPlot.SHIFTMOD, GPlot.CTRLMOD, GPlot.METAMOD,
     *            GPlot.ALTMOD, or GPlot.NONE if no key is need
     */
    public void activatePanning(int button, int keyModifier) {
        panningIsActive = true;

        if (button == LEFT || button == RIGHT || button == CENTER) {
            panningButton = button;
        }

        if (keyModifier == SHIFTMOD || keyModifier == CTRLMOD || keyModifier == METAMOD || keyModifier == ALTMOD || keyModifier == NONE) {
            panningKeyModifier = keyModifier;
        }
    }

    /**
     * Activates the option to pan the plot with the mouse using the specified
     * button
     * 
     * @param button
     *            the mouse button to use. It could be LEFT, RIGHT or CENTER
     */
    public void activatePanning(int button) {
        activatePanning(button, NONE);
    }

    /**
     * Activates the option to pan the plot with the mouse using the LEFT button
     */
    public void activatePanning() {
        activatePanning(LEFT, NONE);
    }

    /**
     * Deactivates the option to pan the plot with the mouse
     */
    public void deactivatePanning() {
        panningIsActive = false;
        panningReferencePoint = null;
    }

    /**
     * Activates the option to draw the labels of the points with the mouse
     * using the specified button and the specified key modifier
     * 
     * @param button
     *            the mouse button to use. It could be LEFT, RIGHT or CENTER
     * @param keyModifier
     *            the key modifier to use in conjunction with the mouse button.
     *            It could be GPlot.SHIFTMOD, GPlot.CTRLMOD, GPlot.METAMOD,
     *            GPlot.ALTMOD, or GPlot.NONE if no key is need
     */
    public void activatePointLabels(int button, int keyModifier) {
        labelingIsActive = true;

        if (button == LEFT || button == RIGHT || button == CENTER) {
            labelingButton = button;
        }

        if (keyModifier == SHIFTMOD || keyModifier == CTRLMOD || keyModifier == METAMOD || keyModifier == ALTMOD || keyModifier == NONE) {
            labelingKeyModifier = keyModifier;
        }
    }

    /**
     * Activates the option to draw the labels of the points with the mouse
     * using the specified button
     * 
     * @param button
     *            the mouse button to use. It could be LEFT, RIGHT or CENTER
     */
    public void activatePointLabels(int button) {
        activatePointLabels(button, NONE);
    }

    /**
     * Activates the option to draw the labels of the points with the mouse
     * using the LEFT button
     */
    public void activatePointLabels() {
        activatePointLabels(LEFT, NONE);
    }

    /**
     * Deactivates the option to draw the labels of the points with the mouse
     */
    public void deactivatePointLabels() {
        labelingIsActive = false;
        mousePos = null;
    }

    /**
     * Activates the option to return to the value of the axes limits previous
     * to any mouse interaction, using the specified button and the specified
     * key modifier
     * 
     * @param button
     *            the mouse button to use. It could be LEFT, RIGHT or CENTER.
     *            Select CENTER to use the mouse wheel
     * @param keyModifier
     *            the key modifier to use in conjunction with the mouse button.
     *            It could be GPlot.SHIFTMOD, GPlot.CTRLMOD, GPlot.METAMOD,
     *            GPlot.ALTMOD, or GPlot.NONE if no key is need
     */
    public void activateReset(int button, int keyModifier) {
        resetIsActive = true;
        xLimReset = null;
        yLimReset = null;

        if (button == LEFT || button == RIGHT || button == CENTER) {
            resetButton = button;
        }

        if (keyModifier == SHIFTMOD || keyModifier == CTRLMOD || keyModifier == METAMOD || keyModifier == ALTMOD || keyModifier == NONE) {
            resetKeyModifier = keyModifier;
        }
    }

    /**
     * Activates the option to return to the value of the axes limits previous
     * to any mouse interaction, using the specified button
     * 
     * @param button
     *            the mouse button to use. It could be LEFT, RIGHT or CENTER.
     *            Select CENTER to use the mouse wheel
     */
    public void activateReset(int button) {
        activateReset(button, NONE);
    }

    /**
     * Activates the option to return to the value of the axes limits previous
     * to any mouse interaction, using the RIGHT button
     */
    public void activateReset() {
        activateReset(RIGHT, NONE);
    }

    /**
     * Deactivates the option to return to the value of the axes limits previous
     * to any mouse interaction using the mouse
     */
    public void deactivateReset() {
        resetIsActive = false;
        xLimReset = null;
        yLimReset = null;
    }

    /**
     * Mouse events (zooming, centering, panning, labeling)
     * 
     * @param event
     *            the mouse event detected by the processing applet
     */
    public void mouseEvent(MouseEvent event) {
        if (zoomingIsActive || centeringIsActive || panningIsActive || labelingIsActive || resetIsActive) {
            int action = event.getAction();
            int button = (action == MouseEvent.WHEEL) ? CENTER : event.getButton();
            int modifiers = event.getModifiers();
            float xMouse = event.getX();
            float yMouse = event.getY();
            int wheelCounter = (action == MouseEvent.WHEEL) ? event.getCount() : 0;

            if (zoomingIsActive && (action == MouseEvent.CLICK || action == MouseEvent.WHEEL)) {
                if (button == increaseZoomButton && (increaseZoomKeyModifier == NONE || (modifiers & increaseZoomKeyModifier) != 0)) {
                    if (isOverBox(xMouse, yMouse)) {
                        // Save the axes limits if it's the first mouse
                        // modification after the last reset
                        if (resetIsActive && (xLimReset == null || yLimReset == null)) {
                            xLimReset = xLim.clone();
                            yLimReset = yLim.clone();
                        }

                        if (wheelCounter <= 0) {
                            zoom(zoomFactor, xMouse, yMouse);
                        }
                    }
                }

                if (button == decreaseZoomButton && (decreaseZoomKeyModifier == NONE || (modifiers & decreaseZoomKeyModifier) != 0)) {
                    if (isOverBox(xMouse, yMouse)) {
                        // Save the axes limits if it's the first mouse
                        // modification after the last reset
                        if (resetIsActive && (xLimReset == null || yLimReset == null)) {
                            xLimReset = xLim.clone();
                            yLimReset = yLim.clone();
                        }

                        if (wheelCounter >= 0) {
                            zoom(1 / zoomFactor, xMouse, yMouse);
                        }
                    }
                }
            }

            if (centeringIsActive && (action == MouseEvent.CLICK || action == MouseEvent.WHEEL)) {
                if (button == centeringButton && (centeringKeyModifier == NONE || (modifiers & centeringKeyModifier) != 0)) {
                    if (isOverBox(xMouse, yMouse)) {
                        // Save the axes limits if it's the first mouse
                        // modification after the last reset
                        if (resetIsActive && (xLimReset == null || yLimReset == null)) {
                            xLimReset = xLim.clone();
                            yLimReset = yLim.clone();
                        }

                        center(xMouse, yMouse);
                    }
                }
            }

            if (panningIsActive) {
                if (button == panningButton && (panningKeyModifier == NONE || (modifiers & panningKeyModifier) != 0)) {
                    if (action == MouseEvent.DRAG) {
                        if (panningReferencePoint != null) {
                            // Save the axes limits if it's the first mouse
                            // modification after the last reset
                            if (resetIsActive && (xLimReset == null || yLimReset == null)) {
                                xLimReset = xLim.clone();
                                yLimReset = yLim.clone();
                            }

                            align(panningReferencePoint, xMouse, yMouse);
                        } else if (isOverBox(xMouse, yMouse)) {
                            panningReferencePoint = getValueAt(xMouse, yMouse);
                        }
                    } else if (action == MouseEvent.RELEASE) {
                        panningReferencePoint = null;
                    }
                }
            }

            if (labelingIsActive) {
                if (button == labelingButton && (labelingKeyModifier == NONE || (modifiers & labelingKeyModifier) != 0)) {
                    if ((action == MouseEvent.PRESS || action == MouseEvent.DRAG) && isOverBox(xMouse, yMouse)) {
                        mousePos = new float[] { xMouse, yMouse };
                    } else {
                        mousePos = null;
                    }
                }
            }

            if (resetIsActive && (action == MouseEvent.CLICK || action == MouseEvent.WHEEL)) {
                if (button == resetButton && (resetKeyModifier == NONE || (modifiers & resetKeyModifier) != 0)) {
                    if (isOverBox(xMouse, yMouse)) {
                        if (xLimReset != null && yLimReset != null) {
                            setXLim(xLimReset);
                            setYLim(yLimReset);
                            xLimReset = null;
                            yLimReset = null;
                        }
                    }
                }
            }
        }
    }
}
