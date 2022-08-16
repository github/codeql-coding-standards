# FIO39-C: Do not alternately input and output from a stream without an intervening flush or positioning call

This query implements the CERT-C rule FIO39-C:

> Do not alternately input and output from a stream without an intervening flush or positioning call


## Description

The C Standard, 7.21.5.3, paragraph 7 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], places the following restrictions on update streams:

> When a file is opened with update mode . . ., both input and output may be performed on the associated stream. However, output shall not be directly followed by input without an intervening call to the `fflush` function or to a file positioning function (`fseek`, `fsetpos`, or `rewind`), and input shall not be directly followed by output without an intervening call to a file positioning function, unless the input operation encounters end-of-file. Opening (or creating) a text file with update mode may instead open (or create) a binary stream in some implementations.


The following scenarios can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 151](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_151).)

* Receiving input from a stream directly following an output to that stream without an intervening call to `fflush()`, `fseek()`, `fsetpos()`, or `rewind()` if the file is not at end-of-file
* Outputting to a stream after receiving input from that stream without a call to `fseek()`, `fsetpos()`, or `rewind()` if the file is not at end-of-file
Consequently, a call to `fseek()`, `fflush()`, or `fsetpos()` is necessary between input and output to the same stream. See [ERR07-C. Prefer functions that support error checking over equivalent functions that don't](https://wiki.sei.cmu.edu/confluence/display/c/ERR07-C.+Prefer+functions+that+support+error+checking+over+equivalent+functions+that+don%27t) for more information on why `fseek()` is preferred over `rewind()`.

## Noncompliant Code Example

This noncompliant code example appends data to a file and then reads from the same file:

```cpp
#include <stdio.h>
 
enum { BUFFERSIZE = 32 };

extern void initialize_data(char *data, size_t size);
 
void func(const char *file_name) {
  char data[BUFFERSIZE];
  char append_data[BUFFERSIZE];
  FILE *file;

  file = fopen(file_name, "a+");
  if (file == NULL) {
    /* Handle error */
  }
 
  initialize_data(append_data, BUFFERSIZE);

  if (fwrite(append_data, 1, BUFFERSIZE, file) != BUFFERSIZE) {
    /* Handle error */
  }
  if (fread(data, 1, BUFFERSIZE, file) < BUFFERSIZE) {
    /* Handle there not being data */
  }

  if (fclose(file) == EOF) {
    /* Handle error */
  }
}
```
Because there is no intervening flush or positioning call between the calls to `fread()` and `fwrite()`, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Compliant Solution

In this compliant solution, `fseek()` is called between the output and input, eliminating the undefined behavior:

```cpp
#include <stdio.h>
 
enum { BUFFERSIZE = 32 };
extern void initialize_data(char *data, size_t size);
 
void func(const char *file_name) {
  char data[BUFFERSIZE];
  char append_data[BUFFERSIZE];
  FILE *file;

  file = fopen(file_name, "a+");
  if (file == NULL) {
    /* Handle error */
  }

  initialize_data(append_data, BUFFERSIZE);
  if (fwrite(append_data, BUFFERSIZE, 1, file) != BUFFERSIZE) {
    /* Handle error */
  }

  if (fseek(file, 0L, SEEK_SET) != 0) {
    /* Handle error */
  }

  if (fread(data, BUFFERSIZE, 1, file) != 0) {
    /* Handle there not being data */
  }

  if (fclose(file) == EOF) {
    /* Handle error */
  }
}
```

## Risk Assessment

Alternately inputting and outputting from a stream without an intervening flush or positioning call is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO39-C </td> <td> Low </td> <td> Likely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-FIO39</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>IO.IOWOP</strong> <strong>IO.OIWOP</strong> </td> <td> Input After Output Without Positioning Output After Input Without Positioning </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect simple violations of this rule </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4711, C4712, C4713</strong> <strong>C++4711, C++4712, C++4713</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.FIO.NO_FLUSH</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>84 D</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-FIO39-a</strong> </td> <td> Do not alternately input and output from a stream without an intervening flush or positioning call </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2478, 2479</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule FIO39-C </a> </td> <td> Checks for alternating input and output from a stream without flush or positioning call (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>5029</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO39-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> FIO50-CPP. Do not alternately input and output from a file stream without an intervening positioning call </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Interleaving stream inputs and outputs without a flush or positioning call \[ioileave\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-664 </a> </td> <td> 2017-07-10: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-664 and FIO39-C**

CWE-664 = Union( FIO39-C, list) where list =

* Improper use of an object (besides alternating reading/writing a file stream without an intervening flush
This CWE is vague on what constitutes “improper control of a resource”. It could include any violation of an object’s method constraints (whether they are documented or not). Or it could be narrowly interpreted to mean object creation and object destruction (which are covered by other CWEs).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.21.5.3, "The <code>fopen</code> Function" </td> </tr> </tbody> </table>


## Implementation notes

The rule is enforced in the context of a single function.

## References

* CERT-C: [FIO39-C: Do not alternately input and output from a stream without an intervening flush or positioning call](https://wiki.sei.cmu.edu/confluence/display/c)
