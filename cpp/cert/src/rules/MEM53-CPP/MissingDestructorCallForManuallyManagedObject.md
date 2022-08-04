# MEM53-CPP: Explicitly destruct objects when manually managing object lifetime

This query implements the CERT-C++ rule MEM53-CPP:

> Explicitly construct and destruct objects when manually managing object lifetime


## Description

The creation of dynamically allocated objects in C++ happens in two stages. The first stage is responsible for allocating sufficient memory to store the object, and the second stage is responsible for initializing the newly allocated chunk of memory, depending on the type of the object being created.

Similarly, the destruction of dynamically allocated objects in C++ happens in two stages. The first stage is responsible for finalizing the object, depending on the type, and the second stage is responsible for deallocating the memory used by the object. The C++ Standard, \[basic.life\], paragraph 1 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> The *lifetime* of an object is a runtime property of the object. An object is said to have non-trivial initialization if it is of a class or aggregate type and it or one of its members is initialized by a constructor other than a trivial default constructor. \[*Note:* initialization by a trivial copy/move constructor is non-trivial initialization. — *end note*\] The lifetime of an object of type `T` begins when:


— storage with the proper alignment and size for type `T` is obtained, and— if the object has non-trivial initialization, its initialization is complete.

The lifetime of an object of type `T` ends when:

— if `T` is a class type with a non-trivial destructor, the destructor call starts, or— the storage which the object occupies is reused or released.

For a dynamically allocated object, these two stages are typically handled automatically by using the `new` and `delete` operators. The expression `new T` for a type `T` results in a call to `operator new()` to allocate sufficient memory for `T`. If memory is successfully allocated, the default constructor for `T` is called. The result of the expression is a pointer `P` to the object of type `T`. When that pointer is passed in the expression `delete P`, it results in a call to the destructor for `T`. After the destructor completes, a call is made to `operator delete()` to deallocate the memory.

When a program creates a dynamically allocated object by means other than the `new` operator, it is said to be *manually managing* the lifetime of that object. This situation arises when using other allocation schemes to obtain storage for the dynamically allocated object, such as using an [allocator object](http://www.cplusplus.com/reference/memory/allocator/) or `malloc()`. For example, a custom container class may allocate a slab of memory in a `reserve()` function in which subsequent objects will be stored. See [MEM51-CPP. Properly deallocate dynamically allocated resources](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM51-CPP.+Properly+deallocate+dynamically+allocated+resources) for further information on dynamic memory management.

When manually managing the lifetime of an object, the constructor must be called to initiate the lifetime of the object. Similarly, the destructor must be called to terminate the lifetime of the object. Use of an object outside of its lifetime is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). An object can be constructed either by calling the constructor explicitly using the placement `new` operator or by calling the `construct()` function of an allocator object. An object can be destroyed either by calling the destructor explicitly or by calling the `destroy()` function of an allocator object.

## Noncompliant Code Example

In this noncompliant code example, a class with nontrivial initialization (due to the presence of a user-provided constructor) is created with a call to `std::malloc()`. However, the constructor for the object is never called, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) when the class is later accessed by calling `s->f()`.

```cpp
#include <cstdlib>

struct S {
  S();
  
  void f();
};

void g() {
  S *s = static_cast<S *>(std::malloc(sizeof(S)));
 
  s->f();
 
  std::free(s);
}
```

## Compliant Solution

In this compliant solution, the constructor and destructor are both explicitly called. Further, to reduce the possibility of the object being used outside of its lifetime, the underlying storage is a separate variable from the live object.

```cpp
#include <cstdlib>
#include <new>

struct S {
  S();
  
  void f();
};

void g() {
  void *ptr = std::malloc(sizeof(S));
  S *s = new (ptr) S;

  s->f();
 
  s->~S();
  std::free(ptr);
}
```

## Noncompliant Code Example

In this noncompliant code example, a custom container class uses an allocator object to obtain storage for arbitrary element types. While the `copy_elements()` function is presumed to call copy constructors for elements being moved into the newly allocated storage, this example fails to explicitly call the default constructor for any additional elements being reserved. If such an element is accessed through the `operator[]()` function, it results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior), depending on the type `T`.

```cpp
#include <memory>

template <typename T, typename Alloc = std::allocator<T>>
class Container {
  T *underlyingStorage;
  size_t numElements;
  
  void copy_elements(T *from, T *to, size_t count);
  
public:
  void reserve(size_t count) {
    if (count > numElements) {
      Alloc alloc;
      T *p = alloc.allocate(count); // Throws on failure
      try {
        copy_elements(underlyingStorage, p, numElements);
      } catch (...) {
        alloc.deallocate(p, count);
        throw;
      }
      underlyingStorage = p;
    }
    numElements = count;
  }
  
  T &operator[](size_t idx) { return underlyingStorage[idx]; }
  const T &operator[](size_t idx) const { return underlyingStorage[idx]; }
};
```

## Compliant Solution

In this compliant solution, all elements are properly initialized by explicitly calling copy or default constructors for `T.`

```cpp
#include <memory>

template <typename T, typename Alloc = std::allocator<T>>
class Container {
  T *underlyingStorage;
  size_t numElements;
  
  void copy_elements(T *from, T *to, size_t count);
  
public:
  void reserve(size_t count) {
    if (count > numElements) {
      Alloc alloc;
      T *p = alloc.allocate(count); // Throws on failure
      try {
        copy_elements(underlyingStorage, p, numElements);
        for (size_t i = numElements; i < count; ++i) {
          alloc.construct(&p[i]);
        }
      } catch (...) {
        alloc.deallocate(p, count);
        throw;
      }
      underlyingStorage = p;
    }
    numElements = count;
  }
  
  T &operator[](size_t idx) { return underlyingStorage[idx]; }
  const T &operator[](size_t idx) const { return underlyingStorage[idx]; }
};
```

## Exceptions

**MEM53-CPP-EX1:** If the object is trivially constructable, it need not have its constructor explicitly called to initiate the object's lifetime. If the object is trivially destructible, it need not have its destructor explicitly called to terminate the object's lifetime. These properties can be tested by calling `std::is_trivially_constructible()` and `std::is_trivially_destructible()` from `<type_traits>`. For instance, integral types such as `int` and `long long` do not require an explicit constructor or destructor call.

## Risk Assessment

Failing to properly construct or destroy an object leaves its internal state inconsistent, which can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) and accidental information exposure.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM53-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4761, C++4762, C++4766, C++4767</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MEM53-a</strong> </td> <td> Do not invoke malloc/realloc for objects having constructors </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V630</a>, <a>V749</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerab) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM33-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> MEM51-CPP. Properly deallocate dynamically allocated resources </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.8, "Object Lifetime" Clause 9, "Classes" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MEM53-CPP: Explicitly construct and destruct objects when manually managing object lifetime](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
