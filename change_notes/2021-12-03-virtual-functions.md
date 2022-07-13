- `M9-3-3` - `MemberFunctionConstIfPossible.ql` and `MemberFunctionStaticIfPossible.ql`:
  - Fix for #444 which provides additional tests clarifying how these queries
    treat virtual and pure virtual functions.
  - Modified behavior of query to exempt checking of the static case from
    virtual functions. 
  - Modified behavior of the query to exempt overridden virtual functions as
    well as pure virtual functions.  