// $Id: A4-7-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <stdexcept>
std::int8_t Fn1(std::int8_t x, std::int8_t y) noexcept {
  return (x + y); // Non-compliant - may lead to overflow
}
std::int8_t Fn2(std::int8_t x, std::int8_t y) {
  if (x > 100 || y > 100) // Range check
  {
    throw std::logic_error("Preconditions check error");
  }
  return (x + y); // Compliant - ranges of x and y checked before the
  // arithmetic operation
}
std::int16_t Fn3(std::int8_t x, std::int8_t y) noexcept {
  return (static_cast<std::int16_t>(x) + y); // Compliant - std::int16_t type
  // is enough for this arithmetic
  // operation
}
std::uint8_t Fn4(std::uint8_t x, std::uint8_t y) noexcept {
  return (x * y); // Non-compliant - may lead to wrap-around
}
std::int8_t Fn5(std::int16_t x) {
  return static_cast<std::int8_t>(x); // Non-compliant - data loss
}
std::int8_t Fn6(std::int16_t x) {
  return x; // Non-compliant - data loss by implicit conversion
}
void F() {
  std::int8_t x1 =
      Fn1(5, 10); // Compliant - overflow will not occur for these values
  std::int8_t x2 = Fn1(250, 250); // Non-compliant - Overflow occurs
  try {
    std::int8_t x3 = Fn2(250, 250); // Compliant - No overflow, range checks
    // inside fn2() function
  } catch (std::logic_error &) {
    // Handle an error
  }
  std::int16_t x4 = Fn3(250, 250); // Compliant - No overflow, arithmetic
  // operation underlying type is wider than
  // std::int8_t
  std::uint8_t x5 = Fn4(50, 10); // Non-compliant - Wrap-around occurs
  std::int8_t x6 = Fn5(100);     // Compliant - data loss will not occur
  std::int8_t x7 = Fn5(300);     // Non-compliant - Data loss occurs
  std::int8_t x8 = Fn6(300);     // Non-compliant - Data loss occurs
  std::int8_t x9 = 150;
  std::int16_t x10 = static_cast<std::int16_t>(x9 + x9); // Non-compliant
  x10 = x9 + x9;                                         // Non-compliant
  x10 = static_cast<std::int16_t>(x9) + x9;              // Compliant

  std::int8_t x11 = x9 << 5; // Non-compliant

  std::int8_t x12 = 127;
  ++x12; // Non-compliant

  std::uint8_t x13 = 255;
  ++x13; // Non-compliant
}