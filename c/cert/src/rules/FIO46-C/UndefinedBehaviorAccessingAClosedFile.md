# FIO46-C: Do not access a closed file

This query implements the CERT-C rule FIO46-C:

> Do not access a closed file


## Description

Using the value of a pointer to a `FILE` object after the associated file is closed is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 148](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_148).) Programs that close the standard streams (especially `stdout` but also `stderr` and `stdin`) must be careful not to use these streams in subsequent function calls, particularly those that implicitly operate on them (such as `printf()`, `perror()`, and `getc()`).

This rule can be generalized to other file representations.

## Noncompliant Code Example

In this noncompliant code example, the `stdout` stream is used after it is closed:

```cpp
#include <stdio.h>
 
int close_stdout(void) {
  if (fclose(stdout) == EOF) {
    return -1;
  }
 
  printf("stdout successfully closed.\n");
  return 0;
}
```

## Compliant Solution

In this compliant solution, `stdout` is not used again after it is closed. This must remain true for the remainder of the program, or `stdout` must be assigned the address of an open file object.

```cpp
#include <stdio.h>
 
int close_stdout(void) {
  if (fclose(stdout) == EOF) {
    return -1;
  }

  fputs("stdout successfully closed.", stderr);
  return 0;
}
```

## Risk Assessment

Using the value of a pointer to a `FILE` object after the associated file is closed is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO46-C </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>IO.UAC</strong> </td> <td> Use after close </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>USE_AFTER_FREE</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C2696, C2697, C2698</strong> <strong>C++2696, C++2697, C++2698</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>SV.INCORRECT_RESOURCE_HANDLING.URH</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>48 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-FIO46-a</strong> </td> <td> Do not use resources that have been freed </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2471</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule FIO46-C </a> </td> <td> Checks for use of previously closed resource (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2696, 2697, 2698</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2696, 2697, 2698</strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S3588</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO46-C).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE Std 1003.1:2013 </a> \] </td> <td> XSH, System Interfaces, <code>open</code> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.21.3, "Files" Subclause 7.21.5.1, "The <code>fclose</code> Function" </td> </tr> </tbody> </table>


## Implementation notes

The rule is enforced in the context of a single function.

## References

* CERT-C: [FIO46-C: Do not access a closed file](https://wiki.sei.cmu.edu/confluence/display/c)
