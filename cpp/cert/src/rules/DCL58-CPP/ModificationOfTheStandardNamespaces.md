# DCL58-CPP: Do not modify the standard namespaces

This query implements the CERT-C++ rule DCL58-CPP:

> Do not modify the standard namespaces


## Description

Namespaces introduce new declarative regions for declarations, reducing the likelihood of conflicting identifiers with other declarative regions. One feature of namespaces is that they can be further extended, even within separate translation units. For instance, the following declarations are well-formed.

```cpp
namespace MyNamespace {
int length;
}
 
namespace MyNamespace {
int width;
}
 
void f() {
  MyNamespace::length = MyNamespace::width = 12;
}
```
The standard library introduces the namespace `std` for standards-provided declarations such as `std::string`, `std::vector`, and `std::for_each`. However, it is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) to introduce new declarations in namespace `std` except under special circumstances. The C++ Standard, \[namespace.std\], paragraphs 1 and 2 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> <sup>1</sup> The behavior of a C++ program is undefined if it adds declarations or definitions to namespace `std` or to a namespace within namespace `std` unless otherwise specified. A program may add a template specialization for any standard library template to namespace `std` only if the declaration depends on a user-defined type and the specialization meets the standard library requirements for the original template and is not explicitly prohibited.


<sup>2</sup> The behavior of a C++ program is undefined if it declares

— an explicit specialization of any member function of a standard library class template, or— an explicit specialization of any member function template of a standard library class or class template, or— an explicit or partial specialization of any member class template of a standard library class or class template.

In addition to restricting extensions to the the namespace `std`, the C++ Standard, \[namespace.posix\], paragraph 1, further states the following:

> The behavior of a C++ program is undefined if it adds declarations or definitions to namespace `posix` or to a namespace within namespace `posix` unless otherwise specified. The namespace `posix` is reserved for use by ISO/IEC 9945 and other POSIX standards.


Do not add declarations or definitions to the standard namespaces `std` or `posix`, or to a namespace contained therein, except for a template specialization that depends on a user-defined type that meets the standard library requirements for the original template.

The Library Working Group, responsible for the wording of the Standard Library section of the C++ Standard, has an unresolved [issue](http://www.open-std.org/jtc1/sc22/wg21/docs/lwg-active.html#2139) on the definition of *user-defined type*. Although the Library Working Group has no official stance on the definition \[[INCITS 2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-INCITS2014)\], we define it to be any `class`, `struct`, `union`, or `enum` that is not defined within namespace `std` or a namespace contained within namespace `std`. Effectively, it is a user-provided type instead of a standard library–provided type.

## Noncompliant Code Example

In this noncompliant code example, the declaration of `x` is added to the namespace `std`, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
namespace std {
int x;
}

```

## Compliant Solution

This compliant solution assumes the intention of the programmer was to place the declaration of `x` into a namespace to prevent collisions with other global identifiers. Instead of placing the declaration into the namespace `std`, the declaration is placed into a namespace without a reserved name.

```cpp
namespace nonstd {
int x;
}

```

## Noncompliant Code Example

In this noncompliant code example, a template specialization of `std::plus` is added to the namespace `std` in an attempt to allow `std::plus` to concatenate a `std::string` and `MyString` object. However, because the template specialization is of a standard library–provided type (`std::string`), this code results in undefined behavior.

```cpp
#include <functional>
#include <iostream>
#include <string>

class MyString {
  std::string data;
  
public:
  MyString(const std::string &data) : data(data) {}
  
  const std::string &get_data() const { return data; }
};

namespace std {
template <>
struct plus<string> : binary_function<string, MyString, string> {
  string operator()(const string &lhs, const MyString &rhs) const {
    return lhs + rhs.get_data();
  }
};
}

void f() {
  std::string s1("My String");
  MyString s2(" + Your String");
  std::plus<std::string> p;
  
  std::cout << p(s1, s2) << std::endl;
}

```

## Compliant Solution

The interface for `std::plus` requires that both arguments to the function call operator and the return type are of the same type. Because the attempted specialization in the noncompliant code example results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior), this compliant solution defines a new `std::binary_function` derivative that can add a `std::string` to a `MyString` object without requiring modification of the namespace `std`.

```cpp
#include <functional>
#include <iostream>
#include <string>

class MyString {
  std::string data;
  
public:
  MyString(const std::string &data) : data(data) {}
  
  const std::string &get_data() const { return data; }
};

struct my_plus : std::binary_function<std::string, MyString, std::string> {
  std::string operator()(const std::string &lhs, const MyString &rhs) const {
    return lhs + rhs.get_data();
  }
};

void f() {
  std::string s1("My String");
  MyString s2(" + Your String");
  my_plus p;
  
  std::cout << p(s1, s2) << std::endl;
}
```

## Compliant Solution

In this compliant solution, a specialization of `std::plus` is added to the `std` namespace, but the specialization depends on a user-defined type and meets the Standard Template Library requirements for the original template, so it complies with this rule. However, because `MyString` can be constructed from `std::string`, this compliant solution involves invoking a converting constructor whereas the previous compliant solution does not.

```cpp
#include <functional>
#include <iostream>
#include <string>
 
class MyString {
  std::string data;
   
public:
  MyString(const std::string &data) : data(data) {}
   
  const std::string &get_data() const { return data; }
};
 
namespace std {
template <>
struct plus<MyString> {
  MyString operator()(const MyString &lhs, const MyString &rhs) const {
    return lhs.get_data() + rhs.get_data();
  }
};
}
 
void f() {
  std::string s1("My String");
  MyString s2(" + Your String");
  std::plus<MyString> p;
   
  std::cout << p(s1, s2).get_data() << std::endl;
}
```

## Risk Assessment

Altering the standard namespace can cause [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) in the C++ standard library.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL58-CPP </td> <td> High </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-DCL58</strong> </td> <td> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3180, C++3181, C++3182</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.DCL.STD_NS_MODIFIED </strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-DCL58-a</strong> </td> <td> Do not modify the standard namespaces 'std' and 'posix' </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: DCL58-CPP </a> </td> <td> Checks for modification of standard namespaces (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4032, 4035, <strong>4631</strong> </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V1061</a></strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S3470</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+DCL58-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> DCL51-CPP. Do not declare or define a reserved identifier </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> INCITS 2014 </a> \] </td> <td> Issue 2139, "What Is a <em> User-Defined </em> Type?" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 17.6.4.2.1, "Namespace <code>std</code> " Subclause 17.6.4.2.2, "Namespace <code>posix</code> " </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [DCL58-CPP: Do not modify the standard namespaces](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
