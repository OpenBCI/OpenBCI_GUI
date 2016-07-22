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

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PFont;

/**
 * Axis class.
 * 
 * @author Javier Gracia Carpio http://jagracar.com
 */
public class GAxis implements PConstants {
    // The parent Processing applet
    protected final PApplet parent;

    // General properties
    protected final int type;
    protected float[] dim;
    protected float[] lim;
    protected boolean log;

    // Format properties
    protected float offset;
    protected int lineColor;
    protected float lineWidth;

    // Ticks properties
    protected int nTicks;
    protected float ticksSeparation;
    protected ArrayList<Float> ticks;
    protected ArrayList<Float> plotTicks;
    protected ArrayList<Boolean> ticksInside;
    protected ArrayList<String> tickLabels;
    protected boolean fixedTicks;
    protected float tickLength;
    protected float smallTickLength;
    protected boolean expTickLabels;
    protected boolean rotateTickLabels;
    protected boolean drawTickLabels;
    protected float tickLabelOffset;

    // Label properties
    protected final GAxisLabel lab;
    protected boolean drawAxisLabel;

    // Text properties
    protected String fontName;
    protected int fontColor;
    protected int fontSize;
    protected PFont font;

    /**
     * GAxis constructor
     * 
     * @param parent
     *            the parent Processing applet
     * @param type
     *            the axis type. It can be X, Y, TOP or RIGHT
     * @param dim
     *            the plot box dimensions in pixels
     * @param lim
     *            the limits
     * @param log
     *            the axis scale. True if it's logarithmic
     */
    public GAxis(PApplet parent, int type, float[] dim, float[] lim, boolean log) {
        this.parent = parent;

        this.type = (type == X || type == Y || type == TOP || type == RIGHT) ? type : X;
        this.dim = dim.clone();
        this.lim = lim.clone();
        this.log = log;

        // Do some sanity checks
        if (this.log && (this.lim[0] <= 0 || this.lim[1] <= 0)) {
            PApplet.println("The limits are negative. This is not allowed in logarithmic scale.");
            PApplet.println("Will set them to (0.1, 10)");

            if (this.lim[1] > this.lim[0]) {
                this.lim[0] = 0.1f;
                this.lim[1] = 10f;
            } else {
                this.lim[0] = 10f;
                this.lim[1] = 0.1f;
            }
        }

        offset = 5;
        lineColor = this.parent.color(0);
        lineWidth = 1;

        nTicks = 5;
        ticksSeparation = -1;
        ticks = new ArrayList<Float>(nTicks);
        plotTicks = new ArrayList<Float>(nTicks);
        ticksInside = new ArrayList<Boolean>(nTicks);
        tickLabels = new ArrayList<String>(nTicks);
        fixedTicks = false;
        tickLength = 3;
        smallTickLength = 2;
        expTickLabels = false;
        rotateTickLabels = (this.type == X || this.type == TOP) ? false : true;
        drawTickLabels = (this.type == X || this.type == Y) ? true : false;
        tickLabelOffset = 7;

        lab = new GAxisLabel(this.parent, this.type, this.dim);
        drawAxisLabel = true;

        fontName = "SansSerif.plain";
        fontColor = this.parent.color(0);
        fontSize = 11;
        font = this.parent.createFont(fontName, fontSize);

        // Update the arrayLists
        updateTicks();
        updatePlotTicks();
        updateTicksInside();
        updateTickLabels();
    }

    /**
     * Calculates the optimum number of significant digits to use for a given
     * number
     * 
     * @param number
     *            the number
     * 
     * @return the number of significant digits
     */
    protected int obtainSigDigits(float number) {
        return Math.round(-PApplet.log(0.5f * Math.abs(number)) / GPlot.LOG10);
    }

    /**
     * Rounds a number to a given number of significant digits
     * 
     * @param number
     *            the number to round
     * @param sigDigits
     *            the number of significant digits
     * 
     * @return the rounded number
     */
    protected float roundPlus(float number, int sigDigits) {
        return BigDecimal.valueOf(number).setScale(sigDigits, BigDecimal.ROUND_HALF_UP).floatValue();
    }

    /**
     * Adapts the provided array list to the new size
     * 
     * @param a
     *            the array list
     * @param n
     *            the new size of the array
     */
    protected void adaptSize(ArrayList<?> a, int n) {
        if (n > a.size()) {
            for (int i = a.size(); i < n; i++) {
                a.add(null);
            }
        } else if (n < a.size()) {
            a.subList(n, a.size()).clear();
        }
    }

