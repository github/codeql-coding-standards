# EXP59-CPP: Use offsetof() on valid types and members

This query implements the CERT-C++ rule EXP59-CPP:

> Use offsetof() on valid types and members


## Description

The `offsetof()` macro is defined by the C Standard as a portable way to determine the offset, expressed in bytes, from the start of the object to a given member of that object. The C Standard, subclause 7.17, paragraph 3 \[[ISO/IEC 9899:1999](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-1999)\], in part, specifies the following:

> `offsetof(type, member-designator)` which expands to an integer constant expression that has type `size_t`, the value of which is the offset in bytes, to the structure member (designated by *member-designator*), from the beginning of its structure (designated by *type*). The type and member designator shall be such that given `static type t;` then the expression `&(t.member-designator)` evaluates to an address constant. (If the specified member is a bit-field, the behavior is undefined.)


The C++ Standard, \[support.types\], paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], places additional restrictions beyond those set by the C Standard:

> The macro `offsetof(type, member-designator)` accepts a restricted set of *type* arguments in this International Standard. If *type* is not a *standard-layout class*, the results are undefined. The expression `offsetof(type, member-designator)` is never type-dependent and it is value-dependent if and only if *type* is dependent. The result of applying the `offsetof` macro to a field that is a static data member or a function member is undefined. No operation invoked by the `offsetof` macro shall throw an exception and `noexcept(offsetof(type, member-designator))` shall be true.


When specifying the type argument for the `offsetof()` macro, pass only a standard-layout class. The full description of a standard-layout class can be found in paragraph 7 of the \[class\] clause of the C++ Standard, or the type can be checked with the `std::is_standard_layout<>` type trait. When specifying the member designator argument for the `offsetof()` macro, do not pass a bit-field, static data member, or function member. Passing an invalid type or member to the `offsetof()` macro is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

In this noncompliant code example, a type that is not a standard-layout class is passed to the `offsetof()` macro, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <cstddef>
 
struct D {
  virtual void f() {}
  int i;
};
 
void f() {
  size_t off = offsetof(D, i);
  // ...
}
```
**Implementation Details**

The noncompliant code example does not emit a diagnostic when compiled with the `/Wall` switch in [Microsoft Visual Studio ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-msvc)2015 on x86, resulting in `off` being `4`, due to the presence of a vtable for type `D`.

## Compliant Solution

It is not possible to determine the offset to `i` within `D` because `D` is not a standard-layout class. However, it is possible to make a standard-layout class within `D` if this functionality is critical to the application, as demonstrated by this compliant solution.

```cpp
#include <cstddef>

struct D {
  virtual void f() {}
  struct InnerStandardLayout {
    int i;
  } inner;
};

void f() {
  size_t off = offsetof(D::InnerStandardLayout, i);
  // ...
}
```

## Noncompliant Code Example

In this noncompliant code example, the offset to `i` is calculated so that a value can be stored at that offset within `buffer`. However, because `i` is a static data member of the class, this example results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). According to the C++ Standard, \[class.static.data\], paragraph 1 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], static data members are not part of the subobjects of a class.

```cpp
#include <cstddef>
 
struct S {
  static int i;
  // ...
};
int S::i = 0;
 
extern void store_in_some_buffer(void *buffer, size_t offset, int val);
extern void *buffer;
 
void f() {
  size_t off = offsetof(S, i);
  store_in_some_buffer(buffer, off, 42);
}
```
**Implementation Details**

The noncompliant code example does not emit a diagnostic when compiled with the `/Wall` switch in Microsoft Visual Studio 2015 on x86, resulting in `off` being a large value representing the offset between the null pointer address `0` and the address of the static variable `S::i`.

## Compliant Solution

Because static data members are not a part of the class layout, but are instead an entity of their own, this compliant solution passes the address of the static member variable as the buffer to store the data in and passes `0` as the offset.

```cpp
#include <cstddef>
 
struct S {
  static int i;
  // ...
};
int S::i = 0;
 
extern void store_in_some_buffer(void *buffer, size_t offset, int val);
 
void f() {
  store_in_some_buffer(&S::i, 0, 42);
}
```

## Risk Assessment

Passing an invalid type or member to `offsetof()` can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) that might be [exploited](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) to cause data integrity violations or result in incorrect values from the macro expansion.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP59-CPP </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>
**Automated Detection**


<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-EXP59</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Winvalid-offsetof</code> </td> <td> Emits an error diagnostic on invalid member designators, and emits a warning diagnostic on invalid types. </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADMACRO.OFFSETOF</strong> </td> <td> Use of offsetof </td> </tr> <tr> <td> <a> GCC </a> </td> <td> </td> <td> <code>-Winvalid-offsetof</code> </td> <td> Emits an error diagnostic on invalid member designators, and emits a warning diagnostic on invalid types. </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3915, C++3916</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP59-a</strong> </td> <td> Use offsetof() on valid types and members </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: EXP59-CPP </a> </td> <td> Checks use of offsetof macro with nonstandard layout class (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP59-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:1999 </a> \] </td> <td> Subclause 7.17, "Common Definitions <code>&lt;stddef.h&gt;</code> " </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 9.4.2, "Static Data Members" Subclause 18.2, "Types" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP59-CPP: Use offsetof() on valid types and members](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
