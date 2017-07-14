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

import java.awt.image.BufferedImage;
import java.io.*;

import processing.core.*;

public class Gif extends PImage implements PConstants, Runnable {
	private PApplet parent;
	Thread runner;
	// if the animation is currently playing
	private boolean play;
	// if the animation is currently looping
	private boolean loop;
	// wether the repeat setting from the gif-file should be ignored
	private boolean ignoreRepeatSetting = false;
	// nr of repeats specified in the gif-file. 0 means repeat forever
	private int repeatSetting = 1;
	// how often this animation has repeated since last call to play()
	private int repeatCount = 0;
	// the current frame number
	private int currentFrame;
	// array containing the frames as PImages
	private PImage[] frames;
	// array containing the delay in ms of every frame
	private int[] delays;
	// last time the frame changed
	private int lastJumpTime;
	// version
	private static String version = "3.1";

	public Gif(PApplet parent, String filename) {
		// this creates a fake image so that the first time this
		// attempts to draw, something happens that's not an exception
		super(1, 1, ARGB);

		this.parent = parent;

		// create the GifDecoder
		GifDecoder gifDecoder = createDecoder(parent, filename);

		// fill up the PImage and the delay arrays
		frames = extractFrames(gifDecoder);
		delays = extractDelays(gifDecoder);

		// get the GIFs repeat count
		repeatSetting = gifDecoder.getLoopCount();

		// re-init our PImage with the new size
		super.init(frames[0].width, frames[0].height, ARGB);
		jump(0);
		parent.registerMethod("dispose", this);

		// and now, make the magic happen
		runner = new Thread(this);
		runner.start();
	}

	public void dispose() {
		// fin
		// System.out.println("disposing");
		stop();
		runner = null;
	}

	/*
	 * the thread's run method
	 */
	public void run() {
		while (Thread.currentThread() == runner) {
			try {
				Thread.sleep(5);
			} catch (InterruptedException e) {
			}

			if (play) {
				// if playing, check if we need to go to next frame

				if (parent.millis() - lastJumpTime >= delays[currentFrame]) {
					// we need to jump

					if (currentFrame == frames.length - 1) {
						// its the last frame
						if (loop) {
							jump(0); // loop is on, so rewind
						} else if (!ignoreRepeatSetting) {
							// we're not looping, but we need to respect the
							// GIF's repeat setting
							repeatCount++;
							if (repeatSetting == 0) {
								// we need to repeat forever
								jump(0);
							} else if (repeatCount == repeatSetting) {
								// stop repeating, we've reached the repeat
								// setting
								stop();
							}
						} else {
							// no loop & ignoring the repeat setting, so just
							// stop.
							stop();
						}
					} else {
						// go to the next frame
						jump(currentFrame + 1);
					}
				}
			}
		}
	}

	/*
	 * creates an input stream using processings openStream() method to read
	 * from the sketch data-directory
	 */
	private static InputStream createInputStream(PApplet parent, String filename) {
		InputStream inputStream = parent.createInput(filename);
		return inputStream;
	}

	/*
	 * in case someone wants to mess with the frames directly, they can get an
	 * array of PImages containing the animation frames. without having a
	 * gif-object with a seperate thread
	 * 
	 * it takes a filename of a file in the datafolder.
	 */
	public static PImage[] getPImages(PApplet parent, String filename) {
		GifDecoder gifDecoder = createDecoder(parent, filename);
		return extractFrames(gifDecoder);
	}

	/*
	 * probably someone wants all the frames even if he has a playback-gif...
	 */
	public PImage[] getPImages() {
		return frames;
	}

	/*
	 * creates a GifDecoder object and loads a gif file
	 */
	private static GifDecoder createDecoder(PApplet parent, String filename) {
		GifDecoder gifDecoder = new GifDecoder();
		gifDecoder.read(createInputStream(parent, filename));
		return gifDecoder;
	}

	/*
	 * creates a PImage-array of gif frames in a GifDecoder object
	 */
	private static PImage[] extractFrames(GifDecoder gifDecoder) {
		int n = gifDecoder.getFrameCount();

		PImage[] frames = new PImage[n];

		for (int i = 0; i < n; i++) {
			BufferedImage frame = gifDecoder.getFrame(i);
			frames[i] = new PImage(frame.getWidth(), frame.getHeight(), ARGB);
			System.arraycopy(frame.getRGB(0, 0, frame.getWidth(), frame
					.getHeight(), null, 0, frame.getWidth()), 0,
					frames[i].pixels, 0, frame.getWidth() * frame.getHeight());
		}
		return frames;
	}

	/*
	 * creates an int-array of frame delays in the gifDecoder object
	 */
	private static int[] extractDelays(GifDecoder gifDecoder) {
		int n = gifDecoder.getFrameCount();
		int[] delays = new int[n];
		for (int i = 0; i < n; i++) {
			delays[i] = gifDecoder.getDelay(i); // display duration of frame in
			// milliseconds
		}
		return delays;
	}

	/*
	 * Can be called to ignore the repeat-count set in the gif-file. this does
	 * not affect loop()/noLoop() settings.
	 */
	public void ignoreRepeat() {
		ignoreRepeatSetting = true;
	}

	/*
	 * returns the number of repeats that is specified in the gif-file 0 means
	 * repeat forever
	 */
	public int getRepeat() {
		return repeatSetting;
	}

	/*
	 * returns true if this GIF object is playing
	 */
	public boolean isPlaying() {
		return play;
	}

	/*
	 * returns the current frame number
	 */
	public int currentFrame() {
		return currentFrame;
	}

	/*
	 * returns true if the animation is set to loop
	 */
	public boolean isLooping() {
		return loop;
	}

	/*
	 * returns true if this animation is set to ignore the file's repeat setting
	 */
	public boolean isIgnoringRepeat() {
		return ignoreRepeatSetting;
	}
	
	/*
	 * returns the version of the library
	 */
	public static String version() {
		return version;
	}

	/*
	 * following methods mimic the behaviour of processing's movie class.
	 */

	/**
	 * Begin playing the animation, with no repeat.
	 */
	public void play() {
		play = true;
		if (!ignoreRepeatSetting) {
			repeatCount = 0;
		}
	}

	/**
	 * Begin playing the animation, with repeat.
	 */
	public void loop() {
		play = true;
		loop = true;
	}

	/**
	 * Shut off the repeating loop.
	 */
	public void noLoop() {
		loop = false;
	}

	/**
	 * Pause the animation at its current frame.
	 */
	public void pause() {
		// System.out.println("pause");
		play = false;
	}

	/**
	 * Stop the animation, and rewind.
	 */
	public void stop() {
		//System.out.println("stop");
		play = false;
		currentFrame = 0;
		repeatCount = 0;
	}

	/**
	 * Jump to a specific location (in frames). if the frame does not exist, go
	 * to last frame
	 * @param where : file location (in sketch)
	 */
	public void jump(int where) {
		if (frames.length > where) {
			currentFrame = where;

			// update the pixel-array
			loadPixels();
			System.arraycopy(frames[currentFrame].pixels, 0, pixels, 0, width
					* height);
			updatePixels();

			// set the jump time
			lastJumpTime = parent.millis();
		}
	}

}
