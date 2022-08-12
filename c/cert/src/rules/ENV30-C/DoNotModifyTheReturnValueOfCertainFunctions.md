# ENV30-C: Do not modify the return value of certain functions

This query implements the CERT-C rule ENV30-C:

> Do not modify the object referenced by the return value of certain functions


## Description

Some functions return a pointer to an object that cannot be modified without causing [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). These functions include `getenv()`, `setlocale()`, `localeconv()`, `asctime()`, and `strerror()`. In such cases, the function call results must be treated as being `const`-qualified.

The C Standard, 7.22.4.6, paragraph 4 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], defines `getenv()` as follows:

> The `getenv` function returns a pointer to a string associated with the matched list member. The string pointed to shall not be modified by the program, but may be overwritten by a subsequent call to the `getenv` function. If the specified name cannot be found, a null pointer is returned.


If the string returned by `getenv()` must be altered, a local copy should be created. Altering the string returned by `getenv()` is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 184](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_184).)

Similarly, subclause 7.11.1.1, paragraph 8 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], defines `setlocale()` as follows:

> The pointer to string returned by the `setlocale` function is such that a subsequent call with that string value and its associated category will restore that part of the program's locale. The string pointed to shall not be modified by the program, but may be overwritten by a subsequent call to the `setlocale` function.


And subclause 7.11.2.1, paragraph 8 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], defines `localeconv()` as follows:

> The `localeconv` function returns a pointer to the filled-in object. The structure pointed to by the return value shall not be modified by the program, but may be overwritten by a subsequent call to the `localeconv` function. In addition, calls to the `setlocale` function with categories `LC_ALL`, `LC_MONETARY`, or `LC_NUMERIC` may overwrite the contents of the structure.


Altering the string returned by `setlocale()` or the structure returned by `localeconv()` are [undefined behaviors](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behaviors 120](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_120) and [121](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_121).) Furthermore, the C Standard imposes no requirements on the contents of the string by `setlocale()`. Consequently, no assumptions can be made as to the string's internal contents or structure.

Finally, subclause 7.24.6.2, paragraph 4 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> The `strerror` function returns a pointer to the string, the contents of which are locale-specific. The array pointed to shall not be modified by the program, but may be overwritten by a subsequent call to the `strerror` function.


Altering the string returned by `strerror()` is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 184](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_184).)

## Noncompliant Code Example (getenv())

This noncompliant code example modifies the string returned by `getenv()` by replacing all double quotation marks (`"`) with underscores (`_`):

```cpp
#include <stdlib.h>
 
void trstr(char *c_str, char orig, char rep) {
  while (*c_str != '\0') {
    if (*c_str == orig) {
      *c_str = rep;
    }
    ++c_str;
  }
}

void func(void) {
  char *env = getenv("TEST_ENV");
  if (env == NULL) {
    /* Handle error */
  }
  trstr(env,'"', '_');
}

```

## Compliant Solution (getenv()) (Environment Not Modified)

If the programmer does not intend to modify the environment, this compliant solution demonstrates how to modify a copy of the return value:

```cpp
#include <stdlib.h>
#include <string.h>
 
void trstr(char *c_str, char orig, char rep) {
  while (*c_str != '\0') {
    if (*c_str == orig) {
      *c_str = rep;
    }
    ++c_str;
  }
}
 
void func(void) {
  const char *env;
  char *copy_of_env;

  env = getenv("TEST_ENV");
  if (env == NULL) {
    /* Handle error */
  }

  copy_of_env = (char *)malloc(strlen(env) + 1);
  if (copy_of_env == NULL) {
    /* Handle error */
  }

  strcpy(copy_of_env, env);
  trstr(copy_of_env,'"', '_');
  /* ... */
  free(copy_of_env);
}
```

## Compliant Solution (getenv()) (Modifying the Environment in POSIX)

If the programmer's intent is to modify the environment, this compliant solution, which saves the altered string back into the environment by using the POSIX `setenv()` and `strdup()` functions, can be used:

