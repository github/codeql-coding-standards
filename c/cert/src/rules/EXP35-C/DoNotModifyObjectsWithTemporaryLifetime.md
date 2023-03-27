# EXP35-C: Do not modify objects with temporary lifetime

This query implements the CERT-C rule EXP35-C:

> Do not modify objects with temporary lifetime


## Description

The C11 Standard \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\] introduced a new term: *temporary lifetime*. Modifying an object with temporary lifetime is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). According to subclause 6.2.4, paragraph 8

> A non-lvalue expression with structure or union type, where the structure or union contains a member with array type (including, recursively, members of all contained structures and unions) refers to an object with automatic storage duration and *temporary*lifetime. Its lifetime begins when the expression is evaluated and its initial value is the value of the expression. Its lifetime ends when the evaluation of the containing full expression or full declarator ends. Any attempt to modify an object with temporary lifetime results in undefined behavior.


This definition differs from the C99 Standard (which defines modifying the result of a function call or accessing it after the next sequence point as undefined behavior) because a temporary object's lifetime ends when the evaluation containing the full expression or full declarator ends, so the result of a function call can be accessed. This extension to the lifetime of a temporary also removes a quiet change to C90 and improves compatibility with C++.

C functions may not return arrays; however, functions can return a pointer to an array or a `struct` or `union` that contains arrays. Consequently, in any version of C, if a function call returns by value a `struct` or `union` containing an array, do not modify those arrays within the expression containing the function call. In C99 and older, do not access an array returned by a function after the next sequence point or after the evaluation of the containing full expression or full declarator ends.

## Noncompliant Code Example

This noncompliant code example [conforms](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-conformingprogram) to the C11 Standard; however, it fails to conform to C99. If compiled with a C99-conforming implementation, this code has [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) because the sequence point preceding the call to `printf()` comes between the call and the access by `printf()` of the string in the returned object.

```cpp
#include <stdio.h>

struct X { char a[8]; };

struct X salutation(void) {
  struct X result = { "Hello" };
  return result;
}

struct X addressee(void) {
  struct X result = { "world" };
  return result;
}

int main(void) {
  printf("%s, %s!\n", salutation().a, addressee().a);
  return 0;
}

```

## Compliant Solution (C11 and newer)

This compliant solution checks `__STDC_VERSION__` to ensure that a pre-C11 compiler will fail to compile the code, rather than invoking undefined behavior.

```cpp
#include <stdio.h>

#if __STDC_VERSION__ < 201112L
#error This code requires a compiler supporting the C11 standard or newer
#endif

struct X { char a[8]; };

struct X salutation(void) {
  struct X result = { "Hello" };
  return result;
}

struct X addressee(void) {
  struct X result = { "world" };
  return result;
}

int main(void) {
  printf("%s, %s!\n", salutation().a, addressee().a);
  return 0;
}
```

## Compliant Solution

This compliant solution stores the structures returned by the call to `addressee()` before calling the `printf()` function. Consequently, this program conforms to both C99 and C11.

```cpp
#include <stdio.h>

struct X { char a[8]; };
 
struct X salutation(void) {
  struct X result = { "Hello" };
  return result;
}

struct X addressee(void) {
  struct X result = { "world" };
  return result;
}

int main(void) {
  struct X my_salutation = salutation();
  struct X my_addressee = addressee();
 
  printf("%s, %s!\n", my_salutation.a, my_addressee.a);
  return 0;
}

```

## Noncompliant Code Example

This noncompliant code example attempts to retrieve an array and increment the array's first value. The array is part of a `struct` that is returned by a function call. Consequently, the array has temporary lifetime, and modifying the array is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) in both C99 and C11.

```cpp
#include <stdio.h>

struct X { int a[6]; };

struct X addressee(void) {
  struct X result = { { 1, 2, 3, 4, 5, 6 } };
  return result;
}

int main(void) {
  printf("%x", ++(addressee().a[0]));
  return 0;
}

```

## Compliant Solution

This compliant solution stores the structure returned by the call to `addressee()` as `my_x` before calling the `printf()` function. When the array is modified, its lifetime is no longer temporary but matches the lifetime of the block in `main()`.

```cpp
#include <stdio.h>

struct X { int a[6]; };

struct X addressee(void) {
  struct X result = { { 1, 2, 3, 4, 5, 6 } };
  return result;
}

int main(void) {
  struct X my_x = addressee();
  printf("%x", ++(my_x.a[0]));
  return 0;
}

```

## Noncompliant Code Example

This noncompliant code example attempts to save a pointer to an array that is part of a `struct` that is returned by a function call. Consequently, the array has temporary lifetime, and using the pointer to it outside of the full expression is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) in both C99 and C11.

```cpp
#include <stdio.h>

struct X { int a[6]; };

struct X addressee(void) {
  struct X result = { { 1, 2, 3, 4, 5, 6 } };
  return result;
}

int main(void) {
  int *my_a = addressee().a;
  printf("%x", my_a[0]);
  return 0;
}

```

## Compliant Solution

This compliant solution stores the structure returned by the call to `addressee()` as `my_x` before saving a pointer to its array member. When the pointer is used, its lifetime is no longer temporary but matches the lifetime of the block in `main()`.

```cpp
#include <stdio.h>

struct X { int a[6]; };

struct X addressee(void) {
  struct X result = { { 1, 2, 3, 4, 5, 6 } };
  return result;
}

int main(void) {
  struct X my_x = addressee();
  int *my_a = my_x.a;
  printf("%x", my_a[0]);
  return 0;
}

```

## Risk Assessment

Attempting to modify an array or access it after its lifetime expires may result in erroneous program behavior.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP35-C </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>temporary-object-modification</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP35</strong> </td> <td> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C0450, C0455, C0459, C0464, C0465</strong> <strong>C++3807, C++3808</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>642 S, 42 D, 77 D</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-EXP35-a</strong> </td> <td> Do not modify objects with temporary lifetime </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT-C: Rule EXP35-C </a> </td> <td> Checks for accesses on objects with temporary lifetime (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0450 \[U\], 0455 \[U\], 0459 \[U\],</strong> <strong>0464 \[U\], 0465 \[U\]</strong> </td> <td> </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>temporary-object-modification</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP35-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Dangling References to Stack Frames \[DCM\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Side-effects and Order of Evaluation \[SAM\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.2.4, "Storage Durations of Objects" </td> </tr> </tbody> </table>


## Implementation notes

This implementation also always reports non-modifying accesses of objects with temporary lifetime, which are only compliant in C11.

## References

* CERT-C: [EXP35-C: Do not modify objects with temporary lifetime](https://wiki.sei.cmu.edu/confluence/display/c)
