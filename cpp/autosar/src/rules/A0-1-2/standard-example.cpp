// $Id: A0-1-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <algorithm>
#include <cstdint>
#include <vector>
std::uint8_t Fn1() noexcept { return 0U; }
void Fn2() noexcept {
  std::uint8_t x = Fn1();   // Compliant
  Fn1();                    // Non-compliant
  static_cast<void>(Fn1()); // Compliant by exception
}
void Fn3() {
  std::vector<std::int8_t> v{0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5};
  std::unique(v.begin(), v.end());                   // Non-compliant
  v.erase(std::unique(v.begin(), v.end()), v.end()); // Compliant
}