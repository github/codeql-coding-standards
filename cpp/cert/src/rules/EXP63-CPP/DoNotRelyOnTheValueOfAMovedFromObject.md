# EXP63-CPP: Do not rely on the value of a moved-from object

This query implements the CERT-C++ rule EXP63-CPP:

> Do not rely on the value of a moved-from object


## Description

Many types, including user-defined types and types provided by the Standard Template Library, support move semantics. Except in rare circumstances, an object of a type that supports move operations (move initialization or move assignment) will be left in a valid, but unspecified state after the object's value has been moved.

Passing an object as a function argument that binds to an [rvalue](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-rvalue) reference parameter, including via implicit function call syntax such as move assignment or move construction, *moves* the object's state into another object. Upon return from such a function call, the object that was bound as an rvalue reference parameter is considered to be in the *moved-from* state. Once an object is in the moved-from state, the only operations that may be safely performed on that object instance are ones for which the operation has no preconditions, because it is unknown whether the unspecified state of the object will satisfy those preconditions. While some types have explicitly-defined preconditions, such as types defined by the Standard Template Library, it should be assumed that the only operations that may be safely performed on a moved-from object instance are reinitialization through assignment into the object or terminating the lifetime of the object by invoking its destructor.

Do not rely on the value of a moved-from object unless the type of the object is documented to be in a well-specified state. While the object is guaranteed to be in a valid state, relying on [unspecified values](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedvalue) leads to [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedbehavior). Since the behavior need not be documented, this can in turn result in abnormal program behavior and portability concerns.

The following Standard Template Library functions are guaranteed to leave the moved-from object in a well-specified state.

