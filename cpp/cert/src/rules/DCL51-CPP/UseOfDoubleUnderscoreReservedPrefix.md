# DCL51-CPP: Name uses reserved prefix

This query implements the CERT-C++ rule DCL51-CPP:

> Do not declare or define a reserved identifier


## Description

The C++ Standard, \[reserved.names\] \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], specifies the following rules regarding reserved names:

> 


* A translation unit that includes a standard library header shall not `#define` or `#undef` names declared in any standard library header.
* A translation unit shall not `#define` or `#undef` names lexically identical to keywords, to the identifiers listed in Table 3, or to the *attribute-token*s described in 7.6.
* Each name that contains a double underscore `__` or begins with an underscore followed by an uppercase letter is reserved to the implementation for any use.
* Each name that begins with an underscore is reserved to the implementation for use as a name in the global namespace.
* Each name declared as an object with external linkage in a header is reserved to the implementation to designate that library object with external linkage, both in namespace `std` and in the global namespace.
* Each global function signature declared with external linkage in a header is reserved to the implementation to designate that function signature with external linkage.
* Each name from the Standard C library declared with external linkage is reserved to the implementation for use as a name with `extern "C"` linkage, both in namespace `std` and in the global namespace.
* Each function signature from the Standard C library declared with external linkage is reserved to the implementation for use as a function signature with both `extern "C"` and `extern "C++"` linkage, or as a name of namespace scope in the global namespace.
* For each type `T` from the Standard C library, the types `::T` and `std::T` are reserved to the implementation and, when defined, `::T` shall be identical to `std::T`.
* Literal suffix identifiers that do not start with an underscore are reserved for future standardization.
The identifiers and attribute names referred to in the preceding excerpt are `override`, `final`, `alignas`, `carries_dependency`, `deprecated`, and `noreturn`.

No other identifiers are reserved. Declaring or defining an identifier in a context in which it is reserved results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). Do not declare or define a reserved identifier.

## Noncompliant Code Example (Header Guard)

A common practice is to use a macro in a preprocessor conditional that guards against multiple inclusions of a header file. While this is a recommended practice, many programs use reserved names as the header guards. Such a name may clash with reserved names defined by the implementation of the C++ standard template library in its headers or with reserved names implicitly predefined by the compiler even when no C++ standard library header is included.

```cpp
#ifndef _MY_HEADER_H_
#define _MY_HEADER_H_

// Contents of <my_header.h>

#endif // _MY_HEADER_H_

```

## Compliant Solution (Header Guard)

This compliant solution avoids using leading or trailing underscores in the name of the header guard.

```cpp
#ifndef MY_HEADER_H
#define MY_HEADER_H

// Contents of <my_header.h>

#endif // MY_HEADER_H

```

## Noncompliant Code Example (User-Defined Literal)

In this noncompliant code example, a user-defined literal operator"" x is declared. However, literal suffix identifiers are required to start with an underscore; literal suffixes without the underscore prefix are reserved for future library implementations.

```cpp
#include <cstddef>
 
unsigned int operator"" x(const char *, std::size_t);
```

## Compliant Solution (User-Defined Literal)

In this compliant solution, the user-defined literal is named `operator"" _x`, which is not a reserved identifier.

```cpp
#include <cstddef>
 
unsigned int operator"" _x(const char *, std::size_t);
```
The name of the user-defined literal is `operator"" _x` and not `_x`, which would have otherwise been reserved for the global namespace.

## Noncompliant Code Example (File Scope Objects)

In this noncompliant code example, the names of the file scope objects `_max_limit` and `_limit` both begin with an underscore. Because it is `static`, the declaration of `_max_limit` might seem to be impervious to clashes with names defined by the implementation. However, because the header `<cstddef>` is included to define `std::size_t`, a potential for a name clash exists. (Note, however, that a conforming compiler may implicitly declare reserved names regardless of whether any C++ standard template library header has been explicitly included.) In addition, because `_limit` has external linkage, it may clash with a symbol with the same name defined in the language runtime library even if such a symbol is not declared in any header. Consequently, it is unsafe to start the name of any file scope identifier with an underscore even if its linkage limits its visibility to a single translation unit.

```cpp
#include <cstddef> // std::for size_t

static const std::size_t _max_limit = 1024;
std::size_t _limit = 100;

unsigned int get_value(unsigned int count) {
  return count < _limit ? count : _limit;
}

```

## Compliant Solution (File Scope Objects)

In this compliant solution, file scope identifiers do not begin with an underscore.

