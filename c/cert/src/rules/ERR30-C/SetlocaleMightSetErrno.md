# ERR30-C: Do not rely solely on errno to determine if en error occurred in setlocale

This query implements the CERT-C rule ERR30-C:

> Take care when reading errno


## Description

The value of `errno` is initialized to zero at program startup, but it is never subsequently set to zero by any C standard library function. The value of `errno` may be set to nonzero by a C standard library function call whether or not there is an error, provided the use of `errno` is not documented in the description of the function. It is meaningful for a program to inspect the contents of `errno` only after an error might have occurred. More precisely, `errno` is meaningful only after a library function that sets `errno` on error has returned an error code.

According to Question 20.4 of C-FAQ \[[Summit 2005](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Summit05)\],

> In general, you should detect errors by checking return values, and use `errno` only to distinguish among the various causes of an error, such as "File not found" or "Permission denied." (Typically, you use `perror` or `strerror` to print these discriminating error messages.) It's only necessary to detect errors with `errno` when a function does not have a unique, unambiguous, out-of-band error return (that is, because all of its possible return values are valid; one example is `atoi [*sic*]`). In these cases (and in these cases only; check the documentation to be sure whether a function allows this), you can detect errors by setting `errno` to 0, calling the function, and then testing `errno`. (Setting `errno` to 0 first is important, as no library function ever does that for you.)


Note that `atoi()` is not required to set the value of `errno`.

Library functions fall into the following categories:

* Those that set `errno` and return an [out-of-band error indicator](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-out-of-banderrorindicator)
* Those that set `errno` and return an [in-band error indicator](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-in-banderrorindicator)
* Those that do not promise to set `errno`
* Those with differing standards documentation

## Library Functions that Set errno and Return an Out-of-Band Error Indicator

The C Standard specifies that the functions listed in the following table set `errno` and return an [out-of-band error indicator](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-out-of-banderrorindicator). That is, their return value on error can never be returned by a successful call.

A program may check `errno` after invoking these library functions but is not required to do so. The program should not check the value of `errno` without first verifying that the function returned an error indicator. For example, `errno` should not be checked after calling `signal()` without first ensuring that `signal()` actually returned `SIG_ERR`.

**Functions That Set `errno` and Return an Out-of-Band Error Indicator**

<table> <tbody> <tr> <th> <strong>Function Name</strong> </th> <th> <strong>Return Value</strong> </th> <th> <code><strong>errno</strong></code> <strong> Value</strong> </th> </tr> <tr> <td> <code>ftell()</code> </td> <td> <code>-1L</code> </td> <td> Positive </td> </tr> <tr> <td> <code>fgetpos()</code> , <code>fsetpos()</code> </td> <td> Nonzero </td> <td> Positive </td> </tr> <tr> <td> <code>mbrtowc()</code> , <code>mbsrtowcs()</code> </td> <td> <code>(size_t)(-1)</code> </td> <td> <code>EILSEQ</code> </td> </tr> <tr> <td> <code>signal()</code> </td> <td> <code>SIG_ERR</code> </td> <td> Positive </td> </tr> <tr> <td> <code>wcrtomb()</code> , <code>wcsrtombs()</code> </td> <td> <code>(size_t)(-1)</code> </td> <td> <code>EILSEQ</code> </td> </tr> <tr> <td> <code>mbrtoc16()</code> , <code>mbrtoc32()</code> </td> <td> <code>(size_t)(-1)</code> </td> <td> <code>EILSEQ</code> </td> </tr> <tr> <td> <code>c16rtomb()</code> , <code>c32rtomb()</code> </td> <td> <code>(size_t)(-1)</code> </td> <td> <code>EILSEQ</code> </td> </tr> </tbody> </table>


## Library Functions that Set errno and Return an In-Band Error Indicator

The C Standard specifies that the functions listed in the following table set `errno` and return an [in-band error indicator](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-in-banderrorindicator). That is, the return value when an error occurs is also a valid return value for successful calls. For example, the `strtoul()` function returns `ULONG_MAX` and sets `errno` to `ERANGE` if an error occurs. Because `ULONG_MAX` is a valid return value, the only way to confirm that an error occurred when LONG_MAX is returned is to check `errno`.