<table> <tbody> <tr> <th> Type </th> <th> Functionality </th> <th> Moved-from State </th> </tr> <tr> <td> <code>std::unique_ptr</code> </td> <td> Move construction, Move assignment, "Converting" move construction, "Converting" move assignment (likewise for <code>std::unique_ptr</code> for array objects with a runtime length) </td> <td> The moved-from object is guaranteed to refer to a null pointer value, per \[unique.ptr\], paragraph 4 \[ <a> ISO/IEC 14882-2014 </a> \]. </td> </tr> <tr> <td> <code>std::shared_ptr</code> </td> <td> Move construction, Move assignment, "Converting" move construction, "Converting" move assignment </td> <td> The moved-from object shall be "empty," per \[util.smartptr.shared.const\], paragraph 22 and \[util.smartptr.shared.assign\], paragraph 4. </td> </tr> <tr> <td> <code>std::shared_ptr</code> </td> <td> Move construction, Move assignment from a <code>std::unique_ptr</code> </td> <td> The moved-from object is guaranteed to refer to a null pointer value, per \[util.smartptr.shared.const\], paragraph 29 and \[util.smartptr.shared.assign\], paragraph 6. </td> </tr> <tr> <td> <code>std::weak_ptr</code> </td> <td> Move construction, Move assignment, "Converting" move construction, "Converting" move assignment </td> <td> The moved-from object shall be "empty," per \[util.smartptr.weak.const\], paragraph 8, and \[util.smartptr.weak.assign\], paragraph 4. </td> </tr> <tr> <td> <code>std::basic_ios</code> </td> <td> <code>move()</code> </td> <td> The moved-from object is still left in an unspecified state, except that <code>rdbuf()</code> shall return the same value as it returned before the move, and <code>tie()</code> shall return <code>0</code> , per \[basic.ios.members\], paragraph 20. </td> </tr> <tr> <td> <code>std::basic_filebuf</code> </td> <td> Move constructor, Move assignment </td> <td> The moved-from object is guaranteed to reference no file; other internal state is also affected, per \[filebuf.cons\], paragraphs 3 and 4, and \[filebuf.assign\], paragraph 1. </td> </tr> <tr> <td> <code>std::thread</code> </td> <td> Move constructor, Move assignment </td> <td> The result from calling <code>get_id()</code> on the moved-from object is guaranteed to remain unchanged; otherwise the object is in an unspecified state, per \[thread.thread.constr\], paragraph 11 and \[thread.thread.assign\], paragraph 2. </td> </tr> <tr> <td> <code>std::unique_lock</code> </td> <td> Move constructor, Move assignment </td> <td> The moved-from object is guaranteed to be in its default state, per \[thread.lock.unique.cons\], paragraphs 21 and 23. </td> </tr> <tr> <td> <code>std::shared_lock</code> </td> <td> Move constructor, Move assignment </td> <td> The moved-from object is guaranteed to be in its default state, per \[thread.lock.shared.cons\], paragraphs 21 and 23. </td> </tr> <tr> <td> <code>std::promise</code> </td> <td> Move constructor, Move assignment </td> <td> The moved-from object is guaranteed not to have any shared state, per \[futures.promise\], paragraphs 6 and 8. </td> </tr> <tr> <td> <code>std::future</code> </td> <td> Move constructor, Move assignment </td> <td> Calling <code>valid()</code> on the moved-from object is guaranteed to return <code>false</code> , per \[futures.unique_future\], paragraphs 8 and 11. </td> </tr> <tr> <td> <code>std::shared_future</code> </td> <td> Move constructor, Move assignment, "Converting" move constructor, "Converting" move assignment </td> <td> Calling <code>valid()</code> on the moved-from object is guaranteed to return <code>false</code> , per \[futures.shared_future\], paragraphs 8 and 11. </td> </tr> <tr> <td> <code>std::packaged_task</code> </td> <td> Move constructor, Move assignment </td> <td> The moved-from object is guaranteed not to have any shared state, per \[future.task.members\], paragraphs 7 and 8. </td> </tr> </tbody> </table>
Several generic standard template library (STL) algorithms, such as `std::remove()` and `std::unique()`, remove instances of elements from a container without shrinking the size of the container. Instead, these algorithms return a `ForwardIterator` to indicate the partition within the container after which elements are no longer valid. The elements in the container that precede the returned iterator are valid elements with specified values; whereas the elements that succeed the returned iterator are valid but have unspecified values. Accessing [unspecified values](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedvalue) of elements iterated over results in [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedbehavior). Frequently, the [erase-remove idiom](http://en.wikipedia.org/wiki/Erase-remove_idiom) is used to shrink the size of the container when using these algorithms.


## Noncompliant Code Example

In this noncompliant code example, the integer values `0` through `9` are expected to be printed to the standard output stream from a `std::string` rvalue reference. However, because the object is moved and then reused under the assumption its internal state has been cleared, unexpected output may occur despite not triggering [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <iostream>
#include <string>

void g(std::string v) {
  std::cout << v << std::endl;
}

void f() {
  std::string s;
  for (unsigned i = 0; i < 10; ++i) {
    s.append(1, static_cast<char>('0' + i));
    g(std::move(s));
  }
}
```
**Implementation Details**

Some standard library implementations may implement the *short string optimization (SSO)* when implementing `std::string`. In such implementations, strings under a certain length are stored in a character buffer internal to the `std::string` object (avoiding an expensive heap allocation operation). However, such an implementation might not alter the original buffer value when performing a move operation. When the noncompliant code example is compiled with [Clang ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-clang)3.7 using [libc++](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-libcxx), the following output is produced.

```cpp
0
01
012
0123
01234
012345
0123456
01234567
012345678
0123456789
```

## Compliant Solution

In this compliant solution, the `std::string` object is initialized to the expected value on each iteration of the loop. This practice ensures that the object is in a valid, specified state prior to attempting to access it in `g()`, resulting in the expected output.

```cpp
#include <iostream>
#include <string>

void g(std::string v) {
  std::cout << v << std::endl;
}

void f() {
  for (unsigned i = 0; i < 10; ++i) {
    std::string s(1, static_cast<char>('0' + i));
    g(std::move(s));
  }
}
```

## Noncompliant Code Example

In this noncompliant code example, elements matching `42` are removed from the given container. The contents of the container are then printed to the standard output stream. However, if any elements were removed from the container, the range-based `for` loop iterates over an invalid iterator range, resulting in [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedbehavior).

```cpp
#include <algorithm>
#include <iostream>
#include <vector>
 
void f(std::vector<int> &c) {
  std::remove(c.begin(), c.end(), 42);
  for (auto v : c) {
    std::cout << "Container element: " << v << std::endl;
  }
}
```

## Compliant Solution

In this compliant solution, elements removed by the standard algorithm are skipped during iteration.

```cpp
#include <algorithm>
#include <iostream>
#include <vector>
 
void f(std::vector<int> &c) {
  auto e = std::remove(c.begin(), c.end(), 42);
  for (auto i = c.begin(); i != c.end(); i++) {
    if (i < e) {
      std::cout << *i << std::endl;
    }
  }
}
```

## Compliant Solution

In this compliant solution, elements removed by the standard algorithm are subsequently erased from the given container. This technique ensures that a valid iterator range is used by the range-based `for` loop.

```cpp
#include <algorithm>
#include <iostream>
#include <vector>
 
void f(std::vector<int> &c) {
  c.erase(std::remove(c.begin(), c.end(), 42), c.end());
  for (auto v : c) {
    std::cout << "Container element: " << v << std::endl;
  }
}
```

## Risk Assessment

The state of a moved-from object is generally valid, but unspecified. Relying on unspecified values can lead to abnormal program termination as well as data integrity violations.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP63-CPP </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.NPD</strong> </td> <td> Null Pointer Dereference </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4701, C++4702, C++4703</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP63-a</strong> </td> <td> Do not rely on the value of a moved-from object </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: EXP63-CPP </a> </td> <td> Checks for read operations that reads the value of a moved-from object (rule fully covered) </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V1030</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP63-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> </td> <td> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 17.6.5.15, "Moved-from State of Library Types" Subclause 20.8.1, "Class Template <code>unique_ptr</code> " Subclause 20.8.2, "Shared-Ownership Pointers" Subclause 27.5.5, "Class Template <code>basic_ios</code> " Subclause 27.9.1, "File Streams" Subclause 30.3.1, "Class <code>thread</code> " Subclause 30.4.2, "Locks" Subclause 30.6, "Futures" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP63-CPP: Do not rely on the value of a moved-from object](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
