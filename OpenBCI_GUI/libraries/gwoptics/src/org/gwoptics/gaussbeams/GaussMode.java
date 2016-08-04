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
package org.gwoptics.gaussbeams;

import org.gwoptics.mathutils.Complex;
import org.gwoptics.mathutils.mathUtils;

/**
 * Gaussmode is a class that provides the mathematical framework for Gaussian
 * beams. Gaussmode objects store the beam parameter, the laser wavelength and
 * the local index of refraction, which fully decribes a Gaussian beam. The
 * class provides a set of utility functions to transform Gaussian beam
 * parameters or to compute properties of the beam (beam size, amplitue
 * patterns, etc.)
 *
 * @author Andreas Freise 05/6/2009
 * @since 0.1.1
 */
public class GaussMode {

  double _lambda; // vacuum wavelength of the laser light
  double _nr;     // index of refraction of local medium
	/*
   * for Hermite-Gauss modes the beam parameter in x and y directions can be
   * different
   */
  public Complex _qx; // Gaussian beam parameter in x direction (tangential plane) 
  public Complex _qy; // Gaussian beam parameter in y direction (sagittal plane) 

  /**
   * Default constructor which sets dummy parameters for the Gaussian beam:
   *
   * lambda = 1064nm, wavelength of a Nd:YAG laser nr = 1, index of refraction
   * of vacuum (or air) beam waist of w0=1mm at z0=0
   *
   */
  public GaussMode() {
    _lambda = 1064e-9d;
    _nr = 1;
    _qx = make_q(1e-3d, 0, _lambda, _nr);
    _qy = make_q(1e-3d, 0, _lambda, _nr);
  }

  /**
   * Standard constructor that sets user defined beam parameters.
   *
   * @param lambda laser vacuum wavelength (in meters)
   * @param q Gaussian beam parameters for x- and y-direction
   * @param nr local index of refraction (typically nr=1)
   */
  public GaussMode(float lambda, Complex q, float nr) {
    assert (lambda > 0);
    assert (q.imag() > 0);
    _lambda = lambda;
    _qx = q;
    _qy = q;
    _nr = nr;
  }

  /**
   * Additional constructor that sets user defined beam parameters, now
   * optionally different for x- and y-direction.
   *
   * @param lambda vacuum wavelength of laser (in meters)
   * @param qx Gaussian beam parameter in x-direction (tangential plane)
   * @param qy Gaussian beam parameter in y-direction (sagittal plane)
   * @param nr local index of refraction (typically nr=1)
   */
  public GaussMode(float lambda, Complex qx, Complex qy, float nr) {
    assert (lambda > 0);
    assert (qx.imag() > 0);
    assert (qy.imag() > 0);
    _lambda = lambda;
    _qx = qx;
    _qy = qy;
    _nr = nr;
  }

  /**
   * Additional constructor that sets the beam parameters via beam waist radius
   * and beam waist position.
   *
   * @param lambda vacuum wavelength of laser (in meters)
   * @param w0 beam waist radius (in meters)
   * @param z beam waist position (in meters)
   * @param nr local index of refraction (typically n=1)
   */
  public GaussMode(float lambda, float w0, float z, float nr) {
    assert (lambda > 0);
    assert (w0 > 0);
    _lambda = lambda;
    _nr = nr;
    _qx = make_q(w0, z, _lambda, _nr);
    _qy = _qx;
  }

  /**
   * Additional constructor that sets the beam parameters via beam waist radius
   * and beam waist position, now allowing different parameters in x- and
   * y-direction.
   *
   * @param lambda vacuum wavelength of laser (in meters)
   * @param w0x beam waist radius, x-direction (in meters)
   * @param w0y beam waist radius, y-direction (in meters)
   * @param zx beam waist position, x-direction (in meters)
   * @param zy beam waist position, y-direction (in meters)
   * @param nr local index of refraction (typically n=1)
   */
  public GaussMode(float lambda, float w0x, float zx, float w0y, float zy,
          float nr) {
    assert (lambda > 0);
    assert (w0x > 0);
    assert (w0y > 0);
    _lambda = lambda;
    _nr = nr;
    _qx = make_q(w0x, zx, _lambda, _nr);
    _qy = make_q(w0y, zy, _lambda, _nr);
  }

