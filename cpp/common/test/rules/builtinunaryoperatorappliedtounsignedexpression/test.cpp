/* The unary minus operator shall not be applied to an expression
whose underlying type is unsigned
*/
#include <cstdint>

int K;
void f() {

  std::uint16_t a = -K; // COMPLIANT
  std::int16_t b = -a;  // NON_COMPLIANT
  std::uint64_t c = K;  // COMPLIANT
  std::int64_t d = -c;  // NON_COMPLIANT
}