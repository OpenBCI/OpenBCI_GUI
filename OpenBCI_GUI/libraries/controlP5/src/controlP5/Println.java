
package controlP5;

/**
 * controlP5 is a processing gui library.
 * 
 * 2006-2015 by Andreas Schlegel
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 * 
 * @author Andreas Schlegel (http://www.sojamo.de)
 * @modified 04/14/2016
 * @version 2.2.6
 * 
 */

import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintStream;

public class Println {

	int max = -1;

	final Textarea c;

	String buffer = "";

	boolean paused;


	public Println(Textarea theTextarea) {
		c = theTextarea;
		run();
	}


	public Println setMax(int theMax) {
		max = theMax;
		return this;
	}


	private void run() {
		try {
			final PipedInputStream pi = new PipedInputStream();
			final PipedOutputStream po = new PipedOutputStream(pi);
			System.setOut(new PrintStream(po, true));

			(new Thread() {

				public void run() {
					final byte[] buf = new byte[1024];
					try {
						while (true) {
							final int len = pi.read(buf);
							if (len == -1) {
								break;
							}
							if (!paused) {
								if (!c._myScrollbar.isMousePressed) {
									c.append(buffer + new String(buf, 0, len), max);
									buffer = "";
									c.scroll(1);
								}
								else {
									buffer += new String(buf, 0, len);
								}
							}
						}
					} catch (IOException e) {
					}
				}
			}).start();
		} catch (IOException e) {
			System.out.println("Problems setting up console");
		}
	}


	public void clear() {
		c.clear();
	}


	public void pause() {
		paused = true;
	}


	public void play() {
		paused = false;
	}

}
