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
package org.gwoptics.mathutils;

//import com.sun.org.apache.xpath.internal.operations.Div;

/*
 * TODO: - ask a student to do a proper test of all functions, probably in a
 * dedicated processing sketch, e.g. define 6 complex numbers 0,-1,i,1-i,34.3 +
 * 0.1 i and compare the Java function results against precomputed (Matlab)
 * values (or maybe against the Apache math library). Probably use println
 * statements such as: computing sqrt: - expected: 0.3 - 4 i, result: 0.30000 -
 * 4.0000 i
 */
/**
 * Complex is a class that provides complex numbers and a number of mathematical
 * functions (dynamic and static) such as sqrt() and exp() for complex numbers.
 *
 * @author Andreas Freise 05/6/2009
 * @since 0.1.1
 */
public class Complex {

  private double _re;
  private double _im;

  // -------------------------------------------------------------------------------------------
  // Constructors
  /**
   * Standard constructor that sets the complex number to z = 0.0.
   */
  Complex() {
    _re = _im = 0.0f;
  }

  /**
   * Additional constructor that return the user defined complex number
   *
   * @param re real part
   * @param im imaginary part
   */
  public Complex(final double re, final double im) {
    _re = re;
    _im = im;
  }

  /**
   * Additional constructor that returns a purely real complex number
   *
   * @param re real part
   */
  public Complex(final double re) {
    _re = re;
    _im = 0.0d;
  }

  // -------------------------------------------------------------------------------------------
  // Methods
  /**
   * This functions sets the real and imaginary part of the complex number.
   *
   * @param re real part
   * @param im imaginary part
   */
  public void set(final double re, final double im) {
    _re = re;
    _im = im;
  }

  /**
   * This functions sets the real part of the complex number
   *
   * @param re real part
   */
  public void setReal(final double re) {
    _re = re;
  }

  /**
   * This function sets the imaginary part of the complex number.
   *
   * @param im imaginary part
   */
  public void setImag(final double im) {
    _im = im;
  }

  /**
   * This function sets the complex number via an amplitude and phase as
   * amp*exp(i phi).
   *
   * @param amp amplitude
   * @param phi phase
   */
  public void setAbsPhi(final double amp, final double phi) {
    final Complex zz = Complex.scale(amp, Complex.exp(new Complex(0, phi)));
    _re = zz._re;
    _im = zz._im;
  }

  /**
   * This function returns a new complex number set via amplitude and phase as
   * amp*exp(i phi).
   *
   * @param amp amplitude
   * @param phi phase
   * @return complex number amp*exp(i phi)
   */
  public static Complex newAbsPhi(final double amp, final double phi) {
    final Complex zz = Complex.scale(amp, Complex.exp(new Complex(0, phi)));
    return zz;
  }

  /**
   * This function add a complex number to a complex number as z=z+c.
   *
   * @param c complex number
   */
  public void add(final Complex c) {
    _re += c._re;
    _im += c._im;
  }

  /**
   * This function adds two complex numbers as z=a+b.
   *
   * @param a complex number
   * @param b complex number
   *
   * @return complex number a+b
   */
  public static Complex add(final Complex a, final Complex b) {
    final Complex zz = new Complex(0);
    zz._re = a._re + b._re;
    zz._im = a._im + b._im;
    return zz;
  }

  /**
   * This function computes the square of the complex number as (x + i y)*(x + i
   * y)
   *
   * @return
   */
  public void squared() {
    final Complex zz = new Complex(0);
    zz._re = (_re - _im) * (_re + _im);
    zz._im = 2 * _re * _im;
    _re = zz._re;
    _im = zz._im;
  }

  /**
   * This function computes the square of a complex number as (x + i y) * (x + i
   * y)
   *
   * @param c complex number
   * @return complex number c*c
   */
  public static Complex squared(Complex c) {
    final Complex zz = new Complex(0);
    zz._re = (c._re - c._im) * (c._re + c._im);
    zz._im = 2 * c._re * c._im;
    return zz;
  }

