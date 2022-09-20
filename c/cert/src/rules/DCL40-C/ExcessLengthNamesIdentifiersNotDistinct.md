# DCL40-C: External identifiers shall be distinct

This query implements the CERT-C rule DCL40-C:

> Do not create incompatible declarations of the same function or object


## CERT

** REPLACE THIS BY RUNNING THE SCRIPT `scripts/help/cert-help-extraction.py` **

## Implementation notes

This query considers the first 31 characters of identifiers as significant, as per C99 and reports the case when names are longer than 31 characters and differ in those characters past the 31 first only. This query does not consider universal or extended source characters.

## References

* CERT-C: [DCL40-C: Do not create incompatible declarations of the same function or object](https://wiki.sei.cmu.edu/confluence/display/c)