  /**
   * This function returns the vacuum wavelength of the laser.
   *
   * @return lambda, vacuum wavelength
   */
  public double get_lambda() {
    return _lambda;
  }

  /**
   * This function returns the local index of refraction
   *
   * @return nr, local index of refraction
   */
  public double get_nr() {
    return _nr;
  }

  /**
   * This function returns the Gaussian beam parameter q in x-direction
   * (tangential plane)
   *
   * @return qx
   */
  public Complex get_qx() {
    return _qx;
  }

  /**
   * This function returns the Gaussian beam parameter q in y-direction
   * (sagittal plane)
   *
   * @return qy
   */
  public Complex get_qy() {
    return _qy;
  }

  /**
   * This function returns the beam waist radius in x-direction (tangential
   * plane)
   *
   * @return w0 in x-direction
   */
  public double get_w0x() {
    return this.w0_size(_qx);
  }

  /**
   * This function returns the beam waist radius in y-direction (sagittal plane)
   *
   * @return w0 in y-direction
   */
  public double get_w0y() {
    return this.w0_size(_qy);
  }

  /**
   * This function returns the beam radius in x-direction (tangential plane)
   *
   * @return w in x-direction
   */
  public double get_wx() {
    return this.w_size(_qx);
  }

  /**
   * This function returns the beam radius in y-direction (sagittal plane)
   *
   * @return w in y-direction
   */
  public double get_wy() {
    return this.w_size(_qy);
  }

  /**
   * This function returns the distance to the beam waist in x-direction
   * (tangential plane)
   *
   * @return z-z0 in x-direction
   */
  public double get_zx() {
    return _qx.real();
  }

  /**
   * This function returns the distance to the beam waist in y-direction
   * (sagittal plane)
   *
   * @return z-z0 in y-direction
   */
  public double get_zy() {
    return _qy.real();
  }

  /**
   * This function returns the Rayleigh range z_r in x-direction (tangential
   * plane)
   *
   * @return zr in x-direction
   */
  public double get_zrx() {
    return _qx.imag();
  }

  /**
   * This function returns the Rayleigh range z_r in y-direction (sagittal
   * plane)
   *
   * @return zr in y-direction
   */
  public double get_zry() {
    return _qy.imag();
  }

  /**
   * This function returns the phase front radius of curvature in x-direction
   * (tangential plane)
   *
   * @return ROC in x-direction
   */
  public double get_ROCx() {
    return ROC(_qx);
  }

  /**
   * This function returns the phase front radius of curvature in y-direction
   * (sagittal plane)
   *
   * @return ROC in y-direction
   */
  public double get_ROCy() {
    return ROC(_qy);
  }

  /**
   * This function returns the Gouy phase Psi(z) in x-direction (tangential
   * plane)
   *
   * @return Psi(z) in x-direction
   */
  public double get_Gouyx() {
    return Gouy(_qx);
  }

  /**
   * This function returns the Gouy phase Psi(z) in y-direction (sagittal plane)
   *
   * @return Psi(z) in y-direction
   */
  public double get_Gouyy() {
    return Gouy(_qy);
  }

  /**
   * This function Gaussian beam parametera at the waist q0 in x-direction
   * (tangential plane)
   *
   * @return q0 in x-direction
   */
  public Complex get_q0x() {
    return q0(_qx);
  }

  /**
   * This function returns the Gaussian beam parameter at the waist q0 in
   * y-direction (sagittal plane)
   *
   * @return q0 in y-direction
   */
  public Complex get_q0y() {
    return q0(_qy);
  }

  /**
   * This function computes a Gaussian beam parameters from user defined
   * parameters for the beam waist (and wavelength, and index of refraction).
   *
   * @param w0 beam waist radius
   * @param z distance to beam waist
   * @param lambda vacuum wavelength of the laser
   * @param nr local index of refraction
   * @return Gaussian beam parameter q
   */
  public static Complex make_q(double w0, double z, double lambda, double nr) {
    Complex q = new Complex(0);
    q.setReal(z);
    q.setImag(w0 * w0 * Math.PI / lambda * nr);
    return (q);
  }

