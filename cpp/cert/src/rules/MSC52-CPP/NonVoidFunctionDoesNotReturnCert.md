# MSC52-CPP: Value-returning functions must return a value from all exit paths

This query implements the CERT-C++ rule MSC52-CPP:

> Value-returning functions must return a value from all exit paths


## Description

The C++ Standard, \[stmt.return\], paragraph 2 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> Flowing off the end of a function is equivalent to a `return` with no value; this results in undefined behavior in a value-returning function.


A value-returning function must return a value from all code paths; otherwise, it will result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). This includes returning through less-common code paths, such as from a *[function-try-block](https://en.cppreference.com/w/cpp/language/function-try-block)*, as explained in the C++ Standard, \[except.handle\], paragraph 15:

> Flowing off the end of a *function-try-block* is equivalent to a `return` with no value; this results in undefined behavior in a value-returning function (6.6.3).


## Noncompliant Code Example

In this noncompliant code example, the programmer forgot to return the input value for positive input, so not all code paths return a value.

```cpp
int absolute_value(int a) {
  if (a < 0) {
    return -a;
  }
}
```

## Compliant Solution

In this compliant solution, all code paths now return a value.

```cpp
int absolute_value(int a) {
  if (a < 0) {
    return -a;
  }
  return a;
}
```

## Noncompliant Code Example

In this noncompliant code example, the *function-try-block* handler does not return a value, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) when an exception is thrown.

```cpp
#include <vector>
 
std::size_t f(std::vector<int> &v, std::size_t s) try {
  v.resize(s);
  return s;
} catch (...) {
}

```

## Compliant Solution

In this compliant solution, the exception handler of the *function-try-block* also returns a value.

```cpp
#include <vector>
 
std::size_t f(std::vector<int> &v, std::size_t s) try {
  v.resize(s);
  return s;
} catch (...) {
  return 0;
}
```

## Exceptions

**MSC54-CPP-EX1:**Flowing off the end of the `main()` function is equivalent to a `return 0;` statement, according to the C++ Standard, \[basic.start.main\], paragraph 5 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]. Thus, flowing off the end of the `main()` function does not result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

**MSC54-CPP-EX2:** It is permissible for a control path to not return a value if that code path is never expected to be taken and a function marked `[[noreturn]]` is called as part of that code path or if an exception is thrown, as is illustrated in the following code example.

```cpp
#include <cstdlib>
#include <iostream>
[[noreturn]] void unreachable(const char *msg) {
  std::cout << "Unreachable code reached: " << msg << std::endl;
  std::exit(1);
}

enum E {
  One,
  Two,
  Three
};

int f(E e) {
  switch (e) {
  case One: return 1;
  case Two: return 2;
  case Three: return 3;
  }
  unreachable("Can never get here");
}
```

## Risk Assessment

Failing to return a value from a code path in a value-returning function results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) that might be [exploited](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) to cause data integrity violations.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MSC52-CPP </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>return-implicit</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-MSC52</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <strong>-Wreturn-type</strong> </td> <td> Does not catch all instances of this rule, such as <em> function-try-blocks </em> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.MRS</strong> </td> <td> Missing return statement </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2888</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>FUNCRET.GEN</strong> <strong>FUNCRET.IMPLICIT</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>2 D, 36 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MSC52-a</strong> </td> <td> All exit paths from a function, except main(), with non-void return type shall have an explicit return statement with an expression </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: MSC52-CPP </a> </td> <td> Checks for missing return statements (rule partially covered) </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S935</a></strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>1510</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V591</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>return-implicit</strong> </td> <td> Fully checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MSC52-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.6.1, "Main Function" Subclause 6.6.3, "The <code>return</code> Statement" Subclause 15.3, "Handling an Exception" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MSC52-CPP: Value-returning functions must return a value from all exit paths](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
