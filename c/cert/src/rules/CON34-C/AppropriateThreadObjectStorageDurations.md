# CON34-C: Declare objects shared between threads with appropriate storage durations

This query implements the CERT-C rule CON34-C:

> Declare objects shared between threads with appropriate storage durations


## CERT

** REPLACE THIS BY RUNNING THE SCRIPT `scripts/help/cert-help-extraction.py` **

## Implementation notes

This query does not consider Windows implementations or OpenMP implementations. This query is primarily about excluding cases wherein the storage duration of a variable is appropriate. As such, this query is not concerned if the appropriate synchronization mechanisms are used, such as sequencing calls to `thrd_join` and `free`. An audit query is supplied to handle some of those cases.

## References

* CERT-C: [CON34-C: Declare objects shared between threads with appropriate storage durations](https://wiki.sei.cmu.edu/confluence/display/c)