  /**
   * This function computes the beam waist radius for a given beam parameters.
   * This function takes the wavelength and index of refraction from its
   * GaussMode onject!
   *
   * @param q Gaussian beam parameter
   * @return beam waist radius w0
   */
  public Double w0_size(Complex q) {
    return (Math.sqrt(q.imag() / Math.PI) * Math.sqrt(_lambda / _nr));
  }

  /**
   * This function computes the beam waist radius for a given beam parameters.
   *
   * @param q Gaussian beam parameter
   * @param lambda vacuum wavelength
   * @param nr local index of refraction
   * @return beam waist radius w0
   */
  public static Double w0_size(Complex q, Double lambda, Double nr) {
    assert (nr > 0.0);
    assert (lambda > 0.0);
    return (Math.sqrt(q.imag() / Math.PI) * Math.sqrt(lambda / nr));
  }

  /**
   * This function computes the beam radius for a given beam parameters. This
   * function takes the wavelength and index of refraction from its GaussMode
   * onject!
   *
   * @param q Gaussian beam parameter
   * @return beam radius w
   */
  public Double w_size(Complex q) {
    assert (q.imag() > 0.0);
    return (Complex.modulus(q) / Math.sqrt(Math.PI * q.imag()) * Math.sqrt(_lambda / _nr));
  }

  /**
   * This function computes the beam radius for a given beam parameters.
   *
   * @param q Gaussian beam parameter
   * @param lambda vacuum wavelength
   * @param nr local index of refraction
   * @return beam radius w
   */
  public static Double w_size(Complex q, Double lambda, Double nr) {
    assert (nr > 0.0);
    assert (lambda > 0.0);
    assert (q.imag() > 0.0);
    return (Complex.modulus(q) / Math.sqrt(Math.PI * q.imag()) * Math.sqrt(lambda / nr));
  }

  /**
   * This function computes the phase front curvature for a given beam
   * parameters.
   *
   * @param q Gaussian beam parameter
   * @return radius of curvature ROC
   */
  public static Double ROC(Complex q) {
    return (Complex.absSquared(q) / Complex.real(q));
  }

  /**
   * This function computes the Gouy for a given beam parameters.
   *
   * @param q Gaussian beam parameter
   * @return Gouy phase Psi
   */
  public static Double Gouy(Complex q) {
    assert (q.imag() > 0);
    return (Complex.real(q) / Complex.imag(q));
  }

  /**
   * This function computes the beam parameter at the waist for a given beam
   * parameters.
   *
   * @param q Gaussian beam parameter
   * @return Gaussian beam parameter at waist q0
   */
  public static Complex q0(Complex q) {
    Complex temp_q = q;
    temp_q.setReal(0.0d);
    return (temp_q);
  }

  /**
   * This function computes the Rayleigh range for a given beam parameters.
   *
   * @param q Gaussian beam parameter
   * @return Rayleigh range zr
   */
  public static Double zr(Complex q) {
    return (q.imag());
  }

  /**
   * This function returns the complex amplitude of a Hermite-Gaussian beam
   * shape u_nm.
   *
   * @param n horizontal mode index
   * @param m vertical mode index
   * @param x position on x-xaxis (orthogonal to beam direction) in meters
   * @param y position on y-xaxis (orthogonal to beam direction) in meters
   * @return complex amplitude
   */
  public Complex u_nm(int n, int m, double x, double y) {
    Complex temp_u;
    temp_u = Complex.multiply(u_n(n, _qx, x), u_n(m, _qy, y));
    return temp_u;
  }

  /**
   * This function returns the real amplitude only of a Hermite-Gaussian beam
   * shape u_nm. This is not simply abs(u_nm) or real(u_nm) but the amplitude
   * including the characteristic sign flips.
   *
   * @param n horizontal mode index
   * @param m vertical mode index
   * @param x position on x-xaxis (orthogonal to beam direction) in meters
   * @param y position on y-xaxis (orthogonal to beam direction) in meters
   * @return bipolar real amplitude
   * @see u_nm
   */
  public double u_nm_amp(int n, int m, double x, double y) {
    double temp_u;
    temp_u = u_n_amp(n, _qx, x) * u_n_amp(m, _qy, y);
    return temp_u;
  }

