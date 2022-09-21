# FIO47-C: Use correct number of arguments

This query implements the CERT-C rule FIO47-C:

> Use valid format strings


## Description

The formatted output functions (`fprintf()` and related functions) convert, format, and print their arguments under control of a *format* string. The C Standard, 7.21.6.1, paragraph 3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\], specifies

> The format shall be a multibyte character sequence, beginning and ending in its initial shift state. The format is composed of zero or more directives: ordinary multibyte characters (not **%**), which are copied unchanged to the output stream; and conversion specifications, each of which results in fetching zero or more subsequent arguments, converting them, if applicable, according to the corresponding conversion specifier, and then writing the result to the output stream.


Each *conversion specification* is introduced by the `%` character followed (in order) by

* Zero or more *flags* (in any order), which modify the meaning of the conversion specification
* An optional minimum field *width*
* An optional *precision* that gives the minimum number of digits, the maximum number of digits, or the maximum number of bytes, etc. depending on the conversion specifier
* An optional *length modifier* that specifies the size of the argument
* A *conversion specifier character* that indicates the type of conversion to be applied
Common mistakes in creating format strings include
* Providing an incorrect number of arguments for the format string
* Using invalid conversion specifiers
* Using a flag character that is incompatible with the conversion specifier
* Using a length modifier that is incompatible with the conversion specifier
* Mismatching the argument type and conversion specifier
* Using an argument of type other than `int` for *width* or *precision*
The following table summarizes the compliance of various conversion specifications. The first column contains one or more conversion specifier characters. The next four columns consider the combination of the specifier characters with the various flags (the apostrophe \[`'`\], `-`, `+`, the space character, `#`, and `0`). The next eight columns consider the combination of the specifier characters with the various length modifiers (`h`, `hh`, `l`, `ll`, `j`, `z`, `t`, and `L`).

Valid combinations are marked with a type name; arguments matched with the conversion specification are interpreted as that type. For example, an argument matched with the specifier `%hd` is interpreted as a `short`, so `short` appears in the cell where `d` and `h` intersect. The last column denotes the expected types of arguments matched with the original specifier characters.

Valid and meaningful combinations are marked by the ✓ symbol (save for the length modifier columns, as described previously). Valid combinations that have no effect are labeled *N/E*. Using a combination marked by the ❌ symbol, using a specification not represented in the table, or using an argument of an unexpected type is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See undefined behaviors [153](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_153), [155](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_155), [157](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_157), [158](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_158), [161](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_161), and [162](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_162).)

