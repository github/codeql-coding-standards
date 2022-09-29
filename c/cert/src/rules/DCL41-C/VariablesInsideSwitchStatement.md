# DCL41-C: Do not declare variables inside a switch statement before the first case label

This query implements the CERT-C rule DCL41-C:

> Do not declare variables inside a switch statement before the first case label


## Description

According to the C Standard, 6.8.4.2, paragraph 4 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\],

> A switch statement causes control to jump to, into, or past the statement that is the switch body, depending on the value of a controlling expression, and on the presence of a default label and the values of any case labels on or in the switch body.


If a programmer declares variables, initializes them before the first case statement, and then tries to use them inside any of the case statements, those variables will have scope inside the `switch` block but will not be initialized and will consequently contain indeterminate values. Reading such values also violates [EXP33-C. Do not read uninitialized memory](https://wiki.sei.cmu.edu/confluence/display/c/EXP33-C.+Do+not+read+uninitialized+memory).

## Noncompliant Code Example

This noncompliant code example declares variables and contains executable statements before the first case label within the `switch` statement:

```cpp
#include <stdio.h>
 
extern void f(int i);
 
void func(int expr) {
  switch (expr) {
    int i = 4;
    f(i);
  case 0:
    i = 17;
    /* Falls through into default code */
  default:
    printf("%d\n", i);
  }
}

```
**Implementation Details**

When the preceding example is executed on GCC 4.8.1, the variable `i` is instantiated with automatic storage duration within the block, but it is not initialized. Consequently, if the controlling expression `expr` has a nonzero value, the call to `printf()` will access an indeterminate value of `i`. Similarly, the call to `f()` is not executed.

<table> <tbody> <tr> <th> Value of <code>expr</code> </th> <th> <code>Output</code> </th> </tr> <tr> <td> 0 </td> <td> 17 </td> </tr> <tr> <td> Nonzero </td> <td> Indeterminate </td> </tr> </tbody> </table>


## Compliant Solution

In this compliant solution, the statements before the first case label occur before the `switch` statement:

```cpp
#include <stdio.h>
 
extern void f(int i);
 
int func(int expr) {
  /*
   * Move the code outside the switch block; now the statements
   * will get executed.
   */
  int i = 4;
  f(i);

  switch (expr) {
    case 0:
      i = 17;
      /* Falls through into default code */
    default:
      printf("%d\n", i);
  }
  return 0;
}

```

## Risk Assessment

Using test conditions or initializing variables before the first case statement in a `switch` block can result in [unexpected behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior) and [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL41-C </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <td> <strong>Tool</strong> </td> <td> Version </td> <td> <strong>Checker</strong> </td> <td> <strong>Description</strong> </td> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>switch-skipped-code</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-DCL41</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wsometimes-uninitialized</code> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.1p0 </td> <td> <strong>LANG.STRUCT.SW.BAD</strong> </td> <td> Malformed switch Statement </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2004 Rule 15.0</strong> <strong>MISRA C 2012 Rule 16.1</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C2008, C2882, C3234</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.DCL.SWITCH.VAR_BEFORE_CASE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>385 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-DCL41-a</strong> </td> <td> A switch statement shall only contain switch labels and switch clauses, and no other code </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>527</strong> </td> <td> Assistance provided </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule DCL41-C </a> </td> <td> Checks for ill-formed switch statements (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>3234</strong> <strong>2008</strong> <strong>2882</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.20 </td> <td> <strong><a>V622</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>switch-skipped-code</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>initialisation</strong> </td> <td> Exhaustively detects undefined behavior (see <a> the compliant and the non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+DCL41-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 16.1 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.8.4.2, "The <code>switch</code> Statement" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [DCL41-C: Do not declare variables inside a switch statement before the first case label](https://wiki.sei.cmu.edu/confluence/display/c)
