# MEM51-CPP: Properly deallocate dynamically allocated resources

This query implements the CERT-C++ rule MEM51-CPP:

> Properly deallocate dynamically allocated resources


## Description

The C programming language provides several ways to allocate memory, such as `std::malloc()`, `std::calloc()`, and `std::realloc()`, which can be used by a C++ program. However, the C programming language defines only a single way to free the allocated memory: `std::free()`. See [MEM31-C. Free dynamically allocated memory when no longer needed](https://wiki.sei.cmu.edu/confluence/display/c/MEM31-C.+Free+dynamically+allocated+memory+when+no+longer+needed) and [MEM34-C. Only free memory allocated dynamically](https://wiki.sei.cmu.edu/confluence/display/c/MEM34-C.+Only+free+memory+allocated+dynamically) for rules specifically regarding C allocation and deallocation requirements.

The C++ programming language adds additional ways to allocate memory, such as the operators `new`, `new[]`, and placement `new`, and [allocator objects](http://www.cplusplus.com/reference/memory/allocator/). Unlike C, C++ provides multiple ways to free dynamically allocated memory, such as the operators `delete`, `delete[]()`, and deallocation functions on allocator objects.

Do not call a deallocation function on anything other than `nullptr` , or a pointer returned by the corresponding allocation function described by the following.

<table> <tbody> <tr> <th> Allocator </th> <th> Deallocator </th> </tr> <tr> <td> global <code> operator new()/new</code> </td> <td> global <code> operator delete</code> () <code>/delete</code> </td> </tr> <tr> <td> global <code> operator new\[\]()/new\[\]</code> </td> <td> global <code> operator delete\[\]()/delete\[\]</code> </td> </tr> <tr> <td> class-specific <code> operator new()/new</code> </td> <td> <code> class-specific operator delete</code> () <code>/delete</code> </td> </tr> <tr> <td> <code> class-specific operator new\[\]()/new\[\]</code> </td> <td> <code> class-specific operator delete\[\]()/delete\[\]</code> </td> </tr> <tr> <td> placement <code>operator new</code> () </td> <td> N/A </td> </tr> <tr> <td> <code>allocator&lt;T&gt;::allocate()</code> </td> <td> <code>allocator&lt;T&gt;::deallocate()</code> </td> </tr> <tr> <td> <code>std::malloc()</code> , <code>std::calloc()</code> , <code> std::realloc()</code> </td> <td> <code> std::free()</code> </td> </tr> <tr> <td> <code>std::get_temporary_buffer()</code> </td> <td> <code>std::return_temporary_buffer()</code> </td> </tr> </tbody> </table>
Passing a pointer value to an inappropriate deallocation function can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).


The C++ Standard, \[expr.delete\], paragraph 2 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], in part, states the following:

> In the first alternative (*delete object*), the value of the operand of `delete` may be a null pointer value, a pointer to a non-array object created by a previous *new-expression*, or a pointer to a subobject (1.8) representing a base class of such an object (Clause 10). If not, the behavior is undefined. In the second alternative (*delete array*), the value of the operand of `delete` may be a null pointer value or a pointer value that resulted from a previous array *new-expression*. If not, the behavior is undefined.


Deallocating a pointer that is not allocated dynamically (including non-dynamic pointers returned from calls to placement `new()`) is undefined behavior because the pointer value was not obtained by an allocation function. Deallocating a pointer that has already been passed to a deallocation function is undefined behavior because the pointer value no longer points to memory that has been dynamically allocated.

When an operator such as `new` is called, it results in a call to an overloadable operator of the same name, such as `operator new()`. These overloadable functions can be called directly but carry the same restrictions as their operator counterparts. That is, calling `operator delete()` and passing a pointer parameter has the same constraints as calling the `delete` operator on that pointer. Further, the overloads are subject to scope resolution, so it is possible (but not permissible) to call a class-specific operator to allocate an object but a global operator to deallocate the object.

See [MEM53-CPP. Explicitly construct and destruct objects when manually managing object lifetime](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM53-CPP.+Explicitly+construct+and+destruct+objects+when+manually+managing+object+lifetime) for information on lifetime management of objects when using memory management functions other than the `new` and `delete` operators.

## Noncompliant Code Example (placement new())

In this noncompliant code example, the local variable `space` is passed as the expression to the placement `new` operator. The resulting pointer of that call is then passed to `::operator delete()`, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) due to `::operator delete()` attempting to free memory that was not returned by `::operator new()`.

```cpp
#include <iostream>
 
struct S {
  S() { std::cout << "S::S()" << std::endl; }
  ~S() { std::cout << "S::~S()" << std::endl; }
};

void f() {
  alignas(struct S) char space[sizeof(struct S)];
  S *s1 = new (&space) S;

  // ...

  delete s1;
}
```

