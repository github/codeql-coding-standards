- `A0-1-3`, `RULE-0-2-4` - `UnusedLocalFunction.ql`:
  - Fixed false positives for private pure virtual functions used through the non-virtual
    interface (NVI) idiom. `DynamicCallGraph::getTarget()` resolves a virtual call to the
    implementations that may actually run; a pure virtual function has no body, so it is
    never a viable dispatch target and was reported as unused even when a sibling member
    called it. A call is now also counted when the function is the statically named
    callee. Pure virtual functions that are genuinely never called and never overridden
    are still reported.
  - Excluded private member functions of class templates that are never concretely
    instantiated anywhere in the database (and where no sibling member of the same
    class-template pattern is instantiated either). Clang never elaborates a body for the
    members of such patterns, so calls between sibling members of the same
    never-instantiated class (e.g. a public entry point calling a private helper) cannot be
    resolved by the call graph. This is common for generic "plumbing" library code
    (CRTP-style wrappers, etc.) that is only ever
    instantiated by downstream consumers outside of the analyzed codebase.
