# MEM57-CPP: Avoid using default operator new for over-aligned types

This query implements the CERT-C++ rule MEM57-CPP:

> Avoid using default operator new for over-aligned types


## Description

The non-placement `new` expression is specified to invoke an allocation function to allocate storage for an object of the specified type. When successful, the allocation function, in turn, is required to return a pointer to storage with alignment suitable for any object with a fundamental alignment requirement. Although the global `operator new`, the default allocation function invoked by the new expression, is specified by the C++ standard \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\] to allocate sufficient storage suitably aligned to represent any object of the specified size, since the expected alignment isn't part of the function's interface, the most a program can safely assume is that the storage allocated by the default `operator new` defined by the implementation is aligned for an object with a fundamental alignment. In particular, it is unsafe to use the storage for an object of a type with a stricter alignment requirement—an* over-aligned type*.

Furthermore, the array form of the non-placement `new` expression may increase the amount of storage it attempts to obtain by invoking the corresponding allocation function by an unspecified amount. This amount, referred to as overhead in the C++ standard, is commonly known as a *cookie*. The cookie is used to store the number of elements in the array so that the array delete expression or the exception unwinding mechanism can invoke the type's destructor on each successfully constructed element of the array. While the specific conditions under which the cookie is required by the array new expression aren't described in the C++ standard, they may be outlined in other specifications such as the [application binary interface](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions) (ABI) document for the target environment. For example, the Itanium C++ ABI describes the rules for computing the size of a cookie, its location, and achieving the correct alignment of the array elements. When these rules require that a cookie be created, it is possible to obtain a suitably aligned array of elements of an overaligned type \[[CodeSourcery 2016a](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-codesourcery2016a)\]. However, the rules are complex and the Itanium C++ ABI isn't universally applicable.

Avoid relying on the default `operator new` to obtain storage for objects of over-aligned types. Doing so may result in an object being constructed at a misaligned location, which has [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) and can result in [abnormal termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) when the object is accessed, even on architectures otherwise known to tolerate misaligned accesses.

## Noncompliant Code Example

In the following noncompliant code example, the new expression is used to invoke the default `operator new` to obtain storage in which to then construct an object of the user-defined type `Vector` with alignment that exceeds the fundamental alignment of most implementations (typically 16 bytes). Objects of such over-aligned types are typically required by SIMD (single instruction, multiple data) vectorization instructions, which can trap when passed unsuitably aligned arguments.

```cpp
struct alignas(32) Vector {
  char elems[32];
};

Vector *f() {
  Vector *pv = new Vector;
  return pv;
}
```

## Compliant Solution (aligned_alloc)

In this compliant solution, an overloaded `operator new` function is defined to obtain appropriately aligned storage by calling the C11 function `aligned_alloc()`. Programs that make use of the array form of the new expression must define the corresponding member array `operator new[]` and `operator delete[]`. The `aligned_alloc()` function is not part of the C++ 98, C++ 11, or C++ 14 standards but may be provided by implementations of such standards as an extension. Programs targeting C++ implementations that do not provide the C11 `aligned_alloc()` function must define the member `operator new` to adjust the alignment of the storage obtained by the allocation function of their choice.

```cpp
#include <cstdlib>
#include <new>

struct alignas(32) Vector {
  char elems[32];
  static void *operator new(size_t nbytes) {
    if (void *p = std::aligned_alloc(alignof(Vector), nbytes)) {
      return p;
    }
    throw std::bad_alloc();
  }
  static void operator delete(void *p) {
    free(p);
  }
};

Vector *f() {
  Vector *pv = new Vector;
  return pv;
}
```

## Risk Assessment

Using improperly aligned pointers results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior), typically leading to [abnormal termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM57-CPP </td> <td> Medium </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3129</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MEM57-a</strong> </td> <td> Avoid using the default operator 'new' for over-aligned types </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: MEM57-CPP </a> </td> <td> Checks for situations where operator new is not overloaded for possibly overaligned types (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulner) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM57-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> MEM54-CPP. Provide placement new with properly aligned pointers to sufficient storage capacity </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.7.4, "Dynamic Storage Duration" Subclause 5.3.4, "New" Subclause 18.6.1, "Storage Allocation and Deallocation" </td> </tr> <tr> <td> \[ <a> CodeSourcery 2016a </a> \] </td> <td> Itanium C++ ABI, version 1.86 </td> </tr> <tr> <td> \[ <a> INCITS 2012 </a> \] </td> <td> Dynamic memory allocation for over-aligned data, WG14 proposal </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MEM57-CPP: Avoid using default operator new for over-aligned types](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
