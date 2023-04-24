# STR32-C: Do not pass a non-null-terminated character sequence to a library function that expects a string

This query implements the CERT-C rule STR32-C:

> Do not pass a non-null-terminated character sequence to a library function that expects a string


## Description

Many library functions accept a string or wide string argument with the constraint that the string they receive is properly null-terminated. Passing a character sequence or wide character sequence that is not null-terminated to such a function can result in accessing memory that is outside the bounds of the object. Do not pass a character sequence or wide character sequence that is not null-terminated to a library function that expects a string or wide string argument.

## Noncompliant Code Example

This code example is noncompliant because the character sequence `c_str` will not be null-terminated when passed as an argument to `printf().` (See [STR11-C. Do not specify the bound of a character array initialized with a string literal](https://wiki.sei.cmu.edu/confluence/display/c/STR11-C.+Do+not+specify+the+bound+of+a+character+array+initialized+with+a+string+literal) on how to properly initialize character arrays.)

```cpp
#include <stdio.h>
 
void func(void) {
  char c_str[3] = "abc";
  printf("%s\n", c_str);
}

```

## Compliant Solution

This compliant solution does not specify the bound of the character array in the array declaration. If the array bound is omitted, the compiler allocates sufficient storage to store the entire string literal, including the terminating null character.

```cpp
#include <stdio.h>
 
void func(void) {
  char c_str[] = "abc";
  printf("%s\n", c_str);
}
```

## Noncompliant Code Example

This code example is noncompliant because the wide character sequence `cur_msg` will not be null-terminated when passed to `wcslen()`. This will occur if `lessen_memory_usage()` is invoked while `cur_msg_size` still has its initial value of 1024.

```cpp
#include <stdlib.h>
#include <wchar.h>
 
wchar_t *cur_msg = NULL;
size_t cur_msg_size = 1024;
size_t cur_msg_len = 0;

void lessen_memory_usage(void) {
  wchar_t *temp;
  size_t temp_size;

  /* ... */

  if (cur_msg != NULL) {
    temp_size = cur_msg_size / 2 + 1;
    temp = realloc(cur_msg, temp_size * sizeof(wchar_t));
    /* temp &and cur_msg may no longer be null-terminated */
    if (temp == NULL) {
      /* Handle error */
    }

    cur_msg = temp;
    cur_msg_size = temp_size;
    cur_msg_len = wcslen(cur_msg); 
  }
}
```

## Compliant Solution

In this compliant solution, `cur_msg` will always be null-terminated when passed to `wcslen()`:

```cpp
#include <stdlib.h>
#include <wchar.h>
 
wchar_t *cur_msg = NULL;
size_t cur_msg_size = 1024;
size_t cur_msg_len = 0;

void lessen_memory_usage(void) {
  wchar_t *temp;
  size_t temp_size;

  /* ... */

  if (cur_msg != NULL) {
    temp_size = cur_msg_size / 2 + 1;
    temp = realloc(cur_msg, temp_size * sizeof(wchar_t));
    /* temp and cur_msg may no longer be null-terminated */
    if (temp == NULL) {
      /* Handle error */
    }

    cur_msg = temp;
    /* Properly null-terminate cur_msg */
    cur_msg[temp_size - 1] = L'\0'; 
    cur_msg_size = temp_size;
    cur_msg_len = wcslen(cur_msg); 
  }
}
```

## Noncompliant Code Example (strncpy())

Although the `strncpy()` function takes a string as input, it does not guarantee that the resulting value is still null-terminated. In the following noncompliant code example, if no null character is contained in the first `n` characters of the `source` array, the result will not be null-terminated. Passing a non-null-terminated character sequence to `strlen()` is undefined behavior.

```cpp
#include <string.h>
 
enum { STR_SIZE = 32 };
 
size_t func(const char *source) {
  char c_str[STR_SIZE];
  size_t ret = 0;

  if (source) {
    c_str[sizeof(c_str) - 1] = '\0';
    strncpy(c_str, source, sizeof(c_str));
    ret = strlen(c_str);
  } else {
    /* Handle null pointer */
  }
  return ret;
}

```

## Compliant Solution (Truncation)

This compliant solution is correct if the programmer's intent is to truncate the string:

```cpp
#include <string.h>
 
enum { STR_SIZE = 32 };
 
size_t func(const char *source) {
  char c_str[STR_SIZE];
  size_t ret = 0;

  if (source) {
    strncpy(c_str, source, sizeof(c_str) - 1);
    c_str[sizeof(c_str) - 1] = '\0';
    ret = strlen(c_str);
  } else {
    /* Handle null pointer */
  }
  return ret;
}
```

## Compliant Solution (Truncation, strncpy_s())

The C Standard, Annex K `strncpy_s()` function can also be used to copy with truncation. The `strncpy_s()` function copies up to `n` characters from the source array to a destination array. If no null character was copied from the source array, then the `n`th position in the destination array is set to a null character, guaranteeing that the resulting string is null-terminated.

```cpp
#define __STDC_WANT_LIB_EXT1__ 1
#include <string.h>

enum { STR_SIZE = 32 };

size_t func(const char *source) {
  char a[STR_SIZE];
  size_t ret = 0;

  if (source) {
    errno_t err = strncpy_s(
      a, sizeof(a), source, strlen(source)
    );
    if (err != 0) {
      /* Handle error */
    } else {
      ret = strnlen_s(a, sizeof(a));
    }
  } else {
     /* Handle null pointer */
  }
  return ret;
}

```

## Compliant Solution (Copy without Truncation)

If the programmer's intent is to copy without truncation, this compliant solution copies the data and guarantees that the resulting array is null-terminated. If the string cannot be copied, it is handled as an error condition.

```cpp
#include <string.h>
 
enum { STR_SIZE = 32 };
 
size_t func(const char *source) {
  char c_str[STR_SIZE];
  size_t ret = 0;

  if (source) {
    if (strlen(source) < sizeof(c_str)) {
      strcpy(c_str, source);
      ret = strlen(c_str);
    } else {
      /* Handle string-too-large */
    }
  } else {
    /* Handle null pointer */
  }
  return ret;
}
```

## Risk Assessment

Failure to properly null-terminate a character sequence that is passed to a library function that expects a string can result in buffer overflows and the execution of arbitrary code with the permissions of the vulnerable process. Null-termination errors can also result in unintended information disclosure.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR32-C </td> <td> High </td> <td> Probable </td> <td> Medium </td> <td> <strong>P12</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported Astrée supports the implementation of library stubs to fully verify this guideline. </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-STR32</strong> </td> <td> Partially implemented: can detect some violation of the rule </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>MISC.MEM.NTERM.CSTRING</strong> </td> <td> Unterminated C String </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect some violations of this rule </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>STRING_NULL</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C2835, C2836, C2839</strong> <strong>C++2835, C++2836, C++2839</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>NNTS.MIGHTSV.STRBO.BOUND_COPY.UNTERM</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>404 S, 600 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-STR32-a</strong> </td> <td> Avoid overflow due to reading a not zero terminated string </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule STR32-C </a> </td> <td> Checks for: Invalid use of standard library string routinenvalid use of standard library string routine, tainted null or non-null-terminated stringainted null or non-null-terminated string. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2835, 2836, 2839</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>0145</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V692</a></strong> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>match format and arguments</strong> </td> <td> Partially verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+STR32-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> String Termination \[CMJ\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Passing a non-null-terminated character sequence to a library function that expects a string \[strmod\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-119 </a> , Improper Restriction of Operations within the Bounds of a Memory Buffer </td> <td> 2017-05-18: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-123 </a> , Write-what-where Condition </td> <td> 2017-06-12: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-125 </a> , Out-of-bounds Read </td> <td> 2017-05-18: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-170 </a> , Improper Null Termination </td> <td> 2017-06-13: CERT: Exact </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-119 and STR32-C**

Independent( ARR30-C, ARR38-C, ARR32-C, INT30-C, INT31-C, EXP39-C, EXP33-C, FIO37-C) STR31-C = Subset( Union( ARR30-C, ARR38-C)) STR32-C = Subset( ARR38-C)

CWE-119 = Union( STR32-C, list) where list =

* Out-of-bounds reads or writes that do not involve non-null-terminated byte strings.
**CWE-125 and STR32-C**

Independent( ARR30-C, ARR38-C, EXP39-C, INT30-C) STR31-C = Subset( Union( ARR30-C, ARR38-C)) STR32-C = Subset( ARR38-C)

CWE-125 = Union( STR32-C, list) where list =

* Out-of-bounds reads that do not involve non-null-terminated byte strings.
**CWE-123 and STR32-C**

Independent(ARR30-C, ARR38-C) STR31-C = Subset( Union( ARR30-C, ARR38-C)) STR32-C = Subset( ARR38-C)

Intersection( CWE-123, STR32-C) =

* Buffer overflow from passing a non-null-terminated byte string to a standard C library copying function that expects null termination, and that overwrites an (unrelated) pointer
STR32-C - CWE-123 =
* Buffer overflow from passing a non-null-terminated byte string to a standard C library copying function that expects null termination, but it does not overwrite an (unrelated) pointer
CWE-123 – STR31-C =
* Arbitrary writes that do not involve standard C library copying functions, such as strcpy()

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Seacord 2013 </a> \] </td> <td> Chapter 2, "Strings" </td> </tr> <tr> <td> \[ <a> Viega 2005 </a> \] </td> <td> Section 5.2.14, "Miscalculated <code>NULL</code> Termination" </td> </tr> </tbody> </table>


## Implementation notes

Wide character types are not handled correctly on the `aarch64le` architecture. This can lead to false negative alerts.

## References

* CERT-C: [STR32-C: Do not pass a non-null-terminated character sequence to a library function that expects a string](https://wiki.sei.cmu.edu/confluence/display/c)
