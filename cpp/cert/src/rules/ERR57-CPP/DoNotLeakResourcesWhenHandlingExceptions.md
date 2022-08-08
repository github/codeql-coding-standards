# ERR57-CPP: Do not leak resources when handling exceptions

This query implements the CERT-C++ rule ERR57-CPP:

> Do not leak resources when handling exceptions


## Description

Reclaiming resources when exceptions are thrown is important. An exception being thrown may result in cleanup code being bypassed or an object being left in a partially initialized state. Such a partially initialized object would violate basic exception safety, as described in [ERR56-CPP. Guarantee exception safety](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR56-CPP.+Guarantee+exception+safety). It is preferable that resources be reclaimed automatically, using the [RAII](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-RAII) design pattern \[[Stroustrup 2001](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Stroustrup01)\], when objects go out of scope. This technique avoids the need to write complex cleanup code when allocating resources.

However, constructors do not offer the same protection. Because a constructor is involved in allocating resources, it does not automatically free any resources it allocates if it terminates prematurely. The C++ Standard, \[except.ctor\], paragraph 2 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> An object of any storage duration whose initialization or destruction is terminated by an exception will have destructors executed for all of its fully constructed subobjects (excluding the variant members of a union-like class), that is, for subobjects for which the principal constructor (12.6.2) has completed execution and the destructor has not yet begun execution. Similarly, if the non-delegating constructor for an object has completed execution and a delegating constructor for that object exits with an exception, the object’s destructor will be invoked. If the object was allocated in a new-expression, the matching deallocation function (3.7.4.2, 5.3.4, 12.5), if any, is called to free the storage occupied by the object.


It is generally recommended that constructors that cannot complete their job should throw exceptions rather than exit normally and leave their object in an incomplete state \[[Cline 2009](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Cline09)\].

Resources must not be leaked as a result of throwing an exception, including during the construction of an object.

*This rule is a subset of [MEM51-CPP. Properly deallocate dynamically allocated resources](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM51-CPP.+Properly+deallocate+dynamically+allocated+resources), as all failures to deallocate resources violate that rule.*

## Noncompliant Code Example

In this noncompliant code example, `pst` is not properly released when `process_item` throws an exception, causing a resource leak.

```cpp
#include <new>
 
struct SomeType {
  SomeType() noexcept; // Performs nontrivial initialization.
  ~SomeType(); // Performs nontrivial finalization.
  void process_item() noexcept(false);
};
 
void f() {
  SomeType *pst = new (std::nothrow) SomeType();
  if (!pst) {
    // Handle error
    return;
  }
 
  try {
    pst->process_item();
  } catch (...) {
    // Process error, but do not recover from it; rethrow.
    throw;
  }
  delete pst;
}

```

## Compliant Solution (delete)

In this compliant solution, the exception handler frees `pst` by calling `delete.`

```cpp
#include <new>

struct SomeType {
  SomeType() noexcept; // Performs nontrivial initialization.
  ~SomeType(); // Performs nontrivial finalization.

  void process_item() noexcept(false);
};

void f() {
  SomeType *pst = new (std::nothrow) SomeType();
  if (!pst) {
    // Handle error
    return;
  }
  try {
    pst->process_item();
  } catch (...) {
    // Process error, but do not recover from it; rethrow.
    delete pst;
    throw;
  }
  delete pst;
}
```
While this compliant solution properly releases its resources using `catch` clauses, this approach can have some disadvantages:

* Each distinct cleanup requires its own `try` and `catch` blocks.
* The cleanup operation must not throw any exceptions.

## Compliant Solution (RAII Design Pattern)

A better approach is to employ RAII. This pattern forces every object to clean up after itself in the face of abnormal behavior, preventing the programmer from having to do so. Another benefit of this approach is that it does not require statements to handle resource allocation errors, in conformance with [MEM52-CPP. Detect and handle memory allocation errors](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM52-CPP.+Detect+and+handle+memory+allocation+errors).

