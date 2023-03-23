# EXP42-C: Do not compare padding data

This query implements the CERT-C rule EXP42-C:

> Do not compare padding data


## Description

The C Standard, 6.7.2.1 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> There may be unnamed padding within a structure object, but not at its beginning. . . . There may be unnamed padding at the end of a structure or union.


Subclause 6.7.9, paragraph 9, states that

> unnamed members of objects of structure and union type do not participate in initialization. Unnamed members of structure objects have indeterminate value even after initialization.


The only exception is that padding bits are set to zero when a static or thread-local object is implicitly initialized (paragraph10):

> If an object that has automatic storage duration is not initialized explicitly, its value is indeterminate. If an object that has static or thread storage duration is not initialized explicitly, then:


— if it is an aggregate, every member is initialized (recursively) according to these rules, and any padding is initialized to zero bits;

— if it is a union, the first named member is initialized (recursively) according to these rules, and any padding is initialized to zero bits;

Because these padding values are unspecified, attempting a byte-by-byte comparison between structures can lead to incorrect results \[[Summit 1995](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Summit95)\].

## Noncompliant Code Example

In this noncompliant code example, `memcmp()` is used to compare the contents of two structures, including any padding bytes:

```cpp
#include <string.h>
 
struct s {
  char c;
  int i;
  char buffer[13];
};
 
void compare(const struct s *left, const struct s *right) {  
  if ((left && right) &&
      (0 == memcmp(left, right, sizeof(struct s)))) {
    /* ... */
  }
}
```

## Compliant Solution

In this compliant solution, all of the fields are compared manually to avoid comparing any padding bytes:

```cpp
#include <string.h>
 
struct s {
  char c;
  int i;
  char buffer[13];
};
 
void compare(const struct s *left, const struct s *right) {  
  if ((left && right) &&
      (left->c == right->c) &&
      (left->i == right->i) &&
      (0 == memcmp(left->buffer, right->buffer, 13))) {
    /* ... */
  }
}
```

## Exceptions

**EXP42-C-EX1**: A structure can be defined such that the members are aligned properly or the structure is packed using implementation-specific packing instructions. This is true only when the members' data types have no padding bits of their own and when their object representations are the same as their value representations. This frequently is not true for the `_Bool` type or floating-point types and need not be true for pointers. In such cases, the compiler does not insert padding, and use of functions such as `memcmp()` is acceptable.

This compliant example uses the [\#pragma pack](http://msdn.microsoft.com/en-us/library/2e70t5y1.aspx) compiler extension from Microsoft Visual Studio to ensure the structure members are packed as tightly as possible:

```cpp
#include <string.h>
 
#pragma pack(push, 1)
struct s {
  char c;
  int i;
  char buffer[13];
};
#pragma pack(pop)
 
void compare(const struct s *left, const struct s *right) {  
  if ((left && right) &&
      (0 == memcmp(left, right, sizeof(struct s)))) {
    /* ... */
  }
}
```

## Risk Assessment

Comparing padding bytes, when present, can lead to [unexpected program behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP42-C </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>memcpy-with-padding</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP42</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>BADFUNC.MEMCMP</strong> </td> <td> Use of memcmp </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF4726, DF4727, DF4728, DF4729</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.STDLIB.MEMCMP.PTR_ARG_TYPES</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>618 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Cppcheck </a> </td> <td> 1.66 </td> <td> cert.py </td> <td> Detected by the addon cert.py Does not warn about global/static padding data as this is probably initialized to 0 </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-EXP42-a</strong> </td> <td> Don't memcpy or memcmp non-PODs </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>958, 959</strong> </td> <td> Assistance provided: reports structures which require padding between members or after the last member </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule EXP42-C </a> </td> <td> Checks for memory comparison of padding data (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>1488</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>memcpy-with-padding</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>comparable_char_blocks</strong> </td> <td> Exhaustively verified (see <a> the compliant and the non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP42-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Comparison of padding data \[padcomp\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> EXP62-CPP. Do not access the bits of an object representation that are not part of the object's value representation </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.7.2.1, "Structure and Union Specifiers" 6.7.9, "Initialization" </td> </tr> <tr> <td> \[ <a> Summit 1995 </a> \] </td> <td> <a> Question 2.8 </a> <a> Question 2.12 </a> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [EXP42-C: Do not compare padding data](https://wiki.sei.cmu.edu/confluence/display/c)
