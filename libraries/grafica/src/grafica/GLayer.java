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
import processing.core.PImage;
import processing.core.PShape;

/**
 * Layer class. A GLayer usually contains an array of points and a histogram
 * 
 * @author Javier Gracia Carpio http://jagracar.com
 */
public class GLayer implements PConstants {
	// The parent Processing applet
	protected final PApplet parent;

	// General properties
	protected final String id;
	protected float[] dim;
	protected float[] xLim;
	protected float[] yLim;
	protected boolean xLog;
	protected boolean yLog;

	// Points properties
	protected GPointsArray points;
	protected GPointsArray plotPoints;
	protected ArrayList<Boolean> inside;
	protected int[] pointColors;
	protected float[] pointSizes;

	// Line properties
	protected int lineColor;
	protected float lineWidth;

	// Histogram properties
	protected GHistogram hist;
	protected GPoint histBasePoint;

	// Labels properties
	protected int labelBgColor;
	protected float[] labelSeparation;
	protected String fontName;
	protected int fontColor;
	protected int fontSize;
	protected PFont font;

	// Helper variable
	protected float[][] cuts = new float[4][2];

	/**
	 * GLayer constructor
	 * 
	 * @param parent
	 *            the parent Processing applet
	 * @param id
	 *            the layer id
	 * @param dim
	 *            the plot box dimensions in pixels
	 * @param xLim
	 *            the horizontal limits
	 * @param yLim
	 *            the vertical limits
	 * @param xLog
	 *            the horizontal scale. True if it's logarithmic
	 * @param yLog
	 *            the vertical scale. True if it's logarithmic
	 */
	public GLayer(PApplet parent, String id, float[] dim, float[] xLim,
			float[] yLim, boolean xLog, boolean yLog) {
		this.parent = parent;

		this.id = id;
		this.dim = dim.clone();
		this.xLim = xLim.clone();
		this.yLim = yLim.clone();
		this.xLog = xLog;
		this.yLog = yLog;

		// Do some sanity checks
		if (this.xLog && (this.xLim[0] <= 0 || this.xLim[1] <= 0)) {
			PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
			PApplet.println("Will set horizontal limits to (0.1, 10)");
			this.xLim[0] = 0.1f;
			this.xLim[1] = 10;
		}

		if (this.yLog && (this.yLim[0] <= 0 || this.yLim[1] <= 0)) {
			PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
			PApplet.println("Will set vertical limits to (0.1, 10)");
			this.yLim[0] = 0.1f;
			this.yLim[1] = 10;
		}

		// Continue with the rest
		points = new GPointsArray();
		plotPoints = new GPointsArray();
		inside = new ArrayList<Boolean>();
		pointColors = new int[] { this.parent.color(255, 0, 0, 150) };
		pointSizes = new float[] { 7 };

		lineColor = this.parent.color(0, 150);
		lineWidth = 1;

		hist = null;
		histBasePoint = new GPoint(0, 0);

		labelBgColor = this.parent.color(255, 200);
		labelSeparation = new float[] { 7, 7 };
		fontName = "SansSerif.plain";
		fontColor = this.parent.color(0);
		fontSize = 11;
		font = this.parent.createFont(fontName, fontSize);
	}

	/**
	 * Checks if the provided number is a valid number (i.e. is not NaN and is
	 * not Infinite)
	 * 
	 * @param number
	 *            the number to check
	 * 
	 * @return true if it's not NaN and is not Infinite
	 */
	protected boolean isValidNumber(float number) {
		return !Float.isNaN(number) && !Float.isInfinite(number);
	}

	/**
	 * Checks if the layer's id is equal to a given id
	 * 
	 * @param someId
	 *            the id to check
	 * 
	 * @return true if the provided id is equal to the layer's id
	 */
	public boolean isId(String someId) {
		return id.equals(someId);
	}

	/**
	 * Calculates the position of the x value in the plot reference system
	 * 
	 * @param x
	 *            the x value
	 * 
	 * @return the x position in the plot reference system
	 */
	public float valueToXPlot(float x) {
		if (xLog) {
			return dim[0] * PApplet.log(x / xLim[0])
					/ PApplet.log(xLim[1] / xLim[0]);
		} else {
			return dim[0] * (x - xLim[0]) / (xLim[1] - xLim[0]);
		}
	}

	/**
	 * Calculates the position of the y value in the plot reference system
	 * 
	 * @param y
	 *            the y value
	 * 
	 * @return the y position in the plot reference system
	 */
	public float valueToYPlot(float y) {
		if (yLog) {
			return -dim[1] * PApplet.log(y / yLim[0])
					/ PApplet.log(yLim[1] / yLim[0]);
		} else {
			return -dim[1] * (y - yLim[0]) / (yLim[1] - yLim[0]);
		}
	}

	/**
	 * Calculates the position of a given (x, y) point in the plot reference
	 * system
	 * 
	 * @param x
	 *            the x value
	 * @param y
	 *            the y value
	 * 
	 * @return the (x, y) position in the plot reference system
	 */
	public float[] valueToPlot(float x, float y) {
		return new float[] { valueToXPlot(x), valueToYPlot(y) };
	}

	/**
	 * Calculates the position of a given point in the plot reference system
	 * 
	 * @param point
	 *            the point
	 * 
	 * @return a copy of the point with its position transformed to the plot
	 *         reference system
	 */
	public GPoint valueToPlot(GPoint point) {
		return new GPoint(valueToXPlot(point.getX()),
				valueToYPlot(point.getY()), point.getLabel());
	}

	/**
	 * Calculates the positions of a given set of points in the plot reference
	 * system
	 * 
	 * @param pts
	 *            the set of points
	 * 
	 * @return a copy of the set of point with their positions transformed to
	 *         the plot reference system
	 */
	public GPointsArray valueToPlot(GPointsArray pts) {
		int nPoints = pts.getNPoints();
		GPointsArray plotPts = new GPointsArray(nPoints);

		// Go case by case. More code, but it's faster
		if (xLog && yLog) {
			float xScalingFactor = dim[0] / PApplet.log(xLim[1] / xLim[0]);
			float yScalingFactor = -dim[1] / PApplet.log(yLim[1] / yLim[0]);

			for (int i = 0; i < nPoints; i++) {
				float xPlot = PApplet.log(pts.getX(i) / xLim[0])
						* xScalingFactor;
				float yPlot = PApplet.log(pts.getY(i) / yLim[0])
						* yScalingFactor;
				plotPts.add(xPlot, yPlot, pts.getLabel(i));
			}
		} else if (xLog) {
			float xScalingFactor = dim[0] / PApplet.log(xLim[1] / xLim[0]);
			float yScalingFactor = -dim[1] / (yLim[1] - yLim[0]);

			for (int i = 0; i < nPoints; i++) {
				float xPlot = PApplet.log(pts.getX(i) / xLim[0])
						* xScalingFactor;
				float yPlot = (pts.getY(i) - yLim[0]) * yScalingFactor;
				plotPts.add(xPlot, yPlot, pts.getLabel(i));
			}
		} else if (yLog) {
			float xScalingFactor = dim[0] / (xLim[1] - xLim[0]);
			float yScalingFactor = -dim[1] / PApplet.log(yLim[1] / yLim[0]);

			for (int i = 0; i < nPoints; i++) {
				float xPlot = (pts.getX(i) - xLim[0]) * xScalingFactor;
				float yPlot = PApplet.log(pts.getY(i) / yLim[0])
						* yScalingFactor;
				plotPts.add(xPlot, yPlot, pts.getLabel(i));
			}
		} else {
			float xScalingFactor = dim[0] / (xLim[1] - xLim[0]);
			float yScalingFactor = -dim[1] / (yLim[1] - yLim[0]);

			for (int i = 0; i < nPoints; i++) {
				float xPlot = (pts.getX(i) - xLim[0]) * xScalingFactor;
				float yPlot = (pts.getY(i) - yLim[0]) * yScalingFactor;
				plotPts.add(xPlot, yPlot, pts.getLabel(i));
			}
		}

		return plotPts;
	}

