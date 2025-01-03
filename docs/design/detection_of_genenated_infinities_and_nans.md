# Coding Standards: Detection of generated Infinities and NaNs

- [Coding Standards: Detection of generated Infinities and NaNs](#coding-standards-detection-of-generated-infinities-and-nans)
  - [Document management](#document-management)
  - [Background](#background)
  - [Critical problems](#critical-problems)
  - [TL;DR](#tldr)
  - [Range / Source Analysis, In Detail](#range-source-analysis-in-detail)
    - [Mathematical Operations](#mathematical-operations)
    - [Range / Source Proposal #1 (Recommended)](#range-source-proposal-1-recommended)
    - [Range / Source Proposal #2 (Not Recommended)](#range-source-proposal-2-not-recommended)
    - [Range / Source Proposal #3 (Not Recommended)](#range-source-proposal-3-not-recommended)
    - [Range / Source Proposal #4 (Not Recommended)](#range-source-proposal-4-not-recommended)
  - [Detection / Sink Analysis, In Detail](#detection-sink-analysis-in-detail)
    - [Detection / Sink Proposal #1 (Recommended)](#range-source-proposal-1-recommended)
    - [Detection / Sink Proposal #2 (Not Recommended)](#range-source-proposal-2-not-recommended)
  - [Case study examples](#case-study-examples)

## Document management

**ID**: codeql-coding-standards/design/detection-infinities-nans<br/>
**Status**: Draft

| Version | Date       | Author(s)      | Reviewer (s)                                                                                   |
| ------- | ---------- | -------------- | ---------------------------------------------------------------------------------------------- |
| 0.1     | 12/13/2024 | Mike Fairhurst | Robert C. Seacord, J.F. Bastien, Luke Cartey, Vincent Mailhol, Fernando Jose, Rakesh Pothengil |

## Background

Directive 4-15 of MISRA-C 2023 states that a program shall not have undetected generation of Infinities and NaNs. It also states that infinities and NaNs may propagate across various FLOPs, but may not propagate into sections of code not designed to handle infinities and NaNs.

This directive is intentionally open to a large degree of interpretation. This document is intended to help guide the decision making for how to implement this directive in the most useful way.

## Critical problems

There are two fundamental problems to decide on before implementing this directive:
- **Range / source analysis**, even a simple expression like `a + b` can be a source of infinity or NaN if there is no estimated value for `a` and/or `b`, which violates developer expectations and produces false positives.
- **Detection / sink analysis**, how we decide which sources need to be reported to users. This can be flow analysis with sinks, or it can be modeled as a resource leak analysis where certain actions (`isnan(x), x < 10`) are handled as freeing the NaN/infinite value.

## TL;DR

This document proposes to create a float-specialized copy of standard range analysis which assumes most values are in the range of +/-1e15, which covers most valid program use cases, and allows `a * b` without generating `Infinity`. Then standard flow analysis will be used to detect when these values flow into underflowing operations (`x / infinity` and `x % infinity`, etc.), and when NaNs flow into comparison operations (`>`, `>=`, `<`, `<=`). If the query is noisy, we may ignore NaNs and/or infinities that come from the mostly safe basic operations (`+`, `-`, `*`).

## Range / Source Analysis, In Detail:

Default CodeQL range analysis is limited for performance reasons (etc):

- Range analysis is local, not interprocedural
- Global variables are assumed to be in the range of [-Infinity, Infinity]
- Struct members, array values are assumed to be in the range of [-Infinity, Infinity]
- Guards (e.g. `x != 0 ? y / x : ...`) are not always tracked

This creates a scenario where even `a + b` can be `Infinity` or `NaN`; if either `a` or `b` is `Inf` then the expression is `Inf`, and if `a` is `+Inf` while `b` is `-Inf` then the result is `NaN`.

Perhaps the flaw is in assuming `a` or `b` may be an infinite value. However, if the analysis considered `a` and `b` to be between the largest positive and negative finite floating values, then still `a + b` can produce an infinity, and only offers a single step of protection from false positives and negatives.

There are a few proposals to handle this.

#### Mathematical Operations

IEEE 754-1985 specifies floating point semantics for “add, subtract, multiply, divide, square root, remainder, and compare operations,” including invalid use of these operators that produce NaN, propagating NaNs, and overflows that produce +/- Infinity. These semantics shall be used in the analysis.

The C17 standard states that implementations compiling with IEEE 754-1985 shall define `__STDC_IEC_559__`. Under this proposal we will detect compilations where this macro is not defined and report a warning.

Beyond the standard binary operators defined by IEEE 754-1985, programs may generate Infinity and/or NaN in the standard library mathematical functions. Note that technically, the c spec is vague in certain ways about when range errors, pole errors, and invalid operation errors in the standard math functions produce infinities or NaNs. We propose to assume IEEE 754-2019 behavior in this regard as a practical matter, though there is no guarantee that is the case. An alternative approach which we do not plan to take would be to broadly assume that all range errors, pole errors, invalid operation errors produce both Infinities and NaNs. This alternative would increase false positives. 

### Range / Source Proposal #1 (Recommended):

We will create a new float-specific version of range analysis. The actual values stored in floating point variables in real programs are very unlikely to be close to the limits of finite floating point numbers (+/- 3.4e38 for floats, 1.8e308 for doubles). This proposal is that we, for the purposes of this rule, create a new range analysis for floats where otherwise undeterminable values are assumed to be a very large range that is small compared to the range of floating point values, such as +/-1e15.

Creating a new version of float analysis rather than extending previous analysis is likely to have better performance than extending standard range analysis. When floats and integers interact, the integer from standard range analysis can be used.

Implications of this approach (assuming values `a` and `b` have no estimated range):
- `a + b` will be finite
- `a * b` will be finite
- `a * b * c` will be possibly infinite
- `a / b` will be possibly infinite, as the range includes small values such as 1e-30, as well as zero
- `acos(a)` will be considered out of domain

**Additional option**: If this query is still noisy, we may simply exclude reporting NaN’s and Infinities that come from a basic float operation such as `+`, `-`, or `*`. We would most likely still choose to report `/`, as divide-by-zero errors are the most common and most important to catch.

### Range / Source Proposal #2 (Not Recommended):

This proposal mirrors Proposal #1 except that otherwise undeterminable values will be treated as the max finite value +/-3.4e38 (floats) or 1.7e308 (doubles).

The implications are as above except:
- `a + b` will be possibly infinite
- `a * b` will be possibly infinite

### Range / Source Proposal #3 (Not Recommended):

Under this proposal, standard CodeQL range analysis is used to detect generation of NaN/Infinity. All uses of a global or otherwise undeterminable value will be considered possibly infinite.

### Range / Source Proposal #4 (Recommended):

Under this proposal, standard CodeQL range analysis is extended to provide the support of proposal #1. While this should mostly have the same results, it will likely create performance problems, as it would rerun all range analysis code on every expression in order to have different findings in a subset of them.

## Detection / Sink Analysis, In Detail:

The directive states that: 

- Generated Infinities and NaNs may not be unchecked
- Infinities and NaNs may propagate to delay NaN/Infinity checking for performance reasons
- Infinities and NaNs may not reach sections of code not designed to handle them

This leaves open some questions. For instance, is `printf("%f", a * b)` possibly sending an infinity to code prepared to handle it?

### Detection / Sink Proposal #1 (recommended):

This proposal is to identify sinks that should not accept Infinity or NaN, and then rely on standard flow analysis as the backbone of supporting this directive.

If a valid propagation of a NaN or an Infinity can be distinguished from cases where a program was not prepared to receive a NaN or Infinity, then flow analysis is the only thing that is needed, and a resource-leak approach is not necessary. This proposes that the following cases are detected as sinks, such that if NaN or Infinity flows into them they are reported.

**Case 1**:  _NaNs shall not be compared, except to themselves_
```c
void f(float x, float y) {
  float z = x / y; // Could be 0.0 / 0.0 which produces NaN

  if (x < 10) { ... } // Not allowed
  if (x != x) { ... } // OK
}
```

**Case 2**: _NaNs and infinities shall not be cast to integers_
```c
void f(float x, float y) {
  int z = x / y; // 0.0 / 0.0 may produce Infinity or NaN
}
```

**Case 3**: _Infinite values shall not underflow or otherwise produce finite values_
```c
float f(void) {
  float x = ...; // Could be a positive number / 0.0, which produces Infinity
  1 / x; // If x is Infinity, this underflows to 0.0
  1 % x; // If x is Infinity, this is defined to produce 1.
}
```

**Case 4**: _Functions shall not return NaNs and infinities_
```c
void f(float* p) {
  float local1 = ...; // Could be infinity

  return local1;
}
```

**Case 5**: _NaNs and infinities shall only be stored in local stack variables_
```c
float global;
void f(float* p) {
  float local1 = ...; // Could be infinity

  // The following assignments could store an infinity in the heap:
  global = local1;
  extern_function(local1);
  *p = local1;

  // The following cases should be possible to analyze correctly as well
  // with modest effort:
  float arr[10] = ...;
  struct my_struct = ...;
  arr[0] = local2;
  my_struct.member = local1;
}
```

**Case 6 (not planned, compiler specific)**: _Functions can use assume() to declare they are not prepared for Infinity or NaN_
```c
void f(float x, float[] y, struct foo z) {
  assume(!isnan(x));        // May be supportable, not planned
  assert(!isnan(y[0]));     // Not supportable
  assert(!isnan(z.member)); // Not supportable
}
```

With these cases specified, we can detect invalid usage of Infinity and NaN with simple flow analysis.

## Detection / Sink Proposal #2 (not recommended):

This proposed solution takes inspiration from resource leak detection. In this metaphor, a generated infinity or NaN is treated like a resource that must be disposed. [There is a draft WIP of this approach here.](https://github.com/github/codeql-coding-standards/compare/main...michaelrfairhurst/implement-floatingtype-package)

The advantage of this solution is that we do not need to define every way in which a NaN or an Infinity could be misused. Rather, we only need to define a few ways that a NaN or Infinity can be checked, and then find possible Infinities and NaNs that are not checked (or propagated to a value that is checked).

Under this proposal, the following are echecks for infinity and NaN:

- The macros `isnan(x)`, `isinf(x)`, `isfinite(x)` should be considered checks for infinity.
- Reflexive equality checks (`x == x` or `x != x`) should be considered checks for NaN.
- Any comparison operation (`>`, `>=`, `<`, and `<=`) should be considered a check on both positive and negative and positive infinities for an operand if the other is finite.
  - If `a` may only be positive infinity, `a < b` and `a > b` both create a branch of the code where `a` is not positive infinity.
  - If `a` may only be negative infinity, the same as above is the case for negative infinity cases.
  - If `a` may be both positive or negative infinity, then a single check is not sufficient, however detecting an appropriate pair of checks would be a much more difficult implementation

Only local leak detection analysis is feasible at this time. Therefore, this proposal suggests that an infinite or NaN value should be flagged if it goes out of scope before it is checked. _(In other leak detection problems, this would typically be considered a free event to avoid false positives, and that is an option here as well)_.

```c
float g;
void f(void) {
  float l = 1 / 0; // Must be checked
  g = l; // May send Infinity to code not prepared to handle it
  isinf(l); // check occurs too late
}
```

Overall, this option is not recommended for the following reasons:

- Slower performance than Proposal #1
- Limited benefits over Proposal #1
- Detecting out-of-scope cases heavily resembles Proposal #1
- Unused values will be flagged, which is not useful to developers
- Intraprocedural analysis will be difficult to support
- High false positive rate if too few checks are detected, as opposed to the alternative where missing sinks do not create false positives

In this analysis, a method or function call which can generate an infinity, such as `x / y` is treated somewhat like opening a file descriptor, and calls to `isinf(x)` or `isnan(x)` are treated as closing that file descriptor. _There are some differences between how we would approach this and how an actual resource leak detection would be modeled. For instance, we are not searching for use-after-free or double-free bugs, in this metaphor._

Note that resource leak detection is not the same as standard CodeQL flow analysis. For instance, if the below example is analyzed with flow analysis, CodeQL will detect that the result of `fopen` flows into a call to `fclose`. However, this only means it is possible that the program will close the file, it does not mean the file descriptor cannot leak.

```c
void f(bool p) {
  FILE* fd = fopen(...);
  if (p) {
    fclose(fd);
  }
}
```

The drafted leak detection algorithm follows [this paper](https://arxiv.org/html/2312.01912v2/#S2.SS2). In this approach, the program flow from the exit of `f()` is walked backwards. The walk stops upon reaching a call to `fclose()`, and if a call to `fopen()` is reached by this iterative process then that resource could leak.

_Note that this approach still uses flow analysis to determine that fclose(fd) is referring to an initial fopen() call. In the paper, flow analysis is used to find aliases of resources, so that disposing an alias of a resource is handled correctly._

This approach is still neither 100% accurate nor precise. It can generate both false positives and false negatives, though it is hopefully accurate and precise enough for our purposes:

```c
// FALSE POSITIVE: See fprintf call marked (1). Not all successors from (1)
  // call fclose(), and not all predecessors of (1) call fclose() either.
  // All paths dispose fd, but this algorithm does not see that.
  fd = fopen(...);
  if (!cond) {
    fclose(fd);
  }
  fprintf(...); // (1)
  if (cond) {
    fclose(fd);
  }

  // FALSE NEGATIVE: The file descriptor opened at (2) flows into the dispose
  // call at (3) if the values of x and y are not known. However, the resource
  // is only closed when x == y, which is not necessarily the case.
  fds[x] = fopen(...); // (2)
  fclose(fds[y]);      // (3)
```

Nevertheless, their approach is sensible and likely good enough.

Lastly, this approach has the unfortunate downside that unused float values which could be NaN or Infinity will be reported, when they do not have any negative effect on a program (as opposed to the negative effects of leaking unused file descriptors, or unused memory, etc).

## Case study examples

The following is an interesting set of examples and code snippets that come from the open source project [pandas](https://github.com/commaai/panda), which aims to be MISRA compliant and is used for self-driving cars.

These examples are hand picked results from a query that selected expressions with a floating point type along with their upper and lower bounds.

**Example 1**:
```c
float filtered_pcm_speed =
  ((to_push->data[6] << 8) | to_push->data[7])
  * 0.01 / 3.6;
// Disable controls if speeds from ABS and PCM ECUs are too far apart.
bool is_invalid_speed = ABS(filtered_pcm_speed
  - ((float)vehicle_speed.values[0] / VEHICLE_SPEED_FACTOR))
  > FORD_MAX_SPEED_DELTA;
```

While `filter_pcm_speed` cannot be infinity or NaN, it is interesting to see how this value is sanity checked. If this code were refactored such that it could produce NaN, the greater-than check would return false, resulting in a bug. If the condition were flipped (check inside valid range, rather than outside), it would handle NaN correctly. This cannot be captured via static analysis.

**Example 2**:
```c
        float x0 = xy.x[i];
        float y0 = xy.y[i];
        float dx = xy.x[i+1] - x0;
        float dy = xy.y[i+1] - y0;
        // dx should not be zero as xy.x is supposed to be monotonic
        dx = MAX(dx, 0.0001);
        ret = (dy * (x - x0) / dx) + y0;
```

This is an [interpolation function](https://github.com/commaai/panda/blob/dec9223f9726e400e4a4eb91ca19fffcd745f97a/board/safety.h#L538), where `xy` is a struct parameter, with array members `x` and `y` that represent points in the domain and range to interpolate across.

Range analysis is performed with local information only, and therefore, the expression `xy.x[i]` is given the range [-Infinity, Infinity]. This is not a generated infinity. However, the computations of `dx` and `dy` could generate a positive or negative infinity (if both numbers are finite and the result exceeds the maximum float value), they could propagate a positive or negative infinity, and/or they could generate a NaN (if an infinite value is subtracted from itself).

The call to `MAX()` will not check if `dx` = positive infinity, and is unsafe to use with NaN. It prevents a divide-by-zero error, but `ret` could still propagate or generate a NaN or one of the infinities since we know so little about `dy`, `x0`, and `y0`.

It’s worth noting that if `dx` is positive Infinity, then `(x - x0) / dx` will produce zero, rather than propagating the infinity. This may be worth flagging.