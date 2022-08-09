# OOP57-CPP: Prefer special member functions and overloaded operators to C Standard Library functions

This query implements the CERT-C++ rule OOP57-CPP:

> Prefer special member functions and overloaded operators to C Standard Library functions


## Description

Several C standard library functions perform bytewise operations on objects. For instance, `std::memcmp()` compares the bytes comprising the object representation of two objects, and `std::memcpy()` copies the bytes comprising an object representation into a destination buffer. However, for some object types, it results in undefined or abnormal program behavior.

The C++ Standard, \[class\], paragraph 6 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> A *trivially copyable class* is a class that: — has no non-trivial copy constructors, — has no non-trivial move constructors, — has no non-trivial copy assignment operators, — has no non-trivial move assignment operators, and — has a trivial destructor.A *trivial class* is a class that has a default constructor, has no non-trivial default constructors, and is trivially copyable. \[Note: In particular, a trivially copyable or trivial class does not have virtual functions or virtual base classes. — end note\]


Additionally, the C++ Standard, \[class\], paragraph 7, states the following:

> A *standard-layout class* is a class that: — has no non-static data members of type non-standard-layout class (or array of such types) or reference, — has no virtual functions and no virtual base classes, — has the same access control for all non-static data members, — has no non-standard-layout base classes, — either has no non-static data members in the most derived class and at most one base class with non-static data members, or has no base classes with non-static data members, and — has no base classes of the same type as the first non-static data member.


Do not use `std::memset()` to initialize an object of nontrivial class type as it may not properly initialize the value representation of the object. Do not use `std::memcpy()` (or related bytewise copy functions) to initialize a copy of an object of nontrivial class type, as it may not properly initialize the value representation of the copy. Do not use `std::memcmp()` (or related bytewise comparison functions) to compare objects of nonstandard-layout class type, as it may not properly compare the value representations of the objects. In all cases, it is best to prefer the alternatives.

<table> <tbody> <tr> <th> C Standard Library Function </th> <th> C++ Equivalent Functionality </th> </tr> <tr> <td> <code>std::memset()</code> </td> <td> Class constructor </td> </tr> <tr> <td> <code>std::memcpy()</code> <code>std::memmove()</code> <code>std::strcpy()</code> </td> <td> Class copy constructor or <code>operator=()</code> </td> </tr> <tr> <td> <code>std::memcmp()</code> <code>std::strcmp()</code> </td> <td> <code>operator&lt;()</code> , <code>operator&gt;()</code> , <code>operator==()</code> , or <code>operator!=()</code> </td> </tr> </tbody> </table>


## Noncompliant Code Example

In this noncompliant code example, a nontrivial class object is initialized by calling its default constructor but is later reinitialized to its default state using `std::memset()`, which does not properly reinitialize the object. Improper reinitialization leads to class invariants not holding in later uses of the object.

