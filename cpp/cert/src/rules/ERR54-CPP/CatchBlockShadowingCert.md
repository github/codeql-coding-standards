# ERR54-CPP: Catch handlers should order their parameter types from most derived to least derived

This query implements the CERT-C++ rule ERR54-CPP:

> Catch handlers should order their parameter types from most derived to least derived


## Description

The C++ Standard, \[except.handle\], paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> The handlers for a try block are tried in order of appearance. That makes it possible to write handlers that can never be executed, for example by placing a handler for a derived class after a handler for a corresponding base class.


Consequently, if two handlers catch exceptions that are derived from the same base class (such as `std::exception`), the most derived exception must come first.

## Noncompliant Code Example

In this noncompliant code example, the first handler catches all exceptions of class `B`, as well as exceptions of class `D`, since they are also of class `B`. Consequently, the second handler does not catch any exceptions.

```cpp
// Classes used for exception handling
class B {};
class D : public B {};

void f() {
  try {
    // ...
  } catch (B &b) {
    // ...
  } catch (D &d) {
    // ...
  }
}
```

## Compliant Solution

In this compliant solution, the first handler catches all exceptions of class `D`, and the second handler catches all the other exceptions of class `B`.

```cpp
// Classes used for exception handling
class B {};
class D : public B {};

void f() {
  try {
    // ...
  } catch (D &d) {
    // ...
  } catch (B &b) {
    // ...
  }
}
```

## Risk Assessment

Exception handlers with inverted priorities cause unexpected control flow when an exception of the derived type occurs.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR54-CPP </td> <td> Medium </td> <td> Likely </td> <td> Low </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>exception-caught-by-earlier-handler</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-ERR54</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wexceptions</code> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.UCTCH</strong> </td> <td> Unreachable Catch </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CP1.ERR36</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4030, C++4639</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.CATCH.NOALL</strong> <strong>MISRA.CATCH.WRONGORD</strong> <strong> </strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>541 S, 556 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR54-a</strong> </td> <td> Where multiple handlers are provided in a single try-catch statement or function-try-block for a derived class and some or all of its bases, the handlers shall be ordered most-derived to base class </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: ERR54-CPP </a> </td> <td> Checks for: Exception handlers not ordered from most-derived to base classxception handlers not ordered from most-derived to base class, incorrect order of ellipsis handlerncorrect order of ellipsis handler. Rule fully covered. </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4030, 4639</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V759</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>exception-caught-by-earlier-handler</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S1045</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability)resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR36-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> \[ <a> MISRA 08 </a> \] </td> <td> Rule 15-3-6 (Required) Rule 15-3-7 (Required) </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 15.3, "Handling an Exception" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR54-CPP: Catch handlers should order their parameter types from most derived to least derived](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
