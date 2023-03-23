# MEM31-C: Free dynamically allocated memory when no longer needed

This query implements the CERT-C rule MEM31-C:

> Free dynamically allocated memory when no longer needed


## Description

Before the lifetime of the last pointer that stores the return value of a call to a standard memory allocation function has ended, it must be matched by a call to `free()` with that pointer value.

## Noncompliant Code Example

In this noncompliant example, the object allocated by the call to `malloc()` is not freed before the end of the lifetime of the last pointer `text_buffer` referring to the object:

```cpp
#include <stdlib.h>
 
enum { BUFFER_SIZE = 32 };

int f(void) {
  char *text_buffer = (char *)malloc(BUFFER_SIZE); 
  if (text_buffer == NULL) {
    return -1;
  }
  return 0;
}
```

## Compliant Solution

In this compliant solution, the pointer is deallocated with a call to `free()`:

```cpp
#include <stdlib.h>

enum { BUFFER_SIZE = 32 };

int f(void) {
  char *text_buffer = (char *)malloc(BUFFER_SIZE); 
  if (text_buffer == NULL) {
    return -1;
  }
 
  free(text_buffer);
  return 0;
}

```

## Exceptions

**MEM31-C-EX1**: Allocated memory does not need to be freed if it is assigned to a pointer whose lifetime includes program termination. The following code example illustrates a pointer that stores the return value from `malloc()` in a `static` variable:

```cpp
#include <stdlib.h>
 
enum { BUFFER_SIZE = 32 };

int f(void) {
  static char *text_buffer = NULL;
  if (text_buffer == NULL) {
    text_buffer = (char *)malloc(BUFFER_SIZE); 
    if (text_buffer == NULL) {
      return -1;
    }
  }
  return 0;
}

```

## Risk Assessment

Failing to free memory can result in the exhaustion of system memory resources, which can lead to a [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-denial-of-service).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM31-C </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-MEM31</strong> </td> <td> Can detect dynamically allocated resources that are not freed </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>ALLOC.LEAK</strong> </td> <td> Leak </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>RESOURCE_LEAK</strong> <strong>ALLOC_FREE_MISMATCH</strong> </td> <td> Finds resource leaks from variables that go out of scope while owning a resource </td> </tr> <tr> <td> <a> Cppcheck </a> </td> <td> 1.66 </td> <td> <strong>leakReturnValNotUsed</strong> </td> <td> Doesn't use return value of memory allocation function </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF2706, DF2707, DF2708</strong> <strong><strong>C++3337, C++3338</strong></strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>CL.FFM.ASSIGN</strong> <strong>CL.FFM.COPY</strong> <strong>CL.SHALLOW.ASSIGN</strong> <strong>CL.SHALLOW.COPY</strong> <strong>FMM.MIGHT</strong> <strong>FMM.MUST</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>50 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-MEM31-a</strong> </td> <td> Ensure resources are freed </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>429</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule MEM31-C </a> </td> <td> Checks for memory leak (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2706, 2707, 2708</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2706, 2707, 2708, 3337, 3338</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong><a>V773</a></strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S3584</a></strong> </td> <td> </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>malloc</strong> </td> <td> Exhaustively verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM31-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Memory Leak \[XYL\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Failing to close files or free dynamic memory when they are no longer needed \[fileclose\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-401 </a> , Improper Release of Memory Before Removing Last Reference ("Memory Leak") </td> <td> 2017-07-05: CERT: Exact </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-404 </a> </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-459 </a> </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-771 </a> </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-772 </a> </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-404/CWE-459/CWE-771/CWE-772 and FIO42-C/MEM31-C**

Intersection( FIO42-C, MEM31-C) = Ø

CWE-404 = CWE-459 = CWE-771 = CWE-772

CWE-404 = Union( FIO42-C, MEM31-C list) where list =

* Failure to free resources besides files or memory chunks, such as mutexes)

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.22.3, "Memory Management Functions" </td> </tr> </tbody> </table>


## Implementation notes

The rule is enforced in the context of a single function.

## References

* CERT-C: [MEM31-C: Free dynamically allocated memory when no longer needed](https://wiki.sei.cmu.edu/confluence/display/c)
