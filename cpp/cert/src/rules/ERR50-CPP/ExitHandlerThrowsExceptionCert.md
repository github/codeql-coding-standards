# ERR50-CPP: Registered exit handler throws an exception

This query implements the CERT-C++ rule ERR50-CPP:

> Do not abruptly terminate the program


## Description

The `std::abort()`, `std::quick_exit()`, and `std::_Exit()` functions are used to terminate the program in an immediate fashion. They do so without calling exit handlers registered with `std::atexit()` and without executing destructors for objects with automatic, thread, or static storage duration. How a system manages open streams when a program ends is [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior) \[[ISO/IEC 9899:1999](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-1999)\]. Open streams with unwritten buffered data may or may not be flushed, open streams may or may not be closed, and temporary files may or may not be removed. Because these functions can leave external resources, such as files and network communications, in an indeterminate state, they should be called explicitly only in direct response to a critical error in the application. (See ERR50-CPP-EX1 for more information.)

The `std::terminate()` function calls the current `terminate_handler` function, which defaults to calling `std::abort()`.

The C++ Standard defines several ways in which `std::terminate()` may be called implicitly by an [implementation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation) \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]:

1. When the exception handling mechanism, after completing the initialization of the exception object but before activation of a handler for the exception, calls a function that exits via an exception (\[except.throw\], paragraph 7)See [ERR60-CPP. Exception objects must be nothrow copy constructible](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR60-CPP.+Exception+objects+must+be+nothrow+copy+constructible) for more information.
1. When a *throw-expression* with no operand attempts to rethrow an exception and no exception is being handled (\[except.throw\], paragraph 9)
1. When the exception handling mechanism cannot find a handler for a thrown exception (\[except.handle\], paragraph 9)See [ERR51-CPP. Handle all exceptions](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR51-CPP.+Handle+all+exceptions) for more information.
1. When the search for a handler encounters the outermost block of a function with a *noexcept-specification* that does not allow the exception (\[except.spec\], paragraph 9)See [ERR55-CPP. Honor exception specifications](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR55-CPP.+Honor+exception+specifications) for more information.
1. When the destruction of an object during stack unwinding terminates by throwing an exception (\[except.ctor\], paragraph 3)See [DCL57-CPP. Do not let exceptions escape from destructors or deallocation functions](https://wiki.sei.cmu.edu/confluence/display/cplusplus/DCL57-CPP.+Do+not+let+exceptions+escape+from+destructors+or+deallocation+functions) for more information.
1. When initialization of a nonlocal variable with static or thread storage duration exits via an exception (\[basic.start.init\], paragraph 6)See [ERR58-CPP. Handle all exceptions thrown before main() begins executing](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR58-CPP.+Handle+all+exceptions+thrown+before+main%28%29+begins+executing) for more information.
1. When destruction of an object with static or thread storage duration exits via an exception (\[basic.start.term\], paragraph 1)See [DCL57-CPP. Do not let exceptions escape from destructors or deallocation functions](https://wiki.sei.cmu.edu/confluence/display/cplusplus/DCL57-CPP.+Do+not+let+exceptions+escape+from+destructors+or+deallocation+functions) for more information.
1. When execution of a function registered with `std::atexit()`or `std::at_quick_exit()` exits via an exception (\[support.start.term\], paragraphs 8 and 12)
1. When the implementation’s default unexpected exception handler is called (\[except.unexpected\], paragraph 2) Note that `std::unexpected()` is currently deprecated.
1. When `std::unexpected()` throws an exception that is not allowed by the previously violated *dynamic-exception-specification*, and `std::bad_exception()` is not included in that *dynamic-exception-specification* (\[except.unexpected\], paragraph 3)
1. When the function `std::nested_exception::rethrow_nested()` is called for an object that has captured no exception (\[except.nested\], paragraph 4)
1. When execution of the initial function of a thread exits via an exception (\[thread.thread.constr\], paragraph 5)See [ERR51-CPP. Handle all exceptions](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR51-CPP.+Handle+all+exceptions) for more information.
1. When the destructor is invoked on an object of type `std::thread` that refers to a joinable thread (\[thread.thread.destr\], paragraph 1)
1. When the copy assignment operator is invoked on an object of type `std::thread` that refers to a joinable thread (\[thread.thread.assign\], paragraph 1)
1. When calling `condition_variable::wait()`, `condition_variable::wait_until()`, or `condition_variable::wait_for()` results in a failure to meet the postcondition: `lock.owns_lock() == true` or `lock.mutex()` is not locked by the calling thread (\[thread.condition.condvar\], paragraphs 11, 16, 21, 28, 33, and 40)
1. When calling `condition_variable_any::wait()`, `condition_variable_any::wait_until()`, or `condition_variable_any::wait_for()` results in a failure to meet the postcondition: `lock` is not locked by the calling thread (\[thread.condition.condvarany\], paragraphs 11, 16, and 22)
In many circumstances, the call stack will not be unwound in response to an implicit call to `std::terminate()`, and in a few cases, it is implementation-defined whether or not stack unwinding will occur. The C++ Standard, \[except.terminate\], paragraph 2 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], in part, states the following:

> In the situation where no matching handler is found, it is implementation-defined whether or not the stack is unwound before `std::terminate()` is called. In the situation where the search for a handler encounters the outermost block of a function with a *noexcept-specification* that does not allow the exception, it is implementation-defined whether the stack is unwound, unwound partially, or not unwound at all before `std::terminate()` is called. In all other situations, the stack shall not be unwound before `std::terminate()` is called.


Do not explicitly or implicitly call `std::quick_exit()`, `std::abort()`, or `std::_Exit()`. When the default `terminate_handler` is installed or the current `terminate_handler` responds by calling `std::abort()` or `std::_Exit()`, do not explicitly or implicitly call `std::terminate()`. [Abnormal process termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) is the typical vector for [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service).

The `std::exit()` function is more complex. The C++ Standard, \[basic.start.main\], paragraph 4, states:

> Terminating the program without leaving the current block (e.g., by calling the function std::exit(int) (17.5)) does not destroy any objects with automatic storage duration (11.4.6). If std::exit is called to end a program during the destruction of an object with static or thread storage duration, the program has undefined behavior.


You may call `std::exit()` only in a program that has not yet initialized any objects with automatic storage duration.

Noncompliant Code Example

In this noncompliant code example, the call to `f()`, which was registered as an exit handler with `std::at_exit()`, may result in a call to `std::terminate()` because `throwing_func()` may throw an exception.

```cpp
#include <cstdlib>
 
void throwing_func() noexcept(false);
 
void f() { // Not invoked by the program except as an exit handler.
  throwing_func();
}
 
int main() {
  if (0 != std::atexit(f)) {
    // Handle error
  }
  // ...
}
```

## Compliant Solution

In this compliant solution, `f()` handles all exceptions thrown by `throwing_func()` and does not rethrow.

```cpp
#include <cstdlib>

void throwing_func() noexcept(false);

void f() { // Not invoked by the program except as an exit handler.
  try {
    throwing_func();
  } catch (...) {
    // Handle error
  }
}

int main() {
  if (0 != std::atexit(f)) {
    // Handle error
  }
  // ...
}
```

## Exceptions

**ERR50-CPP-EX1:** It is acceptable, after indicating the nature of the problem to the operator, to explicitly call `std::abort()`, `std::_Exit()`, or `std::terminate()` in response to a critical program error for which no recovery is possible, as in this example.

```cpp
#include <exception>

void report(const char *msg) noexcept;
[[noreturn]] void fast_fail(const char *msg) {
  // Report error message to operator
  report(msg);
 
  // Terminate
  std::terminate();
}
 
void critical_function_that_fails() noexcept(false);
 
void f() {
  try {
    critical_function_that_fails();
  } catch (...) {
    fast_fail("Critical function failure");
  }
}
```
The `assert()` macro is permissible under this exception because failed assertions will notify the operator on the standard error stream in an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior) manner before calling `std::abort()`.

