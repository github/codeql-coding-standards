# CON33-C: Avoid race conditions when using library functions

This query implements the CERT-C rule CON33-C:

> Avoid race conditions when using library functions


## Description

Some C standard library functions are not guaranteed to be [reentrant](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-reentrant) with respect to threads. Functions such as `strtok()` and `asctime()` return a pointer to the result stored in function-allocated memory on a per-process basis. Other functions such as `rand()` store state information in function-allocated memory on a per-process basis. Multiple threads invoking the same function can cause concurrency problems, which often result in abnormal behavior and can cause more serious [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability), such as [abnormal termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination), [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-denial-of-service), and data integrity violations.

According to the C Standard, the library functions listed in the following table may contain data races when invoked by multiple threads.

<table> <tbody> <tr> <th> Functions </th> <th> Remediation </th> </tr> <tr> <td> <code>rand()</code> , <code>srand()</code> </td> <td> <a> MSC30-C. Do not use the rand() function for generating pseudorandom numbers </a> </td> </tr> <tr> <td> <code>getenv()</code> , <code>getenv_s()</code> </td> <td> <a> ENV34-C. Do not store pointers returned by certain functions </a> </td> </tr> <tr> <td> <code>strtok()</code> </td> <td> <code>strtok_s()</code> in C11 Annex K <code>strtok_r()</code> in POSIX </td> </tr> <tr> <td> <code>strerror()</code> </td> <td> <code>strerror_s()</code> in C11 Annex K <code>strerror_r()</code> in POSIX </td> </tr> <tr> <td> <code>asctime()</code> , <code>ctime()</code> , <code>localtime()</code> , <code>gmtime()</code> </td> <td> <code>asctime_s()</code> , <code>ctime_s()</code> , <code>localtime_s()</code> , <code>gmtime_s()</code> in C11 Annex K </td> </tr> <tr> <td> <code>setlocale()</code> </td> <td> Protect multithreaded access to locale-specific functions with a mutex </td> </tr> <tr> <td> <code>ATOMIC_VAR_INIT</code> , <code>atomic_init()</code> </td> <td> Do not attempt to initialize an atomic variable from multiple threads </td> </tr> <tr> <td> <code>tmpnam()</code> </td> <td> <code>tmpnam_s()</code> in C11 Annex K <code>tmpnam_r()</code> in POSIX </td> </tr> <tr> <td> <code>mbrtoc16()</code> , <code>c16rtomb()</code> , <code>mbrtoc32()</code> , <code>c32rtomb()</code> </td> <td> Do not call with a null <code>mbstate_t \*</code> argument </td> </tr> </tbody> </table>
Section 2.9.1 of the *Portable Operating System Interface (POSIX<sup>®</sup>), Base Specifications, Issue 7* \[[IEEE Std 1003.1:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\] extends the list of functions that are not required to be thread-safe.


## Noncompliant Code Example

In this noncompliant code example, the function `f()` is called from within a multithreaded application but encounters an error while calling a system function. The `strerror()` function returns a human-readable error string given an error number. The C Standard, 7.24.6.2 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], specifically states that `strerror()` is not required to avoid data races. An [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) could write the error string into a static array and return a pointer to it, and that array might be accessible and modifiable by other threads.

```cpp
#include <errno.h>
#include <stdio.h>
#include <string.h>
 
void f(FILE *fp) {
  fpos_t pos;
  errno = 0;

  if (0 != fgetpos(fp, &pos)) {
    char *errmsg = strerror(errno);
    printf("Could not get the file position: %s\n", errmsg);
  }
}
```
This code first sets `errno` to 0 to comply with [ERR30-C. Take care when reading errno](https://wiki.sei.cmu.edu/confluence/display/c/ERR30-C.+Take+care+when+reading+errno).

## Compliant Solution (Annex K, strerror_s())

This compliant solution uses the `strerror_s()` function from Annex K of the C Standard, which has the same functionality as `strerror()` but guarantees thread-safety:

```cpp
#define __STDC_WANT_LIB_EXT1__ 1
#include <errno.h>
#include <stdio.h>
#include <string.h>
 
enum { BUFFERSIZE = 64 };
void f(FILE *fp) {
  fpos_t pos;
  errno = 0;

  if (0 != fgetpos(fp, &pos)) {
    char errmsg[BUFFERSIZE];
    if (strerror_s(errmsg, BUFFERSIZE, errno) != 0) {
      /* Handle error */
    }
    printf("Could not get the file position: %s\n", errmsg);
  }
}
```
Because Annex K is optional, `strerror_s()` may not be available in all implementations.

## Compliant Solution (POSIX, strerror_r())

This compliant solution uses the POSIX `strerror_r()` function, which has the same functionality as `strerror()` but guarantees thread safety:

```cpp
#include <errno.h>
#include <stdio.h>
#include <string.h>

enum { BUFFERSIZE = 64 };
 
void f(FILE *fp) {
  fpos_t pos;
  errno = 0;

  if (0 != fgetpos(fp, &pos)) {
    char errmsg[BUFFERSIZE];
    if (strerror_r(errno, errmsg, BUFFERSIZE) != 0) {
      /* Handle error */
    }
    printf("Could not get the file position: %s\n", errmsg);
  }
}
```
Linux provides two versions of `strerror_r()`, known as the *XSI-compliant version* and the *GNU-specific version*. This compliant solution assumes the XSI-compliant version, which is the default when an application is compiled as required by POSIX (that is, by defining `_POSIX_C_SOURCE` or `_XOPEN_SOURCE` appropriately). The` strerror_r()` manual page lists versions that are available on a particular system.

## Risk Assessment

Race conditions caused by multiple threads invoking the same library function can lead to [abnormal termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination) of the application, data integrity violations, or a [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-denial-of-service).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON33-C </td> <td> Medium </td> <td> Probable </td> <td> High </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON33-C).

## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.RANDOM.RAND</strong> <strong>BADFUNC.TEMP.TMPNAM</strong> <strong>BADFUNC.TTYNAME</strong> </td> <td> Use of <code>rand</code> (includes check for uses of <code>srand()</code> ) Use of <code>tmpnam</code> (includes check for uses of <code>tmpnam_r()</code> ) Use of <code>ttyname</code> </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> A module written in Compass/ROSE can detect violations of this rule </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4976, C4977,C5037</strong> <strong>C++4976, C++4977, C++5021</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.CONC.LIB_FUNC_USE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>44 S</strong> </td> <td> Partially Implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-CON33-a</strong> </td> <td> Avoid using thread-unsafe functions </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>586</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule CON33-C </a> </td> <td> Checks for data race through standard library function call (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>5037, 4976, 4977</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4976, 4977, 5021</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> ERR30-C. Set errno to zero before calling a library function known to set errno, and check errno only after the function returns a value indicating failure </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> CON00-CPP. Avoid assuming functions are thread safe unless otherwise specified </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-330 </a> </td> <td> 2017-06-28: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-377 </a> </td> <td> 2017-06-28: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-676 </a> </td> <td> 2017-05-18: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-330 and CON33-C**

Independent( MSC30-C, MSC32-C, CON33-C)

Intersection( CWE-330, CON33-C) =

* Use of rand() or srand() from multiple threads, introducing a race condition.
CWE-330 – CON33-C =
* Use of rand() or srand() without introducing race conditions
* Use of other dangerous functions
CON33-C – CWE-330 =
* Use of other global functions (besides rand() and srand()) introducing race conditions
**CWE-377 and CON33-C**

Intersection( CWE-377, CON33-C) =

* Use of tmpnam() from multiple threads, introducing a race condition.
CWE-377 – CON33-C =
* Insecure usage of tmpnam() without introducing race conditions
* Insecure usage of other functions for creating temporary files (see CERT recommendation FIO21-C for details)
CON33-C – CWE-377 =
* Use of other global functions (besides tmpnam()) introducing race conditions
**CWE-676 and CON33-C**
* Independent( ENV33-C, CON33-C, STR31-C, EXP33-C, MSC30-C, ERR34-C)
* CON33-C lists standard C library functions that manipulate global data (e.g., locale()), that can be dangerous to use in a multithreaded context.
* CWE-676 = Union( CON33-C, list) where list =
* Invocation of the following functions without introducing a race condition:
* rand(), srand(, getenv(), getenv_s(), strtok(), strerror(), asctime(), ctime(), localtime(), gmtime(), setlocale(), ATOMIC_VAR_INIT, atomic_init(), tmpnam(), mbrtoc16(), c16rtomb(), mbrtoc32(), c32rtomb()
* Invocation of other dangerous functions

## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE Std 1003.1:2013 </a> \] </td> <td> Section 2.9.1, "Thread Safety" </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.24.6.2, "The <code>strerror</code> Function" </td> </tr> <tr> <td> \[ <a> Open Group 1997b </a> \] </td> <td> Section 10.12, "Thread-Safe POSIX.1 and C-Language Functions" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [CON33-C: Avoid race conditions when using library functions](https://wiki.sei.cmu.edu/confluence/display/c)
