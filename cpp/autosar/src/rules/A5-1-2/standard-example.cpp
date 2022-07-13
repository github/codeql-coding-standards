// $Id: A5-1-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <algorithm>
#include <cstdint>
#include <vector>
void Fn1(const std::vector<std::int32_t>& v)
{
  std::uint64_t sum = 0;
  std::for_each(v.begin(), v.end(), [&](std::int32_t lhs) {
        sum += lhs;
  }); // Non-compliant

  sum = 0;
  std::for_each(v.begin(), v.end(), [&sum](std::int32_t lhs) {
        sum += lhs; }); // Compliant
  }); // Compliant
}
void Fn2() 
{
  constexpr std::uint8_t n = 10; 
  static std::int32_t j = 0;
  [n]() {
    std::int32_t array[n]; // Compliant
    j += 1; // Compliant by exception
  };
}