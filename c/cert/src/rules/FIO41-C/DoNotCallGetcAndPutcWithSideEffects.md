# FIO41-C: Do not call getc(), putc(), getwc(), or putwc() with a stream argument that has side effects

This query implements the CERT-C rule FIO41-C:

> Do not call getc(), putc(), getwc(), or putwc() with a stream argument that has side effects


## Description

Do not invoke `getc()` or `putc()` or their wide-character analogues `getwc()` and `putwc()` with a stream argument that has side effects. The stream argument passed to these macros may be evaluated more than once if these functions are implemented as unsafe macros. (See [PRE31-C. Avoid side effects in arguments to unsafe macros](https://wiki.sei.cmu.edu/confluence/display/c/PRE31-C.+Avoid+side+effects+in+arguments+to+unsafe+macros) for more information.)

This rule does not apply to the character argument in `putc()` or the wide-character argument in `putwc()`, which is guaranteed to be evaluated exactly once.

## Noncompliant Code Example (getc())

This noncompliant code example calls the `getc()` function with an expression as the stream argument. If `getc()` is implemented as a macro, the file may be opened multiple times. (See [FIO24-C. Do not open a file that is already open](https://wiki.sei.cmu.edu/confluence/display/c/FIO24-C.+Do+not+open+a+file+that+is+already+open).)

```cpp
#include <stdio.h>
 
void func(const char *file_name) {
  FILE *fptr;

  int c = getc(fptr = fopen(file_name, "r"));
  if (feof(fptr) || ferror(fptr)) {
    /* Handle error */
  }

  if (fclose(fptr) == EOF) {
    /* Handle error */
  }
}
```
This noncompliant code example also violates [ERR33-C. Detect and handle standard library errors](https://wiki.sei.cmu.edu/confluence/display/c/ERR33-C.+Detect+and+handle+standard+library+errors) because the value returned by `fopen()` is not checked for errors.

## Compliant Solution (getc())

In this compliant solution, `fopen()` is called before `getc()` and its return value is checked for errors:

```cpp
#include <stdio.h>
 
void func(const char *file_name) {
  int c;
  FILE *fptr;

  fptr = fopen(file_name, "r");
  if (fptr == NULL) {
    /* Handle error */
  }

  c = getc(fptr);
  if (c == EOF) {
    /* Handle error */
  }

  if (fclose(fptr) == EOF) {
    /* Handle error */
  }
}
```

## Noncompliant Code Example (putc())

In this noncompliant example, `putc()` is called with an expression as the stream argument. If `putc()` is implemented as a macro, this expression might be evaluated multiple times.

```cpp
#include <stdio.h>
 
void func(const char *file_name) {
  FILE *fptr = NULL;
  int c = 'a';
 
  while (c <= 'z') {
    if (putc(c++, fptr ? fptr :
         (fptr = fopen(file_name, "w"))) == EOF) {
      /* Handle error */
    }
  }

  if (fclose(fptr) == EOF) {
    /* Handle error */
  }
}
```
This noncompliant code example might appear safe even if the `putc()` macro evaluates its stream argument multiple times, as the ternary conditional expression ostensibly prevents multiple calls to `fopen()`. However, the assignment to `fptr` and the evaluation of `fptr` as the controlling expression of the ternary conditional expression can take place between the same sequence points, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) (a violation of [EXP30-C. Do not depend on the order of evaluation for side effects](https://wiki.sei.cmu.edu/confluence/display/c/EXP30-C.+Do+not+depend+on+the+order+of+evaluation+for+side+effects)). This code also violates [ERR33-C. Detect and handle standard library errors](https://wiki.sei.cmu.edu/confluence/display/c/ERR33-C.+Detect+and+handle+standard+library+errors) because it fails to check the return value from `fopen()`.

## Compliant Solution (putc())

In this compliant solution, the stream argument to `putc()` no longer has side effects:

```cpp
#include <stdio.h>
 
void func(const char *file_name) {
  int c = 'a'; 
  FILE *fptr = fopen(file_name, "w");
 
  if (fptr == NULL) {
    /* Handle error */
  }

  while (c <= 'z') {
    if (putc(c++, fptr) == EOF) {
      /* Handle error */
    }
  }

  if (fclose(fptr) == EOF) {
    /* Handle error */
  }
}
```
The expression `c++` is perfectly safe because `putc()` guarantees to evaluate its character argument exactly once.

NOTE: The output of this compliant solution differs depending on the character set. For example, when run on a machine using an ASCII-derived code set such as ISO-8859 or Unicode, this solution will print out the 26 lowercase letters of the English alphabet. However, if run with an EBCDIC-based code set, such as Codepage 037 or Codepage 285, punctuation marks or symbols may be output between the letters.

## Risk Assessment

Using an expression that has side effects as the stream argument to `getc()`, `putc()`, or `getwc()` can result in [unexpected behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior) and [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO41-C </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>stream-argument-with-side-effects</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-FIO41</strong> </td> <td> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C5036</strong> <strong>C++3225, C++3229</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>35 D, 1 Q, 9 S,30 S, 134 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-FIO41-a</strong> <strong>CERT_C-FIO41-b</strong> <strong>CERT_C-FIO41-c</strong> <strong>CERT_C-FIO41-d</strong> <strong>CERT_C-FIO41-e</strong> </td> <td> The value of an expression shall be the same under any order of evaluation that the standard permits Don't write code that depends on the order of evaluation of function arguments Don't write code that depends on the order of evaluation of function designator and function arguments Don't write code that depends on the order of evaluation of expression that involves a function call A full expression containing an increment (++) or decrement (--) operator should have no other potential side effects </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule FIO41-C </a> </td> <td> Checks for stream arguments with possibly unintended side effects (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>5036</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3225, 3229 </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>stream-argument-with-side-effects</strong> </td> <td> Fully checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO41-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> FIO24-C. Do not open a file that is already open </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> EXP30-C. Do not depend on the order of evaluation for side effects </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [FIO41-C: Do not call getc(), putc(), getwc(), or putwc() with a stream argument that has side effects](https://wiki.sei.cmu.edu/confluence/display/c)
