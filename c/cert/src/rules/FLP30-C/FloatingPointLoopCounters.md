# FLP30-C: Do not use floating-point variables as loop counters

This query implements the CERT-C rule FLP30-C:

> Do not use floating-point variables as loop counters


## Description

Because floating-point numbers represent real numbers, it is often mistakenly assumed that they can represent any simple fraction exactly. Floating-point numbers are subject to representational limitations just as integers are, and binary floating-point numbers cannot represent all real numbers exactly, even if they can be represented in a small number of decimal digits.

In addition, because floating-point numbers can represent large values, it is often mistakenly assumed that they can represent all significant digits of those values. To gain a large dynamic range, floating-point numbers maintain a fixed number of precision bits (also called the significand) and an exponent, which limit the number of significant digits they can represent.

Different implementations have different precision limitations, and to keep code portable, floating-point variables must not be used as the loop induction variable. See Goldberg's work for an introduction to this topic \[[Goldberg 1991](https://www.securecoding.cert.org/confluence/display/java/Rule+AA.+References#RuleAA.References-Goldberg91)\].

For the purpose of this rule, a *loop counter* is an induction variable that is used as an operand of a comparison expression that is used as the controlling expression of a `do`, `while`, or `for` loop. An *induction variable* is a variable that gets increased or decreased by a fixed amount on every iteration of a loop \[[Aho 1986](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Aho1986)\]. Furthermore, the change to the variable must occur directly in the loop body (rather than inside a function executed within the loop).

## Noncompliant Code Example

In this noncompliant code example, a floating-point variable is used as a loop counter. The decimal number `0.1` is a repeating fraction in binary and cannot be exactly represented as a binary floating-point number. Depending on the implementation, the loop may iterate 9 or 10 times.

```cpp
void func(void) {
  for (float x = 0.1f; x <= 1.0f; x += 0.1f) {
    /* Loop may iterate 9 or 10 times */
  }
}
```
For example, when compiled with GCC or Microsoft Visual Studio 2013 and executed on an x86 processor, the loop is evaluated only nine times.

## Compliant Solution

In this compliant solution, the loop counter is an integer from which the floating-point value is derived:

```cpp
#include <stddef.h>
 
void func(void) {
  for (size_t count = 1; count <= 10; ++count) {
    float x = count / 10.0f;
    /* Loop iterates exactly 10 times */
  }
}
```

## Noncompliant Code Example

In this noncompliant code example, a floating-point loop counter is incremented by an amount that is too small to change its value given its precision:

```cpp
void func(void) {
  for (float x = 100000001.0f; x <= 100000010.0f; x += 1.0f) {
    /* Loop may not terminate */
  }
}
```
On many implementations, this produces an infinite loop.

## Compliant Solution

In this compliant solution, the loop counter is an integer from which the floating-point value is derived. The variable `x` is assigned a computed value to reduce compounded rounding errors that are present in the noncompliant code example.

```cpp
void func(void) {
  for (size_t count = 1; count <= 10; ++count) {
    float x = 100000000.0f + (count * 1.0f);
    /* Loop iterates exactly 10 times */
  }
}
```

## Risk Assessment

The use of floating-point variables as loop counters can result in [unexpected behavior ](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FLP30-C </td> <td> Low </td> <td> Probable </td> <td> Low </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>for-loop-float</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-FLP30</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>cert-flp30-c</code> </td> <td> Checked by <code>clang-tidy</code> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.STRUCT.LOOP.FPC</strong> </td> <td> Float-typed loop counter </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2004 Rule 13.4</strong> <strong><strong>MISRA C 2012 Rule 14.1</strong></strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.FLP30</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C3339, C3340, C3342</strong> <strong>C++4234</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.FOR.COUNTER.FLT</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>39 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-FLP30-a</strong> </td> <td> Do not use floating point variables as loop counters </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>9009</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule FLP30-C </a> </td> <td> Checks for use of float variable as loop counter (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>3339, 3340, 3342</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4234 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong><a>V1034</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>for-loop-float</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S2193</a></strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>non-terminating</strong> </td> <td> Exhaustively detects non-terminating statements (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FLP30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> FLP30-CPP. Do not use floating-point variables as loop counters </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> NUM09-J. Do not use floating-point variables as loop counters </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Floating-Point Arithmetic \[PLF\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Directive 1.1 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 14.1 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Aho 1986 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Goldberg 1991 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Lockheed Martin 05 </a> \] </td> <td> AV Rule 197 </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [FLP30-C: Do not use floating-point variables as loop counters](https://wiki.sei.cmu.edu/confluence/display/c)
