# MSC53-CPP: Do not return from a function declared [[noreturn]]

This query implements the CERT-C++ rule MSC53-CPP:

> Do not return from a function declared [[noreturn]]


## Description

The `[[noreturn]]` attribute specifies that a function does not return. The C++ Standard, \[dcl.attr.noreturn\] paragraph 2 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> If a function `f` is called where `f` was previously declared with the `noreturn` attribute and `f` eventually returns, the behavior is undefined.


A function that specifies `[[noreturn]]` can prohibit returning by throwing an exception, entering an infinite loop, or calling another function designated with the `[[noreturn]]` attribute.

## Noncompliant Code Example

In this noncompliant code example, if the value `0` is passed, control will flow off the end of the function, resulting in an implicit return and [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <cstdlib>
 
[[noreturn]] void f(int i) {
  if (i > 0)
    throw "Received positive input";
  else if (i < 0)
    std::exit(0);
}
```

## Compliant Solution

In this compliant solution, the function does not return on any code path.

```cpp
#include <cstdlib>
 
[[noreturn]] void f(int i) {
  if (i > 0)
    throw "Received positive input";
  std::exit(0);
}
```

## Risk Assessment

Returning from a function marked `[[noreturn]]` results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) that might be [exploited](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) to cause data-integrity violations.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MSC53-CPP </td> <td> Medium </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>invalid-noreturn</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-MSC53</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Winvalid-noreturn</code> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.RFNR</strong> </td> <td> Return from noreturn </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2886</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.MSC.NORETURN_FUNC_RETURNS</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MSC53-a</strong> </td> <td> Never return from functions that should not return </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: MSC53-CPP </a> </td> <td> Checks for <code>\[\[noreturn\]\]</code> functions returning to caller (rule fully covered) </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V1082</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>invalid-noreturn</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S935</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability)resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MSC53-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 7.6.3, " <code>noreturn</code> Attribute" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MSC53-CPP: Do not return from a function declared [[noreturn]]](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
