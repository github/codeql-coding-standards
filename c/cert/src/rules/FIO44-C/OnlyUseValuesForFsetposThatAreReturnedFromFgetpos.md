# FIO44-C: Only use values for fsetpos() that are returned from fgetpos()

This query implements the CERT-C rule FIO44-C:

> Only use values for fsetpos() that are returned from fgetpos()


## Description

The C Standard, 7.21.9.3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], defines the following behavior for `fsetpos()`:

> The `fsetpos` function sets the `mbstate_t` object (if any) and file position indicator for the stream pointed to by `stream` according to the value of the object pointed to by `pos`, which shall be a value obtained from an earlier successful call to the `fgetpos` function on a stream associated with the same file.


Invoking the `fsetpos()` function with any other values for `pos` is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

This noncompliant code example attempts to read three values from a file and then set the file position pointer back to the beginning of the file:

```cpp
#include <stdio.h>
#include <string.h>
 
int opener(FILE *file) {
  int rc;
  fpos_t offset;

  memset(&offset, 0, sizeof(offset));

  if (file == NULL) { 
    return -1;
  }

  /* Read in data from file */

  rc = fsetpos(file, &offset);
  if (rc != 0 ) {
    return rc;
  }

  return 0;
}

```
Only the return value of an `fgetpos()` call is a valid argument to `fsetpos()`; passing a value of type `fpos_t` that was created in any other way is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Compliant Solution

In this compliant solution, the initial file position indicator is stored by first calling `fgetpos()`, which is used to restore the state to the beginning of the file in the later call to `fsetpos()`:

```cpp
#include <stdio.h>
#include <string.h>
 
int opener(FILE *file) {
  int rc;
  fpos_t offset;

  if (file == NULL) {
    return -1;
  }

  rc = fgetpos(file, &offset);
  if (rc != 0 ) {
    return rc;
  }

  /* Read in data from file */

  rc = fsetpos(file, &offset);
  if (rc != 0 ) {
    return rc;
  }

  return 0;
}

```

## Risk Assessment

Misuse of the `fsetpos()` function can position a file position indicator to an unintended location in the file.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO44-C </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>(customization)</strong> </td> <td> Users can add a custom check for violations of this constraint. </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect common violations of this rule. However, it cannot handle cases in which the value returned by <code>fgetpos()</code> is copied between several variables before being passed to <code>fsetpos()</code> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4841, C4842, C4843</strong> <strong>C++4841, C++4842, C++4843</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.FSETPOS.VALUE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>82 D</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-FIO44-a</strong> </td> <td> Only use values for fsetpos() that are returned from fgetpos() </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> </td> <td> <a> CERT C: Rule FIO44-C </a> </td> <td> Checks for invalid file position (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>4841, 4842, 4843</strong> </td> <td> Enforced by QAC </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4841, 4842, 4843</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V1035</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO44-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Using a value for fsetpos other than a value returned from fgetpos \[xfilepos\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.21.9.3, "The <code>fsetpos</code> Function" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [FIO44-C: Only use values for fsetpos() that are returned from fgetpos()](https://wiki.sei.cmu.edu/confluence/display/c)
