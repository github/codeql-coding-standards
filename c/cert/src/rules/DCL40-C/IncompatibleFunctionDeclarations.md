# DCL40-C: Do not create incompatible declarations of the same function or object

This query implements the CERT-C rule DCL40-C:

> Do not create incompatible declarations of the same function or object


## Description

Two or more incompatible declarations of the same function or object must not appear in the same program because they result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). The C Standard, 6.2.7, mentions that two types may be distinct yet compatible and addresses precisely when two distinct types are compatible.

The C Standard identifies four situations in which [undefined behavior (UB)](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) may arise as a result of incompatible declarations of the same function or object:

<table> <tbody> <tr> <th> UB </th> <th> Description </th> <th> Code </th> </tr> <tr> <td> <a> 15 </a> </td> <td> <em> Two declarations of the same object or function specify types that are not compatible (6.2.7). </em> </td> <td> All noncompliant code in this guideline </td> </tr> <tr> <td> <a> 31 </a> </td> <td> <em> Two identifiers differ only in nonsignificant characters (6.4.2.1). </em> </td> <td> <a> Excessively Long Identifiers </a> </td> </tr> <tr> <td> <a> 37 </a> </td> <td> <em> An object has its stored value accessed other than by an lvalue of an allowable type (6.5). </em> </td> <td> <a> Incompatible Object Declarations </a> <a> Incompatible Array Declarations </a> </td> </tr> <tr> <td> <a> 41 </a> </td> <td> <em> A function is defined with a type that is not compatible with the type (of the expression) pointed to by the expression that denotes the called function (6.5.2.2). </em> </td> <td> <a> Incompatible Function Declarations </a> <a> Excessively Long Identifiers </a> </td> </tr> </tbody> </table>
Although the effect of two incompatible declarations simply appearing in the same program may be benign on most [implementations](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation), the effects of invoking a function through an expression whose type is incompatible with the function definition are typically catastrophic. Similarly, the effects of accessing an object using an [lvalue](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-lvalue) of a type that is incompatible with the object definition may range from unintended information exposure to memory overwrite to a hardware trap.


## Noncompliant Code Example (Incompatible Object Declarations)

In this noncompliant code example, the variable `i` is declared to have type `int` in file `a.c` but defined to be of type `short` in file `b.c`. The declarations are incompatible, resulting in [undefined behavior 15](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_15). Furthermore, accessing the object using an [lvalue](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-lvalue) of an incompatible type, as shown in function `f()`, is [undefined behavior 37](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_37) with possible observable results ranging from unintended information exposure to memory overwrite to a hardware trap.

```cpp
/* In a.c */
extern int i;   /* UB 15 */

int f(void) {
  return ++i;   /* UB 37 */
}

/* In b.c */
short i;   /* UB 15 */

```

## Compliant Solution (Incompatible Object Declarations)

This compliant solution has compatible declarations of the variable `i`:

```cpp
/* In a.c */
extern int i;   

int f(void) {
  return ++i;   
}

/* In b.c */
int i;   
```

## Noncompliant Code Example (Incompatible Array Declarations)

In this noncompliant code example, the variable `a` is declared to have a pointer type in file `a.c` but defined to have an array type in file `b.c`. The two declarations are incompatible, resulting in [undefined behavior 15](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_15). As before, accessing the object in function `f()` is [undefined behavior 37](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_37) with the typical effect of triggering a hardware trap.

```cpp
/* In a.c */
extern int *a;   /* UB 15 */

int f(unsigned int i, int x) {
  int tmp = a[i];   /* UB 37: read access */
  a[i] = x;         /* UB 37: write access */
  return tmp;
}

/* In b.c */
int a[] = { 1, 2, 3, 4 };   /* UB 15 */

```

## Compliant Solution (Incompatible Array Declarations)

This compliant solution declares `a` as an array in `a.c` and `b.c`:

```cpp
/* In a.c */
extern int a[];   

int f(unsigned int i, int x) {
  int tmp = a[i];   
  a[i] = x;         
  return tmp;
}

/* In b.c */
int a[] = { 1, 2, 3, 4 };  
```

## Noncompliant Code Example (Incompatible Function Declarations)

In this noncompliant code example, the function `f()` is declared in file `a.c` with one prototype but defined in file `b.c` with another. The two prototypes are incompatible, resulting in [undefined behavior 15](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_15). Furthermore, invoking the function is [undefined behavior 41](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_41) and typically has catastrophic consequences.

```cpp
/* In a.c */
extern int f(int a);   /* UB 15 */

int g(int a) {
  return f(a);   /* UB 41 */
}

/* In b.c */
long f(long a) {   /* UB 15 */
  return a * 2;
}

```

## Compliant Solution (Incompatible Function Declarations)

This compliant solution has compatible prototypes for the function `f()`:

```cpp
/* In a.c */
extern int f(int a);   

int g(int a) {
  return f(a);   
}

/* In b.c */
int f(int a) {   
  return a * 2;
}
```

## Noncompliant Code Example (Incompatible Variadic Function Declarations)

In this noncompliant code example, the function `buginf()` is defined to take a variable number of arguments and expects them all to be signed integers with a sentinel value of `-1`:

```cpp
/* In a.c */
void buginf(const char *fmt, ...) {
   /* ... */
}
 
/* In b.c */
void buginf();
```
Although this code appears to be well defined because of the prototype-less declaration of `buginf()`, it exhibits [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) in accordance with the C Standard, 6.7.6.3, paragraph 15 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\],

> For two function types to be compatible, both shall specify compatible return types. Moreover, the parameter type lists, if both are present, shall agree in the number of parameters and in use of the ellipsis terminator; corresponding parameters shall have compatible types. If one type has a parameter type list and the other type is specified by a function declarator that is not part of a function definition and that contains an empty identifier list, the parameter list shall not have an ellipsis terminator and the type of each parameter shall be compatible with the type that results from the application of the default argument promotions.


## Compliant Solution (Incompatible Variadic Function Declarations)

In this compliant solution, the prototype for the function `buginf()` is included in the scope in the source file where it will be used:

```cpp
/* In a.c */
void buginf(const char *fmt, ...) {
   /* ... */
}

/* In b.c */
void buginf(const char *fmt, ...);
```

## Noncompliant Code Example (Excessively Long Identifiers)

In this noncompliant code example, the length of the identifier declaring the function pointer `bash_groupname_completion_function()` in the file `bashline.h` exceeds by 3 the minimum implementation limit of 31 significant initial characters in an external identifier. This introduces the possibility of colliding with the `bash_groupname_completion_funct` integer variable defined in file `b.c`, which is exactly 31 characters long. On an implementation that exactly meets this limit, this is [undefined behavior 31](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_31). It results in two incompatible declarations of the same function. (See [undefined behavior 15](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_15).) In addition, invoking the function leads to [undefined behavior 41](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_41) with typically catastrophic effects.

```cpp
/* In bashline.h */
/* UB 15, UB 31 */
extern char * bash_groupname_completion_function(const char *, int);

/* In a.c */
#include "bashline.h"

void f(const char *s, int i) {
  bash_groupname_completion_function(s, i);  /* UB 41 */
}

/* In b.c */
int bash_groupname_completion_funct;  /* UB 15, UB 31 */

```
NOTE: The identifier `bash_groupname_completion_function` referenced here was taken from GNU [Bash](http://www.gnu.org/software/bash/), version 3.2.

## Compliant Solution (Excessively Long Identifiers)

In this compliant solution, the length of the identifier declaring the function pointer `bash_groupname_completion()` in `bashline.h` is less than 32 characters. Consequently, it cannot clash with `bash_groupname_completion_funct` on any compliant platform.

```cpp
/* In bashline.h */
extern char * bash_groupname_completion(const char *, int);   

/* In a.c */
#include "bashline.h"

void f(const char *s, int i) {
  bash_groupname_completion(s, i);  
}

/* In b.c */
int bash_groupname_completion_funct; 
```

## Risk Assessment

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL40-C </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>type-compatibility</strong> <strong>type-compatibility-link</strong> <strong>distinct-extern</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-DCL40</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.1p0 </td> <td> <strong>LANG.STRUCT.DECL.IFLANG.STRUCT.DECL.IO</strong> </td> <td> Inconsistent function declarations Inconsistent object declarations </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2012 Rule 8.4</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C0776, C0778, C0779, C0789, C1510</strong> <strong>C++1510</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.FUNC.NOPROT.DEF.2012</strong> <strong>MISRA.FUNC.PARAMS.IDENT</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 8.5.4 </td> <td> <strong>1 X, 17 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-DCL40-a</strong> <strong>CERT_C-DCL40-b</strong> </td> <td> All declarations of an object or function shall have compatible types If objects or functions are declared more than once their types shall be compatible </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>18, 621, 793, 4376</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule DCL40-C </a> </td> <td> Checks for declaration mismatch (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0776, 0778, 0779, </strong> <strong>0789, </strong> <strong>1510</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>1510</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>type-compatibility</strong> <strong>type-compatibility-link</strong> <strong>distinct-extern</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>incompatible declaration</strong> </td> <td> Exhaustively verified. </td> </tr> </tbody> </table>


## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Declaring the same function or object in incompatible ways \[funcdecl\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 8.4 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Hatton 1995 </a> \] </td> <td> Section 2.8.3 </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.7.6.3, "Function Declarators (including Prototypes)" J.2, "Undefined Behavior" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [DCL40-C: Do not create incompatible declarations of the same function or object](https://wiki.sei.cmu.edu/confluence/display/c)
