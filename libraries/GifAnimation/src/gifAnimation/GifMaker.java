/*
 * GifAnimation is a processing library to play gif animations and to 
 * extract frames from a gif file. It can also export animated GIF animations
 * This file class is under a GPL license. The Decoder used to open the
 * gif files was written by Kevin Weiner. please see the separate copyright
 * notice in the header of the GifDecoder / GifEncoder class.
 * 
 * by extrapixel 2007
 * http://extrapixel.ch
 * 
  
  	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package gifAnimation;

import java.awt.Color;
import java.awt.image.BufferedImage;
import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PImage;

public class GifMaker implements PConstants {
	public final static int DISPOSE_NOTHING = 0;
	public final static int DISPOSE_KEEP = 1;
	public final static int DISPOSE_RESTORE_BACKGROUND = 2;
	public final static int DISPOSE_REMOVE = 3;
	private GifEncoder encoder;
	private PApplet parent;

	public GifMaker(PApplet parent, String filename) {
		this.parent = parent;
		parent.registerMethod("dispose", this);
		encoder = initEncoder(filename);
	}

	public GifMaker(PApplet parent, String filename, int quality) {
		this(parent, filename);
		setQuality(quality);
	}

	public GifMaker(PApplet parent, String filename, int quality, int bgColor) {
		this(parent, filename, quality);
		setTransparent(bgColor);
	}

	/*
	 * finish stuff up when sketch is killed
	 */
	public void dispose() {
		finish();
	}

	private GifEncoder initEncoder(String filename) {
		GifEncoder returnEncoder = new GifEncoder();
		returnEncoder.start(parent.savePath(filename));
		return returnEncoder;
	}

	/*
	 * adds a delay to the last added frame int in milliseconds
	 */
	public void setDelay(int delay) {
		encoder.setDelay(delay);
	}

	/*
	 * set the disposal mode for the last added frame
	 * 
	 * from GIF specs: CODE MEANING 00 Nothing special 01 KEEP - retain the
	 * current image 02 RESTORE BACKGROUND - restore the background color 03
	 * REMOVE - remove the current image, and restore whatever image was beneath
	 * it.
	 */
	public void setDispose(int dispose) {
		encoder.setDispose(dispose);
	}

	/**
	 * description taken from GifEncoder-class: Sets quality of color
	 * quantization (conversion of images to the maximum 256 colors allowed by
	 * the GIF specification). Lower values (minimum = 1) produce better colors,
	 * but slow processing significantly. 10 is the default, and produces good
	 * color mapping at reasonable speeds. Values greater than 20 do not yield
	 * significant improvements in speed.
	 * 
	 * @param quality
	 *            int greater than 0.
	 */
	public void setQuality(int quality) {
		encoder.setQuality(quality);
	}

	/*
	 * sets the amount of times the animation should repeat
	 * 
	 */
	public void setRepeat(int repeat) {
		encoder.setRepeat(repeat);
	}

	/*
	 * sets the size of the GIF-file. if this method is not invoked, the size of
	 * the first added frame will be the image size.
	 */
	public void setSize(int width, int height) {
		encoder.setSize(width, height);
	}

	/*
	 * Sets the transparent color. Every pixel with this color will be
	 * transparent in the output File
	 */
	public void setTransparent(int color) {
		setTransparent((int) parent.red(color), (int) parent.green(color),
				(int) parent.blue(color));
	}

	public void setTransparent(float red, float green, float blue) {
		setTransparent((int) red, (int) green, (int) blue);
	}

	public void setTransparent(int red, int green, int blue) {
		encoder.setTransparent(new Color(red, green, blue));
	}

	/*
	 * adds a frame to the current animation takes a PImage, or a pixel-array.
	 * if no parameter is passed, the currently displayed pixels in the sketch
	 * window is used.
	 */
	public void addFrame() {
		parent.loadPixels();
		addFrame(parent.pixels, parent.width, parent.height);
	}

	public void addFrame(PImage newImage) {
		addFrame(newImage.pixels, newImage.width, newImage.height);
	}

	public void addFrame(int[] pixels, int width, int height) {
		BufferedImage frame = new BufferedImage(width, height,
				BufferedImage.TYPE_INT_ARGB);
		frame.setRGB(0, 0, width, height, pixels, 0, width);
		encoder.addFrame(frame);
	}

	/*
	 * finishes off the GIF-file and saves it to the given filename
	 * in the sketch directory. if the file already exists, it will
	 * be overridden!
	 */
	public boolean finish() {
		return encoder.finish();
	}

}
