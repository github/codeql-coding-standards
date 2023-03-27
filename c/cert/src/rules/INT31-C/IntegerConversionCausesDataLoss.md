# INT31-C: Ensure that integer conversions do not result in lost or misinterpreted data

This query implements the CERT-C rule INT31-C:

> Ensure that integer conversions do not result in lost or misinterpreted data


## Description

Integer conversions, both implicit and explicit (using a cast), must be guaranteed not to result in lost or misinterpreted data. This rule is particularly true for integer values that originate from untrusted sources and are used in any of the following ways:

* Integer operands of any pointer arithmetic, including array indexing
* The assignment expression for the declaration of a variable length array
* The postfix expression preceding square brackets `[]` or the expression in square brackets `[]` of a subscripted designation of an element of an array object
* Function arguments of type `size_t` or `rsize_t` (for example, an argument to a memory allocation function)
This rule also applies to arguments passed to the following library functions that are converted to `unsigned char`:
* `memset()`
* `memset_s()`
* `fprintf()` and related functions (For the length modifier `c`, if no `l` length modifier is present, the `int` argument is converted to an `unsigned char`, and the resulting character is written.)
* `fputc()`
* `ungetc()`
* `memchr()`
and to arguments to the following library functions that are converted to `char`:
* `strchr()`
* `strrchr()`
* All of the functions listed in `<ctype.h>`
The only integer type conversions that are guaranteed to be safe for all data values and all possible conforming implementations are conversions of an integral value to a wider type of the same signedness. The C Standard, subclause 6.3.1.3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IECTR24731-2-2010)\], says

> When a value with integer type is converted to another integer type other than `_Bool`, if the value can be represented by the new type, it is unchanged.


Otherwise, if the new type is unsigned, the value is converted by repeatedly adding or subtracting one more than the maximum value that can be represented in the new type until the value is in the range of the new type.

Otherwise, the new type is signed and the value cannot be represented in it; either the result is [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) or an implementation-defined signal is raised.

Typically, converting an integer to a smaller type results in truncation of the high-order bits.

## Noncompliant Code Example (Unsigned to Signed)

Type range errors, including loss of data (truncation) and loss of sign (sign errors), can occur when converting from a value of an unsigned integer type to a value of a signed integer type. This noncompliant code example results in a truncation error on most [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation):

```cpp
#include <limits.h>
 
void func(void) {
  unsigned long int u_a = ULONG_MAX;
  signed char sc;
  sc = (signed char)u_a; /* Cast eliminates warning */
  /* ... */
}
```

## Compliant Solution (Unsigned to Signed)

Validate ranges when converting from an unsigned type to a signed type. This compliant solution can be used to convert a value of `unsigned long int` type to a value of `signed char `type:

```cpp
#include <limits.h>
 
void func(void) {
  unsigned long int u_a = ULONG_MAX;
  signed char sc;
  if (u_a <= SCHAR_MAX) {
    sc = (signed char)u_a;  /* Cast eliminates warning */
  } else {
    /* Handle error */
  }
}
```

## Noncompliant Code Example (Signed to Unsigned)

Type range errors, including loss of data (truncation) and loss of sign (sign errors), can occur when converting from a value of a signed type to a value of an unsigned type. This noncompliant code example results in a negative number being misinterpreted as a large positive number.

```cpp
#include <limits.h>

void func(signed int si) {
  /* Cast eliminates warning */
  unsigned int ui = (unsigned int)si;

  /* ... */
}

/* ... */

func(INT_MIN);
```

## Compliant Solution (Signed to Unsigned)

Validate ranges when converting from a signed type to an unsigned type. This compliant solution converts a value of a `signed int` type to a value of an `unsigned int` type:

```cpp
#include <limits.h>

void func(signed int si) {
  unsigned int ui;
  if (si < 0) {
    /* Handle error */
  } else {
    ui = (unsigned int)si;  /* Cast eliminates warning */
  }
  /* ... */
}
/* ... */

func(INT_MIN + 1);
```
Subclause 6.2.5, paragraph 9, of the C Standard \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IECTR24731-2-2010)\] provides the necessary guarantees to ensure this solution works on a [conforming](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-conformingprogram) [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation):

> The range of nonnegative values of a signed integer type is a subrange of the corresponding unsigned integer type, and the representation of the same value in each type is the same.


