# OOP56-CPP: Honor replacement handler requirements

This query implements the CERT-C++ rule OOP56-CPP:

> Honor replacement handler requirements


## Description

The *handler* functions `new_handler`, `terminate_handler`, and `unexpected_handler` can be globally replaced by custom [implementations](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation), as specified by \[handler.functions\], paragraph 2, of the C++ Standard \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]. For instance, an application could set a custom termination handler by calling `std::set_terminate()`, and the custom termination handler may log the termination for later auditing. However, the C++ Standard, \[res.on.functions\], paragraph 1, states the following:

> In certain cases (replacement functions, handler functions, operations on types used to instantiate standard library template components), the C++ standard library depends on components supplied by a C++ program. If these components do not meet their requirements, the Standard places no requirements on the implementation.


Paragraph 2, in part, further states the following:

> In particular, the effects are undefined in the following cases:— for handler functions, if the installed handler function does not implement the semantics of the applicable *Required behavior:* paragraph


A replacement for any of the handler functions must meet the semantic requirements specified by the appropriate *Required behavior:* clause of the replaced function.

**New Handler**

The requirements for a replacement `new_handler` are specified by \[new.handler\], paragraph 2:

> Required behavior: A `new_handler` shall perform one of the following:— make more storage available for allocation and then return;— throw an exception of type `bad_alloc` or a class derived from `bad_alloc`;— terminate execution of the program without returning to the caller;


**Terminate Handler**

The requirements for a replacement `terminate_handler` are specified by \[terminate.handler\], paragraph 2:

> Required behavior: A `terminate_handler` shall terminate execution of the program without returning to the caller.


**Unexpected Handler**

The requirements for a replacement `unexpected_handler` are specified by \[unexpected.handler\], paragraph 2.

> Required behavior: An `unexpected_handler` shall not return. See also 15.5.2.


`unexpected_handler` is a deprecated feature of C++.

## Noncompliant Code Example

In this noncompliant code example, a replacement `new_handler` is written to attempt to release salvageable resources when the dynamic memory manager runs out of memory. However, this example does not take into account the situation in which all salvageable resources have been recovered and there is still insufficient memory to satisfy the allocation request. Instead of terminating the replacement handler with an exception of type `std::bad_alloc` or terminating the execution of the program without returning to the caller, the replacement handler returns as normal. Under low memory conditions, an infinite loop will occur with the default implementation of `::operator new()`. Because such conditions are rare in practice, it is likely for this bug to go undiscovered under typical testing scenarios.

```cpp
#include <new>
 
void custom_new_handler() {
  // Returns number of bytes freed.
  extern std::size_t reclaim_resources();
  reclaim_resources();
}
 
int main() {
  std::set_new_handler(custom_new_handler);
 
  // ...
}
```

## Compliant Solution

In this compliant solution, `custom_new_handler()` uses the return value from `reclaim_resources()`. If it returns `0`, then there will be insufficient memory for `operator new` to succeed. Hence, an exception of type `std::bad_alloc` is thrown, meeting the requirements for the replacement handler.

```cpp
#include <new>

void custom_new_handler() noexcept(false) {
  // Returns number of bytes freed.
  extern std::size_t reclaim_resources();
  if (0 == reclaim_resources()) {
    throw std::bad_alloc();
  }
}
 
int main() {
  std::set_new_handler(custom_new_handler);
 
  // ...
}
```

## Risk Assessment

Failing to meet the required behavior for a replacement handler results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> OOP56-CPP </td> <td> Low </td> <td> Probable </td> <td> High </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4776, C++4777, C++4778, C++4779</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-OOP56-a</strong> <strong>CERT_CPP-OOP56-b</strong> <strong>CERT_CPP-OOP56-c</strong> </td> <td> Properly define terminate handlers Properly define unexpected handlers Properly define new handlers </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+OOP56-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> MEM55-CPP. Honor replacement dynamic storage management requirements </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 17.6.4.8, "Other Functions" Subclause 18.6.2.3, "Type <code>new_handler</code> " Subclause 18.8.3.1, "Type <code>terminate_handler</code> " Subclause D.11.1, "Type <code>unexpected_handler</code> " </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [OOP56-CPP: Honor replacement handler requirements](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
