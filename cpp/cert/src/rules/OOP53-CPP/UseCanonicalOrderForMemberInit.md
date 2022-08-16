# OOP53-CPP: Write constructor member initializers in the canonical order

This query implements the CERT-C++ rule OOP53-CPP:

> Write constructor member initializers in the canonical order


## Description

The member initializer list for a class constructor allows members to be initialized to specified values and for base class constructors to be called with specific arguments. However, the order in which initialization occurs is fixed and does not depend on the order written in the member initializer list. The C++ Standard, \[class.base.init\], paragraph 11 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> In a non-delegating constructor, initialization proceeds in the following order:— First, and only for the constructor of the most derived class, virtual base classes are initialized in the order they appear on a depth-first left-to-right traversal of the directed acyclic graph of base classes, where “left-to-right” is the order of appearance of the base classes in the derived class base-specifier-list.— Then, direct base classes are initialized in declaration order as they appear in the base-specifier-list (regardless of the order of the mem-initializers).— Then, non-static data members are initialized in the order they were declared in the class definition (again regardless of the order of the mem-initializers).— Finally, the compound-statement of the constructor body is executed.\[Note: The declaration order is mandated to ensure that base and member subobjects are destroyed in the reverse order of initialization. —end note\]


Consequently, the order in which member initializers appear in the member initializer list is irrelevant. The order in which members are initialized, including base class initialization, is determined by the declaration order of the class member variables or the base class specifier list. Writing member initializers other than in canonical order can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior), such as reading uninitialized memory.

Always write member initializers in a constructor in the canonical order: first, direct base classes in the order in which they appear in the *base-specifier-list* for the class, then nonstatic data members in the order in which they are declared in the class definition.

## Noncompliant Code Example

In this noncompliant code example, the member initializer list for `C::C()` attempts to initialize `someVal` first and then to initialize `dependsOnSomeVal` to a value dependent on `someVal`. Because the declaration order of the member variables does not match the member initializer order, attempting to read the value of `someVal` results in an [unspecified value](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedvalue) being stored into dependsOnSomeVal.

```cpp
class C {
  int dependsOnSomeVal;
  int someVal;
 
public:
  C(int val) : someVal(val), dependsOnSomeVal(someVal + 1) {}
};
```

## Compliant Solution

This compliant solution changes the declaration order of the class member variables so that the dependency can be ordered properly in the constructor's member initializer list.

```cpp
class C {
  int someVal;
  int dependsOnSomeVal;
 
public:
  C(int val) : someVal(val), dependsOnSomeVal(someVal + 1) {}
};

```
It is reasonable for initializers to depend on previously initialized values.

## Noncompliant Code Example

In this noncompliant code example, the derived class, `D`, attempts to initialize the base class, `B1`, with a value obtained from the base class, `B2`. However, because `B1` is initialized before `B2` due to the declaration order in the base class specifier list, the resulting behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
class B1 {
  int val;
 
public:
  B1(int val) : val(val) {}
};

class B2 {
  int otherVal;
 
public:
  B2(int otherVal) : otherVal(otherVal) {}
  int get_other_val() const { return otherVal; }
};

class D : B1, B2 {
public:
  D(int a) : B2(a), B1(get_other_val()) {}
};
```

## Compliant Solution

This compliant solution initializes both base classes using the same value from the constructor's parameter list instead of relying on the initialization order of the base classes.

```cpp
class B1 {
  int val;
 
public:
  B1(int val) : val(val) {}
};

class B2 {
  int otherVal;
 
public:
  B2(int otherVal) : otherVal(otherVal) {}
};

class D : B1, B2 {
public:
  D(int a) : B1(a), B2(a) {}
};
```

## Exceptions

**OOP53-CPP-EX0:** Constructors that do not use member initializers do not violate this rule.

## Risk Assessment

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> OOP53-CPP </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>initializer-list-order</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-OOP53</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wreorder</code> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.STRUCT.INIT.OOMI</strong> </td> <td> Out of Order Member Initializers </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4053</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CERT.OOP.CTOR.INIT_ORDER</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>206 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-OOP53-a</strong> </td> <td> List members in an initialization list in the order in which they are declared </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: OOP53-CPP </a> </td> <td> Checks for members not initialized in canonical order (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4053</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>initializer-list-order</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>S3229</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+OOP37-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 12.6.2, "Initializing Bases and Members" </td> </tr> <tr> <td> \[ <a> Lockheed Martin 2005 </a> \] </td> <td> AV Rule 75, Members of the initialization list shall be listed in the order in which they are declared in the class </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [OOP53-CPP: Write constructor member initializers in the canonical order](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
