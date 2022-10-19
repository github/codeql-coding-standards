# CON39-C: Do not join or detach a thread that was previously joined or detached

This query implements the CERT-C rule CON39-C:

> Do not join or detach a thread that was previously joined or detached


## Description

The C Standard, 7.26.5.6 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states that a thread shall not be joined once it was previously joined or detached. Similarly, subclause 7.26.5.3 states that a thread shall not be detached once it was previously joined or detached. Violating either of these subclauses results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

This noncompliant code example detaches a thread that is later joined.

```cpp
#include <stddef.h>
#include <threads.h>
 
int thread_func(void *arg) {
  /* Do work */
  thrd_detach(thrd_current());
  return 0;
}

int main(void) {
  thrd_t t;

  if (thrd_success != thrd_create(&t, thread_func, NULL)) {
    /* Handle error */
    return 0;
  }

  if (thrd_success != thrd_join(t, 0)) {
    /* Handle error */
    return 0;
  }
  return 0;
}
```

## Compliant Solution

This compliant solution does not detach the thread. Its resources are released upon successfully joining with the main thread:

```cpp
#include <stddef.h>
#include <threads.h>
  
int thread_func(void *arg) {
  /* Do work */
  return 0;
}

int main(void) {
  thrd_t t;

  if (thrd_success != thrd_create(&t, thread_func, NULL)) {
    /* Handle error */
    return 0;
  }

  if (thrd_success != thrd_join(t, 0)) {
    /* Handle error */
    return 0;
  }
  return 0;
} 
```

## Risk Assessment

Joining or detaching a previously joined or detached thread is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON39-C </td> <td> Low </td> <td> Likely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.1p0 </td> <td> <strong>CONCURRENCY.TNJ</strong> </td> <td> Thread is not Joinable </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.3 </td> <td> <strong>C1776</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-CON39-a</strong> </td> <td> Do not join or detach a thread that was previously joined or detached </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule CON39-C </a> </td> <td> Checks for join or detach of a joined or detached thread (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON39-C).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.26.5.3, "The <code>thrd_detach</code> Function" Subclause 7.26.5.6, "The <code>thrd_join</code> Function" </td> </tr> </tbody> </table>


## Implementation notes

This query considers problematic usages of join and detach irrespective of the execution of the program and other synchronization and interprocess communication mechanisms that may be used.

## References

* CERT-C: [CON39-C: Do not join or detach a thread that was previously joined or detached](https://wiki.sei.cmu.edu/confluence/display/c)
