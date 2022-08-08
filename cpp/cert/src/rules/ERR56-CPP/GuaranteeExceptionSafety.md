# ERR56-CPP: Guarantee exception safety

This query implements the CERT-C++ rule ERR56-CPP:

> Guarantee exception safety


## Description

Proper handling of errors and exceptional situations is essential for the continued correct operation of software. The preferred mechanism for reporting errors in a C++ program is exceptions rather than error codes. A number of core language facilities, including `dynamic_cast`, `operator new()`, and `typeid`, report failures by throwing exceptions. In addition, the C++ standard library makes heavy use of exceptions to report several different kinds of failures. Few C++ programs manage to avoid using some of these facilities. Consequently, the vast majority of C++ programs must be prepared for exceptions to occur and must handle each appropriately. (See [ERR51-CPP. Handle all exceptions](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR51-CPP.+Handle+all+exceptions).)

Because exceptions introduce code paths into a program, it is important to consider the effects of code taking such paths and to avoid any undesirable effects that might arise otherwise. Some such effects include failure to release an acquired resource, thereby introducing a leak, and failure to reestablish a class invariant after a partial update to an object or even a partial object update while maintaining all invariants. Code that avoids any such undesirable effects is said to be [exception safe](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exceptionsafety).

Based on the preceding effects, the following table distinguishes three kinds of exception safety guarantees from most to least desired.

<table> <tbody> <tr> <th> Guarantee </th> <th> Description </th> <th> Example </th> </tr> <tr> <td> <strong> <em>Strong</em> </strong> </td> <td> The strong exception safety guarantee is a property of an operation such that, in addition to satisfying the basic exception safety guarantee, if the operation terminates by raising an exception, it has no observable effects on program state. </td> <td> <a> Strong Exception Safety </a> </td> </tr> <tr> <td> <strong> <em>Basic</em> </strong> </td> <td> The basic exception safety guarantee is a property of an operation such that, if the operation terminates by raising an exception, it preserves program state invariants and prevents resource leaks. </td> <td> Basic Exception Safety </td> </tr> <tr> <td> <strong> <em>None</em> </strong> </td> <td> Code that provides neither the strong nor basic exception safety guarantee is not exception safe. </td> <td> <a> No Exception Safety </a> </td> </tr> </tbody> </table>
Code that guarantees strong exception safety also guarantees basic exception safety.


Because all exceptions thrown in an application must be handled, in compliance with [ERR50-CPP. Do not abruptly terminate the program](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR50-CPP.+Do+not+abruptly+terminate+the+program), it is critical that thrown exceptions do not leave the program in an indeterminate state where invariants are violated. That is, the program must provide basic exception safety for all invariants and may choose to provide strong exception safety for some invariants. Whether exception handling is used to control the termination of the program or to recover from an exceptional situation, a violated invariant leaves the program in a state where graceful continued execution is likely to introduce security vulnerabilities. Thus, code that provides no exception safety guarantee is unsafe and must be considered defective.

## Noncompliant Code Example (No Exception Safety)

The following noncompliant code example shows a flawed copy assignment operator. The implicit invariants of the class are that the `array` member is a valid (possibly null) pointer and that the `nElems` member stores the number of elements in the array pointed to by `array`. The function deallocates `array` and assigns the element counter, `nElems`, before allocating a new block of memory for the copy. As a result, if the `new` expression throws an exception, the function will have modified the state of both member variables in a way that violates the implicit invariants of the class. Consequently, such an object is in an indeterminate state and any operation on it, including its destruction, results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <cstring>
 
class IntArray {
  int *array;
  std::size_t nElems;
public:
  // ...

  ~IntArray() {
    delete[] array;
  }

 
  IntArray(const IntArray& that); // nontrivial copy constructor
  IntArray& operator=(const IntArray &rhs) {
    if (this != &rhs) {
      delete[] array;
      array = nullptr;
      nElems = rhs.nElems;
      if (nElems) {
        array = new int[nElems];
        std::memcpy(array, rhs.array, nElems * sizeof(*array));
      }
    }
    return *this;
  }

  // ...
};

```

## Compliant Solution (Strong Exception Safety)

In this compliant solution, the copy assignment operator provides the [strong exception safety](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-strongexceptionsafety) guarantee. The function allocates new storage for the copy before changing the state of the object. Only after the allocation succeeds does the function proceed to change the state of the object. In addition, by copying the array to the newly allocated storage before deallocating the existing array, the function avoids the test for self-assignment, which improves the performance of the code in the common case \[[Sutter 2004](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Sutter04)\].

```cpp
#include <cstring>
 
class IntArray {
  int *array;
  std::size_t nElems;
public:
  // ...

  ~IntArray() {
    delete[] array;
  }

  IntArray(const IntArray& that); // nontrivial copy constructor

  IntArray& operator=(const IntArray &rhs) {
    int *tmp = nullptr;
    if (rhs.nElems) {
      tmp = new int[rhs.nElems];
      std::memcpy(tmp, rhs.array, rhs.nElems * sizeof(*array));
    }
    delete[] array;
    array = tmp;
    nElems = rhs.nElems;
    return *this;
  }

  // ...
};

```

## Risk Assessment

Code that is not exception safe typically leads to resource leaks, causes the program to be left in an inconsistent or unexpected state, and ultimately results in undefined behavior at some point after the first exception is thrown.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR56-CPP </td> <td> High </td> <td> Likely </td> <td> High </td> <td> <strong>P9</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>ALLOC.LEAK</strong> </td> <td> Leak </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4075, C++4076</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>527 S, 56 D, 71 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR56-aCERT_CPP-ERR56-b</strong> </td> <td> Always catch exceptions Do not leave 'catch' blocks empty </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: ERR56-CPP </a> </td> <td> Checks for exceptions violating class invariant (rule fully covered). </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4075, 4076</strong> <strong> </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V565</a>, <a>V1023</a>, <a>V5002</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for vulnerabilities resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR56-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> ERR51-CPP. Handle all exceptions </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-703 </a> , Failure to Handle Exceptional Conditions <a> CWE-754 </a> , Improper Check for Unusual or Exceptional Conditions <a> CWE-755 </a> , Improper Handling of Exceptional Conditions </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Clause 15, "Exception Handling" </td> </tr> <tr> <td> \[ <a> Stroustrup 2001 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Sutter 2000 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Sutter 2001 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Sutter 2004 </a> \] </td> <td> 55. "Prefer the canonical form of assignment." </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR56-CPP: Guarantee exception safety](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
