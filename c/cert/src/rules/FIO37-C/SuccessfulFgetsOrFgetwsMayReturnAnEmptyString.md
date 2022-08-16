# FIO37-C: Do not assume that fgets() or fgetws() returns a nonempty string when successful

This query implements the CERT-C rule FIO37-C:

> Do not assume that fgets() or fgetws() returns a nonempty string when successful


## Description

Errors can occur when incorrect assumptions are made about the type of data being read. These assumptions may be violated, for example, when binary data has been read from a file instead of text from a user's terminal or the output of a process is piped to `stdin.` (See [FIO14-C. Understand the difference between text mode and binary mode with file streams](https://wiki.sei.cmu.edu/confluence/display/c/FIO14-C.+Understand+the+difference+between+text+mode+and+binary+mode+with+file+streams).) On some systems, it may also be possible to input a null byte (as well as other binary codes) from the keyboard.

Subclause 7.21.7.2 of the C Standard \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\] says,

> The `fgets` function returns `s` if successful. If end-of-file is encountered and no characters have been read into the array, the contents of the array remain unchanged and a null pointer is returned.


The wide-character function `fgetws()` has the same behavior. Therefore, if `fgets()` or `fgetws()` returns a non-null pointer, it is safe to assume that the array contains data. However, it is erroneous to assume that the array contains a nonempty string because the data may contain null characters.

## Noncompliant Code Example

This noncompliant code example attempts to remove the trailing newline (`\n`) from an input line. The `fgets()` function is typically used to read a newline-terminated line of input from a stream. It takes a size parameter for the destination buffer and copies, at most, `size - 1` characters from a stream to a character array.

```cpp
#include <stdio.h>
#include <string.h>
 
enum { BUFFER_SIZE = 1024 };

void func(void) {
  char buf[BUFFER_SIZE];

  if (fgets(buf, sizeof(buf), stdin) == NULL) {
    /* Handle error */
  }
  buf[strlen(buf) - 1] = '\0';
}
```
The `strlen()` function computes the length of a string by determining the number of characters that precede the terminating null character. A problem occurs if the first character read from the input by `fgets()` happens to be a null character. This may occur, for example, if a binary data file is read by the `fgets()` call \[[Lai 2006](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Lai06)\]. If the first character in `buf` is a null character, `strlen(buf)` returns 0, the expression `strlen(buf) - 1` wraps around to a large positive value, and a write-outside-array-bounds error occurs.

## Compliant Solution

This compliant solution uses `strchr()` to replace the newline character in the string if it exists:

```cpp
#include <stdio.h>
#include <string.h>
 
enum { BUFFER_SIZE = 1024 };

void func(void) {
  char buf[BUFFER_SIZE];
  char *p;

  if (fgets(buf, sizeof(buf), stdin)) {
    p = strchr(buf, '\n');
    if (p) {
      *p = '\0';
    }
  } else {
    /* Handle error */
  }
}
```

## Risk Assessment

Incorrectly assuming that character data has been read can result in an out-of-bounds memory write or other flawed logic.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO37-C </td> <td> High </td> <td> Probable </td> <td> Medium </td> <td> <strong>P12</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported: Astrée reports defects due to returned (empty) strings. </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-FIO37</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>(general)</strong> </td> <td> Considers the possibility that <code>fgets()</code> and <code>fgetws()</code> may return empty strings (Warnings of various classes may be triggered depending on subsequent operations on those strings. For example, the noncompliant code example cited above would trigger a buffer underrun warning.) </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Could detect some violations of this rule (In particular, it could detect the noncompliant code example by searching for <code>fgets()</code> , followed by <code>strlen() - 1</code> , which could be −1. The crux of this rule is that a string returned by <code>fgets()</code> could still be empty, because the first <code>char</code> is ' <code>\\0</code> '. There are probably other code examples that violate this guideline; they would need to be enumerated before ROSE could detect them.) </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4911, C4912, C4913</strong> <strong>C++4911, C++4912, C++4913</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>44 S</strong> </td> <td> Enhanced enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-FIO37-a</strong> </td> <td> Avoid accessing arrays out of bounds </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule FIO37-C </a> </td> <td> Checks for use of indeterminate string (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2844</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO37-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> FIO14-C. Understand the difference between text mode and binary mode with file streams </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> FIO20-C. Avoid unintentional truncation when using fgets() or fgetws() </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-241 </a> , Improper Handling of Unexpected Data Type </td> <td> 2017-07-05: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-241 and FIO37-C**

CWE-241 = Union( FIO37-C, list) where list =

* Improper handling of unexpected data type that does not come from the fgets() function.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.21.7.2, "The <code>fgets</code> Function" Subclause 7.29.3.2, "The <code>fgetws</code> Function" </td> </tr> <tr> <td> \[ <a> Lai 2006 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Seacord 2013 </a> \] </td> <td> Chapter 2, "Strings" </td> </tr> </tbody> </table>


## Implementation notes

The rule checks that access to a string returned by fgets() or fgetws() if protected by a guard condition. The rule is enforced in the context of a single function.

## References

* CERT-C: [FIO37-C: Do not assume that fgets() or fgetws() returns a nonempty string when successful](https://wiki.sei.cmu.edu/confluence/display/c)
