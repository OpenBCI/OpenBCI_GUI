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
package org.gwoptics;

//import java.applet.AppletContext;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;
//import java.net.MalformedURLException;
//import java.net.URL;

import org.gwoptics.graphics.Renderable;
import org.gwoptics.graphics.GWColour;

import processing.core.PApplet;
import processing.core.PImage;

/**
 * Renders a clickabled image of the gwOptics logo. Use this in your application
 * if any part of the library is used to provide a link back to our website.
 *
 * @author Daniel Brown 24/6/09
 * @since 0.3.2
 *
 */
public class Logo extends Renderable {

  private boolean _clickable;
  private PImage _logo;
  private PImage _logoMouseOver;
  private boolean _isMouseOverLogo;
  private PApplet _parent;

  public Logo(PApplet parent, float x, float y, boolean clickable) {
    this(parent, x, y, clickable, LogoSize.Size35);
  }

  public Logo(PApplet parent, float x, float y, boolean clickable, LogoSize size) {
    super(parent);
    position.x = x;
    position.y = y;
    _clickable = clickable;
    _parent = parent;

    parent.registerMethod("mouseEvent",this);
    //parent.registerDraw(this);

    _logo = parent.loadImage("gwoptics_org_logo_" + size.getSize() + "px.png");
    _logoMouseOver = parent.loadImage("gwoptics_org_logo_shadow_" + size.getSize() + "px.png");
  }

  public void mouseEvent(MouseEvent event) {
    if (_isMouseOver()) {
      _isMouseOverLogo = true;
    } else {
      _isMouseOverLogo = false;
    }

    if (event.getID() == MouseEvent.MOUSE_CLICKED && _isMouseOverLogo && _clickable) {
      _parent.link("http://www.gwoptics.org");
      /*
       * try { AppletContext a = _parent.getAppletContext(); URL url = new
       * URL("http://www.gwoptics.org"); if ( a != null ) {
       * a.showDocument(url,"_self"); } } catch (Exception e){
       * PApplet.print(e.getMessage()); }
       */
    }
  }

  @Override
  public void draw() {
    if (_isMouseOverLogo) {
      _parent.image(_logoMouseOver, position.x, position.y);
    } else {
      _parent.image(_logo, position.x, position.y);
    }
  }

  public void clearBackground(int borderSize, GWColour bgColor) {
    //_parent.pushMatrix();
    _parent.pushStyle();
    _parent.noStroke();
    _parent.fill(bgColor.toInt());
    _parent.rect((int) position.x - borderSize, (int) position.y - borderSize, _logo.width + 2 * borderSize, _logo.height + 2 * borderSize);
    _parent.popStyle();
    //_parent.popMatrix();
  }

  private boolean _isMouseOver() {
    Rectangle r = new Rectangle((int) position.x, (int) position.y, _logo.width, _logo.height);

    if (r.contains(_parent.mouseX, _parent.mouseY)) {
      return true;
    } else {
      return false;
    }
  }
}
