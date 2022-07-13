// $Id: A5-1-6.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
void Fn() noexcept
{
  auto lambda1 = []() -> std::uint8_t {
    std::uint8_t ret = 0U;
    // ...
    return ret;
  }; // Compliant
  auto lambda2 = []() {
    // ... 
    return 0U;
  }; // Non-compliant - returned type is not specified
  auto x = lambda1(); // Type of x is std::uint8_t
  auto y = lambda2(); // What is the type of y? 
}