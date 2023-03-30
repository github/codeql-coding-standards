# ARR32-C: Ensure size arguments for variable length arrays are in a valid range

This query implements the CERT-C rule ARR32-C:

> Ensure size arguments for variable length arrays are in a valid range


## Description

Variable length arrays (VLAs), a conditionally supported language feature, are essentially the same as traditional C arrays except that they are declared with a size that is not a constant integer expression and can be declared only at block scope or function prototype scope and no linkage. When supported, a variable length array can be declared

```cpp
{ /* Block scope */
  char vla[size];
}

```
where the integer expression `size` and the declaration of `vla` are both evaluated at runtime. If the size argument supplied to a variable length array is not a positive integer value, the behavior is undefined. (See [undefined behavior 75](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_75).) Additionally, if the magnitude of the argument is excessive, the program may behave in an unexpected way. An attacker may be able to leverage this behavior to overwrite critical program data \[[Griffiths 2006](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Griffiths06)\]. The programmer must ensure that size arguments to variable length arrays, especially those derived from untrusted data, are in a valid range.

Because variable length arrays are a conditionally supported feature of C11, their use in portable code should be guarded by testing the value of the macro `__STDC_NO_VLA__`. Implementations that do not support variable length arrays indicate it by setting `__STDC_NO_VLA__` to the integer constant 1.

## Noncompliant Code Example

In this noncompliant code example, a variable length array of size `size` is declared. The `size` is declared as `size_t` in compliance with [INT01-C. Use rsize_t or size_t for all integer values representing the size of an object](https://wiki.sei.cmu.edu/confluence/display/c/INT01-C.+Use+rsize_t+or+size_t+for+all+integer+values+representing+the+size+of+an+object).

```cpp
#include <stddef.h>

extern void do_work(int *array, size_t size);
 
void func(size_t size) {
  int vla[size];
  do_work(vla, size);
}

```
However, the value of `size` may be zero or excessive, potentially giving rise to a security [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability).

## Compliant Solution

This compliant solution ensures the `size` argument used to allocate `vla` is in a valid range (between 1 and a programmer-defined maximum); otherwise, it uses an algorithm that relies on dynamic memory allocation. The solution also avoids unsigned integer wrapping that, given a sufficiently large value of `size`, would cause `malloc` to allocate insufficient storage for the array.

```cpp
#include <stdint.h>
#include <stdlib.h>
 
enum { MAX_ARRAY = 1024 };
extern void do_work(int *array, size_t size);
 
void func(size_t size) {
  if (0 == size || SIZE_MAX / sizeof(int) < size) {
    /* Handle error */
    return;
  }
  if (size < MAX_ARRAY) {
    int vla[size];
    do_work(vla, size);
  } else {
    int *array = (int *)malloc(size * sizeof(int));
    if (array == NULL) {
      /* Handle error */
    }
    do_work(array, size);
    free(array);
  }
}

```

## Noncompliant Code Example (sizeof)

The following noncompliant code example defines `A` to be a variable length array and then uses the `sizeof` operator to compute its size at runtime. When the function is called with an argument greater than `SIZE_MAX / (N1 * sizeof (int))`, the runtime `sizeof` expression may wrap around, yielding a result that is smaller than the mathematical product `N1 * n2 * sizeof (int)`. The call to `malloc()`, when successful, will then allocate storage for fewer than `n2` elements of the array, causing one or more of the final `memset()` calls in the `for` loop to write past the end of that storage.

```cpp
#include <stdlib.h>
#include <string.h>
 
enum { N1 = 4096 };

void *func(size_t n2) {
  typedef int A[n2][N1];

  A *array = malloc(sizeof(A));
  if (!array) {
    /* Handle error */
    return NULL;
  }

  for (size_t i = 0; i != n2; ++i) {
    memset(array[i], 0, N1 * sizeof(int));
  }

  return array;
}

```
Furthermore, this code also violates [ARR39-C. Do not add or subtract a scaled integer to a pointer](https://wiki.sei.cmu.edu/confluence/display/c/ARR39-C.+Do+not+add+or+subtract+a+scaled+integer+to+a+pointer), where `array` is a pointer to the two-dimensional array, where it should really be a pointer to the latter dimension instead. This means that the `memset() `call does out-of-bounds writes on all of its invocations except the first.

## Compliant Solution (sizeof)

This compliant solution prevents `sizeof` wrapping by detecting the condition before it occurs and avoiding the subsequent computation when the condition is detected. The code also uses an additional typedef to fix the type of `array` so that `memset()` never writes past the two-dimensional array.

```cpp
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
 
enum { N1 = 4096 };

void *func(size_t n2) {
  if (n2 > SIZE_MAX / (N1 * sizeof(int))) {
    /* Prevent sizeof wrapping */
    return NULL;
  }

  typedef int A1[N1];
  typedef A1 A[n2];

  A1 *array = (A1*) malloc(sizeof(A));

  if (!array) {
    /* Handle error */
    return NULL;
  } 

  for (size_t i = 0; i != n2; ++i) {
    memset(array[i], 0, N1 * sizeof(int));
  }
  return array;
}

```
**Implementation Details**

**Microsoft**

Variable length arrays are not supported by Microsoft compilers.

## Risk Assessment

Failure to properly specify the size of a variable length array may allow arbitrary code execution or result in stack exhaustion.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ARR32-C </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>ALLOC.SIZE.IOFLOWALLOC.SIZE.MULOFLOWMISC.MEM.SIZE.BAD</strong> </td> <td> Integer Overflow of Allocation Size Multiplication Overflow of Allocation Size Unreasonable Size Argument </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>REVERSE_NEGATIVE</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C1051</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.ARRAY.VAR_LENGTH.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>621 S</strong> </td> <td> Enhanced enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-ARR32-a</strong> </td> <td> Ensure the size of the variable length array is in valid range </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>9035</strong> </td> <td> Assistance provided </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule ARR32-C </a> </td> <td> Checks for: Memory allocation with tainted sizeemory allocation with tainted size, tainted size of variable length arrayainted size of variable length array. Rule fully covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>1051</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Cppcheck </a> </td> <td> 1.66 </td> <td> <strong>negativeArraySize</strong> </td> <td> Context sensitive analysis Will warn only if given size is negative </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>alloca_bounds</strong> </td> <td> Exhaustively verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ARR32-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> INT01-C. Use rsize_t or size_t for all integer values representing the size of an object </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Unchecked Array Indexing \[XYZ\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Tainted, potentially mutilated, or out-of-domain integer values are used in a restricted sink \[taintsink\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-758 </a> </td> <td> 2017-06-29: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-129 and ARR32-C**

Intersection( CWE-188, EXP39-C) = Ø

ARR32-C addresses specifying the size of a variable-length array (VLA). CWE-129 addresses invalid array indices, not array sizes.

**CWE-758 and ARR32-C**

Independent( INT34-C, INT36-C, MSC37-C, FLP32-C, EXP33-C, EXP30-C, ERR34-C, ARR32-C)

CWE-758 = Union( ARR32-C, list) where list =

* Undefined behavior that results from anything other than too large a VLA dimension.
**CWE-119 and ARR32-C**
* Intersection( CWE-119, ARR32-C) = Ø
* ARR32-C is not about providing a valid buffer but reading/writing outside it. It is about providing an invalid buffer, or one that exhausts the stack.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Griffiths 2006 </a> \] </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ARR32-C: Ensure size arguments for variable length arrays are in a valid range](https://wiki.sei.cmu.edu/confluence/display/c)
