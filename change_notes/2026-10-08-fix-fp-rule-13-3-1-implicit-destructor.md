- `RULE-13-3-1` - `MemberSpecifiersNotUsedAppropriately.ql`:
   - Fixed false positives on implicitly declared member functions, most
     commonly the implicit destructor of a class deriving from a class with a
     virtual destructor. The rule applies to user-declared member functions
     only, and an implicit destructor cannot carry `override` or `final`.
