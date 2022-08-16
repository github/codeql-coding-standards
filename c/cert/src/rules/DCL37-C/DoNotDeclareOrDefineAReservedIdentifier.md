# DCL37-C: Do not declare or define a reserved identifier

This query implements the CERT-C rule DCL37-C:

> Do not declare or define a reserved identifier


## Description

According to the C Standard, 7.1.3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\],

> All identifiers that begin with an underscore and either an uppercase letter or another underscore are always reserved for any use.


All identifiers that begin with an underscore are always reserved for use as identifiers with file scope in both the ordinary and tag name spaces.

Each macro name in any of the following subclauses (including the future library directions) is reserved for use as specified if any of its associated headers is included, unless explicitly stated otherwise.

All identifiers with external linkage (including future library directions) and `errno` are always reserved for use as identifiers with external linkage.

Each identifier with file scope listed in any of the following subclauses (including the future library directions) is reserved for use as a macro name and as an identifier with file scope in the same name space if any of its associated headers is included.

Additionally, subclause 7.31 defines many other reserved identifiers for future library directions.

No other identifiers are reserved. (The POSIX standard extends the set of identifiers reserved by the C Standard to include an open-ended set of its own. See *Portable Operating System Interface \[POSIX<sup>®</sup>\], Base Specifications, Issue 7*, [Section 2.2](http://www.opengroup.org/onlinepubs/9699919799/functions/V2_chap02.html#tag_15_02), "The Compilation Environment" \[[IEEE Std 1003.1-2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\].) The behavior of a program that declares or defines an identifier in a context in which it is reserved or that defines a reserved identifier as a macro name is undefined. (See [undefined behavior 106](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_106).)

## Noncompliant Code Example (Include Guard)

A common, but noncompliant, practice is to choose a reserved name for a macro used in a preprocessor conditional guarding against multiple inclusions of a header file. (See also [PRE06-C. Enclose header files in an include guard](https://wiki.sei.cmu.edu/confluence/display/c/PRE06-C.+Enclose+header+files+in+an+include+guard).) The name may clash with reserved names defined by the implementation of the C standard library in its headers or with reserved names implicitly predefined by the compiler even when no C standard library header is included.

```cpp
#ifndef _MY_HEADER_H_
#define _MY_HEADER_H_

/* Contents of <my_header.h> */

#endif /* _MY_HEADER_H_ */

```

## Compliant Solution (Include Guard)

This compliant solution avoids using leading underscores in the macro name of the include guard:

```cpp
#ifndef MY_HEADER_H
#define MY_HEADER_H

/* Contents of <my_header.h> */

#endif /* MY_HEADER_H */

```

## Noncompliant Code Example (File Scope Objects)

In this noncompliant code example, the names of the file scope objects `_max_limit` and `_limit` both begin with an underscore. Because `_max_limit` is static, this declaration might seem to be impervious to clashes with names defined by the implementation. However, because the header `<stddef.h>` is included to define `size_t`, a potential for a name clash exists. (Note, however, that a [conforming](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-conformingprogram) compiler may implicitly declare reserved names regardless of whether any C standard library header is explicitly included.)

In addition, because `_limit` has external linkage, it may clash with a symbol of the same name defined in the language runtime library even if such a symbol is not declared in any header. Consequently, it is not safe to start the name of any file scope identifier with an underscore even if its linkage limits its visibility to a single translation unit.

```cpp
#include <stddef.h>

static const size_t _max_limit = 1024;
size_t _limit = 100;

unsigned int getValue(unsigned int count) {
  return count < _limit ? count : _limit;
}

```

## Compliant Solution (File Scope Objects)

In this compliant solution, names of file scope objects do not begin with an underscore:

```cpp
#include <stddef.h>

static const size_t max_limit = 1024;
size_t limit = 100;

unsigned int getValue(unsigned int count) {
  return count < limit ? count : limit;
}

```

## Noncompliant Code Example (Reserved Macros)

In this noncompliant code example, because the C standard library header `<inttypes.h>` is specified to include `<stdint.h>`, the name `SIZE_MAX` conflicts with a standard macro of the same name, which is used to denote the upper limit of `size_t`. In addition, although the name `INTFAST16_LIMIT_MAX` is not defined by the C standard library, it is a reserved identifier because it begins with the `INT` prefix and ends with the `_MAX` suffix. (See the C Standard, 7.31.10.)

```cpp
#include <inttypes.h>
#include <stdio.h>

static const int_fast16_t INTFAST16_LIMIT_MAX = 12000;

void print_fast16(int_fast16_t val) {
  enum { SIZE_MAX = 80 };
  char buf[SIZE_MAX];
  if (INTFAST16_LIMIT_MAX < val) {
    sprintf(buf, "The value is too large");
  } else {
    snprintf(buf, SIZE_MAX, "The value is %" PRIdFAST16, val);
  }
}

```

## Compliant Solution (Reserved Macros)

This compliant solution avoids redefining reserved names or using reserved prefixes and suffixes:

```cpp
#include <inttypes.h>
#include <stdio.h>
 
static const int_fast16_t MY_INTFAST16_UPPER_LIMIT = 12000;

void print_fast16(int_fast16_t val) {
  enum { BUFSIZE = 80 };
  char buf[BUFSIZE];
  if (MY_INTFAST16_UPPER_LIMIT < val) {
    sprintf(buf, "The value is too large");
  } else {
    snprintf(buf, BUFSIZE, "The value is %" PRIdFAST16, val);
  }
}

```

## Noncompliant Code Example (Identifiers with External Linkage)

This noncompliant example provides definitions for the C standard library functions `malloc()` and `free()`. Although this practice is permitted by many traditional implementations of UNIX (for example, the [Dmalloc ](http://dmalloc.com/) library), it is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) according to the C Standard. Even on systems that allow replacing `malloc()`, doing so without also replacing `aligned_alloc()`, `calloc()`, and `realloc()` is likely to cause problems.

```cpp
#include <stddef.h>
 
void *malloc(size_t nbytes) {
  void *ptr;
  /* Allocate storage from own pool and set ptr */
  return ptr;
}

void free(void *ptr) {
  /* Return storage to own pool */
}

```

## Compliant Solution (Identifiers with External Linkage)

The compliant, portable solution avoids redefining any C standard library identifiers with external linkage. In addition, it provides definitions for all memory allocation functions:

```cpp
#include <stddef.h>

void *my_malloc(size_t nbytes) {
  void *ptr;
  /* Allocate storage from own pool and set ptr */
  return ptr;
}

void *my_aligned_alloc(size_t alignment, size_t size) {
  void *ptr;
  /* Allocate storage from own pool, align properly, set ptr */
  return ptr;
}

void *my_calloc(size_t nelems, size_t elsize) {
  void *ptr;
  /* Allocate storage from own pool, zero memory, and set ptr */
  return ptr;
}

void *my_realloc(void *ptr, size_t nbytes) {
  /* Reallocate storage from own pool and set ptr */
  return ptr;
}

void my_free(void *ptr) {
  /* Return storage to own pool */
}

```

## Noncompliant Code Example (errno)

In addition to symbols defined as functions in each C standard library header, identifiers with external linkage include `errno` and `math_errhandling`. According to the C Standard, 7.5, paragraph 2 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], the behavior of a program is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) when

> A macro definition of `errno` is suppressed in order to access an actual object, or the program defines an identifier with the name `errno`.


See [undefined behavior 114](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_114).

The `errno` identifier expands to a modifiable [lvalue](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-lvalue) that has type `int` but is not necessarily the identifier of an object. It might expand to a modifiable lvalue resulting from a function call, such as `*errno()`. It is unspecified whether `errno` is a macro or an identifier declared with external linkage. If a macro definition is suppressed to access an actual object, or if a program defines an identifier with the name `errno`, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

Legacy code is apt to include an incorrect declaration, such as the following:

```cpp
extern int errno;

```

## Compliant Solution (errno)

The correct way to declare `errno` is to include the header `<errno.h>`:

```cpp
#include <errno.h>

```
[Implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) [conforming](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-conformingprogram) to C are required to declare `errno` in `<errno.h>`, although some historic implementations failed to do so.

## Exceptions

**DCL37-C-EX1:** Provided that a library function can be declared without reference to any type defined in a header, it is permissible to declare that function without including its header provided that declaration is compatible with the standard declaration.

```cpp
/* Not including stdlib.h */
void free(void *);
 
void func(void *ptr) {
  free(ptr);
}
```
Such code is compliant because the declaration matches what `stdlib.h` would provide and does not redefine the reserved identifier. However, it would not be acceptable to provide a definition for the `free()` function in this example.

**DCL37-C-EX2:** For compatibility with other compiler vendors or language standard modes, it is acceptable to create a macro identifier that is the same as a reserved identifier so long as the behavior is idempotent, as in this example:

```cpp
/* Sometimes generated by configuration tools such as autoconf */
#define const const
 
/* Allowed compilers with semantically equivalent extension behavior */
#define inline __inline
```
**DCL37-C-EX3:** As a compiler vendor or standard library developer, it is acceptable to use identifiers reserved for your implementation. Reserved identifiers may be defined by the compiler, in standard library headers or headers included by a standard library header, as in this example declaration from the glibc standard C library implementation:

```cpp
/*
  The following declarations of reserved identifiers exist in the glibc implementation of
  <stdio.h>. The original source code may be found at:
  https://sourceware.org/git/?p=glibc.git;a=blob_plain;f=include/stdio.h;hb=HEAD
*/
 
#  define __need_size_t
#  include <stddef.h>
/* Generate a unique file name (and possibly open it).  */
extern int __path_search (char *__tmpl, size_t __tmpl_len,
			  const char *__dir, const char *__pfx,
			  int __try_tempdir);
```

## Risk Assessment

Using reserved identifiers can lead to incorrect program operation.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL37-C </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>future-library-use</strong> <strong>language-override</strong> <strong>language-override-c99</strong> <strong>reserved-declaration</strong> <strong>reserved-declaration-c99</strong> <strong>reserved-identifier</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-DCL37</strong> </td> <td> Fully implemented. Reserved identifiers, as in <strong>DCL37-C-EX3</strong> , are configurable. </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.DECL.RESERVED</strong> </td> <td> Declaration of reserved name </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2004 Rule 20.1</strong> <strong><strong>MISRA C 2004 Rule 20.2</strong></strong> <strong><strong><strong>MISRA C 2012 Rule 21.1</strong></strong></strong> <strong><strong><strong><strong>MISRA C 2012 Rule 21.2</strong></strong></strong></strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.DCL37</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C0602, C0603, C4600, C4601, C4602, C4603, C4604, C4605, C4606, C4607, C4608, C4620, C4621, C4622, C4623, C4624, C4640, C4641, C4642, C4643, C4644, C4645</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.DEFINE.WRONGNAME.UNDERSCORE</strong> <strong>MISRA.STDLIB.WRONGNAME.UNDERSCORE</strong> <strong>MISRA.STDLIB.WRONGNAME</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>86 S, 218 S, 219 S, 580 S, 626 S</strong> </td> <td> Fully Implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-DCL37-a</strong> </td> <td> Do not \#define or \#undef identifiers with names which start with underscore </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>978, 9071, 9093</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule DCL37-C </a> </td> <td> Checks for: Defining and undefining reserved identifiers or macrosefining and undefining reserved identifiers or macros, declaring a reserved identifier or macro nameeclaring a reserved identifier or macro name. Rule partially covered </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0602, 0603, 4600, 4601, 4602, </strong> <strong>4603, 4604, 4605, 4606, 4607, </strong> <strong>4608, 4620, 4621, 4622, 4623,</strong> <strong>4624, 4640, 4641, 4642, 4643, </strong> <strong>4644, 4645</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V677</a></strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S978</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>future-library-use</strong> <strong>language-override</strong> <strong>language-override-c99</strong> <strong>reserved-declaration</strong> <strong>reserved-declaration-c99</strong> <strong>reserved-identifier</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> PRE00-C. Prefer inline or static functions to function-like macros </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> PRE06-C. Enclose header files in an include guard </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> PRE31-C. Avoid side effects in arguments to unsafe macros </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> DCL51-CPP. Do not declare or define a reserved identifier </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Using identifiers that are reserved for the implementation \[resident\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 21.1 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 21.2 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE Std 1003.1-2013 </a> \] </td> <td> Section 2.2, "The Compilation Environment" </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.1.3, "Reserved Identifiers" 7.31.10, "Integer Types <code>&lt;stdint.h&gt;</code> " </td> </tr> </tbody> </table>


## Implementation notes

This query does not consider identifiers described in the future library directions section of the standard. This query also checks for any reserved identifier as declared regardless of whether its header file is included or not.

## References

* CERT-C: [DCL37-C: Do not declare or define a reserved identifier](https://wiki.sei.cmu.edu/confluence/display/c)
