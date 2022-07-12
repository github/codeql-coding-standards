#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <algorithm>
#include <functional>

int add_ints(int x, int y) { return x + y; }

void test_bind_used() {
  using namespace std::placeholders;
  auto f1 = std::bind(&add_ints, 42, std::placeholders::_1); // NON_COMPLIANT
  auto f2 = std::bind1st(std::equal_to<int>(), 1);           // NON_COMPLIANT
  auto f3 = std::bind2nd(std::equal_to<int>(), 1);           // NON_COMPLIANT
}