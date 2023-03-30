# MEM35-C: Allocate sufficient memory for an object

This query implements the CERT-C rule MEM35-C:

> Allocate sufficient memory for an object


## Description

The types of integer expressions used as size arguments to `malloc()`, `calloc()`, `realloc()`, or `aligned_alloc()` must have sufficient range to represent the size of the objects to be stored. If size arguments are incorrect or can be manipulated by an attacker, then a buffer overflow may occur. Incorrect size arguments, inadequate range checking, integer overflow, or truncation can result in the allocation of an inadequately sized buffer.

Typically, the amount of memory to allocate will be the size of the type of object to allocate. When allocating space for an array, the size of the object will be multiplied by the bounds of the array. When allocating space for a structure containing a flexible array member, the size of the array member must be added to the size of the structure. (See [MEM33-C. Allocate and copy structures containing a flexible array member dynamically](https://wiki.sei.cmu.edu/confluence/display/c/MEM33-C.++Allocate+and+copy+structures+containing+a+flexible+array+member+dynamically).) Use the correct type of the object when computing the size of memory to allocate.

[STR31-C. Guarantee that storage for strings has sufficient space for character data and the null terminator](https://wiki.sei.cmu.edu/confluence/display/c/STR31-C.+Guarantee+that+storage+for+strings+has+sufficient+space+for+character+data+and+the+null+terminator) is a specific instance of this rule.

## Noncompliant Code Example (Pointer)

In this noncompliant code example, inadequate space is allocated for a `struct tm` object because the size of the pointer is being used to determine the size of the pointed-to object:

```cpp
#include <stdlib.h>
#include <time.h>
 
struct tm *make_tm(int year, int mon, int day, int hour,
                   int min, int sec) {
  struct tm *tmb;
  tmb = (struct tm *)malloc(sizeof(tmb));
  if (tmb == NULL) {
    return NULL;
  }
  *tmb = (struct tm) {
    .tm_sec = sec, .tm_min = min, .tm_hour = hour,
    .tm_mday = day, .tm_mon = mon, .tm_year = year
  };
  return tmb;
}
```

## Compliant Solution (Pointer)

In this compliant solution, the correct amount of memory is allocated for the `struct tm` object. When allocating space for a single object, passing the (dereferenced) pointer type to the `sizeof` operator is a simple way to allocate sufficient memory. Because the `sizeof` operator does not evaluate its operand, dereferencing an uninitialized or null pointer in this context is well-defined behavior.

```cpp
#include <stdlib.h>
#include <time.h>
 
struct tm *make_tm(int year, int mon, int day, int hour,
                   int min, int sec) {
  struct tm *tmb;
  tmb = (struct tm *)malloc(sizeof(*tmb));
  if (tmb == NULL) {
    return NULL;
  }
  *tmb = (struct tm) {
    .tm_sec = sec, .tm_min = min, .tm_hour = hour,
    .tm_mday = day, .tm_mon = mon, .tm_year = year
  };
  return tmb;
}
```

## Noncompliant Code Example (Integer)

In this noncompliant code example, an array of `long` is allocated and assigned to `p`. The code attempts to check for unsigned integer overflow in compliance with [INT30-C. Ensure that unsigned integer operations do not wrap](https://wiki.sei.cmu.edu/confluence/display/c/INT30-C.+Ensure+that+unsigned+integer+operations+do+not+wrap) and also ensures that `len` is not equal to zero. (See [MEM04-C. Beware of zero-length allocations](https://wiki.sei.cmu.edu/confluence/display/c/MEM04-C.+Beware+of+zero-length+allocations).) However, because `sizeof(int)` is used to compute the size, and not `sizeof(long)`, an insufficient amount of memory can be allocated on implementations where `sizeof(long)` is larger than `sizeof(int)`, and filling the array can cause a heap buffer overflow.

```cpp
#include <stdint.h>
#include <stdlib.h>
 
void function(size_t len) {
  long *p;
  if (len == 0 || len > SIZE_MAX / sizeof(long)) {
    /* Handle overflow */
  }
  p = (long *)malloc(len * sizeof(int));
  if (p == NULL) {
    /* Handle error */
  }
  free(p);
}

```

## Compliant Solution (Integer)

This compliant solution uses `sizeof(long)` to correctly size the memory allocation:

```cpp
#include <stdint.h>
#include <stdlib.h>

void function(size_t len) {
  long *p;
  if (len == 0 || len > SIZE_MAX / sizeof(long)) {
    /* Handle overflow */
  }
  p = (long *)malloc(len * sizeof(long));
  if (p == NULL) {
    /* Handle error */
  }
  free(p);
}

```

## Compliant Solution (Integer)

Alternatively, `sizeof(*p)` can be used to properly size the allocation:

```cpp
#include <stdint.h>
#include <stdlib.h>
 
void function(size_t len) {
  long *p;
  if (len == 0 || len > SIZE_MAX / sizeof(*p)) {
    /* Handle overflow */
  }
  p = (long *)malloc(len * sizeof(*p));
  if (p == NULL) {
    /* Handle error */
  }
  free(p);
}
```

## Risk Assessment

Providing invalid size arguments to memory allocation functions can lead to buffer overflows and the execution of arbitrary code with the permissions of the vulnerable process.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM35-C </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>malloc-size-insufficient</strong> </td> <td> Partially checked Besides direct rule violations, all undefined behaviour resulting from invalid memory accesses is reported by Astrée. </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-MEM35</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>ALLOC.SIZE.ADDOFLOW</strong> <strong>ALLOC.SIZE.IOFLOW</strong> <strong>ALLOC.SIZE.MULOFLOW</strong> <strong>ALLOC.SIZE.SUBUFLOW</strong> <strong>ALLOC.SIZE.TRUNC</strong> <strong>IO.TAINT.SIZE</strong> <strong>MISC.MEM.SIZE.BADLANG.MEM.BOLANG.MEM.BULANG.STRUCT.PARITHLANG.STRUCT.PBBLANG.STRUCT.PPELANG.MEM.TBALANG.MEM.TOLANG.MEM.TU</strong> </td> <td> Addition overflow of allocation size Addition overflow of allocation size Multiplication overflow of allocation size Subtraction underflow of allocation size Truncation of allocation size Tainted allocation size Unreasonable size argument Buffer Overrun Buffer Underrun Pointer Arithmetic Pointer Before Beginning of Object Pointer Past End of Object Tainted Buffer Access Type Overrun Type Underrun </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Could check violations of this rule by examining the size expression to <code>malloc()</code> or <code>memcpy()</code> functions. Specifically, the size argument should be bounded by 0, <code>SIZE_MAX</code> , and, unless it is a variable of type <code>size_t</code> or <code>rsize_t</code> , it should be bounds-checked before the <code>malloc()</code> call. If the argument is of the expression <code>a\*b</code> , then an appropriate check is <code>if (a &lt; SIZE_MAX / b &amp;&amp; a &gt; 0) ...</code> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>BAD_ALLOC_STRLEN</strong> <strong>SIZECHECK (deprecated)</strong> </td> <td> Partially implemented Can find instances where string length is miscalculated (length calculated may be one less than intended) for memory allocation purposes. Coverity Prevent cannot discover all violations of this rule, so further verification is necessary Finds memory allocations that are assigned to a pointer that reference objects larger than the allocated block </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C0696, C0701, C1069, C1071, C1073, C2840</strong> <strong>DF2840, DF2841, DF2842, DF2843, DF2935, DF2936, DF2937, DF2938</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>INCORRECT.ALLOC_SIZE</strong> <strong>SV.TAINTED.ALLOC_SIZE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>400 S, 487 S, 115 D</strong> </td> <td> Enhanced enforcement </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-MEM35-a</strong> </td> <td> Do not use sizeof operator on pointer type to specify the size of the memory to be allocated via 'malloc', 'calloc' or 'realloc' function </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>433, 826</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule MEM35-C </a> </td> <td> Checks for: Pointer access out of boundsointer access out of bounds, memory allocation with tainted sizeemory allocation with tainted size. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0696, 0701, 1069, 1071, 1073, 2840, 2841, 2842, 2843, 2935, 2936, 2937, 2938</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2840, 2841, 2842, 2843, 2935, 2936, 2937, 2938</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong>V531<a></a></strong> , <strong>V635<a></a></strong> , <strong><a>V781</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>malloc-size-insufficient</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>mem_access</strong> </td> <td> Exhaustively detects undefined behavior (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM35-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> ARR01-C. Do not apply the sizeof operator to a pointer when taking the size of an array </a> <a> INT31-C. Ensure that integer conversions do not result in lost or misinterpreted data </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> INT32-C. Ensure that operations on signed integers do not result in overflow </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> INT18-C. Evaluate integer expressions in a larger size before comparing or assigning to that size </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MEM04-C. Beware of zero-length allocations </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Buffer Boundary Violation (Buffer Overflow) \[HCB\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Taking the size of a pointer to determine the size of the pointed-to type \[sizeofptr\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-131 </a> , Incorrect Calculation of Buffer Size </td> <td> 2017-05-16: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-680 </a> </td> <td> 2017-05-18: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-789 </a> </td> <td> 2017-06-12: CERT: Partial overlap </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-680 and MEM35-C**

Intersection( INT32-C, MEM35-C) = Ø

CWE-680 = Union( MEM35-C, list) where list =

* Overflowed buffers with inadequate sizes not produced by integer overflow
**CWE-467 and MEM35-C**

CWE-467 = Subset( MEM35-C)

**CWE-789 and MEM35-C**

Intersection( MEM35-C, CWE-789) =

* Insufficient memory allocation on the heap
MEM35-C – CWE-789 =
* Insufficient memory allocation with trusted value but incorrect calculation
CWE-789 - MEM35-C =
* Sufficient memory allocation (possibly over-allocation) with untrusted value
**CWE-120 and MEM35-C**

Intersection( MEM35-C, CWE-120) = Ø

CWE-120 specifically addresses buffer overflow operations, which occur in the context of string-copying. MEM35-C specifically addresses allocation of memory ranges (some of which may be for subsequent string copy operations).

Consequently, they address different sections of code, although one (or both) may be responsible for a single buffer overflow vulnerability.

**CWE-131 and MEM35-C**

* Intersection( INT30-C, MEM35-C) = Ø
* CWE-131 = Union( MEM35-C, list) where list =
* Miscalculating a buffer for a non-heap region (such as a variable-length array)

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Coverity 2007 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Drepper 2006 </a> \] </td> <td> Section 2.1.1, "Respecting Memory Bounds" </td> </tr> <tr> <td> \[ <a> Seacord 2013 </a> \] </td> <td> Chapter 4, "Dynamic Memory Management" Chapter 5, "Integer Security" </td> </tr> <tr> <td> \[ <a> Viega 2005 </a> \] </td> <td> Section 5.6.8, "Use of <code>sizeof()</code> on a Pointer Type" </td> </tr> <tr> <td> \[ <a> xorl 2009 </a> \] </td> <td> <a> CVE-2009-0587: Evolution Data Server Base64 Integer Overflows </a> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [MEM35-C: Allocate sufficient memory for an object](https://wiki.sei.cmu.edu/confluence/display/c)
