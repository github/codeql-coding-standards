# ARR36-C: Do not subtract two pointers that do not refer to the same array

This query implements the CERT-C rule ARR36-C:

> Do not subtract or compare two pointers that do not refer to the same array


## Description

When two pointers are subtracted, both must point to elements of the same array object or just one past the last element of the array object (C Standard, 6.5.6 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\]); the result is the difference of the subscripts of the two array elements. Otherwise, the operation is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 48](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_48).)

Similarly, comparing pointers using the relational operators `<`, `<=`, `>=`, and `>` gives the positions of the pointers relative to each other. Subtracting or comparing pointers that do not refer to the same array is undefined behavior. (See [undefined behavior 48](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_48) and [undefined behavior 53](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_53).)

Comparing pointers using the equality operators `==` and `!=` has well-defined semantics regardless of whether or not either of the pointers is null, points into the same object, or points one past the last element of an array object or function.

## Noncompliant Code Example

In this noncompliant code example, pointer subtraction is used to determine how many free elements are left in the `nums` array:

```cpp
#include <stddef.h>
 
enum { SIZE = 32 };
 
void func(void) {
  int nums[SIZE];
  int end;
  int *next_num_ptr = nums;
  size_t free_elements;

  /* Increment next_num_ptr as array fills */

  free_elements = &end - next_num_ptr;
}
```
This program incorrectly assumes that the `nums` array is adjacent to the `end` variable in memory. A compiler is permitted to insert padding bits between these two variables or even reorder them in memory.

## Compliant Solution

In this compliant solution, the number of free elements is computed by subtracting `next_num_ptr` from the address of the pointer past the `nums` array. While this pointer may not be dereferenced, it may be used in pointer arithmetic.

```cpp
#include <stddef.h>
enum { SIZE = 32 };
 
void func(void) {
  int nums[SIZE];
  int *next_num_ptr = nums;
  size_t free_elements;

  /* Increment next_num_ptr as array fills */

  free_elements = &(nums[SIZE]) - next_num_ptr;
}
```

## Exceptions

**ARR36-C-EX1:**Comparing two pointers to distinct members of the same `struct` object is allowed. Pointers to structure members declared later in the structure compare greater-than pointers to members declared earlier in the structure.

## Risk Assessment

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ARR36-C </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>pointer-subtraction</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-ARR36</strong> </td> <td> Can detect operations on pointers that are unrelated </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.STRUCT.CUP</strong> <strong>LANG.STRUCT.SUP</strong> </td> <td> Comparison of Unrelated Pointers Subtraction of Unrelated Pointers </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2004 17.2</strong> <strong>MISRA C 2004 17.3</strong> <strong>MISRA C 2012 18.2</strong> <strong>MISRA C 2012 18.3</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C0487, C0513</strong> <strong>DF2668, DF2669, DF2761, DF2762, DF2763, DF2766, DF2767, DF2768, DF2771, DF2772, DF2773</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.PTR.ARITH</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>437 S, 438 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-ARR36-aCERT_C-ARR36-b</strong> </td> <td> Do not subtract two pointers that do not address elements of the same array Do not compare two unrelated pointers </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule ARR36-C </a> </td> <td> Checks for subtraction or comparison between pointers to different arrays (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0487, 0513, 2668, 2669, 2761,</strong> <strong> 2762, 2763, 2766, 2767, 2768, </strong> <strong>2771, 2772, 2773</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong>V736<a></a></strong> , <strong><a>V782</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>pointer-subtraction</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>differing_blocks</strong> </td> <td> Exhaustively verified (see <a> the compliant and the non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ARR36-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> CTR54-CPP. Do not subtract iterators that do not refer to the same container </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Subtracting or comparing two pointers that do not refer to the same array \[ptrobj\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-469 </a> , Use of Pointer Subtraction to Determine Size </td> <td> 2017-07-10: CERT: Exact </td> </tr> <tr> <td> <a> CWE 3.11 </a> </td> <td> <a> CWE-469 </a> , Use of Pointer Subtraction to Determine Size </td> <td> 2018-10-18:CERT: CWE subset of rule </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-469 and ARR36-C**

CWE-469 = Subset(ARR36-C)

ARR36-C = Union(CWE-469, list) where list =

* Pointer comparisons using the relational operators `<`, `<=`, `>=`, and `>`, where the pointers do not refer to the same array

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Banahan 2003 </a> \] </td> <td> <a> Section 5.3, "Pointers" </a> <a> Section 5.7, "Expressions Involving Pointers" </a> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.5.6, "Additive Operators" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ARR36-C: Do not subtract or compare two pointers that do not refer to the same array](https://wiki.sei.cmu.edu/confluence/display/c)
