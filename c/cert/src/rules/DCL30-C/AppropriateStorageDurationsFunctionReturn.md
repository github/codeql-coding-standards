# DCL30-C: Declare objects with appropriate storage durations

This query implements the CERT-C rule DCL30-C:

> Declare objects with appropriate storage durations


## Description

Every object has a storage duration that determines its lifetime: *static*, *thread*, *automatic*, or *allocated*.

According to the C Standard, 6.2.4, paragraph 2 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\],

> The lifetime of an object is the portion of program execution during which storage is guaranteed to be reserved for it. An object exists, has a constant address, and retains its last-stored value throughout its lifetime. If an object is referred to outside of its lifetime, the behavior is undefined. The value of a pointer becomes indeterminate when the object it points to reaches the end of its lifetime.


Do not attempt to access an object outside of its lifetime. Attempting to do so is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) and can lead to an exploitable [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability). (See also [undefined behavior 9](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_9) in the C Standard, Annex J.)

## Noncompliant Code Example (Differing Storage Durations)

In this noncompliant code example, the address of the variable `c_str` with automatic storage duration is assigned to the variable `p`, which has static storage duration. The assignment itself is valid, but it is invalid for `c_str` to go out of scope while `p` holds its address, as happens at the end of `dont_do_this``()`.

```cpp
#include <stdio.h>
 
const char *p;
void dont_do_this(void) {
  const char c_str[] = "This will change";
  p = c_str; /* Dangerous */
}

void innocuous(void) {
  printf("%s\n", p);
}

int main(void) {
  dont_do_this();
  innocuous();
  return 0;
}
```

## Compliant Solution (Same Storage Durations)

In this compliant solution, `p` is declared with the same storage duration as `c_str`, preventing `p` from taking on an [indeterminate value](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue) outside of `this_is_OK()`:

```cpp
void this_is_OK(void) {
  const char c_str[] = "Everything OK";
  const char *p = c_str;
  /* ... */
}
/* p is inaccessible outside the scope of string c_str */

```
Alternatively, both `p` and `c_str` could be declared with static storage duration.

## Compliant Solution (Differing Storage Durations)

If it is necessary for `p` to be defined with static storage duration but `c_str` with a more limited duration, then `p` can be set to `NULL` before `c_str` is destroyed. This practice prevents `p` from taking on an [indeterminate value](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-indeterminatevalue), although any references to `p` must check for `NULL`.

```cpp
const char *p;
void is_this_OK(void) {
  const char c_str[] = "Everything OK?";
  p = c_str;
  /* ... */
  p = NULL;
}

```

## Noncompliant Code Example (Return Values)

In this noncompliant code sample, the function `init_array``()` returns a pointer to a character array with automatic storage duration, which is accessible to the caller:

```cpp
char *init_array(void) {
  char array[10];
  /* Initialize array */
  return array;
}

```
Some compilers generate a diagnostic message when a pointer to an object with automatic storage duration is returned from a function, as in this example. Programmers should compile code at high warning levels and resolve any diagnostic messages. (See [MSC00-C. Compile cleanly at high warning levels](https://wiki.sei.cmu.edu/confluence/display/c/MSC00-C.+Compile+cleanly+at+high+warning+levels).)

## Compliant Solution (Return Values)

The solution, in this case, depends on the intent of the programmer. If the intent is to modify the value of `array` and have that modification persist outside the scope of `init_array()`, the desired behavior can be achieved by declaring `array` elsewhere and passing it as an argument to `init_array()`:

```cpp
#include <stddef.h>
void init_array(char *array, size_t len) {
  /* Initialize array */
  return;
}

int main(void) {
  char array[10];
  init_array(array, sizeof(array) / sizeof(array[0]));
  /* ... */
  return 0;
}

```

## Noncompliant Code Example (Output Parameter)

In this noncompliant code example, the function `squirrel_away()` stores a pointer to local variable `local` into a location pointed to by function parameter `ptr_param`. Upon the return of `squirrel_away()`, the pointer `ptr_param` points to a variable that has an expired lifetime.

```cpp
void squirrel_away(char **ptr_param) {
  char local[10];
  /* Initialize array */
  *ptr_param = local;
}

void rodent(void) {
  char *ptr;
  squirrel_away(&ptr);
  /* ptr is live but invalid here */
}

```

## Compliant Solution (Output Parameter)

In this compliant solution, the variable `local` has static storage duration; consequently, `ptr` can be used to reference the `local` array within the `rodent()` function:

```cpp
char local[10];
 
void squirrel_away(char **ptr_param) {
  /* Initialize array */
  *ptr_param = local;
}

void rodent(void) {
  char *ptr;
  squirrel_away(&ptr);
  /* ptr is valid in this scope */
}

```

## Risk Assessment

Referencing an object outside of its lifetime can result in an attacker being able to execute arbitrary code.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL30-C </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>pointered-deallocation</strong> <strong>return-reference-local</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-DCL30</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.STRUCT.RPL</strong> </td> <td> Returns pointer to local </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this rule. It automatically detects returning pointers to local variables. Detecting more general cases, such as examples where static pointers are set to local variables which then go out of scope, would be difficult </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>RETURN_LOCAL</strong> </td> <td> Finds many instances where a function will return a pointer to a local stack variable. Coverity Prevent cannot discover all violations of this rule, so further verification is necessary </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C3217, C3225, C3230, C4140</strong> <strong>C++2515, C++2516, C++2527, C++2528, C++4026, C++4624, C++4629</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>LOCRET.ARGLOCRET.GLOB</strong> <strong>LOCRET.RET</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>42 D, 77 D, 71 S, 565 S</strong> </td> <td> Enhanced Enforcement </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-DCL30-a</strong> <strong>CERT_C-DCL30-b</strong> </td> <td> The address of an object with automatic storage shall not be returned from a function The address of an object with automatic storage shall not be assigned to another object that may persist after the first object has ceased to exist </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>604, 674, 733, 789</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule DCL30-C </a> </td> <td> Checks for pointer or reference to stack variable leaving scope (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>3217, 3225, 3230, 4140</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2515, 2516, 2527, 2528, 4026, 4624, 4629</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong>V506<a></a></strong> , <strong>V507<a></a></strong> , <strong>V558<a></a></strong> , <strong>V623<a></a></strong> , <strong>V723<a></a></strong> , <strong><a>V738</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>return-reference-local</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>dangling_pointer</strong> </td> <td> Exhaustively detects undefined behavior (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+DCL30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MSC00-C. Compile cleanly at high warning levels </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> EXP54-CPP. Do not access an object outside of its lifetime </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Dangling References to Stack Frames \[DCM\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961 </a> </td> <td> Escaping of the address of an automatic object \[addrescape\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> MISRA C:2012 </a> </td> <td> Rule 18.6 (required) </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-562 and DCL30-C**

DCL30-C = Union( CWE-562, list) where list =

* Assigning a stack pointer to an argument (thereby letting it outlive the current function

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Coverity 2007 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.2.4, "Storage Durations of Objects" </td> </tr> </tbody> </table>


## Implementation notes

The rule checks specifically for pointers to objects with automatic storage duration that are returned by functions or assigned to function output parameters.

## References

* CERT-C: [DCL30-C: Declare objects with appropriate storage durations](https://wiki.sei.cmu.edu/confluence/display/c)