  /**
   * This function returns the absolute square of a complex number as
   * |z|^2=x^2+y^2.
   *
   * @return absolute squared |z|^2
   */
  public double absSquared() {
    return (_re * _re + _im * _im);
  }

  /**
   * This function computes the absolute square of a complex numbers as
   * |c|^2=x^2+y^2.
   *
   * @param c complex number
   * @return absolute squared |c|^2
   */
  public static double absSquared(Complex c) {
    return (c._re * c._re + c._im * c._im);
  }

  /**
   * This function computes the absolute of a complex number as
   * |z|=sqrt(x^2+y^2).
   *
   * @return absolute |c|
   */
  public double abs() {
    return Math.sqrt(_re * _re + _im * _im);
  }

  /**
   * This function computes the absolute of a complex number as
   * |c|=sqrt(x^2+y^2).
   *
   * @param c complex number
   * @return absolute |c|
   */
  public static double abs(Complex c) {
    return Math.sqrt(c._re * c._re + c._im * c._im);
  }

  /**
   * This function returns the real part of the complex number.
   *
   * @return real part
   */
  public double real() {
    return _re;
  }

  /**
   * This function returns the real part of a complex number.
   *
   * @param c complex number
   * @return real part
   */
  public static double real(Complex c) {
    return c.real();
  }

  /**
   * This function returns the imaginary part of the complex number.
   *
   * @return imaginary part
   */
  public double imag() {
    return _im;
  }

  /**
   * This function returns the imaginary part of a complex number.
   *
   * @param c complex number
   * @return imaginary part
   */
  public static double imag(Complex c) {
    return c.imag();
  }

  /**
   * This function computes the square root of the complex number
   *
   * @return square root
   */
  public Complex sqrt() {
    /*
     * TODO: find a proper reference This code is adapted from Finesse code
     * which has been derived following the example in Numerical Recipes for C
     * S. 949
     */
    Complex cnull = new Complex(0);
    Complex z1 = new Complex(0);
    double x, y, w, r;

    if ((_re == 0.0) && (_im == 0.0)) {
      return (cnull);
    } else {
      x = Math.abs(_re);
      y = Math.abs(_im);

      if (x >= y) {
        r = y / x;
        w = Math.sqrt(x)
                * Math.sqrt(0.5 * (1.0 + Math.sqrt(1.0d + r * r)));
      } else {
        r = x / y;
      }
      w = Math.sqrt(y)
              * Math.sqrt(0.5 * (r + Math.sqrt(1.0d + r * r)));
    }

    if (_re >= 0.0) {
      z1.set(w, _im / (2.0d * w));
    } else {
      double t_im = (_im >= 0) ? w : -w;
      z1.set(_im / (2.0d * t_im), t_im);
    }

    if (Complex.isNaN(z1)) {
      throw new RuntimeException("division by zero");
    }
    return (z1);
  }

  /**
   * This function returns the sqaure root of a complex number.
   *
   * @param z complex number
   * @return square root
   */
  public static Complex sqrt(Complex z) {
    // TDOO: find reference, see above
    Complex cnull = new Complex(0);
    Complex z1 = new Complex(0);
    double x, y, w, r;

    if ((z.real() == 0.0) && (z.imag() == 0.0)) {
      return (cnull);
    } else {
      x = Math.abs(z.real());
      y = Math.abs(z.imag());

      if (x >= y) {
        r = y / x;
        w = Math.sqrt(x)
                * Math.sqrt(0.5 * (1.0 + Math.sqrt(1.0d + r * r)));
      } else {
        r = x / y;
        w = Math.sqrt(y)
                * Math.sqrt(0.5 * (r + Math.sqrt(1.0d + r * r)));
      }

      if (z._re >= 0.0) {
        z1.set(w, z.imag() / (2.0d * w));
      } else {
        double t_im = (z.imag() >= 0) ? w : -w;
        z1.set(z.imag() / (2.0d * t_im), t_im);
      }
      if (Complex.isNaN(z1)) {
        throw new RuntimeException("division by zero");
      }
      return (z1);
    }
  }

