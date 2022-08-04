# CON54-CPP: Wrap functions that can spuriously wake up in a loop

This query implements the CERT-C++ rule CON54-CPP:

> Wrap functions that can spuriously wake up in a loop


## Description

The `wait()`, `wait_for()`, and `wait_until()` member functions of the `std::condition_variable` class temporarily cede possession of a mutex so that other threads that may be requesting the mutex can proceed. These functions must always be called from code that is protected by locking a mutex. The waiting thread resumes execution only after it has been notified, generally as the result of the invocation of the `notify_one()` or `notify_all()` member functions invoked by another thread.

The `wait()` function must be invoked from a loop that checks whether a [condition predicate](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-conditionpredicate) holds. A condition predicate is an expression constructed from the variables of a function that must be true for a thread to be allowed to continue execution. The thread pauses execution via `wait()`, `wait_for()`, `wait_until()`, or some other mechanism, and is resumed later, presumably when the condition predicate is true and the thread is notified.

```cpp
#include <condition_variable>
#include <mutex>
 
extern bool until_finish(void);
extern std::mutex m;
extern std::condition_variable condition;
 
void func(void) {
  std::unique_lock<std::mutex> lk(m);

  while (until_finish()) {  // Predicate does not hold.
    condition.wait(lk);
  }
 
  // Resume when condition holds.
}
```
The notification mechanism notifies the waiting thread and allows it to check its condition predicate. The invocation of `notify_all()` in another thread cannot precisely determine which waiting thread will be resumed. Condition predicate statements allow notified threads to determine whether they should resume upon receiving the notification.

## Noncompliant Code Example

This noncompliant code example monitors a linked list and assigns one thread to consume list elements when the list is nonempty.

This thread pauses execution using `wait()` and resumes when notified, presumably when the list has elements to be consumed. It is possible for the thread to be notified even if the list is still empty, perhaps because the notifying thread used `notify_all()`, which notifies all threads. Notification using `notify_all()` is frequently preferred over using `notify_one()`. (See [CON55-CPP. Preserve thread safety and liveness when using condition variables](https://wiki.sei.cmu.edu/confluence/display/cplusplus/CON55-CPP.+Preserve+thread+safety+and+liveness+when+using+condition+variables) for more information.)

A condition predicate is typically the negation of the condition expression in the loop. In this noncompliant code example, the condition predicate for removing an element from a linked list is `(list->next != nullptr)`, whereas the condition expression for the `while` loop condition is `(list->next == nullptr)`.

This noncompliant code example nests the call to `wait()` inside an `if` block and consequently fails to check the condition predicate after the notification is received. If the notification was spurious or malicious, the thread would wake up prematurely.

```cpp
#include <condition_variable>
#include <mutex>
 
struct Node {
  void *node;
  struct Node *next;
};
  
static Node list;
static std::mutex m;
static std::condition_variable condition;
  
void consume_list_element(std::condition_variable &condition) {
  std::unique_lock<std::mutex> lk(m);
  
  if (list.next == nullptr) {
    condition.wait(lk);
  }
 
  // Proceed when condition holds.
}
```

## Compliant Solution (Explicit loop with predicate)

This compliant solution calls the `wait()` member function from within a `while` loop to check the condition both before and after the call to `wait()`.

```cpp
#include <condition_variable>
#include <mutex>
 
struct Node {
  void *node;
  struct Node *next;
};
  
static Node list;
static std::mutex m;
static std::condition_variable condition;
  
void consume_list_element() {
  std::unique_lock<std::mutex> lk(m);
  
  while (list.next == nullptr) {
    condition.wait(lk);
  }
 
  // Proceed when condition holds.
}
```

## Compliant Solution (Implicit loop with lambda predicate)

The `std::condition_variable::wait()` function has an overloaded form that accepts a function object representing the predicate. This form of `wait()` behaves as if it were implemented as `while (!pred()) wait(lock);`. This compliant solution uses a lambda as a predicate and passes it to the `wait()` function. The predicate is expected to return true when it is safe to proceed, which reverses the predicate logic from the compliant solution using an explicit loop predicate.

```cpp
#include <condition_variable>
#include <mutex>
 
struct Node {
  void *node;
  struct Node *next;
};
  
static Node list;
static std::mutex m;
static std::condition_variable condition;
  
void consume_list_element() {
  std::unique_lock<std::mutex> lk(m);
 
  condition.wait(lk, []{ return list.next; });
  // Proceed when condition holds.
}
```

## Risk Assessment

Failure to enclose calls to the `wait()`, `wait_for()`, or `wait_until()` member functions inside a `while` loop can lead to indefinite blocking and [denial of service](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service) (DoS).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON54-CPP </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.ICOL</strong> <strong>CONCURRENCY.BADFUNC.CNDWAIT</strong> </td> <td> Inappropriate Call Outside Loop Use of Condition Variable Wait </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++5019</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.CONC.WAKE_IN_LOOP</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CON54-a</strong> </td> <td> Wrap functions that can spuriously wake up in a loop </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: CON54-CPP </a> </td> <td> Checks for situations where functions that can spuriously wake up are not wrapped in loop </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>5019</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON54-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> THI03-J. Always invoke wait() and await() methods inside a loop </a> </td> </tr> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> CON36-C. Wrap functions that can spuriously wake up in a loop </a> </td> </tr> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> CON55-CPP. Preserve thread safety and liveness when using condition variables </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.17.7.4, "The <code>atomic_compare_exchange</code> Generic Functions" </td> </tr> <tr> <td> \[ <a> Lea 2000 </a> \] </td> <td> 1.3.2, "Liveness" 3.2.2, "Monitor Mechanics" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CON54-CPP: Wrap functions that can spuriously wake up in a loop](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