  /**
   * This function returns the phase of a Hermite-Gaussian beam shape u_nm,
   * *without* the sign flips from the H polynomials!
   *
   * @param n horizontal mode index
   * @param m vertical mode index
   * @param x position on x-xaxis (orthogonal to beam direction) in meters
   * @param y position on y-xaxis (orthogonal to beam direction) in meters
   * @return phase
   * @see u_nm
   */
  public double u_nm_phs(int n, int m, double x, double y) {
    double temp_u;
    temp_u = u_n_phs(n, _qx, x) + u_n_phs(m, _qy, y);
    return temp_u;
  }

  /**
   * This function represents the one-dimensional part of u_nm_amp the amplitude
   * of a u_nm Hermite-Gauss beam pattern.
   *
   * @param n mode index
   * @param q Gaussian beam parameter
   * @param x position on axis
   * @return complex amplitude
   * @see u_nm_amp
   */
  public double u_n_amp(int n, Complex q, double x) {
    assert (n >= 0);
    assert (q.imag() > 0.0);

    Double factor;
    Double w;
    w = w_size(q, _lambda, _nr);
    Double a1 = 0.893243841738002308794364125788; // (2/pi)^1/4
    factor = a1
            / Math.sqrt(Math.pow(2, n) * mathUtils.factorial(n) * w)
            * mathUtils.hermite(n, Math.sqrt(2) * x
            / w_size(q, _lambda, _nr));
    factor *= Math.exp(-1.0 * x * x / (w * w));
    return (factor);
  }

  /**
   * This function represents the one-dimensional part of u_nm_phs the phase of
   * a u_nm Hermite-Gauss beam pattern.
   *
   * @param n mode index
   * @param q Gaussian beam parameter
   * @param x position on axis
   * @return complex amplitude
   * @see u_nm_phs
   */
  public double u_n_phs(int n, Complex q, double x) {
    assert (n >= 0);
    assert (q.imag() > 0.0);

    Double phase;
    Double ROC;
    Double Psi;
    ROC = ROC(q);
    Psi = Gouy(q);
    Double k = 2.0d * Math.PI / _lambda * _nr;
    phase = (n + 0.5) * Psi;
    phase = phase - k * Math.pow(x, 2) / (2 * ROC);
    return (phase);
  }

  /**
   * This function represents the one-dimensional part of a u_nm Hermite-Gauss
   * beam patter,
   *
   * @param n mode index
   * @param q Gaussian beam parameter
   * @param x position on axis
   * @return complex amplitude
   * @see u_nm
   */
  public Complex u_n(int n, Complex q, double x) {
    assert (n >= 0);
    assert (q.imag() > 0.0);

    Double factor;
    Complex phase, z1, z2, z3, z4;
    Double a1 = 0.893243841738002308794364125788; // (2/pi)^1/4
    Double k = 2.0d * Math.PI / _lambda * _nr;

    factor = a1
            / Math.sqrt(Math.pow(2, n) * mathUtils.factorial(n)
            * w0_size(q, _lambda, _nr))
            * mathUtils.hermite(n, Math.sqrt(2) * x
            / w_size(q, _lambda, _nr));

    z1 = Complex.sqrt(Complex.divide(q0(q), q));
    z2 = Complex.sqrt(Complex.divide(Complex.multiply(q0(q), Complex.conj(q)), Complex.multiply(Complex.conj(q0(q)), q)));
    z3 = Complex.multiply(z1, Complex.pow(z2, n, 1));
    phase = Complex.scale(-1.0 * k * x * x / 2.0, Complex.inv(q));
    factor *= Math.exp(-1.0 * phase.imag());
    z4 = Complex.scaleAndDelay(factor, phase.real(), z3);

    return (z4);
  }

  /**
   * This function returns the complex amplitude of a heical Laguerre-Gaussian
   * beam shape u_pl. This is a wrapper for u_pl which uses cylindrical
   * coordinates.
   *
   * @param p radial mode index
   * @param l azimuthal mode index
   * @param x position on x-xaxis (orthogonal to beam direction) in meters
   * @param y position on y-xaxis (orthogonal to beam direction) in meters
   * @return complex amplitude
   * @see u_pl
   */
  public Complex u_pl_xy(int p, int l, double x, double y) {
    Double r = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
    Double phi = Math.atan2(x, y);
    return u_pl(p, l, r, phi);
  }

