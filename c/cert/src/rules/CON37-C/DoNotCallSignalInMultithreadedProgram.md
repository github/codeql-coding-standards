# CON37-C: Do not call signal() in a multithreaded program

This query implements the CERT-C rule CON37-C:

> Do not call signal() in a multithreaded program


## Description

Calling the `signal()` function in a multithreaded program is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 135](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_135).)

## Noncompliant Code Example

This noncompliant code example invokes the `signal()` function from a multithreaded program:

```cpp
#include <signal.h>
#include <stddef.h>
#include <threads.h>
 
volatile sig_atomic_t flag = 0;

void handler(int signum) {
  flag = 1;
}

/* Runs until user sends SIGUSR1 */
int func(void *data) {
  while (!flag) {
    /* ... */
  }
  return 0;
}

int main(void) {
  signal(SIGUSR1, handler); /* Undefined behavior */
  thrd_t tid;
  
  if (thrd_success != thrd_create(&tid, func, NULL)) {
    /* Handle error */
  }
  /* ... */
  return 0;
}
```
NOTE: The `SIGUSR1` signal value is not defined in the C Standard; consequently, this is not a C-compliant code example.

## Compliant Solution

This compliant solution uses an object of type `atomic_bool` to indicate when the child thread should terminate its loop:

```cpp
#include <stdatomic.h>
#include <stdbool.h>
#include <stddef.h>
#include <threads.h>
 
atomic_bool flag = ATOMIC_VAR_INIT(false);

int func(void *data) {
  while (!flag) {
    /* ... */
  }
  return 0;
}

int main(void) {
  thrd_t tid;
  
  if (thrd_success != thrd_create(&tid, func, NULL)) {
    /* Handle error */
  }
  /* ... */
  /* Set flag when done */
  flag = true;

  return 0;
}
```

## Exceptions

**CON37-C-EX1:** Implementations such as POSIX that provide defined behavior when multithreaded programs use custom signal handlers are exempt from this rule \[[IEEE Std 1003.1-2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\].

## Risk Assessment

Mixing signals and threads causes [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON37-C </td> <td> Low </td> <td> Probable </td> <td> Low </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON37-C).

## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>stdlib-use-signal</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.SIGNAL</strong> </td> <td> Use of signal </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2012 Rule 21.5</strong> </td> <td> Over-constraining </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C5021</strong> <strong>C++5022</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.STDLIB.SIGNAL</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>44 S</strong> </td> <td> Enhanced enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-CON37-a</strong> </td> <td> The signal handling facilities of &lt;signal.h&gt; shall not be used </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>586</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule CON37-C </a> </td> <td> Checks for signal call in multithreaded program (rule fully covered) </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>stdlib-use-signal</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>5021</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>5022</strong> </td> <td> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE Std 1003.1-2013 </a> \] </td> <td> XSH 2.9.1, "Thread Safety" </td> </tr> </tbody> </table>


## Implementation notes

This implementation does not consider threads created function pointers.

## References

* CERT-C: [CON37-C: Do not call signal() in a multithreaded program](https://wiki.sei.cmu.edu/confluence/display/c)
