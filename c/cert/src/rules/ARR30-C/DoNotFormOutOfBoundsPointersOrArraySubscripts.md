# ARR30-C: Do not form or use out-of-bounds pointers or array subscripts

This query implements the CERT-C rule ARR30-C:

> Do not form or use out-of-bounds pointers or array subscripts


## Description

The C Standard identifies the following distinct situations in which undefined behavior (UB) can arise as a result of invalid pointer operations:

<table> <tbody> <tr> <th> UB </th> <th> Description </th> <th> Example Code </th> </tr> <tr> <td> <a> 46 </a> </td> <td> Addition or subtraction of a pointer into, or just beyond, an array object and an integer type produces a result that does not point into, or just beyond, the same array object. </td> <td> <a> Forming Out-of-Bounds Pointer </a> , <a> Null Pointer Arithmetic </a> </td> </tr> <tr> <td> <a> 47 </a> </td> <td> Addition or subtraction of a pointer into, or just beyond, an array object and an integer type produces a result that points just beyond the array object and is used as the operand of a unary <code>\*</code> operator that is evaluated. </td> <td> <a> Dereferencing Past the End Pointer </a> , <a> Using Past the End Index </a> </td> </tr> <tr> <td> <a> 49 </a> </td> <td> An array subscript is out of range, even if an object is apparently accessible with the given subscript, for example, in the lvalue expression <code>a\[1\]\[7\]</code> given the declaration <code>int a\[4\]\[5\]</code> ). </td> <td> <a> Apparently Accessible Out-of-Range Index </a> </td> </tr> <tr> <td> <a> 62 </a> </td> <td> An attempt is made to access, or generate a pointer to just past, a flexible array member of a structure when the referenced object provides no elements for that array. </td> <td> <a> Pointer Past Flexible Array Member </a> </td> </tr> </tbody> </table>


## Noncompliant Code Example (Forming Out-of-Bounds Pointer)

In this noncompliant code example, the function `f()` attempts to validate the `index` before using it as an offset to the statically allocated `table` of integers. However, the function fails to reject negative `index` values. When `index` is less than zero, the behavior of the addition expression in the return statement of the function is [undefined behavior 46](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_46). On some implementations, the addition alone can trigger a hardware trap. On other implementations, the addition may produce a result that when dereferenced triggers a hardware trap. Other implementations still may produce a dereferenceable pointer that points to an object distinct from `table`. Using such a pointer to access the object may lead to information exposure or cause the wrong object to be modified.

```cpp
enum { TABLESIZE = 100 };

static int table[TABLESIZE];

int *f(int index) {
  if (index < TABLESIZE) {
    return table + index;
  }
  return NULL;
}

```

## Compliant Solution

One compliant solution is to detect and reject invalid values of `index` if using them in pointer arithmetic would result in an invalid pointer:

```cpp
enum { TABLESIZE = 100 };

static int table[TABLESIZE];

int *f(int index) {
  if (index >= 0 && index < TABLESIZE) {
    return table + index;
  }
  return NULL;
}

```

## Compliant Solution

Another slightly simpler and potentially more efficient compliant solution is to use an unsigned type to avoid having to check for negative values while still rejecting out-of-bounds positive values of `index`:

```cpp
#include <stddef.h>
 
enum { TABLESIZE = 100 };

static int table[TABLESIZE];

int *f(size_t index) {
  if (index < TABLESIZE) {
    return table + index;
  }
  return NULL;
}

```

## Noncompliant Code Example (Dereferencing Past-the-End Pointer)

This noncompliant code example shows the flawed logic in the Windows Distributed Component Object Model (DCOM) Remote Procedure Call (RPC) interface that was exploited by the W32.Blaster.Worm. The error is that the `while` loop in the `GetMachineName()` function (used to extract the host name from a longer string) is not sufficiently bounded. When the character array pointed to by `pwszTemp` does not contain the backslash character among the first `MAX_COMPUTERNAME_LENGTH_FQDN + 1` elements, the final valid iteration of the loop will dereference past the end pointer, resulting in exploitable [undefined behavior 47](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_47). In this case, the actual exploit allowed the attacker to inject executable code into a running program. Economic damage from the Blaster worm has been estimated to be at least $525 million \[[Pethia 2003](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Pethia03)\].