## Noncompliant Code Example (Signed, Loss of Precision)

A loss of data (truncation) can occur when converting from a value of a signed integer type to a value of a signed type with less precision. This noncompliant code example results in a truncation error on most [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation):

```cpp
#include <limits.h>

void func(void) {
  signed long int s_a = LONG_MAX;
  signed char sc = (signed char)s_a; /* Cast eliminates warning */
  /* ... */
}
```

## Compliant Solution (Signed, Loss of Precision)

Validate ranges when converting from a signed type to a signed type with less precision. This compliant solution converts a value of a `signed long int` type to a value of a `signed char` type:

```cpp
#include <limits.h>

void func(void) {
  signed long int s_a = LONG_MAX;
  signed char sc;
  if ((s_a < SCHAR_MIN) || (s_a > SCHAR_MAX)) {
    /* Handle error */
  } else {
    sc = (signed char)s_a; /* Use cast to eliminate warning */
  }
  /* ... */
}

```
Conversions from a value of a signed integer type to a value of a signed integer type with less precision requires that both the upper and lower bounds are checked.

## Noncompliant Code Example (Unsigned, Loss of Precision)

A loss of data (truncation) can occur when converting from a value of an unsigned integer type to a value of an unsigned type with less precision. This noncompliant code example results in a truncation error on most [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation):

```cpp
#include <limits.h>

void func(void) {
  unsigned long int u_a = ULONG_MAX;
  unsigned char uc = (unsigned char)u_a; /* Cast eliminates warning */
  /* ... */
}
```

## Compliant Solution (Unsigned, Loss of Precision)

Validate ranges when converting a value of an unsigned integer type to a value of an unsigned integer type with less precision. This compliant solution converts a value of an `unsigned long int` type to a value of an `unsigned char` type:

```cpp
#include <limits.h>

void func(void) {
  unsigned long int u_a = ULONG_MAX;
  unsigned char uc;
  if (u_a > UCHAR_MAX) {
    /* Handle error */
  } else {
    uc = (unsigned char)u_a; /* Cast eliminates warning */
  }
  /* ... */
}

```
Conversions from unsigned types with greater precision to unsigned types with less precision require only the upper bounds to be checked.

## Noncompliant Code Example (time_t Return Value)

The `time()` function returns the value `(time_t)(-1)` to indicate that the calendar time is not available. The C Standard requires that the `time_t` type is only a *real type* capable of representing time. (The integer and real floating types are collectively called real types.) It is left to the implementor to decide the best real type to use to represent time. If `time_t` is implemented as an unsigned integer type with less precision than a signed `int`, the return value of `time()` will never compare equal to the integer literal `-1`.

```cpp
#include <time.h>
 
void func(void) {
  time_t now = time(NULL);
  if (now != -1) {
    /* Continue processing */
  }
}
```

## Compliant Solution (time_t Return Value)

To ensure the comparison is properly performed, the return value of `time()` should be compared against `-1` cast to type `time_t`:

```cpp
#include <time.h>
 
void func(void) {
  time_t now = time(NULL);
  if (now != (time_t)-1) {
    /* Continue processing */
  }
}
```
This solution is in accordance with [INT18-C. Evaluate integer expressions in a larger size before comparing or assigning to that size](https://wiki.sei.cmu.edu/confluence/display/c/INT18-C.+Evaluate+integer+expressions+in+a+larger+size+before+comparing+or+assigning+to+that+size). Note that `(time_+t)-1` also complies with **INT31-C-EX3**.

## Noncompliant Code Example (memset())

For historical reasons, certain C Standard functions accept an argument of type `int` and convert it to either `unsigned char` or plain `char`. This conversion can result in unexpected behavior if the value cannot be represented in the smaller type. The second argument to `memset()` is an example; it indicates what byte to store in the range of memory indicated by the first and third arguments. If the second argument is outside the range of a `signed char` or plain `char`, then its higher order bits will typically be truncated. Consequently, this noncompliant solution unexpectedly sets all elements in the array to 0, rather than 4096:

```cpp
#include <string.h>
#include <stddef.h>
 
int *init_memory(int *array, size_t n) {
  return memset(array, 4096, n); 
} 
```

## Compliant Solution (memset())

In general, the `memset()` function should not be used to initialize an integer array unless it is to set or clear all the bits, as in this compliant solution:

```cpp
#include <string.h>
#include <stddef.h>

int *init_memory(int *array, size_t n) {
  return memset(array, 0, n); 
} 
```

## Exceptions

**INT31-C-EX1:** The C Standard defines minimum ranges for standard integer types. For example, the minimum range for an object of type `unsigned short int` is 0 to 65,535, whereas the minimum range for `int` is −32,767 to +32,767. Consequently, it is not always possible to represent all possible values of an `unsigned short int` as an `int`. However, on the IA-32 architecture, for example, the actual integer range is from −2,147,483,648 to +2,147,483,647, meaning that it is quite possible to represent all the values of an `unsigned short int` as an `int` for this architecture. As a result, it is not necessary to provide a test for this conversion on IA-32. It is not possible to make assumptions about conversions without knowing the precision of the underlying types. If these tests are not provided, assumptions concerning precision must be clearly documented, as the resulting code cannot be safely ported to a system where these assumptions are invalid. A good way to document these assumptions is to use static assertions. (See [DCL03-C. Use a static assertion to test the value of a constant expression](https://wiki.sei.cmu.edu/confluence/display/c/DCL03-C.+Use+a+static+assertion+to+test+the+value+of+a+constant+expression).)

**INT31-C-EX2:** Conversion from any integer type with a value between `SCHAR_MIN` and `UCHAR_MAX` to a character type is permitted provided the value represents a character and not an integer.

Conversions to unsigned character types are well defined by C to have modular behavior. A character's value is not misinterpreted by the loss of sign or conversion to a negative number. For example, the Euro symbol `€` is sometimes represented by bit pattern `0x80` which can have the numerical value 128 or −127 depending on the signedness of the type.

Conversions to signed character types are more problematic. The C Standard, subclause 6.3.1.3, paragraph 3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IECTR24731-2-2010)\], says, regarding conversions

> Otherwise, the new type is signed and the value cannot be represented in it; either the result is implementation-defined or an implementation-defined signal is raised.


Furthermore, subclause 6.2.6.2, paragraph 2, says, regarding integer modifications

> If the sign bit is one, the value shall be modified in one of the following ways:— the corresponding value with sign bit 0 is negated (sign and magnitude)— the sign bit has the value −(2M ) (two’s complement);— the sign bit has the value −(2M − 1) (ones’ complement).Which of these applies is implementation-defined, as is whether the value with sign bit 1 and all value bits zero (for the first two), or with sign bit and all value bits 1 (for ones’ complement), is a trap representation or a normal value. \[See note.\]


NOTE: *Two's complement* is shorthand for "radix complement in radix 2." *Ones' complement* is shorthand for "diminished radix complement in radix 2."

Consequently, the standard allows for this code to trap:

```cpp
int i = 128; /* 1000 0000 in binary */
assert(SCHAR_MAX == 127);
signed char c = i; /* can trap */

```
However, platforms where this code traps or produces an unexpected value are rare. According to *[The New C Standard: An Economic and Cultural Commentary](http://www.knosof.co.uk/cbook/cbook.html)* by Derek Jones \[[Jones 2008](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Jones08)\],

> Implementations with such trap representations are thought to have existed in the past. Your author was unable to locate any documents describing such processors.


**INT31-C-EX3:** ISO C, section 7.27.2.4, paragraph 3 says:

> The time function returns the implementation’s best approximation to the current calendar time.


The value (time_t) (−1) is returned if the calendar time is not available.

If `time_t` is an unsigned type, then the expression `((time_t) (-1))` is guaranteed to yield a large positive value.

Therefore, conversion of a negative compile-time constant to an unsigned value with the same or larger width is permitted by this rule. This exception does not apply to conversion of unsigned to signed values, nor does it apply if the resulting value would undergo truncation.

## Risk Assessment

Integer truncation errors can lead to buffer overflows and the execution of arbitrary code by an attacker.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> INT31-C </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported via MISRA C:2012 Rules 10.1, 10.3, 10.4, 10.6 and 10.7 </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.CAST.PC.AVLANG.CAST.PC.CONST2PTRLANG.CAST.PC.INT</strong> <strong>LANG.CAST.COERCELANG.CAST.VALUE</strong> <strong>ALLOC.SIZE.TRUNCMISC.MEM.SIZE.TRUNC</strong> <strong>LANG.MEM.TBA</strong> </td> <td> Cast: arithmetic type/void pointer Conversion: integer constant to pointer Conversion: pointer/integer Coercion alters value Cast alters value Truncation of allocation size Truncation of size Tainted buffer access </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule. However, false warnings may be raised if <code>limits.h</code> is included </td> </tr> <tr> <td> <a> Coverity </a> \* </td> <td> 2017.07 </td> <td> <strong>NEGATIVE_RETURNS</strong> <strong>REVERSE_NEGATIVE</strong> <strong>MISRA_CAST</strong> </td> <td> Can find array accesses, loop bounds, and other expressions that may contain dangerous implied integer conversions that would result in unexpected behavior Can find instances where a negativity check occurs after the negative value has been used for something else Can find instances where an integer expression is implicitly converted to a narrower integer type, where the signedness of an integer value is implicitly converted, or where the type of a complex expression is implicitly converted </td> </tr> <tr> <td> <a> Cppcheck </a> </td> <td> 1.66 </td> <td> <strong>memsetValueOutOfRange</strong> </td> <td> The second argument to <code>memset()</code> cannot be represented as <code>unsigned char</code> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C2850, C2855, C2890, C2895, C2900, C2905, </strong> <strong>C++2850, C++2855, C++2890, </strong> <strong>C++2895, C++2900, </strong> <strong>C++2905, C++3000, C++3010</strong> <strong>DF2851, DF2852, DF2853, DF2856, DF2857, DF2858, DF2891, DF2892, DF2893, DF2896, DF2897, DF2898, DF2901, DF2902, DF2903, DF2906, DF2907, DF2908</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>PORTING.CAST.SIZE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>93 S</strong> <strong>, 433 S</strong> <strong>, 434 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-INT31-a</strong> <strong>CERT_C-INT31-b</strong> <strong>CERT_C-INT31-c</strong> <strong>CERT_C-INT31-d</strong> <strong>CERT_C-INT31-e</strong> <strong>CERT_C-INT31-f</strong> <strong>CERT_C-INT31-g</strong> <strong>CERT_C-INT31-h</strong> <strong>CERT_C-INT31-i</strong> <strong>CERT_C-INT31-j</strong> <strong>CERT_C-INT31-k</strong> <strong>CERT_C-INT31-l</strong> <strong>CERT_C-INT31-m</strong> <strong>CERT_C-INT31-nCERT_C-INT31-o</strong> </td> <td> An expression of essentially Boolean type should always be used where an operand is interpreted as a Boolean value An operand of essentially Boolean type should not be used where an operand is interpreted as a numeric value An operand of essentially character type should not be used where an operand is interpreted as a numeric value An operand of essentially enum type should not be used in an arithmetic operation Shift and bitwise operations should not be performed on operands of essentially signed or enum type An operand of essentially signed or enum type should not be used as the right hand operand to the bitwise shifting operator An operand of essentially unsigned type should not be used as the operand to the unary minus operator The value of an expression shall not be assigned to an object with a narrower essential type The value of an expression shall not be assigned to an object of a different essential type category Both operands of an operator in which the usual arithmetic conversions are performed shall have the same essential type category The second and third operands of the ternary operator shall have the same essential type category The value of a composite expression shall not be assigned to an object with wider essential type If a composite expression is used as one operand of an operator in which the usual arithmetic conversions are performed then the other operand shall not have wider essential type If a composite expression is used as one (second or third) operand of a conditional operator then the other operand shall not have wider essential type Avoid integer overflows </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule INT31-C </a> </td> <td> Checks for: Integer conversion overflownteger conversion overflow, call to memset with unintended value all to memset with unintended value , sign change integer conversion overflowign change integer conversion overflow, tainted sign change conversionainted sign change conversion, unsigned integer conversion overflownsigned integer conversion overflow. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2850, 2851, 2852, 2853, </strong> <strong><strong>2855, 2856, 2857, 2858,</strong></strong> <strong><strong>2890, 2891, 2892, 2893, </strong></strong> <strong><strong>2895, 2896, 2897, 2898</strong></strong> <strong>2900, 2901, 2902, 2903, </strong> <strong>2905, 2906, 2907, 2908</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2850, 2851, 2852, 2853, 2855, 2856, 2857, 2858, </strong> <strong>2890, 2891, 2892, 2893, 2895, 2896, 2897, 2898, </strong> <strong>2900, 2901, 2902, 2903, 2905, 2906, 2907, 2908, </strong> <strong>3000, 3010</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong>V562<a></a></strong> , <strong>V569<a></a></strong> , <strong>V642<a></a></strong> , <strong><a>V676</a></strong> , <strong><a>V716</a></strong> , <strong><a>V721</a></strong> , <strong>V724<a></a></strong> , <strong><a>V732</a></strong> , <strong><a>V739</a></strong> , <strong><a>V784</a></strong> , <strong><a>V793</a></strong> , <strong><a>V1019</a></strong> , <strong><a>V1029</a></strong> , <strong> <a>V1046</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> </td> <td> Supported via MISRA C:2012 Rules 10.1, 10.3, 10.4, 10.6 and 10.7 </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>signed_downcast</strong> </td> <td> Exhaustively verified. </td> </tr> </tbody> </table>
\* Coverity Prevent cannot discover all violations of this rule, so further [verification](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-verification) is necessary.


## Related Vulnerabilities

[CVE-2009-1376](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2009-1376) results from a violation of this rule. In version 2.5.5 of Pidgin, a `size_t` offset is set to the value of a 64-bit unsigned integer, which can lead to truncation \[[xorl 2009](http://xorl.wordpress.com/2009/05/28/cve-2009-1376-pidgin-msn-slp-integer-truncation/)\] on platforms where a `size_t` is implemented as a 32-bit unsigned integer. An attacker can execute arbitrary code by carefully choosing this value and causing a buffer overflow.

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+INT31-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> DCL03-C. Use a static assertion to test the value of a constant expression </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> INT18-C. Evaluate integer expressions in a larger size before comparing or assigning to that size </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> FIO34-C. Distinguish between characters read from a file and EOF or WEOF </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> NUM12-J. Ensure conversions of numeric types to narrower types do not result in lost or misinterpreted data </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Numeric Conversion Errors \[FLC\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 10.1 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 10.3 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 10.4 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 10.6 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 10.7 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-192 </a> , Integer Coercion Error </td> <td> 2017-07-17: CERT: Exact </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-197 </a> , Numeric Truncation Error </td> <td> 2017-06-14: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-681 </a> , Incorrect Conversion between Numeric Types </td> <td> 2017-07-17: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-704 </a> </td> <td> 2017-07-17: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-195 and INT31-C**

CWE-195 = Subset( CWE-192)

INT31-C = Union( CWE-195, list) where list =

* Unsigned-to-signed conversion error
* Truncation that does not change sign
**CWE-197 and INT31-C**

See CWE-197 and FLP34-C

**CWE-194 and INT31-C**

CWE-194 = Subset( CWE-192)

INT31-C = Union( CWE-194, list) where list =

* Integer conversion that truncates significant data, but without loss of sign
**CWE-20 and INT31-C**

See CWE-20 and ERR34-C

**CWE-704 and INT31-C**

CWE-704 = Union( INT31-C, list) where list =

* Improper type casts where either the source or target type is not an integral type
**CWE-681 and INT31-C**

CWE-681 = Union( INT31-C, FLP34-C)

Intersection( INT31-C, FLP34-C) = Ø

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Dowd 2006 </a> \] </td> <td> Chapter 6, "C Language Issues" ("Type Conversions," pp. 223–270) </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.3.1.3, "Signed and Unsigned Integers" </td> </tr> <tr> <td> \[ <a> Jones 2008 </a> \] </td> <td> Section 6.2.6.2, "Integer Types" </td> </tr> <tr> <td> \[ <a> Seacord 2013b </a> \] </td> <td> Chapter 5, "Integer Security" </td> </tr> <tr> <td> \[ <a> Viega 2005 </a> \] </td> <td> Section 5.2.9, "Truncation Error" Section 5.2.10, "Sign Extension Error" Section 5.2.11, "Signed to Unsigned Conversion Error" Section 5.2.12, "Unsigned to Signed Conversion Error" </td> </tr> <tr> <td> \[ <a> Warren 2002 </a> \] </td> <td> Chapter 2, "Basics" </td> </tr> <tr> <td> \[ <a> xorl 2009 </a> \] </td> <td> <a> "CVE-2009-1376: Pidgin MSN SLP Integer Truncation" </a> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [INT31-C: Ensure that integer conversions do not result in lost or misinterpreted data](https://wiki.sei.cmu.edu/confluence/display/c)
