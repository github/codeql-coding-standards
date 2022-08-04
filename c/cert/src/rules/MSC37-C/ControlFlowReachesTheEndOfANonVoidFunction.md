# MSC37-C: Ensure that control never reaches the end of a non-void function

This query implements the CERT-C rule MSC37-C:

> Ensure that control never reaches the end of a non-void function


## Description

If control reaches the closing curly brace (`}`) of a non-`void` function without evaluating a `return` statement, using the return value of the function call is [undefined behavior. ](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior)(See [undefined behavior 88](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_88).)

## Noncompliant Code Example

In this noncompliant code example, control reaches the end of the `checkpass()` function when the two strings passed to `strcmp()` are not equal, resulting in undefined behavior. Many compilers will generate code for the `checkpass()` function, returning various values along the execution path where no `return` statement is defined.

```cpp
#include <string.h>
#include <stdio.h>
 
int checkpass(const char *password) {
  if (strcmp(password, "pass") == 0) {
    return 1;
  }
}

void func(const char *userinput) {
  if (checkpass(userinput)) {
    printf("Success\n");
  }
}
```
This error is frequently diagnosed by compilers. (See [MSC00-C. Compile cleanly at high warning levels](https://wiki.sei.cmu.edu/confluence/display/c/MSC00-C.+Compile+cleanly+at+high+warning+levels).)

## Compliant Solution

This compliant solution ensures that the `checkpass()` function always returns a value:

```cpp
#include <string.h>
#include <stdio.h>
 
int checkpass(const char *password) {
  if (strcmp(password, "pass") == 0) {
    return 1;
  }
  return 0;
}

void func(const char *userinput) {
  if (checkpass(userinput)) {
    printf("Success!\n");
  }
}
```

## Noncompliant Code Example

In this noncompliant code example, control reaches the end of the `getlen()` function when `input` does not contain the integer `delim`. Because the potentially undefined return value of `getlen()` is later used as an index into an array, a buffer overflow may occur.

```cpp
#include <stddef.h>
 
size_t getlen(const int *input, size_t maxlen, int delim) {
  for (size_t i = 0; i < maxlen; ++i) {
    if (input[i] == delim) {
      return i;
    }
  }
}
 
void func(int userdata) {
  size_t i;
  int data[] = { 1, 1, 1 };
  i = getlen(data, sizeof(data), 0);
  data[i] = userdata;
}
```
**Implementation Details (GCC)**

Violating this rule can have unexpected consequences, as in the following example:

```cpp
#include <stdio.h>

size_t getlen(const int *input, size_t maxlen, int delim) {
  for (size_t i = 0; i < maxlen; ++i) {
    if (input[i] == delim) {
      return i;
    }
  }
}

int main(int argc, char **argv) {
  size_t i;
  int data[] = { 1, 1, 1 };

  i = getlen(data, sizeof(data), 0);
  printf("Returned: %zu\n", i);
  data[i] = 0;

  return 0;
}
```
When this program is compiled with `-Wall` on most versions of the GCC compiler, the following warning is generated:

```cpp
example.c: In function 'getlen':
example.c:12: warning: control reaches end of non-void function

```
None of the inputs to the function equal the delimiter, so when run with GCC 5.3 on Linux, control reaches the end of the `getlen()` function, which is undefined behavior and in this test returns `3`, causing an out-of-bounds write to the `data` array.

## Compliant Solution

This compliant solution changes the interface of `getlen()` to store the result in a user-provided pointer and returns a status indicator to report success or failure. The best method for handling this type of error is specific to the application and the type of error. (See [ERR00-C. Adopt and implement a consistent and comprehensive error-handling policy](https://wiki.sei.cmu.edu/confluence/display/c/ERR00-C.+Adopt+and+implement+a+consistent+and+comprehensive+error-handling+policy) for more on error handling.)

```cpp
#include <stddef.h>
 
int getlen(const int *input, size_t maxlen, int delim,
           size_t *result) {
  if (result == NULL) {
    return -1;
  }
  for (size_t i = 0; i < maxlen; ++i) {
    if (input[i] == delim) {
      *result = i;
      return 0;
    }
  }
  return -1;
}

void func(int userdata) {
  size_t i;
  int data[] = {1, 1, 1};
  if (getlen(data, sizeof(data), 0, &i) != 0) {
    /* Handle error */
  } else {
    data[i] = userdata;
  }
}

```

## Exceptions

**MSC37-C-EX1:** According to the C Standard, 5.1.2.2.3, paragraph 1 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], "Reaching the `}` that terminates the main function returns a value of 0." As a result, it is permissible for control to reach the end of the `main()` function without executing a return statement.

**MSC37-C-EX2:**It is permissible for a control path to not return a value if that code path is never taken and a function marked `_Noreturn` is called as part of that code path. For example:

```cpp
#include <stdio.h>
#include <stdlib.h>
 
_Noreturn void unreachable(const char *msg) {
  printf("Unreachable code reached: %s\n", msg);
  exit(1);
}

enum E {
  One,
  Two,
  Three
};
 
int f(enum E e) {
  switch (e) {
  case One: return 1;
  case Two: return 2;
  case Three: return 3;
  }
  unreachable("Can never get here");
}
```

## Risk Assessment

Using the return value from a non-`void` function where control reaches the end of the function without evaluating a `return` statement can lead to buffer overflow [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) as well as other [unexpected program behaviors](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MSC37-C </td> <td> High </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MSC37-C).

## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>return-implicit</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-MSC37</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.MRS</strong> </td> <td> Missing return statement </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISSING_RETURN</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C2888</strong> <strong>C++2888, C++4022</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>FUNCRET.GEN</strong> <strong>FUNCRET.IMPLICIT</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>2 D, 36 S, 66 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-MSC37-a</strong> </td> <td> All exit paths from a function, except main(), with non-void return type shall have an explicit return statement with an expression </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>533</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule MSC37-C </a> </td> <td> Checks for missing return statement (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2888</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2888, 4022 </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>return-implicit</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S935</a></strong> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>Body of function falls-through</strong> </td> <td> Exhaustively verified. </td> </tr> </tbody> </table>


## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MSC01-C. Strive for logical completeness </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-758 </a> </td> <td> 2017-07-07: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-758 and MSC37-C**

Independent( INT34-C, INT36-C, MEM30-C, MSC37-C, FLP32-C, EXP33-C, EXP30-C, ERR34-C, ARR32-C)

CWE-758 = Union( MSC37-C, list) where list =

Undefined behavior that results from anything other than failing to return a value from a function that expects one

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 5.1.2.2.3, "Program Termination" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [MSC37-C: Ensure that control never reaches the end of a non-void function](https://wiki.sei.cmu.edu/confluence/display/c)
