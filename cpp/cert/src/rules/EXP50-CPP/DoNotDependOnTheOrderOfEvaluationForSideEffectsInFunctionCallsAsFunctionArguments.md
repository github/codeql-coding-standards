# EXP50-CPP: Do not depend on the order of evaluation of function calls as function arguments for side effects

This query implements the CERT-C++ rule EXP50-CPP:

> Do not depend on the order of evaluation for side effects


## Description

In C++, modifying an object, calling a library I/O function, accessing a `volatile`-qualified value, or calling a function that performs one of these actions are ways to modify the state of the execution environment. These actions are called *side effects*. All relationships between value computations and side effects can be described in terms of sequencing of their evaluations. The C++ Standard, \[intro.execution\], paragraph 13 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], establishes three sequencing terms:

> *Sequenced before* is an asymmetric, transitive, pair-wise relation between evaluations executed by a single thread, which induces a partial order among those evaluations. Given any two evaluations *A* and *B*, if *A* is sequenced before *B*, then the execution of *A* shall precede the execution of *B*. If *A* is not sequenced before *B* and *B* is not sequenced before *A*, then *A* and *B* are *unsequenced*. \[Note: The execution of unsequenced evaluations can overlap. — end note\] Evaluations *A* and *B* are *indeterminately sequenced* when either *A* is sequenced before *B* or *B* is sequenced before *A*, but it is unspecified which. \[Note: Indeterminately sequenced evaluations cannot overlap, but either could be executed first. — end note\]


Paragraph 15 further states (nonnormative text removed for brevity) the following:

> Except where noted, evaluations of operands of individual operators and of subexpressions of individual expressions are unsequenced. ... The value computations of the operands of an operator are sequenced before the value computation of the result of the operator. If a side effect on a scalar object is unsequenced relative to either another side effect on the same scalar object or a value computation using the value of the same scalar object, and they are not potentially concurrent, the behavior is undefined. ... When calling a function (whether or not the function is inline), every value computation and side effect associated with any argument expression, or with the postfix expression designating the called function, is sequenced before execution of every expression or statement in the body of the called function. ... Every evaluation in the calling function (including other function calls) that is not otherwise specifically sequenced before or after the execution of the body of the called function is indeterminately sequenced with respect to the execution of the called function. Several contexts in C++ cause evaluation of a function call, even though no corresponding function call syntax appears in the translation unit. ... The sequencing constraints on the execution of the called function (as described above) are features of the function calls as evaluated, whatever the syntax of the expression that calls the function might be.


Do not allow the same scalar object to appear in side effects or value computations in both halves of an unsequenced or indeterminately sequenced operation.

The following expressions have sequencing restrictions that deviate from the usual unsequenced ordering \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\]:

