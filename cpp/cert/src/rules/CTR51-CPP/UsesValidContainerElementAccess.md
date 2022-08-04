# CTR51-CPP: Use valid references, pointers, and iterators to reference elements of a container

This query implements the CERT-C++ rule CTR51-CPP:

> Use valid references, pointers, and iterators to reference elements of a container


## Description

Iterators are a generalization of pointers that allow a C++ program to work with different data structures (containers) in a uniform manner \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]. Pointers, references, and iterators share a close relationship in which it is required that referencing values be done through a valid iterator, pointer, or reference. Storing an iterator, reference, or pointer to an element within a container for any length of time comes with a risk that the underlying container may be modified such that the stored iterator, pointer, or reference becomes invalid. For instance, when a sequence container such as `std::vector` requires an underlying reallocation, outstanding iterators, pointers, and references will be invalidated \[[Kalev 99](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Kalev99)\]. Use only a [valid pointer](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-validpointer), reference, or iterator to refer to an element of a container.

The C++ Standard, \[container.requirements.general\], paragraph 12 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\] states the following:

> Unless otherwise specified (either explicitly or by defining a function in terms of other functions), invoking a container member function or passing a container as an argument to a library function shall not invalidate iterators to, or change the values of, objects within that container.


The C++ Standard allows references and pointers to be invalidated independently for the same operation, which may result in an invalidated reference but not an invalidated pointer. However, relying on this distinction is insecure because the object pointed to by the pointer may be different than expected even if the pointer is valid. For instance, it is possible to retrieve a pointer to an element from a container, erase that element (invalidating references when destroying the underlying object), then insert a new element at the same location within the container causing the extant pointer to now point to a valid, but distinct object. Thus, any operation that invalidates a pointer or a reference should be treated as though it invalidates both pointers and references.

The following container functions can invalidate iterators, references, and pointers under certain circumstances.

