# CTR54-CPP: Do not subtract iterators that do not refer to the same container

This query implements the CERT-C++ rule CTR54-CPP:

> Do not subtract iterators that do not refer to the same container


## Description

When two pointers are subtracted, both must point to elements of the same array object or to one past the last element of the array object; the result is the difference of the subscripts of the two array elements. Similarly, when two iterators are subtracted (including via `std::distance()`), both iterators must refer to the same container object or must be obtained via a call to `end()` (or `cend()`) on the same container object.

If two unrelated iterators (including pointers) are subtracted, the operation results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]. Do not subtract two iterators (including pointers) unless both point into the same container or one past the end of the same container.

## Noncompliant Code Example

This noncompliant code example attempts to determine whether the pointer `test` is within the range `[r, r + n]`. However, when `test` does not point within the given range, as in this example, the subtraction produces undefined behavior.

```cpp
#include <cstddef>
#include <iostream>
 
template <typename Ty>
bool in_range(const Ty *test, const Ty *r, size_t n) {
  return 0 < (test - r) && (test - r) < (std::ptrdiff_t)n;
}
 
void f() {
  double foo[10];
  double *x = &foo[0];
  double bar;
  std::cout << std::boolalpha << in_range(&bar, x, 10);
}
```

## Noncompliant Code Example

In this noncompliant code example, the `in_range()` function is implemented using a comparison expression instead of subtraction. The C++ Standard, \[expr.rel\], paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> If two operands `p` and `q` compare equal, `p<=q` and `p>=q` both yield `true` and `p<q` and `p>q` both yield `false`. Otherwise, if a pointer `p` compares greater than a pointer `q`, `p>=q`, `p>q`, `q<=p`, and `q<p` all yield `true` and `p<=q`, `p<q`, `q>=p`, and `q>p` all yield `false`. Otherwise, the result of each of the operators is unspecified.


Thus, comparing two pointers that do not point into the same container or one past the end of the container results in [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedbehavior). Although the following example is an improvement over the previous noncompliant code example, it does not result in portable code and may fail when executed on a segmented memory architecture (such as some antiquated x86 variants). Consequently, it is noncompliant.

```cpp
#include <iostream>
 
template <typename Ty>
bool in_range(const Ty *test, const Ty *r, size_t n) {
  return test >= r && test < (r + n);
}
 
void f() {
  double foo[10];
  double *x = &foo[0];
  double bar;
  std::cout << std::boolalpha << in_range(&bar, x, 10);
}
```

## Noncompliant Code Example

This noncompliant code example is roughly equivalent to the previous example, except that it uses iterators in place of raw pointers. As with the previous example, the `in_range_impl()` function exhibits [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedbehavior) when the iterators do not refer into the same container because the operational semantics of `a < b` on a random access iterator are `b - a > 0`, and `>=` is implemented in terms of `<`.

```cpp
#include <iostream>
#include <iterator>
#include <vector>

template <typename RandIter>
bool in_range_impl(RandIter test, RandIter r_begin, RandIter r_end, std::random_access_iterator_tag) {
  return test >= r_begin && test < r_end;
}
 
template <typename Iter>
bool in_range(Iter test, Iter r_begin, Iter r_end) {
  typename std::iterator_traits<Iter>::iterator_category cat;
  return in_range_impl(test, r_begin, r_end, cat);
}
 
void f() {
  std::vector<double> foo(10);
  std::vector<double> bar(1);
  std::cout << std::boolalpha << in_range(bar.begin(), foo.begin(), foo.end());
}
```

## Noncompliant Code Example

In this noncompliant code example, `std::less<>` is used in place of the `<` operator. The C++ Standard, \[comparisons\], paragraph 14 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> For templates `greater`, `less`, `greater_equal`, and `less_equal`, the specializations for any pointer type yield a total order, even if the built-in operators `<`, `>`, `<=`, `>=` do not.


Although this approach yields a total ordering, the definition of that total ordering is still unspecified by the [implementation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions). For instance, the following statement could result in the assertion triggering for a given, unrelated pair of pointers, `a` and `b`: `assert(std::less<T *>()(a, b) == std::greater<T *>()(a, b));`. Consequently, this noncompliant code example is still nonportable and, on common implementations of `std::less<>`, may even result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) when the `<` operator is invoked.

```cpp
#include <functional>
#include <iostream>
 
template <typename Ty>
bool in_range(const Ty *test, const Ty *r, size_t n) {
  std::less<const Ty *> less;
  return !less(test, r) && less(test, r + n);
}
 
void f() {
  double foo[10];
  double *x = &foo[0];
  double bar;
  std::cout << std::boolalpha << in_range(&bar, x, 10);
}
```

## Compliant Solution

This compliant solution demonstrates a fully portable, but likely inefficient, implementation of `in_range()` that compares `test` against each possible address in the range `[r, n]`. A compliant solution that is both efficient and fully portable is currently unknown.

```cpp
#include <iostream>
 
template <typename Ty>
bool in_range(const Ty *test, const Ty *r, size_t n) {
  auto *cur = reinterpret_cast<const unsigned char *>(r);
  auto *end = reinterpret_cast<const unsigned char *>(r + n);
  auto *testPtr = reinterpret_cast<const unsigned char *>(test);
 
  for (; cur != end; ++cur) {
    if (cur == testPtr) {
      return true;
    }
  }
  return false;
}
 
void f() {
  double foo[10];
  double *x = &foo[0];
  double bar;
  std::cout << std::boolalpha << in_range(&bar, x, 10);
}

```

## Risk Assessment

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CTR54-CPP </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>invalid_pointer_subtractioninvalid_pointer_comparison</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.CUP</strong> <strong>LANG.STRUCT.SUP</strong> </td> <td> Comparison of Unrelated Pointers Subtraction of Unrelated Pointers </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2668, C++2761, C++2762, C++2763, C++2766, C++2767, C++2768</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>70 S, 87 S, 437 S, 438 S</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CTR54-a</strong> <strong>CERT_CPP-CTR54-b</strong> <strong>CERT_CPP-CTR54-c</strong> </td> <td> Do not compare iterators from different containers Do not compare two unrelated pointers Do not subtract two pointers that do not address elements of the same array </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2668, 2761, 2762, 2763, 2766, 2767, 2768</strong> </td> <td> Enforced by QA-CPP </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CTR36-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> ARR36-C. Do not subtract or compare two pointers that do not refer to the same array </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-469 </a> , Use of Pointer Subtraction to Determine Size </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Banahan 2003 </a> \] </td> <td> Section 5.3, "Pointers" Section 5.7, "Expressions Involving Pointers" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 5.7, "Additive Operators" Subclause 5.9, "Relational Operators" Subclause 20.9.5, "Comparisons" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CTR54-CPP: Do not subtract iterators that do not refer to the same container](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
