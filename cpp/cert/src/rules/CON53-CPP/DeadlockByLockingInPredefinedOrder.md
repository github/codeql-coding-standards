# CON53-CPP: Avoid deadlock by locking in a predefined order

This query implements the CERT-C++ rule CON53-CPP:

> Avoid deadlock by locking in a predefined order


## Description

Mutexes are used to prevent multiple threads from causing a [data race](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-datarace) by accessing the same shared resource at the same time. Sometimes, when locking mutexes, multiple threads hold each other's lock, and the program consequently [deadlocks](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-deadlock). Four conditions are required for deadlock to occur:

* mutual exclusion (At least one nonshareable resource must be held.),
* hold and wait (A thread must hold a resource while awaiting availability of another resource.),
* no preemption (Resources cannot be taken away from a thread while they are in-use.), and
* circular wait (A thread must await a resource held by another thread which is, in turn, awaiting a resource held by the first thread.).
Deadlock needs all four conditions, so preventing deadlock requires preventing any one of the four conditions. One simple solution is to lock the mutexes in a predefined order, which prevents circular wait.

## Noncompliant Code Example

The behavior of this noncompliant code example depends on the runtime environment and the platform's scheduler. The program is susceptible to deadlock if thread `thr1 `attempts to lock `ba2`'s mutex at the same time thread `thr2` attempts to lock `ba1`'s mutex in the `deposit()` function.

```cpp
#include <mutex>
#include <thread>
 
class BankAccount {
  int balance;
public:
  std::mutex balanceMutex;
  BankAccount() = delete;
  explicit BankAccount(int initialAmount) : balance(initialAmount) {}
  int get_balance() const { return balance; }
  void set_balance(int amount) { balance = amount; }
};
 
int deposit(BankAccount *from, BankAccount *to, int amount) {
  std::lock_guard<std::mutex> from_lock(from->balanceMutex);
 
  // Not enough balance to transfer.
  if (from->get_balance() < amount) {
    return -1; // Indicate error
  }
  std::lock_guard<std::mutex> to_lock(to->balanceMutex);
 
  from->set_balance(from->get_balance() - amount);
  to->set_balance(to->get_balance() + amount);
 
  return 0;
}
 
void f(BankAccount *ba1, BankAccount *ba2) {
  // Perform the deposits.
  std::thread thr1(deposit, ba1, ba2, 100);
  std::thread thr2(deposit, ba2, ba1, 100);
  thr1.join();
  thr2.join();
}
```

## Compliant Solution (Manual Ordering)

This compliant solution eliminates the circular wait condition by establishing a predefined order for locking in the `deposit()` function. Each thread will lock on the basis of the `BankAccount` ID, which is set when the `BankAccount` object is initialized.

```cpp
#include <atomic>
#include <mutex>
#include <thread>
 
class BankAccount {
  static std::atomic<unsigned int> globalId;
  const unsigned int id;
  int balance;
public:
  std::mutex balanceMutex;
  BankAccount() = delete;
  explicit BankAccount(int initialAmount) : id(globalId++), balance(initialAmount) {}
  unsigned int get_id() const { return id; }
  int get_balance() const { return balance; }
  void set_balance(int amount) { balance = amount; }
};

std::atomic<unsigned int> BankAccount::globalId(1);
 
int deposit(BankAccount *from, BankAccount *to, int amount) {
  std::mutex *first;
  std::mutex *second;
 
  if (from->get_id() == to->get_id()) {
    return -1; // Indicate error
  }
 
  // Ensure proper ordering for locking.
  if (from->get_id() < to->get_id()) {
    first = &from->balanceMutex;
    second = &to->balanceMutex;
  } else {
    first = &to->balanceMutex;
    second = &from->balanceMutex;
  }
  std::lock_guard<std::mutex> firstLock(*first);
  std::lock_guard<std::mutex> secondLock(*second);
 
  // Check for enough balance to transfer.
  if (from->get_balance() >= amount) {
    from->set_balance(from->get_balance() - amount);
    to->set_balance(to->get_balance() + amount);
    return 0;
  }
  return -1;
}
 
void f(BankAccount *ba1, BankAccount *ba2) {
  // Perform the deposits.
  std::thread thr1(deposit, ba1, ba2, 100);
  std::thread thr2(deposit, ba2, ba1, 100);
  thr1.join();
  thr2.join();
}
```

## Compliant Solution (std::lock())

This compliant solution uses Standard Template Library facilities to ensure that deadlock does not occur due to circular wait conditions. The `std::lock()` function takes a variable number of lockable objects and attempts to lock them such that deadlock does not occur \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]. In typical implementations, this is done by using a combination of `lock()`, `try_lock()`, and `unlock()` to attempt to lock the object and backing off if the lock is not acquired, which may have worse performance than a solution that locks in predefined order explicitly.

```cpp
#include <mutex>
#include <thread>
 
class BankAccount {
  int balance;
public:
  std::mutex balanceMutex;
  BankAccount() = delete;
  explicit BankAccount(int initialAmount) : balance(initialAmount) {}
  int get_balance() const { return balance; }
  void set_balance(int amount) { balance = amount; }
};
 
int deposit(BankAccount *from, BankAccount *to, int amount) {
  // Create lock objects but defer locking them until later.
  std::unique_lock<std::mutex> lk1(from->balanceMutex, std::defer_lock);
  std::unique_lock<std::mutex> lk2(to->balanceMutex, std::defer_lock);

  // Lock both of the lock objects simultaneously.
  std::lock(lk1, lk2);

  if (from->get_balance() >= amount) {
    from->set_balance(from->get_balance() - amount);
    to->set_balance(to->get_balance() + amount);
    return 0;
  }
  return -1;
}
 
void f(BankAccount *ba1, BankAccount *ba2) {
  // Perform the deposits.
  std::thread thr1(deposit, ba1, ba2, 100);
  std::thread thr2(deposit, ba2, ba1, 100);
  thr1.join();
  thr2.join();
}
```

## Risk Assessment

Deadlock prevents multiple threads from progressing, halting program execution. A [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service) is possible if the attacker can create the conditions for deadlock.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON53-CPP </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>CONCURRENCY.LOCK.ORDER</strong> </td> <td> Conflicting lock order </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 6.5 </td> <td> <strong>DEADLOCK</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++1772, C++1773</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CON53-a</strong> </td> <td> Do not acquire locks in different order </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: CON53-CPP </a> </td> <td> Checks for deadlocks </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>1772, 1773</strong> </td> <td> Enforced by MTA </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON53-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> LCK07-J. Avoid deadlock by requesting and releasing locks in the same order </a> </td> </tr> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> CON35-C. Avoid deadlock by locking in a predefined order </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-764 </a> , Multiple Locks of a Critical Resource </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 30.4, "Mutual Exclusion" Subclause 30.4.3, "Generic Locking Algorithms" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CON53-CPP: Avoid deadlock by locking in a predefined order](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
