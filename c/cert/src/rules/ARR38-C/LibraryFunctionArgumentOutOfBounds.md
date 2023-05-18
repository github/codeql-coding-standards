# ARR38-C: Guarantee that library functions do not form invalid pointers

This query implements the CERT-C rule ARR38-C:

> Guarantee that library functions do not form invalid pointers


## Description

C library functions that make changes to arrays or objects take at least two arguments: a pointer to the array or object and an integer indicating the number of elements or bytes to be manipulated. For the purposes of this rule, the element count of a pointer is the size of the object to which it points, expressed by the number of elements that are valid to access. Supplying arguments to such a function might cause the function to form a pointer that does not point into or just past the end of the object, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

Annex J of the C Standard \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\] states that it is undefined behavior if the "pointer passed to a library function array parameter does not have a value such that all address computations and object accesses are valid." (See [undefined behavior 109](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_109).)

In the following code,

```cpp
int arr[5];
int *p = arr;

unsigned char *p2 = (unsigned char *)arr;
unsigned char *p3 = arr + 2;
void *p4 = arr;
```
the element count of the pointer `p` is `sizeof(arr) / sizeof(arr[0])`, that is, `5`. The element count of the pointer `p2` is `sizeof(arr)`, that is, `20`, on implementations where `sizeof(int) == 4`. The element count of the pointer `p3` is `12` on implementations where `sizeof(int) == 4`, because `p3` points two elements past the start of the array `arr`. The element count of `p4` is treated as though it were `unsigned char *` instead of `void *`, so it is the same as `p2`.

## Pointer + Integer

The following standard library functions take a pointer argument and a size argument, with the constraint that the pointer must point to a valid memory object of at least the number of elements indicated by the size argument.

<table> <tbody> <tr> <td> <code>fgets()</code> </td> <td> <code>fgetws()</code> </td> <td> <code>mbstowcs()</code> <sup> 1 <code> </code> </sup> </td> <td> <code>wcstombs()</code> <sup> 1 </sup> </td> </tr> <tr> <td> <code>mbrtoc16()</code> <sup> 2 <code> </code> </sup> </td> <td> <code>mbrtoc32()</code> <sup> 2 </sup> </td> <td> <code>mbsrtowcs()</code> <sup> 1 </sup> </td> <td> <code>wcsrtombs()</code> <sup> 1 </sup> </td> </tr> <tr> <td> <code>mbtowc()</code> <sup> 2 <code> </code> </sup> </td> <td> <code>mbrtowc()</code> <sup> 2 </sup> </td> <td> <code>mblen()</code> </td> <td> <code>mbrlen()</code> </td> </tr> <tr> <td> <code>memchr()</code> </td> <td> <code>wmemchr()</code> </td> <td> <code>memset()</code> </td> <td> <code>wmemset()</code> </td> </tr> <tr> <td> <code>strftime()</code> </td> <td> <code>wcsftime()</code> </td> <td> <code>strxfrm()<sup>1</sup></code> </td> <td> <code>wcsxfrm()<sup>1</sup></code> </td> </tr> <tr> <td> <code>strncat()<sup>2</sup></code> </td> <td> <code>wcsncat()<sup>2</sup></code> </td> <td> <code>snprintf()</code> </td> <td> <code>vsnprintf()</code> </td> </tr> <tr> <td> <code>swprintf()</code> </td> <td> <code>vswprintf()</code> </td> <td> <code>setvbuf()</code> </td> <td> <code>tmpnam_s()</code> </td> </tr> <tr> <td> <code>snprintf_s()</code> </td> <td> <code>sprintf_s()</code> </td> <td> <code>vsnprintf_s()</code> </td> <td> <code>vsprintf_s()</code> </td> </tr> <tr> <td> <code>gets_s()</code> </td> <td> <code>getenv_s()</code> </td> <td> <code>wctomb_s()</code> </td> <td> <code>mbstowcs_s()<sup>3</sup></code> </td> </tr> <tr> <td> <code>wcstombs_s()<sup>3</sup></code> </td> <td> <code>memcpy_s()<sup>3</sup></code> </td> <td> <code>memmove_s()<sup>3</sup></code> </td> <td> <code>strncpy_s()<sup>3</sup></code> </td> </tr> <tr> <td> <code>strncat_s()<sup>3</sup></code> </td> <td> <code>strtok_s()<sup>2</sup></code> </td> <td> <code>strerror_s()</code> </td> <td> <code>strnlen_s()</code> </td> </tr> <tr> <td> <code>asctime_s()</code> </td> <td> <code>ctime_s()</code> </td> <td> <code>snwprintf_s()</code> </td> <td> <code>swprintf_s()</code> </td> </tr> <tr> <td> <code>vsnwprintf_s()</code> </td> <td> <code>vswprintf_s()</code> </td> <td> <code>wcsncpy_s()<sup>3</sup></code> </td> <td> <code>wmemcpy_s()<sup>3</sup></code> </td> </tr> <tr> <td> <code>wmemmove_s()<sup>3</sup></code> </td> <td> <code>wcsncat_s()<sup>3</sup></code> </td> <td> <code>wcstok_s()<sup>2</sup></code> </td> <td> <code>wcsnlen_s()</code> </td> </tr> <tr> <td> <code>wcrtomb_s()</code> </td> <td> <code>mbsrtowcs_s()<sup>3</sup></code> </td> <td> <code>wcsrtombs_s()<sup>3</sup></code> </td> <td> <code>memset_s()<sup>4</sup></code> </td> </tr> </tbody> </table>
<sup>1</sup> Takes two pointers and an integer, but the integer specifies the element count only of the output buffer, not of the input buffer.<sup>2</sup> Takes two pointers and an integer, but the integer specifies the element count only of the input buffer, not of the output buffer.<sup>3</sup> Takes two pointers and two integers; each integer corresponds to the element count of one of the pointers.<sup>4</sup> Takes a pointer and two size-related integers; the first size-related integer parameter specifies the number of bytes available in the buffer; the second size-related integer parameter specifies the number of bytes to write within the buffer.


