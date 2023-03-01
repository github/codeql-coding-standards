# EXP34-C: Do not dereference null pointers

This query implements the CERT-C rule EXP34-C:

> Do not dereference null pointers


## Description

Dereferencing a null pointer is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

On many platforms, dereferencing a null pointer results in [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination), but this is not required by the standard. See "[Clever Attack Exploits Fully-Patched Linux Kernel](http://www.theregister.co.uk/2009/07/17/linux_kernel_exploit/)" \[[Goodin 2009](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Goodin2009)\] for an example of a code execution [exploit](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-exploit) that resulted from a null pointer dereference.

## Noncompliant Code Example

This noncompliant code example is derived from a real-world example taken from a vulnerable version of the `libpng` library as deployed on a popular ARM-based cell phone \[[Jack 2007](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Jack07)\]. The `libpng` library allows applications to read, create, and manipulate PNG (Portable Network Graphics) raster image files. The `libpng` library implements its own wrapper to `malloc()` that returns a null pointer on error or on being passed a 0-byte-length argument.

This code also violates [ERR33-C. Detect and handle standard library errors](https://wiki.sei.cmu.edu/confluence/display/c/ERR33-C.+Detect+and+handle+standard+library+errors).

```cpp
#include <png.h> /* From libpng */
#include <string.h>
 
void func(png_structp png_ptr, int length, const void *user_data) { 
  png_charp chunkdata;
  chunkdata = (png_charp)png_malloc(png_ptr, length + 1);
  /* ... */
  memcpy(chunkdata, user_data, length);
  /* ... */
 }
```
If `length` has the value `−1`, the addition yields 0, and `png_malloc()` subsequently returns a null pointer, which is assigned to `chunkdata`. The `chunkdata` pointer is later used as a destination argument in a call to `memcpy()`, resulting in user-defined data overwriting memory starting at address 0. In the case of the ARM and XScale architectures, the `0x0` address is mapped in memory and serves as the exception vector table; consequently, dereferencing `0x0` did not cause an [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination).

## Compliant Solution

This compliant solution ensures that the pointer returned by `png_malloc()` is not null. It also uses the unsigned type `size_t` to pass the `length` parameter, ensuring that negative values are not passed to `func()`.

This solution also ensures that the `user_data` pointer is not null. Passing a null pointer to memcpy() would produce undefined behavior, even if the number of bytes to copy were 0. The `user_data` pointer could be invalid in other ways, such as pointing to freed memory. However there is no portable way to verify that the pointer is valid, other than checking for null.

```cpp
#include <png.h> /* From libpng */
#include <string.h>

 void func(png_structp png_ptr, size_t length, const void *user_data) { 
  png_charp chunkdata;
  if (length == SIZE_MAX) {
    /* Handle error */
  }
  if (NULL == user_data) {
    /* Handle error */
  }
  chunkdata = (png_charp)png_malloc(png_ptr, length + 1);
  if (NULL == chunkdata) {
    /* Handle error */
  }
  /* ... */
  memcpy(chunkdata, user_data, length);
  /* ... */

 }
```

## Noncompliant Code Example

In this noncompliant code example, `input_str` is copied into dynamically allocated memory referenced by `c_str`. If `malloc()` fails, it returns a null pointer that is assigned to `c_str`. When `c_str` is dereferenced in `memcpy()`, the program exhibits [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). Additionally, if `input_str` is a null pointer, the call to `strlen()` dereferences a null pointer, also resulting in undefined behavior. This code also violates [ERR33-C. Detect and handle standard library errors](https://wiki.sei.cmu.edu/confluence/display/c/ERR33-C.+Detect+and+handle+standard+library+errors).

```cpp
#include <string.h>
#include <stdlib.h>
 
void f(const char *input_str) {
  size_t size = strlen(input_str) + 1;
  char *c_str = (char *)malloc(size);
  memcpy(c_str, input_str, size);
  /* ... */
  free(c_str);
  c_str = NULL;
  /* ... */
}
```

## Compliant Solution

This compliant solution ensures that both `input_str` and the pointer returned by `malloc()` are not null:

```cpp
#include <string.h>
#include <stdlib.h>
 
void f(const char *input_str) {
  size_t size;
  char *c_str;
 
  if (NULL == input_str) {
    /* Handle error */
  }
  
  size = strlen(input_str) + 1;
  c_str = (char *)malloc(size);
  if (NULL == c_str) {
    /* Handle error */
  }
  memcpy(c_str, input_str, size);
  /* ... */
  free(c_str);
  c_str = NULL;
  /* ... */
}
```

## Noncompliant Code Example

This noncompliant code example is from a version of `drivers/net/tun.c` and affects Linux kernel 2.6.30 \[[Goodin 2009](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Goodin2009)\]:

```cpp
static unsigned int tun_chr_poll(struct file *file, poll_table *wait)  {
  struct tun_file *tfile = file->private_data;
  struct tun_struct *tun = __tun_get(tfile);
  struct sock *sk = tun->sk;
  unsigned int mask = 0;

  if (!tun)
    return POLLERR;

  DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);

  poll_wait(file, &tun->socket.wait, wait);

  if (!skb_queue_empty(&tun->readq))
    mask |= POLLIN | POLLRDNORM;

  if (sock_writeable(sk) ||
     (!test_and_set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags) &&
     sock_writeable(sk)))
    mask |= POLLOUT | POLLWRNORM;

  if (tun->dev->reg_state != NETREG_REGISTERED)
    mask = POLLERR;

  tun_put(tun);
  return mask;
}

```
The `sk` pointer is initialized to `tun->sk` before checking if `tun` is a null pointer. Because null pointer dereferencing is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior), the compiler (GCC in this case) can optimize away the `if (!tun)` check because it is performed after `tun->sk` is accessed, implying that `tun` is non-null. As a result, this noncompliant code example is vulnerable to a null pointer dereference exploit, because null pointer dereferencing can be permitted on several platforms, for example, by using `mmap(2)` with the `MAP_FIXED` flag on Linux and Mac OS X, or by using the `shmat()` POSIX function with the `SHM_RND` flag \[[Liu 2009](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Liu2009)\].

## Compliant Solution

This compliant solution eliminates the null pointer deference by initializing `sk` to `tun->sk` following the null pointer check. It also adds assertions to document that certain other pointers must not be null.

```cpp
static unsigned int tun_chr_poll(struct file *file, poll_table *wait)  {
  assert(file);
  struct tun_file *tfile = file->private_data;
  struct tun_struct *tun = __tun_get(tfile);
  struct sock *sk;
  unsigned int mask = 0;

  if (!tun)
    return POLLERR;
  assert(tun->dev);
  sk = tun->sk;
  assert(sk);
  assert(sk->socket);
  /* The remaining code is omitted because it is unchanged... */
}

```

## Risk Assessment

Dereferencing a null pointer is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior), typically [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination). In some situations, however, dereferencing a null pointer can lead to the execution of arbitrary code \[[Jack 2007](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Jack07), [van Sprundel 2006](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-vanSprundel06)\]. The indicated severity is for this more severe case; on platforms where it is not possible to exploit a null pointer dereference to execute arbitrary code, the actual severity is low.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP34-C </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>null-dereferencing</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP34</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.MEM.NPD</strong> <strong>LANG.STRUCT.NTAD</strong> <strong>LANG.STRUCT.UPD</strong> </td> <td> Null pointer dereference Null test after dereference Unchecked parameter dereference </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule. In particular, ROSE ensures that any pointer returned by <code>malloc()</code> , <code>calloc()</code> , or <code>realloc()</code> is first checked for <code>NULL</code> before being used (otherwise, it is <code>free()</code> -ed). ROSE does not handle cases where an allocation is assigned to an <a> lvalue </a> that is not a variable (such as a <code>struct</code> member or C++ function call returning a reference) </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>CHECKED_RETURN</strong> <strong>NULL_RETURNS</strong> <strong>REVERSE_INULL</strong> <strong>FORWARD_NULL</strong> </td> <td> Finds instances where a pointer is checked against <code>NULL</code> and then later dereferenced Identifies functions that can return a null pointer but are not checked Identifies code that dereferences a pointer and then checks the pointer against <code>NULL</code> Can find the instances where <code>NULL</code> is explicitly dereferenced or a pointer is checked against <code>NULL</code> but then dereferenced anyway. Coverity Prevent cannot discover all violations of this rule, so further verification is necessary </td> </tr> <tr> <td> <a> Cppcheck </a> </td> <td> 1.66 </td> <td> <strong>nullPointer, nullPointerDefaultArg, nullPointerRedundantCheck</strong> </td> <td> Context sensitive analysis Detects when NULL is dereferenced (Array of pointers is not checked. Pointer members in structs are not checked.) Finds instances where a pointer is checked against <code>NULL</code> and then later dereferenced Identifies code that dereferences a pointer and then checks the pointer against <code>NULL</code> Does not guess that return values from <code>malloc()</code> , <code>strchr()</code> , etc., can be <code>NULL</code> (The return value from <code>malloc()</code> is <code>NULL</code> only if there is OOMo and the dev might not care to handle that. The return value from <code>strchr()</code> is often <code>NULL</code> , but the dev might know that a specific <code>strchr()</code> function call will not return <code>NULL</code> .) </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF2810, DF2811, DF2812, DF2813</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>NPD.CHECK.CALL.MIGHT</strong> <strong>NPD.CHECK.CALL.MUST</strong> <strong>NPD.CHECK.MIGHT</strong> <strong>NPD.CHECK.MUST</strong> <strong>NPD.CONST.CALL</strong> <strong>NPD.CONST.DEREF</strong> <strong>NPD.FUNC.CALL.MIGHT</strong> <strong>NPD.FUNC.CALL.MUST</strong> <strong>NPD.FUNC.MIGHT</strong> <strong>NPD.FUNC.MUST</strong> <strong>NPD.GEN.CALL.MIGHT</strong> <strong>NPD.GEN.CALL.MUST</strong> <strong>NPD.GEN.MIGHT</strong> <strong>NPD.GEN.MUST</strong> <strong>RNPD.CALL</strong> <strong>RNPD.DEREF</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>45 D, 123 D, 128 D, 129 D, 130 D, 131 D, 652 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-EXP34-a</strong> </td> <td> Avoid null pointer dereferencing </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>413, 418, 444, 613, 668</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> </td> <td> <a> CERT C: Rule EXP34-C </a> </td> <td> Checks for use of null pointers (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2810, 2811, 2812, 2813</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2810, 2811, 2812, 2813</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.22 </td> <td> <strong>V522<a></a></strong> , <strong>V595<a></a></strong> , <strong>V664<a></a></strong> , <strong>V713<a></a></strong> , <strong><a>V1004</a></strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S2259</a></strong> </td> <td> </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>mem_access</strong> </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP34-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> EXP01-J. Do not use a null in a case where an object is required </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Pointer Casting and Pointer Type Changes \[HFC\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Null Pointer Dereference \[XYH\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Dereferencing an out-of-domain pointer \[nullref\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-476 </a> , NULL Pointer Dereference </td> <td> 2017-07-06: CERT: Exact </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-690 and EXP34-C**

EXP34-C = Union( CWE-690, list) where list =

* Dereferencing null pointers that were not returned by a function
**CWE-252 and EXP34-C**

Intersection( CWE-252, EXP34-C) = Ø

EXP34-C is a common consequence of ignoring function return values, but it is a distinct error, and can occur in other scenarios too.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Goodin 2009 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Jack 2007 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Liu 2009 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> van Sprundel 2006 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Viega 2005 </a> \] </td> <td> Section 5.2.18, "Null-Pointer Dereference" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [EXP34-C: Do not dereference null pointers](https://wiki.sei.cmu.edu/confluence/display/c)
