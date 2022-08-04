# ERR62-CPP: Detect errors when converting a string to a number

This query implements the CERT-C++ rule ERR62-CPP:

> Detect errors when converting a string to a number


## Description

The process of parsing an integer or floating-point number from a string can produce many errors. The string might not contain a number. It might contain a number of the correct type that is out of range (such as an integer that is larger than `INT_MAX`). The string may also contain extra information after the number, which may or may not be useful after the conversion. These error conditions must be detected and addressed when a string-to-number conversion is performed using a formatted input stream such as `std::istream` or the locale facet `num_get<>`.

When calling a formatted input stream function like `istream::operator>>()`, information about conversion errors is queried through the `basic_ios::good()`, `basic_ios::bad()`, and `basic_ios::fail()` inherited member functions or through exception handling if it is enabled on the stream object.

When calling `num_get<>::get()`, information about conversion errors is returned to the caller through the `ios_base::iostate&` argument. The C++ Standard, section \[facet.num.get.virtuals\], paragraph 3 \[[ISO/IEC 14882-2014](https://www.securecoding.cert.org/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], in part, states the following:

> If the conversion function fails to convert the entire field, or if the field represents a value outside the range of representable values, `ios_base::failbit` is assigned to `err`.


Always explicitly check the error state of a conversion from string to a numeric value (or handle the related exception, if applicable) instead of assuming the conversion results in a valid value. This rule is in addition to [ERR34-C. Detect errors when converting a string to a number](https://wiki.sei.cmu.edu/confluence/display/c/ERR34-C.+Detect+errors+when+converting+a+string+to+a+number), which bans the use of conversion functions that do not perform conversion validation such as `std::atoi()` and `std::scanf()` from the C Standard Library.

## Noncompliant Code Example

In this noncompliant code example, multiple numeric values are converted from the standard input stream. However, if the text received from the standard input stream cannot be converted into a numeric value that can be represented by an `int`, the resulting value stored into the variables `i` and `j` may be unexpected.

```cpp
#include <iostream>

void f() {
  int i, j;
  std::cin >> i >> j;
  // ...
}
```
For instance, if the text `12345678901234567890` is the first converted value read from the standard input stream, then `i` will have the value `std::numeric_limits<int>::max()` (per \[facet.num.get.virtuals\] paragraph 3), and `j` will be uninitialized (per \[istream.formatted.arithmetic\] paragraph 3). If the text `abcdefg` is the first converted value read from the standard input stream, then `i` will have the value `0` and `j` will remain uninitialized.

## Compliant Solution

In this compliant solution, exceptions are enabled so that any conversion failure results in an exception being thrown. However, this approach cannot distinguish between which values are valid and which values are invalid and must assume that all values are invalid. Both the `badbit` and `failbit` flags are set to ensure that conversion errors as well as loss of integrity with the stream are treated as exceptions.

```cpp
#include <iostream>

void f() {
  int i, j;

  std::cin.exceptions(std::istream::failbit | std::istream::badbit);
  try {     
    std::cin >> i >> j;
    // ...
  } catch (std::istream::failure &E) {
    // Handle error
  }
}
```

## Compliant Solution

In this compliant solution, each converted value read from the standard input stream is tested for validity before reading the next value in the sequence, allowing error recovery on a per-value basis. It checks `std::istream::fail()` to see if the failure bit was set due to a conversion failure or whether the bad bit was set due to a loss of integrity with the stream object. If a failure condition is encountered, it is cleared on the input stream and then characters are read and discarded until a `' '` (space) character occurs. The error handling in this case only works if a space character is what delimits the two numeric values to be converted.

```cpp
#include <iostream>
#include <limits>

void f() {
  int i;
  std::cin >> i;
  if (std::cin.fail()) {
    // Handle failure to convert the value.
    std::cin.clear();
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), ' ');
  }
  
  int j;
  std::cin >> j;
  if (std::cin.fail()) {
    std::cin.clear();
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), ' ');
  }
 
  // ...
}
```

## Risk Assessment

It is rare for a violation of this rule to result in a security [vulnerability](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) unless it occurs in security-sensitive code. However, violations of this rule can easily result in lost or misinterpreted data.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR62-CPP </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-ERR62</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>cert-err34-c</code> </td> <td> Checked by <code>clang-tidy</code> ; only identifies use of unsafe C Standard Library functions corresponding to ERR34-C </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.ATOF<strong>BADFUNC.ATOI</strong><strong>BADFUNC.ATOL</strong><strong>BADFUNC.ATOLL</strong></strong> </td> <td> Use of atof Use of atoi Use of atol Use of atoll </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3161</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.ERR.CONV.STR_TO_NUM</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR62-a</strong> </td> <td> The library functions atof, atoi and atol from library stdlib.h shall not be used </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://www.securecoding.cert.org/confluence/display/seccode/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR62-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> ERR34-C. Detect errors when converting a string to a number </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-676 </a> , Use of potentially dangerous function <a> CWE-20 </a> , Insufficient input validation </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:1999 </a> \] </td> <td> Subclause 7.22.1, "Numeric conversion functions" Subclause 7.21.6, "Formatted input/output functions" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 22.4.2.1.1, "num_get members" Subclause 27.7.2.2, "Formatted input functions" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR62-CPP: Detect errors when converting a string to a number](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
