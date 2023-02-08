# MEM30-C: Do not access freed memory

This query implements the CERT-C rule MEM30-C:

> Do not access freed memory


## Description

Evaluating a pointer—including dereferencing the pointer, using it as an operand of an arithmetic operation, type casting it, and using it as the right-hand side of an assignment—into memory that has been deallocated by a memory management function is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). Pointers to memory that has been deallocated are called *dangling pointers*. Accessing a dangling pointer can result in exploitable [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability).

According to the C Standard, using the value of a pointer that refers to space deallocated by a call to the `free()` or `realloc()` function is undefined behavior. (See [undefined behavior 177](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).)

Reading a pointer to deallocated memory is undefined behavior because the pointer value is [indeterminate](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue) and might be a [trap representation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-traprepresentation). Fetching a trap representation might perform a hardware trap (but is not required to).

It is at the memory manager's discretion when to reallocate or recycle the freed memory. When memory is freed, all pointers into it become invalid, and its contents might either be returned to the operating system, making the freed space inaccessible, or remain intact and accessible. As a result, the data at the freed location can appear to be valid but change unexpectedly. Consequently, memory must not be written to or read from once it is freed.

## Noncompliant Code Example

This example from Brian Kernighan and Dennis Ritchie \[[Kernighan 1988](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Kernighan88)\] shows both the incorrect and correct techniques for freeing the memory associated with a linked list. In their (intentionally) incorrect example, `p` is freed before `p->next` is executed, so that `p->next` reads memory that has already been freed.

```cpp
#include <stdlib.h>
 
struct node {
  int value;
  struct node *next;
};
 
void free_list(struct node *head) {
  for (struct node *p = head; p != NULL; p = p->next) {
    free(p);
  }
}
```

## Compliant Solution

Kernighan and Ritchie correct this error by storing a reference to `p->next` in `q` before freeing `p`:

```cpp
#include <stdlib.h>
 
struct node {
  int value;
  struct node *next;
};
 
void free_list(struct node *head) {
  struct node *q;
  for (struct node *p = head; p != NULL; p = q) {
    q = p->next;
    free(p);
  }
}
```

## Noncompliant Code Example

In this noncompliant code example, `buf` is written to after it has been freed. Write-after-free vulnerabilities can be [exploited](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-exploit) to run arbitrary code with the permissions of the vulnerable process. Typically, allocations and frees are far removed, making it difficult to recognize and diagnose these problems.

```cpp
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
  char *return_val = 0;
  const size_t bufsize = strlen(argv[0]) + 1;
  char *buf = (char *)malloc(bufsize);
  if (!buf) {
    return EXIT_FAILURE;
  }
  /* ... */
  free(buf);
  /* ... */
  strcpy(buf, argv[0]);
  /* ... */
  return EXIT_SUCCESS;
}
```

## Compliant Solution

In this compliant solution, the memory is freed after its final use:

```cpp
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
  char *return_val = 0;
  const size_t bufsize = strlen(argv[0]) + 1;
  char *buf = (char *)malloc(bufsize);
  if (!buf) {
    return EXIT_FAILURE;
  }
  /* ... */
  strcpy(buf, argv[0]);
  /* ... */
  free(buf);
  return EXIT_SUCCESS;
}

```

## Noncompliant Code Example

In this noncompliant example, `realloc()` may free `c_str1` when it returns a null pointer, resulting in `c_str1` being freed twice. The C Standards Committee's proposed response to [Defect Report \#400](http://www.open-std.org/jtc1/sc22/wg14/www/docs/dr_400.htm) makes it implementation-defined whether or not the old object is deallocated when `size` is zero and memory for the new object is not allocated. The current implementation of `realloc()` in the GNU C Library and Microsoft Visual Studio's Runtime Library will free `c_str1` and return a null pointer for zero byte allocations. Freeing a pointer twice can result in a potentially exploitable vulnerability commonly referred to as a *double-free vulnerability* \[[Seacord 2013b](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Seacord2013)\].