<table> <tbody> <tr> <th> Class </th> <th> Function </th> <th> Iterators </th> <th> References/Pointers </th> <th> Notes </th> </tr> <tr> <td> <code>std::deque</code> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> </td> <td> <code>insert()</code> , <code>emplace_front()</code> , <code>emplace_back()</code> , <code>emplace()</code> , <code>push_front()</code> , <code>push_back()</code> </td> <td> X </td> <td> X </td> <td> An insertion in the middle of the deque invalidates all the iterators and references to elements of the deque. An insertion at either end of the deque invalidates all the iterators to the deque but has no effect on the validity of references to elements of the deque. (\[deque.modifiers\], paragraph 1 ) </td> </tr> <tr> <td> </td> <td> <code>erase()</code> , <code>pop_back()</code> , <code>resize()</code> </td> <td> X </td> <td> X </td> <td> An erase operation that erases the last element of a deque invalidates only the past-the-end iterator and all iterators and references to the erased elements. An erase operation that erases the first element of a deque but not the last element invalidates only the erased elements. An erase operation that erases neither the first element nor the last element of a deque invalidates the past-the-end iterator and all iterators and references to all the elements of the deque. (\[deque.modifiers\], paragraph 4) </td> </tr> <tr> <td> </td> <td> <code>clear()</code> </td> <td> X </td> <td> X </td> <td> Destroys all elements in the container. Invalidates all references, pointers, and iterators referring to the elements of the container and may invalidate the past-the-end iterator. (\[sequence.reqmts\], Table 100) </td> </tr> <tr> <td> <code>std::forward_list</code> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> </td> <td> <code>erase_after()</code> , <code>pop_front()</code> , <code>resize()</code> </td> <td> X </td> <td> X </td> <td> <code>erase_after</code> shall invalidate only iterators and references to the erased elements. (\[forwardlist.modifiers\], paragraph 1) </td> </tr> <tr> <td> </td> <td> <code>remove()</code> , <code>unique()</code> </td> <td> X </td> <td> X </td> <td> Invalidates only the iterators and references to the erased elements. (\[forwardlist.ops\], paragraph 12 &amp; paragraph 16) </td> </tr> <tr> <td> </td> <td> <code>clear()</code> </td> <td> X </td> <td> X </td> <td> Destroys all elements in the container. Invalidates all references, pointers, and iterators referring to the elements of the container and may invalidate the past-the-end iterator. ( \[sequence.reqmts\], Table 100) </td> </tr> <tr> <td> <code>std::list</code> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> </td> <td> <code>erase()</code> , <code>pop_front()</code> , <code>pop_back()</code> , <code>clear()</code> , <code>remove()</code> , <code>remove_if()</code> , <code>unique()</code> </td> <td> X </td> <td> X </td> <td> Invalidates only the iterators and references to the erased elements. (\[list.modifiers\], paragraph 3 and \[list.ops\], paragraph 15 &amp; paragraph 19) </td> </tr> <tr> <td> </td> <td> <code>clear()</code> </td> <td> X </td> <td> X </td> <td> Destroys all elements in the container. Invalidates all references, pointers, and iterators referring to the elements of the container and may invalidate the past-the-end iterator. ( \[sequence.reqmts\], Table 100) </td> </tr> <tr> <td> <code>std::vector</code> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> </td> <td> <code>reserve()</code> </td> <td> X </td> <td> X </td> <td> After <code>reserve()</code> , <code>capacity()</code> is greater or equal to the argument of <code>reserve</code> if reallocation happens and is equal to the previous value of <code>capacity()</code> otherwise. Reallocation invalidates all the references, pointers, and iterators referring to the elements in the sequence. (\[vector.capacity\], paragraph 3 &amp; paragraph 6) </td> </tr> <tr> <td> </td> <td> <code>insert()</code> , <code>emplace_back()</code> , <code>emplace()</code> , <code>push_back()</code> </td> <td> X </td> <td> X </td> <td> Causes reallocation if the new size is greater than the old capacity. If no reallocation happens, all the iterators and references before the insertion point remain valid. (\[vector.modifiers\], paragraph 1). All iterators and references after the insertion point are invalidated. </td> </tr> <tr> <td> </td> <td> <code>erase()</code> , <code>pop_back()</code> , <code>resize()</code> </td> <td> X </td> <td> X </td> <td> Invalidates iterators and references at or after the point of the erase. ( \[vector.modifiers\], paragraph 3) </td> </tr> <tr> <td> </td> <td> <code>clear()</code> </td> <td> X </td> <td> X </td> <td> Destroys all elements in the container. Invalidates all references, pointers, and iterators referring to the elements of the container and may invalidate the past-the-end iterator. ( \[sequence.reqmts\], Table 100) </td> </tr> <tr> <td> <code>std::set</code> , <code>std::multiset</code> , <code>std::map</code> , <code>std::multimap</code> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> </td> <td> <code>erase()</code> , <code>clear()</code> </td> <td> X </td> <td> X </td> <td> Invalidates only iterators and references to the erased elements. (\[associative.reqmts\], paragraph 9) </td> </tr> <tr> <td> <code>std::unordered_set</code> , <code>std::unordered_multiset</code> , <code>std::unordered_map</code> , <code>std::unordered_multimap</code> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> </td> <td> <code>erase()</code> , <code>clear()</code> </td> <td> X </td> <td> X </td> <td> Invalidates only iterators and references to the erased elements. (\[unord.req\], paragraph 14) </td> </tr> <tr> <td> </td> <td> <code>insert()</code> , <code>emplace()</code> </td> <td> X </td> <td> </td> <td> The <code>insert</code> and <code>emplace</code> members shall not affect the validity of iterators if ( <em> N </em> + <em> n </em> ) &lt; <em> z </em> \* <em> B </em> , where <em> N </em> is the number of elements in the container prior to the <code>insert</code> operation, <em> n </em> is the number of elements inserted, <em> B </em> is the container’s bucket count, and <em> z </em> is the container’s maximum load factor. (\[unord.req\], paragraph 15) </td> </tr> <tr> <td> </td> <td> <code>rehash()</code> , <code>reserve()</code> </td> <td> X </td> <td> </td> <td> Rehashing invalidates iterators, changes ordering between elements, and changes which buckets the elements appear in but does not invalidate pointers or references to elements. (\[unord.req\], paragraph 9) </td> </tr> <tr> <td> <code>std::valarray</code> </td> <td> <code>resize()</code> </td> <td> </td> <td> X </td> <td> Resizing invalidates all pointers and references to elements in the array. (\[valarray.members\], paragraph 12) </td> </tr> </tbody> </table>
A `std::basic_string` object is also a container to which this rule applies. For more specific information pertaining to `std::basic_string` containers, see [STR52-CPP. Use valid references, pointers, and iterators to reference elements of a basic_string](https://wiki.sei.cmu.edu/confluence/display/cplusplus/STR52-CPP.+Use+valid+references%2C+pointers%2C+and+iterators+to+reference+elements+of+a+basic_string).


## Noncompliant Code Example

In this noncompliant code example, `pos` is invalidated after the first call to `insert()`, and subsequent loop iterations have [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <deque>
 
void f(const double *items, std::size_t count) {
  std::deque<double> d;
  auto pos = d.begin();
  for (std::size_t i = 0; i < count; ++i, ++pos) {
    d.insert(pos, items[i] + 41.0);
  }
}
```

## Compliant Solution (Updated Iterator)

In this compliant solution, `pos` is assigned a valid iterator on each insertion, preventing undefined behavior.

```cpp
#include <deque>
 
void f(const double *items, std::size_t count) {
  std::deque<double> d;
  auto pos = d.begin();
  for (std::size_t i = 0; i < count; ++i, ++pos) {
    pos = d.insert(pos, items[i] + 41.0);
  }
}

```

## Compliant Solution (Generic Algorithm)

This compliant solution replaces the handwritten loop with the generic standard template library algorithm `std::transform()`. The call to `std::transform()` accepts the range of elements to transform, the location to store the transformed values (which, in this case, is a `std::inserter` object to insert them at the beginning of `d`), and the transformation function to apply (which, in this case, is a simple lambda).

```cpp
#include <algorithm>
#include <deque>
#include <iterator>
 
void f(const double *items, std::size_t count) {
  std::deque<double> d;
  std::transform(items, items + count, std::inserter(d, d.begin()),
                 [](double d) { return d + 41.0; });
}

```

## Risk Assessment

Using invalid references, pointers, or iterators to reference elements of a container results in undefined behavior.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CTR51-CPP </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>overflow_upon_dereference</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>ALLOC.UAF</strong> </td> <td> Use After Free </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4746, C++4747, C++4748, C++4749</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>ITER.CONTAINER.MODIFIED</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-CTR51-a</strong> </td> <td> Do not modify container while iterating over it </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: CTR51-CPP </a> </td> <td> Checks for use of invalid iterator (rule partially covered). </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V783</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabil) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CTR51-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> STR52-CPP. Use valid references, pointers, and iterators to reference elements of a basic_string </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Clause 23, "Containers Library" Subclause 24.2.1, "In General" </td> </tr> <tr> <td> \[ <a> Kalev 1999 </a> \] </td> <td> <em> ANSI/ISO C++ Professional Programmer's Handbook </em> </td> </tr> <tr> <td> \[ <a> Meyers 2001 </a> \] </td> <td> Item 43, "Prefer Algorithm Calls to Handwritten Loops" </td> </tr> <tr> <td> \[ <a> Sutter 2004 </a> \] </td> <td> Item 84, "Prefer Algorithm Calls to Handwritten Loops" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [CTR51-CPP: Use valid references, pointers, and iterators to reference elements of a container](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
