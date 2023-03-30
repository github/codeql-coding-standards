# PRE31-C: Avoid side effects in arguments to unsafe macros

This query implements the CERT-C rule PRE31-C:

> Avoid side effects in arguments to unsafe macros


## Description

An [unsafe function-like macro](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unsafefunction-likemacro) is one whose expansion results in evaluating one of its parameters more than once or not at all. Never invoke an unsafe macro with arguments containing an assignment, increment, decrement, volatile access, input/output, or other expressions with side effects (including function calls, which may cause side effects).

The documentation for unsafe macros should warn against invoking them with arguments with side effects, but the responsibility is on the programmer using the macro. Because of the risks associated with their use, it is recommended that the creation of unsafe function-like macros be avoided. (See [PRE00-C. Prefer inline or static functions to function-like macros](https://wiki.sei.cmu.edu/confluence/display/c/PRE00-C.+Prefer+inline+or+static+functions+to+function-like+macros).)

This rule is similar to [EXP44-C. Do not rely on side effects in operands to sizeof, _Alignof, or _Generic](https://wiki.sei.cmu.edu/confluence/display/c/EXP44-C.+Do+not+rely+on+side+effects+in+operands+to+sizeof%2C+_Alignof%2C+or+_Generic).

## Noncompliant Code Example

One problem with unsafe macros is [side effects](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-sideeffect) on macro arguments, as shown by this noncompliant code example:

```cpp
#define ABS(x) (((x) < 0) ? -(x) : (x))
 
void func(int n) {
  /* Validate that n is within the desired range */
  int m = ABS(++n);

  /* ... */
}
```
The invocation of the `ABS()` macro in this example expands to

```cpp
m = (((++n) < 0) ? -(++n) : (++n));

```
The resulting code is well defined but causes `n` to be incremented twice rather than once.

## Compliant Solution

In this compliant solution, the increment operation `++n` is performed before the call to the unsafe macro.

```cpp
#define ABS(x) (((x) < 0) ? -(x) : (x)) /* UNSAFE */
 
void func(int n) {
  /* Validate that n is within the desired range */
  ++n;
  int m = ABS(n);

  /* ... */
}
```
Note the comment warning programmers that the macro is unsafe. The macro can also be renamed `ABS_UNSAFE()` to make it clear that the macro is unsafe. This compliant solution, like all the compliant solutions for this rule, has undefined behavior if the argument to `ABS()` is equal to the minimum (most negative) value for the signed integer type. (See [INT32-C. Ensure that operations on signed integers do not result in overflow](https://wiki.sei.cmu.edu/confluence/display/c/INT32-C.+Ensure+that+operations+on+signed+integers+do+not+result+in+overflow) for more information.)

## Compliant Solution

This compliant solution follows the guidance of [PRE00-C. Prefer inline or static functions to function-like macros](https://wiki.sei.cmu.edu/confluence/display/c/PRE00-C.+Prefer+inline+or+static+functions+to+function-like+macros) by defining an inline function `iabs()` to replace the `ABS()` macro. Unlike the `ABS()` macro, which operates on operands of any type, the `iabs()` function will truncate arguments of types wider than `int` whose value is not in range of the latter type.

```cpp
#include <complex.h>
#include <math.h>
 
static inline int iabs(int x) {
  return (((x) < 0) ? -(x) : (x));
}
 
void func(int n) {
  /* Validate that n is within the desired range */

int m = iabs(++n);

  /* ... */
}
```

## Compliant Solution

A more flexible compliant solution is to declare the `ABS()` macro using a `_Generic` selection. To support all arithmetic data types, this solution also makes use of inline functions to compute integer absolute values. (See [PRE00-C. Prefer inline or static functions to function-like macros](https://wiki.sei.cmu.edu/confluence/display/c/PRE00-C.+Prefer+inline+or+static+functions+to+function-like+macros) and [PRE12-C. Do not define unsafe macros](https://wiki.sei.cmu.edu/confluence/display/c/PRE12-C.+Do+not+define+unsafe+macros).)

According to the C Standard, 6.5.1.1, paragraph 3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\]:

> The controlling expression of a generic selection is not evaluated. If a generic selection has a generic association with a type name that is compatible with the type of the controlling expression, then the result expression of the generic selection is the expression in that generic association. Otherwise, the result expression of the generic selection is the expression in the `default` generic association. None of the expressions from any other generic association of the generic selection is evaluated.


Because the expression is not evaluated as part of the generic selection, the use of a macro in this solution is guaranteed to evaluate the macro parameter `v` only once.

```cpp
#include <complex.h>
#include <math.h>
 
static inline long long llabs(long long v) {
  return v < 0 ? -v : v;
}
static inline long labs(long v) {
  return v < 0 ? -v : v;
}
static inline int iabs(int v) {
  return v < 0 ? -v : v;
}
static inline int sabs(short v) {
  return v < 0 ? -v : v;
}
static inline int scabs(signed char v) {
  return v < 0 ? -v : v;
}
 
#define ABS(v)  _Generic(v, signed char : scabs, \
                            short : sabs, \
                            int : iabs, \
                            long : labs, \
                            long long : llabs, \
                            float : fabsf, \
                            double : fabs, \
                            long double : fabsl, \
                            double complex : cabs, \
                            float complex : cabsf, \
                            long double complex : cabsl)(v)
 
void func(int n) {
  /* Validate that n is within the desired range */
  int m = ABS(++n);
  /* ... */
}
```
Generic selections were introduced in C11 and are not available in C99 and earlier editions of the C Standard.

## Compliant Solution (GCC)

GCC's [__typeof](http://gcc.gnu.org/onlinedocs/gcc/Typeof.html) extension makes it possible to declare and assign the value of the macro operand to a temporary of the same type and perform the computation on the temporary, consequently guaranteeing that the operand will be evaluated exactly once. Another GCC extension, known as *statement expression[](http://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html)*, makes it possible for the block statement to appear where an expression is expected:

```cpp
#define ABS(x) __extension__ ({ __typeof (x) tmp = x; \
                    tmp < 0 ? -tmp : tmp; })
```
Note that relying on such extensions makes code nonportable and violates [MSC14-C. Do not introduce unnecessary platform dependencies](https://wiki.sei.cmu.edu/confluence/display/c/MSC14-C.+Do+not+introduce+unnecessary+platform+dependencies).

## Noncompliant Code Example (assert())

The `assert()` macro is a convenient mechanism for incorporating diagnostic tests in code. (See [MSC11-C. Incorporate diagnostic tests using assertions](https://wiki.sei.cmu.edu/confluence/display/c/MSC11-C.+Incorporate+diagnostic+tests+using+assertions).) Expressions used as arguments to the standard `assert()` macro should not have side effects. The behavior of the `assert()` macro depends on the definition of the object-like macro `NDEBUG`. If the macro `NDEBUG` is undefined, the `assert()` macro is defined to evaluate its expression argument and, if the result of the expression compares equal to 0, call the `abort()` function. If `NDEBUG` is defined, `assert` is defined to expand to `((void)0)`. Consequently, the expression in the assertion is not evaluated, and no side effects it may have had otherwise take place in non-debugging executions of the code.

This noncompliant code example includes an `assert()` macro containing an expression (`index++`) that has a side effect:

```cpp
#include <assert.h>
#include <stddef.h>
  
void process(size_t index) {
  assert(index++ > 0); /* Side effect */
  /* ... */
}

```

## Compliant Solution (assert())

This compliant solution avoids the possibility of side effects in assertions by moving the expression containing the side effect outside of the `assert()` macro.

```cpp
#include <assert.h>
#include <stddef.h>
  
void process(size_t index) {
  assert(index > 0); /* No side effect */
  ++index;
  /* ... */
}
```

## Exceptions

**PRE31-C-EX1:** An exception can be made for invoking an [unsafe macro](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unsafefunction-likemacro) with a function call argument provided that the function has no [side effects](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-sideeffect). However, it is easy to forget about obscure side effects that a function might have, especially library functions for which source code is not available; even changing `errno` is a side effect. Unless the function is user-written and does nothing but perform a computation and return its result without calling any other functions, it is likely that many developers will forget about some side effect. Consequently, this exception must be used with great care.

## Risk Assessment

Invoking an unsafe macro with an argument that has side effects may cause those side effects to occur more than once. This practice can lead to [unexpected program behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> PRE31-C </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>expanded-side-effect-multiplied</strong> <strong>expanded-side-effect-not-evaluated</strong> <strong>side-effect-not-expanded</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-PRE31</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.PREPROC.FUNCMACRO</strong> <strong>LANG.STRUCT.SE.DEC</strong> <strong>LANG.STRUCT.SE.INC</strong> </td> <td> Function-Like Macro Side Effects in Expression with Decrement Side Effects in Expression with Increment </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>ASSERT_SIDE_EFFECTS</strong> </td> <td> Partially implemented Can detect the specific instance where assertion contains an operation/function call that may have a side effect </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.EXP31CC2.PRE31</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C3462,</strong> <strong> C3463, </strong> <strong>C3464,</strong> <strong>C3465,</strong> <strong>C3466,</strong> <strong>C3467</strong> <strong>C++3225,</strong> <strong> C++3226,</strong> <strong> C++3227,</strong> <strong> C++3228,</strong> <strong> C++3229 </strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>PORTING.VAR.EFFECTS</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>9 S, 562 S, 572 S, 35 D, 1 Q</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-PRE31-b</strong> <strong>CERT_C-PRE31-c</strong> <strong>CERT_C-PRE31-d</strong> </td> <td> Assertions should not contain assignments, increment, or decrement operators Assertions should not contain function calls nor function-like macro calls Avoid side effects in arguments to unsafe macros </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>666, 2666</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule PRE31-C </a> </td> <td> Checks for side effect in arguments to unsafe macro (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>3462, 3463, 3464, 3465, 3466, 3467</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3225, 3226, 3227, 3228, 3229 </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>expanded-side-effect-multiplied</strong> <strong>expanded-side-effect-not-evaluated</strong> <strong>side-effect-not-expanded</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&amp;query=FIELD+KEYWORDS+contains+PRE31-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Dewhurst 2002 </a> \] </td> <td> Gotcha \#28, "Side Effects in Assertions" </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 6.5.1.1, "Generic Selection" </td> </tr> <tr> <td> \[ <a> Plum 1985 </a> \] </td> <td> Rule 1-11 </td> </tr> </tbody> </table>


## Implementation notes

This implementation only considers ++ and function call side effects. Due to the textual nature of macro expansion it is not always possible to determine accurately whether a side-effect was produced by a particular argument, and this may cause both false positives and false negatives. The query does not consider the case where a macro argument including a side-effect is never evaluated.

## References

* CERT-C: [PRE31-C: Avoid side effects in arguments to unsafe macros](https://wiki.sei.cmu.edu/confluence/display/c)
