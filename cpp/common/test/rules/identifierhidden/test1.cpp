template <typename T> constexpr bool foo = false;   // COMPLIANT
template <typename T> constexpr bool foo<T> = true; // COMPLIANT