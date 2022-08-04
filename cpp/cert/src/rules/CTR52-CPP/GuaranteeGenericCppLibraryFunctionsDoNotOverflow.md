# CTR52-CPP: Guarantee that C++ library functions do not overflow

This query implements the CERT-C++ rule CTR52-CPP:

> Guarantee that library functions do not overflow


## Description

Copying data into a container that is not large enough to hold that data results in a buffer overflow. To prevent such errors, data copied to the destination container must be restricted on the basis of the destination container's size, or preferably, the destination container must be guaranteed to be large enough to hold the data to be copied.

[Vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) that result from copying data to an undersized buffer can also involve null-terminated strings. Consult [STR50-CPP. Guarantee that storage for strings has sufficient space for character data and the null terminator](https://wiki.sei.cmu.edu/confluence/display/cplusplus/STR50-CPP.+Guarantee+that+storage+for+strings+has+sufficient+space+for+character+data+and+the+null+terminator) for specific examples of this rule that involve strings.

Copies can be made with the `std::memcpy()` function. However, the `std::memmove()` and `std::memset()` functions can also have the same vulnerabilities because they overwrite a block of memory without checking that the block is valid. Such issues are not limited to C standard library functions; standard template library (STL) generic algorithms, such as `std::copy()`, `std::fill()`, and `std::transform()`, also assume valid output buffer sizes \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\].

## Noncompliant Code Example

STL containers can be subject to the same vulnerabilities as array data types. The `std::copy()` algorithm provides no inherent bounds checking and can lead to a buffer overflow. In this noncompliant code example, a vector of integers is copied from `src` to `dest` using `std::copy()`. Because `std::copy()` does nothing to expand the `dest` vector, the program will overflow the buffer on copying the first element.

```cpp
#include <algorithm>
#include <vector>

void f(const std::vector<int> &src) {
  std::vector<int> dest;
  std::copy(src.begin(), src.end(), dest.begin());
  // ...
}

```
This hazard applies to any algorithm that takes a destination iterator, expecting to fill it with values. Most of the STL algorithms expect the destination container to have sufficient space to hold the values provided.

## Compliant Solution (Sufficient Initial Capacity)

The proper way to use `std::copy()` is to ensure the destination container can hold all the elements being copied to it. This compliant solution enlarges the capacity of the vector prior to the copy operation.

```cpp
#include <algorithm>
#include <vector>
void f(const std::vector<int> &src) {
  // Initialize dest with src.size() default-inserted elements
  std::vector<int> dest(src.size());
  std::copy(src.begin(), src.end(), dest.begin());
  // ...
}

```

## Compliant Solution (Per-Element Growth)

An alternative approach is to supply a `std::back_insert_iterator` as the destination argument. This iterator expands the destination container by one element for each element supplied by the algorithm, which guarantees the destination container will become sufficiently large to hold the elements provided.

```cpp
#include <algorithm>
#include <iterator>
#include <vector>

void f(const std::vector<int> &src) {
  std::vector<int> dest;
  std::copy(src.begin(), src.end(), std::back_inserter(dest));
  // ...
}
```

## Compliant Solution (Assignment)

The simplest solution is to construct `dest` from `src` directly, as in this compliant solution.

```cpp
#include <vector>

void f(const std::vector<int> &src) {
  std::vector<int> dest(src);
  // ...
}
```

## Noncompliant Code Example

In this noncompliant code example, `std::fill_n()` is used to fill a buffer with 10 instances of the value `0x42`. However, the buffer has not allocated any space for the elements, so this operation results in a buffer overflow.

```cpp
#include <algorithm>
#include <vector>

void f() {
  std::vector<int> v;
  std::fill_n(v.begin(), 10, 0x42);
}
```

## Compliant Solution (Sufficient Initial Capacity)

This compliant solution ensures the capacity of the vector is sufficient before attempting to fill the container.

```cpp
#include <algorithm>
#include <vector>

void f() {
  std::vector<int> v(10);
  std::fill_n(v.begin(), 10, 0x42);
}
```
However, this compliant solution is inefficient. The constructor will default-construct 10 elements of type `int`, which are subsequently replaced by the call to `std::fill_n()`, meaning that each element in the container is initialized twice.

## Compliant Solution (Fill Initialization)

This compliant solution initializes `v` to 10 elements whose values are all `0x42`.

```cpp
#include <algorithm>
#include <vector>

void f() {
  std::vector<int> v(10, 0x42);
}
```

## Risk Assessment

Copying data to a buffer that is too small to hold the data results in a buffer overflow. Attackers can [exploit](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) this condition to execute arbitrary code.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CTR52-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>invalid_pointer_dereference</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.BO.\*</strong> <strong>LANG.MEM.BOLANG.MEM.TBA</strong> </td> <td> A collection of warning classes that report uses of library functions prone to internal buffer overflows. Buffer Overrun Tainted Buffer Access </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3526, C++3527, C++3528, C++3529, C++3530, C++3531, C++3532, C++3533, C++3534</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CTR52-a</strong> </td> <td> Do not pass empty container iterators to std algorithms as destinations </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CTR52-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> STR50-CPP. Guarantee that storage for strings has sufficient space for character data and the null terminator </a> </td> </tr> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> ARR38-C. Guarantee that library functions do not form invalid pointers </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE 119 </a> , Failure to Constrain Operations within the Bounds of an Allocated Memory Buffer <a> CWE 805 </a> , Buffer Access with Incorrect Length Value </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 25.3, "Mutating Sequence Operations" </td> </tr> <tr> <td> \[ <a> ISO/IEC TR 24772-2013 </a> \] </td> <td> Buffer Overflow in Heap \[XYB\] Buffer Overflow in Stack \[XYW\] Unchecked Array Indexing \[XYZ\] </td> </tr> <tr> <td> \[ <a> Meyers 2001 </a> \] </td> <td> Item 30, "Make Sure Destination Ranges Are Big Enough" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CTR52-CPP: Guarantee that library functions do not overflow](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
