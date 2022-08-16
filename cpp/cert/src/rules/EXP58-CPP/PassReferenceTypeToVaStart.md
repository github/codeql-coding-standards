# EXP58-CPP: Pass an object with a reference type to va_start

This query implements the CERT-C++ rule EXP58-CPP:

> Pass an object of the correct type to va_start


## Description

While rule [DCL50-CPP. Do not define a C-style variadic function](https://wiki.sei.cmu.edu/confluence/display/cplusplus/DCL50-CPP.+Do+not+define+a+C-style+variadic+function) forbids creation of such functions, they may still be defined when that function has external, C language linkage. Under these circumstances, care must be taken when invoking the `va_start()` macro. The C-standard library macro `va_start()` imposes several semantic restrictions on the type of the value of its second parameter. The C Standard, subclause 7.16.1.4, paragraph 4 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states the following:

> The parameter *parmN* is the identifier of the rightmost parameter in the variable parameter list in the function definition (the one just before the `...`). If the parameter *parmN* is declared with the `register` storage class, with a function or array type, or with a type that is not compatible with the type that results after application of the default argument promotions, the behavior is undefined.


These restrictions are superseded by the C++ Standard, \[support.runtime\], paragraph 3 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], which states the following:

> The restrictions that ISO C places on the second parameter to the `va_start()` macro in header `<stdarg.h>` are different in this International Standard. The parameter `parmN` is the identifier of the rightmost parameter in the variable parameter list of the function definition (the one just before the `...`). If the parameter `parmN` is of a reference type, or of a type that is not compatible with the type that results when passing an argument for which there is no parameter, the behavior is undefined.


The primary differences between the semantic requirements are as follows:

* You must not pass a reference as the second argument to `va_start()`.
* Passing an object of a class type that has a nontrivial copy constructor, nontrivial move constructor, or nontrivial destructor as the second argument to `va_start` is conditionally supported with implementation-defined semantics (\[expr.call\] paragraph 7).
* You may pass a parameter declared with the `register` keyword (\[dcl.stc\] paragraph 3) or a parameter with a function type.
Passing an object of array type still produces [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) in C++ because an array type as a function parameter requires the use of a reference, which is prohibited. Additionally, passing an object of a type that undergoes default argument promotions still produces undefined behavior in C++.

Noncompliant Code Example

In this noncompliant code example, the object passed to `va_start()` will undergo a default argument promotion, which results in undefined behavior.

```cpp
#include <cstdarg>
 
extern "C" void f(float a, ...) {
  va_list list;
  va_start(list, a);
  // ...
  va_end(list);
}
```

## Compliant Solution

In this compliant solution, `f()` accepts a `double` instead of a `float.`

```cpp
#include <cstdarg>
 
extern "C" void f(double a, ...) {
  va_list list;
  va_start(list, a);
  // ...
  va_end(list);
}

```

## Noncompliant Code Example

In this noncompliant code example, a reference type is passed as the second argument to `va_start().`

```cpp
#include <cstdarg>
#include <iostream>
 
extern "C" void f(int &a, ...) {
  va_list list;
  va_start(list, a);
  if (a) {
    std::cout << a << ", " << va_arg(list, int);
    a = 100; // Assign something to a for the caller
  }
  va_end(list);
}
```

## Compliant Solution

Instead of passing a reference type to `f()`, this compliant solution passes a pointer type.

```cpp
#include <cstdarg>
#include <iostream>
 
extern "C" void f(int *a, ...) {
  va_list list;
  va_start(list, a);
  if (a && *a) {
    std::cout << a << ", " << va_arg(list, int);
    *a = 100; // Assign something to *a for the caller
  }
  va_end(list);
}

```

## Noncompliant Code Example

In this noncompliant code example, a class with a nontrivial copy constructor (`std::string`) is passed as the second argument to `va_start()`, which is conditionally supported depending on the [implementation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation).

```cpp
#include <cstdarg>
#include <iostream>
#include <string>
 
extern "C" void f(std::string s, ...) {
  va_list list;
  va_start(list, s);
  std::cout << s << ", " << va_arg(list, int);
  va_end(list);
}
```

## Compliant Solution

This compliant solution passes a `const char *` instead of a `std::string`, which has well-defined behavior on all implementations.

```cpp
#include <cstdarg>
#include <iostream>
 
extern "C" void f(const char *s, ...) {
  va_list list;
  va_start(list, s);
  std::cout << (s ? s : "") << ", " << va_arg(list, int);
  va_end(list);
}
```

## Risk Assessment

Passing an object of an unsupported type as the second argument to `va_start()` can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) that might be [exploited](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) to cause data integrity violations.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP58-CPP </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wvarargs</code> </td> <td> Does not catch the violation in the third noncompliant code example (it is conditionally supported by <a> Clang </a> ) </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADMACRO.STDARG_H</strong> </td> <td> Use of &lt;stdarg.h&gt; Feature </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3852, C++3853</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.VA_START.TYPE</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP58-a</strong> </td> <td> Use macros for variable arguments correctly </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: EXP58-CPP </a> </td> <td> Checks for incorrect data types for second argument of va_start (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP40-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> DCL50-CPP. Do not define a C-style variadic function </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.16.1.4, "The <code>va_start</code> Macro" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 18.10, "Other Runtime Support" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP58-CPP: Pass an object of the correct type to va_start](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
