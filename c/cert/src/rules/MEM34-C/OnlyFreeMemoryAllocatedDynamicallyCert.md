# MEM34-C: Only free memory allocated dynamically

This query implements the CERT-C rule MEM34-C:

> Only free memory allocated dynamically


## Description

The C Standard, Annex J \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states that the behavior of a program is [undefined ](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) when

> The pointer argument to the `free` or `realloc` function does not match a pointer earlier returned by a memory management function, or the space has been deallocated by a call to `free` or `realloc`.


See also [undefined behavior 179](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_179).

Freeing memory that is not allocated dynamically can result in heap corruption and other serious errors. Do not call `free()` on a pointer other than one returned by a standard memory allocation function, such as `malloc()`, `calloc()`, `realloc()`, or `aligned_alloc()`.

A similar situation arises when `realloc()` is supplied a pointer to non-dynamically allocated memory. The `realloc()` function is used to resize a block of dynamic memory. If `realloc()` is supplied a pointer to memory not allocated by a standard memory allocation function, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). One consequence is that the program may [terminate abnormally](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination).

This rule does not apply to null pointers. The C Standard guarantees that if `free()` is passed a null pointer, no action occurs.

## Noncompliant Code Example

This noncompliant code example sets `c_str` to reference either dynamically allocated memory or a statically allocated string literal depending on the value of `argc`. In either case, `c_str` is passed as an argument to `free()`. If anything other than dynamically allocated memory is referenced by `c_str`, the call to `free(c_str)` is erroneous.

```cpp
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
 
enum { MAX_ALLOCATION = 1000 };

int main(int argc, const char *argv[]) {
  char *c_str = NULL;
  size_t len;

  if (argc == 2) {
    len = strlen(argv[1]) + 1;
    if (len > MAX_ALLOCATION) {
      /* Handle error */
    }
    c_str = (char *)malloc(len);
    if (c_str == NULL) {
      /* Handle error */
    }
    strcpy(c_str, argv[1]);
  } else {
    c_str = "usage: $>a.exe [string]";
    printf("%s\n", c_str);
  }
  free(c_str);
  return 0;
}

```

## Compliant Solution

This compliant solution eliminates the possibility of `c_str` referencing memory that is not allocated dynamically when passed to `free()`:

```cpp
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
 
enum { MAX_ALLOCATION = 1000 };

int main(int argc, const char *argv[]) {
  char *c_str = NULL;
  size_t len;

  if (argc == 2) {
    len = strlen(argv[1]) + 1;
    if (len > MAX_ALLOCATION) {
      /* Handle error */
    }
    c_str = (char *)malloc(len);
    if (c_str == NULL) {
      /* Handle error */
    }
    strcpy(c_str, argv[1]);
  } else {
    printf("%s\n", "usage: $>a.exe [string]");
    return EXIT_FAILURE;
  }
  free(c_str);
  return 0;
}

```

## Noncompliant Code Example (realloc())

In this noncompliant example, the pointer parameter to `realloc()`, `buf`, does not refer to dynamically allocated memory:

```cpp
#include <stdlib.h>
 
enum { BUFSIZE = 256 };
 
void f(void) {
  char buf[BUFSIZE];
  char *p = (char *)realloc(buf, 2 * BUFSIZE);
  if (p == NULL) {
    /* Handle error */
  }
}

```

## Compliant Solution (realloc())

In this compliant solution, `buf` refers to dynamically allocated memory:

```cpp
#include <stdlib.h>
 
enum { BUFSIZE = 256 };
 
void f(void) {
  char *buf = (char *)malloc(BUFSIZE * sizeof(char));
  char *p = (char *)realloc(buf, 2 * BUFSIZE);
  if (p == NULL) {
    /* Handle error */
  }
}
```
Note that `realloc()` will behave properly even if `malloc()` failed, because when given a null pointer, `realloc()` behaves like a call to `malloc()`.

## Risk Assessment

The consequences of this error depend on the [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation), but they range from nothing to arbitrary code execution if that memory is reused by `malloc()`.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM34-C </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>invalid-free</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-MEM34</strong> </td> <td> Can detect memory deallocations for stack objects </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <strong>clang-analyzer-unix.Malloc</strong> </td> <td> Checked by <code>clang-tidy</code> ; can detect some instances of this rule, but does not detect all </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>ALLOC.TM</strong> </td> <td> Type Mismatch </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect some violations of this rule </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>BAD_FREE</strong> </td> <td> Identifies calls to <code>free()</code> where the argument is a pointer to a function or an array. It also detects the cases where <code>free()</code> is used on an address-of expression, which can never be heap allocated. Coverity Prevent cannot discover all violations of this rule, so further verification is necessary </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF2721, DF2722, DF2723</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>FNH.MIGHT</strong> <strong>FNH.MUST</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>407 S, 483 S, 644 S, 645 S, 125 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-MEM34-a</strong> </td> <td> Do not free resources using invalid pointers </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>424, 673</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule MEM34-C </a> </td> <td> Checks for: Invalid free of pointernvalid free of pointer, invalid reallocation of pointernvalid reallocation of pointer. Rule fully covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2721, 2722, 2723</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2721</strong> , <strong>2722, 2723</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong>V585<a></a></strong> , <strong><a>V726</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>invalid-free</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>unclassified ("free expects a free-able address")</strong> </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

[CVE-2015-0240](https://securityblog.redhat.com/2015/02/23/samba-vulnerability-cve-2015-0240/) describes a [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) in which an uninitialized pointer is passed to `TALLOC_FREE()`, which is a Samba-specific memory deallocation macro that wraps the `talloc_free()` function. The implementation of `talloc_free()` would access the uninitialized pointer, resulting in a remote [exploit](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-exploit).

Search for vulnerabilities resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM34-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MEM31-C. Free dynamically allocated memory when no longer needed </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> MEM51-CPP. Properly deallocate dynamically allocated resources </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Reallocating or freeing memory that was not dynamically allocated \[xfree\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-590 </a> , Free of Memory Not on the Heap </td> <td> 2017-07-10: CERT: Exact </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause J.2, "Undefined Behavior" </td> </tr> <tr> <td> \[ <a> Seacord 2013b </a> \] </td> <td> Chapter 4, "Dynamic Memory Management" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [MEM34-C: Only free memory allocated dynamically](https://wiki.sei.cmu.edu/confluence/display/c)
