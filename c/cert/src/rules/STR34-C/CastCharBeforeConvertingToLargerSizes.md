# STR34-C: Cast characters to unsigned char before converting to larger integer sizes

This query implements the CERT-C rule STR34-C:

> Cast characters to unsigned char before converting to larger integer sizes


## Description

Signed character data must be converted to `unsigned char` before being assigned or converted to a larger signed type. This rule applies to both `signed char` and (plain) `char` characters on implementations where `char` is defined to have the same range, representation, and behaviors as `signed char`.

However, this rule is applicable only in cases where the character data may contain values that can be interpreted as negative numbers. For example, if the `char` type is represented by a two's complement 8-bit value, any character value greater than +127 is interpreted as a negative value.

This rule is a generalization of [STR37-C. Arguments to character-handling functions must be representable as an unsigned char](https://wiki.sei.cmu.edu/confluence/display/c/STR37-C.+Arguments+to+character-handling+functions+must+be+representable+as+an+unsigned+char).

## Noncompliant Code Example

This noncompliant code example is taken from a [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) in bash versions 1.14.6 and earlier that led to the release of CERT Advisory [CA-1996-22](http://www.cert.org/advisories/CA-1996-22.html). This vulnerability resulted from the sign extension of character data referenced by the `c_str` pointer in the `yy_string_get()` function in the `parse.y` module of the bash source code:

```cpp
static int yy_string_get(void) {
  register char *c_str;
  register int c;

  c_str = bash_input.location.string;
  c = EOF;

  /* If the string doesn't exist or is empty, EOF found */
  if (c_str && *c_str) {
    c = *c_str++;
    bash_input.location.string = c_str;
  }
  return (c);
}

```
The `c_str` variable is used to traverse the character string containing the command line to be parsed. As characters are retrieved from this pointer, they are stored in a variable of type `int`. For implementations in which the `char` type is defined to have the same range, representation, and behavior as `signed char`, this value is sign-extended when assigned to the `int` variable. For character code 255 decimal (−1 in two's complement form), this sign extension results in the value −1 being assigned to the integer, which is indistinguishable from `EOF`.

## Noncompliant Code Example

This problem can be repaired by explicitly declaring the `c_str` variable as `unsigned char`:

```cpp
static int yy_string_get(void) {
  register unsigned char *c_str;
  register int c;

  c_str = bash_input.location.string;
  c = EOF;

  /* If the string doesn't exist or is empty, EOF found */
  if (c_str && *c_str) {
    c = *c_str++;
    bash_input.location.string = c_str;
  }
  return (c);
}

```
This example, however, violates [STR04-C. Use plain char for characters in the basic character set](https://wiki.sei.cmu.edu/confluence/display/c/STR04-C.+Use+plain+char+for+characters+in+the+basic+character+set).

## Compliant Solution

In this compliant solution, the result of the expression `*c_str++` is cast to `unsigned char` before assignment to the `int` variable `c`:

```cpp
static int yy_string_get(void) {
  register char *c_str;
  register int c;

  c_str = bash_input.location.string;
  c = EOF;

  /* If the string doesn't exist or is empty, EOF found */
  if (c_str && *c_str) {
    /* Cast to unsigned type */
    c = (unsigned char)*c_str++;

    bash_input.location.string = c_str;
  }
  return (c);
}

```

## Noncompliant Code Example

In this noncompliant code example, the cast of `*s` to `unsigned int` can result in a value in excess of `UCHAR_MAX` because of integer promotions, a violation of [ARR30-C. Do not form or use out-of-bounds pointers or array subscripts](https://wiki.sei.cmu.edu/confluence/display/c/ARR30-C.+Do+not+form+or+use+out-of-bounds+pointers+or+array+subscripts):

```cpp
#include <limits.h>
#include <stddef.h>
 
static const char table[UCHAR_MAX + 1] = { 'a' /* ... */ };

ptrdiff_t first_not_in_table(const char *c_str) {
  for (const char *s = c_str; *s; ++s) {
    if (table[(unsigned int)*s] != *s) {
      return s - c_str;
    }
  }
  return -1;
}

```

## Compliant Solution

This compliant solution casts the value of type `char` to `unsigned char` before the implicit promotion to a larger type:

```cpp
#include <limits.h>
#include <stddef.h>
 
static const char table[UCHAR_MAX + 1] = { 'a' /* ... */ };

ptrdiff_t first_not_in_table(const char *c_str) {
  for (const char *s = c_str; *s; ++s) {
    if (table[(unsigned char)*s] != *s) {
      return s - c_str;
    }
  }
  return -1;
}

```

## Risk Assessment

Conversion of character data resulting in a value in excess of `UCHAR_MAX` is an often-missed error that can result in a disturbingly broad range of potentially severe [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR34-C </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>char-sign-conversion</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-STR34</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>MISC.NEGCHAR</strong> </td> <td> Negative Character Value </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule when checking for violations of <a> INT07-C. Use only explicitly signed or unsigned char type for numeric values </a> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2012 Rule 10.1</strong> <strong><strong>MISRA C 2012 Rule 10.2</strong></strong> <strong><strong><strong>MISRA C 2012 Rule 10.3</strong></strong></strong> <strong><strong><strong><strong>MISRA C 2012 Rule 10.4</strong></strong></strong></strong> </td> <td> Implemented Essential type checkers </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.STR34</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 2.95 and later </td> <td> <strong><code><a>-Wchar-subscripts</a></code></strong> </td> <td> Detects objects of type <code>char</code> used as array indices </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C2140, C2141, C2143, C2144, C2145, C2147, C2148, C2149, C2151, C2152, C2153, C2155</strong> <strong>C++3051</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.ETYPE.ASSIGN.2012</strong> <strong>MISRA.ETYPE.CATEGORY.DIFFERENT.2012</strong> <strong>MISRA.ETYPE.INAPPR.OPERAND.BINOP.2012</strong> <strong>MISRA.ETYPE.INAPPR.OPERAND.INDEXPR.2012</strong> <strong>MISRA.ETYPE.INAPPR.OPERAND.TERNOP.2012</strong> <strong>MISRA.ETYPE.INAPPR.OPERAND.UNOP.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>434 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-STR34-b</strong> <strong>CERT_C-STR34-c</strong> <strong>CERT_C-STR34-d</strong> </td> <td> Cast characters to unsigned char before assignment to larger integer sizes An expressions of the 'signed char' type should not be used as an array index Cast characters to unsigned char before converting to larger integer sizes </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>571</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule STR34-C </a> </td> <td> Checks for misuse of sign-extended character value (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2140, 2141, 2143, 2144, </strong> <strong>2145, </strong> <strong>2147, 2148, 2149, </strong> <strong>2151, 2152, </strong> <strong>2153, 2155</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3051 </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>char-sign-conversion</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>out of bounds read</strong> </td> <td> Partially verified (exhaustively detects undefined behavior). </td> </tr> </tbody> </table>


## Related Vulnerabilities

[CVE-2009-0887](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2009-0887) results from a violation of this rule. In Linux PAM (up to version 1.0.3), the `libpam` implementation of `strtok()` casts a (potentially signed) character to an integer for use as an index to an array. An attacker can exploit this vulnerability by inputting a string with non-ASCII characters, causing the cast to result in a negative index and accessing memory outside of the array \[[xorl 2009](http://xorl.wordpress.com/2009/03/26/cve-2009-0887-linux-pam-singedness-issue/)\].

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+STR34-C).

**Related Guidelines**

<table> <tbody> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> STR37-C. Arguments to character-handling functions must be representable as an unsigned char </a> <a> STR04-C. Use plain char for characters in the basic character set </a> <a> ARR30-C. Do not form or use out-of-bounds pointers or array subscripts </a> </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Conversion of signed characters to wider integer types before a check for EOF \[signconv\] </td> </tr> <tr> <td> <a> MISRA-C:2012 </a> </td> <td> Rule 10.1 (required) Rule 10.2 (required) Rule 10.3 (required) Rule 10.4 (required) </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-704 </a> , Incorrect Type Conversion or Cast </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> xorl 2009 </a> \] </td> <td> <a> CVE-2009-0887: Linux-PAM Signedness Issue </a> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [STR34-C: Cast characters to unsigned char before converting to larger integer sizes](https://wiki.sei.cmu.edu/confluence/display/c)