	/**
	 * Updates the position of the layer points to the plot reference system
	 */
	protected void updatePlotPoints() {
		int nPoints = points.getNPoints();

		// Go case by case. More code, but it should be faster
		if (xLog && yLog) {
			float xScalingFactor = dim[0] / PApplet.log(xLim[1] / xLim[0]);
			float yScalingFactor = -dim[1] / PApplet.log(yLim[1] / yLim[0]);

			for (int i = 0; i < nPoints; i++) {
				float xPlot = PApplet.log(points.getX(i) / xLim[0])
						* xScalingFactor;
				float yPlot = PApplet.log(points.getY(i) / yLim[0])
						* yScalingFactor;
				plotPoints.set(i, xPlot, yPlot, points.getLabel(i));
			}
		} else if (xLog) {
			float xScalingFactor = dim[0] / PApplet.log(xLim[1] / xLim[0]);
			float yScalingFactor = -dim[1] / (yLim[1] - yLim[0]);

			for (int i = 0; i < nPoints; i++) {
				float xPlot = PApplet.log(points.getX(i) / xLim[0])
						* xScalingFactor;
				float yPlot = (points.getY(i) - yLim[0]) * yScalingFactor;
				plotPoints.set(i, xPlot, yPlot, points.getLabel(i));
			}
		} else if (yLog) {
			float xScalingFactor = dim[0] / (xLim[1] - xLim[0]);
			float yScalingFactor = -dim[1] / PApplet.log(yLim[1] / yLim[0]);

			for (int i = 0; i < nPoints; i++) {
				float xPlot = (points.getX(i) - xLim[0]) * xScalingFactor;
				float yPlot = PApplet.log(points.getY(i) / yLim[0])
						* yScalingFactor;
				plotPoints.set(i, xPlot, yPlot, points.getLabel(i));
			}
		} else {
			float xScalingFactor = dim[0] / (xLim[1] - xLim[0]);
			float yScalingFactor = -dim[1] / (yLim[1] - yLim[0]);

			for (int i = 0; i < nPoints; i++) {
				float xPlot = (points.getX(i) - xLim[0]) * xScalingFactor;
				float yPlot = (points.getY(i) - yLim[0]) * yScalingFactor;
				plotPoints.set(i, xPlot, yPlot, points.getLabel(i));
			}
		}

		// Remove the unused points
		if (plotPoints.getNPoints() > nPoints) {
			plotPoints.setNPoints(nPoints);
		}
	}

	/**
	 * Returns the plot x value at a given position in the plot reference system
	 * 
	 * @param xPlot
	 *            x position in the plot reference system
	 * 
	 * @return the x values at the xPlot position
	 */
	protected float xPlotToValue(float xPlot) {
		if (xLog) {
			return PApplet.exp(PApplet.log(xLim[0])
					+ PApplet.log(xLim[1] / xLim[0]) * xPlot / dim[0]);
		} else {
			return xLim[0] + (xLim[1] - xLim[0]) * xPlot / dim[0];
		}
	}

	/**
	 * Returns the plot y value at a given position in the plot reference system
	 * 
	 * @param yPlot
	 *            y position in the plot reference system
	 * 
	 * @return the y values at the yPlot position
	 */
	protected float yPlotToValue(float yPlot) {
		if (yLog) {
			return PApplet.exp(PApplet.log(yLim[0])
					- PApplet.log(yLim[1] / yLim[0]) * yPlot / dim[1]);
		} else {
			return yLim[0] - (yLim[1] - yLim[0]) * yPlot / dim[1];
		}
	}

	/**
	 * Returns the plot values at a given position in the plot reference system
	 * 
	 * @param xPlot
	 *            x position in the plot reference system
	 * @param yPlot
	 *            y position in the plot reference system
	 * 
	 * @return the (x, y) values at the (xPlot, yPlot) position
	 */
	public float[] plotToValue(float xPlot, float yPlot) {
		return new float[] { xPlotToValue(xPlot), yPlotToValue(yPlot) };
	}

	/**
	 * Checks if a given (xPlot, yPlot) position in the plot reference system is
	 * inside the layer limits
	 * 
	 * @param xPlot
	 *            x position in the plot reference system
	 * @param yPlot
	 *            y position in the plot reference system
	 * 
	 * @return true if the (xPlot, yPlot) position is inside the layer limits
	 */
	public boolean isInside(float xPlot, float yPlot) {
		return (xPlot >= 0) && (xPlot <= dim[0]) && (-yPlot >= 0)
				&& (-yPlot <= dim[1]);
	}

	/**
	 * Checks if a given point in the plot reference system is inside the layer
	 * limits
	 * 
	 * @param plotPoint
	 *            the point in the plot reference system
	 * 
	 * @return true if the point is inside the layer limits
	 */
	public boolean isInside(GPoint plotPoint) {
		return (plotPoint.isValid()) ? isInside(plotPoint.getX(),
				plotPoint.getY()) : false;
	}

	/**
	 * Checks if a given set of points in the plot reference system is inside
	 * the layer limits
	 * 
	 * @param plotPts
	 *            the set of points to check
	 * 
	 * @return a boolean array with the elements set to true if the point is
	 *         inside the layer limits
	 */
	public boolean[] isInside(GPointsArray plotPts) {
		boolean[] pointsInside = new boolean[plotPts.getNPoints()];

		for (int i = 0; i < pointsInside.length; i++) {
			pointsInside[i] = isInside(plotPts.get(i));
		}

		return pointsInside;
	}

	/**
	 * Updates the array list that tells if the points are inside the layer
	 * limits or not
	 */
	protected void updateInsideList() {
		// Clear the list first, because the size could have changed
		inside.clear();

		// Refill the list
		int nPoints = plotPoints.getNPoints();

		for (int i = 0; i < nPoints; i++) {
			inside.add(isInside(plotPoints.get(i)));
		}
	}

	/**
	 * Returns the position index of the closest point (if any) to a given
	 * position in the plot reference system
	 * 
	 * @param xPlot
	 *            x position in the plot reference system
	 * @param yPlot
	 *            y position in the plot reference system
	 * 
	 * @return the position index of closest point to the specified position.
	 *         Returns -1 if there is no close point.
	 */
	public int getPointIndexAtPlotPos(float xPlot, float yPlot) {
		int pointIndex = -1;

		if (isInside(xPlot, yPlot)) {
			int nPoints = plotPoints.getNPoints();
			float minDistSq = 25;

			for (int i = 0; i < nPoints; i++) {
				if (inside.get(i)) {
					float distSq = PApplet.sq(plotPoints.getX(i) - xPlot)
							+ PApplet.sq(plotPoints.getY(i) - yPlot);

					if (distSq < minDistSq) {
						minDistSq = distSq;
						pointIndex = i;
					}
				}
			}
		}

		return pointIndex;
	}

	/**
	 * Returns the closest point (if any) to a given position in the plot
	 * reference system
	 * 
	 * @param xPlot
	 *            x position in the plot reference system
	 * @param yPlot
	 *            y position in the plot reference system
	 * 
	 * @return the closest point to the specified position. Returns null if
	 *         there is no close point.
	 */
	public GPoint getPointAtPlotPos(float xPlot, float yPlot) {
		int pointIndex = getPointIndexAtPlotPos(xPlot, yPlot);

		return (pointIndex >= 0) ? points.get(pointIndex) : null;
	}

