# MEM50-CPP: Do not access freed memory

This query implements the CERT-C++ rule MEM50-CPP:

> Do not access freed memory


## Description

Evaluating a pointer—including dereferencing the pointer, using it as an operand of an arithmetic operation, type casting it, and using it as the right-hand side of an assignment—into memory that has been deallocated by a memory management function is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior). Pointers to memory that has been deallocated are called *dangling pointers*. Accessing a dangling pointer can result in exploitable [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability).

It is at the memory manager's discretion when to reallocate or recycle the freed memory. When memory is freed, all pointers into it become invalid, and its contents might either be returned to the operating system, making the freed space inaccessible, or remain intact and accessible. As a result, the data at the freed location can appear to be valid but change unexpectedly. Consequently, memory must not be written to or read from once it is freed.

## Noncompliant Code Example (new and delete)

In this noncompliant code example, `s` is dereferenced after it has been deallocated. If this access results in a write-after-free, the [vulnerability](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) can be [exploited](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-exploit) to run arbitrary code with the permissions of the vulnerable process. Typically, dynamic memory allocations and deallocations are far removed, making it difficult to recognize and diagnose such problems.

```cpp
#include <new>
 
struct S {
  void f();
};
 
void g() noexcept(false) {
  S *s = new S;
  // ...
  delete s;
  // ...
  s->f();
}

```
The function `g()` is marked `noexcept(false)` to comply with [MEM52-CPP. Detect and handle memory allocation errors](https://wiki.sei.cmu.edu/confluence/display/cplusplus/MEM52-CPP.+Detect+and+handle+memory+allocation+errors).

## Compliant Solution (new and delete)

In this compliant solution, the dynamically allocated memory is not deallocated until it is no longer required.

```cpp
#include <new>

struct S {
  void f();
};

void g() noexcept(false) {
  S *s = new S;
  // ...
  s->f();
  delete s;
}
```

## Compliant Solution (Automatic Storage Duration)

When possible, use automatic storage duration instead of dynamic storage duration. Since `s` is not required to live beyond the scope of `g()`, this compliant solution uses automatic storage duration to limit the lifetime of `s` to the scope of `g().`

```cpp
struct S {
  void f();
};

void g() {
  S s;
  // ...
  s.f();
}
```

## Noncompliant Code Example (std::unique_ptr)

In the following noncompliant code example, the dynamically allocated memory managed by the `buff` object is accessed after it has been implicitly deallocated by the object's destructor.

```cpp
#include <iostream>
#include <memory>
#include <cstring>
 
int main(int argc, const char *argv[]) {
  const char *s = "";
  if (argc > 1) {
    enum { BufferSize = 32 };
    try {
      std::unique_ptr<char[]> buff(new char[BufferSize]);
      std::memset(buff.get(), 0, BufferSize);
      // ...
      s = std::strncpy(buff.get(), argv[1], BufferSize - 1);
    } catch (std::bad_alloc &) {
      // Handle error
    }
  }

  std::cout << s << std::endl;
}

```
This code always creates a null-terminated byte string, despite its use of `strncpy()`, because it leaves the final `char` in the buffer set to 0.

## Compliant Solution (std::unique_ptr)

In this compliant solution, the lifetime of the `buff` object extends past the point at which the memory managed by the object is accessed.

```cpp
#include <iostream>
#include <memory>
#include <cstring>
 
int main(int argc, const char *argv[]) {
  std::unique_ptr<char[]> buff;
  const char *s = "";

  if (argc > 1) {
    enum { BufferSize = 32 };
    try {
      buff.reset(new char[BufferSize]);
      std::memset(buff.get(), 0, BufferSize);
      // ...
      s = std::strncpy(buff.get(), argv[1], BufferSize - 1);
    } catch (std::bad_alloc &) {
      // Handle error
    }
  }

  std::cout << s << std::endl;
}

```

## Compliant Solution

In this compliant solution, a variable with automatic storage duration of type `std::string` is used in place of the `std::unique_ptr<char[]>`, which reduces the complexity and improves the security of the solution.

```cpp
#include <iostream>
#include <string>
 
int main(int argc, const char *argv[]) {
  std::string str;

  if (argc > 1) {
    str = argv[1];
  }

  std::cout << str << std::endl;
}
```

## Noncompliant Code Example (std::string::c_str())

In this noncompliant code example, `std::string::c_str()` is being called on a temporary `std::string` object. The resulting pointer will point to released memory once the `std::string` object is destroyed at the end of the assignment expression, resulting in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior) when accessing elements of that pointer.

```cpp
#include <string>
 
std::string str_func();
void display_string(const char *);
 
void f() {
  const char *str = str_func().c_str();
  display_string(str);  /* Undefined behavior */
}
```

