# DCL37-C: Do not declare or define a reserved identifier

This query implements the CERT-C rule DCL37-C:

> Do not declare or define a reserved identifier


## CERT

** REPLACE THIS BY RUNNING THE SCRIPT `scripts/help/cert-help-extraction.py` **

## Implementation notes

This query does not consider identifiers described in the future library directions section of the standard. This query also checks for any reserved identifier as declared regardless of whether its header file is included or not.

## References

* CERT-C: [DCL37-C: Do not declare or define a reserved identifier](https://wiki.sei.cmu.edu/confluence/display/c)
