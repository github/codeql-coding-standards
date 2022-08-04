# ERR61-CPP: Catch exceptions by lvalue reference

This query implements the CERT-C++ rule ERR61-CPP:

> Catch exceptions by lvalue reference


## Description

When an exception is thrown, the value of the object in the throw expression is used to initialize an anonymous temporary object called the *exception object*. The type of this exception object is used to transfer control to the nearest catch handler, which contains an exception declaration with a matching type. The C++ Standard, \[except.handle\], paragraph 16 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], in part, states the following:

> The variable declared by the *exception-declaration*, of type *cv* `T` or *cv* `T&`, is initialized from the exception object, of type `E`, as follows: — if `T` is a base class of `E`, the variable is copy-initialized from the corresponding base class subobject of the exception object; — otherwise, the variable is copy-initialized from the exception object.


Because the variable declared by the *exception-declaration* is copy-initialized, it is possible to *slice[](https://en.wikipedia.org/wiki/Object_slicing)* the exception object as part of the copy operation, losing valuable exception information and leading to incorrect error recovery. For more information about object slicing, see [OOP51-CPP. Do not slice derived objects](https://wiki.sei.cmu.edu/confluence/display/cplusplus/OOP51-CPP.+Do+not+slice+derived+objects). Further, if the copy constructor of the exception object throws an exception, the copy initialization of the *exception-declaration* object results in undefined behavior. (See [ERR60-CPP. Exception objects must be nothrow copy constructible](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR60-CPP.+Exception+objects+must+be+nothrow+copy+constructible) for more information.)

Always catch exceptions by [lvalue](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-lvalue) reference unless the type is a trivial type. For reference, the C++ Standard, \[basic.types\], paragraph 9 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], defines trivial types as the following:

> Arithmetic types, enumeration types, pointer types, pointer to member types, `std::nullptr_t`, and cv-qualified versions of these types are collectively called *scalar types*.... Scalar types, trivial class types, arrays of such types and cv-qualified versions of these types are collectively called *trivial types*.


The C++ Standard, \[class\], paragraph 6, defines trivial class types as the following:

> A *trivially copyable class* is a class that: — has no non-trivial copy constructors, — has no non-trivial move constructors, — has no non-trivial copy assignment operators, — has no non-trivial move assignment operators, and — has a trivial destructor.A *trivial class* is a class that has a default constructor, has no non-trivial default constructors, and is trivially copyable. \[*Note*: In particular, a trivially copyable or trivial class does not have virtual functions or virtual base classes. — *end note*\]


## Noncompliant Code Example

In this noncompliant code example, an object of type `S` is used to initialize the exception object that is later caught by an *exception-declaration* of type `std::exception`. The *exception-declaration* matches the exception object type, so the variable `E` is copy-initialized from the exception object, resulting in the exception object being sliced. Consequently, the output of this noncompliant code example is the implementation-defined value returned from calling `std::exception::what()` instead of `"My custom exception"`.

```cpp
#include <exception>
#include <iostream>
 
struct S : std::exception {
  const char *what() const noexcept override {
    return "My custom exception";
  }
};
 
void f() {
  try {
    throw S();
  } catch (std::exception e) {
    std::cout << e.what() << std::endl;
  }
}
```

## Compliant Solution

In this compliant solution, the variable declared by the *exception-declaration* is an lvalue reference. The call to `what()` results in executing `S::what()` instead of `std::exception::what()`.

```cpp
#include <exception>
#include <iostream>
 
struct S : std::exception {
  const char *what() const noexcept override {
    return "My custom exception";
  }
};
 
void f() {
  try {
    throw S();
  } catch (std::exception &e) {
    std::cout << e.what() << std::endl;
  }
}
```

## Risk Assessment

Object slicing can result in abnormal program execution. This generally is not a problem for exceptions, but it can lead to unexpected behavior depending on the assumptions made by the exception handler.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR61-CPP </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>catch-class-by-value</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-ERR61</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>cert-err61-cpp</code> </td> <td> Checked by <code>clang-tidy</code> ; also checks for <a> VOID ERR09-CPP. Throw anonymous temporaries </a> by default </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4031 </strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.CATCH.BY_VALUE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>455 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR61-a</strong> <strong>CERT_CPP-ERR61-b</strong> </td> <td> A class type exception shall always be caught by reference Throw by value, catch by reference </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: ERR61-CPP </a> </td> <td> Checks for exception object initialized by copy in catch statement (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4031 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V746</a>, <a>V816</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>catch-class-by-value</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S1044</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR61-CPP).

## Related Guidelines

*This rule is a subset of [OOP51-CPP. Do not slice derived objects.](https://wiki.sei.cmu.edu/confluence/display/cplusplus/OOP51-CPP.+Do+not+slice+derived+objects)*

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> ERR60-CPP. Exception objects must be nothrow copy constructible </a> <a> </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.9, "Types" Clause 9, "Classes" Subclause 15.1, "Throwing an Exception" Subclause 15.3, "Handling an Exception" </td> </tr> <tr> <td> \[ <a> MISRA 2008 </a> \] </td> <td> Rule 15-3-5 </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR61-CPP: Catch exceptions by lvalue reference](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