    /**
     * Updates the axis ticks
     */
    protected void updateTicks() {
        if (log) {
            obtainLogarithmicTicks();
        } else {
            obtainLinearTicks();
        }
    }

    /**
     * Calculates the axis ticks for the logarithmic scale
     */
    protected void obtainLogarithmicTicks() {
        // Get the exponents of the first and last ticks in increasing order
        int firstExp, lastExp;

        if (lim[1] > lim[0]) {
            firstExp = PApplet.floor(PApplet.log(lim[0]) / GPlot.LOG10);
            lastExp = PApplet.ceil(PApplet.log(lim[1]) / GPlot.LOG10);
        } else {
            firstExp = PApplet.floor(PApplet.log(lim[1]) / GPlot.LOG10);
            lastExp = PApplet.ceil(PApplet.log(lim[0]) / GPlot.LOG10);
        }

        // Calculate the ticks
        int n = (lastExp - firstExp) * 9 + 1;
        adaptSize(ticks, n);

        for (int exp = firstExp; exp < lastExp; exp++) {
            float base = roundPlus(PApplet.exp(exp * GPlot.LOG10), -exp);

            for (int i = 0; i < 9; i++) {
                ticks.set((exp - firstExp) * 9 + i, (i + 1) * base);
            }
        }

        ticks.set(ticks.size() - 1, roundPlus(PApplet.exp(lastExp * GPlot.LOG10), -lastExp));
    }

    /**
     * Calculates the axis ticks for the linear scale
     */
    protected void obtainLinearTicks() {
        // Obtain the required precision for the ticks
        float step = 0;
        int sigDigits = 0;
        int nSteps = 0;

        if (ticksSeparation > 0) {
            step = (lim[1] > lim[0]) ? ticksSeparation : -ticksSeparation;
            sigDigits = obtainSigDigits(step);

            while (roundPlus(step, sigDigits) - step != 0) {
                sigDigits++;
            }

            nSteps = PApplet.floor((lim[1] - lim[0]) / step);
        } else if (nTicks > 0) {
            step = (lim[1] - lim[0]) / nTicks;
            sigDigits = obtainSigDigits(step);
            step = roundPlus(step, sigDigits);

            if (step == 0 || Math.abs(step) > Math.abs(lim[1] - lim[0])) {
                sigDigits++;
                step = roundPlus((lim[1] - lim[0]) / nTicks, sigDigits);
            }

            nSteps = PApplet.floor((lim[1] - lim[0]) / step);
        }

        // Calculate the linear ticks
        if (nSteps > 0) {
            // Obtain the first tick
            float firstTick = lim[0] + ((lim[1] - lim[0]) - nSteps * step) / 2;

            // Subtract some steps to be sure we have all
            firstTick = roundPlus(firstTick - 2 * step, sigDigits);

            while ((lim[1] - firstTick) * (lim[0] - firstTick) > 0) {
                firstTick = roundPlus(firstTick + step, sigDigits);
            }

            // Calculate the rest of the ticks
            int n = PApplet.floor(Math.abs((lim[1] - firstTick) / step)) + 1;
            adaptSize(ticks, n);
            ticks.set(0, firstTick);

            for (int i = 1; i < n; i++) {
                ticks.set(i, roundPlus(ticks.get(i - 1) + step, sigDigits));
            }
        } else {
            ticks.clear();
        }
    }

    /**
     * Updates the positions of the axis ticks in the plot reference system
     */
    protected void updatePlotTicks() {
        int n = ticks.size();
        adaptSize(plotTicks, n);
        float scaleFactor;

        if (log) {
            if (type == X || type == TOP) {
                scaleFactor = dim[0] / PApplet.log(lim[1] / lim[0]);
            } else {
                scaleFactor = -dim[1] / PApplet.log(lim[1] / lim[0]);
            }

            for (int i = 0; i < n; i++) {
                plotTicks.set(i, PApplet.log(ticks.get(i) / lim[0]) * scaleFactor);
            }
        } else {
            if (type == X || type == TOP) {
                scaleFactor = dim[0] / (lim[1] - lim[0]);
            } else {
                scaleFactor = -dim[1] / (lim[1] - lim[0]);
            }

            for (int i = 0; i < n; i++) {
                plotTicks.set(i, (ticks.get(i) - lim[0]) * scaleFactor);
            }
        }
    }

