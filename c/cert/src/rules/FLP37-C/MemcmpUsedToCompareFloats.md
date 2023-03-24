# FLP37-C: Do not use object representations to compare floating-point values

This query implements the CERT-C rule FLP37-C:

> Do not use object representations to compare floating-point values


## Description

The object representation for floating-point values is implementation defined. However, an implementation that defines the `__STDC_IEC_559__` macro shall conform to the IEC 60559 floating-point standard and uses what is frequently referred to as IEEE 754 floating-point arithmetic \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\]. The floating-point object representation used by IEC 60559 is one of the most common floating-point object representations in use today.

All floating-point object representations use specific bit patterns to encode the value of the floating-point number being represented. However, equivalence of floating-point values is not encoded solely by the bit pattern used to represent the value. For instance, if the floating-point format supports negative zero values (as IEC 60559 does), the values `-0.0` and `0.0` are equivalent and will compare as equal, but the bit patterns used in the object representation are not identical. Similarly, if two floating-point values are both (the same) NaN, they will not compare as equal, despite the bit patterns being identical, because they are not equivalent.

Do not compare floating-point object representations directly, such as by calling `memcmp()`or its moral equivalents. Instead, the equality operators (`==` and `!=`) should be used to determine if two floating-point values are equivalent.

## Noncompliant Code Example

In this noncompliant code example, `memcmp()` is used to compare two structures for equality. However, since the structure contains a floating-point object, this code may not behave as the programmer intended.

```cpp
#include <stdbool.h>
#include <string.h>
 
struct S {
  int i;
  float f;
};
 
bool are_equal(const struct S *s1, const struct S *s2) {
  if (!s1 && !s2)
    return true;
  else if (!s1 || !s2)
    return false;
  return 0 == memcmp(s1, s2, sizeof(struct S));
}
```

## Compliant Solution

In this compliant solution, the structure members are compared individually:

```cpp
#include <stdbool.h>
#include <string.h>
 
struct S {
  int i;
  float f;
};
 
bool are_equal(const struct S *s1, const struct S *s2) {
  if (!s1 && !s2)
    return true;
  else if (!s1 || !s2)
    return false;
  return s1->i == s2->i &&
         s1->f == s2->f;
}
```

## Risk Assessment

Using the object representation of a floating-point value for comparisons can lead to incorrect equality results, which can lead to unexpected behavior.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FLP37-C </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>memcmp-with-float</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-FLP37</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C5026</strong> <strong>C++3118</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.STDLIB.MEMCMP.PTR_ARG_TYPES</strong> <strong>CERT.MEMCMP.FLOAT_MEMBER</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>618 S</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-FLP37-c</strong> </td> <td> Do not use object representations to compare floating-point values </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2498, 2499</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule FLP37-C </a> </td> <td> Checks for memory comparison of floating-point values (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>5026</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong><a>V1014</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>memcmp-with-float</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> </td> <td> Exhaustively verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FLP37-C).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Annex F, " IEC 60559 floating-point arithmetic" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [FLP37-C: Do not use object representations to compare floating-point values](https://wiki.sei.cmu.edu/confluence/display/c)
