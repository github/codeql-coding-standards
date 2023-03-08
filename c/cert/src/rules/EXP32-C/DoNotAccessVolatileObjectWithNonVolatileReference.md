# EXP32-C: Do not access a volatile object through a nonvolatile reference

This query implements the CERT-C rule EXP32-C:

> Do not access a volatile object through a nonvolatile reference


## Description

An object that has volatile-qualified type may be modified in ways unknown to the [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) or have other unknown [side effects](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-sideeffect). Referencing a volatile object by using a non-volatile lvalue is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). The C Standard, 6.7.3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> If an attempt is made to refer to an object defined with a volatile-qualified type through use of an lvalue with non-volatile-qualified type, the behavior is undefined.


See [undefined behavior 65](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_65).

## Noncompliant Code Example

In this noncompliant code example, a volatile object is accessed through a non-volatile-qualified reference, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior):

```cpp
#include <stdio.h>
 
void func(void) {
  static volatile int **ipp;
  static int *ip;
  static volatile int i = 0;

  printf("i = %d.\n", i);

  ipp = &ip; /* May produce a warning diagnostic */
  ipp = (int**) &ip; /* Constraint violation; may produce a warning diagnostic */
  *ipp = &i; /* Valid */
  if (*ip != 0) { /* Valid */
    /* ... */
  }
}
```
The assignment `ipp = &ip` is not safe because it allows the valid code that follows to reference the value of the volatile object `i` through the non-volatile-qualified reference `ip`. In this example, the compiler may optimize out the entire `if` block because `*ip != 0` must be false if the object to which `ip` points is not volatile.

**Implementation Details**

This example compiles without warning on Microsoft Visual Studio 2013 when compiled in C mode (`/TC`) but causes errors when compiled in C++ mode (`/TP`).

GCC 4.8.1 generates a warning but compiles successfully.

## Compliant Solution

In this compliant solution, `ip` is declared `volatile`:

```cpp
#include <stdio.h>

void func(void) {
  static volatile int **ipp;
  static volatile int *ip;
  static volatile int i = 0;

  printf("i = %d.\n", i);

  ipp = &ip;
  *ipp = &i;
  if (*ip != 0) {
    /* ... */
  }

}
```

## Risk Assessment

Accessing an object with a volatile-qualified type through a reference with a non-volatile-qualified type is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP32-C </td> <td> Low </td> <td> Likely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>pointer-qualifier-cast-volatile</strong> <strong>pointer-qualifier-cast-volatile-implicit</strong> </td> <td> Supported indirectly via MISRA C 2012 Rule 11.8 </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP32</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wincompatible-pointer-types-discards-qualifiers</code> </td> <td> </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2012 Rule 11.8</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 4.3.5 </td> <td> </td> <td> Can detect violations of this rule when the <code>-Wcast-qual</code> flag is used </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C0312, C0562, C0563, C0673, C0674</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>CERT.EXPR.VOLATILE.ADDR</strong> <strong>CERT.EXPR.VOLATILE.ADDR.PARAM</strong> <strong>CERT.EXPR.VOLATILE.PTRPTR</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>344 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-EXP32-a</strong> </td> <td> A cast shall not remove any 'const' or 'volatile' qualification from the type of a pointer or reference </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> </td> <td> <a> CERT C: Rule EXP32-C </a> </td> <td> Checks for cast to pointer that removes const or volatile qualification (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0312,562,563,673,674</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>pointer-qualifier-cast-volatile</strong> <strong>pointer-qualifier-cast-volatile-implicit</strong> </td> <td> Supported indirectly via MISRA C 2012 Rule 11.8 </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP32-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Pointer Casting and Pointer Type Changes \[HFC\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Type System \[IHN\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 11.8 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> EXP55-CPP. Do not access a cv-qualified object through a cv-unqualified type </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.7.3, "Type Qualifiers" </td> </tr> </tbody> </table>


## Implementation notes

In limited cases, this query can raise false-positives for assignment of volatile objects and subsequent accesses of those objects via non-volatile pointers.

## References

* CERT-C: [EXP32-C: Do not access a volatile object through a nonvolatile reference](https://wiki.sei.cmu.edu/confluence/display/c)
