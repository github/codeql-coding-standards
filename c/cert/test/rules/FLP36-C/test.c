#include <stdint.h>

void test_conversion_int_to_float() {
  uint64_t i1 = 1234567890L;
  (float)i1;  // NON_COMPLIANT - precision (23 bits) isn't sufficient
  (double)i1; // COMPLIANT - precision (52 bits) is sufficient

  uint32_t i2 = 16777216; // 2^24
  (float)i2;              // COMPLIANT - precision (23 bits) is sufficient
  (double)i2;             // COMPLIANT - precision (52 bits) is sufficient

  uint64_t i3 = 16777217; // 2^24 + 1
  (float)i3;  // NON_COMPLIANT - precision (23 bits) is not sufficient
  (double)i3; // COMPLIANT - precision (52 bits) is sufficient

  uint64_t i4 = 9007199254740992L; // 2^54
  (float)i4;  // NON_COMPLIANT - precision (23 bits) is not sufficient
  (double)i4; // COMPLIANT - precision (52 bits) is sufficient

  uint64_t i5 = 9007199254740993L; // 2^54 + 1
  (float)i5;  // NON_COMPLIANT - precision (23 bits) is not sufficient
  (double)i5; // NON_COMPLIANT[FALSE_POSITIVE] - precision (52 bits) is not
              // sufficient, but our analysis also works with doubles, so cannot
              // precisely represent this value either, and chooses to round
              // down, thus making this case impractical to detect.

  uint64_t i6 = 9007199254740995L; // 2^54 + 3
  (float)i6;  // NON_COMPLIANT - precision (23 bits) is not sufficient
  (double)i6; // NON_COMPLIANT - precision (52 bits) is not sufficient
}