# STR37-C: Arguments to character-handling functions must be representable as an unsigned char

This query implements the CERT-C rule STR37-C:

> Arguments to character-handling functions must be representable as an unsigned char


## Description

According to the C Standard, 7.4 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\],

> The header `<ctype.h>` declares several functions useful for classifying and mapping characters. In all cases the argument is an `int`, the value of which shall be representable as an `unsigned char` or shall equal the value of the macro `EOF`. If the argument has any other value, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).


See also [undefined behavior 113](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_113).

This rule is applicable only to code that runs on platforms where the `char` data type is defined to have the same range, representation, and behavior as `signed char`.

Following are the character classification functions that this rule addresses:

<table> <tbody> <tr> <td> <code>isalnum()</code> </td> <td> <code>isalpha()</code> </td> <td> <code>isascii()</code> <sup> XSI </sup> </td> <td> <code>isblank()</code> </td> </tr> <tr> <td> <code>iscntrl()</code> </td> <td> <code>isdigit()</code> </td> <td> <code>isgraph()</code> </td> <td> <code>islower()</code> </td> </tr> <tr> <td> <code>isprint()</code> </td> <td> <code>ispunct()</code> </td> <td> <code>isspace()</code> </td> <td> <code>isupper()</code> </td> </tr> <tr> <td> <code>isxdigit()</code> </td> <td> <code>toascii()</code> <sup> XSI </sup> </td> <td> <code>toupper()</code> </td> <td> <code>tolower()</code> </td> </tr> </tbody> </table>
<sup>XSI</sup> denotes an X/Open System Interfaces Extension to ISO/IEC 9945—POSIX. These functions are not defined by the C Standard.


This rule is a specific instance of [STR34-C. Cast characters to unsigned char before converting to larger integer sizes](https://wiki.sei.cmu.edu/confluence/display/c/STR34-C.+Cast+characters+to+unsigned+char+before+converting+to+larger+integer+sizes).

## Noncompliant Code Example

On implementations where plain `char` is signed, this code example is noncompliant because the parameter to `isspace()`, `*t`, is defined as a `const char *`, and this value might not be representable as an `unsigned char`:

```cpp
#include <ctype.h>
#include <string.h>
 
size_t count_preceding_whitespace(const char *s) {
  const char *t = s;
  size_t length = strlen(s) + 1;
  while (isspace(*t) && (t - s < length)) { 
    ++t;
  }
  return t - s;
} 
```
The argument to `isspace()` must be `EOF` or representable as an `unsigned char`; otherwise, the result is undefined.

## Compliant Solution

This compliant solution casts the character to `unsigned char` before passing it as an argument to the `isspace()` function:

```cpp
#include <ctype.h>
#include <string.h>
 
size_t count_preceding_whitespace(const char *s) {
  const char *t = s;
  size_t length = strlen(s) + 1;
  while (isspace((unsigned char)*t) && (t - s < length)) { 
    ++t;
  }
  return t - s;
} 
```

## Risk Assessment

Passing values to character handling functions that cannot be represented as an `unsigned char` to character handling functions is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR37-C </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>ctype-limits</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-STR37</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>MISC.NEGCHAR</strong> </td> <td> Negative character value </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Could detect violations of this rule by seeing if the argument to a character handling function (listed above) is not an <code>unsigned char</code> </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.STR37</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4413, C4414</strong> <strong>C++3051</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>AUTOSAR.STDLIB.CCTYPE.UCHAR</strong> <strong>MISRA.ETYPE.ASSIGN.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>663 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-STR37-a</strong> </td> <td> Do not pass incorrect values to ctype.h library functions </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule STR37-C </a> </td> <td> Checks for invalid use of standard library integer routine (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>4413, 4414</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3051 </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>ctype-limits</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>valid_char</strong> </td> <td> Partially verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+STR37-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> STR34-C. Cast characters to unsigned char before converting to larger integer sizes </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Passing arguments to character-handling functions that are not representable as unsigned char \[chrsgnext\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-704 </a> , Incorrect Type Conversion or Cast </td> <td> 2017-06-14: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-686 and STR37-C**

Intersection( CWE-686, STR37-C) = Ø

STR37-C is not about the type of the argument passed (which is signed int), but about the restrictions placed on the value in this type (must be 0-UCHAR_MAX or EOF). I interpret ‘argument type’ to be specific to the C language, so CWE-686 does not apply to incorrect argument values, just incorrect types (which is relatively rare in C, but still possible).

**CWE-704 and STR37-C**

STR37-C = Subset( STR34-C)

**CWE-683 and STR37-C**

Intersection( CWE-683, STR37-C) = Ø

STR37-C excludes mis-ordered function arguments (assuming they pass type-checking), because there is no easy way to reliably detect violations of CWE-683.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.4, "Character Handling &lt; <code>ctype.h</code> &gt;" </td> </tr> <tr> <td> \[ <a> Kettlewell 2002 </a> \] </td> <td> Section 1.1, "&lt; <code>ctype.h</code> &gt; and Characters Types" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [STR37-C: Arguments to character-handling functions must be representable as an unsigned char](https://wiki.sei.cmu.edu/confluence/display/c)