```cpp
#include <stdlib.h>
 
void f(char *c_str1, size_t size) {
  char *c_str2 = (char *)realloc(c_str1, size);
  if (c_str2 == NULL) {
    free(c_str1);
  }
}
```

## Compliant Solution

This compliant solution does not pass a size argument of zero to the `realloc()` function, eliminating the possibility of `c_str1` being freed twice:

```cpp
#include <stdlib.h>
 
void f(char *c_str1, size_t size) {
  if (size != 0) {
    char *c_str2 = (char *)realloc(c_str1, size); 
    if (c_str2 == NULL) {
      free(c_str1); 
    }
  }
  else {
    free(c_str1);
  }
 
}
```
If the intent of calling `f()` is to reduce the size of the object, then doing nothing when the size is zero would be unexpected; instead, this compliant solution frees the object.

## Noncompliant Code Example

In this noncompliant example ([CVE-2009-1364](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2009-1364)) from `libwmf` version 0.2.8.4, the return value of `gdRealloc` (a simple wrapper around `realloc()` that reallocates space pointed to by `im->clip->list`) is set to `more`. However, the value of `im->clip->list` is used directly afterwards in the code, and the C Standard specifies that if `realloc()` moves the area pointed to, then the original block is freed. An attacker can then execute arbitrary code by forcing a reallocation (with a sufficient `im->clip->count`) and accessing freed memory \[[xorl 2009](http://xorl.wordpress.com/2009/05/05/cve-2009-1364-libwmf-pointer-use-after-free/)\].

```cpp
void gdClipSetAdd(gdImagePtr im, gdClipRectanglePtr rect) {
  gdClipRectanglePtr more;
  if (im->clip == 0) {
   /* ... */
  }
  if (im->clip->count == im->clip->max) {
    more = gdRealloc (im->clip->list,(im->clip->max + 8) *
                      sizeof (gdClipRectangle));
    /*
     * If the realloc fails, then we have not lost the
     * im->clip->list value.
     */
    if (more == 0) return; 
    im->clip->max += 8;
  }
  im->clip->list[im->clip->count] = *rect;
  im->clip->count++;

}
```

## Compliant Solution

This compliant solution simply reassigns `im->clip->list` to the value of `more` after the call to `realloc()`:

```cpp
void gdClipSetAdd(gdImagePtr im, gdClipRectanglePtr rect) {
  gdClipRectanglePtr more;
  if (im->clip == 0) {
    /* ... */
  }
  if (im->clip->count == im->clip->max) {
    more = gdRealloc (im->clip->list,(im->clip->max + 8) *
                      sizeof (gdClipRectangle));
    if (more == 0) return;
    im->clip->max += 8;
    im->clip->list = more;
  }
  im->clip->list[im->clip->count] = *rect;
  im->clip->count++;

}
```

## Risk Assessment

Reading memory that has already been freed can lead to abnormal program termination and denial-of-service attacks. Writing memory that has already been freed can additionally lead to the execution of arbitrary code with the permissions of the vulnerable process.

Freeing memory multiple times has similar consequences to accessing memory after it is freed. Reading a pointer to deallocated memory is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) because the pointer value is [indeterminate](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue) and might be a [trap representation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-traprepresentation). When reading from or writing to freed memory does not cause a trap, it may corrupt the underlying data structures that manage the heap in a manner that can be exploited to execute arbitrary code. Alternatively, writing to memory after it has been freed might modify memory that has been reallocated.

Programmers should be wary when freeing memory in a loop or conditional statement; if coded incorrectly, these constructs can lead to double-free vulnerabilities. It is also a common error to misuse the `realloc()` function in a manner that results in double-free vulnerabilities. (See [MEM04-C. Beware of zero-length allocations](https://wiki.sei.cmu.edu/confluence/display/c/MEM04-C.+Beware+of+zero-length+allocations).)

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM30-C </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>dangling_pointer_use</strong> </td> <td> Supported Astrée reports all accesses to freed allocated memory. </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-MEM30</strong> </td> <td> Detects memory accesses after its deallocation and double memory deallocations </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>ALLOC.UAF</strong> </td> <td> Use after free </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>USE_AFTER_FREE</strong> </td> <td> Can detect the specific instances where memory is deallocated more than once or read/written to the target of a freed pointer </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF4866, DF4867, DF4868, DF4871, DF4872, DF4873</strong> <strong>C++3339, C++4303, C++4304</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>UFM.DEREF.MIGHT</strong> <strong>UFM.DEREF.MUST</strong> <strong>UFM.FFM.MIGHT</strong> <strong>UFM.FFM.MUST</strong> <strong>UFM.RETURN.MIGHT</strong> <strong>UFM.RETURN.MUST</strong> <strong>UFM.USE.MIGHT</strong> <strong>UFM.USE.MUST</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>51 D, 484 S, 112 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-MEM30-a</strong> </td> <td> Do not use resources that have been freed </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>449, 2434</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule MEM30-C </a> </td> <td> Checks for: Accessing previously freed pointerccessing previously freed pointer, freeing previously freed pointerreeing previously freed pointer. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2731, 2732, 2733</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3339, 4303, 4304 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.22 </td> <td> <strong>V586<a></a></strong> , <strong><a>V774</a></strong> </td> <td> </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>dangling_pointer</strong> </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

[VU\#623332](http://www.kb.cert.org/vuls/id/623332) describes a double-free vulnerability in the MIT Kerberos 5 function [krb5_recvauth()](http://web.mit.edu/kerberos/www/advisories/MITKRB5-SA-2005-003-recvauth.txt).

Search for [vulnerabilities](https://www.securecoding.cert.org/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ARR32-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MEM01-C. Store a new value in pointers immediately after free() </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> MEM50-CPP. Do not access freed memory </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Dangling References to Stack Frames \[DCM\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Dangling Reference to Heap \[XYK\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Accessing freed memory \[accfree\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Freeing memory multiple times \[dblfree\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 18.6 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-416 </a> , Use After Free </td> <td> 2017-07-07: CERT: Exact </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-672 </a> </td> <td> 2017-07-07: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-672 and MEM30-C**

Intersection( MEM30-C, FIO46-C) = Ø CWE-672 = Union( MEM30-C, list) where list =

* Use of a resource, other than memory after it has been released (eg: reusing a closed file, or expired mutex)
**CWE-666 and MEM30-C**

Intersection( MEM30-C, FIO46-C) = Ø

CWE-672 = Subset( CWE-666)

**CWE-758 and MEM30-C**

CWE-758 = Union( MEM30-C, list) where list =

* Undefined behavior that is not covered by use-after-free errors
**CWE-415 and MEM30-C**

MEM30-C = Union( CWE-456, list) where list =

* Dereference of a pointer after freeing it (besides passing it to free() a second time)

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.22.3, "Memory Management Functions" </td> </tr> <tr> <td> \[ <a> Kernighan 1988 </a> \] </td> <td> Section 7.8.5, "Storage Management" </td> </tr> <tr> <td> \[ <a> OWASP Freed Memory </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> MIT 2005 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Seacord 2013b </a> \] </td> <td> Chapter 4, "Dynamic Memory Management" </td> </tr> <tr> <td> \[ <a> Viega 2005 </a> \] </td> <td> Section 5.2.19, "Using Freed Memory" </td> </tr> <tr> <td> \[ <a> VU\#623332 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> xorl 2009 </a> \] </td> <td> <a> CVE-2009-1364: LibWMF Pointer Use after free() </a> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [MEM30-C: Do not access freed memory](https://wiki.sei.cmu.edu/confluence/display/c)