The `fgetwc()` and `fputwc()` functions return `WEOF` in multiple cases, only one of which results in setting `errno`. The string conversion functions will return the maximum or minimum representable value and set `errno` to `ERANGE` if the converted value cannot be represented by the data type. However, if the conversion cannot happen because the input is invalid, the function will return `0`, and the output pointer parameter will be assigned the value of the input pointer parameter, provided the output parameter is non-null.

A program that uses `errno` for error checking a function that returns an in-band error indicator must set `errno` to `0` before calling one of these library functions and then inspect `errno` before a subsequent library function call.

**Functions that Set `errno` and Return an In-Band Error Indicator**

<table> <tbody> <tr> <th> <strong>Function Name</strong> </th> <th> <strong>Return Value</strong> </th> <th> <code><strong>errno</strong></code> <strong> Value</strong> </th> </tr> <tr> <td> <code>fgetwc()</code> , <code>fputwc()</code> </td> <td> <code>WEOF</code> </td> <td> <code>EILSEQ</code> </td> </tr> <tr> <td> <code>strtol()</code> , <code>wcstol()</code> </td> <td> <code>LONG_MIN</code> or <code>LONG_MAX</code> </td> <td> <code>ERANGE</code> </td> </tr> <tr> <td> <code>strtoll()</code> , <code>wcstoll()</code> </td> <td> <code>LLONG_MIN</code> or <code>LLONG_MAX</code> </td> <td> <code>ERANGE</code> </td> </tr> <tr> <td> <code>strtoul()</code> , <code>wcstoul()</code> </td> <td> <code>ULONG_MAX</code> </td> <td> <code>ERANGE</code> </td> </tr> <tr> <td> <code>strtoull()</code> , <code>wcstoull()</code> </td> <td> <code>ULLONG_MAX</code> </td> <td> <code>ERANGE</code> </td> </tr> <tr> <td> <code>strtoumax()</code> , <code>wcstoumax()</code> </td> <td> <code>UINTMAX_MAX</code> </td> <td> <code>ERANGE</code> </td> </tr> <tr> <td> <code>strtod()</code> , <code>wcstod()</code> </td> <td> <code>0</code> or <code>±HUGE_VAL</code> </td> <td> <code>ERANGE</code> </td> </tr> <tr> <td> <code>strtof()</code> , <code>wcstof()</code> </td> <td> <code>0</code> or <code>±HUGE_VALF</code> </td> <td> <code>ERANGE</code> </td> </tr> <tr> <td> <code>strtold()</code> , <code>wcstold()</code> </td> <td> <code>0</code> or <code>±HUGE_VALL</code> </td> <td> <code>ERANGE</code> </td> </tr> <tr> <td> <code>strtoimax()</code> , <code>wcstoimax()</code> </td> <td> <code>INTMAX_MIN</code> , <code>INTMAX_MAX</code> </td> <td> <code>ERANGE</code> </td> </tr> </tbody> </table>


## Library Functions that Do Not Promise to Set errno

The C Standard fails to document the behavior of `errno` for some functions. For example, the `setlocale()` function normally returns a null pointer in the event of an error, but no guarantees are made about setting `errno`.

After calling one of these functions, a program should not rely solely on the value of `errno` to determine if an error occurred. The function might have altered `errno`, but this does not ensure that `errno` will properly indicate an error condition. If the program does check `errno` after calling one of these functions, it should set `errno` to 0 before the function call.

## Library Functions with Differing Standards Documentation

