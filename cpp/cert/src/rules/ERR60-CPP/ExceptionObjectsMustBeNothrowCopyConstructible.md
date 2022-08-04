# ERR60-CPP: Exception objects must be nothrow copy constructible

This query implements the CERT-C++ rule ERR60-CPP:

> Exception objects must be nothrow copy constructible


## Description

When an exception is thrown, the exception object operand of the `throw` expression is copied into a temporary object that is used to initialize the handler. The C++ Standard, \[except.throw\], paragraph 3 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], in part, states the following:

> Throwing an exception copy-initializes a temporary object, called the *exception object*. The temporary is an lvalue and is used to initialize the variable declared in the matching *handler*.


If the copy constructor for the exception object type throws during the copy initialization, `std::terminate()` is called, which can result in possibly unexpected [implementation-defined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior). For more information on implicitly calling `std::terminate()`, see [ERR50-CPP. Do not abruptly terminate the program](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR50-CPP.+Do+not+abruptly+terminate+the+program).

The copy constructor for an object thrown as an exception must be declared `noexcept`, including any implicitly-defined copy constructors. Any function declared `noexcept` that terminates by throwing an exception violates [ERR55-CPP. Honor exception specifications](https://www.securecoding.cert.org/confluence/display/cplusplus/ERR55-CPP.+Honor+exception+specifications).

The C++ Standard allows the copy constructor to be elided when initializing the exception object to perform the initialization if a temporary is thrown. Many modern compiler implementations make use of both optimization techniques. However, the copy constructor for an exception object still must not throw an exception because compilers are not required to elide the copy constructor call in all situations, and common implementations of `std::exception_ptr` will call a copy constructor even if it can be elided from a `throw` expression.

## Noncompliant Code Example

In this noncompliant code example, an exception of type `S` is thrown in `f()`. However, because `S` has a `std::string` data member, and the copy constructor for `std::string` is not declared `noexcept`, the implicitly-defined copy constructor for `S` is also not declared to be `noexcept`. In low-memory situations, the copy constructor for `std::string` may be unable to allocate sufficient memory to complete the copy operation, resulting in a `std::bad_alloc` exception being thrown.

```cpp
#include <exception>
#include <string>

class S : public std::exception {
  std::string m;
public:
  S(const char *msg) : m(msg) {}
  
  const char *what() const noexcept override {
    return m.c_str();   
  }
};
 
void g() {
  // If some condition doesn't hold...
  throw S("Condition did not hold");
}

void f() {
  try {
    g();
  } catch (S &s) {
    // Handle error
  }
}
```

## Compliant Solution

This compliant solution assumes that the type of the exception object can inherit from `std::runtime_error`, or that type can be used directly. Unlike `std::string`, a `std::runtime_error` object is required to correctly handle an arbitrary-length error message that is exception safe and guarantees the copy constructor will not throw \[ [ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014) \].

```cpp
#include <stdexcept>
#include <type_traits>

struct S : std::runtime_error {
  S(const char *msg) : std::runtime_error(msg) {}
};
 
static_assert(std::is_nothrow_copy_constructible<S>::value,
              "S must be nothrow copy constructible");

void g() {
  // If some condition doesn't hold...
  throw S("Condition did not hold");
}

void f() {
  try {
    g();
  } catch (S &s) {
    // Handle error
  }
}
```

## Compliant Solution

If the exception type cannot be modified to inherit from `std::runtime_error`, a data member of that type is a legitimate implementation strategy, as shown in this compliant solution.

```cpp
#include <stdexcept>
#include <type_traits>

class S : public std::exception {
  std::runtime_error m;
public:
  S(const char *msg) : m(msg) {}
  
  const char *what() const noexcept override {
    return m.what();   
  }
};
 
static_assert(std::is_nothrow_copy_constructible<S>::value,
              "S must be nothrow copy constructible");
 
void g() {
  // If some condition doesn't hold...
  throw S("Condition did not hold");
}

void f() {
  try {
    g();
  } catch (S &s) {
    // Handle error
  }
}
```

## Risk Assessment

Allowing the application to [abnormally terminate](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) can lead to resources not being freed, closed, and so on. It is frequently a vector for [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR60-CPP </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>cert-err60-cpp</code> </td> <td> Checked by <code>clang-tidy</code> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3508</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR60-a</strong> <strong>CERT_CPP-ERR60-b</strong> </td> <td> Exception objects must be nothrow copy constructible An explicitly declared copy constructor for a class that inherits from 'std::exception' should have a non-throwing exception specification </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3508</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR60-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> ERR50-CPP. Do not abruptly terminate the program </a> <a> ERR55-CPP. Honor exception specifications </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Hinnant 2015 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 15.1, "Throwing an Exception" Subclause 18.8.1, "Class <code>exception</code> " Subclause 18.8.5, "Exception Propagation" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR60-CPP: Exception objects must be nothrow copy constructible](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
