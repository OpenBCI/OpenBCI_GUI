/**
 * Copyright notice
 *
 * This file is part of the Processing library `gwoptics'
 * http://www.gwoptics.org/processing/gwoptics_p5lib/
 *
 * Copyright (C) 2009 onwards Daniel Brown and Andreas Freise
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 2.1 as published
 * by the Free Software Foundation.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
package org.gwoptics.graphics.camera;

//import org.eclipse.tptp.trace.arm.internal.model.ArmWrapper;
//import org.gwoptics.mathutils.TrigLookup;
import org.gwoptics.mathutils.VectorUtils;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PVector;
import processing.event.MouseEvent;

/**
 * <p> Camera3D is a camera class designed to be integrated into a processing
 * sketch with minimal effort. This camera setup is specifically useful for
 * 'orbiting' around an object that is to be viewed. Rather than applying the
 * PApplet rotateX,rotateY and rotateZ, it uses matrix transformation to alter
 * the position of the camera in the world space. </p> <p> To use the camera
 * simply import the class and create a new Camera3D object. The class will
 * register itself with the parent applet for draw() calls, and internally
 * handles mouse events for rotations. </p>
 *
 * <p> <b>History</b><br/> Version 0.3.8 Added some static members to allow
 * access too the various position, lookat and up vectors of the camera.
 * <br/><br/> Version 0.3.5 Orthographic view is added to camera class, can now
 * be set using the setOthographicView and setPerpectiveView methods </p>
 *
 * @author Daniel Brown 19/6/09
 * @since 0.3.0
 */
public final class Camera3D implements PConstants {

  private PApplet _parent;
  private PVector _lookat;
  private PVector _up;
  private PVector _position;
  private float _nearLimit = 200;
  private float _farLimit = 2000;
  private float prevX;
  private float prevY;
  private PVector A = new PVector();
  private boolean _orthoView;
  private static Camera3D _cam;

  //Setters
  /**
   * Set target location for cameras view.
   */
  public void setLookat(PVector lookat) {
    _lookat = lookat;
  }

  /**
   * Set world space position of the camera.
   */
  public void setPosition(PVector position) {
    _position = position;
  }

  /**
   * Set the closet zoom possible to the look at position.
   */
  public void setNearLimit(float limit) {
    _nearLimit = limit;
  }

  /**
   * Set the farthest zoom possible to the look at position.
   */
  public void setFarLimit(float limit) {
    _farLimit = limit;
  }

  /**
   * Set the camera upwards vector
   *
   * @param up vector pointing upwards from the camera (0,-1,0) per default
   */
  public void setUpVector(PVector up) {
    _up = up;
  }

  /**
   * Gets the nearest distance the camera can get to its lookat point
   */
  public float getNearLimit() {
    return _nearLimit;
  }

  /**
   * Gets the furthest distance the camera can get to its lookat point
   */
  public float getFarLimit() {
    return _farLimit;
  }

  /**
   * Gets the position of the camera
   */
  public static PVector getPosition() {
    if (_cam == null) {
      return null;
    }
    return _cam._position.get();
  }

  /**
   * Gets the point the camera is looking at
   */
  public static PVector getLookat() {
    if (_cam == null) {
      return null;
    }
    return _cam._lookat.get();
  }

  /**
   * Gets a vector perpendicular to the eye vector pointing in the up direction.
   */
  public static PVector getUpVector() {
    if (_cam == null) {
      return null;
    }
    return _cam._up.get();
  }

  /**
   * Gets a normalised vector stating the direction the camera is facing.
   */
  public static PVector getEyeVector() {
    PVector eye = PVector.sub(_cam._lookat, _cam._position);
    eye.normalize();
    return eye;
  }

  /**
   * Returns the up cross with eye vector, to get a vector pointing to the right
   * of the camera
   */
  public static PVector getRightVector() {
    PVector up, eye, right;
    up = Camera3D.getEyeVector();
    eye = Camera3D.getUpVector();
    right = up.cross(eye);
    right.normalize();
    return right;
  }

  /**
   * Gets the position of the camera relative to the position the camera is
   * looking at.
   */
  public static PVector getRelativePosition() {
    return PVector.mult(PVector.sub(_cam._lookat, _cam._position), -1);
  }

  /**
   * Sets default values of camera position to <100,100,100> and look at
   * position to <0,0,0>.
   *
   * Throws NullPointerException on null parent object.
   */
  public Camera3D(PApplet parent) {
    if (parent == null) {
      throw new NullPointerException("Can not except null parent.");
    }

    if (_cam != null) {
      throw new RuntimeException("A camera3D object has already been created.");
    }

    _cam = this;
    _parent = parent;
    _position = new PVector(100, 100, 100);
    _lookat = new PVector(0, 0, 0);
    _up = new PVector(0, -1, 0);
    _orthoView = false;

    _parent.camera(_position.x, _position.y, _position.z, _lookat.x,
            _lookat.y, _lookat.z, _up.x, _up.y, _up.z);

    parent.registerMethod("draw",this);
    parent.registerMethod("dispose",this);
    parent.registerMethod("mouseEvent",this);
  }

