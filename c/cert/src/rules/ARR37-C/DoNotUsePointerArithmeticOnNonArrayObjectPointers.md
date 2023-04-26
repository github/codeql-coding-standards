# ARR37-C: Do not add or subtract an integer to a pointer to a non-array object

This query implements the CERT-C rule ARR37-C:

> Do not add or subtract an integer to a pointer to a non-array object


## Description

Pointer arithmetic must be performed only on pointers that reference elements of array objects.

The C Standard, 6.5.6 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states the following about pointer arithmetic:

> When an expression that has integer type is added to or subtracted from a pointer, the result has the type of the pointer operand. If the pointer operand points to an element of an array object, and the array is large enough, the result points to an element offset from the original element such that the difference of the subscripts of the resulting and original array elements equals the integer expression.


## Noncompliant Code Example

This noncompliant code example attempts to access structure members using pointer arithmetic. This practice is dangerous because structure members are not guaranteed to be contiguous.

```cpp
struct numbers {
  short num_a, num_b, num_c;
};

int sum_numbers(const struct numbers *numb){
  int total = 0;
  const short *numb_ptr;

  for (numb_ptr = &numb->num_a;
       numb_ptr <= &numb->num_c;
       numb_ptr++) {
    total += *(numb_ptr);
  }

  return total;
}

int main(void) {
  struct numbers my_numbers = { 1, 2, 3 };
  sum_numbers(&my_numbers);
  return 0;
}

```

## Compliant Solution

It is possible to use the `->` operator to dereference each structure member:

```cpp
total = numb->num_a + numb->num_b + numb->num_c;

```
However, this solution results in code that is hard to write and hard to maintain (especially if there are many more structure members), which is exactly what the author of the noncompliant code example was likely trying to avoid.

## Compliant Solution

A better solution is to define the structure to contain an array member to store the numbers in an array rather than a structure, as in this compliant solution:

```cpp
#include <stddef.h>

struct numbers {
  short a[3];
};

int sum_numbers(const short *numb, size_t dim) {
  int total = 0;
  for (size_t i = 0; i < dim; ++i) {
    total += numb[i];
  }

  return total;
}

int main(void) {
  struct numbers my_numbers = { .a[0]= 1, .a[1]= 2, .a[2]= 3};
  sum_numbers(
    my_numbers.a,
    sizeof(my_numbers.a)/sizeof(my_numbers.a[0])
  );
  return 0;
}

```
Array elements are guaranteed to be contiguous in memory, so this solution is completely portable.

## Exceptions

** ARR37-C-EX1:** Any non-array object in memory can be considered an array consisting of one element. Adding one to a pointer for such an object yields a pointer one element past the array, and subtracting one from that pointer yields the original pointer. This allows for code such as the following:

```cpp
#include <stdlib.h>
#include <string.h>
 
struct s {
  char *c_str;
  /* Other members */
};
 
struct s *create_s(const char *c_str) {
  struct s *ret;
  size_t len = strlen(c_str) + 1;
   
  ret = (struct s *)malloc(sizeof(struct s) + len);
  if (ret != NULL) {
    ret->c_str = (char *)(ret + 1);
    memcpy(ret + 1, c_str, len);
  }
  return ret;
}
```
A more general and safer solution to this problem is to use a flexible array member that guarantees the array that follows the structure is properly aligned by inserting padding, if necessary, between it and the member that immediately precedes it.

## Risk Assessment

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ARR37-C </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported indirectly via MISRA C:2004 Rule 17.4. </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-ARR37</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>LANG.MEM.BO</strong> <strong>LANG.MEM.BU</strong> <strong>LANG.STRUCT.PARITH</strong> <strong>LANG.STRUCT.PBB</strong> <strong>LANG.STRUCT.PPE</strong> <strong>LANG.MEM.TBA</strong> <strong>LANG.MEM.TO</strong> <strong>LANG.MEM.TU</strong> </td> <td> Buffer Overrun Buffer Underrun Pointer Arithmetic Pointer Before Beginning of Object Pointer Past End of Object Tainted Buffer Access Type Overrun Type Underrun </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>ARRAY_VS_SINGLETON</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>DF2930, DF2931, DF2932, DF2933</strong> <strong>C++3705, C++3706, C++3707</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.4 </td> <td> <strong>MISRA.PTR.ARITH.2012</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>567 S</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-ARR37-a</strong> </td> <td> Pointer arithmetic shall not be applied to pointers that address variables of non-array type </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2662</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2023a </td> <td> <a> CERT C: Rule ARR37-C </a> </td> <td> Checks for invalid assumptions about memory organization (rule partially covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2930, 2931, 2932, 2933</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2930, 2931, 2932, 2933,</strong> <strong> 3705, 3706, 3707</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> </td> <td> Supported indirectly via MISRA C:2004 Rule 17.4. </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ARR37-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> Banahan 2003 </a> \] </td> <td> <a> Section 5.3, "Pointers" </a> <a> Section 5.7, "Expressions Involving Pointers" </a> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.5.6, "Additive Operators" </td> </tr> <tr> <td> \[ <a> VU\#162289 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ARR37-C: Do not add or subtract an integer to a pointer to a non-array object](https://wiki.sei.cmu.edu/confluence/display/c)
