- Fixed an issue found in
  `EnsureActivelyHeldLocksAreReleasedOnExceptionalConditions.ql` which causes
  performance issues with CodeQL bundle version `2.5.9`. To identify catch
  blocks with an unlock statement the query was using the predicate
  `getASuccessor`. Reversing the logic to use `getAPredecessor` resolved the
  issue. 