  /**
   * This function computes the inverse of the complex number
   */
  public void inv() {
    double tmp_d = 1.0d / absSquared(this);
    if (Double.isNaN(tmp_d)) {
      throw new RuntimeException("division by zero");
    }
    _re = _re * tmp_d;
    _im = -1.0d * _im * tmp_d;
  }

  /**
   * This function returns the inverse of a complex number
   *
   * @param z complex number
   * @return inverse
   */
  public static Complex inv(Complex z) {
    double tmp_d;
    Complex temp_z = new Complex(0);

    tmp_d = 1.0d / absSquared(z);

    if (Double.isNaN(tmp_d)) {
      throw new RuntimeException("division by zero");
    }

    temp_z._re = z._re * tmp_d;
    temp_z._im = -1.0d * z._im * tmp_d;

    return temp_z;
  }

  /**
   * This function computes the modulus of the complex number
   *
   * @return modulus
   */
  public Double modulus() {
    // TODO: find proper reference
    double r, i, t1, t2;

    t1 = 0.0d;
    t2 = 0.0d;
    r = Math.abs(_re);
    i = Math.abs(_im);

    if (r == 0.0d) {
      t1 = i;
    } else if (i == 0.0d) {
      t1 = r;
    } else if (r > i) {
      t2 = i / r;
      t1 = r * Math.sqrt(1.0d + t2 * t2);
    } else {
      t2 = r / i;
      t1 = i * Math.sqrt(1.0d + t2 * t2);
    }

    if (Double.isNaN(t1)) {
      throw new RuntimeException("division by zero");
    }
    return (t1);
  }

  /**
   * This function returns the modulus of a complex number
   *
   * @param z complex number
   * @return modulus
   */
  public static Double modulus(Complex z) {
    double r, i, t1, t2;

    t1 = 0.0d;
    t2 = 0.0d;
    r = Math.abs(z.real());
    i = Math.abs(z.imag());

    if (r == 0.0d) {
      t1 = i;
    } else if (i == 0.0d) {
      t1 = r;
    } else if (r > i) {
      t2 = i / r;
      t1 = r * Math.sqrt(1.0d + t2 * t2);
    } else {
      t2 = r / i;
      t1 = i * Math.sqrt(1.0d + t2 * t2);
    }

    if (Double.isNaN(t1)) {
      throw new RuntimeException("division by zero");
    }
    return (t1);
  }

  /**
   * This function multiplies the complex number by a complex number.
   *
   * @param b complex number
   */
  public void multiply(Complex b) {
    Complex zz = this;
    _re = zz._re * b._re - zz._im * b._im;
    _im = zz._im * b._re + zz._re * b._im;
  }

  /**
   * This function multiplies two complex numbers a*b.
   *
   * @param a complex number
   * @param b complex number
   * @return multiplication a*b
   */
  public static Complex multiply(Complex a, Complex b) {
    Complex zz = new Complex(0);
    zz._re = a._re * b._re - a._im * b._im;
    zz._im = a._im * b._re + a._re * b._im;
    return zz;
  }

  /**
   * This function divides the complex number by a complex number.
   *
   * @param b complex number
   */
  public void divide(Complex b) {
//TODO: rewrite code from Numerical recipies, see below
    Complex z = this;
    double r, den;

    if (Math.abs(b.real()) >= Math.abs(b.imag())) {
      r = b.imag() / b.real();
      den = b.real() + r * b.imag();
      _re = (z.real() + r * z.imag()) / den;
      _im = (z.imag() - r * z.real()) / den;
    } else {
      r = b.real() / b.imag();
      den = b.imag() + r * b.real();
      _re = (r * z.real() + z.imag()) / den;
      _im = (r * z.imag() - z.real()) / den;
    }

    if (Complex.isNaN(this)) {
      throw new RuntimeException("division by zero");
    }
  }

