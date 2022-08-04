# DCL60-CPP: Obey the one-definition rule

This query implements the CERT-C++ rule DCL60-CPP:

> Obey the one-definition rule


## Description

Nontrivial C++ programs are generally divided into multiple translation units that are later linked together to form an executable. To support such a model, C++ restricts named object definitions to ensure that linking will behave deterministically by requiring a single definition for an object across all translation units. This model is called the o*ne-definition rule* (ODR), which is defined by the C++ Standard, \[basic.def.odr\], in paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]:

Every program shall contain exactly one definition of every non-inline function or variable that is odr-used in that program; no diagnostic required. The definition can appear explicitly in the program, it can be found in the standard or a user-defined library, or (when appropriate) it is implicitly-defined. An inline function shall be defined in every translation unit in which it is odr-used.

The most common approach to multitranslation unit compilation involves declarations residing in a header file that is subsequently made available to a source file via `#include`. These declarations are often also definitions, such as class and function template definitions. This approach is allowed by an exception defined in paragraph 6, which, in part, states the following:

> There can be more than one definition of a class type, enumeration type, inline function with external linkage, class template, non-static function template, static data member of a class template, member function of a class template, or template specialization for which some template parameters are not specified in a program provided that each definition appears in a different translation unit, and provided the definitions satisfy the following requirements. Given such an entity named `D` defined in more than one translation unit....


If the definitions of `D` satisfy all these requirements, then the program shall behave as if there were a single definition of `D`. If the definitions of `D` do not satisfy these requirements, then the behavior is undefined.

The requirements specified by paragraph 6 essentially state that that two definitions must be identical (not simply equivalent). Consequently, a definition introduced in two separate translation units by an `#include` directive generally will not violate the ODR because the definitions are identical in both translation units.

However, it is possible to violate the ODR of a definition introduced via `#include` using block language linkage specifications, vendor-specific language extensions, and so on. A more likely scenario for ODR violations is that accidental definitions of differing objects will exist in different translation units.

Do not violate the one-definition rule; violations result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

In this noncompliant code example, two different translation units define a class of the same name with differing definitions. Although the two definitions are functionally equivalent (they both define a class named `S` with a single, public, nonstatic data member `int a`), they are not defined using the same sequence of tokens. This code example violates the ODR and results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
// a.cpp
struct S {
  int a;
};
 
// b.cpp
class S {
public:
  int a;
};
```

## Compliant Solution

The correct mitigation depends on programmer intent. If the programmer intends for the same class definition to be visible in both translation units because of common usage, the solution is to use a header file to introduce the object into both translation units, as shown in this compliant solution.

```cpp
// S.h
struct S {
  int a;
};
 
// a.cpp
#include "S.h"
 
// b.cpp
#include "S.h"
```

## Compliant Solution

If the ODR violation was a result of accidental name collision, the best mitigation solution is to ensure that both class definitions are unique, as in this compliant solution.

```cpp
// a.cpp
namespace {
struct S {
  int a;
};
}
 
// b.cpp
namespace {
class S {
public:
  int a;
};
}
```
Alternatively, the classes could be given distinct names in each translation unit to avoid violating the ODR.

## Noncompliant Code Example (Microsoft Visual Studio)

In this noncompliant code example, a class definition is introduced into two translation units using `#include`. However, one of the translation units uses an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbed) `#pragma` that is supported by Microsoft Visual Studio to specify structure field alignment requirements. Consequently, the two class definitions may have differing layouts in each translation unit, which is a violation of the ODR.

```cpp
// s.h
struct S {
  char c;
  int a;
};
 
void init_s(S &s);
 
// s.cpp
#include "s.h"
 
void init_s(S &s); {
  s.c = 'a';
  s.a = 12;
}
 
// a.cpp
#pragma pack(push, 1)
#include "s.h"
#pragma pack(pop)
 
void f() {
  S s;
  init_s(s);
}
```
**Implementation Details**

It is possible for the preceding noncompliant code example to result in `a.cpp` allocating space for an object with a different size than expected by `init_s()` in `s.cpp`. When translating `s.cpp`, the layout of the structure may include padding bytes between the `c` and `a` data members. When translating `a.cpp`, the layout of the structure may remove those padding bytes as a result of the `#pragma pack` directive, so the object passed to `init_s()` may be smaller than expected. Consequently, when `init_s()` initializes the data members of `s`, it may result in a buffer overrun.

