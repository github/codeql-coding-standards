# EXP16-C: Do not compare function pointers to constant values

This query implements the CERT-C rule EXP16-C:

> Do not compare function pointers to constant values


## Description

Comparing a function pointer to a value that is not a null function pointer of the same type will be diagnosed because it typically indicates programmer error and can result in [unexpected behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior). Implicit comparisons will be diagnosed, as well.

## Noncompliant Code Example

In this noncompliant code example, the addresses of the POSIX functions `getuid` and `geteuid` are compared for equality to 0. Because no function address shall be null, the first subexpression will always evaluate to false (0), and the second subexpression always to true (nonzero). Consequently, the entire expression will always evaluate to true, leading to a potential security vulnerability.

```cpp
/* First the options that are allowed only for root */
if (getuid == 0 || geteuid != 0) {
  /* ... */
}

```

## Noncompliant Code Example

In this noncompliant code example, the function pointers `getuid` and `geteuid` are compared to 0. This example is from an actual [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) ([VU\#837857](http://www.kb.cert.org/vuls/id/837857)) discovered in some versions of the X Window System server. The vulnerability exists because the programmer neglected to provide the open and close parentheses following the `geteuid()` function identifier. As a result, the `geteuid` token returns the address of the function, which is never equal to 0. Consequently, the `or` condition of this `if` statement is always true, and access is provided to the protected block for all users. Many compilers issue a warning noting such pointless expressions. Therefore, this coding error is normally detected by adherence to [MSC00-C. Compile cleanly at high warning levels](https://wiki.sei.cmu.edu/confluence/display/c/MSC00-C.+Compile+cleanly+at+high+warning+levels).

```cpp
/* First the options that are allowed only for root */
if (getuid() == 0 || geteuid != 0) {
  /* ... */
}

```

## Compliant Solution

The solution is to provide the open and close parentheses following the `geteuid` token so that the function is properly invoked:

```cpp
/* First the options that are allowed only for root */
if (getuid() == 0 || geteuid() != 0) {
  /* ... */
}

```

## Compliant Solution

A function pointer can be compared to a null function pointer of the same type:

```cpp
/* First the options that are allowed only for root */ 
if (getuid == (uid_t(*)(void))0 || geteuid != (uid_t(*)(void))0) { 
  /* ... */ 
} 

```
This code should not be diagnosed by an analyzer.

## Noncompliant Code Example

In this noncompliant code example, the function pointer `do_xyz` is implicitly compared unequal to 0:

```cpp
int do_xyz(void); 
 
int f(void) {
/* ... */
  if (do_xyz) { 
    return -1; /* Indicate failure */ 
  }
/* ... */
  return 0;
} 

```

## Compliant Solution

In this compliant solution, the function `do_xyz()` is invoked and the return value is compared to 0:

```cpp
int do_xyz(void); 
 
int f(void) {
/* ... */ 
  if (do_xyz()) { 
    return -1; /* Indicate failure */
  }
/* ... */
  return 0;  
} 

```

## Risk Assessment

Errors of omission can result in unintended program flow.

<table> <tbody> <tr> <th> Recommendation </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP16-C </td> <td> Low </td> <td> Likely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 24.04 </td> <td> <strong>function-name-constant-comparison</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>BAD_COMPARE</strong> </td> <td> Can detect the specific instance where the address of a function is compared against 0, such as in the case of <code>geteuid</code> versus <code>getuid()</code> in the implementation-specific details </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 4.3.5 </td> <td> </td> <td> Can detect violations of this recommendation when the <code>-Wall</code> flag is used </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2024.4 </td> <td> <strong>C0428, C3004, C3344</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2024.4 </td> <td> <strong>CWARN.NULLCHECK.FUNCNAMECWARN.FUNCADDR</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>99 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2024.2 </td> <td> <strong>CERT_C-EXP16-a</strong> </td> <td> Function address should not be compared to zero </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2440, 2441</strong> </td> <td> Partially supported: reports address of function, array, or variable directly or indirectly compared to null </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.35 </td> <td> <strong><a>V516</a>, <a>V1058</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 24.04 </td> <td> <strong>function-name-constant-comparison</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP16-C).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> VOID EXP16-CPP. Avoid conversions using void pointers </a> </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Likely incorrect expressions \[KOA\] </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Comparing function addresses to zero \[funcaddr\] </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-480 </a> , Use of incorrect operator <a> CWE-482 </a> , Comparing instead of assigning </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Hatton 1995 </a> \] </td> <td> Section 2.7.2, "Errors of Omission and Addition" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [EXP16-C: Do not compare function pointers to constant values](https://wiki.sei.cmu.edu/confluence/display/c)