## Compliant solution (std::string::c_str())

In this compliant solution, a local copy of the string returned by `str_func()` is made to ensure that string `str` will be valid when the call to `display_string()` is made.

```cpp
#include <string>
 
std::string str_func();
void display_string(const char *s);

void f() {
  std::string str = str_func();
  const char *cstr = str.c_str();
  display_string(cstr);  /* ok */
}
```

## Noncompliant Code Example

In this noncompliant code example, an attempt is made to allocate zero bytes of memory through a call to `operator new()`. If this request succeeds, `operator new()` is required to return a non-null pointer value. However, according to the C++ Standard, \[basic.stc.dynamic.allocation\], paragraph 2 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], attempting to dereference memory through such a pointer results in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <new>

void f() noexcept(false) {
  unsigned char *ptr = static_cast<unsigned char *>(::operator new(0));
  *ptr = 0;
  // ...
  ::operator delete(ptr);
}
```

## Compliant Solution

The compliant solution depends on programmer intent. If the programmer intends to allocate a single `unsigned char` object, the compliant solution is to use `new` instead of a direct call to `operator new()`, as this compliant solution demonstrates.

```cpp
void f() noexcept(false) {
  unsigned char *ptr = new unsigned char;
  *ptr = 0;
  // ...
  delete ptr;
}
```

## Compliant Solution

If the programmer intends to allocate zero bytes of memory (perhaps to obtain a unique pointer value that cannot be reused by any other pointer in the program until it is properly released), then instead of attempting to dereference the resulting pointer, the recommended solution is to declare `ptr` as a `void *`, which cannot be dereferenced by a [conforming](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-conformingprogram) [implementation](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-implementation).

```cpp
#include <new>

void f() noexcept(false) {
  void *ptr = ::operator new(0);
  // ...
  ::operator delete(ptr);
}
```

## Risk Assessment

Reading previously dynamically allocated memory after it has been deallocated can lead to [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-abnormaltermination) and [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-denial-of-service). Writing memory that has been deallocated can lead to the execution of arbitrary code with the permissions of the vulnerable process.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM50-CPP </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 20.10 </td> <td> <strong>dangling_pointer_use</strong> </td> <td> </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-MEM50</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>clang-analyzer-cplusplus.NewDeleteclang-analyzer-alpha.security.ArrayBoundV2 </code> </td> <td> Checked by <code>clang-tidy</code> , but does not catch all violations of this rule. </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>ALLOC.UAF</strong> </td> <td> Use after free </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> v7.5.0 </td> <td> <strong>USE_AFTER_FREE</strong> </td> <td> Can detect the specific instances where memory is deallocated more than once or read/written to the target of a freed pointer </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4303, C++4304</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>UFM.DEREF.MIGHT</strong> <strong>UFM.DEREF.MUST</strong> <strong>UFM.FFM.MIGHT</strong> <strong>UFM.FFM.MUST</strong> <strong>UFM.RETURN.MIGHT</strong> <strong>UFM.RETURN.MUST</strong> <strong>UFM.USE.MIGHT</strong> <strong>UFM.USE.MUST </strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> </td> <td> <strong>483 S, 484 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-MEM50-a</strong> </td> <td> Do not use resources that have been freed </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime detection </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C++: MEM50-CPP </a> </td> <td> Checks for: Pointer access out of boundsointer access out of bounds, deallocation of previously deallocated pointereallocation of previously deallocated pointer, use of previously freed pointerse of previously freed pointer. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4303, 4304 </strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.19 </td> <td> <strong>V586<a></a></strong> , <strong><a>V774</a></strong> </td> <td> </td> </tr> <tr> <td> <a> Splint </a> </td> <td> </td> <td> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

VU\#623332 describes a double-free vulnerability in the MIT Kerberos 5 function [krb5_recvauth()](http://web.mit.edu/kerberos/www/advisories/MITKRB5-SA-2005-003-recvauth.txt) \[[VU\# 623332](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-VU623332)\].

Search for other [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM30-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C++ Coding Standard </a> </td> <td> <a> EXP54-CPP. Do not access an object outside of its lifetime </a> <a> MEM52-CPP. Detect and handle memory allocation errors </a> </td> </tr> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> MEM30-C. Do not access freed memory </a> </td> </tr> <tr> <td> <a> MITRE CWE </a> </td> <td> <a> CWE-415 </a> , Double Free <a> CWE-416 </a> , Use After Free </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 3.7.4.1, "Allocation Functions" Subclause 3.7.4.2, "Deallocation Functions" </td> </tr> <tr> <td> \[ <a> Seacord 2013b </a> \] </td> <td> Chapter 4, "Dynamic Memory Management" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C++: [MEM50-CPP: Do not access freed memory](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