	/**
	 * Obtains the box intersections of the line that connects two given points
	 * 
	 * @param plotPoint1
	 *            the first point in the plot reference system
	 * @param plotPoint2
	 *            the second point in the plot reference system
	 * 
	 * @return the number of box intersections in the plot reference system
	 */
	protected int obtainBoxIntersections(GPoint plotPoint1, GPoint plotPoint2) {
		int nCuts = 0;

		if (plotPoint1.isValid() && plotPoint2.isValid()) {
			float x1 = plotPoint1.getX();
			float y1 = plotPoint1.getY();
			float x2 = plotPoint2.getX();
			float y2 = plotPoint2.getY();
			boolean inside1 = isInside(x1, y1);
			boolean inside2 = isInside(x2, y2);

			// Check if the line between the two points could cut the box
			// borders
			boolean dontCut = (inside1 && inside2) || (x1 < 0 && x2 < 0)
					|| (x1 > dim[0] && x2 > dim[0]) || (-y1 < 0 && -y2 < 0)
					|| (-y1 > dim[1] && -y2 > dim[1]);

			if (!dontCut) {
				// Obtain the axis cuts of the line that cross the two points
				float deltaX = x2 - x1;
				float deltaY = y2 - y1;

				if (deltaX == 0) {
					nCuts = 2;
					cuts[0][0] = x1;
					cuts[0][1] = 0;
					cuts[1][0] = x1;
					cuts[1][1] = -dim[1];
				} else if (deltaY == 0) {
					nCuts = 2;
					cuts[0][0] = 0;
					cuts[0][1] = y1;
					cuts[1][0] = dim[0];
					cuts[1][1] = y1;
				} else {
					// Obtain the straight line (y = yCut + slope*x) that
					// crosses the two points
					float slope = deltaY / deltaX;
					float yCut = y1 - slope * x1;

					// Calculate the axis cuts of that line
					nCuts = 4;
					cuts[0][0] = -yCut / slope;
					cuts[0][1] = 0;
					cuts[1][0] = (-dim[1] - yCut) / slope;
					cuts[1][1] = -dim[1];
					cuts[2][0] = 0;
					cuts[2][1] = yCut;
					cuts[3][0] = dim[0];
					cuts[3][1] = yCut + slope * dim[0];
				}

				// Select only the cuts that fall inside the box and are located
				// between the two points
				nCuts = getValidCuts(cuts, nCuts, plotPoint1, plotPoint2);

				// Make sure we have the correct number of cuts
				if (inside1 || inside2) {
					// One of the points is inside. We should have one cut only
					if (nCuts != 1) {
						GPoint pointInside = (inside1) ? plotPoint1
								: plotPoint2;

						// If too many cuts
						if (nCuts > 1) {
							nCuts = removeDuplicatedCuts(cuts, nCuts, 0);

							if (nCuts > 1) {
								nCuts = removePointFromCuts(cuts, nCuts,
										pointInside, 0);

								// In case of rounding number errors
								if (nCuts > 1) {
									nCuts = removeDuplicatedCuts(cuts, nCuts,
											0.001f);

									if (nCuts > 1) {
										nCuts = removePointFromCuts(cuts,
												nCuts, pointInside, 0.001f);
									}
								}
							}
						}

						// If the cut is missing, then it must be equal to the
						// point inside
						if (nCuts == 0) {
							nCuts = 1;
							cuts[0][0] = pointInside.getX();
							cuts[1][0] = pointInside.getY();
						}
					}
				} else {
					// Both points are outside. We should have either two cuts
					// or none
					if (nCuts > 2) {
						nCuts = removeDuplicatedCuts(cuts, nCuts, 0);

						// In case of rounding number errors
						if (nCuts > 2) {
							nCuts = removeDuplicatedCuts(cuts, nCuts, 0.001f);
						}
					}

					// If we have two cuts, order them (the closest to the first
					// point goes first)
					if (nCuts == 2) {
						if ((PApplet.sq(cuts[0][0] - x1) + PApplet
								.sq(cuts[0][1] - y1)) > (PApplet.sq(cuts[1][0]
								- x1) + PApplet.sq(cuts[1][1] - y1))) {
							cuts[2][0] = cuts[0][0];
							cuts[2][1] = cuts[0][1];
							cuts[0][0] = cuts[1][0];
							cuts[0][1] = cuts[1][1];
							cuts[1][0] = cuts[2][0];
							cuts[1][1] = cuts[2][1];
						}
					}

					// If one cut is missing, add the same one twice
					if (nCuts == 1) {
						nCuts = 2;
						cuts[1][0] = cuts[0][0];
						cuts[1][1] = cuts[0][1];
					}
				}

				// Some sanity checks
				if ((inside1 || inside2) && nCuts != 1) {
					PApplet.println("There should be one cut!!!");
				} else if (!inside1 && !inside2 && nCuts != 0 && nCuts != 2) {
					PApplet.println("There should be either 0 or 2 cuts!!! "
							+ nCuts + " were found");
				}
			}
		}

		return nCuts;
	}

	/**
	 * Returns only those cuts that are inside the box region and lie between
	 * the two given points
	 * 
	 * @param cuts
	 *            the axis cuts
	 * @param nCuts
	 *            the number of cuts
	 * @param plotPoint1
	 *            the first point in the plot reference system
	 * @param plotPoint2
	 *            the second point in the plot reference system
	 * 
	 * @return the number of cuts inside the box region and between the two
	 *         points
	 */
	protected int getValidCuts(float[][] cuts, int nCuts, GPoint plotPoint1,
			GPoint plotPoint2) {
		float x1 = plotPoint1.getX();
		float y1 = plotPoint1.getY();
		float x2 = plotPoint2.getX();
		float y2 = plotPoint2.getY();
		float deltaX = Math.abs(x2 - x1);
		float deltaY = Math.abs(y2 - y1);
		int counter = 0;

		for (int i = 0; i < nCuts; i++) {
			// Check that the cut is inside the inner plotting area
			if (isInside(cuts[i][0], cuts[i][1])) {
				// Check that the cut falls between the two points
				if (Math.abs(cuts[i][0] - x1) <= deltaX
						&& Math.abs(cuts[i][1] - y1) <= deltaY
						&& Math.abs(cuts[i][0] - x2) <= deltaX
						&& Math.abs(cuts[i][1] - y2) <= deltaY) {
					cuts[counter][0] = cuts[i][0];
					cuts[counter][1] = cuts[i][1];
					counter++;
				}
			}
		}

		return counter;
	}

	/**
	 * Removes duplicated cuts
	 * 
	 * @param cuts
	 *            the box cuts
	 * @param nCuts
	 *            the number of cuts
	 * @param tolerance
	 *            maximum distance after which the points can't be duplicates
	 * 
	 * @return the number of cuts without the duplications
	 */
	protected int removeDuplicatedCuts(float[][] cuts, int nCuts,
			float tolerance) {
		int counter = 0;

		for (int i = 0; i < nCuts; i++) {
			boolean repeated = false;

			for (int j = 0; j < counter; j++) {
				if (Math.abs(cuts[j][0] - cuts[i][0]) <= tolerance
						&& Math.abs(cuts[j][1] - cuts[i][1]) <= tolerance) {
					repeated = true;
					break;
				}
			}

			if (!repeated) {
				cuts[counter][0] = cuts[i][0];
				cuts[counter][1] = cuts[i][1];
				counter++;
			}
		}

		return counter;
	}

	/**
	 * Removes cuts that are equal to a given point
	 * 
	 * @param cuts
	 *            the box cuts
	 * @param nCuts
	 *            the number of cuts
	 * @param plotPoint
	 *            the point to compare with
	 * @param tolerance
	 *            maximum distance after which the points can't be equal
	 * 
	 * @return the number of cuts without the point duplications
	 */
	protected int removePointFromCuts(float[][] cuts, int nCuts,
			GPoint plotPoint, float tolerance) {
		float x = plotPoint.getX();
		float y = plotPoint.getY();
		int counter = 0;

		for (int i = 0; i < nCuts; i++) {
			if (Math.abs(cuts[i][0] - x) > tolerance
					|| Math.abs(cuts[i][1] - y) > tolerance) {
				cuts[counter][0] = cuts[i][0];
				cuts[counter][1] = cuts[i][1];
				counter++;
			}
		}

		return counter;
	}

	/**
	 * Initializes the histogram
	 * 
	 * @param histType
	 *            the type of histogram to use. It can be GPlot.VERTICAL or
	 *            GPlot.HORIZONTAL
	 */
	public void startHistogram(int histType) {
		hist = new GHistogram(parent, histType, dim, plotPoints);
	}

	/**
	 * Draws the points inside the layer limits
	 */
	public void drawPoints() {
		int nPoints = plotPoints.getNPoints();
		int nColors = pointColors.length;
		int nSizes = pointSizes.length;

		parent.pushStyle();
		parent.ellipseMode(CENTER);
		parent.noStroke();

		if (nColors == 1 && nSizes == 1) {
			parent.fill(pointColors[0]);

			for (int i = 0; i < nPoints; i++) {
				if (inside.get(i)) {
					parent.ellipse(plotPoints.getX(i), plotPoints.getY(i),
							pointSizes[0], pointSizes[0]);
				}
			}
		} else if (nColors == 1) {
			parent.fill(pointColors[0]);

			for (int i = 0; i < nPoints; i++) {
				if (inside.get(i)) {
					parent.ellipse(plotPoints.getX(i), plotPoints.getY(i),
							pointSizes[i % nSizes], pointSizes[i % nSizes]);
				}
			}
		} else if (nSizes == 1) {
			for (int i = 0; i < nPoints; i++) {
				if (inside.get(i)) {
					parent.fill(pointColors[i % nColors]);
					parent.ellipse(plotPoints.getX(i), plotPoints.getY(i),
							pointSizes[0], pointSizes[0]);
				}
			}
		} else {
			for (int i = 0; i < nPoints; i++) {
				if (inside.get(i)) {
					parent.fill(pointColors[i % nColors]);
					parent.ellipse(plotPoints.getX(i), plotPoints.getY(i),
							pointSizes[i % nSizes], pointSizes[i % nSizes]);
				}
			}
		}

		parent.popStyle();
	}

	/**
	 * Draws the points inside the layer limits
	 * 
	 * @param pointShape
	 *            the shape that should be used to represent the points
	 */
	public void drawPoints(PShape pointShape) {
		int nPoints = plotPoints.getNPoints();
		int nColors = pointColors.length;

		parent.pushStyle();
		parent.shapeMode(CENTER);

		if (nColors == 1) {
			parent.fill(pointColors[0]);
			parent.stroke(pointColors[0]);

			for (int i = 0; i < nPoints; i++) {
				if (inside.get(i)) {
					parent.shape(pointShape, plotPoints.getX(i),
							plotPoints.getY(i));
				}
			}
		} else {
			for (int i = 0; i < nPoints; i++) {
				if (inside.get(i)) {
					parent.fill(pointColors[i % nColors]);
					parent.stroke(pointColors[i % nColors]);
					parent.shape(pointShape, plotPoints.getX(i),
							plotPoints.getY(i));
				}
			}
		}

		parent.popStyle();
	}

