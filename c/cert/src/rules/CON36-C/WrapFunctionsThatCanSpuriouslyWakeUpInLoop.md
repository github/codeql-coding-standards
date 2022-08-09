# CON36-C: Wrap functions that can spuriously wake up in a loop

This query implements the CERT-C rule CON36-C:

> Wrap functions that can spuriously wake up in a loop


## Description

The `cnd_wait()` and `cnd_timedwait()` functions temporarily cede possession of a mutex so that other threads that may be requesting the mutex can proceed. These functions must always be called from code that is protected by locking a mutex. The waiting thread resumes execution only after it has been notified, generally as the result of the invocation of the `cnd_signal()` or `cnd_broadcast()` function invoked by another thread. The `cnd_wait()` function must be invoked from a loop that checks whether a [condition predicate](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-conditionpredicate) holds. A condition predicate is an expression constructed from the variables of a function that must be true for a thread to be allowed to continue execution. The thread pauses execution, via `cnd_wait()`, `cnd_timedwait()`, or some other mechanism, and is resumed later, presumably when the condition predicate is true and the thread is notified.

```cpp
#include <threads.h>
#include <stdbool.h>
 
extern bool until_finish(void);
extern mtx_t lock;
extern cnd_t condition;
 
void func(void) {
  if (thrd_success != mtx_lock(&lock)) {
    /* Handle error */
  }

  while (until_finish()) {  /* Predicate does not hold */
    if (thrd_success != cnd_wait(&condition, &lock)) {
      /* Handle error */
    }
  }
 
  /* Resume when condition holds */

  if (thrd_success != mtx_unlock(&lock)) {
    /* Handle error */
  }
}
```
The notification mechanism notifies the waiting thread and allows it to check its condition predicate. The invocation of `cnd_broadcast()` in another thread cannot precisely determine which waiting thread will be resumed. Condition predicate statements allow notified threads to determine whether they should resume upon receiving the notification.

## Noncompliant Code Example

This noncompliant code example monitors a linked list and assigns one thread to consume list elements when the list is nonempty.

This thread pauses execution using `cnd_wait()` and resumes when notified, presumably when the list has elements to be consumed. It is possible for the thread to be notified even if the list is still empty, perhaps because the notifying thread used `cnd_broadcast()`, which notifies all threads. Notification using `cnd_broadcast()` is frequently preferred over using `cnd_signal().` (See [CON38-C. Preserve thread safety and liveness when using condition variables](https://wiki.sei.cmu.edu/confluence/display/c/CON38-C.+Preserve+thread+safety+and+liveness+when+using+condition+variables) for more information.)

A condition predicate is typically the negation of the condition expression in the loop. In this noncompliant code example, the condition predicate for removing an element from a linked list is `(list->next != NULL)`, whereas the condition expression for the `while` loop condition is `(list->next == NULL)`.

This noncompliant code example nests the `cnd_wait()` function inside an `if` block and consequently fails to check the condition predicate after the notification is received. If the notification was spurious or malicious, the thread would wake up prematurely.

```cpp
#include <stddef.h>
#include <threads.h>
 
struct node_t {
  void *node;
  struct node_t *next;
};
 
struct node_t list;
static mtx_t lock;
static cnd_t condition;
 
void consume_list_element(void) {
  if (thrd_success != mtx_lock(&lock)) {
    /* Handle error */
  }
 
  if (list.next == NULL) {
    if (thrd_success != cnd_wait(&condition, &lock)) {
      /* Handle error */
    }
  }

  /* Proceed when condition holds */

  if (thrd_success != mtx_unlock(&lock)) {
    /* Handle error */
  }
}
```

## Compliant Solution

This compliant solution calls the `cnd_wait()` function from within a `while` loop to check the condition both before and after the call to `cnd_wait()`:

```cpp
#include <stddef.h>
#include <threads.h>
 
struct node_t {
  void *node;
  struct node_t *next;
};
 
struct node_t list;
static mtx_t lock;
static cnd_t condition;
 
void consume_list_element(void) {
  if (thrd_success != mtx_lock(&lock)) {
    /* Handle error */
  }
 
  while (list.next == NULL) {
    if (thrd_success != cnd_wait(&condition, &lock)) {
      /* Handle error */
    }
  }

  /* Proceed when condition holds */

  if (thrd_success != mtx_unlock(&lock)) {
    /* Handle error */
  }
}
```

## Risk Assessment

Failure to enclose calls to the `cnd_wait()` or `cnd_timedwait()` functions inside a `while` loop can lead to indefinite blocking and [denial of service](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-denial-of-service) (DoS).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON36-C </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.ICOL</strong> <strong>CONCURRENCY.BADFUNC.CNDWAIT</strong> </td> <td> Inappropriate Call Outside Loop Use of Condition Variable Wait </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C2027</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.CONC.WAKE_IN_LOOP_C</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-CON36-a</strong> </td> <td> Wrap functions that can spuriously wake up in a loop </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule CON36-C </a> </td> <td> Checks for situations where functions that can spuriously wake up are not wrapped in loop (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2027</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON36-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> THI03-J. Always invoke wait() and await() methods inside a loop </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.17.7.4, "The <code>atomic_compare_exchange</code> Generic Functions" </td> </tr> <tr> <td> \[ <a> Lea 2000 </a> \] </td> <td> 1.3.2, "Liveness" 3.2.2, "Monitor Mechanics" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [CON36-C: Wrap functions that can spuriously wake up in a loop](https://wiki.sei.cmu.edu/confluence/display/c)