    /**
     * Updates the array that indicates which ticks are inside the axis limits
     */
    protected void updateTicksInside() {
        int n = ticks.size();
        adaptSize(ticksInside, n);

        if (type == X || type == TOP) {
            for (int i = 0; i < n; i++) {
                ticksInside.set(i, (plotTicks.get(i) >= 0) && (plotTicks.get(i) <= dim[0]));
            }
        } else {
            for (int i = 0; i < n; i++) {
                ticksInside.set(i, (-plotTicks.get(i) >= 0) && (-plotTicks.get(i) <= dim[1]));
            }
        }
    }

    /**
     * Updates the axis tick labels
     */
    protected void updateTickLabels() {
        int n = ticks.size();
        adaptSize(tickLabels, n);

        if (log) {
            for (int i = 0; i < n; i++) {
                float tick = ticks.get(i);

                if (tick > 0) {
                    float logValue = PApplet.log(tick) / GPlot.LOG10;
                    boolean isExactLogValue = Math.abs(logValue - Math.round(logValue)) < 0.0001;

                    if (isExactLogValue) {
                        logValue = Math.round(logValue);

                        if (expTickLabels) {
                            tickLabels.set(i, "1e" + (int) logValue);
                        } else {
                            if (logValue > -3.1 && logValue < 3.1) {
                                tickLabels.set(i, (logValue >= 0) ? PApplet.str((int) tick) : PApplet.str(tick));
                            } else {
                                tickLabels.set(i, "1e" + (int) logValue);
                            }
                        }
                    } else {
                        tickLabels.set(i, "");
                    }
                } else {
                    tickLabels.set(i, "");
                }
            }
        } else {
            for (int i = 0; i < n; i++) {
                float tick = ticks.get(i);
                tickLabels.set(i, (tick % 1 == 0 && Math.abs(tick) < 1e9) ? PApplet.str((int) tick) : PApplet.str(tick));
            }
        }
    }

    /**
     * Removes those axis ticks that are outside the axis limits
     * 
     * @return the ticks that are inside the axis limits
     */
    protected float[] removeOutsideTicks() {
        float[] validTicks = new float[ticksInside.size()];
        int counter = 0;

        for (int i = 0; i < ticksInside.size(); i++) {
            if (ticksInside.get(i)) {
                validTicks[counter] = ticks.get(i);
                counter++;
            }
        }

        return Arrays.copyOf(validTicks, counter);
    }

    /**
     * Removes those axis ticks in the plot reference system that are outside
     * the axis limits
     * 
     * @return the ticks in the plot reference system that are inside the axis
     *         limits
     */
    protected float[] removeOutsidePlotTicks() {
        float[] validPlotTicks = new float[ticksInside.size()];
        int counter = 0;

        for (int i = 0; i < ticksInside.size(); i++) {
            if (ticksInside.get(i)) {
                validPlotTicks[counter] = plotTicks.get(i);
                counter++;
            }
        }

        return Arrays.copyOf(validPlotTicks, counter);
    }

