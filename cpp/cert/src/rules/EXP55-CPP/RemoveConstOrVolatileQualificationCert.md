# EXP55-CPP: Do not access a cv-qualified object through a cv-unqualified type

This query implements the CERT-C++ rule EXP55-CPP:

> Do not access a cv-qualified object through a cv-unqualified type


## Description

The C++ Standard, \[dcl.type.cv\], paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> Except that any class member declared `mutable` can be modified, any attempt to modify a `const` object during its lifetime results in undefined behavior.


Similarly, paragraph 6 states the following:

> What constitutes an access to an object that has volatile-qualified type is implementation-defined. If an attempt is made to refer to an object defined with a volatile-qualified type through the use of a glvalue with a non-volatile-qualified type, the program behavior is undefined.


Do not cast away a `const` qualification to attempt to modify the resulting object. The `const` qualifier implies that the API designer does not intend for that object to be modified despite the possibility it may be modifiable. Do not cast away a `volatile` qualification; the `volatile` qualifier implies that the API designer intends the object to be accessed in ways unknown to the compiler, and any access of the volatile object results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Noncompliant Code Example

In this noncompliant code example, the function `g`() is passed a const int &amp;, which is then cast to an int &amp; and modified. Because the referenced value was previously declared as const, the assignment operation results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
void g(const int &ci) {
  int &ir = const_cast<int &>(ci);
  ir = 42;
}

void f() {
  const int i = 4;
  g(i);
}
```

## Compliant Solution

In this compliant solution, the function `g()` is passed an `int &`, and the caller is required to pass an `int` that can be modified.

```cpp
void g(int &i) {
  i = 42;
}

void f() {
  int i = 4;
  g(i);
}

```

## Noncompliant Code Example

In this noncompliant code example, a `const`-qualified method is called that attempts to cache results by casting away the `const`-qualifier of `this`. Because `s` was declared `const`, the mutation of `cachedValue` results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <iostream>
 
class S {
  int cachedValue;
  
  int compute_value() const;  // expensive
public:
  S() : cachedValue(0) {}
  
  // ...  
  int get_value() const {
    if (!cachedValue) {
      const_cast<S *>(this)->cachedValue = compute_value();  
    }        
    return cachedValue;
  }
};

void f() {
  const S s;
  std::cout << s.get_value() << std::endl;
}
```

## Compliant Solution

This compliant solution uses the `mutable` keyword when declaring `cachedValue`, which allows `cachedValue` to be mutated within a `const` context without triggering [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <iostream>
 
class S {
  mutable int cachedValue;
  
  int compute_value() const;  // expensive
public:
  S() : cachedValue(0) {}
  
  // ...  
  int get_value() const {
    if (!cachedValue) {
      cachedValue = compute_value();  
    }        
    return cachedValue;
  }
};

void f() {
  const S s;
  std::cout << s.get_value() << std::endl;
}
```

## Noncompliant Code Example

In this noncompliant code example, the volatile value `s` has the `volatile` qualifier cast away, and an attempt is made to read the value within `g()`, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <iostream>

struct S {
  int i;
  
  S(int i) : i(i) {}
};

void g(S &s) {
  std::cout << s.i << std::endl;
}

void f() {
  volatile S s(12);
  g(const_cast<S &>(s));
}
```

## Compliant Solution

This compliant solution assumes that the volatility of `s` is required, so `g()` is modified to accept a `volatile S &.`

```cpp
#include <iostream>

struct S {
  int i;
  
  S(int i) : i(i) {}
};

void g(volatile S &s) {
  std::cout << s.i << std::endl;
}

void f() {
  volatile S s(12);
  g(s);
}
```

## Exceptions

**EXP55-CPP-EX1:** An exception to this rule is allowed when it is necessary to cast away `const` when invoking a legacy API that does not accept a `const` argument, provided the function does not attempt to modify the referenced variable. However, it is always preferable to modify the API to be `const`-correct when possible. For example, the following code casts away the `const` qualification of `INVFNAME` in the call to the `audit_log()` function.

```cpp
// Legacy function defined elsewhere - cannot be modified; does not attempt to
// modify the contents of the passed parameter.
void audit_log(char *errstr);

void f() {
  const char INVFNAME[]  = "Invalid file name.";
  audit_log(const_cast<char *>(INVFNAME));
}
```

## Risk Assessment

If the object is declared as being constant, it may reside in write-protected memory at runtime. Attempting to modify such an object may lead to [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) or a [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service). If an object is declared as being volatile, the compiler can make no assumptions regarding access of that object. Casting away the volatility of an object can result in reads or writes to the object being reordered or elided entirely, resulting in abnormal program execution.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP55-CPP </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>pointer-qualifier-cast-constpointer-qualifier-cast-volatile</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-EXP55</strong> </td> <td> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3066, C++4671</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.CAST.CONST</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>203 S, 242 S, 344 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-EXP55-a</strong> </td> <td> A cast shall not remove any 'const' or 'volatile' qualification from the type of a pointer or reference </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: EXP55-CPP </a> </td> <td> Checks for casts that remove cv-qualification of pointer (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3066, 4671</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>pointer-qualifier-cast-constpointer-qualifier-cast-volatile</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S859</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vuln) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+EXP35-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> EXP32-C. Do not access a volatile object through a nonvolatile reference </a> <a> EXP40-C. Do not modify constant objects </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 7.1.6.1, "The <em> cv-qualifiers </em> " </td> </tr> <tr> <td> \[ <a> Sutter 2004 </a> \] </td> <td> Item 94, "Avoid Casting Away <code>const</code> " </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP55-CPP: Do not access a cv-qualified object through a cv-unqualified type](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
