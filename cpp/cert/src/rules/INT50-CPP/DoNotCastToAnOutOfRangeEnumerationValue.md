# INT50-CPP: Do not cast to an out-of-range enumeration value

This query implements the CERT-C++ rule INT50-CPP:

> Do not cast to an out-of-range enumeration value


## Description

Enumerations in C++ come in two forms: *scoped* enumerations in which the underlying type is fixed and *unscoped* enumerations in which the underlying type may or may not be fixed. The range of values that can be represented by either form of enumeration may include enumerator values not specified by the enumeration itself. The range of valid enumeration values for an enumeration type is defined by the C++ Standard, \[dcl.enum\], in paragraph 8 \[[ISO/IEC 14882-2020](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2020)\]:

> For an enumeration whose underlying type is fixed, the values of the enumeration are the values of the underlying type. Otherwise, the values of the enumeration are the values representable by a hypothetical integer type with minimal width M such that all enumerators can be represented. The width of the smallest bit-field large enough to hold all the values of the enumeration type is M. It is possible to define an enumeration that has values not defined by any of its enumerators. If the enumerator-list is empty, the values of the enumeration are as if the enumeration had a single enumerator with value 0.


The C++ Standard, \[expr.static.cast\], paragraph 10, states the following:

> A value of integral or enumeration type can be explicitly converted to a complete enumeration type. If the enumeration type has a fixed underlying type, the value is first converted to that type by integral conversion, if necessary, and then to the enumeration type. If the enumeration type does not have a fixed underlying type, the value is unchanged if the original value is within the range of the enumeration values (9.7.1), and otherwise, the behavior is undefined. A value of floating-point type can also be explicitly converted to an enumeration type. The resulting value is the same as converting the original value to the underlying type of the enumeration (7.3.10), and subsequently to the enumeration type.


To avoid operating on [unspecified values](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedvalue), the arithmetic value being cast must be within the range of values the enumeration can represent. When dynamically checking for out-of-range values, checking must be performed before the cast expression.

## Noncompliant Code Example (Bounds Checking)

This noncompliant code example attempts to check whether a given value is within the range of acceptable enumeration values. However, it is doing so after casting to the enumeration type, which may not be able to represent the given integer value. On a two's complement system, the valid range of values that can be represented by `EnumType` are \[0..3\], so if a value outside of that range were passed to `f()`, the cast to `EnumType` would result in an unspecified value, and using that value within the `if` statement results in [unspecified behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-unspecifiedbehavior).

```cpp
enum EnumType {
  First,
  Second,
  Third
};

void f(int intVar) {
  EnumType enumVar = static_cast<EnumType>(intVar);

  if (enumVar < First || enumVar > Third) {
    // Handle error
  }
}
```

## Compliant Solution (Bounds Checking)

This compliant solution checks that the value can be represented by the enumeration type before performing the conversion to guarantee the conversion does not result in an unspecified value. It does this by restricting the converted value to one for which there is a specific enumerator value.

```cpp
enum EnumType {
  First,
  Second,
  Third
};

void f(int intVar) {
  if (intVar < First || intVar > Third) {
    // Handle error
  }
  EnumType enumVar = static_cast<EnumType>(intVar);
}

```

## Compliant Solution (Scoped Enumeration)

This compliant solution uses a scoped enumeration, which has a fixed underlying `int` type by default, allowing any value from the parameter to be converted into a valid enumeration value. It does not restrict the converted value to one for which there is a specific enumerator value, but it could do so as shown in the previous compliant solution.

```cpp
enum class EnumType {
  First,
  Second,
  Third
};

void f(int intVar) {
  EnumType enumVar = static_cast<EnumType>(intVar);
}
```

## Compliant Solution (Fixed Unscoped Enumeration)

Similar to the previous compliant solution, this compliant solution uses an unscoped enumeration but provides a fixed underlying `int` type allowing any value from the parameter to be converted to a valid enumeration value.

```cpp
enum EnumType : int {
  First,
  Second,
  Third
};

void f(int intVar) {
  EnumType enumVar = static_cast<EnumType>(intVar);
}
```
Although similar to the previous compliant solution, this compliant solution differs from the noncompliant code example in the way the enumerator values are expressed in code and which implicit conversions are allowed. The previous compliant solution requires a nested name specifier to identify the enumerator (for example, `EnumType::First`) and will not implicitly convert the enumerator value to `int`. As with the noncompliant code example, this compliant solution does not allow a nested name specifier and will implicitly convert the enumerator value to `int`.

## Risk Assessment

It is possible for unspecified values to result in a buffer overflow, leading to the execution of arbitrary code by an attacker. However, because enumerators are rarely used for indexing into arrays or other forms of pointer arithmetic, it is more likely that this scenario will result in data integrity violations rather than arbitrary code execution.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> INT50-CPP </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-INT50</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.CAST.COERCE</strong> <strong>LANG.CAST.VALUE</strong> </td> <td> Coercion Alters Value Cast Alters Value </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++3013</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-INT50-a</strong> </td> <td> An expression with enum underlying type shall only have values corresponding to the enumerators of the enumeration </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3013</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V1016</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabilty) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+INT50-CPP).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Becker 2009 </a> \] </td> <td> Section 7.2, "Enumeration Declarations" </td> </tr> <tr> <td> \[ <a> ISO/IEC 14882-2020 </a> \] </td> <td> Subclause 5.2.9, "Static Cast" Subclause 7.2, "Enumeration Declarations" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [INT50-CPP: Do not cast to an out-of-range enumeration value](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
