# EXP36-C: Do not cast pointers into more strictly aligned pointer types

This query implements the CERT-C rule EXP36-C:

> Do not cast pointers into more strictly aligned pointer types


## Description

Do not convert a pointer value to a pointer type that is more strictly aligned than the referenced type. Different alignments are possible for different types of objects. If the type-checking system is overridden by an explicit cast or the pointer is converted to a void pointer (`void *`) and then to a different type, the alignment of an object may be changed.

The C Standard, 6.3.2.3, paragraph 7 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> A pointer to an object or incomplete type may be converted to a pointer to a different object or incomplete type. If the resulting pointer is not correctly aligned for the referenced type, the behavior is undefined.


See [undefined behavior 25.](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_25)

If the misaligned pointer is dereferenced, the program may [terminate abnormally](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination). On some architectures, the cast alone may cause a loss of information even if the value is not dereferenced if the types involved have differing alignment requirements.

## Noncompliant Code Example

In this noncompliant example, the `char` pointer `&c` is converted to the more strictly aligned `int` pointer `ip`. On some [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation), `cp` will not match `&c`. As a result, if a pointer to one object type is converted to a pointer to a different object type, the second object type must not require stricter alignment than the first.

```cpp
#include <assert.h>
 
void func(void) {
  char c = 'x';
  int *ip = (int *)&c; /* This can lose information */
  char *cp = (char *)ip;

  /* Will fail on some conforming implementations */
  assert(cp == &c);
}

```

## Compliant Solution (Intermediate Object)

In this compliant solution, the `char` value is stored into an object of type `int` so that the pointer's value will be properly aligned:

```cpp
#include <assert.h>
 
void func(void) {
  char c = 'x';
  int i = c;
  int *ip = &i;

  assert(ip == &i);
}
```

## Noncompliant Code Example

The C Standard allows any object pointer to be cast to and from `void *`. As a result, it is possible to silently convert from one pointer type to another without the compiler diagnosing the problem by storing or casting a pointer to `void *` and then storing or casting it to the final type. In this noncompliant code example, `loop_function()` is passed the `char` pointer `char_ptr` but returns an object of type `int` pointer:

```cpp
int *loop_function(void *v_pointer) {
  /* ... */
  return v_pointer;
}
 
void func(char *char_ptr) {
  int *int_ptr = loop_function(char_ptr);

  /* ... */
}
```
This example compiles without warning using GCC 4.8 on Ubuntu Linux 14.04. However, `int_pointer` can be more strictly aligned than an object of type `char *`.

## Compliant Solution

Because the input parameter directly influences the return value, and `loop_function()` returns an object of type `int *`, the formal parameter `v_pointer` is redeclared to accept only an object of type `int *`:

```cpp
int *loop_function(int *v_pointer) {
  /* ... */
  return v_pointer;
}
 
void func(int *loop_ptr) {
  int *int_ptr = loop_function(loop_ptr);

  /* ... */
}
```

## Noncompliant Code Example

Some architectures require that pointers are correctly aligned when accessing objects larger than a byte. However, it is common in system code that unaligned data (for example, the network stacks) must be copied to a properly aligned memory location, such as in this noncompliant code example:

```cpp
#include <string.h>
 
struct foo_header {
  int len;
  /* ... */
};
 
void func(char *data, size_t offset) {
  struct foo_header *tmp;
  struct foo_header header;

  tmp = (struct foo_header *)(data + offset);
  memcpy(&header, tmp, sizeof(header));

  /* ... */
}
```
Assigning an unaligned value to a pointer that references a type that needs to be aligned is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). An [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) may notice, for example, that `tmp` and `header` must be aligned and use an inline `memcpy()` that uses instructions that assume aligned data.

## Compliant Solution

This compliant solution avoids the use of the `foo_header` pointer:

```cpp
#include <string.h>
 
struct foo_header {
  int len;
  /* ... */
};
  
void func(char *data, size_t offset) {
  struct foo_header header; 
  memcpy(&header, data + offset, sizeof(header));

  /* ... */
}
```

## Exceptions

**EXP36-C-EX1:** Some hardware architectures have relaxed requirements with regard to pointer alignment. Using a pointer that is not properly aligned is correctly handled by the architecture, although there might be a performance penalty. On such an architecture, improper pointer alignment is permitted but remains an efficiency problem.

The x86 32- and 64-bit architectures usually impose only a performance penalty for violations of this rule, but under some circumstances, noncompliant code can still exhibit undefined behavior. Consider the following program:

