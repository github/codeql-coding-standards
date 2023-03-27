# FLP34-C: Ensure that floating-point conversions are within range of the new type

This query implements the CERT-C rule FLP34-C:

> Ensure that floating-point conversions are within range of the new type


## Description

If a floating-point value is to be converted to a floating-point value of a smaller range and precision or to an integer type, or if an integer type is to be converted to a floating-point type, the value must be representable in the destination type.

The C Standard, 6.3.1.4, paragraph 1 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], says,

> When a finite value of real floating type is converted to an integer type other than `_Bool`, the fractional part is discarded (i.e., the value is truncated toward zero). If the value of the integral part cannot be represented by the integer type, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).


Paragraph 2 of the same subclause says,

> When a value of integer type is converted to a real floating type, if the value being converted can be represented exactly in the new type, it is unchanged. If the value being converted is in the range of values that can be represented but cannot be represented exactly, the result is either the nearest higher or nearest lower representable value, chosen in an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) manner. If the value being converted is outside the range of values that can be represented, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).


And subclause 6.3.1.5, paragraph 1, says,

> When a value of real floating type is converted to a real floating type, if the value being converted can be represented exactly in the new type, it is unchanged. If the value being converted is in the range of values that can be represented but cannot be represented exactly, the result is either the nearest higher or nearest lower representable value, chosen in an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) manner. If the value being converted is outside the range of values that can be represented, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).


See [undefined behaviors 17](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_17) and [18](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_18).

This rule does not apply to demotions of floating-point types on [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) that support signed infinity, such as IEEE 754, as all values are within range.

## Noncompliant Code Example (float to int)

This noncompliant code example leads to undefined behavior if the integral part of `f_a` cannot be represented as an integer:

```cpp
void func(float f_a) {
  int i_a;
 
  /* Undefined if the integral part of f_a cannot be represented. */
  i_a = f_a;
}
```

## Compliant Solution (float to int)

This compliant solution tests to ensure that the `float` value will fit within the `int` variable before performing the assignment.

```cpp
#include <float.h>
#include <limits.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>
 
extern size_t popcount(uintmax_t); /* See INT35-C */
#define PRECISION(umax_value) popcount(umax_value)
 
void func(float f_a) {
  int i_a;
 
  if (isnan(f_a) ||
      PRECISION(INT_MAX) < log2f(fabsf(f_a)) ||
      (f_a != 0.0F && fabsf(f_a) < FLT_MIN)) {
    /* Handle error */
  } else {
    i_a = f_a;
  }
}

```

## Noncompliant Code Example (Narrowing Conversion)

This noncompliant code example attempts to perform conversions that may result in truncating values outside the range of the destination types:

```cpp
void func(double d_a, long double big_d) {
  double d_b = (float)big_d;
  float f_a = (float)d_a;
  float f_b = (float)big_d;
}

```
As a result of these conversions, it is possible that `d_a` is outside the range of values that can be represented by a float or that `big_d` is outside the range of values that can be represented as either a `float` or a `double`. If this is the case, the result is undefined on implementations that do not support Annex F, "IEC 60559 Floating-Point Arithmetic."

## Compliant Solution (Narrowing Conversion)

This compliant solution checks whether the values to be stored can be represented in the new type:

```cpp
#include <float.h>
#include <math.h>
 
void func(double d_a, long double big_d) {
  double d_b;
  float f_a;
  float f_b;

  if (d_a != 0.0 &&
      (isnan(d_a) ||
       isgreater(fabs(d_a), FLT_MAX) ||
       isless(fabs(d_a), FLT_MIN))) {
    /* Handle error */
  } else {
    f_a = (float)d_a;
  }
  if (big_d != 0.0 &&
      (isnan(big_d) ||
       isgreater(fabs(big_d), FLT_MAX) ||
       isless(fabs(big_d), FLT_MIN))) {
    /* Handle error */
  } else {
    f_b = (float)big_d;
  }
  if (big_d != 0.0 &&
      (isnan(big_d) ||
       isgreater(fabs(big_d), DBL_MAX) ||
       isless(fabs(big_d), DBL_MIN))) {
    /* Handle error */
  } else {
    d_b = (double)big_d;
  }  
}

```

## Risk Assessment

Converting a floating-point value to a floating-point value of a smaller range and precision or to an integer type, or converting an integer type to a floating-point type, can result in a value that is not representable in the destination type and is undefined behavior on implementations that do not support Annex F.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FLP34-C </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported Astrée reports all potential overflows resulting from floating-point conversions. </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect some violations of this rule. However, it does not flag implicit casts, only explicit ones </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.TYPE.IAT</strong> </td> <td> Inappropriate Assignment Type </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA_CAST (needs verification)</strong> </td> <td> Can detect instances where implicit float conversion is involved: implicitly converting a complex expression with integer type to floating type, implicitly converting a double expression to narrower float type (may lose precision), implicitly converting a complex expression from <code>float</code> to <code>double</code> , implicitly converting from <code>float</code> to <code>double</code> in a function argument, and so on </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C4450, C4451, C4452, C4453, C4454, C4462, C4465</strong> <strong>C++3011</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.CAST.FLOAT.WIDER</strong> <strong>MISRA.CAST.FLOAT.INT</strong> <strong>MISRA.CAST.INT_FLOAT</strong> <strong>MISRA.CONV.FLOAT</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>435 S, 93 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-FLP34-aCERT_C-FLP34-b</strong> </td> <td> Avoid implicit conversions from wider to narrower floating type Avoid implicit conversions of floating point numbers from wider to narrower floating type </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>735, 736,915, 922,9118, 9227</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule FLP34-C </a> </td> <td> Checks for float conversion overflow (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>4450, 4451, 4452, 4453,4454, </strong> <strong>4462, </strong> <strong>4465</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3011 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong>V615<a></a></strong> , <strong>V2003<a></a></strong> , <strong><a>V2004</a></strong> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>float_to_int</strong> </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FLP34-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> NUM12-J. Ensure conversions of numeric types to narrower types do not result in lost or misinterpreted data </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Numeric Conversion Errors \[FLC\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-681 </a> , Incorrect Conversion between Numeric Types </td> <td> 2017-06-29: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-197 </a> </td> <td> 2017-06-14: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-197 and FLP34-C**

Independent( FLP34-C, INT31-C) FIO34-C = Subset( INT31-C)

CWE-197 = Union( FLP34-C, INT31-C)

**CWE-195 and FLP34-C**

Intersection( CWE-195, FLP34-C) = Ø

Both conditions involve type conversion. However, CWE-195 explicitly focuses on conversions between unsigned vs signed types, whereas FLP34-C focuses on floating-point arithmetic.

**CWE-681 and FLP34-C**

CWE-681 = Union( FLP34-C, INT31-C)

## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE 754 2006 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 6.3.1.4, "Real Floating and Integer" Subclause 6.3.1.5, "Real Floating Types" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [FLP34-C: Ensure that floating-point conversions are within range of the new type](https://wiki.sei.cmu.edu/confluence/display/c)