    /**
     * Moves the axis limits
     * 
     * @param newLim
     *            the new axis limits
     */
    public void moveLim(float[] newLim) {
        if (newLim[1] != newLim[0]) {
            // Check that the new limit makes sense
            if (log && (newLim[0] <= 0 || newLim[1] <= 0)) {
                PApplet.println("The limits are negative. This is not allowed in logarithmic scale.");
            } else {
                lim[0] = newLim[0];
                lim[1] = newLim[1];

                // Calculate the new ticks if they are not fixed
                if (!fixedTicks) {
                    int n = ticks.size();

                    if (log) {
                        obtainLogarithmicTicks();
                    } else if (n > 0) {
                        // Obtain the ticks precision and the tick separation
                        float step = 0;
                        int sigDigits = 0;

                        if (ticksSeparation > 0) {
                            step = (lim[1] > lim[0]) ? ticksSeparation : -ticksSeparation;
                            sigDigits = obtainSigDigits(step);

                            while (roundPlus(step, sigDigits) - step != 0) {
                                sigDigits++;
                            }
                        } else {
                            step = (n == 1) ? lim[1] - lim[0] : ticks.get(1) - ticks.get(0);
                            sigDigits = obtainSigDigits(step);
                            step = roundPlus(step, sigDigits);

                            if (step == 0 || Math.abs(step) > Math.abs(lim[1] - lim[0])) {
                                sigDigits++;
                                step = (n == 1) ? lim[1] - lim[0] : ticks.get(1) - ticks.get(0);
                                step = roundPlus(step, sigDigits);
                            }

                            step = (lim[1] > lim[0]) ? Math.abs(step) : -Math.abs(step);
                        }

                        // Obtain the first tick
                        float firstTick = ticks.get(0) + step * PApplet.ceil((lim[0] - ticks.get(0)) / step);
                        firstTick = roundPlus(firstTick, sigDigits);

                        if ((lim[1] - firstTick) * (lim[0] - firstTick) > 0) {
                            firstTick = ticks.get(0) + step * PApplet.floor((lim[0] - ticks.get(0)) / step);
                            firstTick = roundPlus(firstTick, sigDigits);
                        }

                        // Calculate the rest of the ticks
                        n = PApplet.floor(Math.abs((lim[1] - firstTick) / step)) + 1;
                        adaptSize(ticks, n);
                        ticks.set(0, firstTick);

                        for (int i = 1; i < n; i++) {
                            ticks.set(i, roundPlus(ticks.get(i - 1) + step, sigDigits));
                        }
                    }

                    // Obtain the new tick labels
                    updateTickLabels();
                }

                // Update the rest of the arrays
                updatePlotTicks();
                updateTicksInside();
            }
        }
    }

    /**
     * Draws the axis
     */
    public void draw() {
        switch (type) {
        case X:
            drawAsXAxis();
            break;
        case Y:
            drawAsYAxis();
            break;
        case TOP:
            drawAsTopAxis();
            break;
        case RIGHT:
            drawAsRightAxis();
            break;
        }

        if (drawAxisLabel)
            lab.draw();
    }

    /**
     * Draws the axis as an X axis
     */
    protected void drawAsXAxis() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.stroke(lineColor);
        parent.strokeWeight(lineWidth);
        parent.strokeCap(SQUARE);

        // Draw the ticks
        parent.line(0, offset, dim[0], offset);

        for (int i = 0; i < plotTicks.size(); i++) {
            if (ticksInside.get(i)) {
                if (log && tickLabels.get(i).equals("")) {
                    parent.line(plotTicks.get(i), offset, plotTicks.get(i), offset + smallTickLength);
                } else {
                    parent.line(plotTicks.get(i), offset, plotTicks.get(i), offset + tickLength);
                }
            }
        }

        // Draw the tick labels
        if (drawTickLabels) {
            if (rotateTickLabels) {
                parent.textAlign(RIGHT, CENTER);

                for (int i = 0; i < plotTicks.size(); i++) {
                    if (ticksInside.get(i) && !tickLabels.get(i).equals("")) {
                        parent.pushMatrix();
                        parent.translate(plotTicks.get(i), offset + tickLabelOffset);
                        parent.rotate(-HALF_PI);
                        parent.text(tickLabels.get(i), 0, 0);
                        parent.popMatrix();
                    }
                }
            } else {
                parent.textAlign(CENTER, TOP);

                for (int i = 0; i < plotTicks.size(); i++) {
                    if (ticksInside.get(i) && !tickLabels.get(i).equals("")) {
                        parent.text(tickLabels.get(i), plotTicks.get(i), offset + tickLabelOffset);
                    }
                }
            }
        }

