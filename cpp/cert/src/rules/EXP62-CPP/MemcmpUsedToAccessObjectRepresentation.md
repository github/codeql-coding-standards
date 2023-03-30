# EXP62-CPP: Do not use memcmp to access bits that are not part of the object's value

This query implements the CERT-C++ rule EXP62-CPP:

> Do not access the bits of an object representation that are not part of the object's value representation


## Description

The C++ Standard, \[basic.types\], paragraph 9 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], states the following:

> The *object representation* of an object of type `T` is the sequence of *N* `unsigned char` objects taken up by the object of type `T`, where *N* equals `sizeof(T)`. The *value representation* of an object is the set of bits that hold the value of type `T`.


The narrow character types (`char`, `signed char`, and `unsigned char`)—as well as some other integral types on specific platforms—have an object representation that consists solely of the bits from the object's value representation. For such types, accessing any of the bits of the value representation is well-defined behavior. This form of object representation allows a programmer to access and modify an object solely based on its bit representation, such as by calling `std::memcmp()` on its object representation.

Other types, such as classes, may not have an object representation composed solely of the bits from the object's value representation. For instance, classes may have bit-field data members, padding inserted between data members, a [vtable](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vtable) to support virtual method dispatch, or data members declared with different access privileges. For such types, accessing bits of the object representation that are not part of the object's value representation may result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) depending on how those bits are accessed.

Do not access the bits of an object representation that are not part of the object's value representation. Even if the bits are accessed in a well-defined manner, such as through an array of `unsigned char` objects, the values represented by those bits are unspecified or implementation-defined, and reliance on any particular value can lead to abnormal program execution.

## Noncompliant Code Example

In this noncompliant code example, the complete object representation is accessed when comparing two objects of type `S`. Per the C++ Standard, \[class\], paragraph 13 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], classes may be padded with data to ensure that they are properly aligned in memory. The contents of the padding and the amount of padding added is [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior). This can lead to incorrect results when comparing the object representation of classes instead of the value representation, as the padding may assume different [unspecified values](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedvalue) for each object instance.

```cpp
#include <cstring>
 
struct S {
  unsigned char buffType;
  int size;
};
 
void f(const S &s1, const S &s2) {
  if (!std::memcmp(&s1, &s2, sizeof(S))) {
    // ...
  }
}
```

## Compliant Solution

In this compliant solution, `S` overloads `operator==()` to perform a comparison of the value representation of the object.

```cpp
struct S {  
  unsigned char buffType;
  int size;
 
  friend bool operator==(const S &lhs, const S &rhs) {
    return lhs.buffType == rhs.buffType &&
           lhs.size == rhs.size;
  }
};
 
void f(const S &s1, const S &s2) {
  if (s1 == s2) {
    // ...
  }
}
```

## Noncompliant Code Example

In this noncompliant code example, `std::memset()` is used to clear the internal state of an object. An [implementation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation) may store a vtable within the object instance due to the presence of a virtual function, and that vtable is subsequently overwritten by the call to `std::memset()`, leading to [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) when virtual method dispatch is required.

```cpp
#include <cstring>

struct S {
  int i, j, k;
 
  // ...

  virtual void f();
};

void f() {
  S *s = new S;
  // ...
  std::memset(s, 0, sizeof(S));
  // ...
  s->f(); // undefined behavior
}
```

## Compliant Solution

In this compliant solution, the data members of `S` are cleared explicitly instead of calling `std::memset().`

```cpp
struct S {
  int i, j, k;
 
  // ...

  virtual void f();
  void clear() { i = j = k = 0; }
};

void f() {
  S *s = new S;
  // ...
  s->clear();
  // ...
  s->f(); // ok
}
```

## Exceptions

**EXP62-CPP-EX1:** It is permissible to access the bits of an object representation when that access is otherwise unobservable in well-defined code. Specifically, reading bits that are not part of the value representation is permissible when there is no reliance or assumptions placed on their values, and writing bits that are not part of the value representation is only permissible when those bits are padding bits. This exception does not permit writing to bits that are part of the object representation aside from padding bits, such as overwriting a vtable pointer.

For instance, it is acceptable to call `std::memcpy()` on an object containing a bit-field, as in the following example, because the read and write of the padding bits cannot be observed.

```cpp
#include <cstring>
 
struct S {
  int i : 10;
  int j;
};
 
void f(const S &s1) {
  S s2;
  std::memcpy(&s2, &s1, sizeof(S));
}
```
Code that complies with this exception must still comply with [OOP57-CPP. Prefer special member functions and overloaded operators to C Standard Library functions](https://wiki.sei.cmu.edu/confluence/display/cplusplus/OOP57-CPP.+Prefer+special+member+functions+and+overloaded+operators+to+C+Standard+Library+functions).

## Risk Assessment

The effects of accessing bits of an object representation that are not part of the object's value representation can range from [implementation-defined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation-definedbehavior) (such as assuming the layout of fields with differing access controls) to code execution [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) (such as overwriting the vtable pointer).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> EXP62-CPP </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.10 </td> <td> <strong>invalid_pointer_dereferenceuninitialized_variable_use</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>BADFUNC.MEMCMP</strong> <strong>BADFUNC.MEMSET</strong> </td> <td> Use of memcmp Use of memset </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF4726, DF4727, DF4728, DF4729, DF4731, DF4732, DF4733, DF4734</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>CERT.MEMCMP.PADDED_DATA</strong> <strong>CWARN.MEM.NONPOD</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>618 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_CPP-EXP62-a</strong> </td> <td> Do not compare objects of a class that may contain padding bits with C standard library functions </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C++: EXP62-CPP </a> </td> <td> Checks for access attempts on padding and vtable bits (rule fully covered). </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong>V598<a></a></strong> , <strong><a>V780</a>, </strong> <strong>V1084<a></a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabil) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&amp;query=FIELD+KEYWORDS+contains+EXP62-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> OOP57-CPP. Prefer special member functions and overloaded operators to C Standard Library functions </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.9, "Types" Subclause 3.10, "Lvalues and Rvalues" Clause 9, "Classes" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [EXP62-CPP: Do not access the bits of an object representation that are not part of the object's value representation](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
