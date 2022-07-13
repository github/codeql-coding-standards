// $Id: A7-1-7.cpp 292454 2017-10-23 13:14:23Z michal.szczepankiewicz $
#include <cstdint>
#include <vector>

typedef std::int32_t *ptr;            // Compliant
typedef std::int32_t *pointer, value; // Non-compliant

void Fn1() noexcept {
  std::int32_t x = 0;                // Compliant
  std::int32_t y = 7, *p1 = nullptr; // Non-compliant
  std::int32_t const *p2, z = 1;     // Non-compliant
}

void Fn2() {
  std::vector<std::int32_t> v{1, 2, 3, 4, 5};
  for (auto iter{v.begin()}, end{v.end()}; iter != end;
       ++iter) // Compliant by exception
  {
    // ...
  }
}

void Fn3() noexcept {
  std::int32_t x{5};
  std::int32_t y{15}; // Non-compliant
  x++;
  ++y; // Non-compliant
  for (std::int32_t i{0}; i < 100; ++i) {
    Fn2(); // Compliant
  }
}