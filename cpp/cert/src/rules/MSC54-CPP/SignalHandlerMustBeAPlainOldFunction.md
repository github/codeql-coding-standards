# MSC54-CPP: A signal handler must be a plain old function

This query implements the CERT-C++ rule MSC54-CPP:

> A signal handler must be a plain old function


## Description

The C++14 Standard, \[support.runtime\], paragraph 10 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> The common subset of the C and C++ languages consists of all declarations, definitions, and expressions that may appear in a well-formed C++ program and also in a conforming C program. A POF (“plain old function”) is a function that uses only features from this common subset, and that does not directly or indirectly use any function that is not a POF, except that it may use plain lock-free atomic operations. A plain lock-free atomic operation is an invocation of a function f from Clause 29, such that f is not a member function, and either f is the function atomic_is_lock_free, or for every atomic argument A passed to f, atomic_is_lock_free(A) yields true. All signal handlers shall have C linkage. The behavior of any function other than a POF used as a signal handler in a C++ program is implementation-defined.228


Footnote 228 states the following:

> In particular, a signal handler using exception handling is very likely to have problems. Also, invoking `std::exit` may cause destruction of objects, including those of the standard library implementation, which, in general, yields undefined behavior in a signal handler.


If your signal handler is not a plain old function, then the behavior of a call to it in response to a signal is [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior), at best, and is likely to result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). All signal handlers must meet the definition of a plain old function. In addition to the restrictions placed on signal handlers in a C program, this definition also prohibits the use of features that exist in C++ but not in C (such as non-POD \[non–plain old data\] objects and exceptions). This includes indirect use of such features through function calls.

In C++17, the wording has changed and relaxed some of the constraints on signal handlers. Section \[support.signal\], paragraph 3 says:

> An evaluation is signal-safe unless it includes one of the following:


— a call to any standard library function, except for plain lock-free atomic operations and functions explicitly identified as signal-safe. \[ Note: This implicitly excludes the use of new and delete expressions that rely on a library-provided memory allocator. — end note \]— an access to an object with thread storage duration;— a dynamic_cast expression;— throwing of an exception;— control entering a try-block or function-try-block;— initialization of a variable with static storage duration requiring dynamic initialization (6.6.3, 9.7)220; or— waiting for the completion of the initialization of a variable with static storage duration (9.7).

A signal handler invocation has undefined behavior if it includes an evaluation that is not signal-safe.

Signal handlers in code that will be executed on C++17-compliant platforms must be signal-safe.

## Noncompliant Code Example

In this noncompliant code example, the signal handler is declared as a `static` function. However, since all signal handler functions must have C language linkage, and C++ is the default language linkage for functions in C++, calling the signal handler results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <csignal>
 
static void sig_handler(int sig) {
  // Implementation details elided.
}

void install_signal_handler() {
  if (SIG_ERR == std::signal(SIGTERM, sig_handler)) {
    // Handle error
  }
}
```

## Compliant Solution

This compliant solution defines `sig_handler()` as having C language linkage. As a consequence of declaring the signal handler with C language linkage, the signal handler will have external linkage rather than internal linkage.

```cpp
#include <csignal>
 
extern "C" void sig_handler(int sig) {
  // Implementation details elided.
}

void install_signal_handler() {
  if (SIG_ERR == std::signal(SIGTERM, sig_handler)) {
    // Handle error
  }
}
```

## Noncompliant Code Example

In this noncompliant code example, a signal handler calls a function that allows exceptions, and it attempts to handle any exceptions thrown. Because exceptions are not part of the common subset of C and C++ features, this example results in [implementation-defined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior). However, it is unlikely that the implementation's behavior will be suitable. For instance, on a stack-based architecture where a signal is generated asynchronously (instead of as a result of a call to `std:abort()` or `std::raise()`), it is possible that the stack frame is not properly initialized, causing stack tracing to be unreliable and preventing the exception from being caught properly.

```cpp
#include <csignal>

static void g() noexcept(false);

extern "C" void sig_handler(int sig) {
  try {
    g();
  } catch (...) {
    // Handle error
  }
}
 
void install_signal_handler() {
  if (SIG_ERR == std::signal(SIGTERM, sig_handler)) {
    // Handle error
  }
}
```

## Compliant Solution

There is no compliant solution whereby `g()` can be called from the signal handler because it allows exceptions. Even if `g()` were implemented such that it handled all exceptions and was marked `noexcept(true)`, it would still be noncompliant to call `g()` from a signal handler because `g()` would still use a feature that is not a part of the common subset of C and C++ features allowed by a signal handler. Therefore, this compliant solution removes the call to `g()` from the signal handler and instead polls a variable of type `volatile sig_atomic_t` periodically; if the variable is set to `1` in the signal handler, then `g()` is called to respond to the signal.

```cpp
#include <csignal>

volatile sig_atomic_t signal_flag = 0;
static void g() noexcept(false);

extern "C" void sig_handler(int sig) {
  signal_flag = 1;
}

void install_signal_handler() {
  if (SIG_ERR == std::signal(SIGTERM, sig_handler)) {
    // Handle error
  }
}
 
// Called periodically to poll the signal flag.
void poll_signal_flag() {
  if (signal_flag == 1) {
    signal_flag = 0;
    try {
      g();
    } catch(...) {
      // Handle error
    }
  }
}
```

## Risk Assessment

Failing to use a plain old function as a signal handler can result in [implementation-defined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior) as well as [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). Given the number of features that exist in C++ that do not also exist in C, the consequences that arise from failure to comply with this rule can range from benign (harmless) behavior to [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination), or even arbitrary code execution.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MSC54-CPP </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2888</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.MSC.SIG_HANDLER.POF</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MSC54-a</strong> </td> <td> Properly define signal handlers </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2888 </strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerab) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MSC54-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> SIG30-C. Call only asynchronous-safe functions within signal handlers </a> <a> SIG31-C. Do not access shared objects in signal handlers </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 18.10, "Other Runtime Support" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MSC54-CPP: A signal handler must be a plain old function](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