	/**
	 * Draws the points inside the layer limits
	 * 
	 * @param pointImg
	 *            the image that should be used to represent the points
	 */
	public void drawPoints(PImage pointImg) {
		int nPoints = plotPoints.getNPoints();

		parent.pushStyle();
		parent.imageMode(CENTER);

		for (int i = 0; i < nPoints; i++) {
			if (inside.get(i)) {
				parent.image(pointImg, plotPoints.getX(i), plotPoints.getY(i));
			}
		}

		parent.popStyle();
	}

	/**
	 * Draws a point
	 * 
	 * @param point
	 *            the point to draw
	 * @param pointColor
	 *            color to use
	 * @param pointSize
	 *            point size in pixels
	 */
	public void drawPoint(GPoint point, int pointColor, float pointSize) {
		float xPlot = valueToXPlot(point.getX());
		float yPlot = valueToYPlot(point.getY());

		if (isInside(xPlot, yPlot)) {
			parent.pushStyle();
			parent.ellipseMode(CENTER);
			parent.fill(pointColor);
			parent.noStroke();
			parent.ellipse(xPlot, yPlot, pointSize, pointSize);
			parent.popStyle();
		}
	}

	/**
	 * Draws a point
	 * 
	 * @param point
	 *            the point to draw
	 */
	public void drawPoint(GPoint point) {
		drawPoint(point, pointColors[0], pointSizes[0]);
	}

	/**
	 * Draws a point
	 * 
	 * @param point
	 *            the point to draw
	 * @param pointShape
	 *            the shape that should be used to represent the point
	 */
	public void drawPoint(GPoint point, PShape pointShape) {
		float xPlot = valueToXPlot(point.getX());
		float yPlot = valueToYPlot(point.getY());

		parent.pushStyle();
		parent.shapeMode(CENTER);

		if (isInside(xPlot, yPlot)) {
			parent.shape(pointShape, xPlot, yPlot);
		}

		parent.popStyle();
	}

	/**
	 * Draws a point
	 * 
	 * @param point
	 *            the point to draw
	 * @param pointShape
	 *            the shape that should be used to represent the points
	 * @param pointColor
	 *            color to use
	 */
	public void drawPoint(GPoint point, PShape pointShape, int pointColor) {
		float xPlot = valueToXPlot(point.getX());
		float yPlot = valueToYPlot(point.getY());

		if (isInside(xPlot, yPlot)) {
			parent.pushStyle();
			parent.shapeMode(CENTER);
			parent.fill(pointColor);
			parent.stroke(pointColor);
			parent.strokeCap(SQUARE);
			parent.shape(pointShape, xPlot, yPlot);
			parent.popStyle();
		}
	}

	/**
	 * Draws a point
	 * 
	 * @param point
	 *            the point to draw
	 * @param pointImg
	 *            the image that should be used to represent the point
	 */
	public void drawPoint(GPoint point, PImage pointImg) {
		float xPlot = valueToXPlot(point.getX());
		float yPlot = valueToYPlot(point.getY());

		parent.pushStyle();
		parent.imageMode(CENTER);

		if (isInside(xPlot, yPlot)) {
			parent.image(pointImg, xPlot, yPlot);
		}

		parent.popStyle();
	}

	/**
	 * Draws lines connecting consecutive points in the layer
	 */
	public void drawLines() {
		parent.pushStyle();
		parent.noFill();
		parent.stroke(lineColor);
		parent.strokeWeight(lineWidth);
		parent.strokeCap(SQUARE);

		for (int i = 0; i < plotPoints.getNPoints() - 1; i++) {
			if (inside.get(i) && inside.get(i + 1)) {
				parent.line(plotPoints.getX(i), plotPoints.getY(i),
						plotPoints.getX(i + 1), plotPoints.getY(i + 1));
			} else if (plotPoints.isValid(i) && plotPoints.isValid(i + 1)) {
				// At least one of the points is outside the inner region.
				// Obtain the valid line box intersections
				int nCuts = obtainBoxIntersections(plotPoints.get(i),
						plotPoints.get(i + 1));

				if (inside.get(i)) {
					parent.line(plotPoints.getX(i), plotPoints.getY(i),
							cuts[0][0], cuts[0][1]);
				} else if (inside.get(i + 1)) {
					parent.line(cuts[0][0], cuts[0][1], plotPoints.getX(i + 1),
							plotPoints.getY(i + 1));
				} else if (nCuts >= 2) {
					parent.line(cuts[0][0], cuts[0][1], cuts[1][0], cuts[1][1]);
				}
			}
		}

		parent.popStyle();
	}

	/**
	 * Draws a line between two points
	 * 
	 * @param point1
	 *            first point
	 * @param point2
	 *            second point
	 * @param lc
	 *            line color
	 * @param lw
	 *            line width
	 */
	public void drawLine(GPoint point1, GPoint point2, int lc, float lw) {
		GPoint plotPoint1 = valueToPlot(point1);
		GPoint plotPoint2 = valueToPlot(point2);

		if (plotPoint1.isValid() && plotPoint2.isValid()) {
			boolean inside1 = isInside(plotPoint1);
			boolean inside2 = isInside(plotPoint2);

			parent.pushStyle();
			parent.noFill();
			parent.stroke(lc);
			parent.strokeWeight(lw);
			parent.strokeCap(SQUARE);

			if (inside1 && inside2) {
				parent.line(plotPoint1.getX(), plotPoint1.getY(),
						plotPoint2.getX(), plotPoint2.getY());
			} else {
				// At least one of the points is outside the inner region.
				// Obtain the valid line box intersections
				int nCuts = obtainBoxIntersections(plotPoint1, plotPoint2);

				if (inside1) {
					parent.line(plotPoint1.getX(), plotPoint1.getY(),
							cuts[0][0], cuts[0][1]);
				} else if (inside2) {
					parent.line(cuts[0][0], cuts[0][1], plotPoint2.getX(),
							plotPoint2.getY());
				} else if (nCuts >= 2) {
					parent.line(cuts[0][0], cuts[0][1], cuts[1][0], cuts[1][1]);
				}
			}

			parent.popStyle();
		}
	}

	/**
	 * Draws a line between two points
	 * 
	 * @param point1
	 *            first point
	 * @param point2
	 *            second point
	 */
	public void drawLine(GPoint point1, GPoint point2) {
		drawLine(point1, point2, lineColor, lineWidth);
	}

	/**
	 * Draws a line defined by the slope and the cut in the y axis
	 * 
	 * @param slope
	 *            the line slope
	 * @param yCut
	 *            the line y axis cut
	 * @param lc
	 *            line color
	 * @param lw
	 *            line width
	 */
	public void drawLine(float slope, float yCut, int lc, float lw) {
		GPoint point1, point2;

		if (xLog && yLog) {
			point1 = new GPoint(xLim[0], PApplet.pow(10,
					slope * PApplet.log(xLim[0]) / GPlot.LOG10 + yCut));
			point2 = new GPoint(xLim[1], PApplet.pow(10,
					slope * PApplet.log(xLim[1]) / GPlot.LOG10 + yCut));
		} else if (xLog) {
			point1 = new GPoint(xLim[0], slope * PApplet.log(xLim[0])
					/ GPlot.LOG10 + yCut);
			point2 = new GPoint(xLim[1], slope * PApplet.log(xLim[1])
					/ GPlot.LOG10 + yCut);
		} else if (yLog) {
			point1 = new GPoint(xLim[0],
					PApplet.pow(10, slope * xLim[0] + yCut));
			point2 = new GPoint(xLim[1],
					PApplet.pow(10, slope * xLim[1] + yCut));
		} else {
			point1 = new GPoint(xLim[0], slope * xLim[0] + yCut);
			point2 = new GPoint(xLim[1], slope * xLim[1] + yCut);
		}

		drawLine(point1, point2, lc, lw);
	}

	/**
	 * Draws a line defined by the slope and the cut in the y axis
	 * 
	 * @param slope
	 *            the line slope
	 * @param yCut
	 *            the line y axis cut
	 */
	public void drawLine(float slope, float yCut) {
		drawLine(slope, yCut, lineColor, lineWidth);
	}

