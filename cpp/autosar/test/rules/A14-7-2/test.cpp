#include "test.hpp"
#include <functional>
#include <vector>

template <> struct s<int> { int t; }; // NON_COMPLIANT

template <> void f<long>() { long t; } // NON_COMPLIANT

struct s1 {};

namespace std {
// has default arg of allocator type declared in std
template <> class vector<s1> {}; // NON_COMPLIANT

template <> class binder1st<s1> {}; // COMPLIANT

} // namespace std
