# INT33-C: Ensure that division and remainder operations do not result in divide-by-zero errors

This query implements the CERT-C rule INT33-C:

> Ensure that division and remainder operations do not result in divide-by-zero errors


## Description

The C Standard identifies the following condition under which division and remainder operations result in [undefined behavior (UB)](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior):

<table> <tbody> <tr> <td> UB </td> <td> Description </td> </tr> <tr> <td> <a> 45 </a> </td> <td> The value of the second operand of the <code>/</code> or <code>%</code> operator is zero (6.5.5). </td> </tr> </tbody> </table>
Ensure that division and remainder operations do not result in divide-by-zero errors.


## Division

The result of the `/` operator is the quotient from the division of the first arithmetic operand by the second arithmetic operand. Division operations are susceptible to divide-by-zero errors. Overflow can also occur during two's complement signed integer division when the dividend is equal to the minimum (most negative) value for the signed integer type and the divisor is equal to `−1.` (See [INT32-C. Ensure that operations on signed integers do not result in overflow](https://wiki.sei.cmu.edu/confluence/display/c/INT32-C.+Ensure+that+operations+on+signed+integers+do+not+result+in+overflow).)

**Noncompliant Code Example**

This noncompliant code example prevents signed integer overflow in compliance with [INT32-C. Ensure that operations on signed integers do not result in overflow](https://wiki.sei.cmu.edu/confluence/display/c/INT32-C.+Ensure+that+operations+on+signed+integers+do+not+result+in+overflow) but fails to prevent a divide-by-zero error during the division of the signed operands `s_a` and `s_b`:` `

```cpp
#include <limits.h>
 
void func(signed long s_a, signed long s_b) {
  signed long result;
  if ((s_a == LONG_MIN) && (s_b == -1)) {
    /* Handle error */
  } else {
    result = s_a / s_b;
  }
  /* ... */
}
```
**Compliant Solution**

This compliant solution tests the division operation to guarantee there is no possibility of divide-by-zero errors or signed overflow:

```cpp
#include <limits.h>
 
void func(signed long s_a, signed long s_b) {
  signed long result;
  if ((s_b == 0) || ((s_a == LONG_MIN) && (s_b == -1))) {
    /* Handle error */
  } else {
    result = s_a / s_b;
  }
  /* ... */
}
```

## Remainder

The remainder operator provides the remainder when two operands of integer type are divided.

**Noncompliant Code Example**

This noncompliant code example prevents signed integer overflow in compliance with [INT32-C. Ensure that operations on signed integers do not result in overflow](https://wiki.sei.cmu.edu/confluence/display/c/INT32-C.+Ensure+that+operations+on+signed+integers+do+not+result+in+overflow) but fails to prevent a divide-by-zero error during the remainder operation on the signed operands `s_a` and `s_b`:

```cpp
#include <limits.h>
 
void func(signed long s_a, signed long s_b) {
  signed long result;
  if ((s_a == LONG_MIN) && (s_b == -1)) {
    /* Handle error */
  } else {
    result = s_a % s_b;
  }
  /* ... */
}
```
**Compliant Solution**

This compliant solution tests the remainder operand to guarantee there is no possibility of a divide-by-zero error or an overflow error:

```cpp
#include <limits.h>
 
void func(signed long s_a, signed long s_b) {
  signed long result;
  if ((s_b == 0 ) || ((s_a == LONG_MIN) && (s_b == -1))) {
    /* Handle error */
  } else {
    result = s_a % s_b;
  }
  /* ... */
}
```

## Risk Assessment

A divide-by-zero error can result in [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination) and denial of service.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> INT33-C </td> <td> Low </td> <td> Likely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>int-division-by-zero</strong> <strong>int-modulo-by-zero</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-INT33</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.ARITH.DIVZEROLANG.ARITH.FDIVZERO</strong> </td> <td> Division by zero Float Division By Zero </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect some violations of this rule (In particular, it ensures that all operations involving division or modulo are preceded by a check ensuring that the second operand is nonzero.) </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>DIVIDE_BY_ZERO</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Cppcheck </a> </td> <td> 1.66 </td> <td> <strong>zerodivzerodivcond</strong> </td> <td> Context sensitive analysis of division by zero Not detected for division by struct member / array element / pointer data that is 0 Detected when there is unsafe division by variable before/after test if variable is zero </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C2830</strong> <strong>C++2830</strong> <strong>DF2831, DF2832, DF2833</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>DBZ.CONST</strong> <strong>DBZ.CONST.CALL</strong> <strong>DBZ.GENERAL</strong> <strong>DBZ.ITERATOR</strong> <strong>DBZ.ITERATOR.CALL</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>43 D, 127 D, 248 S, 629 S, 80 X</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-INT33-a</strong> </td> <td> Avoid division by zero </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule INT33-C </a> </td> <td> Checks for: Integer division by zeronteger division by zero, tainted division operandainted division operand, tainted modulo operandainted modulo operand. Rule fully covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2830 \[C\], 2831 \[D\], 2832 \[A\]</strong> <strong>2833 \[S\]</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2831, 2832, 2833</strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S3518</a></strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong><a>V609</a></strong> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>division_by_zero</strong> </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+INT33-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> INT32-C. Ensure that operations on signed integers do not result in overflow </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> NUM02-J. Ensure that division and remainder operations do not result in divide-by-zero errors </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Integer division errors \[diverr\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-369 </a> , Divide By Zero </td> <td> 2017-07-07: CERT: Exact </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-682 and INT33-C**

CWE-682 = Union( INT33-C, list) where list =

* Incorrect calculations that do not involve division by zero

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Seacord 2013b </a> \] </td> <td> Chapter 5, "Integer Security" </td> </tr> <tr> <td> \[ <a> Warren 2002 </a> \] </td> <td> Chapter 2, "Basics" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [INT33-C: Ensure that division and remainder operations do not result in divide-by-zero errors](https://wiki.sei.cmu.edu/confluence/display/c)
