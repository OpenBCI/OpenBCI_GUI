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

//Todo: create factorial LUT, test speed against logFactorial.
/**
 * Mathutils is a class that provides a set of utility functions for
 * mathematical operations.
 *
 * History 0.3.5 Added lookup tables for factorial and binomial functions, added
 * gamma function as well.
 *
 * @author Andreas Freise 05/6/2009
 * @since 0.1.1
 */
public final class mathUtils {

  /**
   * This function computes the factorial of an long integer
   *
   * @param n long integer
   * @return factorial n!
   */
  public static long factorial(long n) {
    long fac = 1;
    if (n < 0) {
      throw new RuntimeException("Underflow error in factorial");
    } else if (n > 20) {
      throw new RuntimeException("Overflow error in factorial");
    } else if (n == 0) {
      return 1;
    } else {
      for (int i = 1; i <= n; i++) {
        fac = fac * i;
      }
    }
    return fac;
  }
  private final static double[] _logFactorials = new double[]{
    0.6931471805599453, 1.791759469228055, 3.1780538303479453, 4.787491742782046,
    6.579251212010101, 8.525161361065415, 10.60460290274525, 12.80182748008147,
    15.104412573075518, 17.502307845873887, 19.98721449566189, 22.552163853123425,
    25.191221182738683, 27.899271383840894, 30.671860106080675, 33.50507345013689,
    36.39544520803305, 39.339884187199495, 42.335616460753485};

  /**
   * This function returns the logarithmic factorial log(n!). Uses lookup table
   * for
   *
   * @param n input argument
   * @return logarithmic factorial log(n!)
   */
  public static double logFactorial(int n) {
    if (n <= 1) {
      return 0.0d;
    }

    if (n <= 20) {
      return _logFactorials[n - 2];
    } else {
      double ans = 0.0;

      for (int i = 1; i <= n; i++) {
        ans += Math.log(i);
      }
      return ans;
    }
  }

//%GAMMA  Gamma function.
//%   Y = GAMMA(X) evaluates the gamma function for each element of X.
//%   X must be real.  The gamma function is defined as:
//%
//%      gamma(x) = integral from 0 to inf of t^(x-1) exp(-t) dt.
//%
//%   The gamma function interpolates the factorial function.  For
//%   integer n, gamma(n+1) = n! (n factorial) = prod(1:n).
//%
//%   Class support for input X:
//%      float: double, single
//%
//%   See also GAMMALN, GAMMAINC, PSI.
//
//%   Ref: Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 6.1.
//%   Copyright 1984-2007 The MathWorks, Inc.
//%   $Revision: 5.19.4.7 $  $Date: 2007/09/18 02:17:24 $
//
//%   This is based on a FORTRAN program by W. J. Cody,
//%   Argonne National Laboratory, NETLIB/SPECFUN, October 12, 1989.
//%
//% References: "An Overview of Software Development for Special
//%              Functions", W. J. Cody, Lecture Notes in Mathematics,
//%              506, Numerical Analysis Dundee, 1975, G. A. Watson
//%              (ed.), Springer Verlag, Berlin, 1976.
//%
//%              Computer Approximations, Hart, Et. Al., Wiley and
//%              sons, New York, 1968.
//
//%   Note: This M-file is intended to document the algorithm.
//%   If a MEX file for a particular architecture exists,
//%   it will be executed instead, but its functionality is the same.
//%#mex
//
//%{
//p = [-1.71618513886549492533811e+0; 2.47656508055759199108314e+1;
//     -3.79804256470945635097577e+2; 6.29331155312818442661052e+2;
//      8.66966202790413211295064e+2; -3.14512729688483675254357e+4;
//     -3.61444134186911729807069e+4; 6.64561438202405440627855e+4];
//q = [-3.08402300119738975254353e+1; 3.15350626979604161529144e+2;
//     -1.01515636749021914166146e+3; -3.10777167157231109440444e+3;
//      2.25381184209801510330112e+4; 4.75584627752788110767815e+3;
//     -1.34659959864969306392456e+5; -1.15132259675553483497211e+5];
//c = [-1.910444077728e-03; 8.4171387781295e-04;
//     -5.952379913043012e-04; 7.93650793500350248e-04;
//     -2.777777777777681622553e-03; 8.333333333333333331554247e-02;
//      5.7083835261e-03];
//
//   if ~isreal(x)
//      error('MATLAB:gamma:ComplexInput', 'Input argument must be real.')
//   end
//   res = zeros(size(x));
//   xn = zeros(size(x));
//%
//%  Catch negative x.
//%
//   kneg = find(x <= 0);
//   if ~isempty(kneg)
//      y = -x(kneg);
//      y1 = fix(y);
//      res(kneg) = y - y1;
//      fact = -pi ./ sin(pi*res(kneg)) .* (1 - 2*rem(y1,2));
//      x(kneg) = y + 1;
//   end
//%
//%  x is now positive.
//%  Map x in interval [0,1] to [1,2]
//%
//   k1 = find(x < 1);
//   x1 = x(k1);
//   x(k1) = x1 + 1;
//%
//%  Map x in interval [1,12] to [1,2]
//%
//   k = find(x < 12);
//   xn(k) = fix(x(k)) - 1;
//   x(k) = x(k) - xn(k);
//%
//%  Evaluate approximation for 1 < x < 2
//%
//   if ~isempty(k)
//      z = x(k) - 1;
//      xnum = 0*z;
//      xden = xnum + 1;
//      for i = 1:8
//         xnum = (xnum + p(i)) .* z;
//         xden = xden .* z + q(i);
//      end
//      res(k) = xnum ./ xden + 1;
//   end
//%
//%  Adjust result for case  0.0 < x < 1.0
//%
//   res(k1) = res(k1) ./ x1;
//%
//%  Adjust result for case  2.0 < x < 12.0
//%
//   for j = 1:max(xn(:))
//      k = find(xn);
//      res(k) = res(k) .* x(k);
//      x(k) = x(k) + 1;
//      xn(k) = xn(k) - 1;
//   end
//%
//%  Evaluate approximation for x >= 12
//%
//   k = find(x >= 12);
//   if ~isempty(k)
//      y = x(k);
//      ysq = y .* y;
//      sum = c(7);
//      for i = 1:6
//         sum = sum ./ ysq + c(i);
//      end
//      spi = 0.9189385332046727417803297;
//      sum = sum ./ y - y + spi;
//      sum = sum + (y-0.5).*log(y);
//      res(k) = exp(sum);
//   end
//%
//%  Final adjustments.
//%
//   if any(~isfinite(x))
//      k = find(isinf(x)); res(k) = Inf;
//      k = find(isnan(x)); res(k) = NaN;
//   end
//   if ~isempty(kneg)
//      res(kneg) = fact ./ res(kneg);
//   end
//%}
  static double logGamma(double x) {
    double tmp = (x - 0.5) * Math.log(x + 4.5) - (x + 4.5);
    double ser = 1.0 + 76.18009173 / (x + 0) - 86.50532033 / (x + 1)
            + 24.01409822 / (x + 2) - 1.231739516 / (x + 3)
            + 0.00120858003 / (x + 4) - 0.00000536382 / (x + 5);
    return tmp + Math.log(ser * Math.sqrt(2 * Math.PI));
  }

