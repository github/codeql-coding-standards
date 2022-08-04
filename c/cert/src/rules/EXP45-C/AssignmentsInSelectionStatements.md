# EXP45-C: Do not perform assignments in selection statements

This query implements the CERT-C rule EXP45-C:

> Do not perform assignments in selection statements


## Description

Do not use the assignment operator in the contexts listed in the following table because doing so typically indicates programmer error and can result in [unexpected behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior).

<table> <tbody> <tr> <th> Operator </th> <th> Context </th> </tr> <tr> <td> <code>if</code> </td> <td> Controlling expression </td> </tr> <tr> <td> <code>while</code> </td> <td> Controlling expression </td> </tr> <tr> <td> <code>do ... while</code> </td> <td> Controlling expression </td> </tr> <tr> <td> <code>for</code> </td> <td> Second operand </td> </tr> <tr> <td> <code>?:</code> </td> <td> First operand </td> </tr> <tr> <td> <code>?:</code> </td> <td> Second or third operands, where the ternary expression is used in any of these contexts </td> </tr> <tr> <td> <code>&amp;&amp;</code> </td> <td> Either operand </td> </tr> <tr> <td> <code>||</code> </td> <td> either operand </td> </tr> <tr> <td> <code>,</code> </td> <td> Second operand, when the comma expression is used in any of these contexts </td> </tr> </tbody> </table>
Performing assignment statements in other contexts do not violate this rule. However, they may violate other rules, such as [EXP30-C. Do not depend on the order of evaluation for side effects](https://wiki.sei.cmu.edu/confluence/display/c/EXP30-C.+Do+not+depend+on+the+order+of+evaluation+for+side+effects).


Noncompliant Code Example

In this noncompliant code example, an assignment expression is the outermost expression in an `if` statement:

```cpp
if (a = b) {
  /* ... */
}

```
Although the intent of the code may be to assign `b` to `a` and test the value of the result for equality to 0, it is frequently a case of the programmer mistakenly using the assignment operator `=` instead of the equals operator `==`. Consequently, many compilers will warn about this condition, making this coding error detectable by adhering to [MSC00-C. Compile cleanly at high warning levels](https://wiki.sei.cmu.edu/confluence/display/c/MSC00-C.+Compile+cleanly+at+high+warning+levels).

## Compliant Solution (Unintentional Assignment)

When the assignment of `b` to `a` is not intended, the conditional block is now executed when `a` is equal to `b`:

```cpp
if (a == b) {
  /* ... */
}

```

## Compliant Solution (Intentional Assignment)

When the assignment is intended, this compliant solution explicitly uses inequality as the outermost expression while performing the assignment in the inner expression:

```cpp
if ((a = b) != 0) {
  /* ... */
}

```
It is less desirable in general, depending on what was intended, because it mixes the assignment in the condition, but it is clear that the programmer intended the assignment to occur.

## Noncompliant Code Example

In this noncompliant code example, the expression `x = y` is used as the controlling expression of the `while` statement:

```cpp
 do { /* ... */ } while (foo(), x = y);
```

## Compliant Solution (Unintentional Assignment)

When the assignment of y to x is not intended, the conditional block should be executed only when x is equal to y, as in this compliant solution:

```cpp
do { /* ... */ } while (foo(), x == y); 

```

## Compliant Solution (Intentional Assignment)

When the assignment is intended, this compliant solution can be used:

```cpp
do { /* ... */ } while (foo(), (x = y) != 0);

```

## Compliant Solution (for statement)

The same result can be obtained using the `for` statement, which is specifically designed to evaluate an expression on each iteration of the loop, just before performing the test in its controlling expression. Remember that its controlling expression is the second operand, where the assignment occurs in its third operand:

```cpp
 for (; x; foo(), x = y) { /* ... */ }
```

## Noncompliant Code Example

In this noncompliant example, the expression `p = q` is used as the controlling expression of the `while` statement:

```cpp
 do { /* ... */ } while (x = y, p = q);
```

## Compliant Solution

In this compliant solution, the expression `x = y` is not used as the controlling expression of the `while` statement:

```cpp
do { /* ... */ } while (x = y, p == q); 

```

## Noncompliant Code Example

This noncompliant code example has a typo that results in an assignment rather than a comparison.

```cpp
while (ch = '\t' || ch == ' ' || ch == '\n') {
  /* ... */
}

```
Many compilers will warn about this condition. This coding error would typically be eliminated by adherence to [MSC00-C. Compile cleanly at high warning levels](https://wiki.sei.cmu.edu/confluence/display/c/MSC00-C.+Compile+cleanly+at+high+warning+levels). Although this code compiles, it will cause [unexpected behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior) to an unsuspecting programmer. If the intent was to verify a string such as a password, user name, or group user ID, the code may produce significant [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) and require significant debugging.

## Compliant Solution (RHS Variable)

When comparisons are made between a variable and a literal or const-qualified variable, placing the variable on the right of the comparison operation can prevent a spurious assignment.

In this code example, the literals are placed on the left-hand side of each comparison. If the programmer were to inadvertently use an assignment operator, the statement would assign `ch` to `'\t'`, which is invalid and produces a diagnostic message.

```cpp
while ('\t' = ch || ' ' == ch || '\n' == ch) {
  /* ... */
}
```
Due to the diagnostic, the typo will be easily spotted and fixed.

```cpp
while ('\t' == ch || ' ' == ch || '\n' == ch) {
  /* ... */
}
```
As a result, any mistaken use of the assignment operator that could otherwise create a [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) for operations such as string verification will result in a compiler diagnostic regardless of compiler, warning level, or [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation).

## Exceptions

**EXP45-C-EX1**:****Assignment can be used where the result of the assignment is itself an operand to a comparison expression or relational expression. In this compliant example, the expression `x = y` is itself an operand to a comparison operation:

```cpp
if ((x = y) != 0) { /* ... */ } 
```
**EXP45-C-EX2**:****Assignment can be used where the expression consists of a single primary expression. The following code is compliant because the expression `x = y` is a single primary expression:

```cpp
if ((x = y)) { /* ... */ } 
```
The following controlling expression is noncompliant because `&&` is not a comparison or relational operator and the entire expression is not primary:

```cpp
if ((v = w) && flag) { /* ... */ } 
```
When the assignment of `v` to `w` is not intended, the following controlling expression can be used to execute the conditional block when `v` is equal to `w`:

```cpp
if ((v == w) && flag) { /* ... */ }; 
```
When the assignment is intended, the following controlling expression can be used:

```cpp
if (((v = w) != 0) && flag) { /* ... */ }; 
```
**EXP45-C-EX3**:****Assignment can be used in a function argument or array index. In this compliant solution, the expression `x = y` is used in a function argument:

```cpp
if (foo(x = y)) { /* ... */ } 
```

## Risk Assessment

Errors of omission can result in unintended program flow.

<table> <tbody> <tr> <th> Recommendation </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP45-C </td> <td> Low </td> <td> Likely </td> <td> Medium </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>assignment-conditional</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP45</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wparentheses</code> </td> <td> Can detect some instances of this rule, but does not detect all </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.CONDASSIGLANG.STRUCT.SE.CONDLANG.STRUCT.USEASSIGN</strong> </td> <td> Assignment in conditional Condition contains side effects Assignment result in expression </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Could detect violations of this recommendation by identifying any assignment expression as the top-level expression in an <code>if</code> or <code>while</code> statement </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.EXP18</strong> <strong><strong>CC2.EXP21</strong></strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 4.3.5 </td> <td> </td> <td> Can detect violations of this recommendation when the <code>-Wall</code> flag is used </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C3314, C3326, C3344, C3416</strong> <strong>C++4071, C++4074</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>ASSIGCOND.CALL</strong> <strong>ASSIGCOND.GENMISRA.ASSIGN.COND</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>114 S, 132 S</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-EXP45-b</strong> <strong>CERT_C-EXP45-d</strong> </td> <td> Assignment operators shall not be used in conditions without brackets Assignment operators shall not be used in expressions that yield a Boolean value </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>720</strong> </td> <td> Partially supported: reports Boolean test of unparenthesized assignment </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule EXP45-C </a> </td> <td> Checks for invalid use of = (assignment) operator (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>3314, 3326, 3344, 3416</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4071, 4074 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong>V559<a></a></strong> , <strong>V633<a></a></strong> , <strong><a>V699</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>assignment-conditional</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>AssignmentInSubExpression</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP45-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> EXP19-CPP. Do not perform assignments in conditional expressions </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> EXP51-J. Do not perform assignments in conditional expressions </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Likely Incorrect Expression \[KOA\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> No assignment in conditional expressions \[boolasgn\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-480 </a> , Use of Incorrect Operator </td> <td> 2017-07-05: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-481 </a> </td> <td> 2017-07-05: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-480 and EXP45-C**

Intersection( EXP45-C, EXP46-C) = Ø

CWE-480 = Union( EXP45-C, list) where list =

* Usage of incorrect operator besides s/=/==/
**CWE-569 and EXP45-C**

CWE-480 = Subset( CWE-569)

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Dutta 03 </a> \] </td> <td> "Best Practices for Programming in C" </td> </tr> <tr> <td> \[ <a> Hatton 1995 </a> \] </td> <td> Section 2.7.2, "Errors of Omission and Addition" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [EXP45-C: Do not perform assignments in selection statements](https://wiki.sei.cmu.edu/confluence/display/c)