	/**
	 * Draws an horizontal line
	 * 
	 * @param value
	 *            line horizontal value
	 * @param lc
	 *            line color
	 * @param lw
	 *            line width
	 */
	public void drawHorizontalLine(float value, int lc, float lw) {
		float yPlot = valueToYPlot(value);

		if (isValidNumber(yPlot) && -yPlot >= 0 && -yPlot <= dim[1]) {
			parent.pushStyle();
			parent.noFill();
			parent.stroke(lc);
			parent.strokeWeight(lw);
			parent.strokeCap(SQUARE);
			parent.line(0, yPlot, dim[0], yPlot);
			parent.popStyle();
		}
	}

	/**
	 * Draws an horizontal line
	 * 
	 * @param value
	 *            line horizontal value
	 */
	public void drawHorizontalLine(float value) {
		drawHorizontalLine(value, lineColor, lineWidth);
	}

	/**
	 * Draws a vertical line
	 * 
	 * @param value
	 *            line vertical value
	 * @param lc
	 *            line color
	 * @param lw
	 *            line width
	 */
	public void drawVerticalLine(float value, int lc, float lw) {
		float xPlot = valueToXPlot(value);

		if (isValidNumber(xPlot) && xPlot >= 0 && xPlot <= dim[0]) {
			parent.pushStyle();
			parent.noFill();
			parent.stroke(lc);
			parent.strokeWeight(lw);
			parent.strokeCap(SQUARE);
			parent.line(xPlot, 0, xPlot, -dim[1]);
			parent.popStyle();
		}
	}

	/**
	 * Draws a vertical line
	 * 
	 * @param value
	 *            line vertical value
	 */
	public void drawVerticalLine(float value) {
		drawVerticalLine(value, lineColor, lineWidth);
	}

	/**
	 * Draws a filled contour connecting consecutive points in the layer and a
	 * reference value
	 * 
	 * @param contourType
	 *            the type of contours to use. It can be GPlot.VERTICAL or
	 *            GPlot.HORIZONTAL
	 * @param referenceValue
	 *            the reference value to use to close the contour
	 */
	public void drawFilledContour(int contourType, float referenceValue) {
		// Get the points that compose the shape
		GPointsArray shapePoints = null;

		if (contourType == GPlot.HORIZONTAL) {
			shapePoints = getHorizontalShape(referenceValue);
		} else if (contourType == GPlot.VERTICAL) {
			shapePoints = getVerticalShape(referenceValue);
		}

		// Draw the shape
		if (shapePoints != null && shapePoints.getNPoints() > 0) {
			parent.pushStyle();
			parent.fill(lineColor);
			parent.noStroke();

			parent.beginShape();

			for (int i = 0; i < shapePoints.getNPoints(); i++) {
				if (shapePoints.isValid(i)) {
					parent.vertex(shapePoints.getX(i), shapePoints.getY(i));
				}
			}

			parent.endShape(CLOSE);

			parent.popStyle();
		}
	}

	/**
	 * Obtains the shape points of the horizontal contour that connects
	 * consecutive layer points and a reference value
	 * 
	 * @param referenceValue
	 *            the reference value to use to close the contour
	 * 
	 * @return the shape points
	 */
	protected GPointsArray getHorizontalShape(float referenceValue) {
		// Collect the points and cuts inside the box
		int nPoints = plotPoints.getNPoints();
		GPointsArray shapePoints = new GPointsArray(2 * nPoints);
		int indexFirstPoint = -1;
		int indexLastPoint = -1;

		for (int i = 0; i < nPoints; i++) {
			if (plotPoints.isValid(i)) {
				boolean addedPoints = false;

				// Add the point if it's inside the box
				if (inside.get(i)) {
					shapePoints.add(plotPoints.getX(i), plotPoints.getY(i),
							"normal point");
					addedPoints = true;
				} else if (plotPoints.getX(i) >= 0
						&& plotPoints.getX(i) <= dim[0]) {
					// If it's outside, add the projection of the point on the
					// horizontal axes
					if (-plotPoints.getY(i) < 0) {
						shapePoints.add(plotPoints.getX(i), 0, "projection");
						addedPoints = true;
					} else {
						shapePoints.add(plotPoints.getX(i), -dim[1],
								"projection");
						addedPoints = true;
					}
				}

				// Add the box cuts if there is any
				int nextIndex = i + 1;

				while (nextIndex < nPoints - 1
						&& !plotPoints.isValid(nextIndex)) {
					nextIndex++;
				}

				if (nextIndex < nPoints && plotPoints.isValid(nextIndex)) {
					int nCuts = obtainBoxIntersections(plotPoints.get(i),
							plotPoints.get(nextIndex));

					for (int j = 0; j < nCuts; j++) {
						shapePoints.add(cuts[j][0], cuts[j][1], "cut");
						addedPoints = true;
					}
				}

				if (addedPoints) {
					if (indexFirstPoint < 0) {
						indexFirstPoint = i;
					}

					indexLastPoint = i;
				}
			}
		}

		// Continue if there are points in the shape
		if (shapePoints.getNPoints() > 0) {
			// Calculate the starting point
			GPoint startPoint = new GPoint(shapePoints.get(0));

			if (startPoint.getX() != 0 && startPoint.getX() != dim[0]) {
				if (startPoint.getLabel().equals("cut")) {
					if (plotPoints.getX(indexFirstPoint) < 0) {
						startPoint.setX(0);
						startPoint.setLabel("extreme");
					} else {
						startPoint.setX(dim[0]);
						startPoint.setLabel("extreme");
					}
				} else if (indexFirstPoint != 0) {
					// Get the previous valid point
					int prevIndex = indexFirstPoint - 1;

					while (prevIndex > 0 && !plotPoints.isValid(prevIndex)) {
						prevIndex--;
					}

					if (plotPoints.isValid(prevIndex)) {
						if (plotPoints.getX(prevIndex) < 0) {
							startPoint.setX(0);
							startPoint.setLabel("extreme");
						} else {
							startPoint.setX(dim[0]);
							startPoint.setLabel("extreme");
						}
					}
				}
			}

			// Calculate the end point
			GPoint endPoint = new GPoint(shapePoints.getLastPoint());

			if (endPoint.getX() != 0 && endPoint.getX() != dim[0]
					&& indexLastPoint != nPoints - 1) {
				int nextIndex = indexLastPoint + 1;

				while (nextIndex < nPoints - 1
						&& !plotPoints.isValid(nextIndex)) {
					nextIndex++;
				}

				if (plotPoints.isValid(nextIndex)) {
					if (plotPoints.getX(nextIndex) < 0) {
						endPoint.setX(0);
						endPoint.setLabel("extreme");
					} else {
						endPoint.setX(dim[0]);
						endPoint.setLabel("extreme");
					}
				}
			}

			// Add the end point if it's a new extreme
			if (endPoint.getLabel().equals("extreme")) {
				shapePoints.add(endPoint);
			}

			// Add the reference connections
			if (yLog && referenceValue <= 0) {
				referenceValue = Math.min(yLim[0], yLim[1]);
			}

			float[] plotReference = valueToPlot(1, referenceValue);

			if (-plotReference[1] < 0) {
				shapePoints.add(endPoint.getX(), 0);
				shapePoints.add(startPoint.getX(), 0);
			} else if (-plotReference[1] > dim[1]) {
				shapePoints.add(endPoint.getX(), -dim[1]);
				shapePoints.add(startPoint.getX(), -dim[1]);
			} else {
				shapePoints.add(endPoint.getX(), plotReference[1]);
				shapePoints.add(startPoint.getX(), plotReference[1]);
			}

			// Add the starting point if it's a new extreme
			if (startPoint.getLabel().equals("extreme")) {
				shapePoints.add(startPoint);
			}
		}

		return shapePoints;
	}

