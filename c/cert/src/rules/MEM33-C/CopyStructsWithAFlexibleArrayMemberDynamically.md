# MEM33-C: Copy structures containing a flexible array member using memcpy or a similar function

This query implements the CERT-C rule MEM33-C:

> Allocate and copy structures containing a flexible array member dynamically


## Description

The C Standard, 6.7.2.1, paragraph 18 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], says

> As a special case, the last element of a structure with more than one named member may have an incomplete array type; this is called a *flexible array member*. In most situations, the flexible array member is ignored. In particular, the size of the structure is as if the flexible array member were omitted except that it may have more trailing padding than the omission would imply.


The following is an example of a structure that contains a flexible array member:

```cpp
struct flex_array_struct {
  int num;
  int data[];
};

```
This definition means that when computing the size of such a structure, only the first member, `num`, is considered. Unless the appropriate size of the flexible array member has been explicitly added when allocating storage for an object of the `struct`, the result of accessing the member `data` of a variable of nonpointer type `struct flex_array_struct` is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior). [DCL38-C. Use the correct syntax when declaring a flexible array member](https://wiki.sei.cmu.edu/confluence/display/c/DCL38-C.+Use+the+correct+syntax+when+declaring+a+flexible+array+member) describes the correct way to declare a `struct` with a flexible array member.

To avoid the potential for undefined behavior, structures that contain a flexible array member should always be allocated dynamically. Flexible array structures must

* Have dynamic storage duration (be allocated via `malloc()` or another dynamic allocation function)
* Be dynamically copied using `memcpy()` or a similar function and not by assignment
* When used as an argument to a function, be passed by pointer and not copied by value

## Noncompliant Code Example (Storage Duration)

This noncompliant code example uses automatic storage for a structure containing a flexible array member:

```cpp
#include <stddef.h>
 
struct flex_array_struct {
  size_t num;
  int data[];
};
 
void func(void) {
  struct flex_array_struct flex_struct;
  size_t array_size = 4;

  /* Initialize structure */
  flex_struct.num = array_size;

  for (size_t i = 0; i < array_size; ++i) {
    flex_struct.data[i] = 0;
  }
}
```
Because the memory for `flex_struct` is reserved on the stack, no space is reserved for the `data` member. Accessing the `data` member is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

## Compliant Solution (Storage Duration)

This compliant solution dynamically allocates storage for `flex_array_struct`:

```cpp
#include <stdlib.h>
 
struct flex_array_struct {
  size_t num;
  int data[];
};
 
void func(void) {
  struct flex_array_struct *flex_struct;
  size_t array_size = 4;

  /* Dynamically allocate memory for the struct */
  flex_struct = (struct flex_array_struct *)malloc(
    sizeof(struct flex_array_struct)
    + sizeof(int) * array_size);
  if (flex_struct == NULL) {
    /* Handle error */
  }

  /* Initialize structure */
  flex_struct->num = array_size;

  for (size_t i = 0; i < array_size; ++i) {
    flex_struct->data[i] = 0;
  }
}
```

## Noncompliant Code Example (Copying)

This noncompliant code example attempts to copy an instance of a structure containing a flexible array member (`struct `flex_array_struct``) by assignment:

```cpp
#include <stddef.h>
 
struct flex_array_struct {
  size_t num;
  int data[];
};
 
void func(struct flex_array_struct *struct_a,
          struct flex_array_struct *struct_b) {
  *struct_b = *struct_a;
}
```
When the structure is copied, the size of the flexible array member is not considered, and only the first member of the structure, `num`, is copied, leaving the array contents untouched.

## Compliant Solution (Copying)

This compliant solution uses `memcpy()` to properly copy the content of `struct_a` into `struct_b`:

```cpp
#include <string.h>
 
struct flex_array_struct {
  size_t num;
  int data[];
};
 
void func(struct flex_array_struct *struct_a,
          struct flex_array_struct *struct_b) {
  if (struct_a->num > struct_b->num) {
    /* Insufficient space; handle error */
    return;
  }
  memcpy(struct_b, struct_a,
         sizeof(struct flex_array_struct) + (sizeof(int)
           * struct_a->num));
}
```

## Noncompliant Code Example (Function Arguments)

In this noncompliant code example, the flexible array structure is passed by value to a function that prints the array elements:

```cpp
#include <stdio.h>
#include <stdlib.h>
 
struct flex_array_struct {
  size_t num;
  int data[];
};
 
void print_array(struct flex_array_struct struct_p) {
  puts("Array is: ");
  for (size_t i = 0; i < struct_p.num; ++i) {
    printf("%d ", struct_p.data[i]);
  }
  putchar('\n');
}

void func(void) {
  struct flex_array_struct *struct_p;
  size_t array_size = 4;

  /* Space is allocated for the struct */
  struct_p = (struct flex_array_struct *)malloc(
    sizeof(struct flex_array_struct)
    + sizeof(int) * array_size);
  if (struct_p == NULL) {
    /* Handle error */
  }
  struct_p->num = array_size;

  for (size_t i = 0; i < array_size; ++i) {
    struct_p->data[i] = i;
  }
  print_array(*struct_p);
}
```
Because the argument is passed by value, the size of the flexible array member is not considered when the structure is copied, and only the first member of the structure, `num`, is copied.

## Compliant Solution (Function Arguments)

In this compliant solution, the structure is passed by reference and not by value:

```cpp
#include <stdio.h>
#include <stdlib.h>
 
struct flex_array_struct {
  size_t num;
  int data[];
};
 
void print_array(struct flex_array_struct *struct_p) {
  puts("Array is: ");
  for (size_t i = 0; i < struct_p->num; ++i) {
    printf("%d ", struct_p->data[i]);
  }
  putchar('\n');
}

void func(void) {
  struct flex_array_struct *struct_p;
  size_t array_size = 4;

  /* Space is allocated for the struct and initialized... */

  print_array(struct_p);
}
```

## Risk Assessment

Failure to use structures with flexible array members correctly can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MEM33-C </td> <td> Low </td> <td> Unlikely </td> <td> Low </td> <td> <strong>P3</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>flexible-array-member-assignment</strong> <strong>flexible-array-member-declaration</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-MEM33</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.STRUCT.DECL.FAM</strong> </td> <td> Declaration of Flexible Array Member </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect all of these </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C1061, C1062, C1063, C1064</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.INCOMPLETE.STRUCT</strong> <strong>MISRA.MEMB.FLEX_ARRAY.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> 649 S, 650 S </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-MEM33-a</strong> <strong>CERT_C-MEM33-b</strong> </td> <td> Allocate structures containing a flexible array member dynamically Do not copy instances of structures containing a flexible array member </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule MEM33-C </a> </td> <td> Checks for misuse of structure with flexible array member (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>1061, 1062, 1063, 1064 </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>flexible-array-member-assignment</strong> <strong>flexible-array-member-declaration</strong> </td> <td> Fully checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM33-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> DCL38-C. Use the correct syntax when declaring a flexible array member </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-401 and MEM33-CPP**

There is no longer a C++ rule for MEM33-CPP. (In fact, all C++ rules from 30-50 are gone, because we changed the numbering system to be 50-99 for C++ rules.)

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 6.7.2.1, "Structure and Union Specifiers" </td> </tr> <tr> <td> \[ <a> JTC1/SC22/WG14 N791 </a> \] </td> <td> Solving the Struct Hack Problem </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [MEM33-C: Allocate and copy structures containing a flexible array member dynamically](https://wiki.sei.cmu.edu/confluence/display/c)