## Compliant Solution (placement new())

This compliant solution removes the call to `::operator delete()`, instead explicitly calling `s1`'s destructor. This is one of the few times when explicitly invoking a destructor is warranted.

```cpp
#include <iostream>
 
struct S {
  S() { std::cout << "S::S()" << std::endl; }
  ~S() { std::cout << "S::~S()" << std::endl; }
};
 
void f() {
  alignas(struct S) char space[sizeof(struct S)];
  S *s1 = new (&space) S;
 
  // ...

  s1->~S();
}
```

## Noncompliant Code Example (Uninitialized delete)

In this noncompliant code example, two allocations are attempted within the same `try` block, and if either fails, the `catch` handler attempts to free resources that have been allocated. However, because the pointer variables have not been initialized to a known value, a failure to allocate memory for `i1` may result in passing `::operator delete()` a value (in `i2`) that was not previously returned by a call to `::operator new()`, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <new>
 
void f() {
  int *i1, *i2;
  try {
    i1 = new int;
    i2 = new int;
  } catch (std::bad_alloc &) {
    delete i1;
    delete i2;
  }
}
```

## Compliant Solution (Uninitialized delete)

This compliant solution initializes both pointer values to `nullptr`, which is a valid value to pass to `::operator delete().`

```cpp
#include <new>
 
void f() {
  int *i1 = nullptr, *i2 = nullptr;
  try {
    i1 = new int;
    i2 = new int;
  } catch (std::bad_alloc &) {
    delete i1;
    delete i2;
  }
}
```

## Noncompliant Code Example (Double-Free)

Once a pointer is passed to the proper deallocation function, that pointer value is invalidated. Passing the pointer to a deallocation function a second time when the pointer value has not been returned by a subsequent call to an allocation function results in an attempt to free memory that has not been allocated dynamically. The underlying data structures that manage the heap can become corrupted in a way that can introduce security [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) into a program. These types of issues are called *double-free vulnerabilities*. In practice, double-free vulnerabilities can be [exploited](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) to execute arbitrary code.

In this noncompliant code example, the class `C` is given ownership of a `P *`, which is subsequently deleted by the class destructor. The C++ Standard, \[class.copy\], paragraph 7 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> If the class definition does not explicitly declare a copy constructor, one is declared implicitly. If the class definition declares a move constructor or move assignment operator, the implicitly declared copy constructor is defined as deleted; otherwise, it is defined as defaulted (8.4). The latter case is deprecated if the class has a user-declared copy assignment operator or a user-declared destructor.


Despite the presence of a user-declared destructor, `C` will have an implicitly defaulted copy constructor defined for it, and this defaulted copy constructor will copy the pointer value stored in `p`, resulting in a double-free: the first free happens when `g()` exits and the second free happens when `h()` exits.

```cpp
struct P {};

class C {
  P *p;
  
public:
  C(P *p) : p(p) {}
  ~C() { delete p; }  
  
  void f() {}
};

void g(C c) {
  c.f();
}

void h() {
  P *p = new P;
  C c(p);
  g(c);
}
```

## Compliant Solution (Double-Free)

In this compliant solution, the copy constructor and copy assignment operator for `C` are explicitly deleted. This deletion would result in an [ill-formed](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-ill-formed) program with the definition of `g()` from the preceding noncompliant code example due to use of the deleted copy constructor. Consequently, `g()` was modified to accept its parameter by reference, removing the double-free.

```cpp
struct P {};

class C {
  P *p;
  
public:
  C(P *p) : p(p) {}
  C(const C&) = delete;
  ~C() { delete p; }
 
  void operator=(const C&) = delete;
  
  void f() {}
};

void g(C &c) {
  c.f();
}

void h() {
  P *p = new P;
  C c(p);
  g(c);
}
```

## Noncompliant Code Example (array new[])

In the following noncompliant code example, an array is allocated with array `new[]` but is deallocated with a scalar `delete` call instead of an array `delete[]` call, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
void f() {
  int *array = new int[10];
  // ...
  delete array;
}
```

## Compliant Solution (array new[])

## In the compliant solution, the code is fixed by replacing the call to delete with a call to delete [] to adhere to the correct pairing of memory allocation and deallocation functions.

```cpp
void f() {
  int *array = new int[10];
  // ...
  delete[] array;
}

```

## Noncompliant Code Example (malloc())

In this noncompliant code example, the call to `malloc()` is mixed with a call to `delete`.

```cpp
#include <cstdlib>
void f() {
  int *i = static_cast<int *>(std::malloc(sizeof(int)));
  // ...
  delete i;
}

```
This code does not violate [MEM53-CPP. Explicitly construct and destruct objects when manually managing object lifetime](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM53-CPP.+Explicitly+construct+and+destruct+objects+when+manually+managing+object+lifetime) because it complies with the MEM53-CPP-EX1 exception.

