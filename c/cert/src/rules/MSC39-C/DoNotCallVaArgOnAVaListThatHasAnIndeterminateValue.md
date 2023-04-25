# MSC39-C: Do not call va_arg() on a va_list that has an indeterminate value

This query implements the CERT-C rule MSC39-C:

> Do not call va_arg() on a va_list that has an indeterminate value


## Description

Variadic functions access their variable arguments by using `va_start()` to initialize an object of type `va_list`, iteratively invoking the `va_arg()` macro, and finally calling `va_end()`. The `va_list` may be passed as an argument to another function, but calling `va_arg()` within that function causes the `va_list` to have an [indeterminate value](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue) in the calling function. As a result, attempting to read variable arguments without reinitializing the `va_list` can have [unexpected behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior). According to the C Standard, 7.16, paragraph 3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\],

> If access to the varying arguments is desired, the called function shall declare an object (generally referred to as `ap` in this subclause) having type `va_list`. The object `ap` may be passed as an argument to another function; if that function invokes the `va_arg` macro with parameter `ap`, the value of `ap` in the calling function is indeterminate and shall be passed to the `va_end` macro prior to any further reference to `ap`.<sup>253</sup>253) It is permitted to create a pointer to a `va_list` and pass that pointer to another function, in which case the original function may take further use of the original list after the other function returns.


## Noncompliant Code Example

This noncompliant code example attempts to check that none of its variable arguments are zero by passing a `va_list` to helper function `contains_zero()`. After the call to `contains_zero()`, the value of `ap` is [indeterminate](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue).

```cpp
#include <stdarg.h>
#include <stdio.h>
 
int contains_zero(size_t count, va_list ap) {
  for (size_t i = 1; i < count; ++i) {
    if (va_arg(ap, double) == 0.0) {
      return 1;
    }
  }
  return 0;
}

int print_reciprocals(size_t count, ...) {
  va_list ap;  
  va_start(ap, count);

  if (contains_zero(count, ap)) {
    va_end(ap);
    return 1;
  }

  for (size_t i = 0; i < count; ++i) {
    printf("%f ", 1.0 / va_arg(ap, double));
  }

  va_end(ap);
  return 0;
}

```

## Compliant Solution

The compliant solution modifies `contains_zero()` to take a pointer to a `va_list`. It then uses the `va_copy` macro to make a copy of the list, traverses the copy, and cleans it up. Consequently, the `print_reciprocals()` function is free to traverse the original `va_list`.

```cpp
#include <stdarg.h>
#include <stdio.h>
 
int contains_zero(size_t count, va_list *ap) {
  va_list ap1;
  va_copy(ap1, *ap);
  for (size_t i = 1; i < count; ++i) {
    if (va_arg(ap1, double) == 0.0) {
      return 1;
    }
  }
  va_end(ap1);
  return 0;
}
 
int print_reciprocals(size_t count, ...) {
  int status;
  va_list ap;
  va_start(ap, count);
 
  if (contains_zero(count, &ap)) {
    printf("0 in arguments!\n");
    status = 1;
  } else {
    for (size_t i = 0; i < count; i++) {
      printf("%f ", 1.0 / va_arg(ap, double));
    }
    printf("\n");
    status = 0;
  }
 
  va_end(ap);
  return status;
}

```

## Risk Assessment

Reading variable arguments using a `va_list` that has an [indeterminate value](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue) can have unexpected results.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MSC39-C </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>BADMACRO.STDARG_H</strong> </td> <td> Use of &lt;stdarg.h&gt; Feature </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C3497</strong> <strong>C++3146, C++3147, C++3148, C++3149, C++3167</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>VA.LIST.INDETERMINATE</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-MSC39-a</strong> </td> <td> Use macros for variable arguments correctly </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule MSC39-C </a> </td> <td> Checks for: Invalid va_list argumentnvalid va_list argument, too many va_arg calls for current argument listoo many va_arg calls for current argument list. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>3497</strong> </td> <td> Enforced by QAC </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>variadic</strong> </td> <td> Exhaustively verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MSC39-C).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.16, "Variable Arguments <code>&lt;stdarg.h&gt;</code> " </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [MSC39-C: Do not call va_arg() on a va_list that has an indeterminate value](https://wiki.sei.cmu.edu/confluence/display/c)
