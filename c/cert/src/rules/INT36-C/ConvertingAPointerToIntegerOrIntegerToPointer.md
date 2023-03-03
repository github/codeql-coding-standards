# INT36-C: Do not convert pointers to integers and back

This query implements the CERT-C rule INT36-C:

> Converting a pointer to integer or integer to pointer


## Description

Although programmers often use integers and pointers interchangeably in C, pointer-to-integer and integer-to-pointer conversions are [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior).

Conversions between integers and pointers can have undesired consequences depending on the [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation). According to the C Standard, subclause 6.3.2.3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\],

> An integer may be converted to any pointer type. Except as previously specified, the result is implementation-defined, might not be correctly aligned, might not point to an entity of the referenced type, and might be a trap representation.


> Any pointer type may be converted to an integer type. Except as previously specified, the result is implementation-defined. If the result cannot be represented in the integer type, the behavior is undefined. The result need not be in the range of values of any integer type.


Do not convert an integer type to a pointer type if the resulting pointer is incorrectly aligned, does not point to an entity of the referenced type, or is a [trap representation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-traprepresentation).

Do not convert a pointer type to an integer type if the result cannot be represented in the integer type. (See [undefined behavior 24](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_24).)

The mapping between pointers and integers must be consistent with the addressing structure of the execution environment. Issues may arise, for example, on architectures that have a segmented memory model.

## Noncompliant Code Example

The size of a pointer can be greater than the size of an integer, such as in an implementation where pointers are 64 bits and unsigned integers are 32 bits. This code example is noncompliant on such implementations because the result of converting the 64-bit `ptr` cannot be represented in the 32-bit integer type:

```cpp
void f(void) {
  char *ptr;
  /* ... */
  unsigned int number = (unsigned int)ptr;
  /* ... */
}

```

## Compliant Solution

Any valid pointer to `void` can be converted to `intptr_t` or `uintptr_t` and back with no change in value. (See **INT36-EX2**.) The C Standard guarantees that a pointer to `void` may be converted to or from a pointer to any object type and back again and that the result must compare equal to the original pointer. Consequently, converting directly from a `char *` pointer to a `uintptr_t`, as in this compliant solution, is allowed on implementations that support the `uintptr_t` type.

```cpp
#include <stdint.h>
 
void f(void) {
  char *ptr;
  /* ... */
  uintptr_t number = (uintptr_t)ptr;  
  /* ... */
}

```

## Noncompliant Code Example

In this noncompliant code example, the pointer `ptr` is converted to an integer value. The high-order 9 bits of the number are used to hold a flag value, and the result is converted back into a pointer. This example is noncompliant on an implementation where pointers are 64 bits and unsigned integers are 32 bits because the result of converting the 64-bit `ptr` cannot be represented in the 32-bit integer type.

```cpp
void func(unsigned int flag) {
  char *ptr;
  /* ... */
  unsigned int number = (unsigned int)ptr;
  number = (number & 0x7fffff) | (flag << 23);
  ptr = (char *)number;
}

```
A similar scheme was used in early versions of Emacs, limiting its portability and preventing the ability to edit files larger than 8MB.

## Compliant Solution

This compliant solution uses a `struct` to provide storage for both the pointer and the flag value. This solution is portable to machines of different word sizes, both smaller and larger than 32 bits, working even when pointers cannot be represented in any integer type.

```cpp
struct ptrflag {
  char *pointer;
  unsigned int flag : 9;
} ptrflag;
 
void func(unsigned int flag) {
  char *ptr;
  /* ... */
  ptrflag.pointer = ptr;
  ptrflag.flag = flag;
}

```

## Noncompliant Code Example

It is sometimes necessary to access memory at a specific location, requiring a literal integer to pointer conversion. In this noncompliant code, a pointer is set directly to an integer constant, where it is unknown whether the result will be as intended:

```cpp
unsigned int *g(void) {
  unsigned int *ptr = 0xdeadbeef;
  /* ... */
  return ptr;
} 
```
The result of this assignment is [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior), might not be correctly aligned, might not point to an entity of the referenced type, and might be a [trap representation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-traprepresentation).

## Compliant Solution

Unfortunately this code cannot be made safe while strictly conforming to ISO C.

A particular platform (that is, hardware, operating system, compiler, and Standard C library) might guarantee that a memory address is correctly aligned for the pointer type, and actually contains a value for that type. A common practice is to use addresses that are known to point to hardware that provides valid values.

## Exceptions

**INT36-C-EX1:** The integer value 0 can be converted to a pointer; it becomes the null pointer.

**INT36-C-EX2:** Any valid pointer to `void` can be converted to `intptr_t` or `uintptr_t` or their underlying types and back again with no change in value. Use of underlying types instead of `intptr_t` or `uintptr_t` is discouraged, however, because it limits portability.

