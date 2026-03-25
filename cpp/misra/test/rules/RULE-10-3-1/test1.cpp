#include "test.hpp"
#include <cassert>

extern void setValues();
extern std::int32_t getX_File1();
extern std::int32_t getNested_File1();

/* ========== 6. Compliant: anonymous namespace in .cpp file ========== */

namespace { // COMPLIANT: anonymous namespace in source file is fine
std::int32_t localVar = 0;

void localHelper() {
  localVar = 100; // Only visible in this TU, as expected
}
} // namespace

int main() {
  localHelper();
  return 0;
}
