- `RULE-7-0-2` - `NoImplicitBoolConversion.ql`:
   - Fixed false positives where a conversion's source expression type could
     not be resolved to a concrete type (`UnknownType`), which occurs only in
     template-dependent contexts that the extractor cannot resolve, e.g. a
     `constexpr bool` variable template whose initializer is itself another
     dependent variable template such as `std::conjunction_v<...>`.
   - Fixed false positives on reference-dereference conversions (`bool&`/
     `bool&&` to `bool`), which occur e.g. via the compiler-synthesized
     `std::get<N>(...)` call used to implement structured binding
     decomposition (`auto [a, b] = some_pair_or_tuple_expr;` where `b` is
     `bool`). Dereferencing a reference to `bool` does not change the type or
     representation of the value, so this is not a conversion to `bool` in
     the sense intended by the rule.
