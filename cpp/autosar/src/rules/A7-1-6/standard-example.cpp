// $Id: A7-1-6.cpp 271687 2017-03-23 08:57:35Z piotr.tanski $
#include <cstdint>
#include <type_traits>

typedef std::int32_t (*fPointer1)(std::int32_t); // Non-compliant

using fPointer2 = std::int32_t (*)(std::int32_t); // Compliant

// template<typename T>
// typedef std::int32_t (*fPointer3)(T); // Non-compliant - compilation error

template <typename T>
using fPointer3 = std::int32_t (*)(T); // Compliant