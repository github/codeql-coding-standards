# DCL55-CPP: Avoid information leakage when passing a class object across a trust boundary

This query implements the CERT-C++ rule DCL55-CPP:

> Avoid information leakage when passing a class object across a trust boundary


## Description

The C++ Standard, \[class.mem\], paragraph 13 \[[ISO/IEC 14882-2014](https://wiki.sei.cmu.edu/confluence/display/cplusplus/AA.+Bibliography#AA.Bibliography-ISO%2FIEC14882-2014)\], describes the layout of non-static data members of a non-union class, specifying the following:

> Nonstatic data members of a (non-union) class with the same access control are allocated so that later members have higher addresses within a class object. The order of allocation of non-static data members with different access control is unspecified. Implementation alignment requirements might cause two adjacent members not to be allocated immediately after each other; so might requirements for space for managing virtual functions and virtual base classes.


Further, \[class.bit\], paragraph 1, in part, states the following:

> Allocation of bit-fields within a class object is implementation-defined. Alignment of bit-fields is implementation-defined. Bit-fields are packed into some addressable allocation unit.


Thus, padding bits may be present at any location within a class object instance (including at the beginning of the object, in the case of an unnamed bit-field as the first member declared in a class). Unless initialized by zero-initialization, padding bits contain [indeterminate values](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-indeterminatevalue) that may contain sensitive information.

When passing a pointer to a class object instance across a [trust boundary](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-trustboundary) to a different trusted domain, the programmer must ensure that the padding bits of such an object do not contain sensitive information.

## Noncompliant Code Example

This noncompliant code example runs in kernel space and copies data from `arg` to user space. However, padding bits may be used within the object, for example, to ensure the proper alignment of class data members. These padding bits may contain sensitive information that may then be leaked when the data is copied to user space, regardless of how the data is copied.

```cpp
#include <cstddef>
 
struct test {
  int a;
  char b;
  int c;
};
 
// Safely copy bytes to user space
extern int copy_to_user(void *dest, void *src, std::size_t size);
 
void do_stuff(void *usr_buf) {
  test arg{1, 2, 3};
  copy_to_user(usr_buf, &arg, sizeof(arg));
}
```

## Noncompliant Code Example

In this noncompliant code example, `arg` is value-initialized through direct initialization. Because `test` does not have a user-provided default constructor, the value-initialization is preceded by a zero-initialization that guarantees the padding bits are initialized to `0` before any further initialization occurs. It is akin to using `std::memset()` to initialize all of the bits in the object to `0`.

```cpp
#include <cstddef>
 
struct test {
  int a;
  char b;
  int c;
};
 
// Safely copy bytes to user space
extern int copy_to_user(void *dest, void *src, std::size_t size);
 
void do_stuff(void *usr_buf) {
  test arg{};
 
  arg.a = 1;
  arg.b = 2;
  arg.c = 3;
 
  copy_to_user(usr_buf, &arg, sizeof(arg));
}
```
However, compilers are free to implement `arg.b = 2` by setting the low byte of a 32-bit register to `2`, leaving the high bytes unchanged, and storing all 32 bits of the register into memory. This could leak the high-order bytes resident in the register to a user.

## Compliant Solution

This compliant solution serializes the structure data before copying it to an untrusted context.

```cpp
#include <cstddef>
#include <cstring>
 
struct test {
  int a;
  char b;
  int c;
};
 
// Safely copy bytes to user space.
extern int copy_to_user(void *dest, void *src, std::size_t size);
 
void do_stuff(void *usr_buf) {
  test arg{1, 2, 3};
  // May be larger than strictly needed.
  unsigned char buf[sizeof(arg)];
  std::size_t offset = 0;
 
  std::memcpy(buf + offset, &arg.a, sizeof(arg.a));
  offset += sizeof(arg.a);
  std::memcpy(buf + offset, &arg.b, sizeof(arg.b));
  offset += sizeof(arg.b);
  std::memcpy(buf + offset, &arg.c, sizeof(arg.c));
  offset += sizeof(arg.c);
 
  copy_to_user(usr_buf, buf, offset /* size of info copied */);
}
```
This code ensures that no uninitialized padding bits are copied to unprivileged users. The structure copied to user space is now a packed structure and the `copy_to_user()` function would need to unpack it to recreate the original, padded structure.

## Compliant Solution (Padding Bytes)

Padding bits can be explicitly declared as fields within the structure. This solution is not portable, however, because it depends on the implementation and target memory architecture. The following solution is specific to the x86-32 architecture.

```cpp
#include <cstddef>

struct test {
  int a;
  char b;
  char padding_1, padding_2, padding_3;
  int c;
 
  test(int a, char b, int c) : a(a), b(b),
    padding_1(0), padding_2(0), padding_3(0),
    c(c) {}
};
// Ensure c is the next byte after the last padding byte.
static_assert(offsetof(test, c) == offsetof(test, padding_3) + 1,
              "Object contains intermediate padding");
// Ensure there is no trailing padding.
static_assert(sizeof(test) == offsetof(test, c) + sizeof(int),
              "Object contains trailing padding");



// Safely copy bytes to user space.
extern int copy_to_user(void *dest, void *src, std::size_t size);

void do_stuff(void *usr_buf) {
  test arg{1, 2, 3};
  copy_to_user(usr_buf, &arg, sizeof(arg));
}
```
The `static_assert()` declaration accepts a constant expression and an [error message](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-error). The expression is evaluated at compile time and, if false, the compilation is terminated and the error message is used as the diagnostic. The explicit insertion of the padding bytes into the `struct` should ensure that no additional padding bytes are added by the compiler, and consequently both static assertions should be true. However, it is necessary to validate these assumptions to ensure that the solution is correct for a particular implementation.

## Noncompliant Code Example

In this noncompliant code example, padding bits may abound, including

* alignment padding bits after a virtual method table or virtual base class data to align a subsequent data member,
* alignment padding bits to position a subsequent data member on a properly aligned boundary,
* alignment padding bits to position data members of varying access control levels.
* bit-field padding bits when the sequential set of bit-fields does not fill an entire allocation unit,
* bit-field padding bits when two adjacent bit-fields are declared with different underlying types,
* padding bits when a bit-field is declared with a length greater than the number of bits in the underlying allocation unit, or
* padding bits to ensure a class instance will be appropriately aligned for use within an array.
This code example runs in kernel space and copies data from `arg` to user space. However, the padding bits within the object instance may contain sensitive information that will then be leaked when the data is copied to user space.

```cpp
#include <cstddef>

class base {
public:
  virtual ~base() = default;
};

class test : public virtual base {
  alignas(32) double h;
  char i;
  unsigned j : 80;
protected:
  unsigned k;
  unsigned l : 4;
  unsigned short m : 3;
public:
  char n;
  double o;
  
  test(double h, char i, unsigned j, unsigned k, unsigned l, unsigned short m,
       char n, double o) :
    h(h), i(i), j(j), k(k), l(l), m(m), n(n), o(o) {}
  
  virtual void foo();
};

// Safely copy bytes to user space.
extern int copy_to_user(void *dest, void *src, std::size_t size);

void do_stuff(void *usr_buf) {
  test arg{0.0, 1, 2, 3, 4, 5, 6, 7.0};
  copy_to_user(usr_buf, &arg, sizeof(arg));
}
```
Padding bits are implementation-defined, so the layout of the class object may differ between compilers or architectures. When compiled with [GCC ](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-gcc)5.3.0 for x86-32, the `test` object requires 96 bytes of storage to accommodate 29 bytes of data (33 bytes including the vtable) and has the following layout.

<table> <tbody> <tr> <th> Offset (bytes (bits)) </th> <th> Storage Size (bytes (bits)) </th> <th> Reason </th> <th> </th> <th> Offset </th> <th> Storage Size </th> <th> Reason </th> </tr> <tr> <td> 0 </td> <td> 1 (32) </td> <td> vtable pointer </td> <td> </td> <td> 56 (448) </td> <td> 4 (32) </td> <td> <code>unsigned k</code> </td> </tr> <tr> <td> 4 (32) </td> <td> 28 (224) </td> <td> data member alignment padding </td> <td> </td> <td> 60 (480) </td> <td> 0 (4) </td> <td> <code>unsigned l : 4</code> </td> </tr> <tr> <td> 32 (256) </td> <td> 8 (64) </td> <td> <code>double h</code> </td> <td> </td> <td> 60 (484) </td> <td> 0 (3) </td> <td> <code>unsigned short m : 3</code> </td> </tr> <tr> <td> 40 (320) </td> <td> 1 (8) </td> <td> <code>char i</code> </td> <td> </td> <td> 60 (487) </td> <td> 0 (1) </td> <td> unused bit-field bits </td> </tr> <tr> <td> 41 (328) </td> <td> 3 (24) </td> <td> data member alignment padding </td> <td> </td> <td> 61 (488) </td> <td> 1 (8) </td> <td> <code>char n</code> </td> </tr> <tr> <td> 44 (352) </td> <td> 4 (32) </td> <td> <code>unsigned j : 80</code> </td> <td> </td> <td> 62 (496) </td> <td> 2 (16) </td> <td> data member alignment padding </td> </tr> <tr> <td> 48 (384) </td> <td> 6 (48) </td> <td> extended bit-field size padding </td> <td> </td> <td> 64 (512) </td> <td> 8 (64) </td> <td> <code>double o</code> </td> </tr> <tr> <td> 54 (432) </td> <td> 2 (16) </td> <td> alignment padding </td> <td> </td> <td> 72 (576) </td> <td> 24 (192) </td> <td> class alignment padding </td> </tr> </tbody> </table>


## Compliant Solution

Due to the complexity of the data structure, this compliant solution serializes the object data before copying it to an untrusted context instead of attempting to account for all of the padding bytes manually.

```cpp
#include <cstddef>
#include <cstring>
 
class base {
public:
  virtual ~base() = default;
};
class test : public virtual base {
  alignas(32) double h;
  char i;
  unsigned j : 80;
protected:
  unsigned k;
  unsigned l : 4;
  unsigned short m : 3;
public:
  char n;
  double o;
  
  test(double h, char i, unsigned j, unsigned k, unsigned l, unsigned short m,
       char n, double o) :
    h(h), i(i), j(j), k(k), l(l), m(m), n(n), o(o) {}
  
  virtual void foo();
  bool serialize(unsigned char *buffer, std::size_t &size) {
    if (size < sizeof(test)) {
      return false;
    }
    
    std::size_t offset = 0;
    std::memcpy(buffer + offset, &h, sizeof(h));
    offset += sizeof(h);
    std::memcpy(buffer + offset, &i, sizeof(i));
    offset += sizeof(i);
    unsigned loc_j = j; // Only sizeof(unsigned) bits are valid, so this is not narrowing.
    std::memcpy(buffer + offset, &loc_j, sizeof(loc_j));
    offset += sizeof(loc_j);
    std::memcpy(buffer + offset, &k, sizeof(k));
    offset += sizeof(k);
    unsigned char loc_l = l & 0b1111;
    std::memcpy(buffer + offset, &loc_l, sizeof(loc_l));
    offset += sizeof(loc_l);
    unsigned short loc_m = m & 0b111;
    std::memcpy(buffer + offset, &loc_m, sizeof(loc_m));
    offset += sizeof(loc_m);
    std::memcpy(buffer + offset, &n, sizeof(n));
    offset += sizeof(n);
    std::memcpy(buffer + offset, &o, sizeof(o));
    offset += sizeof(o);
    
    size -= offset;
    return true;
  }
};
 
// Safely copy bytes to user space.
extern int copy_to_user(void *dest, void *src, size_t size);
 
void do_stuff(void *usr_buf) {
  test arg{0.0, 1, 2, 3, 4, 5, 6, 7.0};
  
  // May be larger than strictly needed, will be updated by
  // calling serialize() to the size of the buffer remaining.
  std::size_t size = sizeof(arg);
  unsigned char buf[sizeof(arg)];
  if (arg.serialize(buf, size)) {
    copy_to_user(usr_buf, buf, sizeof(test) - size);
  } else {
    // Handle error
  }
}
```
This code ensures that no uninitialized padding bits are copied to unprivileged users. The structure copied to user space is now a packed structure and the `copy_to_user()` function would need to unpack it to re-create the original, padded structure.

## Risk Assessment

Padding bits might inadvertently contain sensitive data such as pointers to kernel data structures or passwords. A pointer to such a structure could be passed to other functions, causing information leakage.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL55-CPP </td> <td> Low </td> <td> Unlikely </td> <td> High </td> <td> <strong>P1</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC++-DCL55</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>MISC.PADDING.POTB</strong> </td> <td> Padding Passed Across a Trust Boundary </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C++4941, C++4942, C++4943</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_CPP-DCL55-a</strong> </td> <td> A pointer to a structure should not be passed to a function that can copy data to the user space </td> </tr> </tbody> </table>


## Related Vulnerabilities

Numerous vulnerabilities in the Linux Kernel have resulted from violations of this rule.

[CVE-2010-4083](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2010-4083) describes a vulnerability in which the `semctl()` system call allows unprivileged users to read uninitialized kernel stack memory because various fields of a `semid_ds struct` declared on the stack are not altered or zeroed before being copied back to the user.

[CVE-2010-3881](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2010-3881) describes a vulnerability in which structure padding and reserved fields in certain data structures in `QEMU-KVM` were not initialized properly before being copied to user space. A privileged host user with access to `/dev/kvm` could use this flaw to leak kernel stack memory to user space.

[CVE-2010-3477](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2010-3477) describes a kernel information leak in `act_police` where incorrectly initialized structures in the traffic-control dump code may allow the disclosure of kernel memory to user space applications.

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/cplusplus/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+DCL55-CPP).

## Related Guidelines

<table> <tbody> <tr> <td> <a> SEI CERT C Coding Standard </a> </td> <td> <a> DCL39-C. Avoid information leakage when passing a structure across a trust boundary </a> </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 14882-2014 </a> \] </td> <td> Subclause 8.5, "Initializers" Subclause 9.2, "Class Members" Subclause 9.6, "Bit-fields" </td> </tr> </tbody> </table>


## Implementation notes

The rule does not detect cases where fields may have uninitialized padding but are initialized via an initializer.

## References

* CERT-C++: [DCL55-CPP: Avoid information leakage when passing a class object across a trust boundary](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
