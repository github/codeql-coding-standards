# SIG31-C: Do not access shared objects in signal handlers

This query implements the CERT-C rule SIG31-C:

> Do not access shared objects in signal handlers


## Description

Accessing or modifying shared objects in signal handlers can result in race conditions that can leave data in an inconsistent state. The two exceptions (C Standard, 5.1.2.3, paragraph 5) to this rule are the ability to read from and write to lock-free atomic objects and variables of type `volatile sig_atomic_t`. Accessing any other type of object from a signal handler is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 131](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_131).)

The need for the `volatile` keyword is described in [DCL22-C. Use volatile for data that cannot be cached](https://wiki.sei.cmu.edu/confluence/display/c/DCL22-C.+Use+volatile+for+data+that+cannot+be+cached).

The type `sig_atomic_t` is the integer type of an object that can be accessed as an atomic entity even in the presence of asynchronous interrupts. The type of `sig_atomic_t` is [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior), though it provides some guarantees. Integer values ranging from `SIG_ATOMIC_MIN` through `SIG_ATOMIC_MAX`, inclusive, may be safely stored to a variable of the type. In addition, when `sig_atomic_t` is a signed integer type, `SIG_ATOMIC_MIN` must be no greater than `−127` and `SIG_ATOMIC_MAX` no less than `127`. Otherwise, `SIG_ATOMIC_MIN` must be `0` and `SIG_ATOMIC_MAX` must be no less than `255`. The macros `SIG_ATOMIC_MIN` and `SIG_ATOMIC_MAX` are defined in the header `<stdint.h>`.

According to the C99 Rationale \[[C99 Rationale 2003](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-C992003)\], other than calling a limited, prescribed set of library functions,

> the C89 Committee concluded that about the only thing a [strictly conforming](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-strictlyconforming) program can do in a signal handler is to assign a value to a `volatile static` variable which can be written uninterruptedly and promptly return.


However, this issue was discussed at the April 2008 meeting of ISO/IEC WG14, and it was agreed that there are no known [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) in which it would be an error to read a value from a `volatile sig_atomic_t` variable, and the original intent of the committee was that both reading and writing variables of `volatile sig_atomic_t` would be strictly conforming.

The signal handler may also call a handful of functions, including `abort().` (See [SIG30-C. Call only asynchronous-safe functions within signal handlers](https://wiki.sei.cmu.edu/confluence/display/c/SIG30-C.+Call+only+asynchronous-safe+functions+within+signal+handlers) for more information.)

## Noncompliant Code Example

In this noncompliant code example, `err_msg` is updated to indicate that the `SIGINT` signal was delivered. The `err_msg` variable is a character pointer and not a variable of type `volatile sig_atomic_t`.

```cpp
#include <signal.h>
#include <stdlib.h>
#include <string.h>

enum { MAX_MSG_SIZE = 24 };
char *err_msg;

void handler(int signum) {
  strcpy(err_msg, "SIGINT encountered.");
}

int main(void) {
  signal(SIGINT, handler);

  err_msg = (char *)malloc(MAX_MSG_SIZE);
  if (err_msg == NULL) {
    /* Handle error */
  }
  strcpy(err_msg, "No errors yet.");
  /* Main code loop */
  return 0;
}

```

## Compliant Solution (Writing volatile sig_atomic_t)

For maximum portability, signal handlers should only unconditionally set a variable of type `volatile sig_atomic_t` and return, as in this compliant solution:

```cpp
#include <signal.h>
#include <stdlib.h>
#include <string.h>

enum { MAX_MSG_SIZE = 24 };
volatile sig_atomic_t e_flag = 0;

void handler(int signum) {
  e_flag = 1;
}

int main(void) {
  char *err_msg = (char *)malloc(MAX_MSG_SIZE);
  if (err_msg == NULL) {
    /* Handle error */
  }

  signal(SIGINT, handler);
  strcpy(err_msg, "No errors yet.");
  /* Main code loop */
  if (e_flag) {
    strcpy(err_msg, "SIGINT received.");
  } 
  return 0;
}

```

## Compliant Solution (Lock-Free Atomic Access)

Signal handlers can refer to objects with static or thread storage durations that are lock-free atomic objects, as in this compliant solution:

```cpp
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <stdatomic.h>
 
#ifdef __STDC_NO_ATOMICS__
#error "Atomics are not supported"
#elif ATOMIC_INT_LOCK_FREE == 0
#error "int is never lock-free"
#endif

atomic_int e_flag = ATOMIC_VAR_INIT(0);
 
void handler(int signum) {
  e_flag = 1;
}

int main(void) {
  enum { MAX_MSG_SIZE = 24 };
  char err_msg[MAX_MSG_SIZE];
#if ATOMIC_INT_LOCK_FREE == 1
  if (!atomic_is_lock_free(&e_flag)) {
    return EXIT_FAILURE;
  }
#endif
  if (signal(SIGINT, handler) == SIG_ERR) {
    return EXIT_FAILURE;
  }
  strcpy(err_msg, "No errors yet.");
  /* Main code loop */
  if (e_flag) {
    strcpy(err_msg, "SIGINT received.");
  }
  return EXIT_SUCCESS;
}

```

## Exceptions

**SIG31-C-EX1:** The C Standard, 7.14.1.1 paragraph 5 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\], makes a special exception for `errno` when a valid call to the `signal()` function results in a `SIG_ERR` return, allowing `errno` to take an indeterminate value. (See [ERR32-C. Do not rely on indeterminate values of errno](https://wiki.sei.cmu.edu/confluence/display/c/SIG31-C.+Do+not+access+shared+objects+in+signal+handlers#).)

## Risk Assessment

Accessing or modifying shared objects in signal handlers can result in accessing data in an inconsistent state. Michal Zalewski's paper "Delivering Signals for Fun and Profit" \[[Zalewski 2001](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Zalewski01)\] provides some examples of [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) that can result from violating this and other signal-handling rules.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> SIG31-C </td> <td> High </td> <td> Likely </td> <td> High </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>signal-handler-shared-access</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-SIG31</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>CONCURRENCY.DATARACE</strong> </td> <td> Data race </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule for single-file programs </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C2029, C2030</strong> <strong>C++3854, C++3855</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>87 D</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-SIG31-a</strong> </td> <td> Properly define signal handlers </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2765</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule SIG31-C </a> </td> <td> Checks for shared data access within signal handler (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2029, 2030</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>signal-handler-shared-access</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+SIG31-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Accessing shared objects in signal handlers \[accsig\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-662 </a> , Improper Synchronization </td> <td> 2017-07-10: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-828 </a> , Signal Handler with Functionality that is not Asynchronous-Safe </td> <td> 2017-10-30:MITRE:Unspecified Relationship 2018-10-19:CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-662 and SIG31-C**

CWE-662 = Union( SIG31-C, list) where list =

* Improper synchronization of shared objects between threads
* Improper synchronization of files between programs (enabling TOCTOU race conditions
**CWE-828 and SIG31-C**

CWE-828 = SIG31-C + non-async-safe things besides shared objects.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> C99 Rationale 2003 </a> \] </td> <td> 5.2.3, "Signals and Interrupts" </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.14.1.1, "The <code>signal</code> Function" </td> </tr> <tr> <td> \[ <a> Zalewski 2001 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

The implementation does not verify the correct usage of `atomic_is_lock_free`.

## References

* CERT-C: [SIG31-C: Do not access shared objects in signal handlers](https://wiki.sei.cmu.edu/confluence/display/c)
