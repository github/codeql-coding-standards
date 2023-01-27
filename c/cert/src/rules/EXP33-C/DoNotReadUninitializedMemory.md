# EXP33-C: Do not read uninitialized memory

This query implements the CERT-C rule EXP33-C:

> Do not read uninitialized memory


## Description

Local, automatic variables assume unexpected values if they are read before they are initialized. The C Standard, 6.7.9, paragraph 10, specifies \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\]

> If an object that has automatic storage duration is not initialized explicitly, its value is [indeterminate](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue).


See [undefined behavior 11](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_11).

When local, automatic variables are stored on the program stack, for example, their values default to whichever values are currently stored in stack memory.

Additionally, some dynamic memory allocation functions do not initialize the contents of the memory they allocate.

<table> <tbody> <tr> <th> Function </th> <th> Initialization </th> </tr> <tr> <td> <code>aligned_alloc()</code> </td> <td> Does not perform initialization </td> </tr> <tr> <td> <code>calloc()</code> </td> <td> Zero-initializes allocated memory </td> </tr> <tr> <td> <code>malloc()</code> </td> <td> Does not perform initialization </td> </tr> <tr> <td> <code>realloc()</code> </td> <td> Copies contents from original pointer; may not initialize all memory </td> </tr> </tbody> </table>
Uninitialized automatic variables or dynamically allocated memory has [indeterminate values](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue), which for objects of some types, can be a [trap representation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-traprepresentation). Reading such trap representations is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior); it can cause a program to behave in an [unexpected](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior) manner and provide an avenue for attack. (See [undefined behavior 10](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_10) and [undefined behavior 12](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_12).) In many cases, compilers issue a warning diagnostic message when reading uninitialized variables. (See [MSC00-C. Compile cleanly at high warning levels](https://wiki.sei.cmu.edu/confluence/display/c/MSC00-C.+Compile+cleanly+at+high+warning+levels) for more information.)


## Noncompliant Code Example (Return-by-Reference)

In this noncompliant code example, the `set_flag()` function is intended to set the parameter, `sign_flag`, to the sign of `number`. However, the programmer neglected to account for the case where `number` is equal to `0`. Because the local variable `sign` is uninitialized when calling `set_flag()` and is never written to by `set_flag()`, the comparison operation exhibits [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) when reading `sign`.

```cpp
void set_flag(int number, int *sign_flag) {
  if (NULL == sign_flag) {
    return;
  }

  if (number > 0) {
    *sign_flag = 1;
  } else if (number < 0) {
    *sign_flag = -1;
  }
}

int is_negative(int number) {
  int sign;
  set_flag(number, &sign);
  return sign < 0;
}

```
Some compilers assume that when the address of an uninitialized variable is passed to a function, the variable is initialized within that function. Because compilers frequently fail to diagnose any resulting failure to initialize the variable, the programmer must apply additional scrutiny to ensure the correctness of the code.

This defect results from a failure to consider all possible data states. (See [MSC01-C. Strive for logical completeness](https://wiki.sei.cmu.edu/confluence/display/c/MSC01-C.+Strive+for+logical+completeness) for more information.)

## Compliant Solution (Return-by-Reference)

This compliant solution trivially repairs the problem by accounting for the possibility that `number` can be equal to 0.

Although compilers and [static analysis](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-staticanalysis) tools often detect uses of uninitialized variables when they have access to the source code, diagnosing the problem is difficult or impossible when either the initialization or the use takes place in object code for which the source code is inaccessible. Unless doing so is prohibitive for performance reasons, an additional defense-in-depth practice worth considering is to initialize local variables immediately after declaration.

```cpp
void set_flag(int number, int *sign_flag) {
  if (NULL == sign_flag) {
    return;
  }

  /* Account for number being 0 */
  if (number >= 0) { 
    *sign_flag = 1;
  } else {
    *sign_flag = -1;
  }
}

int is_negative(int number) {
  int sign = 0; /* Initialize for defense-in-depth */
  set_flag(number, &sign);
  return sign < 0;
}

```

## Noncompliant Code Example (Uninitialized Local)

In this noncompliant code example, the programmer mistakenly fails to set the local variable `error_log` to the `msg` argument in the `report_error()` function \[[Mercy 2006](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-mercy06)\]. Because `error_log` has not been initialized, an [indeterminate value](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue) is read. The `sprintf()` call copies data from the arbitrary location pointed to by the indeterminate `error_log` variable until a null byte is reached, which can result in a buffer overflow.

```cpp
#include <stdio.h>

/* Get username and password from user, return -1 on error */
extern int do_auth(void);
enum { BUFFERSIZE = 24 }; 
void report_error(const char *msg) {
  const char *error_log;
  char buffer[BUFFERSIZE];

  sprintf(buffer, "Error: %s", error_log);
  printf("%s\n", buffer);
}

int main(void) {
  if (do_auth() == -1) {
    report_error("Unable to login");
  }
  return 0;
}

```

## Noncompliant Code Example (Uninitialized Local)

In this noncompliant code example, the `report_error()` function has been modified so that `error_log` is properly initialized:

```cpp
#include <stdio.h>
enum { BUFFERSIZE = 24 }; 
void report_error(const char *msg) {
  const char *error_log = msg;
  char buffer[BUFFERSIZE];

  sprintf(buffer, "Error: %s", error_log);
  printf("%s\n", buffer);
}

```
This example remains problematic because a buffer overflow will occur if the null-terminated byte string referenced by `msg` is greater than 17 characters, including the null terminator. (See [STR31-C. Guarantee that storage for strings has sufficient space for character data and the null terminator](https://wiki.sei.cmu.edu/confluence/display/c/STR31-C.+Guarantee+that+storage+for+strings+has+sufficient+space+for+character+data+and+the+null+terminator) for more information.)

## Compliant Solution (Uninitialized Local)

In this compliant solution, the buffer overflow is eliminated by calling the `snprintf()` function:

```cpp
#include <stdio.h>
enum { BUFFERSIZE = 24 };
void report_error(const char *msg) {
  char buffer[BUFFERSIZE];

  if (0 < snprintf(buffer, BUFFERSIZE, "Error: %s", msg))
    printf("%s\n", buffer);
  else
    puts("Unknown error");
}

```

## Compliant Solution (Uninitialized Local)

A less error-prone compliant solution is to simply print the error message directly instead of using an intermediate buffer:

```cpp
#include <stdio.h>
 
void report_error(const char *msg) {
  printf("Error: %s\n", msg);
}

```

## Noncompliant Code Example (mbstate_t)

In this noncompliant code example, the function `mbrlen()` is passed the address of an automatic `mbstate_t` object that has not been properly initialized. This is [undefined behavior 200](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_200) because `mbrlen()` dereferences and reads its third argument.

```cpp
#include <string.h> 
#include <wchar.h>
 
void func(const char *mbs) {
  size_t len;
  mbstate_t state;

  len = mbrlen(mbs, strlen(mbs), &state);
}

```

## Compliant Solution (mbstate_t)

Before being passed to a multibyte conversion function, an `mbstate_t` object must be either initialized to the initial conversion state or set to a value that corresponds to the most recent shift state by a prior call to a multibyte conversion function. This compliant solution sets the `mbstate_t` object to the initial conversion state by setting it to all zeros:

```cpp
#include <string.h> 
#include <wchar.h>
 
void func(const char *mbs) {
  size_t len;
  mbstate_t state;

  memset(&state, 0, sizeof(state));
  len = mbrlen(mbs, strlen(mbs), &state);
}

```

## Noncompliant Code Example (POSIX, Entropy)

In this noncompliant code example described in "[More Randomness or Less](http://kqueue.org/blog/2012/06/25/more-randomness-or-less/)" \[[Wang 2012](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Wang12)\], the process ID, time of day, and uninitialized memory `junk` is used to seed a random number generator. This behavior is characteristic of some distributions derived from Debian Linux that use uninitialized memory as a source of entropy because the value stored in `junk` is indeterminate. However, because accessing an [indeterminate value](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue) is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior), compilers may optimize out the uninitialized variable access completely, leaving only the time and process ID and resulting in a loss of desired entropy.

```cpp
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/time.h>
  
void func(void) {
  struct timeval tv;
  unsigned long junk;

  gettimeofday(&tv, NULL);
  srandom((getpid() << 16) ^ tv.tv_sec ^ tv.tv_usec ^ junk);
}
```
In security protocols that rely on unpredictability, such as RSA encryption, a loss in entropy results in a less secure system.

## Compliant Solution (POSIX, Entropy)

This compliant solution seeds the random number generator by using the CPU clock and the real-time clock instead of reading uninitialized memory:

```cpp
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/time.h>

void func(void) {     
  double cpu_time;
  struct timeval tv;

  cpu_time = ((double) clock()) / CLOCKS_PER_SEC;
  gettimeofday(&tv, NULL);
  srandom((getpid() << 16) ^ tv.tv_sec ^ tv.tv_usec ^ cpu_time);
}
```

## Noncompliant Code Example (realloc())

The `realloc()` function changes the size of a dynamically allocated memory object. The initial `size` bytes of the returned memory object are unchanged, but any newly added space is uninitialized, and its value is [indeterminate](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue). As in the case of `malloc()`, accessing memory beyond the size of the original object is [undefined behavior 181](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_171).

It is the programmer's responsibility to ensure that any memory allocated with `malloc()` and `realloc()` is properly initialized before it is used.

In this noncompliant code example, an array is allocated with `malloc()` and properly initialized. At a later point, the array is grown to a larger size but not initialized beyond what the original array contained. Subsequently accessing the uninitialized bytes in the new array is undefined behavior.

```cpp
#include <stdlib.h>
#include <stdio.h>
enum { OLD_SIZE = 10, NEW_SIZE = 20 };
 
int *resize_array(int *array, size_t count) {
  if (0 == count) {
    return 0;
  }
 
  int *ret = (int *)realloc(array, count * sizeof(int));
  if (!ret) {
    free(array);
    return 0;
  }
 
  return ret;
}
 
void func(void) {
 
  int *array = (int *)malloc(OLD_SIZE * sizeof(int));
  if (0 == array) {
    /* Handle error */
  }
 
  for (size_t i = 0; i < OLD_SIZE; ++i) {
    array[i] = i;
  }
 
  array = resize_array(array, NEW_SIZE);
  if (0 == array) {
    /* Handle error */
  }
 
  for (size_t i = 0; i < NEW_SIZE; ++i) {
    printf("%d ", array[i]);
  }
}
```

## Compliant Solution (realloc())

In this compliant solution, the `resize_array()` helper function takes a second parameter for the old size of the array so that it can initialize any newly allocated elements:

```cpp
#include <stdlib.h>
#include <stdio.h> 
#include <string.h>

enum { OLD_SIZE = 10, NEW_SIZE = 20 };
 
int *resize_array(int *array, size_t old_count, size_t new_count) {
  if (0 == new_count) {
    return 0;
  }
 
  int *ret = (int *)realloc(array, new_count * sizeof(int));
  if (!ret) {
    free(array);
    return 0;
  }
 
  if (new_count > old_count) {
    memset(ret + old_count, 0, (new_count - old_count) * sizeof(int));
  }
 
  return ret;
}
 
void func(void) {
 
  int *array = (int *)malloc(OLD_SIZE * sizeof(int));
  if (0 == array) {
    /* Handle error */
  }
 
  for (size_t i = 0; i < OLD_SIZE; ++i) {
    array[i] = i;
  }
 
  array = resize_array(array, OLD_SIZE, NEW_SIZE);
  if (0 == array) {
    /* Handle error */
  }
 
  for (size_t i = 0; i < NEW_SIZE; ++i) {
    printf("%d ", array[i]);
  }
}
```

## Exceptions

**EXP33-C-EX1:** Reading uninitialized memory by an [lvalue](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-lvalue) of type `unsigned char` that could not have been declared with the `register` storage class does not trigger [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). The `unsigned char` type is defined to not have a trap representation, which allows for moving bytes without knowing if they are initialized. (See the C Standard, 6.2.6.1, paragraph 3.) The requirement that `register` could not have been used (not merely that it was not used) is because on some architectures, such as the Intel Itanium, registers have a bit to indicate whether or not they have been initialized. The C Standard, 6.3.2.1, paragraph 2, allows such [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) to cause a trap for an object that never had its address taken and is stored in a register if such an object is referred to in any way.

## Risk Assessment

Reading uninitialized variables is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) and can result in [unexpected program behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior). In some cases, these [security flaws](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-securityflaw) may allow the execution of arbitrary code.

Reading uninitialized variables for creating entropy is problematic because these memory accesses can be removed by compiler optimization. [VU\#925211](http://www.kb.cert.org/vuls/id/925211) is an example of a [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) caused by this coding error.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP33-C </td> <td> High </td> <td> Probable </td> <td> Medium </td> <td> <strong>P12</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>uninitialized-local-read</strong> <strong>uninitialized-variable-use</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP33</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.MEM.UVAR</strong> </td> <td> Uninitialized variable </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Automatically detects simple violations of this rule, although it may return some false positives. It may not catch more complex violations, such as initialization within functions taking uninitialized variables as arguments. It does catch the second noncompliant code example, and can be extended to catch the first as well </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>UNINIT</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Cppcheck </a> </td> <td> 1.66 </td> <td> <strong>uninitvaruninitdatauninitstringuninitMemberVaruninitStructMember</strong> </td> <td> Detects uninitialized variables, uninitialized pointers, uninitialized struct members, and uninitialized array elements (However, if one element is initialized, then cppcheck assumes the array is initialized.) There are FN compared to some other tools because Cppcheck tries to avoid FP in impossible paths. </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 4.3.5 </td> <td> </td> <td> Can detect some violations of this rule when the <code>-Wuninitialized</code> flag is used </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF2726, DF2727, DF2728, DF2961, DF2962, DF2963, DF2966, DF2967, DF2968, DF2971, DF2972, DF2973, DF2976, DF2977, DF2978</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>UNINIT.HEAP.MIGHT</strong> <strong>UNINIT.HEAP.MUST</strong> <strong>UNINIT.STACK.ARRAY.MIGHT</strong> <strong>UNINIT.STACK.ARRAY.MUST </strong> <strong>UNINIT.STACK.ARRAY.PARTIAL.MUST</strong> <strong>UNINIT.STACK.MIGHT</strong> <strong>UNINIT.STACK.MUST</strong> <strong>UNINIT.CTOR.MIGHT</strong> <strong>UNINIT.CTOR.MUST</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>53 D, 69 D, 631 S, 652 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-EXP33-a</strong> </td> <td> Avoid use before initialization </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> 2022.2 </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>530, 603, 644, 901</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule EXP33-C </a> </td> <td> Checks for: Non-initialized variableon-initialized variable, non-initialized pointeron-initialized pointer. Rule partially covered </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2726, 2727, 2728, 2961, </strong> <strong>2962, 2963, 2966, </strong> <strong>2967, </strong> <strong>2968, 2971, 2972, 2973, </strong> <strong>2976, 2977, </strong> <strong>2978</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2961, 2962, 2963, 2966, </strong> <strong>2967, 2968, 2971, </strong> <strong>2972, </strong> <strong>2973, 2976, 2977, </strong> <strong>2978</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.22 </td> <td> <strong>V573<a></a></strong> , <strong>V614<a></a></strong> , <strong>V670<a></a></strong> , <strong><a>V679</a></strong> , <strong><a>V1050</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>uninitialized-local-read</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>initialisation</strong> </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

[CVE-2009-1888](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2009-1888) results from a violation of this rule. Some versions of SAMBA (up to 3.3.5) call a function that takes in two potentially uninitialized variables involving access rights. An attacker can [exploit](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-exploit) these coding errors to bypass the access control list and gain access to protected files \[[xorl 2009](http://xorl.wordpress.com/2009/06/26/cve-2009-1888-samba-acls-uninitialized-memory-read/)\].

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP33-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MSC00-C. Compile cleanly at high warning levels </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MSC01-C. Strive for logical completeness </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> EXP53-CPP. Do not read uninitialized memory </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Initialization of Variables \[LAV\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Referencing uninitialized memory \[uninitref\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-456 </a> </td> <td> 2017-07-05: CERT: Exact </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-457 </a> </td> <td> 2017-07-05: CERT: Exact </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-758 </a> </td> <td> 2017-07-05: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-908 </a> </td> <td> 2017-07-05: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-119 and EXP33-C**

* Intersection( CWE-119, EXP33-C) = Ø
* EXP33-C is about reading uninitialized memory, but this memory is considered part of a valid buffer (on the stack, or returned by a heap function). No buffer overflow is involved.
**CWE-676 and EXP33-C**
* Intersection( CWE-676, EXP33-C) = Ø
* EXP33-C implies that memory allocation functions (e.g., malloc()) are dangerous because they do not initialize the memory they reserve. However, the danger is not in their invocation, but rather reading their returned memory without initializing it.
**CWE-758 and EXP33-C**

Independent( INT34-C, INT36-C, MSC37-C, FLP32-C, EXP33-C, EXP30-C, ERR34-C, ARR32-C)

CWE-758 = Union( EXP33-C, list) where list =

* Undefined behavior that results from anything other than reading uninitialized memory
**CWE-665 and EXP33-C**

Intersection( CWE-665, EXP33-C) = Ø

CWE-665 is about correctly initializing items (usually objects), not reading them later. EXP33-C is about reading memory later (that has not been initialized).

**CWE-908 and EXP33-C**

CWE-908 = Union( EXP33-C, list) where list =

* Use of uninitialized items besides raw memory (objects, disk space, etc)
New CWE-CERT mappings:

**CWE-123 and EXP33-C**

Intersection( CWE-123, EXP33-C) = Ø

EXP33-C is only about reading uninitialized memory, not writing, whereas CWE-123 is about writing.

**CWE-824 and EXP33-C**

EXP33-C = Union( CWE-824, list) where list =

* Read of uninitialized memory that does not represent a pointer

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Flake 2006 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 6.7.9, "Initialization" Subclause 6.2.6.1, "General" Subclause 6.3.2.1, "Lvalues, Arrays, and Function Designators" </td> </tr> <tr> <td> \[ <a> Mercy 2006 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> VU\#925211 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Wang 2012 </a> \] </td> <td> <a> "More Randomness or Less" </a> </td> </tr> <tr> <td> \[ <a> xorl 2009 </a> \] </td> <td> <a> "CVE-2009-1888: SAMBA ACLs Uninitialized Memory Read" </a> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [EXP33-C: Do not read uninitialized memory](https://wiki.sei.cmu.edu/confluence/display/c)
