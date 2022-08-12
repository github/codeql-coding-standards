# CTR50-CPP: A container shall not be accessed beyond its range

This query implements the CERT-C++ rule CTR50-CPP:

> Guarantee that container indices and iterators are within the valid range


## Description

Ensuring that array references are within the bounds of the array is almost entirely the responsibility of the programmer. Likewise, when using standard template library vectors, the programmer is responsible for ensuring integer indexes are within the bounds of the vector.

## Noncompliant Code Example (Pointers)

This noncompliant code example shows a function, `insert_in_table()`, that has two `int` parameters, `pos` and `value`, both of which can be influenced by data originating from untrusted sources. The function performs a range check to ensure that `pos` does not exceed the upper bound of the array, specified by `tableSize`, but fails to check the lower bound. Because `pos` is declared as a (signed) `int`, this parameter can assume a negative value, resulting in a write outside the bounds of the memory referenced by `table`.

```cpp
#include <cstddef>
 
void insert_in_table(int *table, std::size_t tableSize, int pos, int value) {
  if (pos >= tableSize) {
    // Handle error
    return;
  }
  table[pos] = value;
}
```

## Compliant Solution (size_t)

In this compliant solution, the parameter `pos` is declared as `size_t`, which prevents the passing of negative arguments.

```cpp
#include <cstddef>
 
void insert_in_table(int *table, std::size_t tableSize, std::size_t pos, int value) {
  if (pos >= tableSize) {
    // Handle error
    return;
  }
  table[pos] = value;
}
```

## Compliant Solution (Non-Type Templates)

Non-type templates can be used to define functions accepting an array type where the array bounds are deduced at compile time. This compliant solution is functionally equivalent to the previous bounds-checking one except that it additionally supports calling `insert_in_table()` with an array of known bounds.

```cpp
#include <cstddef>
#include <new>

void insert_in_table(int *table, std::size_t tableSize, std::size_t pos, int value) { // #1
  if (pos >= tableSize) {
    // Handle error
    return;
  }
  table[pos] = value;
}

template <std::size_t N>
void insert_in_table(int (&table)[N], std::size_t pos, int value) { // #2
  insert_in_table(table, N, pos, value);
}
 
void f() {
  // Exposition only
  int table1[100];
  int *table2 = new int[100];
  insert_in_table(table1, 0, 0); // Calls #2
  insert_in_table(table2, 0, 0); // Error, no matching function call
  insert_in_table(table1, 100, 0, 0); // Calls #1
  insert_in_table(table2, 100, 0, 0); // Calls #1
  delete [] table2;
}
```

## Noncompliant Code Example (std::vector)

In this noncompliant code example, a `std::vector` is used in place of a pointer and size pair. The function performs a range check to ensure that `pos` does not exceed the upper bound of the container. Because `pos` is declared as a (signed) `long long`, this parameter can assume a negative value. On systems where `std::vector::size_type` is ultimately implemented as an `unsigned int` (such as with [Microsoft Visual Studio ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-msvc)2013), the usual arithmetic conversions applied for the comparison expression will convert the unsigned value to a signed value. If `pos` has a negative value, this comparison will not fail, resulting in a write outside the bounds of the `std::vector` object when the negative value is interpreted as a large unsigned value in the indexing operator.

```cpp
#include <vector>
 
void insert_in_table(std::vector<int> &table, long long pos, int value) {
  if (pos >= table.size()) {
    // Handle error
    return;
  }
  table[pos] = value;
}

```

## Compliant Solution (std::vector, size_t)

In this compliant solution, the parameter `pos` is declared as `size_t`, which ensures that the comparison expression will fail when a large, positive value (converted from a negative argument) is given.

```cpp
#include <vector>
 
void insert_in_table(std::vector<int> &table, std::size_t pos, int value) {
  if (pos >= table.size()) {
    // Handle error
    return;
  }
  table[pos] = value;
}

```

## Compliant Solution (std::vector::at())

In this compliant solution, access to the vector is accomplished with the `at()` method. This method provides bounds checking, throwing a `std::out_of_range` exception if `pos` is not a valid index value. The `insert_in_table()` function is declared with `noexcept(false)` in compliance with [ERR55-CPP. Honor exception specifications](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR55-CPP.+Honor+exception+specifications).