* In postfix `++` and `--` expressions, the value computation is sequenced before the modification of the operand. (\[expr.post.incr\], paragraph 1)
* In logical `&&` expressions, if the second expression is evaluated, every value computation and side effect associated with the first expression is sequenced before every value computation and side effect associated with the second expression. (\[expr.log.and\], paragraph 2)
* In logical `||` expressions, if the second expression is evaluated, every value computation and side effect associated with the first expression is sequenced before every value computation and side effect associated with the second expression. (\[expr.log.or\], paragraph 2)
* In conditional `?:` expressions, every value computation and side effect associated with the first expression is sequenced before every value computation and side effect associated with the second or third expression (whichever is evaluated). (\[expr.cond\], paragraph 1)
* In assignment expressions (including compound assignments), the assignment is sequenced after the value computations of left and right operands and before the value computation of the assignment expression. (\[expr.ass\], paragraph 1)
* In comma `,` expressions, every value computation and side effect associated with the left expression is sequenced before every value computation and side effect associated with the right expression. (\[expr.comma\], paragraph 1)
* When evaluating initializer lists, the value computation and side effect associated with each *initializer-clause* is sequenced before every value computation and side effect associated with a subsequent *initializer-clause*. (\[dcl.init.list\], paragraph 4)
* When a signal handler is executed as a result of a call to `std::raise()`, the execution of the handler is sequenced after the invocation of `std::raise()` and before its return. (\[intro.execution\], paragraph 6)
* The completions of the destructors for all initialized objects with thread storage duration within a thread are sequenced before the initiation of the destructors of any object with static storage duration. (\[basic.start.term\], paragraph 1)
* In a *new-expression*, initialization of an allocated object is sequenced before the value computation of the *new-expression*. (\[expr.new\], paragraph 18)
* When a default constructor is called to initialize an element of an array and the constructor has at least one default argument, the destruction of every temporary created in a default argument is sequenced before the construction of the next array element, if any. (\[class.temporary\], paragraph 4)
* The destruction of a temporary whose lifetime is not extended by being bound to a reference is sequenced before the destruction of every temporary that is constructed earlier in the same full-expression. (\[class.temporary\], paragraph 5)
* Atomic memory ordering functions can explicitly determine the sequencing order for expressions. (\[atomics.order\] and \[atomics.fences\])
This rule means that statements such as

```cpp
i = i + 1;
a[i] = i;

```
have defined behavior, and statements such as the following do not.

```cpp
// i is modified twice in the same full expression
i = ++i + 1;  

// i is read other than to determine the value to be stored
a[i++] = i;   

```
Not all instances of a comma in C++ code denote use of the comma operator. For example, the comma between arguments in a function call is *not* the comma operator. Additionally, overloaded operators behave the same as a function call, with the operands to the operator acting as arguments to a function call.

## Noncompliant Code Example

In this noncompliant code example, `i` is evaluated more than once in an unsequenced manner, so the behavior of the expression is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
void f(int i, const int *b) {
  int a = i + b[++i];
  // ...
}

```

## Compliant Solution

These examples are independent of the order of evaluation of the operands and can each be interpreted in only one way.

```cpp
void f(int i, const int *b) {
  ++i;
  int a = i + b[i];
  // ...
}

```
```cpp
void f(int i, const int *b) {
  int a = i + b[i + 1];
  ++i;
  // ...
}

```

## Noncompliant Code Example

The call to `func()` in this noncompliant code example has [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) because the argument expressions are unsequenced.

```cpp
extern void func(int i, int j);
 
void f(int i) {
  func(i++, i);
}

```
The first (left) argument expression reads the value of `i` (to determine the value to be stored) and then modifies `i`. The second (right) argument expression reads the value of `i`, but not to determine the value to be stored in `i`. This additional attempt to read the value of `i` has [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Compliant Solution

This compliant solution is appropriate when the programmer intends for both arguments to `func()` to be equivalent.

```cpp
extern void func(int i, int j);
 
void f(int i) {
  i++;
  func(i, i);
}

```
This compliant solution is appropriate when the programmer intends for the second argument to be 1 greater than the first.

```cpp
extern void func(int i, int j);
 
void f(int i) {
  int j = i++;
  func(j, i);
}

```

## Noncompliant Code Example

This noncompliant code example is similar to the previous noncompliant code example. However, instead of calling a function directly, this code calls an overloaded `operator<<()`. Overloaded operators are equivalent to a function call and have the same restrictions regarding the sequencing of the function call arguments. This means that the operands are not evaluated left-to-right, but are unsequenced with respect to one another. Consequently, this noncompliant code example has undefined behavior.

```cpp
#include <iostream>
 
void f(int i) {
  std::cout << i++ << i << std::endl;
}
```

## Compliant Solution

In this compliant solution, two calls are made to `operator<<()`, ensuring that the arguments are printed in a well-defined order.

```cpp
#include <iostream>
 
