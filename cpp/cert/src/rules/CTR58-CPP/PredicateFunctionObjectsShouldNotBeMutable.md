# CTR58-CPP: Predicate function objects should not be mutable

This query implements the CERT-C++ rule CTR58-CPP:

> Predicate function objects should not be mutable


## Description

The C++ standard library implements numerous common algorithms that accept a predicate function object. The C++ Standard, \[algorithms.general\], paragraph 10 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> \[*Note:* Unless otherwise specified, algorithms that take function objects as arguments are permitted to copy those function objects freely. Programmers for whom object identity is important should consider using a wrapper class that points to a noncopied implementation object such as `reference_wrapper<T>`, or some equivalent solution. — *end note*\]


Because it is [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior) whether an algorithm copies a predicate function object, any such object must either

* implement a function call operator that does not mutate state related to the function object's identity, such as nonstatic data members or captured values, or
* wrap the predicate function object in a `std::reference_wrapper<T>` (or an equivalent solution).
Marking the function call operator as `const` is beneficial, but insufficient, because data members with the `mutable` storage class specifier may still be modified within a `const` member function.

## Noncompliant Code Example (Functor)

This noncompliant code example attempts to remove the third item in a container using a predicate that returns `true` only on its third invocation.

```cpp
#include <algorithm>
#include <functional>
#include <iostream>
#include <iterator>
#include <vector>
  
class MutablePredicate : public std::unary_function<int, bool> {
  size_t timesCalled;
public:
  MutablePredicate() : timesCalled(0) {}

  bool operator()(const int &) {
    return ++timesCalled == 3;
  }
};
 
template <typename Iter>
void print_container(Iter b, Iter e) {
  std::cout << "Contains: ";
  std::copy(b, e, std::ostream_iterator<decltype(*b)>(std::cout, " "));
  std::cout << std::endl;
}
 
void f() {
  std::vector<int> v{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  print_container(v.begin(), v.end());

  v.erase(std::remove_if(v.begin(), v.end(), MutablePredicate()), v.end());
  print_container(v.begin(), v.end());
}

```
However, `std::remove_if()` is permitted to construct and use extra copies of its predicate function. Any such extra copies may result in unexpected output.

**Implementation Details**

This program produces the following results using [gcc](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-gcc) 4.8.1 with [libstdc++](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-libstdcxx).

```cpp
Contains: 0 1 2 3 4 5 6 7 8 9  
Contains: 0 1 3 4 6 7 8 9
```
This result arises because `std::remove_if` makes two copies of the predicate before invoking it. The first copy is used to determine the location of the first element in the sequence for which the predicate returns `true`. The subsequent copy is used for removing other elements in the sequence. This results in the third element (`2`) and sixth element (`5`) being removed; two distinct predicate functions are used.

## Noncompliant Code Example (Lambda)

Similar to the functor noncompliant code example, this noncompliant code example attempts to remove the third item in a container using a predicate lambda function that returns `true` only on its third invocation. As with the functor, this lambda carries local state information, which it attempts to mutate within its function call operator.

```cpp
#include <algorithm>
#include <iostream>
#include <iterator>
#include <vector>
  
template <typename Iter>
void print_container(Iter b, Iter e) {
  std::cout << "Contains: ";
  std::copy(b, e, std::ostream_iterator<decltype(*b)>(std::cout, " "));
  std::cout << std::endl;
}
 
void f() {
  std::vector<int> v{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  print_container(v.begin(), v.end());

  int timesCalled = 0;
  v.erase(std::remove_if(v.begin(), v.end(), [timesCalled](const int &) mutable { return ++timesCalled == 3; }), v.end());
  print_container(v.begin(), v.end());
}
```

## Compliant Solution (std::reference_wrapper)

This compliant solution uses `std::ref` to wrap the predicate in a `std::reference_wrapper<T>` object, ensuring that copies of the wrapper object all refer to the same underlying predicate object.

```cpp
#include <algorithm>
#include <functional>
#include <iostream>
#include <iterator>
#include <vector>
  
class MutablePredicate : public std::unary_function<int, bool> {
  size_t timesCalled;
public:
  MutablePredicate() : timesCalled(0) {}

  bool operator()(const int &) {
    return ++timesCalled == 3;
  }
};
 
template <typename Iter>
void print_container(Iter b, Iter e) {
  std::cout << "Contains: ";
  std::copy(b, e, std::ostream_iterator<decltype(*b)>(std::cout, " "));
  std::cout << std::endl;
}
 
void f() {
  std::vector<int> v{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  print_container(v.begin(), v.end());

  MutablePredicate mp;
  v.erase(std::remove_if(v.begin(), v.end(), std::ref(mp)), v.end());
  print_container(v.begin(), v.end());
}
```
The above compliant solution demonstrates using a reference wrapper over a functor object but can similarly be used with a stateful lambda. The code produces the expected results, where only the third element is removed.

```cpp
Contains: 0 1 2 3 4 5 6 7 8 9  
Contains: 0 1 3 4 5 6 7 8 9
```

## Compliant Solution (Iterator Arithmetic)

Removing a specific element of a container does not require a predicate function but can instead simply use `std::vector::erase()`, as in this compliant solution.

```cpp
#include <algorithm>
#include <iostream>
#include <iterator>
#include <vector>
 
template <typename Iter>
void print_container(Iter B, Iter E) {
  std::cout << "Contains: ";
  std::copy(B, E, std::ostream_iterator<decltype(*B)>(std::cout, " "));
  std::cout << std::endl;
}
 
void f() {
  std::vector<int> v{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  print_container(v.begin(), v.end());
  v.erase(v.begin() + 3);
  print_container(v.begin(), v.end());
}
```

## Risk Assessment

Using a predicate function object that contains state can produce unexpected values.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CTR58-CPP </td> <td> Low </td> <td> Likely </td> <td> High </td> <td> <strong> P3 </strong> </td> <td> <strong> L3 </strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3225, C++3226, C++3227, C++3228, C++3229, C++3230, C++3231, C++3232, C++3233, C++3234</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CTR58-a</strong> </td> <td> Make predicates const pure functions </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: CTR58-CPP </a> </td> <td> Checks for function object that modifies its state (rule fully covered). </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3225, 3226, 3227, 3228, 3229, </strong> <strong>3230, 3231, 3232, 3233, 3234 </strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CTR44-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 25.1, "General" </td> </tr> <tr> <td> \[ <a> Meyers 2001 </a> \] </td> <td> Item 39, "Make Predicates Pure Functions" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CTR58-CPP: Predicate function objects should not be mutable](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
