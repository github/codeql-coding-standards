#include <cstdint>

void f1() {
  using std::int16_t;
  using std::int32_t;
  using std::int8_t;

  int8_t l1;
  int16_t l2;
  int32_t l3;

  l2 = l1 + l1;                       // NON_COMPLIANT
  l2 = static_cast<int16_t>(l1) + l1; // COMPLIANT
  l3 = l2 + 1;                        // NON_COMPLIANT
  l3 = static_cast<int32_t>(l2) + 1;  // COMPLIANT
  l3 = l2 + 0x01ffff;                 // COMPLIANT
}

void int16_arg(std::int16_t t);

void test_func_call() {
  std::int8_t l1;
  int16_arg(l1 + l1);                            // NON_COMPLIANT
  int16_arg(static_cast<std::int16_t>(l1 + l1)); // COMPLIANT
  int16_arg(static_cast<std::int8_t>(l1 + l1));  // NON_COMPLIANT
}

std::int16_t test_return(int test) {
  std::int8_t l1;
  if (test > 0) {
    return l1 + l1; // NON_COMPLIANT
  } else if (test < 0) {
    return static_cast<std::int8_t>(l1 + l1); // NON_COMPLIANT
  } else {
    return static_cast<std::int16_t>(l1 + l1); // COMPLIANT
  }
}