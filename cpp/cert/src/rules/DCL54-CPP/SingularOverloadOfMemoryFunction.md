# DCL54-CPP: Overload allocation and deallocation functions as a pair in the same scope

This query implements the CERT-C++ rule DCL54-CPP:

> Overload allocation and deallocation functions as a pair in the same scope


## Description

Allocation and deallocation functions can be overloaded at both global and class scopes.

If an allocation function is overloaded in a given scope, the corresponding deallocation function must also be overloaded in the same scope (and vice versa).

Failure to overload the corresponding dynamic storage function is likely to violate rules such as [MEM51-CPP. Properly deallocate dynamically allocated resources](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM51-CPP.+Properly+deallocate+dynamically+allocated+resources). For instance, if an overloaded allocation function uses a private heap to perform its allocations, passing a pointer returned by it to the default deallocation function will likely cause [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). Even in situations in which the allocation function ultimately uses the default allocator to obtain a pointer to memory, failing to overload a corresponding deallocation function may leave the program in an unexpected state by not updating internal data for the custom allocator.

It is acceptable to define a deleted allocation or deallocation function without its corresponding [free store](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-freestore) function. For instance, it is a common practice to define a deleted non-placement allocation or deallocation function as a class member function when the class also defines a placement `new` function. This prevents accidental allocation via calls to `new` for that class type or deallocation via calls to `delete` on pointers to an object of that class type. It is acceptable to declare, but not define, a private allocation or deallocation function without its corresponding free store function for similar reasons. However, a definition must not be provided as that still allows access to the free store function within a class member function.

## Noncompliant Code Example

In this noncompliant code example, an allocation function is overloaded at global scope. However, the corresponding deallocation function is not declared. Were an object to be allocated with the overloaded allocation function, any attempt to delete the object would result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) in violation of [MEM51-CPP. Properly deallocate dynamically allocated resources](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM51-CPP.+Properly+deallocate+dynamically+allocated+resources).

```cpp
#include <Windows.h>
#include <new>
 
void *operator new(std::size_t size) noexcept(false) {
  static HANDLE h = ::HeapCreate(0, 0, 0); // Private, expandable heap.
  if (h) {
    return ::HeapAlloc(h, 0, size);
  }
  throw std::bad_alloc();
}
 
// No corresponding global delete operator defined.
```

## Compliant Solution

In this compliant solution, the corresponding deallocation function is also defined at global scope.

```cpp
#include <Windows.h>
#include <new>

class HeapAllocator {
  static HANDLE h;
  static bool init;
 
public:
  static void *alloc(std::size_t size) noexcept(false) {
    if (!init) {
      h = ::HeapCreate(0, 0, 0); // Private, expandable heap.
      init = true;
    }
 
    if (h) {
      return ::HeapAlloc(h, 0, size);
    }
    throw std::bad_alloc();
  }
 
  static void dealloc(void *ptr) noexcept {
    if (h) {
      (void)::HeapFree(h, 0, ptr);
    }
  }
};
 
HANDLE HeapAllocator::h = nullptr;
bool HeapAllocator::init = false;

void *operator new(std::size_t size) noexcept(false) {
  return HeapAllocator::alloc(size);
}
 
void operator delete(void *ptr) noexcept {
  return HeapAllocator::dealloc(ptr);
}
```

## Noncompliant Code Example

In this noncompliant code example, `operator new()` is overloaded at class scope, but `operator delete()` is not similarly overloaded at class scope. Despite that the overloaded allocation function calls through to the default global allocation function, were an object of type `S` to be allocated, any attempt to delete the object would result in leaving the program in an indeterminate state due to failing to update allocation bookkeeping accordingly.

```cpp
#include <new>
 
extern "C++" void update_bookkeeping(void *allocated_ptr, std::size_t size, bool alloc);
 
struct S {
  void *operator new(std::size_t size) noexcept(false) {
    void *ptr = ::operator new(size);
    update_bookkeeping(ptr, size, true);
    return ptr;
  }
};
```

## Compliant Solution

In this compliant solution, the corresponding `operator delete()` is overloaded at the same class scope.

```cpp
#include <new>

extern "C++" void update_bookkeeping(void *allocated_ptr, std::size_t size, bool alloc);

struct S {
  void *operator new(std::size_t size) noexcept(false) {
    void *ptr = ::operator new(size);
    update_bookkeeping(ptr, size, true);
    return ptr;
  }
 
  void operator delete(void *ptr, std::size_t size) noexcept {
    ::operator delete(ptr);
    update_bookkeeping(ptr, size, false);
  }
};
```

## Exceptions

**DCL54-CPP-EX1:** A placement deallocation function may be elided for a corresponding placement allocation function, but only if the object placement allocation and object construction are guaranteed to be `noexcept(true)`. Because placement deallocation functions are automatically invoked when the object initialization terminates by throwing an exception, it is safe to elide the placement deallocation function when exceptions cannot be thrown. For instance, some vendors implement compiler flags disabling exception support (such as -fno-cxx-exceptions in [Clang ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-clang)and /EHs-c- in [Microsoft Visual Studio](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-msvc)), which has [implementation-defined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior) when an exception is thrown but generally results in program termination similar to calling `abort()`.

## Risk Assessment

Mismatched usage of `new` and `delete` could lead to a [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL54-CPP </td> <td> Low </td> <td> Probable </td> <td> Low </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>new-delete-pairwise</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-DCL54</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>misc-new-delete-overloads</code> </td> <td> Checked with <code>clang-tidy</code> . </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2160</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.DCL.SAME_SCOPE_ALLOC_DEALLOC </strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-DCL54-a</strong> </td> <td> Always provide new and delete together </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: DCL54-CPP </a> </td> <td> Checks for mismatch between overloaded operator new and operator delete (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2160</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>new-delete-pairwise</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S1265</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerab) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+DCL35-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> MEM51-CPP. Properly deallocate dynamically allocated resources </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.7.4, "Dynamic Storage Duration" Subclause 5.3.4, "New" Subclause 5.3.5, "Delete" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [DCL54-CPP: Overload allocation and deallocation functions as a pair in the same scope](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
