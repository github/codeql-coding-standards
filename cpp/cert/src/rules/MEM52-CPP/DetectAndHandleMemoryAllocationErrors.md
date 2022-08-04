# MEM52-CPP: Detect and handle memory allocation errors

This query implements the CERT-C++ rule MEM52-CPP:

> Detect and handle memory allocation errors


## Description

The default memory allocation operator, `::operator new(std::size_t)`, throws a `std::bad_alloc` exception if the allocation fails. Therefore, you need not check whether calling `::operator new(std::size_t)` results in nullptr. The nonthrowing form, `::operator new(std::size_t, const std::nothrow_t &)`, does not throw an exception if the allocation fails but instead returns `nullptr`. The same behaviors apply for the `operator new[]` versions of both allocation functions. Additionally, the default allocator object (`std::allocator`) uses `::operator new(std::size_t)` to perform allocations and should be treated similarly.

```cpp
T *p1 = new T; // Throws std::bad_alloc if allocation fails
T *p2 = new (std::nothrow) T; // Returns nullptr if allocation fails

T *p3 = new T[1]; // Throws std::bad_alloc if the allocation fails
T *p4 = new (std::nothrow) T[1]; // Returns nullptr if the allocation fails
```
Furthermore, `operator new[]` can throw an error of type `std::bad_array_new_length`, a subclass of `std::bad_alloc`, if the `size` argument passed to `new` is negative or excessively large.

When using the nonthrowing form, it is imperative to check that the return value is not `nullptr` before accessing the resulting pointer. When using either form, be sure to comply with [ERR50-CPP. Do not abruptly terminate the program](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR50-CPP.+Do+not+abruptly+terminate+the+program).

## Noncompliant Code Example

In this noncompliant code example, an array of `int` is created using `::operator new[](std::size_t)` and the results of the allocation are not checked. The function is marked as `noexcept`, so the caller assumes this function does not throw any exceptions. Because `::operator new[](std::size_t)` can throw an exception if the allocation fails, it could lead to [abnormal termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) of the program.

```cpp
#include <cstring>
 
void f(const int *array, std::size_t size) noexcept {
  int *copy = new int[size];
  std::memcpy(copy, array, size * sizeof(*copy));
  // ...
  delete [] copy;
}

```

## Compliant Solution (std::nothrow)

When using `std::nothrow`, the `new` operator returns either a null pointer or a pointer to the allocated space. Always test the returned pointer to ensure it is not `nullptr` before referencing the pointer. This compliant solution handles the error condition appropriately when the returned pointer is `nullptr.`

```cpp
#include <cstring>
#include <new>
 
void f(const int *array, std::size_t size) noexcept {
  int *copy = new (std::nothrow) int[size];
  if (!copy) {
    // Handle error
    return;
  }
  std::memcpy(copy, array, size * sizeof(*copy));
  // ...
  delete [] copy;
}
```

## Compliant Solution (std::bad_alloc)

Alternatively, you can use `::operator new[]` without `std::nothrow` and instead catch a `std::bad_alloc` exception if sufficient memory cannot be allocated.

```cpp
#include <cstring>
#include <new>
 
void f(const int *array, std::size_t size) noexcept {
  int *copy;
  try {
    copy = new int[size];
  } catch(std::bad_alloc) {
    // Handle error
    return;
  }
  // At this point, copy has been initialized to allocated memory
  std::memcpy(copy, array, size * sizeof(*copy));
  // ...
  delete [] copy;
}
```

## Compliant Solution (noexcept(false))

If the design of the function is such that the caller is expected to handle exceptional situations, it is permissible to mark the function explicitly as one that may throw, as in this compliant solution. Marking the function is not strictly required, as any function without a `noexcept` specifier is presumed to allow throwing.

```cpp
#include <cstring>
 
void f(const int *array, std::size_t size) noexcept(false) {
  int *copy = new int[size];
  // If the allocation fails, it will throw an exception which the caller
  // will have to handle.
  std::memcpy(copy, array, size * sizeof(*copy));
  // ...
  delete [] copy;
}
```

## Noncompliant Code Example

In this noncompliant code example, two memory allocations are performed within the same expression. Because the memory allocations are passed as arguments to a function call, an exception thrown as a result of one of the calls to `new` could result in a memory leak.

```cpp
struct A { /* ... */ };
struct B { /* ... */ }; 
 
void g(A *, B *);
void f() {
  g(new A, new B);
}
```
Consider the situation in which `A` is allocated and constructed first, and then `B` is allocated and throws an exception. Wrapping the call to `g()` in a `try`/`catch` block is insufficient because it would be impossible to free the memory allocated for `A`.

