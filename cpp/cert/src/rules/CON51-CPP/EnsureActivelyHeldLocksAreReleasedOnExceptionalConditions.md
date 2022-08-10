# CON51-CPP: Ensure actively held locks are released on exceptional conditions

This query implements the CERT-C++ rule CON51-CPP:

> Ensure actively held locks are released on exceptional conditions


## Description

Mutexes that are used to protect accesses to shared data may be locked using the `lock()` member function and unlocked using the `unlock()` member function. If an exception occurs between the call to `lock()` and the call to `unlock()`, and the exception changes control flow such that `unlock()` is not called, the mutex will be left in the locked state and no [critical sections](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-criticalsections) protected by that mutex will be allowed to execute. This is likely to lead to deadlock.

The throwing of an exception must not allow a mutex to remain locked indefinitely. If a mutex was locked and an exception occurs within the critical section protected by that mutex, the mutex must be unlocked as part of exception handling before rethrowing the exception or continuing execution unless subsequent control flow will unlock the mutex.

C++ supplies the lock classes `lock_guard`, `unique_lock`, and `shared_lock`, which can be initialized with a mutex. In its constructor, the lock object locks the mutex, and in its destructor, it unlocks the mutex. The `lock_guard` class provides a simple [RAII](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-RAII) wrapper around a mutex. The `unique_lock` and `shared_lock` classes also use RAII and provide additional functionality, such as manual control over the locking strategy. The `unique_lock` class prevents the lock from being copied, although it allows the lock ownership to be moved to another lock. The `shared_lock` class allows the mutex to be shared by several locks. For all three classes, if an exception occurs and takes control flow out of the scope of the lock, the destructor will unlock the mutex and the program can continue working normally. These lock objects are the preferred way to ensure that a mutex is properly released when an exception is thrown.

Noncompliant Code Example

This noncompliant code example manipulates shared data and protects the critical section by locking the mutex. When it is finished, it unlocks the mutex. However, if an exception occurs while manipulating the shared data, the mutex will remain locked.

```cpp
#include <mutex>

void manipulate_shared_data(std::mutex &pm) {
  pm.lock();

  // Perform work on shared data.

  pm.unlock();
}

```

## Compliant Solution (Manual Unlock)

This compliant solution catches any exceptions thrown when performing work on the shared data and unlocks the mutex before rethrowing the exception.

```cpp
#include <mutex>

void manipulate_shared_data(std::mutex &pm) {
  pm.lock();
  try {
    // Perform work on shared data.
  } catch (...) {
    pm.unlock();
    throw;
  }
  pm.unlock(); // in case no exceptions occur
}
```

## Compliant Solution (Lock Object)

This compliant solution uses a `lock_guard` object to ensure that the mutex will be unlocked, even if an exception occurs, without relying on exception handling machinery and manual resource management.

```cpp
#include <mutex>

void manipulate_shared_data(std::mutex &pm) {
  std::lock_guard<std::mutex> lk(pm);

  // Perform work on shared data.
}

```

## Risk Assessment

If an exception occurs while a mutex is locked, deadlock may result.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON51-CPP </td> <td> Low </td> <td> Probable </td> <td> Low </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>CONCURRENCY.LOCK.NOUNLOCK</strong> </td> <td> Missing Lock Release </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++5018</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CON51-a</strong> </td> <td> Do not call lock() directly on a mutex </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>5018</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON51-CPP).

## Related Guidelines

*This rule is a subset of [ERR56-CPP. Guarantee exception safety](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR56-CPP.+Guarantee+exception+safety).*

<table> <tbody> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-667 </a> , Improper Locking </td> </tr> <tr> <td> <a> SEI CERT Oracle Coding Standard for Java </a> </td> <td> <a> LCK08-J. Ensure actively held locks are released on exceptional conditions </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 30.4.2, "Locks" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CON51-CPP: Ensure actively held locks are released on exceptional conditions](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