For a discussion of this programming error in the Common Weakness Enumeration database, see [CWE-119](http://cwe.mitre.org/data/definitions/119.html), "Improper Restriction of Operations within the Bounds of a Memory Buffer," and [CWE-121](http://cwe.mitre.org/data/definitions/121.html), "Stack-based Buffer Overflow" \[[MITRE 2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-MITRE)\].

```cpp
error_status_t _RemoteActivation(
      /* ... */, WCHAR *pwszObjectName, ... ) {
   *phr = GetServerPath(
              pwszObjectName, &pwszObjectName);
    /* ... */
}

HRESULT GetServerPath(
  WCHAR *pwszPath, WCHAR **pwszServerPath ){
  WCHAR *pwszFinalPath = pwszPath;
  WCHAR wszMachineName[MAX_COMPUTERNAME_LENGTH_FQDN+1];
  hr = GetMachineName(pwszPath, wszMachineName);
  *pwszServerPath = pwszFinalPath;
}

HRESULT GetMachineName(
  WCHAR *pwszPath,
  WCHAR wszMachineName[MAX_COMPUTERNAME_LENGTH_FQDN+1])
{
  pwszServerName = wszMachineName;
  LPWSTR pwszTemp = pwszPath + 2;
  while (*pwszTemp != L'\\')
    *pwszServerName++ = *pwszTemp++;
  /* ... */
}

```

## Compliant Solution

In this compliant solution, the `while` loop in the `GetMachineName()` function is bounded so that the loop terminates when a backslash character is found, the null-termination character (`L'\0'`) is discovered, or the end of the buffer is reached. Or, as coded, the while loop continues as long as each character is neither a backslash nor a null character and is not at the end of the buffer. This code does not result in a buffer overflow even if no backslash character is found in `wszMachineName`.

```cpp
HRESULT GetMachineName(
  wchar_t *pwszPath,
  wchar_t wszMachineName[MAX_COMPUTERNAME_LENGTH_FQDN+1])
{
  wchar_t *pwszServerName = wszMachineName;
  wchar_t *pwszTemp = pwszPath + 2;
  wchar_t *end_addr
    = pwszServerName + MAX_COMPUTERNAME_LENGTH_FQDN;
  while ((*pwszTemp != L'\\') &&
         (*pwszTemp != L'\0') &&
         (pwszServerName < end_addr))
  {
    *pwszServerName++ = *pwszTemp++;
  }

  /* ... */
}

```
This compliant solution is for illustrative purposes and is not necessarily the solution implemented by Microsoft. This particular solution may not be correct because there is no guarantee that a backslash is found.

## Noncompliant Code Example (Using Past-the-End Index)

Similar to the [dereferencing-past-the-end-pointer](https://wiki.sei.cmu.edu/confluence/display/c/ARR30-C.+Do+not+form+or+use+out-of-bounds+pointers+or+array+subscripts#ARR30C.Donotformoruseoutofboundspointersorarraysubscripts-DereferencingPasttheEndPointer) error, the function `insert_in_table()` in this noncompliant code example uses an otherwise valid index to attempt to store a value in an element just past the end of an array.

First, the function incorrectly validates the index `pos` against the size of the buffer. When `pos` is initially equal to `size`, the function attempts to store `value` in a memory location just past the end of the buffer.

Second, when the index is greater than `size`, the function modifies `size` before growing the size of the buffer. If the call to `realloc()` fails to increase the size of the buffer, the next call to the function with a value of `pos` equal to or greater than the original value of `size` will again attempt to store `value` in a memory location just past the end of the buffer or beyond.

Third, the function violates [INT30-C. Ensure that unsigned integer operations do not wrap](https://wiki.sei.cmu.edu/confluence/display/c/INT30-C.+Ensure+that+unsigned+integer+operations+do+not+wrap), which could lead to wrapping when 1 is added to `pos` or when `size` is multiplied by the size of `int`.

For a discussion of this programming error in the Common Weakness Enumeration database, see [CWE-122](http://cwe.mitre.org/data/definitions/122.html), "Heap-based Buffer Overflow," and [CWE-129](http://cwe.mitre.org/data/definitions/129.html), "Improper Validation of Array Index" \[[MITRE 2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-MITRE)\].

```cpp
#include <stdlib.h>
 
static int *table = NULL;
static size_t size = 0;

int insert_in_table(size_t pos, int value) {
  if (size < pos) {
    int *tmp;
    size = pos + 1;
    tmp = (int *)realloc(table, sizeof(*table) * size);
    if (tmp == NULL) {
      return -1;   /* Failure */
    }
    table = tmp;
  }

  table[pos] = value;
  return 0;
}

```

## Compliant Solution

This compliant solution correctly validates the index `pos` by using the `<=` relational operator, ensures the multiplication will not overflow, and avoids modifying `size` until it has verified that the call to `realloc()` was successful:

```cpp
#include <stdint.h>
#include <stdlib.h>
 
static int *table = NULL;
static size_t size = 0;

int insert_in_table(size_t pos, int value) {
  if (size <= pos) {
    if ((SIZE_MAX - 1 < pos) ||
        ((pos + 1) > SIZE_MAX / sizeof(*table))) {
      return -1;
    }
 
    int *tmp = (int *)realloc(table, sizeof(*table) * (pos + 1));
    if (tmp == NULL) {
      return -1;
    }
    /* Modify size only after realloc() succeeds */
    size  = pos + 1;
    table = tmp;
  }

  table[pos] = value;
  return 0;
}

```

## Noncompliant Code Example (Apparently Accessible Out-of-Range Index)

This noncompliant code example declares `matrix` to consist of 7 rows and 5 columns in row-major order. The function `init_matrix` iterates over all 35 elements in an attempt to initialize each to the value given by the function argument `x`. However, because multidimensional arrays are declared in C in row-major order, the function iterates over the elements in column-major order, and when the value of `j` reaches the value `COLS` during the first iteration of the outer loop, the function attempts to access element `matrix[0][5]`. Because the type of `matrix` is `int[7][5]`, the `j` subscript is out of range, and the access has [undefined behavior 49](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_49).

```cpp
#include <stddef.h>
#define COLS 5
#define ROWS 7
static int matrix[ROWS][COLS];

void init_matrix(int x) {
  for (size_t i = 0; i < COLS; i++) {
    for (size_t j = 0; j < ROWS; j++) {
      matrix[i][j] = x;
    }
  }
}

```

## Compliant Solution

This compliant solution avoids using out-of-range indices by initializing `matrix` elements in the same row-major order as multidimensional objects are declared in C:

```cpp
#include <stddef.h>
#define COLS 5
#define ROWS 7
static int matrix[ROWS][COLS];

void init_matrix(int x) {
  for (size_t i = 0; i < ROWS; i++) {
    for (size_t j = 0; j < COLS; j++) {
      matrix[i][j] = x;
    }
  }
}

```

## Noncompliant Code Example (Pointer Past Flexible Array Member)

In this noncompliant code example, the function `find()` attempts to iterate over the elements of the flexible array member `buf`, starting with the second element. However, because function `g()` does not allocate any storage for the member, the expression `first++` in `find()` attempts to form a pointer just past the end of `buf` when there are no elements. This attempt is [undefined behavior 62](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_62). (See [MSC21-C. Use robust loop termination conditions](https://wiki.sei.cmu.edu/confluence/display/c/MSC21-C.+Use+robust+loop+termination+conditions) for more information.)

```cpp
#include <stdlib.h>
 
struct S {
  size_t len;
  char buf[];  /* Flexible array member */
};

const char *find(const struct S *s, int c) {
  const char *first = s->buf;
  const char *last  = s->buf + s->len;

  while (first++ != last) { /* Undefined behavior */
    if (*first == (unsigned char)c) {
      return first;
    }
  }
  return NULL;
}
 
void g(void) {
  struct S *s = (struct S *)malloc(sizeof(struct S));
  if (s == NULL) {
    /* Handle error */
  }
  s->len = 0;
  find(s, 'a');
}
```

## Compliant Solution

This compliant solution avoids incrementing the pointer unless a value past the pointer's current value is known to exist:

```cpp
#include <stdlib.h>
 
struct S {
  size_t len;
  char buf[];  /* Flexible array member */
};

const char *find(const struct S *s, int c) {
  const char *first = s->buf;
  const char *last  = s->buf + s->len;

  while (first != last) { /* Avoid incrementing here */
    if (*++first == (unsigned char)c) {
      return first;
    }
  }
  return NULL;
}
 
void g(void) {
  struct S *s = (struct S *)malloc(sizeof(struct S));
  if (s == NULL) {
    /* Handle error */
  }
  s->len = 0;
  find(s, 'a');
}
```

## Noncompliant Code Example (Null Pointer Arithmetic)

This noncompliant code example is similar to an [Adobe Flash Player vulnerability](http://www.iss.net/threats/289.html) that was first exploited in 2008. This code allocates a block of memory and initializes it with some data. The data does not belong at the beginning of the block, which is left uninitialized. Instead, it is placed `offset` bytes within the block. The function ensures that the data fits within the allocated block.

```cpp
#include <string.h>
#include <stdlib.h>

char *init_block(size_t block_size, size_t offset,
                 char *data, size_t data_size) {
  char *buffer = malloc(block_size);
  if (data_size > block_size || block_size - data_size < offset) {
    /* Data won't fit in buffer, handle error */
  }
  memcpy(buffer + offset, data, data_size);
  return buffer;
}
```
This function fails to check if the allocation succeeds, which is a violation of [ERR33-C. Detect and handle standard library errors](https://wiki.sei.cmu.edu/confluence/display/c/ERR33-C.+Detect+and+handle+standard+library+errors). If the allocation fails, then `malloc()` returns a null pointer. The null pointer is added to `offset` and passed as the destination argument to `memcpy()`. Because a null pointer does not point to a valid object, the result of the pointer arithmetic is [undefined behavior 46](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_46).

An attacker who can supply the arguments to this function can exploit it to execute arbitrary code. This can be accomplished by providing an overly large value for `block_size`, which causes `malloc()` to fail and return a null pointer. The `offset` argument will then serve as the destination address to the call to `memcpy()`. The attacker can specify the `data` and `data_size` arguments to provide the address and length of the address, respectively, that the attacker wishes to write into the memory referenced by `offset`. The overall result is that the call to `memcpy()` can be exploited by an attacker to overwrite an arbitrary memory location with an attacker-supplied address, typically resulting in arbitrary code execution.

## Compliant Solution  (Null Pointer Arithmetic)

This compliant solution ensures that the call to `malloc()` succeeds:

```cpp
#include <string.h>
#include <stdlib.h>

char *init_block(size_t block_size, size_t offset,
                 char *data, size_t data_size) {
  char *buffer = malloc(block_size);
  if (NULL == buffer) {
    /* Handle error */
  }
  if (data_size > block_size || block_size - data_size < offset) {
    /* Data won't fit in buffer, handle error */
  }
  memcpy(buffer + offset, data, data_size);
  return buffer;
}

```

## Risk Assessment

Writing to out-of-range pointers or array subscripts can result in a buffer overflow and the execution of arbitrary code with the permissions of the vulnerable process. Reading from out-of-range pointers or array subscripts can result in unintended information disclosure.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ARR30-C </td> <td> High </td> <td> Likely </td> <td> High </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>array-index-rangearray-index-range-constantnull-dereferencingpointered-deallocation</strong> <strong>return-reference-local</strong> </td> <td> Partially checked Can detect all accesses to invalid pointers as well as array index out-of-bounds accesses and prove their absence. This rule is only partially checked as invalid but unused pointers may not be reported. </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-ARR30</strong> </td> <td> Can detect out-of-bound access to array / buffer </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.3p0 </td> <td> <strong>LANG.MEM.BO</strong> <strong>LANG.MEM.BU</strong> <strong>LANG.MEM.TBA</strong> <strong>LANG.MEM.TO</strong> <strong>LANG.MEM.TULANG.STRUCT.PARITH</strong> <strong>LANG.STRUCT.PBB</strong> <strong>LANG.STRUCT.PPE</strong> <strong>BADFUNC.BO.\*</strong> </td> <td> Buffer overrun Buffer underrun Tainted buffer access Type overrun Type underrun Pointer Arithmetic Pointer before beginning of object Pointer past end of object A collection of warning classes that report uses of library functions prone to internal buffer overflows. </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Could be configured to catch violations of this rule. The way to catch the noncompliant code example is to first hunt for example code that follows this pattern: <code> for (LPWSTR pwszTemp = pwszPath + 2; \*pwszTemp != L'\\\\'; \*pwszTemp++;) </code> In particular, the iteration variable is a pointer, it gets incremented, and the loop condition does not set an upper bound on the pointer. Once this case is handled, ROSE can handle cases like the real noncompliant code example, which is effectively the same semantics, just different syntax </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>OVERRUN</strong> <strong>NEGATIVE_RETURNS</strong> <strong>ARRAY_VS_SINGLETON</strong> <strong>BUFFER_SIZE</strong> </td> <td> Can detect the access of memory past the end of a memory buffer/array Can detect when the loop bound may become negative Can detect the out-of-bound read/write to array allocated statically or dynamically Can detect buffer overflows </td> </tr> <tr> <td> <a> Cppcheck </a> </td> <td> 1.66 </td> <td> <strong>arrayIndexOutOfBounds, outOfBounds, negativeIndex, arrayIndexThenCheck, arrayIndexOutOfBoundsCond, possibleBufferAccessOutOfBounds</strong> </td> <td> Context sensitive analysis of array index, pointers, etc. Array index out of bounds Buffer overflow when calling various functions memset,strcpy,.. Warns about condition (a\[i\] == 0 &amp;&amp; i &lt; unknown_value) and recommends that (i &lt; unknown_value &amp;&amp; a\[i\] == 0) is used instead Detects unsafe code when array is accessed before/after it is tested if the array index is out of bounds </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2023.1 </td> <td> <strong>C2840</strong> <strong>DF2820, DF2821, DF2822, DF2823, DF2840, DF2841, DF2842, DF2843, DF2930, DF2931, DF2932, DF2933, DF2935, DF2936, DF2937, DF2938, DF2950, DF2951, DF2952, DF2953</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2023.1 </td> <td> <strong>ABV.GENERAL</strong> <strong>ABV.GENERAL.MULTIDIMENSION</strong> <strong>NPD.FUNC.CALL.MIGHT</strong> <strong>ABV.ANY_SIZE_ARRAY</strong> <strong>ABV.STACK</strong> <strong>ABV.TAINTED</strong> <strong>ABV.UNICODE.BOUND_MAP</strong> <strong>ABV.UNICODE.FAILED_MAP</strong> <strong>ABV.UNICODE.NNTS_MAP</strong> <strong>ABV.UNICODE.SELF_MAP</strong> <strong>ABV.UNKNOWN_SIZE</strong> <strong>NNTS.MIGHT</strong> <strong>NNTS.MUST</strong> <strong>NNTS.TAINTED</strong> <strong>SV.TAINTED.INDEX_ACCESS</strong> <strong>SV.TAINTED.LOOP_BOUND</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>45 D, 47 S, 476 S, 489 S, 64 X, 66 X, 68 X, 69 X, 70 X, 71 X</strong> <strong>, 79 X</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-ARR30-a</strong> </td> <td> Avoid accessing arrays out of bounds </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>413, 415, 416, 613, 661, 662, 676</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule ARR30-C </a> </td> <td> Checks for: Array access out of boundsrray access out of bounds, pointer access out of boundsointer access out of bounds, array access with tainted indexrray access with tainted index, use of tainted pointerse of tainted pointer, pointer dereference with tainted offsetointer dereference with tainted offset. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2820, 2821, 2822, 2823, 2840, 2841, 2842, 2843, 2930, 2931, 2932, 2933, 2935, 2936, 2937, 2938, 2950, 2951, 2952, 2953</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2820, 2821, 2822, 2823, 2840, 2841, 2842, 2843, 2930, 2931, 2932, 2933, 2935, 2936, 2937, 2938, 2950, 2951, 2952, 2953</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.24 </td> <td> <strong>V512<a></a></strong> , <strong>V557<a></a></strong> , <strong>V582<a></a></strong> , <strong>V594<a></a></strong> , <strong>V643<a></a></strong> , <strong>V645<a></a></strong> , <strong><a>V694</a>, </strong> <strong>V1086<a></a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>array-index-range-constantreturn-reference-local</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>index_in_address</strong> </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

[CVE-2008-1517](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2008-1517) results from a violation of this rule. Before Mac OSX version 10.5.7, the XNU kernel accessed an array at an unverified user-input index, allowing an attacker to execute arbitrary code by passing an index greater than the length of the array and therefore accessing outside memory \[[xorl 2009](http://xorl.wordpress.com/2009/06/09/cve-2008-1517-apple-mac-os-x-xnu-missing-array-index-validation/)\].

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ARR30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Arithmetic Wrap-Around Error \[FIF\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Unchecked Array Indexing \[XYZ\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Forming or using out-of-bounds pointers or array subscripts \[invptr\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-119 </a> , Improper Restriction of Operations within the Bounds of a Memory Buffer </td> <td> 2017-05-18: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-123 </a> , Write-what-where Condition </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-125 </a> , Out-of-bounds Read </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 18.1 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-119 and ARR30-C**

Independent( ARR30-C, ARR38-C, ARR32-C, INT30-C, INT31-C, EXP39-C, EXP33-C, FIO37-C)

STR31-C = Subset( Union( ARR30-C, ARR38-C))

STR32-C = Subset( ARR38-C)

CWE-119 = Union( ARR30-C, ARR38-C)

Intersection( ARR30-C, ARR38-C) = Ø

**CWE-394 and ARR30-C**

Intersection( ARR30-C, CWE-394) = Ø

CWE-394 deals with potentially-invalid function return values. Which may be used as an (invalid) array index, but validating the return value is a separate operation.

**CWE-125 and ARR30-C**

Independent( ARR30-C, ARR38-C, EXP39-C, INT30-C)

STR31-C = Subset( Union( ARR30-C, ARR38-C))

STR32-C = Subset( ARR38-C)

CWE-125 = Subset( CWE-119) = Union( ARR30-C, ARR38-C)

Intersection( ARR30-C, CWE-125) =

* Reading from an out-of-bounds array index, or off the end of an array
ARR30-C – CWE-125 =
* Writing to an out-of-bounds array index, or off the end of an array
CWE-125 – ARR30-C =
* Reading beyond a non-array buffer
* Using a library function to achieve an out-of-bounds read.
**CWE-123 and ARR30-C**

Independent(ARR30-C, ARR38-C)

STR31-C = Subset( Union( ARR30-C, ARR38-C))

STR32-C = Subset( ARR38-C)

Intersection( CWE-123, ARR30-C) =

* Write of arbitrary value to arbitrary (probably invalid) array index
ARR30-C – CWE-123 =
* Read of value from arbitrary (probably invalid) array index
* Construction of invalid index (pointer arithmetic)
CWE-123 – ARR30-C =
* Arbitrary writes that do not involve directly constructing an invalid array index
**CWE-129 and ARR30-C**

Independent( ARR30-C, ARR32-C, INT31-C, INT32-C)

ARR30-C = Union( CWE-129, list), where list =

* Dereferencing an out-of-bounds array index, where index is a trusted value
* Forming an out-of-bounds array index, without dereferencing it, whether or not index is a trusted value. (This excludes the array’s TOOFAR index, which is one past the final element; this behavior is well-defined in C11.)
**CWE-120 and ARR30-C**

See CWE-120 and MEM35-C

**CWE-122 and ARR30-C**

Intersection( ARR30-C, CWE-122) = Ø

CWE-122 specifically addresses buffer overflows on the heap operations, which occur in the context of string-copying. ARR30 specifically addresses improper creation or references of array indices. Which might happen as part of a heap buffer overflow, but is on a lower programming level.

**CWE-20 and ARR30-C**

See CWE-20 and ERR34-C

**CWE-687 and ARR30-C**

Intersection( CWE-687, ARR30-C) = Ø

ARR30-C is about invalid array indices which are created through pointer arithmetic, and dereferenced through an operator (\* or \[\]). Neither involve function calls, thus CWE-687 does not apply.

**CWE-786 and ARR30-C**

ARR30-C = Union( CWE-786, list) where list =

* Access of memory location after end of buffer
* Construction of invalid arry reference (pointer). This does not include an out-of-bounds array index (an integer).
**CWE-789 and ARR30-C**

Intersection( CWE-789, ARR30-C) = Ø

CWE-789 is about allocating memory, not array subscripting

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Finlay 2003 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Microsoft 2003 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Pethia 2003 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Seacord 2013b </a> \] </td> <td> Chapter 1, "Running with Scissors" </td> </tr> <tr> <td> \[ <a> Viega 2005 </a> \] </td> <td> Section 5.2.13, "Unchecked Array Indexing" </td> </tr> <tr> <td> \[ <a> xorl 2009 </a> \] </td> <td> <a> "CVE-2008-1517: Apple Mac OS X (XNU) Missing Array Index Validation" </a> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ARR30-C: Do not form or use out-of-bounds pointers or array subscripts](https://wiki.sei.cmu.edu/confluence/display/c)
