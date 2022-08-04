# CTR57-CPP: Provide a valid ordering predicate

This query implements the CERT-C++ rule CTR57-CPP:

> Provide a valid ordering predicate


## Description

Associative containers place a strict weak ordering requirement on their key comparison predicates \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]. A strict weak ordering has the following properties:

* for all `x`: `x < x == false` (irreflexivity)
* for all `x`, `y`: if `x < y` then `!(y < x)` (asymmetry)
* for all `x`, `y`, `z`: if `x < y && y < z `then` x < z` (transitivity)
Providing an invalid ordering predicate for an associative container (e.g., sets, maps, multisets, and multimaps), or as a comparison criterion with the sorting algorithms, can result in erratic behavior or infinite loops \[[Meyers 01](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Meyers01)\]. When an ordering predicate is required for an associative container or a generic standard template library algorithm, the predicate must meet the requirements for inducing a strict weak ordering.

## Noncompliant Code Example

In this noncompliant code example, the `std::set` object is created with a comparator that does not adhere to the strict weak ordering requirement. Specifically, it fails to return false for equivalent values. As a result, the behavior of iterating over the results from `std::set::equal_range` results in [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedbehavior).

```cpp
#include <functional>
#include <iostream>
#include <set>

void f() {
  std::set<int, std::less_equal<int>> s{5, 10, 20};  
  for (auto r = s.equal_range(10); r.first != r.second; ++r.first) {
    std::cout << *r.first << std::endl;
  }
}

```

## Compliant Solution

This compliant solution uses the default comparator with `std::set` instead of providing an invalid one.

```cpp
#include <iostream>
#include <set>

void f() {
  std::set<int> s{5, 10, 20};  
  for (auto r = s.equal_range(10); r.first != r.second; ++r.first) {
    std::cout << *r.first << std::endl;
  }
}

```

## Noncompliant Code Example

In this noncompliant code example, the objects stored in the std::set have an overloaded operator&lt; implementation, allowing the objects to be compared with std::less. However, the comparison operation does not provide a strict weak ordering. Specifically, two sets, x and y, whose i values are both 1, but have differing j values can result in a situation where comp(x, y) and comp(y, x) are both false, failing the asymmetry requirements.

```cpp
#include <iostream>
#include <set>

class S {
  int i, j;

public:
  S(int i, int j) : i(i), j(j) {}
  
  friend bool operator<(const S &lhs, const S &rhs) {
    return lhs.i < rhs.i && lhs.j < rhs.j;
  }
  
  friend std::ostream &operator<<(std::ostream &os, const S& o) {
    os << "i: " << o.i << ", j: " << o.j;
    return os;
  }
};

void f() {
  std::set<S> t{S(1, 1), S(1, 2), S(2, 1)};
  for (auto v : t) {
    std::cout << v << std::endl;
  }
}
```

## Compliant Solution

This compliant solution uses std::tie() to properly implement the strict weak ordering operator&lt; predicate.

```cpp
#include <iostream>
#include <set>
#include <tuple>
 
class S {
  int i, j;
 
public:
  S(int i, int j) : i(i), j(j) {}
  
  friend bool operator<(const S &lhs, const S &rhs) {
    return std::tie(lhs.i, lhs.j) < std::tie(rhs.i, rhs.j);
  }
  
  friend std::ostream &operator<<(std::ostream &os, const S& o) {
    os << "i: " << o.i << ", j: " << o.j;
    return os;
  }
};

void f() {
  std::set<S> t{S(1, 1), S(1, 2), S(2, 1)};  
  for (auto v : t) {
    std::cout << v << std::endl;
  }
}
```

## Risk Assessment

Using an invalid ordering rule can lead to erratic behavior or infinite loops.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CTR57-CPP </td> <td> Low </td> <td> Probable </td> <td> High </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3293</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CTR57-a</strong> </td> <td> For associative containers never use comparison function returning true for equal values </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: CTR57-CPP </a> </td> <td> Checks for predicate lacking strict weak ordering (rule partially covered). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vul) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CTR40-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT Oracle Coding Standard for Java </a> </td> <td> <a> MET10-J. Follow the general contract when implementing the compareTo() method </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 23.2.4, "Associative Containers" </td> </tr> <tr> <td> \[ <a> Meyers 2001 </a> \] </td> <td> Item 21, "Always Have Comparison Functions Return False for Equal Values" </td> </tr> <tr> <td> \[ <a> Sutter 2004 </a> \] </td> <td> Item 83, "Use a Checked STL Implementation" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CTR57-CPP: Provide a valid ordering predicate](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
