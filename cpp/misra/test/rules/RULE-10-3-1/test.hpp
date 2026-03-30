#include <cstdint>

/* ========== 1. Non-compliant: anonymous namespace in header ========== */

namespace { // NON_COMPLIANT: anonymous namespace in header file
inline std::int32_t x = 0;

void helper() {}

class InternalClass {};
} // namespace

/* ========== 2. Compliant: named namespace in header ========== */

namespace MyNamespace { // COMPLIANT: named namespace
inline std::int32_t y = 0;

void publicHelper();

class PublicClass {};
} // namespace MyNamespace

/* ========== 3. Compliant: no namespace ========== */

inline std::int32_t z = 0; // COMPLIANT: no anonymous namespace

void declaredFunction();

/* ========== 4. Non-compliant: nested anonymous namespace ========== */

namespace Outer {
namespace { // NON_COMPLIANT: anonymous namespace in header file
inline std::int32_t nested = 0;
}
} // namespace Outer

/* ========== 5. Non-compliant: anonymous namespace with extern "C" ==========
 */

extern "C" {
namespace { // NON_COMPLIANT: anonymous namespace in header file
inline std::int32_t cStyleVar = 0;
}
}
