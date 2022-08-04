# OOP54-CPP: Gracefully handle self-copy assignment

This query implements the CERT-C++ rule OOP54-CPP:

> Gracefully handle self-copy assignment


## Description

Self-copy assignment can occur in situations of varying complexity, but essentially, all self-copy assignments entail some variation of the following.

```cpp
#include <utility>
 
struct S { /* ... */ }
 
void f() {
  S s;
  s = s; // Self-copy assignment
}
```
User-provided copy operators must properly handle self-copy assignment.

The postconditions required for copy assignment are specified by the C++ Standard, \[utility.arg.requirements\], Table 23 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], which states that for `x = y`, the value of `y` is unchanged. When `&x == &y`, this postcondition translates into the values of both `x` and `y` remaining unchanged. A naive implementation of copy assignment could destroy object-local resources in the process of copying resources from the given parameter. If the given parameter is the same object as the local object, the act of destroying object-local resources will invalidate them. The subsequent copy of those resources will be left in an indeterminate state, which violates the postcondition.

A user-provided copy assignment operator must prevent self-copy assignment from leaving the object in an indeterminate state. This can be accomplished by self-assignment tests, copy-and-swap, or other idiomatic design patterns.

The C++ Standard, \[copyassignable\], specifies that types must ensure that self-copy assignment leave the object in a consistent state when passed to Standard Template Library (STL) functions. Since objects of STL types are used in contexts where `CopyAssignable` is required, STL types are required to gracefully handle self-copy assignment.

## Noncompliant Code Example

In this noncompliant code example, the copy assignment operator does not protect against self-copy assignment. If self-copy assignment occurs, `this->s1` is deleted, which results in `rhs.s1` also being deleted. The invalidated memory for `rhs.s1` is then passed into the copy constructor for `S`, which can result in dereferencing an [invalid pointer](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-invalidpointer).

```cpp
#include <new>
 
struct S { S(const S &) noexcept; /* ... */ };
 
class T {
  int n;
  S *s1;
 
public:
  T(const T &rhs) : n(rhs.n), s1(rhs.s1 ? new S(*rhs.s1) : nullptr) {}
  ~T() { delete s1; }
 
  // ...
 
  T& operator=(const T &rhs) {
    n = rhs.n;
    delete s1;
    s1 = new S(*rhs.s1);
    return *this;
  }
};
```

## Compliant Solution (Self-Test)

This compliant solution guards against self-copy assignment by testing whether the given parameter is the same as `this`. If self-copy assignment occurs, then `operator=` does nothing; otherwise, the copy proceeds as in the original example.

```cpp
#include <new>
 
struct S { S(const S &) noexcept; /* ... */ };
 
class T {
  int n;
  S *s1;
 
public:
  T(const T &rhs) : n(rhs.n), s1(rhs.s1 ? new S(*rhs.s1) : nullptr) {}
  ~T() { delete s1; }

  // ...
 
  T& operator=(const T &rhs) {
    if (this != &rhs) {
      n = rhs.n;
      delete s1;
      try {
        s1 = new S(*rhs.s1);
      } catch (std::bad_alloc &) {
        s1 = nullptr; // For basic exception guarantees
        throw;
      }
    }
    return *this;
  }
};

```
This solution does not provide a [strong exception](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-strongexceptionsafety) guarantee for the copy assignment. Specifically, if an exception is called when evaluating the `new` expression, `this` has already been modified. However, this solution does provide a basic exception guarantee because no resources are leaked and all data members contain valid values. Consequently, this code complies with [ERR56-CPP. Guarantee exception safety](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR56-CPP.+Guarantee+exception+safety).

## Compliant Solution (Copy and Swap)

This compliant solution avoids self-copy assignment by constructing a temporary object from `rhs` that is then swapped with `*this`. This compliant solution provides a strong exception guarantee because `swap()` will never be called if resource allocation results in an exception being thrown while creating the temporary object.

```cpp
#include <new>
#include <utility>
 
struct S { S(const S &) noexcept; /* ... */ };
 
class T {
  int n;
  S *s1;
 
public:
  T(const T &rhs) : n(rhs.n), s1(rhs.s1 ? new S(*rhs.s1) : nullptr) {}
  ~T() { delete s1; }

  // ...
 
  void swap(T &rhs) noexcept {
    using std::swap;
    swap(n, rhs.n);
    swap(s1, rhs.s1);
  }
 
  T& operator=(T rhs) noexcept {
    rhs.swap(*this);
    return *this;
  }
};
```

## Compliant Solution (Move and Swap)

This compliant solution uses the same classes `S` and `T` from the previous compliant solution, but adds the following public constructor and methods:

```cpp
  T(T &&rhs) { *this = std::move(rhs); }

  // ... everything except operator= ..

  T& operator=(T &&rhs) noexcept {
    using std::swap;
    swap(n, rhs.n);
    swap(s1, rhs.s1);
    return *this;
  }
```
The copy assignment operator uses `std::move()` rather than `swap()` to achieve safe self-assignment and a strong exception guarantee. The move assignment operator uses a move (via the method parameter) and swap.

The move constructor is not strictly necessary, but defining a move constructor along with a move assignment operator is conventional for classes that support move operations.

Note that unlike copy assignment operators, the signature of a move assignment operator accepts a non-const reference to its object with the expectation that the moved-from object will be left in an unspecified, but valid state. Move constructors have the same difference from copy constructors.

## Risk Assessment

Allowing a copy assignment operator to corrupt an object could lead to [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> OOP54-CPP </td> <td> Low </td> <td> Probable </td> <td> High </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>dangling_pointer_use</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 9.0 (r361550) </td> <td> <code>cert-oop54-cpp</code> </td> <td> Checked by <code>clang-tidy</code> . </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>IO.DC</strong> <strong>ALLOC.DF</strong> <strong>ALLOC.LEAK</strong> <strong>LANG.MEM.NPD</strong> <strong>LANG.STRUCT.RC</strong> <strong>IO.UAC</strong> <strong>ALLOC.UAF</strong> </td> <td> Double Close Double Free Leak Null Pointer Dereference Redundant Condition Use After Close Use After Free </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4072, C++4073, C++4075, C++4076</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CL.SELF-ASSIGN</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-OOP54-a</strong> </td> <td> Check for assignment to self in operator= </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: OOP54-CPP </a> </td> <td> Checks for copy assignment operators where self-assignment is not tested (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4072, 4073, 4075, 4076</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+OOP38-CPP).

## Related Guidelines

This rule is a partial subset of [OOP58-CPP. Copy operations must not mutate the source object](https://wiki.sei.cmu.edu/confluence/display/cplusplus/OOP58-CPP.+Copy+operations+must+not+mutate+the+source+object) when copy operations do not gracefully handle self-copy assignment, because the copy operation may mutate both the source and destination objects (due to them being the same object).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Henricson 1997 </a> \] </td> <td> Rule 5.12, Copy assignment operators should be protected from doing destructive actions if an object is assigned to itself </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 17.6.3.1, "Template Argument Requirements" Subclause 17.6.4.9, "Function Arguments" </td> </tr> <tr> <td> \[ <a> Meyers 2005 </a> \] </td> <td> Item 11, "Handle Assignment to Self in <code>operator=</code> " </td> </tr> <tr> <td> \[ <a> Meyers 2014 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [OOP54-CPP: Gracefully handle self-copy assignment](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