For calls that take a pointer and an integer size, the given size should not be greater than the element count of the pointer.

** Noncompliant Code Example (Element Count)**

In this noncompliant code example, the incorrect element count is used in a call to `wmemcpy()`. The `sizeof` operator returns the size expressed in bytes, but `wmemcpy()` uses an element count based on `wchar_t *`.

```cpp
#include <string.h>
#include <wchar.h>
 
static const char str[] = "Hello world";
static const wchar_t w_str[] = L"Hello world";
void func(void) {
  char buffer[32];
  wchar_t w_buffer[32];
  memcpy(buffer, str, sizeof(str)); /* Compliant */
  wmemcpy(w_buffer, w_str, sizeof(w_str)); /* Noncompliant */
}
```
**Compliant Solution (Element Count)**

When using functions that operate on pointed-to regions, programmers must always express the integer size in terms of the element count expected by the function. For example, `memcpy()` expects the element count expressed in terms of `void *`, but `wmemcpy()` expects the element count expressed in terms of `wchar_t *`. Instead of the `sizeof` operator, functions that return the number of elements in the string are called, which matches the expected element count for the copy functions. In the case of this compliant solution, where the argument is an array `A` of type `T`, the expression `sizeof(A) / sizeof(T)`, or equivalently `sizeof(A) / sizeof(*A)`, can be used to compute the number of elements in the array.

```cpp
#include <string.h>
#include <wchar.h>
 
static const char str[] = "Hello world";
static const wchar_t w_str[] = L"Hello world";
void func(void) {
  char buffer[32];
  wchar_t w_buffer[32];
  memcpy(buffer, str, strlen(str) + 1);
  wmemcpy(w_buffer, w_str, wcslen(w_str) + 1);
} 
```
**Noncompliant Code Example (Pointer + Integer)**

This noncompliant code example assigns a value greater than the number of bytes of available memory to `n`, which is then passed to `memset()`:

