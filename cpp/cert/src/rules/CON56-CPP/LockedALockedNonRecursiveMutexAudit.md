# CON56-CPP: (Audit) Do not speculatively lock a non-recursive mutex that is already owned by the calling thread

This query implements the CERT-C++ rule CON56-CPP:

> Do not speculatively lock a non-recursive mutex that is already owned by the calling thread


## Description

The C++ Standard Library supplies both recursive and non-recursive mutex classes used to protect [critical sections](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-criticalsections). The recursive mutex classes (`std::recursive_mutex` and `std::recursive_timed_mutex`) differ from the non-recursive mutex classes (`std::mutex`, `std::timed_mutex`, and `std::shared_timed_mutex`) in that a recursive mutex may be locked recursively by the thread that currently owns the mutex. All mutex classes support the ability to speculatively lock the mutex through functions such as `try_lock()`, `try_lock_for()`, `try_lock_until()`, `try_lock_shared_for()`, and `try_lock_shared_until()`. These speculative locking functions attempt to obtain ownership of the mutex for the calling thread, but will not block in the event the ownership cannot be obtained. Instead, they return a Boolean value specifying whether the ownership of the mutex was obtained or not.

The C++ Standard, \[thread.mutex.requirements.mutex\], paragraphs 14 and 15 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], state the following:

> The expression `m.try_lock()` shall be well-formed and have the following semantics:Requires: If `m` is of type `std::mutex`, `std::timed_mutex`, or `std::shared_timed_mutex`, the calling thread does not own the mutex.


Further, \[thread.timedmutex.class\], paragraph 3, in part, states the following:

> The behavior of a program is undefined if:— a thread that owns a `timed_mutex` object calls `lock()`, `try_lock()`, `try_lock_for()`, or `try_lock_until()` on that object


Finally, \[thread.sharedtimedmutex.class\], paragraph 3, in part, states the following:

> The behavior of a program is undefined if:— a thread attempts to recursively gain any ownership of a `shared_timed_mutex`.


Thus, attempting to speculatively lock a non-recursive mutex object that is already owned by the calling thread is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). Do not call `try_lock()`, `try_lock_for()`, `try_lock_until()`, `try_lock_shared_for()`, or `try_lock_shared_until()` on a non-recursive mutex object from a thread that already owns that mutex object.

## Noncompliant Code Example

In this noncompliant code example, the mutex `m` is locked by the thread's initial entry point and is speculatively locked in the `do_work()` function from the same thread, resulting in undefined behavior because it is not a recursive mutex. With common implementations, this may result in [deadlock](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-deadlock).

```cpp
#include <mutex>
#include <thread>

std::mutex m;

void do_thread_safe_work();

void do_work() {
  while (!m.try_lock()) {
    // The lock is not owned yet, do other work while waiting.
    do_thread_safe_work();
  }
  try {

    // The mutex is now locked; perform work on shared resources.
    // ...

  // Release the mutex.
  catch (...) {
    m.unlock();
    throw;
  }
  m.unlock();
}

void start_func() {
  std::lock_guard<std::mutex> lock(m);
  do_work();
}

int main() {
  std::thread t(start_func);

  do_work();

  t.join();
}

```

## Compliant Solution

This compliant solution removes the lock from the thread's initial entry point, allowing the mutex to be speculatively locked, but not recursively.

```cpp
#include <mutex>
#include <thread>

std::mutex m;

void do_thread_safe_work();

void do_work() {
  while (!m.try_lock()) {
    // The lock is not owned yet, do other work while waiting.
    do_thread_safe_work();
  }
  try {
    // The mutex is now locked; perform work on shared resources.
    // ...

  // Release the mutex.
  catch (...) {
    m.unlock();
    throw;
  }
  m.unlock();
}

void start_func() {
  do_work();
}

int main() {
  std::thread t(start_func);

  do_work();

  t.join();
}
```

## Risk Assessment

Speculatively locking a non-recursive mutex in a recursive manner is undefined behavior that can lead to deadlock.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON56-CPP </td> <td> Low </td> <td> Unlikely </td> <td> High </td> <td> <strong>P1</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>CONCURRENCY.TL</strong> </td> <td> Try-lock that will never succeed </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4986, C++4987</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CON56-a</strong> </td> <td> Avoid double locking </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON56-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-667 </a> , Improper Locking </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 30.4.1, "Mutex Requirements" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CON56-CPP: Do not speculatively lock a non-recursive mutex that is already owned by the calling thread](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
