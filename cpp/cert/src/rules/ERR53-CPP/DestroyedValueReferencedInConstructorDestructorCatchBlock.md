# ERR53-CPP: Do not reference base classes or class data members in a constructor or destructor function-try-block handler

This query implements the CERT-C++ rule ERR53-CPP:

> Do not reference base classes or class data members in a constructor or destructor function-try-block handler


## Description

When an exception is caught by a *[function-try-block](https://en.cppreference.com/w/cpp/language/function-try-block)* handler in a constructor, any fully constructed base classes and class members of the object are destroyed prior to entering the handler \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]. Similarly, when an exception is caught by a *function-try-block* handler in a destructor, all base classes and nonvariant class members of the objects are destroyed prior to entering the handler. Because of this behavior, the C++ Standard, \[except.handle\], paragraph 10, states the following:

> Referring to any non-static member or base class of an object in the handler for a *function-try-block* of a constructor or destructor for that object results in undefined behavior.


Do not reference base classes or class data members in a constructor or destructor *function-try-block* handler. Doing so results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

In this noncompliant code example, the constructor for class `C` handles exceptions with a *function-try-block*. However, it generates [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) by inspecting its member field `str`.

```cpp
#include <string>
 
class C {
  std::string str;
 
public:
  C(const std::string &s) try : str(s) {
    // ...
  } catch (...) {
    if (!str.empty()) {
      // ...
    }
  }
};

```

## Compliant Solution

In this compliant solution, the handler inspects the constructor parameter rather than the class data member, thereby avoiding [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <string>

class C {
  std::string str;

public:
  C(const std::string &s) try : str(s) {
    // ...
  } catch (...) {
    if (!s.empty()) {
      // ...
    }
  }
};
```

## Risk Assessment

Accessing nonstatic data in a constructor's exception handler or a destructor's exception handler leads to [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR53-CPP </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>exception-handler-member-access</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-ERR53</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wexceptions</code> </td> <td> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3510</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.CTOR.TRY.NON_STATIC</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>549 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR53-a</strong> </td> <td> Handlers of a function-try-block implementation of a class constructor or destructor shall not reference nonstatic members from this class or its bases </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: ERR53-CPP </a> </td> <td> Checks for constructor or destructor function-try-block handler referencing base class or class data member (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3510</strong> <strong> </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>exception-handler-member-access</strong> </td> <td> Fully checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability)resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR35-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> \[ <a> MISRA 2008 </a> \] </td> <td> Rule 15-3-3 (Required) </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 15.3, "Handling an Exception" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR53-CPP: Do not reference base classes or class data members in a constructor or destructor function-try-block handler](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