```cpp
#include <stdio.h>
#include <stdint.h>

#define READ_UINT16(ptr)       (*(uint16_t *)(ptr))
#define WRITE_UINT16(ptr, val) (*(uint16_t *)(ptr) = (val))

void compute(unsigned char *b1, unsigned char *b2,
             int value, int range) {
  int i;
  for (i = 0; i < range; i++) {
    int newval = (int)READ_UINT16(b1) + value;
    WRITE_UINT16(b2, newval);
    b1 += 2;
    b2 += 2;
  }
}

int main() {
  unsigned char buffer1[1024];
  unsigned char buffer2[1024];
  printf("Compute something\n");
  compute(buffer1 + 3, buffer2 + 1, 42, 500);
  return 0;
}
```
This code tries to read short ints (which are 16 bits long) from odd pairs in a character array, which violates this rule. On 32- and 64-bit x86 platforms, this program should run to completion without incident. However, the program aborts with a SIGSEGV due to the unaligned reads on a 64-bit platform running Debian Linux, when compiled with GCC 4.9.4 using the flags `-O3` or `-O2 -ftree-loop-vectorize -fvect-cost-model`.

If a developer wishes to violate this rule and use undefined behavior, they must not only ensure that the hardware guarantees the behavior of the object code, but they must also ensure that their compiler, along with its optimizer, also respect these guarantees.

**EXP36-C-EX2**: If a pointer is known to be correctly aligned to the target type, then a cast to that type is permitted. There are several cases where a pointer is known to be correctly aligned to the target type. The pointer could point to an object declared with a suitable alignment specifier. It could point to an object returned by `aligned_alloc()`, `calloc()`, `malloc()`, or `realloc()`, as per the C standard, section 7.22.3, paragraph 1 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\].

This compliant solution uses the alignment specifier, which is new to C11, to declare the `char` object `c` with the same alignment as that of an object of type `int`. As a result, the two pointers reference equally aligned pointer types:

```cpp
#include <stdalign.h>
#include <assert.h>
 
void func(void) {
  /* Align c to the alignment of an int */
  alignas(int) char c = 'x';
  int *ip = (int *)&c; 
  char *cp = (char *)ip;
  /* Both cp and &c point to equally aligned objects */
  assert(cp == &c);
}
```

## Risk Assessment

Accessing a pointer or an object that is not properly aligned can cause a program to crash or give erroneous information, or it can cause slow pointer accesses (if the architecture allows misaligned accesses).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP36-C </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>pointer-cast-alignment</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP36</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.CAST.PC.OBJ</strong> </td> <td> Cast: Object Pointers </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule. However, it does not flag explicit casts to <code>void \*</code> and then back to another pointer type </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2004 Rule 11.4</strong> <strong>MISRA C 2012 Rule 11.1</strong> <strong><strong>MISRA C 2012 Rule 11.2</strong></strong> <strong><strong><strong>MISRA C 2012 Rule 11.5</strong></strong></strong> <strong><strong><strong><strong>MISRA C 2012 Rule 11.7</strong></strong></strong></strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.EXP36</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> EDG </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 4.3.5 </td> <td> </td> <td> Can detect some violations of this rule when the <code>-Wcast-align</code> flag is used </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C0326, C3305</strong> <strong>C++3033, C++3038</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.CAST.OBJ_PTR_TO_OBJ_PTR.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>94 S, 606 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-EXP36-a</strong> </td> <td> A cast should not be performed between a pointer to object type and a different pointer to object type </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2445</strong> </td> <td> Partially supported: reports casts directly from a pointer to a less strictly aligned type to a pointer to a more strictly aligned type </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule EXP36-C </a> </td> <td> Checks for source buffer misaligned with destination buffer (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0326, 3305</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3033, 3038</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.22 </td> <td> <strong>V548<a></a></strong> , <strong><a>V641</a></strong> , <strong><a>V1032</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>pointer-cast-alignment</strong> </td> <td> Fully checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP36-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> VOID EXP56-CPP. Do not cast pointers into more strictly aligned pointer types </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Pointer Casting and Pointer Type Changes \[HFC\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Converting pointer values to more strictly aligned pointer types \[alignconv\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 11.1 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 11.2 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 11.5 (advisory) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 11.7 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Bryant 2003 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.3.2.3, "Pointers" </td> </tr> <tr> <td> \[ <a> Walfridsson 2003 </a> \] </td> <td> <a> Aliasing, Pointer Casts and GCC 3.3 </a> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [EXP36-C: Do not cast pointers into more strictly aligned pointer types](https://wiki.sei.cmu.edu/confluence/display/c)