        parent.popStyle();
    }

    /**
     * Draws the axis as a Y axis
     */
    protected void drawAsYAxis() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.stroke(lineColor);
        parent.strokeWeight(lineWidth);
        parent.strokeCap(SQUARE);

        // Draw the ticks
        parent.line(-offset, 0, -offset, -dim[1]);

        for (int i = 0; i < plotTicks.size(); i++) {
            if (ticksInside.get(i)) {
                if (log && tickLabels.get(i).equals("")) {
                    parent.line(-offset, plotTicks.get(i), -offset - smallTickLength, plotTicks.get(i));
                } else {
                    parent.line(-offset, plotTicks.get(i), -offset - tickLength, plotTicks.get(i));
                }
            }
        }

        // Draw the tick labels
        if (drawTickLabels) {
            if (rotateTickLabels) {
                parent.textAlign(CENTER, BOTTOM);

                for (int i = 0; i < plotTicks.size(); i++) {
                    if (ticksInside.get(i) && !tickLabels.get(i).equals("")) {
                        parent.pushMatrix();
                        parent.translate(-offset - tickLabelOffset, plotTicks.get(i));
                        parent.rotate(-HALF_PI);
                        parent.text(tickLabels.get(i), 0, 0);
                        parent.popMatrix();
                    }
                }
            } else {
                parent.textAlign(RIGHT, CENTER);

                for (int i = 0; i < plotTicks.size(); i++) {
                    if (ticksInside.get(i) && !tickLabels.get(i).equals("")) {
                        parent.text(tickLabels.get(i), -offset - tickLabelOffset, plotTicks.get(i));
                    }
                }
            }
        }

        parent.popStyle();
    }

    /**
     * Draws the axis as a TOP axis
     */
    protected void drawAsTopAxis() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.stroke(lineColor);
        parent.strokeWeight(lineWidth);
        parent.strokeCap(SQUARE);

        parent.pushMatrix();
        parent.translate(0, -dim[1]);

        // Draw the ticks
        parent.line(0, -offset, dim[0], -offset);

        for (int i = 0; i < plotTicks.size(); i++) {
            if (ticksInside.get(i)) {
                if (log && tickLabels.get(i).equals("")) {
                    parent.line(plotTicks.get(i), -offset, plotTicks.get(i), -offset - smallTickLength);
                } else {
                    parent.line(plotTicks.get(i), -offset, plotTicks.get(i), -offset - tickLength);
                }
            }
        }

        // Draw the tick labels
        if (drawTickLabels) {
            if (rotateTickLabels) {
                parent.textAlign(LEFT, CENTER);

                for (int i = 0; i < plotTicks.size(); i++) {
                    if (ticksInside.get(i) && !tickLabels.get(i).equals("")) {
                        parent.pushMatrix();
                        parent.translate(plotTicks.get(i), -offset - tickLabelOffset);
                        parent.rotate(-HALF_PI);
                        parent.text(tickLabels.get(i), 0, 0);
                        parent.popMatrix();
                    }
                }
            } else {
                parent.textAlign(CENTER, BOTTOM);

                for (int i = 0; i < plotTicks.size(); i++) {
                    if (ticksInside.get(i) && !tickLabels.get(i).equals("")) {
                        parent.text(tickLabels.get(i), plotTicks.get(i), -offset - tickLabelOffset);
                    }
                }
            }
        }

        parent.popMatrix();
        parent.popStyle();
    }

    /**
     * Draws the axis as a RIGHT axis
     */
    protected void drawAsRightAxis() {
        parent.pushStyle();
        parent.textMode(MODEL);
        parent.textFont(font);
        parent.textSize(fontSize);
        parent.fill(fontColor);
        parent.stroke(lineColor);
        parent.strokeWeight(lineWidth);
        parent.strokeCap(SQUARE);

        parent.pushMatrix();
        parent.translate(dim[0], 0);

        // Draw the ticks
        parent.line(offset, 0, offset, -dim[1]);

        for (int i = 0; i < plotTicks.size(); i++) {
            if (ticksInside.get(i)) {
                if (log && tickLabels.get(i).equals("")) {
                    parent.line(offset, plotTicks.get(i), offset + smallTickLength, plotTicks.get(i));
                } else {
                    parent.line(offset, plotTicks.get(i), offset + tickLength, plotTicks.get(i));
                }
            }
        }

        // Draw the tick labels
        if (drawTickLabels) {
            if (rotateTickLabels) {
                parent.textAlign(CENTER, TOP);

                for (int i = 0; i < plotTicks.size(); i++) {
                    if (ticksInside.get(i) && !tickLabels.get(i).equals("")) {
                        parent.pushMatrix();
                        parent.translate(offset + tickLabelOffset, plotTicks.get(i));
                        parent.rotate(-HALF_PI);
                        parent.text(tickLabels.get(i), 0, 0);
                        parent.popMatrix();
                    }
                }
            } else {
                parent.textAlign(LEFT, CENTER);

                for (int i = 0; i < plotTicks.size(); i++) {
                    if (ticksInside.get(i) && !tickLabels.get(i).equals("")) {
                        parent.text(tickLabels.get(i), offset + tickLabelOffset, plotTicks.get(i));
                    }
                }
            }
        }

        parent.popMatrix();
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
            updatePlotTicks();
            lab.setDim(dim);
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
     * Sets the axis limits
     * 
     * @param newLim
     *            the new axis limits
     */
    public void setLim(float[] newLim) {
        if (newLim[1] != newLim[0]) {
            // Make sure the new limits makes sense
            if (log && (newLim[0] <= 0 || newLim[1] <= 0)) {
                PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
            } else {
                lim[0] = newLim[0];
                lim[1] = newLim[1];

                if (!fixedTicks) {
                    updateTicks();
                    updateTickLabels();
                }

                updatePlotTicks();
                updateTicksInside();
            }
        }
    }

    /**
     * Sets the axis limits and the axis scale
     * 
     * @param newLim
     *            the new axis limits
     * @param newLog
     *            the new axis scale
     */
    public void setLimAndLog(float[] newLim, boolean newLog) {
        if (newLim[1] != newLim[0]) {
            // Make sure the new limits makes sense
            if (newLog && (newLim[0] <= 0 || newLim[1] <= 0)) {
                PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
            } else {
                lim[0] = newLim[0];
                lim[1] = newLim[1];
                log = newLog;

                if (!fixedTicks) {
                    updateTicks();
                    updateTickLabels();
                }

                updatePlotTicks();
                updateTicksInside();
            }
        }
    }

    /**
     * Sets the axis scale
     * 
     * @param newLog
     *            the new axis scale
     */
    public void setLog(boolean newLog) {
        if (newLog != log) {
            log = newLog;

            // Check if the old limits still make sense
            if (log && (lim[0] <= 0 || lim[1] <= 0)) {
                PApplet.println("The limits are negative. This is not allowed in logarithmic scale.");
                PApplet.println("Will set them to (0.1, 10)");

                if (lim[1] > lim[0]) {
                    lim[0] = 0.1f;
                    lim[1] = 10f;
                } else {
                    lim[0] = 10f;
                    lim[1] = 0.1f;
                }
            }

            if (!fixedTicks) {
                updateTicks();
                updateTickLabels();
            }

            updatePlotTicks();
            updateTicksInside();
        }
    }

    /**
     * Sets the axis offset with respect to the plot box
     * 
     * @param newOffset
     *            the new axis offset
     */
    public void setOffset(float newOffset) {
        offset = newOffset;
    }

    /**
     * Sets the line color
     * 
     * @param newLineColor
     *            the new line color
     */
    public void setLineColor(int newLineColor) {
        lineColor = newLineColor;
    }

    /**
     * Sets the line width
     * 
     * @param newLineWidth
     *            the new line width
     */
    public void setLineWidth(float newLineWidth) {
        if (newLineWidth > 0) {
            lineWidth = newLineWidth;
        }
    }

    /**
     * Sets the approximate number of ticks in the axis. The actual number of
     * ticks depends on the axis limits and the axis scale
     * 
     * @param newNTicks
     *            the new approximate number of ticks in the axis
     */
    public void setNTicks(int newNTicks) {
        if (newNTicks >= 0) {
            nTicks = newNTicks;
            ticksSeparation = -1;

            if (!log) {
                fixedTicks = false;
                updateTicks();
                updatePlotTicks();
                updateTicksInside();
                updateTickLabels();
            }
        }
    }

    /**
     * Sets the separation between the ticks in the axis
     * 
     * @param newTicksSeparation
     *            the new ticks separation
     */
    public void setTicksSeparation(float newTicksSeparation) {
        ticksSeparation = newTicksSeparation;

        if (!log) {
            fixedTicks = false;
            updateTicks();
            updatePlotTicks();
            updateTicksInside();
            updateTickLabels();
        }
    }

    /**
     * Sets the axis ticks
     * 
     * @param newTicks
     *            the new axis ticks
     */
    public void setTicks(float[] newTicks) {
        fixedTicks = true;
        int n = newTicks.length;
        adaptSize(ticks, n);

        for (int i = 0; i < n; i++) {
            ticks.set(i, newTicks[i]);
        }

        updatePlotTicks();
        updateTicksInside();
        updateTickLabels();
    }

    /**
     * Sets the axis ticks labels
     * 
     * @param newTickLabels
     *            the new axis ticks labels
     */
    public void setTickLabels(String[] newTickLabels) {
        if (newTickLabels.length == tickLabels.size()) {
            fixedTicks = true;

            for (int i = 0; i < tickLabels.size(); i++) {
                tickLabels.set(i, newTickLabels[i]);
            }
        }
    }

    /**
     * Sets if the axis ticks are fixed or not
     * 
     * @param newFixedTicks
     *            true if the axis ticks should be fixed
     */
    public void setFixedTicks(boolean newFixedTicks) {
        if (newFixedTicks != fixedTicks) {
            fixedTicks = newFixedTicks;

            if (!fixedTicks) {
                updateTicks();
                updatePlotTicks();
                updateTicksInside();
                updateTickLabels();
            }
        }
    }

    /**
     * Sets the tick length
     * 
     * @param newTickLength
     *            the new tick length
     */
    public void setTickLength(float newTickLength) {
        tickLength = newTickLength;
    }

    /**
     * Sets the small tick length
     * 
     * @param newSmallTickLength
     *            the new small tick length
     */
    public void setSmallTickLength(float newSmallTickLength) {
        smallTickLength = newSmallTickLength;
    }

    /**
     * Sets if the ticks labels should be displayed in exponential form or not
     * 
     * @param newExpTickLabels
     *            true if the ticks labels should be in exponential form
     */
    public void setExpTickLabels(boolean newExpTickLabels) {
        if (newExpTickLabels != expTickLabels) {
            expTickLabels = newExpTickLabels;
            updateTickLabels();
        }
    }

    /**
     * Sets if the ticks labels should be displayed rotated or not
     * 
     * @param newRotateTickLabels
     *            true is the ticks labels should be rotated
     */
    public void setRotateTickLabels(boolean newRotateTickLabels) {
        rotateTickLabels = newRotateTickLabels;
    }

    /**
     * Sets if the ticks labels should be drawn or not
     * 
     * @param newDrawTicksLabels
     *            true it the ticks labels should be drawn
     */
    public void setDrawTickLabels(boolean newDrawTicksLabels) {
        drawTickLabels = newDrawTicksLabels;
    }

    /**
     * Sets the tick label offset
     * 
     * @param newTickLabelOffset
     *            the new tick label offset
     */
    public void setTickLabelOffset(float newTickLabelOffset) {
        tickLabelOffset = newTickLabelOffset;
    }

    /**
     * Sets if the axis label should be drawn or not
     * 
     * @param newDrawAxisLabel
     *            true if the axis label should be drawn
     */
    public void setDrawAxisLabel(boolean newDrawAxisLabel) {
        drawAxisLabel = newDrawAxisLabel;
    }

    /**
     * Sets the axis label text
     * 
     * @param text
     *            the new axis label text
     */
    public void setAxisLabelText(String text) {
        lab.setText(text);
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

    /**
     * Sets the font properties in the axis and the axis label
     * 
     * @param newFontName
     *            the new font name
     * @param newFontColor
     *            the new font color
     * @param newFontSize
     *            the new font size
     */
    public void setAllFontProperties(String newFontName, int newFontColor, int newFontSize) {
        setFontProperties(newFontName, newFontColor, newFontSize);
        lab.setFontProperties(newFontName, newFontColor, newFontSize);
    }

    /**
     * Returns a copy of the axis ticks
     * 
     * @return a copy of the axis ticks
     */
    public float[] getTicks() {
        if (fixedTicks) {
            float[] a = new float[ticks.size()];

            for (int i = 0; i < ticks.size(); i++) {
                a[i] = ticks.get(i);
            }

            return a;
        } else {
            return removeOutsideTicks();
        }
    }

    /**
     * Returns the axis ticks
     * 
     * @return the axis ticks
     */
    public ArrayList<Float> getTicksRef() {
        return ticks;
    }

    /**
     * Returns a copy of the axis ticks positions in the plot reference system
     * 
     * @return a copy of the axis ticks positions in the plot reference system
     */
    public float[] getPlotTicks() {
        if (fixedTicks) {
            float[] a = new float[plotTicks.size()];

            for (int i = 0; i < plotTicks.size(); i++) {
                a[i] = plotTicks.get(i);
            }

            return a;
        } else {
            return removeOutsidePlotTicks();
        }
    }

    /**
     * Returns the axis ticks positions in the plot reference system
     * 
     * @return the axis ticks positions in the plot reference system
     */
    public ArrayList<Float> getPlotTicksRef() {
        return plotTicks;
    }

    /**
     * Returns the axis label
     * 
     * @return the axis label
     */
    public GAxisLabel getAxisLabel() {
        return lab;
    }
}
