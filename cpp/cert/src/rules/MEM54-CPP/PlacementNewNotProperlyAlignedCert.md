# MEM54-CPP: Placement new shall be used only with properly aligned pointers

This query implements the CERT-C++ rule MEM54-CPP:

> Provide placement new with properly aligned pointers to sufficient storage capacity


## Description

When invoked by a `new` expression for a given type, the default global non-placement forms of `operator new` attempt to allocate sufficient storage for an object of the type and, if successful, return a pointer with alignment suitable for any object with a fundamental alignment requirement. However, the default placement `new` operator simply returns the given pointer back to the caller without guaranteeing that there is sufficient space in which to construct the object or ensuring that the pointer meets the proper alignment requirements. The C++ Standard, \[expr.new\], paragraph 16 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], nonnormatively states the following:

> \[Note: when the allocation function returns a value other than null, it must be a pointer to a block of storage in which space for the object has been reserved. The block of storage is assumed to be appropriately aligned and of the requested size. The address of the created object will not necessarily be the same as that of the block if the object is an array. —end note\]


(This note is a reminder of the general requirements specified by the C++ Standard, \[basic.stc.dynamic.allocation\], paragraph 1, which apply to placement `new` operators by virtue of \[basic.stc.dynamic\], paragraph 3.)

In addition, the standard provides the following example later in the same section:

> `new(2, f) T[5] `results in a call` of operator new[](sizeof(T) * 5 + y, 2, f).`


Here, `...` and `y` are non-negative unspecified values representing array allocation overhead; the result of the new-expression will be offset by this amount from the value returned by `operator new[]`. This overhead may be applied in all array *new-expressions*, including those referencing the library function `operator new[](std::size_t, void*)` and other placement allocation functions. The amount of overhead may vary from one invocation of new to another.

Do not pass a pointer that is not suitably aligned for the object being constructed to placement `new`. Doing so results in an object being constructed at a misaligned location, which results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). Do not pass a pointer that has insufficient storage capacity for the object being constructed, including the overhead required for arrays. Doing so may result in initialization of memory outside of the bounds of the object being constructed, which results in undefined behavior.

Finally, do not use placement `new[]` on any platform that does not specify a limit for the overhead it requires.

## Noncompliant Code Example

In this noncompliant code example, a pointer to a `short` is passed to placement `new`, which is attempting to initialize a `long`. On architectures where `sizeof(short) < sizeof(long)`, this results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). This example, and subsequent ones, all assume the pointer returned by placement `new` will not be used after the lifetime of its underlying storage has ended. For instance, the pointer will not be stored in a `static` global variable and dereferenced after the call to `f()` has ended. This assumption is in conformance with [MEM50-CPP. Do not access freed memory](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM50-CPP.+Do+not+access+freed+memory).

```cpp
#include <new>
 
void f() {
  short s;
  long *lp = ::new (&s) long;
}
```

## Noncompliant Code Example

This noncompliant code example ensures that the `long` is constructed into a buffer of sufficient size. However, it does not ensure that the alignment requirements are met for the pointer passed into placement `new`. To make this example clearer, an additional local variable `c` has also been declared.

```cpp
#include <new>
 
void f() {
  char c; // Used elsewhere in the function
  unsigned char buffer[sizeof(long)];
  long *lp = ::new (buffer) long;
 
  // ...
}
```

## Compliant Solution (alignas)

In this compliant solution, the `alignas` declaration specifier is used to ensure the buffer is appropriately aligned for a `long.`

```cpp
#include <new>
 
void f() {
  char c; // Used elsewhere in the function
  alignas(long) unsigned char buffer[sizeof(long)];
  long *lp = ::new (buffer) long;
 
  // ...
}
```

## Compliant Solution (std::aligned_storage)

This compliant solution ensures that the `long` is constructed into a buffer of sufficient size and with suitable alignment.

```cpp
#include <new>
 
void f() {
  char c; // Used elsewhere in the function
  std::aligned_storage<sizeof(long), alignof(long)>::type buffer;
  long *lp = ::new (&buffer) long;
 
  // ...
}
```

## Noncompliant Code Example (Failure to Account for Array Overhead)

This noncompliant code example attempts to allocate sufficient storage of the appropriate alignment for the array of objects of `S`. However, it fails to account for the overhead an implementation may add to the amount of storage for array objects. The overhead (commonly referred to as a cookie) is necessary to store the number of elements in the array so that the array delete expression or the exception unwinding mechanism can invoke the type's destructor on each successfully constructed element of the array. While some implementations are able to avoid allocating space for the cookie in some situations, assuming they do in all cases is unsafe.

```cpp
#include <new>

struct S {
  S ();
  ~S ();
};

void f() {
  const unsigned N = 32;
  alignas(S) unsigned char buffer[sizeof(S) * N];
  S *sp = ::new (buffer) S[N];
 
  // ...
  // Destroy elements of the array.
  for (size_t i = 0; i != n; ++i) {
    sp[i].~S();
  }
}
```

## Compliant Solution (Clang/GCC)

The amount of overhead required by array new expressions is unspecified but ideally would be documented by quality implementations. The following compliant solution is specifically for the [Clang ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-clang)and GNU [GCC ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-gcc)compilers, which guarantee that the overhead for dynamic array allocations is a single value of type `size_t`. (Note that this value is often treated as a "-1th" element in the array, so the actual space used may be larger.) To verify that the assumption is, in fact, safe, the compliant solution also overloads the placement `new[]` operator to accept the buffer size as a third argument and verifies that it is not smaller than the total amount of storage required.

```cpp
#include <cstddef>
#include <new>

#if defined(__clang__) || defined(__GNUG__)
  const size_t overhead = sizeof(size_t);
#else
  static_assert(false, "you need to determine the size of your implementation's array overhead");
  const size_t overhead = 0; // Declaration prevents additional diagnostics about overhead being undefined; the value used does not matter.
#endif

struct S {
  S();
  ~S();
};

void *operator new[](size_t n, void *p, size_t bufsize) {
  if (n > bufsize) {
    throw std::bad_array_new_length();
  }
  return p;
}

void f() {
  const size_t n = 32;
  alignas(S) unsigned char buffer[sizeof(S) * n + std::max(overhead, alignof(S))];
  S *sp = ::new (buffer, sizeof(buffer)) S[n];
 
  // ...
  // Destroy elements of the array.
  for (size_t i = 0; i != n; ++i) {
    sp[i].~S();
  }
}
```
Porting this compliant solution to other implementations requires adding similar conditional definitions of the overhead constant, depending on the constraints of the platform.

## Risk Assessment

Passing improperly aligned pointers or pointers to insufficient storage to placement `new` expressions can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior), including buffer overflow and [abnormal termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM54-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-MEM54</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.BO</strong> </td> <td> Buffer Overrun </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3119, C++3128</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>597 S</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MEM54-a</strong> <strong>CERT_CPP-MEM54-b</strong> </td> <td> Do not pass a pointer that has insufficient storage capacity or that is not suitably aligned for the object being constructed to placement 'new' An overhead should be used when an array of objects is passed to the placement 'new' allocation function </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: MEM54-CPP </a> </td> <td> Checks for placement new used with insufficient storage or misaligned pointers (rule fully covered) </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V752</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulner) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM45-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> MEM50-CPP. Do not access freed memory </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.7.4, "Dynamic Storage Duration" Subclause 5.3.4, "New" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MEM54-CPP: Provide placement new with properly aligned pointers to sufficient storage capacity](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
