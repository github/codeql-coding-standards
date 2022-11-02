# CON40-C: Do not refer to an atomic variable twice in an expression

This query implements the CERT-C rule CON40-C:

> Do not refer to an atomic variable twice in an expression


## Description

A consistent locking policy guarantees that multiple threads cannot simultaneously access or modify shared data. Atomic variables eliminate the need for locks by guaranteeing thread safety when certain operations are performed on them. The thread-safe operations on atomic variables are specified in the C Standard, subclauses 7.17.7 and 7.17.8 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\]. While atomic operations can be combined, combined operations do not provide the thread safety provided by individual atomic operations.

Every time an atomic variable appears on the left side of an assignment operator, including a compound assignment operator such as `*=`, an atomic write is performed on the variable. The use of the increment (++`)` or decrement `(--)` operators on an atomic variable constitutes an atomic read-and-write operation and is consequently thread-safe. Any reference of an atomic variable anywhere else in an expression indicates a distinct atomic read on the variable.

If the same atomic variable appears twice in an expression, then two atomic reads, or an atomic read and an atomic write, are required. Such a pair of atomic operations is not thread-safe, as another thread can modify the atomic variable between the two operations. Consequently, an atomic variable must not be referenced twice in the same expression.

## Noncompliant Code Example (atomic_bool)

This noncompliant code example declares a shared `atomic_bool` `flag` variable and provides a `toggle_flag()` method that negates the current value of `flag`:

```cpp
#include <stdatomic.h>
#include <stdbool.h>
  
static atomic_bool flag = ATOMIC_VAR_INIT(false);
  
void init_flag(void) {
  atomic_init(&flag, false);
}
  
void toggle_flag(void) {
  bool temp_flag = atomic_load(&flag);
  temp_flag = !temp_flag;
  atomic_store(&flag, temp_flag);
}
    
bool get_flag(void) {
  return atomic_load(&flag);
}

```
Execution of this code may result in unexpected behavior because the value of `flag` is read, negated, and written back. This occurs even though the read and write are both atomic.

Consider, for example, two threads that call `toggle_flag()`. The expected effect of toggling `flag` twice is that it is restored to its original value. However, the scenario in the following table leaves `flag` in the incorrect state.

`toggle_flag()` without Compare-and-Exchange

<table> <tbody> <tr> <th> Time </th> <th> <code>flag</code> </th> <th> Thread </th> <th> Action </th> </tr> <tr> <td> 1 </td> <td> <code>true</code> </td> <td> <em> t </em> <sub> 1 </sub> </td> <td> Reads the current value of <code>flag</code> , which is <code>true,</code> into a cache </td> </tr> <tr> <td> 2 </td> <td> <code>true</code> </td> <td> <em> t </em> <sub> 2 </sub> </td> <td> Reads the current value of <code>flag</code> , which is still <code>true,</code> into a different cache </td> </tr> <tr> <td> 3 </td> <td> <code>true</code> </td> <td> <em> t </em> <sub> 1 </sub> </td> <td> Toggles the temporary variable in the cache to <code>false</code> </td> </tr> <tr> <td> 4 </td> <td> <code>true</code> </td> <td> <em> t </em> <sub> 2 </sub> </td> <td> Toggles the temporary variable in the different cache to <code>false</code> </td> </tr> <tr> <td> 5 </td> <td> <code>false</code> </td> <td> <em> t </em> <sub> 1 </sub> </td> <td> Writes the cache variable's value to <code>flag</code> </td> </tr> <tr> <td> 6 </td> <td> <code>false</code> </td> <td> <em> t </em> <sub> 2 </sub> </td> <td> Writes the different cache variable's value to <code>flag</code> </td> </tr> </tbody> </table>
As a result, the effect of the call by *t*<sub>2</sub> is not reflected in `flag`; the program behaves as if `toggle_flag()` was called only once, not twice.


## Compliant Solution (atomic_compare_exchange_weak())

This compliant solution uses a compare-and-exchange to guarantee that the correct value is stored in `flag`. All updates are visible to other threads. The call to `atomic_compare_exchange_weak()` is in a loop in conformance with [CON41-C. Wrap functions that can fail spuriously in a loop](https://wiki.sei.cmu.edu/confluence/display/c/CON41-C.+Wrap+functions+that+can+fail+spuriously+in+a+loop).

```cpp
#include <stdatomic.h>
#include <stdbool.h>
 
static atomic_bool flag = ATOMIC_VAR_INIT(false);
 
void init_flag(void) {
  atomic_init(&flag, false);
}
 
void toggle_flag(void) {
  bool old_flag = atomic_load(&flag);
  bool new_flag;
  do {
    new_flag = !old_flag;
  } while (!atomic_compare_exchange_weak(&flag, &old_flag, new_flag));
}
   
bool get_flag(void) {
  return atomic_load(&flag);
}
```
An alternative solution is to use the `atomic_flag` data type for managing Boolean values atomically. However, `atomic_flag` does not support a toggle operation.

## Compliant Solution (Compound Assignment)

This compliant solution uses the `^=` assignment operation to toggle `flag`. This operation is guaranteed to be atomic, according to the C Standard, 6.5.16.2, paragraph 3. This operation performs a bitwise-exclusive-or between its arguments, but for Boolean arguments, this is equivalent to negation.

```cpp
#include <stdatomic.h>
#include <stdbool.h>
  
static atomic_bool flag = ATOMIC_VAR_INIT(false);
  
void toggle_flag(void) {
  flag ^= 1;
}
    
bool get_flag(void) {
  return flag;
}
```
An alternative solution is to use a mutex to protect the atomic operation, but this solution loses the performance benefits of atomic variables.

## Noncompliant Code Example

This noncompliant code example takes an atomic global variable `n` and computes `n + (n - 1) + (n - 2) + ... + 1`, using the formula `n * (n + 1) / 2`:

```cpp
#include <stdatomic.h>

atomic_int n = ATOMIC_VAR_INIT(0);
  
int compute_sum(void) {
  return n * (n + 1) / 2;
}
```
The value of `n` may change between the two atomic reads of `n` in the expression, yielding an incorrect result.

## Compliant Solution

This compliant solution passes the atomic variable as a function argument, forcing the variable to be copied and guaranteeing a correct result. Note that the function's formal parameter need not be atomic, and the atomic variable can still be passed as an actual argument.

```cpp
#include <stdatomic.h>
 
int compute_sum(int n) {
  return n * (n + 1) / 2;
}

```

## Risk Assessment

When operations on atomic variables are assumed to be atomic, but are not atomic, surprising data races can occur, leading to corrupted data and invalid control flow.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON40-C </td> <td> Medium </td> <td> Probable </td> <td> Medium </td> <td> <strong>P8</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>multiple-atomic-accesses</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-CON40</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.1p0 </td> <td> <strong>CONCURRENCY.MAA</strong> </td> <td> Multiple Accesses of Atomic </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>EVALUATION_ORDER (partial)</strong> <strong>MISRA 2012 Rule 13.2</strong> <strong>VOLATILE_ATOICITY (possible)</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.3 </td> <td> <strong>C1114, C1115, C1116</strong> <strong>C++3171, C++4150</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.3 </td> <td> <strong>CERT.CONC.ATOMIC_TWICE_EXPR</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-CON40-a</strong> </td> <td> Do not refer to an atomic variable twice in an expression </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule CON40-C </a> </td> <td> Checks for: Atomic variable accessed twice in an expressiontomic variable accessed twice in an expression, atomic load and store sequence not atomictomic load and store sequence not atomic. Rule fully covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>1114, 1115, 1116 </strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>multiple-atomic-accesses</strong> </td> <td> Partially checked </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://www.securecoding.cert.org/confluence/display/seccode/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON40-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-366 </a> , Race Condition within a Thread </td> <td> 2017-07-07: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-366 and CON40-C**

CON40-C = Subset( CON43-C) Intersection( CON32-C, CON40-C) = Ø

CWE-366 = Union( CON40-C, list) where list =

* C data races that do not involve an atomic variable used twice within an expression

## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.5.16.2, "Compound Assignment" 7.17, "Atomics" </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [CON40-C: Do not refer to an atomic variable twice in an expression](https://wiki.sei.cmu.edu/confluence/display/c)