<table> <tbody> <tr> <th> Conversion Specifier Character </th> <th> <strong><code>'</code></strong> <em> <sup> XSI </sup> </em> </th> <th> <strong><code>-</code> </strong> <strong>+ </strong> <strong>SPACE</strong> </th> <th> <strong> \#</strong> </th> <th> 0 </th> <th> <code>h</code> </th> <th> <code>hh</code> </th> <th> <code>l</code> </th> <th> <code>ll</code> </th> <th> <code>j</code> </th> <th> <code>z</code> </th> <th> <code>t</code> </th> <th> <code>L</code> </th> <th> Argument Type </th> </tr> <tr> <td> <code>d</code> , <code>i</code> </td> <td> ✓ </td> <td> ✓ </td> <td> ❌ </td> <td> ✓ </td> <td> <code>short</code> </td> <td> <code>signed char</code> </td> <td> <code>long</code> </td> <td> <code>long long</code> </td> <td> <code>intmax_t</code> </td> <td> <code>size_t</code> </td> <td> <code>ptrdiff_t</code> </td> <td> ❌ </td> <td> Signed integer </td> </tr> <tr> <td> <code>o</code> </td> <td> ❌ </td> <td> ✓ </td> <td> ✓ </td> <td> ✓ </td> <td> <code>unsigned </code> <code>short</code> </td> <td> <code><code>unsigned </code>char</code> </td> <td> <code><code><code>unsigned </code></code>long</code> </td> <td> <code><code><code>unsigned </code></code>long long</code> </td> <td> <code>uintmax_t</code> </td> <td> <code>size_t</code> </td> <td> <code>ptrdiff_t</code> </td> <td> ❌ </td> <td> Unsigned integer </td> </tr> <tr> <td> <code>u</code> </td> <td> ✓ </td> <td> ✓ </td> <td> ❌ </td> <td> ✓ </td> <td> <code>unsigned short</code> </td> <td> <code><code>unsigned</code> char</code> </td> <td> <code><code><code>unsigned </code></code>long</code> </td> <td> <code><code><code>unsigned </code></code>long long</code> </td> <td> <code>uintmax_t</code> </td> <td> <code>size_t</code> </td> <td> <code>ptrdiff_t</code> </td> <td> ❌ </td> <td> Unsigned integer </td> </tr> <tr> <td> <code>x</code> , <code>X</code> </td> <td> ❌ </td> <td> ✓ </td> <td> ✓ </td> <td> ✓ </td> <td> <code>unsigned short</code> </td> <td> <code><code>unsigned </code>char</code> </td> <td> <code><code><code>unsigned </code></code>long</code> </td> <td> <code><code><code>unsigned </code></code>long long</code> </td> <td> <code>uintmax_t</code> </td> <td> <code>size_t</code> </td> <td> <code>ptrdiff_t</code> </td> <td> ❌ </td> <td> Unsigned integer </td> </tr> <tr> <td> <code>f</code> , <code>F</code> </td> <td> ✓ </td> <td> ✓ </td> <td> ✓ </td> <td> ✓ </td> <td> ❌ </td> <td> ❌ </td> <td> <em> N/E </em> </td> <td> <em> N/E </em> </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <code>long double</code> </td> <td> <code>double</code> <em> or </em> <code>long double</code> </td> </tr> <tr> <td> <code>e</code> , <code>E</code> </td> <td> ❌ </td> <td> ✓ </td> <td> ✓ </td> <td> ✓ </td> <td> ❌ </td> <td> ❌ </td> <td> <em> N/E </em> </td> <td> <em> N/E </em> </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <code>long double</code> </td> <td> <code>double</code> <em> or </em> <code>long double</code> </td> </tr> <tr> <td> <code>g</code> , <code>G</code> </td> <td> ✓ </td> <td> ✓ </td> <td> ✓ </td> <td> ✓ </td> <td> ❌ </td> <td> ❌ </td> <td> <em> N/E </em> </td> <td> <em> N/E </em> </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <code>long double</code> </td> <td> <code>double</code> <em> or </em> <code>long double</code> </td> </tr> <tr> <td> <code>a</code> , <code>A</code> </td> <td> ✓ </td> <td> ✓ </td> <td> ✓ </td> <td> ✓ </td> <td> ❌ </td> <td> ❌ </td> <td> <em> N/E </em> </td> <td> <em> N/E </em> </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <code>long double</code> </td> <td> <code>double</code> <em> or </em> <code>long double</code> </td> </tr> <tr> <td> <code>c</code> </td> <td> ❌ </td> <td> ✓ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <code>wint_t</code> </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <code>int</code> <em> or </em> <code>wint_t</code> </td> </tr> <tr> <td> <code>s</code> </td> <td> ❌ </td> <td> ✓ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> NTWS </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> NTBS <em> or </em> NTWS </td> </tr> <tr> <td> <code>p</code> </td> <td> ❌ </td> <td> ✓ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <code>void\*</code> </td> </tr> <tr> <td> <code>n</code> </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <code>short\*</code> </td> <td> <code>char\*</code> </td> <td> <code>long\*</code> </td> <td> <code>long long\*</code> </td> <td> <code>intmax_t\*</code> </td> <td> <code>size_t\*</code> </td> <td> <code>ptrdiff_t\*</code> </td> <td> ❌ </td> <td> Pointer to integer </td> </tr> <tr> <td> <code>C</code> <em> <sup> XSI </sup> </em> </td> <td> ❌ </td> <td> ✓ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <code>wint_t</code> </td> </tr> <tr> <td> <code>S</code> <em> <sup> XSI </sup> </em> </td> <td> ❌ </td> <td> ✓ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> NTWS </td> </tr> <tr> <td> <code>%</code> </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> ❌ </td> <td> <em> None </em> </td> </tr> </tbody> </table>
SPACE: The space (`" "`) character* N/E*: No effect NTBS: `char*` argument pointing to a null-terminated character string NTWS: `wchar_t*` argument pointing to a null-terminated wide character string XSI: [ISO/IEC 9945-2003](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9945-2003) XSI extension


