# INT30-C: Ensure that unsigned integer operations do not wrap

This query implements the CERT-C rule INT30-C:

> Ensure that unsigned integer operations do not wrap


## Description

The C Standard, 6.2.5, paragraph 9 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> A computation involving unsigned operands can never overflow, because a result that cannot be represented by the resulting unsigned integer type is reduced modulo the number that is one greater than the largest value that can be represented by the resulting type.


This behavior is more informally called [unsigned integer wrapping](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unsignedintegerwrapping). Unsigned integer operations can wrap if the resulting value cannot be represented by the underlying representation of the integer. The following table indicates which operators can result in wrapping:

<table> <tbody> <tr> <th> Operator </th> <th> Wrap </th> <th> Operator </th> <th> Wrap </th> <th> Operator </th> <th> Wrap </th> <th> Operator </th> <th> Wrap </th> </tr> <tr> <td> <code><a>+</a></code> </td> <td> Yes </td> <td> <code><a>-=</a></code> </td> <td> Yes </td> <td> <code><a>&lt;&lt;</a></code> </td> <td> Yes </td> <td> <code>&lt;</code> </td> <td> No </td> </tr> <tr> <td> <code><a>-</a></code> </td> <td> Yes </td> <td> <code><a>\*=</a></code> </td> <td> Yes </td> <td> <code>&gt;&gt;</code> </td> <td> No </td> <td> <code>&gt;</code> </td> <td> No </td> </tr> <tr> <td> <code><a>\*</a></code> </td> <td> Yes </td> <td> <code>/=</code> </td> <td> No </td> <td> <code>&amp;</code> </td> <td> No </td> <td> <code>&gt;=</code> </td> <td> No </td> </tr> <tr> <td> <code>/</code> </td> <td> No </td> <td> <code>%=</code> </td> <td> No </td> <td> <code>|</code> </td> <td> No </td> <td> <code>&lt;=</code> </td> <td> No </td> </tr> <tr> <td> <code>%</code> </td> <td> No </td> <td> <code><a>&lt;&lt;=</a></code> </td> <td> Yes </td> <td> <code>^</code> </td> <td> No </td> <td> <code>==</code> </td> <td> No </td> </tr> <tr> <td> <code>++</code> </td> <td> Yes </td> <td> <code>&gt;&gt;=</code> </td> <td> No </td> <td> <code>~</code> </td> <td> No </td> <td> <code>!=</code> </td> <td> No </td> </tr> <tr> <td> <code>--</code> </td> <td> Yes </td> <td> <code>&amp;=</code> </td> <td> No </td> <td> <code>!</code> </td> <td> No </td> <td> <code>&amp;&amp;</code> </td> <td> No </td> </tr> <tr> <td> <code>=</code> </td> <td> No </td> <td> <code>|=</code> </td> <td> No </td> <td> <code>un +</code> </td> <td> No </td> <td> <code>||</code> </td> <td> No </td> </tr> <tr> <td> <code><a>+=</a></code> </td> <td> Yes </td> <td> <code>^=</code> </td> <td> No </td> <td> <code>un -</code> </td> <td> Yes </td> <td> <code>?:</code> </td> <td> No </td> </tr> </tbody> </table>
The following sections examine specific operations that are susceptible to unsigned integer wrap. When operating on integer types with less precision than `int`, integer promotions are applied. The usual arithmetic conversions may also be applied to (implicitly) convert operands to equivalent types before arithmetic operations are performed. Programmers should understand integer conversion rules before trying to implement secure arithmetic operations. (See [INT02-C. Understand integer conversion rules](https://wiki.sei.cmu.edu/confluence/display/c/INT02-C.+Understand+integer+conversion+rules).)


Integer values must not be allowed to wrap, especially if they are used in any of the following ways:

* Integer operands of any pointer arithmetic, including array indexing
* The assignment expression for the declaration of a variable length array
* The postfix expression preceding square brackets `[]` or the expression in square brackets `[]` of a subscripted designation of an element of an array object
* Function arguments of type `size_t` or `rsize_t` (for example, an argument to a memory allocation function)
* In security-critical code
The C Standard defines arithmetic on atomic integer types as read-modify-write operations with the same representation as regular integer types. As a result, wrapping of atomic unsigned integers is identical to regular unsigned integers and should also be prevented or detected.

## Addition

Addition is between two operands of arithmetic type or between a pointer to an object type and an integer type. This rule applies only to addition between two operands of arithmetic type. (See [ARR37-C. Do not add or subtract an integer to a pointer to a non-array object](https://wiki.sei.cmu.edu/confluence/display/c/ARR37-C.+Do+not+add+or+subtract+an+integer+to+a+pointer+to+a+non-array+object) and [ARR30-C. Do not form or use out-of-bounds pointers or array subscripts](https://wiki.sei.cmu.edu/confluence/display/c/ARR30-C.+Do+not+form+or+use+out-of-bounds+pointers+or+array+subscripts).)

Incrementing is equivalent to adding 1.

**Noncompliant Code Example**

This noncompliant code example can result in an unsigned integer wrap during the addition of the unsigned operands `ui_a` and `ui_b`. If this behavior is [unexpected](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior), the resulting value may be used to allocate insufficient memory for a subsequent operation or in some other manner that can lead to an exploitable [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability).

```cpp
void func(unsigned int ui_a, unsigned int ui_b) {
  unsigned int usum = ui_a + ui_b;
  /* ... */
}
```
**Compliant Solution (Precondition Test)**

This compliant solution performs a precondition test of the operands of the addition to guarantee there is no possibility of unsigned wrap:

```cpp
#include <limits.h>
 
void func(unsigned int ui_a, unsigned int ui_b) {
  unsigned int usum;
  if (UINT_MAX - ui_a < ui_b) {
    /* Handle error */
  } else {
    usum = ui_a + ui_b;
  }
  /* ... */
}
```
**Compliant Solution (Postcondition Test)**

This compliant solution performs a postcondition test to ensure that the result of the unsigned addition operation `usum` is not less than the first operand:

```cpp
void func(unsigned int ui_a, unsigned int ui_b) {
  unsigned int usum = ui_a + ui_b;
  if (usum < ui_a) {
    /* Handle error */
  }
  /* ... */
}
```

## Subtraction

Subtraction is between two operands of arithmetic type, two pointers to qualified or unqualified versions of compatible object types, or a pointer to an object type and an integer type. This rule applies only to subtraction between two operands of arithmetic type. (See [ARR36-C. Do not subtract or compare two pointers that do not refer to the same array](https://wiki.sei.cmu.edu/confluence/display/c/ARR36-C.+Do+not+subtract+or+compare+two+pointers+that+do+not+refer+to+the+same+array), [ARR37-C. Do not add or subtract an integer to a pointer to a non-array object](https://wiki.sei.cmu.edu/confluence/display/c/ARR37-C.+Do+not+add+or+subtract+an+integer+to+a+pointer+to+a+non-array+object), and [ARR30-C. Do not form or use out-of-bounds pointers or array subscripts](https://wiki.sei.cmu.edu/confluence/display/c/ARR30-C.+Do+not+form+or+use+out-of-bounds+pointers+or+array+subscripts) for information about pointer subtraction.)

Decrementing is equivalent to subtracting 1.

**Noncompliant Code Example**

This noncompliant code example can result in an unsigned integer wrap during the subtraction of the unsigned operands `ui_a` and `ui_b`. If this behavior is unanticipated, it may lead to an exploitable [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability).

```cpp
void func(unsigned int ui_a, unsigned int ui_b) {
  unsigned int udiff = ui_a - ui_b;
  /* ... */
}
```
**Compliant Solution (Precondition Test)**

This compliant solution performs a precondition test of the unsigned operands of the subtraction operation to guarantee there is no possibility of unsigned wrap:

```cpp
void func(unsigned int ui_a, unsigned int ui_b) {
  unsigned int udiff;
  if (ui_a < ui_b){
    /* Handle error */
  } else {
    udiff = ui_a - ui_b;
  }
  /* ... */
}
```
**Compliant Solution (Postcondition Test)**

This compliant solution performs a postcondition test that the result of the unsigned subtraction operation `udiff` is not greater than the minuend:

```cpp
void func(unsigned int ui_a, unsigned int ui_b) {
  unsigned int udiff = ui_a - ui_b;
  if (udiff > ui_a) {
    /* Handle error */
  }
  /* ... */
}
```

## Multiplication

Multiplication is between two operands of arithmetic type.

**Noncompliant Code Example**

The Mozilla Foundation Security Advisory 2007-01 describes a heap buffer overflow vulnerability in the Mozilla Scalable Vector Graphics (SVG) viewer resulting from an unsigned integer wrap during the multiplication of the `signed int` value `pen->num_vertices` and the `size_t` value `sizeof(cairo_pen_vertex_t)` \[[VU\#551436](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-VU551436)\]. The `signed int` operand is converted to `size_t` prior to the multiplication operation so that the multiplication takes place between two `size_t` integers, which are unsigned. (See [INT02-C. Understand integer conversion rules](https://wiki.sei.cmu.edu/confluence/display/c/INT02-C.+Understand+integer+conversion+rules).)

```cpp
pen->num_vertices = _cairo_pen_vertices_needed(
  gstate->tolerance, radius, &gstate->ctm
);
pen->vertices = malloc(
  pen->num_vertices * sizeof(cairo_pen_vertex_t)
);

```
The unsigned integer wrap can result in allocating memory of insufficient size.

**Compliant Solution**

This compliant solution tests the operands of the multiplication to guarantee that there is no unsigned integer wrap:

```cpp
pen->num_vertices = _cairo_pen_vertices_needed(
  gstate->tolerance, radius, &gstate->ctm
);

if (pen->num_vertices > SIZE_MAX / sizeof(cairo_pen_vertex_t)) {
  /* Handle error */
}
pen->vertices = malloc(
  pen->num_vertices * sizeof(cairo_pen_vertex_t)
);

```

## Exceptions

**INT30-C-EX1:** Unsigned integers can exhibit modulo behavior (wrapping) when necessary for the proper execution of the program. It is recommended that the variable declaration be clearly commented as supporting modulo behavior and that each operation on that integer also be clearly commented as supporting modulo behavior.

**INT30-C-EX2:** Checks for wraparound can be omitted when it can be determined at compile time that wraparound will not occur. As such, the following operations on unsigned integers require no validation:

* Operations on two compile-time constants
* Operations on a variable and 0 (except division or remainder by 0)
* Subtracting any variable from its type's maximum; for example, any `unsigned int` may safely be subtracted from `UINT_MAX`
* Multiplying any variable by 1
* Division or remainder, as long as the divisor is nonzero
* Right-shifting any type maximum by any number no larger than the type precision; for example, `UINT_MAX >> x` is valid as long as `0 <= x < 32` (assuming that the precision of `unsigned int` is 32 bits)
**INT30-C-EX3.** The left-shift operator takes two operands of integer type. Unsigned left shift `<<` can exhibit modulo behavior (wrapping). This exception is provided because of common usage, because this behavior is usually expected by the programmer, and because the behavior is well defined. For examples of usage of the left-shift operator, see [INT34-C. Do not shift an expression by a negative number of bits or by greater than or equal to the number of bits that exist in the operand](https://wiki.sei.cmu.edu/confluence/display/c/INT34-C.+Do+not+shift+an+expression+by+a+negative+number+of+bits+or+by+greater+than+or+equal+to+the+number+of+bits+that+exist+in+the+operand).

## Risk Assessment

Integer wrap can lead to buffer overflows and the execution of arbitrary code by an attacker.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> INT30-C </td> <td> High </td> <td> Likely </td> <td> High </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>integer-overflow</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-INT30</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>ALLOC.SIZE.ADDOFLOW</strong> <strong>ALLOC.SIZE.IOFLOW</strong> <strong>ALLOC.SIZE.MULOFLOW</strong> <strong>ALLOC.SIZE.SUBUFLOW</strong> <strong>MISC.MEM.SIZE.ADDOFLOW</strong> <strong>MISC.MEM.SIZE.BAD</strong> <strong>MISC.MEM.SIZE.MULOFLOW</strong> <strong>MISC.MEM.SIZE.SUBUFLOW</strong> </td> <td> Addition overflow of allocation size Integer overflow of allocation size Multiplication overflow of allocation size Subtraction underflow of allocation size Addition overflow of size Unreasonable size argument Multiplication overflow of size Subtraction underflow of size </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule by ensuring that operations are checked for overflow before being performed (Be mindful of exception INT30-EX2 because it excuses many operations from requiring <a> validation </a> , including all the operations that would validate a potentially dangerous operation. For instance, adding two <code>unsigned int</code> s together requires validation involving subtracting one of the numbers from <code>UINT_MAX</code> , which itself requires no validation because it cannot wrap.) </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>INTEGER_OVERFLOW</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C2910, C3383, C3384, C3385, C3386</strong> <strong>C++2910</strong> <strong>DF2911, DF2912, DF2913, </strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>NUM.OVERFLOW</strong> <strong>CWARN.NOEFFECT.OUTOFRANGE</strong> <strong>NUM.OVERFLOW.DF</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>493 S, 494 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-INT30-a</strong> <strong>CERT_C-INT30-b</strong> <strong>CERT_C-INT30-c</strong> </td> <td> Avoid integer overflows Integer overflow or underflow in constant expression in '+', '-', '\*' operator Integer overflow or underflow in constant expression in '&lt;&lt;' operator </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule INT30-C </a> </td> <td> Checks for: Unsigned integer overflownsigned integer overflow, unsigned integer constant overflownsigned integer constant overflow. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2910 \[C\], 2911 \[D\], 2912 \[A\], </strong> <strong>2913 \[S\], 3383, 3384, 3385, 3386</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2910, 2911, 2912, 2913</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong><a>V658</a>, <a>V1012</a>, <strong><a>V1028</a>, <a>V5005</a>, <a>V5011</a> </strong></strong> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>unsigned overflow</strong> </td> <td> Exhaustively verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

[CVE-2009-1385](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2009-1385) results from a violation of this rule. The value performs an unchecked subtraction on the `length` of a buffer and then adds those many bytes of data to another buffer \[[xorl 2009](http://xorl.wordpress.com/2009/06/10/cve-2009-1385-linux-kernel-e1000-integer-underflow/)\]. This can cause a buffer overflow, which allows an attacker to execute arbitrary code.

A Linux Kernel vmsplice [exploit](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-exploit), described by Rafal Wojtczuk \[[Wojtczuk 2008](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Wojtczuk08)\], documents a [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) and exploit arising from a buffer overflow (caused by unsigned integer wrapping).

Don Bailey \[[Bailey 2014](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Bailey14)\] describes an unsigned integer wrap [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) in the LZO compression algorithm, which can be exploited in some implementations.

[CVE-2014-4377](https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2014-4377) describes a [vulnerability](http://blog.binamuse.com/2014/09/coregraphics-memory-corruption.html) in iOS 7.1 resulting from a multiplication operation that wraps, producing an insufficiently small value to pass to a memory allocation routine, which is subsequently overflowed.

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+INT30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> INT02-C. Understand integer conversion rules </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> ARR30-C. Do not form or use out-of-bounds pointers or array subscripts </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> ARR36-C. Do not subtract or compare two pointers that do not refer to the same array </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> ARR37-C. Do not add or subtract an integer to a pointer to a non-array object </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> CON08-C. Do not assume that a group of calls to independently atomic methods is atomic </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Arithmetic Wrap-Around Error \[FIF\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-190 </a> , Integer Overflow or Wraparound </td> <td> 2016-12-02: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-131 </a> </td> <td> 2017-05-16: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-191 </a> </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-680 </a> </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-131 and INT30-C**

* Intersection( INT30-C, MEM35-C) = Ø
* Intersection( CWE-131, INT30-C) =
* Calculating a buffer size such that the calculation wraps. This can happen, for example, when using malloc() or operator new\[\] to allocate an array, multiplying the array item size with the array dimension. An untrusted dimension could cause wrapping, resulting in a too-small buffer being allocated, and subsequently overflowed when the array is initialized.
* CWE-131 – INT30-C =
* Incorrect calculation of a buffer size that does not involve wrapping. This includes off-by-one errors, for example.
INT30-C – CWE-131 =
* Integer wrapping where the result is not used to allocate memory.
**CWE-680 and INT30-C**

Intersection( CWE-680, INT30-C) =

* Unsigned integer overflows that lead to buffer overflows
CWE-680 - INT30-C =
* Signed integer overflows that lead to buffer overflows
INT30-C – CWE-680 =
* Unsigned integer overflows that do not lead to buffer overflows
**CWE-191 and INT30-C**

Union( CWE-190, CWE-191) = Union( INT30-C, INT32-C) Intersection( INT30-C, INT32-C) == Ø

Intersection(CWE-191, INT30-C) =

* Underflow of unsigned integer operation
CWE-191 – INT30-C =
* Underflow of signed integer operation
INT30-C – CWE-191 =
* Overflow of unsigned integer operation

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Bailey 2014 </a> \] </td> <td> <a> Raising Lazarus - The 20 Year Old Bug that Went to Mars </a> </td> </tr> <tr> <td> \[ <a> Dowd 2006 </a> \] </td> <td> Chapter 6, "C Language Issues" ("Arithmetic Boundary Conditions," pp. 211–223) </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 6.2.5, "Types" </td> </tr> <tr> <td> \[ <a> Seacord 2013b </a> \] </td> <td> Chapter 5, "Integer Security" </td> </tr> <tr> <td> \[ <a> Viega 2005 </a> \] </td> <td> Section 5.2.7, "Integer Overflow" </td> </tr> <tr> <td> \[ <a> VU\#551436 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Warren 2002 </a> \] </td> <td> Chapter 2, "Basics" </td> </tr> <tr> <td> \[ <a> Wojtczuk 2008 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> xorl 2009 </a> \] </td> <td> <a> "CVE-2009-1385: Linux Kernel E1000 Integer Underflow" </a> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [INT30-C: Ensure that unsigned integer operations do not wrap](https://wiki.sei.cmu.edu/confluence/display/c)
