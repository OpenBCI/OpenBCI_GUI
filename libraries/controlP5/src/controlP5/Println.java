
package controlP5;

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
