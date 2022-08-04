# ERR51-CPP: Handle all exceptions

This query implements the CERT-C++ rule ERR51-CPP:

> Handle all exceptions


## Description

When an exception is thrown, control is transferred to the nearest handler with a type that matches the type of the exception thrown. If no matching handler is directly found within the handlers for a try block in which the exception is thrown, the search for a matching handler continues to dynamically search for handlers in the surrounding try blocks of the same thread. The C++ Standard, \[except.handle\], paragraph 9 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> If no matching handler is found, the function `std::terminate()` is called; whether or not the stack is unwound before this call to `std::terminate()` is implementation-defined.


The default terminate handler called by `std::terminate()` calls `std::abort()`, which [abnormally terminates](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) the process. When `std::abort()` is called, or if the [implementation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation) does not unwind the stack prior to calling `std::terminate()`, destructors for objects may not be called and external resources can be left in an indeterminate state. Abnormal process termination is the typical vector for [denial-of-service](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service) attacks. For more information on implicitly calling `std::terminate()`, see [ERR50-CPP. Do not abruptly terminate the program](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR50-CPP.+Do+not+abruptly+terminate+the+program).

All exceptions thrown by an application must be caught by a matching exception handler. Even if the exception cannot be gracefully recovered from, using the matching exception handler ensures that the stack will be properly unwound and provides an opportunity to gracefully manage external resources before terminating the process.

As per **ERR50-CPP-EX1**, a program that encounters an unrecoverable exception may explicitly catch the exception and terminate, but it may not allow the exception to remain uncaught. One possible solution to comply with this rule, as well as with ERR50-CPP, is for the `main()` function to catch all exceptions. While this does not generally allow the application to recover from the exception gracefully, it does allow the application to terminate in a controlled fashion.

## Noncompliant Code Example

In this noncompliant code example, neither `f()` nor `main()` catch exceptions thrown by `throwing_func()`. Because no matching handler can be found for the exception thrown, `std::terminate()` is called.

```cpp
void throwing_func() noexcept(false);
 
void f() {
  throwing_func();
}
 
int main() {
  f();
}
```

## Compliant Solution

In this compliant solution, the main entry point handles all exceptions, which ensures that the stack is unwound up to the `main()` function and allows for graceful management of external resources.

```cpp
void throwing_func() noexcept(false);
 
void f() {
  throwing_func();
}
 
int main() {
  try {
    f();
  } catch (...) {
    // Handle error
  }
}
```

## Noncompliant Code Example

In this noncompliant code example, the thread entry point function `thread_start()` does not catch exceptions thrown by `throwing_func()`. If the initial thread function exits because an exception is thrown, `std::terminate()` is called.

```cpp
#include <thread>

void throwing_func() noexcept(false);
 
void thread_start() {
  throwing_func();
}
 
void f() {
  std::thread t(thread_start);
  t.join();
}
```

## Compliant Solution

In this compliant solution, the `thread_start()` handles all exceptions and does not rethrow, allowing the thread to terminate normally.

```cpp
#include <thread>

void throwing_func() noexcept(false);

void thread_start(void) {
  try {
    throwing_func();
  } catch (...) {
    // Handle error
  }
}

void f() {
  std::thread t(thread_start);
  t.join();
}
```

## Risk Assessment

Allowing the application to [abnormally terminate](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) can lead to resources not being freed, closed, and so on. It is frequently a vector for [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR51-CPP </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>main-function-catch-allearly-catch-all</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-ERR51</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.UCTCH</strong> </td> <td> Unreachable Catch </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4035, C++4036, C++4037</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.CATCH.ALL</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>527 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR51-a</strong> <strong>CERT_CPP-ERR51-b</strong> </td> <td> Always catch exceptions Each exception explicitly thrown in the code shall have a handler of a compatible type in all call paths that could lead to that point </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: ERR51-CPP </a> </td> <td> Checks for unhandled exceptions (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4035, 4036, 4037</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong><strong>main-function-catch-allearly-catch-all</strong></strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability)resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR31-CPP).

## Related Guidelines

*This rule is a subset of**[ERR50-CPP. Do not abruptly terminate the program](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR50-CPP.+Do+not+abruptly+terminate+the+program)*.

<table> <tbody> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-754 </a> , Improper Check for Unusual or Exceptional Conditions </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 15.1, "Throwing an Exception" Subclause 15.3, "Handling an Exception" Subclause 15.5.1, "The <code>std::terminate()</code> Function" </td> </tr> <tr> <td> \[ <a> MISRA 2008 </a> \] </td> <td> Rule 15-3-2 (Advisory) Rule 15-3-4 (Required) </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR51-CPP: Handle all exceptions](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
