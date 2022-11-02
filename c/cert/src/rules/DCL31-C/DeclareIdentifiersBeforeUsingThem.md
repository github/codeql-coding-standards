# DCL31-C: Declare identifiers before using them

This query implements the CERT-C rule DCL31-C:

> Declare identifiers before using them


## Description

The C11 Standard requires type specifiers and forbids implicit function declarations. The C90 Standard allows implicit typing of variables and functions. Consequently, some existing legacy code uses implicit typing. Some C compilers still support legacy code by allowing implicit typing, but it should not be used for new code. Such an [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) may choose to assume an implicit declaration and continue translation to support existing programs that used this feature.

## Noncompliant Code Example (Implicit int)

C no longer allows the absence of type specifiers in a declaration. The C Standard, 6.7.2 \[ [ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011) \], states

> At least one type specifier shall be given in the declaration specifiers in each declaration, and in the specifier-qualifier list in each `struct` declaration and type name.


This noncompliant code example omits the type specifier:

```cpp
extern foo;

```
Some C [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) do not issue a diagnostic for the violation of this constraint. These nonconforming C translators continue to treat such declarations as implying the type `int`.

## Compliant Solution (Implicit int)

This compliant solution explicitly includes a type specifier:

```cpp
extern int foo;

```

## Noncompliant Code Example (Implicit Function Declaration)

Implicit declaration of functions is not allowed; every function must be explicitly declared before it can be called. In C90, if a function is called without an explicit prototype, the compiler provides an implicit declaration.

The C90 Standard \[[ISO/IEC 9899:1990](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-1990)\] includes this requirement:

> If the expression that precedes the parenthesized argument list in a function call consists solely of an identifier, and if no declaration is visible for this identifier, the identifier is implicitly declared exactly as if, in the innermost block containing the function call, the declaration `extern int identifier();` appeared.


If a function declaration is not visible at the point at which a call to the function is made, C90-compliant platforms assume an implicit declaration of `extern int identifier();`.

This declaration implies that the function may take any number and type of arguments and return an `int`. However, to conform to the current C Standard, programmers must explicitly prototype every function before invoking it. An implementation that conforms to the C Standard may or may not perform implicit function declarations, but C does require a conforming implementation to issue a diagnostic if it encounters an undeclared function being used.

In this noncompliant code example, if `malloc()` is not declared, either explicitly or by including `stdlib.h`, a compiler that conforms only to C90 may implicitly declare `malloc()` as `int malloc()`. If the platform's size of `int` is 32 bits, but the size of pointers is 64 bits, the resulting pointer would likely be truncated as a result of the implicit declaration of `malloc()`, returning a 32-bit integer.

```cpp
#include <stddef.h>
/* #include <stdlib.h> is missing */
 
int main(void) {
  for (size_t i = 0; i < 100; ++i) {
    /* int malloc() assumed */
    char *ptr = (char *)malloc(0x10000000);
    *ptr = 'a';
  }
  return 0;
}
```
**Implementation Details**

When compiled with Microsoft Visual Studio 2013 for a 64-bit platform, this noncompliant code example will eventually cause an access violation when dereferencing `ptr` in the loop.

## Compliant Solution (Implicit Function Declaration)

This compliant solution declares `malloc()` by including the appropriate header file:

```cpp
#include <stdlib.h>
 
int main(void) {
  for (size_t i = 0; i < 100; ++i) {
    char *ptr = (char *)malloc(0x10000000);
    *ptr = 'a';
  }
  return 0;
}
```
For more information on function declarations, see [DCL07-C. Include the appropriate type information in function declarators](https://wiki.sei.cmu.edu/confluence/display/c/DCL07-C.+Include+the+appropriate+type+information+in+function+declarators).

## Noncompliant Code Example (Implicit Return Type)

Do not declare a function with an implicit return type. For example, if a function returns a meaningful integer value, declare it as returning `int`. If it returns no meaningful value, declare it as returning `void`.

```cpp
#include <limits.h>
#include <stdio.h>
 
foo(void) {
  return UINT_MAX;
}

int main(void) {
  long long int c = foo();
  printf("%lld\n", c);
  return 0;
}

```
Because the compiler assumes that `foo()` returns a value of type `int` for this noncompliant code example, `UINT_MAX` is incorrectly converted to `−1`.

## Compliant Solution (Implicit Return Type)

This compliant solution explicitly defines the return type of `foo()` as `unsigned int`. As a result, the function correctly returns ` `UINT_MAX` `.

```cpp
#include <limits.h>
#include <stdio.h>

unsigned int foo(void) {
  return UINT_MAX;
}

int main(void) {
  long long int c = foo();
  printf("%lld\n", c);
  return 0;
}

```

## Risk Assessment

Because implicit declarations lead to less stringent type checking, they can introduce [unexpected](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior) and erroneous behavior. Occurrences of an omitted type specifier in existing code are rare, and the consequences are generally minor, perhaps resulting in [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL31-C </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>type-specifier</strong> <strong>function-return-type</strong> <strong>implicit-function-declaration</strong> <strong>undeclared-parameter</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-DCL31</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wimplicit-int</code> </td> <td> </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2012 Rule 8.1</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.DCL31</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 4.3.5 </td> <td> </td> <td> Can detect violations of this rule when the <code>-Wimplicit</code> and <code>-Wreturn-type</code> flags are used </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C0434, C2050, C2051, C3335</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CWARN.IMPLICITINT</strong> <strong>MISRA.DECL.NO_TYPE</strong> <strong>MISRA.FUNC.NOPROT.CALL</strong> <strong>RETVOID.IMPLICIT</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>24 D, 41 D, 20 S, 326 S, 496 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-DCL31-a</strong> </td> <td> All functions shall be declared before use </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>601, 718, 746, 808</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule DCL31-C </a> </td> <td> Checks for: Types not explicitly specifiedypes not explicitly specified, implicit function declarationmplicit function declaration. Rule fully covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0434 (C)205020513335</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.20 </td> <td> <strong><a>V1031</a></strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong> <a>S819</a>, </strong> <strong><a>S820</a> </strong> </td> <td> Partially implemented; implicit return type not covered. </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>type-specifier</strong> <strong>function-return-type</strong> <strong>implicit-function-declaration</strong> <strong>undeclared-parameter</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>type specifier missing</strong> </td> <td> Partially verified (exhaustively detects undefined behavior). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+DCL31-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> DCL07-C. Include the appropriate type information in function declarators </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Subprogram Signature Mismatch \[OTR\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 8.1 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:1990 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 6.7.2, "Type Specifiers" </td> </tr> <tr> <td> \[ <a> Jones 2008 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

This query does not check for implicitly typed parameters, typedefs or member declarations as this is partially compiler checked.

## References

* CERT-C: [DCL31-C: Declare identifiers before using them](https://wiki.sei.cmu.edu/confluence/display/c)
