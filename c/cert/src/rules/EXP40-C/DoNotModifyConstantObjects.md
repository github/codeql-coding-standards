# EXP40-C: Do not modify constant objects

This query implements the CERT-C rule EXP40-C:

> Do not modify constant objects


## Description

The C Standard, 6.7.3, paragraph 6 \[[IS](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)[O/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> If an attempt is made to modify an object defined with a `const`-qualified type through use of an [lvalue](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-lvalue) with non-`const`-qualified type, the behavior is undefined.


See also [undefined behavior 64](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_64).

There are existing compiler [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) that allow `const`-qualified objects to be modified without generating a warning message.

Avoid casting away `const` qualification because doing so makes it possible to modify `const`-qualified objects without issuing diagnostics. (See [EXP05-C. Do not cast away a const qualification](https://wiki.sei.cmu.edu/confluence/display/c/EXP05-C.+Do+not+cast+away+a+const+qualification) and [STR30-C. Do not attempt to modify string literals](https://wiki.sei.cmu.edu/confluence/display/c/STR30-C.+Do+not+attempt+to+modify+string+literals) for more details.)

## Noncompliant Code Example

This noncompliant code example allows a constant object to be modified:

```cpp
const int **ipp;
int *ip;
const int i = 42;

void func(void) {
  ipp = &ip; /* Constraint violation */
  *ipp = &i; /* Valid */
  *ip = 0;   /* Modifies constant i (was 42) */
}
```
The first assignment is unsafe because it allows the code that follows it to attempt to change the value of the `const` object `i`.

**Implementation Details**

If `ipp`, `ip`, and `i` are declared as automatic variables, this example compiles without warning with Microsoft Visual Studio 2013 when compiled in C mode (`/TC`) and the resulting program changes the value of `i`. GCC 4.8.1 generates a warning but compiles, and the resulting program changes the value of `i`.

If `ipp`, `ip`, and `i` are declared with static storage duration, this program compiles without warning and terminates abnormally with Microsoft Visual Studio 2013, and compiles with warning and terminates abnormally with GCC 4.8.1.

## Compliant Solution

The compliant solution depends on the intent of the programmer. If the intent is that the value of `i` is modifiable, then it should not be declared as a constant, as in this compliant solution:

```cpp
int **ipp;
int *ip;
int i = 42;

void func(void) {
  ipp = &ip; /* Valid */
  *ipp = &i; /* Valid */
  *ip = 0; /* Valid */
}
```
If the intent is that the value of i is not meant to change, then do not write noncompliant code that attempts to modify it.

## Risk Assessment

Modifying constant objects through nonconstant references is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP40-C </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>assignment-to-non-modifiable-lvalue</strong> <strong>pointer-qualifier-cast-const</strong> <strong>pointer-qualifier-cast-const-implicit</strong> <strong>write-to-constant-memory</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP40</strong> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>PW</strong> <strong>MISRA C 2004 Rule 11.5</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.3 </td> <td> <strong>C0563</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>582 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-EXP40-a</strong> </td> <td> A cast shall not remove any 'const' or 'volatile' qualification from the type of a pointer or reference </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule EXP40-C </a> </td> <td> Checks for write operations on const qualified objects (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0563</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>assignment-to-non-modifiable-lvalue</strong> <strong>pointer-qualifier-cast-const</strong> <strong>pointer-qualifier-cast-const-implicit</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>mem_access</strong> </td> <td> Exhaustively verified (see <a> the compliant and the non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP40-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> EXP05-C. Do not cast away a const qualification </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> STR30-C. Do not attempt to modify string literals </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 6.7.3, "Type Qualifiers" </td> </tr> </tbody> </table>


## Implementation notes

The implementation does not consider pointer aliasing via multiple indirection.

## References

* CERT-C: [EXP40-C: Do not modify constant objects](https://wiki.sei.cmu.edu/confluence/display/c)