```cpp
#include <vector>
 
void insert_in_table(std::vector<int> &table, std::size_t pos, int value) noexcept(false) {
  table.at(pos) = value;
}
```

## Noncompliant Code Example (Iterators)

In this noncompliant code example, the `f_imp()` function is given the (correct) ending iterator `e` for a container, and `b` is an iterator from the same container. However, it is possible that `b` is not within the valid range of its container. For instance, if the container were empty, `b` would equal `e` and be improperly dereferenced.

```cpp
#include <iterator>
 
template <typename ForwardIterator>
void f_imp(ForwardIterator b, ForwardIterator e, int val, std::forward_iterator_tag) {
  do {
    *b++ = val;
  } while (b != e);
}

template <typename ForwardIterator>
void f(ForwardIterator b, ForwardIterator e, int val) {
  typename std::iterator_traits<ForwardIterator>::iterator_category cat;
  f_imp(b, e, val, cat);
}
```

## Compliant Solution

This compliant solution tests for iterator validity before attempting to dereference `b.`

```cpp
#include <iterator>
 
template <typename ForwardIterator>
void f_imp(ForwardIterator b, ForwardIterator e, int val, std::forward_iterator_tag) {
  while (b != e) {
    *b++ = val;
  }
}

template <typename ForwardIterator>
void f(ForwardIterator b, ForwardIterator e, int val) {
  typename std::iterator_traits<ForwardIterator>::iterator_category cat;
  f_imp(b, e, val, cat);
}
```

## Risk Assessment

Using an invalid array or container index can result in an arbitrary memory overwrite or [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CTR50-CPP </td> <td> High </td> <td> Likely </td> <td> High </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>overflow_upon_dereference</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.BOLANG.MEM.BULANG.MEM.TOLANG.MEM.TU</strong> <strong>LANG.MEM.TBA</strong> <strong>LANG.STRUCT.PBB</strong> <strong>LANG.STRUCT.PPELANG.STRUCT.PARITH</strong> </td> <td> Buffer overrun Buffer underrun Type overrun Type underrun Tainted buffer access Pointer before beginning of object Pointer past end of object Pointer Arithmetic </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2891, C++3139, C++3140</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>ABV.ANY_SIZE_ARRAY</strong> <strong>ABV.GENERAL</strong> <strong>ABV.GENERAL.MULTIDIMENSION</strong> <strong>ABV.STACK </strong> <strong>ABV.TAINTED</strong> <strong>SV.TAINTED.ALLOC_SIZE</strong> <strong>SV.TAINTED.CALL.INDEX_ACCESS</strong> <strong>SV.TAINTED.CALL.LOOP_BOUND</strong> <strong>SV.TAINTED.INDEX_ACCESS</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>45 D, 47 S, 476 S, 489 S, 64 X, 66 X, 68 X, 69 X, 70 X, 71 X, 79 X</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CTR50-a</strong> </td> <td> Guarantee that container indices are within the valid range </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: CTR50-CPP </a> </td> <td> Checks for: Array access out of boundsrray access out of bounds, array access with tainted indexrray access with tainted index, pointer dereference with tainted offsetointer dereference with tainted offset. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2891, 3139, 3140</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V781</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CTR50-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> ARR30-C. Do not form or use out-of-bounds pointers or array subscripts </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE 119 </a> , Failure to Constrain Operations within the Bounds of a Memory Buffer <a> CWE 129 </a> , Improper Validation of Array Index </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Clause 23, "Containers Library" Subclause 24.2.1, "In General" </td> </tr> <tr> <td> \[ <a> ISO/IEC TR 24772-2013 </a> \] </td> <td> Boundary Beginning Violation \[XYX\] Wrap-Around Error \[XYY\] Unchecked Array Indexing \[XYZ\] </td> </tr> <tr> <td> \[ <a> Viega 2005 </a> \] </td> <td> Section 5.2.13, "Unchecked Array Indexing" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CTR50-CPP: Guarantee that container indices and iterators are within the valid range](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
