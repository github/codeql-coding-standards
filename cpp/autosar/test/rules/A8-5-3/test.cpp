#include <initializer_list>

void test() {
  auto a1(1);                             // COMPLIANT
  auto a2{1};                             // NON_COMPLIANT
  auto a3 = 1;                            // COMPLIANT
  auto a4 = {1};                          // NON_COMPLIANT
  int a5 = {1};                           // COMPLIANT
  const auto a6(1);                       // COMPLIANT
  const auto a7{1};                       // NON_COMPLIANT
  auto a8 = std::initializer_list<int>(); // COMPLIANT
}