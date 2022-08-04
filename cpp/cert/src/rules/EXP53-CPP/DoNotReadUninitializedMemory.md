# EXP53-CPP: Do not read uninitialized memory

This query implements the CERT-C++ rule EXP53-CPP:

> Do not read uninitialized memory


## Description

Local, automatic variables assume unexpected values if they are read before they are initialized. The C++ Standard, \[dcl.init\], paragraph 12 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> If no initializer is specified for an object, the object is default-initialized. When storage for an object with automatic or dynamic storage duration is obtained, the object has an *indeterminate value*, and if no initialization is performed for the object, that object retains an indeterminate value until that value is replaced. If an indeterminate value is produced by an evaluation, the behavior is undefined except in the following cases:


— If an indeterminate value of unsigned narrow character type is produced by the evaluation of: — the second or third operand of a conditional expression, — the right operand of a comma expression, — the operand of a cast or conversion to an unsigned narrow character type, or — a discarded-value expression,then the result of the operation is an indeterminate value.— If an indeterminate value of unsigned narrow character type is produced by the evaluation of the right operand of a simple assignment operator whose first operand is an lvalue of unsigned narrow character type, an indeterminate value replaces the value of the object referred to by the left operand.— If an indeterminate value of unsigned narrow character type is produced by the evaluation of the initialization expression when initializing an object of unsigned narrow character type, that object is initialized to an indeterminate value.

The default initialization of an object is described by paragraph 7 of the same subclause:

> To *default-initialize* an object of type `T` means:— if `T` is a (possibly cv-qualified) class type, the default constructor for `T` is called (and the initialization is ill-formed if `T` has no default constructor or overload resolution results in an ambiguity or in a function that is deleted or inaccessible from the context of the initialization);— if `T` is an array type, each element is default-initialized;— otherwise, no initialization is performed.If a program calls for the default initialization of an object of a const-qualified type `T`, `T` shall be a class type with a user-provided default constructor.


As a result, objects of type `T` with automatic or dynamic storage duration must be explicitly initialized before having their value read as part of an expression unless `T` is a class type or an array thereof or is an unsigned narrow character type. If `T` is an unsigned narrow character type, it may be used to initialize an object of unsigned narrow character type, which results in both objects having an [indeterminate value](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-indeterminatevalue). This technique can be used to implement copy operations such as `std::memcpy()` without triggering [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

Additionally, memory dynamically allocated with a `new` expression is default-initialized when the *new-initialized* is omitted. Memory allocated by the standard library function `std::calloc()` is zero-initialized. Memory allocated by the standard library function `std::realloc()` assumes the values of the original pointer but may not initialize the full range of memory. Memory allocated by any other means ( `std::malloc()`, allocator objects, `operator new()`, and so on) is assumed to be default-initialized.

Objects of static or thread storage duration are zero-initialized before any other initialization takes place \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\] and need not be explicitly initialized before having their value read.

