# FIO50-CPP: Do not alternately input and output from a file stream without an intervening positioning call

This query implements the CERT-C++ rule FIO50-CPP:

> Do not alternately input and output from a file stream without an intervening positioning call


## Description

The C++ Standard, \[filebuf\], paragraph 2 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> The restrictions on reading and writing a sequence controlled by an object of class `basic_filebuf<charT, traits>` are the same as for reading and writing with the Standard C library `FILE`s.


The C Standard, subclause 7.19.5.3, paragraph 6 \[[ISO/IEC 9899:1999](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-1999)\], places the following restrictions on `FILE` objects opened for both reading and writing:

> When a file is opened with update mode . . ., both input and output may be performed on the associated stream. However, output shall not be directly followed by input without an intervening call to the `fflush` function or to a file positioning function (`fseek`, `fsetpos`, or `rewind`), and input shall not be directly followed by output without an intervening call to a file positioning function, unless the input operation encounters end-of-file.


Consequently, the following scenarios can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior):

* Receiving input from a stream directly following an output to that stream without an intervening call to `std::basic_filebuf<T>::seekoff()` if the file is not at end-of-file
* Outputting to a stream after receiving input from that stream without a call to `std::basic_filebuf<T>::seekoff()` if the file is not at end-of-file
No other `std::basic_filebuf<T>` function guarantees behavior as if a call were made to a standard C library file-positioning function, or `std::fflush()`.

Calling `std::basic_ostream<T>::seekp()` or `std::basic_istream<T>::seekg()` eventually results in a call to `std::basic_filebuf<T>::seekoff()` for file stream positioning. Given that `std::basic_iostream<T>` inherits from both `std::basic_ostream<T>` and `std::basic_istream<T>`, and `std::fstream` inherits from `std::basic_iostream`, either function is acceptable to call to ensure the file buffer is in a valid state before the subsequent I/O operation.

## Noncompliant Code Example

This noncompliant code example appends data to the end of a file and then reads from the same file. However, because there is no intervening positioning call between the formatted output and input calls, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <fstream>
#include <string>

void f(const std::string &fileName) {
  std::fstream file(fileName);
  if (!file.is_open()) {
    // Handle error
    return;
  }
  
  file << "Output some data";
  std::string str;
  file >> str;
}

```

## Compliant Solution

In this compliant solution, the `std::basic_istream<T>::seekg()` function is called between the output and input, eliminating the [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <fstream>
#include <string>

void f(const std::string &fileName) {
  std::fstream file(fileName);
  if (!file.is_open()) {
    // Handle error
    return;
  }
  
  file << "Output some data";
 
  std::string str;
  file.seekg(0, std::ios::beg);
  file >> str;
}

```

## Risk Assessment

Alternately inputting and outputting from a stream without an intervening flush or positioning call is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO50-CPP </td> <td> Low </td> <td> Likely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-FIO50</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>IO.IOWOP</strong> <strong>IO.OIWOP</strong> </td> <td> Input After Output Without Positioning Output After Input Without Positioning </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4711, C++4712, C++4713</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-FIO50-a</strong> </td> <td> Do not alternately input and output from a stream without an intervening flush or positioning call </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: FIO50-CPP </a> </td> <td> Checks for alternating input and output from a stream without flush or positioning call (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabilit) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO39-CPP).

## Related Guidelines

*This rule supplements**[FIO39-C. Do not alternately input and output from a stream without an intervening flush or positioning call](https://wiki.sei.cmu.edu/confluence/display/c/FIO39-C.+Do+not+alternately+input+and+output+from+a+stream+without+an+intervening+flush+or+positioning+call).*

<table> <tbody> <tr> <td> </td> <td> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:1999 </a> \] </td> <td> Subclause 7.19.5.3, "The <code>fopen</code> Function" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Clause 27, "Input/Output Library" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [FIO50-CPP: Do not alternately input and output from a file stream without an intervening positioning call](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
