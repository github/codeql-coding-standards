# EXP51-CPP: Do not delete an array through a pointer of the incorrect type

This query implements the CERT-C++ rule EXP51-CPP:

> Do not delete an array through a pointer of the incorrect type


## Description

The C++ Standard, \[expr.delete\], paragraph 3 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> In the first alternative (*delete object*), if the static type of the object to be deleted is different from its dynamic type, the static type shall be a base class of the dynamic type of the object to be deleted and the static type shall have a virtual destructor or the behavior is undefined. In the second alternative (*delete array*) if the dynamic type of the object to be deleted differs from its static type, the behavior is undefined.


Do not delete an array object through a static pointer type that differs from the dynamic pointer type of the object. Deleting an array through a pointer to the incorrect type results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

In this noncompliant code example, an array of `Derived` objects is created and the pointer is stored in a `Base *`. Despite `Base::~Base`() being declared virtual, it still results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). Further, attempting to perform pointer arithmetic on the static type `Base *` violates [CTR56-CPP. Do not use pointer arithmetic on polymorphic objects](https://wiki.sei.cmu.edu/confluence/display/cplusplus/CTR56-CPP.+Do+not+use+pointer+arithmetic+on+polymorphic+objects).

```cpp
struct Base {
  virtual ~Base() = default;
};

struct Derived final : Base {};

void f() {
   Base *b = new Derived[10];
   // ...
   delete [] b;
}
```

## Compliant Solution

In this compliant solution, the static type of `b` is `Derived *`, which removes the [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) when indexing into the array as well as when deleting the pointer.

```cpp
struct Base {
  virtual ~Base() = default;
};

struct Derived final : Base {};

void f() {
   Derived *b = new Derived[10];
   // ...
   delete [] b;
}
```

## Risk Assessment

Attempting to destroy an array of polymorphic objects through the incorrect static type is undefined behavior. In practice, potential consequences include abnormal program execution and memory leaks.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP51-CPP </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-analyzer-checker=cplusplus</code> </td> <td> Checked with <code>clang -cc1</code> or (preferably) <code>scan-build</code> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>ALLOC.TM</strong> </td> <td> Type Mismatch </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3166</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.EXPR.DELETE_ARR.BASE_PTR</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP51-a</strong> </td> <td> Do not treat arrays polymorphically </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime detection </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP31-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> CTR56-CPP. Do not use pointer arithmetic on polymorphic objects </a> <a> OOP52-CPP. Do not delete a polymorphic object without a virtual destructor </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 5.3.5, "Delete" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP51-CPP: Do not delete an array through a pointer of the incorrect type](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