Some functions behave differently regarding `errno` in various standards. The `fopen()` function is one such example. When `fopen()` encounters an error, it returns a null pointer. The C Standard makes no mention of `errno` when describing `fopen()`. However, POSIX.1 declares that when `fopen()` encounters an error, it returns a null pointer and sets `errno` to a value indicating the error \[[IEEE Std 1003.1-2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\]. The implication is that a program conforming to C but not to POSIX (such as a Windows program) should not check `errno` after calling `fopen()`, but a POSIX program may check `errno` if `fopen()` returns a null pointer.

## Library Functions and errno

The following uses of `errno` are documented in the C Standard:

* Functions defined in `<complex.h>` may set `errno` but are not required to.
* For numeric conversion functions in the `strtod`, `strtol`, `wcstod`, and `wcstol` families, if the correct result is outside the range of representable values, an appropriate minimum or maximum value is returned and the value `ERANGE` is stored in `errno`. For floating-point conversion functions in the `strtod` and `wcstod` families, if an underflow occurs, whether `errno` acquires the value `ERANGE` is [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior). If the conversion fails, `0` is returned and `errno` is not set.
* The numeric conversion function `atof()` and those in the `atoi` family "need not affect the value of" `errno`.
* For mathematical functions in `<math.h>`, if the integer expression `math_errhandling & MATH_ERRNO` is nonzero, on a domain error, `errno` acquires the value `EDOM`; on an overflow with default rounding or if the mathematical result is an exact infinity from finite arguments, `errno` acquires the value `ERANGE`; and on an underflow, whether `errno` acquires the value `ERANGE` is implementation-defined.
* If a request made by calling `signal()` cannot be honored, a value of `SIG_ERR` is returned and a positive value is stored in `errno`.
* The byte I/O functions, wide-character I/O functions, and multibyte conversion functions store the value of the macro `EILSEQ` in `errno` if and only if an encoding error occurs.
* On failure, `fgetpos()` and `fsetpos()` return nonzero and store an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) positive value in `errno`.
* On failure, `ftell()` returns `-1L` and stores an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) positive value in `errno`.
* The `perror()` function maps the error number in `errno` to a message and writes it to `stderr`.
The POSIX.1 standard defines the use of `errno` by many more functions (including the C standard library function). POSIX also has a small set of functions that are exceptions to the rule. These functions have no return value reserved to indicate an error, but they still set `errno` on error. To detect an error, an application must set `errno` to `0` before calling the function and check whether it is nonzero after the call. Affected functions include `strcoll()`, `strxfrm()`, `strerror()`, `wcscoll()`, `wcsxfrm()`, and `fwide()`. The C Standard allows these functions to set `errno` to a nonzero value on success. Consequently, this type of error checking should be performed only on POSIX systems.

## Noncompliant Code Example (strtoul())

This noncompliant code example fails to set `errno` to `0` before invoking `strtoul()`. If an error occurs, `strtoul()` returns a valid value (`ULONG_MAX`), so `errno` is the only means of determining if `strtoul()` ran successfully.

```cpp
#include <errno.h>
#include <limits.h>
#include <stdlib.h>
 
void func(const char *c_str) {
  unsigned long number;
  char *endptr;
  
  number = strtoul(c_str, &endptr, 0);
  if (endptr == c_str || (number == ULONG_MAX 
                         && errno == ERANGE)) {
    /* Handle error */
  } else {
    /* Computation succeeded */
  }
}
```
Any error detected in this manner may have occurred earlier in the program or may not represent an actual error.

## Compliant Solution (strtoul())

This compliant solution sets `errno` to `0` before the call to `strtoul()` and inspects `errno` after the call:

```cpp
#include <errno.h>
#include <limits.h>
#include <stdlib.h>
 
void func(const char *c_str) {
  unsigned long number;
  char *endptr;
 
  errno = 0;
  number = strtoul(c_str, &endptr, 0);
  if (endptr == c_str || (number == ULONG_MAX 
                         && errno == ERANGE)) {
    /* Handle error */
  } else {
    /* Computation succeeded */
  }
}
```

## Noncompliant Code Example (ftell())

This noncompliant code example, after calling `ftell()`, examines `errno` without first checking whether the out-of-band indicator returned by `ftell() `indicates an error.

```cpp
#include <errno.h>
#include <stdio.h>

void func(FILE* fp) { 
  errno=0;
  ftell(fp);
  if (errno) {
    perror("ftell");
  }
}
```

## Compliant Solution (ftell())

This compliant solution first detects that `ftell() `failed using its out-of-band error indicator. Once an error has been confirmed, reading `errno` (implicitly by using the `perror()` function) is permitted.

