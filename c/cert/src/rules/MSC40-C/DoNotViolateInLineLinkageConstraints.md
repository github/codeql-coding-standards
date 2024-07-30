# MSC40-C: Do not violate inline linkage constraints

This query implements the CERT-C rule MSC40-C:

> Do not violate constraints


## Description

According to the C Standard, 3.8 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\], a constraint is a "restriction, either syntactic or semantic, by which the exposition of language elements is to be interpreted." Despite the similarity of the terms, a runtime constraint is not a kind of constraint.

Violating any *shall* statement within a constraint clause in the C Standard requires an [implementation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation) to issue a diagnostic message, the C Standard, 5.1.1.3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\] states

> A conforming implementation shall produce at least one diagnostic message (identified in an implementation-defined manner) if a preprocessing translation unit or translation unit contains a violation of any syntax rule or constraint, even if the behavior is also explicitly specified as undefined or implementation-defined. Diagnostic messages need not be produced in other circumstances.


The C Standard further explains in a footnote

> The intent is that an implementation should identify the nature of, and where possible localize, each violation. Of course, an implementation is free to produce any number of diagnostics as long as a valid program is still correctly translated. It may also successfully translate an invalid program.


Any constraint violation is a violation of this rule because it can result in an invalid program.

## Noncompliant Code Example (Inline, Internal Linkage)

The C Standard, 6.7.4, paragraph 3 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\], states

> An inline definition of a function with external linkage shall not contain a definition of a modifiable object with static or thread storage duration, and shall not contain a reference to an identifier with internal linkage.


The motivation behind this constraint lies in the semantics of inline definitions. Paragraph 7 of subclause 6.7.4 reads, in part:

> An inline definition provides an alternative to an external definition, which a translator may use to implement any call to the function in the same translation unit. It is unspecified whether a call to the function uses the inline definition or the external definition.


That is, if a function has an external and inline definition, implementations are free to choose which definition to invoke (two distinct invocations of the function may call different definitions, one the external definition, the other the inline definition). Therefore, issues can arise when these definitions reference internally linked objects or mutable objects with static or thread storage duration.

This noncompliant code example refers to a static variable with file scope and internal linkage from within an external inline function:

```cpp
static int I = 12;
extern inline void func(int a) {
  int b = a * I;
  /* ... */
}

```

## Compliant Solution (Inline, Internal Linkage)

This compliant solution omits the `static` qualifier; consequently, the variable `I` has external linkage by default:

```cpp
int I = 12;
extern inline void func(int a) {
  int b = a * I;
  /* ... */
}

```

## Noncompliant Code Example (inline, Modifiable Static)

This noncompliant code example defines a modifiable `static` variable within an `extern inline` function.

```cpp
extern inline void func(void) {
  static int I = 12;
  /* Perform calculations which may modify I */
}

```

## Compliant Solution (Inline, Modifiable Static)

This compliant solution removes the `static` keyword from the local variable definition. If the modifications to `I` must be retained between invocations of `func()`, it must be declared at file scope so that it will be defined with external linkage.

```cpp
extern inline void func(void) {
  int I = 12;
  /* Perform calculations which may modify I */
}
```

## Noncompliant Code Example (Inline, Modifiable static)

This noncompliant code example includes two translation units: `file1.c` and `file2.c`. The first file, `file1.c`, defines a pseudorandom number generation function:

```cpp
/* file1.c */

/* Externally linked definition of the function get_random() */
extern unsigned int get_random(void) {
  /* Initialize the seeds */
  static unsigned int m_z = 0xdeadbeef;
  static unsigned int m_w = 0xbaddecaf;

  /* Compute the next pseudorandom value and update the seeds */
  m_z = 36969 * (m_z & 65535) + (m_z >> 16);
  m_w = 18000 * (m_w & 65535) + (m_w >> 16);
  return (m_z << 16) + m_w;
}

```
The left-shift operation in the last line may wrap, but this is permitted by exception INT30-C-EX3 to rule [INT30-C. Ensure that unsigned integer operations do not wrap](https://wiki.sei.cmu.edu/confluence/display/c/INT30-C.+Ensure+that+unsigned+integer+operations+do+not+wrap).

The second file, `file2.c`, defines an `inline` version of this function that references mutable `static` objects—namely, objects that maintain the state of the pseudorandom number generator. Separate invocations of the `get_random()` function can call different definitions, each operating on separate static objects, resulting in a faulty pseudorandom number generator.

```cpp
/* file2.c */

/* Inline definition of get_random function */
inline unsigned int get_random(void) {
  /* 
   * Initialize the seeds 
   * Constraint violation: static duration storage referenced
   * in non-static inline definition
   */
  static unsigned int m_z = 0xdeadbeef;
  static unsigned int m_w = 0xbaddecaf;

  /* Compute the next pseudorandom value and update the seeds */
  m_z = 36969 * (m_z & 65535) + (m_z >> 16);
  m_w = 18000 * (m_w & 65535) + (m_w >> 16);
  return (m_z << 16) + m_w;
}

int main(void) {
  unsigned int rand_no;
  for (int ii = 0; ii < 100; ii++) {
    /* 
     * Get a pseudorandom number. Implementation defined whether the
     * inline definition in this file or the external definition  
     * in file2.c is called. 
     */
    rand_no = get_random();
    /* Use rand_no... */
  }

  /* ... */

  /* 
   * Get another pseudorandom number. Behavior is
   * implementation defined.
   */
  rand_no = get_random();
  /* Use rand_no... */
  return 0;
}

```

## Compliant Solution (Inline, Modifiable static)

This compliant solution adds the `static` modifier to the `inline` function definition in `file2.c`, giving it internal linkage. All references to `get_random()` in `file.2.c` will now reference the internally linked definition. The first file, which was not changed, is not shown here.

```cpp
/* file2.c */

/* Static inline definition of get_random function */
static inline unsigned int get_random(void) {
  /* 
   * Initialize the seeds. 
   * No more constraint violation; the inline function is now 
   * internally linked. 
   */
  static unsigned int m_z = 0xdeadbeef;
  static unsigned int m_w = 0xbaddecaf;

  /* Compute the next pseudorandom value and update the seeds  */
  m_z = 36969 * (m_z & 65535) + (m_z >> 16);
  m_w = 18000 * (m_w & 65535) + (m_w >> 16);
  return (m_z << 16) + m_w;
}

int main(void) {
  /* Generate pseudorandom numbers using get_random()... */
  return 0;
}

```

## Risk Assessment

Constraint violations are a broad category of error that can result in unexpected control flow and corrupted data.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> MSC40-C </td> <td> Low </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P2</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 23.04 </td> <td> <strong>alignas-extended</strong> <strong>assignment-to-non-modifiable-lvalue</strong> <strong>cast-pointer-void-arithmetic-implicit</strong> <strong>element-type-incomplete</strong> <strong>function-pointer-integer-cast-implicit</strong> <strong>function-return-type</strong> <strong>inappropriate-pointer-cast-implicit</strong> <strong>incompatible-function-pointer-conversion</strong> <strong>incompatible-object-pointer-conversion</strong> <strong>initializer-excess</strong> <strong>invalid-array-size</strong> <strong>non-constant-static-assert</strong> <strong>parameter-match-type</strong> <strong>pointer-integral-cast-implicit</strong> <strong>pointer-qualifier-cast-const-implicit</strong> <strong>pointer-qualifier-cast-volatile-implicit</strong> <strong>redeclaration</strong> <strong>return-empty</strong> <strong>return-non-empty</strong> <strong>static-assert</strong> <strong>type-compatibility</strong> <strong>type-compatibility-link</strong> <strong>type-specifier</strong> <strong>undeclared-parameter</strong> <strong>unnamed-parameter</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2023.4 </td> <td> <strong>C0232, C0233, C0244, C0268, C0321, C0322, C0338, C0422, C0423, C0426, C0427, C0429, C0430, C0431, C0432, C0435, C0436, C0437, C0446, C0447, C0448, C0449, C0451, C0452, C0453, C0454, C0456, C0457, C0458, C0460, C0461, C0462, C0463, C0466, C0467, C0468, C0469, C0476, C0477, C0478, C0481, C0482, C0483, C0484, C0485, C0486, C0487, C0493, C0494, C0495, C0496, C0497, C0513, C0514, C0515, C0536, C0537, C0540, C0541, C0542, C0546, C0547, C0550, C0554, C0555, C0556, C0557, C0558, C0559, C0560, C0561, C0562, C0563, C0564, C0565, C0580, C0588, C0589, C0590, C0591, C0605, C0616, C0619, C0620, C0621, C0622, C0627, C0628, C0629, C0631, C0638, C0640, C0641, C0642, C0643, C0644, C0645, C0646, C0649, C0650, C0651, C0653, C0655, C0656, C0657, C0659, C0664, C0665, C0669, C0671, C0673, C0674, C0675, C0677, C0682, C0683, C0684, C0685, C0690, C0698, C0699, C0708, C0709, C0736, C0737, C0738, C0746, C0747, C0755, C0756, C0757, C0758, C0766, C0767, C0768, C0774, C0775, C0801, C0802, C0803, C0804, C0811, C0821, C0834, C0835, C0844, C0845, C0851, C0852, C0866, C0873, C0877, C0940, C0941, C0943, C0944, C1023, C1024, C1025, C1033, C1047, C1048, C1050, C1061, C1062, C3236, C3237, C3238, C3244</strong> <strong>C++4122</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2023.4 </td> <td> <strong>MISRA.FUNC.STATIC.REDECL</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>21 S, 145 S, 323 S, 345 S, 387 S, 404 S, 481 S, 580 S, 612 S, 615 S, 646 S</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2023.1 </td> <td> <strong>CERT_C-MSC40-a</strong> </td> <td> An inline definition of a function with external linkage shall not contain definitions and uses of static objects </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> </td> <td> <a> CERT C: Rule MSC40-C </a> </td> <td> Checks for inline constraint not respected (rule partially covered) </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 23.04 </td> <td> <strong>alignas-extended</strong> <strong>assignment-to-non-modifiable-lvalue</strong> <strong>cast-pointer-void-arithmetic-implicit</strong> <strong>element-type-incomplete</strong> <strong>function-pointer-integer-cast-implicit</strong> <strong>function-return-type</strong> <strong>inappropriate-pointer-cast-implicit</strong> <strong>incompatible-function-pointer-conversion</strong> <strong>incompatible-object-pointer-conversion</strong> <strong>initializer-excess</strong> <strong>invalid-array-size</strong> <strong>non-constant-static-assert</strong> <strong>parameter-match-type</strong> <strong>pointer-integral-cast-implicit</strong> <strong>pointer-qualifier-cast-const-implicit</strong> <strong>pointer-qualifier-cast-volatile-implicit</strong> <strong>redeclaration</strong> <strong>return-empty</strong> <strong>return-non-empty</strong> <strong>static-assert</strong> <strong>type-compatibility</strong> <strong>type-compatibility-link</strong> <strong>type-specifier</strong> <strong>undeclared-parameter</strong> <strong>unnamed-parameter</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MSC40-C).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 4, "Conformance" 5.1.1.3, "Diagnostics" 6.7.4, "Function Specifiers" </td> </tr> </tbody> </table>


## Implementation notes

This query only considers the constraints related to inline extern functions.

## References

* CERT-C: [MSC40-C: Do not violate constraints](https://wiki.sei.cmu.edu/confluence/display/c)