## Risk Assessment

Allowing the application to [abnormally terminate](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) can lead to resources not being freed, closed, and so on. It is frequently a vector for [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR50-CPP </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>stdlib-use</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.ABORTBADFUNC.EXIT</strong> </td> <td> Use of abort Use of exit </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++5014</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.TERMINATE</strong> <strong>CERT.ERR.ABRUPT_TERM</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>122 S</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR50-a</strong> <strong>CERT_CPP-ERR50-b</strong> <strong>CERT_CPP-ERR50-c</strong> <strong>CERT_CPP-ERR50-d</strong> <strong>CERT_CPP-ERR50-e</strong> <strong>CERT_CPP-ERR50-f</strong> <strong>CERT_CPP-ERR50-g</strong> <strong>CERT_CPP-ERR50-h</strong> <strong>CERT_CPP-ERR50-i</strong> <strong>CERT_CPP-ERR50-j</strong> <strong>CERT_CPP-ERR50-k</strong> <strong>CERT_CPP-ERR50-l</strong> <strong>CERT_CPP-ERR50-mCERT_CPP-ERR50-n</strong> </td> <td> The execution of a function registered with 'std::atexit()' or 'std::at_quick_exit()' should not exit via an exception Never allow an exception to be thrown from a destructor, deallocation, and swap Do not throw from within destructor There should be at least one exception handler to catch all otherwise unhandled exceptions An empty throw (throw;) shall only be used in the compound-statement of a catch handler Exceptions shall be raised only after start-up and before termination of the program Each exception explicitly thrown in the code shall have a handler of a compatible type in all call paths that could lead to that point Where a function's declaration includes an exception-specification, the function shall only be capable of throwing exceptions of the indicated type(s) Function called in global or namespace scope shall not throw unhandled exceptions Always catch exceptions Properly define exit handlers The 'abort()' function from the 'stdlib.h' or 'cstdlib' library shall not be used Avoid throwing exceptions from functions that are declared not to throw The 'quick_exit()' and '_Exit()' functions from the 'stdlib.h' or 'cstdlib' library shall not be used </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: ERR50-CPP </a> </td> <td> Checks for implicit call to terminate() function (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>5014</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V667</a>, <a>V2014</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>stdlib-use</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S990</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR50-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> ERR51-CPP. Handle all exceptions </a> <a> ERR55-CPP. Honor exception specifications </a> <a> DCL57-CPP. Do not let exceptions escape from destructors or deallocation functions </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-754 </a> , Improper Check for Unusual or Exceptional Conditions </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899-2011 </a> \] </td> <td> Subclause 7.20.4.1, "The <code>abort</code> Function" Subclause 7.20.4.4, "The <code>_Exit</code> Function" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 15.5.1, "The <code>std::terminate()</code> Function" Subclause 18.5, "Start and Termination" </td> </tr> <tr> <td> \[ <a> MISRA 2008 </a> \] </td> <td> Rule 15-3-2 (Advisory) Rule 15-3-4 (Required) </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR50-CPP: Do not abruptly terminate the program](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