## Implementation Details

Some implementations of `::operator new()` result in calling `std::malloc()`. On such implementations, the `::operator delete()` function is required to call `std::free()` to deallocate the pointer, and the noncompliant code example would behave in a well-defined manner. However, this is an [implementation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation) detail and should not be relied on—implementations are under no obligation to use underlying C memory management functions to implement C++ memory management operators.

## Compliant Solution (malloc())

In this compliant solution, the pointer allocated by `std::malloc()` is deallocated by a call to `std::free()` instead of `delete.`

```cpp
#include <cstdlib>

void f() {
  int *i = static_cast<int *>(std::malloc(sizeof(int)));
  // ...
  std::free(i);
}
```

## Noncompliant Code Example ( new )

In this noncompliant code example, `std::free()` is called to deallocate memory that was allocated by `new`. A common side effect of the [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) caused by using the incorrect deallocation function is that destructors will not be called for the object being deallocated by `std::free().`

```cpp
#include <cstdlib>
 
struct S {
  ~S();
};

void f() {
  S *s = new S();
  // ...
  std::free(s);
}
```
Additionally, this code violates [MEM53-CPP. Explicitly construct and destruct objects when manually managing object lifetime](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM53-CPP.+Explicitly+construct+and+destruct+objects+when+manually+managing+object+lifetime).

## Compliant Solution (new)

In this compliant solution, the pointer allocated by `new` is deallocated by calling `delete` instead of `std::free().`

```cpp
struct S {
  ~S();
};

void f() {
  S *s = new S();
  // ...
  delete s;
}
```

## Noncompliant Code Example (Class new)

In this noncompliant code example, the global `new` operator is overridden by a class-specific implementation of `operator new()`. When `new` is called, the class-specific override is selected, so `S::operator new()` is called. However, because the object is destroyed with a scoped `::delete` operator, the global `operator delete()` function is called instead of the class-specific implementation `S::operator delete()`, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <cstdlib>
#include <new>
 
struct S {
  static void *operator new(std::size_t size) noexcept(true) {
    return std::malloc(size);
  }
  
  static void operator delete(void *ptr) noexcept(true) {
    std::free(ptr);
  }
};

void f() {
  S *s = new S;
  ::delete s;
}
```

## Compliant Solution (class new)

In this compliant solution, the scoped `::delete` call is replaced by a nonscoped `delete` call, resulting in `S::operator delete()` being called.

```cpp
#include <cstdlib>
#include <new>
 
struct S {
  static void *operator new(std::size_t size) noexcept(true) {
    return std::malloc(size);
  }
  
  static void operator delete(void *ptr) noexcept(true) {
    std::free(ptr);
  }
};

void f() {
  S *s = new S;
  delete s;
}
```

## Noncompliant Code Example (std::unique_ptr)

In this noncompliant code example, a `std::unique_ptr` is declared to hold a pointer to an object, but is direct-initialized with an array of objects. When the `std::unique_ptr` is destroyed, its default deleter calls `delete` instead of `delete[]`, resulting in undefined behavior.

```cpp
#include <memory>

struct S {};

void f() {
  std::unique_ptr<S> s{new S[10]};
}
```

## Compliant Solution (std::unique_ptr)

In this compliant solution, the `std::unique_ptr` is declared to hold an array of objects instead of a pointer to an object. Additionally, `std::make_unique()` is used to initialize the smart pointer.

```cpp
#include <memory>

struct S {};

void f() {
  std::unique_ptr<S[]> s = std::make_unique<S[]>(10);
}
```
Use of `std::make_unique()` instead of direct initialization will emit a diagnostic if the resulting `std::unique_ptr` is not of the correct type. Had it been used in the noncompliant code example, the result would have been an ill-formed program instead of undefined behavior. It is best to use `std::make_unique()` instead of manual initialization by other means.

## Noncompliant Code Example (std::shared_ptr)

In this noncompliant code example, a `std::shared_ptr` is declared to hold a pointer to an object, but is direct-initialized with an array of objects. As with `std::unique_ptr`, when the `std::shared_ptr` is destroyed, its default deleter calls `delete` instead of `delete[]`, resulting in undefined behavior.

```cpp
#include <memory>

struct S {};

void f() {
  std::shared_ptr<S> s{new S[10]};
}
```

## Compliant Solution (std::shared_ptr)

Unlike the compliant solution for `std::unique_ptr`, where `std::make_unique()` is called to create a unique pointer to an array, it is ill-formed to call `std::make_shared()` with an array type. Instead, this compliant solution manually specifies a custom deleter for the shared pointer type, ensuring that the underlying array is properly deleted.

```cpp
#include <memory>

