# CON30-C: Clean up thread-specific storage

This query implements the CERT-C rule CON30-C:

> Clean up thread-specific storage


## CERT

** REPLACE THIS BY RUNNING THE SCRIPT `scripts/help/cert-help-extraction.py` **

## Implementation notes

This query does not attempt to ensure that the deallocation function in fact deallocates memory and instead assumes the contract is valid.

## References

* CERT-C: [CON30-C: Clean up thread-specific storage](https://wiki.sei.cmu.edu/confluence/display/c)