The formatted input functions (`fscanf()` and related functions) use similarly specified format strings and impose similar restrictions on their format strings and arguments.

Do not supply an unknown or invalid conversion specification or an invalid combination of flag character, precision, length modifier, or conversion specifier to a formatted IO function. Likewise, do not provide a number or type of argument that does not match the argument type of the conversion specifier used in the format string.

Format strings are usually string literals specified at the call site, but they need not be. However, they should not contain [tainted values](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-taintedvalue). (See [FIO30-C. Exclude user input from format strings](https://wiki.sei.cmu.edu/confluence/display/c/FIO30-C.+Exclude+user+input+from+format+strings) for more information.)

## Noncompliant Code Example

Mismatches between arguments and conversion specifications may result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). Compilers may diagnose type mismatches in formatted output function invocations. In this noncompliant code example, the `error_type` argument to `printf()` is incorrectly matched with the `s` specifier rather than with the `d` specifier. Likewise, the `error_msg` argument is incorrectly matched with the `d` specifier instead of the `s` specifier. These usages result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). One possible result of this invocation is that `printf()` will interpret the `error_type` argument as a pointer and try to read a string from the address that `error_type` contains, possibly resulting in an access violation.

```cpp
#include <stdio.h>
 
void func(void) {
  const char *error_msg = "Resource not available to user.";
  int error_type = 3;
  /* ... */
  printf("Error (type %s): %d\n", error_type, error_msg);
  /* ... */
}
```

## Compliant Solution

This compliant solution ensures that the arguments to the `printf()` function match their respective conversion specifications:

```cpp
#include <stdio.h>
 
void func(void) {
  const char *error_msg = "Resource not available to user.";
  int error_type = 3;
  /* ... */
  printf("Error (type %d): %s\n", error_type, error_msg);

  /* ... */
}
```

## Risk Assessment

