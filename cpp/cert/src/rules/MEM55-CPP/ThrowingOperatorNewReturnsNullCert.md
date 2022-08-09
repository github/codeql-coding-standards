# MEM55-CPP: Replacement operator new returns null instead of throwing std:bad_alloc

This query implements the CERT-C++ rule MEM55-CPP:

> Honor replacement dynamic storage management requirements


## Description

Dynamic memory allocation and deallocation functions can be globally replaced by custom implementations, as specified by \[replacement.functions\], paragraph 2, of the C++ Standard \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]. For instance, a user may profile the dynamic memory usage of an application and decide that the default allocator is not optimal for their usage pattern, and a different allocation strategy may be a marked improvement. However, the C++ Standard, \[res.on.functions\], paragraph 1, states the following:

> In certain cases (replacement functions, handler functions, operations on types used to instantiate standard library template components), the C++ standard library depends on components supplied by a C++ program. If these components do not meet their requirements, the Standard places no requirements on the implementation.


Paragraph 2 further, in part, states the following:

> In particular, the effects are undefined in the following cases:— for replacement functions, if the installed replacement function does not implement the semantics of the applicable *Required behavior:* paragraph.


A replacement for any of the dynamic memory allocation or deallocation functions must meet the semantic requirements specified by the appropriate *Required behavior:* clause of the replaced function.

## Noncompliant Code Example

In this noncompliant code example, the global `operator new(std::size_t)` function is replaced by a custom implementation. However, the custom implementation fails to honor the behavior required by the function it replaces, as per the C++ Standard, \[new.delete.single\], paragraph 3. Specifically, if the custom allocator fails to allocate the requested amount of memory, the replacement function returns a null pointer instead of throwing an exception of type `std::bad_alloc`. By returning a null pointer instead of throwing, functions relying on the required behavior of `operator new(std::size_t)` to throw on memory allocations may instead attempt to dereference a null pointer. See [EXP34-C. Do not dereference null pointers](https://wiki.sei.cmu.edu/confluence/display/c/EXP34-C.+Do+not+dereference+null+pointers) for more information.

```cpp
#include <new>

void *operator new(std::size_t size) {
  extern void *alloc_mem(std::size_t); // Implemented elsewhere; may return nullptr
  return alloc_mem(size);
}
 
void operator delete(void *ptr) noexcept; // Defined elsewhere
void operator delete(void *ptr, std::size_t) noexcept; // Defined elsewhere
```
The declarations of the replacement `operator delete()` functions indicate that this noncompliant code example still complies with [DCL54-CPP. Overload allocation and deallocation functions as a pair in the same scope](https://wiki.sei.cmu.edu/confluence/display/cplusplus/DCL54-CPP.+Overload+allocation+and+deallocation+functions+as+a+pair+in+the+same+scope).

## Compliant Solution

This compliant solution implements the required behavior for the replaced global allocator function by properly throwing a `std::bad_alloc` exception when the allocation fails.

```cpp
#include <new>

void *operator new(std::size_t size) {
  extern void *alloc_mem(std::size_t); // Implemented elsewhere; may return nullptr
  if (void *ret = alloc_mem(size)) {
    return ret;
  }
  throw std::bad_alloc();
}
 
void operator delete(void *ptr) noexcept; // Defined elsewhere
void operator delete(void *ptr, std::size_t) noexcept; // Defined elsewhere
```

## Risk Assessment

Failing to meet the stated requirements for a replaceable dynamic storage function leads to [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). The severity of risk depends heavily on the caller of the allocation functions, but in some situations, dereferencing a null pointer can lead to the execution of arbitrary code \[[Jack 2007](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Jack07), [van Sprundel 2006](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-vanSprundel06)\]. The indicated severity is for this more severe case.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM55-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4736, C++4737, C++4738, C++4739</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.MEM.OVERRIDE.DELETE</strong> <strong>CERT.MEM.OVERRIDE.NEW</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MEM55-a</strong> </td> <td> The user defined 'new' operator should throw the 'std::bad_alloc' exception when the allocation fails </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: MEM55-CPP </a> </td> <td> Checks for replacement allocation/deallocation functions that do not meet requirements of the Standard (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM55-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> DCL54-CPP. Overload allocation and deallocation functions as a pair in the same scope </a> <a> OOP56-CPP. Honor replacement handler requirements </a> <a> </a> <a> </a> </td> </tr> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> EXP34-C. Do not dereference null pointers </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 17.6.4.8, "Other Functions" Subclause 18.6.1, "Storage Allocation and Deallocation" </td> </tr> <tr> <td> \[ <a> Jack 2007 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> van Sprundel 2006 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MEM55-CPP: Honor replacement dynamic storage management requirements](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
