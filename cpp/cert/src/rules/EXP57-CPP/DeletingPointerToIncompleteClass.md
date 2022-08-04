# EXP57-CPP: Do not delete pointers to incomplete classes

This query implements the CERT-C++ rule EXP57-CPP:

> Do not cast or delete pointers to incomplete classes


## Description

Referring to objects of incomplete class type, also known as *forward declarations*, is a common practice. One such common usage is with the "pimpl idiom" \[[Sutter 00](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Sutter00)\] whereby an opaque pointer is used to hide implementation details from a public-facing API. However, attempting to delete a pointer to an object of incomplete class type can lead to [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). The C++ Standard, \[expr.delete\], paragraph 5 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> If the object being deleted has incomplete class type at the point of deletion and the complete class has a non-trivial destructor or a deallocation function, the behavior is undefined.


Do not attempt to delete a pointer to an object of [incomplete type](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-incompletetype). Although it is well-formed if the class has no nontrivial destructor and no associated deallocation function, it would become undefined behavior were a nontrivial destructor or deallocation function added later. It would be possible to check for a nontrivial destructor at compile time using a `static_assert` and the `std::is_trivially_destructible` type trait, but no such type trait exists to test for the presence of a deallocation function.

Pointer downcasting to a pointer of incomplete class type has similar caveats. Pointer upcasting (casting from a more derived type to a less derived type) is a standard implicit conversion operation. C++ allows `static_cast` to perform the inverse operation, pointer downcasting, via \[expr.static.cast\], paragraph 7. However, when the pointed-to type is incomplete, the compiler is unable to make any class offset adjustments that may be required in the presence of multiple inheritance, resulting in a pointer that cannot be validly dereferenced.

`reinterpret_cast` of a pointer type is defined by \[expr.reinterpret.cast\], paragraph 7, as being `static_cast<cv T *>(static_cast<cv void *>(PtrValue))`, meaning that `reinterpret_cast` is simply a sequence of `static_cast` operations. C-style casts of a pointer to an incomplete object type are defined as using either `static_cast` or `reinterpret_cast` (it is unspecified which is picked) in \[expr.cast\], paragraph 5.

Do not attempt to cast through a pointer to an object of incomplete type. The cast operation itself is well-formed, but dereferencing the resulting pointer may result in undefined behavior if the downcast is unable to adjust for multiple inheritance.

## Noncompliant Code Example

In this noncompliant code example, a class attempts to implement the pimpl idiom but deletes a pointer to an incomplete class type, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) if `Body` has a nontrivial destructor.

```cpp
class Handle {
  class Body *impl;  // Declaration of a pointer to an incomplete class
public:
  ~Handle() { delete impl; } // Deletion of pointer to an incomplete class
  // ...
};

```

## Compliant Solution (delete)

In this compliant solution, the deletion of `impl` is moved to a part of the code where `Body` is defined.

```cpp
class Handle {
  class Body *impl;  // Declaration of a pointer to an incomplete class
public:
  ~Handle();
  // ...
};

// Elsewhere
class Body { /* ... */ };
 
Handle::~Handle() {
  delete impl;
}
```

## Compliant Solution (std::shared_ptr)

In this compliant solution, a `std::shared_ptr` is used to own the memory to `impl`. A `std::shared_ptr` is capable of referring to an incomplete type, but a `std::unique_ptr` is not.

```cpp
#include <memory>
 
class Handle {
  std::shared_ptr<class Body> impl;
  public:
    Handle();
    ~Handle() {}
    // ...
};
```

## Noncompliant Code Example

Pointer downcasting (casting a pointer to a base class into a pointer to a derived class) may require adjusting the address of the pointer by a fixed amount that can be determined only when the layout of the class inheritance structure is known. In this noncompliant code example, `f()` retrieves a polymorphic pointer of complete type `B` from `get_d()`. That pointer is then cast to a pointer of incomplete type `D` before being passed to `g()`. Casting to a pointer to the derived class may fail to properly adjust the resulting pointer, causing [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) when the pointer is dereferenced by calling `d->do_something()`.

```cpp
// File1.h
class B {
protected:
  double d;
public:
  B() : d(1.0) {}
};
 
// File2.h
void g(class D *);
class B *get_d(); // Returns a pointer to a D object

// File1.cpp
#include "File1.h"
#include "File2.h"

void f() {
  B *v = get_d();
  g(reinterpret_cast<class D *>(v));
}
 
// File2.cpp
#include "File2.h"
#include "File1.h"
#include <iostream>

class Hah {
protected:
  short s;
public:
  Hah() : s(12) {}
};

class D : public Hah, public B {
  float f;
public:
  D() : Hah(), B(), f(1.2f) {}
  void do_something() { std::cout << "f: " << f << ", d: " << d << ", s: " << s << std::endl; }
};

void g(D *d) {
  d->do_something();
}

B *get_d() {
  return new D;
}

```
**Implementation Details**

When compiled with [Clang](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-clang)[BB. Definitions\#clang](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-clang)3.8 and the function `f()` is executed, the noncompliant code example prints the following.

```cpp
f: 1.89367e-40, d: 5.27183e-315, s: 0
```
Similarly, unexpected values are printed when the example is run in [Microsoft Visual Studio](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-msvc) 2015 and [GCC ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-gcc)6.1.0.

## Compliant Solution

This compliant solution assumes that the intent is to hide implementation details by using incomplete class types. Instead of requiring a `D *` to be passed to `g()`, it expects a `B *` type.

```cpp
// File1.h -- contents identical.
// File2.h
void g(class B *); // Accepts a B object, expects a D object
class B *get_d(); // Returns a pointer to a D object

// File1.cpp
#include "File1.h"
#include "File2.h"

void f() {
  B *v = get_d();
  g(v);
}
 
// File2.cpp
// ... all contents are identical until ...
void g(B *d) {
  D *t = dynamic_cast<D *>(d);
  if (t) {
    t->do_something();
  } else {
    // Handle error
  }
}

B *get_d() {
  return new D;
}
```

## Risk Assessment

Casting pointers or references to incomplete classes can result in bad addresses. Deleting a pointer to an incomplete class results in undefined behavior if the class has a nontrivial destructor. Doing so can cause program termination, a runtime signal, or resource leaks.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP57-CPP </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>delete-with-incomplete-type</strong> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 6.5 </td> <td> <strong>DELETE_VOID</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wdelete-incomplete</code> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.CAST.PC.INC</strong> </td> <td> Conversion: pointer to incomplete </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3112</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.EXPR.DELETE_PTR.INCOMPLETE_TYPE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>169 S, 554 S</strong> <strong> </strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP57-a</strong> <strong>CERT_CPP-EXP57-b</strong> </td> <td> Do not delete objects with incomplete class at the point of deletion Conversions shall not be performed between a pointer to an incomplete type and any other type </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime detection </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: EXP57-CPP </a> </td> <td> Checks for conversion or deletion of incomplete class pointer </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>delete-with-incomplete-type</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP39-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Dewhurst 2002 </a> \] </td> <td> Gotcha \#39, "Casting Incomplete Types" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 4.10, "Pointer Conversions" Subclause 5.2.9, "Static Cast" Subclause 5.2.10, "Reinterpret Cast" Subclause 5.3.5, "Delete" Subclause 5.4, "Explicit Type Conversion (Cast Notation)" </td> </tr> <tr> <td> \[ <a> Sutter 2000 </a> \] </td> <td> "Compiler Firewalls and the Pimpl Idiom" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP57-CPP: Do not cast or delete pointers to incomplete classes](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