```cpp
#include <stdlib.h>
#include <string.h>
 
void f1(size_t nchars) {
  char *p = (char *)malloc(nchars);
  /* ... */
  const size_t n = nchars + 1;
  /* ... */
  memset(p, 0, n);
}

```
**Compliant Solution (Pointer + Integer)**

This compliant solution ensures that the value of `n` is not greater than the number of bytes of the dynamic memory pointed to by the pointer `p`:

```cpp
#include <stdlib.h>
#include <string.h>
 
void f1(size_t nchars) {
  char *p = (char *)malloc(nchars);
  /* ...  */
  const size_t n = nchars;
  /* ...  */
  memset(p, 0, n);
}

```
**Noncompliant Code Example (Pointer + Integer)**

In this noncompliant code example, the element count of the array `a` is `ARR_SIZE` elements. Because `memset()` expects a byte count, the size of the array is scaled incorrectly by `sizeof(int)` instead of `sizeof(long)`, which can form an invalid pointer on architectures where `sizeof(int) != sizeof(long)`.

```cpp
#include <string.h>
 
void f2(void) {
  const size_t ARR_SIZE = 4;
  long a[ARR_SIZE];
  const size_t n = sizeof(int) * ARR_SIZE;
  void *p = a;

  memset(p, 0, n);
}

```
**Compliant Solution (Pointer + Integer)**

In this compliant solution, the element count required by `memset()` is properly calculated without resorting to scaling:

```cpp
#include <string.h>
 
void f2(void) {
  const size_t ARR_SIZE = 4;
  long a[ARR_SIZE];
  const size_t n = sizeof(a);
  void *p = a;

  memset(p, 0, n);
}

```

## Two Pointers + One Integer

The following standard library functions take two pointer arguments and a size argument, with the constraint that both pointers must point to valid memory objects of at least the number of elements indicated by the size argument.

<table> <tbody> <tr> <td> <code><code>memcpy()</code></code> </td> <td> <code>wmemcpy()</code> </td> <td> <code>memmove()</code> </td> <td> <code>wmemmove()</code> </td> </tr> <tr> <td> <code>strncpy()</code> </td> <td> <code>wcsncpy()</code> </td> <td> <code>memcmp()</code> </td> <td> <code>wmemcmp()</code> </td> </tr> <tr> <td> <code>strncmp()</code> </td> <td> <code>wcsncmp()</code> </td> <td> <code>strcpy_s()</code> </td> <td> <code>wcscpy_s()</code> </td> </tr> <tr> <td> <code>strcat_s()</code> </td> <td> <code>wcscat_s()</code> </td> <td> </td> <td> </td> </tr> </tbody> </table>
For calls that take two pointers and an integer size, the given size should not be greater than the element count of either pointer.


**Noncompliant Code Example (Two Pointers + One Integer)**

In this noncompliant code example, the value of `n` is incorrectly computed, allowing a read past the end of the object referenced by `q`:

```cpp
#include <string.h>

void f4() {
  char p[40];
  const char *q = "Too short";
  size_t n = sizeof(p);
  memcpy(p, q, n);
}
```
**Compliant Solution (Two Pointers + One Integer)**

This compliant solution ensures that `n` is equal to the size of the character array:

```cpp
#include <string.h>

void f4() {
  char p[40];
  const char *q = "Too short";
  size_t n = sizeof(p) < strlen(q) + 1 ? sizeof(p) : strlen(q) + 1;
  memcpy(p, q, n);
}
```

## One Pointer + Two Integers

The following standard library functions take a pointer argument and two size arguments, with the constraint that the pointer must point to a valid memory object containing at least as many bytes as the product of the two size arguments.

<table> <tbody> <tr> <td> <code>bsearch()</code> </td> <td> <code>bsearch_s()</code> </td> <td> <code>qsort()</code> </td> <td> <code>qsort_s()</code> </td> </tr> <tr> <td> <code>fread()</code> </td> <td> <code>fwrite()</code> </td> <td> <code> </code> </td> <td> </td> </tr> </tbody> </table>
For calls that take a pointer and two integers, one integer represents the number of bytes required for an individual object, and a second integer represents the number of elements in the array. The resulting product of the two integers should not be greater than the element count of the pointer were it expressed as an `unsigned char *`.


