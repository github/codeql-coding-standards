# OOP58-CPP: Copy operations must not mutate the source object

This query implements the CERT-C++ rule OOP58-CPP:

> Copy operations must not mutate the source object


## Description

Copy operations (copy constructors and copy assignment operators) are expected to copy the salient properties of a source object into the destination object, with the resulting object being a "copy" of the original. What is considered to be a salient property of the type is type-dependent, but for types that expose comparison or equality operators, includes any properties used for those comparison operations. This expectation leads to assumptions in code that a copy operation results in a destination object with a value representation that is equivalent to the source object value representation. Violation of this basic assumption can lead to unexpected behavior.

Ideally, the copy operator should have an idiomatic signature. For copy constructors, that is `T(const T&);` and for copy assignment operators, that is `T& operator=(const T&);`. Copy constructors and copy assignment operators that do not use an idiomatic signature do not meet the requirements of the `CopyConstructible` or `CopyAssignable` concept, respectively. This precludes the type from being used with common standard library functionality \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\].

When implementing a copy operator, do not mutate any externally observable members of the source object operand or globally accessible information. Externally observable members include, but are not limited to, members that participate in comparison or equality operations, members whose values are exposed via public APIs, and global variables.

Before C++11, a copy operation that mutated the source operand was the only way to provide move-like semantics. However, the language did not provide a way to enforce that this operation only occurred when the source operand was at the end of its lifetime, which led to fragile APIs like `std::auto_ptr`. In C++11 and later, such a situation is a good candidate for a move operation instead of a copy operation.

**auto_ptr**

For example, in C++03, `std::auto_ptr` had the following copy operation signatures \[[ISO/IEC 14882-2003](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2003)\]:

<table> <tbody> <tr> <td> Copy constructor </td> <td> <code>auto_ptr(auto_ptr &amp;A);</code> </td> </tr> <tr> <td> Copy assignment </td> <td> <code>auto_ptr&amp; operator=(auto_ptr &amp;A);</code> </td> </tr> </tbody> </table>
Both copy construction and copy assignment would mutate the source argument, `A`, by effectively calling `this->reset(A.release())`. However, this invalidated assumptions made by standard library algorithms such as `std::sort()`, which may need to make a copy of an object for later comparisons \[[Hinnant 05](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Hinnant05)\]. Consider the following implementation of `std::sort()` that implements the [quick sort](https://en.wikipedia.org/wiki/Quicksort) algorithm.


```cpp
// ...
value_type pivot_element = *mid_point;
// ...
```
At this point, the sorting algorithm assumes that `pivot_element` and `*mid_point` have equivalent value representations and will compare equal. However, for `std::auto_ptr`, this is not the case because `*mid_point` has been mutated and results in unexpected behavior.

In C++11, the `std::unique_ptr` smart pointer class was introduced as a replacement for `std::auto_ptr` to better specify the ownership semantics of pointer objects. Rather than mutate the source argument in a copy operation, `std::unique_ptr` explicitly deletes the copy constructor and copy assignment operator, and instead uses a move constructor and move assignment operator. Subsequently, `std::auto_ptr` was deprecated in C++11.

Noncompliant Code Example

In this noncompliant code example, the copy operations for `A` mutate the source operand by resetting its member variable `m` to `0`. When `std::fill()` is called, the first element copied will have the original value of `obj.m`, `12`, at which point `obj.m` is set to `0`. The subsequent nine copies will all retain the value `0`.

```cpp
#include <algorithm>
#include <vector>

class A {
  mutable int m;
  
public:
  A() : m(0) {}
  explicit A(int m) : m(m) {}
  
  A(const A &other) : m(other.m) {
    other.m = 0;
  }
  
  A& operator=(const A &other) {
    if (&other != this) {
      m = other.m;
      other.m = 0;
    }
    return *this;
  }
  
  int get_m() const { return m; }
};

void f() {
  std::vector<A> v{10};
  A obj(12);
  std::fill(v.begin(), v.end(), obj);
}
```

## Compliant Solution

In this compliant solution, the copy operations for `A` no longer mutate the source operand, ensuring that the vector contains equivalent copies of `obj`. Instead, `A` has been given move operations that perform the mutation when it is safe to do so.

```cpp
#include <algorithm>
#include <vector>

class A {
  int m;
  
public:
  A() : m(0) {}
  explicit A(int m) : m(m) {}
  
  A(const A &other) : m(other.m) {}
  A(A &&other) : m(other.m) { other.m = 0; }
  
  A& operator=(const A &other) {
    if (&other != this) {
      m = other.m;
    }
    return *this;
  }
 
  A& operator=(A &&other) {
    m = other.m;
    other.m = 0;
    return *this;
  }
  
  int get_m() const { return m; }
};

void f() {
  std::vector<A> v{10};
  A obj(12);
  std::fill(v.begin(), v.end(), obj);
}
```

## Exceptions

**OOP58-CPP-EX0:** Reference counting, and implementations such as `std::shared_ptr<>` constitute an exception to this rule. Any copy or assignment operation of a reference-counted object requires the reference count to be incremented. The semantics of reference counting are well-understood, and it can be argued that the reference count is not a salient part of the `shared_pointer` object.

## Risk Assessment

Copy operations that mutate the source operand or global state can lead to unexpected program behavior. Using such a type in a Standard Template Library container or algorithm can also lead to undefined behavior.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> OOP58-CPP </td> <td> Low </td> <td> Likely </td> <td> Low </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.FUNCS.COPINC</strong> </td> <td> Copy Operation Parameter Is Not const </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4075</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.OOP.COPY_MUTATES </strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-OOP58-a</strong> </td> <td> Copy operations must not mutate the source object </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: OOP58-CPP </a> </td> <td> Checks for copy operation modifying source operand (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4075</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vuln) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+OOP58-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> OOP54-CPP. Gracefully handle self-copy assignment </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 12.8, "Copying and Moving Class Objects" Table 21, "CopyConstructible Requirements" Table 23, "CopyAssignable Requirements" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2003 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Hinnant 2005 </a> \] </td> <td> "Rvalue Reference Recommendations for Chapter 20" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [OOP58-CPP: Copy operations must not mutate the source object](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
