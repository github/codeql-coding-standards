//% $Id: A3-1-1.hpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
void F1();                            // Compliant
extern void F2();                     // Compliant
void F3() {}                          // Non-compliant
static inline void F4() {}            // Compliant
template <typename T> void F5(T) {}   // Compliant
std::int32_t a;                       // Non-compliant
extern std::int32_t b;                // Compliant
constexpr static std::int32_t c = 10; // Compliant
namespace ns {
constexpr static std::int32_t d = 100; // Compliant
const static std::int32_t e = 50;      // Compliant
static std::int32_t f;                 // Non-compliant
static void F6() noexcept;             // Non-compliant
} // namespace ns