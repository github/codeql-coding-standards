# ERR55-CPP: Honor exception specifications

This query implements the CERT-C++ rule ERR55-CPP:

> Honor exception specifications


## Description

The C++ Standard, \[except.spec\], paragraph 8 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> A function is said to *allow* an exception of type `E` if the *constant-expression* in its *noexcept-specification* evaluates to `false` or its *dynamic-exception-specification* contains a type `T` for which a handler of type `T` would be a match (15.3) for an exception of type `E`.


If a function throws an exception other than one allowed by its *exception-specification*, it can lead to an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior) termination of the program (\[except.spec\], paragraph 9).

If a function declared with a *dynamic-exception-specification* throws an exception of a type that would not match the *exception-specification*, the function `std::unexpected()` is called. The behavior of this function can be overridden but, by default, causes an exception of `std::bad_exception` to be thrown. Unless `std::bad_exception` is listed in the *exception-specification*, the function `std::terminate()` will be called.

Similarly, if a function declared with a *noexcept-specification* throws an exception of a type that would cause the *noexcept-specification* to evaluate to `false`, the function `std::terminate()` will be called.

Calling `std::terminate()` leads to implementation-defined termination of the program. To prevent [abnormal termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) of the program, any function that declares an *exception-specification* should restrict itself, as well as any functions it calls, to throwing only allowed exceptions.

## Noncompliant Code Example

In this noncompliant code example, a function is declared as nonthrowing, but it is possible for `std::vector::resize()` to throw an exception when the requested memory cannot be allocated.

```cpp
#include <cstddef>
#include <vector>
 
void f(std::vector<int> &v, size_t s) noexcept(true) {
  v.resize(s); // May throw 
}

```

## Compliant Solution

In this compliant solution, the function's *noexcept-specification* is removed, signifying that the function allows all exceptions.

```cpp
#include <cstddef>
#include <vector>

void f(std::vector<int> &v, size_t s) {
  v.resize(s); // May throw, but that is okay
}
```

## Noncompliant Code Example

In this noncompliant code example, the second function claims to throw only `Exception1`, but it may also throw `Exception2.`

```cpp
#include <exception>
 
class Exception1 : public std::exception {};
class Exception2 : public std::exception {};

void foo() {
  throw Exception2{}; // Okay because foo() promises nothing about exceptions
}

void bar() throw (Exception1) {
  foo();    // Bad because foo() can throw Exception2
}

```

## Compliant Solution

This compliant solution catches the exceptions thrown by `foo().`

```cpp
#include <exception>
 
class Exception1 : public std::exception {};
class Exception2 : public std::exception {};

void foo() {
  throw Exception2{}; // Okay because foo() promises nothing about exceptions
}

void bar() throw (Exception1) {
  try {
    foo();
  } catch (Exception2 e) {
    // Handle error without rethrowing it
  }
}

```

## Compliant Solution

This compliant solution declares a dynamic *exception-specification* for `bar()`, which covers all of the exceptions that can be thrown from it.

```cpp
#include <exception>
 
class Exception1 : public std::exception {};
class Exception2 : public std::exception {};

void foo() {
  throw Exception2{}; // Okay because foo() promises nothing about exceptions
}

void bar() throw (Exception1, Exception2) {
  foo();
}
```

## Implementation Details

Some vendors provide language extensions for specifying whether or not a function throws. For instance, [Microsoft Visual Studio](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-msvc) provides `__declspec(nothrow))`, and [Clang ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-clang)supports `__attribute__((nothrow))`. Currently, the vendors do not document the behavior of specifying a nonthrowing function using these extensions. Throwing from a function declared with one of these language extensions is presumed to be [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Risk Assessment

Throwing unexpected exceptions disrupts control flow and can cause premature termination and [denial of service](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR55-CPP </td> <td> Low </td> <td> Likely </td> <td> Low </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>unhandled-throw-noexcept</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-ERR55</strong> </td> <td> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4035, C++4036, C++4632</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>56 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++Test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR55-a</strong> </td> <td> Where a function's declaration includes an exception-specification, the function shall only be capable of throwing exceptions of the indicated type(s) </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: ERR55-CPP </a> </td> <td> Checks for noexcept functions exiting with exception (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4035, 4036, 4632</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>unhandled-throw-noexcept</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulner) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR37-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> ERR50-CPP. Do not abruptly terminate the program </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> GNU 2016 </a> \] </td> <td> "Declaring Attributes of Functions" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 15.4, "Exception Specifications" </td> </tr> <tr> <td> \[ <a> MSDN 2016 </a> \] </td> <td> " <code>nothrow</code> (C++)" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR55-CPP: Honor exception specifications](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
