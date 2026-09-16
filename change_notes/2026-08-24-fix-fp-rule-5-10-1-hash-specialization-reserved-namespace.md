- `RULE-5-10-1` - `PoorlyFormedIdentifier.ql`:
  - Fixed false positives where a local variable or function parameter was reported as
    "defined in reserved namespace" merely because its enclosing function is the body of
    an explicit template specialization that C++ permits users to add to namespace `std`
    (for example, `std::hash<UserType>::operator()`'s parameter and local names).