  /**
   * This function returns the complex amplitude of a helical Laguerre-Gaussian
   * beam shape u_pl.
   *
   * @param p radial mode index
   * @param l azimuthal mode index
   * @param r radial position (orthogonal to beam direction) in meters
   * @param phi azimuthal phase (orthogonal to beam direction) in radians
   * @return complex amplitude
   */
  public Complex u_pl(int p, int l, double r, double phi) {
    int l_abs = Math.abs(l);
    //if ((l_abs < 0) || (p < l_abs))
    //	throw new RuntimeException("LG mode index error (0<|l|<p)");
    if (p < 0) {
      throw new RuntimeException("LG mode index error (p<0)");
    }
    Complex q = _qx; // for LG modes q=qx=qy
    Double k = 2.0d * Math.PI / _lambda * _nr;
    Double w = w_size(q, _lambda, _nr);
    Double sr = Math.sqrt(2) * r / w;
    Double psi = Gouy(q);
    Double q_abs = Complex.absSquared(q);
    Double expFactor = -0.5 * k * r * r;

    Double factor = Math.sqrt(2 * mathUtils.factorial(p)
            / (Math.PI * mathUtils.factorial(l_abs + p)))
            / w;
    Double Gouyphase = (2 * p + l_abs + 1) * psi;
    Double AmpPattern = Math.exp(expFactor * q.imag() / q_abs)
            * Math.pow(sr, l_abs)
            * mathUtils.laguerre(p, l_abs, sr * sr);
    Double Spiral = l * phi;
    Double Sphere = expFactor * q.real() / q_abs;
    return Complex.newAbsPhi(factor * AmpPattern, Gouyphase + Sphere + Spiral);
  }

  /**
   * This function returns the real amplitude only of a heical Laguerre-Gaussian
   * beam shape u_pl. This is a wrapper for u_pl_amp which uses cylindrical
   * coordinates.
   *
   * @param p radial mode index
   * @param l azimuthal mode index
   * @param x position on x-xaxis (orthogonal to beam direction) in meters
   * @param y position on y-xaxis (orthogonal to beam direction) in meters
   * @return bipolar real amplitude
   * @see u_pl_amp
   */
  public double u_pl_amp_xy(int p, int l, double x, double y) {
    Double r = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
    Double phi = Math.atan2(x, y);
    return u_pl_amp(p, l, r, phi);
  }

  /**
   * This function returns the real amplitude only of a helical
   * Laguerre-Gaussian beam shape u_pl. This is not simply abs(u_pl) or
   * real(u_pl) but the amplitude including the characteristic sign flips.
   *
   * @param p radial mode index
   * @param l azimuthal mode index
   * @param r radial position (orthogonal to beam direction) in meters
   * @param phi azimuthal phase (orthogonal to beam direction) in radians
   * @return bipolar real amplitude
   * @see u_pl
   */
  public double u_pl_amp(int p, int l, double r, double phi) {
    int l_abs = Math.abs(l);
    if (p < 0) {
      throw new RuntimeException("LG mode index error (p<0)");
    }
    Complex q = _qx; // for LG modes q=qx=qy
    Double k = 2.0d * Math.PI / _lambda * _nr;
    Double w = w_size(q, _lambda, _nr);
    Double sr = Math.sqrt(2) * r / w;
    Double q_abs = Complex.absSquared(q);
    Double expFactor = -0.5 * k * r * r;
    Double factor = Math.sqrt(2 * mathUtils.factorial(p)
            / (Math.PI * mathUtils.factorial(l_abs + p)))
            / w;
    Double AmpPattern = Math.exp(expFactor * q.imag() / q_abs)
            * Math.pow(sr, l_abs)
            * mathUtils.laguerre(p, l_abs, sr * sr);
    return factor * AmpPattern;
  }

