 - `RULE-7-0-1` - `NoConversionFromBool.ql`:
   - Fixed false positives where a `bool` value is bound to a reference whose
     referenced type is also `bool` (e.g. `bool&`, `const bool&`), including
     when this happens via a generic/forwarding-reference parameter (e.g.
     `template<class T> void f(T&& t)`, or class template forwarding
     constructors such as `std::pair`'s `pair(U1&&, U2&&)`) that happens to be
     instantiated with `bool`. Binding a value to a reference of its own type
     does not change the type or representation of the value, so this is not
     a conversion from `bool` in the sense intended by the rule.
