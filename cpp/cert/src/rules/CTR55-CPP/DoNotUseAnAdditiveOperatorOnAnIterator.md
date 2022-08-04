# CTR55-CPP: Do not use an additive operator on an iterator if the result would overflow

This query implements the CERT-C++ rule CTR55-CPP:

> Do not use an additive operator on an iterator if the result would overflow


## Description

Expressions that have an integral type can be added to or subtracted from a pointer, resulting in a value of the pointer type. If the resulting pointer is not a valid member of the container, or one past the last element of the container, the behavior of the additive operator is [undefined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). The C++ Standard, \[expr.add\], paragraph 5 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], in part, states the following:

> If both the pointer operand and the result point to elements of the same array object, or one past the last element of the array object, the evaluation shall not produce an overflow; otherwise, the behavior is undefined.


Because iterators are a generalization of pointers, the same constraints apply to additive operators with random access iterators. Specifically, the C++ Standard, \[iterator.requirements.general\], paragraph 5, states the following:

> Just as a regular pointer to an array guarantees that there is a pointer value pointing past the last element of the array, so for any iterator type there is an iterator value that points past the last element of a corresponding sequence. These values are called *past-the-end* values. Values of an iterator `i` for which the expression `*i` is defined are called *dereferenceable*. The library never assumes that past-the-end values are dereferenceable.


Do not allow an expression of integral type to add to or subtract from a pointer or random access iterator when the resulting value would overflow the bounds of the container.

## Noncompliant Code Example (std::vector)

In this noncompliant code example, a random access iterator from a `std::vector` is used in an additive expression, but the resulting value could be outside the bounds of the container rather than a past-the-end value.

```cpp
#include <iostream>
#include <vector>
 
void f(const std::vector<int> &c) {
  for (auto i = c.begin(), e = i + 20; i != e; ++i) {
    std::cout << *i << std::endl;
  }
}
```

## Compliant Solution (std::vector)

This compliant solution assumes that the programmer's intention was to process up to 20 items in the container. Instead of assuming all containers will have 20 or more elements, the size of the container is used to determine the upper bound on the addition.

```cpp
#include <algorithm>
#include <vector>

void f(const std::vector<int> &c) {
  const std::vector<int>::size_type maxSize = 20;
  for (auto i = c.begin(), e = i + std::min(maxSize, c.size()); i != e; ++i) {
    // ...
  }
}
```

## Risk Assessment

If adding or subtracting an integer to a pointer results in a reference to an element outside the array or one past the last element of the array object, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) but frequently leads to a buffer overflow or buffer underrun, which can often be [exploited](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) to run arbitrary code. Iterators and standard template library containers exhibit the same behavior and caveats as pointers and arrays.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CTR55-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3526, C++3527, C++3528, C++3529, C++3530, C++3531, C++3532, C++3533, C++3534</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>567 S</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CTR55-a</strong> </td> <td> Do not add or subtract a constant with a value greater than one from an iterator </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CTR38-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> ARR30-C. Do not form or use out-of-bounds pointers or array subscripts </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE 129 </a> , Unchecked Array Indexing </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Banahan 2003 </a> \] </td> <td> Section 5.3, "Pointers" Section 5.7, "Expressions Involving Pointers" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 5.7, "Additive Operators" Subclause 24.2.1, "In General" </td> </tr> <tr> <td> \[ <a> VU\#162289 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CTR55-CPP: Do not use an additive operator on an iterator if the result would overflow](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