  /**
   * This function computes the gamme function gamma(x)
   *
   * @param x input argument (double)
   * @return gamma function gamma(x)
   */
  static double gamma(double x) {
    return Math.exp(logGamma(x));
  }
  /**
   * Lookup table for common binomial coefficients This function computes the
   * log-gamme function log(gamma(x))
   */
  private final static long[][] _binomials = new long[][]{
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 3, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 4, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 5, 10, 10, 5, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 6, 15, 20, 15, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 7, 21, 35, 35, 21, 7, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 8, 28, 56, 70, 56, 28, 8, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 9, 36, 84, 126, 126, 84, 36, 9, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 10, 45, 120, 210, 252, 210, 120, 45, 10, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 11, 55, 165, 330, 462, 462, 330, 165, 55, 11, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 12, 66, 220, 495, 792, 924, 792, 495, 220, 66, 12, 1, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 13, 78, 286, 715, 1287, 1716, 1716, 1287, 715, 286, 78, 13, 1, 0, 0, 0, 0, 0, 0, 0},
    {1, 14, 91, 364, 1001, 2002, 3003, 3432, 3003, 2002, 1001, 364, 91, 14, 1, 0, 0, 0, 0, 0, 0},
    {1, 15, 105, 455, 1365, 3003, 5005, 6435, 6435, 5005, 3003, 1365, 455, 105, 15, 1, 0, 0, 0, 0, 0},
    {1, 16, 120, 560, 1820, 4368, 8008, 11440, 12870, 11440, 8008, 4368, 1820, 560, 120, 16, 1, 0, 0, 0, 0},
    {1, 17, 136, 680, 2380, 6188, 12376, 19448, 24310, 24310, 19448, 12376, 6188, 2380, 680, 136, 17, 1, 0, 0, 0},
    {1, 18, 153, 816, 3060, 8568, 18564, 31824, 43758, 48620, 43758, 31824, 18564, 8568, 3060, 816, 153, 18, 1, 0, 0},
    {1, 19, 171, 969, 3876, 11628, 27132, 50388, 75582, 92378, 92378, 75582, 50388, 27132, 11628, 3876, 969, 171, 19, 1, 0},
    {1, 20, 190, 1140, 4845, 15504, 38760, 77520, 125970, 167960, 184756, 167960, 125970, 77520, 38760, 15504, 4845, 1140, 190, 20, 1}
  };

  /**
   * This function computes the binomial coefficient b(n,k).
   *
   * @param n input argument (integer)
   * @param k input argument (integer)
   * @return binomial coefficients b(n,k)
   */
  public static long binomial(int n, int k) {
    if (n < 0 || k < 0) {
      return 0;
    }

    if (n <= 20 || k <= 20) {
      return _binomials[n][k];
    } else {
      if (k <= n && k >= 0) {
        return Math.round(Math.exp(logFactorial(n) - logFactorial(k) - logFactorial(n - k)));
      } else {
        return Math.round(mathUtils.gamma(n + 1) / (gamma(k + 1) / gamma(n - k + 1)));
      }
    }
  }

  /**
   * This function computes the Hermite polynomial H_n(x). This is based on the
   * description in Siegman `Lasers' p.686. It uses the recursion relation:
   * H_{n+1}(x) = 2x H_n(x) - 2n H_{n-1}(x) where the first four terms are given
   * by: H_0 =1, H_1(x) = 2x, H_2(x) = 4x^2 - 2, H_3(x) = 8x^3 - 12x.
   *
   * @param n order of the polynomial (integer)
   * @param x argument (real number)
   * @return Hermite polynomial H_n(x)
   */
  public static Double hermite(int n, double x) {
    // sanity check on input
    // n must be greater than or equal to zero
    assert (n >= 0);

    switch (n) {
      case 0:
        return (1.0d);
      case 1:
        return (2.0d * x);
      case 2:
        return (4.0d * x * x - 2.0d);
      case 3:
        return (8.0d * x * x * x - 12.0d * x);
      case 4:
        return (16.0d * Math.pow(x, 4) - 48.0d * x * x + 12.0d);
      case 5:
        return (32.0d * Math.pow(x, 5) - 160.0d * x * x * x + 120.0d * x);
      case 6:
        return (64.0d * Math.pow(x, 6) - 480.0d * Math.pow(x, 4) + 720.0d
                * x * x - 120.0d);
      case 7:
        return (128.0d * Math.pow(x, 7) - 1344.0d * Math.pow(x, 5)
                + 3360.0d * x * x * x - 1680.0d * x);
      case 8:
        return (256.0d * Math.pow(x, 8) - 3584.0d * Math.pow(x, 6)
                + 13440.0d * Math.pow(x, 4) - 13440.0d * x * x + 1680.0d);
      case 9:
        return (512.0d * Math.pow(x, 9) - 9216.0d * Math.pow(x, 7)
                + 48384.0d * Math.pow(x, 5) - 80640.0d * x * x * x + 30240.0d * x);
      case 10:
        return (1024.0 * Math.pow(x, 10) - 23040.0 * Math.pow(x, 8)
                + 161280.0 * Math.pow(x, 6) - 403200.0 * Math.pow(x, 4)
                + 302400.0 * x * x - 30240.0);
      default:
        return (2 * x * hermite(n - 1, x) - 2 * (n - 1) * hermite(n - 2, x));
    }
  }

  /**
   * Function to compute the associated Laguerre Polynomial L_p^l(x).
   *
   * @param p radial mode index
   * @param l azimuthal mode index
   * @param x argument
   * @return value of polynomial
   */
  public static Double laguerre(int p, int l, double x) {
    Double L = 0.0d;

    for (int j = 0; j <= p; j++) {
      // TODO replace factorial by round(exp(logFactorial()))??
      L += mathUtils.binomial(l + p, p - j) / (double) mathUtils.factorial(j) * Math.pow(-x, j);
    }

    return L;
  }
}
