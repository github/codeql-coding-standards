# EXP30-C: Do not depend on the order of evaluation of function call arguments for side effects

This query implements the CERT-C rule EXP30-C:

> Do not depend on the order of evaluation for side effects


## Description

Evaluation of an expression may produce [side effects](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-sideeffect). At specific points during execution, known as [sequence points](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-sequencepoint), all side effects of previous evaluations are complete, and no side effects of subsequent evaluations have yet taken place. Do not depend on the order of evaluation for side effects unless there is an intervening sequence point.

The C Standard, 6.5, paragraph 2 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> If a side effect on a scalar object is unsequenced relative to either a different side effect on the same scalar object or a value computation using the value of the same scalar object, the behavior is undefined. If there are multiple allowable orderings of the subexpressions of an expression, the behavior is undefined if such an unsequenced side effect occurs in any of the orderings.


This requirement must be met for each allowable ordering of the subexpressions of a full expression; otherwise, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). (See [undefined behavior 35](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_35).)

The following sequence points are defined in the C Standard, Annex C \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\]:

* Between the evaluations of the function designator and actual arguments in a function call and the actual call
* Between the evaluations of the first and second operands of the following operators:Logical AND: `&&`Logical OR: `||`Comma: `**,**`
* Between the evaluations of the first operand of the conditional `?:` operator and whichever of the second and third operands is evaluated
* The end of a full declarator
* Between the evaluation of a full expression and the next full expression to be evaluated; the following are full expressions:An initializer that is not part of a compound literalThe expression in an expression statementThe controlling expression of a selection statement (`if `or `switch`)The controlling expression of a `while` or `do` statementEach of the (optional) expressions of a `for` statementThe (optional) expression in a `return` statement
* Immediately before a library function returns
* After the actions associated with each formatted input/output function conversion specifier
* Immediately before and immediately after each call to a comparison function, and also between any call to a comparison function and any movement of the objects passed as arguments to that call
Furthermore, Section 6.5.16, paragraph 3 says (regarding assignment operations):

> The side effect of updating the stored value of the left operand is sequenced after the value computations of the left and right operands.


This rule means that statements such as

```cpp
i = i + 1;
a[i] = i;

```
have defined behavior, and statements such as the following do not:

```cpp
/* i is modified twice between sequence points */
i = ++i + 1;  

/* i is read other than to determine the value to be stored */
a[i++] = i;   

```
Not all instances of a comma in C code denote a usage of the comma operator. For example, the comma between arguments in a function call is not a sequence point. However, according to the C Standard, 6.5.2.2, paragraph 10 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\]

> Every evaluation in the calling function (including other function calls) that is not otherwise specifically sequenced before or after the execution of the body of the called function is indeterminately sequenced with respect to the execution of the called function.


This rule means that the order of evaluation for function call arguments is unspecified and can happen in any order.

## Noncompliant Code Example

Programs cannot safely rely on the order of evaluation of operands between sequence points. In this noncompliant code example, `i` is evaluated twice without an intervening sequence point, so the behavior of the expression is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior):

```cpp
#include <stdio.h>

void func(int i, int *b) {
  int a = i + b[++i];
  printf("%d, %d", a, i);
}
```

## Compliant Solution

These examples are independent of the order of evaluation of the operands and can be interpreted in only one way:

```cpp
#include <stdio.h>

void func(int i, int *b) {
  int a;
  ++i;
  a = i + b[i];
  printf("%d, %d", a, i);
}
```
Alternatively:

```cpp
#include <stdio.h>

void func(int i, int *b) {
  int a = i + b[i + 1];
  ++i;
  printf("%d, %d", a, i);
}
```

## Noncompliant Code Example

The call to `func()` in this noncompliant code example has [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) because there is no sequence point between the argument expressions:

```cpp
extern void func(int i, int j);
 
void f(int i) {
  func(i++, i);
}
```
The first (left) argument expression reads the value of `i` (to determine the value to be stored) and then modifies `i`. The second (right) argument expression reads the value of `i` between the same pair of sequence points as the first argument, but not to determine the value to be stored in `i`. This additional attempt to read the value of `i` has undefined behavior.

## Compliant Solution

This compliant solution is appropriate when the programmer intends for both arguments to `func()` to be equivalent:

```cpp
extern void func(int i, int j);
 
void f(int i) {
  i++;
  func(i, i);
}
```
This compliant solution is appropriate when the programmer intends for the second argument to be 1 greater than the first:

```cpp
extern void func(int i, int j);
 
void f(int i) {
  int j = i++;
  func(j, i);
}
```

## Noncompliant Code Example

