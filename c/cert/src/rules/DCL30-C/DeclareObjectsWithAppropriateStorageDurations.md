# DCL30-C: Declare objects with appropriate storage durations

This query implements the CERT-C rule DCL30-C:

> Declare objects with appropriate storage durations


## CERT

** REPLACE THIS BY RUNNING THE SCRIPT `scripts/help/cert-help-extraction.py` **

## Implementation notes

The rule checks specifically for pointers to objects with automatic storage duration with respect to the following cases: returned by functions, assigned to function output parameters and assigned to static storage duration variables.

## References

* CERT-C: [DCL30-C: Declare objects with appropriate storage durations](https://wiki.sei.cmu.edu/confluence/display/c)
