# ERR59-CPP: Do not throw an exception across execution boundaries

This query implements the CERT-C++ rule ERR59-CPP:

> Do not throw an exception across execution boundaries


## Description

Throwing an exception requires collaboration between the execution of the `throw` expression and the passing of control to the appropriate `catch` statement, if one applies. This collaboration takes the form of runtime logic used to calculate the correct handler for the exception and is an implementation detail specific to the platform. For code compiled by a single C++ compiler, the details of how to throw and catch exceptions can be safely ignored. However, when throwing an exception across execution boundaries, care must be taken to ensure the runtime logic used is compatible between differing sides of the execution boundary.

An *execution boundary* is the delimitation between code compiled by differing compilers, including different versions of a compiler produced by the same vendor. For instance, a function may be declared in a header file but defined in a library that is loaded at runtime. The execution boundary is between the call site in the executable and the function implementation in the library. Such boundaries are also called [ABI](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-applicationbinaryinterface) (application binary interface) boundaries because they relate to the interoperability of application binaries.

Throw an exception across an execution boundary only when both sides of the execution boundary use the same ABI for exception handling.

## Noncompliant Code Example

In this noncompliant code example, an exception is thrown from a library function to signal an error. Despite the exception being a scalar type (and thus implicitly conforming to [EXP60-CPP. Do not pass a nonstandard-layout type object across execution boundaries](https://wiki.sei.cmu.edu/confluence/display/cplusplus/EXP60-CPP.+Do+not+pass+a+nonstandard-layout+type+object+across+execution+boundaries)), this code can still result in abnormal program execution if the library and application adhere to different ABIs.

```cpp
// library.h
void func() noexcept(false); // Implemented by the library
 
// library.cpp
void func() noexcept(false) {
  // ...
  if (/* ... */) {
    throw 42;
  }
}
 
// application.cpp
#include "library.h"

void f() {
  try {
    func();
  } catch(int &e) {
    // Handle error
  }
}
```
**Implementation Details**

If the library code is compiled (with modification to account for mangling differences) with [GCC ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-gcc)4.9 on a default installation of MinGW-w64 without special compiler flags, the exception throw will rely on the zero-cost, table-based exception model that is based on [DWARF](http://wiki.dwarfstd.org/index.php?title=Exception_Handling) and uses the Itanium ABI. If the application code is compiled with [Microsoft Visual Studio ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-msvc)2013, the catch handler will be based on [Structured Exception Handling](https://en.wikipedia.org/wiki/Microsoft-specific_exception_handling_mechanisms) and the Microsoft ABI. These two exception-handling formats are incompatible, as are the ABIs, resulting in abnormal program behavior. Specifically, the exception thrown by the library is not caught by the application, and `std::terminate()` is eventually called.

## Compliant Solution

In this compliant solution, the error from the library function is indicated by a return value instead of an exception. Using Microsoft Visual Studio (or GCC) to compile both the library and the application would also be a compliant solution because the same exception-handling machinery and ABI would be used on both sides of the execution boundary.

```cpp
// library.h
int func() noexcept(true); // Implemented by the library

// library.cpp
int func() noexcept(true) {
  // ...
  if (/* ... */) {
    return 42;
  }
  // ...
  return 0;
}
 
// application.cpp
#include "library.h"

void f() {
  if (int err = func()) {
    // Handle error
  }
}
```

## Risk Assessment

The effects of throwing an exception across execution boundaries depends on the [implementation details](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation) of the exception-handling mechanics. They can range from correct or benign behavior to [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR59-CPP </td> <td> High </td> <td> Probable </td> <td> Medium </td> <td> <strong>P12</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3809, C++3810</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR59-a</strong> </td> <td> Do not throw an exception across execution boundaries </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR59-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> CERT C++ Coding Standard </a> </td> <td> <a> EXP60-CPP. Do not pass a nonstandard-layout type object across execution boundaries </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause15, "Exception Handling" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR59-CPP: Do not throw an exception across execution boundaries](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
