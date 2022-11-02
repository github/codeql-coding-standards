# EXP37-C: Pass the correct number of arguments to the POSIX open function

This query implements the CERT-C rule EXP37-C:

> Call functions with the correct number and type of arguments


## Description

Do not call a function with the wrong number or type of arguments.

The C Standard identifies five distinct situations in which [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) (UB) may arise as a result of invoking a function using a declaration that is incompatible with its definition or by supplying incorrect types or numbers of arguments:

<table> <tbody> <tr> <td> UB </td> <td> Description </td> </tr> <tr> <td> <a> 26 </a> </td> <td> <em> A pointer is used to call a function whose type is not compatible with the referenced type (6.3.2.3). </em> </td> </tr> <tr> <td> <a> 38 </a> </td> <td> <em> For a call to a function without a function prototype in scope, the number of arguments does not equal the number of parameters (6.5.2.2). </em> </td> </tr> <tr> <td> <a> 39 </a> </td> <td> <em> For a call to a function without a function prototype in scope where the function is defined with a function prototype, either the prototype ends with an ellipsis or the types of the arguments after promotion are not compatible with the types of the parameters (6.5.2.2). </em> </td> </tr> <tr> <td> <a> 40 </a> </td> <td> <em> For a call to a function without a function prototype in scope where the function is not defined with a function prototype, the types of the arguments after promotion are not compatible with those of the parameters after promotion (with certain exceptions) (6.5.2.2). </em> </td> </tr> <tr> <td> <a> 41 </a> </td> <td> <em> A function is defined with a type that is not compatible with the type (of the expression) pointed to by the expression that denotes the called function (6.5.2.2). </em> </td> </tr> </tbody> </table>
Functions that are appropriately declared (as in [DCL40-C. Do not create incompatible declarations of the same function or object](https://wiki.sei.cmu.edu/confluence/display/c/DCL40-C.+Do+not+create+incompatible+declarations+of+the+same+function+or+object)) will typically generate a compiler diagnostic message if they are supplied with the wrong number or types of arguments. However, there are cases in which supplying the incorrect arguments to a function will, at best, generate compiler [warnings](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-warning). Although such warnings should be resolved, they do not prevent program compilation. (See [MSC00-C. Compile cleanly at high warning levels](https://wiki.sei.cmu.edu/confluence/display/c/MSC00-C.+Compile+cleanly+at+high+warning+levels).)


## Noncompliant Code Example

The header `<tgmath.h>` provides type-generic macros for math functions. Although most functions from the `<math.h>` header have a complex counterpart in `<complex.h>`, several functions do not. Calling any of the following type-generic functions with complex values is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

**Functions That Should Not Be Called with Complex Values**

<table> <tbody> <tr> <td> <code>atan2()</code> </td> <td> <code>erf<code>()</code></code> </td> <td> <code>fdim<code>()</code></code> </td> <td> <code>fmin<code>()</code></code> </td> <td> <code>ilogb<code>()</code></code> </td> <td> <code>llround<code>()</code></code> </td> <td> <code>logb<code>()</code></code> </td> <td> <code>nextafter<code>()</code></code> </td> <td> <code>rint<code>()</code></code> </td> <td> <code>tgamma<code>()</code></code> </td> </tr> <tr> <td> <code>cbrt<code>()</code></code> </td> <td> <code>erfc<code>()</code></code> </td> <td> <code>floor<code>()</code></code> </td> <td> <code>fmod<code>()</code></code> </td> <td> <code>ldexp<code>()</code></code> </td> <td> <code>log10<code>()</code></code> </td> <td> <code>lrint<code>()</code></code> </td> <td> <code>nexttoward<code>()</code></code> </td> <td> <code>round<code>()</code></code> </td> <td> <code>trunc<code>()</code></code> </td> </tr> <tr> <td> <code>ceil<code>()</code></code> </td> <td> <code>exp2<code>()</code></code> </td> <td> <code>fma<code>()</code></code> </td> <td> <code>frexp<code>()</code></code> </td> <td> <code>lgamma<code>()</code></code> </td> <td> <code>log1p<code>()</code></code> </td> <td> <code>lround<code>()</code></code> </td> <td> <code>remainder<code>()</code></code> </td> <td> <code>scalbn<code>()</code></code> </td> <td> </td> </tr> <tr> <td> <code>copysign<code>()</code></code> </td> <td> <code>expm1<code>()</code></code> </td> <td> <code>fmax<code>()</code></code> </td> <td> <code>hypot<code>()</code></code> </td> <td> <code>llrint<code>()</code></code> </td> <td> <code>log2<code>()</code></code> </td> <td> <code>nearbyint<code>()</code></code> </td> <td> <code>remquo<code>()</code></code> </td> <td> <code>scalbln<code>()</code></code> </td> <td> </td> </tr> </tbody> </table>
This noncompliant code example attempts to take the base-2 logarithm of a complex number, resulting in undefined behavior:


```cpp
#include <tgmath.h>
 
void func(void) {
  double complex c = 2.0 + 4.0 * I;
  double complex result = log2(c);
}
```

## Compliant Solution (Complex Number)

If the `clog2()` function is not available for an implementation as an extension, the programmer can take the base-2 logarithm of a complex number, using `log()` instead of `log2()`, because `log()` can be used on complex arguments, as shown in this compliant solution:

```cpp
#include <tgmath.h>
 
void func(void) {
  double complex c = 2.0 + 4.0 * I;
  double complex result = log(c)/log(2);
}
```

## Compliant Solution (Real Number)

The programmer can use this compliant solution if the intent is to take the base-2 logarithm of the real part of the complex number:

```cpp
#include <tgmath.h>
 
void func(void) {
  double complex c = 2.0 + 4.0 * I;
  double complex result = log2(creal(c));
}
```

## Noncompliant Code Example

In this noncompliant example, the C standard library function `strchr()` is called through the function pointer `fp` declared with a prototype with incorrectly typed arguments. According to the C Standard, 6.3.2.3, paragraph 8 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\]

> A pointer to a function of one type may be converted to a pointer to a function of another type and back again; the result shall compare equal to the original pointer. If a converted pointer is used to call a function whose type is not compatible with the referenced type, the behavior is undefined.


See [undefined behavior 26.](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_26)

```cpp
#include <stdio.h>
#include <string.h>

char *(*fp)();

int main(void) {
  const char *c;
  fp = strchr;
  c = fp('e', "Hello");
  printf("%s\n", c);
  return 0;
}
```

## Compliant Solution

In this compliant solution, the function pointer `fp`, which points to the C standard library function `strchr()`, is declared with the correct parameters and is invoked with the correct number and type of arguments:

```cpp
#include <stdio.h>
#include <string.h>

char *(*fp)(const char *, int);

int main(void) {
  const char *c;
  fp = strchr;
  c = fp("Hello",'e');
  printf("%s\n", c);
  return 0;
}

```

## Noncompliant Code Example

In this noncompliant example, the function `f()` is defined to take an argument of type `long` but `f()` is called from another file with an argument of type `int`:

```cpp
/* In another source file */
long f(long x) {
  return x < 0 ? -x : x;
}

/* In this source file, no f prototype in scope */
long f();
 
long g(int x) {
  return f(x);
}
```

## Compliant Solution

In this compliant solution, the prototype for the function `f()` is included in the source file in the scope of where it is called, and the function `f()` is correctly called with an argument of type `long`:

```cpp
/* In another source file */
 
long f(long x) {
  return x < 0 ? -x : x;
}

/* f prototype in scope in this source file */

long f(long x); 

long g(int x) {
  return f((long)x);  
}

```

## Noncompliant Code Example (POSIX)

The POSIX function `open()` \[[IEEE Std 1003.1:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\] is a variadic function with the following prototype:

```cpp
int open(const char *path, int oflag, ... );

```
The `open()` function accepts a third argument to determine a newly created file's access mode. If `open()` is used to create a new file and the third argument is omitted, the file may be created with unintended access permissions. (See [FIO06-C. Create files with appropriate access permissions](https://wiki.sei.cmu.edu/confluence/display/c/FIO06-C.+Create+files+with+appropriate+access+permissions).)

In this noncompliant code example from a [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) in the `useradd()` function of the `shadow-utils` package [CVE-2006-1174](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2006-1174), the third argument to `open()` is accidentally omitted:

```cpp
fd = open(ms, O_CREAT | O_EXCL | O_WRONLY | O_TRUNC);

```
Technically, it is incorrect to pass a third argument to open() when not creating a new file (that is, with the O_CREAT flag not set).

## Compliant Solution (POSIX)

In this compliant solution, a third argument is specified in the call to `open()`:

```cpp
#include <fcntl.h>
 
void func(const char *ms, mode_t perms) {
  /* ... */
  int fd;
  fd = open(ms, O_CREAT | O_EXCL | O_WRONLY | O_TRUNC, perms);
  if (fd == -1) {
    /* Handle error */
  }
}
```

## Risk Assessment

Calling a function with incorrect arguments can result in [unexpected](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior) or unintended program behavior.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP37-C </td> <td> Medium </td> <td> Probable </td> <td> High </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>incompatible-argument-type</strong> <strong>parameter-match</strong> <strong>parameter-match-computed</strong> <strong>parameter-match-type</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-EXP37</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.FUNCS.APM</strong> </td> <td> Array parameter mismatch </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect some violations of this rule. In particular, it ensures that all calls to <code>open()</code> supply exactly two arguments if the second argument does not involve <code>O_CREAT</code> , and exactly three arguments if the second argument does involve <code>O_CREAT</code> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2012 Rule 8.2</strong> <strong><strong>MISRA C 2012 Rule 17.3</strong></strong> </td> <td> Implemented Relies on functions declared with prototypes, allow compiler to check </td> </tr> <tr> <td> <a> ECLAIR </a> </td> <td> 1.2 </td> <td> <strong>CC2.EXP37</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> EDG </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> GCC </a> </td> <td> 4.3.5 </td> <td> </td> <td> Can detect violation of this rule when the <code>-Wstrict-prototypes</code> flag is used. However, it cannot detect violations involving variadic functions, such as the <code>open()</code> example described earlier </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C1331, C1332, C1333, C3002, C3320, C3335</strong> <strong>C++0403</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.FUNC.UNMATCHED.PARAMS</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong><strong>41 D, 21 S, 98 S, 170 S, 496 S, 576 S</strong></strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-EXP37-a</strong> <strong>CERT_C-EXP37-b</strong> <strong>CERT_C-EXP37-c</strong> <strong>CERT_C-EXP37-d</strong> </td> <td> Identifiers shall be given for all of the parameters in a function prototype declaration Function types shall have named parameters Function types shall be in prototype form Functions shall always have visible prototype at the function call </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule EXP37-C </a> </td> <td> Checks for: Implicit function declarationmplicit function declaration, bad file access mode or statusad file access mode or status, unreliable cast of function pointernreliable cast of function pointer, standard function call with incorrect argumentstandard function call with incorrect arguments. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>1331, 1332, 1333, 3002, 3320, 3335</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>0403</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.20 </td> <td> <strong>V540<a></a></strong> , <strong>V541<a></a></strong> , <strong>V549<a></a></strong> , <strong>V575<a></a></strong> , <strong>V632<a></a></strong> , <strong>V639<a></a></strong> , <strong><a>V666</a></strong> , <strong>V671<a></a></strong> , <strong>V742<a></a></strong> , <strong><a>V743</a></strong> , <strong>V764<a></a></strong> , <strong><a>V1004</a></strong> </td> <td> </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S930</a></strong> </td> <td> Detects incorrect argument count </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>parameter-match</strong> <strong>parameter-match-type</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>unclassified ("function type matches")</strong> </td> <td> Partially verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP37-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> DCL07-C. Include the appropriate type information in function declarators </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MSC00-C. Compile cleanly at high warning levels </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> FIO06-C. Create files with appropriate access permissions </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Subprogram Signature Mismatch \[OTR\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Calling functions with incorrect arguments \[argcomp\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 8.2 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 17.3 (mandatory) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-628 </a> , Function Call with Incorrectly Specified Arguments </td> <td> 2017-07-05: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-685 and EXP37-C**

EXP37-C = Union( CWE-685, CWE-686) Intersection( CWE-685, CWE-686) = Ø

**CWE-686 and EXP37-C**

Intersection( EXP37-C, FIO47-C) =

* Invalid argument types passed to format I/O function
EXP37-C – FIO47-C =
* Invalid argument types passed to non-format I/O function
FIO47-C – EXP37-C =
* Invalid format string, but correctly matches arguments in number and type
EXP37-C = Union( CWE-685, CWE-686)

Intersection( CWE-685, CWE-686) = Ø

**CWE-628 and EXP37-C**

CWE-628 = Union( EXP37-C, list) where list =

* Improper ordering of function arguments (that does not violate argument types)
* Wrong argument values or references

## Bibliography

<table> <tbody> <tr> <td> \[ <a> CVE </a> \] </td> <td> <a> CVE-2006-1174 </a> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.3.2.3, "Pointers" 6.5.2.2, "Function Calls" </td> </tr> <tr> <td> \[ <a> IEEE Std 1003.1:2013 </a> \] </td> <td> <code>open()</code> </td> </tr> <tr> <td> \[ <a> Spinellis 2006 </a> \] </td> <td> Section 2.6.1, "Incorrect Routine or Arguments" </td> </tr> </tbody> </table>


## Implementation notes

The analysis of invalid parameter count passed to POSIX open calls only applies when the value of the flags argument is computed locally.

## References

* CERT-C: [EXP37-C: Call functions with the correct number and type of arguments](https://wiki.sei.cmu.edu/confluence/display/c)