  /**
   * This function computes the division of two complex numbers
   *
   * @param a complex number
   * @param b complex number
   *
   * @return division a/b
   */
  public static Complex divide(Complex a, Complex b) {
    // TODO: code adapted from  Numerical Recipes in C S.949, rewrite!
    Complex z = new Complex(0);
    double r, den;

    if (Math.abs(b.real()) >= Math.abs(b.imag())) {
      r = b.imag() / b.real();
      den = b.real() + r * b.imag();
      z.setReal((a.real() + r * a.imag()) / den);
      z.setImag((a.imag() - r * a.real()) / den);
    } else {
      r = b.real() / b.imag();
      den = b.imag() + r * b.real();
      z.setReal((r * a.real() + a.imag()) / den);
      z.setImag((r * a.imag() - a.real()) / den);
    }

    if (Complex.isNaN(z)) {
      throw new ArithmeticException("division by zero");
    }
    return (z);
  }

  /**
   * This function computes the complex conjugate of a complex number.
   */
  public void conj() {
    _im = -1.0d * _im;
  }

  /**
   * This function computes the complex conjugate of a complex number
   *
   * @param z complex number
   *
   * @return complex conjugate z^*
   */
  public static Complex conj(Complex z) {
    return new Complex(z.real(), -1.0d * z.imag());
  }

  /**
   * This function multiplies the complex number by a real number
   *
   * @param x multiplier (real number)
   */
  public void scale(Double x) {
    _re = _re * x;
    _im = _im * x;
  }

  /**
   * This function multiplies a complex number by a real number
   *
   * @param x multiplier (real number)
   * @param z complex number
   *
   * @return complex number x*z
   */
  public static Complex scale(Double x, Complex z) {
    return new Complex(z.real() * x, z.imag() * x);
  }

  /**
   * This function multiplies the complex number by a real number and adds a
   * phase delay as z=z*x*exp(i phi).
   *
   * @param amp multiplier (real number)
   * @param phi phase [rad]
   */
  public void scaleAndDelay(double amp, double phi) {
    Complex zz = this;
    _re = amp * (zz._re * Math.cos(phi) - zz._im * Math.sin(phi));
    _im = amp * (zz._re * Math.sin(phi) + zz._im * Math.cos(phi));
  }

  /**
   * This function multiplies a complex number by another given by amplitude and
   * phase as return = z * abs * exp (i phi).
   *
   * @param amp
   * @param phi
   * @param z
   * @return multiplication z*amp*exp(i phi)
   */
  public static Complex scaleAndDelay(double amp, double phi, Complex z) {
    Complex zz = new Complex(0);
    zz._re = amp * (z._re * Math.cos(phi) - z._im * Math.sin(phi));
    zz._im = amp * (z._re * Math.sin(phi) + z._im * Math.cos(phi));
    return zz;
  }

  /**
   * This function computes a rational power of a complex number z^(nom/denom).
   *
   * @param z complex number
   * @param nom nomiator of exponent
   * @param denom denominator of exponent
   *
   * @return rational power z^(nom/denom)
   */
  public static Complex pow(Complex z, int nom, int denom) {
    Complex z1;
    Complex c0 = new Complex(0);
    Complex c1 = new Complex(1);
    Double x;

    if (denom == 0) {
      throw new ArithmeticException("denominator is zero");
    }

    if (nom == 0) {
      return c1;
    }

    x = (double) nom / (double) denom;

    if (z.isEqual(c0)) {
      if (x > 0) {
        return (c0);
      } else {
        throw new ArithmeticException("division by zero (1)");
      }
    }

    if (nom == denom) { // nom=denom -> result=z
      return (z);
    }

    z1 = Complex.log(z);
    z1._re *= x;
    z1._im *= x;
    if (Complex.isNaN(z1)) {
      throw new ArithmeticException("pow returns NaN");
    }
    return (Complex.exp(z1));
  }

