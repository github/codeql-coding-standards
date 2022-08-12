# CON31-C: Do not destroy a mutex while it is locked

This query implements the CERT-C rule CON31-C:

> Do not destroy a mutex while it is locked


## Description

Mutexes are used to protect shared data structures being concurrently accessed. If a mutex is destroyed while a thread is blocked waiting for that mutex, [critical sections](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-criticalsections) and shared data are no longer protected.

The C Standard, 7.26.4.1, paragraph 2 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> The `mtx_destroy` function releases any resources used by the mutex pointed to by `mtx`. No threads can be blocked waiting for the mutex pointed to by `mtx`.


This statement implies that destroying a mutex while a thread is waiting on it is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

This noncompliant code example creates several threads that each invoke the `do_work()` function, passing a unique number as an ID. The `do_work()` function initializes the `lock` mutex if the argument is 0 and destroys the mutex if the argument is `max_threads - 1`. In all other cases, the `do_work()` function provides normal processing. Each thread, except the final cleanup thread, increments the atomic `completed` variable when it is finished.

Unfortunately, this code contains several race conditions, allowing the mutex to be destroyed before it is unlocked. Additionally, there is no guarantee that `lock` will be initialized before it is passed to `mtx_lock()`. Each of these behaviors is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <stdatomic.h>
#include <stddef.h>
#include <threads.h>
 
mtx_t lock;
/* Atomic so multiple threads can modify safely */
atomic_int completed = ATOMIC_VAR_INIT(0);
enum { max_threads = 5 }; 

int do_work(void *arg) {
  int *i = (int *)arg;

  if (*i == 0) { /* Creation thread */
    if (thrd_success != mtx_init(&lock, mtx_plain)) {
      /* Handle error */
    }
    atomic_store(&completed, 1);
  } else if (*i < max_threads - 1) { /* Worker thread */
    if (thrd_success != mtx_lock(&lock)) {
      /* Handle error */
    }
    /* Access data protected by the lock */
    atomic_fetch_add(&completed, 1);
    if (thrd_success != mtx_unlock(&lock)) {
      /* Handle error */
    }
  } else { /* Destruction thread */
    mtx_destroy(&lock);
  }
  return 0;
}
 
int main(void) {
  thrd_t threads[max_threads];
  
  for (size_t i = 0; i < max_threads; i++) {
    if (thrd_success != thrd_create(&threads[i], do_work, &i)) {
      /* Handle error */
    }
  }
  for (size_t i = 0; i < max_threads; i++) {
    if (thrd_success != thrd_join(threads[i], 0)) {
      /* Handle error */
    }
  }
  return 0;
}

```

## Compliant Solution

This compliant solution eliminates the race conditions by initializing the mutex in `main()` before creating the threads and by destroying the mutex in `main()` after joining the threads:

```cpp
#include <stdatomic.h>
#include <stddef.h>
#include <threads.h>
 
mtx_t lock;
/* Atomic so multiple threads can increment safely */
atomic_int completed = ATOMIC_VAR_INIT(0);
enum { max_threads = 5 }; 

int do_work(void *dummy) {
  if (thrd_success != mtx_lock(&lock)) {
    /* Handle error */
  }
  /* Access data protected by the lock */
  atomic_fetch_add(&completed, 1);
  if (thrd_success != mtx_unlock(&lock)) {
    /* Handle error */
  }

  return 0;
}

int main(void) {
  thrd_t threads[max_threads];
  
  if (thrd_success != mtx_init(&lock, mtx_plain)) {
    /* Handle error */
  }
  for (size_t i = 0; i < max_threads; i++) {
    if (thrd_success != thrd_create(&threads[i], do_work, NULL)) {
      /* Handle error */
    }
  }
  for (size_t i = 0; i < max_threads; i++) {
    if (thrd_success != thrd_join(threads[i], 0)) {
      /* Handle error */
    }
  }

  mtx_destroy(&lock);
  return 0;
}

```

## Risk Assessment

Destroying a mutex while it is locked may result in invalid control flow and data corruption.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON31-C </td> <td> Medium </td> <td> Probable </td> <td> High </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>CONCURRENCY.LOCALARG</strong> </td> <td> Local Variable Passed to Thread </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4961, C4962</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>4961, 4962 </strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-CON31-a</strong> <strong>CERT_C-CON31-b</strong> <strong>CERT_C-CON31-c</strong> </td> <td> Do not destroy another thread's mutex Do not use resources that have been freed Do not free resources using invalid pointers </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule CON31-C </a> </td> <td> Checks for destruction of locked mutex (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON31-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-667 </a> , Improper Locking </td> <td> 2017-07-10: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-667 and CON31-C/POS48-C**

Intersection( CON31-C, POS48-C) = Ø

CWE-667 = Union, CON31-C, POS48-C, list) where list =

* Locking &amp; Unlocking issues besides unlocking another thread’s C mutex or pthread mutex.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.26.4.1, "The <code>mtx_destroy</code> Function" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [CON31-C: Do not destroy a mutex while it is locked](https://wiki.sei.cmu.edu/confluence/display/c)
