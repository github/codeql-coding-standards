# STR50-CPP: A C-style string shall guarantee sufficient space for data and the null terminator

This query implements the CERT-C++ rule STR50-CPP:

> Guarantee that storage for strings has sufficient space for character data and the null terminator


## Description

Copying data to a buffer that is not large enough to hold that data results in a buffer overflow. Buffer overflows occur frequently when manipulating strings \[[Seacord 2013](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-Seacord2013)\]. To prevent such errors, either limit copies through truncation or, preferably, ensure that the destination is of sufficient size to hold the data to be copied. C-style strings require a null character to indicate the end of the string, while the C++ `std::basic_string` template requires no such character.

## Noncompliant Code Example

Because the input is unbounded, the following code could lead to a buffer overflow.

```cpp
#include <iostream>
 
void f() {
  char buf[12];
  std::cin >> buf;
}
```

## Noncompliant Code Example

To solve this problem, it may be tempting to use the `std::ios_base::width()` method, but there still is a trap, as shown in this noncompliant code example.

```cpp
#include <iostream>
 
void f() {
  char bufOne[12];
  char bufTwo[12];
  std::cin.width(12);
  std::cin >> bufOne;
  std::cin >> bufTwo;
}
```
In this example, the first read will not overflow, but could fill `bufOne` with a truncated string. Furthermore, the second read still could overflow `bufTwo`. The C++ Standard, \[istream.extractors\], paragraphs 7–9 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], describes the behavior of `operator>>(basic_istream &, charT *)` and, in part, states the following:

> `operator>>` then stores a null byte (`charT()`) in the next position, which may be the first position if no characters were extracted. `operator>>` then calls `width(0)`.


Consequently, it is necessary to call `width()` prior to each `operator>>` call passing a bounded array. However, this does not account for the input being truncated, which may lead to information loss or a possible [vulnerability](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability).

## Compliant Solution

The best solution for ensuring that data is not truncated and for guarding against buffer overflows is to use `std::string` instead of a bounded array, as in this compliant solution.

```cpp
#include <iostream>
#include <string>
 
void f() {
  std::string input;
  std::string stringOne, stringTwo;
  std::cin >> stringOne >> stringTwo;
}
```

## Noncompliant Code Example

In this noncompliant example, the unformatted input function `std::basic_istream<T>::read()` is used to read an unformatted character array of 32 characters from the given file. However, the `read()` function does not guarantee that the string will be null terminated, so the subsequent call of the `std::string` constructor results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) if the character array does not contain a null terminator.

```cpp
#include <fstream>
#include <string>
 
void f(std::istream &in) {
  char buffer[32];
  try {
    in.read(buffer, sizeof(buffer));
  } catch (std::ios_base::failure &e) {
    // Handle error
  }
 
  std::string str(buffer);
  // ...
}
```

## Compliant Solution

This compliant solution assumes that the input from the file is at most 32 characters. Instead of inserting a null terminator, it constructs the `std::string` object based on the number of characters read from the input stream. If the size of the input is uncertain, it is better to use `std::basic_istream<T>::readsome()` or a formatted input function, depending on need.

```cpp
#include <fstream>
#include <string>

void f(std::istream &in) {
  char buffer[32];
  try {
    in.read(buffer, sizeof(buffer));
  } catch (std::ios_base::failure &e) {
    // Handle error
  }
  std::string str(buffer, in.gcount());
  // ...
}
```

## Risk Assessment

Copying string data to a buffer that is too small to hold that data results in a buffer overflow. Attackers can [exploit](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) this condition to execute arbitrary code with the permissions of the vulnerable process.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR50-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>MISC.MEM.NTERM</strong> <strong>LANG.MEM.BOLANG.MEM.TO</strong> </td> <td> No space for null terminator Buffer overrun Type overrun </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++2835, C++2836, C++2839, C++5216</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>NNTS.MIGHT</strong> <strong>NNTS.TAINTED</strong> <strong>NNTS.MUST</strong> <strong>SV.UNBOUND_STRING_INPUT.CIN</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>489 S, 66 X, 70 X, 71 X</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-STR50-b</strong> <strong>CERT_CPP-STR50-c</strong> <strong>CERT_CPP-STR50-e</strong> <strong>CERT_CPP-STR50-f</strong> <strong>CERT_CPP-STR50-g</strong> </td> <td> Avoid overflow due to reading a not zero terminated string Avoid overflow when writing to a buffer Prevent buffer overflows from tainted data Avoid buffer write overflow from tainted data Do not use the 'char' buffer to store input from 'std::cin' </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: STR50-CPP </a> </td> <td> Checks for: Use of dangerous standard functionse of dangerous standard function, missing null in string arrayissing null in string array, buffer overflow from incorrect string format specifieruffer overflow from incorrect string format specifier, destination buffer overflow in string manipulationestination buffer overflow in string manipulation. Rule partially covered. </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S3519</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+STR35-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> STR31-C. Guarantee that storage for strings has sufficient space for character data and the null terminator </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 27.7.2.2.3, " <code>basic_istream::operator&gt;&gt;</code> " Subclause 27.7.2.3, "Unformatted Input Functions" </td> </tr> <tr> <td> \[ <a> Seacord 2013 </a> \] </td> <td> Chapter 2, "Strings" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [STR50-CPP: Guarantee that storage for strings has sufficient space for character data and the null terminator](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
