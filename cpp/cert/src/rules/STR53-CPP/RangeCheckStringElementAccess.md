# STR53-CPP: Range check std::string element access

This query implements the CERT-C++ rule STR53-CPP:

> Range check element access


## Description

The `std::string` index operators `const_reference operator[](size_type) const` and `reference operator[](size_type)` return the character stored at the specified position, `pos`. When `pos >= size()`, a reference to an object of type `charT` with value `charT()` is returned. The index operators are unchecked (no exceptions are thrown for range errors), and attempting to modify the resulting out-of-range object results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

Similarly, the `std::string::back()` and `std::string::front()` functions are unchecked as they are defined to call through to the appropriate `operator[]()` without throwing.

Do not pass an out-of-range value as an argument to `std::string::operator[]()`. Similarly, do not call `std::string::back()` or `std::string::front()` on an empty string. This rule is a specific instance of [CTR50-CPP. Guarantee that container indices and iterators are within the valid range](https://wiki.sei.cmu.edu/confluence/display/cplusplus/CTR50-CPP.+Guarantee+that+container+indices+and+iterators+are+within+the+valid+range).

## Noncompliant Code Example

In this noncompliant code example, the value returned by the call to `get_index()` may be greater than the number of elements stored in the string, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <string>
 
extern std::size_t get_index();
 
void f() {
  std::string s("01234567");
  s[get_index()] = '1';
}
```

## Compliant Solution (try/catch)

This compliant solution uses the `std::basic_string::at()` function, which behaves in a similar fashion to the index `operator[]` but throws a `std::out_of_range` exception if `pos >= size().`

```cpp
#include <stdexcept>
#include <string>
extern std::size_t get_index();

void f() {
  std::string s("01234567");
  try {
    s.at(get_index()) = '1';
  } catch (std::out_of_range &) {
    // Handle error
  }
}
```

## Compliant Solution (Range Check)

This compliant solution checks that the value returned by `get_index()` is within a valid range before calling `operator[]().`

```cpp
#include <string>

extern std::size_t get_index();

void f() {
  std::string s("01234567");
  std::size_t i = get_index();
  if (i < s.length()) {
    s[i] = '1';
  } else {
    // Handle error
  }
}
```

## Noncompliant Code Example

This noncompliant code example attempts to replace the initial character in the string with a capitalized equivalent. However, if the given string is empty, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <string>
#include <locale>

void capitalize(std::string &s) {
  std::locale loc;
  s.front() = std::use_facet<std::ctype<char>>(loc).toupper(s.front());
}
```

## Compliant Solution

In this compliant solution, the call to `std::string::front()` is made only if the string is not empty.

```cpp
#include <string>
#include <locale>

void capitalize(std::string &s) {
  if (s.empty()) {
    return;
  }

  std::locale loc;
  s.front() = std::use_facet<std::ctype<char>>(loc).toupper(s.front());
}
```

## Risk Assessment

Unchecked element access can lead to out-of-bound reads and writes and write-anywhere [exploits](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit). These exploits can, in turn, lead to the execution of arbitrary code with the permissions of the vulnerable process.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR53-CPP </td> <td> High </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>assert_failure</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.BO</strong> <strong>LANG.MEM.BU</strong> <strong>LANG.MEM.TBA</strong> <strong>LANG.MEM.TO</strong> <strong>LANG.MEM.TU</strong> </td> <td> Buffer overrun Buffer underrun Tainted buffer access Type overrun Type underrun </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3162, C++3163, C++3164, C++3165</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-STR53-a</strong> </td> <td> Guarantee that container indices are within the valid range </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: STR53-CPP </a> </td> <td> Checks for: Array access out of boundsrray access out of bounds, array access with tainted indexrray access with tainted index, pointer dereference with tainted offsetointer dereference with tainted offset. Rule partially covered. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+STR39-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> CTR50-CPP. Guarantee that container indices and iterators are within the valid range </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 21.4.5, " <code>basic_string</code> Element Access" </td> </tr> <tr> <td> \[ <a> Seacord 2013 </a> \] </td> <td> Chapter 2, "Strings" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [STR53-CPP: Range check element access](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
