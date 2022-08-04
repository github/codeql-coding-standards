# ERR52-CPP: Do not use setjmp() or longjmp()

This query implements the CERT-C++ rule ERR52-CPP:

> Do not use setjmp() or longjmp()


## Description

The C standard library facilities `setjmp()` and `longjmp()` can be used to simulate throwing and catching exceptions. However, these facilities bypass automatic resource management and can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior), commonly including resource leaks and [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service).

The C++ Standard, \[support.runtime\], paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> The function signature `longjmp(jmp_buf jbuf, int val)` has more restricted behavior in this International Standard. A `setjmp`/`longjmp` call pair has undefined behavior if replacing the `setjmp` and `longjmp` by `catch` and `throw` would invoke any non-trivial destructors for any automatic objects.


Do not call `setjmp()` or `longjmp()`; their usage can be replaced by more standard idioms such as `throw` expressions and `catch` statements.

## Noncompliant Code Example

If a `throw `expression would cause a nontrivial destructor to be invoked, then calling `longjmp() `in the same context will result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). In the following noncompliant code example, the call to `longjmp() `occurs in a context with a local `Counter `object. Since this object’s destructor is nontrivial, undefined behavior results.

```cpp
#include <csetjmp>
#include <iostream>

static jmp_buf env;

struct Counter {
  static int instances;
  Counter() { ++instances; }
  ~Counter() { --instances; }
};

int Counter::instances = 0;

void f() {
  Counter c;
  std::cout << "f(): Instances: " << Counter::instances << std::endl;
  std::longjmp(env, 1);
}

int main() {
  std::cout << "Before setjmp(): Instances: " << Counter::instances << std::endl;
  if (setjmp(env) == 0) {
    f();
  } else {
    std::cout << "From longjmp(): Instances: " << Counter::instances << std::endl;
  }
  std::cout << "After longjmp(): Instances: " << Counter::instances << std::endl;
}

```
**Implementation Details**

The above code produces the following results when compiled with [Clang ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-clang)3.8 for Linux, demonstrating that the program, on this platform, fails to destroy the local `Counter` instance when the execution of `f()` is terminated. This is permissible as the behavior is undefined.

```cpp
Before setjmp(): Instances: 0
f(): Instances: 1
From longjmp(): Instances: 1
After longjmp(): Instances: 1
```

## Compliant Solution

This compliant solution replaces the calls to `setjmp()` and `longjmp()` with a `throw` expression and a `catch` statement.

```cpp
#include <iostream>

struct Counter {
  static int instances;
  Counter() { ++instances; }
  ~Counter() { --instances; }
};

int Counter::instances = 0;

void f() {
  Counter c;
  std::cout << "f(): Instances: " << Counter::instances << std::endl;
  throw "Exception";
}

int main() {
  std::cout << "Before throw: Instances: " << Counter::instances << std::endl;
  try {
    f();
  } catch (const char *E) {
    std::cout << "From catch: Instances: " << Counter::instances << std::endl;
  }
  std::cout << "After catch: Instances: " << Counter::instances << std::endl;
}

```
This solution produces the following output.

```cpp
Before throw: Instances: 0
f(): Instances: 1
From catch: Instances: 0
After catch: Instances: 0

```

## Risk Assessment

Using `setjmp()` and `longjmp()` could lead to a [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions) due to resources not being properly destroyed.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR52-CPP </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>include-setjmp</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-ERR52</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>cert-err52-cpp</code> </td> <td> Checked by <code>clang-tidy</code> . </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.LONGJMPBADFUNC.SETJMP</strong> </td> <td> Use of longjmp Use of setjmp </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++5015</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.STDLIB.LONGJMP</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>43 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-ERR52-a</strong> <strong>CERT_CPP-ERR52-b</strong> </td> <td> The setjmp macro and the longjmp function shall not be used The standard header file &lt;setjmp.h&gt; shall not be used </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: ERR52-CPP </a> </td> <td> Checks for use of setjmp/longjmp (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>5015</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>include-setjmp</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S982</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR34-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Henricson 1997 </a> \] </td> <td> Rule 13.3, Do not use <code>setjmp()</code> and <code>longjmp()</code> </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 18.10, "Other Runtime Support" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [ERR52-CPP: Do not use setjmp() or longjmp()](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