  /**
   * This function computes the logarithm of a complex number
   *
   * @param z complex number
   * @return logarithm log(z)
   */
  public static Complex log(Complex z) {
    double x;
    Complex z1 = new Complex(0);

    x = Math.sqrt(z._re * z._re + z._im * z._im);

    z1._re = Math.log(x);
    z1._im = Math.atan2(z._im, z._re);

    if (Complex.isNaN(z1)) {
      throw new ArithmeticException("log returns NaN");
    }
    return (z1);
  }

  /**
   * This function computes the exponential of a complex number exp(z).
   *
   * @param z complex number
   * @return exponential exp(z)
   */
  public static Complex exp(Complex z) {
    double x;
    Complex z1 = new Complex(0);

    x = Math.exp(z._re);
    z1._re = x * Math.cos(z._im);
    z1._im = x * Math.sin(z._im);

    if (Complex.isNaN(z1)) {
      throw new ArithmeticException("exp returns NaN");
    }
    return (z1);
  }

  /**
   * This function computes the number exp( i phi )
   *
   * @param phi phase
   * @return complex number
   */
  public static Complex expi(Double phi) {

    Complex z1 = new Complex(Math.cos(phi), Math.sin(phi));

    if (Complex.isNaN(z1)) {
      throw new ArithmeticException("expi returns NaN");
    }
    return (z1);
  }

  /**
   * This funtions tests whether the complex number is `not a number' NaN. If
   * the real or imaginary part is NaN this function returns `true'.
   *
   * @return true if NaN
   */
  public boolean isNaN() {
    boolean t1, t2;
    t1 = Double.isNaN(_re);
    t2 = Double.isNaN(_im);
    return (t1 | t2);
  }

  /**
   * This function tests whether a complex number is `not a number' NaN. If the
   * real or the imaginary part is NaN this function returns true.
   *
   * @param c complex number
   * @return true of c is NaN
   */
  public static boolean isNaN(Complex c) {
    boolean t1, t2;
    t1 = Double.isNaN(c._re);
    t2 = Double.isNaN(c._im);
    return (t1 | t2);
  }

  /**
   * This functions tests whether the Complex number is equal to another.
   *
   * @param c complex number
   * @return retruns true if number is equal to c
   */
  public boolean isEqual(Complex c) {
    boolean test = false;
    if (this.isNaN() && c.isNaN()) {
      test = true;
    } else {
      if (_re == c.real() && _im == c.imag()) {
        test = true;
      }
    }
    return test;
  }

  /**
   * This function tests whether two Complex numbers are equal.
   *
   * @param a complex number
   * @param b complex number
   * @return true if a is equal to b
   */
  public static boolean isEqual(Complex a, Complex b) {
    boolean test = false;
    if (a.isNaN() && b.isNaN()) {
      test = true;
    } else {
      if (a.real() == b.real() && a.imag() == b.imag()) {
        test = true;
      }
    }
    return test;
  }

  /**
   * This function converts a complex number into a String "x + y i" with x
   * being the real and y the imaginary part.
   *
   * @return string
   */
  public String toString() {
    char ch = '+';
    if (_im < 0.0d) {
      ch = '-';
    }
    return _re + " " + ch + " " + Math.abs(_im) + " i";
  }

  /**
   * This function converts a complex number into a String "x + y i" with x
   * being the real and y the imaginary part.
   *
   * @param z complex number
   * @return string
   */
  public static String toString(Complex z) {
    char ch = '+';
    if (z.imag() < 0.0d) {
      ch = '-';
    }
    return z.real() + " " + ch + Math.abs(z.imag()) + " i";
  }
}
