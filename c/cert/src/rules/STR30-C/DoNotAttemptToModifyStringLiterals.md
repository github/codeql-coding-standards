# STR30-C: Do not attempt to modify string literals

This query implements the CERT-C rule STR30-C:

> Do not attempt to modify string literals


## Description

According to the C Standard, 6.4.5, paragraph 3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\]:

> A *character string literal* is a sequence of zero or more multibyte characters enclosed in double-quotes, as in `"xyz"`. A UTF−8 string literal is the same, except prefixed by `u8`. A wide string literal is the same, except prefixed by the letter `L`, `u`, or `U`.


At compile time, string literals are used to create an array of static storage duration of sufficient length to contain the character sequence and a terminating null character. String literals are usually referred to by a pointer to (or array of) characters. Ideally, they should be assigned only to pointers to (or arrays of) `const char` or `const wchar_t`. It is unspecified whether these arrays of string literals are distinct from each other. The behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) if a program attempts to modify any portion of a string literal. Modifying a string literal frequently results in an access violation because string literals are typically stored in read-only memory. (See [undefined behavior 33](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_33).)

Avoid assigning a string literal to a pointer to non-`const` or casting a string literal to a pointer to non-`const`. For the purposes of this rule, a pointer to (or array of) `const` characters must be treated as a string literal. Similarly, the returned value of the following library functions must be treated as a string literal if the first argument is a string literal:

* `strpbrk(), strchr(), strrchr(), strstr()`
* `wcspbrk(), wcschr(), wcsrchr(), wcsstr()`
* `memchr(), wmemchr()`
This rule is a specific instance of [EXP40-C. Do not modify constant objects](https://wiki.sei.cmu.edu/confluence/display/c/EXP40-C.+Do+not+modify+constant+objects).

## Noncompliant Code Example

In this noncompliant code example, the `char` pointer `str` is initialized to the address of a string literal. Attempting to modify the string literal is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior):

```cpp
char *str  = "string literal";
str[0] = 'S';

```

## Compliant Solution

As an array initializer, a string literal specifies the initial values of characters in an array as well as the size of the array. (See [STR11-C. Do not specify the bound of a character array initialized with a string literal](https://wiki.sei.cmu.edu/confluence/display/c/STR11-C.+Do+not+specify+the+bound+of+a+character+array+initialized+with+a+string+literal).) This code creates a copy of the string literal in the space allocated to the character array `str`. The string stored in `str` can be modified safely.

```cpp
char str[] = "string literal";
str[0] = 'S';

```

## Noncompliant Code Example (POSIX)

In this noncompliant code example, a string literal is passed to the (pointer to non-`const`) parameter of the POSIX function `[mkstemp()](http://pubs.opengroup.org/onlinepubs/9699919799/functions/mkstemp.html)`, which then modifies the characters of the string literal:

```cpp
#include <stdlib.h>
 
void func(void) {
  mkstemp("/tmp/edXXXXXX");
}
```
The behavior of `mkstemp()` is described in more detail in [FIO21-C. Do not create temporary files in shared directories](https://wiki.sei.cmu.edu/confluence/display/c/FIO21-C.+Do+not+create+temporary+files+in+shared+directories).

## Compliant Solution (POSIX)

This compliant solution uses a named array instead of passing a string literal:

```cpp
#include <stdlib.h>
 
void func(void) {
  static char fname[] = "/tmp/edXXXXXX";
  mkstemp(fname);
}
```

## Noncompliant Code Example (Result of strrchr())

In this noncompliant example, the `char *` result of the `strrchr()` function is used to modify the object pointed to by `pathname`. Because the argument to `strrchr()` points to a string literal, the effects of the modification are undefined.

```cpp
#include <stdio.h>
#include <string.h>
 
const char *get_dirname(const char *pathname) {
  char *slash;
  slash = strrchr(pathname, '/');
  if (slash) {
    *slash = '\0'; /* Undefined behavior */
  }
  return pathname;
}

int main(void) {
  puts(get_dirname(__FILE__));
  return 0;
}

```

## Compliant Solution (Result of strrchr())

This compliant solution avoids modifying a `const` object, even if it is possible to obtain a non-`const` pointer to such an object by calling a standard C library function, such as `strrchr()`. To reduce the risk to callers of `get_dirname()`, a buffer and length for the directory name are passed into the function. It is insufficient to change `pathname` to require a `char *` instead of a `const char *` because conforming compilers are not required to diagnose passing a string literal to a function accepting a `char *`.

```cpp
#include <stddef.h>
#include <stdio.h>
#include <string.h>
 
char *get_dirname(const char *pathname, char *dirname, size_t size) {
  const char *slash;
  slash = strrchr(pathname, '/');
  if (slash) {
    ptrdiff_t slash_idx = slash - pathname;
    if ((size_t)slash_idx < size) {
      memcpy(dirname, pathname, slash_idx);
      dirname[slash_idx] = '\0';      
      return dirname;
    }
  }
  return 0;
}
 
int main(void) {
  char dirname[260];
  if (get_dirname(__FILE__, dirname, sizeof(dirname))) {
    puts(dirname);
  }
  return 0;
}
```

## Risk Assessment

Modifying string literals can lead to [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination) and possibly [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-denial-of-service).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR30-C </td> <td> Low </td> <td> Likely </td> <td> Low </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>string-literal-modfication</strong> <strong>write-to-string-literal</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-STR30</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect simple violations of this rule </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>PW</strong> </td> <td> Deprecates conversion from a string literal to "char \*" </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C0556, C0752, C0753, C0754</strong> <strong>C++3063, C++3064, C++3605, C++3606, C++3607</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.STR.ARG.CONST_TO_NONCONST</strong> <strong>CERT.STR.ASSIGN.CONST_TO_NONCONST</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>157 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-STR30-a</strong> <strong>CERT_C-STR30-b</strong> </td> <td> A string literal shall not be modified Do not modify string literals </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>489, 1776</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule STR30-C </a> </td> <td> Checks for writing to const qualified object (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0556, </strong> <strong>0752, </strong> <strong>0753, 0754</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3063, 3064, 3605, 3606, 3607, 3842 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V675</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>string-literal-modfication</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> mem_access </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnurability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+STR30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> EXP05-C. Do not cast away a const qualification </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> STR11-C. Do not specify the bound of a character array initialized with a string literal </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Modifying string literals \[strmod\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.4.5, "String Literals" </td> </tr> <tr> <td> \[ <a> Plum 1991 </a> \] </td> <td> Topic 1.26, "Strings—String Literals" </td> </tr> <tr> <td> \[ <a> Summit 1995 </a> \] </td> <td> comp.lang.c FAQ List, Question 1.32 </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [STR30-C: Do not attempt to modify string literals](https://wiki.sei.cmu.edu/confluence/display/c)
