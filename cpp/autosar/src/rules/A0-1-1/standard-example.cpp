//% $Id: A0-1-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <array>
#include <cstdint>
std::uint8_t Fn1(std::uint8_t param) noexcept {
  std::int32_t x{0}; // Non-compliant - DU data flow anomaly; Variable defined,
                     // but not used
  if (param > 0) {
    return 1;
  } else {
    return 0;
  }
}
std::int32_t Fn2() noexcept {
  std::int8_t x{10U};          // Compliant - variable defined and will be used
  std::int8_t y{20U};          // Compliant - variable defined and will be used
  std::int16_t result = x + y; // x and y variables used
  x = 0; // Non-compliant - DU data flow anomaly; Variable defined, but x is
  // not subsequently used and goes out of scope
  y = 0; // Non-compliant - DU data flow anomaly; Variable defined, but y is
         // not subsequently used and goes out of scope
  return result;
}
std::int32_t Fn3(std::int32_t param) noexcept {
  std::int32_t x{param + 1}; // Compliant - variable defined, and will be used
                             // in one of the branches
  if (param > 20)
  // However, scope of x variable could be reduced
  {
    return x;
  }
  return 0;
}
std::int32_t Fn4(std::int32_t param) noexcept {
  std::int32_t x{param + 1}; // Compliant - variable defined, and will be used
                             // in some of the branches
  if (param > 20) {
    return x + 1;
  } else if (param > 10) {
    return x;
  } else {
    return 0;
  }
}
void Fn5() noexcept {
  std::array<std::int32_t, 100> arr{};
  arr.fill(1);
  constexpr std::uint8_t limit{100U};
  std::int8_t x{0};
  for (std::uint8_t i{0U}; i < limit; ++i) // Compliant by exception - on the
  // final loop, value of i defined will
  // not be used
  {
    arr[i] = arr[x];
    ++x; // Non-compliant - DU data flow anomaly on the final loop, value
         // defined and not used
  }
}