Incorrectly specified format strings can result in memory corruption or [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO47-C </td> <td> High </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-FIO47</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>IO.INJ.FMT</strong> <strong>MISC.FMTMISC.FMTTYPE</strong> </td> <td> Format string injection Format string Format string type error </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>PW</strong> </td> <td> Reports when the number of arguments differs from the number of required arguments according to the format string </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 4.3.5 </td> <td> </td> <td> Can detect violations of this recommendation when the <code>-Wformat</code> flag is used </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C0161, C0162, C0163, C0164, C0165, C0166, C0167, C0168, C0169, C0170, C0171, C0172, C0173, C0174, C0175, C0176, C0177, C0178, C0179, C0180, C0184, C0185, C0190, C0191, C0192, C0193, C0194, C0195, C0196, C0197, C0198, C0199, C0200, C0201, C0202, C0204, C0206, C0209</strong> <strong>C++3150, C++3151, C++3152, C++3153, C++3154, C++3155, C++3156, C++3157, C++3158, C++3159</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>SV.FMT_STR.PRINT_FORMAT_MISMATCH.BAD</strong> <strong>SV.FMT_STR.PRINT_FORMAT_MISMATCH.UNDESIRED</strong> <strong>SV.FMT_STR.PRINT_IMPROP_LENGTH</strong> <strong>SV.FMT_STR.PRINT_PARAMS_WRONGNUM.FEW</strong> <strong>SV.FMT_STR.PRINT_PARAMS_WRONGNUM.MANY</strong> <strong>SV.FMT_STR.SCAN_FORMAT_MISMATCH.BAD</strong> <strong>SV.FMT_STR.SCAN_FORMAT_MISMATCH.UNDESIRED</strong> <strong>SV.FMT_STR.SCAN_IMPROP_LENGTH</strong> <strong>SV.FMT_STR.SCAN_PARAMS_WRONGNUM.FEW</strong> <strong>SV.FMT_STR.SCAN_PARAMS_WRONGNUM.MANY</strong> <strong>SV.FMT_STR.UNKWN_FORMAT</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>486 S</strong> <strong>589 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-FIO47-a</strong> <strong>CERT_C-FIO47-b</strong> <strong>CERT_C-FIO47-c</strong> <strong>CERT_C-FIO47-d</strong> <strong>CERT_C-FIO47-e</strong> <strong>CERT_C-FIO47-f</strong> </td> <td> There should be no mismatch between the '%s' and '%c' format specifiers in the format string and their corresponding arguments in the invocation of a string formatting function There should be no mismatch between the '%f' format specifier in the format string and its corresponding argument in the invocation of a string formatting function There should be no mismatch between the '%i' and '%d' format specifiers in the string and their corresponding arguments in the invocation of a string formatting function There should be no mismatch between the '%u' format specifier in the format string and its corresponding argument in the invocation of a string formatting function There should be no mismatch between the '%p' format specifier in the format string and its corresponding argument in the invocation of a string formatting function The number of format specifiers in the format string and the number of corresponding arguments in the invocation of a string formatting function should be equal </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>492, 493, 494, 499, 557,</strong> <strong>558, 559, 566, 705, 706,</strong> <strong>719, 816, 855, 2401, 2402,2403, 2404, 2405, 2406, 2407</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule FIO47-C </a> </td> <td> Check for format string specifiers and arguments mismatch (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0161, 0162, 0163, 0164, 0165, 0166, 0167, 0168, </strong> <strong>0169, </strong> <strong>0170, </strong> <strong>0171, 0172, 0173, 0174, 0175, 0176, </strong> <strong>0177, 0178, </strong> <strong>0179 \[U\], </strong> <strong>0180 \[<a>C99</a>\], 0184 \[U\], 0185 <strong>\[U\],</strong> 0190 <strong>\[U\]</strong>, </strong> <strong>0191 <strong>\[U\]</strong>, 0192 <strong>\[U\]</strong>, 0193 <strong>\[U\]</strong>, 0194 <strong>\[U\], </strong></strong> <strong>0195 <strong>\[U\]</strong>, 0196 <strong>\[U\]</strong>, </strong> <strong>0197 <strong>\[U\]</strong>, 0198 <strong>\[U\]</strong>, 0199 <strong>\[U\]</strong>, 0200 <strong>\[U\]</strong>, 0201 <strong>\[U\]</strong>, 0202 <strong>\[I\]</strong>, </strong> <strong>0204 <strong>\[U\]</strong>, 0206 <strong>\[U\]</strong> </strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.20 </td> <td> <strong>V510<a></a></strong> , <strong><a>V576</a></strong> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>match format and arguments</strong> </td> <td> Exhaustively verified (see <a> the compliant and the non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO47-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> FIO00-CPP. Take care when creating format strings </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Using invalid format strings \[invfmtstr\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-686 </a> , Function Call with Incorrect Argument Type </td> <td> 2017-06-29: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-685 </a> </td> <td> 2017-06-29: CERT: Partial overlap </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-686 and FIO47-C**

Intersection( EXP37-C, FIO47-C) =

* Invalid argument types passed to format I/O function
EXP37-C – FIO47-C =
* Invalid argument types passed to non-format I/O function
FIO47-C – EXP37-C =
* Invalid format string, but correctly matches arguments in number and type
Intersection( CWE-686, FIO47-C) =
* Use of format strings that do not match the type of arguments
CWE-686 – FIO47-C =
* Incorrect argument type in functions outside of the printf() family.
FIO47-C – CWE-686 =
* Invalid format strings that still match their arguments in type
**CWE-685 and FIO47-C**

Intersection( CWE-685, FIO47-C) =

* Use of format strings that do not match the number of arguments
CWE-685 – FIO47-C =
* Incorrect argument number in functions outside of the printf() family.
FIO47-C – CWE-685 =
* Invalid format strings that still match their arguments in number
**CWE-134 and FIO47-C**

Intersection( FIO30-C, FIO47-C) =

* Use of untrusted and ill-specified format string
FIO30-C – FIO47-C =
* Use of untrusted, but well-defined format string
FIO47-C – FIO30-C =
* Use of Ill-defined, but trusted format string
FIO47-C = Union(CWE-134, list) where list =
* Using a trusted but invalid format string

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.21.6.1, "The <code>fprintf</code> Function" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [FIO47-C: Use valid format strings](https://wiki.sei.cmu.edu/confluence/display/c)
