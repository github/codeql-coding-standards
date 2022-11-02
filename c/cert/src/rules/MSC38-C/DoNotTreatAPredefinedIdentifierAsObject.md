# MSC38-C: Do not treat a predefined identifier as an object if it might only be implemented as a macro

This query implements the CERT-C rule MSC38-C:

> Do not treat a predefined identifier as an object if it might only be implemented as a macro


## Description

The C Standard, 7.1.4 paragraph 1, \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\] states

> Any function declared in a header may be additionally implemented as a function-like macro defined in the header, so if a library function is declared explicitly when its header is included, one of the techniques shown below can be used to ensure the declaration is not affected by such a macro. Any macro definition of a function can be suppressed locally by enclosing the name of the function in parentheses, because the name is then not followed by the left parenthesis that indicates expansion of a macro function name. For the same syntactic reason, it is permitted to take the address of a library function even if it is also defined as a macro.<sup>185</sup>


185. This means that an implementation shall provide an actual function for each library function, even if it also provides a macro for that function.

However, the C Standard enumerates specific exceptions in which the behavior of accessing an object or function expanded to be a standard library macro definition is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). The macros are `assert`, `errno`, `math_errhandling`, `setjmp`, `va_arg`, `va_copy`, `va_end`, and `va_start`. These cases are described by [undefined behaviors](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) [110](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_110), [114](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_114), [122](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_122), [124](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_124), and [138](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_138). Programmers must not suppress these macros to access the underlying object or function.

## Noncompliant Code Example (assert)

In this noncompliant code example, the standard `assert()` macro is suppressed in an attempt to pass it as a function pointer to the `execute_handler()` function. Attempting to suppress the `assert()` macro is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <assert.h>
 
typedef void (*handler_type)(int);
 
void execute_handler(handler_type handler, int value) {
  handler(value);
}
 
void func(int e) {
  execute_handler(&(assert), e < 0);
} 
```

## Compliant Solution (assert)

In this compliant solution, the `assert()` macro is wrapped in a helper function, removing the [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior):

```cpp
#include <assert.h>
 
typedef void (*handler_type)(int);
 
void execute_handler(handler_type handler, int value) {
  handler(value);
}
 
static void assert_handler(int value) {
  assert(value);
}
 
void func(int e) {
  execute_handler(&assert_handler, e < 0);
}
```

## Noncompliant Code Example (Redefining errno)

Legacy code is apt to include an incorrect declaration, such as the following in this noncompliant code example:

```cpp
extern int errno;

```

## Compliant Solution (Declaring errno)

This compliant solution demonstrates the correct way to declare `errno` by including the header `<errno.h>`:

```cpp
#include <errno.h>

```
[C-conforming](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-conformingprogram) [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) are required to declare `errno` in `<errno.h>`, although some historic implementations failed to do so.

## Risk Assessment

Accessing objects or functions underlying the specific macros enumerated in this rule is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MSC38-C </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADMACRO.STDARG_H</strong> </td> <td> Use of &lt;stdarg.h&gt; Feature </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C3437, C3475</strong> <strong>C++3127, C++5039</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-MSC38-a</strong> </td> <td> A function-like macro shall not be invoked without all of its arguments </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule MSC38-C </a> </td> <td> Checks for predefined macro used as an object (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>3437, 3475</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MSC38-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> DCL37-C. Do not declare or define a reserved identifier </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> <a> ISO/IEC 9899:2011 </a> </td> <td> 7.1.4, "Use of Library Functions" </td> </tr> </tbody> </table>


## Implementation notes

This query reports locations corresponding to both redefinitions of those standard library macros as well as locations where the identifiers used for accesses.

## References

* CERT-C: [MSC38-C: Do not treat a predefined identifier as an object if it might only be implemented as a macro](https://wiki.sei.cmu.edu/confluence/display/c)