	/**
	 * Obtains the shape points of the vertical contour that connects
	 * consecutive layer points and a reference value
	 * 
	 * @param referenceValue
	 *            the reference value to use to close the contour
	 * 
	 * @return the shape points
	 */
	protected GPointsArray getVerticalShape(float referenceValue) {
		// Collect the points and cuts inside the box
		int nPoints = plotPoints.getNPoints();
		GPointsArray shapePoints = new GPointsArray(2 * nPoints);
		int indexFirstPoint = -1;
		int indexLastPoint = -1;

		for (int i = 0; i < nPoints; i++) {
			if (plotPoints.isValid(i)) {
				boolean addedPoints = false;

				// Add the point if it's inside the box
				if (inside.get(i)) {
					shapePoints.add(plotPoints.getX(i), plotPoints.getY(i),
							"normal point");
					addedPoints = true;
				} else if (-plotPoints.getY(i) >= 0
						&& -plotPoints.getY(i) <= dim[1]) {
					// If it's outside, add the projection of the point on the
					// vertical axes
					if (plotPoints.getX(i) < 0) {
						shapePoints.add(0, plotPoints.getY(i), "projection");
						addedPoints = true;
					} else {
						shapePoints.add(dim[0], plotPoints.getY(i),
								"projection");
						addedPoints = true;
					}
				}

				// Add the box cuts if there is any
				int nextIndex = i + 1;

				while (nextIndex < nPoints - 1
						&& !plotPoints.isValid(nextIndex)) {
					nextIndex++;
				}

				if (nextIndex < nPoints && plotPoints.isValid(nextIndex)) {
					int nCuts = obtainBoxIntersections(plotPoints.get(i),
							plotPoints.get(nextIndex));

					for (int j = 0; j < nCuts; j++) {
						shapePoints.add(cuts[j][0], cuts[j][1], "cut");
						addedPoints = true;
					}
				}

				if (addedPoints) {
					if (indexFirstPoint < 0) {
						indexFirstPoint = i;
					}

					indexLastPoint = i;
				}
			}
		}

		// Continue if there are points in the shape
		if (shapePoints.getNPoints() > 0) {
			// Calculate the starting point
			GPoint startPoint = new GPoint(shapePoints.get(0));

			if (startPoint.getY() != 0 && startPoint.getY() != -dim[1]) {
				if (startPoint.getLabel().equals("cut")) {
					if (-plotPoints.getY(indexFirstPoint) < 0) {
						startPoint.setY(0);
						startPoint.setLabel("extreme");
					} else {
						startPoint.setY(-dim[1]);
						startPoint.setLabel("extreme");
					}
				} else if (indexFirstPoint != 0) {
					// Get the previous valid point
					int prevIndex = indexFirstPoint - 1;

					while (prevIndex > 0 && !plotPoints.isValid(prevIndex)) {
						prevIndex--;
					}

					if (plotPoints.isValid(prevIndex)) {
						if (-plotPoints.getY(prevIndex) < 0) {
							startPoint.setY(0);
							startPoint.setLabel("extreme");
						} else {
							startPoint.setY(-dim[1]);
							startPoint.setLabel("extreme");
						}
					}
				}
			}

			// Calculate the end point
			GPoint endPoint = new GPoint(shapePoints.getLastPoint());

			if (endPoint.getY() != 0 && endPoint.getY() != -dim[1]
					&& indexLastPoint != nPoints - 1) {
				int nextIndex = indexLastPoint + 1;

				while (nextIndex < nPoints - 1
						&& !plotPoints.isValid(nextIndex)) {
					nextIndex++;
				}

				if (plotPoints.isValid(nextIndex)) {
					if (-plotPoints.getY(nextIndex) < 0) {
						endPoint.setY(0);
						endPoint.setLabel("extreme");
					} else {
						endPoint.setY(-dim[1]);
						endPoint.setLabel("extreme");
					}
				}
			}

			// Add the end point if it's a new extreme
			if (endPoint.getLabel().equals("extreme")) {
				shapePoints.add(endPoint);
			}

			// Add the reference connections
			if (xLog && referenceValue <= 0) {
				referenceValue = Math.min(xLim[0], xLim[1]);
			}

			float[] plotReference = valueToPlot(referenceValue, 1);

			if (plotReference[0] < 0) {
				shapePoints.add(0, endPoint.getY());
				shapePoints.add(0, startPoint.getY());
			} else if (plotReference[0] > dim[0]) {
				shapePoints.add(dim[0], endPoint.getY());
				shapePoints.add(dim[0], startPoint.getY());
			} else {
				shapePoints.add(plotReference[0], endPoint.getY());
				shapePoints.add(plotReference[0], startPoint.getY());
			}

			// Add the starting point if it's a new extreme
			if (startPoint.getLabel().equals("extreme")) {
				shapePoints.add(startPoint);
			}
		}

		return shapePoints;
	}

	/**
	 * Draws the label of a given point
	 * 
	 * @param point
	 *            the point
	 */
	public void drawLabel(GPoint point) {
		float xPlot = valueToXPlot(point.getX());
		float yPlot = valueToYPlot(point.getY());

		if (isValidNumber(xPlot) && isValidNumber(yPlot)) {
			float xLabelPos = xPlot + labelSeparation[0];
			float yLabelPos = yPlot - labelSeparation[1];
			float delta = fontSize / 4;

			parent.pushStyle();
			parent.rectMode(CORNER);
			parent.textMode(MODEL);
			parent.noStroke();
			parent.textFont(font);
			parent.textSize(fontSize);
			parent.textAlign(LEFT, BOTTOM);

			// Draw the background
			parent.fill(labelBgColor);
			parent.rect(xLabelPos - delta, yLabelPos - fontSize - delta,
					parent.textWidth(point.getLabel()) + 2 * delta, fontSize
							+ 2 * delta);

			// Draw the text
			parent.fill(fontColor);
			parent.text(point.getLabel(), xLabelPos, yLabelPos);
			parent.popStyle();
		}
	}

	/**
	 * Draws the label of the closest point in the layer to a given plot
	 * position
	 * 
	 * @param xPlot
	 *            x position in the plot reference system
	 * @param yPlot
	 *            y position in the plot reference system
	 */
	public void drawLabelAtPlotPos(float xPlot, float yPlot) {
		GPoint point = getPointAtPlotPos(xPlot, yPlot);

		if (point != null) {
			drawLabel(point);
		}
	}

