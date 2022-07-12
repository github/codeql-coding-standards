// $Id: A7-5-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
static std::int32_t Fn1(std::int32_t number);
static std::int32_t Fn2(std::int32_t number);
static std::int32_t Fn3(std::int32_t number);
static std::int32_t Fn4(std::int32_t number);
std::int32_t Fn1(std::int32_t number) {
  if (number > 1) {
    number = number * Fn1(number - 1); // Non-compliant
  }

  return number;
}
std::int32_t Fn2(std::int32_t number) {
  for (std::int32_t n = number; n > 1; --n) // Compliant
  {
    number = number * (n - 1);
  }

  return number;
}
std::int32_t Fn3(std::int32_t number) {
  if (number > 1) {
    number = number * Fn3(number - 1); // Non-compliant
  }

  return number;
}
std::int32_t Fn4(std::int32_t number) {
  if (number == 1) {
    number = number * Fn3(number - 1); // Non-compliant
  }

  return number;
}
template <typename T> T Fn5(T value) { return value; }
template <typename T, typename... Args> T Fn5(T first, Args... args) {
  return first + Fn5(args...); // Compliant by exception - all of the
                               // arguments are known during compile time
}
std::int32_t Fn6() noexcept {
  std::int32_t sum = Fn5<std::int32_t, std::uint8_t, float, double>(
      10, 5, 2.5, 3.5); // An example call to variadic template function
  // ...
  return sum;
}
constexpr std::int32_t Fn7(std::int32_t x, std::int8_t n) {
  if (n >= 0) {
    x += x;
    return Fn5(x, --n); // Compliant by exception - recursion evaluated at
    // compile time
  }
  return x;
}