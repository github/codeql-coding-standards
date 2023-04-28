# STR38-C: Do not confuse narrow and wide character strings and functions

This query implements the CERT-C rule STR38-C:

> Do not confuse narrow and wide character strings and functions


## Description

Passing narrow string arguments to wide string functions or wide string arguments to narrow string functions can lead to [unexpected](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior) and [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). Scaling problems are likely because of the difference in size between wide and narrow characters. (See [ARR39-C. Do not add or subtract a scaled integer to a pointer.)](https://wiki.sei.cmu.edu/confluence/display/c/ARR39-C.+Do+not+add+or+subtract+a+scaled+integer+to+a+pointer) Because wide strings are terminated by a null wide character and can contain null bytes, determining the length is also problematic.

Because `wchar_t` and `char` are distinct types, many compilers will produce a warning diagnostic if an inappropriate function is used. (See [MSC00-C. Compile cleanly at high warning levels](https://wiki.sei.cmu.edu/confluence/display/c/MSC00-C.+Compile+cleanly+at+high+warning+levels).)

## Noncompliant Code Example (Wide Strings with Narrow String Functions)

This noncompliant code example incorrectly uses the `strncpy()` function in an attempt to copy up to 10 wide characters. However, because wide characters can contain null bytes, the copy operation may end earlier than anticipated, resulting in the truncation of the wide string.

```cpp
#include <stddef.h>
#include <string.h>
 
void func(void) {
  wchar_t wide_str1[]  = L"0123456789";
  wchar_t wide_str2[] =  L"0000000000";

  strncpy(wide_str2, wide_str1, 10);
}
```

## Noncompliant Code Example (Narrow Strings with Wide String Functions)

This noncompliant code example incorrectly invokes the `wcsncpy()` function to copy up to 10 wide characters from `narrow_str1` to `narrow_str2`. Because `narrow_str2` is a narrow string, it has insufficient memory to store the result of the copy and the copy will result in a buffer overflow.

```cpp
#include <wchar.h>
 
void func(void) {
  char narrow_str1[] = "01234567890123456789";
  char narrow_str2[] = "0000000000";

  wcsncpy(narrow_str2, narrow_str1, 10);
}
```

## Compliant Solution

This compliant solution uses the proper-width functions. Using `wcsncpy()` for wide character strings and `strncpy()` for narrow character strings ensures that data is not truncated and buffer overflow does not occur.

```cpp
#include <string.h>
#include <wchar.h>
 
void func(void) {
  wchar_t wide_str1[] = L"0123456789";
  wchar_t wide_str2[] = L"0000000000";
  /* Use of proper-width function */ 
  wcsncpy(wide_str2, wide_str1, 10);

  char narrow_str1[] = "0123456789";
  char narrow_str2[] = "0000000000";
  /* Use of proper-width function */ 
  strncpy(narrow_str2, narrow_str1, 10);
}
```

## Noncompliant Code Example (strlen())

In this noncompliant code example, the `strlen()` function is used to determine the size of a wide character string:

```cpp
#include <stdlib.h>
#include <string.h>
 
void func(void) {
  wchar_t wide_str1[] = L"0123456789";
  wchar_t *wide_str2 = (wchar_t*)malloc(strlen(wide_str1) + 1);
  if (wide_str2 == NULL) {
    /* Handle error */
  }
  /* ... */
  free(wide_str2);
  wide_str2 = NULL;
}
```
The `strlen()` function determines the number of characters that precede the terminating null character. However, wide characters can contain null bytes, particularly when expressing characters from the ASCII character set, as in this example. As a result, the `strlen()` function will return the number of bytes preceding the first null byte in the wide string.

## Compliant Solution

This compliant solution correctly calculates the number of bytes required to contain a copy of the wide string, including the terminating null wide character:

```cpp
#include <stdlib.h>
#include <wchar.h>
 
void func(void) {
  wchar_t wide_str1[] = L"0123456789";
  wchar_t *wide_str2 = (wchar_t *)malloc(
    (wcslen(wide_str1) + 1) * sizeof(wchar_t));
  if (wide_str2 == NULL) {
    /* Handle error */
  }
  /* ... */

  free(wide_str2);
  wide_str2 = NULL;
}
```

## Risk Assessment

Confusing narrow and wide character strings can result in buffer overflows, data truncation, and other defects.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR38-C </td> <td> High </td> <td> Likely </td> <td> Low </td> <td> <strong>P27</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

Modern compilers recognize the difference between a `char *` and a `wchar_t *`, so compiling code that violates this rule will generate warnings. It is feasible to have automated software that recognizes functions of improper width and replaces them with functions of proper width (that is, software that uses `wcsncpy()` when it recognizes that the parameters are of type `wchar_t *`).

<table> <tbody> <tr> <td> <strong>Tool</strong> </td> <td> Version </td> <td> <strong>Checker</strong> </td> <td> <strong>Description</strong> </td> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>wide-narrow-string-cast</strong> <strong>wide-narrow-string-cast-implicit</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-STR38</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wincompatible-pointer-types</code> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.BO</strong> <strong>LANG.MEM.TBA</strong> </td> <td> Buffer Overrun Tainted Buffer Access </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>PW</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C0432</strong> <strong><strong>C++0403 </strong></strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.ETYPE.ASSIGN.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-STR38-a</strong> </td> <td> Do not confuse narrow and wide character strings and functions </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2454, 2480, 2481</strong> </td> <td> Partially supported: reports illegal conversions involving pointers to char or wchar_t as well as byte/wide-oriented stream inconsistencies </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule STR38-C </a> </td> <td> Checks for misuse of narrow or wide character string (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0432</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>0403 </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>wide-narrow-string-cast</strong> <strong>wide-narrow-string-cast-implicit</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>pointer arithmetic</strong> </td> <td> Partially verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for vulnerabilities resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+STR38-C).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.24.2.4, "The <code>strncpy</code> Function" 7.29.4.2.2, "The <code>wcsncpy</code> Function" </td> </tr> </tbody> </table>


## Implementation notes

Wide character types are not handled correctly on the `aarch64le` architecture. This can lead to false negative alerts.

## References

* CERT-C: [STR38-C: Do not confuse narrow and wide character strings and functions](https://wiki.sei.cmu.edu/confluence/display/c)
