// $Id: A16-2-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <algorithm> // Non-compliant - nothing from algorithm header file is used
#include <array>     // Non-compliant - nothing from array header file is used
#include <cstdint>   // Compliant - std::int32_t, std::uint8_t are used
#include <iostream>  // Compliant - cout is used
#include <stdexcept> // Compliant - out_of_range is used
#include <vector>    // Compliant - vector is used
void Fn1() noexcept {
  std::int32_t x = 0;
  // ...
  std::uint8_t y = 0;
  // ...
}
void Fn2() noexcept(false) {
  try {
    std::vector<std::int32_t> v;
    // ...
    std::uint8_t idx = 3;
    std::int32_t value = v.at(idx);
  } catch (std::out_of_range &e) {
    std::cout << e.what() << ’\n’;
  }
}