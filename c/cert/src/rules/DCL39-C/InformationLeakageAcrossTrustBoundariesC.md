# DCL39-C: Avoid information leakage when passing a structure across a trust boundary

This query implements the CERT-C rule DCL39-C:

> Avoid information leakage when passing a structure across a trust boundary


## Description

The C Standard, 6.7.2.1, discusses the layout of structure fields. It specifies that non-bit-field members are aligned in an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) manner and that there may be padding within or at the end of a structure. Furthermore, initializing the members of the structure does not guarantee initialization of the padding bytes. The C Standard, 6.2.6.1, paragraph 6 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> When a value is stored in an object of structure or union type, including in a member object, the bytes of the object representation that correspond to any padding bytes take unspecified values.


Additionally, the storage units in which a bit-field resides may also have padding bits. For an object with automatic storage duration, these padding bits do not take on specific values and can contribute to leaking sensitive information.

When passing a pointer to a structure across a trust boundary to a different trusted domain, the programmer must ensure that the padding bytes and bit-field storage unit padding bits of such a structure do not contain sensitive information.

## Noncompliant Code Example

This noncompliant code example runs in kernel space and copies data from `arg` to user space. However, padding bytes may be used within the structure, for example, to ensure the proper alignment of the structure members. These padding bytes may contain sensitive information, which may then be leaked when the data is copied to user space.

```cpp
#include <stddef.h>

struct test {
  int a;
  char b;
  int c;
};

/* Safely copy bytes to user space */
extern int copy_to_user(void *dest, void *src, size_t size);

void do_stuff(void *usr_buf) {
  struct test arg = {.a = 1, .b = 2, .c = 3};
  copy_to_user(usr_buf, &arg, sizeof(arg));
}

```

## Noncompliant Code Example (memset())

The padding bytes can be explicitly initialized by calling `memset()`:

```cpp
#include <string.h>

struct test {
  int a;
  char b;
  int c;
};

/* Safely copy bytes to user space */
extern int copy_to_user(void *dest, void *src, size_t size);

void do_stuff(void *usr_buf) {
  struct test arg;

  /* Set all bytes (including padding bytes) to zero */
  memset(&arg, 0, sizeof(arg));

  arg.a = 1;
  arg.b = 2;
  arg.c = 3;

  copy_to_user(usr_buf, &arg, sizeof(arg));
}

```
However, a conforming compiler is free to implement `arg.b = 2` by setting the low-order bits of a register to 2, leaving the high-order bits unchanged and containing sensitive information. Then the platform copies all register bits into memory, leaving sensitive information in the padding bits. Consequently, this implementation could leak the high-order bits from the register to a user.

## Compliant Solution

This compliant solution serializes the structure data before copying it to an untrusted context:

```cpp
#include <stddef.h>
#include <string.h>
 
struct test {
  int a;
  char b;
  int c;
};
 
/* Safely copy bytes to user space */
extern int copy_to_user(void *dest, void *src, size_t size);
 
void do_stuff(void *usr_buf) {
  struct test arg = {.a = 1, .b = 2, .c = 3};
  /* May be larger than strictly needed */
  unsigned char buf[sizeof(arg)];
  size_t offset = 0;
  
  memcpy(buf + offset, &arg.a, sizeof(arg.a));
  offset += sizeof(arg.a);
  memcpy(buf + offset, &arg.b, sizeof(arg.b));
  offset += sizeof(arg.b);
  memcpy(buf + offset, &arg.c, sizeof(arg.c));
  offset += sizeof(arg.c);
  /* Set all remaining bytes to zero */
  memset(buf + offset, 0, sizeof(arg) - offset);

  copy_to_user(usr_buf, buf, offset /* size of info copied */);
} 
```
This code ensures that no uninitialized padding bytes are copied to unprivileged users. **Important:** The structure copied to user space is now a packed structure and the `copy_to_user()` function (or other eventual user) would need to unpack it to recreate the original padded structure.

## Compliant Solution (Padding Bytes)

Padding bytes can be explicitly declared as fields within the structure. This solution is not portable, however, because it depends on the [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) and target memory architecture. The following solution is specific to the x86-32 architecture:

```cpp
#include <assert.h>
#include <stddef.h>

struct test {
  int a;
  char b;
  char padding_1, padding_2, padding_3;
  int c;
};

/* Safely copy bytes to user space */
extern int copy_to_user(void *dest, void *src, size_t size);

void do_stuff(void *usr_buf) {
  /* Ensure c is the next byte after the last padding byte */
  static_assert(offsetof(struct test, c) ==
                offsetof(struct test, padding_3) + 1,
                "Structure contains intermediate padding");
  /* Ensure there is no trailing padding */
  static_assert(sizeof(struct test) ==
                offsetof(struct test, c) + sizeof(int),
                "Structure contains trailing padding");
  struct test arg = {.a = 1, .b = 2, .c = 3};
  arg.padding_1 = 0;
  arg.padding_2 = 0;
  arg.padding_3 = 0;
  copy_to_user(usr_buf, &arg, sizeof(arg));
}

```
The C Standard `static_assert()` macro accepts a constant expression and an [error message](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-error). The expression is evaluated at compile time and, if false, the compilation is terminated and the error message is output. (See [DCL03-C. Use a static assertion to test the value of a constant expression](https://wiki.sei.cmu.edu/confluence/display/c/DCL03-C.+Use+a+static+assertion+to+test+the+value+of+a+constant+expression) for more details.) The explicit insertion of the padding bytes into the `struct` should ensure that no additional padding bytes are added by the compiler and consequently both static assertions should be true. However, it is necessary to validate these assumptions to ensure that the solution is correct for a particular implementation.

## Compliant Solution (Structure Packing—GCC)

GCC allows specifying declaration attributes using the keyword `__attribute__((__packed__))`. When this attribute is present, the compiler will not add padding bytes for memory alignment unless an explicit alignment specifier for a structure member requires the introduction of padding bytes.

```cpp
#include <stddef.h>

struct test {
  int a;
  char b;
  int c;
} __attribute__((__packed__));

/* Safely copy bytes to user space */
extern int copy_to_user(void *dest, void *src, size_t size);

void do_stuff(void *usr_buf) {
  struct test arg = {.a = 1, .b = 2, .c = 3};
  copy_to_user(usr_buf, &arg, sizeof(arg));
}

```

## Compliant Solution (Structure Packing—Microsoft Visual Studio)

Microsoft Visual Studio supports `#pragma pack()` to suppress padding bytes \[[MSDN](http://msdn.microsoft.com/en-us/library/2e70t5y1(v=vs.110).aspx)\]. The compiler adds padding bytes for memory alignment, depending on the current packing mode, but still honors the alignment specified by `__declspec(align())`. In this compliant solution, the packing mode is set to 1 in an attempt to ensure all fields are given adjacent offsets:

```cpp
#include <stddef.h>

#pragma pack(push, 1) /* 1 byte */
struct test {
  int a;
  char b;
  int c;
};
#pragma pack(pop)
 
/* Safely copy bytes to user space */
extern int copy_to_user(void *dest, void *src, size_t size);

void do_stuff(void *usr_buf) {
  struct test arg = {1, 2, 3};
  copy_to_user(usr_buf, &arg, sizeof(arg));
}

```
The `pack` pragma takes effect at the first `struct` declaration after the pragma is seen.

## Noncompliant Code Example

This noncompliant code example also runs in kernel space and copies data from `struct test` to user space. However, padding bits will be used within the structure due to the bit-field member lengths not adding up to the number of bits in an `unsigned` object. Further, there is an unnamed bit-field that causes no further bit-fields to be packed into the same storage unit. These padding bits may contain sensitive information, which may then be leaked when the data is copied to user space. For instance, the uninitialized bits may contain a sensitive kernel space pointer value that can be trivially reconstructed by an attacker in user space.

```cpp
#include <stddef.h>

struct test {
  unsigned a : 1;
  unsigned : 0;
  unsigned b : 4;
};

/* Safely copy bytes to user space */
extern int copy_to_user(void *dest, void *src, size_t size);

void do_stuff(void *usr_buf) {
  struct test arg = { .a = 1, .b = 10 };
  copy_to_user(usr_buf, &arg, sizeof(arg));
}
```

## Compliant Solution

Padding bits can be explicitly declared, allowing the programmer to specify the value of those bits. When explicitly declaring all of the padding bits, any unnamed bit-fields of length `0` must be removed from the structure because the explicit padding bits ensure that no further bit-fields will be packed into the same storage unit.

```cpp
#include <assert.h>
#include <limits.h>
#include <stddef.h>

struct test {
  unsigned a : 1;
  unsigned padding1 : sizeof(unsigned) * CHAR_BIT - 1;
  unsigned b : 4;
  unsigned padding2 : sizeof(unsigned) * CHAR_BIT - 4;
};
/* Ensure that we have added the correct number of padding bits. */
static_assert(sizeof(struct test) == sizeof(unsigned) * 2,
              "Incorrect number of padding bits for type: unsigned");

/* Safely copy bytes to user space */
extern int copy_to_user(void *dest, void *src, size_t size);

void do_stuff(void *usr_buf) {
  struct test arg = { .a = 1, .padding1 = 0, .b = 10, .padding2 = 0 };
  copy_to_user(usr_buf, &arg, sizeof(arg));
}
```
This solution is not portable, however, because it depends on the [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) and target memory architecture. The explicit insertion of padding bits into the `struct` should ensure that no additional padding bits are added by the compiler. However, it is still necessary to validate these assumptions to ensure that the solution is correct for a particular implementation. For instance, the DEC Alpha is an example of a 64-bit architecture with 32-bit integers that allocates 64 bits to a storage unit.

In addition, this solution assumes that there are no integer padding bits in an `unsigned int`. The portable version of the width calculation from [INT35-C. Use correct integer precisions](https://wiki.sei.cmu.edu/confluence/display/c/INT35-C.+Use+correct+integer+precisions) cannot be used because the bit-field width must be an integer constant expression.

From this situation, it can be seen that special care must be taken because no solution to the bit-field padding issue will be 100% portable.

Risk Assessment

Padding units might contain sensitive data because the C Standard allows any padding to take [unspecified values](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unspecifiedvalue). A pointer to such a structure could be passed to other functions, causing information leakage.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> DCL39-C </td> <td> Low </td> <td> Unlikely </td> <td> High </td> <td> <strong>P1</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>function-argument-with-padding</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-DCL39</strong> </td> <td> Detects composite structures with padding, in particular those passed to trust boundary routines. </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>MISC.PADDING.POTB</strong> </td> <td> Padding Passed Across a Trust Boundary </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF4941, DF4942, DF4943</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>PORTING.STORAGE.STRUCT</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-DCL39-a</strong> </td> <td> A pointer to a structure should not be passed to a function that can copy data to the user space </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule DCL39-C </a> </td> <td> Checks for information leak via structure padding </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>4941, 4942, 4943</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4941, 4942, 4943</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>function-argument-with-padding</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Numerous vulnerabilities in the Linux Kernel have resulted from violations of this rule. [CVE-2010-4083](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2010-4083) describes a [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) in which the `semctl()` system call allows unprivileged users to read uninitialized kernel stack memory because various fields of a `semid_ds struct` declared on the stack are not altered or zeroed before being copied back to the user.

[CVE-2010-3881](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2010-3881) describes a vulnerability in which structure padding and reserved fields in certain data structures in `QEMU-KVM` were not initialized properly before being copied to user space. A privileged host user with access to `/dev/kvm` could use this [flaw](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-securityflaw) to leak kernel stack memory to user space.

[CVE-2010-3477](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2010-3477) describes a kernel information leak in `act_police` where incorrectly initialized structures in the traffic-control dump code may allow the disclosure of kernel memory to user space applications.

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+DCL39-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> DCL03-C. Use a static assertion to test the value of a constant expression </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.2.6.1, "General" 6.7.2.1, "Structure and Union Specifiers" </td> </tr> <tr> <td> \[ <a> Graff 2003 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Sun 1993 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

The rule does not detect cases where fields may have uninitialized padding but are initialized via an initializer.

## References

* CERT-C: [DCL39-C: Avoid information leakage when passing a structure across a trust boundary](https://wiki.sei.cmu.edu/confluence/display/c)
