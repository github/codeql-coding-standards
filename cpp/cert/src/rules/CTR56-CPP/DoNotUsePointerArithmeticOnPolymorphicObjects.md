# CTR56-CPP: Do not use pointer arithmetic on polymorphic objects

This query implements the CERT-C++ rule CTR56-CPP:

> Do not use pointer arithmetic on polymorphic objects


## Description

The definition of *pointer arithmetic* from the C++ Standard, \[expr.add\], paragraph 7 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> For addition or subtraction, if the expressions `P` or `Q` have type “pointer to *cv* `T`”, where `T` is different from the cv-unqualified array element type, the behavior is undefined. \[*Note:* In particular, a pointer to a base class cannot be used for pointer arithmetic when the array contains objects of a derived class type. —*end note*\]


Pointer arithmetic does not account for polymorphic object sizes, and attempting to perform pointer arithmetic on a polymorphic object value results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

The C++ Standard, \[expr.sub\], paragraph 1 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], defines array subscripting as being identical to pointer arithmetic. Specifically, it states the following:

> The expression `E1[E2]` is identical (by definition) to `*((E1)+(E2))`.


Do not use pointer arithmetic, including array subscripting, on polymorphic objects.

The following code examples assume the following static variables and class definitions.

```cpp
int globI;
double globD;

struct S {
  int i;
  
  S() : i(globI++) {}
};

struct T : S {
  double d;
  
  T() : S(), d(globD++) {}
};
```

## Noncompliant Code Example (Pointer Arithmetic)

In this noncompliant code example, `f()` accepts an array of `S` objects as its first parameter. However, `main()` passes an array of `T` objects as the first argument to `f()`, which results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) due to the pointer arithmetic used within the `for` loop.

```cpp
#include <iostream>
 
// ... definitions for S, T, globI, globD ...

void f(const S *someSes, std::size_t count) { 
  for (const S *end = someSes + count; someSes != end; ++someSes) {
    std::cout << someSes->i << std::endl;
  }
}

int main() {
  T test[5];
  f(test, 5);
}

```

## Noncompliant Code Example (Array Subscripting)

In this noncompliant code example, the `for` loop uses array subscripting. Since array subscripts are computed using pointer arithmetic, this code also results in undefined behavior.

```cpp
#include <iostream>
 
// ... definitions for S, T, globI, globD ...

void f(const S *someSes, std::size_t count) { 
  for (std::size_t i = 0; i < count; ++i) {
    std::cout << someSes[i].i << std::endl;
  }
}

int main() {
  T test[5];
  f(test, 5);
}
```

## Compliant Solution (Array)

Instead of having an array of objects, an array of pointers solves the problem of the objects being of different sizes, as in this compliant solution.

```cpp
#include <iostream>

// ... definitions for S, T, globI, globD ...

void f(const S * const *someSes, std::size_t count) { 
  for (const S * const *end = someSes + count; someSes != end; ++someSes) {
    std::cout << (*someSes)->i << std::endl;
  }
}

int main() {
  S *test[] = {new T, new T, new T, new T, new T};
  f(test, 5);
  for (auto v : test) {
    delete v;
  }
}

```
The elements in the arrays are no longer polymorphic objects (instead, they are pointers to polymorphic objects), and so there is no [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) with the pointer arithmetic.

## Compliant Solution (std::vector)

Another approach is to use a standard template library (STL) container instead of an array and have `f()` accept iterators as parameters, as in this compliant solution. However, because STL containers require homogeneous elements, pointers are still required within the container.

```cpp
#include <iostream>
#include <vector>

// ... definitions for S, T, globI, globD ...
template <typename Iter>
void f(Iter i, Iter e) {
  for (; i != e; ++i) {
    std::cout << (*i)->i << std::endl;
  }
}

int main() {
  std::vector<S *> test{new T, new T, new T, new T, new T};
  f(test.cbegin(), test.cend());
  for (auto v : test) {
    delete v;
  }
}

```

## Risk Assessment

Using arrays polymorphically can result in memory corruption, which could lead to an attacker being able to execute arbitrary code.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CTR56-CPP </td> <td> High </td> <td> Likely </td> <td> High </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-CTR56</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.PARITH</strong> </td> <td> Pointer Arithmetic </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3073</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CTR56-a</strong> <strong>CERT_CPP-CTR56-b</strong> <strong>CERT_CPP-CTR56-c</strong> </td> <td> Don't treat arrays polymorphically A pointer to an array of derived class objects should not be converted to a base class pointer Do not treat arrays polymorphically </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>567 S</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3073</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V777</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabil) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CTR39-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> ARR39-C. Do not add or subtract a scaled integer to a pointer </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 5.7, "Additive Operators" Subclause 5.2.1, "Subscripting" </td> </tr> <tr> <td> \[ <a> Lockheed Martin 2005 </a> \] </td> <td> AV Rule 96, "Arrays shall not be treated polymorphically" </td> </tr> <tr> <td> \[ <a> Meyers 1996 </a> \] </td> <td> Item 3, "Never Treat Arrays Polymorphically" </td> </tr> <tr> <td> \[ <a> Stroustrup 2006 </a> \] </td> <td> "What's Wrong with Arrays?" </td> </tr> <tr> <td> \[ <a> Sutter 2004 </a> \] </td> <td> Item 100, "Don't Treat Arrays Polymorphically" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CTR56-CPP: Do not use pointer arithmetic on polymorphic objects](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