```cpp
#include <stdlib.h>
#include <string.h>
 
void trstr(char *c_str, char orig, char rep) {
  while (*c_str != '\0') {
    if (*c_str == orig) {
      *c_str = rep;
    }
    ++c_str;
  }
}
 
void func(void) {
  const char *env;
  char *copy_of_env;

  env = getenv("TEST_ENV");
  if (env == NULL) {
    /* Handle error */
  }

  copy_of_env = strdup(env);
  if (copy_of_env == NULL) {
    /* Handle error */
  }

  trstr(copy_of_env,'"', '_');

  if (setenv("TEST_ENV", copy_of_env, 1) != 0) {
    /* Handle error */
  }
  /* ... */
  free(copy_of_env);
}
```

## Noncompliant Code Example (localeconv())

In this noncompliant example, the object returned by `localeconv()` is directly modified:

```cpp
#include <locale.h>
 
void f2(void) {
  struct lconv *conv = localeconv();
 
  if ('\0' == conv->decimal_point[0]) {
    conv->decimal_point = ".";
  }
}

```

## Compliant Solution (localeconv()) (Copy)

This compliant solution modifies a copy of the object returned by `localeconv()`:

```cpp
#include <locale.h>
#include <stdlib.h>
#include <string.h>
 
void f2(void) {
  const struct lconv *conv = localeconv();
  if (conv == NULL) {
     /* Handle error */
  }
  
  struct lconv *copy_of_conv = (struct lconv *)malloc(
    sizeof(struct lconv));
  if (copy_of_conv == NULL) {
    /* Handle error */
  }
 
  memcpy(copy_of_conv, conv, sizeof(struct lconv));
 
  if ('\0' == copy_of_conv->decimal_point[0]) {
    copy_of_conv->decimal_point = ".";  
  }
  /* ... */
  free(copy_of_conv);
}
```

## Risk Assessment

Modifying the object pointed to by the return value of `getenv()`, `setlocale()`, `localeconv()`, `asctime()`, or `strerror()` is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). Even if the modification succeeds, the modified object can be overwritten by a subsequent call to the same function.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ENV30-C </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>stdlib-const-pointer-assign</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-ENV30</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.GETENV</strong> </td> <td> Use of getenv </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule. In particular, it ensures that the result of <code>getenv()</code> is stored in a <code>const</code> variable </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C1492, C1493, C1494, C4751, C4752, C4753</strong> <strong>C++4751, C++4752, C++4753</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.STDLIB.CTYPE.RANGE.2012_AMD1</strong> <strong>MISRA.STDLIB.ILLEGAL_REUSE.2012_AMD1</strong> <strong>MISRA.STDLIB.ILLEGAL_WRITE.2012_AMD1</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>107 D</strong> </td> <td> Partially Implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-ENV30-a</strong> </td> <td> The pointers returned by the Standard Library functions 'localeconv', 'getenv', 'setlocale' or, 'strerror' shall only be used as if they have pointer to const-qualified type </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule ENV30-C </a> </td> <td> Checks for modification of internal buffer returned from nonreentrant standard function (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>1492, 1493, 1494 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.20 </td> <td> <strong><a>V675</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>stdlib-const-pointer-assign</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ENV30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Modifying the string returned by <code>getenv</code> , <code>localeconv</code> , <code>setlocale</code> , and <code>strerror</code> \[libmod\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE Std 1003.1:2013 </a> \] </td> <td> XSH, System Interfaces, <code>getenv</code> XSH, System Interfaces, <code>setlocale</code> XSH, System Interfaces, <code>localeconv</code> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.11.1.1, "The <code>setlocale</code> Function" 7.11.2.1, "The <code>localeconv</code> Function" 7.22.4.6, "The <code>getenv</code> Function" 7.24.6.2, "The <code>strerror</code> Function" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ENV30-C: Do not modify the object referenced by the return value of certain functions](https://wiki.sei.cmu.edu/confluence/display/c)