  /**
   * This function returns the complex amplitude of a sinusoidal
   * Laguerre-Gaussian beam shape u_pl. This is a wrapper function for u_pl_cos
   * which uses cylindrical coordinates.
   *
   * @param p radial mode index
   * @param l azimuthal mode index
   * @param x position on x-xaxis (orthogonal to beam direction) in meters
   * @param y position on y-xaxis (orthogonal to beam direction) in meters
   * @return complex amplitude
   * @see u_pl_cos
   */
  public Complex u_lp_cos_xy(int p, int l, double x, double y) {
    Double r = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
    Double phi = Math.atan2(x, y);
    return u_pl_cos(p, l, r, phi);
  }

  /**
   * This function returns the complex amplitude of a sinusoidal
   * Laguerre-Gaussian beam shape u_pl.
   *
   * @param p radial mode index
   * @param l azimuthal mode index
   * @param r radial position (orthogonal to beam direction) in meters
   * @param phi azimuthal phase (orthogonal to beam direction) in radians
   * @return complex amplitude
   * @see u_pl
   */
  public Complex u_pl_cos(int p, int l, double r, double phi) {

    int l_abs = Math.abs(l);
    if (p < 0) {
      throw new RuntimeException("LG mode index error (p<0)");
    }
    Complex q = _qx; // for LG modes q=qx=qy
    Double k = 2.0d * Math.PI / _lambda * _nr;
    Double w = w_size(q, _lambda, _nr);
    Double sr = Math.sqrt(2) * r / w;
    Double psi = Gouy(q);
    Double q_abs = Complex.absSquared(q);
    Double expFactor = -0.5 * k * r * r;

    Double factor = Math.sqrt(2 * mathUtils.factorial(p)
            / (Math.PI * mathUtils.factorial(l_abs + p)))
            / w;
    Double Gouyphase = (2 * p + l_abs + 1) * psi;
    Double AmpPattern = Math.exp(expFactor * q.imag() / q_abs)
            * Math.pow(sr, l_abs)
            * mathUtils.laguerre(p, l_abs, sr * sr);
    Double Spiral = l * phi;
    Double Sphere = expFactor * q.real() / q_abs;
    return Complex.newAbsPhi(factor * AmpPattern * Math.cos(Spiral), Gouyphase + Sphere);
  }

  /**
   * This function returns the real amplitude only of a sinusoidal
   * Laguerre-Gaussian beam shape u_pl. This is a wrapper for u_pl_cos_amp which
   * uses cylindrical coordinates.
   *
   * @param p radial mode index
   * @param l azimuthal mode index
   * @param x position on x-xaxis (orthogonal to beam direction) in meters
   * @param y position on y-xaxis (orthogonal to beam direction) in meters
   * @return bipolar real amplitude
   * @see u_pl_cos_amp
   */
  public double u_pl_cos_amp_xy(int p, int l, double x, double y) {
    Double r = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
    Double phi = Math.atan2(x, y);
    return u_pl_cos_amp(p, l, r, phi);
  }

  /**
   * This function returns the real amplitude only of a sinusoidal
   * Laguerre-Gaussian beam shape u_pl. This is not simply abs(u_pl) or
   * real(u_pl) but the amplitude including the characteristic sign flips.
   *
   * @param p radial mode index
   * @param l azimuthal mode index
   * @param r radial position (orthogonal to beam direction) in meters
   * @param phi azimuthal phase (orthogonal to beam direction) in radians
   * @return bipolar real amplitude
   * @see u_pl_cos
   */
  public double u_pl_cos_amp(int p, int l, double r, double phi) {
    int l_abs = Math.abs(l);
    if (p < 0) {
      throw new RuntimeException("LG mode index error (p<0)");
    }
    Complex q = _qx; // for LG modes q=qx=qy
    Double k = 2.0d * Math.PI / _lambda * _nr;
    Double w = w_size(q, _lambda, _nr);
    Double sr = Math.sqrt(2) * r / w;
    Double q_abs = Complex.absSquared(q);
    Double expFactor = -0.5 * k * r * r;
    Double factor = Math.sqrt(2 * mathUtils.factorial(p)
            / (Math.PI * mathUtils.factorial(l_abs + p)))
            / w;
    Double AmpPattern = Math.exp(expFactor * q.imag() / q_abs)
            * Math.pow(sr, l_abs)
            * mathUtils.laguerre(p, l_abs, sr * sr);
    Double Spiral = l * phi;
    return factor * AmpPattern * Math.cos(Spiral);
  }
}
