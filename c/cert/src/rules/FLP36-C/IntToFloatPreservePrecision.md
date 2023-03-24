# FLP36-C: Preserve precision when converting integral values to floating-point type

This query implements the CERT-C rule FLP36-C:

> Preserve precision when converting integral values to floating-point type


## Description

Narrower arithmetic types can be cast to wider types without any effect on the magnitude of numeric values. However, whereas integer types represent exact values, floating-point types have limited precision. The C Standard, 6.3.1.4 paragraph 2 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> When a value of integer type is converted to a real floating type, if the value being converted can be represented exactly in the new type, it is unchanged. If the value being converted is in the range of values that can be represented but cannot be represented exactly, the result is either the nearest higher or nearest lower representable value, chosen in an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) manner. If the value being converted is outside the range of values that can be represented, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). Results of some implicit conversions may be represented in greater range and precision than that required by the new type (see 6.3.1.8 and 6.8.6.4).


Conversion from integral types to floating-point types without sufficient precision can lead to loss of precision (loss of least significant bits). No runtime exception occurs despite the loss.

## Noncompliant Code Example

In this noncompliant example, a large value of type `long int` is converted to a value of type `float` without ensuring it is representable in the type:

```cpp
#include <stdio.h>

int main(void) {
  long int big = 1234567890L;
  float approx = big;
  printf("%ld\n", (big - (long int)approx));
  return 0;
}

```
For most floating-point hardware, the value closest to `1234567890` that is representable in type `float` is `1234567844`; consequently, this program prints the value `-46`.

## Compliant Solution

This compliant solution replaces the type `float` with a `double`. Furthermore, it uses an assertion to guarantee that the `double` type can represent any `long int` without loss of precision. (See [INT35-C. Use correct integer precisions](https://wiki.sei.cmu.edu/confluence/display/c/INT35-C.+Use+correct+integer+precisions) and [MSC11-C. Incorporate diagnostic tests using assertions](https://wiki.sei.cmu.edu/confluence/display/c/MSC11-C.+Incorporate+diagnostic+tests+using+assertions).)

```cpp
#include <assert.h>
#include <float.h>
#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>

extern size_t popcount(uintmax_t); /* See INT35-C */
#define PRECISION(umax_value) popcount(umax_value) 

int main(void) {
  assert(PRECISION(LONG_MAX) <= DBL_MANT_DIG * log2(FLT_RADIX));
  long int big = 1234567890L;
  double approx = big;
  printf("%ld\n", (big - (long int)approx));
  return 0;
}

```
On the same implementation, this program prints `0`, implying that the integer value `1234567890` is representable in type `double` without change.

## Risk Assessment

Conversion from integral types to floating-point types without sufficient precision can lead to loss of precision (loss of least significant bits).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FLP36-C </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported: Astrée keeps track of all floating point rounding errors and loss of precision and reports code defects resulting from those. </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.TYPE.IAT</strong> </td> <td> Inappropriate Assignment Type </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2004 Rule 10.x (needs investigation)</strong> </td> <td> Needs investigation </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C1260, C1263, C1298, C1299, C1800, C1802, C1803, C1804, C4117, C4435, C4437, C4445</strong> <strong>C++3011</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>PORTING.CAST.FLTPNT</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>435 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-FLP36-a</strong> <strong>CERT_C-FLP36-b</strong> </td> <td> Implicit conversions from integral to floating type which may result in a loss of information shall not be used Implicit conversions from integral constant to floating type which may result in a loss of information shall not be used </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>915, 922</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT-C: Rule FLP36-C </a> </td> <td> Checks for precision loss in integer to float conversion (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>1260, 1263, 1298, 1299, 1800, </strong> <strong>1802, </strong> <strong>1803, 1804, 4117, 4435, </strong> <strong>4437, 4445</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3011</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong><a>V674</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FLP36-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> DCL03-C. Use a static assertion to test the value of a constant expression </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> NUM13-J. Avoid loss of precision when converting primitive integers to floating-point </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 6.3.1.4, "Real Floating and Integer" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [FLP36-C: Preserve precision when converting integral values to floating-point type](https://wiki.sei.cmu.edu/confluence/display/c)
