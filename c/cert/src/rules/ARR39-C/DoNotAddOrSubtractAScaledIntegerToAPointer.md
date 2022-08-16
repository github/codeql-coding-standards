# ARR39-C: Do not add or subtract a scaled integer to a pointer

This query implements the CERT-C rule ARR39-C:

> Do not add or subtract a scaled integer to a pointer


## Description

Pointer arithmetic is appropriate only when the pointer argument refers to an array (see [ARR37-C. Do not add or subtract an integer to a pointer to a non-array object](https://wiki.sei.cmu.edu/confluence/display/c/ARR37-C.+Do+not+add+or+subtract+an+integer+to+a+pointer+to+a+non-array+object)), including an array of bytes. When performing pointer arithmetic, the size of the value to add to or subtract from a pointer is automatically scaled to the size of the type of the referenced array object. Adding or subtracting a scaled integer value to or from a pointer is invalid because it may yield a pointer that does not point to an element within or one past the end of the array. (See [ARR30-C. Do not form or use out-of-bounds pointers or array subscripts](https://wiki.sei.cmu.edu/confluence/display/c/ARR30-C.+Do+not+form+or+use+out-of-bounds+pointers+or+array+subscripts).)

Adding a pointer to an array of a type other than character to the result of the `sizeof` operator or `offsetof` macro, which returns a size and an offset, respectively, violates this rule. However, adding an array pointer to the number of array elements, for example, by using the `arr[sizeof(arr)/sizeof(arr[0])])` idiom, is allowed provided that `arr` refers to an array and not a pointer.

## Noncompliant Code Example

In this noncompliant code example, `sizeof(buf)` is added to the array `buf`. This example is noncompliant because `sizeof(buf)` is scaled by `int` and then scaled again when added to `buf`.

```cpp
enum { INTBUFSIZE = 80 };

extern int getdata(void);
int buf[INTBUFSIZE];
 
void func(void) {
  int *buf_ptr = buf;

  while (buf_ptr < (buf + sizeof(buf))) {
    *buf_ptr++ = getdata();
  }
}
```

## Compliant Solution

This compliant solution uses an unscaled integer to obtain a pointer to the end of the array:

```cpp
enum { INTBUFSIZE = 80 };

extern int getdata(void);
int buf[INTBUFSIZE];

void func(void) {
  int *buf_ptr = buf;

  while (buf_ptr < (buf + INTBUFSIZE)) {
    *buf_ptr++ = getdata();
  }
}
```

## Noncompliant Code Example

In this noncompliant code example, `skip` is added to the pointer `s`. However, `skip` represents the byte offset of `ull_b` in `struct big`. When added to `s`, `skip` is scaled by the size of `struct big`.

```cpp
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
 
struct big {
  unsigned long long ull_a;
  unsigned long long ull_b;
  unsigned long long ull_c;
  int si_e;
  int si_f;
};

void func(void) {
  size_t skip = offsetof(struct big, ull_b);
  struct big *s = (struct big *)malloc(sizeof(struct big));
  if (s == NULL) {
    /* Handle malloc() error */
  }

  memset(s + skip, 0, sizeof(struct big) - skip);
  /* ... */
  free(s);
  s = NULL;
}
```

## Compliant Solution

This compliant solution uses an `unsigned char *` to calculate the offset instead of using a `struct big *`, which would result in scaled arithmetic:

```cpp
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
 
struct big {
  unsigned long long ull_a;
  unsigned long long ull_b;
  unsigned long long ull_c;
  int si_d;
  int si_e;
};

void func(void) {
  size_t skip = offsetof(struct big, ull_b);
  unsigned char *ptr = (unsigned char *)malloc(
    sizeof(struct big)
  );
  if (ptr == NULL) {
     /* Handle malloc() error */
  }

  memset(ptr + skip, 0, sizeof(struct big) - skip);
  /* ... */
  free(ptr);
  ptr = NULL;
}
```

## Noncompliant Code Example

In this noncompliant code example, `wcslen(error_msg) * sizeof(wchar_t)` bytes are scaled by the size of `wchar_t` when added to `error_msg`:

```cpp
#include <wchar.h>
#include <stdio.h>
 
enum { WCHAR_BUF = 128 };
 
void func(void) {
  wchar_t error_msg[WCHAR_BUF];

  wcscpy(error_msg, L"Error: ");
  fgetws(error_msg + wcslen(error_msg) * sizeof(wchar_t), 
         WCHAR_BUF - 7, stdin);
  /* ... */
}
```

## Compliant Solution

This compliant solution does not scale the length of the string; `wcslen()` returns the number of characters and the addition to `error_msg` is scaled:

```cpp
#include <wchar.h>
#include <stdio.h>

enum { WCHAR_BUF = 128 };
const wchar_t ERROR_PREFIX[7] = L"Error: ";

void func(void) {
  const size_t prefix_len = wcslen(ERROR_PREFIX);
  wchar_t error_msg[WCHAR_BUF];

  wcscpy(error_msg, ERROR_PREFIX);
  fgetws(error_msg + prefix_len,
        WCHAR_BUF - prefix_len, stdin);
  /* ... */
}
```

## Risk Assessment

Failure to understand and properly use pointer arithmetic can allow an attacker to execute arbitrary code.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ARR39-C </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>scaled-pointer-arithmetic </strong> </td> <td> Partially checked Besides direct rule violations, Astrée reports all (resulting) out-of-bound array accesses. </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-ARR39</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.BO</strong> <strong>LANG.MEM.BU</strong> <strong>LANG.MEM.TBA</strong> <strong>LANG.MEM.TO</strong> <strong>LANG.MEM.TULANG.STRUCT.PARITH</strong> <strong>LANG.STRUCT.PBB</strong> <strong>LANG.STRUCT.PPE</strong> <strong>BADFUNC.BO.\*</strong> </td> <td> Buffer overrun Buffer underrun Tainted buffer access Type overrun Type underrun Pointer Arithmetic Pointer before beginning of object Pointer past end of object A collection of warning classes that report uses of library functions prone to internal buffer overflows. </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>BAD_SIZEOF</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4955, C4956, C4957</strong> <strong>C++4955, C++4956, C++4957</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.PTR.ARITH.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>47 S, 489 S, 567 S,64 X, 66 X, 68 X,69 X, 70 X, 71 X</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-ARR39-a</strong> <strong>CERT_C-ARR39-b</strong> <strong>CERT_C-ARR39-c</strong> </td> <td> Avoid accessing arrays out of bounds Pointer arithmetic should not be used Do not add or subtract a scaled integer to a pointer </td> </tr> <tr> <td> Polyspace Bug Finder </td> <td> R2022a </td> <td> <a> CERT C: Rule ARR39-C </a> </td> <td> Checks for: Incorrect pointer scalingncorrect pointer scaling, pointer access out of boundsointer access out of bounds, possible misuse of sizeofossible misuse of sizeof. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong> 4955, 4956, 4957</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4955, 4956, 4957</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>scaled-pointer-arithmetic</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>index_in_address</strong> </td> <td> Exhaustively detects undefined behavior (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP41-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> ARR30-C. Do not form or use out-of-bounds pointers or array subscripts </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> ARR37-C. Do not add or subtract an integer to a pointer to a non-array object </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Pointer Casting and Pointer Type Changes \[HFC\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Pointer Arithmetic \[RVG\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 18.1 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 18.2 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 18.3 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 18.4 (advisory) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-468 </a> , Incorrect Pointer Scaling </td> <td> 2017-07-07: CERT: Exact </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Dowd 2006 </a> \] </td> <td> Chapter 6, "C Language Issues" </td> </tr> <tr> <td> \[ <a> Murenin 07 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ARR39-C: Do not add or subtract a scaled integer to a pointer](https://wiki.sei.cmu.edu/confluence/display/c)
