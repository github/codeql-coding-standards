# OOP55-CPP: Do not use pointer-to-member operators to access nonexistent members

This query implements the CERT-C++ rule OOP55-CPP:

> Do not use pointer-to-member operators to access nonexistent members


## Description

The pointer-to-member operators `.*` and `->*` are used to obtain an object or a function as though it were a member of an underlying object. For instance, the following are functionally equivalent ways to call the member function `f()` on the object `o`.

```cpp
struct S {
  void f() {}
};

void func() {
  S o;
  void (S::*pm)() = &S::f;
  
  o.f();
  (o.*pm)();
}
```
The call of the form `o.f()` uses class member access at compile time to look up the address of the function `S::f()` on the object `o`. The call of the form `(o.*pm)()` uses the pointer-to-member operator `.*` to call the function at the address specified by `pm`. In both cases, the object `o` is the implicit `this` object within the member function `S::f()`.

The C++ Standard, \[expr.mptr.oper\], paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> Abbreviating *pm-expression.\*cast-expression* as `E1.*E2`, `E1` is called the *object expression*. If the dynamic type of `E1` does not contain the member to which `E2` refers, the behavior is undefined.


A pointer-to-member expression of the form `E1->*E2` is converted to its equivalent form, `(*(E1)).*E2`, so use of pointer-to-member expressions of either form behave equivalently in terms of [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

Further, the C++ Standard, \[expr.mptr.oper\], paragraph 6, in part, states the following:

> If the second operand is the null pointer to member value, the behavior is undefined.


Do not use a pointer-to-member expression where the dynamic type of the first operand does not contain the member to which the second operand refers, including the use of a null pointer-to-member value as the second operand.

## Noncompliant Code Example

In this noncompliant code example, a pointer-to-member object is obtained from `D::g` but is then upcast to be a `B::*`. When called on an object whose dynamic type is `D`, the pointer-to-member call is well defined. However, the dynamic type of the underlying object is `B`, which results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
struct B {
  virtual ~B() = default;
};

struct D : B {
  virtual ~D() = default;
  virtual void g() { /* ... */ }
};

void f() {
  B *b = new B;
 
  // ...
 
  void (B::*gptr)() = static_cast<void(B::*)()>(&D::g);
  (b->*gptr)();
  delete b;
}

```

## Compliant Solution

In this compliant solution, the upcast is removed, rendering the initial code [ill-formed](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-ill-formed) and emphasizing the underlying problem that `B::g()` does not exist. This compliant solution assumes that the programmer's intention was to use the correct dynamic type for the underlying object.

```cpp
struct B {
  virtual ~B() = default;
};

struct D : B {
  virtual ~D() = default;
  virtual void g() { /* ... */ }
};

void f() {
  B *b = new D; // Corrected the dynamic object type.
 
  // ...
  void (D::*gptr)() = &D::g; // Moved static_cast to the next line.
  (static_cast<D *>(b)->*gptr)();
  delete b;
}

```

## Noncompliant Code Example

In this noncompliant code example, a null pointer-to-member value is passed as the second operand to a pointer-to-member expression, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
struct B {
  virtual ~B() = default;
};

struct D : B {
  virtual ~D() = default;
  virtual void g() { /* ... */ }
};
 
static void (D::*gptr)(); // Not explicitly initialized, defaults to nullptr.
void call_memptr(D *ptr) {
  (ptr->*gptr)();
}
 
void f() {
  D *d = new D;
  call_memptr(d);
  delete d;
}
```

## Compliant Solution

In this compliant solution, `gptr` is properly initialized to a valid pointer-to-member value instead of to the default value of `nullptr`.

```cpp
struct B {
  virtual ~B() = default;
};
 
struct D : B {
  virtual ~D() = default;
  virtual void g() { /* ... */ }
};
 
static void (D::*gptr)() = &D::g; // Explicitly initialized.
void call_memptr(D *ptr) {
  (ptr->*gptr)();
}
 
void f() {
  D *d = new D;
  call_memptr(d);
  delete d;
}
```

## Risk Assessment

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> OOP55-CPP </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>overflow_upon_dereferenceinvalid_function_pointer</strong> </td> <td> </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-OOP55</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.UVAR</strong> </td> <td> Uninitialized Variable </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2810, C++2811, C++2812, C++2813, C++2814</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.OOP.PTR_MEMBER.NO_MEMBER</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-OOP55-a</strong> </td> <td> A cast shall not convert a pointer to a function to any other pointer type, including a pointer to function type </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime detection </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: OOP55-CPP </a> </td> <td> Checks for pointers to member accessing non-existent class members (rule fully covered). </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2810, 2811, 2812, 2813, 2814 </strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+OOP39-CPP).

## Related Guidelines

*This rule is a subset of [EXP34-C. Do not dereference null pointers](https://wiki.sei.cmu.edu/confluence/display/c/EXP34-C.+Do+not+dereference+null+pointers).*

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 5.5, "Pointer-to-Member Operators" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [OOP55-CPP: Do not use pointer-to-member operators to access nonexistent members](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