```cpp
#include <errno.h>
#include <stdio.h>

void func(FILE* fp) { 
  if (ftell(fp) == -1) {
    perror("ftell");
  }
}
```

## Noncompliant Code Example (fopen())

This noncompliant code example may fail to diagnose errors because `fopen()` might not set `errno` even if an error occurs:

```cpp
#include <errno.h>
#include <stdio.h>
 
void func(const char *filename) {
  FILE *fileptr;

  errno = 0;
  fileptr = fopen(filename, "rb");
  if (errno != 0) {
    /* Handle error */
  }
}
```

## Compliant Solution (fopen(), C)

The C Standard makes no mention of `errno` when describing `fopen()`. In this compliant solution, the results of the call to `fopen()` are used to determine failure and `errno` is not checked:

```cpp
#include <stdio.h>
 
void func(const char *filename) {
  FILE *fileptr = fopen(filename, "rb");
  if (fileptr == NULL)  {
    /* An error occurred in fopen() */
  }
}
```

## Compliant Solution (fopen(), POSIX)

In this compliant solution, `errno` is checked only after an error has already been detected by another means:

```cpp
#include <errno.h>
#include <stdio.h>
 
void func(const char *filename) {
  FILE *fileptr;

  errno = 0;
  fileptr = fopen(filename, "rb");
  if (fileptr == NULL)  {
    /*
     * An error occurred in fopen(); now it's valid 
     * to examine errno.
     */
    perror(filename);
  }
}
```

## Risk Assessment

The improper use of `errno` may result in failing to detect an error condition or in incorrectly identifying an error condition when none exists.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR30-C </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>errno-reset</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-ERR30</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.1p0 </td> <td> <strong>LANG.STRUCT.RC</strong> </td> <td> Redundant Condition </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Could detect violations of this rule by ensuring that each library function is accompanied by the proper treatment of <code>errno</code> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2012 Rule 22.8</strong> <strong><strong>MISRA C 2012 Rule 22.9</strong></strong> <strong><strong><strong>MISRA C 2012 Rule 22.10</strong></strong></strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.3 </td> <td> <strong>C2500, C2501, C2502, C2503 </strong> <strong>C++3172, C++3173, C++3174, C++3175, C++3176, C++3177, C++3178, C++3179, C++3183, C++3184</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.3 </td> <td> <strong>CXX.ERRNO.NOT_SET</strong> <strong>CXX.ERRNO.NOT_CHECKED</strong> <strong>CXX.ERRNO.INCORRECTLY_CHECKED</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>111 D, 121 D, 122 D, 132 D, 134 D</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-ERR30-a</strong> <strong>CERT_C-ERR30-b</strong> </td> <td> Properly use errno value Provide error handling for file opening errors right next to the call to fopen </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule ERR30-C </a> </td> <td> Checks for: Misuse of errnoisuse of errno, errno not resetrrno not reset. Rule fully covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2500, 2501, 2502, 2503 </strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> EXP12-C. Do not ignore values returned by functions </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Incorrectly setting and using <code>errno</code> \[inverrno\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-456 </a> , Missing Initialization of a Variable </td> <td> 2017-07-05: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-456 and ERR30-C**

CWE-456 = EXP33-C

CWE-456 = Union( ERR30-C, list) where list =

* Reading potentially uninitialized variables besides errno
**CWE-248 and ERR30-C**

Intersection( CWE-248, ERR30-C) = Ø

CWE-248 is only for languages that support exceptions. It lists C++ and Java, but not C.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Brainbell.com </a> \] </td> <td> <a> Macros and Miscellaneous Pitfalls </a> </td> </tr> <tr> <td> \[ <a> Horton 1990 </a> \] </td> <td> Section 11, p. 168 Section 14, p. 254 </td> </tr> <tr> <td> \[ <a> IEEE Std 1003.1-2013 </a> \] </td> <td> XSH, System Interfaces, <code>fopen</code> </td> </tr> <tr> <td> \[ <a> Koenig 1989 </a> \] </td> <td> Section 5.4, p. 73 </td> </tr> <tr> <td> \[ <a> Summit 2005 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ERR30-C: Take care when reading errno](https://wiki.sei.cmu.edu/confluence/display/c)