The order of evaluation for function arguments is unspecified. This noncompliant code example exhibits [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unspecifiedbehavior) but not [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior):

```cpp
extern void c(int i, int j);
int glob;
 
int a(void) {
  return glob + 10;
}

int b(void) {
  glob = 42;
  return glob;
}
 
void func(void) {
  c(a(), b());
}
```
It is unspecified what order `a()` and `b()` are called in; the only guarantee is that both `a()` and `b()` will be called before `c()` is called. If `a()` or `b()` rely on shared state when calculating their return value, as they do in this example, the resulting arguments passed to `c()` may differ between compilers or architectures.

## Compliant Solution

In this compliant solution, the order of evaluation for `a()` and `b()` is fixed, and so no unspecified behavior occurs:

```cpp
extern void c(int i, int j);
int glob;
 
int a(void) {
  return glob + 10;
}
int b(void) {
  glob = 42;
  return glob;
}
 
void func(void) {
  int a_val, b_val;
 
  a_val = a();
  b_val = b();

  c(a_val, b_val);
}
```

## Risk Assessment

Attempting to modify an object multiple times between sequence points may cause that object to take on an unexpected value, which can lead to [unexpected program behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP30-C </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>evaluation-order</strong> <strong>multiple-volatile-accesses</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP30</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wunsequenced</code> </td> <td> Detects simple violations of this rule, but does not diagnose unsequenced function call arguments. </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.SE.DEC</strong> <strong>LANG.STRUCT.SE.INC</strong> <strong>LANG.STRUCT.SE.INIT</strong> </td> <td> Side Effects in Expression with Decrement Side Effects in Expression with Increment Side Effects in Initializer List </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect simple violations of this rule. It needs to examine each expression and make sure that no variable is modified twice in the expression. It also must check that no variable is modified once, then read elsewhere, with the single exception that a variable may appear on both the left and right of an assignment operator </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>EVALUATION_ORDER</strong> </td> <td> Can detect the specific instance where a statement contains multiple side effects on the same value with an undefined evaluation order because, with different compiler flags or different compilers or platforms, the statement may behave differently </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.EXP30</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 4.3.5 </td> <td> </td> <td> Can detect violations of this rule when the <code>-Wsequence-point</code> flag is used </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C0400, C0401, C0402, C0403, C0404, C0405</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>PORTING.VAR.EFFECTS</strong> <strong>MISRA.INCR_DECR.OTHER</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>35 D, 1 Q, 9 S, 30 S, 134 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-EXP30-a</strong> <strong>CERT_C-EXP30-b</strong> <strong>CERT_C-EXP30-c</strong> <strong>CERT_C-EXP30-d</strong> </td> <td> The value of an expression shall be the same under any order of evaluation that the standard permits Don't write code that depends on the order of evaluation of function arguments Don't write code that depends on the order of evaluation of function designator and function arguments Don't write code that depends on the order of evaluation of expression that involves a function call </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>564</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule EXP30-C </a> </td> <td> Checks for situations when expression value depends on order of evaluation or of side effects (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0400, 0401, 0402, </strong> <strong>0403, 0404, 0405</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V532</a></strong> <a> , </a> <strong><a>V567</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>evaluation-order</strong> <strong>multiple-volatile-accesses</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>IncAndDecMixedWithOtherOperators</a></strong> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>separated</strong> </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> EXP50-CPP. Do not depend on the order of evaluation for side effects </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> EXP05-J. Do not follow a write by a subsequent write or read of the same object within an expression </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Operator Precedence/Order of Evaluation \[JCW\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Side-effects and Order of Evaluation \[SAM\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 13.2 (required) </td> <td> CERT cross-reference in <a> MISRA C:2012 – Addendum 3 </a> </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-758 </a> </td> <td> 2017-07-07: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-758 and EXP30-C**

Independent( INT34-C, INT36-C, MEM30-C, MSC37-C, FLP32-C, EXP33-C, EXP30-C, ERR34-C, ARR32-C)

CWE-758 = Union( EXP30-C, list) where list =

* Undefined behavior that results from anything other than reading and writing to a variable twice without an intervening sequence point.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.5, "Expressions" 6.5.2.2, "Function Calls" Annex C, "Sequence Points" </td> </tr> <tr> <td> \[ <a> Saks 2007 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Summit 2005 </a> \] </td> <td> Questions 3.1, 3.2, 3.3, 3.3b, 3.7, 3.8, 3.9, 3.10a, 3.10b, and 3.11 </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [EXP30-C: Do not depend on the order of evaluation for side effects](https://wiki.sei.cmu.edu/confluence/display/c)