```cpp
#include <cstring>
#include <iostream>
 
class C {
  int scalingFactor;
  int otherData;
 
public:
  C() : scalingFactor(1) {}
  
  void set_other_data(int i);
  int f(int i) {
    return i / scalingFactor;
  }
  // ...
};
 
void f() {
  C c;
  
  // ... Code that mutates c ... 
  
  // Reinitialize c to its default state
  std::memset(&c, 0, sizeof(C));
  
  std::cout << c.f(100) << std::endl;
}
```
The above noncompliant code example is compliant with [EXP62-CPP. Do not access the bits of an object representation that are not part of the object's value representation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/EXP62-CPP.+Do+not+access+the+bits+of+an+object+representation+that+are+not+part+of+the+object%27s+value+representation) because all of the bits in the value representation are also used in the object representation of `C`.

## Compliant Solution

In this compliant solution, the call to `std::memset()` is replaced with a default-initialized copy-and-swap operation called `clear()`. This operation ensures that the object is initialized to its default state properly, and it behaves properly for object types that have optimized assignment operators that fail to clear all data members of the object being assigned into.

```cpp
#include <iostream>
#include <utility>
 
class C {
  int scalingFactor;
  int otherData;
 
public:
  C() : scalingFactor(1) {}
  
  void set_other_data(int i);
  int f(int i) {
    return i / scalingFactor;
  }
  // ...
};
 
template <typename T>
T& clear(T &o) {
  using std::swap;
  T empty;
  swap(o, empty);
  return o;
}

void f() {
  C c;
  
  // ... Code that mutates c ... 
  
  // Reinitialize c to its default state
  clear(c);
  
  std::cout << c.f(100) << std::endl;
}
```

## Noncompliant Code Example

In this noncompliant code example, `std::memcpy()` is used to create a copy of an object of nontrivial type `C`. However, because each object instance attempts to delete the `int *` in `C::~C()`, double-free [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) may occur because the same pointer value will be copied into `c2`.

```cpp
#include <cstring>
 
class C {
  int *i;
 
public:
  C() : i(nullptr) {}
  ~C() { delete i; }
 
  void set(int val) {
    if (i) { delete i; }
    i = new int{val};
  }
 
  // ...
};
 
void f(C &c1) {
  C c2;
  std::memcpy(&c2, &c1, sizeof(C));  
}
```

## Compliant Solution

In this compliant solution, `C` defines an assignment operator that is used instead of calling `std::memcpy()`.

```cpp
class C {
  int *i;
 
public:
  C() : i(nullptr) {}
  ~C() { delete i; }
 
  void set(int val) {
    if (i) { delete i; }
    i = new int{val};
  }

  C &operator=(const C &rhs) noexcept(false) {
    if (this != &rhs) {
      int *o = nullptr;
      if (rhs.i) {
        o = new int;
        *o = *rhs.i;
      }
      // Does not modify this unless allocation succeeds.
      delete i;
      i = o;
    }
    return *this;
  }
 
  // ...
};
 
void f(C &c1) {
  C c2 = c1;
}
```

## Noncompliant Code Example

In this noncompliant code example, `std::memcmp()` is used to compared two objects of nonstandard-layout type. Because `std::memcmp()` performs a bytewise comparison of the object representations, if the implementation uses a vtable pointer as part of the object representation, it will compare vtable pointers. If the dynamic type of either `c1` or `c2` is a derived class of type `C`, the comparison may fail despite the value representation of either object.

```cpp
#include <cstring>
 
class C {
  int i;
 
public:
  virtual void f();
  
  // ...
};
 
void f(C &c1, C &c2) {
  if (!std::memcmp(&c1, &c2, sizeof(C))) {
    // ...
  }
}
```
Because a vtable is not part of an object's value representation, comparing it with `std::memcmp()` also violates [EXP62-CPP. Do not access the bits of an object representation that are not part of the object's value representation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/EXP62-CPP.+Do+not+access+the+bits+of+an+object+representation+that+are+not+part+of+the+object%27s+value+representation).

## Compliant Solution

In this compliant solution, `C` defines an equality operator that is used instead of calling `std::memcmp()`. This solution ensures that only the value representation of the objects is considered when performing the comparison.

```cpp
class C {
  int i;
 
public:
  virtual void f();
  
  bool operator==(const C &rhs) const {
    return rhs.i == i;
  }

  // ...
};
 
void f(C &c1, C &c2) {
  if (c1 == c2) {
    // ...
  }
}
```

## Risk Assessment

Most violations of this rule will result in abnormal program behavior. However, overwriting [implementation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions) details of the object representation can lead to code execution [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> OOP57-CPP </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>stdlib-use-atostdlib-usestdlib-use-getenvstdlib-use-systeminclude-timestdlib-use-string-unbounded</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.MEMCMP</strong> <strong>BADFUNC.MEMSET</strong> </td> <td> Use of memcmp Use of memset </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++5017, C++5038</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.OOP.CSTD_FUNC_USE </strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>44 S</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-OOP57-a</strong> <strong>CERT_CPP-OOP57-b</strong> </td> <td> Do not initialize objects with a non-trivial class type using C standard library functions Do not compare objects of nonstandard-layout class type with C standard library functions </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: OOP57-CPP </a> </td> <td> Checks for bytewise operations on nontrivial class object (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>5017, 5038</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong>V598<a></a></strong> , <strong><a>V780</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong><strong>stdlib-use-atostdlib-usestdlib-use-getenvstdlib-use-systeminclude-timestdlib-use-string-unbounded</strong></strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabil) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&amp;query=FIELD+KEYWORDS+contains+OOP57-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> EXP62-CPP. Do not access the bits of an object representation that are not part of the object's value representation </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.9, "Types" Subclause 3.10, "Lvalues and Rvalues" Clause 9, "Classes" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [OOP57-CPP: Prefer special member functions and overloaded operators to C Standard Library functions](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