Reading uninitialized variables for creating entropy is problematic because these memory accesses can be removed by compiler optimization. VU925211 is an example of a [vulnerability](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) caused by this coding error \[[VU\#925211](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-VU925211)\].

## Noncompliant Code Example

In this noncompliant code example, an uninitialized local variable is evaluated as part of an expression to print its value, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <iostream>
 
void f() {
  int i;
  std::cout << i;
}
```

## Compliant Solution

In this compliant solution, the object is initialized prior to printing its value.

```cpp
#include <iostream>
 
void f() {
  int i = 0;
  std::cout << i;
}
```

## Noncompliant Code Example

In this noncompliant code example, an `int *` object is allocated by a *new-expression*, but the memory it points to is not initialized. The object's pointer value and the value it points to are printed to the standard output stream. Printing the pointer value is well-defined, but attempting to print the value pointed to yields an [indeterminate value](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-indeterminatevalue), resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <iostream>
 
void f() {
  int *i = new int;
  std::cout << i << ", " << *i;
}
```

## Compliant Solution

In this compliant solution, the memory is direct-initialized to the value `12` prior to printing its value.

```cpp
#include <iostream>
 
void f() {
  int *i = new int(12);
  std::cout << i << ", " << *i;
}
```
Initialization of an object produced by a *new-expression* is performed by placing (possibly empty) parenthesis or curly braces after the type being allocated. This causes direct initialization of the pointed-to object to occur, which will zero-initialize the object if the initialization omits a value, as illustrated by the following code.

```cpp
int *i = new int(); // zero-initializes *i
int *j = new int{}; // zero-initializes *j
int *k = new int(12); // initializes *k to 12
int *l = new int{12}; // initializes *l to 12
```

## Noncompliant Code Example

In this noncompliant code example, the class member variable `c` is not explicitly initialized by a *ctor-initializer* in the default constructor. Despite the local variable `s` being default-initialized, the use of `c` within the call to `S::f()` results in the evaluation of an object with indeterminate value, resulting in undefined behavior.

```cpp
class S {
  int c;
 
public:
  int f(int i) const { return i + c; }
};
 
void f() {
  S s;
  int i = s.f(10);
}
```

## Compliant Solution

In this compliant solution, `S` is given a default constructor that initializes the class member variable `c.`

```cpp
class S {
  int c;
 
public:
  S() : c(0) {}
  int f(int i) const { return i + c; }
};
 
void f() {
  S s;
  int i = s.f(10);
}
```

## Risk Assessment

Reading uninitialized variables is undefined behavior and can result in unexpected program behavior. In some cases, these [security flaws](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-securityflaw) may allow the execution of arbitrary code.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP53-CPP </td> <td> High </td> <td> Probable </td> <td> Medium </td> <td> <strong>P12</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>uninitialized-read</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wuninitialized</code> <code>clang-analyzer-core.UndefinedBinaryOperatorResult</code> </td> <td> Does not catch all instances of this rule, such as uninitialized values read from heap-allocated memory. </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.RPLLANG.MEM.UVAR</strong> </td> <td> Return pointer to local Uninitialized variable </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2726, C++2727, C++2728, C++2961, C++2962, C++2963, C++2966, C++2967, C++2968, C++2971, C++2972, C++2973, C++2976, C++2977, C++2978</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>UNINIT.CTOR.MIGHT</strong> <strong>UNINIT.CTOR.MUST</strong> <strong>UNINIT.HEAP.MIGHT</strong> <strong>UNINIT.HEAP.MUST</strong> <strong>UNINIT.STACK.ARRAY.MIGHT</strong> <strong>UNINIT.STACK.ARRAY.MUST</strong> <strong>UNINIT.STACK.ARRAY.PARTIAL.MUST</strong> <strong>UNINIT.STACK.MIGHT</strong> <strong>UNINIT.STACK.MUST</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>53 D, 69 D, 631 S, 652 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP53-a</strong> </td> <td> Avoid use before initialization </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime detection </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: EXP53-CPP </a> </td> <td> Checks for: Non-initialized variableon-initialized variable, non-initialized pointeron-initialized pointer. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2726, 2727, 2728, 2961, 2962, 2963, 2966, 2967, 2968, 2971, 2972, 2973, 2976, 2977, 2978</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong>V546<a></a></strong> , <strong>V573<a></a></strong> , <strong><a>V614</a></strong> , <strong><a>V670</a></strong> , <strong><a>V679</a></strong> , <strong><a>V730</a></strong> , <strong>V788<a></a></strong> , <strong><a>V1007</a></strong> , <strong><a>V1050</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>uninitialized-read</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP33-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> EXP33-C. Do not read uninitialized memory </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Clause 5, "Expressions" Subclause 5.3.4, "New" Subclause 8.5, "Initializers" Subclause 12.6.2, "Initializing Bases and Members" </td> </tr> <tr> <td> \[ <a> Lockheed Martin 2005 </a> \] </td> <td> Rule 142, All variables shall be initialized before use </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP53-CPP: Do not read uninitialized memory](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
