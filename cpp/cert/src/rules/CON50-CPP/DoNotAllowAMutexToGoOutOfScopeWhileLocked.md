# CON50-CPP: Do not destroy a mutex while it is locked

This query implements the CERT-C++ rule CON50-CPP:

> Do not destroy a mutex while it is locked


## Description

Mutex objects are used to protect shared data from being concurrently accessed. If a mutex object is destroyed while a thread is blocked waiting for the lock, [critical sections](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-criticalsections) and shared data are no longer protected.

The C++ Standard, \[thread.mutex.class\], paragraph 5 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> The behavior of a program is undefined if it destroys a `mutex` object owned by any thread or a thread terminates while owning a `mutex` object.


Similar wording exists for `std::recursive_mutex`, `std::timed_mutex`, `std::recursive_timed_mutex`, and `std::shared_timed_mutex`. These statements imply that destroying a mutex object while a thread is waiting on it is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

This noncompliant code example creates several threads that each invoke the `do_work()` function, passing a unique number as an ID.

Unfortunately, this code contains a race condition, allowing the mutex to be destroyed while it is still owned, because `start_threads()` may invoke the mutex's destructor before all of the threads have exited.

```cpp
#include <mutex>
#include <thread>

const size_t maxThreads = 10;

void do_work(size_t i, std::mutex *pm) {
  std::lock_guard<std::mutex> lk(*pm);

  // Access data protected by the lock.
}

void start_threads() {
  std::thread threads[maxThreads];
  std::mutex m;

  for (size_t i = 0; i < maxThreads; ++i) {
    threads[i] = std::thread(do_work, i, &m);
  }
}

```

## Compliant Solution

This compliant solution eliminates the race condition by extending the lifetime of the mutex.

```cpp
#include <mutex>
#include <thread>

const size_t maxThreads = 10;

void do_work(size_t i, std::mutex *pm) {
  std::lock_guard<std::mutex> lk(*pm);

  // Access data protected by the lock.
}

std::mutex m;

void start_threads() {
  std::thread threads[maxThreads];

  for (size_t i = 0; i < maxThreads; ++i) {
    threads[i] = std::thread(do_work, i, &m);
  }
}

```

## Compliant Solution

This compliant solution eliminates the race condition by joining the threads before the mutex's destructor is invoked.

```cpp
#include <mutex>
#include <thread>

const size_t maxThreads = 10;

void do_work(size_t i, std::mutex *pm) {
  std::lock_guard<std::mutex> lk(*pm);

  // Access data protected by the lock.
}
void run_threads() {
  std::thread threads[maxThreads];
  std::mutex m;

  for (size_t i = 0; i < maxThreads; ++i) {
    threads[i] = std::thread(do_work, i, &m);
  }

  for (size_t i = 0; i < maxThreads; ++i) {
    threads[i].join();
  }
}
```

## Risk Assessment

Destroying a mutex while it is locked may result in invalid control flow and data corruption.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON50-CPP </td> <td> Medium </td> <td> Probable </td> <td> High </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>CONCURRENCY.LOCALARG</strong> </td> <td> Local Variable Passed to Thread </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4961, C++4962</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.CONC.MUTEX.DESTROY_WHILE_LOCKED</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CON50-a</strong> </td> <td> Do not destroy another thread's mutex </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: CON50-CPP </a> </td> <td> Checks for destruction of locked mutex (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4961, 4962</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON50-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-667 </a> , Improper Locking </td> </tr> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> CON31-C. Do not destroy a mutex while it is locked </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 30.4.1, "Mutex Requirements" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CON50-CPP: Do not destroy a mutex while it is locked](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
