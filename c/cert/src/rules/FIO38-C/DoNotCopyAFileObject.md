# FIO38-C: Do not copy a FILE object

This query implements the CERT-C rule FIO38-C:

> Do not copy a FILE object


## Description

According to the C Standard, 7.21.3, paragraph 6 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\],

> The address of the `FILE` object used to control a stream may be significant; a copy of a `FILE` object need not serve in place of the original.


Consequently, do not copy a `FILE` object.

## Noncompliant Code Example

This noncompliant code example can fail because a by-value copy of `stdout` is being used in the call to `fputs()`:

```cpp
#include <stdio.h>
 
int main(void) {
  FILE my_stdout = *stdout;
  if (fputs("Hello, World!\n", &my_stdout) == EOF) {
    /* Handle error */
  }
  return 0;
}

```
When compiled under Microsoft Visual Studio 2013 and run on Windows, this noncompliant example results in an "access violation" at runtime.

## Compliant Solution

In this compliant solution, a copy of the `stdout` pointer to the `FILE` object is used in the call to `fputs()`:

```cpp
#include <stdio.h>
 
int main(void) {
  FILE *my_stdout = stdout;
  if (fputs("Hello, World!\n", my_stdout) == EOF) {
    /* Handle error */
  }
  return 0;
}

```

## Risk Assessment

Using a copy of a `FILE` object in place of the original may result in a crash, which can be used in a [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-denial-of-service).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO38-C </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>file-dereference</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-FIO38</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>misc-non-copyable-objects</code> </td> <td> Checked with <code>clang-tidy</code> </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect simple violations of this rule </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2012 Rule 22.5</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C1485, C5028</strong> <strong>C++3113, C++3114</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.FILE_PTR.DEREF.2012</strong> <strong>MISRA.FILE_PTR.DEREF.CAST.2012</strong> <strong>MISRA.FILE_PTR.DEREF.INDIRECT.2012</strong> <strong>MISRA.FILE_PTR.DEREF.RETURN.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>591 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-FIO38-a</strong> </td> <td> A pointer to a FILE object shall not be dereferenced </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>9047</strong> </td> <td> Partially supported: reports when a FILE pointer is dereferenced </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule FIO38-C </a> </td> <td> Checks for misuse of a FILE object (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>1485, 5028 </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>file-dereference</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO38-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Copying a <code>FILE</code> object \[filecpy\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.21.3, "Files" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [FIO38-C: Do not copy a FILE object](https://wiki.sei.cmu.edu/confluence/display/c)