This noncompliant code example also violates [EXP50-CPP. Do not depend on the order of evaluation for side effects](https://wiki.sei.cmu.edu/confluence/display/cplusplus/EXP50-CPP.+Do+not+depend+on+the+order+of+evaluation+for+side+effects), because the order in which the arguments to `g()` are evaluated is unspecified.

## Compliant Solution (std::unique_ptr)

In this compliant solution, a `std::unique_ptr` is used to manage the resources for the `A` and `B` objects with [RAII](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-RAII). In the situation described by the noncompliant code example, `B` throwing an exception would still result in the destruction and deallocation of the `A` object when then `std::unique_ptr<A>` was destroyed.

```cpp
#include <memory>
 
struct A { /* ... */ };
struct B { /* ... */ }; 
 
void g(std::unique_ptr<A> a, std::unique_ptr<B> b);
void f() {
  g(std::make_unique<A>(), std::make_unique<B>());
}
```

## Compliant Solution (References)

When possible, the more resilient compliant solution is to remove the memory allocation entirely and pass the objects by reference instead.

```cpp
struct A { /* ... */ };
struct B { /* ... */ }; 
 
void g(A &a, B &b);
void f() {
  A a;
  B b;
  g(a, b);
}
```

## Risk Assessment

Failing to detect allocation failures can lead to [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) and [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service).

If the vulnerable program references memory offset from the return value, an attacker can exploit the program to read or write arbitrary memory. This [vulnerability](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) has been used to execute arbitrary code \[[VU\#159523](http://www.kb.cert.org/vuls/id/159523)\].

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM52-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 7.5 </td> <td> <strong>CHECKED_RETURN</strong> </td> <td> Finds inconsistencies in how function call return values are handled </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3225, C++3226, C++3227, C++3228, C++3229, C++4632</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>NPD.CHECK.CALL.MIGHT</strong> <strong>NPD.CHECK.CALL.MUST</strong> <strong>NPD.CHECK.MIGHT</strong> <strong>NPD.CHECK.MUST</strong> <strong>NPD.CONST.CALL</strong> <strong>NPD.CONST.DEREF</strong> <strong>NPD.FUNC.CALL.MIGHT</strong> <strong>NPD.FUNC.CALL.MUST</strong> <strong>NPD.FUNC.MIGHT</strong> <strong>NPD.FUNC.MUST</strong> <strong>NPD.GEN.CALL.MIGHT</strong> <strong>NPD.GEN.CALL.MUST</strong> <strong>NPD.GEN.MIGHT</strong> <strong>NPD.GEN.MUST</strong> <strong>RNPD.CALL</strong> <strong>RNPD.DEREF</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>45 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MEM52-a</strong> <strong>CERT_CPP-MEM52-b</strong> </td> <td> Check the return value of new Do not allocate resources in function argument list because the order of evaluation of a function's parameters is undefined </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime detection </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: MEM52-CPP </a> </td> <td> Checks for unprotected dynamic memory allocation (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3225, 3226, 3227, 3228, 3229, <strong>4632</strong> </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V522</a>, <a>V668</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

The [vulnerability](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) in Adobe Flash \[[VU\#159523](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-VU%23159523)\] arises because Flash neglects to check the return value from `calloc()`. Even though `calloc()` returns `NULL`, Flash does not attempt to read or write to the return value. Instead, it attempts to write to an offset from the return value. Dereferencing `NULL` usually results in a program crash, but dereferencing an offset from `NULL` allows an [exploit](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) to succeed without crashing the program.

Search for vulnerabilities resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM32-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> ERR33-C. Detect and handle standard library errors </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE 252 </a> , Unchecked Return Value <a> CWE 391, </a> Unchecked Error Condition <a> CWE 476, </a> NULL Pointer Dereference <a> CWE 690 </a> , Unchecked Return Value to NULL Pointer Dereference <a> CWE 703 </a> , Improper Check or Handling of Exceptional Conditions <a> CWE 754 </a> , Improper Check for Unusual or Exceptional Conditions </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.20.3, "Memory Management Functions" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 18.6.1.1, "Single-Object Forms" Subclause 18.6.1.2, "Array Forms" Subclause 20.7.9.1, "Allocator Members" </td> </tr> <tr> <td> \[ <a> Meyers 1996 </a> \] </td> <td> Item 7, "Be Prepared for Out-of-Memory Conditions" </td> </tr> <tr> <td> \[ <a> Seacord 2013 </a> \] </td> <td> Chapter 4, "Dynamic Memory Management" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MEM52-CPP: Detect and handle memory allocation errors](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
