# ENV34-C: Do not store pointers returned by environment functions warning

This query implements the CERT-C rule ENV34-C:

> Do not store pointers returned by environment functions


## Description

The C Standard, 7.22.4.6, paragraph 4 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> The `getenv` function returns a pointer to a string associated with the matched list member. The string pointed to shall not be modified by the program but may be overwritten by a subsequent call to the `getenv` function.


This paragraph gives an implementation the latitude, for example, to return a pointer to a statically allocated buffer. Consequently, do not store this pointer because the string data it points to may be overwritten by a subsequent call to the `getenv()` function or invalidated by modifications to the environment. This string should be referenced immediately and discarded. If later use is anticipated, the string should be copied so the copy can be safely referenced as needed.

The `getenv()` function is not thread-safe. Make sure to address any possible race conditions resulting from the use of this function.

The `asctime()`, `localeconv()`, `setlocale()`, and `strerror()` functions have similar restrictions. Do not access the objects returned by any of these functions after a subsequent call.

## Noncompliant Code Example

This noncompliant code example attempts to compare the value of the `TMP` and `TEMP` environment variables to determine if they are the same:

```cpp
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
 
void func(void) {
  char *tmpvar;
  char *tempvar;

  tmpvar = getenv("TMP");
  if (!tmpvar) {
    /* Handle error */
  }
  tempvar = getenv("TEMP");
  if (!tempvar) {
    /* Handle error */
  }
  if (strcmp(tmpvar, tempvar) == 0) {
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
}

```
This code example is noncompliant because the string referenced by `tmpvar` may be overwritten as a result of the second call to the `getenv()` function. As a result, it is possible that both `tmpvar` and `tempvar` will compare equal even if the two environment variables have different values.

## Compliant Solution

This compliant solution uses the `malloc()` and `strcpy()` functions to copy the string returned by `getenv()` into a dynamically allocated buffer:

```cpp
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
 
void func(void) {
  char *tmpvar;
  char *tempvar;

  const char *temp = getenv("TMP");
  if (temp != NULL) {
    tmpvar = (char *)malloc(strlen(temp)+1);
    if (tmpvar != NULL) {
      strcpy(tmpvar, temp);
    } else {
      /* Handle error */
    }
  } else {
    /* Handle error */
  }

  temp = getenv("TEMP");
  if (temp != NULL) {
    tempvar = (char *)malloc(strlen(temp)+1);
    if (tempvar != NULL) {
      strcpy(tempvar, temp);
    } else {
      /* Handle error */
    }
  } else {
    /* Handle error */
  }

  if (strcmp(tmpvar, tempvar) == 0) {
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
  free(tmpvar);
  free(tempvar);
}

```

## Compliant Solution (Annex K)

The C Standard, Annex K, provides the `getenv_s()` function for getting a value from the current environment. However, `getenv_s()` can still have data races with other threads of execution that modify the environment list.

```cpp
#define __STDC_WANT_LIB_EXT1__ 1
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
 
void func(void) {
  char *tmpvar;
  char *tempvar;
  size_t requiredSize;
  errno_t err;
  err = getenv_s(&requiredSize, NULL, 0, "TMP");

  if (err) {
    /* Handle error */
  }
 
  tmpvar = (char *)malloc(requiredSize);
  if (!tmpvar) {
    /* Handle error */
  }
  err = getenv_s(&requiredSize, tmpvar, requiredSize, "TMP" );

  if (err) {
    /* Handle error */
  }
  err = getenv_s(&requiredSize, NULL, 0, "TEMP");
  if (err) {
    /* Handle error */
  }
 
  tempvar = (char *)malloc(requiredSize);
  if (!tempvar) {
    /* Handle error */
  }
  err = getenv_s(&requiredSize, tempvar, requiredSize, "TEMP" );

  if (err) {
    /* Handle error */
  }
  if (strcmp(tmpvar, tempvar) == 0) {
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
  free(tmpvar);
  tmpvar = NULL;
  free(tempvar);
  tempvar = NULL;
}

```

## Compliant Solution (Windows)

