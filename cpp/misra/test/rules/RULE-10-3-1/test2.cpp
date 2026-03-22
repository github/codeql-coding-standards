#include "test.hpp"
#include <cassert>

/*
 * This file demonstrates the mismatch in expectations.
 * After calling setValues() from file1.cpp:
 * - x is 0 here (different copy)
 * - MyNamespace::y is 42 (shared)
 * - z is 42 (shared)
 * - Outer::nested is 0 here (different copy)
 */

extern void setValues();
extern std::int32_t getX_File1();
extern std::int32_t getNested_File1();

void checkMismatch() {
  setValues();

  /*
   * These demonstrate the MISMATCH - anonymous namespace creates separate
   * copies.
   */
  assert(x == 0);             // file2.cpp's x was never set!
  assert(getX_File1() == 42); // file1.cpp's x was set

  assert(Outer::nested == 0);      // file2.cpp's nested was never set!
  assert(getNested_File1() == 42); // file1.cpp's nested was set

  /* These demonstrate EXPECTED behavior - named namespace and global are shared
   */
  assert(MyNamespace::y == 42); // Shared across TUs
  assert(z == 42);              // Shared across TUs
}

/* ========== 6. Compliant: anonymous namespace in .cpp file ========== */

namespace { // COMPLIANT: anonymous namespace in source file is fine
std::int32_t localVar = 0;

void localHelper() {
  localVar = 100; // Only visible in this TU, as expected
}
} // namespace

int main() {
  checkMismatch();
  localHelper();
  return 0;
}