**Noncompliant Code Example (One Pointer + Two Integers)**

This noncompliant code example allocates a variable number of objects of type `struct obj`. The function checks that `num_objs` is small enough to prevent wrapping, in compliance with [INT30-C. Ensure that unsigned integer operations do not wrap](https://wiki.sei.cmu.edu/confluence/display/c/INT30-C.+Ensure+that+unsigned+integer+operations+do+not+wrap). The size of `struct obj` is assumed to be 16 bytes to account for padding to achieve the assumed alignment of `long long`. However, the padding typically depends on the target architecture, so this object size may be incorrect, resulting in an incorrect element count.

```cpp
#include <stdint.h>
#include <stdio.h>
 
struct obj {
  char c;
  long long i;
};
 
void func(FILE *f, struct obj *objs, size_t num_objs) {
  const size_t obj_size = 16;
  if (num_objs > (SIZE_MAX / obj_size) ||
      num_objs != fwrite(objs, obj_size, num_objs, f)) {
    /* Handle error */
  }
}
```
**Compliant Solution (One Pointer + Two Integers)**

This compliant solution uses the `sizeof` operator to correctly provide the object size and `num_objs` to provide the element count:

```cpp
#include <stdint.h>
#include <stdio.h>
 
struct obj {
  char c;
  long long i;
};
 
void func(FILE *f, struct obj *objs, size_t num_objs) {
  const size_t obj_size = sizeof *objs;
  if (num_objs > (SIZE_MAX / obj_size) ||
      num_objs != fwrite(objs, obj_size, num_objs, f)) {
    /* Handle error */
  }
}
```
**Noncompliant Code Example (One Pointer + Two Integers)**

In this noncompliant code example, the function `f()` calls `fread()` to read `nitems` of type `wchar_t`, each `size` bytes in size, into an array of `BUFFER_SIZE` elements, `wbuf`. However, the expression used to compute the value of `nitems` fails to account for the fact that, unlike the size of `char`, the size of `wchar_t` may be greater than 1. Consequently, `fread()` could attempt to form pointers past the end of `wbuf` and use them to assign values to nonexistent elements of the array. Such an attempt is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 109](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_109).) A likely consequence of this undefined behavior is a buffer overflow. For a discussion of this programming error in the Common Weakness Enumeration database, see [CWE-121](http://cwe.mitre.org/data/definitions/121.html), "Stack-based Buffer Overflow," and [CWE-805](http://cwe.mitre.org/data/definitions/805.html), "Buffer Access with Incorrect Length Value."

```cpp
#include <stddef.h>
#include <stdio.h>

void f(FILE *file) {
  enum { BUFFER_SIZE = 1024 };
  wchar_t wbuf[BUFFER_SIZE];

  const size_t size = sizeof(*wbuf);
  const size_t nitems = sizeof(wbuf);

  size_t nread = fread(wbuf, size, nitems, file);
  /* ... */
}

```
**Compliant Solution (One Pointer + Two Integers)**

This compliant solution correctly computes the maximum number of items for `fread()` to read from the file:

```cpp
#include <stddef.h>
#include <stdio.h>
 
void f(FILE *file) {
  enum { BUFFER_SIZE = 1024 };
  wchar_t wbuf[BUFFER_SIZE];

  const size_t size = sizeof(*wbuf);
  const size_t nitems = sizeof(wbuf) / size;

  size_t nread = fread(wbuf, size, nitems, file);
  /* ... */
}
```
**Noncompliant Code Example (Heartbleed)**

CERT vulnerability [720951](http://www.kb.cert.org/vuls/id/720951) describes a vulnerability in OpenSSL versions 1.0.1 through 1.0.1f, popularly known as "Heartbleed." This vulnerability allows an attacker to steal information that under normal conditions would be protected by Secure Socket Layer/Transport Layer Security (SSL/TLS) encryption.

Despite the seriousness of the vulnerability, Heartbleed is the result of a common programming error and an apparent lack of awareness of secure coding principles. Following is the vulnerable code:

```cpp
int dtls1_process_heartbeat(SSL *s) {         
  unsigned char *p = &s->s3->rrec.data[0], *pl;
  unsigned short hbtype;
  unsigned int payload;
  unsigned int padding = 16; /* Use minimum padding */
 
  /* Read type and payload length first */
  hbtype = *p++;
  n2s(p, payload);
  pl = p;
 
  /* ... More code ... */
 
  if (hbtype == TLS1_HB_REQUEST) {
    unsigned char *buffer, *bp;
    int r;
 
    /* 
     * Allocate memory for the response; size is 1 byte
     * message type, plus 2 bytes payload length, plus
     * payload, plus padding.
     */
    buffer = OPENSSL_malloc(1 + 2 + payload + padding);
    bp = buffer;
 
    /* Enter response type, length, and copy payload */
    *bp++ = TLS1_HB_RESPONSE;
    s2n(payload, bp);
    memcpy(bp, pl, payload);
 
    /* ... More code ... */
  }
  /* ... More code ... */
}
```
This code processes a "heartbeat" packet from a client. As specified in [RFC 6520](https://tools.ietf.org/html/rfc6520), when the program receives a heartbeat packet, it must echo the packet's data back to the client. In addition to the data, the packet contains a length field that conventionally indicates the number of bytes in the packet data, but there is nothing to prevent a malicious packet from lying about its data length.

The `p` pointer, along with `payload` and `p1`, contains data from a packet. The code allocates a `buffer` sufficient to contain `payload` bytes, with some overhead, then copies `payload` bytes starting at `p1` into this buffer and sends it to the client. Notably absent from this code are any checks that the payload integer variable extracted from the heartbeat packet corresponds to the size of the packet data. Because the client can specify an arbitrary value of `payload`, an attacker can cause the server to read and return the contents of memory beyond the end of the packet data, which violates [INT04-C. Enforce limits on integer values originating from tainted sources](https://wiki.sei.cmu.edu/confluence/display/c/INT04-C.+Enforce+limits+on+integer+values+originating+from+tainted+sources). The resulting call to `memcpy()` can then copy the contents of memory past the end of the packet data and the packet itself, potentially exposing sensitive data to the attacker. This call to `memcpy()` violates [ARR38-C. Guarantee that library functions do not form invalid pointers](https://wiki.sei.cmu.edu/confluence/display/c/ARR38-C.+Guarantee+that+library+functions+do+not+form+invalid+pointers). A version of ARR38-C also appears in [ISO/IEC TS 17961:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IECTS17961), "Forming invalid pointers by library functions \[libptr\]." This rule would require a conforming analyzer to diagnose the Heartbleed vulnerability.

**Compliant Solution (Heartbleed)**

OpenSSL version 1.0.1g contains the following patch, which guarantees that `payload` is within a valid range. The range is limited by the size of the input record.

```cpp
int dtls1_process_heartbeat(SSL *s) {         
  unsigned char *p = &s->s3->rrec.data[0], *pl;
  unsigned short hbtype;
  unsigned int payload;
  unsigned int padding = 16; /* Use minimum padding */
 
  /* ... More code ... */
 
  /* Read type and payload length first */
  if (1 + 2 + 16 > s->s3->rrec.length)
    return 0; /* Silently discard */
  hbtype = *p++;
  n2s(p, payload);
  if (1 + 2 + payload + 16 > s->s3->rrec.length)
    return 0; /* Silently discard per RFC 6520 */
  pl = p;
 
  /* ... More code ... */
 
  if (hbtype == TLS1_HB_REQUEST) {
    unsigned char *buffer, *bp;
    int r;
 
    /* 
     * Allocate memory for the response; size is 1 byte
     * message type, plus 2 bytes payload length, plus
     * payload, plus padding.
     */
    buffer = OPENSSL_malloc(1 + 2 + payload + padding);
    bp = buffer;
    /* Enter response type, length, and copy payload */
    *bp++ = TLS1_HB_RESPONSE;
    s2n(payload, bp);
    memcpy(bp, pl, payload);
    /* ... More code ... */
  }
  /* ... More code ... */
}
```

## Risk Assessment

Depending on the library function called, an attacker may be able to use a heap or stack overflow [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) to run arbitrary code.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ARR38-C </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>array_out_of_bounds</strong> </td> <td> Supported Astrée reports all out-of-bound accesses within library analysis stubs. The user may provide additional stubs for arbitrary (library) functions. </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.MEM.BO</strong> <strong>LANG.MEM.BU</strong> <strong>BADFUNC.BO.\*</strong> </td> <td> Buffer overrun Buffer underrun A collection of warning classes that report uses of library functions prone to internal buffer overflows </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>BUFFER_SIZE</strong> <strong>BAD_SIZEOF</strong> <strong>BAD_ALLOC_STRLEN</strong> <strong>BAD_ALLOC_ARITHMETIC</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Fortify SCA </a> </td> <td> 5.0 </td> <td> </td> <td> Can detect violations of this rule with CERT C Rule Pack </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C2840</strong> <strong>DF2840, DF2841, DF2842, DF2843, DF2845, DF2846, DF2847, DF2848, DF2935, DF2936, DF2937, DF2938, DF4880, DF4881, DF4882, DF4883</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>ABV.GENERALABV.GENERAL.MULTIDIMENSION</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>64 X, 66 X, 68 X, 69 X, 70 X, 71 X, 79 X</strong> </td> <td> Partially Implmented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-ARR38-a</strong> <strong>CERT_C-ARR38-b</strong> <strong>CERT_C-ARR38-c</strong> <strong>CERT_C-ARR38-d</strong> </td> <td> Avoid overflow when reading from a buffer Avoid overflow when writing to a buffer Avoid buffer overflow due to defining incorrect format limits Avoid overflow due to reading a not zero terminated string </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>419, 420</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule ARR38-C </a> </td> <td> Checks for: Mismatch between data length and sizeismatch between data length and size, invalid use of standard library memory routinenvalid use of standard library memory routine, possible misuse of sizeofossible misuse of sizeof, buffer overflow from incorrect string format specifieruffer overflow from incorrect string format specifier, invalid use of standard library string routinenvalid use of standard library string routine, destination buffer overflow in string manipulationestination buffer overflow in string manipulation, destination buffer underflow in string manipulationestination buffer underflow in string manipulation. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2840, 2841, 2842, 2843, 2845, 2846, </strong> <strong>2847, 2848, 2935, 2936, 2937, 2938</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2840, 2841, 2842, 2843, 2845, 2846, </strong> <strong>2847, 2848, 2935, 2936, 2937, 2938</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>out of bounds read</strong> </td> <td> Partially verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

[CVE-2016-2208](https://bugs.chromium.org/p/project-zero/issues/detail?id=820) results from a violation of this rule. The attacker can supply a value used to determine how much data is copied into a buffer via `memcpy()`, resulting in a buffer overlow of attacker-controlled data.

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ARR38-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> C Secure Coding Standard </a> </td> <td> <a> API00-C. Functions should validate their parameters </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> C Secure Coding Standard </a> </td> <td> <a> ARR01-C. Do not apply the sizeof operator to a pointer when taking the size of an array </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> C Secure Coding Standard </a> </td> <td> <a> INT30-C. Ensure that unsigned integer operations do not wrap </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Forming invalid pointers by library functions \[libptr\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Buffer Boundary Violation (Buffer Overflow) \[HCB\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Unchecked Array Copying \[XYW\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-119 </a> <a> , </a> Improper Restriction of Operations within the Bounds of a Memory Buffer </td> <td> 2017-05-18: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-121 </a> , Stack-based Buffer Overflow </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-123 </a> , Write-what-where Condition </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-125 </a> , Out-of-bounds Read </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-805 </a> , Buffer Access with Incorrect Length Value </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 3.1 </a> </td> <td> <a> CWE-129 </a> , Improper Validation of Array Index </td> <td> 2017-10-30:MITRE:Unspecified Relationship 2018-10-18:CERT: Partial Overlap </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-121 and ARR38-C**

Intersection( CWE-121, ARR38-C) =

* Stack buffer overflow from passing invalid arguments to library function
CWE-121 – ARR38-C =
* Stack buffer overflows from direct out-of-bounds write
ARR38-C – CWE-121 =
* Out-of-bounds read from passing invalid arguments to library function
* Buffer overflow on heap or data segment from passing invalid arguments to library function
**CWE-119 and ARR38-C**

See CWE-119 and ARR30-C

**CWE-125 and ARR38-C**

Independent( ARR30-C, ARR38-C, EXP39-C, INT30-C)

STR31-C = Subset( Union( ARR30-C, ARR38-C))

STR32-C = Subset( ARR38-C)

Intersection( ARR38-C, CWE-125) =

* Reading from an out-of-bounds array index or off the end of an array via standard library function
ARR38-C – CWE-125 =
* Writing to an out-of-bounds array index or off the end of an array via standard library function
CWE-125 – ARR38-C =
* Reading beyond a non-array buffer
* Reading beyond an array directly (using pointer arithmetic, or \[\] notation)
**CWE-805 and ARR38-C**

Intersection( CWE-805, ARR38-C) =

* Buffer access with incorrect length via passing invalid arguments to library function
CWE-805 – ARR38-C =
* Buffer access with incorrect length directly (such as a loop construct)
ARR38-C – CWE-805 =
* Out-of-bounds read or write that does not involve incorrect length (could use incorrect offset instead), that uses library function
**CWE-123 and ARR38-C**

Independent(ARR30-C, ARR38-C)

STR31-C = Subset( Union( ARR30-C, ARR38-C))

STR32-C = Subset( ARR38-C)

CWE-123 includes any operation that allows an attacker to write an arbitrary value to an arbitrary memory location. This could be accomplished via overwriting a pointer with data that refers to the address to write, then when the program writes to a pointed-to value, supplying a malicious value. Vulnerable pointer values can be corrupted by:

* Stack return address
* Buffer overflow on the heap (which typically overwrites back/next pointer values)
* Write to untrusted array index (if it is also invalid)
* Format string exploit
* Overwriting a C++ object with virtual functions (because it has a virtual pointer)
* Others?
Intersection( CWE-123, ARR38-C) =
* Buffer overflow via passing invalid arguments to library function
ARR38-C – CWE-123 =
* Buffer overflow to “harmless” memory from passing invalid arguments to library function
* Out-of-bounds read from passing invalid arguments to library function
CWE-123 – ARR38-C =
* Arbitrary writes that do not involve standard C library functions
**CWE-129 and ARR38-C**

ARR38-C - CWE-129 = making library functions create invalid pointers without using untrusted data.

E.g. : `char[3] array;`

`strcpy(array, "123456");`

CWE-129 - ARR38-C = not validating an integer used as an array index or in pointer arithmetic

E.g.: `void foo(int i) {`

` char array[3];`

` array[i];`

`}`

Intersection(ARR38-C, CWE-129) = making library functions create invalid pointers using untrusted data.

`eg: void foo(int i) {`

` char src[3], dest[3];`

` memcpy(dest, src, i);`

`}`

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Cassidy 2014 </a> \] </td> <td> <a> Existential Type Crisis : Diagnosis of the OpenSSL Heartbleed Bug </a> </td> </tr> <tr> <td> \[ <a> IETF: RFC 6520 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> ISO/IEC TS 17961:2013 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> VU\#720951 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ARR38-C: Guarantee that library functions do not form invalid pointers](https://wiki.sei.cmu.edu/confluence/display/c)
