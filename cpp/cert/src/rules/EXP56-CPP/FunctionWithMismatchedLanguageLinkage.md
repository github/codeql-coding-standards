# EXP56-CPP: Do not call a function with a mismatched language linkage

This query implements the CERT-C++ rule EXP56-CPP:

> Do not call a function with a mismatched language linkage


## Description

C++ allows a degree of interoperability with other languages through the use of language linkage specifications. These specifications affect the way in which functions are called or data is accessed. By default, all function types, as well as function and variable names, with external linkage have C++ language linkage, though a different language linkage may be specified. Implementations are required to support `"C" and `"C++"`` as a language linkage, but other language linkages exist with implementation-defined semantics, such as `"java"`, `"Ada"`, and `"FORTRAN"`.

Language linkage is specified to be part of the function type, according to the C++ Standard, \[dcl.link\], paragraph 1 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], which, in part, states the following:

> Two function types with different language linkages are distinct types even if they are otherwise identical.


When calling a function, it is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) if the language linkage of the function type used in the call does not match the language linkage of the function definition. For instance, a mismatch in language linkage specification may corrupt the call stack due to calling conventions or other ABI mismatches.

Do not call a function through a type whose language linkage does not match the language linkage of the called function's definition. This restriction applies both to functions called within a C++ program as well as function pointers used to make a function call from outside of the C++ program.

However, many compilers fail to integrate language linkage into the function's type, despite the normative requirement to do so in the C++ Standard. For instance, [GCC](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-gcc) 6.1.0, [Clang](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-clang) 3.9, and [Microsoft Visual Studio](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-msvc) 2015 all consider the following code snippet to be [ill-formed](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-ill-formed) due to a redefinition of `f()` rather than a [well-formed](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-well-formed) overload of `f()`.

```cpp
typedef void (*cpp_func)(void);
extern "C" typedef void (*c_func)(void);

void f(cpp_func fp) {}
void f(c_func fp) {}
```
Some compilers conform to the C++ Standard, but only in their strictest conformance mode, such as EDG 4.11. This implementation divergence from the C++ Standard is a matter of practical design trade-offs. Compilers are required to support only the `"C"` and `"C++"` language linkages, and interoperability between these two languages often does not require significant code generation differences beyond the mangling of function types for most common architectures such as x86, x86-64, and ARM. There are extant Standard Template Library implementations for which language linkage specifications being correctly implemented as part of the function type would break existing code on common platforms where the language linkage has no effect on the runtime implementation of a function call.

It is acceptable to call a function with a mismatched language linkage when the combination of language linkage specifications, runtime platform, and compiler implementation result in no effect on runtime behavior of the function call. For instance, the following code is permissible when compiled with Microsoft Visual Studio 2015 for x86, despite the lambda function call operator implicitly converting to a function pointer type with C++ language linkage, while `qsort()` expects a function pointer with C language linkage.

```cpp
#include <cstdlib>
 
void f(int *int_list, size_t count) {
  std::qsort(int_list, count, sizeof(int),
             [](const void *lhs, const void *rhs) -> int {
               return reinterpret_cast<const int *>(lhs) <
                      reinterpret_cast<const int *>(rhs);
             });
}

```

## Noncompliant Code Example

In this noncompliant code example, the `call_java_fn_ptr()` function expects to receive a function pointer with `"java"` language linkage because that function pointer will be used by a Java interpreter to call back into the C++ code. However, the function is given a pointer with `"C++"` language linkage instead, resulting in undefined behavior when the interpreter attempts to call the function pointer. This code should be ill-formed because the type of `callback_func()` is different than the type `java_callback. However,` due to common implementation divergence from the C++ Standard, some compilers may incorrectly accept this code without issuing a diagnostic.

```cpp
extern "java" typedef void (*java_callback)(int);
 
extern void call_java_fn_ptr(java_callback callback);
void callback_func(int);
 
void f() {
  call_java_fn_ptr(callback_func);
}
```

## Compliant Solution

In this compliant solution, the `callback_func()` function is given `"java"` language linkage to match the language linkage for `java_callback`.

```cpp
extern "java" typedef void (*java_callback)(int);

extern void call_java_fn_ptr(java_callback callback);
extern "java" void callback_func(int);

void f() {
  call_java_fn_ptr(callback_func);
}
```

## Risk Assessment

Mismatched language linkage specifications generally do not create exploitable security vulnerabilities between the C and C++ language linkages. However, other language linkages exist where the undefined behavior is more likely to result in abnormal program execution, including exploitable vulnerabilities.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP56-CPP </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3033, C++3038</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>PORTING.CAST.PTR</strong> <strong>PORTING.CAST.PTR.FLTPNT</strong> <strong>PORTING.CAST.PTR.SIZE</strong> <strong>PORTING.CAST.SIZE</strong> <strong>MISRA.CAST.PTR.UNRELATED</strong> <strong>MISRA.CAST.PTR_TO_INT</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP56-a</strong> </td> <td> Do not call a function with a mismatched language linkage </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3033. 3038</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabil) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&amp;query=FIELD+KEYWORDS+contains+EXP56-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 5.2.2, "Function Call" Subclause 7.5, "Linkage Specifications" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP56-CPP: Do not call a function with a mismatched language linkage](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