For more information on the behavior of `#pragma pack`, see the vendor documentation for your [implementation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions), such as [Microsoft Visual Studio](https://msdn.microsoft.com/en-us/library/2e70t5y1.aspx) or [GCC](https://gcc.gnu.org/onlinedocs/gcc-4.4.4/gcc/Structure_002dPacking-Pragmas.html).

## Compliant Solution

In this compliant solution, the implementation-defined structure member-alignment directive is removed, ensuring that all definitions of `S` comply with the ODR.

```cpp
// s.h
struct S {
  char c;
  int a;
};
 
void init_s(S &s);
 
// s.cpp
#include "s.h"
 
void init_s(S &s); {
  s.c = 'a';
  s.a = 12;
}
 
// a.cpp
#include "s.h"
 
void f() {
  S s;
  init_s(s);
}
```

## Noncompliant Code Example

In this noncompliant code example, the constant object `n` has internal linkage but is [odr-used](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-odr-use) within `f()`, which has external linkage. Because `f()` is declared as an inline function, the definition of `f()` must be identical in all translation units. However, each translation unit has a unique instance of `n`, resulting in a violation of the ODR.

```cpp
const int n = 42;
 
int g(const int &lhs, const int &rhs);
 
inline int f(int k) {
  return g(k, n);
}
```

## Compliant Solution

A compliant solution must change one of three factors: (1) it must not odr-use `n` within `f()`, (2) it must declare `n` such that it has external linkage, or (3) it must not use an inline definition of `f()`.

If circumstances allow modification of the signature of `g()` to accept parameters by value instead of by reference, then `n` will not be odr-used within `f()` because `n` would then qualify as a constant expression. This solution is compliant but it is not ideal. It may not be possible (or desirable) to modify the signature of `g(), `such as if `g()` represented `std::max()` from `<algorithm>`. Also, because of the differing linkage used by `n` and `f()`, accidental violations of the ODR are still likely if the definition of `f()` is modified to odr-use `n`.

```cpp
const int n = 42;
 
int g(int lhs, int rhs);
 
inline int f(int k) {
  return g(k, n);
}
```

## Compliant Solution

In this compliant solution, the constant object `n` is replaced with an enumerator of the same name. Named enumerations defined at namespace scope have the same linkage as the namespace they are contained in. The global namespace has external linkage, so the definition of the named enumeration and its contained enumerators also have external linkage. Although less aesthetically pleasing, this compliant solution does not suffer from the same maintenance burdens of the previous code because `n` and `f()` have the same linkage.

```cpp
enum Constants {
  N = 42
};

int g(const int &lhs, const int &rhs);
 
inline int f(int k) {
  return g(k, N);
}
```

## Risk Assessment

Violating the ODR causes [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior), which can result in exploits as well as [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions). As shown in "Support for Whole-Program Analysis and the Verification of the One-Definition Rule in C++" \[[Quinlan 06](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Quinlan06)\], failing to enforce the ODR enables a virtual function pointer attack known as the *VPTR [exploit](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit)*. In this exploit, an object's virtual function table is corrupted so that calling a virtual function on the object results in malicious code being executed. See the paper by Quinlan and colleagues for more details. However, note that to introduce the malicious class, the attacker must have access to the system building the code.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL60-CPP </td> <td> High </td> <td> Unlikely </td> <td> High </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>type-compatibilitydefinition-duplicateundefined-externundefined-extern-pure-virtualexternal-file-spreadingtype-file-spreading</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-DCL60</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.DEF.FDHLANG.STRUCT.DEF.ODH</strong> </td> <td> Function defined in header file Object defined in header file </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++1067, C++1509, C++1510</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>286 S, 287 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-DCL60-a</strong> </td> <td> A class, union or enum name (including qualification, if any) shall be a unique identifier </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: DCL60-CPP </a> </td> <td> Checks for inline constraints not respected (rule partially covered) </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>type-compatibility</strong> <strong>definition-duplicate</strong> <strong>undefined-extern</strong> <strong>undefined-extern-pure-virtual</strong> <strong>external-file-spreading</strong> <strong>type-file-spreading</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+DCL60-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.2, "One Definition Rule" </td> </tr> <tr> <td> \[ <a> Quinlan 2006 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [DCL60-CPP: Obey the one-definition rule](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
