# STR51-CPP: Do not attempt to create a std::string from a null pointer

This query implements the CERT-C++ rule STR51-CPP:

> Do not attempt to create a std::string from a null pointer


## Description

The `std::basic_string` type uses the *traits* design pattern to handle implementation details of the various string types, resulting in a series of string-like classes with a common, underlying implementation. Specifically, the `std::basic_string` class is paired with `std::char_traits` to create the `std::string`, `std::wstring`, `std::u16string`, and `std::u32string` classes. The `std::char_traits` class is explicitly specialized to provide policy-based implementation details to the `std::basic_string` type. One such implementation detail is the `std::char_traits::length()` function, which is frequently used to determine the number of characters in a null-terminated string. According to the C++ Standard, \[char.traits.require\], Table 62 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], passing a null pointer to this function is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) because it would result in dereferencing a null pointer.

The following `std::basic_string` member functions result in a call to `std::char_traits::length()`:

* `basic_string::basic_string(const charT *, const Allocator &)`
* `basic_string &basic_string::append(const charT *)`
* `basic_string &basic_string::assign(const charT *)`
* `basic_string &basic_string::insert(size_type, const charT *)`
* `basic_string &basic_string::replace(size_type, size_type, const charT *)`
* `basic_string &basic_string::replace(const_iterator, const_iterator, const charT *)`
* `size_type basic_string::find(const charT *, size_type)`
* `size_type basic_string::rfind(const charT *, size_type)`
* `size_type basic_string::find_first_of(const charT *, size_type)`
* `size_type basic_string::find_last_of(const charT *, size_type)`
* `size_type basic_string::find_first_not_of(const charT *, size_type)`
* `size_type basic_string::find_last_not_of(const charT *, size_type)`
* `int basic_string::compare(const charT *)`
* `int basic_string::compare(size_type, size_type, const charT *)`
* `basic_string &basic_string::operator=(const charT *)`
* `basic_string &basic_string::operator+=(const charT *)`
The following `std::basic_string` nonmember functions result in a call to to `std::char_traits::length()`:
* `basic_string operator+(const charT *, const basic_string&)`
* `basic_string operator+(const charT *, basic_string &&)`
* `basic_string operator+(const basic_string &, const charT *)`
* `basic_string operator+(basic_string &&, const charT *)`
* `bool operator==(const charT *, const basic_string &)`
* `bool operator==(const basic_string &, const charT *)`
* `bool operator!=(const charT *, const basic_string &)`
* `bool operator!=(const basic_string &, const charT *)`
* `bool operator<(const charT *, const basic_string &)`
* `bool operator<(const basic_string &, const charT *)`
* `bool operator>(const charT *, const basic_string &)`
* `bool operator>(const basic_string &, const charT *)`
* `bool operator<=(const charT *, const basic_string &)`
* `bool operator<=(const basic_string &, const charT *)`
* `bool operator>=(const charT *, const basic_string &)`
* `bool operator>=(const basic_string &, const charT *)`
Do not call any of the preceding functions with a null pointer as the `const charT *` argument.

This rule is a specific instance of [EXP34-C. Do not dereference null pointers](https://wiki.sei.cmu.edu/confluence/display/c/EXP34-C.+Do+not+dereference+null+pointers).

**Implementation Details**

Some standard library vendors, such as [libstdc++, ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-libstdcxx)throw a `std::logic_error` when a null pointer is used in the above function calls, though not when calling `std::char_traits::length()`. However, `std::logic_error` is not a requirement of the C++ Standard, and some vendors (e.g., [libc++](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-libcxx) and the [Microsoft Visual Studio STL](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-msvcstl)) do not implement this behavior. For portability, you should not rely on this behavior.

## Noncompliant Code Example

In this noncompliant code example, a `std::string` object is created from the results of a call to `std::getenv()`. However, because `std::getenv()` returns a null pointer on failure, this code can lead to [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) when the environment variable does not exist (or some other error occurs).

```cpp
#include <cstdlib>
#include <string>
 
void f() {
  std::string tmp(std::getenv("TMP"));
  if (!tmp.empty()) {
    // ...
  }
}
```

## Compliant Solution

In this compliant solution, the results from the call to `std::getenv()` are checked for null before the `std::string` object is constructed.

```cpp
#include <cstdlib>
#include <string>
 
void f() {
  const char *tmpPtrVal = std::getenv("TMP");
  std::string tmp(tmpPtrVal ? tmpPtrVal : "");
  if (!tmp.empty()) {
    // ...
  }
}
```

## Risk Assessment

Dereferencing a null pointer is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior), typically [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination). In some situations, however, dereferencing a null pointer can lead to the execution of arbitrary code \[[Jack 2007](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Jack07), [van Sprundel 2006](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-vanSprundel06)\]. The indicated severity is for this more severe case; on platforms where it is not possible to [exploit](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions) a null pointer dereference to execute arbitrary code, the actual severity is low.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR51-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>assert_failure</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.NPD</strong> </td> <td> Null Pointer Dereference </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4770, C++4771, C++4772, C++4773, C++4774</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>NPD.CHECK.CALL.MIGHT</strong> <strong>NPD.CHECK.CALL.MUST</strong> <strong>NPD.CHECK.MIGHT</strong> <strong>NPD.CHECK.MUST</strong> <strong>NPD.CONST.CALL</strong> <strong>NPD.CONST.DEREF</strong> <strong>NPD.FUNC.CALL.MIGHT</strong> <strong>NPD.FUNC.CALL.MUST</strong> <strong>NPD.FUNC.MIGHT</strong> <strong>NPD.FUNC.MUST</strong> <strong>NPD.GEN.CALL.MIGHT</strong> <strong>NPD.GEN.CALL.MUST</strong> <strong>NPD.GEN.MIGHT</strong> <strong>NPD.GEN.MUST</strong> <strong>RNPD.CALL</strong> <strong>RNPD.DEREF</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-STR51-a</strong> </td> <td> Avoid null pointer dereferencing </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vul) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+STR36-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> EXP34-C. Do not dereference null pointers </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.20.3, "Memory Management Functions" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 21.2.1, "Character Trait Requirements" </td> </tr> <tr> <td> \[ <a> Jack 2007 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> van Sprundel 2006 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [STR51-CPP: Do not attempt to create a std::string from a null pointer](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