```cpp
#include <assert.h>
#include <stdint.h>
 
void h(void) {
  intptr_t i = (intptr_t)(void *)&i;
  uintptr_t j = (uintptr_t)(void *)&j;
 
  void *ip = (void *)i;
  void *jp = (void *)j;
 
  assert(ip == &i);
  assert(jp == &j);
}

```

## Risk Assessment

Converting from pointer to integer or vice versa results in code that is not portable and may create unexpected pointers to invalid memory locations.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> INT36-C </td> <td> Low </td> <td> Probable </td> <td> High </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>pointer-integral-cast</strong> <strong>pointer-integral-cast-implicit</strong> <strong>function-pointer-integer-cast</strong> <strong> function-pointer-integer-cast-implicit</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-INT36</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wint-to-pointer-cast</code> , <code>-Wint-conversion</code> </td> <td> Can detect some instances of this rule, but does not detect all </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.CAST.PC.CONST2PTRLANG.CAST.PC.INT</strong> </td> <td> Conversion: integer constant to pointer Conversion: pointer/integer </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>PW.POINTER_CONVERSION_LOSES_BITS</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C0303, C0305, C0306, C0309, C0324, C0326, C0360, C0361, C0362</strong> <strong>C++3040, C++3041, C++3042, C++3043, C++3044, C++3045, C++3046, C++3047, C++3048</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.CAST.OBJ_PTR_TO_INT.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>439 S, 440 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-INT36-b</strong> </td> <td> A conversion should not be performed between a pointer to object type and an integer type other than 'uintptr_t' or 'intptr_t' </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>4287</strong> </td> <td> Partially supported: reports casts from pointer types to smaller integer types which lose information </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule INT36-C </a> </td> <td> Checks for unsafe conversion between pointer and integer (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>0303, 0305, 0306, 0309, 0324, </strong> <strong>0326, 0360, 0361, 0362</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>3040, 3041, 3042, 3043, 3044, </strong> <strong>3045, 3046, 3047, 3048</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.23 </td> <td> <strong><a>V527</a></strong> , <strong><a>V528</a></strong> , <strong>V542<a></a></strong> , <strong>V566<a></a></strong> , <strong><a>V601</a></strong> , <strong><a>V647</a></strong> <a> , </a> <strong> <a>V1091</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>pointer-integral-cast</strong> <strong>pointer-integral-cast-implicit</strong> <strong>function-pointer-integer-cast</strong> <strong> function-pointer-integer-cast-implicit</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S1767</a></strong> </td> <td> Partially implemented </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+INT36-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> INT11-CPP. Take care when converting from pointer to integer or integer to pointer </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Pointer Casting and Pointer Type Changes \[HFC\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Converting a pointer to integer or integer to pointer \[intptrconv\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-587 </a> , Assignment of a Fixed Address to a Pointer </td> <td> 2017-07-07: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-704 </a> </td> <td> 2017-06-14: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-758 </a> </td> <td> 2017-07-07: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 3.1 </a> </td> <td> <a> CWE-119 </a> , Improper Restriction of Operations within the Bounds of a Memory Buffer </td> <td> 2018-10-19:CERT:None </td> </tr> <tr> <td> <a> CWE 3.1 </a> </td> <td> <a> CWE-466 </a> , Return of Pointer Value Outside of Expected Range </td> <td> 2018-10-19:CERT:None </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-758 and INT36-C**

Independent( INT34-C, INT36-C, MEM30-C, MSC37-C, FLP32-C, EXP33-C, EXP30-C, ERR34-C, ARR32-C)

CWE-758 = Union( INT36-C, list) where list =

* Undefined behavior that results from anything other than integer &lt;-&gt; pointer conversion
**CWE-704 and INT36-C**

CWE-704 = Union( INT36-C, list) where list =

* Incorrect (?) typecast that is not between integers and pointers
**CWE-587 and INT36-C**

Intersection( CWE-587, INT36-C) =

* Setting a pointer to an integer value that is ill-defined (trap representation, improperly aligned, mis-typed, etc)
CWE-587 – INT36-C =
* Setting a pointer to a valid integer value (eg points to an object of the correct t ype)
INT36-C – CWE-587 =
* Illegal pointer-to-integer conversion
Intersection(INT36-C,CWE-466) = ∅

Intersection(INT36-C,CWE-466) = ∅

An example explaining the above two equations follows:

`static char x[3];`

`char* foo() {`

` int x_int = (int) x; // x_int = 999 eg`

` return x_int + 5; // returns 1004 , violates CWE 466`

`}`

`...`

`int y_int = foo(); // violates CWE-466`

`char* y = (char*) y_int; // // well-defined but y may be invalid, violates INT36-C`

`char c = *y; // indeterminate value, out-of-bounds read, violates CWE-119`

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.3.2.3, "Pointers" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [INT36-C: Converting a pointer to integer or integer to pointer](https://wiki.sei.cmu.edu/confluence/display/c)
