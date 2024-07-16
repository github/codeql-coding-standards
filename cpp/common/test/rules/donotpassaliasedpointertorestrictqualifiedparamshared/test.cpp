#include <cstring>

int a[20];

void undefined_behaviour_fn_119(void) {
  std::memcpy(&a[0], &a[1], 10u * sizeof(a[0]));  // NON_COMPLIANT
  std::memmove(&a[0], &a[1], 10u * sizeof(a[0])); // COMPLIANT
  std::memcpy(&a[1], &a[0], 10u * sizeof(a[0]));  // NON_COMPLIANT
  std::memmove(&a[1], &a[0], 10u * sizeof(a[0])); // COMPLIANT
}