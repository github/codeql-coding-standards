# FIO42-C: Close files when they are no longer needed

This query implements the CERT-C rule FIO42-C:

> Close files when they are no longer needed


## Description

A call to the `fopen()` or `freopen()` function must be matched with a call to `fclose()` before the lifetime of the last pointer that stores the return value of the call has ended or before normal program termination, whichever occurs first.

In general, this rule should also be applied to other functions with open and close resources, such as the POSIX `open()` and `close()` functions, or the Microsoft Windows `CreateFile()` and `CloseHandle()` functions.

## Noncompliant Code Example

This code example is noncompliant because the file opened by the call to `fopen()` is not closed before function `func()` returns:

```cpp
#include <stdio.h>
 
int func(const char *filename) {
  FILE *f = fopen(filename, "r"); 
  if (NULL == f) {
    return -1;
  }
  /* ... */
  return 0;
}
```

## Compliant Solution

In this compliant solution, the file pointed to by `f` is closed before returning to the caller:

```cpp
#include <stdio.h>
 
int func(const char *filename) {
  FILE *f = fopen(filename, "r"); 
  if (NULL == f) {
    return -1;
  }
  /* ... */
  if (fclose(f) == EOF) {
    return -1;
  }
  return 0;
}
```

## Noncompliant Code Example (exit())

This code example is noncompliant because the resource allocated by the call to `fopen()` is not closed before the program terminates. Although `exit()` closes the file, the program has no way of determining if an error occurs while flushing or closing the file.

```cpp
#include <stdio.h>
#include <stdlib.h>
  
int main(void) {
  FILE *f = fopen(filename, "w"); 
  if (NULL == f) {
    exit(EXIT_FAILURE);
  }
  /* ... */
  exit(EXIT_SUCCESS);
}
```

## Compliant Solution (exit())

In this compliant solution, the program closes `f` explicitly before calling `exit()`, allowing any error that occurs when flushing or closing the file to be handled appropriately:

```cpp
#include <stdio.h>
#include <stdlib.h>

int main(void) {
  FILE *f = fopen(filename, "w"); 
  if (NULL == f) {
    /* Handle error */
  }
  /* ... */
  if (fclose(f) == EOF) {
    /* Handle error */
  }
  exit(EXIT_SUCCESS);
}
```

## Noncompliant Code Example (POSIX)

This code example is noncompliant because the resource allocated by the call to `open()` is not closed before function `func()` returns:

```cpp
#include <stdio.h>
#include <fcntl.h>
 
int func(const char *filename) {
  int fd = open(filename, O_RDONLY, S_IRUSR);
  if (-1 == fd) {
    return -1;
  }
  /* ... */
  return 0;
}
```

## Compliant Solution (POSIX)

In this compliant solution, `fd` is closed before returning to the caller:

```cpp
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
 
int func(const char *filename) {
  int fd = open(filename, O_RDONLY, S_IRUSR);
  if (-1 == fd) {
    return -1
  }
  /* ... */
  if (-1 == close(fd)) {
    return -1;
  }
  return 0;
}
```

## Noncompliant Code Example (Windows)

In this noncompliant code example, the file opened by the Microsoft Windows `[CreateFile()](http://msdn.microsoft.com/en-us/library/windows/desktop/aa363858(v=vs.85).aspx)` function is not closed before `func()` returns:

```cpp
#include <Windows.h>

int func(LPCTSTR filename) {
  HANDLE hFile = CreateFile(filename, GENERIC_READ, 0, NULL,
                            OPEN_EXISTING,
                            FILE_ATTRIBUTE_NORMAL, NULL);
  if (INVALID_HANDLE_VALUE == hFile) {
    return -1;
  }
  /* ... */
  return 0;
}
```

## Compliant Solution (Windows)

In this compliant solution, `hFile` is closed by invoking the `[CloseHandle()](http://msdn.microsoft.com/en-us/library/windows/desktop/ms724211(v=vs.85).aspx)` function before returning to the caller:

```cpp
#include <Windows.h>
 
int func(LPCTSTR filename) {
  HANDLE hFile = CreateFile(filename, GENERIC_READ, 0, NULL,
                            OPEN_EXISTING,
                            FILE_ATTRIBUTE_NORMAL, NULL);
  if (INVALID_HANDLE_VALUE == hFile) {
    return -1;
  } 
  /* ... */ 
  if (!CloseHandle(hFile)) {
    return -1;
  }
 
  return 0;
}
```

## Risk Assessment

Failing to properly close files may allow an attacker to exhaust system resources and can increase the risk that data written into in-memory file buffers will not be flushed in the event of [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO42-C </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

This rule is stricter than rule \[fileclose\] in [ISO/IEC TS 17961:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IECTS17961). Analyzers that conform to the technical standard may not detect all violations of this rule.

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>ALLOC.LEAK</strong> </td> <td> Leak </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>RESOURCE_LEAK (partial)</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF2701, DF2702, DF2703</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>RH.LEAK</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>49 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-FIO42-a</strong> </td> <td> Ensure resources are freed </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>429</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule FIO42-C </a> </td> <td> Checks for resource leak (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2701, 2702, 2703</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2701, 2702, 2703</strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S2095</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO42-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> FIO51-CPP. Close files when they are no longer needed </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> FIO04-J. Release resources when they are no longer needed </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Failing to close files or free dynamic memory when they are no longer needed \[fileclose\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-404 </a> , Improper Resource Shutdown or Release </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-459 </a> </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-772 </a> </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-773 </a> </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-775 </a> </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-403 </a> </td> <td> 2017-10-30:MITRE:Unspecified Relationship 2018-10-18:CERT: Partial overlap </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-773/CWE-775 and FIO42-C**

CWE-773 = CWE-775

CWE-773 = Union( FIO42-C, list) where list =

* Failure to free resource handles besides files
**CWE-404/CWE-459/CWE-771/CWE-772 and FIO42-C/MEM31-C**

Intersection( FIO42-C, MEM31-C) = Ø

CWE-404 = CWE-459 = CWE-771 = CWE-772

CWE-404 = Union( FIO42-C, MEM31-C list) where list =

* Failure to free resources besides files or memory chunks, such as mutexes)
**CWE-403 and FIO42-C**

CWE-403 - FIO42-C = list, where list =

* A process opens and closes a sensitive file descriptor, but also executes a child process while the file descriptor is open.
FIO42-C - CWE-403 = SPECIAL_CASES, where SPECIAL_CASES =
* A program opens a file descriptor and fails to close it, but does not invoke any child processes while the file descriptor is open.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE Std 1003.1:2013 </a> \] </td> <td> XSH, System Interfaces, <code>open</code> </td> </tr> </tbody> </table>


## Implementation notes

The rule is enforced in the context of a single function.

## References

* CERT-C: [FIO42-C: Close files when they are no longer needed](https://wiki.sei.cmu.edu/confluence/display/c)
