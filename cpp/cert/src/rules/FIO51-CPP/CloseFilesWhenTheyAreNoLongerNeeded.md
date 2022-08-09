# FIO51-CPP: Close files when they are no longer needed

This query implements the CERT-C++ rule FIO51-CPP:

> Close files when they are no longer needed


## Description

A call to the `std::basic_filebuf<T>::open()` function must be matched with a call to `std::basic_filebuf<T>::close()` before the lifetime of the last pointer that stores the return value of the call has ended or before normal program termination, whichever occurs first.

Note that `std::basic_ifstream<T>`, `std::basic_ofstream<T>`, and `std::basic_fstream<T>` all maintain an internal reference to a `std::basic_filebuf<T>` object on which `open()` and `close()` are called as needed. Properly managing an object of one of these types (by not leaking the object) is sufficient to ensure compliance with this rule. Often, the best solution is to use the stream object by value semantics instead of via dynamic memory allocation, ensuring compliance with [MEM51-CPP. Properly deallocate dynamically allocated resources](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM51-CPP.+Properly+deallocate+dynamically+allocated+resources). However, that is still insufficient for situations in which destructors are not automatically called.

## Noncompliant Code Example

In this noncompliant code example, a `std::fstream` object `file` is constructed. The constructor for `std::fstream` calls `std::basic_filebuf<T>::open()`, and the default `std::terminate_handler` called by `std::terminate()` is `std::abort()`, which does not call destructors. Consequently, the underlying `std::basic_filebuf<T>` object maintained by the object is not properly closed.

```cpp
#include <exception>
#include <fstream>
#include <string>

void f(const std::string &fileName) {
  std::fstream file(fileName);
  if (!file.is_open()) {
    // Handle error
    return;
  }
  // ...
  std::terminate();
}
```
This noncompliant code example and the subsequent compliant solutions are assumed to eventually call `std::terminate()` in accordance with the ERR50-CPP-EX1 exception described in [ERR50-CPP. Do not abruptly terminate the program](https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR50-CPP.+Do+not+abruptly+terminate+the+program). Indicating the nature of the problem to the operator is elided for brevity.

## Compliant Solution

In this compliant solution, `std::fstream::close()` is called before `std::terminate()` is called, ensuring that the file resources are properly closed.

```cpp
#include <exception>
#include <fstream>
#include <string>

void f(const std::string &fileName) {
  std::fstream file(fileName);
  if (!file.is_open()) {
    // Handle error
    return;
  }
  // ...
  file.close();
  if (file.fail()) {
    // Handle error
  }
  std::terminate();
}

```

## Compliant Solution

In this compliant solution, the stream is implicitly closed through [RAII](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-RAII) before `std::terminate()` is called, ensuring that the file resources are properly closed.

```cpp
#include <exception>
#include <fstream>
#include <string>

void f(const std::string &fileName) {
  {
    std::fstream file(fileName);
    if (!file.is_open()) {
      // Handle error
      return;
    }
  } // file is closed properly here when it is destroyed
  std::terminate();
}
```

## Risk Assessment

Failing to properly close files may allow an attacker to exhaust system resources and can increase the risk that data written into in-memory file buffers will not be flushed in the event of [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO51-CPP </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>ALLOC.LEAK</strong> </td> <td> Leak </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4786, C++4787, C++4788</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>RH.LEAK</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-FIO51-a</strong> </td> <td> Ensure resources are freed </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime detection </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: FIO51-CPP </a> </td> <td> Checks for resource leak (rule partially covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabili) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO42-CPP).

## Related Guidelines

*This rule supplements [FIO42-C. Close files when they are no longer needed](https://wiki.sei.cmu.edu/confluence/display/c/FIO42-C.+Close+files+when+they+are+no+longer+needed).*

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> MEM51-CPP. Properly deallocate dynamically allocated resources </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 27.9.1, "File Streams" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [FIO51-CPP: Close files when they are no longer needed](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