```cpp
struct SomeType {
  SomeType() noexcept; // Performs nontrivial initialization.
  ~SomeType(); // Performs nontrivial finalization.

  void process_item() noexcept(false);
};

void f() {
  SomeType st;
  try {
    st.process_item();
  } catch (...) {
    // Process error, but do not recover from it; rethrow.
    throw;
  } // After re-throwing the exception, the destructor is run for st.
} // If f() exits without throwing an exception, the destructor is run for st.

```

## Noncompliant Code Example

In this noncompliant code example, the `C::C()` constructor might fail to allocate memory for `a`, might fail to allocate memory for `b`, or might throw an exception in the `init()` method. If `init()` throws an exception, neither `a` nor `b` will be released. Likewise, if the allocation for `b` fails, `a` will not be released.

```cpp
struct A {/* ... */};
struct B {/* ... */};

class C {
  A *a;
  B *b;
protected:
  void init() noexcept(false);
public:
  C() : a(new A()), b(new B()) {
    init();
  }
};

```

## Compliant Solution (try/catch)

This compliant solution mitigates the potential failures by releasing `a` and `b` if an exception is thrown during their allocation or during `init()`.

```cpp
struct A {/* ... */};
struct B {/* ... */};
 
class C {
  A *a;
  B *b;
protected:
  void init() noexcept(false);
public:
  C() : a(nullptr), b(nullptr) {
    try {
      a = new A();
      b = new B();
      init();
    } catch (...) {
      delete a;
      delete b;
      throw;
    }
  }
};

```

## Compliant Solution (std::unique_ptr)

This compliant solution uses `std::unique_ptr` to create objects that clean up after themselves should anything go wrong in the `C::C()` constructor. The `std::unique_ptr` applies the principles of RAII to pointers.

```cpp
#include <memory>
 
struct A {/* ... */};
struct B {/* ... */};

class C {
  std::unique_ptr<A> a;
  std::unique_ptr<B> b;
protected:
  void init() noexcept(false);
public:
  C() : a(new A()), b(new B()) {
    init();
  }
};
```

## Risk Assessment

Memory and other resource leaks will eventually cause a program to crash. If an attacker can provoke repeated resource leaks by forcing an exception to be thrown through the submission of suitably crafted data, then the attacker can mount a [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR57-CPP </td> <td> Low </td> <td> Probable </td> <td> High </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>ALLOC.LEAK</strong> </td> <td> Leak </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4756, C++4757, C++4758</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CL.MLK</strong> <strong>MLK.MIGHT</strong> <strong>MLK.MUST</strong> <strong>MLK.RET.MIGHT</strong> <strong>MLK.RET.MUST</strong> <strong>RH.LEAK</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>50 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR57-a</strong> </td> <td> Ensure resources are freed </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: ERR57-CPP </a> </td> <td> Checks for: Resource leak caused by exceptionesource leak caused by exception, object left in partially initialized statebject left in partially initialized state, bad allocation in constructorad allocation in constructor. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR57-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> MEM51-CPP. Properly deallocate dynamically allocated resources </a> <a> MEM52-CPP. Detect and handle memory allocation errors </a> <a> ERR56-CPP. Guarantee exception safety </a> <a> </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Cline 2009 </a> \] </td> <td> Question 17.2, I'm still not convinced: A 4-line code snippet shows that return-codes aren't any worse than exceptions; why should I therefore use exceptions on an application that is orders of magnitude larger? </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 15.2, "Constructors and Destructors" </td> </tr> <tr> <td> \[ <a> Meyers 1996 </a> \] </td> <td> Item 9, "Use Destructors to Prevent Resource Leaks" </td> </tr> <tr> <td> \[ <a> Stroustrup 2001 </a> \] </td> <td> "Exception-Safe Implementation Techniques" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR57-CPP: Do not leak resources when handling exceptions](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
