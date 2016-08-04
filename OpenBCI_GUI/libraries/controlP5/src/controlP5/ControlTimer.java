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
 * @author 		Andreas Schlegel (http://www.sojamo.de)
 * @modified	04/14/2016
 * @version		2.2.6
 *
 */

/**
 * control timer is a timer that can be used for example as a stop watch or a duration timer.
 * 
 * @example controllers/ControlP5timer
 */
public class ControlTimer {

	long millisOffset;

	int ms, s, m, h, d;

	float _mySpeed = 1;

	int current, previous;

	/**
	 * create a new control timer, a timer that counts up in time.
	 */
	public ControlTimer() {
		reset();
	}

	/**
	 * return a string representation of the current status of the timer.
	 * 
	 * @return String
	 */
	public String toString() {
		update();
		return (((h < 10) ? "0" + h : "" + h) + " : " + ((m < 10) ? "0" + m : "" + m) + " : " + ((s < 10) ? "0" + s : "" + s) // +
																																// " : "
																																// +
		// ((ms<100) ? "0" + ms: "" +ms)
		);
	}

	/**
	 * called to update the timer.
	 */
	public void update() {
		current = (int) time();
		if (current > previous + 10) {
			ms = (int) (current * _mySpeed);
			s = (int) (((current * _mySpeed) / 1000));
			m = (int) (s / 60);
			h = (int) (m / 60);
			d = (int) (h / 24);
			ms %= 1000;
			s %= 60;
			m %= 60;
			h %= 24;
			previous = current;
		}

	}

	/**
	 * get the time in milliseconds since the timer was started.
	 * 
	 * @return long
	 */
	public long time() {
		return (System.currentTimeMillis() - millisOffset);
	}

	/**
	 * reset the timer.
	 */
	public void reset() {
		millisOffset = System.currentTimeMillis();
		current = previous = 0;
		s = 0; // Values from 0 - 59
		m = 0; // Values from 0 - 59
		h = 0; // Values from 0 - 23
		update();
	}

	/**
	 * set the speed of time, for slow motion or high speed.
	 * 
	 * @param theSpeed int
	 */
	public void setSpeedOfTime(float theSpeed) {
		_mySpeed = theSpeed;
		update();
	}

	/**
	 * Get the milliseconds of the timer.
	 */
	public int millis() {
		return ms;
	}

	/**
	 * Seconds position of the timer.
	 */
	public int second() {
		return s;
	}

	/**
	 * Minutes position of the timer.
	 */
	public int minute() {
		return m;
	}

	/**
	 * Hour position of the timer in international format (0-23).
	 */
	public int hour() {
		return h;
	}

	/**
	 * day position of the timer.
	 */
	public int day() {
		return d;
	}

}
