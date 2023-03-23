# MEM36-C: Do not modify the alignment of objects by calling realloc

This query implements the CERT-C rule MEM36-C:

> Do not modify the alignment of objects by calling realloc


## Description

Do not invoke `realloc()` to modify the size of allocated objects that have stricter alignment requirements than those guaranteed by `malloc()`. Storage allocated by a call to the standard `aligned_alloc()` function, for example, can have stricter than normal alignment requirements. The C standard requires only that a pointer returned by `realloc()` be suitably aligned so that it may be assigned to a pointer to any type of object with a fundamental alignment requirement.

## Noncompliant Code Example

This noncompliant code example returns a pointer to allocated memory that has been aligned to a 4096-byte boundary. If the `resize` argument to the `realloc()` function is larger than the object referenced by `ptr`, then `realloc()` will allocate new memory that is suitably aligned so that it may be assigned to a pointer to any type of object with a fundamental alignment requirement but may not preserve the stricter alignment of the original object.

```cpp
#include <stdlib.h>
 
void func(void) {
  size_t resize = 1024;
  size_t alignment = 1 << 12;
  int *ptr;
  int *ptr1;
  
  if (NULL == (ptr = (int *)aligned_alloc(alignment, sizeof(int)))) {
    /* Handle error */
  }

  if (NULL == (ptr1 = (int *)realloc(ptr, resize))) {
    /* Handle error */
  }
}
```
**Implementation Details**

When compiled with GCC 4.1.2 and run on the x86_64 Red Hat Linux platform, the following code produces the following output:

**CODE**

```cpp
#include <stdlib.h>
#include <stdio.h>

int main(void) {
  size_t  size = 16;
  size_t resize = 1024;
  size_t align = 1 << 12;
  int *ptr;
  int *ptr1;

  if (posix_memalign((void **)&ptr, align , size) != 0) {
    exit(EXIT_FAILURE);
  }

  printf("memory aligned to %zu bytes\n", align);
  printf("ptr = %p\n\n", ptr);

  if ((ptr1 = (int*) realloc((int *)ptr, resize)) == NULL) {
    exit(EXIT_FAILURE);
  }

  puts("After realloc(): \n");
  printf("ptr1 = %p\n", ptr1);

  free(ptr1);
  return 0;
}


```
**OUTPUT**

```cpp
memory aligned to 4096 bytes
ptr = 0x1621b000

After realloc():
ptr1 = 0x1621a010

```
`ptr1` is no longer aligned to 4096 bytes.

## Compliant Solution

This compliant solution allocates `resize` bytes of new memory with the same alignment as the old memory, copies the original memory content, and then frees the old memory. This solution has [implementation-defined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) because it depends on whether extended alignments in excess of `_Alignof (max_align_t)` are supported and the contexts in which they are supported. If not supported, the behavior of this compliant solution is undefined.

```cpp
#include <stdlib.h>
#include <string.h>
 
void func(void) {
  size_t resize = 1024;
  size_t alignment = 1 << 12;
  int *ptr;
  int *ptr1;

  if (NULL == (ptr = (int *)aligned_alloc(alignment,
                                          sizeof(int)))) {
    /* Handle error */
  }

  if (NULL == (ptr1 = (int *)aligned_alloc(alignment,
                                           resize))) {
    /* Handle error */
  }
  
  if (NULL == memcpy(ptr1, ptr, sizeof(int))) {
    /* Handle error */
  }
  
  free(ptr);
}
```

## Compliant Solution (Windows)

Windows defines the `_aligned_malloc()` function to allocate memory on a specified alignment boundary. The `_aligned_realloc()` \[[MSDN](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-MSDN)\] can be used to change the size of this memory. This compliant solution demonstrates one such usage:

```cpp
#include <malloc.h>

void func(void) {
  size_t alignment = 1 << 12;
  int *ptr;
  int *ptr1;

  /* Original allocation */
  if (NULL == (ptr = (int *)_aligned_malloc(sizeof(int),
                                            alignment))) {
    /* Handle error */
}

  /* Reallocation */
  if (NULL == (ptr1 = (int *)_aligned_realloc(ptr, 1024,
                                              alignment))) {
    _aligned_free(ptr);
    /* Handle error */
  }

  _aligned_free(ptr1);
}
```
The `size` and `alignment` arguments for `_aligned_malloc()` are provided in reverse order of the C Standard `aligned_alloc()` function.

## Risk Assessment

Improper alignment can lead to arbitrary memory locations being accessed and written to.

<table> <tbody> <tr> <th> Recommendation </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM36-C </td> <td> Low </td> <td> Probable </td> <td> High </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-MEM36</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>BADFUNC.REALLOC</strong> </td> <td> Use of realloc </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C5027</strong> <strong>C++5034</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>AUTOSAR.STDLIB.MEMORY</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>44 S</strong> </td> <td> Enhanced enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-MEM36-a</strong> </td> <td> Do not modify the alignment of objects by calling realloc() </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule MEM36-C </a> </td> <td> Checks for alignment change after memory allocation (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>5027 </strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>5034</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM36-C).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.22.3.1, "The <code>aligned_alloc</code> Function" </td> </tr> <tr> <td> \[ <a> MSDN </a> \] </td> <td> <code>aligned_malloc()</code> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [MEM36-C: Do not modify the alignment of objects by calling realloc](https://wiki.sei.cmu.edu/confluence/display/c)
