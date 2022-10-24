# ENV32-C: All exit handlers must return normally

This query implements the CERT-C rule ENV32-C:

> All exit handlers must return normally


## Description

The C Standard provides three functions that cause an application to terminate normally: `_Exit()`, `exit()`, and `quick_exit()`. These are collectively called *exit functions*. When the `exit()` function is called, or control transfers out of the `main()` entry point function, functions registered with `atexit()` are called (but not `at_quick_exit()`). When the `quick_exit()` function is called, functions registered with `at_quick_exit()` (but not `atexit()`) are called. These functions are collectively called *exit handlers*. When the `_Exit()` function is called, no exit handlers or signal handlers are called.

Exit handlers must terminate by returning. It is important and potentially safety-critical for all exit handlers to be allowed to perform their cleanup actions. This is particularly true because the application programmer does not always know about handlers that may have been installed by support libraries. Two specific issues include nested calls to an exit function and terminating a call to an exit handler by invoking `longjmp`.

A nested call to an exit function is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 182](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).) This behavior can occur only when an exit function is invoked from an exit handler or when an exit function is called from within a signal handler. (See [SIG30-C. Call only asynchronous-safe functions within signal handlers](https://wiki.sei.cmu.edu/confluence/display/c/SIG30-C.+Call+only+asynchronous-safe+functions+within+signal+handlers).)

If a call to the `longjmp()` function is made that would terminate the call to a function registered with `atexit()`, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

In this noncompliant code example, the `exit1()` and `exit2()` functions are registered by `atexit()` to perform required cleanup upon program termination. However, if `some_condition` evaluates to true, `exit()` is called a second time, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <stdlib.h>

void exit1(void) {
  /* ... Cleanup code ... */
  return;
}
 
void exit2(void) {
  extern int some_condition;
  if (some_condition) {
    /* ... More cleanup code ... */
    exit(0);
  }
  return;
}

int main(void) {
  if (atexit(exit1) != 0) {
    /* Handle error */
  }
  if (atexit(exit2) != 0) {
    /* Handle error */
  }
  /* ... Program code ... */
  return 0;
}

```
Functions registered by the `atexit()` function are called in the reverse order from which they were registered. Consequently, if `exit2()` exits in any way other than by returning, `exit1()` will not be executed. The same may also be true for `atexit()` handlers installed by support libraries.

## Compliant Solution

A function that is registered as an exit handler by `atexit()` must exit by returning, as in this compliant solution:

```cpp
#include <stdlib.h>

void exit1(void) {
  /* ... Cleanup code ... */
  return;
}
 
void exit2(void) {
  extern int some_condition;
  if (some_condition) {
    /* ... More cleanup code ... */
  }
  return;
}

int main(void) {
  if (atexit(exit1) != 0) {
    /* Handle error */
  }
  if (atexit(exit2) != 0) {
    /* Handle error */
  }
  /* ... Program code ... */
  return 0;
}

```

## Noncompliant Code Example

In this noncompliant code example, `exit1()` is registered by `atexit()` so that upon program termination, `exit1()` is called. The `exit1()` function jumps back to `main()` to return, with undefined results.

```cpp
#include <stdlib.h>
#include <setjmp.h>

jmp_buf env;
int val;

void exit1(void) {
  longjmp(env, 1);
}

int main(void) {
  if (atexit(exit1) != 0) {
    /* Handle error */
  }
  if (setjmp(env) == 0) {
    exit(0);
  } else {
    return 0;
  }
}

```

## Compliant Solution

This compliant solution does not call `longjmp()``but instead returns from the exit handler normally:`

```cpp
#include <stdlib.h>

void exit1(void) {
  return;
}

int main(void) {
  if (atexit(exit1) != 0) {
    /* Handle error */
  }
  return 0;
}

```

## Risk Assessment

Terminating a call to an exit handler in any way other than by returning is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) and may result in [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination) or other unpredictable behavior. It may also prevent other registered handlers from being invoked.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ENV32-C </td> <td> Medium </td> <td> Likely </td> <td> Medium </td> <td> <strong>P12</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-ENV32</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.ABORT</strong> <strong>BADFUNC.EXIT</strong> <strong>BADFUNC.LONGJMP</strong> </td> <td> Use of abort Use of exit Use of longjmp </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule. In particular, it ensures that all functions registered with <code>atexit()</code> do not call functions such as <code>exit()</code> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4856, C4857, C4858</strong> <strong>C++4856, C++4857, C++4858</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.EXIT.HANDLER_TERMINATE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>122 S7 S</strong> </td> <td> Enhanced enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-ENV32-a</strong> </td> <td> Properly define exit handlers </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule ENV32-C </a> </td> <td> Checks for abnormal termination of exit handler (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ENV32-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> SIG30-C. Call only asynchronous-safe functions within signal handlers </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Structured Programming \[EWD\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Termination Strategy \[REU\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-705 </a> , Incorrect Control Flow Scoping </td> <td> 2017-07-10: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-705 and ENV32-C**

CWE-705 = Union( ENV32-C, list) where list =

* Improper control flow besides a non-returning exit handler

## Implementation notes

None

## References

* CERT-C: [ENV32-C: All exit handlers must return normally](https://wiki.sei.cmu.edu/confluence/display/c)