	/**
	 * Draws the histogram
	 */
	public void drawHistogram() {
		if (hist != null) {
			hist.draw(valueToPlot(histBasePoint));
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
		if (polygonPoints.getNPoints() > 2) {
			// Remove the polygon invalid points
			GPointsArray plotPolygonPoints = valueToPlot(polygonPoints);
			plotPolygonPoints.removeInvalidPoints();

			// Create a temporal array with the points inside the plotting area
			// and the valid box cuts
			int nPoints = plotPolygonPoints.getNPoints();
			GPointsArray tmp = new GPointsArray(2 * nPoints);

			for (int i = 0; i < nPoints; i++) {
				if (isInside(plotPolygonPoints.get(i))) {
					tmp.add(plotPolygonPoints.getX(i),
							plotPolygonPoints.getY(i), "normal point");
				}

				// Obtain the cuts with the next point
				int nextIndex = (i + 1 < nPoints) ? i + 1 : 0;
				int nCuts = obtainBoxIntersections(plotPolygonPoints.get(i),
						plotPolygonPoints.get(nextIndex));

				if (nCuts == 1) {
					tmp.add(cuts[0][0], cuts[0][1], "single cut");
				} else if (nCuts > 1) {
					tmp.add(cuts[0][0], cuts[0][1], "double cut");
					tmp.add(cuts[1][0], cuts[1][1], "double cut");
				}
			}

			// Final version of the polygon
			nPoints = tmp.getNPoints();
			GPointsArray croppedPoly = new GPointsArray(2 * nPoints);

			for (int i = 0; i < nPoints; i++) {
				// Add the point
				croppedPoly.add(tmp.get(i));

				// Add new points in case we have two consecutive cuts, one of
				// them is single, and they are in consecutive axes
				int next = (i + 1 < nPoints) ? i + 1 : 0;
				String label = tmp.getLabel(i);
				String nextLabel = tmp.getLabel(next);

				boolean cond = (label.equals("single cut") && nextLabel
						.equals("single cut"))
						|| (label.equals("single cut") && nextLabel
								.equals("double cut"))
						|| (label.equals("double cut") && nextLabel
								.equals("single cut"));

				if (cond) {
					float x1 = tmp.getX(i);
					float y1 = tmp.getY(i);
					float x2 = tmp.getX(next);
					float y2 = tmp.getY(next);
					float deltaX = Math.abs(x2 - x1);
					float deltaY = Math.abs(y2 - y1);

					// Check that they come from consecutive axes
					if (deltaX > 0 && deltaY > 0 && deltaX != dim[0]
							&& deltaY != dim[1]) {
						float x = (x1 == 0 || x1 == dim[0]) ? x1 : x2;
						float y = (y1 == 0 || y1 == -dim[1]) ? y1 : y2;
						croppedPoly.add(x, y, "special cut");
					}
				}
			}

			// Draw the cropped polygon
			if (croppedPoly.getNPoints() > 2) {
				parent.pushStyle();
				parent.fill(polygonColor);
				parent.noStroke();

				parent.beginShape();

				for (int i = 0; i < croppedPoly.getNPoints(); i++) {
					parent.vertex(croppedPoly.getX(i), croppedPoly.getY(i));
				}

				parent.endShape(CLOSE);

				parent.popStyle();
			}
		}
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
	public void drawAnnotation(String text, float x, float y, int horAlign,
			int verAlign) {
		float xPlot = valueToXPlot(x);
		float yPlot = valueToYPlot(y);

		if (isValidNumber(xPlot) && isValidNumber(yPlot)
				&& isInside(xPlot, yPlot)) {
			if (horAlign != CENTER && horAlign != RIGHT && horAlign != LEFT) {
				horAlign = LEFT;
			}

			if (verAlign != CENTER && verAlign != TOP && verAlign != BOTTOM) {
				verAlign = CENTER;
			}

			parent.pushStyle();
			parent.textMode(MODEL);
			parent.textFont(font);
			parent.textSize(fontSize);
			parent.fill(fontColor);
			parent.textAlign(horAlign, verAlign);
			parent.text(text, xPlot, yPlot);
			parent.popStyle();
		}
	}

	/**
	 * Sets the layer dimensions
	 * 
	 * @param xDim
	 *            the new layer x dimension
	 * @param yDim
	 *            the new layer y dimension
	 */
	public void setDim(float xDim, float yDim) {
		if (xDim > 0 && yDim > 0) {
			dim[0] = xDim;
			dim[1] = yDim;
			updatePlotPoints();

			if (hist != null) {
				hist.setDim(xDim, yDim);
				hist.setPlotPoints(plotPoints);
			}
		}
	}

	/**
	 * Sets the layer dimensions, which should be equal to the plot box
	 * dimensions
	 * 
	 * @param newDim
	 *            the new layer dimensions
	 */
	public void setDim(float[] newDim) {
		setDim(newDim[0], newDim[1]);
	}

	/**
	 * Sets the horizontal limits
	 * 
	 * @param xMin
	 *            the minimum limit value
	 * @param xMax
	 *            the maximum limit value
	 */
	public void setXLim(float xMin, float xMax) {
		if (xMin != xMax && isValidNumber(xMin) && isValidNumber(xMax)) {
			// Make sure the new limits makes sense
			if (xLog && (xMin <= 0 || xMax <= 0)) {
				PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
			} else {
				xLim[0] = xMin;
				xLim[1] = xMax;
				updatePlotPoints();
				updateInsideList();

				if (hist != null) {
					hist.setPlotPoints(plotPoints);
				}
			}
		}
	}

	/**
	 * Sets the horizontal limits
	 * 
	 * @param newXLim
	 *            the new horizontal limits
	 */
	public void setXLim(float[] newXLim) {
		setXLim(newXLim[0], newXLim[1]);
	}

	/**
	 * Sets the vertical limits
	 * 
	 * @param yMin
	 *            the minimum limit value
	 * @param yMax
	 *            the maximum limit value
	 */
	public void setYLim(float yMin, float yMax) {
		if (yMin != yMax && isValidNumber(yMin) && isValidNumber(yMax)) {
			// Make sure the new limits makes sense
			if (yLog && (yMin <= 0 || yMax <= 0)) {
				PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
			} else {
				yLim[0] = yMin;
				yLim[1] = yMax;
				updatePlotPoints();
				updateInsideList();

				if (hist != null) {
					hist.setPlotPoints(plotPoints);
				}
			}
		}
	}

	/**
	 * Sets the vertical limits
	 * 
	 * @param newYLim
	 *            the new vertical limits
	 */
	public void setYLim(float[] newYLim) {
		setYLim(newYLim[0], newYLim[1]);
	}

	/**
	 * Sets the horizontal and vertical limits
	 * 
	 * @param xMin
	 *            the minimum horizontal limit value
	 * @param xMax
	 *            the maximum horizontal limit value
	 * @param yMin
	 *            the minimum vertical limit value
	 * @param yMax
	 *            the maximum vertical limit value
	 */
	public void setXYLim(float xMin, float xMax, float yMin, float yMax) {
		if (xMin != xMax && yMin != yMax && isValidNumber(xMin)
				&& isValidNumber(xMax) && isValidNumber(yMin)
				&& isValidNumber(yMax)) {
			// Make sure the new limits make sense
			if (xLog && (xMin <= 0 || xMax <= 0)) {
				PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
			} else {
				xLim[0] = xMin;
				xLim[1] = xMax;
			}

			if (yLog && (yMin <= 0 || yMax <= 0)) {
				PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
			} else {
				yLim[0] = yMin;
				yLim[1] = yMax;
			}

			updatePlotPoints();
			updateInsideList();

			if (hist != null) {
				hist.setPlotPoints(plotPoints);
			}
		}
	}

	/**
	 * Sets the horizontal and vertical limits
	 * 
	 * @param newXLim
	 *            the new horizontal limits
	 * @param newYLim
	 *            the new vertical limits
	 */
	public void setXYLim(float[] newXLim, float[] newYLim) {
		setXYLim(newXLim[0], newXLim[1], newYLim[0], newYLim[1]);
	}

	/**
	 * Sets the horizontal and vertical limits and the horizontal and vertical
	 * scales
	 * 
	 * @param xMin
	 *            the minimum horizontal limit value
	 * @param xMax
	 *            the maximum horizontal limit value
	 * @param yMin
	 *            the minimum vertical limit value
	 * @param yMax
	 *            the maximum vertical limit value
	 * @param newXLog
	 *            the new horizontal scale
	 * @param newYLog
	 *            the new vertical scale
	 */
	public void setLimAndLog(float xMin, float xMax, float yMin, float yMax,
			boolean newXLog, boolean newYLog) {
		if (xMin != xMax && yMin != yMax && isValidNumber(xMin)
				&& isValidNumber(xMax) && isValidNumber(yMin)
				&& isValidNumber(yMax)) {
			// Make sure the new limits make sense
			if (newXLog && (xMin <= 0 || xMax <= 0)) {
				PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
			} else {
				xLim[0] = xMin;
				yLim[1] = xMax;
				xLog = newXLog;
			}

			if (newYLog && (yMin <= 0 || yMax <= 0)) {
				PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
			} else {
				yLim[0] = yMin;
				yLim[1] = yMax;
				yLog = newYLog;
			}

			updatePlotPoints();
			updateInsideList();

			if (hist != null) {
				hist.setPlotPoints(plotPoints);
			}
		}
	}

	/**
	 * Sets the horizontal and vertical limits and the horizontal and vertical
	 * scales
	 * 
	 * @param newXLim
	 *            the new horizontal limits
	 * @param newYLim
	 *            the new vertical limits
	 * @param newXLog
	 *            the new horizontal scale
	 * @param newYLog
	 *            the new vertical scale
	 */
	public void setLimAndLog(float[] newXLim, float[] newYLim, boolean newXLog,
			boolean newYLog) {
		setLimAndLog(newXLim[0], newXLim[1], newYLim[0], newYLim[1], newXLog,
				newYLog);
	}

	/**
	 * Sets the horizontal scale
	 * 
	 * @param newXLog
	 *            the new horizontal scale
	 */
	public void setXLog(boolean newXLog) {
		if (newXLog != xLog) {
			if (newXLog && (xLim[0] <= 0 || xLim[1] <= 0)) {
				PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
				PApplet.println("Will set horizontal limits to (0.1, 10)");
				xLim[0] = 0.1f;
				xLim[1] = 10;
			}

			xLog = newXLog;
			updatePlotPoints();
			updateInsideList();

			if (hist != null) {
				hist.setPlotPoints(plotPoints);
			}
		}
	}

	/**
	 * Sets the vertical scale
	 * 
	 * @param newYLog
	 *            the new vertical scale
	 */
	public void setYLog(boolean newYLog) {
		if (newYLog != yLog) {
			if (newYLog && (yLim[0] <= 0 || yLim[1] <= 0)) {
				PApplet.println("One of the limits is negative. This is not allowed in logarithmic scale.");
				PApplet.println("Will set vertical limits to (0.1, 10)");
				yLim[0] = 0.1f;
				yLim[1] = 10;
			}

			yLog = newYLog;
			updatePlotPoints();
			updateInsideList();

			if (hist != null) {
				hist.setPlotPoints(plotPoints);
			}
		}
	}

	/**
	 * Sets the layer points
	 * 
	 * @param newPoints
	 *            the new points
	 */
	public void setPoints(GPointsArray newPoints) {
		points.set(newPoints);
		updatePlotPoints();
		updateInsideList();

		if (hist != null) {
			hist.setPlotPoints(plotPoints);
		}
	}

	/**
	 * Sets one of the layer points
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
		points.set(index, x, y, label);
		plotPoints.set(index, valueToXPlot(x), valueToYPlot(y), label);
		inside.set(index, isInside(plotPoints.get(index)));

		if (hist != null) {
			hist.setPlotPoint(index, plotPoints.get(index));
		}
	}

	/**
	 * Sets one of the layer points
	 * 
	 * @param index
	 *            the point position
	 * @param x
	 *            the point new x coordinate
	 * @param y
	 *            the point new y coordinate
	 */
	public void setPoint(int index, float x, float y) {
		setPoint(index, x, y, points.getLabel(index));
	}

	/**
	 * Sets one of the layer points
	 * 
	 * @param index
	 *            the point position
	 * @param newPoint
	 *            the new point
	 */
	public void setPoint(int index, GPoint newPoint) {
		setPoint(index, newPoint.getX(), newPoint.getY(), newPoint.getLabel());
	}

	/**
	 * Adds a new point to the layer points
	 * 
	 * @param x
	 *            the new point x coordinate
	 * @param y
	 *            the new point y coordinate
	 * @param label
	 *            the new point label
	 */
	public void addPoint(float x, float y, String label) {
		points.add(x, y, label);
		plotPoints.add(valueToXPlot(x), valueToYPlot(y), label);
		inside.add(isInside(plotPoints.getLastPoint()));

		if (hist != null) {
			hist.addPlotPoint(plotPoints.getLastPoint());
		}
	}

	/**
	 * Adds a new point to the layer points
	 * 
	 * @param x
	 *            the new point x coordinate
	 * @param y
	 *            the new point y coordinate
	 */
	public void addPoint(float x, float y) {
		addPoint(x, y, "");
	}

	/**
	 * Adds a new point to the layer points
	 * 
	 * @param newPoint
	 *            the point to add
	 */
	public void addPoint(GPoint newPoint) {
		addPoint(newPoint.getX(), newPoint.getY(), newPoint.getLabel());
	}

	/**
	 * Adds a new point to the layer points
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
		points.add(index, x, y, label);
		plotPoints.add(index, valueToXPlot(x), valueToYPlot(y), label);
		inside.add(index, isInside(plotPoints.getLastPoint()));

		if (hist != null) {
			hist.addPlotPoint(index, plotPoints.getLastPoint());
		}
	}

	/**
	 * Adds a new point to the layer points
	 * 
	 * @param index
	 *            the position to add the point
	 * @param x
	 *            the new point x coordinate
	 * @param y
	 *            the new point y coordinate
	 */
	public void addPoint(int index, float x, float y) {
		addPoint(index, x, y, "");
	}

	/**
	 * Adds a new point to the layer points
	 * 
	 * @param index
	 *            the position to add the point
	 * @param newPoint
	 *            the point to add
	 */
	public void addPoint(int index, GPoint newPoint) {
		addPoint(index, newPoint.getX(), newPoint.getY(), newPoint.getLabel());
	}

	/**
	 * Adds new points to the layer points
	 * 
	 * @param newPoints
	 *            the points to add
	 */
	public void addPoints(GPointsArray newPoints) {
		for (int i = 0; i < newPoints.getNPoints(); i++) {
			points.add(newPoints.get(i));
			plotPoints.add(valueToXPlot(newPoints.getX(i)),
					valueToYPlot(newPoints.getY(i)), newPoints.getLabel(i));
			inside.add(isInside(plotPoints.getLastPoint()));
		}

		if (hist != null) {
			hist.setPlotPoints(plotPoints);
		}
	}

	/**
	 * Removes one of the layer points
	 * 
	 * @param index
	 *            the point position
	 */
	public void removePoint(int index) {
		points.remove(index);
		plotPoints.remove(index);
		inside.remove(index);

		if (hist != null) {
			hist.removePlotPoint(index);
		}
	}

	/**
	 * Sets which points are inside the box
	 * 
	 * @param newInside
	 *            a boolean array with the information whether a point is inside
	 *            or not
	 */
	public void setInside(boolean[] newInside) {
		if (newInside.length == inside.size()) {
			for (int i = 0; i < inside.size(); i++) {
				inside.set(i, newInside[i]);
			}
		}
	}

	/**
	 * Sets the points colors
	 * 
	 * @param newPointColors
	 *            the new point colors
	 */
	public void setPointColors(int[] newPointColors) {
		if (newPointColors.length > 0) {
			pointColors = newPointColors.clone();
		}
	}

	/**
	 * Sets the points color
	 * 
	 * @param newPointColor
	 *            the new point color
	 */
	public void setPointColor(int newPointColor) {
		pointColors = new int[] { newPointColor };
	}

	/**
	 * Sets the points sizes
	 * 
	 * @param newPointSizes
	 *            the new point sizes
	 */
	public void setPointSizes(float[] newPointSizes) {
		if (newPointSizes.length > 0) {
			pointSizes = newPointSizes.clone();
		}
	}

	/**
	 * Sets the points size
	 * 
	 * @param newPointSize
	 *            the new point size
	 */
	public void setPointSize(float newPointSize) {
		pointSizes = new float[] { newPointSize };
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
	 * Sets the histogram base point
	 * 
	 * @param newHistBasePoint
	 *            the new histogram base point
	 */
	public void setHistBasePoint(GPoint newHistBasePoint) {
		histBasePoint.set(newHistBasePoint);
	}

	/**
	 * Sets the histogram type
	 * 
	 * @param histType
	 *            the new histogram type. It can be GPlot.HORIZONTAL or
	 *            GPlot.VERTICAL
	 */
	public void setHistType(int histType) {
		if (hist != null) {
			hist.setType(histType);
		}
	}

	/**
	 * Sets if the histogram is visible or not
	 * 
	 * @param visible
	 *            if true, the histogram is visible
	 */
	public void setHistVisible(boolean visible) {
		if (hist != null) {
			hist.setVisible(visible);
		}
	}

	/**
	 * Sets if the histogram labels will be drawn or not
	 * 
	 * @param drawHistLabels
	 *            if true, the histogram labels will be drawn
	 */
	public void setDrawHistLabels(boolean drawHistLabels) {
		if (hist != null) {
			hist.setDrawLabels(drawHistLabels);
		}
	}

	/**
	 * Sets the label background color
	 * 
	 * @param newLabelBgColor
	 *            the new label background color
	 */
	public void setLabelBgColor(int newLabelBgColor) {
		labelBgColor = newLabelBgColor;
	}

	/**
	 * Sets the label separation
	 * 
	 * @param newLabelSeparation
	 *            the new label separation
	 */
	public void setLabelSeparation(float[] newLabelSeparation) {
		labelSeparation[0] = newLabelSeparation[0];
		labelSeparation[1] = newLabelSeparation[1];
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
	public void setFontProperties(String newFontName, int newFontColor,
			int newFontSize) {
		if (newFontSize > 0) {
			fontName = newFontName;
			fontColor = newFontColor;
			fontSize = newFontSize;
			font = parent.createFont(fontName, fontSize);
		}
	}

	/**
	 * Sets the font properties in the layer and the histogram
	 * 
	 * @param newFontName
	 *            the new font name
	 * @param newFontColor
	 *            the new font color
	 * @param newFontSize
	 *            the new font size
	 */
	public void setAllFontProperties(String newFontName, int newFontColor,
			int newFontSize) {
		setFontProperties(newFontName, newFontColor, newFontSize);

		if (hist != null) {
			hist.setFontProperties(newFontName, newFontColor, newFontSize);
		}
	}

	/**
	 * Returns the layer id
	 * 
	 * @return the layer id
	 */
	public String getId() {
		return id;
	}

	/**
	 * Returns the layer dimensions
	 * 
	 * @return the layer dimensions
	 */
	public float[] getDim() {
		return dim.clone();
	}

	/**
	 * Returns the layer horizontal limits
	 * 
	 * @return the layer horizontal limits
	 */
	public float[] getXLim() {
		return xLim.clone();
	}

	/**
	 * Returns the layer vertical limits
	 * 
	 * @return the layer vertical limits
	 */
	public float[] getYLim() {
		return yLim.clone();
	}

	/**
	 * Returns the layer horizontal scale
	 * 
	 * @return the layer horizontal scale
	 */
	public boolean getXLog() {
		return xLog;
	}

	/**
	 * Returns the layer vertical scale
	 * 
	 * @return the layer vertical scale
	 */
	public boolean getYLog() {
		return yLog;
	}

	/**
	 * Returns a copy of the layer points
	 * 
	 * @return a copy of the layer points
	 */
	public GPointsArray getPoints() {
		return new GPointsArray(points);
	}

	/**
	 * Returns the layer points
	 * 
	 * @return the layer points
	 */
	public GPointsArray getPointsRef() {
		return points;
	}

	/**
	 * Returns the layer point colors array
	 * 
	 * @return the layer point colors array
	 */
	public int[] getPointColors() {
		return pointColors.clone();
	}

	/**
	 * Returns the layer point sizes array
	 * 
	 * @return the layer point sizes array
	 */
	public float[] getPointSizes() {
		return pointSizes.clone();
	}

	/**
	 * Returns the layer line color
	 * 
	 * @return the layer line color
	 */
	public int getLineColor() {
		return lineColor;
	}

	/**
	 * Returns the layer line width
	 * 
	 * @return the layer line width
	 */
	public float getLineWidth() {
		return lineWidth;
	}

	/**
	 * Returns the layer histogram
	 * 
	 * @return the layer histogram
	 */
	public GHistogram getHistogram() {
		return hist;
	}
}
