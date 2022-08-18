# EXP52-CPP: Do not rely on side effects in the operator noexcept

This query implements the CERT-C++ rule EXP52-CPP:

> Do not rely on side effects in unevaluated operands


## Description

Some expressions involve operands that are *unevaluated*. The C++ Standard, \[expr\], paragraph 8 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\] states the following:

> In some contexts, *unevaluated operands* appear. An unevaluated operand is not evaluated. An unevaluated operand is considered a full-expression. \[Note: In an unevaluated operand, a non-static class member may be named (5.1) and naming of objects or functions does not, by itself, require that a definition be provided. — end note\]


The following expressions do not evaluate their operands: `sizeof()`, `typeid()`, `noexcept()`, `decltype()`, and `declval()`.

Because an unevaluated operand in an expression is not evaluated, no side effects from that operand are triggered. Reliance on those side effects will result in unexpected behavior. Do not rely on side effects in unevaluated operands.

Unevaluated expression operands are used when the declaration of an object is required but the definition of the object is not. For instance, in the following example, the function `f()` is overloaded, relying on the unevaluated expression operand to select the desired overload, which is then used to determine the result of the `sizeof()` expression.

```cpp
int f(int);
double f(double);
size_t size = sizeof(f(0));
```
Such a use does not rely on the side effects of `f()` and consequently conforms to this guideline.

## Noncompliant Code Example (sizeof)

In this noncompliant code example, the expression `a++` is not evaluated.

```cpp
#include <iostream>
void f() {
  int a = 14;
  int b = sizeof(a++);
  std::cout << a << ", " << b << std::endl;
}
```
Consequently, the value of `a` after `b` has been initialized is 14.

## Compliant Solution (sizeof)

In this compliant solution, the variable `a` is incremented outside of the `sizeof` operator.

```cpp
#include <iostream>
void f() {
  int a = 14;
  int b = sizeof(a);
  ++a;
  std::cout << a << ", " << b << std::endl;
}
```

## Noncompliant Code Example (decltype)

In this noncompliant code example, the expression `i++` is not evaluated within the `decltype` specifier.

```cpp
#include <iostream>

void f() {
  int i = 0;
  decltype(i++) h = 12;
  std::cout << i;
}
```
Consequently, the value of i remains 0.

## Compliant Solution (decltype)

In this compliant solution, `i` is incremented outside of the `decltype` specifier so that it is evaluated as desired.

```cpp
#include <iostream>

void f() {
  int i = 0;
  decltype(i) h = 12;
  ++i;
  std::cout << i;
}
```

## Exceptions

**EXP52-CPP-EX1:** It is permissible for an expression with side effects to be used as an unevaluated operand in a macro definition or [SFINAE](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-SFINAE) context. Although these situations rely on the side effects to produce valid code, they typically do not rely on values produced as a result of the side effects.

The following code is an example of compliant code using an unevaluated operand in a macro definition.

```cpp
void small(int x);
void large(long long x);
 
#define m(x)                                     \
  do {                                           \
    if (sizeof(x) == sizeof(int)) {              \
      small(x);                                  \
    } else if (sizeof(x) == sizeof(long long)) { \
      large(x);                                  \
    }                                            \
  } while (0)
 
void f() {
  int i = 0;
  m(++i);
}
```
The expansion of the macro `m` will result in the expression `++i` being used as an unevaluated operand to `sizeof()`. However, the expectation of the programmer at the expansion loci is that `i` is preincremented only once. Consequently, this is a safe macro and complies with [PRE31-C. Avoid side effects in arguments to unsafe macros](https://wiki.sei.cmu.edu/confluence/display/c/PRE31-C.+Avoid+side+effects+in+arguments+to+unsafe+macros). Compliance with that rule is especially important for code that follows this exception.

The following code is an example of compliant code using an unevaluated operand in a SFINAE context to determine whether a type can be postfix incremented.

```cpp
#include <iostream>
#include <type_traits>
#include <utility>

template <typename T>
class is_incrementable {
  typedef char one[1];
  typedef char two[2];
  static one &is_incrementable_helper(decltype(std::declval<typename std::remove_cv<T>::type&>()++) *p);
  static two &is_incrementable_helper(...);
  
public:
  static const bool value = sizeof(is_incrementable_helper(nullptr)) == sizeof(one);
};

void f() {
  std::cout << std::boolalpha << is_incrementable<int>::value;
}
```
In an instantiation of `is_incrementable`, the use of the postfix increment operator generates side effects that are used to determine whether the type is postfix incrementable. However, the value result of these side effects is discarded, so the side effects are used only for SFINAE.

## Risk Assessment

If expressions that appear to produce side effects are an unevaluated operand, the results may be different than expected. Depending on how this result is used, it can lead to unintended program behavior.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP52-CPP </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>sizeof</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-EXP52</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wunevaluated-expression</code> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.SE.SIZEOF</strong> </td> <td> Side Effects in sizeof </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3240, C++3241</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.SIZEOF.SIDE_EFFECT</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>54 S, 133 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP52-a</strong> <strong>CERT_CPP-EXP52-b</strong> <strong>CERT_CPP-EXP52-cCERT_CPP-EXP52-dCERT_CPP-EXP52-e</strong> </td> <td> The operand of the sizeof operator shall not contain any expression which has side effects Object designated by a volatile lvalue should not be accessed in the operand of the sizeof operator The function call that causes the side effect shall not be the operand of the sizeof operator The operand of the 'typeid' operator shall not contain any expression that has side effects The operand of the 'typeid' operator shall not contain a function call that causes side effects </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: EXP52-CPP </a> </td> <td> Checks for logical operator operand with side effects </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3240, 3241</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>sizeof</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnera) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP32-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> EXP44-C. Do not rely on side effects in operands to sizeof, _Alignof, or _Generic </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Clause 5, "Expressions" Subclause 20.2.5, "Function Template <code>declval</code> " </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP52-CPP: Do not rely on side effects in unevaluated operands](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