Microsoft Windows provides the `[_dupenv_s()](http://msdn.microsoft.com/en-us/library/ms175774.aspx)` and [wdupenv_s()](http://msdn.microsoft.com/en-us/library/ms175774.aspx) functions for getting a value from the current environment \[[MSDN](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-MSDN)\]. The `_dupenv_s()` function searches the list of environment variables for a specified name. If the name is found, a buffer is allocated; the variable's value is copied into the buffer, and the buffer's address and number of elements are returned. The `_dupenv_s()` and `_wdupenv_s()` functions provide more convenient alternatives to `getenv_s()` and `_wgetenv_s()` because each function handles buffer allocation directly.

The caller is responsible for freeing any allocated buffers returned by these functions by calling `free()`.

```cpp
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
 
void func(void) {
  char *tmpvar;
  char *tempvar;
  size_t len;

  errno_t err = _dupenv_s(&tmpvar, &len, "TMP");
  if (err) {
    /* Handle error */
  }
  err = _dupenv_s(&tempvar, &len, "TEMP");
  if (err) {
    /* Handle error */
  }

  if (strcmp(tmpvar, tempvar) == 0) {
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
  free(tmpvar);
  tmpvar = NULL;
  free(tempvar);
  tempvar = NULL;
}

```

## Compliant Solution (POSIX or C2x)

POSIX provides the `strdup()` function, which can make a copy of the environment variable string \[[IEEE Std 1003.1:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\]. The `strdup()` function is also included in *Extensions to the C Library—Part II* \[[ISO/IEC TR 24731-2:2010](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIECTR24731-2-2010)\]. Further, it is expected to be present in the C2x standard.

```cpp
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
 
void func(void) {
  char *tmpvar;
  char *tempvar;

  const char *temp = getenv("TMP");
  if (temp != NULL) {
    tmpvar = strdup(temp);
    if (tmpvar == NULL) {
      /* Handle error */
    }
  } else {
    /* Handle error */
  }

  temp = getenv("TEMP");
  if (temp != NULL) {
    tempvar = strdup(temp);
    if (tempvar == NULL) {
      /* Handle error */
    }
  } else {
    /* Handle error */
  }

  if (strcmp(tmpvar, tempvar) == 0) {
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
  free(tmpvar);
  tmpvar = NULL;
  free(tempvar);
  tempvar = NULL;
}

```

## Risk Assessment

Storing the pointer to the string returned by `getenv()`, `localeconv()`, `setlocale()`, or `strerror()` can result in overwritten data.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ENV34-C </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ENV34-C).

## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C2681, C2682, C2683</strong> <strong>C++2681, C++2682, C++2683</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.STDLIB.ILLEGAL_REUSE.2012_AMD1</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>133 D</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-ENV34-a</strong> </td> <td> Pointers returned by certain Standard Library functions should not be used following a subsequent call to the same or related function </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule ENV34-C </a> </td> <td> Checks for misuse of return value from nonreentrant standard function (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2681, 2682, 2683</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2681, 2682, 2683</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> C Secure Coding Standard </a> </td> <td> <a> ENV00-C. Do not store objects that can be overwritten by multiple calls to getenv() and similar functions </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24731-2 </a> </td> <td> 5.3.1.1, "The <code>strdup</code> Function" </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Using an object overwritten by <code>getenv</code> , <code>localeconv</code> , <code>setlocale</code> , and <code>strerror</code> \[libuse\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE Std 1003.1:2013 </a> \] </td> <td> Chapter 8, "Environment Variables" XSH, System Interfaces, <code>strdup</code> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.22.4, "Communication with the Environment" Subclause 7.22.4.6, "The <code>getenv</code> Function" Subclause K.3.6.2.1, "The <code>getenv_s</code> Function" </td> </tr> <tr> <td> \[ <a> MSDN </a> \] </td> <td> <a> _dupenv_s() , _wdupenv_s() </a> </td> </tr> <tr> <td> \[ <a> Viega 2003 </a> \] </td> <td> Section 3.6, "Using Environment Variables Securely" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ENV34-C: Do not store pointers returned by environment functions](https://wiki.sei.cmu.edu/confluence/display/c)
