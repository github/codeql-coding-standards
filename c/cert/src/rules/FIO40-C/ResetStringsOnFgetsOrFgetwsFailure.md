# FIO40-C: Reset strings on fgets() or fgetws() failure

This query implements the CERT-C rule FIO40-C:

> Reset strings on fgets() or fgetws() failure


## Description

If either of the C Standard `fgets()` or `fgetws()` functions fail, the contents of the array being written is [indeterminate](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue). (See [undefined behavior 170](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_170).) It is necessary to reset the string to a known value to avoid errors on subsequent string manipulation functions.

## Noncompliant Code Example

In this noncompliant code example, an error flag is set if `fgets()` fails. However, `buf` is not reset and has indeterminate contents:

```cpp
#include <stdio.h>
 
enum { BUFFER_SIZE = 1024 };
void func(FILE *file) {
  char buf[BUFFER_SIZE];

  if (fgets(buf, sizeof(buf), file) == NULL) {
    /* Set error flag and continue */
  }
}
```

## Compliant Solution

In this compliant solution, `buf` is set to an empty string if `fgets()` fails. The equivalent solution for `fgetws()` would set `buf` to an empty wide string.

```cpp
#include <stdio.h>
 
enum { BUFFER_SIZE = 1024 };

void func(FILE *file) {
  char buf[BUFFER_SIZE];

  if (fgets(buf, sizeof(buf), file) == NULL) {
    /* Set error flag and continue */
    *buf = '\0';
  }
}
```

## Exceptions

**FIO40-C-EX1:** If the string goes out of scope immediately following the call to `fgets()` or `fgetws()` or is not referenced in the case of a failure, it need not be reset.

## Risk Assessment

Making invalid assumptions about the contents of an array modified by `fgets()` or `fgetws()` can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) and [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO40-C </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.UVAR</strong> </td> <td> Uninitialized Variable </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4861, C4862, C4863</strong> <strong>C++4861, C++4862, C++4863</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>44 S</strong> </td> <td> Enhanced enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-FIO40-a</strong> </td> <td> Reset strings on fgets() or fgetws() failure </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule FIO40-C </a> </td> <td> Checks for use of indeterminate string (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2956 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V1024</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO40-C).

## Implementation notes

None

## References

* CERT-C: [FIO40-C: Reset strings on fgets() or fgetws() failure](https://wiki.sei.cmu.edu/confluence/display/c)
