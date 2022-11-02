# STR52-CPP: Use valid references, pointers, and iterators to reference elements of a basic_string

This query implements the CERT-C++ rule STR52-CPP:

> Use valid references, pointers, and iterators to reference elements of a basic_string


## Description

Since `std::basic_string` is a container of characters, this rule is a specific instance of [CTR51-CPP. Use valid references, pointers, and iterators to reference elements of a container](https://wiki.sei.cmu.edu/confluence/display/cplusplus/CTR51-CPP.+Use+valid+references%2C+pointers%2C+and+iterators+to+reference+elements+of+a+container). As a container, it supports iterators just like other containers in the Standard Template Library. However, the `std::basic_string` template class has unusual invalidation semantics. The C++ Standard, \[string.require\], paragraph 5 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> References, pointers, and iterators referring to the elements of a `basic_string` sequence may be invalidated by the following uses of that `basic_string` object:


* As an argument to any standard library function taking a reference to non-const `basic_string` as an argument.
* Calling non-const member functions, except `operator[]`, `at`, `front`, `back`, `begin`, `rbegin`, `end`, and `rend`.
Examples of standard library functions taking a reference to non-`const` `std::basic_string` are `std::swap()`, `::operator>>(basic_istream &, string &)`, and `std::getline()`.

Do not use an invalidated reference, pointer, or iterator because doing so results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

Noncompliant Code Example

This noncompliant code example copies `input` into a `std::string`, replacing semicolon (`;)` characters with spaces. This example is noncompliant because the iterator `loc` is invalidated after the first call to `insert()`. The behavior of subsequent calls to `insert()` is undefined.

```cpp
#include <string>
 
void f(const std::string &input) {
  std::string email;

  // Copy input into email converting ";" to " "
  std::string::iterator loc = email.begin();
  for (auto i = input.begin(), e = input.end(); i != e; ++i, ++loc) {
    email.insert(loc, *i != ';' ? *i : ' ');
  }
}
```

## Compliant Solution (std::string::insert())

In this compliant solution, the value of the iterator `loc` is updated as a result of each call to `insert()` so that the invalidated iterator is never accessed. The updated iterator is then incremented at the end of the loop.

```cpp
#include <string>
 
void f(const std::string &input) {
  std::string email;

  // Copy input into email converting ";" to " "
  std::string::iterator loc = email.begin();
  for (auto i = input.begin(), e = input.end(); i != e; ++i, ++loc) {
    loc = email.insert(loc, *i != ';' ? *i : ' ');
  }
}

```

## Compliant Solution (std::replace())

This compliant solution uses a standard algorithm to perform the replacement. When possible, using a generic algorithm is preferable to inventing your own solution.

```cpp
#include <algorithm>
#include <string>
 
void f(const std::string &input) {
  std::string email{input};
  std::replace(email.begin(), email.end(), ';', ' ');
}
```

## Noncompliant Code Example

In this noncompliant code example, `data` is invalidated after the call to `replace()`, and so its use in `g()` is undefined behavior.

```cpp
#include <iostream>
#include <string>
 
extern void g(const char *);
 
void f(std::string &exampleString) {
  const char *data = exampleString.data();
  // ...
  exampleString.replace(0, 2, "bb");
  // ...
  g(data);
}
```

## Compliant Solution

In this compliant solution, the pointer to `exampleString`'s internal buffer is not generated until after the modification from `replace()` has completed.

```cpp
#include <iostream>
#include <string>

extern void g(const char *);

void f(std::string &exampleString) {
  // ...
  exampleString.replace(0, 2, "bb");
  // ...
  g(exampleString.data());
}
```

## Risk Assessment

Using an invalid reference, pointer, or iterator to a string object could allow an attacker to run arbitrary code.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR52-CPP </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>ALLOC.UAF</strong> </td> <td> Use After Free </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4746, C++4747, C++4748, C++4749</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-STR52-a</strong> </td> <td> Use valid references, pointers, and iterators to reference elements of a basic_string </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+STR38-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> CTR51-CPP. Use valid references, pointers, and iterators to reference elements of a container </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 21.4.1, " <code>basic_string</code> General Requirements" </td> </tr> <tr> <td> \[ <a> Meyers 2001 </a> \] </td> <td> Item 43, "Prefer Algorithm Calls to Hand-written Loops" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [STR52-CPP: Use valid references, pointers, and iterators to reference elements of a basic_string](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
