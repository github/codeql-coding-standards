# OOP52-CPP: Do not delete a polymorphic object without a virtual destructor

This query implements the CERT-C++ rule OOP52-CPP:

> Do not delete a polymorphic object without a virtual destructor


## Description

The C++ Standard, \[expr.delete\], paragraph 3 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> In the first alternative (*delete object*), if the static type of the object to be deleted is different from its dynamic type, the static type shall be a base class of the dynamic type of the object to be deleted and the static type shall have a virtual destructor or the behavior is undefined. In the second alternative (*delete array*) if the dynamic type of the object to be deleted differs from its static type, the behavior is undefined.


Do not delete an object of derived class type through a pointer to its base class type that has a non-`virtual` destructor. Instead, the base class should be defined with a `virtual` destructor. Deleting an object through a pointer to a type without a `virtual` destructor results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

In this noncompliant example, `b` is a polymorphic pointer type whose static type is `Base *` and whose dynamic type is `Derived *`. When `b` is deleted, it results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) because `Base` does not have a `virtual` destructor. The C++ Standard, \[class.dtor\], paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> If a class has no user-declared destructor, a destructor is implicitly declared as defaulted. An implicitly declared destructor is an `inline public` member of its class.


The implicitly declared destructor is not declared as `virtual` even in the presence of other `virtual` functions.

```cpp
struct Base {
  virtual void f();
};
 
struct Derived : Base {};
 
void f() {
  Base *b = new Derived();
  // ...
  delete b;
}

```

## Noncompliant Code Example

In this noncompliant example, the explicit pointer operations have been replaced with a smart pointer object, demonstrating that smart pointers suffer from the same problem as other pointers. Because the default deleter for `std::unique_ptr` calls `delete` on the internal pointer value, the resulting behavior is identical to the previous noncompliant example.

```cpp
#include <memory>
 
struct Base {
  virtual void f();
};
 
struct Derived : Base {};
 
void f() {
  std::unique_ptr<Base> b = std::make_unique<Derived()>();
}
```

## Compliant Solution

In this compliant solution, the destructor for `Base` has an explicitly declared `virtual` destructor, ensuring that the polymorphic delete operation results in well-defined behavior.

```cpp
struct Base {
  virtual ~Base() = default;
  virtual void f();
};

struct Derived : Base {};

void f() {
  Base *b = new Derived();
  // ...
  delete b;
}
```

## Exceptions

**OOP52-CPP:EX0**: Deleting a polymorphic object without a virtual destructor is permitted if the object is referenced by a pointer to its class, rather than via a pointer to a class it inherits from.

```cpp
class Base {
public:
  // ...
  virtual void AddRef() = 0;
  virtual void Destroy() = 0;
};

class Derived final : public Base {
public:
  // ...
  virtual void AddRef() { /* ... */ }
  virtual void Destroy() { delete this; }
private:
  ~Derived() {}
};
```
Note that if `Derived` were not marked as `final`, then `delete this` could actually reference a subclass of `Derived`, violating this rule.

**OOP52-CPP:EX1**: Deleting a polymorphic object without a virtual destructor is permitted if its base class has a destroying `operator delete` that will figure out the correct derived class's destructor to call by other means.

```cpp
#include <new>

class Base {
  const int whichDerived;

protected:
  Base(int whichDerived) : whichDerived(whichDerived) {}

public:
  Base() : Base(0) {}
  void operator delete(Base *, std::destroying_delete_t);
};

struct Derived1 final : Base {
  Derived1() : Base(1) {}
};

struct Derived2 final : Base {
  Derived2() : Base(2) {}
};

void Base::operator delete(Base *b, std::destroying_delete_t) {
  switch (b->whichDerived) {
  case 0:
    b->~Base();
    break;
  case 1:
    static_cast<Derived1 *>(b)->~Derived1();
    break;
  case 2:
    static_cast<Derived2 *>(b)->~Derived2();
  }
  ::operator delete(b);
}

void f() {
  Base *b = new Derived1();
  // ...
  delete b;
}
```

## Risk Assessment

Attempting to destruct a polymorphic object that does not have a `virtual` destructor declared results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). In practice, potential consequences include [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) and memory leaks.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> OOP52-CPP </td> <td> Low </td> <td> Likely </td> <td> Low </td> <td> <strong> P9 </strong> </td> <td> <strong> L2 </strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>non-virtual-public-destructor-in-non-final-class</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-OOP52</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wdelete-non-virtual-dtor</code> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.DNVD</strong> </td> <td> delete with Non-Virtual Destructor </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3402, C++3403, C++3404</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CL.MLK.VIRTUAL</strong> <strong>CWARN.DTOR.NONVIRT.DELETE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>303 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-OOP52-a</strong> </td> <td> Define a virtual destructor in classes used as base classes which have virtual functions </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3402, 3403, 3404</strong> </td> <td> </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: OOP52-CPP </a> </td> <td> Checks for situations when a class has virtual functions but not a virtual destructor (rule partially covered) </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong>V599<a></a></strong> , <strong><a>V689</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>non-virtual-public-destructor-in-non-final-class</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S1235</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+OOP52-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> EXP51-CPP. Do not delete an array through a pointer of the incorrect type </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 5.3.5, "Delete" Subclause 12.4, "Destructors" </td> </tr> <tr> <td> \[ <a> Stroustrup 2006 </a> \] </td> <td> "Why Are Destructors Not Virtual by Default?" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [OOP52-CPP: Do not delete a polymorphic object without a virtual destructor](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
