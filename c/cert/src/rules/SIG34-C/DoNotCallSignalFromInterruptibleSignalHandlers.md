# SIG34-C: Do not call signal() from within interruptible signal handlers

This query implements the CERT-C rule SIG34-C:

> Do not call signal() from within interruptible signal handlers


## Description

A signal handler should not reassert its desire to handle its own signal. This is often done on *nonpersistent* platforms—that is, platforms that, upon receiving a signal, reset the handler for the signal to SIG_DFL before calling the bound signal handler. Calling` signal()` under these conditions presents a race condition. (See [SIG01-C. Understand implementation-specific details regarding signal handler persistence](https://wiki.sei.cmu.edu/confluence/display/c/SIG01-C.+Understand+implementation-specific+details+regarding+signal+handler+persistence).)

A signal handler may call `signal()` only if it does not need to be [asynchronous-safe](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-asynchronous-safefunction) (that is, if all relevant signals are masked so that the handler cannot be interrupted).

## Noncompliant Code Example (POSIX)

On nonpersistent platforms, this noncompliant code example contains a race window, starting when the host environment resets the signal and ending when the handler calls `signal()`. During that time, a second signal sent to the program will trigger the default signal behavior, consequently defeating the persistent behavior implied by the call to `signal()` from within the handler to reassert the binding.

If the environment is persistent (that is, it does not reset the handler when the signal is received), the `signal()` call from within the `handler()` function is redundant.

```cpp
#include <signal.h>
 
void handler(int signum) {
  if (signal(signum, handler) == SIG_ERR) {
    /* Handle error */
  }
  /* Handle signal */
}
 
void func(void) {
  if (signal(SIGUSR1, handler) == SIG_ERR) {
    /* Handle error */
  }
}
```

## Compliant Solution (POSIX)

Calling the `signal()` function from within the signal handler to reassert the binding is unnecessary for persistent platforms, as in this compliant solution:

```cpp
#include <signal.h>
 
void handler(int signum) {
  /* Handle signal */
}
 
void func(void) {
  if (signal(SIGUSR1, handler) == SIG_ERR) {
    /* Handle error */
  }
}
```

## Compliant Solution (POSIX)

POSIX defines the `sigaction()` function, which assigns handlers to signals in a similar manner to `signal()` but allows the caller to explicitly set persistence. Consequently, the `sigaction()` function can be used to eliminate the race window on nonpersistent platforms, as in this compliant solution:

```cpp
#include <signal.h>
#include <stddef.h>
 
void handler(int signum) {
  /* Handle signal */
}

void func(void) {
  struct sigaction act;
  act.sa_handler = handler;
  act.sa_flags = 0;
  if (sigemptyset(&act.sa_mask) != 0) {
    /* Handle error */
  }
  if (sigaction(SIGUSR1, &act, NULL) != 0) {
    /* Handle error */
  }
}
```
Although the handler in this example does not call `signal()`, it could do so safely because the signal is masked and the handler cannot be interrupted. If the same handler is installed for more than one signal, the signals must be masked explicitly in `act.sa_mask` to ensure that the handler cannot be interrupted because the system masks only the signal being delivered.

POSIX recommends that new applications should use `sigaction()` rather than `signal()`. The `sigaction()` function is not defined by the C Standard and is not supported on some platforms, including Windows.

## Compliant Solution (Windows)

There is no safe way to implement persistent signal-handler behavior on Windows platforms, and it should not be attempted. If a design depends on this behavior, and the design cannot be altered, it may be necessary to claim a deviation from this rule after completing an appropriate risk analysis.

The reason for this is that Windows is a nonpersistent platform as discussed above. Just before calling the current handler function, Windows resets the handler for the next occurrence of the same signal to `SIG_DFL`. If the handler calls `signal()` to reinstall itself, there is still a race window. A signal might occur between the start of the handler and the call to `signal()`, which would invoke the default behavior instead of the desired handler.

## Exceptions

**SIG34-C-EX1:** For implementations with persistent signal handlers, it is safe for a handler to modify the behavior of its own signal. Behavior modifications include ignoring the signal, resetting to the default behavior, and having the signal handled by a different handler. A handler reasserting its binding is also safe but unnecessary.

The following code example resets a signal handler to the system's default behavior:

```cpp
#include <signal.h>
 
void handler(int signum) {
#if !defined(_WIN32)
  if (signal(signum, SIG_DFL) == SIG_ERR) {
    /* Handle error */
  }
#endif
  /* Handle signal */
}
 
void func(void) {
  if (signal(SIGUSR1, handler) == SIG_ERR) {
    /* Handle error */
  }
}
```

## Risk Assessment

Two signals in quick succession can trigger a race condition on nonpersistent platforms, causing the signal's default behavior despite a handler's attempt to override it.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> SIG34-C </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>signal-handler-signal-call</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-SIG34</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>BADFUNC.SIGNAL</strong> </td> <td> Use of signal </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule. However, false positives may occur on systems with persistent handlers </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C5021</strong> <strong>C++5022</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.STDLIB.SIGNAL</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>97 D</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-SIG34-a</strong> </td> <td> Properly define signal handlers </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2762, 2763</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule SIG34-C </a> </td> <td> Checks for signal call from within signal handler (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>5021</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>5022</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>signal-handler-signal-call</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+SIG34-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> SIG01-C. Understand implementation-specific details regarding signal handler persistence </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Calling signal from interruptible signal handlers \[sigcall\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [SIG34-C: Do not call signal() from within interruptible signal handlers](https://wiki.sei.cmu.edu/confluence/display/c)