  /**
   * Sets default camera properties as normal constructor but allows you to
   * disable mouse events for a static camera.
   *
   * @param parent PApplet containing camera
   * @param registerMouseEvents Boolean, set false for static camera
   */
  public Camera3D(PApplet parent, boolean registerMouseEvents) {
    this(parent);

    if (!registerMouseEvents) {
      parent.unregisterMethod("mouseEvent",this);
    }
  }

  public void dispose() {
    //Parent has been disposed of so clear all bits for camera
    PApplet.println("\nCamera disposed\n");
    _cam = null;
  }

  public void mouseEvent(processing.event.MouseEvent event) {
	  
    switch (event.getAction()) {

      case MouseEvent.DRAG:
        //Calc distance dragged 
        float dx = prevX - event.getX();
        float dy = prevY - event.getY();

        if (_parent.mouseButton == PConstants.LEFT
                && !event.isControlDown()) {
          //Rotation about the z-axis, on the graph not world axis.
          PVector relX = VectorUtils.rotateArbitaryAxis(getRelativePosition(),
                  new PVector(0, 1, 0), -dx * PConstants.PI / 100);
          _position = PVector.add(relX, _lookat);

          float dAngle = dy * PConstants.PI / 100;
          PVector r = getRelativePosition();

          //The next sections is slightly tricky, to get a better understanding
          //render the vector A in the draw routine below, this shows the axis 
          //the camera is rotated about.

          //now need to get an axis to rotate about that will allow
          //the camera to orbit over the top and bottom of lookat point
          A = new PVector(0, 0, 1);
          //now we get the angle between the z axis and the r vector projected
          //into the x-z plane only so no y comp and add 90deg
          float angle = (float) Math.atan2(r.x, r.z) + PConstants.PI / 2;
          //now rotate the axis A so it is orthogonal to r
          A = VectorUtils.rotateArbitaryAxis(A, new PVector(0, 1, 0), angle);
          //As we now have an axis that is always orthogonal to our relative
          //position going through the lookat point, we rotate the camera
          //position around it.
          PVector relY = VectorUtils.rotateArbitaryAxis(r, A, dAngle);

          //Strange things happen when the new relative position gets to 0,0,0 and flips
          //to the other side, the scene flips the z and x axis(comment out this check 
          //to see) so basically we dont want to apply any changes if the sign has changed
          if (Math.signum(r.x) == Math.signum(relY.x)
                  && Math.signum(r.z) == Math.signum(relY.z)) {
            _position = PVector.add(relY, _lookat);
          }

        }
        if (_parent.mouseButton == PConstants.RIGHT
                || (_parent.mouseButton == PConstants.LEFT && event.isControlDown())) {
          PVector newPos = PVector.add(_position, PVector.mult(getEyeVector(), dy * 20));
          PVector relPos = PVector.sub(newPos, _lookat);

          if (relPos.mag() < _nearLimit || relPos.mag() > _farLimit) {
            newPos = _position;
          }

          _position = newPos;
        }

        prevX = event.getX();
        prevY = event.getY();
        break;
      case MouseEvent.MOVE:
        //Keep track of previous mouse pos
        //so a distance dragged can be calculated
        prevX = event.getX();
        prevY = event.getY();
        break;
    }

  }

  /**
   * This methods alters the projection matrix to display scene in an
   * orthographic view.
   */
  public void setOrthographicView() {
    _orthoView = true;
  }

  /**
   * This methods alters the projection matrix to display scene in an
   * Perspective view.
   */
  public void setPerspectiveView() {
    _orthoView = false;

    float fov = (float) (PI / 3.0);  // 60 degrees
    float cameraZ = (float) ((_parent.height / 2.0) / Math.tan(fov / 2.0));
    _parent.perspective(fov, _parent.width / (float) _parent.height, (float) (cameraZ / 100.0), 20000);
  }

  public void draw() {
    if (_orthoView) {
      // scale tuned such that a switch to ortho does not change size too much
      final float orthoScale = 1 / 780f;
      PVector new_pos = new PVector(_position.x, _position.y, _position.z);
      float dist = orthoScale * PVector.sub(new_pos, _lookat).mag();

      //Ortho must be called each draw loop, as it appears to not work otherwise
      _parent.ortho(-_parent.width * dist, _parent.width * dist,
              -_parent.height * dist, _parent.height * dist, -10000f,
              10000f);

      _parent.camera(_position.x, _position.y, _position.z, _lookat.x,
              _lookat.y, _lookat.z, _up.x, _up.y, _up.z);
    } else {
      //normal perspective view needs nothing more doing than stating the 
      //camera matrix.
      _parent.camera(_position.x, _position.y, _position.z, _lookat.x,
              _lookat.y, _lookat.z, _up.x, _up.y, _up.z);
    }
  }
}