struct S {};

void f() {
  std::shared_ptr<S> s{new S[10], [](const S *ptr) { delete [] ptr; }};
}
```

## Risk Assessment

Passing a pointer value to a deallocation function that was not previously obtained by the matching allocation function results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior), which can lead to exploitable [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM51-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>invalid_dynamic_memory_allocationdangling_pointer_use</strong> </td> <td> </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-MEM51</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>clang-analyzer-cplusplus.NewDeleteLeaks</code> <code>-Wmismatched-new-deleteclang-analyzer-unix.MismatchedDeallocator </code> </td> <td> Checked by <code>clang-tidy</code> , but does not catch all violations of this rule </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>ALLOC.FNHALLOC.DFALLOC.TMALLOC.LEAK</strong> </td> <td> Free non-heap variable Double free Type mismatch Leak </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2110, C++2111, C++2112, C++2113, C++2118, C++3337, C++3339, C++4262, C++4263, C++4264</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CL.FFM.ASSIGN</strong> <strong>CL.FFM.COPY</strong> <strong>CL.FMM</strong> <strong>CL.SHALLOW.ASSIGN</strong> <strong>CL.SHALLOW.COPY</strong> <strong>FMM.MIGHT</strong> <strong>FMM.MUST</strong> <strong>FNH.MIGHT</strong> <strong>FNH.MUST</strong> <strong>FUM.GEN.MIGHT</strong> <strong>FUM.GEN.MUST</strong> <strong>UNINIT.CTOR.MIGHT</strong> <strong>UNINIT.CTOR.MUST</strong> <strong>UNINIT.HEAP.MIGHT</strong> <strong>UNINIT.HEAP.MUST</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>232 S, 236 S, 239 S, 407 S, 469 S, 470 S, 483 S, 484 S, 485 S, 64 D, 112 D</strong> <strong> </strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MEM51-a</strong> <strong>CERT_CPP-MEM51-b</strong> <strong>CERT_CPP-MEM51-c</strong> <strong>CERT_CPP-MEM51-d</strong> </td> <td> Use the same form in corresponding calls to new/malloc and delete/free Always provide empty brackets (\[\]) for delete when deallocating arrays Both copy constructor and copy assignment operator should be declared for classes with a nontrivial destructor Properly deallocate dynamically allocated resources </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime detection </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: MEM51-CPP </a> </td> <td> Checks for: Invalid deletion of pointernvalid deletion of pointer, invalid free of pointernvalid free of pointer, deallocation of previously deallocated pointereallocation of previously deallocated pointer. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2110, 2111, 2112, 2113, 2118<strong>, </strong></strong> <strong><strong>3337, 3339</strong>, 4262, 4263, 4264</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong>V515<a></a></strong> , <strong>V554<a></a></strong> , <strong>V611<a></a></strong> , <strong>V701<a></a></strong> , <strong>V748<a></a></strong> , <strong>V773<a></a></strong> , <strong><a>V1066</a></strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S1232</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM31-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> MEM53-CPP. Explicitly construct and destruct objects when manually managing object lifetime </a> </td> </tr> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> MEM31-C. Free dynamically allocated memory when no longer needed </a> <a> MEM34-C. Only free memory allocated dynamically </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE 590 </a> , Free of Memory Not on the Heap <a> CWE 415 </a> , Double Free <a> CWE 404 </a> , Improper Resource Shutdown or Release <a> CWE 762 </a> , Mismatched Memory Management Routines </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Dowd 2007 </a> \] </td> <td> "Attacking <code>delete</code> and <code>delete \[\]</code> in C++" </td> </tr> <tr> <td> \[ <a> Henricson 1997 </a> \] </td> <td> Rule 8.1, " <code>delete</code> should only be used with <code>new"</code> Rule 8.2, " <code>delete \[\]</code> should only be used with <code>new \[\]"</code> </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 5.3.5, "Delete" Subclause 12.8, "Copying and Moving Class Objects" Subclause 18.6.1, "Storage Allocation and Deallocation" Subclause 20.7.11, "Temporary Buffers" </td> </tr> <tr> <td> \[ <a> Meyers 2005 </a> \] </td> <td> Item 16, "Use the Same Form in Corresponding Uses of <code>new</code> and <code>delete</code> " </td> </tr> <tr> <td> \[ <a> Seacord 2013 </a> \] </td> <td> Chapter 4, "Dynamic Memory Management" </td> </tr> <tr> <td> \[ <a> Viega 2005 </a> \] </td> <td> "Doubly Freeing Memory" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MEM51-CPP: Properly deallocate dynamically allocated resources](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
