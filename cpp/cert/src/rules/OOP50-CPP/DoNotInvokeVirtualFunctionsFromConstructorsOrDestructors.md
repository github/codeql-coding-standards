# OOP50-CPP: Do not invoke virtual functions from constructors or destructors

This query implements the CERT-C++ rule OOP50-CPP:

> Do not invoke virtual functions from constructors or destructors


## Description

Virtual functions allow for the choice of member function calls to be determined at run time based on the dynamic type of the object that the member function is being called on. This convention supports object-oriented programming practices commonly associated with object inheritance and function overriding. When calling a nonvirtual member function or when using a class member access expression to denote a call, the specified function is called. Otherwise, a virtual function call is made to the final overrider in the dynamic type of the object expression.

However, during the construction and destruction of an object, the rules for virtual method dispatch on that object are restricted. The C++ Standard, \[class.cdtor\], paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> Member functions, including virtual functions, can be called during construction or destruction. When a virtual function is called directly or indirectly from a constructor or from a destructor, including during the construction or destruction of the class’s non-static data members, and the object to which the call applies is the object (call it `x`) under construction or destruction, the function called is the final overrider in the constructor’s or destructor’s class and not one overriding it in a more-derived class. If the virtual function call uses an explicit class member access and the object expression refers to the complete object of `x` or one of that object’s base class subobjects but not `x` or one of its base class subobjects, the behavior is undefined.


Do not directly or indirectly invoke a virtual function from a constructor or destructor that attempts to call into the object under construction or destruction. Because the order of construction starts with base classes and moves to more derived classes, attempting to call a derived class function from a base class under construction is dangerous. The derived class has not had the opportunity to initialize its resources, which is why calling a virtual function from a constructor does not result in a call to a function in a more derived class. Similarly, an object is destroyed in reverse order from construction, so attempting to call a function in a more derived class from a destructor may access resources that have already been released.

## Noncompliant Code Example

In this noncompliant code example, the base class attempts to seize and release an object's resources through calls to virtual functions from the constructor and destructor. However, the `B::B()` constructor calls `B::seize()` rather than `D::seize()`. Likewise, the `B::~B()` destructor calls `B::release()` rather than `D::release()`.

```cpp
struct B {
  B() { seize(); }
  virtual ~B() { release(); }
 
protected:
  virtual void seize();
  virtual void release();
};

struct D : B {
  virtual ~D() = default;
 
protected:
  void seize() override {
    B::seize();
    // Get derived resources...
  }
 
  void release() override {
    // Release derived resources...
    B::release();
  }
};

```
The result of running this code is that no derived class resources will be seized or released during the initialization and destruction of object of type `D`. At the time of the call to `seize()` from `B::B()`, the `D` constructor has not been entered, and the behavior of the under-construction object will be to invoke `B::seize()` rather than `D::seize()`. A similar situation occurs for the call to `release()` in the base class destructor. If the functions `seize()` and `release()` were declared to be pure virtual functions, the result would be [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Compliant Solution

In this compliant solution, the constructors and destructors call a nonvirtual, private member function (suffixed with `mine`) instead of calling a virtual function. The result is that each class is responsible for seizing and releasing its own resources.

```cpp
class B {
  void seize_mine();
  void release_mine();
  
public:
  B() { seize_mine(); }
  virtual ~B() { release_mine(); }

protected:
  virtual void seize() { seize_mine(); }
  virtual void release() { release_mine(); }
};

class D : public B {
  void seize_mine();
  void release_mine();
  
public:
  D() { seize_mine(); }
  virtual ~D() { release_mine(); }

protected:
  void seize() override {
    B::seize();
    seize_mine();
  }
  
  void release() override {
    release_mine();
    B::release();
  }
};
```

## Exceptions

**OOP50-CPP-EX1:** Because valid use cases exist that involve calling (non-pure) virtual functions from the constructor of a class, it is permissible to call the virtual function with an explicitly qualified ID. The qualified ID signifies to code maintainers that the expected behavior is for the class under construction or destruction to be the final overrider for the function call.

```cpp
struct A {
  A() {
    // f();   // WRONG!
    A::f();   // Okay
  }
  virtual void f();
};

```
**OOP50-CPP-EX2:** It is permissible to call a virtual function that has the `final` *virt-specifier* from a constructor or destructor, as in this example.

```cpp
struct A {
  A();
  virtual void f();
};
 
struct B : A {
  B() : A() {
    f();  // Okay
  }
  void f() override final;
};
```
Similarly, it is permissible to call a virtual function from a constructor or destructor of a class that has the `final` *class-virt-specifier*, as in this example.

```cpp
struct A {
  A();
  virtual void f();
};
 
struct B final : A {
  B() : A() {
    f();  // Okay
  }
  void f() override;
};
```
In either case, `f()` must be the final overrider, guaranteeing consistent behavior of the function being called.

## Risk Assessment

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> OOP50-CPP </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>virtual-call-in-constructorinvalid_function_pointer</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-OOP50</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>clang-analyzer-alpha.cplusplus.VirtualCall</code> </td> <td> Checked by <code>clang-tidy</code> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.VCALL_IN_CTOR</strong> <strong>LANG.STRUCT.VCALL_IN_DTOR</strong> </td> <td> Virtual Call in Constructor Virtual Call in Destructor </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4260, C++4261, C++4273, C++4274, C++4275, C++4276, C++4277, C++4278, C++4279, C++4280, C++4281, C++4282</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>467 S, 92 D</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-OOP50-a</strong> <strong>CERT_CPP-OOP50-b</strong> <strong>CERT_CPP-OOP50-c</strong> <strong>CERT_CPP-OOP50-d</strong> </td> <td> Avoid calling virtual functions from constructors Avoid calling virtual functions from destructors Do not use dynamic type of an object under construction Do not use dynamic type of an object under destruction </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: OOP50-CPP </a> </td> <td> Checks for virtual function call from constructors and destructors (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong> 4260, 4261, 4273, 4274,4275, 4276, 4277, 4278,4279, 4280, 4281, 4282 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V1053</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>virtual-call-in-constructor</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S1699</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+OOP30-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Dewhurst 2002 </a> \] </td> <td> Gotcha \#75, "Calling Virtual Functions in Constructors and Destructors" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 5.5, "Pointer-to-Member Operators" </td> </tr> <tr> <td> \[ <a> Lockheed Martin 2005 </a> \] </td> <td> AV Rule 71.1, "A class's virtual functions shall not be invoked from its destructor or any of its constructors" </td> </tr> <tr> <td> \[ <a> Sutter 2004 </a> \] </td> <td> Item 49, "Avoid Calling Virtual Functions in Constructors and Destructors" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [OOP50-CPP: Do not invoke virtual functions from constructors or destructors](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