void f(int i) {
  std::cout << i++;
  std::cout << i << std::endl;
}
```

## Noncompliant Code Example

The order of evaluation for function arguments is unspecified. This noncompliant code example exhibits [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unspecifiedbehavior) but not [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
extern void c(int i, int j);
int glob;
 
int a() {
  return glob + 10;
}

int b() {
  glob = 42;
  return glob;
}
 
void f() {
  c(a(), b());
}

```
The order in which `a()` and `b()` are called is unspecified; the only guarantee is that both `a()` and `b()` will be called before `c()` is called. If `a()` or `b()` rely on shared state when calculating their return value, as they do in this example, the resulting arguments passed to `c()` may differ between compilers or architectures.

## Compliant Solution

In this compliant solution, the order of evaluation for `a()` and `b()` is fixed, and so no [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unspecifiedbehavior) occurs.

```cpp
extern void c(int i, int j);
int glob;
 
int a() {
  return glob + 10;
}
 
int b() {
  glob = 42;
  return glob;
}
 
void f() {
  int a_val, b_val;
 
  a_val = a();
  b_val = b();

  c(a_val, b_val);
}

```

## Risk Assessment

Attempting to modify an object in an unsequenced or indeterminately sequenced evaluation may cause that object to take on an unexpected value, which can lead to unexpected program behavior.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP50-CPP </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-EXP50</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wunsequenced</code> </td> <td> Can detect simple violations of this rule where path-sensitive analysis is not required </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.SE.DEC</strong> <strong>LANG.STRUCT.SE.INC</strong> </td> <td> Side Effects in Expression with Decrement Side Effects in Expression with Increment </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect simple violations of this rule. It needs to examine each expression and make sure that no variable is modified twice in the expression. It also must check that no variable is modified once, then read elsewhere, with the single exception that a variable may appear on both the left and right of an assignment operator </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> v7.5.0 </td> <td> <strong>EVALUATION_ORDER</strong> </td> <td> Can detect the specific instance where a statement contains multiple side effects on the same value with an undefined evaluation order because, with different compiler flags or different compilers or platforms, the statement may behave differently </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.EXP30</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> GCC </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule when the <code>-Wsequence-point</code> flag is used </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3220, C++3221, C++3222, C++3223, C++3228</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>PORTING.VAR.EFFECTS</strong> <strong>MISRA.EXPR.PARENS</strong> <strong>MISRA.EXPR.PARENS.INSUFFICIENT</strong> <strong>MISRA.INCR_DECR.OTHER</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>35 D</strong> <strong>, 1 Q</strong> <strong>, 9 S</strong> <strong>, 134 S, 67 D, 72 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP50-a</strong> <strong>CERT_CPP-EXP50-b</strong> <strong>CERT_CPP-EXP50-c</strong> <strong>CERT_CPP-EXP50-d</strong> <strong>CERT_CPP-EXP50-e</strong> <strong>CERT_CPP-EXP50-f</strong> </td> <td> The value of an expression shall be the same under any order of evaluation that the standard permits Don't write code that depends on the order of evaluation of function arguments Don't write code that depends on the order of evaluation of function designator and function arguments Don't write code that depends on the order of evaluation of expression that involves a function call Between sequence points an object shall have its stored value modified at most once by the evaluation of an expression Don't write code that depends on the order of evaluation of function calls </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: EXP50-CPP </a> </td> <td> Checks for situations where expression value depends on order of evaluation (rule fully covered). </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3220, 3221, 3222, 3223, 3228</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong>V521<a></a></strong> , <strong><a>V708</a></strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>IncAndDecMixedWithOtherOperators</a></strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Splint </a> </td> <td> </td> <td> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabi) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP30-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> EXP30-C. Do not depend on the order of evaluation for side effects </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 1.9, "Program Execution" </td> </tr> <tr> <td> \[ <a> MISRA 2008 </a> \] </td> <td> Rule 5-0-1 (Required) </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP50-CPP: Do not depend on the order of evaluation for side effects](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
