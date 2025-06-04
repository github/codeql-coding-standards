# Invalid deviation code identifier

## Overview

Invalid deviation markers in code have no effect on the results but may indicate confusion over which results will be suppressed. 

Deviation code markers are used to suppress CodeQL Coding Standards results, following the process specified in the "MISRA Compliance 2020" document. There are a range of different deviation markers, with specific syntactic requirements. If those syntactic requirements are not met, the marker is invalid and will not be applied, which is likely contrary to developer expectations.

## Recommendation

Ensure the following requirements are met:

 * All `codeql::<standard>_deviation_begin(..)` markers are paired with a matching `codeql::<standard>_deviation_end(..)` marker.
 * All instances of `codeql::<standard>_deviation` in comments are correctly formatted comment markers, and reference a `code-identifier`s that is specified in a deviation record included in the analysis.
 * All deviation attributes reference `code-identifier`s that are specified in a deviation record included in the analysis.

## References

* [MISRA Compliance 2020 document - Chapter 4.2 (page 12) - Deviations](https://www.misra.org.uk/app/uploads/2021/06/MISRA-Compliance-2020.pdf)