```cpp
#include <cstddef> // for size_t

static const std::size_t max_limit = 1024;
std::size_t limit = 100;

unsigned int get_value(unsigned int count) {
  return count < limit ? count : limit;
}

```

## Noncompliant Code Example (Reserved Macros)

In this noncompliant code example, because the C++ standard template library header `<cinttypes>` is specified to include `<cstdint>`, as per \[c.files\] paragraph 4 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], the name `MAX_SIZE` conflicts with the name of the `<cstdint>` header macro used to denote the upper limit of `std:size_t.`

```cpp
#include <cinttypes> // for int_fast16_t

void f(std::int_fast16_t val) {
  enum { MAX_SIZE = 80 };
  // ...
}

```

## Compliant Solution (Reserved Macros)

This compliant solution avoids redefining reserved names.

```cpp
#include <cinttypes> // for std::int_fast16_t

void f(std::int_fast16_t val) {
  enum { BufferSize = 80 };
  // ...
}
```

## Exceptions

**DCL51-CPP-EX1:** For compatibility with other compiler vendors or language standard modes, it is acceptable to create a macro identifier that is the same as a reserved identifier so long as the behavior is semantically identical, as in this example.

```cpp
// Sometimes generated by configuration tools such as autoconf
#define const const
 
// Allowed compilers with semantically equivalent extension behavior
#define inline __inline
```
**DCL51-CPP-EX2:** As a compiler vendor or standard library developer, it is acceptable to use identifiers reserved for your implementation. Reserved identifiers may be defined by the compiler, in standard library headers, or in headers included by a standard library header, as in this example declaration from the [libc++](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-libcxx) STL implementation.

```cpp
// The following declaration of a reserved identifier exists in the libc++ implementation of
// std::basic_string as a public member. The original source code may be found at:
// http://llvm.org/svn/llvm-project/libcxx/trunk/include/string
 
template<class charT, class traits = char_traits<charT>, class Allocator = allocator<charT>>
class basic_string {
  // ...
 
  bool __invariants() const;
};
```

## Risk Assessment

Using reserved identifiers can lead to incorrect program operation.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL51-CPP </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>reserved-identifier</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-DCL51</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>-Wreserved-id-macro</code> <code>-Wuser-defined-literals</code> </td> <td> The <code>-Wreserved-id-macro</code> flag is not enabled by default or with <code>-Wall</code> , but is enabled with <code>-Weverything</code> . This flag does not catch all instances of this rule, such as redefining reserved names. </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.ID.NU.MK</strong> <strong>LANG.STRUCT.DECL.RESERVED</strong> </td> <td> Macro name is C keyword Declaration of reserved name </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++5003</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>MISRA.DEFINE.WRONGNAME</strong> <strong>MISRA.DEFINE.WRONGNAME.UNDERSCORE</strong> <strong>MISRA.UNDEF.WRONGNAME</strong> <strong>MISRA.UNDEF.WRONGNAME.UNDERSCORE</strong> <strong>MISRA.STDLIB.WRONGNAME</strong> <strong>MISRA.STDLIB.WRONGNAME.UNDERSCORE</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>86 S, 218 S, 219 S, 580 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-DCL51-a</strong> <strong>CERT_CPP-DCL51-b</strong> <strong>CERT_CPP-DCL51-c</strong> <strong>CERT_CPP-DCL51-d</strong> <strong>CERT_CPP-DCL51-e</strong> <strong>CERT_CPP-DCL51-f</strong> </td> <td> Do not \#define or \#undef identifiers with names which start with underscore Do not redefine reserved words Do not \#define nor \#undef identifier 'defined' The names of standard library macros, objects and functions shall not be reused The names of standard library macros, objects and functions shall not be reused (C90) The names of standard library macros, objects and functions shall not be reused (C99) </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: DCL51-CPP </a> </td> <td> Checks for redefinitions of reserved identifiers (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>5003</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong><a>V1059</a></strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 20.10 </td> <td> <strong>reserved-identifier</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 4.10 </td> <td> <strong><a>978</a></strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerabilit) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+DCL32-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> DCL58-CPP. Do not modify the standard namespaces </a> </td> </tr> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> DCL37-C. Do not declare or define a reserved identifier </a> <a> PRE06-C. Enclose header files in an include guard </a> </td> </tr> <tr> <td> <a> MISRA C++:2008 </a> </td> <td> Rule 17-0-1 </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 17.6.4.3, "Reserved Names" </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.1.3, "Reserved Identifiers" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [DCL51-CPP: Do not declare or define a reserved identifier](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
